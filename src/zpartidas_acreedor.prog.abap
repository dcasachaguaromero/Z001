*&---------------------------------------------------------------------*
*& Report  ZPARTIDAS_ACREEDOR
*&
*&---------------------------------------------------------------------*
*&
*& Reporte de partidas de acreedor
*& Carlos hidalgo - Quintec 26.05.2010
*&---------------------------------------------------------------------*

INCLUDE zpartidas_acreedor_top.
INCLUDE zpartidas_acreedor_f01.


*----------------------------------------------------------------------*
* START-OF-SELECTION                                                   *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  gs_test-repid = sy-repid.

  PERFORM get_description_bukrs
              USING
                 p_bukrs
              CHANGING
                 g_butxt.

  PERFORM select_data.

*----------------------------------------------------------------------*
* END-OF-SELECTION                                                     *
*----------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM display_fullscreen.
