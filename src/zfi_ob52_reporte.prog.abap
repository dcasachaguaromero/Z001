*&---------------------------------------------------------------------*
*& Report ZFI_OB52_REPORTE
*&---------------------------------------------------------------------*
*& Author: WALDO ALARCON   (VISIONONE)                                 *
*& Description: REPORTE DE PERIODOS CONTABLES POR APROBAR              *
*& Date: 22-03-2022                                                    *
*& MODIFICACIONES:                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zfi_ob52_reporte.

INCLUDE zfi_ob52_reporte_top.
INCLUDE zfi_ob52_reporte_sel.
INCLUDE zfi_ob52_reporte_pbo .
INCLUDE zfi_ob52_reporte_pai .
INCLUDE zfi_ob52_reporte_f01.

START-OF-SELECTION.

  PERFORM lee_datos.

  IF <tables> IS ASSIGNED.
    PERFORM muestra_datos.
  ELSE.
    MESSAGE i899(fi) WITH 'Sin datos a mostrar'.
  ENDIF.
