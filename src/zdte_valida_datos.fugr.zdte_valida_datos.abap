*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION zdte_valida_datos.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(VAL_RZNO_SOCIAL) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(VAL_GIRO) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(VAL_DIR) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(VAL_OC) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(VAL_PROVEEDOR) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(VAL_HES) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(GT_DATA) TYPE  ZDTE_DOC_REC
*"  EXPORTING
*"     REFERENCE(RETORNO) TYPE  CHAR02
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"      GT_EKSEL STRUCTURE  EKSEL
*"      GT_REF STRUCTURE  ZDTE_DOC_REC_REF
*"----------------------------------------------------------------------

  REFRESH return.
  CLEAR: lv_error, wa_data, return.

  wa_data = gt_data.

  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE ti_ref
  FROM zdte_doc_rec_ref
  WHERE rutemisor EQ wa_data-rutemisor
    AND tipodte   EQ wa_data-tipodte
    AND folio     EQ wa_data-folio.
  IF sy-subrc EQ 0.
    "Nada

  ELSE.
    lv_error = 'X'.
    CLEAR return.
    return-type = 'E'.
    return-message = 'Factura Sin referencia.'.
    APPEND return.

    CLEAR retorno.
    retorno = 'RE'.

    EXIT.
  ENDIF.

*Valida Razon solcial
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
  SELECT SINGLE bukrs party INTO (lv_bukrs, lv_party)
         FROM   t001z
         WHERE  paval = wa_data-rutrecep.

  IF sy-subrc = 0.
    SELECT SINGLE butxt adrnr INTO (lv_butxt, lv_adrnr)
           FROM   t001
           WHERE  bukrs = lv_bukrs.
    IF sy-subrc = 0.

      PERFORM convert CHANGING lv_butxt.

      SELECT SINGLE city1 street house_num1
        INTO (lv_city1, lv_street, lv_house_num1)
        FROM adrc
       WHERE addrnumber EQ lv_adrnr.
      IF sy-subrc EQ 0.
        CONCATENATE lv_city1 lv_street lv_house_num1 INTO lv_dir SEPARATED BY space.
        PERFORM convert USING lv_dir.
      ENDIF.

    ENDIF.

    PERFORM convert CHANGING lv_party.

  ENDIF.

* validacion a
  IF val_rzno_social EQ 'X'.
    PERFORM convert USING wa_data-rznrecep.
    IF lv_butxt NE wa_data-rznrecep.
      lv_error = 'X'.
      CLEAR return.
      return-type = 'E'.
      return-message = 'Error en la validacion de la Razon Social'.
      APPEND return.
    ENDIF.

    CLEAR retorno.
    IF lv_error IS INITIAL.
      retorno = 'OK'.
    ELSEIF lv_error EQ 'X'.
      retorno = 'RE'.
    ENDIF.

  ENDIF.

  CHECK lv_error IS INITIAL.

* validacion b
  IF val_giro EQ 'X'.
    PERFORM convert USING wa_data-girorecep.
    IF lv_party NE wa_data-girorecep.
      lv_error = 'X'.
      CLEAR return.
      return-type = 'E'.
      return-message = 'Giro receptor del DTE no coincide con sociedad SAP '.
      APPEND return.
    ENDIF.

    CLEAR retorno.
    IF lv_error IS INITIAL.
      retorno = 'OK'.
    ELSEIF lv_error EQ 'X'.
      retorno = 'RE'.
    ENDIF.

  ENDIF.

  CHECK lv_error IS INITIAL.

* validacion c
  IF val_dir EQ 'X'.
    PERFORM convert USING wa_data-dirrecep.
    IF lv_dir NE wa_data-dirrecep.
      lv_error = 'X'.
      CLEAR return.
      return-type     = 'E'.
      return-message  = 'Direccion receptor DTE no coincide con sociedad SAP'.
      APPEND return.
    ENDIF.

    CLEAR retorno.
    IF lv_error IS INITIAL.
      retorno = 'OK'.
    ELSEIF lv_error EQ 'X'.
      retorno = 'RE'.
    ENDIF.

  ENDIF.

  CHECK lv_error IS INITIAL.

* validacion d
  IF val_proveedor EQ 'X'.
    SELECT SINGLE *
    FROM lfa1
    WHERE stcd1 EQ wa_data-rutemisor.
    IF sy-subrc EQ 0.
      SELECT SINGLE *
      FROM lfb1
      WHERE lifnr EQ lfa1-lifnr. "Verificar Sociedad?
      IF sy-subrc EQ 0.
        "Nada.
      ELSE.

        CLEAR retorno.
        IF lv_error IS INITIAL.
          retorno = 'OK'.
        ELSEIF lv_error EQ 'X'.
          retorno = 'RE'.
        ENDIF.

      ENDIF.
    ENDIF.

  ENDIF.

  CHECK lv_error IS INITIAL.

* validacion e
  IF val_oc EQ 'X'.
*    validacion i
    PERFORM valida_oc1  TABLES  ti_ref[].

    IF lv_null EQ 'X'.
      CLEAR return.
      return-type    = 'E'.
      return-message = 'Nro. Orden de compra no viene en el DTE'.
      lv_error       = 'X'.
      APPEND return.
    ELSE.

*    validacion ii
      PERFORM valida_oc2 TABLES ti_ref[].

      IF lv_tipo EQ 'X'.
        CLEAR return.
        return-type    = 'E'.
        return-message = 'Tipo de orden de compra no corresponde a una  factura'.
        lv_error       = 'X'.
        APPEND return.
      ENDIF.

*    validacion iii
      PERFORM valida_oc3 TABLES ti_ref[].
      IF lv_exist EQ 'X'.
        CLEAR return.
        return-type     = 'E'.
        return-message  = 'Orden de compra , no existe en la sociedad'.
        lv_error        = 'X'.
        APPEND return.
      ENDIF.

*    validacion iv
      PERFORM valida_oc4 TABLES ti_ref[].
      IF lv_corr EQ 'X'.
        CLEAR return.
        return-type     = 'E'.
        return-message  = 'Orden de compra , no corresponde al proveedor'.
        lv_error        = 'X'.
        APPEND return.
      ENDIF.

    ENDIF.

    CLEAR retorno.
    IF lv_error IS INITIAL.
      retorno = 'OK'.
    ELSEIF lv_error EQ 'X'.
      retorno = 'RE'.
    ENDIF.

  ENDIF.

* validacion f

*  IF val_hes EQ 'X'.
*    PERFORM valida_hes1 TABLES ti_ref[].
*    IF lv_null2 EQ 'X'.
*      CLEAR return.
*      return-type = 'E'.
*      return-message = 'Error en la validacion de la HES, campo vacio'.
*      lv_error = 'X'.
*      APPEND return.
*    ENDIF.
*
*    PERFORM valida_hes2 TABLES ti_ref[].
*    IF lv_hes EQ 'X'.
*      CLEAR return.
*      return-type = 'E'.
*      return-message = 'Error en la validacion de la HES, hes no relacionada con oc'.
*      lv_error = 'X'.
*      APPEND return.
*    ENDIF.
  DATA vl_ebeln TYPE ebeln.
  DATA vl_hes   TYPE belnr_d.

  READ TABLE ti_ref INTO wa_ref WITH KEY tpodocref = '801'.
  IF sy-subrc EQ 0.
    vl_ebeln = wa_ref-folioref.

    SELECT SINGLE *  "Validamos Factura de Servicio
    FROM ekpo
    WHERE ebeln EQ vl_ebeln
      AND ebelp EQ 10
      AND pstyp EQ '9'.
    IF sy-subrc EQ 0.

      READ TABLE ti_ref INTO wa_ref WITH KEY tpodocref = 'HES'.
      IF sy-subrc EQ 0.

        vl_hes = wa_ref-folioref.

        SELECT SINGLE *
        FROM ekbe
        WHERE ebeln EQ vl_ebeln
          AND belnr EQ vl_hes.
        IF sy-subrc EQ 0.
          "Nada
        ELSE.
          CLEAR return.
          return-type    = 'E'.
          return-message = 'Error en la validación de la HES. No corresponde al Pedido'.
          lv_error       = 'X'.
          APPEND return.

          retorno = 'RE'.
        ENDIF.

      ELSE.
        CLEAR return.
        return-type = 'E'.
        return-message = 'Error en la validación de la HES, campo vacío'.
        lv_error = 'X'.
        APPEND return.

        retorno = 'RE'.

      ENDIF.

    ELSE.
*      CLEAR return.
*      return-type     = 'E'.
*      return-message  = 'Error en la validacion de la HES, campo vacio'.
*      lv_error        = 'X'.
*      APPEND return.
*
*      retorno = 'RE'.

    ENDIF.
  ENDIF.
*ENDIF.

*  ENDIF.

  CHECK lv_error IS INITIAL.

ENDFUNCTION.
