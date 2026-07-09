*&---------------------------------------------------------------------*
*&  Include           ZDTE_DOC_REC_MONITOR_O01
*&---------------------------------------------------------------------*

MODULE status_2000 OUTPUT.

  SET PF-STATUS 'PROTOK2'.
  SET TITLEBAR 'PR2'.

ENDMODULE.                             " STATUS_2000  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  PROT  OUTPUT
*&---------------------------------------------------------------------*
*       Process Log
*----------------------------------------------------------------------*
MODULE prot OUTPUT.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.

  SKIP 1.
  PERFORM protokoll.

ENDMODULE.                             " LIST_TABLE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_2001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2001 OUTPUT.
  SET PF-STATUS '2001'.
  SET TITLEBAR 'T01'.

ENDMODULE.                 " STATUS_2001  OUTPUT
