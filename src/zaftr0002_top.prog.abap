*&---------------------------------------------------------------------*
*&  Include           ZAFTR0002_TOP
*&---------------------------------------------------------------------*


DATA : BEGIN OF wa_select,
         bukrs TYPE anek-bukrs,
         anln1 TYPE anek-anln1,
         anln2 TYPE anek-anln2,
         afabe TYPE anep-afabe,
         gjahr TYPE anek-gjahr,
         bldat TYPE ekko-bedat,
         budat TYPE anek-budat,
         ebeln TYPE anek-ebeln,
       END OF wa_select.

DATA : gt_salida TYPE TABLE OF zeaf_capex_alv,
       wa_salida TYPE zeaf_capex_alv,
       gv_repid  TYPE sy-repid.


CONSTANTS : gc_x     TYPE c LENGTH 01 VALUE 'X',
            gc_tabla TYPE c LENGTH 30 VALUE 'ZEAF_CAPEX_ALV'.
