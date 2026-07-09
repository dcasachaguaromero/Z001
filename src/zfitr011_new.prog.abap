*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <26-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
REPORT zfitr011_new NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132.
INCLUDE zbatchinput.
* ini Waldo Alarcón - Visionone - 11-05-2020 - Ajustes de salida del reporte
INCLUDE zfitr011_new_top.
INCLUDE zfitr011_new_sel.
INCLUDE zfitr011_new_f01.
* ini Waldo Alarcón - Visionone - 11-05-2020 - Ajustes de salida del reporte

INCLUDE zfitr011_new_001. "valores de dynpro 100
INCLUDE zfitr011_new_002. "valores de dynpro 200
*
START-OF-SELECTION.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t001 WHERE bukrs = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
  EXEC SQL.
    connect to 'SAPCSC' as 'con'
  ENDEXEC.
  EXEC SQL.
    set connection 'con'
  ENDEXEC.
  EXEC SQL.
    EXECUTE PROCEDURE prc_tr_act_estados
  ENDEXEC.

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
*
      PERFORM lee_datos.
*
      PERFORM cuadratura.
*
*  CALL SCREEN 100.
      CALL SCREEN 150.
*
      EXEC SQL.
        CLOSE c1
      ENDEXEC.

    CATCH cx_sy_native_sql_error INTO oref.
      observacion = oref->get_text( ).
  ENDTRY.

  EXEC SQL.
    SET CONNECTION DEFAULT
  ENDEXEC.

  IF NOT observacion IS INITIAL.
    WRITE: /, 'Error en proceso : ',observacion.
  ENDIF.

END-OF-SELECTION.
