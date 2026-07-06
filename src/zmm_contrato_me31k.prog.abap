*&---------------------------------------------------------------------*
*& Report ZMM_CONTRATO_ME31K
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_contrato_me31k.

INCLUDE zmm_contrato_me31k_top.
INCLUDE zmm_contrato_me31k_sel.
INCLUDE zmm_contrato_me31k_f01.

START-OF-SELECTION.
  PERFORM lee_archivo.
  PERFORM muestra_datos.
