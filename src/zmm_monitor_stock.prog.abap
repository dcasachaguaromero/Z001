*&---------------------------------------------------------------------*
*& Report ZMM_MONITOR_STOCK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_monitor_stock.

INCLUDE zmm_monitor_stock_top.
INCLUDE zmm_monitor_stock_sel.
INCLUDE zmm_monitor_stock_f01.

START-OF-SELECTION.
  perform lee_datos.
  perform muestra_datos.
