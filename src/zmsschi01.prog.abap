***INCLUDE MSSCHI01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1200  INPUT
*&---------------------------------------------------------------------*
*       Graphic preview
*----------------------------------------------------------------------*
module user_command_1200 input.

  fcode_old = fcode.
  clear fcode.
  case fcode_old.
    when fcode_print.
         perform graphic_print using c_device_printer.
    when fcode_f12
    or   fcode_f3
    or   fcode_f15.
**       call method h_picture->clear_picture.   " not necessary
         graphic_refresh = true.
         set screen 0.
         leave screen.
  endcase.

endmodule.                 " USER_COMMAND_1200  INPUT

*&---------------------------------------------------------------------*
*&      Module  TEXTNAME_GET  INPUT
*&---------------------------------------------------------------------*
module textname_get input.
  perform textname_get.
endmodule.

*&---------------------------------------------------------------------*
*&      Module  GRAPHICNAME_GET  INPUT
*&---------------------------------------------------------------------*
module graphicname_get input.
  perform graphicname_get.
endmodule.                 " GRAPHICNAME_GET  INPUT
