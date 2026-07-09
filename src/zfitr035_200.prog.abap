*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <26-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFITR013_200 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'ZFITR035_2'.


ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.

    WHEN 'CANCELAR'.
      salir = 'NO'.
      LEAVE TO SCREEN 0.

    WHEN 'PROCESAR'.
      PERFORM efectuar_contabilizacion.
      salir = 'SI'.
      LEAVE TO SCREEN 0..


  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Form  EFECTUAR_CONTABILIZACION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM efectuar_contabilizacion .

  DATA : nuevo(01),
         lineas(05)  TYPE n,
         tlineas(05) TYPE n,
         filas(05)   TYPE n,
         fecha(08),
         fecha1(08),
         docpag(16),
         valor(15),
         total        LIKE regup-dmbtr,
         gjahr       LIKE bkpf-gjahr,
         belnr       LIKE bkpf-belnr,
         largo(5)    TYPE n ,
         fecha_aux(08),
         xblnr(16),
         cant_imp(6) TYPE n,
         xzlsch LIKE bseg-zlsch,
         xzfbdt LIKE bseg-zfbdt.


  DATA: BEGIN OF tpro OCCURS 0,
    laufd          LIKE reguh-laufd,
    laufi          LIKE reguh-laufi,
    zbukr          LIKE reguh-zbukr,
    lifnr          LIKE reguh-lifnr,
    vblnr          LIKE reguh-vblnr,
    motivo_rechazo LIKE reguh-motivo_rechazo,
    belnr_dev      LIKE reguh-belnr_dev,
    gjahr_dev      LIKE reguh-gjahr_dev,
  END OF tpro.

  DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.



  IF bkpf-budat IS INITIAL.
    MESSAGE e016(z1) WITH 'Debe Ingresar fecha de contabilizacion'  .
  ENDIF.

  IF   bseg-zfbdt < bkpf-budat.
    MESSAGE e016(z1) WITH 'Fecha de vencimiento debe ser >= a Fecha Contabilizacion'.
  ENDIF.

  IF bseg-zlsch  IS INITIAL.
    MESSAGE e016(z1) WITH 'Debe Ingresar Via de Pago'  .
  ENDIF.

  xzfbdt = bseg-zfbdt.
  xzlsch = bseg-zlsch.

  nuevo = 'S'.
  lineas = 0.
  tlineas  = 0.
  total = 0.

  REFRESH: bdcdata, itab.

  CONCATENATE  bseg-zfbdt+6(2) bseg-zfbdt+4(2) bseg-zfbdt+0(4) INTO fecha.
  CONCATENATE  bkpf-budat+6(2) bkpf-budat+4(2) bkpf-budat+0(4) INTO fecha1.

  LOOP AT int_tabla2.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT  SINGLE * FROM reguh WHERE laufd = int_tabla2-laufd
*                        AND   laufi = int_tabla2-laufi
*                        AND   xvorl = ''
*                        AND   zbukr = bukrs
*                        AND   lifnr = int_tabla2-lifnr
*                        AND   vblnr = int_tabla2-vblnr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM reguh WHERE laufd = int_tabla2-laufd
                        AND   laufi = int_tabla2-laufi
                        AND   xvorl = ''
                        AND   zbukr = bukrs
                        AND   lifnr = int_tabla2-lifnr
                        AND   vblnr = int_tabla2-vblnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ResQ Comment:Correction not required as aggregation is used 26/12/2019 EY_DES02 ECDK917080*
    SELECT  COUNT(*) INTO filas   FROM  regup WHERE laufd = reguh-laufd
                        AND   laufi = reguh-laufi
                        AND   xvorl = reguh-xvorl
                        AND   zbukr = reguh-zbukr
                        AND   lifnr = reguh-lifnr
                        AND   kunnr = reguh-kunnr
                        AND   empfg = reguh-empfg
                        AND   vblnr = reguh-vblnr.

    tlineas = lineas + filas.

    IF tlineas > 998.
      WRITE  total  CURRENCY 'CLP'  TO valor.

      largo = STRLEN( reguh-ubhkt ) - 1.

      reguh-ubhkt+largo  = '1'.

      PERFORM bdc_field       USING 'RF05A-NEWBS'
                                     '40'.
      PERFORM bdc_field       USING 'RF05A-NEWKO'
                                    reguh-ubhkt.
      PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'BSEG-SGTXT'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=BU'.
      PERFORM bdc_field       USING 'BSEG-WRBTR'
                                     valor.
      PERFORM bdc_field       USING 'BSEG-VALUT'
                                     fecha1.
      PERFORM bdc_field       USING 'BSEG-SGTXT'
                                     'Rechazo Pago Bancario'.
      PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'COBL-PRCTR'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=ENTE'.

      CALL TRANSACTION 'F-02' USING  bdcdata
                                      MODE 'E'
                                      UPDATE 'S'
                                      MESSAGES INTO itab.
      CLEAR belnr.
      LOOP AT itab.
        IF itab-msgid = 'F5' AND     itab-msgnr = '312'.
          belnr = itab-msgv1.
          gjahr = fecha1+4(4).
        ENDIF.

      ENDLOOP.

      IF NOT belnr IS INITIAL.
        LOOP AT tpro WHERE belnr_dev IS INITIAL.
          tpro-belnr_dev = belnr.
          tpro-gjahr_dev = gjahr.
          MODIFY tpro.
        ENDLOOP.
        LOOP AT tabsrd.
          tabsrd-comprobante_rechazo = belnr.
          MODIFY tabsrd.
        ENDLOOP.
        PERFORM grabar_datos_deposito.
      ELSE.
        LOOP AT tpro WHERE belnr_dev IS INITIAL.
          DELETE  tpro.
        ENDLOOP.
      ENDIF.

      nuevo = 'S'.
      lineas = 0.
      total = 0.
      REFRESH: bdcdata, itab.
    ENDIF.

SELECT * FROM regup WHERE laufd = reguh-laufd
AND laufi = reguh-laufi
AND xvorl = reguh-xvorl
AND zbukr = reguh-zbukr
AND lifnr = reguh-lifnr
AND kunnr = reguh-kunnr
AND empfg = reguh-empfg
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 26/12/2019 EY_DES02 ECDK917080 *
*AND vblnr = reguh-vblnr.
AND VBLNR = REGUH-VBLNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 26/12/2019 EY_DES02 ECDK917080 *

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
*                              AND  belnr = regup-belnr
*                              AND  gjahr = regup-gjahr
*                              AND  buzei = regup-buzei.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM  bseg WHERE bukrs  = regup-bukrs
                              AND  belnr = regup-belnr
                              AND  gjahr = regup-gjahr
                              AND  buzei = regup-buzei ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01



      IF nuevo = 'S'.
        CONCATENATE sy-datum '-'sy-uzeit INTO xblnr.
        PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'RF05A-NEWKO'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'BKPF-BLDAT'
                                      fecha1.
        PERFORM bdc_field       USING 'BKPF-BLART'
                                      'XF'.
        PERFORM bdc_field       USING 'BKPF-BUKRS'
                                      bukrs.
        PERFORM bdc_field       USING 'BKPF-BUDAT'
                                      fecha1.
        PERFORM bdc_field       USING 'BKPF-WAERS'
                                       'CLP'.
        PERFORM bdc_field       USING 'BKPF-XBLNR'
                                       xblnr.
        PERFORM bdc_field       USING 'BKPF-BKTXT'
                                      'Rechazo Pago Bancario'.
        PERFORM bdc_field       USING 'RF05A-NEWBS'
                                       '31'.
        PERFORM bdc_field       USING 'RF05A-NEWKO'
                                      reguh-lifnr.
        nuevo = 'N'.
      ELSE.
        PERFORM bdc_field       USING 'RF05A-NEWBS'
                                      '31'.
        PERFORM bdc_field       USING 'RF05A-NEWKO'
                                      reguh-lifnr.
      ENDIF.


      WRITE  regup-dmbtr CURRENCY 'CLP'  TO valor.
      PERFORM bdc_dynpro      USING 'SAPMF05A' '0302'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'BSEG-ZLSCH'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=ZK'.

      READ TABLE tcuenta WITH KEY bukrs = bukrs
                                  rzawe = reguh-rzawe
                                  hkont_orig = bseg-hkont
                                  rzawe_d = xzlsch.

      IF sy-subrc <> 0.
        MESSAGE e016(z1) WITH 'Cta no definida Para Soc./Cta. Origen/Via Pago D.' bukrs bseg-hkont.
      ENDIF.

      tabsrd-sociedad  = bukrs.
      tabsrd-fecha_registro = sy-datum.
      tabsrd-comprobante_rechazo = ''.
      tabsrd-rut_afiliado  = reguh-stcd1.
      tabsrd-monto_pago  = regup-dmbtr * 100.
      tabsrd-banco_pagado = tcuenta-hbkid_dest.
      tabsrd-via_pago = xzlsch.
      tabsrd-fecha_vencimiento = xzfbdt.
      tabsrd-motivo_emision = bseg-zzmot_emis.
      tabsrd-agencia_origen = bseg-zz_agencia.
      tabsrd-folio_documento = bseg-zuonr.
      tabsrd-motivo_rechazo = int_tabla2-motivo_rechazo.
      tabsrd-motivo_tesoreria = bseg-zzdesc_est.
      tabsrd-usuario_responsable = sy-uname.
      APPEND tabsrd.

      PERFORM bdc_field       USING 'BSEG-HKONT'
                                     tcuenta-hkont_dest.
      PERFORM bdc_field       USING 'BSEG-WRBTR'
                                     valor.
      PERFORM bdc_field       USING 'BSEG-MWSKZ'
                                     ''.
      PERFORM bdc_field       USING 'BSEG-ZTERM'
                                     'ZC01'.
      PERFORM bdc_field       USING 'BSEG-ZFBDT'
                                     fecha.
      PERFORM bdc_field       USING 'BSEG-ZLSCH'
                                     xzlsch.
      PERFORM bdc_field       USING 'BSEG-ZUONR'
                                     bseg-zuonr.
      PERFORM bdc_field       USING 'BSEG-SGTXT'
                                     int_tabla2-motivo_rechazo.
      PERFORM bdc_field       USING 'BSEG-ZZMOT_EMIS'
                                     bseg-zzmot_emis.
      IF xzlsch = 'C'.
        PERFORM bdc_field       USING 'BSEG-ZZ_AGENCIA'
                                   '229'.
      ELSE.
        PERFORM bdc_field       USING 'BSEG-ZZ_AGENCIA'
                                   bseg-zz_agencia.
      ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM lfb1 WHERE lifnr = reguh-lifnr AND
*                                       bukrs = bukrs.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM lfb1 WHERE lifnr = reguh-lifnr AND
                                       bukrs = bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF sy-subrc = 0.
        SELECT COUNT(*) INTO cant_imp FROM lfbw
                                     WHERE lifnr = reguh-lifnr
                                     AND   bukrs = bukrs.
        IF cant_imp > 0.
          PERFORM bdc_dynpro USING  'SAPLFWTD' '0100'.
          PERFORM bdc_field  USING  'BDC_CURSOR'
                                    'WITH_ITEM-WT_WITHCD(01)'.
          PERFORM bdc_field  USING 'BDC_OKCODE'
                                     '/00'.
          PERFORM bdc_field  USING  'WITH_ITEM-WT_WITHCD(01)'
                                    '  '.
        ENDIF.
      ENDIF.

      PERFORM bdc_dynpro      USING 'SAPMF05A' '0332'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'RF05A-NEWKO'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.


      PERFORM bdc_field       USING 'BSEG-HBKID'
                                     tcuenta-hbkid_dest.
      PERFORM bdc_field       USING 'BSEG-HKTID'
                                     tcuenta-hktid_dest.
      PERFORM bdc_field       USING 'BSEG-XREF2'
                                     reguh-vblnr.

      lineas = lineas + 1.

      total = total + regup-dmbtr.

    ENDSELECT.

    CLEAR tpro.
    tpro-laufd  =    int_tabla2-laufd.
    tpro-laufi  =    int_tabla2-laufi.
    tpro-zbukr  =    bukrs.
    tpro-lifnr  =    int_tabla2-lifnr.
    tpro-vblnr  =    int_tabla2-vblnr.
    tpro-motivo_rechazo = int_tabla2-motivo_rechazo.
    APPEND tpro.

  ENDLOOP.

  IF lineas > 0.
    largo = STRLEN( reguh-ubhkt ) - 1.

    reguh-ubhkt+largo  = '1'.
    WRITE  total  CURRENCY 'CLP'  TO valor.
    PERFORM bdc_field       USING 'RF05A-NEWBS'
                                   '40'.
    PERFORM bdc_field       USING 'RF05A-NEWKO'
                                  reguh-ubhkt.
    PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'BSEG-SGTXT'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=BU'.
    PERFORM bdc_field       USING 'BSEG-WRBTR'
                                   valor.
    PERFORM bdc_field       USING 'BSEG-VALUT'
                                   fecha1.
    PERFORM bdc_field       USING 'BSEG-SGTXT'
                                   'Rechazo Pago'.
    PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'COBL-PRCTR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTE'.

    CALL TRANSACTION 'F-02' USING  bdcdata
                                    MODE 'E'
                                    UPDATE 'S'
                                    MESSAGES INTO itab.
    CLEAR belnr.
    LOOP AT itab.
      IF itab-msgid = 'F5' AND     itab-msgnr = '312'.
        belnr = itab-msgv1.
        gjahr = fecha1+4(4).
      ENDIF.
    ENDLOOP.

    IF NOT belnr IS INITIAL.
      LOOP AT tpro WHERE belnr_dev IS INITIAL.
        tpro-belnr_dev = belnr.
        tpro-gjahr_dev = gjahr.
        MODIFY tpro.
      ENDLOOP.

      LOOP AT tabsrd.
        tabsrd-comprobante_rechazo = belnr.
        MODIFY tabsrd.
      ENDLOOP.
      PERFORM grabar_datos_deposito.
    ELSE.
      LOOP AT tpro WHERE belnr_dev IS INITIAL.
        DELETE  tpro.
      ENDLOOP.
    ENDIF.
  ENDIF.


  LOOP AT tpro.
    CONCATENATE bkpf-budat+0(4) bkpf-budat+4(2) bkpf-budat+6(2) INTO fecha_aux.
    UPDATE reguh
        SET   ind_rechazo = 'X'
              fecha_rechazo = fecha_aux
              motivo_rechazo = tpro-motivo_rechazo
              belnr_dev     = tpro-belnr_dev
              gjahr_dev     = tpro-gjahr_dev
       WHERE laufd = tpro-laufd
       AND   laufi = tpro-laufi
       AND   xvorl = ''
       AND   zbukr = tpro-zbukr
       AND   lifnr = tpro-lifnr
       AND   vblnr = tpro-vblnr.
  ENDLOOP.


ENDFORM.                    "contabilizar



*&---------------------------------------------------------------------*
*&      Form  grabar_datos_deposito
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM grabar_datos_deposito.

  DATA oref TYPE REF TO cx_root.
  DATA observacion(100).

  EXEC SQL.
    connect to 'SAPCSC' as 'con'
  ENDEXEC.

  EXEC SQL.
    set connection 'con'
  ENDEXEC.

  TRY.
      LOOP AT tabsrd.
        EXEC SQL.
          INSERT INTO SAP_RECHAZO_DEPOSITO (srd_sociedad,
                                            srd_fecha_registro,
                                            srd_comprobante_rechazo,
                                            srd_rut_afiliado,
                                            srd_monto_pago,
                                            srd_banco_pagado,
                                            srd_via_pago,
                                            srd_fecha_vencimiento,
                                            srd_motivo_emision,
                                            srd_agencia_origen,
                                            srd_folio_documento,
                                            srd_motivo_rechazo,
                                            srd_motivo_tesoreria,
                                            srd_usuario_responsable)
          VALUES(:tabsrd-sociedad,
                TO_DATE(:tabsrd-fecha_registro,'YYYYMMDD') ,
                :tabsrd-comprobante_rechazo,
                :tabsrd-rut_afiliado,
                :tabsrd-monto_pago,
                :tabsrd-banco_pagado,
                :tabsrd-via_pago,
                TO_DATE(:tabsrd-fecha_vencimiento,'YYYYMMDD'),
                :tabsrd-motivo_emision,
                :tabsrd-agencia_origen,
                :tabsrd-folio_documento,
                :tabsrd-motivo_rechazo,
                :tabsrd-motivo_tesoreria,
                :tabsrd-usuario_responsable )
        ENDEXEC.
      ENDLOOP.

    CATCH cx_sy_native_sql_error INTO oref.
      observacion = oref->get_text( ).
      MESSAGE i016(z1) WITH 'Error Grabar SAP_RECHAZO_DEPOSITO: ' observacion.
  ENDTRY.

  REFRESH tabsrd.

  EXEC SQL.
    set connection default
  ENDEXEC.


ENDFORM.                    "grabar_datos_deposito
