*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION ZFI_F4_T030_SGA.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_XSHOW) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"     VALUE(KTOPL) LIKE  T004-KTOPL OPTIONAL
*"     VALUE(KTOSL) LIKE  T030-KTOSL DEFAULT 'SGA'
*"  EXPORTING
*"     VALUE(SELECT_VALUE) LIKE  T030-BWMOD
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"--------------------------------------------------------------------

*------- Valuetab ------------------------------------------------------
  DATA:  BEGIN OF VALTAB OCCURS 30,
           VALUE LIKE T074T-LTEXT,
         END OF VALTAB.

*------- Initialisierung -----------------------------------------------
  CLEAR SELECT_VALUE.

*------- FLDTAB füllen -------------------------------------------------
  REFRESH: FLDTAB.
  PERFORM FLDTAB_EINTRAGEN USING 'T030'  'KOMOK' 'X'.
  PERFORM FLDTAB_EINTRAGEN USING 'RFCU3' 'KOABZ' ' '.
  PERFORM FLDTAB_EINTRAGEN USING 'T074T' 'LTEXT' ' '.

*------- SHB-Kennzeichen vom Typ 'Sonstige' lesen ----------------------
  REFRESH: VALTAB.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
  SELECT SINGLE * FROM T030B WHERE KTOSL = 'SWE'.
  SELECT * FROM T074U
         WHERE UMSKS NE 'A'.
*        AND   UMSKS NE 'W'.
    IF T074U-UMSKS = 'W'.
      CHECK T074U-UMSKZ = T030B-UMSKZ.
    ENDIF.

*------- ... KOMOK = KOART + UMSKZ -------------------------------------
    VALTAB-VALUE = T074U+3(2).
    APPEND VALTAB.

*------- ... Bezeichnung der Kontoart ----------------------------------
    CASE T074U-KOART.
      WHEN 'D'. PERFORM TEXT_AUS_050T USING '0001' VALTAB-VALUE.
      WHEN 'K'. PERFORM TEXT_AUS_050T USING '0002' VALTAB-VALUE.
      WHEN 'S'. PERFORM TEXT_AUS_050T USING '0006' VALTAB-VALUE.
    ENDCASE.
    APPEND VALTAB.

*------- ... Text zum SHB-Kennzeichen ----------------------------------
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
    SELECT SINGLE * FROM T074T WHERE SPRAS = SY-LANGU
                               AND   KOART = T074U-KOART
                               AND   SHBKZ = T074U-UMSKZ.
    IF SY-SUBRC = 0.
      VALTAB-VALUE = T074T-LTEXT.
    ELSE.
      VALTAB-VALUE = T074U-UMSKZ.
    ENDIF.
    APPEND VALTAB.
  ENDSELECT.

*------- Keine SHB-Kennzeichen vorhanden? ------------------------------
  DESCRIBE TABLE VALTAB LINES SY-TFILL.
  IF SY-TFILL = 0.
    MESSAGE S406 RAISING NOTHING_FOUND.
    EXIT.
  ENDIF.

*------- KOMOK anzeigen ------------------------------------------------
  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
       EXPORTING
            DISPLAY      = I_XSHOW
            FIELDNAME    = 'KOMOK'
            TABNAME      = 'T030'
       IMPORTING
            SELECT_VALUE = SELECT_VALUE
       TABLES
            FIELDS       = FLDTAB
            VALUETAB     = VALTAB.
ENDFUNCTION.
