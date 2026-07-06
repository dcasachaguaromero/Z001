*&---------------------------------------------------------------------*
*&  Include           ZMM_PUR_RP_COMPRAS_TOP
*&---------------------------------------------------------------------*
CONSTANTS: gc_tcode TYPE sy-tcode VALUE 'ZMM009'.

TYPES: BEGIN OF gty_t001,
         bukrs TYPE bukrs,
         butxt TYPE butxt,
         paval TYPE paval,
       END OF gty_t001.

TYPES: BEGIN OF gty_po,
         ebeln TYPE ebeln,
         bedat TYPE ebdat,
         bukrs TYPE bukrs,
         lifnr TYPE lifnr,
         waers TYPE waers,
         ernam TYPE ernam,
         aedat TYPE aedat,
         ebelp TYPE ebelp,
         matnr TYPE matnr,
         menge TYPE bstmg,
         meins TYPE meins,
         netpr TYPE bprei,
         netwr TYPE bwert,
         werks TYPE ewerk,
         txz01 TYPE txz01,
         pstyp TYPE pstyp,
         name1 TYPE name1_gp,
*        maktx TYPE maktx,
         verpr TYPE verpr,
         paval TYPE paval,
       END OF gty_po.

TYPES: BEGIN OF gty_lib,
         ebeln    TYPE ebeln,
         username TYPE cdusername,
         udate    TYPE cddatum,
         utime    TYPE cduzeit,
       END OF gty_lib.

TYPES: BEGIN OF gty_ekbe,
         ebeln TYPE ebeln,
         ebelp TYPE ebelp,
         bwart TYPE bwart,
         vgabe TYPE vgabe,
         bewtp TYPE bewtp,
         xblnr TYPE xblnr1,
         budat TYPE budat,
         matnr TYPE matnr,
         menge TYPE menge_d,
         wrbtr TYPE wrbtr,
         waers TYPE waers,
         belnr TYPE mblnr,
         gjahr TYPE gjahr,
         bldat TYPE bldat,
       END OF gty_ekbe.

TYPES: gtt_po   TYPE STANDARD TABLE OF gty_po,
       gtt_sal  TYPE STANDARD TABLE OF zmm_rp_compras_alv,
       gtt_lib  TYPE STANDARD TABLE OF gty_lib,
       gtt_ekbe TYPE STANDARD TABLE OF gty_ekbe.

TABLES: ekko,
        ekpo.

DATA: gs_layout  TYPE slis_layout_alv,
      gx_variant TYPE disvariant,
      gs_variant TYPE disvariant.

DATA: gt_t001 TYPE STANDARD TABLE OF gty_t001,
      gt_po   TYPE gtt_po,
      gt_sal  TYPE gtt_sal,
      gt_lib  TYPE gtt_lib,
      gt_ekbe TYPE gtt_ekbe.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gt_events   TYPE slis_t_event.

DATA: gv_repid TYPE syrepid,
      gv_save  TYPE c LENGTH 1,
      gv_exit  TYPE c LENGTH 1.
