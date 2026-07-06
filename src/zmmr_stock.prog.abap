*&---------------------------------------------------------------------*
*& Report ZMMR_STOCK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmmr_stock.

INCLUDE zmmr_stock_top.
INCLUDE zmmr_stock_sel.
INCLUDE zmmr_stock_f01.

START-OF-SELECTION.
  PERFORM lee_datos.
  PERFORM muestra_datos.
