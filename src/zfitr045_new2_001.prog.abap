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
MODULE status_0150 OUTPUT.

  REFRESH tab.
  MOVE 'CANCL' TO tab-fcode.
  APPEND tab.
  MOVE 'ACTUAL' TO tab-fcode.
  APPEND tab.

  SET  PF-STATUS 'ZFITR045' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0150  OUTPUT

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
