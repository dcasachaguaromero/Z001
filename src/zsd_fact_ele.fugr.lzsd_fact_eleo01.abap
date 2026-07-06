*----------------------------------------------------------------------*
***INCLUDE LZSD_FACT_ELEO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0050  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0050 OUTPUT.
  SET PF-STATUS 'STAT_10'.
  SET TITLEBAR  'T05'.

  IF g_custom_container IS INITIAL.
    " Create CONTAINER object with reference to container name in the screen
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = g_container.
    " Create GRID object with reference to parent name

    CALL METHOD cl_salv_table=>factory
      EXPORTING
        r_container  = g_custom_container
      IMPORTING
        r_salv_table = gr_table
      CHANGING
        t_table      = gt_ref.           "internal table
*   PERFORM prepare_fieldcatalog.
*... set list title

*  write p_fsol to gd_s.
    l_title = 'Referencias'.
    lr_display_settings = gr_table->get_display_settings( ).
    lr_display_settings->set_list_header( l_title ).
*... Enable Generic ALV functions
    gr_functions = gr_table->get_functions( ).
    gr_functions->set_default( ).
* gr_functions->set_all( ).
** set layout
* lr_layout = gr_table->get_layout( ).
** set the Layout Key
* ls_key-report = sy-repid.
* lr_layout->set_key( ls_key ).

* Display table
**********    lr_columns = gr_table->get_columns( ).
*********** optimize output
**********    lr_columns->set_optimize( 'X' ).

* edit ALV columns
    lr_columns = gr_table->get_columns( ).
* optimize output
    lr_columns->set_optimize( 'X' ).


*    TRY.
*        lr_column = lr_columns->get_column( 'CODIGO' ).
*        lr_column->set_long_text( 'Código' ).
*        lr_column->set_medium_text( 'Código' ).
*        lr_column->set_short_text( 'Código' ).
*
*        lr_column = lr_columns->get_column( 'OBSERVACION' ).
*        lr_column->set_long_text( 'Observación' ).
*        lr_column->set_medium_text( 'Observación' ).
*        lr_column->set_short_text( 'Obs.' ).
*
*      CATCH cx_salv_not_found.
*      CATCH cx_salv_existing.
*      CATCH cx_salv_data_error.
*    ENDTRY.

    TRY.
        lr_column = lr_columns->get_column( 'MANDT' ).
        lr_column->set_visible( if_salv_c_bool_sap=>false ).
      CATCH cx_salv_not_found.
    ENDTRY.

    lr_column = lr_columns->get_column( 'FOLIOREF' ).

*   Set the HotSpot for VBELN Column
*    TRY.
*        CALL METHOD lr_column->set_cell_type_column
*          EXPORTING
*            value = if_salv_c_cell_type=>hotspot.
*        .
*      CATCH cx_salv_data_error .
*    ENDTRY.

    gr_table->display( ).
  ELSE.
    gr_table->refresh( ).
  ENDIF.
ENDMODULE.                 " STATUS_0050  OUTPUT
