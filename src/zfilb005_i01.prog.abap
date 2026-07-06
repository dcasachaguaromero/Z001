*&---------------------------------------------------------------------*
*&  Include           ZFILB005_I01
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

CASE sy-ucomm.
WHEN'OK'.
  SET SCREEN 0.
  WHEN OTHERS.
ENDCASE.
ENDMODULE.
