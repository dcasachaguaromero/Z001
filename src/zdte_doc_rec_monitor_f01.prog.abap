*&---------------------------------------------------------------------*
*&  Include           ZDTE_DOC_REC_MONITOR_F01
*&---------------------------------------------------------------------*
***FORM user_command USING i_function TYPE salv_de_function.
***
***  DATA  lv_msg              TYPE i VALUE 0.
***
***  DATA: l_folio(10)         TYPE n,
***        l_tipo_dte          TYPE zdte_control-tipo_dte,
***        l_hora              TYPE sy-timlo,
***        l_lifnr             TYPE lfa1-lifnr.
***
***  DATA: l_tabix             LIKE sy-tabix,
***        l_lines             TYPE i.
***
***  DATA: l_invoicedocnumber  LIKE  bapi_incinv_fld-inv_doc_no,
***        l_fiscalyear        LIKE  bapi_incinv_fld-fisc_year,
***        l_message           TYPE  zdte_doc_rec-message.
****  gr_selections = gr_table->get_selections( ).
****
***** set selection mode
****  gr_selections->set_selection_mode(
****  if_salv_c_selection_mode=>row_column ).
****
***  gt_rows = gr_selections->get_selected_rows( ).
***
***  DATA lt_doc_ref       TYPE ty_tdoc_ref.
***  DATA lt_doc_ref_d     TYPE ty_tdoc_ref.
***  DATA ls_doc_ref       LIKE LINE OF lt_doc_ref.
***  DATA l_motivo_rec     TYPE zdte_doc_rec-motivo_rec.
***
***  FIELD-SYMBOLS <wa_doc_ref> LIKE LINE OF lt_doc_ref.
***
***  IF i_function = 'DELE'.
***    l_lines = LINES( gt_rows ).
***    IF l_lines > 1.
***      MESSAGE i000(0k) WITH 'Debe seleccionar sola una línea' DISPLAY LIKE 'E'.
***      RETURN.
***    ENDIF.
***  ENDIF.
***
***  DATA l_question(100)  TYPE c.
***  DATA l_answer(1)      TYPE c.
***
***  l_question = '¿Esta seguro de Eliminar Folio & ?'.
***
****  CHECK wa_data-PCLO_ID is NOT INITIAL.
***  CASE i_function.
**** nuevo
***    WHEN 'NUEVO'.
***
***      CALL FUNCTION 'POPUP_TO_CONFIRM'
***        EXPORTING
***          text_question         = '¿Esta seguro de cambiar estado a NUEVO?'
***          text_button_1         = 'Sí'
***          default_button        = '2'
***          display_cancel_button = 'X'
***        IMPORTING
***          answer                = l_answer.
***
***      IF l_answer <> '1'.
***        RETURN.
***      ENDIF.
***
***      LOOP AT gt_rows INTO l_tabix.
***        READ TABLE gt_data INDEX l_tabix INTO wa_data.
***        IF sy-subrc = 0.
***          CHECK wa_data-estado = c_no_contabilizado.
***
***          UPDATE zdte_doc_rec SET estado    = c_nuevo WHERE rutemisor = wa_data-rutemisor AND
***                                                            tipodte   = wa_data-tipodte   AND
***                                                              folio     = wa_data-folio.
***          IF sy-subrc = 0.
***            COMMIT WORK.
***            wa_data-estado = c_nuevo.
***            MODIFY gt_data FROM wa_data INDEX l_tabix.
***          ELSE.
***            MESSAGE i000(0k) WITH 'Error al modificar Folio' wa_data-folio
***                             DISPLAY LIKE 'E'.
***          ENDIF.
***
***        ENDIF.
***      ENDLOOP.
**** borrar
***    WHEN 'DELE'.
***
***      LOOP AT gt_rows INTO l_tabix.
***        READ TABLE gt_data INDEX l_tabix INTO wa_data.
***        IF sy-subrc <> 0.
***          RETURN.
***        ENDIF.
***      ENDLOOP.
***
***      IF wa_data-estado <> c_no_contabilizado.
***        MESSAGE i000(0k) WITH 'Registro debe estar con estado'
***                              'no contabilizado' DISPLAY LIKE 'E'.
***        RETURN.
***      ENDIF.
***
***      REPLACE FIRST OCCURRENCE OF '&' IN l_question WITH wa_data-folio.
***
***      CALL FUNCTION 'POPUP_TO_CONFIRM'
***        EXPORTING
***          text_question         = l_question
***          text_button_1         = 'Sí'
***          default_button        = '2'
***          display_cancel_button = 'X'
***        IMPORTING
***          answer                = l_answer.
***
***      IF l_answer <> '1'.
***        RETURN.
***      ENDIF.
***
***      DELETE FROM zdte_doc_rec WHERE rutemisor = wa_data-rutemisor AND
***                                     tipodte   = wa_data-tipodte   AND
***                                     folio = wa_data-folio.
***      IF sy-subrc = 0.
***        SELECT COUNT(*) FROM zdte_doc_rec_ref WHERE rutemisor = wa_data-rutemisor AND
***                               tipodte   = wa_data-tipodte   AND
***                               folio = wa_data-folio.
***        IF sy-subrc = 0.
***          DELETE FROM zdte_doc_rec_ref WHERE rutemisor = wa_data-rutemisor AND
***                                 tipodte   = wa_data-tipodte   AND
***                                 folio = wa_data-folio.
***          IF sy-subrc = 0.
***            COMMIT WORK.
***            DELETE gt_data INDEX l_tabix.
***            MESSAGE i000(0k) WITH 'Folio' wa_data-folio 'eliminado con éxito' DISPLAY LIKE 'S'.
***          ELSE.
***            ROLLBACK WORK.
***            MESSAGE i000(0k) WITH 'Error al borrar Folio' wa_data-folio DISPLAY LIKE 'E'.
***          ENDIF.
***        ELSE.
***          COMMIT WORK.
***          DELETE gt_data INDEX l_tabix.
***          MESSAGE i000(0k) WITH 'Folio' wa_data-folio 'eliminado con éxito' DISPLAY LIKE 'S'.
***        ENDIF.
***      ELSE.
***        ROLLBACK WORK.
***        MESSAGE i000(0k) WITH 'Error al borrar Folio' wa_data-folio DISPLAY LIKE 'E'.
***      ENDIF.
***
****   Log
***    WHEN 'PROT'.
***      CALL SCREEN 2000  STARTING AT 2 5
***                        ENDING AT 125 20.
****--------------------------------------------------------------------*
***    WHEN 'REC'.
****--------------------------------------------------------------------*
***      DATA ld_a(1)    TYPE c.
***      DATA ls_sval    LIKE sval.
***      DATA lt_sval    TYPE TABLE OF sval.
****  DATA l_motivo_rec TYPE dd07v-domvalue_l.
***      DATA l_text     TYPE dd07v-ddtext.
***      DATA l_string   TYPE string.
***      DATA l_paval    TYPE  t001z-paval.
***
***      CLEAR: gt_rechazados[].
****             gt_desc[].
***
***      ls_sval-tabname   = 'ZDTE_DOC_REC'.
***      ls_sval-fieldname = 'MOTIVO_REC'.
***      ls_sval-field_obl = 'X'.
***
***      APPEND ls_sval TO lt_sval.
***
***      CALL FUNCTION 'POPUP_GET_VALUES'
***        EXPORTING
****   NO_VALUE_CHECK        = ' '
***         popup_title           = 'Ingresar motivo de Rechazo'
****   START_COLUMN          = '5'
****   START_ROW             = '5'
***      IMPORTING
***        returncode            = ld_a
***       TABLES
***         fields                = lt_sval
***      EXCEPTIONS
***        error_in_fields       = 1
***        OTHERS                = 2.
***
***      READ TABLE lt_sval INTO ls_sval WITH KEY fieldname = 'MOTIVO_REC'.
***      IF sy-subrc = 0.
***        MOVE ls_sval-value TO l_motivo_rec.
***
***        SELECT COUNT(*) FROM zdtet_motivo_rec WHERE motivo_rec = l_motivo_rec.
***        IF sy-subrc <> 0.
***          MESSAGE i000(0k) WITH 'Motivo de Rechazo'
***                                l_motivo_rec 'no existe' DISPLAY LIKE 'E'.
***          RETURN.
***        ENDIF.
***      ENDIF.
***
***      CLEAR wa_data.
***      LOOP AT gt_rows INTO l_tabix.
***        READ TABLE gt_data INDEX l_tabix INTO wa_data.
***        IF wa_data-estado = c_no_contabilizado.
****          PERFORM rechazar USING wa_data CHANGING g_subrc l_motivo_rec.
****          IF g_subrc = 0.
****            MOVE-CORRESPONDING   wa_data TO wa_doc_rec.
****            wa_doc_rec-estado = c_rechazado.
****            wa_doc_rec-motivo_rec = l_motivo_rec.
****            wa_doc_rec-uname = sy-uname.
****            MODIFY zdte_doc_rec FROM wa_doc_rec.
****          ENDIF.
***        ENDIF.
***      ENDLOOP.
***
****      IF gt_rechazados[] IS NOT INITIAL.
****        PERFORM call_proxy
****                    USING
****                      gt_rechazados[]
****                    CHANGING
****                       g_subrc.
****
****        IF g_subrc <> 0.
****          RETURN.
****        ENDIF.
****
****        DATA ls_desc LIKE LINE OF gt_desc.
****
***** procesamos respuesta desde SII
****        LOOP AT gt_desc INTO ls_desc WHERE respuesta = '0'.
****          READ TABLE gt_data INTO wa_data WITH KEY rutemisor = ls_desc-rutemisor
****                                                     tipodte = ls_desc-tipodte
****                                                       folio = ls_desc-folio.
****          IF sy-subrc = 0.
****            MOVE-CORRESPONDING   wa_data TO wa_doc_rec.
****            wa_doc_rec-estado = c_rechazado.
****            wa_doc_rec-motivo_rec = l_motivo_rec.
****            wa_doc_rec-uname = sy-uname.
****            MODIFY zdte_doc_rec FROM wa_doc_rec.
****            COMMIT WORK.
****          ENDIF.
****        ENDLOOP.
****
****
****      ENDIF.
****--------------------------------------------------------------------*
***    WHEN 'FB61'.
****--------------------------------------------------------------------*
****DTEs no contabilizados Sin Orden de Compra
***
***      CLEAR wa_data.
***      DATA l_obj_key TYPE bapiache03-obj_key.
***      DATA l_year TYPE gjahr.
***
***      LOOP AT gt_rows INTO l_tabix.
***
****      gt_rows = l_tabix.
***
***        READ TABLE gt_data INDEX l_tabix INTO wa_data.
***        IF wa_data-estado NE c_rechazado.
***
****          PERFORM f_fb61 USING wa_data CHANGING g_subrc l_obj_key l_year l_message.
***
***          PERFORM ejecuta_fb60 USING    wa_data
***                               CHANGING l_obj_key
***                                        l_year.
***
***          IF l_obj_key IS NOT INITIAL.
***
***            MOVE-CORRESPONDING wa_data TO wa_doc_rec  .
***
***            wa_doc_rec-estado = c_contabilizado       .
***            wa_doc_rec-uname  = sy-uname              .
***            wa_doc_rec-belnr  = l_obj_key             .
***            wa_doc_rec-gjahr  = l_year                .
***            wa_doc_rec-tcode  = 'FB60'                .
***
***            MODIFY zdte_doc_rec FROM wa_doc_rec.
***
***            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
***              EXPORTING
***                wait = 'X'.
***
***            wa_data-estado    = c_contabilizado.
***            wa_data-icon_sts  = icon_green_light.
***            wa_data-belnr     = l_obj_key.
***            wa_data-gjahr     = l_year.
***            wa_data-tcode     = 'FB60'.
***
***            MODIFY gt_data FROM wa_data INDEX l_tabix.
***          ELSEIF g_subrc = 99.  "cancel
***            CONTINUE.
***          ELSE.
***            wa_data-icon_sts = icon_red_light.
***            MODIFY gt_data FROM wa_data INDEX l_tabix.
***
***            IF l_message IS NOT INITIAL.
***              MOVE-CORRESPONDING wa_data TO news.
***              news-text = l_message.
***              news-color = col_negative.
***              APPEND news.
***            ENDIF.
***          ENDIF.
***        ENDIF.
***      ENDLOOP.
****--------------------------------------------------------------------*
***    WHEN 'MIRO'.
****--------------------------------------------------------------------*
***      CLEAR wa_data.
***
***      LOOP AT gt_rows INTO l_tabix.
***
***        READ TABLE gt_data INDEX l_tabix INTO wa_data.
***        IF wa_data-estado = c_no_contabilizado.
***          PERFORM miro_manual USING wa_data CHANGING g_subrc
***                                                     l_invoicedocnumber
***                                                     l_fiscalyear
***                                                     l_message.
***          IF g_subrc = 0.
***            MOVE-CORRESPONDING   wa_data TO wa_doc_rec.
***            wa_doc_rec-uname = sy-uname.
***            wa_doc_rec-belnr = l_invoicedocnumber.
***            wa_doc_rec-gjahr = l_fiscalyear.
***            wa_doc_rec-tcode = 'MIRO'.
***            wa_doc_rec-estado = c_contabilizado.
***            MODIFY zdte_doc_rec FROM wa_doc_rec.
***            COMMIT WORK.
***
***            wa_data-estado = c_contabilizado.
***            wa_data-belnr = l_invoicedocnumber.
***            wa_data-gjahr = l_fiscalyear.
***            wa_data-tcode = 'MIRO'.
***            wa_data-icon_sts = icon_green_light.
***            MODIFY gt_data FROM wa_data INDEX l_tabix.
***          ELSE.
***            wa_data-icon_sts = icon_red_light.
***            MODIFY gt_data FROM wa_data INDEX l_tabix.
***
***            IF l_message IS NOT INITIAL.
***              MOVE-CORRESPONDING wa_data TO news.
***              news-text = l_message.
***              news-color = col_negative.
***              APPEND news.
***            ENDIF.
***
***          ENDIF.
***        ENDIF.
***      ENDLOOP.
***  ENDCASE.
***
***  gr_table->refresh( ).
***ENDFORM.                    "user_command


*&---------------------------------------------------------------------*
*&      Form  get_lifnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RUT      text
*      -->P_LIFNR    text
*      -->P_SUBRC    text
*      -->P_MESSAGE  text
*----------------------------------------------------------------------*
FORM get_lifnr USING p_rut CHANGING p_lifnr p_subrc p_message.

  SELECT  SINGLE lifnr INTO p_lifnr  FROM  lfa1
           WHERE stcd1  = p_rut.
  IF sy-subrc <> 0.
    MESSAGE i000(0k) WITH 'Proveedor no existe en sistema con RUT' p_rut DISPLAY LIKE 'E'.
    MESSAGE i000(0k) WITH 'Proveedor no existe en sistema con RUT' p_rut INTO p_message.
    p_subrc = 4.
    RETURN.
  ELSE.
    p_subrc = 0.
  ENDIF.
ENDFORM.                    "get_lifnr

*&---------------------------------------------------------------------*
*&      Form  RECHAZAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_DATA  text
*----------------------------------------------------------------------*
*FORM rechazar  USING p_data TYPE ty_data
*              CHANGING p_subrc TYPE sy-subrc
*                       p_motivo_rec.

*  DATA ld_a(1) TYPE c.
*  DATA ls_sval LIKE sval.
*  DATA lt_sval TYPE TABLE OF sval.
*  DATA l_motivo_rec TYPE dd07v-domvalue_l.
*  DATA l_text TYPE dd07v-ddtext.
*  DATA l_string TYPE string.
*  DATA l_paval TYPE  t001z-paval.


*  p_subrc = 4.
*
*  ls_sval-tabname = 'ZDTE_DOC_REC'.
*  ls_sval-fieldname = 'MOTIVO_REC'.
*  ls_sval-field_obl = 'X'.
*
*  APPEND ls_sval TO lt_sval.
*
*  CALL FUNCTION 'POPUP_GET_VALUES'
*    EXPORTING
**   NO_VALUE_CHECK        = ' '
*     popup_title           = 'Ingresar motivo de Rechazo'
**   START_COLUMN          = '5'
**   START_ROW             = '5'
*  IMPORTING
*    returncode            = ld_a
*   TABLES
*     fields                = lt_sval
*  EXCEPTIONS
*    error_in_fields       = 1
*    OTHERS                = 2.
*
*  READ TABLE lt_sval INTO ls_sval WITH KEY fieldname = 'MOTIVO_REC'.
*  IF sy-subrc = 0.
*    MOVE ls_sval-value TO l_motivo_rec.
*
**    CALL FUNCTION 'DOMAIN_VALUE_GET'
**      EXPORTING
**        i_domname  = 'ZDTE_MOTIVO_REC'
**        i_domvalue = l_motivo_rec
**      IMPORTING
**        e_ddtext   = l_text
**      EXCEPTIONS
**        not_exist  = 1
**        OTHERS     = 2.
*    SELECT COUNT(*) FROM zdtet_motivo_rec WHERE motivo_rec = l_motivo_rec.
*    IF sy-subrc <> 0.
*      MESSAGE i000(0k) WITH 'Motivo de Rechazo'
*                            l_motivo_rec 'no existe' DISPLAY LIKE 'E'.
*      RETURN.
*    ELSE.
*RUTRECEPTOR|RUTEMISOR|TIPODTE|FOLIO|RESPUESTA*|MOTIVO
** Respuestas 1, 2 o 3, que significan APROBAR, RECHAZAR o ENVÍO DE LEY
*respectivamente.
** En caso de enviar 2 se debe adjuntar el motivo obligatorio.
** En caso de enviar 3 se puede adjuntar el recinto en el campo MOTIVO
*opcionalmente.
*  DATA: l_rut(10) TYPE c,
*        l_d(10) TYPE c,
*        ls_rechazados LIKE LINE OF gt_rechazados.
*
**      MOVE l_motivo_rec TO p_motivo_rec.
*  MOVE p_motivo_rec TO l_text.
*
*  SELECT  SINGLE paval  INTO l_paval FROM  t001z
*         WHERE  bukrs  = '0100'
*         AND    party  = 'TAXNR'.
*
*  SPLIT l_paval AT '-' INTO l_rut l_d.
*
*  CONCATENATE l_paval
*              p_data-rutemisor
*              p_data-tipodte
*              p_data-folio
*              c_dte_rechazado
*              l_text INTO l_string SEPARATED BY '|'.
*  p_subrc = 0.
*
*  MOVE-CORRESPONDING p_data TO ls_rechazados.
*  ls_rechazados-rut = l_rut.
*  ls_rechazados-string = l_string.
*  APPEND ls_rechazados TO gt_rechazados.
*  CLEAR ls_rechazados.

*      PERFORM call_proxy USING l_rut l_string CHANGING p_subrc.
*    ENDIF.  "!!!!!!!!!

*  ENDIF.   "!!!!!!!!!!!!!!!!



*ENDFORM.                    " RECHAZAR


*&---------------------------------------------------------------------*
*&      Form  fill_internal_tables
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WA_DOC_REC text
*----------------------------------------------------------------------*
FORM f_fb61 USING wa_doc_rec TYPE ty_data CHANGING p_subrc p_obj_key p_year p_message.
  DATA wa_t003 TYPE t003.

  DATA: l_zterm TYPE lfb1-zterm,
        l_zwels TYPE lfb1-zwels,
        l_konth TYPE t030k-konth,
        l_lifnr TYPE lfa1-lifnr.

  DATA ld_a(1) TYPE c.
  DATA ls_sval LIKE sval.
  DATA lt_sval TYPE TABLE OF sval.
  DATA l_belnr TYPE bkpf-belnr.

  SELECT  SINGLE lifnr INTO l_lifnr  FROM  lfa1
         WHERE stcd1  = wa_doc_rec-rutemisor.

**********************************************************************
  CLEAR: it_accountpayable,
         it_accountgl,
         it_accounttax,
         it_criteria,
         it_valuefield,
         it_currencyamount,
         it_return,
         it_purchaseorder,
         it_purchaseamount,
         it_receivers,
         it_accountpayable[],
         it_accountgl[],
         it_accounttax[],
         it_criteria[],
         it_valuefield[],
         it_currencyamount[],
         it_return[],
         it_purchaseorder[],
         it_purchaseamount[],
         it_receivers.
**********************************************************************

*  ls_sval-tabname = 'BKPF'.
*  ls_sval-fieldname = 'BKTXT'.
*  ls_sval-field_obl = 'X'.
*  APPEND ls_sval TO lt_sval.
*  CLEAR ls_sval.
*
*  ls_sval-tabname = 'BSAK'.
*  ls_sval-fieldname = 'SGTXT'.
*  ls_sval-field_obl = 'X'.
*  APPEND ls_sval TO lt_sval.
*  CLEAR ls_sval.
*
*  ls_sval-tabname = 'INVFO'.
*  ls_sval-fieldname = 'HKONT'.
*  ls_sval-field_obl = 'X'.
*  APPEND ls_sval TO lt_sval.
*  CLEAR ls_sval.
*
*  ls_sval-tabname = 'INVFO'.
*  ls_sval-fieldname = 'MWSKZ'.
*  ls_sval-field_obl = 'X'.
*  APPEND ls_sval TO lt_sval.
*  CLEAR ls_sval.
*
*  ls_sval-tabname = 'CSKS'.
*  ls_sval-fieldname = 'KOSTL'.
*  ls_sval-field_obl = 'X'.
*  APPEND ls_sval TO lt_sval.
*  CLEAR ls_sval.
*
*  CALL FUNCTION 'POPUP_GET_VALUES'
*  EXPORTING
**   NO_VALUE_CHECK        = ' '
*   popup_title           = 'Ingresar datos para contabilización'
**   START_COLUMN          = '5'
**   START_ROW             = '5'
*IMPORTING
*  returncode            = ld_a
* TABLES
*   fields                = lt_sval
*EXCEPTIONS
*  error_in_fields       = 1
*  OTHERS                = 2.

  CALL SCREEN 2001  STARTING AT 2 5
                    ENDING AT 75 15.

  IF zdte_fb60 IS INITIAL.
    p_subrc = 99.   "cancel
    RETURN.
  ENDIF.

*  CHECK ld_a IS INITIAL.


  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      own_logical_system = gd_documentheader-obj_sys.

* fill header
  gd_documentheader-obj_type   = 'BKPFF'.

  SELECT SINGLE  * INTO wa_t003 FROM  t003
         WHERE  blart  = 'ZE'.
*NUMKR

  CALL FUNCTION 'RF_GET_DOCUMENT_NUMBER'
    EXPORTING
      company          = '0100'
      range            = wa_t003-numkr
      year             = sy-datum(4)
    IMPORTING
      document_number  = l_belnr
    EXCEPTIONS
      duplicate_number = 1
      range_missing    = 2
      error_in_open_fi = 3
      OTHERS           = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
    p_subrc = 4.
    RETURN.
  ENDIF.

  gd_documentheader-obj_key    = l_belnr.
* GD_DOCUMENTHEADER-OBJ_SYS    = FUNKTION OWN_LOGICAL_SYSTEM_GET
  gd_documentheader-username   = sy-uname.


  gd_documentheader-header_txt = zdte_fb60-bktxt.  "ingresado usuario


* GD_DOCUMENTHEADER-OBJ_KEY_R  =
  gd_documentheader-comp_code  = '0100'.
* GD_DOCUMENTHEADER-AC_DOC_NO  =
* GD_DOCUMENTHEADER-FISC_YEAR  =
  gd_documentheader-doc_date   = wa_doc_rec-fchemis.
  gd_documentheader-pstng_date = sy-datum.
  p_year = sy-datum(4).
* GD_DOCUMENTHEADER-TRANS_DATE =
* GD_DOCUMENTHEADER-VALUE_DATE =
* GD_DOCUMENTHEADER-FIS_PERIOD =
  CASE wa_doc_rec-tipodte.
    WHEN '33'.
      gd_documentheader-doc_type   = 'ZE'.
    WHEN '61'.
      gd_documentheader-doc_type   = 'ZG'.
  ENDCASE.
  gd_documentheader-ref_doc_no = wa_doc_rec-folio.
  SHIFT   gd_documentheader-ref_doc_no LEFT DELETING LEADING '0'.
* GD_DOCUMENTHEADER-COMPO_ACC  = .

* fill AP (line 1)
  it_accountpayable-itemno_acc     = 1.
  it_accountpayable-vendor_no      = l_lifnr.
* IT_ACCOUNTPAYABLE-REF_KEY_1      =
* IT_ACCOUNTPAYABLE-REF_KEY_2      =
* IT_ACCOUNTPAYABLE-REF_KEY_3      =
* IT_ACCOUNTPAYABLE-GL_ACCOUNT     =
  SELECT SINGLE zterm zwels INTO  (l_zterm,l_zwels) FROM lfb1 WHERE lifnr = l_lifnr AND bukrs = '0100'.

  it_accountpayable-pmnttrms       = l_zterm.
* IT_ACCOUNTPAYABLE-BLINE_DATE     =
* IT_ACCOUNTPAYABLE-DSCT_DAYS1     =
* IT_ACCOUNTPAYABLE-DSCT_DAYS2     =
* IT_ACCOUNTPAYABLE-NETTERMS1      =
* IT_ACCOUNTPAYABLE-DSCT_PCT1      =
* IT_ACCOUNTPAYABLE-DSCT_PCT2      =
* IT_ACCOUNTPAYABLE-PMTMTHSUPL     =
  it_accountpayable-pymt_meth      = l_zwels.
  it_accountpayable-pmnt_block     = 'A'.
* IT_ACCOUNTPAYABLE-SCBANK_IND     =
* IT_ACCOUNTPAYABLE-SUPCOUNTRY     =
* IT_ACCOUNTPAYABLE-SUPCOUNTRY_ISO =
* IT_ACCOUNTPAYABLE-BLLSRV_IND     =
* IT_ACCOUNTPAYABLE-ALLOC_NMBR     =


  it_accountpayable-item_text      = zdte_fb60-sgtxt. "ingresado usuario

* IT_ACCOUNTPAYABLE-PO_SUB_NO      =
* IT_ACCOUNTPAYABLE-PO_CHECKDG     =
* IT_ACCOUNTPAYABLE-PO_REF_NO      =
* IT_ACCOUNTPAYABLE-W_TAX_CODE     =
  APPEND it_accountpayable.
  CLEAR  it_accountpayable.

  it_currencyamount-itemno_acc   = 1.
*  it_currencyamount-curr_type    = '00'.
  it_currencyamount-currency     = 'CLP'.
* IT_CURRENCYAMOUNT-CURRENCY_ISO =
  it_currencyamount-amt_doccur   = wa_doc_rec-mnttotal * -1 * 100. " -100.
* IT_CURRENCYAMOUNT-EXCH_RATE    = 2.
  it_currencyamount-amt_base     = wa_doc_rec-mnttotal * -1 * 100.
* IT_CURRENCYAMOUNT-DISC_BASE    =
*  it_currencyamount-exch_rate_v  = '0.5'.
  APPEND it_currencyamount.
  CLEAR it_currencyamount.


* fill GL (line 2)
  it_accountgl-itemno_acc     = 2.

  it_accountgl-gl_account     = zdte_fb60-hkont. "ingresado usuario


  it_accountgl-comp_code      = '0100'.
* IT_ACCOUNTGL-PSTNG_DATE     =
* IT_ACCOUNTGL-DOC_TYPE       =
* IT_ACCOUNTGL-AC_DOC_NO      =
* IT_ACCOUNTGL-FISC_YEAR      =
* IT_ACCOUNTGL-FIS_PERIOD     =
* IT_ACCOUNTGL-STAT_CON       =
* IT_ACCOUNTGL-REF_KEY_1      =
* IT_ACCOUNTGL-REF_KEY_2      =
* IT_ACCOUNTGL-REF_KEY_3      =

  it_accountgl-tax_code       = zdte_fb60-mwskz. "ingresado por user

* IT_ACCOUNTGL-ACCT_KEY       =
* IT_ACCOUNTGL-TAXJURCODE     =
* IT_ACCOUNTGL-CSHDIS_IND     =
* IT_ACCOUNTGL-ACCT_TYPE      =
* IT_ACCOUNTGL-ALLOC_NMBR     =
  it_accountgl-item_text      = zdte_fb60-sgtxt_2.
*  it_accountgl-bus_area       = '99'.   "division

  it_accountgl-costcenter     = zdte_fb60-kostl.  "ingresao por usuario

* IT_ACCOUNTGL-PO_PR_QNT      =
* IT_ACCOUNTGL-PO_PR_UOM      =
* IT_ACCOUNTGL-PO_PR_UOM_ISO  =
* IT_ACCOUNTGL-ORDERID        =
* IT_ACCOUNTGL-ASSET_NO       =
* IT_ACCOUNTGL-SUB_NUMBER     =
* IT_ACCOUNTGL-ASVAL_DATE     =
* IT_ACCOUNTGL-MATERIAL       =
* IT_ACCOUNTGL-QUANTITY       =
* IT_ACCOUNTGL-BASE_UOM       =
* IT_ACCOUNTGL-BASE_UOM_ISO   =
* IT_ACCOUNTGL-PLANT          =
* IT_ACCOUNTGL-ORIG_GROUP     =
* IT_ACCOUNTGL-ORIG_MAT       =
* IT_ACCOUNTGL-COST_OBJ       =
* IT_ACCOUNTGL-PROFIT_CTR     =
* IT_ACCOUNTGL-PART_PRCTR     =
* IT_ACCOUNTGL-WBS_ELEMENT    =
* IT_ACCOUNTGL-NETWORK        =
* IT_ACCOUNTGL-ROUTING_NO     =
* IT_ACCOUNTGL-ORDER_ITNO     =
* IT_ACCOUNTGL-CMMT_ITEM      =
* IT_ACCOUNTGL-FUNDS_CTR      =
* IT_ACCOUNTGL-FUND           =
* IT_ACCOUNTGL-SALES_ORD      =
* IT_ACCOUNTGL-S_ORD_ITEM     =
* IT_ACCOUNTGL-TRADE_ID       =
* IT_ACCOUNTGL-VAL_AREA       =
* IT_ACCOUNTGL-VAL_TYPE       =
* IT_ACCOUNTGL-OBJ_TYP_P      =
* IT_ACCOUNTGL-OBJ_KEY_P      =
* IT_ACCOUNTGL-OBJ_POS_P      =
* IT_ACCOUNTGL-ITEM_CAT       =
* IT_ACCOUNTGL-DE_CRE_IND     =
* IT_ACCOUNTGL-MATL_TYPE      =
* IT_ACCOUNTGL-P_EL_PRCTR     =
* IT_ACCOUNTGL-COND_TYPE      =
* IT_ACCOUNTGL-COND_ST_NO     =
* IT_ACCOUNTGL-COND_COUNT     =
* IT_ACCOUNTGL-FUNC_AREA      =
* IT_ACCOUNTGL-ENTRY_QNT      =
* IT_ACCOUNTGL-ENTRY_UOM      =
* IT_ACCOUNTGL-ENTRY_UOM_ISO  =
* IT_ACCOUNTGL-ACTTYPE        =
* IT_ACCOUNTGL-CO_BUSPROC     =
  APPEND it_accountgl.
  CLEAR it_accountgl.

  it_currencyamount-itemno_acc   = 2.
*  it_currencyamount-curr_type    = '00'.
  it_currencyamount-currency     = 'CLP'.
* IT_CURRENCYAMOUNT-CURRENCY_ISO =
  it_currencyamount-amt_doccur   = wa_doc_rec-mntneto * 100.
* IT_CURRENCYAMOUNT-EXCH_RATE    = 2.
  it_currencyamount-amt_base     =  wa_doc_rec-mntneto * 100.
* IT_CURRENCYAMOUNT-DISC_BASE    =
*  it_currencyamount-exch_rate_v  = '0.5'.
  APPEND it_currencyamount.
  CLEAR it_currencyamount.


  IF wa_doc_rec-iva IS NOT INITIAL.
* fill tax
    it_accounttax-itemno_acc = 3.
    SELECT SINGLE konth INTO l_konth FROM  t030k
           WHERE  ktopl  = 'PCPR'
           AND    ktosl  = 'VST' "'MWS'
           AND    mwskz  = 'C2'.

    it_accounttax-gl_account = l_konth.
    it_accounttax-tax_code   = 'C2'.
* IT_ACCOUNTTAX-ACCT_KEY   =
* IT_ACCOUNTTAX-TAXJURCODE =
* IT_ACCOUNTTAX-COND_KEY   =
* IT_ACCOUNTTAX-TAX_RATE   =
* IT_ACCOUNTTAX-TAX_DATE   =
* IT_ACCOUNTTAX-STAT_CON   =
    APPEND it_accounttax.

    it_currencyamount-itemno_acc   = 3.
* IT_CURRENCYAMOUNT-CURR_TYPE    = '00'.
    it_currencyamount-currency     = 'CLP'.
* IT_CURRENCYAMOUNT-CURRENCY_ISO =
    it_currencyamount-amt_doccur   = wa_doc_rec-iva * 100.
* IT_CURRENCYAMOUNT-EXCH_RATE    = 2.
    it_currencyamount-amt_base     = wa_doc_rec-iva * 100.
* IT_CURRENCYAMOUNT-DISC_BASE    =
* IT_CURRENCYAMOUNT-EXCH_RATE_V  = '0.5'.
    APPEND it_currencyamount.
    CLEAR it_currencyamount.

  ENDIF.

  break c_ptapia.

  CALL FUNCTION 'BAPI_ACC_INVOICE_RECEIPT_CHECK'
       EXPORTING
            documentheader = gd_documentheader
       TABLES
            accountpayable = it_accountpayable
            accountgl      = it_accountgl
            accounttax     = it_accounttax
            currencyamount = it_currencyamount
            purchaseorder  = it_purchaseorder
            purchaseamount = it_purchaseamount
            return         = it_return
            criteria       = it_criteria
            valuefield     = it_valuefield
*           EXTENSION1     = it_EXTENSION1
            .

  LOOP AT it_return WHERE type = 'E'.
  ENDLOOP.
  IF sy-subrc <> 0.
    CALL FUNCTION 'BAPI_ACC_INVOICE_RECEIPT_POST'
       EXPORTING
            documentheader = gd_documentheader
            customercpd    = gd_customercpd
        IMPORTING
*             OBJ_TYPE       =
             obj_key        = p_obj_key
*             OBJ_SYS        =
       TABLES
            accountpayable = it_accountpayable
            accountgl      = it_accountgl
            accounttax     = it_accounttax
            currencyamount = it_currencyamount
            purchaseorder  = it_purchaseorder
            purchaseamount = it_purchaseamount
            return         = it_return
            criteria       = it_criteria
            valuefield     = it_valuefield.
    LOOP AT it_return WHERE type = 'E'.
    ENDLOOP.
    IF sy-subrc <> 0.
      p_subrc = 0.


    ENDIF.

  ELSE.
    p_subrc = 4.
    MESSAGE ID it_return-id TYPE 'I' NUMBER it_return-number
                        WITH it_return-message_v1
                             it_return-message_v2
                             it_return-message_v3
                             it_return-message_v4 INTO p_message.

  ENDIF.
ENDFORM.                               " fill_internal_tables
*&---------------------------------------------------------------------*
*&      Form  CALL_PROXY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_SUBRC  text
*----------------------------------------------------------------------*
FORM call_proxy  USING p_rechazados LIKE gt_rechazados[] CHANGING p_subrc.

*  DATA msg            TYPE c LENGTH 255.
*  DATA ls_rechazados  LIKE LINE OF gt_rechazados.
*  DATA l_string       TYPE string.
*  DATA l_lines        TYPE i.
** proxy client
*  DATA lo_proxy       TYPE REF TO zpico_consulta_aprob_rech_dteq.
*  DATA ls_output      TYPE zpiconsulta_aprob_rech_dtequer.
*  DATA ls_input       TYPE zpiconsulta_aprob_rech_dteresp.
*  DATA lo_system_ex   TYPE REF TO cx_ai_system_fault.
*  DATA lo_app_ex      TYPE REF TO cx_ai_application_fault.
*
*  p_subrc = 0.
*
*  l_lines = LINES( gt_rechazados ).
*  LOOP AT gt_rechazados INTO ls_rechazados.
*    IF sy-tabix < l_lines.
*      CONCATENATE l_string
*                  ls_rechazados-string
*                  cl_abap_char_utilities=>cr_lf
*                  INTO l_string.
*    ELSE.
*      CONCATENATE l_string
*                  ls_rechazados-string
*                  INTO l_string.
*    ENDIF.
*  ENDLOOP.
*  CONDENSE l_string.
*
*  ls_output-consulta_aprob_rech_dtequery-args0 = ls_rechazados-rut.
*  ls_output-consulta_aprob_rech_dtequery-args1 = ''.  "user
*  ls_output-consulta_aprob_rech_dtequery-args2 = 'MD5'.  "passw
*  ls_output-consulta_aprob_rech_dtequery-args3 = l_string.
*
*
*  CLEAR msg.
*  TRY.
** create proxy
*      CREATE OBJECT lo_proxy.
*
*      CALL METHOD lo_proxy->consulta_aprob_rech_dtequery_o
*        EXPORTING
*          output = ls_output
*        IMPORTING
*          input  = ls_input.
*    CATCH cx_ai_system_fault  INTO lo_system_ex.
**      WRITE lo_system_ex->errortext TO msg.
**      msg =   lo_system_ex->if_message~get_text( ).
*    CATCH cx_ai_application_fault INTO lo_app_ex.
**      WRITE  lo_app_ex->textid TO msg.
**      msg = lo_app_ex->if_message~get_text( ).
*  ENDTRY.
*
*
*  IF lo_system_ex IS NOT INITIAL.
*    msg =   lo_system_ex->if_message~get_text( ).
*    MESSAGE i899(v1) WITH 'Error Interfaz:' msg(50) msg+50(50) msg+100(50) DISPLAY LIKE 'E'.
*    p_subrc = 2.
*    RETURN.
*  ENDIF.
*
*  IF lo_app_ex IS NOT INITIAL.
*    msg =   lo_app_ex->if_message~get_text( ).
*    MESSAGE i899(v1) WITH 'Error en WS:' msg(50) msg+50(50) msg+100(50) DISPLAY LIKE 'E'.
*    p_subrc = 1.
*    RETURN.
*  ENDIF.
*
*  DATA l_s1 TYPE string.
*  DATA l_s2 TYPE string.
*
*  MOVE ls_input-consulta_aprob_rech_dterespons-return TO l_string.
*
** obtenemos código de respuesta
** &lt;Codigo>-1&lt;/Codigo>
*  SPLIT l_string AT 'Codigo>' INTO l_s1 l_s2.
*  SPLIT l_s2 AT '&lt;/Codigo>' INTO l_s1 l_s2.
*
*  IF l_s1 <> '0'.
**error
** &lt;Codigo>-1&lt;/Codigo>
** &lt;Mensaje>Error al conectarse con la Base de Datos&lt;/Mensaje>
*
*    SPLIT l_s2 AT '&lt;Mensaje>' INTO l_s1 l_s2.
*    SPLIT l_s2 AT '&lt;/Mensaje>' INTO l_s1 l_s2.
*
*    MESSAGE i899(v1) WITH l_s2 DISPLAY LIKE 'E'.
*
*    p_subrc = 3.
*    RETURN.
*  ELSE.
*    SPLIT l_s2 AT '&lt;Mensaje>' INTO l_s1 l_s2.
*    SPLIT l_s2 AT '&lt;/Mensaje>' INTO l_s1 l_s2.
*
*    REPLACE ALL OCCURRENCES OF '&lt;' IN l_s1 WITH '<'.
*
*    DATA ls_resp TYPE zdte_resp_proceso.
**    DATA ls_desc LIKE LINE OF gt_desc.
*
*    TRY.
*        CALL TRANSFORMATION zdte_resp_proceso
*             SOURCE  XML l_s1
*             RESULT  proceso = ls_resp.
*      CATCH cx_st_error.
*    ENDTRY.
*
*    CLEAR gt_desc[].
**    PERFORM lee_descripcion
**                USING
**                   ls_resp-descripcion
**                CHANGING
**                   gt_desc[].
*
*    LOOP AT gt_desc INTO ls_desc WHERE respuesta <> '0'.
*      MOVE-CORRESPONDING ls_desc TO news.
*      news-text = ls_desc-motivo.
*      news-color = col_negative.
*      APPEND news.
*    ENDLOOP.
*    IF sy-subrc = 0.
*      MESSAGE i000(0k) WITH 'Se encontraron errores desde SII' 'Ver LOG' DISPLAY LIKE 'E'.
*    ENDIF.
*
*    LOOP AT gt_desc INTO ls_desc WHERE respuesta = '0'.
*      MOVE-CORRESPONDING ls_desc TO news.
*      news-text = ls_desc-motivo.
*      news-color = col_positive.
*      APPEND news.
*    ENDLOOP.
*
*
*  ENDIF.

ENDFORM.                    " CALL_PROXY



*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR gt_bdcdata.
  gt_bdcdata-program  = program.
  gt_bdcdata-dynpro   = dynpro.
  gt_bdcdata-dynbegin = 'X'.
  APPEND gt_bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval <> gv_nodata.
    CLEAR gt_bdcdata.
    gt_bdcdata-fnam = fnam.
    gt_bdcdata-fval = fval.
    APPEND gt_bdcdata.
  ENDIF.
ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  miro_manual
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DATA     text
*----------------------------------------------------------------------*
FORM miro_manual USING p_data TYPE ty_data CHANGING p_subrc
                                                    p_invoicedocnumber
                                                    p_fiscalyear
                                                    p_message.
  DATA lt_ref TYPE TABLE OF zdte_doc_rec_ref WITH HEADER LINE.
  DATA ls_ref LIKE LINE OF lt_ref.

  DATA l_c TYPE bdc_fval.

  CLEAR: gt_bdcdata[],
         gt_messtab[],
         gt_messtab.

  CLEAR p_message.

  SELECT * INTO TABLE lt_ref  FROM  zdte_doc_rec_ref
         WHERE  rutemisor  = p_data-rutemisor
         AND    tipodte    = p_data-tipodte
         AND    folio      = p_data-folio.

  LOOP AT lt_ref INTO ls_ref WHERE  tpodocref = '801'.
    EXIT.
  ENDLOOP.

  PERFORM bdc_dynpro      USING 'SAPLMR1M' '6000'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=DUMMY'.
  IF wa_data-tipodte = '61'. "nota de credito
    PERFORM bdc_field       USING 'RM08M-VORGANG'
                               '4'.
  ELSE.
    PERFORM bdc_field       USING 'RM08M-VORGANG'
                                  '1'.
  ENDIF.

  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'INVFO-XMWST'.
  WRITE p_data-fchemis TO l_c.
  PERFORM bdc_field       USING 'INVFO-BLDAT'
                                l_c.
  MOVE p_data-folio TO l_c.
  SHIFT l_c LEFT DELETING LEADING '0'.

  PERFORM bdc_field       USING 'INVFO-XBLNR'
                                l_c.
  WRITE sy-datum TO l_c.
  PERFORM bdc_field       USING 'INVFO-BUDAT'
                                l_c.
  WRITE p_data-mnttotal TO l_c CURRENCY p_data-waers.
  CONDENSE l_c.
  PERFORM bdc_field       USING 'INVFO-WRBTR'
                                l_c.
  PERFORM bdc_field       USING 'INVFO-XMWST'
                                'X'.
  PERFORM bdc_field       USING 'INVFO-MWSKZ'
                                'C2'.

  WRITE p_data-iva TO l_c CURRENCY p_data-waers.
  CONDENSE l_c.
  PERFORM bdc_field       USING 'INVFO-WMWST'
                                l_c.

  PERFORM bdc_field       USING 'INVFO-WAERS'
                              p_data-waers.

*--------------------------------------------------------------------*
  PERFORM bdc_field       USING 'RM08M-REFERENZBELEGTYP'
                                '1'.
  PERFORM bdc_field       USING 'RM08M-EBELN'
                                ls_ref-folioref.
  PERFORM bdc_field       USING 'RM08M-XWARE_BNK'
                                '1'.
  PERFORM bdc_field       USING 'RM08M-ITEM_LIST_VERSION'
                                '7_6310'.


*--------------------------------------------------------------------*
  CALL TRANSACTION 'MIRO' USING gt_bdcdata
                 MODE   'A'
*                     UPDATE CUPDATE
                  MESSAGES INTO gt_messtab.
  p_subrc = 1.

  LOOP AT gt_messtab WHERE msgtyp = 'S'
                       AND msgid = 'M8'
                       AND msgnr = '060'
                       AND msgv1 IS NOT INITIAL.
  ENDLOOP.
  IF sy-subrc = 0.
    p_subrc = 0.
    p_invoicedocnumber = gt_messtab-msgv1.
    p_fiscalyear = sy-datum(4).
  ELSE.
    LOOP AT gt_messtab WHERE msgtyp = 'E'.
    ENDLOOP.
    IF sy-subrc = 0.
      MESSAGE ID gt_messtab-msgid TYPE gt_messtab-msgtyp NUMBER gt_messtab-msgnr
                           WITH gt_messtab-msgv1
                                gt_messtab-msgv2
                                gt_messtab-msgv3
                                gt_messtab-msgv4 INTO p_message.
    ENDIF.
  ENDIF.

*  DATA w_rbkp TYPE rbkp.
*
*  IF p_invoicedocnumber eq space.
*    SELECT SINGLE * INTO w_rbkp
*      FROM rbkp
*     WHERE xblnr EQ p_data-folio
**       AND bukrs EQ lv_bukrs..
*      .
*    p_invoicedocnumber  = w_rbkp-belnr.
*    p_fiscalyear        = w_rbkp-gjahr.
*  ENDIF.


*perform bdc_field       using 'RM08M-REFERENZBELEGTYP'
*                              '1'.
*perform bdc_field       using 'RM08M-XWARE_BNK'
*                              '1'.
*perform bdc_field       using 'RM08M-ITEM_LIST_VERSION'
*                              '7_6310'.
ENDFORM.                    "miro_manual

*&---------------------------------------------------------------------*
*&      Form  PROTOKOLL
*&---------------------------------------------------------------------*
FORM protokoll.
  WRITE: /(125) sy-uline.
  LOOP AT news.
    WRITE: / sy-vline,
           2 news-rutemisor NO-ZERO COLOR COL_KEY,
           12 sy-vline,
           13 news-tipodte NO-ZERO COLOR COL_KEY,
           16 sy-vline,
           17 news-folio NO-ZERO COLOR COL_KEY,
           27 sy-vline.

    IF news-color IS INITIAL.
      news-color = col_normal.
    ENDIF.
    WRITE: 28 news-text INTENSIFIED OFF COLOR = news-color.
    WRITE: 125 sy-vline.
  ENDLOOP.
  WRITE: /(125) sy-uline.

ENDFORM.                               " PROTOKOLL
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_2001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM user_command_2001 .

  DATA l_ok_code LIKE ok_code.

  l_ok_code = ok_code.
  CLEAR ok_code.

  CASE l_ok_code.
    WHEN 'CANC'.
      CLEAR zdte_fb60.
  ENDCASE.

  SET SCREEN 0.
  LEAVE SCREEN.

ENDFORM.                    " USER_COMMAND_2001


*&---------------------------------------------------------------------*
*&      Form  lee_descripcion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LINE     text
*      -->P_DESC     text
*----------------------------------------------------------------------*
*FORM lee_descripcion USING p_line CHANGING p_desc TYPE ty_tdesc..
*data lt_desc type TABLE OF ZDTE_RESP_PROCESO_DESC.
*  DATA ls_desc LIKE LINE OF p_desc.
*  DATA l_field TYPE string.
*
*  DATA l_cont TYPE i.
*  DATA l_lines TYPE i.
*  DATA l_s1 TYPE string.
*  DATA l_s2 TYPE string.
*
*  DATA l_valor TYPE string.
*  FIELD-SYMBOLS <fs> TYPE ANY.
*  DATA: descr_struc_ref TYPE REF TO cl_abap_structdescr,
*         lt_components TYPE abap_compdescr_tab,
*         ls_components LIKE LINE OF lt_components.
*
*  l_cont = 1.
*
*
*  descr_struc_ref ?= cl_abap_typedescr=>describe_by_data( ls_desc ).
*
*  lt_components = descr_struc_ref->components.
**loop at lt_components into ls_components.
** write:/ ls_components-name.
**endloop.
*  l_lines = LINES( lt_components ).
*
*
*  l_s1 = p_line.
*
*  REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN l_s1 WITH '|'.
*  REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN l_s1 WITH '|'.
*
*  DO.
*    SPLIT l_s1 AT '|' INTO l_s1 l_s2.
*    IF l_s1 IS INITIAL .
*      EXIT.
*    ENDIF.
*
*    l_valor = l_s1.
*    l_s1 = l_s2.
*
*    READ TABLE lt_components INTO ls_components INDEX l_cont.
*    CONCATENATE 'LS_DESC' ls_components-name INTO l_field SEPARATED BY '-'.
*    ASSIGN (l_field) TO <fs>.
*    <fs> = l_valor.
*
*    IF l_cont = l_lines.
*      APPEND ls_desc TO p_desc.
*      l_cont = 0.
*      CLEAR ls_desc.
*    ENDIF.
*
*    ADD 1 TO l_cont.
*  ENDDO.
*ENDFORM.                    "lee_descripcion
*&---------------------------------------------------------------------*
*&      Form  EJECUTA_FB60
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_DATA  text
*      <--P_L_OBJ_KEY  text
*      <--P_L_YEAR  text
*----------------------------------------------------------------------*
FORM ejecuta_fb60  USING    p_wa_data
                   CHANGING p_l_obj_key
                            p_l_year.

  DATA l_c      TYPE bdc_fval.

  DATA lv_bukrs TYPE bukrs.

  SELECT SINGLE bukrs INTO lv_bukrs
  FROM  t001z
  WHERE paval EQ wa_data-rutrecep
    AND party EQ 'TAXNR'.
  IF sy-subrc EQ 0.

  ELSE.
    EXIT.
  ENDIF.

  SET PARAMETER ID 'BUK' FIELD lv_bukrs.
*  CALL TRANSACTION 'FB60'." USING


*  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0100'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'        'RF05L-BELNR'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'        '/00'.
**  PERFORM bdc_field       USING 'RF05L-BELNR'       record-belnr_001.
*  PERFORM bdc_field       USING 'RF05L-BUKRS'       lv_bukrs.
*  WRITE sy-datum+0(4) TO l_c.
*  PERFORM bdc_field       USING 'RF05L-GJAHR'       l_c.
*
*  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0700'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'        'RF05L-ANZDT(01)'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'        '=PK'.
*
*  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0302'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'        'BSEG-ZTERM'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'        '=ZK'.
**  PERFORM bdc_field       USING 'BSEG-ZTERM'        'ZC03'.
**  PERFORM bdc_field       USING 'BSEG-ZBD1T'        record-zbd1t_005.
*  WRITE sy-datum TO l_c.
*  PERFORM bdc_field       USING 'BSEG-ZFBDT'        l_c.
*  PERFORM bdc_field       USING 'BSEG-ZLSPR'        'A'.
*  PERFORM bdc_field       USING 'BSEG-ZLSCH'        'V'.
*  PERFORM bdc_field       USING 'BSEG-SGTXT'        wa_data-rznsoc.
*
*  PERFORM bdc_dynpro      USING 'SAPMF05L'          '1302'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'        'BSEG-ZZMOT_EMIS'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'        '=ENTR'.
*  PERFORM bdc_field       USING 'BSEG-HBKID'        'COR01'.
*  PERFORM bdc_field       USING 'BSEG-FDLEV'        'F1'.
*  PERFORM bdc_field       USING 'BSEG-ZZMOT_EMIS'   'PROVEEDO_F'.
*
*  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0302'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'        'BSEG-ZTERM'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'        '=AE'.
**  PERFORM bdc_field       USING 'BSEG-ZTERM'        record-zterm_013.
**  PERFORM bdc_field       USING 'BSEG-ZBD1T'        record-zbd1t_014.
*  WRITE sy-datum TO l_c.
*  PERFORM bdc_field       USING 'BSEG-ZFBDT'        l_c.
*  PERFORM bdc_field       USING 'BSEG-ZLSPR'        'A'.
*  PERFORM bdc_field       USING 'BSEG-ZLSCH'        'V'.
*  PERFORM bdc_field       USING 'BSEG-SGTXT'        wa_data-rznsoc.

**********************************************************************
*
**********************************************************************
*
*  PERFORM bdc_dynpro      USING 'SAPMF05A' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'   '=DOCT'.
*  PERFORM bdc_field       USING 'RF05A-BUSCS'   record-buscs_001.
*  PERFORM bdc_field       USING 'BDC_CURSOR'  'INVFO-BLART'.
*  PERFORM bdc_field       USING 'INVFO-ACCNT'   record-accnt_002.
*  PERFORM bdc_field       USING 'INVFO-BLDAT'   record-bldat_003.
*  PERFORM bdc_field       USING 'INVFO-XBLNR'   record-xblnr_004.
*  PERFORM bdc_field       USING 'INVFO-BUDAT'   record-budat_005.
*  PERFORM bdc_field       USING 'INVFO-BLART'      record-blart_006.
*  PERFORM bdc_field       USING 'INVFO-WAERS'      record-waers_007.
*  PERFORM bdc_dynpro      USING 'SAPMF05A' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE' '=DUMMY'.
*  PERFORM bdc_field       USING 'RF05A-BUSCS'  record-buscs_008.
*  PERFORM bdc_field       USING 'BDC_CURSOR'  'INVFO-XMWST'.
*  PERFORM bdc_field       USING 'INVFO-ACCNT'  record-accnt_009.
*  PERFORM bdc_field       USING 'INVFO-XBLNR'  record-xblnr_010.
*  PERFORM bdc_field       USING 'INVFO-BLART'  record-blart_011.
*  PERFORM bdc_field       USING 'INVFO-WRBTR'   record-wrbtr_012.
*  PERFORM bdc_field       USING 'INVFO-WAERS'  record-waers_013.
*  PERFORM bdc_field       USING 'INVFO-XMWST'  record-xmwst_014.
*  PERFORM bdc_field       USING 'INVFO-SGTXT'   record-sgtxt_015.
*  PERFORM bdc_dynpro      USING 'SAPMF05A' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'    '=DUMMY'.
*  PERFORM bdc_field       USING 'RF05A-BUSCS'   record-buscs_016.
*  PERFORM bdc_field       USING 'BDC_CURSOR'  'INVFO-MWSKZ'.
*  PERFORM bdc_field       USING 'INVFO-ACCNT'  record-accnt_017.
*  PERFORM bdc_field       USING 'INVFO-XBLNR'    record-xblnr_018.
*  PERFORM bdc_field       USING 'INVFO-BLART'    record-blart_019.
*  PERFORM bdc_field       USING 'INVFO-WRBTR'   record-wrbtr_020.
*  PERFORM bdc_field       USING 'INVFO-XMWST'       record-xmwst_021.
*  PERFORM bdc_field       USING 'INVFO-MWSKZ'   record-mwskz_022.
*  PERFORM bdc_field       USING 'INVFO-SGTXT'   record-sgtxt_023.
*  PERFORM bdc_dynpro      USING 'SAPMF05A' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'     '/00'.
*  PERFORM bdc_field       USING 'RF05A-BUSCS'
*                                record-buscs_024.
*  PERFORM bdc_field       USING 'INVFO-ACCNT'
*                                record-accnt_025.
*  PERFORM bdc_field       USING 'INVFO-XBLNR'
*                                record-xblnr_026.
*  PERFORM bdc_field       USING 'INVFO-BLART'
*                                record-blart_027.
*  PERFORM bdc_field       USING 'INVFO-WRBTR'
*                                record-wrbtr_028.
*  PERFORM bdc_field       USING 'INVFO-XMWST'
*                                record-xmwst_029.
*  PERFORM bdc_field       USING 'INVFO-MWSKZ'
*                                record-mwskz_030.
*  PERFORM bdc_field       USING 'INVFO-SGTXT'
*                                record-sgtxt_031.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'ACGL_ITEM-KOSTL(01)'.
*  PERFORM bdc_field       USING 'ACGL_ITEM-HKONT(01)'
*                                record-hkont_01_032.
*  PERFORM bdc_field       USING 'ACGL_ITEM-WRBTR(01)'
*                                record-wrbtr_01_033.
*  PERFORM bdc_field       USING 'ACGL_ITEM-ZUONR(01)'
*                                record-zuonr_01_034.
*  PERFORM bdc_field       USING 'ACGL_ITEM-SGTXT(01)'
*                                record-sgtxt_01_035.
*  PERFORM bdc_field       USING 'ACGL_ITEM-KOSTL(01)'
*                                record-kostl_01_036.
*  PERFORM bdc_dynpro      USING 'SAPMF05A' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'INVFO-BKTXT'.
*  PERFORM bdc_field       USING 'INVFO-HKONT'
*                                record-hkont_037.
*  PERFORM bdc_field       USING 'INVFO-ZUONR'
*                                record-zuonr_038.
*  PERFORM bdc_field       USING 'INVFO-BKTXT'
*                                record-bktxt_039.
*  PERFORM bdc_field       USING 'INVFO-FDLEV'
*                                record-fdlev_040.
*  PERFORM bdc_field       USING 'INVFO-FDTAG'
*                                record-fdtag_041.
*  PERFORM bdc_dynpro      USING 'SAPMF05A' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '=PAYM'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'INVFO-BKTXT'.
*  PERFORM bdc_field       USING 'INVFO-HKONT'
*                                record-hkont_042.
*  PERFORM bdc_field       USING 'INVFO-ZUONR'
*                                record-zuonr_043.
*  PERFORM bdc_field       USING 'INVFO-BKTXT'
*                                record-bktxt_044.
*  PERFORM bdc_field       USING 'INVFO-FDLEV'
*                                record-fdlev_045.
*  PERFORM bdc_field       USING 'INVFO-FDTAG'
*                                record-fdtag_046.
*  PERFORM bdc_dynpro      USING 'SAPMF05A' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'INVFO-ZLSCH'.
*  PERFORM bdc_field       USING 'INVFO-ZFBDT'
*                                record-zfbdt_047.
*  PERFORM bdc_field       USING 'INVFO-ZTERM'
*                                record-zterm_048.
*  PERFORM bdc_field       USING 'INVFO-ZLSCH'
*                                record-zlsch_049.
*  PERFORM bdc_dynpro      USING 'SAPMF05A' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'INVFO-ZTERM'.
*  PERFORM bdc_field       USING 'INVFO-ZFBDT'
*                                record-zfbdt_050.
*  PERFORM bdc_field       USING 'INVFO-ZTERM'
*                                record-zterm_051.
*  PERFORM bdc_field       USING 'INVFO-ZLSCH'
*                                record-zlsch_052.
*  PERFORM bdc_dynpro      USING 'SAPMF05A' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '=BU'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'INVFO-ZTERM'.
*  PERFORM bdc_field       USING 'INVFO-ZFBDT'
*                                record-zfbdt_053.
*  PERFORM bdc_field       USING 'INVFO-ZTERM'
*                                record-zterm_054.
*  PERFORM bdc_field       USING 'INVFO-ZLSCH'
*                                record-zlsch_055.
*  PERFORM bdc_transaction USING 'FB60'.


**********************************************************************
*
**********************************************************************
*--------------------------------------------------------------------*
  REFRESH gt_messtab.
  CLEAR: p_l_obj_key, p_l_year.

  CALL TRANSACTION 'FB60' USING gt_bdcdata
                 MODE   'A'
*                     UPDATE CUPDATE
                  MESSAGES INTO gt_messtab.


*  p_subrc = 1.
*
  WAIT UP TO 1 SECONDS.

  LOOP AT gt_messtab WHERE msgtyp = 'S'
                       AND msgid = 'FP'
                       AND msgnr = '001'
                       AND msgv1 IS NOT INITIAL.
    p_l_obj_key = gt_messtab-msgv1.
    p_l_year = gt_messtab-msgv2.
  ENDLOOP.
*  IF sy-subrc = 0.
*    p_subrc = 0.
*    p_invoicedocnumber = gt_messtab-msgv1.
*    p_fiscalyear = sy-datum(4).
*  ELSE.
*    LOOP AT gt_messtab WHERE msgtyp = 'E'.
*    ENDLOOP.
*    IF sy-subrc = 0.
*      MESSAGE ID gt_messtab-msgid TYPE gt_messtab-msgtyp NUMBER gt_messtab-msgnr
*                           WITH gt_messtab-msgv1
*                                gt_messtab-msgv2
*                                gt_messtab-msgv3
*                                gt_messtab-msgv4 INTO p_message.
*    ENDIF.
*  ENDIF.

  DATA: w_bkpf TYPE bkpf.
  RANGES: s_blart FOR bkpf-blart .                          "FA F3 F7

  s_blart-sign   = 'I'.
  s_blart-option = 'EQ'.
  s_blart-low = 'FA'. APPEND s_blart.
  s_blart-low = 'F3'. APPEND s_blart.
  s_blart-low = 'F7'. APPEND s_blart.

  IF p_l_obj_key NE space.
    SELECT SINGLE * INTO w_bkpf
      FROM bkpf
     WHERE bukrs EQ lv_bukrs
       AND xblnr EQ wa_data-folio
       AND blart IN s_blart.

    IF  sy-subrc EQ 0.
      p_l_obj_key = w_bkpf-belnr.
      p_l_year    = w_bkpf-gjahr.
    ENDIF.

  ENDIF.


ENDFORM.                    " EJECUTA_FB60

*&---------------------------------------------------------------------*
*&      Form  ejecuta_zfitr006b
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_DATA    text
*      -->P_L_OBJ_KEY  text
*      -->P_L_YEAR     text
*----------------------------------------------------------------------*
FORM ejecuta_zfitr006b  USING p_wa_data
                     CHANGING p_l_obj_key
                              p_l_year.
  DATA l_c      TYPE bdc_fval.

  DATA lv_bukrs TYPE bukrs.
  DATA t_return TYPE TABLE OF  bapiret2 WITH HEADER LINE.

  SELECT SINGLE bukrs INTO lv_bukrs
  FROM  t001z
  WHERE paval EQ wa_data-rutrecep
    AND party EQ 'TAXNR'.
  IF sy-subrc EQ 0.

  ELSE.
    EXIT.
  ENDIF.

  SET PARAMETER ID 'BUK' FIELD lv_bukrs.

  REFRESH : gt_messtab , t_return.
  CALL TRANSACTION 'ZFITR006B' USING gt_bdcdata
               MODE   'A'
*                     UPDATE CUPDATE
                MESSAGES INTO gt_messtab.


  LOOP AT gt_messtab WHERE msgv1 NE space .
    t_return-type = gt_messtab-msgtyp.
    t_return-id = gt_messtab-msgid.
    t_return-number = gt_messtab-msgnr.
    CONCATENATE gt_messtab-msgv1 gt_messtab-msgv2 gt_messtab-msgv3 gt_messtab-msgv4
           INTO t_return-message SEPARATED BY space.

    t_return-message_v1 = gt_messtab-msgv1.
    t_return-message_v2 = gt_messtab-msgv2.
    t_return-message_v3 = gt_messtab-msgv3 .
    t_return-message_v4 = gt_messtab-msgv4.
    MOVE-CORRESPONDING gt_messtab TO t_return.
    APPEND t_return.
  ENDLOOP.

  DATA: w_bkpf TYPE bkpf.
  RANGES: s_blart FOR bkpf-blart .                          "FA F3 F7

  s_blart-sign   = 'I'.
  s_blart-option = 'EQ'.
  s_blart-low = 'FA'. APPEND s_blart.
  s_blart-low = 'F1'. APPEND s_blart.
  s_blart-low = 'F3'. APPEND s_blart.
  s_blart-low = 'F7'. APPEND s_blart.

  SELECT SINGLE * INTO w_bkpf
    FROM bkpf
   WHERE bukrs EQ lv_bukrs
     AND xblnr EQ wa_data-folio
     AND blart IN s_blart.

  IF  sy-subrc EQ 0.
    p_l_obj_key = w_bkpf-belnr.
    p_l_year    = w_bkpf-gjahr.

  ELSE.
    IF NOT t_return[] IS INITIAL.
      CALL FUNCTION 'RSCRMBW_DISPLAY_BAPIRET2'
        TABLES
          it_return = t_return.
    ENDIF.

  ENDIF.


ENDFORM .                   "ejecuta_zfitr006b
