*&---------------------------------------------------------------------*
*&  Include           ZFI_CARGA_MASIVA_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS : slis.

TYPES : BEGIN OF ty_excel,
          key    TYPE char20,
          correl TYPE numc05.
          INCLUDE STRUCTURE zes_fi_carga_masiva.
        TYPES : END OF ty_excel,
        BEGIN OF ty_header.
          INCLUDE STRUCTURE zcabecerav3.
          TYPES : bukrs   TYPE bukrs,
          gjahr   TYPE gjahr,
          belnr01 TYPE belnr_d,
          belnr02 TYPE belnr_d,
          belnr03 TYPE belnr_d,
          belnr04 TYPE belnr_d,
          belnr05 TYPE belnr_d,
          belnr06 TYPE belnr_d,
          belnr07 TYPE belnr_d,
          belnr08 TYPE belnr_d,
          belnr09 TYPE belnr_d,
          belnr10 TYPE belnr_d,
          message TYPE bapi_msg,
          expand,
        END OF ty_header,
        BEGIN OF ty_detalle.
          INCLUDE STRUCTURE zdetallev3.
          TYPES : message TYPE bapi_msg,
        END OF ty_detalle.

DATA : gt_excel     TYPE TABLE OF ty_excel,
       gt_header    TYPE TABLE OF ty_header,
       gt_detalle   TYPE TABLE OF ty_detalle, "zdetallev3,
       gt_return    TYPE TABLE OF bapiret2,
       wa_excel     TYPE ty_excel,
       wa_cabecera  TYPE ty_header,
       wa_detalle   TYPE ty_detalle, "zdetallev3,
       gv_file      TYPE localfile,
       gv_proc      TYPE xflag,
       gv_ok        TYPE xflag,
       gv_num_docum TYPE numc2,
       gv_repid     TYPE syrepid.

CONSTANTS : gc_x      TYPE c LENGTH 01 VALUE 'X',
            gc_tabla1 TYPE c LENGTH 30 VALUE 'ZCABECERAV3',
            gc_tabla2 TYPE c LENGTH 30 VALUE 'ZDETALLEV3',
            gc_tabla3 TYPE c LENGTH 30 VALUE 'BAPIRET2'.
