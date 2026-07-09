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
         t003,          " Clases de documento
         t001z,         " additional CC information
         lfa1.          " vendor master data


TYPES: BEGIN OF ty_s_download,
         data TYPE c LENGTH 255,
       END OF ty_s_download,
       ty_t_download TYPE TABLE OF ty_s_download.

TYPES: BEGIN OF ty_s_outtab,
         bukrs    TYPE bukrs,
         gjahr    TYPE gjahr,
         belnr    TYPE char13, " belnr_d,
         xblnr    TYPE xblnr,
         xblnr2   TYPE numc15,
         budat    TYPE budat,
         bldat    TYPE bldat,
         blart    TYPE blart,
         name1    TYPE name1,
         stcd1    TYPE stcd1,
         brsch    TYPE brsch,
         taxbash1 TYPE hwste, " AFECTO
         taxbash2 TYPE hwste, " EXENTO
         taxbash3 TYPE hwste, " IVA
         taxbash4 TYPE hwste, " IVA NO RECUPERADO
         taxbash5 TYPE hwste, " OTROS IMPUESTOS
         sum_all  TYPE hwste, " VALOR TOTAL
         waers    TYPE waers,
       END OF ty_s_outtab,
       ty_t_outtab TYPE TABLE OF ty_s_outtab.

DATA : BEGIN OF ti_resumen OCCURS 0,
         blart    TYPE blart,
         desbl    TYPE char38,
         cvige    TYPE i,
         cnulo    TYPE i,
         taxbash1 TYPE hwste, " AFECTO
         taxbash2 TYPE hwste, " EXENTO
         taxbash3 TYPE hwste, " IVA
         sum_all  TYPE hwste, " VALOR TOTAL
       END OF ti_resumen.


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

CLASS lcl_event_receiver DEFINITION DEFERRED.

DATA:gt_sort                     TYPE slis_t_sortinfo_alv,
     gt_fieldcat                 TYPE slis_t_fieldcat_alv,
     gt_fieldcat_100             TYPE lvc_t_fcat,
     gs_variant                  TYPE disvariant,
     g_repid                     TYPE sy-repid,
     gs_layout                   TYPE slis_layout_alv,
     g_callback_html_top_of_page TYPE slis_formname VALUE 'HTML_TOP_OF_PAGE',
     gt_bkpf                     TYPE TABLE OF bkpf,
     gt_bseg                     TYPE TABLE OF bseg,
     gt2_bseg                    TYPE TABLE OF bseg,
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

DATA: t_cvige    TYPE i,
      t_cnulo    TYPE i,
      desbl      TYPE char38,
      t_taxbash1 TYPE hwste, " AFECTO
      t_taxbash2 TYPE hwste, " EXENTO
      t_taxbash3 TYPE hwste, " IVA
      t_sum_all  TYPE hwste.  " VALOR TOTAL


CONSTANTS: c_line   TYPE c LENGTH 205  VALUE '-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
           c_line_2 TYPE c LENGTH 121  VALUE '----------------------------------------------------------------------------------------------------------------------------------------'.




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

    DATA: ls_toolbar  TYPE stb_button.


* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.
* append an icon to show booking table
    CLEAR ls_toolbar.
    MOVE 'BOOKINGS' TO ls_toolbar-function.
    MOVE icon_employee TO ls_toolbar-icon.
    MOVE 'Show Bookings'(111) TO ls_toolbar-quickinfo.
    MOVE 'Detail'(112) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

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






PARAMETERS: p_bukrs TYPE bukrs OBLIGATORY.
SELECT-OPTIONS: s_belnr FOR bkpf-belnr.
PARAMETERS: p_gjahr TYPE gjahr OBLIGATORY.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK block2  WITH FRAME TITLE TEXT-012.
SELECT-OPTIONS:s_budat FOR bkpf-budat,
               s_xblnr FOR bkpf-xblnr.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF SCREEN 1001 AS SUBSCREEN.
SELECT-OPTIONS:  s_monat  FOR bkpf-monat NO-EXTENSION NO INTERVALS OBLIGATORY.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF SCREEN 1001.


SELECTION-SCREEN BEGIN OF SCREEN 1002 AS SUBSCREEN.
SELECT-OPTIONS : p_brte_1 FOR t003-blart NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS : p_brte_2 FOR t003-blart NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS : p_brte_3 FOR t003-blart NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS : p_brte_4 FOR t003-blart NO-EXTENSION OBLIGATORY.

*PARAMETERS: p_brte_1 TYPE blart,
*            p_brte_2 TYPE blart,
*            p_brte_3 TYPE blart,
*            p_brte_4 TYPE blart,
*            p_brte_5 TYPE blart,
*            p_brte_6 TYPE blart,
*            p_brte_7 TYPE blart .

SELECTION-SCREEN END OF SCREEN 1002.

SELECTION-SCREEN BEGIN OF SCREEN 1003 AS SUBSCREEN.

SELECT-OPTIONS : p_brtn_1 FOR t003-blart NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS : p_brtn_2 FOR t003-blart NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS : p_brtn_3 FOR t003-blart NO-EXTENSION OBLIGATORY.
SELECT-OPTIONS : p_brtn_4 FOR t003-blart NO-EXTENSION OBLIGATORY.


*PARAMETERS: p_brtn_1 TYPE blart,
*            p_brtn_2 TYPE blart,
*            p_brtn_3 TYPE blart,
*            p_brtn_4 TYPE blart,



*            p_brtn_5 TYPE blart,
*            p_brtn_6 TYPE blart,
*            p_brtn_7 TYPE blart,
*            p_brtn_8 TYPE blart,
*            p_brtn_9 TYPE blart.
SELECTION-SCREEN END OF SCREEN 1003.


SELECTION-SCREEN BEGIN OF BLOCK tabs WITH FRAME TITLE TEXT-155.
SELECTION-SCREEN BEGIN OF TABBED BLOCK opt FOR 9 LINES.
SELECTION-SCREEN TAB (21) tab1 USER-COMMAND user1
                 DEFAULT SCREEN 1001.
SELECTION-SCREEN TAB (21) tab2 USER-COMMAND user2
                 DEFAULT SCREEN 1002.
SELECTION-SCREEN TAB (21) tab3 USER-COMMAND user3
                 DEFAULT SCREEN 1003.
SELECTION-SCREEN END OF BLOCK opt.
SELECTION-SCREEN END OF BLOCK tabs.


SELECTION-SCREEN BEGIN OF BLOCK block3  WITH FRAME TITLE TEXT-013.
PARAMETERS: p_path TYPE localfile LOWER CASE.
SELECTION-SCREEN END OF BLOCK block3.
