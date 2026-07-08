*&---------------------------------------------------------------------*
*&  Include           ZFI_F110_MOT_EMIS_TOP
*&---------------------------------------------------------------------*
TABLES : f110v,
         reguh.
*
DATA : gt_salida TYPE TABLE OF zes_f110_mot_emis,
       wa_salida TYPE zes_f110_mot_emis,
       gv_repid  TYPE syrepid.
*
CONSTANTS : gc_x     TYPE c LENGTH 01 VALUE 'X',
            gc_tabla TYPE c LENGTH 30 VALUE 'ZES_F110_MOT_EMIS'.
