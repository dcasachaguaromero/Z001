*&----------------------------------------------------------------------*
*& PROGRAMA.............: ZFIACREECARGA.
*& AUTOR................: HECTOR CASTILLO
*& FECHA................: 04.09.2015
*& TRANSACCION..........:
*& ORDEN DE TRANSPORTE..:                                               *
*& EMPRESA..............:                                               *
*&----------------------------------------------------------------------*
*& DESCRIPCION:                                                         *
*&   Upload Hoja Excel a tabla interna
*&   Mostrar el contenido por un ALV
*&----------------------------------------------------------------------*
*& Modificador  Fecha   MARCA Motivo                                    *
*& ----------- -------- ----- ----------------------------------------- *
*& XXXXXXXX    DD.MM.AA  @01  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx *
*&----------------------------------------------------------------------*                                                                     *
REPORT zfiacreecarga LINE-SIZE 285.

TYPE-POOLS: truxs.
TYPE-POOLS: slis.
TABLES: lfa1 , lfb1.
CONSTANTS: top_of_page TYPE slis_formname  VALUE 'TOP_OF_PAGE',
           top_of_list TYPE slis_formname  VALUE 'TOP_OF_LIST'.
CONSTANTS: end_of_list  TYPE slis_formname  VALUE 'END_OF_LIST',
           user_command TYPE slis_formname  VALUE 'ALV_USER_COMMAND'.
DATA: k_status       TYPE slis_formname VALUE 'STANDARD_KR01',
      k_user_command TYPE slis_formname VALUE 'USER_COMMAND',
      pos            TYPE i.
DATA: BEGIN OF spl OCCURS 0,
        val(1023),
      END OF spl,
      sindx TYPE i.

TABLES: sscrfields.
"Una variable a modo de contador
DATA: contador TYPE i.

DATA: r_grid   TYPE REF TO cl_gui_alv_grid,
      s2_bukrs LIKE lfb1-bukrs.

DATA: alv_fieldcat    TYPE slis_t_fieldcat_alv,
      wa_alv_fieldcat TYPE slis_fieldcat_alv,
      alv_layout      TYPE slis_layout_alv,
      gd_repid        LIKE sy-repid.

DATA: BEGIN OF wa_datatab OCCURS 0,
        col1(40)  TYPE c,
        col2(10)  TYPE c,
        col3(05)  TYPE c,
        col4(16)  TYPE c,
        col5(10)  TYPE c,
        col6(16)  TYPE c,
        col7(10)  TYPE c,
        col8(60)  TYPE c,
        col9(241) TYPE c,
        col10     TYPE c LENGTH 4,   "V1-CNN ECDK926772 30.09.2025
        col11     TYPE c LENGTH 20,  "V1-CNN ECDK926772 30.09.2025
      END OF wa_datatab.

DATA: rutsg(10)     TYPE c,
      p_t_kunnr(10) TYPE c,
      w_bankl(03)   TYPE c.

DATA t_zacreedor LIKE zacreedor OCCURS 1 WITH HEADER LINE.
DATA t_return    LIKE bapiret2 OCCURS 1 WITH HEADER LINE.
DATA it_raw      TYPE truxs_t_text_data.
DATA: name1(30).
DATA: name2(30).

*--------------------------------------------------------------------*
*  SELECTION-SCREEN
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
PARAMETERS: p_file   TYPE  rlgrap-filename.
SELECTION-SCREEN SKIP.
PARAMETERS:p_chkbox AS CHECKBOX DEFAULT ''.
SELECTION-SCREEN END OF BLOCK b1.

*--------------------------------------------------------------------*
*  AT SELECTION-SCREEN
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name  = p_file.


*--------------------------------------------------------------------*
*  START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
      i_line_header        = 'X'
      i_tab_raw_data       = it_raw       " WORK TABLE
      i_filename           = p_file
    TABLES
      i_tab_converted_data = wa_datatab "it_datatab[]    "ACTUAL DATA
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


*--------------------------------------------------------------------*
*  END-OF-SELECTION
*--------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM obtener_datos.

*--------------------------------------------------------------------*
*   Form OBTENER_DATOS
*--------------------------------------------------------------------*
FORM obtener_datos.

***
  LOOP AT wa_datatab.
    contador = sy-tabix.

    CLEAR t_zacreedor. REFRESH t_zacreedor.

*   Se valida si existe el acreedor en las tablas
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM lfa1 WHERE  stcd1 =  wa_datatab-col2.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM lfa1 WHERE  stcd1 =  wa_datatab-col2 ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0.
      wa_datatab-col8 = 'Acreedor ya Existe, se ampliara'.

*     Si existe se valida si esta en la tabla por sociedad
**mod ini
      SELECT SINGLE bukrs, lifnr FROM lfb1 INTO @DATA(ls_lfbl)
         WHERE lifnr =  @lfa1-lifnr
         AND bukrs =  @wa_datatab-col3.
**mod fin
      IF sy-subrc NE 0.
        wa_datatab-col8 = 'Acreedor ya existe y será ampliado a la sociedad'.
      ELSE.
        wa_datatab-col8 = 'Acreedor ya existe y está ampliado en la sociedad'.
      ENDIF.
      wa_datatab-col7 = lfa1-lifnr.
    ELSE.
      wa_datatab-col7 = ''.
      wa_datatab-col8 = 'Creando Acreedor'.
    ENDIF.

*   Si no está, se crea
    IF sy-subrc <> 0.

      IF wa_datatab-col7 IS INITIAL.
        t_zacreedor-accion = '10'.
        t_zacreedor-lifnr  = ''.
      ELSE.
        t_zacreedor-accion = '10'.
        t_zacreedor-lifnr  = wa_datatab-col7.
      ENDIF.

      t_zacreedor-bukrs = wa_datatab-col3.
      t_zacreedor-ktokk = 'ZB01'.
      t_zacreedor-title = ''.

      name1 = wa_datatab-col1(30).
      name2 = wa_datatab-col1+30.
      t_zacreedor-name1  = name1.
      t_zacreedor-name2  = name2.

      rutsg = wa_datatab-col2.
      REPLACE '-'  WITH '' INTO rutsg.
      CONDENSE rutsg NO-GAPS.
      t_zacreedor-sort1 = rutsg.
      t_zacreedor-sort2 = ''.
      t_zacreedor-street = ''.
      t_zacreedor-house_num1 = ''.
      t_zacreedor-house_num2 = ''.
      t_zacreedor-ort01   = ''.
      t_zacreedor-ort02   = ''.
      t_zacreedor-land1   = 'CL'.
      t_zacreedor-regio   = '13'.

      t_zacreedor-stcd1   = wa_datatab-col2.
      t_zacreedor-akont   = wa_datatab-col4.

      t_zacreedor-fdgrv   = 'A4'.
      t_zacreedor-zterm1  = 'ZC01'.
      t_zacreedor-witht   = ''.
      t_zacreedor-wt_withcd = ''.

      IF NOT wa_datatab-col5 IS INITIAL.
        t_zacreedor-banks = 'CL'.
        t_zacreedor-koinh = wa_datatab-col1.
      ELSE.
        t_zacreedor-banks = ''.
        t_zacreedor-koinh = ''.
      ENDIF.

      w_bankl               = |{ wa_datatab-col5 ALPHA = IN }|.
      t_zacreedor-bankl     = w_bankl.
*     Número de cuenta
      t_zacreedor-bankn     = wa_datatab-col6.

*-> BEG INS V1-CNN ECDK926773 30.09.2025
      t_zacreedor-bvtyp  = wa_datatab-col10.   "Tipo banco interlocutor
      t_zacreedor-bkref  = wa_datatab-col11.   "Referencia para el banco/cuenta
*-> BEG INS V1-CNN ECDK926773 30.09.2025
      t_zacreedor-smtp_addr = wa_datatab-col9.
      t_zacreedor-zgrup = 'Z1'.
      APPEND t_zacreedor.

      CALL FUNCTION 'ZFIRFC003'
        TABLES
          t_acreedor = t_zacreedor
          return     = t_return.

      READ TABLE t_return WITH KEY type   = 'S'
                                   number = 000.
      IF sy-subrc = 0.
        p_t_kunnr       = t_return-message_v1+0(10).
        wa_datatab-col7 = p_t_kunnr.

        MESSAGE ID t_return-id TYPE t_return-type NUMBER t_return-number
               WITH t_return-message_v1 t_return-message_v2
                    t_return-message_v3 t_return-message_v4
               INTO wa_datatab-col8.
      ELSEIF t_return[] IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE lifnr INTO wa_datatab-col7
*            FROM lfa1 WHERE stcd1 =  wa_datatab-col2.
*
* NEW CODE
        SELECT lifnr
        UP TO 1 ROWS  INTO wa_datatab-col7
            FROM lfa1 WHERE stcd1 =  wa_datatab-col2 ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ELSE.
        READ TABLE t_return WITH KEY type = 'E'.
        IF sy-subrc EQ 0.
          CONCATENATE t_return-message_v1 t_return-message_v2
                      t_return-message_v3 t_return-message_v4
                 INTO wa_datatab-col8 SEPARATED BY space.
        ENDIF.
      ENDIF.

    ELSE.
      IF p_chkbox  IS INITIAL.
        t_zacreedor-accion = '20'.
      ELSE.
        t_zacreedor-accion = '30'.
      ENDIF.
      t_zacreedor-lifnr  = wa_datatab-col7.
      t_zacreedor-bukrs  = wa_datatab-col3.
      t_zacreedor-ktokk  = 'ZB01'.
      t_zacreedor-title  = ''.

      name1 = wa_datatab-col1(30).
      name2 = wa_datatab-col1+30.
      t_zacreedor-name1  = name1.
      t_zacreedor-name2  = name2.

      rutsg = wa_datatab-col2.
      REPLACE '-'  WITH '' INTO rutsg.
      CONDENSE rutsg NO-GAPS.
      t_zacreedor-sort1  = rutsg.
      t_zacreedor-sort2  = ''.
      t_zacreedor-street = ''.
      t_zacreedor-house_num1 = ''.
      t_zacreedor-house_num2 = ''.
      t_zacreedor-ort01  = ''.
      t_zacreedor-ort02  = ''.
      t_zacreedor-land1  = ''.
      t_zacreedor-regio  = ''.
      t_zacreedor-stcd1  = wa_datatab-col2.
      t_zacreedor-akont  =  ''.
      t_zacreedor-fdgrv  = 'A4'.
      t_zacreedor-zterm1 = 'ZC01'.
      t_zacreedor-witht  = ''.
      t_zacreedor-wt_withcd = ''.
*         case when v_banco is not null then 'CL' else null end;
      IF NOT wa_datatab-col5 IS INITIAL.
        t_zacreedor-banks = 'CL'.
        t_zacreedor-koinh = wa_datatab-col1.
      ELSE.
        t_zacreedor-banks = ''.
        t_zacreedor-koinh = ''.
      ENDIF.

      w_bankl           = |{ wa_datatab-col5 ALPHA = IN }|.
      t_zacreedor-bankl = w_bankl.
*     Número de cuenta
      t_zacreedor-bankn = wa_datatab-col6."p_ti_detalle1-bankn.

*-> BEG INS V1-CNN ECDK926773 30.09.2025
      t_zacreedor-bvtyp  = wa_datatab-col10.   "Tipo banco interlocutor
      t_zacreedor-bkref  = wa_datatab-col11.   "Referencia para el banco/cuenta
*-> BEG INS V1-CNN ECDK926773 30.09.2025

      IF NOT wa_datatab-col9 IS INITIAL.
        t_zacreedor-smtp_addr = wa_datatab-col9."HCD 19042022
      ENDIF.
      t_zacreedor-zgrup = 'Z1'.
      APPEND t_zacreedor.

      CALL FUNCTION 'ZFIRFC003'
        TABLES
          t_acreedor = t_zacreedor
          return     = t_return.

      READ TABLE t_return WITH KEY type   = 'S'
                                   number = 000.
      IF sy-subrc = 0.
        wa_datatab-col7 =  lfa1-lifnr.
        MESSAGE ID t_return-id TYPE t_return-type NUMBER t_return-number
               WITH t_return-message_v1 t_return-message_v2
                    t_return-message_v3 t_return-message_v4
               INTO wa_datatab-col8.
      ELSE.
        READ TABLE t_return WITH KEY type = 'E'.
        IF sy-subrc EQ 0.
          CONCATENATE t_return-message_v1 t_return-message_v2
                      t_return-message_v3 t_return-message_v4
                 INTO wa_datatab-col8 SEPARATED BY space.
        ENDIF.
      ENDIF.

    ENDIF.

    MODIFY wa_datatab INDEX contador.
    CLEAR: t_zacreedor.


  ENDLOOP.
**

  WRITE: /01(285) sy-uline.
  WRITE:/01 sy-vline,
        (40) 'Nombre'        COLOR COL_HEADING, sy-vline, "COLOR changes background colour
        (10) 'Rut'           COLOR COL_HEADING, sy-vline,
        (05) 'Soc.'          COLOR COL_HEADING, sy-vline,
        (16) 'Cta_Asociada'  COLOR COL_HEADING, sy-vline,
        (10) 'Cod_Banco'     COLOR COL_HEADING, sy-vline,
        (16) 'CtaCte'        COLOR COL_HEADING, sy-vline,
        (10) 'ID_SAP'        COLOR COL_HEADING, sy-vline,
        (60) 'Observación'   COLOR COL_HEADING, sy-vline,
        (60) 'EMAIL'         COLOR COL_HEADING, sy-vline,
*-> BEG INS V1-CNN ECDK926773 30.09.2025
        (04) 'TpBc'          COLOR COL_HEADING, sy-vline,
        (20) 'Ref. Bco/Cta'  COLOR COL_HEADING, sy-vline.
*-> END INS V1-CNN ECDK926773 30.09.2025

  WRITE: /01(285) sy-uline.
  LOOP AT wa_datatab.
    WRITE: /01 sy-vline,
             (40)   wa_datatab-col1, sy-vline,
             (10)   wa_datatab-col2, sy-vline,
             (5)    wa_datatab-col3, sy-vline,
             (16)   wa_datatab-col4, sy-vline,
             (10)   wa_datatab-col5, sy-vline,
             (16)   wa_datatab-col6, sy-vline,
             (10)   wa_datatab-col7, sy-vline,
             (60)   wa_datatab-col8, sy-vline,
             (60)   wa_datatab-col9, sy-vline,
*-> BEG INS V1-CNN ECDK926773 30.09.2025
             (04)      wa_datatab-col10, sy-vline,
             (20)      wa_datatab-col11, sy-vline.
*-> END INS V1-CNN ECDK926773 30.09.2025
  ENDLOOP.

  WRITE: /01(285) sy-uline.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  alv_setup
*&---------------------------------------------------------------------*
*  Setup of the columns in the ALV grid
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
      i_callback_program     = gd_repid
      i_callback_top_of_page = 'TOP_OF_PAGE_SETUP' "Ref to form
      is_layout              = alv_layout
      it_fieldcat            = alv_fieldcat
*     i_callback_user_command  = user_command
      i_save                 = 'X'
    TABLES
      t_outtab               = wa_datatab
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " display_alv


*&---------------------------------------------------------------------*
*&      Form  top_of_page_setup
*&---------------------------------------------------------------------*
*  Set-up what to display at the top of the ALV pages
*  Note that the link to this form is in the
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' parameter
*  i_callback_top_of_page   = 'TOP_OF_PAGE' in form display_alv
*----------------------------------------------------------------------*
FORM top_of_page_setup.

  DATA: t_header  TYPE slis_t_listheader,
        wa_header TYPE slis_listheader.


  wa_header-typ  = 'H'.
  wa_header-info = 'LISTADO CARGADO DE ACREEDORES'.
  APPEND wa_header TO t_header.

  CLEAR wa_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.

ENDFORM.
