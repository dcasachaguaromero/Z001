*----------------------------------------------------------------------*
***INCLUDE ZAFTR0001_PAI.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'RETURN' OR 'EXIT'.
*      CALL METHOD gv_custom_container->free.
*      CALL METHOD cl_gui_cfw=>flush.
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ok_code.
ENDMODULE.
