*&---------------------------------------------------------------------*
*&  Include           ZFIMOD_EMIS4_TOP
*&---------------------------------------------------------------------*
INCLUDE ff05lcdv.                "function module BELEG_WRITE_DOCUMENT
INCLUDE ff05lcdf.                "form CD_CALL_BELEG

TYPES: BEGIN OF protocol_line,        "Protocol line
         bukrs      LIKE bseg-bukrs,
         belnr      LIKE bseg-belnr,
         gjahr      LIKE bseg-gjahr,
         buzei      LIKE bseg-buzei,
         zzmot_emis TYPE bseg-zzmot_emis,
       END OF protocol_line.

TYPES: gtt_bkpf TYPE STANDARD TABLE OF bkpf,
       gtt_bseg TYPE STANDARD TABLE OF bseg.

DATA: gt_bkpf     TYPE STANDARD TABLE OF bkpf,
      gt_bseg     TYPE STANDARD TABLE OF bseg,
      gt_fieldcat TYPE slis_t_fieldcat_alv.

DATA: gv_zbukr       TYPE c LENGTH 10,
      gv_vblnr       TYPE c LENGTH 10,
      gv_gjahr       TYPE c LENGTH 10,
      gv_buzei       TYPE c LENGTH 10,
      gv_pageend     TYPE c LENGTH 1 VALUE 'X',
      gv_intensified TYPE c LENGTH 1,
      gv_repid       TYPE syrepid.
