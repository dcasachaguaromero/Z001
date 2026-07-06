*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include ZFILB002_TOP                                      Report ZFILB002
*&
*&---------------------------------------------------------------------*

REPORT   zfilb002.

TYPE-POOLS slis.

TABLES : bkpf,           " document header information
         bseg,          " document detail information
         bset,          " document tax information
         t001,          " Company code information
         t001z,         " additional CC information
         tsad4,
         lfa1,           " vendor master data
         csks.


TYPES: BEGIN OF ty_s_download,
         data TYPE c LENGTH 255,
       END OF ty_s_download,
       ty_t_download TYPE TABLE OF ty_s_download.

TYPES: BEGIN OF ty_s_outtab,
         bukrs      TYPE bukrs,
         gjahr      TYPE gjahr,
         budat      TYPE budat,
         blart      TYPE blart,
         ltext      TYPE ltext_003t,
         belnr      TYPE belnr_d,
         name2      LIKE kna1-name1,
         stcd2      LIKE kna1-stcd1,
         name1      LIKE lfa1-name1,
         stcd1      LIKE lfa1-stcd1,
         bldat      TYPE bldat,
         xblnr      TYPE xblnr,
         bktxt      LIKE bkpf-bktxt,
         buzei      LIKE bseg-buzei,
         koart      LIKE bseg-koart,
         bschl      LIKE bseg-bschl,
         hkont      LIKE bseg-hkont,
         txt50      LIKE skat-txt50,
         shkzg      LIKE bseg-shkzg,
         mwskz      LIKE bseg-mwskz,
         qsskz      LIKE bseg-qsskz,
         wrbtr      LIKE bseg-wrbtr,
         pswbt      LIKE bseg-pswbt,
         pswsl      LIKE bseg-pswsl,
         sgtxt      LIKE bseg-sgtxt,
         zuonr      LIKE bseg-zuonr,
         kunnr      LIKE bseg-kunnr,
         lifnr      LIKE bseg-lifnr,
         kostl      LIKE bseg-kostl,
         prctr      LIKE bseg-prctr,
         zzprestac  LIKE bseg-zzprestac,
         zzunid_pro LIKE bseg-zzunid_pro,
         zzdesc_est LIKE bseg-zzdesc_est,
         zzmot_emis LIKE bseg-zzmot_emis,
         zzrut_terc LIKE bseg-zzrut_terc,
         name3      LIKE lfa1-name1,
         zz_agencia LIKE bseg-zz_agencia,
         augdt      LIKE bseg-augdt,
         augbl      LIKE bseg-augbl,
         fdtag      LIKE bseg-fdtag,
         zfbdt      LIKE bseg-zfbdt,
         zterm      LIKE bseg-zterm,
         zbd1t      LIKE bseg-zbd1t,
         waers      LIKE bkpf-waers,
         stblg      LIKE bkpf-stblg,
         aedat      LIKE bkpf-aedat,
         usnam      LIKE bkpf-usnam,
         xref2_hd   LIKE bkpf-xref2_hd,
         xref1      LIKE bseg-xref1,
         xref2      LIKE bseg-xref2,
         xref3      LIKE bseg-xref3,
         zlsch      LIKE bseg-zlsch,
         hbkid      LIKE bseg-hbkid,
         zlspr      LIKE bseg-zlspr,
         dmbtr      TYPE bseg-dmbtr, "V1- Waldo Alarcón - Visionone - 17-03-2022
       END OF ty_s_outtab,
       ty_t_outtab TYPE TABLE OF ty_s_outtab.

TYPES: BEGIN OF ty_s_iva_doc_e,
         descripcion TYPE c LENGTH 60,
         monto_cdc   TYPE dmbtr,
         monto_sdc   TYPE dmbtr,
         moneda      TYPE waers,
       END OF ty_s_iva_doc_e.
TYPES: BEGIN OF ty_s_cl_doc,
         descripcion TYPE c LENGTH 60,
         cantidad    TYPE i,
         monto       TYPE dmbtr,
         moneda      TYPE waers,
         orden       TYPE c LENGTH 2,
       END OF ty_s_cl_doc,
       ty_t_cl_doc TYPE TABLE OF ty_s_cl_doc.

DATA: BEGIN OF t_23 OCCURS 0,
        ndoc TYPE belnr_d,
        tot  TYPE char10,
      END OF  t_23.

TYPES: BEGIN OF ty_sociedad,
         bukrs TYPE t001-bukrs,
         butxt TYPE t001-butxt,
         adrnr TYPE t001-adrnr,
         name1 TYPE adrc-name1,
         waers TYPE t001-waers,
         paval TYPE t001z-paval,
       END OF ty_sociedad.

DATA: ti_sociedad TYPE TABLE OF ty_sociedad,
      wa_sociedad TYPE ty_sociedad.

CLASS lcl_event_receiver DEFINITION DEFERRED.

DATA:gt_sort                     TYPE slis_t_sortinfo_alv,
     gt_fieldcat                 TYPE slis_t_fieldcat_alv,
     it_fieldcat_excel           TYPE slis_t_fieldcat_alv,
     gt_fieldcat_100             TYPE lvc_t_fcat,
     gs_variant                  TYPE disvariant,
     g_repid                     TYPE sy-repid,
     gs_layout                   TYPE slis_layout_alv,
     g_callback_html_top_of_page TYPE slis_formname VALUE 'HTML_TOP_OF_PAGE',
     gt_bkpf                     TYPE TABLE OF bkpf,
     gt_bseg                     TYPE TABLE OF bseg,
     gt_bset                     TYPE TABLE OF bset,
     gr_blart                    TYPE TABLE OF rng_blart,
     gt_zfigiro                  TYPE TABLE OF zfigiro,
     gt_outtab                   TYPE ty_t_outtab,
     gt_download                 TYPE ty_t_download,
     gs_iva_doc_e                TYPE ty_s_iva_doc_e,
     gt_cl_doc                   TYPE ty_t_cl_doc,
     g_html_height_top           TYPE i VALUE 30,
     g_address_value             TYPE addr1_val,
     g_paval                     TYPE paval,
     g_butxt                     TYPE butxt,
     g_path                      TYPE c LENGTH 255,
     g_num                       TYPE i,
     g_line                      TYPE i VALUE 50,
     grid1                       TYPE REF TO cl_gui_alv_grid,
     custom_container1           TYPE REF TO cl_gui_custom_container,
     event_receiver              TYPE REF TO lcl_event_receiver..
DATA sumxreg TYPE hwste.
DATA gv_waers TYPE waers. "V1- Waldo Alarcón - Visionone - 17-03-2022

DATA: gt_lfa1  TYPE TABLE OF lfa1,
      ls_lfa1  TYPE lfa1,

      gt_lfb1  TYPE TABLE OF lfb1,
      ls_lfb1  TYPE lfb1,

      gt_kna1  TYPE TABLE OF kna1,
      ls_kna1  TYPE kna1,

      gt_knb1  TYPE TABLE OF knb1,
      ls_knb1  TYPE knb1,

      gt_skat  TYPE TABLE OF skat,
      ls_skat  TYPE skat,

      gt_t003t TYPE TABLE OF t003t,
      ls_t003t TYPE t003t.


DATA: BEGIN OF it_dir OCCURS 0,
        dir TYPE zdir,
      END OF it_dir.

DATA: BEGIN OF it_match OCCURS 0,
        shlpname  LIKE ddshretval-shlpname,
        fieldname LIKE ddshretval-fieldname,
        recordpos LIKE ddshretval-recordpos,
        fieldval  LIKE ddshretval-fieldval,
        retfield  LIKE ddshretval-retfield,
      END OF it_match.

DATA: BEGIN OF it_filedir OCCURS 10.
        INCLUDE STRUCTURE salfldir.
      DATA: END OF it_filedir.

DATA: l_it_file_table TYPE TABLE OF sdokpath WITH HEADER LINE.
DATA: l_it_dir_table TYPE TABLE OF sdokpath.

DATA fname TYPE string.

DATA: globaldirectory TYPE dirname_al11.

DATA: gt_outt TYPE STANDARD TABLE OF cst_rswatch01_alv,
      ws_outt TYPE cst_rswatch01_alv.

DATA: my_name(20).

CONSTANTS:
* for USER_DIR configuration
  all_server TYPE string VALUE 'all'.

DATA: BEGIN OF eps_txtbuf OCCURS 0.
        INCLUDE STRUCTURE epsteco.
      DATA: END   OF eps_txtbuf.


DATA: BEGIN OF t_titulo OCCURS 0,
        titulo(20),
      END OF t_titulo.

DATA : BEGIN OF t_salida,
         linea(15000),
       END OF t_salida.

CONSTANTS: c_line   TYPE c LENGTH 255  VALUE '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
           c_line_2 TYPE c LENGTH 255  VALUE '----------------------------------------------------------------------------------------------------------------------------------------'.




*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS:
      handle_toolbar
                  FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

      handle_user_command
                  FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.

  PRIVATE SECTION.

ENDCLASS.                    "lcl_event_receiver DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_toolbar.

*    DATA: ls_toolbar  TYPE stb_button.
*
*
** append a separator to normal toolbar
*    CLEAR ls_toolbar.
*    MOVE 3 TO ls_toolbar-butn_type.
*    APPEND ls_toolbar TO e_object->mt_toolbar.
** append an icon to show booking table
*    CLEAR ls_toolbar.
*    MOVE 'BOOKINGS' TO ls_toolbar-function.
*    MOVE icon_employee TO ls_toolbar-icon.
*    MOVE 'Show Bookings'(111) TO ls_toolbar-quickinfo.
*    MOVE 'Detail'(112) TO ls_toolbar-text.
*    MOVE ' ' TO ls_toolbar-disabled.
*    APPEND ls_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.                    "handle_toolbar
*-------------------------------------------------------------------
  METHOD handle_user_command.
* § 3.In event handler method for event USER_COMMAND: Query your
*   function codes defined in step 2 and react accordingly.

    DATA: lt_rows TYPE lvc_t_row.

    CASE e_ucomm.
      WHEN 'BOOKINGS'.
*        CALL METHOD grid1->get_selected_rows
*          IMPORTING
*            et_index_rows = lt_rows.
*        CALL METHOD cl_gui_cfw=>flush.
*        IF sy-subrc NE 0.
** add your handling, for example
*          CALL FUNCTION 'POPUP_TO_INFORM'
*            EXPORTING
*              titel = g_repid
*              txt2  = sy-subrc
*              txt1  = 'Error in Flush'(500).
*        ELSE.
**          PERFORM show_booking_table TABLES lt_rows.
*        ENDIF.
    ENDCASE.
  ENDMETHOD.                           "handle_user_command
ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION


SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-008.
** INI RVY 10.08.2023
*PARAMETERS:     p_bukrs TYPE bukrs      OBLIGATORY.
*PARAMETERS:     p_gjahr TYPE gjahr      OBLIGATORY.
SELECT-OPTIONS: p_bukrs FOR bkpf-bukrs   OBLIGATORY.
SELECT-OPTIONS: p_gjahr FOR bkpf-gjahr   OBLIGATORY.
** FIN RVY 10.08.2023
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2  WITH FRAME TITLE TEXT-012.
SELECT-OPTIONS: s_budat  FOR bkpf-budat OBLIGATORY,
                p_brte_1 FOR bkpf-blart,
                s_belnr  FOR bkpf-belnr,
                s_bldat  FOR bkpf-bldat,
                s_xref2  FOR tsad4-prefix_txt MATCHCODE OBJECT zorigen, " bkpf-xref2_hd,
                s_hkont  FOR bseg-hkont,
                s_zzmot  FOR bseg-zzmot_emis,
                s_kostl  FOR csks-kostl,
                s_buzei  FOR bseg-buzei NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block3  WITH FRAME TITLE TEXT-013.
PARAMETERS: x_ser LIKE itemset-xnorm AS CHECKBOX .
PARAMETER: p_fdir TYPE pfeflnamel .
SELECTION-SCREEN END OF BLOCK block3.

PARAMETERS: pa_vari TYPE slis_vari.

AT SELECTION-SCREEN.
  IF p_bukrs-high = ' '.
     p_bukrs-high = p_bukrs-low.
  ENDIF.
  IF p_gjahr-high = ' '.
     p_gjahr-high = p_gjahr-low.
  ENDIF.
*
  SELECT bukrs
    INTO TABLE @DATA(ti_soc)
    FROM t001
    WHERE bukrs IN @p_bukrs.
  LOOP AT ti_soc INTO DATA(wa_soc).
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
          ID 'BUKRS' FIELD wa_soc-bukrs
          ID 'ACTVT' FIELD '03'.

    IF sy-subrc <> 0.
      MESSAGE e004(zfi) WITH 'Sin autorización para Sociedad.' p_bukrs.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zzmot-low.
  PERFORM buscar_motivo_emis CHANGING s_zzmot-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_zzmot-high.
  PERFORM buscar_motivo_emis CHANGING s_zzmot-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_vari.
  PERFORM alv_variant_f4 CHANGING pa_vari.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fdir.
  CLEAR: it_match, gt_outtab.
  REFRESH: it_match, gt_outtab.
  PERFORM:
  append_db_home,
  append_dir_from_profile_param USING 'DIR_ATRA',
  append_dir_from_profile_param USING 'DIR_BINARY',
  append_dir_from_profile_param USING 'DIR_CCMS',
  append_dir_from_profile_param USING 'DIR_CT_LOGGING',
  append_dir_from_profile_param USING 'DIR_CT_RUN',
  append_dir_from_profile_param USING 'DIR_DATA',
  append_dir_from_profile_param USING 'DIR_DBMS',
  append_dir_from_profile_param USING 'DIR_EXECUTABLE',
  append_dir_from_profile_param USING 'DIR_EXE_ROOT',
  append_dir_from_profile_param USING 'DIR_GEN',
  append_dir_from_profile_param USING 'DIR_GEN_ROOT',
  append_dir_from_profile_param USING 'DIR_GLOBAL',
  append_dir_from_profile_param USING 'DIR_GRAPH_EXE',
  append_dir_from_profile_param USING 'DIR_GRAPH_LIB',
  append_dir_from_profile_param USING 'DIR_HOME',
  append_dir_from_profile_param USING 'DIR_INSTALL',
  append_dir_from_profile_param USING 'DIR_INSTANCE',
  append_dir_from_profile_param USING 'DIR_LIBRARY',
  append_dir_from_profile_param USING 'DIR_LOGGING',
  append_dir_from_profile_param USING 'DIR_MEMORY_INSPECTOR',
  append_dir_from_profile_param USING 'DIR_PAGING',
  append_dir_from_profile_param USING 'DIR_PUT',
  append_dir_from_profile_param USING 'DIR_PERF',
  append_dir_from_profile_param USING 'DIR_PROFILE',
  append_dir_from_profile_param USING 'DIR_PROTOKOLLS',
  append_dir_from_profile_param USING 'DIR_REORG',
  append_dir_from_profile_param USING 'DIR_ROLL',
  append_dir_from_profile_param USING 'DIR_RSYN',
  append_dir_from_profile_param USING 'DIR_SAPUSERS',
  append_dir_from_profile_param USING 'DIR_SETUPS',
  append_dir_from_profile_param USING 'DIR_SORTTMP',
  append_dir_from_profile_param USING 'DIR_SOURCE',
  append_dir_from_profile_param USING 'DIR_TEMP',
  append_dir_from_profile_param USING 'DIR_TRANS',
  append_dir_from_profile_param USING 'DIR_TRFILES',
  append_dir_from_profile_param USING 'DIR_TRSUB',
  append_dir_saphostagent.

  SORT gt_outt BY sap_dir.

  PERFORM append_user_dirs.

  LOOP AT gt_outt INTO ws_outt.
    it_dir-dir = ws_outt-dirname+0(50).
    APPEND it_dir.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'EERR'
      window_title    = 'Descargar Archivo'
      value_org       = 'S'
    TABLES
      value_tab       = it_dir
      return_tab      = it_match
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc EQ 0.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
    SORT it_match .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
    READ TABLE it_match INDEX 1.
    MOVE it_match-fieldval TO p_fdir.
  ENDIF.
