
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


REPORT  zfiacreecargav2 LINE-SIZE 255.
include ZBDCRECXY.
DATA: MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
TYPE-POOLS: truxs.
TYPE-POOLS: slis.
TABLES: lfa1 , lfb1.
PARAMETERS: p_file TYPE  rlgrap-filename.

  "REFRESH: MESSTAB, BDCDATA, RETURN, TI_ERROR_ACRE, TI_BAPI_ACRE.
  DATA: v_bankl type BANKL.
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
data: t_acreedor like zacreedor,
   "   t_return like BAPIRET2,
       P_TI_ACREEDOR like ZACREEDOR.

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
        col1(40) TYPE c,
        col2(10) TYPE c,
        col3(05) TYPE c,
*        col4(16) TYPE c,
*        col5(10) TYPE c,
*        col6(16) TYPE c,
        col7(10) TYPE c,
* ini - Waldo Alarcón - Visionone - 17-07-2020
        col8(60) TYPE c,
* fin - Waldo Alarcón - Visionone - 17-07-2020
      END OF wa_datatab.
* DATA: it_datatab type standard table of t_datatab,
DATA: rutsg(10)     TYPE c,
      p_t_kunnr(10) TYPE c,
      w_bankl(03)   TYPE c.
*      wa_datatab type t_datatab.
DATA t_zacreedor LIKE zacreedor OCCURS 1 WITH HEADER LINE.
DATA t_return    LIKE bapiret2 OCCURS 1 WITH HEADER LINE.
DATA it_raw      TYPE truxs_t_text_data.
 DATA: Name1(30).
 DATA: Name2(30).
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


***********************************************************************
* END-OF-SELECTION.
END-OF-SELECTION.
* PERFORM alv_setup.
  PERFORM obtener_datos.
* PERFORM display_alv.

FORM obtener_datos.
*  WRITE: AT (40)  'NOMBRE',
*          AT (10)   'RUT',
*          AT (5)   'SOCIEDAD',
**         AT (10)    'CUENTA_ASOCIADA',
*          AT (20)   'COD_BANCO',
*          AT (20)   'CTACTE',
*          AT (10)   'ID_SAP'.
  LOOP AT wa_datatab. "it_datatab INTO wa_datatab.
    contador = sy-tabix.
* ini - Waldo Alarcón - Visionone - 17-07-2020
    CLEAR t_zacreedor. REFRESH t_zacreedor.
* fin - Waldo Alarcón - Visionone - 17-07-2020
* valido si existe el acreedor en las tablas
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM lfa1  WHERE  stcd1 =  wa_datatab-col2.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM lfa1  WHERE  stcd1 =  wa_datatab-col2 ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0.
* ini - Waldo Alarcón - Visionone - 17-07-2020
      wa_datatab-col8 = 'Acreedor Existe en SAP '.
* fin - Waldo Alarcón - Visionone - 17-07-2020
* si existe valido si esta en la tabla
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM   lfb1  WHERE lifnr =  lfa1-lifnr
*                                   AND   bukrs =  wa_datatab-col3.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM   lfb1  WHERE lifnr =  lfa1-lifnr
                                   AND   bukrs =  wa_datatab-col3 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* ini - Waldo Alarcón - Visionone - 17-07-2020
      IF sy-subrc NE 0.
        wa_datatab-col8 = 'Acreedor no existe en la sociedad'.
      ELSE.
        wa_datatab-col8 = 'Acreedor se le actualizara el Nombre'.
      ENDIF.
      wa_datatab-col7 = lfa1-lifnr.
* fin - Waldo Alarcón - Visionone - 17-07-2020
    ELSE.
      wa_datatab-col7 = ''.
* ini - Waldo Alarcón - Visionone - 17-07-2020
      wa_datatab-col8 = 'Acreedor no Existe'.
* fin - Waldo Alarcón - Visionone - 17-07-2020
    ENDIF.
* si no esta se crea


    IF sy-subrc = 0.


      t_zacreedor-accion = '20'.
      t_zacreedor-lifnr  = wa_datatab-col7.
      t_zacreedor-bukrs  = wa_datatab-col3. "p_ti_detalle1-bukrs.
      t_zacreedor-ktokk  = 'ZB01'."p_ti_detalle1-ktok.
      t_zacreedor-title  = ''.
      Name1 = wa_datatab-col1(30).
      Name2 = wa_datatab-col1+30.
      t_zacreedor-name1  = Name1. "p_ti_detalle1-name1.
      t_zacreedor-name2  = Name2."p_ti_detalle1-name2.


      rutsg = wa_datatab-col2.
      REPLACE '-'  WITH '' INTO rutsg.
      CONDENSE rutsg NO-GAPS.
      t_zacreedor-sort1  = rutsg. "wa_datatab-col2."p_ti_detalle1-sort1.
      t_zacreedor-sort2  = ''.
      t_zacreedor-street = ''.
      t_zacreedor-house_num1 = ''.
      t_zacreedor-house_num2 = ''.
      t_zacreedor-ort01  = ''.
      t_zacreedor-ort02  = ''.
      t_zacreedor-land1  = ''.
      t_zacreedor-regio  = ''.
      t_zacreedor-stcd1  = wa_datatab-col2." p_ti_detalle1-stcd1_d.
      t_zacreedor-akont  =  ''."p_ti_detalle1-akont.
      t_zacreedor-fdgrv  = 'A4'.
      t_zacreedor-zterm1 = 'ZC01'.
      t_zacreedor-witht  = ''.
      t_zacreedor-wt_withcd = ''.
*         case when v_banco is not null then 'CL' else null end;
*      IF NOT wa_datatab-col5 IS INITIAL.
*        t_zacreedor-banks = 'CL'.
*        t_zacreedor-koinh = wa_datatab-col1.
*      ELSE.
        t_zacreedor-banks = ''.
        t_zacreedor-koinh = ''.
*      ENDIF.
*         id de banco
** V1 RVY 07-03-2022
*      t_zacreedor-bankl = wa_datatab-col5."p_ti_detalle1-bankl.
*      w_bankl           = |{ wa_datatab-col5 ALPHA = IN }|.
*      t_zacreedor-bankl = w_bankl.
*         numero de cuenta
*      t_zacreedor-bankn = wa_datatab-col6."p_ti_detalle1-bankn.
*         case when p_accion = 20 then substr(p_nombre,1,40) else null end;
*          t_zacreedor-koinh = ''."p_ti_detalle1-koinh.
      t_zacreedor-zgrup = 'Z1'.
      APPEND t_zacreedor.
  PERFORM UPDATE_ACREEDOR  TABLES  t_return
                        USING    t_zacreedor.
   "   CALL FUNCTION 'ZFIRFC003'
   "     TABLES
     "     t_acreedor = t_zacreedor
      "    return     = t_return.
* ini - Waldo Alarcón - Visionone - 17-07-2020
*      wa_datatab-col7 =   lfa1-lifnr.
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
* fin - Waldo Alarcón - Visionone - 17-07-2020
    ENDIF.
*    WRITE: /.

* WRITE: /
*        wa_datatab-col1,
*        wa_datatab-col2,
*        wa_datatab-col3,
*        wa_datatab-col4,
*        wa_datatab-col5,
*        wa_datatab-col6,
*        wa_datatab-col7.
    MODIFY wa_datatab INDEX contador.
    CLEAR: t_zacreedor.


  ENDLOOP.
  WRITE:/01 sy-uline(115).   "sy-uline(67) display a line 67 chars long
  WRITE:/01 sy-vline,   "sy-vline creates a vertical line
        (40) 'Nombre'        COLOR COL_HEADING, sy-vline, "COLOR changes background colour
        (10) 'Rut'           COLOR COL_HEADING, sy-vline,
        (5) 'Soc.'           COLOR COL_HEADING, sy-vline,
*        (16) 'Cta_Asociada'  COLOR COL_HEADING, sy-vline,
*        (10) 'Cod_Banco'     COLOR COL_HEADING, sy-vline,
*        (16) 'CtaCte'        COLOR COL_HEADING, sy-vline,
*        (10) 'ID_SAP'        COLOR COL_HEADING, sy-vline,
* ini - Waldo Alarcón - Visionone - 17-07-2020
        (60) 'Observación'   COLOR COL_HEADING, sy-vline.
* fin - Waldo Alarcón - Visionone - 17-07-2020

  WRITE:/01 sy-uline(115).     "display a line 67 chars long
  LOOP AT wa_datatab.
    WRITE: /01 sy-vline,
             (40)   wa_datatab-col1, sy-vline,
             (10)   wa_datatab-col2, sy-vline,
             (5)    wa_datatab-col3, sy-vline,
*             (16)   wa_datatab-col4, sy-vline,
*             (10)   wa_datatab-col5, sy-vline,
*             (16)   wa_datatab-col6, sy-vline,
*             (10)   wa_datatab-col7, sy-vline,
* ini - Waldo Alarcón - Visionone - 17-07-2020
             (60)   wa_datatab-col8, sy-vline.
* ini - Waldo Alarcón - Visionone - 17-07-2020
  ENDLOOP.
  WRITE:/01 sy-uline(115). "display a line 67 chars long

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
*
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

FORM UPDATE_ACREEDOR  TABLES  RETURN STRUCTURE BAPIRET2
                        USING   P_TI_ACREEDOR STRUCTURE ZACREEDOR.
  REFRESH: MESSTAB, BDCDATA.
  DATA: CONT_REG TYPE I,
      RESUL1   TYPE I,
      RESUL2   TYPE I,
      RESUL3   TYPE I,
      info type string,
      iter(2) type N.


  DATA:  CREDITOR_GENERAL_DETAIL   LIKE  LFA1,
         CREDITOR_COMPANY_DETAIL  LIKE  LFB1,
         P_RETURN  LIKE  BAPIRETURN.
  DATA:  CREDITOR_BANK_DETAIL  LIKE LFBK OCCURS 0 WITH HEADER LINE.
  DATA:  P_LFBW     LIKE LFBW OCCURS 0 WITH HEADER LINE.
  DATA:  P_LFZA     LIKE LFZA OCCURS 0 WITH HEADER LINE.
  DATA:  PP_RETURN  LIKE  BAPIRETURN OCCURS 0 WITH HEADER LINE.
  DATA: LS_VRSD LIKE LINE OF PP_RETURN.


  DATA: DYMPRO_C(132) TYPE C,
        DYMPRO_C2(132) TYPE C,
        NUM(1) TYPE C.


  PERFORM BDC_DYNPRO      USING 'SAPMF02K'               '0106'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'             'RF02K-D0610'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'             '/00'.
  PERFORM BDC_FIELD       USING 'RF02K-LIFNR'            P_TI_ACREEDOR-LIFNR.
  PERFORM BDC_FIELD       USING 'RF02K-BUKRS'            P_TI_ACREEDOR-BUKRS.
  PERFORM BDC_FIELD       USING 'RF02K-D0110'            'X'.
*   PERFORM BDC_FIELD       USING 'RF02K-D0120'            'X'.
*  PERFORM BDC_FIELD       USING 'RF02K-D0130'            'X'.
* PERFORM BDC_FIELD       USING 'RF02K-D0210'            'X'.
* PERFORM BDC_FIELD       USING 'RF02K-D0215'            'X'.
*  PERFORM BDC_FIELD       USING 'RF02K-D0220'            'X'.
*  PERFORM BDC_FIELD       USING 'RF02K-D0610'            'X'.


  PERFORM BDC_DYNPRO      USING 'SAPMF02K'               '0111'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'             '=$2OC'.
*  PERFORM BDC_FIELD       USING 'BDC_CURSOR'             'SZA1_D0100-TITLE_MEDI'.
*  PERFORM BDC_FIELD       USING 'SZA1_D0100-TITLE_MEDI'  P_TI_ACREEDOR-TITLE.
  PERFORM BDC_FIELD        USING 'ADDR1_DATA-NAME1'      P_TI_ACREEDOR-NAME1.

 IF P_TI_ACREEDOR-NAME2 is INITIAL.
     PERFORM BDC_FIELD       USING 'ADDR1_DATA-NAME2'      ''.
 else.
      PERFORM BDC_FIELD       USING 'ADDR1_DATA-NAME2'     P_TI_ACREEDOR-NAME2.
 ENDIF.

  PERFORM BDC_FIELD       USING 'ADDR1_DATA-SORT1'       P_TI_ACREEDOR-SORT1.
  PERFORM BDC_FIELD       USING 'ADDR1_DATA-SORT2'       P_TI_ACREEDOR-SORT2.

 PERFORM BDC_FIELD       USING 'ADDR1_DATA-STREET'      P_TI_ACREEDOR-STREET.
  PERFORM BDC_FIELD       USING 'ADDR1_DATA-HOUSE_NUM1'  P_TI_ACREEDOR-HOUSE_NUM1.
 PERFORM BDC_FIELD       USING 'ADDR1_DATA-CITY2'       P_TI_ACREEDOR-ORT02.
  PERFORM BDC_FIELD       USING 'ADDR1_DATA-CITY1'       P_TI_ACREEDOR-ORT01.
  PERFORM BDC_FIELD       USING 'ADDR1_DATA-PO_BOX'       P_TI_ACREEDOR-PO_BOX.

  PERFORM BDC_FIELD   USING 'SZA1_D0100-TEL_NUMBER'    P_TI_ACREEDOR-TEL_NUMBER.
 PERFORM BDC_FIELD   USING 'SZA1_D0100-TEL_EXTENS'    P_TI_ACREEDOR-TEL1_EXT.
  PERFORM BDC_FIELD   USING 'SZA1_D0100-FAX_NUMBER'    P_TI_ACREEDOR-TELFAX.
  PERFORM BDC_FIELD   USING 'SZA1_D0100-FAX_EXTENS'    P_TI_ACREEDOR-FAX_EXTENS.
  PERFORM BDC_FIELD   USING 'SZA1_D0100-SMTP_ADDR'     P_TI_ACREEDOR-SMTP_ADDR.


*  PERFORM BDC_DYNPRO      USING 'SAPMF02K'               '0111'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'             '/00'.
*  PERFORM BDC_FIELD       USING 'BDC_CURSOR'             'SZA1_D0100-TITLE_MEDI'.

*  PERFORM BDC_DYNPRO      USING 'SAPMF02K'               '0120'.
*   PERFORM BDC_FIELD       USING 'BDC_CURSOR'             'LFA1-BRSCH'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE'             '/00'.





*  PERFORM BDC_DYNPRO      USING 'SAPMF02K'               '0210'.
*  PERFORM BDC_FIELD       USING 'BDC_CURSOR'             'LFB1-AKONT'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE'             '/00'.
*  PERFORM BDC_FIELD       USING 'LFB1-AKONT'             P_TI_ACREEDOR-AKONT.
*  PERFORM BDC_FIELD       USING 'LFB1-ZUAWA'             P_TI_ACREEDOR-ZUAWA.
*  PERFORM BDC_FIELD       USING 'LFB1-FDGRV'             P_TI_ACREEDOR-FDGRV.

*  PERFORM BDC_DYNPRO      USING 'SAPMF02K'               '0215'.
*  PERFORM BDC_FIELD       USING 'BDC_CURSOR'             'LFB1-ZTERM'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE'             '/00'.
*  PERFORM BDC_FIELD       USING 'LFB1-ZTERM'             P_TI_ACREEDOR-ZTERM1.
**  PERFORM BDC_FIELD       USING 'LFB1-REPRF'             'X'. "Factura Doble Acreedores.
*  if P_TI_ACREEDOR-BUKRS eq 'CL01' or P_TI_ACREEDOR-BUKRS eq 'CL24'.
*    P_TI_ACREEDOR-ZGRUP = 'Z1'.
*  endif.
*  PERFORM BDC_FIELD       USING 'LFB1-ZGRUP'             P_TI_ACREEDOR-ZGRUP.

*  PERFORM BDC_FIELD       USING 'LFB1-ZWELS'             P_TI_ACREEDOR-ZWELS.
*  PERFORM BDC_FIELD       USING 'LFB1-ZAHLS'             P_TI_ACREEDOR-ZAHLS.

*  PERFORM BDC_DYNPRO      USING 'SAPMF02K'               '0220'.
*  PERFORM BDC_FIELD       USING 'BDC_CURSOR'             'LFB5-MAHNA'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE'             '/00'.

*  PERFORM BDC_DYNPRO      USING 'SAPMF02K'               '0610'.
*  PERFORM BDC_FIELD       USING 'BDC_OKCODE'             '/00'.
*  PERFORM BDC_FIELD       USING 'BDC_CURSOR'             'LFB1-QLAND'.

  PERFORM BDC_DYNPRO      USING 'SAPLSPO1'               '0300'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'             '=YES'.

  DATA: CTUMODE LIKE CTU_PARAMS-DISMODE VALUE 'N'.
  DATA: CUPDATE LIKE CTU_PARAMS-UPDMODE VALUE 'L'.
  DATA OPT TYPE CTU_PARAMS.
  OPT-NOBINPT = 'X'.
  OPT-DISMODE = CTUMODE.
  OPT-UPDMODE = CUPDATE.

  CALL TRANSACTION 'FK02' USING BDCDATA
                    OPTIONS FROM OPT
                   MESSAGES INTO MESSTAB.



  DATA: BEGIN OF ITLOG OCCURS 0,
  TEXTO(100),
  END OF ITLOG.

  DATA: V_TEXTO LIKE T100-TEXT,
  V_MSGID LIKE SY-MSGID,
  V_MSGNO LIKE SY-MSGNO,
  V_MSGV1 LIKE SY-MSGV1,
  V_MSGV2 LIKE SY-MSGV2,
  V_MSGV3 LIKE SY-MSGV3,
  V_MSGV4 LIKE SY-MSGV4.

  LOOP AT MESSTAB WHERE MSGID NE 'I'.

    V_MSGID = MESSTAB-MSGID.
    V_MSGNO = MESSTAB-MSGNR.
    V_MSGV1 = MESSTAB-MSGV1.
    V_MSGV2 = MESSTAB-MSGV2.
    V_MSGV3 = MESSTAB-MSGV3.
    V_MSGV4 = MESSTAB-MSGV4.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE TEXT
*      INTO  V_TEXTO
*       FROM T100 WHERE SPRSL = SY-LANGU
*                   AND ARBGB = V_MSGID
*                   AND MSGNR = V_MSGNO.
*
* NEW CODE
    SELECT TEXT
    UP TO 1 ROWS 
      INTO  V_TEXTO
       FROM T100 WHERE SPRSL = SY-LANGU
                   AND ARBGB = V_MSGID
                   AND MSGNR = V_MSGNO ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF SY-SUBRC = 0.
      DATA:
         MAXIMUM_LENGTH TYPE I,
         HLP_TEXT(100)  TYPE C,
         MSGV_NO(1)     TYPE C,
         OFFSET         TYPE I,
         INDEX          TYPE I,
         STRL           LIKE SY-FDPOS,
         P_FDPOS        LIKE SY-FDPOS.

      DESCRIBE FIELD V_TEXTO LENGTH MAXIMUM_LENGTH IN CHARACTER MODE.
      HLP_TEXT = V_TEXTO.
      CLEAR V_TEXTO.

      OFFSET = 0.
      DO 4 TIMES.
        SEARCH HLP_TEXT FOR '&'.
        IF SY-SUBRC <> 0. EXIT. ENDIF.
        IF SY-FDPOS <> 0.
          CHECK OFFSET < MAXIMUM_LENGTH.
          MOVE HLP_TEXT(SY-FDPOS) TO V_TEXTO+OFFSET.
          OFFSET = OFFSET + SY-FDPOS.
        ENDIF.
        INDEX = SY-FDPOS + 1.
        SHIFT HLP_TEXT BY INDEX PLACES LEFT.
        P_FDPOS  = SY-FDPOS.
        IF HLP_TEXT(1) CO '1234'.
          MSGV_NO = HLP_TEXT(1).
          SHIFT HLP_TEXT BY 1 PLACES LEFT.
        ELSE.
          MSGV_NO = SY-INDEX.
        ENDIF.
        CHECK OFFSET < MAXIMUM_LENGTH.
        CASE MSGV_NO.
          WHEN 1.
            WRITE V_MSGV1 TO V_TEXTO+OFFSET LEFT-JUSTIFIED.
            STRL = STRLEN( V_MSGV1 ).

          WHEN 2.
            WRITE V_MSGV2 TO V_TEXTO+OFFSET LEFT-JUSTIFIED.
            STRL = STRLEN( V_MSGV2 ).
          WHEN 3.
            WRITE V_MSGV3 TO V_TEXTO+OFFSET LEFT-JUSTIFIED.
            STRL = STRLEN( V_MSGV3 ).
          WHEN 4.
            WRITE V_MSGV4 TO V_TEXTO+OFFSET LEFT-JUSTIFIED.
            STRL = STRLEN( V_MSGV4 ).
        ENDCASE.
        OFFSET = OFFSET + STRL.
      ENDDO.



      IF OFFSET < MAXIMUM_LENGTH.
        SY-FDPOS = STRLEN( HLP_TEXT ).
        IF SY-FDPOS <> 0.
          MOVE HLP_TEXT(SY-FDPOS) TO V_TEXTO+OFFSET.
        ENDIF.
      ENDIF.

      RETURN-MESSAGE_V1 = V_TEXTO+0(50).
      RETURN-MESSAGE_V2 = V_TEXTO+50(13).

      RETURN-TYPE              = MESSTAB-MSGTYP.
      RETURN-ID                = '01'.
      APPEND RETURN.
      CLEAR: RETURN.


    ENDIF.
  ENDLOOP.



ENDFORM.                    " UPDATE_ACREEDOR
