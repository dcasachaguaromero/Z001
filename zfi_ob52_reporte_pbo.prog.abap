*&---------------------------------------------------------------------*
*&  Include  ZFI_OB52_REPORTE_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA fcode TYPE TABLE OF sy-ucomm.
*
  CLEAR fcode[].
  IF gv_aprobar IS INITIAL.
    APPEND 'APROBAR'  TO fcode.
    APPEND 'RECHAZAR' TO fcode.
  ENDIF.

  SET PF-STATUS '0100' EXCLUDING fcode.
*  SET TITLEBAR 'xxx'.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_T001B'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_t001b_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_t001b LINES tc_t001b-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_ZT001B'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_zt001b_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_zt001b LINES tc_zt001b-lines.
ENDMODULE.
