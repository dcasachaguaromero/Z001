*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION ZFGETDESCCODOPE.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(I_VGTYP) TYPE  VGTYP_EB
*"     REFERENCE(I_VOZPM) TYPE  VOZPM_EB
*"     REFERENCE(I_VGEXT) TYPE  VGEXT_EB
*"  EXPORTING
*"     REFERENCE(E_BUTXT) TYPE  BUTXT_EB
*"----------------------------------------------------------------------

DATA: WA_VGINT TYPE VGINT_EB.

SELECT SINGLE BUTXT INTO (E_BUTXT)
  FROM ZTOPEBANC CLIENT SPECIFIED
  WHERE MANDT = sy-mandt
        AND VGTYP = I_VGTYP
        AND VOZPM = I_VOZPM
        AND VGEXT = I_VGEXT.
  IF SY-SUBRC NE 0.
    SELECT SINGLE VGINT
      INTO (WA_VGINT)
      FROM T028G CLIENT SPECIFIED
      WHERE MANDT = sy-mandt
        AND VGTYP = I_VGTYP
        AND VOZPM = I_VOZPM
        AND VGEXT = I_VGEXT.
      IF SY-SUBRC EQ 0.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES02 ECDK917080 *
        SELECT SINGLE TXT20
          INTO (E_BUTXT)
          FROM T028E CLIENT SPECIFIED
          WHERE MANDT = SY-MANDT
                AND SPRAS = SY-LANGU
                AND VGINT = WA_VGINT.
      ENDIF.
  ENDIF.

ENDFUNCTION.
