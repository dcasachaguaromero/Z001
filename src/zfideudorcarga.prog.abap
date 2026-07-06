*&---------------------------------------------------------------------*
*& Report  ZFIDEUDORCARGA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFIDEUDORCARGA.

TYPE-POOLS: truxs.
type-pools: slis.
tables: knb1 , kna1.
PARAMETERS: p_file TYPE  rlgrap-filename.
constants: top_of_page  type slis_formname  value 'TOP_OF_PAGE',
           top_of_list  type slis_formname  value 'TOP_OF_LIST'.
constants: end_of_list  type slis_formname  value 'END_OF_LIST',
           user_command type slis_formname  value 'ALV_USER_COMMAND' .
DATA: k_status       TYPE slis_formname VALUE 'STANDARD_KR01',
      k_user_command TYPE slis_formname VALUE 'USER_COMMAND',
      pos type i.
DATA: BEGIN OF SPL OCCURS 0,
        VAL(1023),
      END OF SPL,
      sindx TYPE I.

tables: sscrfields.
"Una variable a modo de contador
DATA: CONTADOR TYPE I.

DATA:       r_grid      TYPE REF TO cl_gui_alv_grid,
            s2_BUKRS LIKE LFB1-BUKRS.

DATA:      alv_fieldcat    TYPE slis_t_fieldcat_alv,
           wa_alv_fieldcat TYPE slis_fieldcat_alv,
           alv_layout      TYPE slis_layout_alv,
           gd_repid        LIKE sy-repid.

DATA: BEGIN OF wa_datatab OCCURS 0,
      col1(4)    TYPE c,
      col2(40)    TYPE c,
      col3(10)    TYPE c,
      col4(12)    TYPE c,
      col5(30)    TYPE c,
      END OF wa_datatab.
* DATA: it_datatab type standard table of t_datatab,
DATA:       rutsg(10) type c,
      p_t_kunnr(10) type c.
*      wa_datatab type t_datatab.
DATA t_zdeudor LIKE zdeudor OCCURS 1 WITH HEADER LINE.
DATA t_return   LIKE bapiret2 OCCURS 1 WITH HEADER LINE.

DATA: it_raw TYPE truxs_t_text_data.

* At selection screen
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*  IF  p_file IS INITIAL.
*        MESSAGE 'No sales doc exists' type 'E'.
*  ENDIF.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name  = p_file.


***********************************************************************
*START-OF-SELECTION.
START-OF-SELECTION.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR        =
      i_line_header            =  'X'
      i_tab_raw_data           =  it_raw       " WORK TABLE
      i_filename               =  p_file
    TABLES
      i_tab_converted_data     = wa_datatab "it_datatab[]    "ACTUAL DATA
   EXCEPTIONS
      conversion_failed        = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


***********************************************************************
* END-OF-SELECTION.
END-OF-SELECTION.
* PERFORM alv_setup.
 PERFORM OBTENER_DATOS.
* PERFORM display_alv.

FORM OBTENER_DATOS.
*  WRITE: AT (40)  'NOMBRE',
*          AT (10)   'RUT',
*          AT (5)   'SOCIEDAD',
**         AT (10)    'CUENTA_ASOCIADA',
*          AT (20)   'COD_BANCO',
*          AT (20)   'CTACTE',
*          AT (10)   'ID_SAP'.
  LOOP AT wa_datatab. "it_datatab INTO wa_datatab.
    CONTADOR = SY-TABIX.
* valido si existe el deudor en las tablas
    SELECT SINGLE * FROM kna1  WHERE  stcd1 =  wa_datatab-col4.

    IF sy-subrc = 0.
* si existe valido si esta en la tabla
     SELECT SINGLE * FROM   knb1  WHERE kunnr =  kna1-kunnr
                                  AND   bukrs =   wa_datatab-col1.

        wa_datatab-col5 = kna1-kunnr.
    else.
          wa_datatab-col5 = ''.
    endif.
* si no esta se crea
     IF sy-subrc <> 0.


        IF wa_datatab-col5 IS INITIAL.
          t_zdeudor-accion = '10'.
          t_zdeudor-kunnr  = ''.
        ELSE.
          t_zdeudor-accion = '10'.
          t_zdeudor-kunnr  =  wa_datatab-col5.
*          p_t_lifnr        =  p_ti_detalle1-customer.
        ENDIF.
"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    t_zdeudor-bukrs = wa_datatab-col1.
    t_zdeudor-ktokd = 'Z001'.
    t_zdeudor-title = ''.
    t_zdeudor-name1 = wa_datatab-col2.
    t_zdeudor-name2 = ''.
    rutsg = wa_datatab-col4.
    REPLACE '-'  WITH '' INTO rutsg.
    CONDENSE rutsg NO-GAPS.
    t_zdeudor-sort1 = rutsg.
    t_zdeudor-sort2 = ''.
    t_zdeudor-street = ''.
    t_zdeudor-house_num1 = ''.
    t_zdeudor-house_num2 = ''.
    t_zdeudor-pstlz   = ''.
    t_zdeudor-ort01   = ''.
    t_zdeudor-ort02   = ''.
    t_zdeudor-land1   = 'CL'.
    t_zdeudor-regio   = '13'.
    t_zdeudor-stcd1   =  wa_datatab-col4.
    t_zdeudor-akont   =  wa_datatab-col3.
**************************************************************************************************
* Se agregan 2 campos que no estaban agregados al proceso de creacion de deudor 03-09-2015 HCD
    t_zdeudor-fdgrv   = 'E1'.
    t_zdeudor-zterm1  = 'ZD01'.
**************************************************************************************************
   APPEND t_zdeudor.


"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
           CALL FUNCTION 'ZFIRFC002'
            TABLES
              t_deudor = t_zdeudor
              return   = t_return.

          READ TABLE t_return WITH KEY type = 'S'
                               id = '21'.
          IF sy-subrc = 0.
            p_t_kunnr = t_return-message_v2+0(10).
            IF p_t_kunnr IS INITIAL.
               wa_datatab-col5 = kna1-kunnr.
            ELSE.
               wa_datatab-col5 =   p_t_kunnr.
            ENDIF.
          ELSE.
            wa_datatab-col5 =   'ERROR RUT'.
          ENDIF.


     else.
        wa_datatab-col5 =   kna1-kunnr.
     endif.
     MODIFY wa_datatab INDEX CONTADOR.
     CLEAR: p_t_kunnr.
     CLEAR: t_zdeudor.

  ENDLOOP.

  write:/10 sy-uline(118).   "sy-uline(67) display a line 67 chars long
  write:/10  sy-vline,   "sy-vline creates a vertical line
        (10) 'Soc.' COLOR COL_HEADING, sy-vline, "COLOR changes background colour
        (40) 'Nombre'  COLOR COL_HEADING, sy-vline,
        (10) 'Cuenta Asociada'  COLOR COL_HEADING, sy-vline,
        (12) 'Rut'  COLOR COL_HEADING, sy-vline,
        (30) 'ID_SAP'  COLOR COL_HEADING, sy-vline.

 write:/10 sy-uline(118).     "display a line 67 chars long
LOOP AT wa_datatab.
 WRITE: /10 sy-vline,
          (10)   wa_datatab-col1, sy-vline,
          (40)   wa_datatab-col2, sy-vline,
          (10)    wa_datatab-col3, sy-vline,
          (12)    wa_datatab-col4, sy-vline,
          (30)    wa_datatab-col5, sy-vline.
  ENDLOOP.
write:/10 sy-uline(118). "display a line 67 chars long

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  alv_setup
*&---------------------------------------------------------------------*
*
*  Setup of the columns in the ALV grid
*
*----------------------------------------------------------------------*
FORM alv_setup.

 CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                  "This is a key column
  wa_alv_fieldcat-fieldname = 'col1'.        "Name of the table field
  wa_alv_fieldcat-seltext_s = 'NOMBRE'.  "Short column heading
  wa_alv_fieldcat-seltext_m = 'NOMBRE'.  "Medium column heading
  wa_alv_fieldcat-seltext_l = 'NOMBRE'.  "Long column heading
  APPEND wa_alv_fieldcat TO alv_fieldcat.

  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                  "This is a key column
  wa_alv_fieldcat-fieldname = 'col2'.        "Name of the table field
  wa_alv_fieldcat-seltext_s = 'RUT'.  "Short column heading
  wa_alv_fieldcat-seltext_m = 'RUT'.  "Medium column heading
  wa_alv_fieldcat-seltext_l = 'RUT'.  "Long column heading
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'col3'.
  wa_alv_fieldcat-seltext_s = 'SOCIEDAD'.
  wa_alv_fieldcat-seltext_m = 'SOCIEDAD'.
  wa_alv_fieldcat-seltext_l = 'SOCIEDAD'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'col4'.
  wa_alv_fieldcat-seltext_s = 'CTA_ASOCIADA'.
  wa_alv_fieldcat-seltext_m = 'CTA_ASOCIADA'.
  wa_alv_fieldcat-seltext_l = 'CTA_ASOCIADA'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'col5'.
  wa_alv_fieldcat-seltext_s = 'COD_BANCO'.
  wa_alv_fieldcat-seltext_m = 'COD_BANCO'.
  wa_alv_fieldcat-seltext_l = 'COD_BANCO'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'col6'.
  wa_alv_fieldcat-seltext_s = 'CTA_CTE'.
  wa_alv_fieldcat-seltext_m = 'CTA_CTE'.
  wa_alv_fieldcat-seltext_l = 'CTA_CTE'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  CLEAR wa_alv_fieldcat.
  wa_alv_fieldcat-key = ''.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'col7'.
  wa_alv_fieldcat-seltext_s = 'ID_SAP'.
  wa_alv_fieldcat-seltext_m = 'ID_SAP'.
  wa_alv_fieldcat-seltext_l = 'ID_SAP'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.



ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  display_alv
*&---------------------------------------------------------------------*
*  Display data in the ALV grid
*
*----------------------------------------------------------------------*
FORM display_alv.

  gd_repid = sy-repid.

* Configure layout of screen
  alv_layout-colwidth_optimize = 'X'.
  alv_layout-zebra             = 'X'.
  alv_layout-no_min_linesize   = 'X'.

* Now call display function
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
           i_callback_program       = gd_repid
           i_callback_top_of_page   = 'TOP_OF_PAGE_SETUP' "Ref to form
           is_layout                = alv_layout
           it_fieldcat              = alv_fieldcat
*           i_callback_user_command  = user_command
            i_save = 'X'
      TABLES
            t_outtab                = wa_datatab
       EXCEPTIONS
         program_error            = 1
         OTHERS                   = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " display_alv

*&---------------------------------------------------------------------*
*&      Form  top_of_page_setup
*&---------------------------------------------------------------------*
*
*  Set-up what to display at the top of the ALV pages
*  Note that the link to this form is in the
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' parameter
*  i_callback_top_of_page   = 'TOP_OF_PAGE' in form display_alv
*----------------------------------------------------------------------*
FORM top_of_page_setup.

  DATA: t_header TYPE slis_t_listheader,
        wa_header TYPE slis_listheader.


  wa_header-typ  = 'H'.
  wa_header-info = 'LISTADO CARGADO DE ACREEDORES'.
  APPEND wa_header TO t_header.

  CLEAR wa_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
       EXPORTING
            it_list_commentary = t_header.
ENDFORM.
