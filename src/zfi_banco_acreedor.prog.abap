*&---------------------------------------------------------------------*
*& Report ZFI_BANCO_ACREEDOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_banco_acreedor.

INCLUDE zfi_banco_acreedor_top.
INCLUDE zfi_banco_acreedor_sel.
INCLUDE zfi_banco_acreedor_f01.

START-OF-SELECTION.
  PERFORM leer_archivo_excel.
  PERFORM muestra_datos.
