*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFITR035_300 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'ZFITR035_3'.
  SET TITLEBAR 'T03'.

ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CASE sy-ucomm.

    WHEN 'CANCELAR'.
      salir = 'NO'.
      LEAVE TO SCREEN 0.

    WHEN 'PROCESAR'.
      PERFORM carga_tabla2_300.
      LEAVE TO SCREEN 0..


  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0300  INPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLA_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_tabla_control_0300 OUTPUT.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
SORT INT_TABLA3 .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
  READ TABLE int_tabla3 INTO zfitr035_est2 INDEX tabla3-current_line.


ENDMODULE.                 " FILL_TABLA_CONTROL_0100  OUTPUT

*----------------------------------------------------------------------*
*  MODULE actualiza_grilla_0300 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE actualiza_grilla_0300 INPUT.
*ReSQ: No Need Of Change Internal Table INT_TABLA3 Already Sorted
  MODIFY int_tabla3 FROM zfitr035_est2 INDEX tabla3-current_line
      TRANSPORTING sel.


ENDMODULE.                 " ACTUALIZA_GRILLA_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  carga_tabla2_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM carga_tabla2_300.
  DATA numero LIKE int_tabla3-nrolinea.
  DATA valor LIKE int_tabla-valor.

  LOOP AT int_tabla3 WHERE sel = 'X'.
    IF int_tabla3-bloqueo = 0.
      valor  = valor   +  int_tabla3-rbetr.
    ENDIF.
  ENDLOOP.

  IF valor <> int_tabla-valor.
    MESSAGE e016(z1) WITH 'Valor seleccionado no cuadra' ' con valor rechazo' .
  ELSE.


    LOOP AT int_tabla3 WHERE sel = 'X'.
      IF int_tabla3-bloqueo = 0.
        MOVE-CORRESPONDING int_tabla3   TO int_tabla2.
        int_tabla2-rut   = int_tabla-rut.
        int_tabla2-lifnr = int_tabla-lifnr.
        int_tabla2-name1 = int_tabla-name1.
        int_tabla2-observacion = int_tabla-observacion.
        int_tabla2-proceso = 'M'.
        numero =  int_tabla-nrolinea.
        monto_i =  monto_i + int_tabla3-rbetr.
        int_tabla2-sel = ''.
        APPEND  int_tabla2.
        monto_p = monto_r  -  monto_i.
      ELSE.
        int_tabla3-sel = ''.
        MODIFY int_tabla3.
      ENDIF.


    ENDLOOP.
    IF numero > 0.
      DELETE int_tabla INDEX xlinea.
    ENDIF.
  ENDIF.

  DESCRIBE TABLE int_tabla LINES fill.
  tabla-lines = fill.
  tabla-top_line = 1.
  DESCRIBE TABLE int_tabla2 LINES fill.
  tabla2-lines = fill.
  tabla2-top_line = 1.

  SORT int_tabla  BY nrolinea .
  SORT int_tabla2 BY nrolinea  .

ENDFORM.                    "carga_tabla2
