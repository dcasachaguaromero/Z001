*&---------------------------------------------------------------------*
*& Report ZAFTR0002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zaftr0002.

INCLUDE zaftr0002_top.
INCLUDE zaftr0002_sel.
INCLUDE zaftr0002_f01.

START-OF-SELECTION.

  PERFORM lee_datos.
  PERFORM muestra_datos.
