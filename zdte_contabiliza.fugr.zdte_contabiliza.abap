*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION zdte_contabiliza.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(RUT_EMISOR) TYPE  ZRUT_EMI
*"     VALUE(TIPO_DTE) TYPE  ZDTE_TIPO
*"     VALUE(FOLIO) TYPE  ZDTE_FOLIO
*"     VALUE(FCHEMIS) TYPE  AUSGDT OPTIONAL
*"  EXPORTING
*"     VALUE(RESULTADO) TYPE  SUBRC
*"     VALUE(FACTURA) TYPE  BELNR_D
*"     VALUE(EJERCICIO) TYPE  GJAHR
*"     VALUE(ESTADO) TYPE  ZDTE_ESTADO
*"     VALUE(MENSAJE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------
  "Mensajes:
*    NU	Nuevo
*    CO	Contabilizado
*    NC	No Contabilizado
*    RE	Rechazado

  DATA: lv_supera TYPE c LENGTH 1.

  REFRESH: ltab_return , lt_itemdata , lt_poitem, lt_pohistory .
  CLEAR: ltab_return, lt_itemdata, ls_headerdata, vl_invoice_doc_item,
         ls_poheader.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*  INTO CORRESPONDING FIELDS OF TABLE lt_dte_doc_rec
*  FROM zdte_doc_rec
*  WHERE rutemisor EQ rut_emisor
*    AND tipodte   EQ tipo_dte
*    AND folio     EQ folio.
*
* NEW CODE
  SELECT *

  INTO CORRESPONDING FIELDS OF TABLE lt_dte_doc_rec
  FROM zdte_doc_rec
  WHERE rutemisor EQ rut_emisor
    AND tipodte   EQ tipo_dte
    AND folio     EQ folio ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE lt_dte_doc_rec_ref
*    FROM zdte_doc_rec_ref
**    FOR ALL ENTRIES IN lt_dte_doc_rec
*    WHERE rutemisor EQ rut_emisor
*      AND tipodte   EQ tipo_dte
*      AND folio     EQ folio.
*
* NEW CODE
    SELECT *

    INTO CORRESPONDING FIELDS OF TABLE lt_dte_doc_rec_ref
    FROM zdte_doc_rec_ref
*    FOR ALL ENTRIES IN lt_dte_doc_rec
    WHERE rutemisor EQ rut_emisor
      AND tipodte   EQ tipo_dte
      AND folio     EQ folio ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    IF sy-subrc EQ 0.
      "Nada
    ELSE.
      mensaje = 'NO HAY DATOS PARA LA CONSULTA.(REF. 801)'.
      estado  = 'RE'.
    ENDIF.
  ELSE.
    mensaje = 'NO HAY DATOS PARA LA CONSULTA.'.
  ENDIF.

  CHECK lt_dte_doc_rec_ref[] IS NOT INITIAL.

  LOOP AT lt_dte_doc_rec INTO wa_dte_doc_rec.
    " Obtenemos Sociedad
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE bukrs INTO ld_bukrs
*       FROM  t001z
*       WHERE paval = wa_dte_doc_rec-rutrecep
*       AND   party = 'TAXNR'.
*
* NEW CODE
    SELECT bukrs
    UP TO 1 ROWS  INTO ld_bukrs
       FROM  t001z
       WHERE paval = wa_dte_doc_rec-rutrecep
       AND   party = 'TAXNR' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
      "nada
    ELSE.
      estado = 'RE'.
      mensaje = 'Sociedad No existe.'.
    ENDIF.

    ld_folio        = wa_dte_doc_rec-folio      .
    ld_tipodte      = wa_dte_doc_rec-tipodte    .

**********MONTO DESDE LA FACTURA EN XML************
    ld_gross_amount = wa_dte_doc_rec-mnttotal   .
    vg_monto_neto   = wa_dte_doc_rec-mntneto    .

    "Obtenemos Po
    READ TABLE lt_dte_doc_rec_ref INTO wa_dte_doc_rec_ref WITH KEY rutemisor = wa_dte_doc_rec-rutemisor
                                                                   tipodte   = wa_dte_doc_rec-tipodte
                                                                   folio     = wa_dte_doc_rec-folio
                                                                   tpodocref = '801'.

    ld_ebeln = wa_dte_doc_rec_ref-folioref.

    CLEAR vg_proveedor.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM ekko
*    WHERE ebeln EQ ld_ebeln.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM ekko
    WHERE ebeln EQ ld_ebeln ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE name1 INTO vg_proveedor
*      FROM lfa1
*      WHERE lifnr EQ ekko-lifnr.
*
* NEW CODE
      SELECT name1
      UP TO 1 ROWS  INTO vg_proveedor
      FROM lfa1
      WHERE lifnr EQ ekko-lifnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.

    "Si el pedido viene sin HES rechazo
*    801+hes
*    solo una hes

    "Materiales
*    puede venir solo 801 pedido
    "identificamos Tipo Documento

    DATA  vl_tipo(2).
    CLEAR vl_tipo.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM ekpo
*    WHERE ebeln EQ wa_dte_doc_rec_ref-folioref.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM ekpo
    WHERE ebeln EQ wa_dte_doc_rec_ref-folioref ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*      AND ebelp EQ 10.
    IF sy-subrc EQ 0.
      IF ekpo-knttp NE 'A' AND ekpo-pstyp NE '9'.
        vl_tipo = 'MT'.
      ELSEIF ekpo-knttp EQ 'A'.
        vl_tipo = 'AF'.
      ELSE.
        vl_tipo = 'HS'.
      ENDIF.
    ENDIF.

    IF vl_tipo EQ 'MT'.
      "Nada
    ELSEIF  vl_tipo EQ 'AF'. "Material / AF
      EXIT.
    ELSE. "Servicio HES

      READ TABLE lt_dte_doc_rec_ref INTO wa_dte_doc_rec_ref WITH KEY rutemisor = wa_dte_doc_rec-rutemisor
                                                                     tipodte   = wa_dte_doc_rec-tipodte
                                                                     folio     = wa_dte_doc_rec-folio
                                                                     tpodocref = 'HES'.
      IF sy-subrc EQ 0.
        DELETE lt_dte_doc_rec_ref WHERE tpodocref EQ '801'.
      ELSE.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
        SORT lt_poitem .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
        resultado = 1.
        estado    = 'RE'.
        mensaje   = 'Referencia sin HES.'.
        EXIT.
      ENDIF.

      READ TABLE lt_dte_doc_rec_ref INTO wa_dte_doc_rec_ref WITH KEY rutemisor = wa_dte_doc_rec-rutemisor
                                                                     tipodte   = wa_dte_doc_rec-tipodte
                                                                     folio     = wa_dte_doc_rec-folio
                                                                     tpodocref = '50'.
      IF sy-subrc EQ 0.
        DELETE lt_dte_doc_rec_ref WHERE tpodocref EQ '801'.
      ENDIF.

      READ TABLE lt_dte_doc_rec_ref INTO wa_dte_doc_rec_ref WITH KEY rutemisor = wa_dte_doc_rec-rutemisor
                                                                     tipodte   = wa_dte_doc_rec-tipodte
                                                                     folio     = wa_dte_doc_rec-folio
                                                                     tpodocref = '52'.
      IF sy-subrc EQ 0.
        DELETE lt_dte_doc_rec_ref WHERE tpodocref EQ '801'.
      ENDIF.

    ENDIF.

    IF estado EQ 'RE'.
      EXIT.
    ENDIF.

    REFRESH ltab_return.

    CALL FUNCTION 'BAPI_PO_GETDETAIL1' "#EC CI_USAGE_OK[2438131]
      EXPORTING
        purchaseorder      = ld_ebeln
        account_assignment = 'X'
        services           = 'X'
      IMPORTING
        poheader           = ls_poheader
      TABLES
        return             = ltab_return
        poitem             = lt_poitem
        poaccount          = lt_poaccount
        pohistory          = lt_pohistory
        pohistory_totals   = lt_pohistory_totals.

    LOOP AT ltab_return INTO  lstr_return WHERE type CA 'EA'.
    ENDLOOP.
    IF sy-subrc = 0.
      mensaje = lstr_return-message.
      EXIT.
    ENDIF.

    PERFORM hist_quitar_anulados.
    PERFORM doc_ref_sort.
    "Obtenemos el indicador de impuesto
    READ TABLE lt_poitem INTO ls_poitem INDEX 1.
    IF sy-subrc EQ 0.
      vg_mwskz = ls_poitem-tax_code.
    ENDIF.

    LOOP AT lt_dte_doc_rec_ref INTO wa_dte_doc_rec_ref WHERE rutemisor EQ wa_dte_doc_rec-rutemisor
                                                         AND tipodte   EQ wa_dte_doc_rec-tipodte
                                                         AND folio     EQ wa_dte_doc_rec-folio.

      IF wa_dte_doc_rec_ref-tpodocref EQ 'HES'.
        ld_folioref     = wa_dte_doc_rec_ref-folioref.
        PERFORM carga_hes.
        EXIT.
      ELSEIF wa_dte_doc_rec_ref-tpodocref EQ '801'.
        ld_ebeln        = wa_dte_doc_rec_ref-folioref.
        ld_folioref     = wa_dte_doc_rec_ref-folio.
        PERFORM conversion_alpha_out USING ld_folioref.
        PERFORM carga_po.
        EXIT.
      ELSEIF wa_dte_doc_rec_ref-tpodocref EQ '50' OR wa_dte_doc_rec_ref-tpodocref EQ '52'.
        ld_folioref     = wa_dte_doc_rec_ref-folioref.

        PERFORM carga_guia.
        EXIT.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

  IF vl_tipo EQ 'AF'.
    resultado = 1.
    estado    = 'NC'.
    mensaje   = 'COMPRA DE ACTIVO FIJO'.
    EXIT.
  ENDIF.
* clase de documento
  CALL FUNCTION 'OBTIENE_CLASE_DOCUMENTO'
    EXPORTING
      folio_ref = ld_ebeln
      tipo_dte  = ld_tipodte
      sociedad  = ld_bukrs
    CHANGING
      clase_doc = ls_headerdata-doc_type.

* ¿Calcular impuesto automáticamente?
  ls_headerdata-calc_tax_ind  = 'X'.

* ind. cont factura
  ls_headerdata-invoice_ind   = 'X'.

* fecha de documento en documento
*  ls_headerdata-doc_date      = ls_poheader-doc_date.
  ls_headerdata-doc_date      = fchemis.

* fecha de contabilización en el documento
*  ls_headerdata-pstng_date    = ls_poheader-doc_date.
  ls_headerdata-pstng_date    = sy-datum.
* número de documento de referencia
  ls_headerdata-ref_doc_no    = ld_folio.
* sociedad
  ls_headerdata-comp_code     = ls_poheader-comp_code.
* clave de moneda
  ls_headerdata-currency      = ls_poheader-currency.
  ls_headerdata-currency_iso  = ls_poheader-currency.
* Asignación
  ls_headerdata-alloc_nmbr    = ld_folio.

***************************************************************
**Clave de condiciones de pago
**  PMNTTRMS = corresponde al campo de la EKKO  (EKKO-ZTERM)
**  ls_headerdata-pmnttrms      = ls_poheader-pmnttrms.
*  ls_headerdata-pmnttrms      = 'ZC01'.  "2018.08.16
*  ls_headerdata-netterms      = '30'  .  "2018.08.16
*  ls_headerdata-bline_date    = fchemis. "2018.08.16
***************************************************************
  ls_headerdata-header_txt    = vg_proveedor.
  ls_headerdata-item_text     = vg_proveedor.
  ls_headerdata-pmnt_block    = ''.

*  PYMT_METH
*
*V =  (Vale Vista): Monto Neto < $50.000.000
*C=  (Cheque): Monto Neto >= $50.000.000
*C= Proveedores Lista Blanca
*

  IF vg_monto_neto < 50000000.
    ls_headerdata-pymt_meth = 'V'.
  ELSEIF vg_monto_neto >= 50000000.
    ls_headerdata-pymt_meth = 'C'.
  ENDIF.

*PLANNING_LEVEL = Siempre ='F1'
  ls_headerdata-planning_level = 'F1'.

  IF ls_headerdata-currency NE 'CLP'.
    ls_headerdata-gross_amount  = ld_gross_amount.
    ls_headerdata-currency      = 'CLP'.
    ls_headerdata-currency_iso  = 'CLP'.

    v_line_amount = ld_gross_amount.

*-- Converting SAP amount to BAPI format by passing line item amount and currency
    PERFORM f_currency_amount_sap_to_bapi USING    vl_currency "wa_ekpo-waers
                                                   v_line_amount
                                          CHANGING ls_headerdata-gross_amount .

    ls_headerdata-gross_amount = ls_headerdata-gross_amount * 100.
  ELSE.
    ls_headerdata-gross_amount  = ld_gross_amount * 100.
  ENDIF.

  IF ls_headerdata-pymt_meth ='V'.

    ls_headerdata-housebankid = 'COR01'.

  ELSEIF ls_headerdata-pymt_meth = 'C'.

    IF ls_headerdata-comp_code = 'CL12'.
      ls_headerdata-housebankid = 'CHI01'.
    ELSE.
      ls_headerdata-housebankid = 'BCI01'.
    ENDIF.

  ENDIF.

*-> BEG DEL V1-CNN 13.02.2019 - ECDK917529
*t_tolerancia-base = 68.
*t_tolerancia-currency = 'USD'.
*append t_tolerancia.
*t_tolerancia-base = 400.
*t_tolerancia-currency = 'UF'.
*append t_tolerancia.
*****VERIFCAR TOLERANCIA.
**  DATA: lv_aux1 LIKE ls_itemdata-item_amount.
*  DATA: lv_aux1 TYPE i.
*  DATA: lv_aux2 TYPE p DECIMALS 2.
*  DATA: lv_aux3 TYPE p DECIMALS 2.
*
*  CLEAR : vg_monto_total_l , vg_monto_total_d , vg_monto_quantity, t_tolerancia.
**  vg_tolerancia_usd , vg_tolerancia_uf
*  LOOP AT t_item_montos .
*    "vg_tolerancia , vg_monto_total
*    ADD t_item_montos-item_amount TO vg_monto_total_l.
*    ADD t_item_montos-val_forcur  TO vg_monto_total_d.
*    ADD t_item_montos-quantity    TO vg_monto_quantity.
*
*    READ TABLE t_tolerancia WITH KEY currency = t_item_montos-currency.
*  ENDLOOP.
**  vg_monto_total
**  vg_monto_total
*
*  t_tolerancia-calc = vg_monto_total_d * t_tolerancia-base.
*  t_tolerancia-diff = vg_monto_neto - vg_monto_total_l.
*
*  IF t_tolerancia-diff <= t_tolerancia-calc."tolerancia permitida.
*****distribuir diferencias
*    LOOP AT lt_itemdata INTO ls_itemdata.
*      lv_aux1 = ( 100 * ls_itemdata-quantity ) /  vg_monto_quantity."PORCENTAJE
*      lv_aux2 = ( lv_aux1 * t_tolerancia-diff ) / 100."VALOR A SUMAR
*      AT LAST."para el ultimo asignar la diferencia.
*       lv_aux2 = t_tolerancia-diff - lv_aux3."
*      ENDAT.
*      ADD lv_aux2 to ls_itemdata-item_amount.
**      ls_itemdata-item_amount = ls_itemdata-item_amount * 100.
*
*      v_line_amount = ls_itemdata-item_amount.
*
**-- Converting SAP amount to BAPI format by passing line item amount and currency
*    PERFORM f_currency_amount_sap_to_bapi USING    vl_currency "wa_ekpo-waers
*                                                   v_line_amount
*                                          CHANGING ls_itemdata-item_amount .
*
*      ls_itemdata-item_amount = ls_itemdata-item_amount * 100.
*
*      MODIFY lt_itemdata FROM ls_itemdata TRANSPORTING item_amount.
*      ADD lv_aux2 to lv_aux3."acumula diferencias.
*    ENDLOOP.
*
*  ENDIF.
*
**    ld_gross_amount = wa_dte_doc_rec-mnttotal .
**    vg_monto_neto   = wa_dte_doc_rec-mntneto  .
*-> END DEL V1-CNN 13.02.2019 - ECDK917529

*-> BEG INS V1-CNN 13.02.2019 - ECDK917529
  CLEAR: lv_supera.
  CALL FUNCTION 'ZDTE_AJUSTA_TOLERANCIAS'
    EXPORTING
      it_items       = lt_itemdata
      it_monto_items = t_item_montos[]
      iv_mnt_neto    = vg_monto_neto
    IMPORTING
      ot_items       = lt_itemdata
      ov_supera      = lv_supera
    EXCEPTIONS
      no_items       = 1
      OTHERS         = 2.

  IF sy-subrc = 0.
    IF NOT lv_supera IS INITIAL.
      resultado = 1.
      estado    = 'NC'.
      mensaje   = 'Supera la tolerancia'.
      EXIT.
    ENDIF.
  ELSE.
*   Hay otro problema de antes.
  ENDIF.
*-> END INS V1-CNN 13.02.2019 - ECDK917529

  lt_taxdata-tax_code = ls_itemdata-tax_code.
  lt_taxdata-tax_amount = wa_dte_doc_rec-iva.
  lt_taxdata-tax_base_amount = wa_dte_doc_rec-mntneto.
  APPEND lt_taxdata.

**********************************************************************
*    Contabilización
**********************************************************************
  IF ls_headerdata-doc_type IS INITIAL.
    resultado = 1.
    estado    = 'NC'.
    mensaje   = 'Indicadores de impuestos inconsistentes'.
  ELSEIF lt_itemdata[] IS INITIAL.
    resultado = 1.
    estado    = 'NC'.
*    mensaje   = 'Factura con Contabilización ya realizada. Revisar'.
    mensaje   = 'Documento sin Posiciones para contabilizar.'.
  ELSE.

    DATA: ledo_invoicedocnumber TYPE bapi_incinv_fld-inv_doc_no,
          ledo_fiscalyear       TYPE bapi_incinv_fld-fisc_year.

    DATA it_extensionin LIKE bapiparex OCCURS 0 WITH HEADER LINE.

    REFRESH ltab_return.

    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE' "#EC CI_USAGE_OK[2438131]
      EXPORTING
        headerdata       = ls_headerdata
      IMPORTING
        invoicedocnumber = ledo_invoicedocnumber
        fiscalyear       = ledo_fiscalyear
      TABLES
        itemdata         = lt_itemdata
*       taxdata          = lt_taxdata
*       accountingdata   = lt_accountingdata
        return           = ltab_return.
*        extensionin      = it_extensionin.

    IF ledo_invoicedocnumber IS NOT INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      resultado = 0.
      factura   = ledo_invoicedocnumber.
      ejercicio = ledo_fiscalyear.
      estado    = 'CO'.

*      IF ltab_return[] IS INITIAL.
      IF factura IS NOT INITIAL.
        CONCATENATE 'Factura MM Contabilizada Nro.' factura INTO mensaje SEPARATED BY space.
      ENDIF.

      "Ejecutamos Grabación para guardar campo emisión

      PERFORM graba_emision USING factura
                                  ejercicio
                                  ls_headerdata-comp_code
                                  rut_emisor
                                  fchemis
                                  resultado.
      IF resultado NE 0.
        CONCATENATE mensaje ' / Error al grabar Emisión.' INTO mensaje.
      ENDIF.
    ELSE.
      resultado = 1.
      estado    = 'NC'.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
      SORT ltab_return .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
      READ TABLE ltab_return INTO lstr_return INDEX 1.
      IF sy-subrc EQ 0.
        mensaje = lstr_return-message.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR ltab_return[].
  CLEAR lt_itemdata[].
  CLEAR ls_headerdata.

  FREE MEMORY.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  hist_quitar_anulados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM hist_quitar_anulados.
***Quitar anulados
  lt_pohistory_anul[] = lt_pohistory[].

*  LOOP AT lt_pohistory_anul INTO ls_pohistory.
*    IF ls_pohistory-mat_doc EQ ls_pohistory-ref_doc."mismo documento
*      CONTINUE.
*    ELSE.
********* borrar referencia
*      READ TABLE lt_pohistory INTO ls_pohistory_aux WITH KEY mat_doc = ls_pohistory-ref_doc.
*      IF sy-subrc EQ 0.
*        DELETE lt_pohistory INDEX sy-tabix.
*
*        READ TABLE lt_pohistory INTO ls_pohistory_aux WITH KEY mat_doc = ls_pohistory-mat_doc.
*          IF sy-subrc EQ 0.
*            DELETE lt_pohistory INDEX sy-tabix.
*          ENDIF.
*      ENDIF.
*********borrar doc de anulacion
*
*    ENDIF.
*  ENDLOOP.
ENDFORM.                    "hist_quitar_anulados

*&---------------------------------------------------------------------*
*&      Form  doc_ref_sort
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM doc_ref_sort.
  LOOP AT lt_dte_doc_rec_ref.
    IF lt_dte_doc_rec_ref-tpodocref EQ 'HES'.
      lt_dte_doc_rec_ref-indglobal = '1'.
      MODIFY lt_dte_doc_rec_ref TRANSPORTING indglobal.
    ELSEIF  lt_dte_doc_rec_ref-tpodocref EQ '50' OR  lt_dte_doc_rec_ref-tpodocref EQ '52'.
      lt_dte_doc_rec_ref-indglobal = '2'.
      MODIFY lt_dte_doc_rec_ref TRANSPORTING indglobal.
    ELSEIF  lt_dte_doc_rec_ref-tpodocref EQ '801'.
      lt_dte_doc_rec_ref-indglobal = '3'.
      MODIFY lt_dte_doc_rec_ref TRANSPORTING indglobal.
    ENDIF.
  ENDLOOP.
  SORT lt_dte_doc_rec_ref BY indglobal ASCENDING.

ENDFORM.                    "doc_ref_sort

*&---------------------------------------------------------------------*
*&      Form  conversion_alpha_out
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LV_NUMERO  text
*----------------------------------------------------------------------*
FORM conversion_alpha_out USING lv_numero.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = lv_numero
    IMPORTING
      output = lv_numero.

ENDFORM.                    "conversion_alpha_out
