*----------------------------------------------------------------------*
***INCLUDE LZFI_OB52O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VERIFICA_PANTALLA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE verifica_pantalla OUTPUT.
  MOVE-CORRESPONDING extract TO zvfi_ob52_t001b.
  IF gv_save EQ 'X'.
    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  CHECK zvfi_ob52_t001b-brgru IS INITIAL.
  LOOP AT SCREEN.
    CHECK screen-group1 EQ 'VER'.
    screen-input = 0.
    MODIFY SCREEN.
  ENDLOOP.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status OUTPUT.
  IF gv_save EQ 'X'.
    APPEND 'SAVE' TO excl_cua_funct.
    APPEND 'ANZG' TO excl_cua_funct.
    APPEND 'NEWL' TO excl_cua_funct.
    APPEND 'KOPE' TO excl_cua_funct.
    APPEND 'DELE' TO excl_cua_funct.
    APPEND 'ORGI' TO excl_cua_funct.
    APPEND 'MKAL' TO excl_cua_funct.
    APPEND 'MKBL' TO excl_cua_funct.
    APPEND 'MKLO' TO excl_cua_funct.
  ENDIF.
ENDMODULE.
