*&---------------------------------------------------------------------*
*& Report ZFICO_REP05
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfico_rep05.

INCLUDE zfico_rep05_top.
INCLUDE zfico_rep05_sel.
INCLUDE zfico_rep05_f01.

START-OF-SELECTION.
  PERFORM lee_datos.

  IF <tables> IS ASSIGNED.
    PERFORM muestra_datos.
  ELSE.
    IF gt_rep05[] IS INITIAL.
      MESSAGE i899(fi) WITH 'Configurar grupo de Sociedades,'
                            'o sin autorizacion a ver sociedades'.
    ELSE.
      MESSAGE i899(fi) WITH 'Sin datos a mostrar'.
    ENDIF.
  ENDIF.
