*&---------------------------------------------------------------------*
*&  Include           ZMM_REPORTE_CONDICION_TOP
*&---------------------------------------------------------------------*

DATA : BEGIN OF wa_selec,
         matnr TYPE matnr,
         lifnr TYPE lifnr,
         ekorg TYPE ekorg,
         datam TYPE datam,
         werks TYPE werks_d,
         esokz TYPE esokz,
         kschl TYPE kscha,
       END OF wa_selec.

DATA : gt_salida TYPE TABLE OF zemm_condicion,
       wa_salida TYPE zemm_condicion,
       gv_repid  TYPE sy-repid.
*
CONSTANTS : gc_x     TYPE c LENGTH 01 VALUE 'X',
            gc_tabla TYPE c LENGTH 30 VALUE 'ZEMM_CONDICION'.
