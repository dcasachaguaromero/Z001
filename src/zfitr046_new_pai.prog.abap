*----------------------------------------------------------------------*
***INCLUDE ZFITR046_NEW_PAI.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
    WHEN 'SELECT'.
      PERFORM select_all_entries   CHANGING gt_outtab[].
    WHEN 'DESELECT'.
      PERFORM deselect_all_entries CHANGING gt_outtab[].
    WHEN 'CONT'.
      CLEAR: totalbco, totaldep.
      LOOP AT gt_outtab WHERE sel EQ 'X'.
        totalbco = totalbco + gt_outtab-montodev.
        totaldep = totaldep + gt_outtab-montopend.
      ENDLOOP.
*
      IF  totalbco  <> '0.00' OR  totaldep  <> '0.00'.
        PERFORM confirma_contabilizacion.
        SET SCREEN 0.  "salida a la pantalla de seleccion
      ELSE.
        MESSAGE i004(zfi) WITH 'Debe seleccionar informacion para contabilizar'.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDA-GRILLA_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida-grilla_0200 INPUT.

  SORT int_tabla2 .
  MODIFY int_tabla2 FROM zfitr045_est_002  INDEX tabla2-current_line
     TRANSPORTING sel.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'CANCL'.
      LEAVE TO SCREEN 0.
    WHEN 'ACTUAL'.
      PERFORM actualiza_200.
  ENDCASE.

  CLEAR sy-ucomm.
ENDMODULE.
