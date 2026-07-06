*&---------------------------------------------------------------------*
*& Report: ZFITR004_WS copia del programa ZFITR004                     *
*& Author:  Waldo Alarcón                                              *
*& Description: Se ajusta programa para enviar los datos por Portal del*
*&              BCI                                                    *
*& Date: <25-03-2025>                                                  *
*& Transport Number: <   >                                             *
*&---------------------------------------------------------------------*
REPORT zfitr004_ws NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132 .

INCLUDE zfitr004_ws_top.
INCLUDE zfitr004_ws_sel.
INCLUDE zfitr004_ws_f01.
*
START-OF-SELECTION.

  CASE gc_x.
    WHEN p_proc.
      PERFORM cargo_datos.
      IF int_tabla[] IS NOT INITIAL.
        CALL SCREEN 100.
      ELSE.
        MESSAGE e899(fi) WITH 'Sin datos encontrados'.
      ENDIF.
    WHEN p_repo.
      PERFORM lee_datos.
      PERFORM muestra_datos.
  ENDCASE.
