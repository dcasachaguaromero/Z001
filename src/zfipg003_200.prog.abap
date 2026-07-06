*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_200
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUTS_0200 OUPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  REFRESH tab.
  MOVE 'IMPR' TO tab-fcode.
  APPEND tab.
  MOVE 'REFR' TO tab-fcode.
  APPEND tab.
  MOVE 'ORD1' TO tab-fcode.
  APPEND tab.
  MOVE 'ORD2' TO tab-fcode.
  APPEND tab.

  SET  PF-STATUS 'ZFIPG003' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0200  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200_EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200_exit INPUT.

  CASE sy-ucomm.
    WHEN 'CANCL' .
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200_EXIT  INPUT


*&---------------------------------------------------------------------
*&      Module  FILL_TABLE_CONTROL_0200  OUTPUT
*&---------------------------------------------------------------------
*   Lleno grilla con valores desde tabla
*----------------------------------------------------------------------
MODULE fill_table_control_0200 OUTPUT.

  SORT int_tabla1 .
  READ TABLE int_tabla1 INTO zfipg003_a_est INDEX tabla1-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0200  OUTPUT
