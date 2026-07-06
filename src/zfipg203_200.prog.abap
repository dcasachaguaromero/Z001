*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&  Include           ZFIPG002_200
**&---------------------------------------------------------------------*
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

ENDMODULE.                             " STATUS_0100  OUTPUT
*
*
**&---------------------------------------------------------------------*
**&      Module  USER_COMMAND_0100  INPUT
**&---------------------------------------------------------------------*
MODULE user_command_0200_exit INPUT.
  CASE sy-ucomm.
    WHEN 'CANCL' .
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300_EXIT  INPUT
***&---------------------------------------------------------------------
***&      Module  FILL_TABLE_CONTROL  OUTPUT
***&---------------------------------------------------------------------
***   Lleno grilla con valores desde tabla
***----------------------------------------------------------------------
**&      Module  FILL_TABLE_CONTROL_0100  OUTPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
MODULE fill_table_control_0200 OUTPUT.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT INT_TABLA1 .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
  READ TABLE int_tabla1 INTO zfipg203_a_est INDEX tabla1-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT

*
