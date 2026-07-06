*----------------------------------------------------------------------*
***INCLUDE MSSCHO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1200  OUTPUT
*&---------------------------------------------------------------------*
module status_1200 output.

 if h_picture is initial.
   create object h_pic_container
          exporting container_name =  'IMAGE_PREVIEW'.
   create object h_picture exporting parent = h_pic_container.

   call method h_picture->set_display_mode
        exporting
             display_mode = cl_gui_picture=>display_mode_normal.
***          display_mode = cl_gui_picture=>display_mode_normal_center.
 endif.

 if graphic_refresh = true.
   call method h_picture->load_picture_from_url
        exporting url    = graphic_url
        importing result = g_result.
   if g_result = cntl_false.
*    message e...
     exit.
   endif.
   graphic_refresh = false.
 endif.


endmodule.                 " STATUS_1200  OUTPUT
