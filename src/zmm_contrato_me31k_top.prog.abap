*&---------------------------------------------------------------------*
*&  Include           ZMM_CONTRATO_ME31K_TOP
*&---------------------------------------------------------------------*


DATA : gt_table TYPE TABLE OF zes_me31k,
       gv_proc  TYPE xflag,
       gv_repid TYPE sy-repid.
*
CONSTANTS : gc_x     TYPE c LENGTH 01 VALUE 'X',
            gc_tabla TYPE c LENGTH 30 VALUE 'ZES_ME31K'.
