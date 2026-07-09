*&---------------------------------------------------------------------*
*&  Include           ZFI_OB52_REPORTE_TOP
*&---------------------------------------------------------------------*


DATA : BEGIN OF wa_select,
         bname TYPE zfi_ob52_repor-bname,
         bukrs TYPE zfi_ob52_repor-bukrs,
         datum TYPE zfi_ob52_repor-datum,
       END OF wa_select.
*
DATA : gt_datos     TYPE TABLE OF zefi_ob52_repor,
       gt_datos_aud TYPE TABLE OF zefi_ob52_repor_audit,
       gt_tob52     TYPE TABLE OF zfi_ob52_repor,
       gt_t001b     TYPE TABLE OF t001b,
       gt_zt001b    TYPE TABLE OF zfi_ob52_t001b,
       wa_t001b     TYPE t001b,
       wa_zt001b    TYPE zfi_ob52_t001b,
       wa_datos     TYPE zefi_ob52_repor, "zfi_ob52_repor,
       wa_datos_aud TYPE zefi_ob52_repor_audit,
       gv_aprobar   TYPE xflag,
       gv_repid     TYPE sy-repid.
*
FIELD-SYMBOLS <tables> TYPE STANDARD TABLE.
*
CONSTANTS : gc_x         TYPE c LENGTH 01 VALUE 'X',
            gc_tabla     TYPE c LENGTH 30 VALUE 'ZEFI_OB52_REPOR',
            gc_tabla_aud TYPE c LENGTH 30 VALUE 'ZEFI_OB52_REPOR_AUDIT'.
*
CONTROLS: tc_t001b  TYPE TABLEVIEW USING SCREEN 0100.
CONTROLS: tc_zt001b TYPE TABLEVIEW USING SCREEN 0100.
