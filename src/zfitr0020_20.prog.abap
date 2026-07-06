*&---------------------------------------------------------------------*
*& Report  ZFITR0020_20
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFITR0020_20.

TABLES ZFITR020_T01.

data: ti_ZFITR020_T01 type STANDARD TABLE OF ZFITR020_T01 WITH HEADER LINE.

PARAMETER: p_todo as CHECKBOX.

SELECT-OPTIONS: p_belnr for ZFITR020_T01-BELNR NO INTERVALS,
                p_gjhar  for ZFITR020_T01-GJAHR NO INTERVALS.

if p_todo eq 'X'.
  clear: p_belnr[], p_gjhar[], p_belnr, p_gjhar.
endif.

SELECT * into CORRESPONDING FIELDS OF TABLE ti_ZFITR020_T01
  from ZFITR020_T01
  WHERE BELNR in p_belnr
    and GJAHR in p_gjhar.

LOOP AT ti_ZFITR020_T01.
  delete ZFITR020_T01 from ti_ZFITR020_T01.
ENDLOOP.

MESSAGE 'Proceso terminado' TYPE 'S'.
