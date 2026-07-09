*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZMOD_BSEG
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMOD_BSEG_PROD.
TABLES: bseg.
PARAMETERS: BUKRS LIKE bseg-bukrs OBLIGATORY,
            p_BELNR(10) type c OBLIGATORY,
            GJAHR like bseg-gjahr OBLIGATORY,
            BUZEI like bseg-BUZEI OBLIGATORY,
            ZZUNID LIKE BSEG-ZZUNID_PRO MATCHCODE OBJECT ZUNID_PROD OBLIGATORY.
*            ZZMEMI LIKE bseg-ZZMOT_EMIS MATCHCODE OBJECT ZMOT_EMIS OBLIGATORY.
data belnr like bseg-belnr.
START-OF-SELECTION.
MOVE p_belnr to belnr.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT single * from bseg
*  where
*      BUKRS = bukrs
*      and BELNR = belnr
*      and GJAHR = gjahr
*      and BUZEI = buzei.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  from bseg
  where
      BUKRS = bukrs
      and BELNR = belnr
      and GJAHR = gjahr
      and BUZEI = buzei ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc eq 0.
    bseg-ZZUNID_PRO = ZZUNID.
    MODIFY bseg.
    IF SY-SUBRC EQ 0.
      MESSAGE 'Se han aplicado los cambios correctamente' type 'I'.
    ELSE.
      MESSAGE 'Error' type 'E'.
    ENDIF.
  ENDIF.
