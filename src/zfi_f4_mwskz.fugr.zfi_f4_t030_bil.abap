FUNCTION ZFI_F4_T030_BIL.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_XSHOW) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"     VALUE(KTOPL) LIKE  T004-KTOPL
*"     VALUE(KTOSL) LIKE  T030-KTOSL OPTIONAL
*"  EXPORTING
*"     VALUE(SELECT_VALUE) LIKE  T030-BWMOD
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"--------------------------------------------------------------------

*------- Valuetab ------------------------------------------------------
  DATA:  BEGIN OF VALTAB OCCURS 30,
           VALUE LIKE SKA1-SAKNR,
         END OF VALTAB.

*------- Einzelfelder --------------------------------------------------
  DATA:  LASTKTOPL LIKE T004-KTOPL.

*------- Initialisierung -----------------------------------------------
  CLEAR SELECT_VALUE.

*------- FLDTAB füllen -------------------------------------------------
  REFRESH: FLDTAB.
  PERFORM FLDTAB_EINTRAGEN USING 'SKA1' 'GVTYP' 'X'.
  PERFORM FLDTAB_EINTRAGEN USING 'SKA1' 'SAKNR' ' '.

*------- SKA1 lesen ----------------------------------------------------
  IF LASTKTOPL NE KTOPL.
    REFRESH: VALTAB.
    SELECT * FROM SKA1 WHERE KTOPL EQ KTOPL
                       AND   GVTYP NE SPACE.
      LOOP AT VALTAB WHERE VALUE = SKA1-GVTYP.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC NE 0.
        VALTAB-VALUE = SKA1-GVTYP.
        APPEND VALTAB.
        VALTAB-VALUE = SKA1-SAKNR.
        APPEND VALTAB.
      ENDIF.
    ENDSELECT.
    LASTKTOPL = KTOPL.
  ENDIF.

*------- Keine GVTYP vorhanden? ----------------------------------------
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
