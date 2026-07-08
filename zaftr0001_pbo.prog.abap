*----------------------------------------------------------------------*
***INCLUDE ZAFTR0001_PBO.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
*
  SET PF-STATUS 'MAIN100'.
  IF gv_custom_container IS INITIAL.

    CREATE OBJECT gv_custom_container
      EXPORTING
        container_name              = gv_cont_on_dialog
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.
    IF sy-subrc NE 0.
* add your handling, for example
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          titel = gv_repid
          txt2  = sy-subrc
          txt1  = 'El TabControl no puede ser creado'(e01).
    ENDIF.
* create an instance of alv control
    CREATE OBJECT gv_grid
      EXPORTING
        i_parent = gv_custom_container.
*
    CONCATENATE TEXT-m01 wa_salida-anln1
             INTO gs_layout-grid_title SEPARATED BY space.
*
    PERFORM mask_columns TABLES gt_fieldcat.

    CALL METHOD gv_grid->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout
      CHANGING
        it_fieldcatalog = gt_fieldcat[]
        it_outtab       = gt_datos.

    CREATE OBJECT lv_event_receiver.
    SET HANDLER lv_event_receiver->handle_hotspot_click FOR gv_grid.
  ELSE.
    CALL METHOD gv_grid->refresh_table_display.
  ENDIF.
  CALL METHOD cl_gui_control=>set_focus EXPORTING control = gv_grid.
  CALL METHOD cl_gui_cfw=>flush.
ENDMODULE.
