*&---------------------------------------------------------------------*
*& Report ZFICO_REP04
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfico_rep04.

INCLUDE zfico_rep04_top.
INCLUDE zfico_rep04_sel.
INCLUDE zfico_rep04_f01.

START-OF-SELECTION.
  PERFORM lee_datos.

  IF <tables> IS ASSIGNED.
    PERFORM muestra_datos.
  ELSE.
    MESSAGE i899(fi) WITH 'Sin datos a mostrar'.
  ENDIF.
