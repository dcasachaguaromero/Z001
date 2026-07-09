*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917093 > *
*&---------------------------------------------------------------------*
FUNCTION zfirfc001_v5.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      TI_CABECERA STRUCTURE  ZCABECERAV5
*"      TI_DETALLE STRUCTURE  ZDETALLEV5
*"      TI_TLOGCABERR STRUCTURE  ZTLOGCABERRV5
*"      TI_TLOGDETERR STRUCTURE  ZTLOGDETERRV5
*"      TI_RESUMEN STRUCTURE  ZRESUMENV5
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  REFRESH: return, return2, currencyamount, accountpayable,
           accountreceivable, accountgl, documentheader, currencyamount,
           extension1, accountwt, accounttax, t_mwdat, ti_cont_det,
           ti_cont_cab, ti_error_det, ti_error_cab, ti_resumen.


  DATA: total LIKE ti_cont_det-amt_doccur.

  DATA: pp_index LIKE sy-tabix.

  DATA: zdetalle_aux LIKE zdetalle.
  DATA: secuencia(1) TYPE n.
  DATA: lineas      LIKE zfirfc02-lineas,
        valord      LIKE zfirfc02-valord,
        valorh      LIKE zfirfc02-valorh,
        gsecuencia  LIKE zfirfc02-secuencia,
        xsecuencia  LIKE zfirfc02-secuencia,
        graba_grupo(1).

* Validación datos de Cabecera y Posicion.
* Verifico si documentos enviados están en proceso.
  CLEAR: t_error.

  LOOP AT  ti_cabecera.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM zfirfc04
*      WHERE bukrs = ti_cabecera-comp_code
*        AND grupo = ti_cabecera-grupo
*        AND zkey  =  ti_cabecera-key.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM zfirfc04
      WHERE bukrs = ti_cabecera-comp_code
        AND grupo = ti_cabecera-grupo
        AND zkey  =  ti_cabecera-key ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF  sy-subrc  = 0.
      t_error = 4.
      return-number            = '1'.
      return-message           = ti_cabecera-key.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'Datos  se encuentra actualmente en proceso'.
      return-message_v2        = zfirfc02-zkey.
      return-message_v3        = 'Número de comprobante externo '.
      return-message_v4        = ti_cabecera-key.
      APPEND return.
    ENDIF.
  ENDLOOP.

  IF t_error = 0.
    LOOP AT  ti_cabecera.
      zfirfc04-bukrs = ti_cabecera-comp_code.
      zfirfc04-grupo = ti_cabecera-grupo.
      zfirfc04-zkey  = ti_cabecera-key.
      zfirfc04-cpudt = sy-datum.
      zfirfc04-cputm = sy-uzeit.
      zfirfc04-uname = ti_cabecera-username.
      INSERT  zfirfc04.
    ENDLOOP.

***
    LOOP AT  ti_cabecera.

      CLEAR: return, t_error.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM zfirfc03
*        WHERE bukrs = ti_cabecera-comp_code
*          AND grupo = ti_cabecera-grupo.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM zfirfc03
        WHERE bukrs = ti_cabecera-comp_code
          AND grupo = ti_cabecera-grupo ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      graba_grupo = 'N'.

      IF sy-subrc = 0.
        graba_grupo = 'S'.
        LOOP AT ti_detalle WHERE key EQ ti_cabecera-key.
          lineas = lineas + 1.
          IF ti_detalle-amt_doccur > '0.0000'.
            valord = valord + ti_detalle-amt_doccur.
          ELSE.
            valorh = valorh + ( ti_detalle-amt_doccur * -1 ).
          ENDIF.
        ENDLOOP.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM zfirfc02
*          WHERE bukrs = ti_cabecera-comp_code
*            AND grupo = ti_cabecera-grupo
*            AND lineas = lineas
*            AND valord = valord
*            AND valorh = valorh.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM zfirfc02
          WHERE bukrs = ti_cabecera-comp_code
            AND grupo = ti_cabecera-grupo
            AND lineas = lineas
            AND valord = valord
            AND valorh = valorh ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc = 0.
          SELECT MAX( secuencia ) INTO gsecuencia
            FROM zfirfc02 WHERE bukrs = ti_cabecera-comp_code
              AND    grupo  = ti_cabecera-grupo
              AND    lineas = lineas
              AND    valord = valord
              AND    valorh = valorh.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM zfirfc02
*            WHERE  bukrs     = ti_cabecera-comp_code
*              AND  grupo     = ti_cabecera-grupo
*              AND  lineas    = lineas
*              AND  valord    = valord
*              AND  valorh    = valorh
*              AND  secuencia = gsecuencia.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM zfirfc02
            WHERE  bukrs     = ti_cabecera-comp_code
              AND  grupo     = ti_cabecera-grupo
              AND  lineas    = lineas
              AND  valord    = valord
              AND  valorh    = valorh
              AND  secuencia = gsecuencia ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          IF ti_cabecera-recarga <> 'R'.
            t_error = 4.
            return-number            = '1'.
            return-message           = ti_cabecera-key.
            return-type              = 'E'.
            return-id                = '01'.
            return-message_v1        = 'Datos ya se encuentran contabilizados con key'.
            return-message_v2        = zfirfc02-zkey.
            return-message_v3        = 'Número de comprobante externo '.
            return-message_v4        = ti_cabecera-key.
            APPEND return.
            SELECT MAX( secuencia ) INTO xsecuencia
              FROM zfirfc01
              WHERE bukrs  =  ti_cabecera-comp_code
                AND grupo  =  ti_cabecera-grupo
                AND zkey   =  zfirfc02-zkey.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*            SELECT * FROM zfirfc01
*              WHERE bukrs       =  ti_cabecera-comp_code
*                AND   grupo     =  ti_cabecera-grupo
*                AND   zkey      =  zfirfc02-zkey
*                AND   secuencia = xsecuencia.
*
* NEW CODE
            SELECT *
 FROM zfirfc01
              WHERE bukrs       =  ti_cabecera-comp_code
                AND   grupo     =  ti_cabecera-grupo
                AND   zkey      =  zfirfc02-zkey
                AND   secuencia = xsecuencia ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
              ti_resumen-key       =   zfirfc01-zkey.
              ti_resumen-grupo     =   zfirfc01-grupo.
              ti_resumen-secuencia =   zfirfc01-secuencia.
              ti_resumen-linead    =   zfirfc01-linead.
              ti_resumen-lineah    =   zfirfc01-lineah.
              ti_resumen-ref       =   ti_cabecera-ref_doc_no.
              ti_resumen-con_pos   =   0.
              ti_resumen-estado    =   '0'.
              ti_resumen-n_sap     =   zfirfc01-belnr.
              APPEND   ti_resumen.
            ENDSELECT.
          ENDIF.
        ENDIF.

        zfirfc02-bukrs = ti_cabecera-comp_code.
        zfirfc02-grupo = ti_cabecera-grupo.
        zfirfc02-lineas = lineas.
        zfirfc02-valord = valord.
        zfirfc02-valorh = valorh.
        zfirfc02-secuencia = gsecuencia + 1.
        zfirfc02-zkey = ti_cabecera-key.
        zfirfc02-datum = sy-datum.
        zfirfc02-uzeit = sy-uzeit.
        zfirfc02-usuario = ti_cabecera-username.
      ENDIF.

      IF t_error EQ 0.
        PERFORM val_cab TABLES    return ti_resumen
                        USING     ti_cabecera
                        CHANGING  t_error.
      ENDIF.

      IF t_error EQ 0.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917093 *
SORT TI_CONT_CAB .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917093 *
        LOOP AT ti_detalle WHERE key EQ ti_cabecera-key.
          CLEAR: return.
          PERFORM val_detalle TABLES return
                              USING  ti_cabecera
                              CHANGING  ti_detalle t_error.
          IF t_error EQ 0.
            MOVE-CORRESPONDING ti_cabecera TO ti_cont_cab.
            READ TABLE ti_cont_cab WITH KEY key = ti_cabecera-key.
            pp_index = sy-tabix.
            IF sy-subrc NE 0.
              APPEND ti_cont_cab.
            ELSE.
              MODIFY ti_cont_cab INDEX pp_index.
            ENDIF.
            MOVE-CORRESPONDING  ti_detalle TO ti_cont_det.
            APPEND ti_cont_det.
          ELSE.
            MOVE-CORRESPONDING  ti_detalle TO ti_error_det.
            APPEND ti_error_det.
            CLEAR: ti_error_det.
          ENDIF.
        ENDLOOP.
      ELSE.
        MOVE-CORRESPONDING  ti_cabecera TO ti_error_cab.
        APPEND ti_error_cab.
        CLEAR: ti_error_cab.
      ENDIF.
      CLEAR:  t_error.
    ENDLOOP.

    PERFORM procesa_error TABLES ti_error_cab
                                 ti_error_det
                                 ti_cont_cab
                                 ti_cont_det
                                 ti_tlogcaberr
                                 ti_tlogdeterr
                                 ti_resumen
                                 return
                                 ti_detalle.
    REFRESH: return.
    CLEAR:   return.
    DATA: cont_reg TYPE i.

    DESCRIBE TABLE ti_cont_cab LINES  cont_reg.
    IF cont_reg > 0.
*     Determinación de tipo de contabilización.
      PERFORM dertmina_gl_ap_rr.

*     Contabilización de Documentos.
      SORT ti_cont_det BY key itemno_acc.
      DATA: contador(3) TYPE n.

      LOOP AT ti_cont_cab.
        CLEAR: contador, t_error, total.
        CLEAR zfirfc01.
        SELECT MAX( secuencia ) INTO (secuencia)
          FROM zfirfc01 WHERE bukrs  =  ti_cont_cab-comp_code
            AND grupo     =  ti_cont_cab-grupo
            AND zkey      =  ti_cont_cab-key.
        zfirfc01-bukrs     =  ti_cont_cab-comp_code.
        zfirfc01-grupo     =  ti_cont_cab-grupo.
        zfirfc01-zkey      =  ti_cont_cab-key.
        zfirfc01-secuencia =  secuencia + 1.

        LOOP AT ti_cont_det WHERE key EQ ti_cont_cab-key.
          IF zfirfc01-linead IS INITIAL.
            zfirfc01-linead = ti_cont_det-itemno_acc.
          ENDIF.
          zfirfc01-lineah = ti_cont_det-itemno_acc.

          ADD 1 TO contador.
          ti_cont_det-itemno_acc = contador.

          PERFORM contabilizacion.
          total = total + ti_cont_det-amt_doccur.
          IF contador > 889.
            IF NOT total IS INITIAL.
              CLEAR ti_cont_det.
              ADD 1 TO contador.
              ti_cont_cab-key = zdetalle_aux-key.
              ti_cont_det-hkont = '9000000008'.
              ti_cont_det-tipo  = 'GL'.
              ti_cont_det-itemno_acc = contador.
              ti_cont_det-amt_doccur = total * -1.
              ti_cont_det-currency   = 'CLP'.
              PERFORM contabilizacion.
            ENDIF.
            PERFORM ejecuta_bapi   TABLES    return
                                             ti_resumen
                                   USING     contador
                                   CHANGING  t_error.
            IF total IS INITIAL.
              CLEAR: contador, total.
            ELSE.
              contador = 1.
              ti_cont_det-itemno_acc = contador.
              ti_cont_det-amt_doccur = total.
              PERFORM contabilizacion.
              total =   ti_cont_det-amt_doccur.
            ENDIF.
          ENDIF.

          IF  t_error = 4.
            EXIT.
          ENDIF.

        ENDLOOP.

        IF  t_error = 0.
          IF contador > 0.
            PERFORM ejecuta_bapi TABLES  return
                                         ti_resumen
                                 USING  contador
                                 CHANGING  t_error.
            CLEAR: contador, total.
          ENDIF.
        ENDIF.

        IF  t_error = 0.
          DELETE FROM zfirfc04 WHERE bukrs = ti_cont_cab-comp_code
                                AND grupo  = ti_cont_cab-grupo
                                AND zkey   = ti_cont_cab-key.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

          IF graba_grupo = 'S'.
            INSERT  zfirfc02.
          ENDIF.

        ENDIF.

      ENDLOOP.
    ENDIF.

    LOOP AT  ti_cabecera.
      DELETE FROM   zfirfc04 WHERE bukrs = ti_cabecera-comp_code
                             AND   grupo  = ti_cabecera-grupo
                             AND   zkey   = ti_cabecera-key.
      COMMIT WORK.
    ENDLOOP.

  ENDIF.

  REFRESH: ti_cabecera,ti_detalle.

ENDFUNCTION.
