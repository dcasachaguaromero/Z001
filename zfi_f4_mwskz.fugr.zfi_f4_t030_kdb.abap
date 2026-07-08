FUNCTION ZFI_F4_T030_KDB.
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

* Dieser FBS wird nur aufgerufen, wenn in der Tabelle T030A
* für den Vorgang KDB im Feld T030A-F4KOM der Name dieses
* FBS 'FI_F4_T030_KDB' eingetragen ist.
* Da die Sachkonten aller Buchungskreise zu einem Kontenplan
* gelesen werden müssen, ist dieser FBS im Standard inaktiv.

*------- Valuetab ------------------------------------------------------
  DATA:  BEGIN OF VALTAB OCCURS 30,
           VALUE LIKE SKB1-SAKNR,
         END OF VALTAB.

* ------ Buchungskreise zum Kontenplan ---------------------------------
  RANGES: BUKTAB FOR T001-BUKRS.

*------- Einzelfelder --------------------------------------------------
  DATA:  LASTKTOPL LIKE T004-KTOPL.

*------- Initialisierung -----------------------------------------------
  CLEAR SELECT_VALUE.

*------- FLDTAB füllen -------------------------------------------------
  REFRESH: FLDTAB.
  PERFORM FLDTAB_EINTRAGEN USING 'SKB1' 'KDFSL' 'X'.
  PERFORM FLDTAB_EINTRAGEN USING 'SKB1' 'SAKNR' ' '.

*------- Daten neu lesen? ----------------------------------------------
  IF LASTKTOPL NE KTOPL.
    REFRESH: VALTAB, BUKTAB.

*------- ... Buchungskreise zum KTOPL in BUKTAB füllen -----------------
    BUKTAB-SIGN   = 'I'.
    BUKTAB-OPTION = 'EQ'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM T001 WHERE KTOPL = KTOPL.
*
* NEW CODE
    SELECT *
 FROM T001 WHERE KTOPL = KTOPL ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      BUKTAB-LOW    = T001-BUKRS.
      BUKTAB-HIGH   = T001-BUKRS.
      APPEND BUKTAB.
    ENDSELECT.

*------- ... SKB1 in allen Buchungskreisen aus BUKTAB lesen ------------
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM SKB1 WHERE BUKRS IN BUKTAB
*                       AND   KDFSL NE SPACE.
*
* NEW CODE
    SELECT *
 FROM SKB1 WHERE BUKRS IN BUKTAB
                       AND   KDFSL NE SPACE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      LOOP AT VALTAB WHERE VALUE = SKB1-KDFSL.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC NE 0.
        VALTAB-VALUE = SKB1-KDFSL.
        APPEND VALTAB.
        VALTAB-VALUE = SKB1-SAKNR.
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
