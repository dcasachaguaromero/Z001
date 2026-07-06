*&---------------------------------------------------------------------*
*& Report ZMM_PRECIOS_MEK1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_precios_mek1.

INCLUDE zmm_precios_mek1_f01.
INCLUDE zmm_precios_mek1_sel.
INCLUDE zmm_precios_mek1_top.

START-OF-SELECTION.
  PERFORM lee_archivo.
  PERFORM muestra_datos.
