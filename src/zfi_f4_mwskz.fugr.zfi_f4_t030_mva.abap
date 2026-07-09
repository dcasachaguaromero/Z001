*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION ZFI_F4_T030_MVA.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_XSHOW) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"     VALUE(KTOPL) LIKE  T004-KTOPL OPTIONAL
*"     VALUE(KTOSL) LIKE  T030-KTOSL DEFAULT 'MVA'
*"  EXPORTING
*"     VALUE(SELECT_VALUE) LIKE  T030-BWMOD
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"--------------------------------------------------------------------

*------- Einzelfelder --------------------------------------------------
  DATA:  KOART LIKE T074-KOART.

*------- Valuetab ------------------------------------------------------
  DATA:  BEGIN OF VALTAB OCCURS 30,
           VALUE LIKE T074-KON30,
         END OF VALTAB.

*------- Initialisierung -----------------------------------------------
  CLEAR SELECT_VALUE.
  CASE KTOSL.
    WHEN 'MVA'. KOART = 'D'.
    WHEN 'VVA'. KOART = 'K'.
  ENDCASE.

*------- FLDTAB füllen -------------------------------------------------
  REFRESH: FLDTAB.
  PERFORM FLDTAB_EINTRAGEN USING 'T074' 'KON30' 'X'.

*------- T074 lesen ----------------------------------------------------
  REFRESH: VALTAB.
SELECT * FROM T074 WHERE KTOPL = KTOPL
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES01 ECDK917080 *
*AND KOART = KOART.
AND KOART = KOART ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES01 ECDK917080 *
    VALTAB-VALUE = T074-KON30.
    COLLECT VALTAB.
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
