*&---------------------------------------------------------------------*
*& Report ZFI_F110_MOT_EMIS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_f110_mot_emis.

INCLUDE zfi_f110_mot_emis_top.
INCLUDE zfi_f110_mot_emis_sel.
INCLUDE zfi_f110_mot_emis_f01.

START-OF-SELECTION.
*  PERFORM procesa_datos.
  PERFORM procesa_datos_funcion.
  PERFORM muestra_datos.
