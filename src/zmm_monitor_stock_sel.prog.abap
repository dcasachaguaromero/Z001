*&---------------------------------------------------------------------*
*&  Include           ZMM_MONITOR_STOCK_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : s_matnr FOR wa_selec-matnr,
                 s_werks FOR wa_selec-werks,
                 s_lgort FOR wa_selec-lgort,
                 s_mtart FOR wa_selec-mtart,
                 s_bwart FOR wa_selec-bwart.
SELECTION-SCREEN END OF BLOCK block1.

AT SELECTION-SCREEN ON s_bwart.
  IF s_bwart[] IS INITIAL.
    MESSAGE e899(mm) WITH 'Ingrese al menos una Clase de Movimiento'.
  ENDIF.
