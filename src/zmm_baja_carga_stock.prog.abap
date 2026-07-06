*&---------------------------------------------------------------------*
*& Report ZMM_BAJA_CARGA_STOCK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_baja_carga_stock.

INCLUDE zmm_baja_carga_stock_top.
INCLUDE zmm_baja_carga_stock_sel.
INCLUDE zmm_baja_carga_stock_f01.

START-OF-SELECTION.

  CASE gc_x.
    WHEN p_opc1.
      PERFORM baja_stock_mb52.
    WHEN p_opc2.
      PERFORM carga_stock.
  ENDCASE.
