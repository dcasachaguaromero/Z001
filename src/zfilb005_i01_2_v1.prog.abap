*&---------------------------------------------------------------------*
*&  Include           ZFILB005_I01_2_V1
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

CASE sy-ucomm.
WHEN'OK'.
  SET SCREEN 0.
  WHEN OTHERS.
ENDCASE.
ENDMODULE.
