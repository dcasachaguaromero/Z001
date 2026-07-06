FUNCTION zws_crea_clientes.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(STR_CLIENTE) LIKE  ZSD_BI_CLIENTES STRUCTURE
*"        ZSD_BI_CLIENTES
*"  EXPORTING
*"     VALUE(E_ID_CLIENTE_SAP) TYPE  CHAR10
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  wa_data = str_cliente.
  CLEAR e_id_cliente_sap.

  SELECT SINGLE FROM kna1 FIELDS kunnr, stcd1
    WHERE stcd1 = @wa_data-rut INTO @DATA(ls_kna1).
  IF sy-subrc <> 0.
*   Cliente nuevo
    PERFORM crea_cliente USING wa_data.
  ELSE.
*   Verificar sociedad
    SELECT SINGLE FROM knb1 FIELDS kunnr, bukrs
      WHERE kunnr = @ls_kna1-kunnr
        AND bukrs = @wa_data-sociedad
      INTO @DATA(ls_knb1).
    IF sy-subrc <> 0.
*     Ampliar cliente
      PERFORM amplia_cliente USING wa_data
                                   ls_kna1-kunnr.
    ELSE.
*     El cliente con RUT & ya existe en la sociedad & con ID &
      CLEAR return.
      return-type       = 'E'.
      return-id         = 'Z001'.
      return-number     = '009'.
      return-message_v1 = wa_data-rut.
      return-message_v2 = wa_data-sociedad.
      return-message_v3 = ls_kna1-kunnr.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = return-id
          msgnr               = return-number
          msgv1               = return-message_v1
          msgv2               = return-message_v2
          msgv3               = return-message_v3
        IMPORTING
          message_text_output = return-message.
      APPEND return.
*     Sale de la función
      RETURN.
    ENDIF.
  ENDIF.

  CLEAR: messtab.
  CALL TRANSACTION 'XD01' USING bdcdata
                   MODE   ctumode
                   UPDATE cupdate
                   MESSAGES INTO messtab.

  READ TABLE messtab INTO ls_mess WITH KEY msgtyp = 'S'
                                           msgid = 'F2'
                                           msgnr = '174'.
  IF sy-subrc = 0.
    CLEAR return.
    e_id_cliente_sap  = ls_mess-msgv1.
    return-type       = ls_mess-msgtyp.
    return-id         = ls_mess-msgid.
    return-number     = ls_mess-msgnr.
    CONCATENATE 'El cliente' wa_data-nroclientecore
                'se ha creado exitosamente en SAP con el id'
                ls_mess-msgv1
      INTO return-message SEPARATED BY space.
    return-message_v1 = ls_mess-msgv1.
    return-message_v2 = ls_mess-msgv2.
    return-message_v3 = ls_mess-msgv3.
    return-message_v4 = ls_mess-msgv4.
    return-parameter  = space.
    APPEND return.

    PERFORM actualizar_textos USING ls_mess-msgv1 wa_data-texto1 wa_data-texto2.
  ELSE.
    LOOP AT messtab INTO ls_mess WHERE msgtyp = 'E'.
      CLEAR return.
      SELECT SINGLE text INTO return-message FROM t100 WHERE sprsl EQ sy-langu
                                                         AND arbgb EQ ls_mess-msgid
                                                         AND msgnr EQ ls_mess-msgnr.
      REPLACE '&1' INTO return-message WITH ls_mess-msgv1.
      REPLACE '&2' INTO return-message WITH ls_mess-msgv2.
      REPLACE '&3' INTO return-message WITH ls_mess-msgv3.
      REPLACE '&4' INTO return-message WITH ls_mess-msgv4.
      return-type       = ls_mess-msgtyp.
      return-id         = ls_mess-msgid.
      return-number     = ls_mess-msgnr.
      return-message_v1 = ls_mess-msgv1.
      return-message_v2 = ls_mess-msgv2.
      return-message_v3 = ls_mess-msgv3.
      return-message_v4 = ls_mess-msgv4.
      APPEND return.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.


*--------------------------------------------------------------------*
*              Form CREA_CLIENTE
*--------------------------------------------------------------------*
FORM crea_cliente USING wa_data TYPE gty_data.

  CLEAR: bdcdata[].

  PERFORM bdc_dynpro USING 'SAPMF02D'    '0100'.
  PERFORM bdc_field  USING 'BDC_CURSOR'  'USE_ZAV'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
  PERFORM bdc_field  USING 'RF02D-BUKRS' wa_data-sociedad. "CL51
  PERFORM bdc_field  USING 'RF02D-VKORG' wa_data-oventas. "CL51
  PERFORM bdc_field  USING 'RF02D-VTWEG' wa_data-canal.   "'01'.
  PERFORM bdc_field  USING 'RF02D-SPART' wa_data-sector.  "'00'.
  PERFORM bdc_field  USING 'RF02D-KTOKD' wa_data-grupocuentas. "'Z001'.
  PERFORM bdc_field  USING 'USE_ZAV'     'X'.
**----------------------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'              '0111'.
  PERFORM bdc_field  USING 'BDC_OKCODE'            '=$MTE'.
  PERFORM bdc_field  USING 'BDC_CURSOR'            'ADDR1_DATA-REMARK'.
  PERFORM bdc_field  USING 'ADDR1_DATA-NAME1'      wa_data-nombre1. "'nombre1'.
  PERFORM bdc_field  USING 'ADDR1_DATA-NAME2'      wa_data-nombre2. "'nombre2'.
  PERFORM bdc_field  USING 'ADDR1_DATA-SORT1'      wa_data-rut."'15.331.915-4'.
  PERFORM bdc_field  USING 'ADDR1_DATA-SORT2'      wa_data-nroclientecore."'numero cli core
  PERFORM bdc_field  USING 'ADDR1_DATA-BUILDING'   wa_data-depto."'depto'.
  PERFORM bdc_field  USING 'ADDR1_DATA-FLOOR'      wa_data-piso."'piso'.
  PERFORM bdc_field  USING 'ADDR1_DATA-STR_SUPPL1' wa_data-calle2. "'calle2'.
  PERFORM bdc_field  USING 'ADDR1_DATA-STR_SUPPL2' wa_data-block."'block'.
  PERFORM bdc_field  USING 'ADDR1_DATA-STREET'     wa_data-calle."'calle'.
  PERFORM bdc_field  USING 'ADDR1_DATA-HOUSE_NUM1' wa_data-numero."'num'.
  PERFORM bdc_field  USING 'ADDR1_DATA-LOCATION'   wa_data-villa."'villa'.
  PERFORM bdc_field  USING 'ADDR1_DATA-CITY2'      wa_data-comuna."'comuna'.
  PERFORM bdc_field  USING 'ADDR1_DATA-CITY1'      wa_data-ciudad."'ciudad'.
  PERFORM bdc_field  USING 'ADDR1_DATA-COUNTRY'    wa_data-pais."'cl'.
  PERFORM bdc_field  USING 'ADDR1_DATA-REGION'     wa_data-region. "'13'.
  PERFORM bdc_field  USING 'ADDR1_DATA-LANGU'      sy-langu.
  PERFORM bdc_field  USING 'ADDR1_DATA-REMARK'     wa_data-fechanac.
***---------------------------------------------------
*  PERFORM BDC_DYNPRO USING 'SAPLSPO1' '0600'.
*  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=OPT1'.
***---------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPLSZA6'             '0200'.
  PERFORM bdc_field  USING 'BDC_OKCODE'           '=NEWL'.
  PERFORM bdc_field  USING 'ADTEL-TEL_NUMBER(01)' wa_data-telefono1.
**---------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPLSZA6' '0200'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=NEWL'.
  PERFORM bdc_field  USING 'ADTEL-TEL_NUMBER(01)' wa_data-telefono2.
**--------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPLSZA6'  '0200'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=SHTM'.
  PERFORM bdc_field  USING 'ADTEL-TEL_NUMBER(01)' wa_data-movil."movil.
  PERFORM bdc_field  USING 'G_SELECTED(01)'  'X'.
*-----------------------------------------------
  PERFORM bdc_dynpro USING 'SAPLSZA6' '0200'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=CONT'.
**--------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D' '0111'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=$MMO'.
**----------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPLSZA6' '0200'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=CONT'.
**----------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D' '0111'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=ZUDA'.
**---------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPLV02Z'   '0100'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=BACK'.
  PERFORM bdc_field  USING 'KNA1-KATR1' wa_data-prevision.
  PERFORM bdc_field  USING 'KNA1-KATR2' wa_data-estadocivil.
  PERFORM bdc_field  USING 'KNA1-KATR3' wa_data-sexo.
  PERFORM bdc_field  USING 'KNA1-KATR4' wa_data-catcliente.
  PERFORM bdc_field  USING 'KNA1-KATR5' wa_data-rangoetareo.
  PERFORM bdc_field  USING 'KNA1-KATR6' wa_data-perfilcobranza.
  PERFORM bdc_field  USING 'KNA1-KATR7' wa_data-rentabilidad.
  PERFORM bdc_field  USING 'KNA1-KATR8' wa_data-profesion.
  PERFORM bdc_field  USING 'KNA1-KATR9' wa_data-cargo.
**---------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0111'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
**--------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0120'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'KNA1-STCD1'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
  REPLACE '.' WITH space INTO wa_data-rut2.
  CONDENSE wa_data-rut2 NO-GAPS.
  PERFORM bdc_field USING 'KNA1-STCD1' wa_data-rut2.
**------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0125'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'KNA1-NIELS'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
**------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0130'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'KNBK-BANKS(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=ENTR'.
**--------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0360'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'KNVK-NAMEV(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=ENTR'.
**--------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0210'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'KNB1-FDGRV'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field  USING 'KNB1-AKONT' wa_data-cuentaasociada.
  PERFORM bdc_field  USING 'KNB1-ZUAWA' wa_data-claveclasif.
  PERFORM bdc_field  USING 'KNB1-FDGRV' wa_data-grupotesoreria.
**--------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0215'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'KNB1-HBKID'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field  USING 'KNB1-ZTERM' wa_data-condicionpago. "'ZD00'.
  PERFORM bdc_field  USING 'KNB1-XZVER' 'X'.
  PERFORM bdc_field  USING 'KNB1-ZWELS' wa_data-viapago."'DET'.
  PERFORM bdc_field  USING 'KNB1-HBKID' wa_data-bancopropio. "'BIC00'.
**--------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0220'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'KNB5-MAHNA'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
**--------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0230'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'KNB1-VRSNR'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
**--------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0610'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'RF02D-KUNNR'.
**--------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0310'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'KNVV-BZIRK'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field  USING 'KNVV-BZIRK' space.
  PERFORM bdc_field  USING 'KNVV-AWAHR' '100'.
  PERFORM bdc_field  USING 'KNVV-WAERS' 'CLP'.
  PERFORM bdc_field  USING 'KNVV-KALKS' '1'.
**--------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '0320'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'KNVV-KTGRD'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '/00'.
  PERFORM bdc_field  USING 'KNVV-ZTERM' wa_data-condpago. "'ZD00'.
  PERFORM bdc_field  USING 'KNVV-KTGRD' wa_data-grupoimputacion. "'01'.
**--------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'       '1350'.
  PERFORM bdc_field  USING 'BDC_CURSOR'     'KNVI-TAXKD(01)'.
  PERFORM bdc_field  USING 'BDC_OKCODE'     '=ENTR'.
  PERFORM bdc_field  USING 'KNVI-TAXKD(01)' wa_data-clasiffiscal.
**--------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '1350'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'RF02D-KUNNR'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=TEXT'.
**--------------------------------------------------------
  PERFORM bdc_dynpro USING 'SAPMF02D'   '3500'.
  PERFORM bdc_field  USING 'BDC_CURSOR' 'RF02D-KUNNR'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=UPDA'.

  PERFORM bdc_dynpro USING 'SAPMF02D'   '3500'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=BACK'.

ENDFORM.


*--------------------------------------------------------------------*
*              Form AMPLIA_CLIENTE
*--------------------------------------------------------------------*
FORM amplia_cliente USING wa_data  TYPE gty_data
                          iv_kunnr TYPE kunnr.

  CLEAR: bdcdata[].

* Cliente crear: Acceso
  PERFORM bdc_dynpro USING 'SAPMF02D'    '0100'.
  PERFORM bdc_field  USING 'RF02D-KUNNR' iv_kunnr.
  PERFORM bdc_field  USING 'RF02D-BUKRS' wa_data-sociedad.
  PERFORM bdc_field  USING 'RF02D-VKORG' wa_data-oventas.
  PERFORM bdc_field  USING 'RF02D-VTWEG' wa_data-canal.
  PERFORM bdc_field  USING 'RF02D-SPART' wa_data-sector.
  PERFORM bdc_field  USING 'RF02D-KTOKD' wa_data-grupocuentas.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
*
  PERFORM bdc_dynpro USING 'SAPMF02D'    '0210'.
  PERFORM bdc_field  USING 'KNB1-AKONT'  wa_data-cuentaasociada.
  PERFORM bdc_field  USING 'KNB1-ZUAWA'  wa_data-claveclasif.
  PERFORM bdc_field  USING 'KNB1-FDGRV'  wa_data-grupotesoreria.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=VW'.
*
  PERFORM bdc_dynpro USING 'SAPMF02D'    '0215'.
  PERFORM bdc_field  USING 'KNB1-ZTERM'  wa_data-condicionpago.
  PERFORM bdc_field  USING 'KNB1-XZVER'  'X'.
  PERFORM bdc_field  USING 'KNB1-ZWELS'  wa_data-viapago.
  PERFORM bdc_field  USING 'KNB1-HBKID'  wa_data-bancopropio.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=VW'.
*
  PERFORM bdc_dynpro USING 'SAPMF02D'    '0220'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=VW'.
*
  PERFORM bdc_dynpro USING 'SAPMF02D'    '0230'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=VW'.
*
  PERFORM bdc_dynpro USING 'SAPMF02D'    '0610'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=VW'.
*
  PERFORM bdc_dynpro USING 'SAPMF02D'    '0310'.
  PERFORM bdc_field  USING 'KNVV-BZIRK'  space.
  PERFORM bdc_field  USING 'KNVV-AWAHR'  '100'.
  PERFORM bdc_field  USING 'KNVV-WAERS'  'CLP'.
  PERFORM bdc_field  USING 'KNVV-KALKS'  '1'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=VW'.
*
  PERFORM bdc_dynpro USING 'SAPMF02D'    '0320'.
  PERFORM bdc_field  USING 'KNVV-ZTERM'  wa_data-condpago.
  PERFORM bdc_field  USING 'KNVV-KTGRD'  wa_data-grupoimputacion.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=VW'.
*
  PERFORM bdc_dynpro USING 'SAPMF02D'       '1350'.
  PERFORM bdc_field  USING 'KNVI-TAXKD(01)' wa_data-clasiffiscal.
  PERFORM bdc_field  USING 'BDC_OKCODE'     '=UPDA'.

ENDFORM.
