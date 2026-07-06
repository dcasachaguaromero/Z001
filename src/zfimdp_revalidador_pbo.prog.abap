*&---------------------------------------------------------------------*
*&  Include           ZFIMDP_REVALIDADOR_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'ST_0100'.
  SET TITLEBAR 'TXT_0100'.
ENDMODULE.                 " STATUS_0100  OUTPUT

*----------------------------------------------------------------------*
*  MODULE TC_REVALIDA_CHANGE_TC_ATTR OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE tc_revalida_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_data LINES tc_revalida-lines.
ENDMODULE.                    "TC_REVALIDA_CHANGE_TC_ATTR OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_REVALIDA_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
MODULE tc_revalida_get_lines OUTPUT.
  g_tc_revalida_lines = sy-loopc.
ENDMODULE.                 " TC_REVALIDA_GET_LINES  OUTPUT
