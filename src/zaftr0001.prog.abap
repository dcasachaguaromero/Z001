*&---------------------------------------------------------------------*
*& Report ZAFTR0001
*&---------------------------------------------------------------------*
*& Autor : Waldo Alarcón                                               *
*% Fecha : 06-07-2020                                                  *
*& Empresa : Visionone                                                 *
*& Descripción : Reporte de Activo Fijo, trazabilidad                  *
*&---------------------------------------------------------------------*
REPORT zaftr0001.

INCLUDE zaftr0001_top.
INCLUDE zaftr0001_sel.
INCLUDE zaftr0001_f01.
INCLUDE zaftr0001_pbo.
INCLUDE zaftr0001_pai.
*
START-OF-SELECTION .
  PERFORM lee_datos.
  PERFORM muestra_datos.
