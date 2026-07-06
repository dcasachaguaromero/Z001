FUNCTION ZFI_F4_AKONT.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_BUKRS) LIKE  SKB1-BUKRS
*"     VALUE(I_MITKZ) LIKE  SKB1-MITKZ
*"     VALUE(I_AKONT) LIKE  SKB1-SAKNR OPTIONAL
*"     VALUE(I_XSHOW) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_AKONT) LIKE  SKB1-SAKNR
*"     VALUE(E_AKONT0) LIKE  SKB1-SAKNR
*"  EXCEPTIONS
*"      INVALID_CALL
*"      NOTHING_FOUND
*"      INTERNAL_ERROR
*"--------------------------------------------------------------------

*------- interne Tabelle aller erlaubten Abstimmkonten -----------------
  DATA:  BEGIN OF AKONT_TAB OCCURS 40,
           AKONT LIKE SKAT-TXT50,
         END OF AKONT_TAB.


*------- Initialisierung -----------------------------------------------
  CLEAR E_AKONT.

*------- Aufruf gültig? ------------------------------------------------
  IF  I_MITKZ NA 'ADK'
  AND I_MITKZ NE SPACE.
    MESSAGE E404 WITH 'FI_F4_AKONT' RAISING INVALID_CALL.
  ENDIF.

*------- Kontenplan zu I_BUKRS aus T001 besorgen -----------------------
  SELECT SINGLE * FROM T001
         WHERE BUKRS = I_BUKRS.
  IF SY-SUBRC <> 0.
    MESSAGE E001 WITH I_BUKRS RAISING INTERNAL_ERROR.
  ENDIF.

*------- FLDTAB füllen -------------------------------------------------
  REFRESH: FLDTAB.
  PERFORM FLDTAB_EINTRAGEN USING 'SKB1'  'SAKNR' 'X'.
  PERFORM FLDTAB_EINTRAGEN USING 'SKAT'  'TXT50' ' '.
  REFRESH AKONT_TAB.

*------- generische Suche ----------------------------------------------
  IF I_AKONT CA '*+'.
    TRANSLATE I_AKONT USING '*%'.
    TRANSLATE I_AKONT USING '+_'.

*------- ... Abstimmkonto lesen ----------------------------------------
    IF I_MITKZ NE SPACE.
      SELECT * FROM SKB1
             WHERE BUKRS = I_BUKRS
             AND   SAKNR LIKE I_AKONT
             AND   MITKZ = I_MITKZ.
        WRITE SKB1-SAKNR TO AKONT_TAB-AKONT NO-ZERO.
        APPEND AKONT_TAB.
*------- ... Text zum Abstimmkonto lesen -------------------------------
        PERFORM SKAT_LESEN USING AKONT_TAB-AKONT.
        APPEND AKONT_TAB.
      ENDSELECT.
    ELSE.
      SELECT * FROM SKB1
             WHERE ( BUKRS = I_BUKRS
               AND   SAKNR LIKE I_AKONT
               AND   MITKZ = 'D' )
               OR  ( BUKRS = I_BUKRS
               AND   SAKNR LIKE I_AKONT
               AND   MITKZ = 'K' ).
        WRITE SKB1-SAKNR TO AKONT_TAB-AKONT NO-ZERO.
        APPEND AKONT_TAB.
*------- ... Text zum Abstimmkonto lesen -------------------------------
        PERFORM SKAT_LESEN USING AKONT_TAB-AKONT.
        APPEND AKONT_TAB.
      ENDSELECT.
    ENDIF.
*------- nicht generische Suche ----------------------------------------
  ELSE.
    IF I_MITKZ NE SPACE.
*------- ... Abstimmkonto lesen ----------------------------------------
      SELECT * FROM SKB1
             WHERE BUKRS = I_BUKRS
             AND   MITKZ = I_MITKZ.
        WRITE SKB1-SAKNR TO AKONT_TAB-AKONT NO-ZERO.
        APPEND AKONT_TAB.
*------- ... Text zum Abstimmkonto lesen -------------------------------
        PERFORM SKAT_LESEN USING AKONT_TAB-AKONT.
        APPEND AKONT_TAB.
      ENDSELECT.
    ELSE.
      SELECT * FROM SKB1
             WHERE ( BUKRS = I_BUKRS AND  MITKZ = 'D' )
                OR ( BUKRS = I_BUKRS AND  MITKZ = 'K' ).
        WRITE SKB1-SAKNR TO AKONT_TAB-AKONT NO-ZERO.
        APPEND AKONT_TAB.
*------- ... Text zum Abstimmkonto lesen -------------------------------
        PERFORM SKAT_LESEN USING AKONT_TAB-AKONT.
        APPEND AKONT_TAB.
      ENDSELECT.
    ENDIF.
  ENDIF.

*------- Keine Abstimmkonten vorhanden? --------------------------------
  DESCRIBE TABLE AKONT_TAB LINES SY-TFILL.
  IF SY-TFILL = 0.
    MESSAGE S406 RAISING NOTHING_FOUND.
    EXIT.
  ENDIF.


*------- Abstimmkonten anzeigen ----------------------------------------
  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
       EXPORTING
            DISPLAY      = I_XSHOW
            FIELDNAME    = 'AKONT'
            TABNAME      = 'KNB1'
       IMPORTING
            SELECT_VALUE = E_AKONT
       TABLES
            FIELDS       = FLDTAB
            VALUETAB     = AKONT_TAB.

*------- E_AKONT0 versorgen --------------------------------------------
  E_AKONT0 = E_AKONT.
  CHECK NOT E_AKONT0 IS INITIAL.
  WHILE E_AKONT0+9(1) = ' '.
    SHIFT E_AKONT0 RIGHT.
  ENDWHILE.
  TRANSLATE E_AKONT0 USING ' 0'.

ENDFUNCTION.
