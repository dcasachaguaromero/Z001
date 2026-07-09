*----------------------------------------------------------------------*
***INCLUDE LZDTE_CONTABILIZAF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0599   text
*      -->P_LV_MONTO_CAB_TXT  text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  BDC_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0546   text
*----------------------------------------------------------------------*
FORM bdc_transaction  TABLES mensaje_salida USING tcode folio i_resultado i_ctumode.
  DATA: l_mstring(480).
  DATA: l_subrc LIKE sy-subrc.
  DATA: ctumode LIKE ctu_params-dismode.
  DATA: cupdate LIKE ctu_params-updmode VALUE 'A'.
  i_resultado = 4.
  ctumode = i_ctumode."A visible N invisible.
  REFRESH messtab.
  CALL TRANSACTION tcode USING bdcdata
                   MODE   ctumode
                   UPDATE cupdate
                   MESSAGES INTO messtab.
  l_subrc = sy-subrc.

*  IF sy-subrc NE 0.
  LOOP AT messtab." WHERE msgtyp = 'E'.
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = messtab-msgid
        msgnr               = messtab-msgnr
        msgv1               = messtab-msgv1
        msgv2               = messtab-msgv2
        msgv3               = messtab-msgv3
        msgv4               = messtab-msgv4
      IMPORTING
        message_text_output = t_salida-message.

    APPEND t_salida.

    MOVE-CORRESPONDING messtab TO mensaje_salida.
    APPEND mensaje_salida.
  ENDLOOP.

  IF messtab[] IS INITIAL.
    i_resultado = 0.
  ENDIF.
*  ENDIF.

  REFRESH bdcdata.

ENDFORM.                    "bdc_transaction

*&---------------------------------------------------------------------*
*&      Form  bdc_transaction2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->MENSAJE_SALIDA  text
*      -->RETORNO         text
*----------------------------------------------------------------------*
FORM bdc_transaction2  USING tcode retorno.
  DATA: l_mstring(480).
  DATA: l_subrc LIKE sy-subrc.
  DATA: ctumode LIKE ctu_params-dismode VALUE 'N'.
  DATA: cupdate LIKE ctu_params-updmode VALUE 'A'.

  REFRESH messtab.
  CALL TRANSACTION tcode USING bdcdata
                   MODE   ctumode
                   UPDATE cupdate
                   MESSAGES INTO messtab.
  retorno = sy-subrc.

*  IF sy-subrc NE 0.
  LOOP AT messtab." WHERE msgtyp = 'E'.
*    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
*      EXPORTING
*        msgid               = messtab-msgid
*        msgnr               = messtab-msgnr
*        msgv1               = messtab-msgv1
*        msgv2               = messtab-msgv2
*        msgv3               = messtab-msgv3
*        msgv4               = messtab-msgv4
*      IMPORTING
*        message_text_output = t_salida-message.
*
*    APPEND t_salida.
*
*    MOVE-CORRESPONDING messtab TO mensaje_salida.
*    APPEND mensaje_salida.
  ENDLOOP.

*  ENDIF.
  COMMIT WORK AND WAIT.

  REFRESH bdcdata.

ENDFORM.                    "bdc_transaction
*&---------------------------------------------------------------------*
*&      Form  CARGA_GUIA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM carga_guia .
  "Guía Despacho
  LOOP AT lt_poitem INTO ls_poitem.

    CLEAR : vl_mat_doc    , vl_mat_year ,
            vl_matdoc_itm ,
            vl_continue   .

    LOOP AT lt_dte_doc_rec_ref INTO wa_dte_doc_rec_ref WHERE ( tipodte   EQ '33' OR tipodte   EQ '34' )
                                                         AND ( tpodocref EQ '50' OR tpodocref EQ '52' ).

      "Rescatar posiciones del pedido que están recepcionadas
      "y que tienen  como referencia la Guía de Despacho (Tipo Ref 50 o 52)
      LOOP AT lt_pohistory INTO ls_pohistory WHERE hist_type EQ 'E'
                                               AND po_item   EQ ls_poitem-po_item.

        PERFORM ref_doc_no_split.
        READ TABLE lt_dte_doc_rec_ref INTO wa_dte_doc_rec_ref WITH KEY folioref = ls_pohistory-ref_doc_no.
        IF sy-subrc EQ 0.

          vl_mat_year    = ls_pohistory-doc_year.
          vl_mat_doc     = ls_pohistory-mat_doc.
          vl_matdoc_itm  = ls_pohistory-matdoc_itm.
          vl_continue    = 'X'.

          "Obtener las posiciones de Pedido ya facturadas
          READ TABLE lt_pohistory INTO ls_pohistory WITH KEY hist_type  = 'Q'
                                                             db_cr_ind  = 'S'
                                                             po_item    = ls_poitem-po_item
                                                             mat_doc    = vl_mat_doc
                                                             matdoc_itm = vl_matdoc_itm.
          IF  sy-subrc NE 0.
            vl_continue = 'X'.
          ENDIF.

          "Verificar si la factura del paso Anterior está anulada
          READ TABLE lt_pohistory INTO ls_pohistory WITH KEY hist_type  = 'Q'
                                                             db_cr_ind  = 'H'
                                                             po_item    = ls_poitem-po_item
                                                             mat_doc    = vl_mat_doc
                                                             matdoc_itm = vl_matdoc_itm.
          IF  sy-subrc EQ 0.
            CLEAR vl_continue.
          ENDIF.
        ELSE.
*          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    IF vl_continue IS NOT INITIAL.
      PERFORM carga_posiciones USING ls_poitem-po_item.
    ENDIF.

  ENDLOOP.
ENDFORM.                    " CARGA_GUIA
*&---------------------------------------------------------------------*
*&      Form  CARGA_HES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM carga_hes .

  LOOP AT lt_poitem INTO ls_poitem.

    CLEAR : vl_mat_doc    , vl_mat_year ,
            vl_matdoc_itm ,
            vl_continue   .

    "Caso de DTE tipo 33 y 34 con Tipo de Referencia 801 (Orden de Compra (esta es obligatoria)) y Tipo de Referencia HES (HES)
    LOOP AT lt_dte_doc_rec_ref INTO wa_dte_doc_rec_ref WHERE ( tipodte   EQ '33' OR tipodte   EQ '34' )
                                                         AND   tpodocref EQ 'HES' .

      "Rescatar posiciones del pedido que están recepcionadas y
      "que tienen  como referencia la HES (Tipo Ref HES)
      LOOP AT lt_pohistory INTO ls_pohistory WHERE hist_type EQ 'E'
                                               AND po_item   EQ ls_poitem-po_item.

        READ TABLE lt_dte_doc_rec_ref INTO wa_dte_doc_rec_ref WITH KEY folioref = ls_pohistory-ref_doc.
        IF sy-subrc EQ 0.

          vl_mat_year    = ls_pohistory-doc_year.
          vl_mat_doc     = ls_pohistory-mat_doc.
          vl_matdoc_itm  = ls_pohistory-matdoc_itm.
          vl_continue    = 'X'.

          "Obtener las posiciones de Pedido ya facturadas
          READ TABLE lt_pohistory INTO ls_pohistory WITH KEY hist_type  = 'Q'
                                                             db_cr_ind  = 'S'
                                                             po_item    = ls_poitem-po_item
                                                             mat_doc    = vl_mat_doc
                                                             matdoc_itm = vl_matdoc_itm.
          IF  sy-subrc NE 0.
            vl_continue = 'X'.
          ENDIF.

          "Verificar si la factura del paso Anterior está anulada
          READ TABLE lt_pohistory INTO ls_pohistory WITH KEY hist_type  = 'Q'
                                                             db_cr_ind  = 'H'
                                                             po_item    = ls_poitem-po_item
                                                             mat_doc    = vl_mat_doc
                                                             matdoc_itm = vl_matdoc_itm.
          IF  sy-subrc EQ 0.
            CLEAR vl_continue.
          ENDIF.

        ELSE.
*          EXIT.
        ENDIF.
      ENDLOOP.

    ENDLOOP.
    IF vl_continue IS NOT INITIAL.
      PERFORM carga_posiciones USING ls_poitem-po_item.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CARGA_HES


*&---------------------------------------------------------------------*
*&      Form  CARGA_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM carga_po .

  LOOP AT lt_poitem INTO ls_poitem.

    CLEAR : vl_mat_doc    , vl_mat_year ,
            vl_matdoc_itm ,
            vl_continue   .


    "Caso de DTE tipo 33 y 34 con Tipo de Referencia 801 (Orden de Compra (esta es obligatoria))
    LOOP AT lt_dte_doc_rec_ref INTO wa_dte_doc_rec_ref WHERE ( tipodte   EQ '33' OR tipodte   EQ '34' )
                                                         AND   tpodocref EQ '801' .

      "Rescatar posiciones del pedido que están recepcionadas
      "y que tienen  como referencia la HES (Tipo Ref HES)
      LOOP AT lt_pohistory INTO ls_pohistory WHERE  hist_type EQ 'E' AND
                                                    po_item EQ ls_poitem-po_item.

        PERFORM ref_doc_no_split." --> ref_doc_no
*        READ TABLE lt_dte_doc_rec_ref INTO wa_dte_doc_rec_ref WITH KEY folioref = ld_ebeln.
*        IF sy-subrc EQ 0.
        IF ld_folioref EQ ls_pohistory-ref_doc_no.

          vl_mat_year    = ls_pohistory-doc_year.
          vl_mat_doc     = ls_pohistory-mat_doc.
          vl_matdoc_itm  = ls_pohistory-matdoc_itm.
          vl_continue    = 'X'.

          "Obtener las posiciones de Pedido ya facturadas
          READ TABLE lt_pohistory INTO ls_pohistory WITH KEY hist_type  = 'Q'
                                                             db_cr_ind  = 'S'
                                                             po_item    = ls_poitem-po_item
                                                             mat_doc    = vl_mat_doc
                                                             matdoc_itm = vl_matdoc_itm.
          IF  sy-subrc NE 0.
            vl_continue = 'X'.
          ELSE.
            CLEAR vl_continue.
          ENDIF.

          "Verificar si la factura del paso Anterior está anulada
          READ TABLE lt_pohistory INTO ls_pohistory WITH KEY hist_type  = 'Q'
                                                             db_cr_ind  = 'H'
                                                             po_item    = ls_poitem-po_item
                                                             mat_doc    = vl_mat_doc
                                                             matdoc_itm = vl_matdoc_itm.
          IF  sy-subrc EQ 0.
            CLEAR vl_continue.
          ENDIF.

        ELSE.
*          EXIT.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    IF vl_continue IS NOT INITIAL.
      PERFORM carga_posiciones USING ls_poitem-po_item.
    ENDIF.

  ENDLOOP.
ENDFORM.                    " CARGA_PO

*&---------------------------------------------------------------------*
*&      Form  CARGA_POSICIONES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_POITEM_PO_ITEM  text
*----------------------------------------------------------------------*
FORM carga_posiciones  USING    p_ls_poitem_po_item.
**********************************************************************
* Verificamos Asignación Múltiple
**********************************************************************
  DATA  vl_posicion TYPE ebeln.

  DATA  vl_check(1).
  CLEAR vl_check.

  vl_posicion = p_ls_poitem_po_item.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *
*  FROM ekko
*  WHERE ebeln EQ ld_ebeln.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
  FROM ekko
  WHERE ebeln EQ ld_ebeln ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc EQ 0.
    vl_currency = ekko-waers.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *
*  FROM ekpo
*  WHERE ebeln EQ ld_ebeln
*    AND ebelp EQ vl_posicion
*    AND knttp NE space
*    AND weunb EQ 'X'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
  FROM ekpo
  WHERE ebeln EQ ld_ebeln
    AND ebelp EQ vl_posicion
    AND knttp NE space
    AND weunb EQ 'X' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc EQ 0.
    vl_check = 'X'.
  ENDIF.
**********************************************************************
* Inicio Asignamos Posiciones Simples
**********************************************************************
* importe bruto de factura en moneda del documento
*      ADD ls_poitem-net_price TO ls_headerdata-gross_amount.

* Posición de documento en documento de factura
  ADD 1 TO vl_invoice_doc_item.

  ls_itemdata-item_text         =  vg_proveedor.
  ls_itemdata-invoice_doc_item  =  vl_invoice_doc_item.
* Número de pedido
  ls_itemdata-po_number         =  ls_poheader-po_number.
* Número de posición del documento de compras
  ls_itemdata-po_item           =  vl_posicion.
* Indicador de IVA
  ls_itemdata-tax_code          =  ls_poitem-tax_code.
  ls_itemdata-taxjurcode        =  ls_poitem-tax_code.
* Importe en la moneda del documento

  "Asignamos Importes
  DATA wa1 TYPE TABLE OF ekbe WITH HEADER LINE.

  SELECT * INTO TABLE wa1
    FROM ekbe
   WHERE ebeln EQ ld_ebeln
     AND ebelp EQ vl_posicion
     AND bwart EQ '101'
    ORDER BY belnr DESCENDING.

  READ TABLE wa1 INDEX 1.
  IF sy-subrc EQ 0.
    v_line_amount = wa1-dmbtr.
  ELSE.
    v_line_amount = ( ls_poitem-net_price * ls_poitem-quantity ) / ls_poitem-price_unit.
  ENDIF.

  ls_itemdata-item_amount = v_line_amount.

*-- Converting SAP amount to BAPI format by passing line item amount and currency
*  PERFORM f_currency_amount_sap_to_bapi USING    vl_currency "wa_ekpo-waers
*                                                 v_line_amount
*                                        CHANGING ls_itemdata-item_amount .

*  ls_itemdata-ref_doc_year      = ls_poheader-doc_date.
  ls_itemdata-ref_doc_year      = vl_mat_year.
  ls_itemdata-ref_doc           = vl_mat_doc.
  ls_itemdata-ref_doc_it        = vl_matdoc_itm."posicion referencia

  READ TABLE lt_pohistory INTO ls_pohistory WITH KEY po_item    = vl_posicion
                                                     hist_type  = 'E'
                                                     ref_doc    = ld_folioref.

  IF sy-subrc EQ 0. "Servicio
    CLEAR :
            ls_itemdata-ref_doc   ,
            ls_itemdata-ref_doc_it,
            ls_itemdata-quantity  ,
            ls_itemdata-po_unit   .

    ls_itemdata-sheet_no          = ls_pohistory-ref_doc.

    IF ls_pohistory-currency NE 'CLP'.
      ls_itemdata-item_amount       = ls_pohistory-val_loccur.".

      v_line_amount = ls_pohistory-val_loccur.

*-- Converting SAP amount to BAPI format by passing line item amount and currency
      PERFORM f_currency_amount_sap_to_bapi USING vl_currency "wa_ekpo-waers
                                                  v_line_amount
                                         CHANGING ls_itemdata-item_amount .

*            ls_itemdata-item_amount = ls_itemdata-item_amount * 100.   "V1 - CNN

    ELSE.
      ls_itemdata-item_amount = ls_pohistory-val_loccur.
    ENDIF.

  ELSE.         "Material
    ls_itemdata-ref_doc           = vl_mat_doc.
*    ls_itemdata-ref_doc_it        = vl_invoice_doc_item.
    ls_itemdata-ref_doc_it        = vl_matdoc_itm.

    READ TABLE lt_pohistory INTO ls_pohistory WITH KEY po_item    = vl_posicion
                                                       mat_doc    = vl_mat_doc
                                                       hist_type  = 'E'.

    "Cantidad
    ls_itemdata-quantity          =  ls_pohistory-quantity.
    " Unidad de medida de pedido
    ls_itemdata-po_unit           =  ls_poitem-po_unit    .

    "Reasignamos Importe Recepcionado

    v_line_amount = ls_pohistory-val_loccur.
*    v_line_amount = ( ls_poitem-net_price * ls_pohistory-quantity ) / ls_poitem-price_unit.

    ls_itemdata-item_amount = v_line_amount.


  ENDIF.


  APPEND ls_itemdata TO lt_itemdata.

  MOVE-CORRESPONDING ls_poitem TO t_item_montos.
  MOVE-CORRESPONDING ls_pohistory TO t_item_montos.
  MOVE-CORRESPONDING ls_itemdata TO t_item_montos.
  APPEND t_item_montos.
**********************************************************************
* Fin Asignamos Posiciones Simples
**********************************************************************
*  ENDIF.

  DATA  vl_lineas TYPE i.
  CLEAR vl_lineas.

  DESCRIBE TABLE lt_poaccount LINES vl_lineas.

*  CHECK vl_lineas GT 1 AND lt_accountingdata[] IS INITIAL.
*  CHECK vl_check IS NOT INITIAL AND lt_accountingdata[] IS INITIAL.

  IF ls_itemdata-sheet_no NE space.

    LOOP AT lt_poaccount INTO ls_poaccount.
      ls_accountingdata-invoice_doc_item  =  ls_poaccount-po_item / 10  .
      ls_accountingdata-gl_account        =  ls_poaccount-gl_account    .
      ls_accountingdata-costcenter        =  ls_poaccount-costcenter    .

      READ TABLE lt_pohistory INTO ls_pohistory WITH KEY po_item    = ls_poaccount-po_item
                                                         serial_no  = ls_poaccount-serial_no
                                                         hist_type  = 'E'.
      "ref_doc    = ld_folioref.
      IF sy-subrc EQ 0  .
*  ls_accountingdata-item_amount       =  ls_poaccount-net_value     .
        ls_accountingdata-item_amount       =  ls_pohistory-val_loccur  .
      ELSE.
        ls_accountingdata-item_amount       =  ls_poaccount-net_value   .
      ENDIF.

      ls_accountingdata-cmmt_item         =  ls_poaccount-cmmt_item     .
      ls_accountingdata-bus_area          =  ls_poaccount-bus_area      .
      ls_accountingdata-co_area           =  ls_poaccount-co_area       .
      ls_accountingdata-profit_ctr        =  ls_poaccount-profit_ctr    .
      ls_accountingdata-orderid           =  ls_poaccount-orderid       .
      ls_accountingdata-wbs_elem          =  ls_poaccount-wbs_element   .
      ls_accountingdata-sd_doc            =  ls_poaccount-sd_doc        .
      ls_accountingdata-sdoc_item         =  ls_poaccount-sd_doc        .
      ls_accountingdata-serial_no         =  ls_poaccount-serial_no     .
      ls_accountingdata-tax_code          =  vg_mwskz                   .
*      ls_accountingdata-quantity          =  ls_poaccount-quantity      .
*      ls_accountingdata-po_unit           =  ls_poitem-po_unit          .

      APPEND ls_accountingdata TO lt_accountingdata.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " CARGA_POSICIONES

*&---------------------------------------------------------------------*
*&      Form  f_currency_amount_sap_to_bapi
*&---------------------------------------------------------------------*
*       SAP Amount to BAPI Amount
*----------------------------------------------------------------------*
FORM f_currency_amount_sap_to_bapi  USING    p_waers
                                             p_kbetr
                                    CHANGING p_amt_doccur.

  DATA : lv_waers       LIKE  tcurc-waers,
         lv_sapamount   LIKE bapicurr-bapicurr,
         lv_bapi_amount LIKE bapicurr-bapicurr.

  lv_waers     = p_waers.
  lv_sapamount = p_kbetr.

  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_BAPI'
    EXPORTING
      currency    = lv_waers
      sap_amount  = lv_sapamount
    IMPORTING
      bapi_amount = lv_bapi_amount.

  p_amt_doccur = lv_bapi_amount.

ENDFORM.                    " f_currency_amount_sap_to_bapi


*&---------------------------------------------------------------------*
*&      Form  GRABA_EMISION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FACTURA  text
*      -->P_EJERCICIO  text
*      -->P_LS_HEADERDATA_COMP_CODE  text
*      -->P_RESULTADO  text
*----------------------------------------------------------------------*
FORM graba_emision  USING    p_factura
                             p_ejercicio
                             p_ls_headerdata_comp_code
                             p_rut
                             p_fechaemi
                             p_resultado.

  DATA vl_awkey TYPE bkpf-awkey.
  DATA vl_belnr TYPE bkpf-belnr.
  DATA w_bkpf   TYPE bkpf.
  CONCATENATE p_factura p_ejercicio INTO vl_awkey.

  CONDENSE vl_awkey NO-GAPS.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * INTO w_bkpf
*   FROM bkpf
*   WHERE bukrs EQ p_ls_headerdata_comp_code
*     AND gjahr EQ p_ejercicio
*     AND awkey EQ vl_awkey.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  INTO w_bkpf
   FROM bkpf
   WHERE bukrs EQ p_ls_headerdata_comp_code
     AND gjahr EQ p_ejercicio
     AND awkey EQ vl_awkey ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc EQ 0.
    vl_belnr = w_bkpf-belnr.
  ENDIF.


  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'        'RF05L-BELNR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'        '/00'.
  PERFORM bdc_field       USING 'RF05L-BELNR'       vl_belnr.
  PERFORM bdc_field       USING 'RF05L-BUKRS'       p_ls_headerdata_comp_code.
  PERFORM bdc_field       USING 'RF05L-GJAHR'       p_ejercicio.

  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0700'.
  PERFORM bdc_field       USING 'BDC_CURSOR'        'RF05L-ANZDT(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'        '=PK'.

  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0302'.
  PERFORM bdc_field       USING 'BDC_CURSOR'        'BSEG-ZTERM'.
  PERFORM bdc_field       USING 'BDC_OKCODE'        '=ZK'.
*  PERFORM bdc_field       USING 'BSEG-ZTERM'        record-zterm_004.
*  PERFORM bdc_field       USING 'BSEG-ZBD1T'        record-zbd1t_005.
*  PERFORM bdc_field       USING 'BSEG-ZFBDT'        record-zfbdt_006.
*  PERFORM bdc_field       USING 'BSEG-ZLSPR'        record-zlspr_007.
*  PERFORM bdc_field       USING 'BSEG-ZLSCH'        record-zlsch_008.
*  PERFORM bdc_field       USING 'BSEG-SGTXT'        record-sgtxt_009.

  PERFORM bdc_dynpro      USING 'SAPMF05L'          '1302'.
  PERFORM bdc_field       USING 'BDC_CURSOR'        'BSEG-ZZMOT_EMIS'.
  PERFORM bdc_field       USING 'BDC_OKCODE'        '=ENTR'.
*  PERFORM bdc_field       USING 'BSEG-HBKID'        record-hbkid_010.
*  PERFORM bdc_field       USING 'BSEG-FDLEV'        record-fdlev_011.
  PERFORM bdc_field       USING 'BSEG-ZZMOT_EMIS'   'PROVEEDO_C'.

  PERFORM bdc_dynpro      USING 'SAPMF05L'          '0302'.
  PERFORM bdc_field       USING 'BDC_CURSOR'        'BSEG-ZTERM'.
  PERFORM bdc_field       USING 'BDC_OKCODE'        '=AE'.
*  PERFORM bdc_field       USING 'BSEG-ZTERM'        record-zterm_013.
*  PERFORM bdc_field       USING 'BSEG-ZBD1T'        record-zbd1t_014.
*  PERFORM bdc_field       USING 'BSEG-ZFBDT'        record-zfbdt_015.
*  PERFORM bdc_field       USING 'BSEG-ZLSPR'        record-zlspr_016.
*  PERFORM bdc_field       USING 'BSEG-ZLSCH'        record-zlsch_017.
*  PERFORM bdc_field       USING 'BSEG-SGTXT'        record-sgtxt_018.

  PERFORM bdc_transaction2 USING 'FB02' p_resultado.

  IF vl_belnr NE space.
*    UPDATE zzrut_terc FROM bsis where belnr EQ  vl_belnr  .

  ENDIF.

ENDFORM.                    " GRABA_EMISION

*&---------------------------------------------------------------------*
*&      Form  ref_doc_no_split
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ref_doc_no_split.
  DATA: aux TYPE c LENGTH 20.
  CONDENSE ls_pohistory-ref_doc_no NO-GAPS.

  IF ls_pohistory-ref_doc_no CS '-'.
    SPLIT ls_pohistory-ref_doc_no AT '-' INTO aux ls_pohistory-ref_doc_no.
  ELSEIF ls_pohistory-ref_doc_no CS '_'.
    SPLIT ls_pohistory-ref_doc_no AT '_' INTO aux ls_pohistory-ref_doc_no.
  ELSE.
*    SPLIT ls_pohistory-ref_doc_no AT ' ' INTO aux ls_pohistory-ref_doc_no.
  ENDIF.
ENDFORM.                    "ref_doc_no_split
