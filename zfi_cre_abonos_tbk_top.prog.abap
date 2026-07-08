*&---------------------------------------------------------------------*
*&  Include           ZFI_CRE_ABONOS_TBK_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF gty_t012k,
         bukrs TYPE bukrs,
         hbkid TYPE hbkid,
         hktid TYPE hktid,
         hkont TYPE hkont,
       END OF gty_t012k.

TYPES: gtt_t012k TYPE STANDARD TABLE OF gty_t012k.

CONSTANTS: gc_tcode TYPE sytcode VALUE 'ZFI_CCCAT'.

TABLES: bsis,
        t012k.

DATA: gt_bdcdata TYPE tab_bdcdata,
      gt_t012k   TYPE gtt_t012k.
