*&---------------------------------------------------------------------*
*& Include Z_TXT_DOCUMENTO_TOP                               Report Z_TXT_DOCUMENTO
*&
*&---------------------------------------------------------------------*

REPORT   Z_TXT_DOCUMENTO.

TABLES: BSEG.

TYPES: BEGIN OF WABSEF_TYPE,
         BUKRS LIKE BSEG-BUKRS,
         BELNR LIKE BSEG-BELNR,
         GJAHR LIKE BSEG-GJAHR,
         BUZEI LIKE BSEG-BUZEI,
         SGTXT LIKE BSEG-SGTXT,
         LIFNR LIKE BSEG-LIFNR,
       END OF WABSEF_TYPE.


PARAMETERS: P_BUKRS LIKE BSEG-BUKRS ,
            P_GJAHR LIKE BSEG-GJAHR.

SELECT-OPTIONS: S_BELNR  FOR BSEG-BELNR.

DATA: IT_BSEG TYPE STANDARD TABLE OF WABSEF_TYPE WITH HEADER LINE.
