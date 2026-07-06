*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <27-12-2019> *
*& Transport Number: < ECDK916992 > *
*&---------------------------------------------------------------------*
REPORT zfitr011 NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132.

TABLES: reguh,
        regup,
        bseg,
        lfb1,
        zctarechazo.

DATA p1(01) TYPE c VALUE '0'.
DATA oref TYPE REF TO cx_root.
DATA observacion(100).
DATA fecha_aux(08).
DATA cta_pagar LIKE bseg-hkont VALUE '2011730046'.
DATA: fec_estado LIKE sy-datum.

DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.

DATA: BEGIN OF reg,
  numero_empresa(10) TYPE c,
  rut_emisor(9),
  cuenta_cargo(10) TYPE n,
  nombre_beneficiario(50),
  rut_beneficiario(9),
  monto(15) TYPE n,
  numero_cheque(9),
  estado_pago(21),
  centro_pago(4) TYPE n,
  fecha_recepcion(10),
  numero_lote(3) TYPE n,
  codigo_identificacion(15),
  fecha_proceso LIKE sy-datum,
  fecha_pago(10),
  fecha_estado(10),
 END OF reg.

TYPES: BEGIN OF reg1,
  codigo_identificacion(15),
  numero_empresa(10) TYPE c,
  rut_emisor(9),
  cuenta_cargo(10) TYPE n,
  nombre_beneficiario(50),
  rut_beneficiario(9),
  monto(15) TYPE n,
  numero_cheque(9),
  estado_pago(21),
  centro_pago(4) TYPE n,
  fecha_recepcion(10),
  fecha_estado(10),
  numero_lote(3) TYPE n,
 END OF reg1.

DATA reg1x TYPE STANDARD TABLE OF reg1.

DATA:  tdev TYPE  reg1 OCCURS 0 WITH HEADER LINE.
DATA:  trec TYPE  reg1 OCCURS 0 WITH HEADER LINE.
DATA:  tres TYPE  reg1 OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF tpro OCCURS 0,
  codigo_identificacion(15),
  estado_pago(21),
  fecha_recepcion(10),
  fecha_estado(10),
  belnr_dev  LIKE reguh-belnr_dev,
  gjahr_dev  LIKE reguh-gjahr_dev,
END OF tpro.

DATA : BEGIN OF tcuenta  OCCURS 0,
          bukrs          LIKE  zctarechazo-bukrs,
          rzawe          LIKE  zctarechazo-rzawe,
          hkont_orig     LIKE  zctarechazo-hkont_orig,
          hkont_dest     LIKE  zctarechazo-hkont_dest,
          hbkid_dest     LIKE  zctarechazo-hbkid_dest,
          hktid_dest     LIKE  zctarechazo-hktid_dest,
END OF tcuenta.

START-OF-SELECTION.

  EXEC SQL.
    connect to 'SAPCSC' as 'con'
  ENDEXEC.

  EXEC SQL.
    set connection 'con'
  ENDEXEC.

*  Modificacion Herman job de fondo oracle
  EXEC SQL.
    EXECUTE PROCEDURE prc_tr_act_estados
  ENDEXEC.
*  Fin modificacion
  TRY.
      EXEC SQL.

        OPEN c1 FOR
         SELECT
           NUMERO_EMPRESA,
           RUT_EMISOR,
           CUENTA_CARGO,
           NOMBRE_BENEFICIARIO,
           RUT_BENEFICIARIO,
           MONTO,
           NUMERO_CHEQUE,
           ESTADO_PAGO,
           CENTRO_PAGO,
           FECHA_RECEPCION,
           NUMERO_LOTE,
           CODIGO_IDENTIFICACION,
           TO_CHAR(FECHA_PROCESO, 'YYYYMMDD') AS FECHA_PROCESO,
           FECHA_PAGO,
           FECHA_ESTADO
           FROM   SAPBBVA_EMITIDOS_NOCOBRADOS
           WHERE ESTADO_PROCESO = '0'
           ORDER BY NUMERO_EMPRESA, CODIGO_IDENTIFICACION, RUT_BENEFICIARIO

      ENDEXEC.

      REFRESH: trec,tdev,tres.

      DO.
        EXEC SQL.
          FETCH NEXT c1 INTO  :reg

        ENDEXEC.
        IF sy-subrc <> 0.
          EXIT.
        ELSE.
          IF reg-estado_pago = 'CUSTODIA'.
*            CONCATENATE reg-fecha_recepcion+0(4) reg-fecha_recepcion+5(2) reg-fecha_recepcion+8(2) INTO fecha_aux. - CBD
            IF NOT reg-fecha_estado IS INITIAL.
              CONCATENATE reg-fecha_estado+0(4) reg-fecha_estado+5(2) reg-fecha_estado+8(2) INTO fecha_aux.
            ELSE.
              CONCATENATE reg-fecha_recepcion+0(4) reg-fecha_recepcion+5(2) reg-fecha_recepcion+8(2) INTO fecha_aux.
            ENDIF.
            UPDATE reguh
              SET ind_custodia = 'X'
                  fecha_custodia = fecha_aux
             WHERE identif_pago = reg-codigo_identificacion.

            IF sy-subrc = 0.
* CBD 2011-12-20        COMMIT WORK.        SE SACA ESTA INSTRUCCIÓN YA QUE PROVOCABA ERROR AL LEER EL SIG. REGISTRO DEL RECORDSET --> "TRUNCABA" EL RECORDSET.
              EXEC SQL.
                update SAPBBVA_EMITIDOS_NOCOBRADOS
                  set ESTADO_PROCESO = '1',
                      FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
                  where CODIGO_IDENTIFICACION = :reg-CODIGO_IDENTIFICACION
                  AND   ESTADO_PROCESO = '0'
                  AND   FECHA_RECEPCION = :reg-fecha_recepcion
              ENDEXEC.
            ELSE.
              EXEC SQL.
                update SAPBBVA_EMITIDOS_NOCOBRADOS
                  set ESTADO_PROCESO = '9',
                      FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
                  where CODIGO_IDENTIFICACION = :reg-CODIGO_IDENTIFICACION
                  AND   ESTADO_PROCESO = '0'
                  AND   FECHA_RECEPCION = :reg-fecha_recepcion
              ENDEXEC.
            ENDIF.
          ELSE.
            IF reg-estado_pago = 'CHEQUE PAGADO'.
*              CONCATENATE reg-fecha_recepcion+0(4) reg-fecha_recepcion+5(2) reg-fecha_recepcion+8(2) INTO fecha_aux. - CBD
              IF NOT reg-fecha_estado IS INITIAL.
                CONCATENATE reg-fecha_estado+0(4) reg-fecha_estado+5(2) reg-fecha_estado+8(2) INTO fecha_aux.
              ELSE.
                CONCATENATE reg-fecha_recepcion+0(4) reg-fecha_recepcion+5(2) reg-fecha_recepcion+8(2) INTO fecha_aux.
              ENDIF.
* Ini V1-RVY 29.04.2025
              UPDATE reguh
                SET ind_pago = 'X'
                    fecha_pago = fecha_aux
*              WHERE identif_pago = reg-codigo_identificacion
              WHERE identif_pago = reg-codigo_identificacion AND
                    GlOSA_REDEPO <> 'RETIRO POR UN 3RO'.
* Fin V1-RVY 29.04.2025
              IF sy-subrc = 0.
                EXEC SQL.
                  update SAPBBVA_EMITIDOS_NOCOBRADOS
                    set ESTADO_PROCESO = '1',
                        FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
                    where CODIGO_IDENTIFICACION = :reg-CODIGO_IDENTIFICACION
                    AND   ESTADO_PROCESO = '0'
                    AND   FECHA_RECEPCION = :reg-fecha_recepcion
                ENDEXEC.
              ELSE.
                EXEC SQL.
                  update SAPBBVA_EMITIDOS_NOCOBRADOS
                    set ESTADO_PROCESO = '9',
                        FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
                    where CODIGO_IDENTIFICACION = :reg-CODIGO_IDENTIFICACION
                    AND   ESTADO_PROCESO = '0'
                    AND   FECHA_RECEPCION = :reg-fecha_recepcion
                ENDEXEC.
              ENDIF.
            ELSE.
              IF reg-estado_pago = 'CHEQUE DEVUELTO' OR reg-estado_pago = 'CHEQUE DEVUELTO R'.
* CBD - 2011-12-21 - 08:15 / SE AGREGA VALIDACION PARA ESTADO PAGADO, ES DECIR AL ESTAR PAGADO TAMPOCO DEBE GENERAR UNA NUEVA OBLIGACION
* CBD                SELECT SINGLE * INTO reguh
* CBD                  FROM reguh
* CBD                WHERE identif_pago = reg-codigo_identificacion
* CBD                  AND ( ind_devuelto = 'X' OR ind_rechazo = 'X' ).
                IF reg-estado_pago = 'CHEQUE DEVUELTO'.
                  SELECT SINGLE * INTO reguh
                    FROM reguh
                  WHERE identif_pago = reg-codigo_identificacion
                    AND ( ind_pago = 'X' OR ind_rescatado = 'X' OR ind_devuelto = 'X' OR ind_rechazo = 'X' ).
* CBD - 2011-12-21 - 08:15 / SE AGREGA VALIDACION PARA ESTADO PAGADO, ES DECIR AL ESTAR PAGADO TAMPOCO DEBE GENERAR UNA NUEVA OBLIGACION
                  IF sy-subrc <> 0.
                    MOVE-CORRESPONDING reg TO tdev.
                    APPEND tdev.
                  ELSE.
* CBD - 2011-12-21 - 08:20 / SE AGREGA UPDATE CON ESTADO 9 PARA REGISTROS QUE YA FUERON PROCESADOS ANTERIORMENTE Y SE HAN VUELTO A CARGA DESDE EL TXT
                    EXEC SQL.
                      update SAPBBVA_EMITIDOS_NOCOBRADOS
                        set ESTADO_PROCESO = '9',
                            FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
                        where CODIGO_IDENTIFICACION = :reg-CODIGO_IDENTIFICACION
                        AND   ESTADO_PROCESO = '0'
                        AND   FECHA_RECEPCION = :reg-fecha_recepcion
                    ENDEXEC.
* CBD - 2011-12-21 - 08:20 / SE AGREGA UPDATE CON ESTADO 9 PARA REGISTROS QUE YA FUERON PROCESADOS ANTERIORMENTE Y SE HAN VUELTO A CARGA DESDE EL TXT
                  ENDIF.
                ELSE.
                  MOVE-CORRESPONDING reg TO tdev.
                  APPEND tdev.
                ENDIF.
              ELSE.
                IF reg-estado_pago = 'CHEQUE RECHAZADO' OR reg-estado_pago = 'CHEQUE RECHAZADO R'.
* CBD - 2011-12-21 - 08:18 / SE AGREGA VALIDACION PARA ESTADO PAGADO, ES DECIR AL ESTAR PAGADO TAMPOCO DEBE GENERAR UNA NUEVA OBLIGACION
* CBD                  SELECT SINGLE * INTO reguh
* CBD                    FROM reguh
* CBD                   WHERE identif_pago = reg-codigo_identificacion
* CBD                     AND ( ind_devuelto = 'X' OR ind_rechazo = 'X' ).
                  IF reg-estado_pago = 'CHEQUE RECHAZADO'.
                    SELECT SINGLE * INTO reguh
                      FROM reguh
                     WHERE identif_pago = reg-codigo_identificacion
                       AND ( ind_pago = 'X' OR ind_rescatado = 'X' OR ind_devuelto = 'X' OR ind_rechazo = 'X' ).
* CBD - 2011-12-21 - 08:18 / SE AGREGA VALIDACION PARA ESTADO PAGADO, ES DECIR AL ESTAR PAGADO TAMPOCO DEBE GENERAR UNA NUEVA OBLIGACION
                    IF sy-subrc <> 0.
                      MOVE-CORRESPONDING reg TO trec.
                      APPEND trec.
                    ELSE.
* CBD - 2011-12-21 - 08:22 / SE AGREGA UPDATE CON ESTADO 9 PARA REGISTROS QUE YA FUERON PROCESADOS ANTERIORMENTE Y SE HAN VUELTO A CARGA DESDE EL TXT
                      EXEC SQL.
                        update SAPBBVA_EMITIDOS_NOCOBRADOS
                          set ESTADO_PROCESO = '9',
                              FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
                          where CODIGO_IDENTIFICACION = :reg-CODIGO_IDENTIFICACION
                          AND   ESTADO_PROCESO = '0'
                          AND   FECHA_RECEPCION = :reg-fecha_recepcion
                      ENDEXEC.
* CBD - 2011-12-21 - 08:22 / SE AGREGA UPDATE CON ESTADO 9 PARA REGISTROS QUE YA FUERON PROCESADOS ANTERIORMENTE Y SE HAN VUELTO A CARGA DESDE EL TXT
                    ENDIF.
                  ELSE.
                    MOVE-CORRESPONDING reg TO trec.
                    APPEND trec.
                  ENDIF.
                ELSE.
* CBD - 2012-01-10 - 23:06 / INCORPORO TRATAMIENTO PARA EL ESTADO "CHEQUE RESCATADO"
                  IF reg-estado_pago = 'CHEQUE RESCATADO' OR reg-estado_pago = 'CHEQUE RESCATADO R'.
                    IF reg-estado_pago = 'CHEQUE RESCATADO'.
                      SELECT SINGLE * INTO reguh
                        FROM reguh
                       WHERE identif_pago = reg-codigo_identificacion
                         AND ( ind_pago = 'X' OR ind_rescatado = 'X' OR ind_devuelto = 'X' OR ind_rechazo = 'X' ).
                      IF sy-subrc <> 0.
                        MOVE-CORRESPONDING reg TO tres.
                        APPEND tres.
                      ELSE.
                        EXEC SQL.
                          update SAPBBVA_EMITIDOS_NOCOBRADOS
                            set ESTADO_PROCESO = '9',
                                FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
                            where CODIGO_IDENTIFICACION = :reg-CODIGO_IDENTIFICACION
                            AND   ESTADO_PROCESO = '0'
                            AND   FECHA_RECEPCION = :reg-fecha_recepcion
                        ENDEXEC.
                      ENDIF.
                    ELSE.
                        MOVE-CORRESPONDING reg TO tres.
                        APPEND tres.
                    ENDIF.
                  ENDIF.
* CBD - 2012-01-10 - 23:06 / INCORPORO TRATAMIENTO PARA EL ESTADO "CHEQUE RESCATADO"
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDDO.

      REFRESH tpro.

      PERFORM contabilizo  TABLES trec USING 'Pago Rechazo BBVA'.
      PERFORM contabilizo  TABLES tdev USING 'Pago Devuelto BBVA'.
      PERFORM contabilizo  TABLES tres USING 'Pago Rescatado BBVA'.

      LOOP AT tpro.
*        CONCATENATE tpro-fecha_recepcion+0(4) tpro-fecha_recepcion+5(2) tpro-fecha_recepcion+8(2) INTO fecha_aux. - CBD
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
          WHERE identif_pago = tpro-codigo_identificacion.
        ELSE.
          IF tpro-estado_pago = 'CHEQUE RESCATADO'.
            UPDATE reguh
            SET ind_rescatado = 'X'
                fecha_rescatado = fecha_aux
                belnr_dev     = tpro-belnr_dev
                gjahr_dev     = tpro-gjahr_dev
            WHERE identif_pago = tpro-codigo_identificacion.
          ELSE.
            IF tpro-estado_pago = 'CHEQUE RECHAZADO'.
              UPDATE reguh
              SET ind_rechazo = 'X'
                  fecha_rechazo = fecha_aux
                  belnr_dev     = tpro-belnr_dev
                  gjahr_dev     = tpro-gjahr_dev
              WHERE identif_pago = tpro-codigo_identificacion.
            ENDIF.
          ENDIF.
        ENDIF.

        EXEC SQL.
          update SAPBBVA_EMITIDOS_NOCOBRADOS
            set ESTADO_PROCESO = '1',
                FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
            where CODIGO_IDENTIFICACION = :tpro-CODIGO_IDENTIFICACION
            AND   ESTADO_PROCESO = '0'
            AND   FECHA_RECEPCION = :tpro-fecha_recepcion
        ENDEXEC.

      ENDLOOP.

      EXEC SQL.
        CLOSE c1
      ENDEXEC.

    CATCH cx_sy_native_sql_error INTO oref.
      observacion = oref->get_text( ).
  ENDTRY.

  EXEC SQL.
    SET CONNECTION DEFAULT
  ENDEXEC.

  WRITE: /, 'El Proceso ha terminado exitosamente'.

END-OF-SELECTION.

  INCLUDE zbatchinput.

*&---------------------------------------------------------------------*
*&      Form  CONTABILIZO_DEVOLUCIONes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM contabilizo   TABLES tdat LIKE reg1x USING texto LIKE bkpf-bktxt.

  DATA : nuevo(01),
         lineas(05)  TYPE n,
         tlineas(05) TYPE n,
         filas(05)   TYPE n,
         fecha(08),
         fecha1(08),
         docpag(16),
         valor(15),
         total        LIKE regup-dmbtr,
         bukrs_x(4),
         banco       LIKE bseg-hbkid,
         cuenta      LIKE bseg-hktid,
         gjahr       LIKE bkpf-gjahr,
         belnr       LIKE bkpf-belnr,
         largo(5)    TYPE n ,
         cant_imp(6) TYPE n.

  nuevo = 'S'.
  lineas = 0.
  tlineas  = 0.
  total = 0.

  REFRESH: bdcdata, itab.

 SORT tdat BY codigo_identificacion+0(4) fecha_estado descending codigo_identificacion.

  LOOP AT tdat.

    SORT tdat BY codigo_identificacion.

    IF bukrs_x <> tdat-codigo_identificacion+0(4).
      SELECT *  FROM zctarechazo INTO CORRESPONDING FIELDS OF TABLE tcuenta
                                   WHERE bukrs = tdat-codigo_identificacion+0(4)
                                   and   RZAWE_D = ''.

      SORT tcuenta BY bukrs rzawe hkont_orig.
    ENDIF.

    IF bukrs_x <> tdat-codigo_identificacion+0(4) AND
       NOT  bukrs_x IS INITIAL AND lineas > 0.
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
                                     texto.
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

    bukrs_x = tdat-codigo_identificacion+0(4).

*    IF bukrs_x = 'CL01'.
*      banco = 'SAN06'.
*      cuenta = '00305'.
*    ELSE.
*      banco =  'SAN16'.
*      cuenta = '00315'.
*    ENDIF.

    SELECT  SINGLE * FROM reguh WHERE identif_pago  = tdat-codigo_identificacion.
    largo = STRLEN( reguh-ubhkt ) - 1.
    reguh-ubhkt+largo(1) = '1'.

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
                                     texto.
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

    SELECT  * FROM  regup WHERE laufd = reguh-laufd
                          AND   laufi = reguh-laufi
                          AND   xvorl = reguh-xvorl
                          AND   zbukr = reguh-zbukr
                          AND   lifnr = reguh-lifnr
                          AND   kunnr = reguh-kunnr
                          AND   empfg = reguh-empfg
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916992*
*                          AND   vblnr = reguh-vblnr.
                          AND   vblnr = reguh-vblnr ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916992*

      SELECT SINGLE  * FROM bseg WHERE bukrs  = regup-bukrs
                             AND  belnr = regup-belnr
                             AND  gjahr = regup-gjahr
                             AND  buzei = regup-buzei.

      IF nuevo = 'S'.
        IF tdat-fecha_estado IS INITIAL.
          CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+0(4) INTO fecha1.
        ELSE.
          CONCATENATE  tdat-fecha_estado+8(2) tdat-fecha_estado+5(2) tdat-fecha_estado+0(4) INTO fecha1.
        ENDIF.
        PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'RF05A-NEWKO'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'BKPF-BLDAT'
                                      fecha1.
        PERFORM bdc_field       USING 'BKPF-BLART'
                                      'SA'.
        PERFORM bdc_field       USING 'BKPF-BUKRS'
                                      bukrs_x.
        PERFORM bdc_field       USING 'BKPF-BUDAT'
                                      fecha1.
        PERFORM bdc_field       USING 'BKPF-WAERS'
                                       'CLP'.
        PERFORM bdc_field       USING 'BKPF-BKTXT'
                                      texto.
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

      IF tdat-fecha_estado IS INITIAL.
        CONCATENATE  tdat-fecha_recepcion+8(2) tdat-fecha_recepcion+5(2) tdat-fecha_recepcion+0(4) INTO fecha.
      ELSE.
        CONCATENATE  tdat-fecha_estado+8(2) tdat-fecha_estado+5(2) tdat-fecha_estado+0(4) INTO fecha.
      ENDIF.

      IF texto = 'Pago Rescatado BBVA' OR texto = 'Pago Rechazo BBVA'.
        READ TABLE tcuenta WITH KEY bukrs = bukrs_x
                                    rzawe =  reguh-rzawe
                               hkont_orig = '1011110001'. "CBD: ESTA CUENTA SE USA SOLO PARA OBTENER EL BANCO Y CTA A USAR EN LA NUEVA OBLIGACIÓN LA CUAL
                                                          "     NO USARÁ LA CUENTA DE LA TABLA SINO LA CUENTA DE LA OBLIGACIÓN ORIGINAL.
        IF sy-subrc <> 0.
          MESSAGE e016(z1) WITH 'Cta no definida Para Soc./Cta. Origen' bukrs_x '1011110001'.
        ENDIF.
        tcuenta-hkont_dest = bseg-hkont.
      ELSE.
        READ TABLE tcuenta WITH KEY bukrs = bukrs_x
                                    rzawe =  reguh-rzawe
                               hkont_orig = bseg-hkont.
        IF sy-subrc <> 0.
          MESSAGE e016(z1) WITH 'Cta no definida Para Soc./Cta. Origen' bukrs_x bseg-hkont.
        ENDIF.
      ENDIF.

      PERFORM bdc_dynpro      USING 'SAPMF05A' '0302'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'BSEG-ZLSCH'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=ZK'.
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
                                     'C'.
      PERFORM bdc_field       USING 'BSEG-ZUONR'
                                     regup-ZUONR.
      PERFORM bdc_field       USING 'BSEG-SGTXT'
                                     texto.
      PERFORM bdc_field       USING 'BSEG-ZZMOT_EMIS'
                                     bseg-zzmot_emis.
* CBD      PERFORM bdc_field       USING 'BSEG-ZZ_AGENCIA' A SOLICITUD DE EDUARDO RAVELLO SE DEBE USAR AGENCIA Y REFERENCIA1 DE LA OBLIGACION ORIGINAL.
* CBD                                      '229'.
      PERFORM bdc_field       USING 'BSEG-ZZ_AGENCIA'
                                     bseg-zz_agencia.
* CBD
      SELECT SINGLE * FROM lfb1 WHERE lifnr = reguh-lifnr AND
                                       bukrs = bukrs_x.

      IF sy-subrc = 0.
* CBD NO ES NECESARIO PREGUNTAR POR "IF NOT lfb1-qland IS INITIAL" YA QUE BASTA CON QUE EXISTA EN TABLA LFB1 PARA REALIZAR COUNT(*) EN TABLA LFBW
* CBD        IF NOT lfb1-qland IS INITIAL.

          SELECT COUNT(*) INTO cant_imp FROM lfbw
                                      WHERE lifnr = reguh-lifnr
                                      AND   bukrs = bukrs_x.
          IF cant_imp > 0.
            PERFORM bdc_dynpro USING  'SAPLFWTD' '0100'.
            PERFORM bdc_field  USING  'BDC_CURSOR'
                                      'WITH_ITEM-WT_WITHCD(01)'.
            PERFORM bdc_field  USING 'BDC_OKCODE'
                                      '/00'.
            PERFORM bdc_field  USING  'WITH_ITEM-WT_WITHCD(01)'
                   '  '.
          ENDIF.

* CBD        ENDIF.
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
* CBD - 2012-01-11 - SE AGREGA EL CAMPO XREF1 QUE SE OBTIENE DE LA OBLIGACION ORIGINAL
      PERFORM bdc_field       USING 'BSEG-XREF1'
                                     bseg-xref1.
* CBD - 2012-01-11 - SE AGREGA EL CAMPO XREF1 QUE SE OBTIENE DE LA OBLIGACION ORIGINAL
      PERFORM bdc_field       USING 'BSEG-XREF2'
                                     reguh-vblnr.

      lineas = lineas + 1.

      total = total + regup-dmbtr.

    ENDSELECT.

    CLEAR tpro.
    tpro-codigo_identificacion = tdat-codigo_identificacion.
    tpro-fecha_recepcion = tdat-fecha_recepcion.
    tpro-fecha_estado = tdat-fecha_estado.
    tpro-estado_pago = tdat-estado_pago.

    APPEND tpro.

  ENDLOOP.

  IF lineas > 0.

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
                                   texto.
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
    ELSE.
      LOOP AT tpro WHERE belnr_dev IS INITIAL.
        DELETE  tpro.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    "contabilizar
