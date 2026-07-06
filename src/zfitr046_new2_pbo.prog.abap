*----------------------------------------------------------------------*
***INCLUDE ZFITR046_NEW_PBO.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  REFRESH tab.
  MOVE 'CANCL' TO tab-fcode.
  APPEND tab.
  MOVE 'ACTUAL' TO tab-fcode.
  APPEND tab.
*
  SET  PF-STATUS 'ZFITR046' EXCLUDING tab.
  SET  TITLEBAR 'T01'.
ENDMODULE.
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
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  REFRESH tab.
  MOVE 'CONT' TO tab-fcode.
  APPEND tab.
  MOVE 'SELECT' TO tab-fcode.
  APPEND tab.
  MOVE 'DESELECT' TO tab-fcode.
  APPEND tab.

  SET  PF-STATUS 'ZFITR046' EXCLUDING tab.
  SET  TITLEBAR 'T01'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLE_CONTROL_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control_0200 OUTPUT.
  READ TABLE int_tabla2 INTO zfitr045_est_002 INDEX tabla2-current_line.
ENDMODULE.
