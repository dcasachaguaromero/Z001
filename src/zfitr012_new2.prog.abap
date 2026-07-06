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
INCLUDE zfitr012_new2_top.
INCLUDE zfitr012_new2_sel.
INCLUDE zfitr012_new2_f01.
INCLUDE zfitr012_new2_001.
INCLUDE zfitr012_new2_002.
*
START-OF-SELECTION.
  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
*
  CASE gc_x.
    WHEN p_opc1.
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
*
      IF gt_salida[] IS NOT INITIAL.
        MODIFY ztfi_log_pago FROM TABLE gt_salida.
        PERFORM mustra_datos.
      ELSE.
        IF NOT observacion IS INITIAL.
          WRITE: /, 'Error en proceso : ',observacion.
        ELSE.
          MESSAGE i004(zfi) WITH 'No se procesarón datos'.
        ENDIF.
      ENDIF.
    WHEN p_opc2.
      PERFORM datos_reporte.
      IF gt_salida[] IS NOT INITIAL.
        PERFORM mustra_datos.
      ELSE.
        MESSAGE i004(zfi) WITH 'No hay datos para la selección'.
      ENDIF.
  ENDCASE.


END-OF-SELECTION.
