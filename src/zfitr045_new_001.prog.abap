*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZFITR045_001
*&---------------------------------------------------------------------*


MODULE status_0100 OUTPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
  ENDCASE.

  REFRESH tab.
  MOVE 'CANCL' TO tab-fcode.
  APPEND tab.
  MOVE 'ACTUAL' TO tab-fcode.
  APPEND tab.
  MOVE 'SELECT' TO tab-fcode.
  APPEND tab.
  MOVE 'DESELECT' TO tab-fcode.
  APPEND tab.

  SET  PF-STATUS 'ZFITR045' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0100  OUTPUT

MODULE status_0150 OUTPUT.
*  CASE sy-ucomm.
*    WHEN 'BACK' OR '%EX' OR 'RW'.
*      LEAVE TO SCREEN 0.
*    WHEN '%EX' OR 'RW'.
*      LEAVE PROGRAM.
*  ENDCASE.

  REFRESH tab.
  MOVE 'CANCL' TO tab-fcode.
  APPEND tab.
  MOVE 'ACTUAL' TO tab-fcode.
  APPEND tab.

  SET  PF-STATUS 'ZFITR045' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100_exit INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
  ENDCASE.
  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0100_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA : xlinea LIKE tabla-top_line.

  CASE sy-ucomm.

    WHEN 'CONT'.
      IF  totalbco  <> '0.00' OR  totaldep  <> '0.00'.
        PERFORM confirma_contabilizacion.
      ELSE.
        MESSAGE i004(zfi) WITH 'Debe seleccionar informacion para contabilizar'.
      ENDIF.

    WHEN 'VALIDA'.

      CLEAR: totalbco, totaldep.

      LOOP AT int_tabla.
        IF int_tabla-sel = 'X'.
          totalbco = totalbco + int_tabla-montodev.
          totaldep = totaldep + int_tabla-montopend.
        ENDIF.
      ENDLOOP.

    WHEN 'SEL'.
      GET CURSOR FIELD cursorfield.
      GET CURSOR LINE xlinea.
      IF xlinea > 0 AND xlinea <= tabla-lines .
        xlinea = xlinea + tabla-top_line - 1.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
        SORT int_tabla .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
        READ TABLE int_tabla INDEX xlinea.
        CLEAR sy-ucomm.
        PERFORM detalle.
      ENDIF.

  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

**&---------------------------------------------------------------------
**&      Module  FILL_TABLE_CONTROL  OUTPUT
**&---------------------------------------------------------------------
MODULE fill_table_control_0100 OUTPUT.

*ReSQ: No Need Of Change Internal Table INT_TABLA Already Sorted
  READ TABLE int_tabla INTO zfitr045_est_001 INDEX tabla-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT


*----------------------------------------------------------------------*
*  MODULE valida-grilla_0100 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE valida-grilla_0100 INPUT.

  IF zfitr045_est_001-montodif <> '0.00' AND zfitr045_est_001-sel = 'X'.
    zfitr045_est_001-sel = ''.
    MESSAGE i004(zfi) WITH 'Existen diferencias en linea seleccionada'.
  ELSE.
    IF zfitr045_est_001-montodev = '0.00' AND zfitr045_est_001-montopend = '0.00' AND zfitr045_est_001-sel = 'X'.
      zfitr045_est_001-sel = ''.
      MESSAGE i004(zfi) WITH 'Valores en cero en linea seleccionada'.
    ELSE.
*ReSQ: No Need Of Change Internal Table INT_TABLA Already Sorted
      MODIFY int_tabla FROM zfitr045_est_001 INDEX tabla-current_line
       TRANSPORTING sel.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDA-GRILLA_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  DETALLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detalle .
  REFRESH int_tabla2.

  totalsel  = 0.

  IF  cursorfield = 'ZFITR045_EST_001-MONTODEV'.

    LOOP AT tdev WHERE estado_pago = int_tabla-estado_pago
                 AND   cuenta_cargo = int_tabla-ctactedev
                 AND   numero_lote = int_tabla-lotedev
                 AND   fecha_pago = int_tabla-fechadev
                 AND   correl     = int_tabla-correl.

      int_tabla2-sel   =      tdev-estado.
      int_tabla2-identif_pago =  tdev-codigo_identificacion.
      int_tabla2-rut   = tdev-rut_emisor.
      int_tabla2-nombre = tdev-nombre_beneficiario.
      int_tabla2-estado_pago = tdev-estado_pago.
      int_tabla2-cuentadep = ''.
      int_tabla2-fechacon = ''.
*     int_tabla2-monto =  tdev-monto / 10000.
      int_tabla2-monto =  tdev-monto / 100.
      IF int_tabla2-sel = 'X'.
        totalsel  = totalsel  + int_tabla2-monto.
      ENDIF.
      int_tabla2-correl = tdev-correl.
      APPEND int_tabla2.
    ENDLOOP.

    DESCRIBE TABLE int_tabla2 LINES fill.
    tabla2-lines = fill.
    tabla2-top_line = 1.
    LOOP AT tabla2-cols INTO cols .
      IF sy-tabix = 4 OR
         sy-tabix = 5 OR
         sy-tabix = 6 OR
         sy-tabix = 7.
        cols-invisible = '1'.
      ELSE.
        cols-invisible = '0'.
      ENDIF.
      MODIFY tabla2-cols FROM cols INDEX sy-tabix.
    ENDLOOP.
    SORT int_tabla2 BY identif_pago.
    sw_dato = '1'.
    titulo = 'SELECCIONA PARTIDAS BANCO'.
    CALL SCREEN 200 STARTING AT 25 03 ENDING AT 130 25.
  ELSE.
    IF  cursorfield = 'ZFITR045_EST_001-MONTOPEND'.
      tdep-cuenta_cargo = int_tabla-ctactedev.
      tdep-secuencia = tdep-secuencia + 1.
      LOOP AT tdep  WHERE estado_pago = int_tabla-estado_pago
                    AND  cuenta_cargo = int_tabla-ctactedev
                    AND numero_lote = int_tabla-lotedev
                    AND fecha_recepcion = int_tabla-fechadev
                    AND correl          = int_tabla-correl.
        int_tabla2-sel   =   tdep-estado.
        int_tabla2-identif_pago =  ''.
        int_tabla2-rut   = ''.
        int_tabla2-nombre = ''.
        int_tabla2-cuentadep = tdep-hkont.
        int_tabla2-belnr = tdep-belnr.
        int_tabla2-fechacon = tdep-budat.
        int_tabla2-sec = tdep-secuencia.
        int_tabla2-monto =  tdep-wrbtr .
        int_tabla2-correl = tdep-correl.
        IF int_tabla2-sel = 'X'.
          totalsel  = totalsel  + int_tabla2-monto.
        ENDIF.
        APPEND int_tabla2.
      ENDLOOP.

      DESCRIBE TABLE int_tabla2 LINES fill.
      tabla2-lines = fill.
      tabla2-top_line = 1.
      LOOP AT tabla2-cols INTO cols .
        IF sy-tabix = 1   OR
            sy-tabix = 2 OR
            sy-tabix = 3 .
          cols-invisible = '1'.
        ELSE.
          cols-invisible = '0'.
        ENDIF.
        MODIFY tabla2-cols FROM cols INDEX sy-tabix.
      ENDLOOP.


      SORT int_tabla2 BY cuentadep fechacon sec.
      sw_dato = '2'.
      titulo = 'SELECCIONA PARTIDAS DEPOSITO'.
      CALL SCREEN 200 STARTING AT 25 03 ENDING AT 130 25.
    ENDIF.
  ENDIF.

  REFRESH int_tabla.
  CLEAR int_tabla.

  totalbco = 0.
  totaldep = 0.
  SORT tdev BY estado_pago cuenta_cargo numero_lote fecha_pago correl.
  LOOP AT tdev.
    IF tdev-estado = 'X'.
*      int_tabla-montodev = int_tabla-montodev + tdev-monto / 10000.
      int_tabla-montodev = int_tabla-montodev + tdev-monto / 100.
    ENDIF.
    AT END OF correl.
      MOVE tdev-estado_pago TO int_tabla-estado_pago.
      MOVE tdev-cuenta_cargo TO int_tabla-ctactedev.
      MOVE tdev-numero_lote TO int_tabla-lotedev.
      MOVE tdev-fecha_pago TO int_tabla-fechadev.
      MOVE tdev-correl     TO int_tabla-correl.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM zctarechazobco WHERE bukrs      = bukrs
*                                            AND hbkid_dest = bancopropio
*                                            AND ctacte_bco = int_tabla-ctactedev.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM zctarechazobco WHERE bukrs      = bukrs
                                            AND hbkid_dest = bancopropio
                                            AND ctacte_bco = int_tabla-ctactedev ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        int_tabla-cuentadep = zctarechazobco-hkont_dep.
        LOOP AT tdep     WHERE estado_pago = int_tabla-estado_pago
                         AND   cuenta_cargo = int_tabla-ctactedev
                         AND   numero_lote = int_tabla-lotedev
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
      CLEAR int_tabla.
    ENDAT.
  ENDLOOP.
  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY estado_pago ctactedev lotedev fechadev correl.
  tabla-lines = fill.
  tabla-top_line = 1.

ENDFORM.                    " DETALLE
*&---------------------------------------------------------------------*
*&      Module  PREPARA_REPORTE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE prepara_reporte OUTPUT.
*
  IF g_custom_container IS INITIAL.
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = g_container.
    CREATE OBJECT g_grid1
      EXPORTING
        i_parent = g_custom_container.
*
    PERFORM build_fieldcat       CHANGING gt_fieldcat.
*
    PERFORM exclude_tb_functions CHANGING gt_exclude.
*
    gs_layout-stylefname = 'CELLTAB'.
    gs_layout-ctab_fname = 'COLOR'.

    CALL METHOD g_grid1->set_table_for_first_display
      EXPORTING
        it_toolbar_excluding = gt_exclude
        is_layout            = gs_layout
      CHANGING
        it_fieldcatalog      = gt_fieldcat
        it_outtab            = gt_outtab[].
*
    CREATE OBJECT g_event_receiver.
    SET HANDLER g_event_receiver->catch_hotspot_click FOR g_grid1.
    SET HANDLER g_event_receiver->catch_doubleclick   FOR g_grid1.

* Set editable cells to ready for input initially
    CALL METHOD g_grid1->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0150 INPUT.

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
