*&---------------------------------------------------------------------*
*&  Include           ZFI_BANCO_ACREEDOR_TOP
*&---------------------------------------------------------------------*


*
DATA : gt_salida  TYPE TABLE OF zes_banco_acreedor,
       wa_salida  TYPE zes_banco_acreedor,
       gv_repid   TYPE sy-repid,
       gv_procesa TYPE xflag.
*
CONSTANTS : gc_x     TYPE c LENGTH 01 VALUE 'X',
            gc_tabla TYPE c LENGTH 30 VALUE 'ZES_BANCO_ACREEDOR'.
