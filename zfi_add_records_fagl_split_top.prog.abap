*&---------------------------------------------------------------------*
*&  Include           ZFI_ADD_RECORDS_FAGL_SPLIT_TOP
*&---------------------------------------------------------------------*

CONSTANTS: gc_tcode TYPE sytcode VALUE 'ZFI_ADD_FAGL'.

TABLES: bkpf.

TYPES: gtr_belnr TYPE RANGE OF belnr_d.

DATA: gr_belnr TYPE gtr_belnr.

DATA: gv_cuenta    TYPE sytabix,
      gv_reg1      TYPE sy-subrc,
      gv_reg2      TYPE sy-subrc,
      gv_reg3      TYPE sy-subrc,
      gv_belnr_del TYPE belnr_d.
