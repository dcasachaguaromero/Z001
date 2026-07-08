*&---------------------------------------------------------------------*
*& Report  Z_ACTUALIZA_DEUDOR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_ACTUALIZA_DEUDOR.
TABLES: kna1.
PARAMETERS: p_status type statusflag1.
data: w_sortl like kna1-sortl,
      wa_kna1 type kna1.

START-OF-SELECTION.
IF p_status = 'X'.
  select * from kna1.
*    BREAK-POINT.
    w_sortl = kna1-stcd1.
    REPLACE ALL OCCURRENCES OF '-' IN w_sortl WITH ''.
    kna1-sortl = w_sortl.
    MODIFY kna1.
    CLEAR w_sortl.

   ENDSELECT.
ENDIF.
