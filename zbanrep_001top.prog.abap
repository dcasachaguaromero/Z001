*&---------------------------------------------------------------------*
*& Include ZBANREP_001TOP                                    Report ZBANREP_001
*&
*&---------------------------------------------------------------------*

REPORT   ZBANREP_001.
tables: bseg.

TYPES: BEGIN OF wabsef_type,
         bukrs like bseg-bukrs,
         belnr like bseg-belnr,
         gjahr like bseg-gjahr,
         buzei like bseg-buzei,
         sgtxt like bseg-sgtxt,
       END OF wabsef_type.


PARAMETERS: p_bukrs like bseg-bukrs,
            p_gjahr like bseg-gjahr.

SELECT-OPTIONS: s_belnr for bseg-belnr.
**COMMENT INI
*data: it_bseg type STANDARD TABLE OF wabsef_type WITH HEADER LINE.
**COMMENT FIN
INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
     ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.
