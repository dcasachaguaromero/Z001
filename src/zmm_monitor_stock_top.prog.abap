*&---------------------------------------------------------------------*
*&  Include           ZMM_MONITOR_STOCK_TOP
*&---------------------------------------------------------------------*

DATA : BEGIN OF wa_selec,
         matnr TYPE mara-matnr,
         werks TYPE t001l-werks,
         lgort TYPE t001l-lgort,
         mtart TYPE mara-mtart,
         bwart TYPE mseg-bwart,
       END OF wa_selec.
*
DATA : gt_salida TYPE TABLE OF zemm_monitor_stock,
       wa_salida TYPE zemm_monitor_stock,
       gv_repid  TYPE sy-repid.
*
CONSTANTS : gc_x     TYPE c LENGTH 01 VALUE 'X',
            gc_tabla TYPE c LENGTH 30 VALUE 'ZEMM_MONITOR_STOCK'.
*
