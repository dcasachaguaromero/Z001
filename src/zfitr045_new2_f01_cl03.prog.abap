*&---------------------------------------------------------------------*
*&  Include           ZFITR045_NEW_F01_CL03
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t001 WHERE bukrs = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* ini Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE banka INTO gv_banka
*         FROM bnka WHERE banks EQ t001-land1 AND
*                         bankl EQ ubnkl.
*
* NEW CODE
  SELECT banka
  UP TO 1 ROWS  INTO gv_banka
         FROM bnka WHERE banks EQ t001-land1 AND
                         bankl EQ ubnkl ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* fin Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *
*       FROM   znovedadbanco
*      WHERE   sociedad = bukrs
*        AND   banco    = ubnkl
*        AND  estado = '0'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
       FROM   znovedadbanco
      WHERE   sociedad = bukrs
        AND   banco    = ubnkl
        AND  estado = '0' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'SE CANCELA, No hay datos sin procesar, Sociedad: '
                           bukrs ' Banco: ' ubnkl.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*           FROM reguh
*           WHERE identif_pago = znovedadbanco-identif.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
           FROM reguh
           WHERE identif_pago = znovedadbanco-identif ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    bancopropio = reguh-hbkid.
  ENDIF.

  REFRESH: trec,tdev.
* PERFORM actualizar_pagos.
*&---------------------------------------------------------------------*
*&   Invocar actualizacion de ZDOC_PAGOS
*&---------------------------------------------------------------------*
  PERFORM actualizar_pagos.   " " Cambio PYV R01049 Suspendido para pruebas  Octubre 2018
  " Cambio PYV R01049 Liberado para produccion Marzo 2019
*&---------------------------------------------------------------------*
*&   Carga en tabla interna datos de la nomina seleccionada
*&---------------------------------------------------------------------*
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*       FROM   znovedadbanco  UP TO p_lineas ROWS "HCD 20200421
*      WHERE   sociedad = bukrs
*        AND   banco    = ubnkl
** ini - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
*        AND   numlot   IN s_numlot
*        AND   cuenta   IN s_cuenta
*        AND   fecpag   IN s_fecpag
** fin - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
*        AND  estado = '0' .
*
* NEW CODE
  SELECT *

       FROM   znovedadbanco  UP TO p_lineas ROWS "HCD 20200421
      WHERE   sociedad = bukrs
        AND   banco    = ubnkl
* ini - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
        AND   numlot   IN s_numlot
        AND   cuenta   IN s_cuenta
        AND   fecpag   IN s_fecpag
* fin - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
        AND  estado = '0'  ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    MOVE-CORRESPONDING znovedadbanco TO nov.
    APPEND nov.
*&        ORDER BY NUMEMP, IDENTIFICACION, RUTBEN.
  ENDSELECT.
*&---------------------------------------------------------------------*
*&     Pasa a tabla interna con nombres diferentes
*&--------------------------------------------------------------------*
  reg[] = nov[].
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESA_DATOS
*&---------------------------------------------------------------------*
FORM procesa_datos .

*&---------------------------------------------------------------------*
*&     Procesa los datos cargados en tabla interna
*&---------------------------------------------------------------------*
  LOOP AT reg.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = reg-rut_beneficiario+0(8)
      IMPORTING
        output = rut_aux.

    CONCATENATE rut_aux '-'  reg-rut_beneficiario+8(1)  INTO rut_aux.

    IF reg-estado_pago = 'CUSTODIA'.
      IF NOT reg-fecha_estado IS INITIAL.
*         CONCATENATE reg-fecha_estado+0(4) reg-fecha_estado+5(2) reg-fecha_estado+8(2) INTO fecha_aux
        fecha_aux = reg-fecha_estado.
      ELSE.
*         CONCATENATE reg-fecha_recepcion+0(4) reg-fecha_recepcion+5(2) reg-fecha_recepcion+8(2) INTO fecha_aux.
        fecha_aux = reg-fecha_recepcion.
      ENDIF.
      UPDATE reguh
       SET ind_custodia = 'X'
           fecha_custodia = fecha_aux
      WHERE identif_pago = reg-codigo_identificacion
      AND   zstc1 =  rut_aux.
      subrc = sy-subrc.
      PERFORM actualizo_znovedadbanco.
    ELSE.
      IF reg-estado_pago = 'CHEQUE PAGADO'.
        IF NOT reg-fecha_estado IS INITIAL.
*         CONCATENATE reg-fecha_estado+0(4) reg-fecha_estado+5(2) reg-fecha_estado+8(2) INTO fecha_aux.
*        fecha_aux = reg-fecha_estado.  rapp cambio criterio de asignacion de fecha de pago , ya no es fecha estado sino fecha pago
          fecha_aux = reg-fecha_pago.
        ELSE.
*         CONCATENATE reg-fecha_recepcion+0(4) reg-fecha_recepcion+5(2) reg-fecha_recepcion+8(2) INTO fecha_aux.
          fecha_aux = reg-fecha_recepcion.
        ENDIF.
        UPDATE reguh
         SET ind_pago = 'X'
              fecha_pago = fecha_aux
          WHERE identif_pago = reg-codigo_identificacion
          AND   zstc1 =  rut_aux.
        subrc = sy-subrc.
        PERFORM actualizo_znovedadbanco.
      ELSE.
        IF reg-estado_pago = 'CHEQUE DEVUELTO'  OR reg-estado_pago = 'VALE VISTA REINTEGRAD' OR reg-estado_pago = 'RECHAZO'. " HCD 12-10-2022 se agrega RECHAZO
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * INTO reguh
*             FROM reguh
*           WHERE identif_pago = reg-codigo_identificacion
*             AND  zstc1 =  rut_aux
*             AND ( ind_pago = 'X' OR ind_rescatado = 'X' OR ind_devuelto = 'X' OR ind_rechazo = 'X' ).
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  INTO reguh
             FROM reguh
           WHERE identif_pago = reg-codigo_identificacion
             AND  zstc1 =  rut_aux
             AND ( ind_pago = 'X' OR ind_rescatado = 'X' OR ind_devuelto = 'X' OR ind_rechazo = 'X' ) ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc <> 0.
            CLEAR tdev.
            MOVE-CORRESPONDING reg TO tdev.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE *
*                      FROM reguh
*                      WHERE identif_pago = reg-codigo_identificacion
*                        AND  zstc1 =  rut_aux.
*
* NEW CODE
            SELECT *
            UP TO 1 ROWS 
                      FROM reguh
                      WHERE identif_pago = reg-codigo_identificacion
                        AND  zstc1 =  rut_aux ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            IF tdev-vvmcad = 'X'.
              tdev-ctacadmat = reguh-hkont.
              tdev-ctacadmat+9(1) = '8'.
            ELSE.

              CLEAR tdev-ctacadmat.
            ENDIF.
            tdev-estado = 'X'.
            APPEND tdev.
          ELSE.
            subrc = 1.
            PERFORM actualizo_znovedadbanco.
          ENDIF.
        ELSE.
          IF reg-estado_pago = 'CHEQUE RECHAZADO'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE * INTO reguh
*              FROM reguh
*             WHERE identif_pago = reg-codigo_identificacion
*               AND  zstc1 =  rut_aux
*               AND ( ind_pago = 'X' OR ind_rescatado = 'X' OR ind_devuelto = 'X' OR ind_rechazo = 'X' ).
*
* NEW CODE
            SELECT *
            UP TO 1 ROWS  INTO reguh
              FROM reguh
             WHERE identif_pago = reg-codigo_identificacion
               AND  zstc1 =  rut_aux
               AND ( ind_pago = 'X' OR ind_rescatado = 'X' OR ind_devuelto = 'X' OR ind_rechazo = 'X' ) ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            IF sy-subrc <> 0.
              MOVE-CORRESPONDING reg TO trec.
              APPEND trec.
            ELSE.
              subrc = 1.
              PERFORM actualizo_znovedadbanco.
            ENDIF.
          ELSE.                                                        " Cambio PYV R01061
            IF reg-estado_pago = 'REDEPOSITO'.                         " Cambio PYV R01061
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE * INTO reguh                               " Cambio PYV R01061
*                 FROM reguh                                            " Cambio PYV R01061
*                WHERE identif_pago = reg-codigo_identificacion         " Cambio PYV R01061
*                  AND  zstc1 =  rut_aux                                " Cambio PYV R01061
*                  AND ( ind_pago = 'X' OR ind_rescatado = 'X' OR ind_devuelto = 'X' OR ind_rechazo = 'X' ).      
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  INTO reguh                               " Cambio PYV R01061
                 FROM reguh                                            " Cambio PYV R01061
                WHERE identif_pago = reg-codigo_identificacion         " Cambio PYV R01061
                  AND  zstc1 =  rut_aux                                " Cambio PYV R01061
                  AND ( ind_pago = 'X' OR ind_rescatado = 'X' OR ind_devuelto = 'X' OR ind_rechazo = 'X' ) ORDER BY PRIMARY KEY.      

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01" Cambio PYV R01061
              IF sy-subrc <> 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*                SELECT SINGLE * INTO reguh                               " Cambio PYV R01061
*                                FROM reguh                                            " Cambio PYV R01061
*                                WHERE identif_pago = reg-codigo_identificacion         " Cambio PYV R01061
*                                AND  zstc1 =  rut_aux.                                
*
* NEW CODE
                SELECT *
                UP TO 1 ROWS  INTO reguh                               " Cambio PYV R01061
                                FROM reguh                                            " Cambio PYV R01061
                                WHERE identif_pago = reg-codigo_identificacion         " Cambio PYV R01061
                                AND  zstc1 =  rut_aux ORDER BY PRIMARY KEY.                                

                ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01" Cambio PYV R01061
                IF reguh-rzawe =  'T'.                                                                     " Cambio PYV R01061
                  PERFORM actualizar_redeposito.
                ELSE.
                  subrc = 1.                                                                                       " Cambio PYV R01061
                  PERFORM actualizo_znovedadbanco.
                ENDIF.                                                                                   " Cambio PYV R01061
              ELSE.                                                                                              " Cambio PYV R01061
                subrc = 1.                                                                                       " Cambio PYV R01061
                PERFORM actualizo_znovedadbanco.                                                                 " Cambio PYV R01061
              ENDIF.                                                                                             " Cambio PYV R01061
            ENDIF.                                                                                               " Cambio PYV R01061
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  REFRESH tpro.
*
  correlativo = 0.
  IF ubnkl = '037'.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
    SORT tdev .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
    LOOP AT tdev WHERE estado_pago = 'VALE VISTA REINTEGRAD' OR
                       estado_pago = 'CHEQUE DEVUELTO'.          "HCD - 06-05-2020
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM reguh
*            WHERE identif_pago = tdev-codigo_identificacion.  
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM reguh
            WHERE identif_pago = tdev-codigo_identificacion ORDER BY PRIMARY KEY.  

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"HCD 03-04-2020 de cambia obtencion de codigoznovedadbanco-identif.
      IF sy-subrc = 0.
        IF reguh-rzawe = 'V'.
          correlativo =  correlativo + 1.
          tdev-correl =   correlativo.
          MODIFY tdev  INDEX sy-tabix.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CUADRATURA
*&---------------------------------------------------------------------*
FORM cuadratura .
*
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
      int_tabla-montodev = tdev-monto / 100.
*      int_tabla-montodev = tdev-monto / 10000.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM zctarechazobco WHERE bukrs      = bukrs
**                                            AND hbkid_dest = bancopropio
*                                            AND ctacte_bco = int_tabla-ctactedev
*                                            AND rzawe_d    = ''.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM zctarechazobco WHERE bukrs      = bukrs
*                                            AND hbkid_dest = bancopropio
                                            AND ctacte_bco = int_tabla-ctactedev
                                            AND rzawe_d    = '' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        int_tabla-cuentadep = zctarechazobco-hkont_dep.

        SELECT * FROM bsis
                 WHERE bukrs = bukrs
                 AND   hkont = zctarechazobco-hkont_dep
                 AND   blart = 'ZR'
                 AND   wrbtr EQ int_tabla-montodev  "WAJ 22.04.2020
                 AND   budat IN s_feccon            "WAJ 22.04.2020
                 ORDER BY PRIMARY KEY.
*
          IF s_feccon[] IS NOT INITIAL.
            READ TABLE tdep WITH KEY estado_pago  = int_tabla-estado_pago
                                     cuenta_cargo = int_tabla-ctactedev
                                     numero_lote  = int_tabla-lotedev
                                     hkont        = bsis-hkont
                                     budat        = bsis-budat
                                     belnr        = bsis-belnr.
            CHECK sy-subrc NE 0.
          ENDIF.
*
          IF bsis-shkzg = 'H'.
            int_tabla-montopend = int_tabla-montopend + bsis-wrbtr.
          ELSE.
            int_tabla-montopend = int_tabla-montopend - bsis-wrbtr.
          ENDIF.
          tdep-estado_pago     = int_tabla-estado_pago.
          tdep-cuenta_cargo    = int_tabla-ctactedev.
          tdep-numero_lote     = int_tabla-lotedev.
          tdep-fecha_recepcion = int_tabla-fechadev.
          tdep-correl          = int_tabla-correl.
          tdep-secuencia       = tdep-secuencia + 1.
          tdep-hkont           = bsis-hkont.
          tdep-budat           = bsis-budat.
          tdep-belnr           = bsis-belnr.
          tdep-wrbtr           = bsis-wrbtr.
          tdep-shkzg           = bsis-shkzg.
          tdep-gjahr           = bsis-gjahr.
          tdep-estado          = 'X'.
          APPEND tdep.
          CHECK s_feccon[] IS NOT INITIAL.
          EXIT.
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

  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY estado_pago ctactedev lotedev fechadev correl.
*
  CLEAR   gt_outtab.
  REFRESH gt_outtab.
*
  LOOP AT int_tabla.
    MOVE-CORRESPONDING int_tabla TO gt_outtab.
    APPEND gt_outtab.
  ENDLOOP.
*
  CHECK p_proc IS INITIAL.
  REFRESH int_tabla. CLEAR int_tabla.
ENDFORM.                    "Cuadratura_dev

*&---------------------------------------------------------------------*
*&      Form  tabla de novedades de bancos
*&---------------------------------------------------------------------*
FORM actualizo_znovedadbanco.

  IF subrc = 0.
    UPDATE znovedadbanco
        SET estado     = '1'
            fecpro     = sy-datum
        WHERE identif  = reg-codigo_identificacion
        AND   rutben   = reg-rut_beneficiario
        AND   estado   = '0'
        AND   fecrec   = reg-fecha_recepcion.
  ELSE.
    UPDATE znovedadbanco
       SET estado     = '9'
           fecpro     = sy-datum
       WHERE identif  = reg-codigo_identificacion
       AND   rutben   = reg-rut_beneficiario
       AND   estado   = '0'
       AND   fecrec   = reg-fecha_recepcion.
  ENDIF.

ENDFORM.                    "actualizo_novedades banco

*&---------------------------------------------------------------------*
*&      Form  confirma_contabilizacion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM confirma_contabilizacion.

  DATA: l_flag      TYPE c.
  DATA:largo_rut     TYPE i, "HCD 20200615
       ti_dev        TYPE  reg1    OCCURS 0 WITH HEADER LINE,
       ti_dep        TYPE  ty_tdep OCCURS 0 WITH HEADER LINE,
       ti_dev_paso   TYPE  reg1    OCCURS 0 WITH HEADER LINE,
       ti_dep_paso   TYPE  ty_tdep OCCURS 0 WITH HEADER LINE,
       lv_clave_proc TYPE i.
*

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *  FROM zctarechazobco  INTO CORRESPONDING FIELDS OF TABLE tcuenta
*                               WHERE bukrs      = bukrs
**                                 and hbkid_dest = bancopropio
*                               AND   rzawe_d    = ''.
*
* NEW CODE
  SELECT *
  FROM zctarechazobco  INTO CORRESPONDING FIELDS OF TABLE tcuenta
                               WHERE bukrs      = bukrs
*                                 and hbkid_dest = bancopropio
                               AND   rzawe_d    = '' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

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
      LOOP AT tdep  INTO ti_dep
                    WHERE estado_pago     = int_tabla-estado_pago
                    AND   cuenta_cargo    = int_tabla-ctactedev
                    AND   numero_lote     = int_tabla-lotedev
                    AND   fecha_recepcion = int_tabla-fechadev
                    AND   correl          = int_tabla-correl.
        ti_dep-clave_proc = lv_clave_proc.
        APPEND ti_dep.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
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
*
  SET  PF-STATUS 'ZFITR045' EXCLUDING tab.

*  WRITE: /, 'Se Generaron los siguientes Voucher por Pagos Devueltos y Rescatados     '.

  PERFORM contabilizo  TABLES tdev
                       USING 'Pago Dev/Rescatado     '
                              '1'.

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
*      fecha_aux = tpro-fecha_estado.
*    ELSE.
*      fecha_aux = tpro-fecha_recepcion.
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
*    UPDATE znovedadbanco
*        SET estado  = '1'
*            fecpro  = sy-datum
*        WHERE identif = tpro-codigo_identificacion
*        AND   rutben  = tpro-rut_beneficiario
*        AND   estado  = '0'
*        AND   numlot  = tpro-numero_lote
*        AND   fecrec  = tpro-fecha_recepcion.
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

    COMMIT WORK.
  ENDLOOP.
*
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
                                   correl      = int_tabla-correl.
      CHECK sy-subrc EQ 0.
      DELETE gt_outtab INDEX sy-tabix.
    ENDLOOP.
  ENDIF.
*
  tdev[] = ti_dev_paso[].
  tdep[] = ti_dep_paso[].
*
  CALL METHOD g_grid1->refresh_table_display.
ENDFORM.                    "confirma_contabilizacion
*&---------------------------------------------------------------------*
*&      Form  CONTABILIZO_DEVOLUCIONES
*&---------------------------------------------------------------------*
FORM contabilizo   TABLES ti_dat LIKE reg1x
                   USING texto LIKE bkpf-bktxt
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
*
  DATA: largo_rut       TYPE i,
        lv_n1           TYPE i,
        ti_regup        TYPE TABLE OF regup,
        wa_regup        TYPE regup,
        tdat            TYPE reg1,
        lv_rep          Type sy-subrc,
*
        lt_desborde     TYPE TABLE OF ty_desborde,
        lt_clave_proc   TYPE TABLE OF ty_clave_proc,
        lt_doc_desborde TYPE TABLE OF ty_doc_desborde,
        wa_desborde     TYPE ty_desborde,
        wa_clave_proc   TYPE ty_clave_proc,
        wa_doc_desborde TYPE ty_doc_desborde,
*
        lv_tabix        TYPE sy-tabix,
        lt_monto(15)    TYPE p DECIMALS 0,
        lv_posnr        TYPE i,
        lv_posnr_tot    TYPE i,
        lv_dynpro       TYPE char04,
        lv_count        TYPE i,
        lv_tope         TYPE i VALUE '900',
        lv_mensaje      TYPE bapi_msg.
*
  CLEAR gt_salida[].
*
  SORT ti_dat BY clave_proc cuenta_cargo fecha_estado DESCENDING codigo_identificacion.
  CONCATENATE sy-datum sy-uzeit INTO asignacion.
* ACUMULA POR POSICION PARA VERIFICAR SI EL PROCESO TENDRA MAS DE 900 POSICIONES.
  LOOP AT ti_dat INTO tdat.

* identifica el registro de la REGUH
    largo_rut    = strlen( tdat-rut_beneficiario ) - 1.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = tdat-rut_beneficiario+0(largo_rut)
      IMPORTING
        output = rut_aux.
    CONCATENATE rut_aux '-'  tdat-rut_beneficiario+largo_rut(1) INTO rut_aux.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM reguh
*               WHERE identif_pago  = tdat-codigo_identificacion
*               AND   zstc1         =  rut_aux.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM reguh
               WHERE identif_pago  = tdat-codigo_identificacion
               AND   zstc1         =  rut_aux ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
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
*
  lt_monto = 0.
  lv_rep   = 0.
  LOOP AT ti_dat.
    MOVE-CORRESPONDING ti_dat TO tdat.
    lt_monto = lt_monto + tdat-monto.
    AT NEW clave_proc.
      REFRESH: bdcdata, lt_desborde, lt_doc_desborde, itab.
      total = lv_posnr = 0.
      lv_posnr_tot     = lv_tope.
      nuevo            = 'S'.
*
      IF ubnkl = '037' AND tdat-estado_pago = 'VALE VISTA REINTEGRAD' AND tdat-ingres <> 'MANUAL'." HCD 12-10-2022 se agrega RECHAZO
        tipdoc = 'XF'.
      ELSEIF   ubnkl = '016' AND tdat-estado_pago = 'RECHAZO'.
         tipdoc = 'XF'.
      ELSE.
        tipdoc = 'XG'.
      ENDIF.
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
    largo_rut    = strlen( tdat-rut_beneficiario ) - 1."HCD 20200615

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = tdat-rut_beneficiario+0(largo_rut) "tdat-rut_beneficiario+0(8) "HCD 20200615 tdat-rut_beneficiario+0(8)
      IMPORTING
        output = rut_aux.

    CONCATENATE rut_aux '-'  tdat-rut_beneficiario+largo_rut(1) INTO rut_aux. "tdat-rut_beneficiario+8(1) INTO rut_aux. "HCD 20200615tdat-rut_beneficiario+8(1) INTO rut_aux.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT  SINGLE * FROM reguh WHERE identif_pago  = tdat-codigo_identificacion
*                                AND   zstc1         =  rut_aux.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM reguh WHERE identif_pago  = tdat-codigo_identificacion
                                AND   zstc1         =  rut_aux ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
    IF sy-subrc NE 0.
* ini Waldo Alarcón - Visionone - 17-05-2021 - log
*      WRITE: / 'Error No se encontro RUT en REGUH: ',
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
* cambia el valor de la cuenta de compensacion modificando la ultima posicion con el valor 1.
    largo                = strlen( reguh-ubhkt ) - 1.
    reguh-ubhkt+largo(1) = '1'.
*
    SELECT * FROM regup WHERE laufd = reguh-laufd
                          AND laufi = reguh-laufi
                          AND xvorl = reguh-xvorl
                          AND zbukr = reguh-zbukr
                          AND lifnr = reguh-lifnr
                          AND kunnr = reguh-kunnr
                          AND empfg = reguh-empfg
                          AND vblnr = reguh-vblnr
                          ORDER BY PRIMARY KEY.
      IF nuevo = 'S'.
        IF tdat-fecha_estado IS INITIAL.
          CONCATENATE sy-datum+6(2)
                      sy-datum+4(2)
                      sy-datum+0(4) INTO fecha1.
        ELSE.
          CONCATENATE  tdat-fecha_estado+6(2)
                       tdat-fecha_estado+4(2)
                       tdat-fecha_estado+0(4) INTO fecha1.
        ENDIF.

*
        PERFORM f_insert_line USING:
                'X' 'SAPMF05A'    lv_dynpro,
                ' ' 'BDC_CURSOR'  'BKPF-BLART',
                ' ' 'BDC_OKCODE'  '/00',
                ' ' 'BKPF-BLDAT'  fecha1,
                ' ' 'BKPF-BLART'  tipdoc,
                ' ' 'BKPF-BUKRS'  bukrs,
                ' ' 'BKPF-BUDAT'  fecha1,
                ' ' 'BKPF-WAERS'  'CLP',
                ' ' 'BKPF-BKTXT'  texto,
                ' ' 'FS006-DOCID' '*'.

        nuevo = 'N'.
      ENDIF.
*
      IF  regup-shkzg = 'H'.
        PERFORM bdc_field    USING 'RF05A-NEWBS'       '31'.
      ELSE.
        PERFORM bdc_field    USING 'RF05A-NEWBS'       '21'.
      ENDIF.
      PERFORM bdc_field      USING 'RF05A-NEWKO'      reguh-lifnr.

*->   BEG MOD V1-CNN 23.06.2022 ECDK922463
      DATA: lv_importe TYPE dmbtr.
*->   BEG MOD V1-RVY 10.05.2023
      IF reguh-zbukr = 'CL03' AND
        ( reguh-waers = 'UF' OR reguh-waers = 'UF2').
*->   END MOD V1-RVY 10.05.2023

          lv_importe = regup-dmbtr + regup-gdiff.
** V1 RVY INI 26.10.2023
          if lv_importe = 0.
             lv_importe = regup-dmbtr.
          endif.
** V1 RVY FIN 26.10.2023
          WRITE lv_importe CURRENCY 'CLP'  TO valor.
      ELSE.
        WRITE  regup-dmbtr CURRENCY 'CLP'  TO valor.
      ENDIF.
*->   END MOD V1-CNN 23.06.2022 ECDK922463

      IF tdat-fecha_estado IS INITIAL.
        CONCATENATE  tdat-fecha_recepcion+6(2)
                     tdat-fecha_recepcion+4(2)
                     tdat-fecha_recepcion+0(4) INTO fecha.
      ELSE.
        CONCATENATE  tdat-fecha_estado+6(2)
                     tdat-fecha_estado+4(2)
                     tdat-fecha_estado+0(4)    INTO fecha.
      ENDIF.
*
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  * FROM bseg WHERE bukrs = regup-bukrs
*                                  AND  belnr = regup-belnr
*                                  AND  gjahr = regup-gjahr
*                                  AND  buzei = regup-buzei.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM bseg WHERE bukrs = regup-bukrs
                                  AND  belnr = regup-belnr
                                  AND  gjahr = regup-gjahr
                                  AND  buzei = regup-buzei ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
      IF tdat-estado_pago = 'VALE VISTA REINTEGRAD' OR tdat-estado_pago = 'CHEQUE RECHAZADO' OR tdat-estado_pago = 'RECHAZO'.
        READ TABLE tcuenta WITH KEY bukrs      = bukrs
                                    rzawe      = reguh-rzawe
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
        READ TABLE tcuenta WITH KEY bukrs      = bukrs
                                    rzawe      = reguh-rzawe
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

      PERFORM bdc_dynpro      USING 'SAPMF05A'        '0302'.
      PERFORM bdc_field       USING 'BDC_OKCODE'      '=ZK'.
      PERFORM bdc_field       USING 'BSEG-HKONT'      tcuenta-hkont_dest.
      PERFORM bdc_field       USING 'BSEG-WRBTR'      valor.
      PERFORM bdc_field       USING 'BSEG-MWSKZ'      ''.
      PERFORM bdc_field       USING 'BSEG-ZTERM'      'ZC01'.
      PERFORM bdc_field       USING 'BSEG-ZFBDT'      fecha.
      PERFORM bdc_field       USING 'BSEG-ZLSCH'      'C'.
      PERFORM bdc_field       USING 'BSEG-ZUONR'      regup-zuonr.
      PERFORM bdc_field       USING 'BSEG-SGTXT'      texto.
      PERFORM bdc_field       USING 'BSEG-ZZMOT_EMIS' bseg-zzmot_emis.
      PERFORM bdc_field       USING 'BSEG-ZZ_AGENCIA' bseg-zz_agencia.

      IF lv_dynpro EQ '0100'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM lfb1 WHERE lifnr = reguh-lifnr AND
*                                         bukrs = bukrs.
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
            PERFORM bdc_dynpro USING  'SAPLFWTD'                 '0100'.
            PERFORM bdc_field  USING  'BDC_CURSOR'               'WITH_ITEM-WT_WITHCD(01)'.
            PERFORM bdc_field  USING  'BDC_OKCODE'               '/00'.
            PERFORM bdc_field  USING  'WITH_ITEM-WT_WITHCD(01)'  '  '.
          ENDIF.
        ENDIF.
      ENDIF.

      PERFORM bdc_dynpro      USING 'SAPMF05A'        '0332'.
      PERFORM bdc_field       USING 'BDC_CURSOR'      'RF05A-NEWKO'.
      PERFORM bdc_field       USING 'BDC_OKCODE'      '/00'.

      PERFORM bdc_field       USING 'BSEG-HBKID'      tcuenta-hbkid_dest.
      PERFORM bdc_field       USING 'BSEG-HKTID'      tcuenta-hktid_dest.
      PERFORM bdc_field       USING 'BSEG-XREF1'      bseg-xref1.
      PERFORM bdc_field       USING 'BSEG-XREF2'      reguh-vblnr.
*
      ADD 1 TO lv_posnr.
      total = total + regup-dmbtr.
** INI V1 RVY 18-05-2023
      total_sum = total_sum + lv_importe.
** FIN V1 RVY 18-05-2023
    ENDSELECT.
*
** INI V1 RVY 18-05-2023
*    IF reguh-zbukr = 'CL03' AND
*        ( reguh-waers = 'UF' OR reguh-waers = 'UF2').
**       total_des = reguh-rbetr * -1.
*       total_des = TDEP-WRBTR.
*       if total_sum <> total_des.
*          total = total_sum - total_des.
*          if total > 0.
*             PERFORM bdc_field    USING 'RF05A-NEWBS' '21'.
*          else.
*             Total = Total * -1.
*             PERFORM bdc_field    USING 'RF05A-NEWBS' '31'.
*          endif.
*          PERFORM bdc_field   USING 'RF05A-NEWKO'     reguh-lifnr.
*          PERFORM bdc_dynpro  USING 'SAPMF05A'        '0302'.
*          PERFORM bdc_field   USING 'BDC_OKCODE'      '=ZK'.
*          PERFORM bdc_field   USING 'BSEG-HKONT'      tcuenta-hkont_dest.
*          WRITE total CURRENCY 'CLP'  TO valor.
*          PERFORM bdc_field   USING 'BSEG-WRBTR'      valor.
*          PERFORM bdc_field   USING 'BSEG-MWSKZ'      ''.
*          PERFORM bdc_field   USING 'BSEG-ZTERM'      'ZC01'.
*          PERFORM bdc_field   USING 'BSEG-ZFBDT'      fecha.
*          PERFORM bdc_field   USING 'BSEG-ZLSCH'      'C'.
*          PERFORM bdc_field   USING 'BSEG-ZUONR'      regup-zuonr.
*          PERFORM bdc_field   USING 'BSEG-SGTXT'      texto.
*          PERFORM bdc_field   USING 'BSEG-ZZMOT_EMIS' bseg-zzmot_emis.
*          PERFORM bdc_field   USING 'BSEG-ZZ_AGENCIA' bseg-zz_agencia.
*          total = 0.
*          IF lv_dynpro EQ '0100'.
*             SELECT SINGLE * FROM lfb1 WHERE lifnr = reguh-lifnr AND
*                                             bukrs = bukrs.
*             IF sy-subrc = 0.
*                SELECT COUNT(*) INTO cant_imp FROM lfbw
*                                      WHERE lifnr = reguh-lifnr
*                                      AND   bukrs = bukrs.
*                IF cant_imp > 0.
*                   PERFORM bdc_dynpro USING  'SAPLFWTD'       '0100'.
*                   PERFORM bdc_field  USING  'BDC_CURSOR'     'WITH_ITEM-WT_WITHCD(01)'.
*                   PERFORM bdc_field  USING  'BDC_OKCODE'     '/00'.
*                   PERFORM bdc_field  USING  'WITH_ITEM-WT_WITHCD(01)'  '  '.
*                ENDIF.
*             ENDIF.
*          ENDIF.
*          PERFORM bdc_dynpro  USING 'SAPMF05A'        '0332'.
*          PERFORM bdc_field   USING 'BDC_CURSOR'      'RF05A-NEWKO'.
*          PERFORM bdc_field   USING 'BDC_OKCODE'      '/00'.
*          PERFORM bdc_field   USING 'BSEG-HBKID' tcuenta-hbkid_dest.
*          PERFORM bdc_field   USING 'BSEG-HKTID' tcuenta-hktid_dest.
*          PERFORM bdc_field   USING 'BSEG-XREF1' bseg-xref1.
*          PERFORM bdc_field   USING 'BSEG-XREF2' reguh-vblnr.
*       ENDIF.
*    ENDIF.
** FIN V1 RVY 18-05-2023
    CLEAR tpro.
    tpro-codigo_identificacion = tdat-codigo_identificacion.
    tpro-rut_beneficiario      = tdat-rut_beneficiario.
    tpro-fecha_recepcion       = tdat-fecha_recepcion.
    tpro-fecha_estado          = tdat-fecha_estado.
    tpro-estado_pago           = tdat-estado_pago.
    tpro-correl                = tdat-correl.
    tpro-clave_proc            = tdat-clave_proc.
    tpro-numero_lote           = tdat-numero_lote.
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
*      ELSE.
*
*        PERFORM bdc_dynpro      USING 'SAPMF05A'        '0332'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'      '=SL'.
** INI V1 RVY 19-12-23
       ELSE.
         PERFORM bdc_dynpro      USING 'SAPMF05A'        '0332'.
         PERFORM bdc_field       USING 'BDC_OKCODE'      '=SL'.
         Move 1 to lv_rep.
      ENDIF.
** FIN V1 RVY 19-12-23
** INI V1 RVY 29-05-2023
      IF reguh-zbukr = 'CL03' AND
       ( reguh-waers = 'UF' OR reguh-waers = 'UF2').
*       total_des = reguh-rbetr * -1.
** V1 RVY 26-07-23.
*         total_des = TDEP-WRBTR.
*         total_des  = tdat-monto.
         total_des  = lt_monto.
         total_des  = total_des / 100.
** V1 RVY 26-07-23

         if total_sum <> total_des.
            total = total_sum - total_des.
            if total > 0.
               PERFORM bdc_field    USING 'RF05A-NEWBS' '21'.
            else.
               Total = Total * -1.
               PERFORM bdc_field    USING 'RF05A-NEWBS' '31'.
            endif.
            PERFORM bdc_field   USING 'RF05A-NEWKO'     reguh-lifnr.
            PERFORM bdc_dynpro  USING 'SAPMF05A'        '0302'.
            PERFORM bdc_field   USING 'BDC_OKCODE'      '=ZK'.
            PERFORM bdc_field   USING 'BSEG-HKONT'      tcuenta-hkont_dest.
            WRITE total CURRENCY 'CLP'  TO valor.
            PERFORM bdc_field   USING 'BSEG-WRBTR'      valor.
            PERFORM bdc_field   USING 'BSEG-MWSKZ'      ''.
            PERFORM bdc_field   USING 'BSEG-ZTERM'      'ZC01'.
            PERFORM bdc_field   USING 'BSEG-ZFBDT'      fecha.
            PERFORM bdc_field   USING 'BSEG-ZLSCH'      'C'.
            PERFORM bdc_field   USING 'BSEG-ZUONR'      regup-zuonr.
            PERFORM bdc_field   USING 'BSEG-SGTXT'      texto.
            PERFORM bdc_field   USING 'BSEG-ZZMOT_EMIS' bseg-zzmot_emis.
            PERFORM bdc_field   USING 'BSEG-ZZ_AGENCIA' bseg-zz_agencia.
            total = 0.
            IF lv_dynpro EQ '0100'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*               SELECT SINGLE * FROM lfb1 WHERE lifnr = reguh-lifnr AND
*                                               bukrs = bukrs.
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
                     PERFORM bdc_dynpro USING  'SAPLFWTD'       '0100'.
                     PERFORM bdc_field  USING  'BDC_CURSOR'     'WITH_ITEM-WT_WITHCD(01)'.
                     PERFORM bdc_field  USING  'BDC_OKCODE'     '/00'.
                     PERFORM bdc_field  USING  'WITH_ITEM-WT_WITHCD(01)'  '  '.
                  ENDIF.
               ENDIF.
            ENDIF.
            PERFORM bdc_dynpro  USING 'SAPMF05A'        '0332'.
*            PERFORM bdc_field   USING 'BDC_CURSOR'      'RF05A-NEWKO'.
*            PERFORM bdc_field   USING 'BDC_OKCODE'      '/00'.
            PERFORM bdc_field   USING 'BDC_CURSOR'      'BSEG-HKTID'.
            PERFORM bdc_field   USING 'BDC_OKCODE'      '=PA'.
            PERFORM bdc_field   USING 'BSEG-HBKID' tcuenta-hbkid_dest.
            PERFORM bdc_field   USING 'BSEG-HKTID' tcuenta-hktid_dest.
            PERFORM bdc_field   USING 'BSEG-XREF1' bseg-xref1.
            PERFORM bdc_field   USING 'BSEG-XREF2' reguh-vblnr.
         else.
** INI V1 RVY 27-02-2024
            If lv_rep = 0.
               PERFORM bdc_dynpro      USING 'SAPMF05A'        '0332'.
               PERFORM bdc_field       USING 'BDC_OKCODE'      '=SL'.
            endif.
** Fin V1 RVY 27-02-2024
         endif.
*      else.
*         PERFORM bdc_dynpro      USING 'SAPMF05A'        '0332'.
*         PERFORM bdc_field       USING 'BDC_OKCODE'      '=SL'.
      ENDIF.
** FIN V1 RVY 29-05-2023

      DATA(lv_cta) = ''.
      LOOP AT tdep WHERE estado_pago     = tdat-estado_pago
                   AND   cuenta_cargo    = tdat-cuenta_cargo
                   AND   numero_lote     = tdat-numero_lote
                   AND   fecha_recepcion = tdat-fecha_pago
                   AND   correl          = tdat-correl
                   AND   clave_proc      = tdat-clave_proc.

        IF lv_cta IS INITIAL.
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
        PERFORM modifica_xblnr.               "Mod SSYG R01046 201810
*
        COMMIT WORK AND WAIT.
        sy-subrc = 4.
        lv_n1    = 0.
        WHILE sy-subrc NE 0 AND lv_n1 LT 100.
          ADD 1 TO lv_n1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE belnr INTO itab-msgv1
*                 FROM bkpf WHERE bukrs EQ bukrs
*                            AND  belnr EQ belnr
*                            AND  gjahr EQ gjahr.
*
* NEW CODE
          SELECT belnr
          UP TO 1 ROWS  INTO itab-msgv1
                 FROM bkpf WHERE bukrs EQ bukrs
                            AND  belnr EQ belnr
                            AND  gjahr EQ gjahr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        ENDWHILE.
*
        LOOP AT tpro ASSIGNING FIELD-SYMBOL(<campos>)
                     WHERE belnr_dev  IS INITIAL AND
                           clave_proc EQ tdat-clave_proc.
          <campos>-belnr_dev = belnr.
          <campos>-gjahr_dev = gjahr.
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
*
      nuevo  = 'S'.
* continua con el siguiente documento.
      CONTINUE.
    ENDAT.
* SI NO ES TERMINO DEL PROCESO Y SE LLEGO A LA CATIDAD LIMITE DE LIENAS SE GENERA
* DOCUMENTO DE DESBORDE CON LA F-02
    IF lv_posnr GE lv_tope.
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
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE belnr INTO itab-msgv1
*                 FROM bkpf WHERE bukrs EQ bukrs
*                            AND  belnr EQ belnr
*                            AND  gjahr EQ gjahr.
*
* NEW CODE
          SELECT belnr
          UP TO 1 ROWS  INTO itab-msgv1
                 FROM bkpf WHERE bukrs EQ bukrs
                            AND  belnr EQ belnr
                            AND  gjahr EQ gjahr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
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
      IF lv_posnr_tot LT lv_lineas.
        lv_dynpro = '0100'.
      ELSE.
        lv_dynpro = '0122'.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "contabilizar
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZAR_REDEPOSITO
*&---------------------------------------------------------------------*
FORM actualizar_redeposito .
  fecha_aux = reg-fecha.
  UPDATE reguh
     SET  ind_redepo = 'X'
          fecha_redepo = fecha_aux
          glosa_redepo = 'Cambio Via Pago T a V'
          rzawe = 'V'
     WHERE identif_pago = reg-codigo_identificacion
       AND        zstc1 =  rut_aux.

  IF sy-subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM reguh
*          WHERE identif_pago = reg-codigo_identificacion
*         AND        zstc1 =  rut_aux.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM reguh
          WHERE identif_pago = reg-codigo_identificacion
         AND        zstc1 =  rut_aux ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    UPDATE regup
             SET       zlsch = 'V'
          WHERE laufd = reguh-laufd
                           AND   laufi = reguh-laufi
                           AND   xvorl = reguh-xvorl
                           AND   zbukr = reguh-zbukr
                           AND   lifnr = reguh-lifnr
                           AND   kunnr = reguh-kunnr
                           AND   empfg = reguh-empfg
                           AND   vblnr = reguh-vblnr.
  ENDIF.

  IF sy-subrc = 0.
    w_mode = p_fb09. "'N'.
    tcode  = 'FB09'.

    REFRESH bdcdata.
    CLEAR bdcdata.

    PERFORM bdc USING:
         'X' 'SAPMF05L' '0102'            "ingresa al programa
          ,'' 'BDC_CURSOR' 'RF05L-BELNR'        "se posiciona en el centro
          ,'' 'RF05L-BELNR' reguh-vblnr         "asigna el valor al centro
          ,'' 'BDC_CURSOR' 'RF05L-BUKRS'
          ,'' 'RF05L-BUKRS' reguh-zbukr
          ,'' 'BDC_CURSOR' 'RF05L-GJAHR'
          ,'' 'RF05L-GJAHR' reguh-zaldt+0(4)
          ,'' 'BDC_CURSOR' 'RF05L-BUZEI'
          ,'' 'RF05L-BUZEI' '001'
          ,'' 'BDC_OKCODE' '/00'
          ,'X' 'SAPMF05L' '0302'
          ,'' 'BDC_CURSOR' 'BSEG-ZLSCH'
          ,'' 'BSEG-ZLSCH' 'V'
          ,'' 'BDC_CURSOR' 'BSEG-SGTXT'
          ,'' 'BSEG-SGTXT' 'CAMBIA VIA PAGO'
          ,'' 'BDC_OKCODE' '=ZK'
          ,'X' 'SAPMF05L' '1302'
            ,'X' 'SAPMF05L' '0302'
          ,'' 'BDC_OKCODE' '/11'

          .
    CALL TRANSACTION tcode USING bdcdata
                           MODE   w_mode
                           UPDATE 'S'
                           MESSAGES INTO messtab.

    DESCRIBE TABLE messtab LINES v_lineas.
    READ TABLE messtab INDEX v_lineas.

    IF messtab-msgnr EQ '300' OR messtab-msgnr EQ '303' .
      sy-subrc = 0.
    ELSE.
      sy-subrc = 1.
    ENDIF.
  ENDIF.
  IF sy-subrc <> 0.
* ini Waldo Alarcón - Visionone - 17-05-2021 - log
*    WRITE: /'Error al actualizar redeposito : ', reg-codigo_identificacion.

    CLEAR wa_salida.
    MOVE-CORRESPONDING reg TO wa_salida.
    MOVE : gv_tcode                                 TO wa_salida-tcode,
           bukrs                                    TO wa_salida-bukrs,
           ubnkl                                    TO wa_salida-ubnkl,
           rut_aux                                  TO wa_salida-rut_aux,
           'Error al actualizar redeposito FB09: '  TO wa_salida-mensaje,
           sy-uname                                 TO wa_salida-uname,
           sy-datum                                 TO wa_salida-datum,
           sy-uzeit                                 TO wa_salida-uzeit.
    APPEND wa_salida TO gt_salida.
* fin Waldo Alarcón - Visionone - 17-05-2021 - log
  ELSE.
    UPDATE znovedadbanco
        SET estado  = '1'
            fecpro  = sy-datum
        WHERE identif = reg-codigo_identificacion
        AND   rutben  = reg-rut_beneficiario
        AND   estado  = '0'
        AND   fecrec  = reg-fecha_recepcion.
  ENDIF.

ENDFORM.                    " ACTUALIZAR_REDEPOSITO
*&---------------------------------------------------------------------*
*&   Invocar actualización de ZDOC_PAGOS
*&---------------------------------------------------------------------*
FORM actualizar_pagos.
  EXEC SQL.
    connect to 'SAPCSC' as 'con'
  ENDEXEC.

  EXEC SQL.
    set connection 'con'
  ENDEXEC.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*        FROM   znovedadbanco UP TO p_lineas ROWS "WAJ 22.04.2020
*       WHERE   sociedad = bukrs
*         AND   banco    = ubnkl
** ini - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
*         AND   numlot   IN s_numlot
*         AND   cuenta   IN s_cuenta
*         AND   fecpag   IN s_fecpag
** fin - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
*         AND  estado = '0'.
*
* NEW CODE
  SELECT *

        FROM   znovedadbanco UP TO p_lineas ROWS "WAJ 22.04.2020
       WHERE   sociedad = bukrs
         AND   banco    = ubnkl
* ini - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
         AND   numlot   IN s_numlot
         AND   cuenta   IN s_cuenta
         AND   fecpag   IN s_fecpag
* fin - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
         AND  estado = '0' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    EXEC SQL.

      EXECUTE PROCEDURE csc_sap_transfer.prc_novedad_multibanco
 (IN :znovedadbanco-sociedad,
                        IN :znovedadbanco-banco   ,
                        IN :znovedadbanco-fecest  ,
                        IN :znovedadbanco-identif,
                        IN :znovedadbanco-rutemi,
                        IN :znovedadbanco-cuenta,
                        IN :znovedadbanco-nomben ,
                        IN :znovedadbanco-rutben,
                        IN :znovedadbanco-montow,
                        IN :znovedadbanco-numche,
                        IN :znovedadbanco-estpag,
                        IN :znovedadbanco-fecrec,
                        IN :znovedadbanco-numlot,
                        IN :znovedadbanco-fecpro,
                        IN :znovedadbanco-fecpag,
                        IN :znovedadbanco-estado)
    ENDEXEC.

  ENDSELECT.

  EXEC SQL.
    SET CONNECTION DEFAULT
  ENDEXEC.

  EXEC SQL.
    DISCONNECT 'con'
  ENDEXEC.

ENDFORM.                    "actualizar_pagos
*&---------------------------------------------------------------------*
*&      Form  bdc
*&---------------------------------------------------------------------*
FORM bdc  USING    a
      b
      c.

  CLEAR bdcdata.
  IF a = 'X'.
    bdcdata-program   = b.
    bdcdata-dynpro    = c.
    bdcdata-dynbegin  = a.
  ELSE.
    bdcdata-fnam = b.
    WRITE c TO bdcdata-fval LEFT-JUSTIFIED.
  ENDIF.
  APPEND bdcdata.

ENDFORM.                    "bdc
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
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM build_fieldcat CHANGING pt_fieldcat TYPE lvc_t_fcat.
  DATA : ls_fcat   TYPE lvc_s_fcat,
         l_col_pos TYPE lvc_s_fcat-col_pos.
*
  CLEAR pt_fieldcat[].
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZFITR045_EST_001'
    CHANGING
      ct_fieldcat      = pt_fieldcat.
*
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'MENSAJE'.
  ls_fcat-outputlen = 40.
  APPEND ls_fcat TO pt_fieldcat.
*
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'LINSEL'.
  ls_fcat-outputlen = 5.
  APPEND ls_fcat TO pt_fieldcat.
*
  l_col_pos = 5.
  LOOP AT pt_fieldcat INTO ls_fcat.
    ADD 1 TO l_col_pos.
    ls_fcat-col_pos = l_col_pos.
    CASE ls_fcat-fieldname.
      WHEN 'ESTADO_PAGO'.
        ls_fcat-coltext   = 'Estado'.
      WHEN 'CTACTEDEV'.
        ls_fcat-coltext   = 'Cta.Cte.'.
        ls_fcat-outputlen = 10.
      WHEN 'LOTEDEV'.
        ls_fcat-coltext   = 'Lote'.
        ls_fcat-outputlen = 10.
      WHEN 'FECHADEV'.
        ls_fcat-coltext   = 'Fecha Recepción'.
        ls_fcat-outputlen = 15.
      WHEN 'MONTODEV'.
        ls_fcat-coltext    = 'Monto Envio'.
        ls_fcat-currency   = t001-waers.
        ls_fcat-outputlen  = 15.
      WHEN 'CUENTADEP'.
        ls_fcat-coltext   = 'Cta. Depósito'.
      WHEN 'MONTOPEND'.
        ls_fcat-coltext   = 'Monto Depósito'.
        ls_fcat-currency   = t001-waers.
        ls_fcat-outputlen = 15.
      WHEN 'MONTODIF'.
        ls_fcat-coltext   = 'Diferencia'.
        ls_fcat-currency   = t001-waers.
        ls_fcat-outputlen = 10.
      WHEN 'SEL'.
        ls_fcat-col_pos   = 0.
        ls_fcat-checkbox  = 'X'.
        ls_fcat-edit      = 'X'.
        ls_fcat-outputlen = 8.
        ls_fcat-hotspot   = 'X'.
        ls_fcat-coltext   = 'Selección'.
      WHEN 'MENSAJE'.
        ls_fcat-coltext   = 'Mensaje Error'.
      WHEN 'LINSEL'.
        ls_fcat-coltext   = 'Correl'.
        ls_fcat-col_pos   = 1.
      WHEN 'CORREL'.
        ls_fcat-no_out    = 'X'.
        ls_fcat-tech      = 'X'.
    ENDCASE.
    ls_fcat-tooltip    = ls_fcat-coltext.
    ls_fcat-reptext    = ls_fcat-coltext.
    ls_fcat-txt_field  = ls_fcat-coltext.
    ls_fcat-scrtext_l  = ls_fcat-coltext.
    ls_fcat-scrtext_m  = ls_fcat-coltext.
    ls_fcat-scrtext_s  = ls_fcat-coltext.
*
    MODIFY pt_fieldcat FROM ls_fcat.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
FORM exclude_tb_functions CHANGING pt_exclude TYPE ui_functions.
  DATA ls_exclude TYPE ui_func.
*
  CLEAR pt_exclude[].
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_ENTRIES
*&---------------------------------------------------------------------*
FORM select_all_entries CHANGING pt_outtab TYPE STANDARD TABLE.
  DATA: ls_outtab         TYPE ty_outtab,
        lt_filter_entries TYPE lvc_t_fidx.   " Filtered entries
  DATA: l_valid  TYPE c,
        l_locked TYPE c,
        l_linsel TYPE numc05,
        l_tabix  TYPE sy-tabix,                " Index
        lt_color TYPE lvc_t_scol,
        ls_color TYPE lvc_s_scol.
*
  CALL METHOD g_grid1->check_changed_data
    IMPORTING
      e_valid = l_valid.
  IF l_valid EQ 'X'.
*
    CALL METHOD g_grid1->get_filtered_entries
      IMPORTING
        et_filtered_entries = lt_filter_entries.
*
    l_linsel = 0.
    LOOP AT pt_outtab INTO ls_outtab.
      l_tabix = sy-tabix.
      IF ls_outtab-montodif <> '0.00'.
        ls_outtab-mensaje = 'Existen diferencias'.
      ELSE.
        IF ls_outtab-montodev = '0.00' AND ls_outtab-montopend = '0.00'.
          ls_outtab-mensaje = 'Valores en cero'.
        ELSE.
          READ TABLE lt_filter_entries FROM l_tabix TRANSPORTING NO FIELDS.
          IF sy-subrc IS NOT INITIAL.
            ADD 1 TO l_linsel.
            ls_outtab-linsel  = l_linsel.
            ls_outtab-mensaje = ''.
            ls_outtab-sel     = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
*
      IF ls_outtab-mensaje IS NOT INITIAL.
        ls_color-fname     = 'MENSAJE'.
        ls_color-color-col = cl_gui_resources=>list_col_negative.
        ls_color-color-int = 0.
        ls_color-color-inv = 0.
        ls_color-nokeycol  = 'X'.
        APPEND ls_color TO lt_color.
        ls_outtab-color[] = lt_color[].
      ENDIF.
*
      MODIFY pt_outtab FROM ls_outtab.
    ENDLOOP.
    CALL METHOD g_grid1->refresh_table_display.
  ENDIF.
*
  IF l_linsel GE 480.
    gv_error = TEXT-adv.
  ELSE.
    CLEAR gv_error.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL_ENTRIES
*&---------------------------------------------------------------------*
FORM deselect_all_entries  CHANGING pt_outtab TYPE STANDARD TABLE.
  DATA: ls_outtab         TYPE ty_outtab,
        lt_filter_entries TYPE lvc_t_fidx.   " Filtered entries
  DATA: l_valid  TYPE c,
        l_locked TYPE c,
        l_tabix  TYPE sy-tabix,                " Index
        lt_color TYPE lvc_t_scol,
        ls_color TYPE lvc_s_scol.
*
  CALL METHOD g_grid1->check_changed_data
    IMPORTING
      e_valid = l_valid.
  IF l_valid EQ 'X'.
*
    CALL METHOD g_grid1->get_filtered_entries
      IMPORTING
        et_filtered_entries = lt_filter_entries.
*
    LOOP AT pt_outtab INTO ls_outtab.
      l_tabix = sy-tabix.
      PERFORM check_lock USING    ls_outtab
                         CHANGING l_locked.
      IF l_locked IS INITIAL  AND NOT ls_outtab-sel EQ '-'.
        READ TABLE lt_filter_entries FROM l_tabix TRANSPORTING NO FIELDS.
        IF sy-subrc IS NOT INITIAL.
          ls_outtab-sel     = ' '.
          ls_outtab-mensaje = ' '.
          ls_outtab-linsel  = ' '.
          ls_color-fname     = 'MENSAJE'.
          APPEND ls_color TO lt_color.
          ls_outtab-color[] = lt_color[].
        ENDIF.
      ENDIF.
      MODIFY pt_outtab FROM ls_outtab.
    ENDLOOP.
    CLEAR gv_error.
    CALL METHOD g_grid1->refresh_table_display.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_LOCK
*&---------------------------------------------------------------------*
FORM check_lock  USING    ps_outtab TYPE ty_outtab
                 CHANGING p_locked.
  DATA ls_celltab TYPE lvc_s_styl.

  LOOP AT ps_outtab-celltab INTO ls_celltab.
    IF ls_celltab-fieldname = 'SEL'.
      IF ls_celltab-style EQ cl_gui_alv_grid=>mc_style_disabled.
        p_locked = 'X'.
      ELSE.
        p_locked = space.
      ENDIF.
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
    int_tabla2-monto        =  tdev-monto / 100.
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
                  AND correl           EQ ls_outtab-correl
                  AND usado            EQ space. "(*)
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
      PERFORM ajusta_tabla USING ls_outtab 'MD'.  "(*)
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
      fecha_aux = tpro-fecha_estado.
    ELSE.
      fecha_aux = tpro-fecha_recepcion.
    ENDIF.
    IF tpro-estado_pago = 'CHEQUE DEVUELTO'.
      UPDATE reguh
      SET ind_devuelto   = 'X'
          fecha_devuelto = fecha_aux
          belnr_dev      = tpro-belnr_dev
          gjahr_dev      = tpro-gjahr_dev
      WHERE identif_pago = tpro-codigo_identificacion
      AND   zstc1 =  rut_aux.
    ELSE.
      IF tpro-estado_pago = 'VALE VISTA REINTEGRAD'.
        UPDATE reguh
        SET ind_rescatado   = 'X'
            fecha_rescatado = fecha_aux
            belnr_dev       = tpro-belnr_dev
            gjahr_dev       = tpro-gjahr_dev
        WHERE identif_pago  = tpro-codigo_identificacion
        AND   zstc1 =  rut_aux.
      ELSE.
        IF tpro-estado_pago = 'CHEQUE RECHAZADO' or tpro-estado_pago = 'RECHAZO'.
          UPDATE reguh
          SET ind_rechazo    = 'X'
              fecha_rechazo  = fecha_aux
              belnr_dev      = tpro-belnr_dev
              gjahr_dev      = tpro-gjahr_dev
          WHERE identif_pago = tpro-codigo_identificacion
           AND   zstc1 =  rut_aux.
        ENDIF.
      ENDIF.
    ENDIF.

    UPDATE znovedadbanco  SET : estado  = '1'
                                fecpro  = sy-datum
        WHERE identif = tpro-codigo_identificacion
        AND   rutben  = tpro-rut_beneficiario
        AND   estado  = '0'
        AND   numlot  = tpro-numero_lote
        AND   fecrec  = tpro-fecha_recepcion.
*
    COMMIT WORK.
  ENDLOOP.
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
  MOVE : gv_tcode                              TO wa_salida-tcode,
         bukrs                                 TO wa_salida-bukrs,
         ubnkl                                 TO wa_salida-ubnkl,
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
*&      Form  DATOS_REPORTE
*&---------------------------------------------------------------------*
FORM datos_reporte .

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * INTO TABLE gt_salida
*        FROM ztfi_log_pago WHERE tcode EQ gv_tcode
*                          AND    bukrs EQ bukrs
*                          AND    ubnkl EQ ubnkl
*                          AND    datum IN s_datum.
*
* NEW CODE
  SELECT *
 INTO TABLE gt_salida
        FROM ztfi_log_pago WHERE tcode EQ gv_tcode
                          AND    bukrs EQ bukrs
                          AND    ubnkl EQ ubnkl
                          AND    datum IN s_datum ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
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
    ENDCASE.
    <campos>-colddictxt = 'M'.
  ENDLOOP.
ENDFORM.
