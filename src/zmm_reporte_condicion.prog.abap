*&---------------------------------------------------------------------*
*& Report ZMM_REPORTE_CONDICION
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_reporte_condicion.


INCLUDE zmm_reporte_condicion_top.
INCLUDE zmm_reporte_condicion_sel.
INCLUDE zmm_reporte_condicion_f01.

START-OF-SELECTION.
  PERFORM lee_datos.
  PERFORM muetra_datos.
