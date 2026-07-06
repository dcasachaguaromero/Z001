*&---------------------------------------------------------------------*
*& Report  ZGENCHEQUES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZGENCHEQUES.
DATA: XSTATUS type flag.
TABLES: PAYR.
PARAMETERS:   XZBUKR           type   PAYR-ZBUKR,
              XHBKID           type   PAYR-HBKID,
              XHKTID           type   PAYR-HKTID,
              XRZAWE           type   PAYR-RZAWE,
              XCHECT           type   PAYR-CHECT.
START-OF-SELECTION.

CALL FUNCTION 'ZINSERT_CHEQUE'
     EXPORTING
          ZBUKR             =  XZBUKR
          HBKID             =  XHBKID
          HKTID             =  XHKTID
          RZAWE             =  XRZAWE
          CHECT             =  XCHECT
     IMPORTING
          STATUS            = XSTATUS
    .


Message S000(IH) with 'Terminado'.
