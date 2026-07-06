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
  DATA : l_flag      TYPE c.
  DATA:largo_rut     TYPE i, "HCD 20200615
       ti_dev        TYPE  reg1    OCCURS 0 WITH HEADER LINE,
       ti_dep        TYPE  ty_dep  OCCURS 0 WITH HEADER LINE,
       ti_dev_paso   TYPE  reg1    OCCURS 0 WITH HEADER LINE,
       ti_dep_paso   TYPE  ty_dep  OCCURS 0 WITH HEADER LINE,
       lv_clave_proc TYPE i.
*
  CLEAR int_tabla.
*
* se modifica el acceso a la tabla zctarechazobco por la tabla zctarechazo dado que esta es la usada por este proceso
* SELECT *  FROM zctarechazobco  INTO CORRESPONDING FIELDS OF TABLE tcuenta
  SELECT *  FROM zctarechazo  INTO CORRESPONDING FIELDS OF TABLE tcuenta
                               WHERE bukrs      = bukrs
                               AND   rzawe_d    = ''.

  SORT tcuenta BY bukrs rzawe hkont_orig.
*
  lv_clave_proc = 0.
  LOOP AT gt_outtab  WHERE sel EQ 'X'.
    MOVE-CORRESPONDING gt_outtab TO int_tabla.
    ADD 1 TO lv_clave_proc.
*
    LOOP AT tdev INTO ti_dev
                  WHERE estado_pago  = int_tabla-estado_pago
                  AND   cuenta_cargo = int_tabla-ctactedev
                  AND   numero_lote  = int_tabla-lotedev
                  AND   fecha_pago   = int_tabla-fechadev
                  AND   correl       = int_tabla-correl.
      ti_dev-clave_proc = lv_clave_proc.
      APPEND ti_dev.
    ENDLOOP.
*
    LOOP AT tdep  INTO ti_dep
                  WHERE estado_pago     = int_tabla-estado_pago
                  AND   cuenta_cargo    = int_tabla-ctactedev
                  AND   numero_lote     = int_tabla-lotedev
                  AND   fecha_recepcion = int_tabla-fechadev
                  AND   belnr           = gt_outtab-belnr
                  AND   usado           = 'X'
                  AND   correl          = int_tabla-correl.
      ti_dep-clave_proc = lv_clave_proc.
      APPEND ti_dep.
    ENDLOOP.
    IF sy-subrc NE 0.
      LOOP AT tdep INTO ti_dep
                    WHERE estado_pago     = int_tabla-estado_pago
                    AND   cuenta_cargo    = int_tabla-ctactedev
                    AND   numero_lote     = int_tabla-lotedev
                    AND   fecha_recepcion = int_tabla-fechadev
                    AND   correl          = int_tabla-correl
                    AND   estado          = 'X'.
        ti_dep-clave_proc = lv_clave_proc.
        APPEND ti_dep.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
*
  ti_dev_paso[] = tdev[].
  ti_dep_paso[] = tdep[].

  tdev[] = ti_dev[].
  tdep[] = ti_dep[].

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

*  WRITE: /, 'Se Generaron los siguietes Voucher por Pagos Devueltos y rescatados BBVA'.
  PERFORM contabilizo  TABLES tdev USING 'Pago Dev/Rescatdo BBVA' '1'.

  LOOP AT tpro WHERE belnr_dev IS NOT INITIAL.
*    largo_rut  = strlen( tpro-rut_beneficiario ) - 1."HCD 20200615
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        input  = tpro-rut_beneficiario+0(largo_rut)
*      IMPORTING
*        output = rut_aux.
*
*    CONCATENATE rut_aux '-'  tpro-rut_beneficiario+largo_rut(1)  INTO rut_aux.
*
*    IF NOT tpro-fecha_estado IS INITIAL.
*      CONCATENATE tpro-fecha_estado+0(4) tpro-fecha_estado+5(2) tpro-fecha_estado+8(2) INTO fecha_aux.
*    ELSE.
*      CONCATENATE tpro-fecha_recepcion+0(4) tpro-fecha_recepcion+5(2) tpro-fecha_recepcion+8(2) INTO fecha_aux.
*    ENDIF.
*    IF tpro-estado_pago = 'CHEQUE DEVUELTO'.
*      UPDATE reguh
*      SET ind_devuelto = 'X'
*          fecha_devuelto = fecha_aux
*          belnr_dev     = tpro-belnr_dev
*          gjahr_dev     = tpro-gjahr_dev
*      WHERE identif_pago = tpro-codigo_identificacion
*      AND   zstc1 =  rut_aux.
*    ELSE.
**      IF tpro-estado_pago = 'CHEQUE RESCATADO'.
*      IF tpro-estado_pago = 'VALE VISTA REINTEGRAD'.
*        UPDATE reguh
*        SET ind_rescatado = 'X'
*            fecha_rescatado = fecha_aux
*            belnr_dev     = tpro-belnr_dev
*            gjahr_dev     = tpro-gjahr_dev
*        WHERE identif_pago = tpro-codigo_identificacion
*        AND   zstc1 =  rut_aux.
*      ELSE.
*        IF tpro-estado_pago = 'CHEQUE RECHAZADO'.
*          UPDATE reguh
*          SET ind_rechazo = 'X'
*              fecha_rechazo = fecha_aux
*              belnr_dev     = tpro-belnr_dev
*              gjahr_dev     = tpro-gjahr_dev
*          WHERE identif_pago = tpro-codigo_identificacion
*           AND   zstc1 =  rut_aux.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    EXEC SQL.
*      update SAPBBVA_EMITIDOS_NOCOBRADOS
*        set ESTADO_PROCESO = '1',
*            FECHA_PROCESO  = TO_DATE(:SY-DATUM,'YYYYMMDD')
*        where CODIGO_IDENTIFICACION = :tpro-CODIGO_IDENTIFICACION
*        AND   RUT_BENEFICIARIO = :tpro-RUT_BENEFICIARIO
*        AND   ESTADO_PROCESO = '0'
*        AND   FECHA_RECEPCION = :tpro-fecha_recepcion
*    ENDEXEC.
*
    IF tpro-belnr_dev IS NOT INITIAL.
      READ TABLE gt_outtab INTO gs_outtab
                          WITH KEY estado_pago  = tpro-estado_pago
                                   correl       = tpro-correl
                                   sel          = 'X'.
      IF sy-subrc EQ 0.
        DELETE gt_outtab INDEX sy-tabix.
        l_flag = 'X'.
      ENDIF.
    ENDIF.
*
*    COMMIT WORK.
  ENDLOOP.
**  elimina registros procesados del reporte.
  IF l_flag EQ 'X'.
    LOOP AT tdev WHERE estado_pago  = int_tabla-estado_pago
                 AND   cuenta_cargo = int_tabla-ctactedev
                 AND   numero_lote  = int_tabla-lotedev
                 AND   fecha_pago   = int_tabla-fechadev
                 AND   correl       = int_tabla-correl.
      READ TABLE gt_outtab INTO gs_outtab
                          WITH KEY estado_pago = int_tabla-estado_pago
                                   ctactedev   = int_tabla-ctactedev
                                   lotedev     = int_tabla-lotedev
                                   fechadev    = int_tabla-fechadev
                                   correl      = int_tabla-correl
                                   sel         = 'X'.
      CHECK sy-subrc EQ 0.
      DELETE gt_outtab INDEX sy-tabix.
    ENDLOOP.
*  ELSE.
*    MESSAGE i899(fi) WITH 'No se pudieron procesar los pagos'.
  ENDIF.
*
  tdev[] = ti_dev_paso[].
  tdep[] = ti_dep_paso[].
*
  CALL METHOD g_grid1->refresh_table_display.
ENDFORM.                    "confirma_contabilizacion
*&---------------------------------------------------------------------*
*&      Form  CONTABILIZO_DEVOLUCIONes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM contabilizo   TABLES ti_dat LIKE reg1x
                   USING  texto LIKE bkpf-bktxt
                          proceso.
  TYPES : BEGIN OF ty_desborde,
            clave_proc TYPE char10,
            newko      TYPE char10,
            wrbtr      TYPE dmbtr,
            sgtxt      TYPE char25,
          END OF ty_desborde,
          BEGIN OF ty_doc_desborde,
            clave_proc TYPE char10,
            belnr      TYPE belnr_d,
            gjahr      TYPE gjahr,
            bukrs      TYPE bukrs,
            fecha      TYPE char08,
          END OF ty_doc_desborde,
          BEGIN OF ty_clave_proc,
            clave_proc TYPE char10,
            lineas     TYPE i,
          END OF ty_clave_proc.
  DATA: largo_rut       TYPE i, "HCD 20200615
        cuenta          LIKE bseg-hkont,
        tdat            TYPE reg1,
        lv_n1           TYPE i,
        newbs           LIKE bseg-bschl,
*
        lt_desborde     TYPE TABLE OF ty_desborde,
        lt_clave_proc   TYPE TABLE OF ty_clave_proc,
        lt_doc_desborde TYPE TABLE OF ty_doc_desborde,
        wa_desborde     TYPE ty_desborde,
        wa_clave_proc   TYPE ty_clave_proc,
        wa_doc_desborde TYPE ty_doc_desborde,
*
        lv_tabix        TYPE sy-tabix,
        lv_dynpro       TYPE char04,
        lv_posnr        TYPE i,
        lv_posnr_tot    TYPE i,
        lv_count        TYPE i,
        lv_tope         TYPE i VALUE '900',
        lv_mensaje      TYPE bapi_msg.
*
  SORT ti_dat BY clave_proc cuenta_cargo fecha_estado DESCENDING codigo_identificacion.
  CONCATENATE sy-datum sy-uzeit INTO asignacion.
* ACUMULA POR POSICION PARA VERIFICAR SI EL PROCESO TENDRA MAS DE 900 POSICIONES.
  LOOP AT ti_dat.
    MOVE-CORRESPONDING ti_dat TO tdat.
* identifica el registro de la REGUH
    largo_rut    = strlen( tdat-rut_beneficiario ) - 1.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = tdat-rut_beneficiario+0(largo_rut)
      IMPORTING
        output = rut_aux.
    CONCATENATE rut_aux '-'  tdat-rut_beneficiario+largo_rut(1) INTO rut_aux.
    SELECT SINGLE * FROM reguh
               WHERE identif_pago  = tdat-codigo_identificacion
               AND   zstc1         =  rut_aux.
    IF sy-subrc EQ 0.
* verifica la cantidad de posiciones de la REGUP para saber las lineas que se tendran.
      SELECT COUNT(*) INTO lv_count
        FROM regup WHERE laufd = reguh-laufd
                     AND laufi = reguh-laufi
                     AND xvorl = reguh-xvorl
                     AND zbukr = reguh-zbukr
                     AND lifnr = reguh-lifnr
                     AND kunnr = reguh-kunnr
                     AND empfg = reguh-empfg
                     AND vblnr = reguh-vblnr.
    ELSE.
      lv_count = 0.
    ENDIF.
*
    wa_clave_proc-clave_proc = tdat-clave_proc.
    wa_clave_proc-lineas     = lv_count.
    COLLECT wa_clave_proc  INTO lt_clave_proc.
  ENDLOOP.

  LOOP AT ti_dat.
    MOVE-CORRESPONDING ti_dat TO tdat.
*
    AT NEW clave_proc.
      REFRESH: bdcdata, lt_desborde, lt_doc_desborde, itab.
*
      nuevo            = 'S'.
      total = lv_posnr = 0.
      lv_posnr_tot     = lv_tope.
*
      DATA(lv_lineas) = lt_clave_proc[ clave_proc = tdat-clave_proc ]-lineas.
      IF lv_lineas GT lv_tope.
        lv_dynpro = '0100'.
      ELSE.
        lv_dynpro = '0122'.
      ENDIF.
    ENDAT.
*
    cuenta_cargo = tdat-cuenta_cargo.
    largo_rut  = strlen( tdat-rut_beneficiario ) - 1."HCD 20200615
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = tdat-rut_beneficiario+0(largo_rut)
      IMPORTING
        output = rut_aux.

    CONCATENATE rut_aux '-'  tdat-rut_beneficiario+largo_rut(1) INTO rut_aux.

    SELECT  SINGLE * INTO reguh
      FROM reguh  WHERE identif_pago  = tdat-codigo_identificacion
                  AND   zstc1         =  rut_aux.
*
    IF sy-subrc NE 0.
* ini Waldo Alarcón - Visionone - 17-05-2021 - log
*      WRITE: / 'Error No se encontro en REGUH: ',
*               tdat-clave_proc,
*               tdat-codigo_identificacion,
*               rut_aux.
      lv_mensaje = 'Error No se encontro RUT en REGUH: '.
      PERFORM log_errores USING tdat
                                rut_aux
                                ' '
                                ' '
                                lv_mensaje.
* fin Waldo Alarcón - Visionone - 17-05-2021 - log
      CONTINUE.
    ENDIF.

    largo                = strlen( reguh-ubhkt ) - 1.
    reguh-ubhkt+largo(1) = '1'.

    SELECT * FROM regup WHERE laufd = reguh-laufd
                          AND laufi = reguh-laufi
                          AND xvorl = reguh-xvorl
                          AND zbukr = reguh-zbukr
                          AND lifnr = reguh-lifnr
                          AND kunnr = reguh-kunnr
                          AND empfg = reguh-empfg
                          AND vblnr = reguh-vblnr
                          ORDER BY PRIMARY KEY.

      SELECT SINGLE  * FROM bseg WHERE bukrs  = regup-bukrs
                             AND  belnr = regup-belnr
                             AND  gjahr = regup-gjahr
                             AND  buzei = regup-buzei.
      IF nuevo = 'S'.
        IF tdat-fecha_estado IS INITIAL.
          CONCATENATE sy-datum+6(2)
                      sy-datum+4(2)
                      sy-datum+0(4) INTO fecha1.
        ELSE.
          CONCATENATE  tdat-fecha_estado+8(2)
                       tdat-fecha_estado+5(2)
                       tdat-fecha_estado+0(4) INTO fecha1.
        ENDIF.

        PERFORM f_insert_line USING:
                'X' 'SAPMF05A'    lv_dynpro,  "'0122',
                ' ' 'BDC_CURSOR'  'BKPF-BLART',
                ' ' 'BDC_OKCODE'  '/00',
                ' ' 'BKPF-BLDAT'  fecha1,
                ' ' 'BKPF-BLART'  'XG',
                ' ' 'BKPF-BUKRS'  bukrs,
                ' ' 'BKPF-BUDAT'  fecha1,
                ' ' 'BKPF-WAERS'  'CLP',
                ' ' 'BKPF-BKTXT'  texto,
                ' ' 'FS006-DOCID' '*'.

        nuevo = 'N'.
      ENDIF.

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
          MESSAGE e016(z1) WITH 'Cta no definida Para Soc./Cta. Origen' bukrs '1011110001'
                           INTO lv_mensaje.
* ini Waldo Alarcón - Visionone - 17-05-2021 - log
          PERFORM log_errores USING tdat
                                    rut_aux
                                    ' '
                                    ' '
                                    lv_mensaje.
          CONTINUE.
* fin Waldo Alarcón - Visionone - 17-05-2021 - log
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
            MESSAGE e016(z1) WITH 'Cta no definida Para Soc./Cta. Origen' bukrs bseg-hkont
                             INTO lv_mensaje.
* ini Waldo Alarcón - Visionone - 17-05-2021 - log
            PERFORM log_errores USING tdat
                                      rut_aux
                                      ' '
                                      ' '
                                      lv_mensaje.
            CONTINUE.
* fin Waldo Alarcón - Visionone - 17-05-2021 - log
          ENDIF.
        ENDIF.
      ENDIF.

      PERFORM bdc_field       USING 'RF05A-NEWBS'       newbs.
      PERFORM bdc_field       USING 'RF05A-NEWKO'       cuenta .

      WRITE  regup-dmbtr CURRENCY 'CLP'  TO valor.

      IF tdat-fecha_estado IS INITIAL.
        CONCATENATE  tdat-fecha_recepcion+8(2)
                     tdat-fecha_recepcion+5(2)
                     tdat-fecha_recepcion+0(4) INTO fecha.
      ELSE.
        CONCATENATE  tdat-fecha_estado+8(2)
                     tdat-fecha_estado+5(2)
                     tdat-fecha_estado+0(4) INTO fecha.
      ENDIF.

*      IF tdat-estado_pago = 'CHEQUE RESCATADO' OR tdat-estado_pago = 'CHEQUE RECHAZADO'.

      IF newbs = '21' OR newbs = '31'.
        PERFORM bdc_dynpro      USING 'SAPMF05A'           '0302'.
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

        IF lv_dynpro EQ '0100'.
          SELECT SINGLE * FROM lfb1 WHERE lifnr = reguh-lifnr AND
                                          bukrs = bukrs.

          IF sy-subrc = 0.
            SELECT COUNT(*) INTO cant_imp FROM lfbw
                                        WHERE lifnr = reguh-lifnr
                                        AND   bukrs = bukrs.
            IF cant_imp > 0.
              PERFORM bdc_dynpro USING  'SAPLFWTD'                '0100'.
              PERFORM bdc_field  USING  'BDC_CURSOR'              'WITH_ITEM-WT_WITHCD(01)'.
              PERFORM bdc_field  USING  'BDC_OKCODE'              '/00'.
              PERFORM bdc_field  USING  'WITH_ITEM-WT_WITHCD(01)' '  '.
            ENDIF.
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
*
      ADD 1 TO lv_posnr.
      total = total + regup-dmbtr.
    ENDSELECT.
*
    CLEAR tpro.
    tpro-codigo_identificacion = tdat-codigo_identificacion.
    tpro-rut_beneficiario      = tdat-rut_beneficiario.
    tpro-fecha_recepcion       = tdat-fecha_recepcion.
    tpro-fecha_estado          = tdat-fecha_estado.
    tpro-estado_pago           = tdat-estado_pago.
    tpro-correl                = tdat-correl.
    tpro-clave_proc            = tdat-clave_proc.
    APPEND tpro.
*
    AT END OF clave_proc.
      IF lt_desborde[] IS NOT INITIAL.
        LOOP AT lt_desborde INTO wa_desborde.
          WRITE wa_desborde-wrbtr  CURRENCY 'CLP'  TO valor.
          PERFORM bdc_field       USING 'RF05A-NEWBS'    '50'.
          PERFORM bdc_field       USING 'RF05A-NEWKO'    wa_desborde-newko.

          PERFORM bdc_dynpro      USING 'SAPMF05A'        '0300'.
          PERFORM bdc_field       USING 'BDC_OKCODE'      '/00'.
          PERFORM bdc_field       USING 'BSEG-WRBTR'      valor.
          PERFORM bdc_field       USING 'BSEG-SGTXT'      wa_desborde-sgtxt.
          PERFORM bdc_field       USING 'DKACB-FMORE'     ' '.
        ENDLOOP.
*
        PERFORM bdc_dynpro      USING 'SAPMF05A'        '0300'.
        PERFORM bdc_field       USING 'BDC_OKCODE'      '=SL'.

        PERFORM bdc_dynpro      USING 'SAPLKACB'        '0002'.
        PERFORM bdc_field       USING 'BDC_OKCODE'      '/00'.
      ELSE.
        IF newbs = '21' OR newbs = '31'.
          PERFORM bdc_dynpro      USING 'SAPMF05A'        '0332'.
        ELSE.
          PERFORM bdc_dynpro      USING 'SAPMF05A'        '0330'.
        ENDIF.
        PERFORM bdc_field       USING 'BDC_OKCODE'      '=SL'.

      ENDIF.
*
      DATA(lv_cta) = ''.
      LOOP AT tdep WHERE estado_pago     = tdat-estado_pago
                   AND   cuenta_cargo    = tdat-cuenta_cargo
                   AND   numero_lote     = tdat-numero_lote
                   AND   fecha_recepcion = tdat-fecha_pago
                   AND   correl          = tdat-correl
                   AND   clave_proc      = tdat-clave_proc.
        IF lv_cta is INITIAL.
          PERFORM f_insert_line USING:
                  'X' 'SAPMF05A'    '0710',
                  ' ' 'BDC_OKCODE'  '/00',
                  ' ' 'RF05A-AGBUK'  bukrs,
                  ' ' 'RF05A-AGKON'  tdep-hkont, "reguh-ubhkt,
                  ' ' 'RF05A-AGKOA'  'S',
                  ' ' 'RF05A-XNOPS'  'X',
                  ' ' 'RF05A-XPOS1(04)'  'X'.
          lv_cta = gc_x.
        ENDIF.
        PERFORM f_insert_line USING:
                 'X' 'SAPMF05A'    '0731',
                 ' ' 'BDC_CURSOR'  'RF05A-SEL01(01)',
                 ' ' 'BDC_OKCODE'  '/00',
                 ' ' 'RF05A-SEL01(01)'  tdep-belnr.
      ENDLOOP.
**
      PERFORM f_insert_line USING:
              'X' 'SAPMF05A'    '0731',
              ' ' 'BDC_OKCODE'  '=PA'.
**
      PERFORM f_insert_line USING:
              'X' 'SAPDF05X'    '3100',
              ' ' 'BDC_OKCODE' '=BU'.

      REFRESH itab. CLEAR itab.
*
      CALL TRANSACTION 'F-51' USING  bdcdata
                                      MODE   p_mode
                                      UPDATE 'S'
                                      MESSAGES INTO itab.
      CLEAR belnr.
      READ TABLE itab WITH KEY msgid = 'F5'
                               msgnr = '312'.
      IF sy-subrc EQ 0.
        belnr = itab-msgv1.
        gjahr = fecha1+4(4).
*        WRITE: / 'Correlativo : ', tdat-clave_proc,
*                 'Se genero Voucher Numero : ',  belnr , ' Año :' ,  gjahr.
*
        COMMIT WORK AND WAIT.
        sy-subrc = 4.
        lv_n1    = 0.
        WHILE sy-subrc NE 0 AND lv_n1 LT 100.
          ADD 1 TO lv_n1.
          SELECT SINGLE belnr INTO itab-msgv1
                 FROM bkpf WHERE bukrs EQ bukrs
                            AND  belnr EQ belnr
                            AND  gjahr EQ gjahr.
        ENDWHILE.
*
        LOOP AT tpro WHERE belnr_dev IS INITIAL AND
                           clave_proc EQ tdat-clave_proc.
          MOVE sy-tabix TO lv_tabix.
          tpro-belnr_dev = belnr.
          tpro-gjahr_dev = gjahr.
          MODIFY tpro INDEX lv_tabix.
        ENDLOOP.
*
* ini Waldo Alarcón - Visionone - 17-05-2021 - log
        lv_mensaje = 'Se genero Voucher '.
        PERFORM log_errores USING tdat
                                  rut_aux
                                  belnr
                                  gjahr
                                  lv_mensaje.
*
        PERFORM actualiza_datos USING tdat
                                      belnr
                                      gjahr.
* fin Waldo Alarcón - Visionone - 17-05-2021 - log
      ELSE.
        LOOP AT itab WHERE msgtyp EQ 'E' OR
                           msgid  NE 'F5'.
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
* ini Waldo Alarcón - Visionone - 17-05-2021 - log
*          WRITE: / 'Error Al contabilizar : ',
*                   tdat-clave_proc,
*                   tdat-codigo_identificacion, mensaje.
          lv_mensaje = 'Error al contabilizar : ' && ' ' && mensaje.
          PERFORM log_errores USING tdat
                                    rut_aux
                                    ' '
                                    ' '
                                    lv_mensaje.
* fin Waldo Alarcón - Visionone - 17-05-2021 - log
        ENDLOOP.
* si se produjo error en la Compensacion, anula los documentos creados
        LOOP AT lt_doc_desborde INTO wa_doc_desborde.
          PERFORM anula_documento USING wa_doc_desborde-bukrs
                                        wa_doc_desborde-belnr
                                        wa_doc_desborde-gjahr
                                        wa_doc_desborde-fecha
                                        wa_doc_desborde-clave_proc
                                        tdat.
        ENDLOOP.
      ENDIF.

      nuevo  = 'S'.
* continua con el siguiente documento.
      CONTINUE.
    ENDAT.
* SI NO ES TERMINO DEL PROCESO Y SE LLEGO A LA CATIDAD LIMITE DE LIENAS SE GENERA
* DOCUMENTO DE DESBORDE CON LA F-02
    IF lv_posnr GT lv_tope.
      WRITE  total  CURRENCY 'CLP'  TO valor.
      PERFORM bdc_field       USING 'RF05A-NEWBS'    '40'.
      PERFORM bdc_field       USING 'RF05A-NEWKO'    '9000000008'.
*
      PERFORM bdc_dynpro      USING 'SAPMF05A'        '0300'.
      PERFORM bdc_field       USING 'BDC_OKCODE'      '=BU'.
      PERFORM bdc_field       USING 'BSEG-WRBTR'      valor.
      PERFORM bdc_field       USING 'BSEG-SGTXT'      texto.
      PERFORM bdc_field       USING 'DKACB-FMORE'     ' '.
*
      CALL TRANSACTION 'F-02' USING  bdcdata
                                      MODE   p_mode
                                      UPDATE 'S'
                                      MESSAGES INTO itab.
      READ TABLE itab WITH KEY msgid = 'F5'
                               msgnr = '312'.
      IF sy-subrc EQ 0.
        belnr = itab-msgv1.
        gjahr = fecha1+4(4).
*        WRITE: / 'Correlativo : ', tdat-clave_proc,
*                 'Se genero Voucher DESBORDE NUMERO : ', belnr , ' Año :' ,  gjahr.
        PERFORM modifica_xblnr.               "Mod SSYG R01046 201810

        wa_desborde-clave_proc = tdat-clave_proc.
        wa_desborde-newko      = '9000000008'.
        wa_desborde-wrbtr      = total.
        wa_desborde-sgtxt      = texto.
        COLLECT wa_desborde INTO lt_desborde.
*
        CLEAR wa_doc_desborde.
        wa_doc_desborde-bukrs      = bukrs.
        wa_doc_desborde-belnr      = belnr.
        wa_doc_desborde-gjahr      = gjahr.
        wa_doc_desborde-fecha      = fecha.
        wa_doc_desborde-clave_proc = tdat-clave_proc.
        APPEND wa_doc_desborde  TO lt_doc_desborde .
* para veriricar que la cuenta no quede tomada
        sy-subrc = 4.
        lv_n1    = 0.
        WHILE sy-subrc NE 0 AND lv_n1 LT 100.
          ADD 1 TO lv_n1.
          SELECT SINGLE belnr INTO itab-msgv1
                 FROM bkpf WHERE bukrs EQ bukrs
                            AND  belnr EQ belnr
                            AND  gjahr EQ gjahr.
        ENDWHILE.
* ini Waldo Alarcón - Visionone - 17-05-2021 - log
        CONCATENATE 'Se genero Voucher DESBORDE NUMERO : ' belnr ' Año :' gjahr
                   INTO lv_mensaje SEPARATED BY space.
        PERFORM log_errores USING tdat
                                  rut_aux
                                  belnr
                                  gjahr
                                  lv_mensaje.
* fin Waldo Alarcón - Visionone - 17-05-2021 - log
      ELSE.
        LOOP AT itab WHERE msgtyp EQ 'E' OR
                           msgid  NE 'F5'.
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
* ini Waldo Alarcón - Visionone - 17-05-2021 - log
*          WRITE: / 'Error Al contabilizar : ',
*                   tdat-clave_proc,
*                   tdat-codigo_identificacion, mensaje.
          CONCATENATE 'Error Al contabilizar : ' mensaje
                     INTO lv_mensaje SEPARATED BY space.
          PERFORM log_errores USING tdat
                                    rut_aux
                                    ' '
                                    ' '
                                    lv_mensaje.
* fin Waldo Alarcón - Visionone - 17-05-2021 - log
        ENDLOOP.
      ENDIF.
*
      lv_posnr_tot = lv_posnr_tot + lv_posnr.
      nuevo = 'S'.
      REFRESH: bdcdata, itab.
      total = lv_posnr = 0.
*
      IF lv_posnr_tot LE lv_lineas.
        lv_dynpro = '0100'.
      ELSE.
        lv_dynpro = '0122'.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "contabilizar
*&---------------------------------------------------------------------*
*&      Form  modifica_xblnr
*&---------------------------------------------------------------------*
*       Para rechazo de transferencias de HUB santander BLART = 'XF'   *
*----------------------------------------------------------------------*
FORM modifica_xblnr.

  UPDATE bkpf SET xblnr = belnr
  WHERE bukrs = bukrs
    AND belnr = belnr
    AND gjahr = gjahr.

ENDFORM.                    "modifica_xblnr.
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
  IF fill GT 0.
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
    CLEAR gv_act.
    CALL SCREEN 250 STARTING AT 25 03 ENDING AT 130 25.
*
    IF gv_act EQ 'X'.
      PERFORM ajusta_tabla USING ls_outtab 'ME'.  "(*)
    ENDIF.
  ELSE.
    MESSAGE i899(fi) WITH 'No existen registros para Seleccionar'.
  ENDIF.
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
*
  IF ls_outtab-montodif EQ 0.
    LOOP AT tdep  WHERE estado_pago    EQ ls_outtab-estado_pago
                  AND  cuenta_cargo    EQ ls_outtab-ctactedev
                  AND numero_lote      EQ ls_outtab-lotedev
                  AND fecha_recepcion  EQ ls_outtab-fechadev
                  AND correl           EQ ls_outtab-correl
                  AND belnr            EQ ls_outtab-belnr
                  AND usado            EQ 'X'.
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
  ENDIF.
*
  IF int_tabla2[] IS INITIAL.
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
  ENDIF.
*
  DESCRIBE TABLE int_tabla2 LINES fill.
  IF fill GT 0.
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
    CLEAR gv_act.
    CALL SCREEN 250 STARTING AT 25 03 ENDING AT 130 25.
*
    IF gv_act EQ 'X'.
      PERFORM ajusta_tabla  USING ls_outtab 'MD'.  "(*)
    ENDIF.
  ELSE.
    MESSAGE i899(fi) WITH 'No existen registros para Seleccionar'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AJUSTA_TABLA
*&---------------------------------------------------------------------*
FORM ajusta_tabla USING ls_outtab  TYPE ty_outtab
                        p_sem.
*
  totalbco = 0.
  totaldep = 0.
  SORT tdev BY estado_pago cuenta_cargo numero_lote fecha_pago correl.
*
  LOOP AT int_tabla2 WHERE sel EQ 'X'.
    ls_outtab-belnr = int_tabla2-belnr.
    CASE p_sem.
      WHEN 'MD'.
        ls_outtab-montopend = int_tabla2-monto.
      WHEN 'ME'.
        ls_outtab-montodev  = int_tabla2-monto.
    ENDCASE.

    ls_outtab-montodif = ls_outtab-montodev - ls_outtab-montopend.
  ENDLOOP.
  IF sy-subrc NE 0.
    LOOP AT int_tabla2.
      ls_outtab-belnr = ''.
      CASE p_sem.
        WHEN 'MD'.
          ls_outtab-montopend = 0.
        WHEN 'ME'.
          ls_outtab-montodev  = 0.
      ENDCASE.

      ls_outtab-montodif = ls_outtab-montodev - ls_outtab-montopend.
    ENDLOOP.
  ENDIF.
**
  REFRESH : int_tabla.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_INSERT_LINE
*&---------------------------------------------------------------------*
FORM f_insert_line USING p_start TYPE c
                         p_name  TYPE c
                         p_value TYPE any.

  DATA: lv_tipo    TYPE c,
        lw_bdcdata LIKE LINE OF bdcdata.

  MOVE  p_start TO lw_bdcdata-dynbegin.

  IF p_start = abap_true.
    MOVE:  p_name  TO lw_bdcdata-program,
           p_value TO lw_bdcdata-dynpro.
  ELSE.

    MOVE p_name  TO lw_bdcdata-fnam.

    DESCRIBE FIELD p_value TYPE lv_tipo.

    TRANSLATE lv_tipo TO UPPER CASE.

    CASE lv_tipo.
      WHEN 'S' OR 'B' OR 'I' OR 'P'.

        lw_bdcdata-fval = p_value.
        CONDENSE lw_bdcdata-fval NO-GAPS.
        TRANSLATE lw_bdcdata-fval USING '.,'.

      WHEN 'D'.
        WRITE p_value DD/MM/YYYY TO lw_bdcdata-fval.

      WHEN 'T'.
        WRITE p_value USING EDIT MASK '__:__:__' TO lw_bdcdata-fval.

      WHEN 'F'.
        WRITE p_value EXPONENT 0 TO lw_bdcdata-fval.
        SHIFT lw_bdcdata-fval RIGHT DELETING TRAILING '0'.
        SHIFT lw_bdcdata-fval LEFT  DELETING LEADING  space.

      WHEN OTHERS.
        MOVE p_value TO lw_bdcdata-fval.

    ENDCASE.

  ENDIF.

  APPEND lw_bdcdata TO bdcdata.

ENDFORM. "F_INSERT_LINE
*&---------------------------------------------------------------------*
*&      Form  ANULA_DOCUMENTO
*&---------------------------------------------------------------------*
FORM anula_documento  USING    p_bukrs
                               p_belnr
                               p_gjahr
                               p_fecha
                               p_clave_proc
                               p_tdat        TYPE reg1.
  DATA : wa_reversal TYPE bapiacrev,
         lv_new_key  TYPE bapiache01-obj_key,
         lv_mensaje  TYPE bapi_msg.
*
  CONCATENATE p_belnr p_bukrs p_gjahr INTO lv_new_key.
*
  MOVE '01'                   TO wa_reversal-reason_rev.
  wa_reversal-pstng_date = p_fecha+4(4) && p_fecha+2(2) && p_fecha+0(2).
*
  CALL FUNCTION 'TB_FI_DOCUMENT_REVERSE'
    EXPORTING
      companycode         = p_bukrs
      document            = p_belnr
      year                = p_gjahr
      obj_key             = lv_new_key
      date_of_reversal    = wa_reversal-pstng_date
      period_of_reversal  = wa_reversal-pstng_date+4(2)
      reason_for_reversal = wa_reversal-reason_rev
    EXCEPTIONS
      error               = 1
      OTHERS              = 2.
  IF sy-subrc <> 0.
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = sy-msgid
        msgnr               = sy-msgno
        msgv1               = sy-msgv1
        msgv2               = sy-msgv2
        msgv3               = sy-msgv3
        msgv4               = sy-msgv4
      IMPORTING
        message_text_output = mensaje.
* ini Waldo Alarcón - Visionone - 17-05-2021 - log
*    WRITE: / 'Error al anular documento : ',
*             p_clave_proc,
*             p_belnr, p_gjahr,
*             ',Error', mensaje.
    CONCATENATE 'Error al anular documento : ' p_belnr p_gjahr ',Error:' mensaje
                INTO lv_mensaje SEPARATED BY space.
    PERFORM log_errores USING p_tdat
                              rut_aux
                              belnr
                              gjahr
                              lv_mensaje.
* fin Waldo Alarcón - Visionone - 17-05-2021 - log
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
* ini Waldo Alarcón - Visionone - 17-05-2021 - log
*    WRITE: / 'Se anulo el documento desborde: ',
*             p_clave_proc,
*             p_belnr, p_gjahr,
*             ',con documento',
*             sy-msgv1.
    CONCATENATE 'Se anulo el documento desborde: ' p_belnr p_gjahr ',con documento' sy-msgv1
                INTO lv_mensaje SEPARATED BY space.
    PERFORM log_errores USING p_tdat
                              rut_aux
                              belnr
                              gjahr
                              lv_mensaje.
* fin Waldo Alarcón - Visionone - 17-05-2021 - log
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LOG_ERRORES
*&---------------------------------------------------------------------*
FORM log_errores  USING    p_tdat        TYPE reg1
                           p_rut_aux
                           p_belnr
                           p_gjahr
                           p_lv_mensaje.

  CLEAR wa_salida.
  MOVE-CORRESPONDING p_tdat TO wa_salida.
  PERFORM formatea_fecha USING    p_tdat-fecha_pago
                         CHANGING wa_salida-fecha_pago.
  PERFORM formatea_fecha USING    p_tdat-fecha_estado
                         CHANGING wa_salida-fecha_estado.
  PERFORM formatea_fecha USING    p_tdat-fecha_recepcion
                         CHANGING wa_salida-fecha_recepcion.
*
  MOVE : gv_tcode                              TO wa_salida-tcode,
         bukrs                                 TO wa_salida-bukrs,
*         ubnkl                                 TO wa_salida-ubnkl,
         p_rut_aux                             TO wa_salida-rut_aux,
         p_lv_mensaje                          TO wa_salida-mensaje,
         p_belnr                               TO wa_salida-belnr,
         p_gjahr                               TO wa_salida-gjahr,
         sy-uname                              TO wa_salida-uname,
         sy-datum                              TO wa_salida-datum,
         sy-uzeit                              TO wa_salida-uzeit.
  APPEND wa_salida TO gt_salida.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZA_DATOS
*&---------------------------------------------------------------------*
FORM actualiza_datos  USING    p_tdat   TYPE reg1
                               p_belnr
                               p_gjahr.
  DATA: largo_rut TYPE i,
        l_flag    TYPE c.
*
  LOOP AT tpro WHERE belnr_dev  EQ p_belnr
               AND   gjahr_dev  EQ p_gjahr
               AND   clave_proc EQ p_tdat-clave_proc.

    largo_rut  = strlen( tpro-rut_beneficiario ) - 1."HCD 20200615
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
        AND   RUT_BENEFICIARIO      = :tpro-RUT_BENEFICIARIO
        AND   ESTADO_PROCESO        = '0'
        AND   FECHA_RECEPCION       = :tpro-fecha_recepcion
    ENDEXEC.
*
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DATOS_REPORTE
*&---------------------------------------------------------------------*
FORM datos_reporte .
  SELECT * INTO TABLE gt_salida
        FROM ztfi_log_pago WHERE tcode EQ gv_tcode
                          AND    bukrs EQ bukrs
                          AND    datum IN s_datum.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUSTRA_DATOS
*&---------------------------------------------------------------------*
FORM mustra_datos .
  DATA: lt_fieldcat TYPE lvc_t_fcat,
        wa_layout   TYPE lvc_s_layo.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM fieldcat_init   USING lt_fieldcat[].
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_salida
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm    LIKE sy-ucomm            "#EC NEEDED
                        rs_selfield TYPE slis_selfield.     "#EC CALLED
  DATA : l_getfeld  TYPE  t354s-initfield,
         l_getvalue TYPE  t354s-initfield,
         ti_iobject TYPE TABLE OF iopick.
*
  CASE rs_selfield-fieldname.
    WHEN 'BELNR'.
      IF rs_selfield-value IS NOT INITIAL.
        READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
        SET PARAMETER ID : 'BLN' FIELD wa_salida-belnr,
                           'BUK' FIELD wa_salida-bukrs,
                           'GJR' FIELD wa_salida-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA: lt_fcode_attrib_tab TYPE TABLE OF smp_dyntxt.
*
  CLEAR: lt_fcode_attrib_tab[].
*
  PERFORM dynamic_report_fcodes IN PROGRAM rhteiln0
                                          TABLES lt_fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.

  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.
ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE lvc_s_layo.
  CLEAR rs_layout.
  rs_layout-zebra                = gc_x.
  rs_layout-detailinit           = gc_x.
  rs_layout-cwidth_opt           = gc_x.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
  DATA : gs_fieldcat TYPE lvc_s_fcat.
*
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gc_tabla
    CHANGING
      ct_fieldcat            = p_gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT p_gt_fieldcat ASSIGNING FIELD-SYMBOL(<campos>).
    CASE <campos>-fieldname.
      WHEN 'TCODE'.
        <campos>-tech    = gc_x.
      WHEN 'BELNR'.
        <campos>-hotspot = gc_x.
      WHEN'UBNKL'.
        <campos>-tech    = gc_x.
    ENDCASE.
    <campos>-colddictxt = 'M'.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORMATEA_FECHA
*&---------------------------------------------------------------------*
FORM formatea_fecha  USING    p_fecha
                     CHANGING p_fecha_sal.

  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      date_external            = p_fecha
    IMPORTING
      date_internal            = p_fecha_sal
    EXCEPTIONS
      date_external_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    TRANSLATE p_fecha USING '- '.
    CONDENSE p_fecha NO-GAPS.
    p_fecha_sal = p_fecha.
  ENDIF.
ENDFORM.
