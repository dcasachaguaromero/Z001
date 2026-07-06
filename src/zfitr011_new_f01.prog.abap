*&---------------------------------------------------------------------*
*&  Include           ZFITR011_NEW_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
*
  REFRESH: trec,tdev,tres.

  DO.
    EXEC SQL.
      FETCH NEXT c1 INTO  :reg
    ENDEXEC.
    IF sy-subrc <> 0.
      EXIT.
    ELSE.
      IF bukrs = reg-codigo_identificacion+0(4).
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = reg-rut_beneficiario+0(8)
          IMPORTING
            output = rut_aux.
        CONCATENATE rut_aux '-'  reg-rut_beneficiario+8(1)  INTO rut_aux.

        IF reg-estado_pago = 'CUSTODIA'.
          IF NOT reg-fecha_estado IS INITIAL.
            CONCATENATE reg-fecha_estado+0(4) reg-fecha_estado+5(2) reg-fecha_estado+8(2) INTO fecha_aux.
          ELSE.
            CONCATENATE reg-fecha_recepcion+0(4) reg-fecha_recepcion+5(2) reg-fecha_recepcion+8(2) INTO fecha_aux.
          ENDIF.
          UPDATE reguh SET ind_custodia = 'X'
                          fecha_custodia = fecha_aux
                WHERE identif_pago = reg-codigo_identificacion
                AND   zstc1 =  rut_aux.
          subrc = sy-subrc.
          PERFORM actualizo_sapbbva_emitidos.
        ELSE.
          IF reg-estado_pago = 'CHEQUE PAGADO'.
            IF NOT reg-fecha_estado IS INITIAL.
              CONCATENATE reg-fecha_estado+0(4) reg-fecha_estado+5(2) reg-fecha_estado+8(2) INTO fecha_aux.
            ELSE.
              CONCATENATE reg-fecha_recepcion+0(4) reg-fecha_recepcion+5(2) reg-fecha_recepcion+8(2) INTO fecha_aux.
            ENDIF.
            UPDATE reguh SET ind_pago = 'X'
                             fecha_pago = fecha_aux
                  WHERE identif_pago = reg-codigo_identificacion
                  AND   zstc1 =  rut_aux.
            subrc = sy-subrc.
            PERFORM actualizo_sapbbva_emitidos.
          ELSE.
            IF reg-estado_pago = 'CHEQUE DEVUELTO'  OR reg-estado_pago = 'VALE VISTA REINTEGRAD'.
              SELECT SINGLE * INTO reguh
                 FROM reguh WHERE identif_pago = reg-codigo_identificacion
                            AND   zstc1 =  rut_aux
                            AND ( ind_pago      = 'X' OR
                                  ind_rescatado = 'X' OR
                                  ind_devuelto  = 'X' OR
                                  ind_rechazo   = 'X' ).
              IF sy-subrc <> 0.
                CLEAR tdev.
                MOVE-CORRESPONDING reg TO tdev.
                tdev-estado = 'X'.
* ini Waldo Alarcón - Visionone - 11-05-2020 - Ajustes de salida del reporte
*                    APPEND tdev.
                IF tdev-numero_lote  IN s_lote   AND
                   tdev-fecha_pago   IN s_fecha  AND
                   tdev-cuenta_cargo IN s_cuenta.
                  APPEND tdev.
                ENDIF.
* fin Waldo Alarcón - Visionone - 11-05-2020 - Ajustes de salida del reporte
              ELSE.
                subrc = 1.
                PERFORM actualizo_sapbbva_emitidos.
              ENDIF.
            ELSE.
              IF reg-estado_pago = 'CHEQUE RECHAZADO'.
                SELECT SINGLE * INTO reguh
                  FROM reguh WHERE identif_pago = reg-codigo_identificacion
                              AND  zstc1 =  rut_aux
                AND ( ind_pago = 'X' OR ind_rescatado = 'X' OR ind_devuelto = 'X' OR ind_rechazo = 'X' ).
                IF sy-subrc <> 0.
                  MOVE-CORRESPONDING reg TO trec.
                  APPEND trec.
                ELSE.
                  subrc = 1.
                  PERFORM actualizo_sapbbva_emitidos.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDDO.

  REFRESH tpro.
  correlativo = 0.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 26/12/2019 EY_DES02 ECDK917080 *
  SORT tdev .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 26/12/2019 EY_DES02 ECDK917080 *
  LOOP AT tdev WHERE estado_pago = 'VALE VISTA REINTEGRAD'.
    SELECT SINGLE *
           FROM reguh  WHERE identif_pago = reg-codigo_identificacion.
    IF sy-subrc = 0.
      IF reguh-rzawe = 'V' AND reguh-ind_redepo IS INITIAL.
        correlativo =  correlativo + 1.
        tdev-correl =  correlativo.
        MODIFY tdev  INDEX sy-tabix.
      ENDIF.
    ENDIF.
  ENDLOOP.
*
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  actualizo_reguh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualizo_sapbbva_emitidos.

  IF subrc = 0.
    EXEC SQL.
      update SAPBBVA_EMITIDOS_NOCOBRADOS
        set ESTADO_PROCESO = '1',
            FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
        where CODIGO_IDENTIFICACION = :reg-CODIGO_IDENTIFICACION
        AND   RUT_BENEFICIARIO = :reg-RUT_BENEFICIARIO
        AND   ESTADO_PROCESO   = '0'
        AND   FECHA_RECEPCION  = :reg-fecha_recepcion
    ENDEXEC.
  ELSE.
    EXEC SQL.
      update SAPBBVA_EMITIDOS_NOCOBRADOS
        set ESTADO_PROCESO = '9',
            FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
        where CODIGO_IDENTIFICACION = :reg-CODIGO_IDENTIFICACION
        AND   RUT_BENEFICIARIO = :reg-RUT_BENEFICIARIO
        AND   ESTADO_PROCESO = '0'
        AND   FECHA_RECEPCION = :reg-fecha_recepcion
    ENDEXEC.
  ENDIF.

ENDFORM.                    "actualizo_reguh
*&---------------------------------------------------------------------*
*&      Form  Cuadratura_dev
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cuadratura.

  REFRESH: int_tabla, tdep.

  SORT tdev BY estado_pago  cuenta_cargo numero_lote fecha_pago correl.
  totalbco = 0.
  totaldep = 0.
  LOOP AT tdev.
    AT END OF correl.
      SUM.
      CLEAR int_tabla.
      MOVE tdev-estado_pago  TO int_tabla-estado_pago.
      MOVE tdev-cuenta_cargo TO int_tabla-ctactedev.
      MOVE tdev-numero_lote  TO int_tabla-lotedev.
      MOVE tdev-fecha_pago   TO int_tabla-fechadev.
      MOVE tdev-correl       TO int_tabla-correl.
      int_tabla-montodev = tdev-monto / 10000.
      SELECT SINGLE * FROM zctarechazo WHERE bukrs = bukrs
                                       AND   ctacte_bco = int_tabla-ctactedev
      AND   rzawe_d = ''.
      IF sy-subrc = 0.
        int_tabla-cuentadep = zctarechazo-hkont_dep.
        SELECT * FROM bsis
                 WHERE bukrs = bukrs
                 AND   hkont = zctarechazo-hkont_dep
                 AND   blart = 'ZR'
                 AND   wrbtr EQ int_tabla-montodev  "WAJ 11.05.2020
                 AND   budat IN s_feccon            "WAJ 11.05.2020
                 ORDER BY PRIMARY KEY.
*         monto_aux  = bsis-wrbtr * 100.
*          IF bsis-wrbtr = int_tabla-montodev.
* ini - Waldo Alarcón - Visionone - 11-05-2020
          IF s_feccon[] IS NOT INITIAL.
            READ TABLE tdep WITH KEY estado_pago  = int_tabla-estado_pago
                                     cuenta_cargo = int_tabla-ctactedev
                                     numero_lote  = int_tabla-lotedev
                                     hkont        = bsis-hkont
                                     budat        = bsis-budat
                                     belnr        = bsis-belnr.
            CHECK sy-subrc NE 0.
          ENDIF.
* fin - Waldo Alarcón - Visionone - 11-05-2020

          IF bsis-shkzg = 'H'.
            int_tabla-montopend = int_tabla-montopend + bsis-wrbtr.
          ELSE.
            int_tabla-montopend = int_tabla-montopend - bsis-wrbtr.
          ENDIF.
          tdep-estado_pago = int_tabla-estado_pago.
          tdep-cuenta_cargo = int_tabla-ctactedev.
          tdep-numero_lote = int_tabla-lotedev.
          tdep-fecha_recepcion = int_tabla-fechadev.
          tdep-correl = int_tabla-correl.
          tdep-secuencia = tdep-secuencia + 1.
          tdep-hkont =  bsis-hkont.
          tdep-budat =  bsis-budat.
          tdep-belnr =  bsis-belnr.
          tdep-wrbtr =  bsis-wrbtr.
          tdep-shkzg  = bsis-shkzg.
          tdep-gjahr  = bsis-gjahr.
          tdep-estado = 'X'.
          APPEND tdep.
*          ENDIF.

* ini - Waldo Alarcón - Visionone - 11-05-2020
          CHECK s_feccon[] IS NOT INITIAL.
          EXIT.
* fin - Waldo Alarcón - Visionone - 11-05-2020
        ENDSELECT.
      ENDIF.
      int_tabla-montodif = int_tabla-montodev - int_tabla-montopend.
      IF int_tabla-montodif  = '0.00'.
        int_tabla-sel = ''.
      ENDIF.
      IF int_tabla-sel = 'X'.
        totalbco = totalbco + int_tabla-montodev.
        totaldep = totaldep + int_tabla-montopend.
      ENDIF.
      APPEND int_tabla.
      tdep-secuencia = 0.
    ENDAT.
  ENDLOOP.
*
  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY estado_pago ctactedev lotedev fechadev correl.
  tabla-lines = fill.
  tabla-top_line = 1.

* ini Waldo Alarcón - Visionone - 11-05-2020 - Ajustes de salida del reporte
  CLEAR   gt_outtab.
  REFRESH gt_outtab.
*
  LOOP AT int_tabla.
    MOVE-CORRESPONDING int_tabla TO gt_outtab.
    APPEND gt_outtab.
  ENDLOOP.
*
  REFRESH int_tabla. CLEAR int_tabla.
* fin Waldo Alarcón - Visionone - 11-05-2020 - Ajustes de salida del reporte

ENDFORM.                    "Cuadratura_dev

*&---------------------------------------------------------------------*
*&      Form  confirma_contabilizacion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM confirma_contabilizacion.
  DATA : lv_borra TYPE c.
  DATA:largo_rut TYPE i. "HCD 20200615
*
  REFRESH int_tabla. CLEAR int_tabla.
  LOOP AT gt_outtab."  WHERE sel EQ 'X'.
    MOVE-CORRESPONDING gt_outtab TO int_tabla.
    APPEND int_tabla.
  ENDLOOP.

  SELECT *  INTO CORRESPONDING FIELDS OF TABLE tcuenta
          FROM zctarechazo WHERE bukrs   = bukrs
                           AND   rzawe_d = ''.
  SORT tcuenta BY bukrs rzawe hkont_orig.
  LOOP AT int_tabla WHERE sel <> 'X'.
    LOOP AT tdev WHERE estado_pago  = int_tabla-estado_pago
                 AND   cuenta_cargo = int_tabla-ctactedev
                 AND   numero_lote  = int_tabla-lotedev
                 AND   fecha_pago   = int_tabla-fechadev
                 AND   correl       = int_tabla-correl.
      tdev-estado = ''.
      MODIFY  tdev.
    ENDLOOP.

    LOOP AT tdep  WHERE estado_pago     = int_tabla-estado_pago
                  AND   cuenta_cargo    = int_tabla-ctactedev
                  AND   numero_lote     = int_tabla-lotedev
                  AND   fecha_recepcion = int_tabla-fechadev
                  AND   correl          = int_tabla-correl.
      tdep-estado = ''.
      MODIFY tdep.
    ENDLOOP.
  ENDLOOP.

  DELETE tdev WHERE estado <> 'X'.
  DELETE tdep WHERE estado <> 'X'.

  LEAVE TO LIST-PROCESSING .
  REFRESH tab.
  MOVE 'CANCL' TO tab-fcode.
  APPEND tab.
  MOVE 'ACTUAL' TO tab-fcode.
  APPEND tab.
  MOVE 'CONT' TO tab-fcode.
  APPEND tab.
*
  MOVE 'SELECT' TO tab-fcode.
  APPEND tab.
  MOVE 'DESELECT' TO tab-fcode.
  APPEND tab.

  SET  PF-STATUS 'ZFITR011' EXCLUDING tab.

  WRITE: /, 'Se Generaron los siguietes Voucher por Pagos Devueltos y rescatados BBVA'.
  PERFORM contabilizo  TABLES tdev USING 'Pago Dev/Rescatdo BBVA' '1'.

  WRITE: /, 'Se Generaron los siguietes Voucher por Pagos Rechazo BBVA'.
  PERFORM contabilizo  TABLES trec USING 'Pago Rechazo BBVA' '2'.
  largo_rut  = strlen( tpro-rut_beneficiario ) - 1."HCD 20200615

  LOOP AT tpro.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = tpro-rut_beneficiario+0(largo_rut)
      IMPORTING
        output = rut_aux.

    CONCATENATE rut_aux '-'  tpro-rut_beneficiario+largo_rut(1)  INTO rut_aux.

    IF NOT tpro-fecha_estado IS INITIAL.
      CONCATENATE tpro-fecha_estado+0(4) tpro-fecha_estado+5(2) tpro-fecha_estado+8(2) INTO fecha_aux.
    ELSE.
      CONCATENATE tpro-fecha_recepcion+0(4) tpro-fecha_recepcion+5(2) tpro-fecha_recepcion+8(2) INTO fecha_aux.
    ENDIF.
    IF tpro-estado_pago = 'CHEQUE DEVUELTO'.
      UPDATE reguh
      SET ind_devuelto = 'X'
          fecha_devuelto = fecha_aux
          belnr_dev     = tpro-belnr_dev
          gjahr_dev     = tpro-gjahr_dev
      WHERE identif_pago = tpro-codigo_identificacion
      AND   zstc1 =  rut_aux.
    ELSE.
*      IF tpro-estado_pago = 'CHEQUE RESCATADO'.
      IF tpro-estado_pago = 'VALE VISTA REINTEGRAD'.
        UPDATE reguh
        SET ind_rescatado = 'X'
            fecha_rescatado = fecha_aux
            belnr_dev     = tpro-belnr_dev
            gjahr_dev     = tpro-gjahr_dev
        WHERE identif_pago = tpro-codigo_identificacion
        AND   zstc1 =  rut_aux.
      ELSE.
        IF tpro-estado_pago = 'CHEQUE RECHAZADO'.
          UPDATE reguh
          SET ind_rechazo = 'X'
              fecha_rechazo = fecha_aux
              belnr_dev     = tpro-belnr_dev
              gjahr_dev     = tpro-gjahr_dev
          WHERE identif_pago = tpro-codigo_identificacion
           AND   zstc1 =  rut_aux.
        ENDIF.
      ENDIF.
    ENDIF.

    EXEC SQL.
      update SAPBBVA_EMITIDOS_NOCOBRADOS
        set ESTADO_PROCESO = '1',
            FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
        where CODIGO_IDENTIFICACION = :tpro-CODIGO_IDENTIFICACION
        AND   RUT_BENEFICIARIO = :tpro-RUT_BENEFICIARIO
        AND   ESTADO_PROCESO = '0'
        AND   FECHA_RECEPCION = :tpro-fecha_recepcion
    ENDEXEC.
*
  ENDLOOP.
*
  LOOP AT tpro WHERE belnr_dev IS NOT INITIAL.
    lv_borra = 'X'.
    CHECK tpro-correl    IS NOT INITIAL.
    READ TABLE gt_outtab INTO gs_outtab
                        WITH KEY estado_pago  = tpro-estado_pago
                                 correl       = tpro-correl.
    IF sy-subrc EQ 0.
      DELETE gt_outtab INDEX sy-tabix.
    ENDIF.
  ENDLOOP.
  IF lv_borra IS NOT INITIAL.
    DELETE gt_outtab WHERE sel EQ 'X'.
  ENDIF.
*
  CALL METHOD g_grid1->refresh_table_display.
ENDFORM.                    "confirma_contabilizacion
*&---------------------------------------------------------------------*
*&      Form  CONTABILIZO_DEVOLUCIONes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM contabilizo   TABLES tdat LIKE reg1x USING texto LIKE bkpf-bktxt
                                                proceso.
  DATA: newbs  LIKE bseg-bschl,
        cuenta LIKE bseg-hkont.
  DATA:largo_rut TYPE i. "HCD 20200615
  nuevo   = 'S'.
  lineas  = 0.
  tlineas = 0.
  total   = 0.

  REFRESH: bdcdata, itab.

  SORT tdat BY cuenta_cargo  fecha_estado DESCENDING codigo_identificacion.

  CONCATENATE sy-datum sy-uzeit INTO asignacion.

  LOOP AT tdat.
    IF cuenta_cargo <> tdat-cuenta_cargo.
      IF  NOT  cuenta_cargo IS INITIAL AND lineas > 0.
        PERFORM cierro_voucher USING proceso texto.
      ENDIF.
      lineas_dep = 0.
      LOOP AT tdep WHERE cuenta_cargo = tdat-cuenta_cargo.
        lineas_dep = lineas_dep + 1.
      ENDLOOP.
    ENDIF.

    cuenta_cargo = tdat-cuenta_cargo.
    largo_rut  = strlen( tdat-rut_beneficiario ) - 1."HCD 20200615
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = tdat-rut_beneficiario+0(largo_rut)
      IMPORTING
        output = rut_aux.

    CONCATENATE rut_aux '-'  tdat-rut_beneficiario+largo_rut(1) INTO rut_aux.


    SELECT  SINGLE * FROM reguh WHERE identif_pago  = tdat-codigo_identificacion
    AND   zstc1 =  rut_aux.

    largo = strlen( reguh-ubhkt ) - 1.
    reguh-ubhkt+largo(1) = '1'.
*ResQ Comment:Correction not required as aggregation is used 26/12/2019 EY_DES02 ECDK917080*
    SELECT  COUNT(*) INTO filas   FROM  regup WHERE laufd = reguh-laufd
                        AND   laufi = reguh-laufi
                        AND   xvorl = reguh-xvorl
                        AND   zbukr = reguh-zbukr
                        AND   lifnr = reguh-lifnr
                        AND   kunnr = reguh-kunnr
                        AND   empfg = reguh-empfg
                        AND   vblnr = reguh-vblnr.

    tlineas = lineas + filas + lineas_dep.

    IF tlineas > 997.
      WRITE  total  CURRENCY 'CLP'  TO valor.
      PERFORM bdc_field       USING 'RF05A-NEWBS'      '40'.
      IF proceso = '1'.
        PERFORM bdc_field       USING 'RF05A-NEWKO'    '9000000008'.
        total_des  = total.
      ELSE.
        PERFORM bdc_field       USING 'RF05A-NEWKO'    reguh-ubhkt.
        total_des  = 0.
      ENDIF.
      PERFORM bdc_dynpro      USING 'SAPMF05A'      '0300'.
      PERFORM bdc_field       USING 'BDC_CURSOR'    'BSEG-SGTXT'.
      PERFORM bdc_field       USING 'BDC_OKCODE'    '=BU'.
      PERFORM bdc_field       USING 'BSEG-WRBTR'     valor.
      PERFORM bdc_field       USING 'BSEG-VALUT'     fecha1.
      PERFORM bdc_field       USING 'BSEG-SGTXT'     texto.
      PERFORM bdc_field       USING 'DKACB-FMORE'    ' '. "V1 - WAJ

* ini "V1 - WAJ
*      perform bdc_dynpro      using 'SAPLKACB'        '0002'.
*      perform bdc_field       using 'BDC_CURSOR'      'COBL-PRCTR'.
*      perform bdc_field       using 'COBL-ZZMOT_EMIS' bseg-zzmot_emis.
*      perform bdc_field       using 'BDC_OKCODE'      '=ENTE'.
* fin "V1 - WAJ

      CALL TRANSACTION 'F-02' USING  bdcdata
                                      MODE   p_mode
                                      UPDATE 'S'
                                      MESSAGES INTO itab.
      CLEAR belnr.
      LOOP AT itab.
        IF itab-msgid = 'F5' AND     itab-msgnr = '312'.
          belnr = itab-msgv1.
          gjahr = fecha1+4(4).
          WRITE: /'Se genero Voucher Numero  : ', belnr , ' Año :' ,  gjahr.
        ELSE.
          CALL FUNCTION 'MESSAGE_TEXT_BUILD'
            EXPORTING
              msgid               = itab-msgid
              msgnr               = itab-msgnr
              msgv1               = itab-msgv1
              msgv2               = itab-msgv2
              msgv3               = itab-msgv3
              msgv4               = itab-msgv4
            IMPORTING
              message_text_output = mensaje.
          WRITE: /'Errro Al contabilizar : ', mensaje.
        ENDIF.

      ENDLOOP.
      IF NOT belnr IS INITIAL.
        LOOP AT tpro WHERE belnr_dev IS INITIAL.
          tpro-belnr_dev = belnr.
          tpro-gjahr_dev = gjahr.
          MODIFY tpro.
        ENDLOOP.
      ELSE.
        LOOP AT tpro WHERE belnr_dev IS INITIAL.
          DELETE  tpro.
        ENDLOOP.
      ENDIF.

      nuevo  = 'S'.
      lineas = 0.
      total  = total_des. "0 04-06-2020 - Waldo Alarcón - Visionone.
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
*and vblnr = reguh-vblnr.
                          AND vblnr = reguh-vblnr ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 26/12/2019 EY_DES02 ECDK917080 *

      SELECT SINGLE  * FROM bseg WHERE bukrs  = regup-bukrs
                             AND  belnr = regup-belnr
                             AND  gjahr = regup-gjahr
      AND  buzei = regup-buzei.


      IF  regup-shkzg = 'H'.
        newbs = '31'.
      ELSE.
        newbs = '21'.
      ENDIF.

      cuenta = reguh-lifnr.


      IF tdat-estado_pago = 'VALE VISTA REINTEGRAD' OR tdat-estado_pago = 'CHEQUE RECHAZADO'.
        READ TABLE tcuenta WITH KEY bukrs = bukrs
                                    rzawe =  reguh-rzawe
                                    hkont_orig = '1011110001'.
        IF sy-subrc <> 0.
          MESSAGE e016(z1) WITH 'Cta no definida Para Soc./Cta. Origen' bukrs '1011110001'.
        ENDIF.
        tcuenta-hkont_dest = bseg-hkont.
      ELSE.
        IF tdat-estado_pago = 'CHEQUE DEVUELTO' AND
         ( bseg-zzmot_emis = 'SUBHIJMEN' OR bseg-zzmot_emis = 'SUBMATERNA' OR
          bseg-zzmot_emis = 'SUBNOSIL' OR bseg-zzmot_emis = 'SUBPOSTNAT' OR
          bseg-zzmot_emis = 'SUBPOSTPAR' OR bseg-zzmot_emis = 'SUBPRENAT' ).
          CONCATENATE  reguh-ubhkt+0(9) '7' INTO  tcuenta-hkont_dest.
          cuenta = tcuenta-hkont_dest.
          IF  regup-shkzg = 'H'.
            newbs = '50'.
          ELSE.
            newbs = '40'.
          ENDIF.

        ELSE.
          READ TABLE tcuenta WITH KEY bukrs = bukrs
                                      rzawe =  reguh-rzawe
                                      hkont_orig = bseg-hkont.
          IF sy-subrc <> 0.
            MESSAGE e016(z1) WITH 'Cta no definida Para Soc./Cta. Origen' bukrs bseg-hkont.
          ENDIF.
        ENDIF.
      ENDIF.

      IF nuevo = 'S'.
        IF tdat-fecha_estado IS INITIAL.
          CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+0(4) INTO fecha1.
        ELSE.
          CONCATENATE  tdat-fecha_estado+8(2) tdat-fecha_estado+5(2) tdat-fecha_estado+0(4) INTO fecha1.
        ENDIF.
        PERFORM bdc_dynpro      USING 'SAPMF05A'        '0100'.
        PERFORM bdc_field       USING 'BDC_CURSOR'      'RF05A-NEWKO'.
        PERFORM bdc_field       USING 'BDC_OKCODE'      '/00'.
        PERFORM bdc_field       USING 'BKPF-BLDAT'      fecha1.
        PERFORM bdc_field       USING 'BKPF-BLART'      'XG'.
*                                      'SA'."Mod 11.06.2014 Seidor Crystalis

        PERFORM bdc_field       USING 'BKPF-BUKRS'      bukrs.
        PERFORM bdc_field       USING 'BKPF-BUDAT'      fecha1.
        PERFORM bdc_field       USING 'BKPF-WAERS'      'CLP'.
        PERFORM bdc_field       USING 'BKPF-BKTXT'      texto.
        IF total_des > 0.
          WRITE  total_des  CURRENCY 'CLP'  TO valor.
          PERFORM bdc_field       USING 'RF05A-NEWBS'    '50'.
          PERFORM bdc_field       USING 'RF05A-NEWKO'    '9000000008'.

          PERFORM bdc_dynpro      USING 'SAPMF05A'       '0300'.
          PERFORM bdc_field       USING 'BDC_CURSOR'     'BSEG-SGTXT'.
          PERFORM bdc_field       USING 'BDC_OKCODE'     '/00'.
          PERFORM bdc_field       USING 'BSEG-WRBTR'     valor.
          PERFORM bdc_field       USING 'BSEG-SGTXT'     texto.
          PERFORM bdc_field       USING 'DKACB-FMORE'    ' '.  "V1 - WAJ
          lineas = lineas + 1.
          total = total + total_des.
          CLEAR total_des.
        ENDIF.

        PERFORM bdc_field       USING 'RF05A-NEWBS'       newbs.
        PERFORM bdc_field       USING 'RF05A-NEWKO'       cuenta .
        nuevo = 'N'.
      ELSE.
        PERFORM bdc_field       USING 'RF05A-NEWBS'       newbs.
        PERFORM bdc_field       USING 'RF05A-NEWKO'       cuenta .
      ENDIF.

      WRITE  regup-dmbtr CURRENCY 'CLP'  TO valor.

      IF tdat-fecha_estado IS INITIAL.
        CONCATENATE  tdat-fecha_recepcion+8(2) tdat-fecha_recepcion+5(2) tdat-fecha_recepcion+0(4) INTO fecha.
      ELSE.
        CONCATENATE  tdat-fecha_estado+8(2) tdat-fecha_estado+5(2) tdat-fecha_estado+0(4) INTO fecha.
      ENDIF.

*      IF tdat-estado_pago = 'CHEQUE RESCATADO' OR tdat-estado_pago = 'CHEQUE RECHAZADO'.

      IF newbs = '21' OR newbs = '31'.
        PERFORM bdc_dynpro      USING 'SAPMF05A'           '0302'.
        PERFORM bdc_field       USING 'BDC_CURSOR'         'BSEG-ZLSCH'.
        PERFORM bdc_field       USING 'BDC_OKCODE'         '=ZK'.
        PERFORM bdc_field       USING 'BSEG-HKONT'         tcuenta-hkont_dest.
        PERFORM bdc_field       USING 'BSEG-WRBTR'         valor.
        PERFORM bdc_field       USING 'BSEG-MWSKZ'         ''.
        PERFORM bdc_field       USING 'BSEG-ZTERM'         'ZC01'.
        PERFORM bdc_field       USING 'BSEG-ZFBDT'         fecha.
        PERFORM bdc_field       USING 'BSEG-ZLSCH'         'C'.
        PERFORM bdc_field       USING 'BSEG-ZUONR'         reguh-identif_pago.
        PERFORM bdc_field       USING 'BSEG-SGTXT'         texto.
        PERFORM bdc_field       USING 'BSEG-ZZMOT_EMIS'    bseg-zzmot_emis.
        PERFORM bdc_field       USING 'BSEG-ZZ_AGENCIA'    bseg-zz_agencia.

        SELECT SINGLE * FROM lfb1 WHERE lifnr = reguh-lifnr AND
        bukrs = bukrs.

        IF sy-subrc = 0.
          SELECT COUNT(*) INTO cant_imp FROM lfbw
                                      WHERE lifnr = reguh-lifnr
          AND   bukrs = bukrs.
          IF cant_imp > 0.
            PERFORM bdc_dynpro USING  'SAPLFWTD'                '0100'.
            PERFORM bdc_field  USING  'BDC_CURSOR'              'WITH_ITEM-WT_WITHCD(01)'.
            PERFORM bdc_field  USING 'BDC_OKCODE'               '/00'.
            PERFORM bdc_field  USING  'WITH_ITEM-WT_WITHCD(01)' '  '.
          ENDIF.
        ENDIF.

        PERFORM bdc_dynpro      USING 'SAPMF05A'                '0332'.
        PERFORM bdc_field       USING 'BDC_CURSOR'              'RF05A-NEWKO'.
        PERFORM bdc_field       USING 'BDC_OKCODE'              '/00'.
        PERFORM bdc_field       USING 'BSEG-HBKID'              tcuenta-hbkid_dest.
        PERFORM bdc_field       USING 'BSEG-HKTID'              tcuenta-hktid_dest.
        PERFORM bdc_field       USING 'BSEG-XREF1'              bseg-xref1.
        PERFORM bdc_field       USING 'BSEG-XREF2'              reguh-vblnr.
        PERFORM bdc_field       USING 'BSEG-XREF3'              regup-zuonr.
      ELSE.
        PERFORM bdc_dynpro      USING 'SAPMF05A'                '0300'.
        PERFORM bdc_field       USING 'BDC_CURSOR'              'BSEG-WRBTR'.
        PERFORM bdc_field       USING 'BDC_OKCODE'              '=ZK'.
        PERFORM bdc_field       USING 'BSEG-WRBTR'              valor.
        PERFORM bdc_field       USING 'BSEG-ZUONR'              reguh-identif_pago.
        PERFORM bdc_field       USING 'BSEG-VALUT'              fecha.
        PERFORM bdc_field       USING 'DKACB-FMORE'             'X'.

        PERFORM bdc_dynpro      USING 'SAPLKACB'                '0002'.
        PERFORM bdc_field       USING 'BDC_OKCODE'              '=ENTE'.
        PERFORM bdc_field       USING 'BDC_CURSOR'              'COBL-ZZRUT_TERC'.
        PERFORM bdc_field       USING 'COBL-ZZMOT_EMIS'         bseg-zzmot_emis.
        PERFORM bdc_field       USING 'COBL-ZZRUT_TERC'         reguh-lifnr.
        PERFORM bdc_field       USING 'COBL-ZZ_AGENCIA'         bseg-zz_agencia.

        PERFORM bdc_dynpro      USING 'SAPMF05A'                '0330'.
        PERFORM bdc_field       USING 'BDC_CURSOR'              'RF05A-NEWKO'.
        PERFORM bdc_field       USING 'BDC_OKCODE'              '/00'.
        PERFORM bdc_field       USING 'BSEG-XREF2'              reguh-vblnr.
        PERFORM bdc_field       USING 'BSEG-XREF3'              regup-zuonr.

      ENDIF.
      lineas = lineas + 1.
      total = total + regup-dmbtr.
    ENDSELECT.

    CLEAR tpro.
    tpro-codigo_identificacion = tdat-codigo_identificacion.
    tpro-rut_beneficiario      = tdat-rut_beneficiario.
    tpro-fecha_recepcion       = tdat-fecha_recepcion.
    tpro-fecha_estado          = tdat-fecha_estado.
    tpro-estado_pago           = tdat-estado_pago.
    tpro-correl                = tdat-correl.
    APPEND tpro.
  ENDLOOP.

  IF lineas > 0.
    PERFORM cierro_voucher USING proceso texto.
  ENDIF.

ENDFORM.                    "contabilizar
*&---------------------------------------------------------------------*
*&      Form  CIERRO_VOUCHER
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*      -->P_PROCESO  text
*----------------------------------------------------------------------*
FORM cierro_voucher  USING    p_proceso p_texto.
  IF  p_proceso = '1'.
    LOOP AT tdep WHERE cuenta_cargo = cuenta_cargo.
      WRITE  tdep-wrbtr  CURRENCY 'CLP'  TO valor.
      PERFORM bdc_field       USING 'RF05A-NEWBS'     '40'.
      PERFORM bdc_field       USING 'RF05A-NEWKO'     tdep-hkont.

      PERFORM bdc_dynpro      USING 'SAPMF05A'        '0300'.
      PERFORM bdc_field       USING 'BDC_CURSOR'      'BSEG-SGTXT'.
      PERFORM bdc_field       USING 'BDC_OKCODE'      '/00'.
      PERFORM bdc_field       USING 'BSEG-WRBTR'      valor.
      SELECT SINGLE zuonr INTO asignacion
                          FROM bseg
                          WHERE bukrs = bukrs
                          AND   belnr = tdep-belnr
                          AND   gjahr = tdep-gjahr
                          AND   bschl = '50'.
      PERFORM bdc_field       USING 'BSEG-ZUONR'      asignacion.
      PERFORM bdc_field       USING 'BSEG-SGTXT'      p_texto.
      PERFORM bdc_field       USING 'DKACB-FMORE'    ' '.
    ENDLOOP.
    PERFORM bdc_dynpro      USING 'SAPMF05A'          '0300'.
    PERFORM bdc_field       USING 'BDC_CURSOR'        'BSEG-SGTXT'.
    PERFORM bdc_field       USING 'BDC_OKCODE'        '=BU'.
    PERFORM bdc_field       USING 'DKACB-FMORE'       ' '.

*    PERFORM bdc_dynpro      USING 'SAPLKACB'          '0002'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'        'COBL-PRCTR'.
*    PERFORM bdc_field       USING 'COBL-ZZMOT_EMIS'   bseg-zzmot_emis.
*    PERFORM bdc_field       USING 'BDC_OKCODE'        '=ENTE'.
  ELSE.
    WRITE  total  CURRENCY 'CLP'  TO valor.
    PERFORM bdc_field       USING 'RF05A-NEWBS'      '40'.
    PERFORM bdc_field       USING 'RF05A-NEWKO'      reguh-ubhkt.

    PERFORM bdc_dynpro      USING 'SAPMF05A'         '0300'.
    PERFORM bdc_field       USING 'BDC_CURSOR'       'BSEG-SGTXT'.
    PERFORM bdc_field       USING 'BDC_OKCODE'       '=BU'.
    PERFORM bdc_field       USING 'BSEG-WRBTR'       valor.
    PERFORM bdc_field       USING 'BSEG-VALUT'       fecha1.
    PERFORM bdc_field       USING 'BSEG-SGTXT'       p_texto.
    PERFORM bdc_field       USING 'DKACB-FMORE'      ' '.

*    PERFORM bdc_dynpro      USING 'SAPLKACB'         '0002'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'       'COBL-PRCTR'.
*    PERFORM bdc_field       USING 'COBL-ZZMOT_EMIS'  bseg-zzmot_emis.
*    PERFORM bdc_field       USING 'BDC_OKCODE'       '=ENTE'.
  ENDIF.

  CALL TRANSACTION 'F-02' USING  bdcdata
                                  MODE   p_mode
                                  UPDATE 'S'
                                  MESSAGES INTO itab.
  CLEAR belnr.
  LOOP AT itab.
    IF itab-msgid = 'F5' AND     itab-msgnr = '312'.
      belnr = itab-msgv1.
      gjahr = fecha1+4(4).
      WRITE: /'Se genero Voucher Numero  : ', belnr , ' Año :' ,  gjahr.
    ELSE.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = itab-msgid
          msgnr               = itab-msgnr
          msgv1               = itab-msgv1
          msgv2               = itab-msgv2
          msgv3               = itab-msgv3
          msgv4               = itab-msgv4
        IMPORTING
          message_text_output = mensaje.
      WRITE: /'Error al contabilizar : ', mensaje.
    ENDIF.
  ENDLOOP.

  IF NOT belnr IS INITIAL.
    LOOP AT tpro WHERE belnr_dev IS INITIAL.
      tpro-belnr_dev = belnr.
      tpro-gjahr_dev = gjahr.
      MODIFY tpro.
    ENDLOOP.
  ELSE.
    LOOP AT tpro WHERE belnr_dev IS INITIAL.
      DELETE  tpro.
    ENDLOOP.
  ENDIF.

  nuevo = 'S'.
  lineas = 0.
  total = 0.
  REFRESH: bdcdata, itab.
ENDFORM.                    " CIERRO_VOUCHER
*&---------------------------------------------------------------------*
*&      Form  AJUSTA_CUENTA
*&---------------------------------------------------------------------*
FORM ajusta_cuenta .
  REFRESH s_cuenta[].
  LOOP AT s_ctacte.
    IF s_ctacte-low IS NOT INITIAL.
      APPEND s_ctacte TO s_cuenta.
* variable de 10 caracteres
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = s_ctacte-low
        IMPORTING
          output = gv_char10.
      s_ctacte-low = gv_char10.
      IF s_ctacte-high IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = s_ctacte-high
          IMPORTING
            output = gv_char10.
        s_ctacte-high = gv_char10.
      ENDIF.
      APPEND s_ctacte TO s_cuenta.
* variable de 18 caracteres
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = s_ctacte-low
        IMPORTING
          output = gv_char18.
      s_ctacte-low = gv_char18.
      IF s_cuenta-high IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = s_ctacte-high
          IMPORTING
            output = gv_char18.
        s_ctacte-high = gv_char18.
      ENDIF.
      APPEND s_ctacte TO s_cuenta.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AJUSTA_FECHA
*&---------------------------------------------------------------------*
FORM ajusta_fecha .
  REFRESH s_fecha[].
  LOOP AT s_fecpag.
    IF s_fecpag-low IS NOT INITIAL.
      s_fecha-sign   = s_fecpag-sign.
      s_fecha-option = s_fecpag-option.
* variable de 10 caracteres
      CONCATENATE s_fecpag-low(4) s_fecpag-low+4(2) s_fecpag-low+6(2)
                  INTO s_fecha-low SEPARATED BY '-'.
      IF s_fecpag-high IS NOT INITIAL.
        CONCATENATE s_fecpag-high(4) s_fecpag-high+4(2) s_fecpag-high+6(2)
                    INTO s_fecha-high SEPARATED BY '-'.
      ENDIF.
      APPEND s_fecha.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AJUSTA_LOTE
*&---------------------------------------------------------------------*
FORM ajusta_lote .
  REFRESH s_lote.
  LOOP AT s_numlot.
    IF s_numlot-low IS NOT INITIAL.
      APPEND s_numlot TO s_lote.
* variable de 10 caracteres
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = s_numlot-low
        IMPORTING
          output = s_lote-low.
      IF s_numlot-high IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = s_numlot-high
          IMPORTING
            output = s_lote-high.
      ENDIF.
      s_lote-sign   = s_numlot-sign.
      s_lote-option = s_numlot-option.
      APPEND s_lote.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_MONTODEV
*&---------------------------------------------------------------------*
FORM muestra_montodev USING ls_outtab TYPE ty_outtab.
*
  totalsel = 0.
  CLEAR   int_tabla2.
  REFRESH int_tabla2.
  LOOP AT tdev WHERE estado_pago  EQ ls_outtab-estado_pago
               AND   cuenta_cargo EQ ls_outtab-ctactedev
               AND   numero_lote  EQ ls_outtab-lotedev
               AND   fecha_pago   EQ ls_outtab-fechadev
               AND   correl       EQ ls_outtab-correl.

    int_tabla2-sel          = tdev-estado.
    int_tabla2-identif_pago = tdev-codigo_identificacion.
    int_tabla2-rut          = tdev-rut_emisor.
    int_tabla2-nombre       = tdev-nombre_beneficiario.
    int_tabla2-estado_pago  = tdev-estado_pago.
    int_tabla2-cuentadep    = ''.
    int_tabla2-fechacon     = ''.
    int_tabla2-monto        =  tdev-monto / 10000.
    IF int_tabla2-sel = 'X'.
      totalsel  = totalsel  + int_tabla2-monto.
    ENDIF.
    int_tabla2-correl = tdev-correl.
    APPEND int_tabla2.
  ENDLOOP.
*
  DESCRIBE TABLE int_tabla2 LINES fill.
  tabla3-lines    = fill.
  tabla3-top_line = 1.
  LOOP AT tabla3-cols INTO cols .
    IF sy-tabix = 4 OR
       sy-tabix = 5 OR
       sy-tabix = 6 OR
       sy-tabix = 7.
      cols-invisible = '1'.
    ELSE.
      cols-invisible = '0'.
    ENDIF.
    MODIFY tabla3-cols FROM cols INDEX sy-tabix.
  ENDLOOP.
  SORT int_tabla2 BY identif_pago.
  sw_dato = '1'.
  titulo = 'SELECCIONA PARTIDAS BANCO'.
  CALL SCREEN 250 STARTING AT 25 03 ENDING AT 130 25.
*
  PERFORM ajusta_tabla USING ls_outtab.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_MONTOPEND
*&---------------------------------------------------------------------*
FORM muestra_montopend  USING ls_outtab  TYPE ty_outtab.
*
  totalsel = 0.
  CLEAR   int_tabla2.
  REFRESH int_tabla2.
  tdep-cuenta_cargo = ls_outtab-ctactedev.
  tdep-secuencia    = tdep-secuencia + 1.
  LOOP AT tdep  WHERE estado_pago    EQ ls_outtab-estado_pago
                AND  cuenta_cargo    EQ ls_outtab-ctactedev
                AND numero_lote      EQ ls_outtab-lotedev
                AND fecha_recepcion  EQ ls_outtab-fechadev
                AND correl           EQ ls_outtab-correl.
    int_tabla2-sel          = ''.
    int_tabla2-identif_pago = ''.
    int_tabla2-rut          = ''.
    int_tabla2-nombre       = ''.
    int_tabla2-cuentadep    = tdep-hkont.
    int_tabla2-belnr        = tdep-belnr.
    int_tabla2-fechacon     = tdep-budat.
    int_tabla2-sec          = tdep-secuencia.
    int_tabla2-monto        = tdep-wrbtr .
    int_tabla2-correl       = tdep-correl.
    IF int_tabla2-sel EQ 'X'.
      totalsel  = totalsel  + int_tabla2-monto.
    ENDIF.
    APPEND int_tabla2.
  ENDLOOP.
*
  DESCRIBE TABLE int_tabla2 LINES fill.
  tabla3-lines = fill.
  tabla3-top_line = 1.
  LOOP AT tabla3-cols INTO cols .
    IF sy-tabix = 1   OR
        sy-tabix = 2 OR
        sy-tabix = 3 .
      cols-invisible = '1'.
    ELSE.
      cols-invisible = '0'.
    ENDIF.
    MODIFY tabla3-cols FROM cols INDEX sy-tabix.
  ENDLOOP.
*
  SORT int_tabla2 BY cuentadep fechacon sec.
  sw_dato = '2'.
  titulo = 'SELECCIONA PARTIDAS DEPOSITO'.
  CALL SCREEN 250 STARTING AT 25 03 ENDING AT 130 25.
*
  PERFORM ajusta_tabla USING ls_outtab.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AJUSTA_TABLA
*&---------------------------------------------------------------------*
FORM ajusta_tabla USING ls_outtab  TYPE ty_outtab.
*
  totalbco = 0.
  totaldep = 0.
  SORT tdev BY estado_pago cuenta_cargo numero_lote fecha_pago correl.
*
*  CLEAR : ls_outtab-montodev, ls_outtab-montopend.
*  LOOP AT int_tabla2.
*    AT END OF correl.
*      LOOP AT tdev WHERE correl EQ int_tabla2-correl AND
*                         estado EQ 'X'.
*        ls_outtab-montodev = ls_outtab-montodev + tdev-monto / 10000.
*      ENDLOOP.
**
*      LOOP AT tdep WHERE correl EQ int_tabla2-correl AND
*                         estado EQ 'X'.
*        IF tdep-shkzg = 'H'.
*          ls_outtab-montopend = ls_outtab-montopend + tdep-wrbtr.
*        ELSE.
*          ls_outtab-montopend = ls_outtab-montopend - tdep-wrbtr.
*        ENDIF.
*      ENDLOOP.
*      ls_outtab-montodif = ls_outtab-montodev - ls_outtab-montopend.
*      modify gt_outtab from ls_outtab index int_tabla2-correl.
*    ENDAT.
*  ENDLOOP.
*
  REFRESH : int_tabla, gt_outtab.
  CLEAR   : int_tabla, gt_outtab.

  LOOP AT tdev.
    IF tdev-estado = 'X'.
      int_tabla-montodev = int_tabla-montodev + tdev-monto / 10000.
    ENDIF.
*
    AT END OF correl.
      MOVE tdev-estado_pago  TO int_tabla-estado_pago.
      MOVE tdev-cuenta_cargo TO int_tabla-ctactedev.
      MOVE tdev-numero_lote  TO int_tabla-lotedev.
      MOVE tdev-fecha_pago   TO int_tabla-fechadev.
      MOVE tdev-correl       TO int_tabla-correl.
      SELECT SINGLE * FROM zctarechazo WHERE bukrs      = bukrs
                                         AND ctacte_bco = int_tabla-ctactedev.
      IF sy-subrc = 0.
        int_tabla-cuentadep = zctarechazo-hkont_dep.
        LOOP AT tdep     WHERE estado_pago     = int_tabla-estado_pago
                         AND   cuenta_cargo    = int_tabla-ctactedev
                         AND   numero_lote     = int_tabla-lotedev
                         AND   fecha_recepcion = int_tabla-fechadev
                         AND   correl          = int_tabla-correl
                         AND   estado = 'X'.
          IF tdep-shkzg = 'H'.
            int_tabla-montopend = int_tabla-montopend + tdep-wrbtr.
          ELSE.
            int_tabla-montopend = int_tabla-montopend - tdep-wrbtr.
          ENDIF.
        ENDLOOP.
      ENDIF.
      int_tabla-montodif = int_tabla-montodev - int_tabla-montopend.
      APPEND int_tabla.
*
      MOVE-CORRESPONDING int_tabla TO gt_outtab.
      APPEND gt_outtab.
*
      CLEAR int_tabla.
    ENDAT.
  ENDLOOP.
  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY estado_pago ctactedev lotedev fechadev correl.
  tabla-lines    = fill.
  tabla-top_line = 1.

  REFRESH : int_tabla.
ENDFORM.
