FUNCTION ZFI_F4_FIELDNAME_OLD .
*"--------------------------------------------------------------------
*"*"Interfase global
*"  IMPORTING
*"     VALUE(I_XKEYF) LIKE  RFCU4-FLAGX DEFAULT 'X'
*"     VALUE(I_XLOGF) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"     VALUE(I_MODUS) LIKE  T020-AKTYP DEFAULT 'W'
*"     VALUE(I_CUCOL) LIKE  SY-CUCOL DEFAULT 0
*"     VALUE(I_CUROW) LIKE  SY-CUROW DEFAULT 0
*"     VALUE(I_XTECH) LIKE  RFCU4-FLAGX DEFAULT 'X'
*"     VALUE(I_FNAME) LIKE  RFCU3-FNAME OPTIONAL
*"     VALUE(I_XFELD) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"     VALUE(I_XGRKL) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"     VALUE(I_INTTP) LIKE  RFCU4-INTTP DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_FNAME) LIKE  RFCU3-FNAME
*"     VALUE(E_FTEXT) LIKE  DD03D-DDTEXT
*"     VALUE(E_FELDN) LIKE  DD03D-FIELDNAME
*"     VALUE(E_TNAME) LIKE  DD02L-TABNAME
*"     VALUE(E_OUTPL) LIKE  DD01D-OUTPUTLEN
*"     VALUE(E_INTTP) LIKE  DD03D-INTTYPE
*"     VALUE(E_INTLN) LIKE  DD03D-INTLEN
*"     VALUE(E_DLENG) LIKE  DD03D-LENG
*"  TABLES
*"      TABTAB STRUCTURE  RFTAB
*"      EXCTAB STRUCTURE  RFFLD OPTIONAL
*"  EXCEPTIONS
*"      INVALID_CALL
*"      INVALID_FNAME
*"      INTERNAL_ERROR
*"      NOTHING_FOUND
*"      TABLE_NOT_ACTIV
*"--------------------------------------------------------------------

*------- Einzelfelder --------------------------------------------------
  DATA:    TFILL     LIKE SY-TFILL.      " Anzahl Zeilen in Tabelle

*------- Initialisierung -----------------------------------------------
  CLEAR: E_FELDN, E_FNAME, E_FTEXT, E_TNAME,
         E_DLENG, E_OUTPL, E_INTTP, E_INTLN.
  IF I_XTECH CN ' X'.
    I_XTECH = 'X'.
  ENDIF.

*------- Aufruf gültig? ------------------------------------------------
  DESCRIBE TABLE TABTAB LINES TFILL.
  IF TFILL = 0.
    MESSAGE E404 WITH 'FI_F4_FIELDNAME' RAISING INVALID_CALL.
  ENDIF.
  IF I_MODUS CN 'APTW'.
    MESSAGE E404 WITH 'FI_F4_FIELDNAME' RAISING INVALID_CALL.
  ENDIF.
  IF  I_MODUS = 'P'
  AND I_FNAME IS INITIAL.
    MESSAGE E404 WITH 'FI_F4_FIELDNAME' RAISING INVALID_CALL.
  ENDIF.
  IF  I_MODUS CA 'AW'
  AND NOT I_FNAME IS INITIAL.
    MESSAGE E404 WITH 'FI_F4_FIELDNAME' RAISING INVALID_CALL.
  ENDIF.

*------- DFIESTAB und FELDTAB füllen, falls erforderlich ---------------
  PERFORM TABTABS_VERGLEICHEN USING RC.
  IF RC <> 0.
    PERFORM DFIESTAB_FUELLEN.
    PERFORM FELDTAB_FUELLEN.
  ELSE.
    PERFORM EXCTABS_VERGLEICHEN USING RC.
    IF RC <> 0
    OR OLD_XKEYF <> I_XKEYF
    OR OLD_XLOGF <> I_XLOGF
    OR OLD_XGRKL <> I_XGRKL
    OR OLD_XFELD <> I_XFELD
    OR OLD_INTTP <> I_INTTP.
      PERFORM FELDTAB_FUELLEN.
    ENDIF.
  ENDIF.

*------- Bezeichnung des Feldnamens ermitteln/Feldname prüfen ----------
  IF I_MODUS CA 'PT'.
    LOOP AT FELDTAB
         WHERE FNAME = I_FNAME.
      EXIT.
    ENDLOOP.
    IF SY-SUBRC = 0.
      E_FTEXT = FELDTAB-FTEXT.
      E_DLENG = FELDTAB-DLENG.
      E_OUTPL = FELDTAB-OUTPL.
      E_INTTP = FELDTAB-INTTP.
      E_INTLN = FELDTAB-INTLN.
      IF I_XFELD = SPACE.
        E_FNAME = I_FNAME.
        PERFORM FELDN_TNAME_ERMITTELN.
      ELSE.
        E_FELDN = I_FNAME.
      ENDIF.
    ELSEIF I_MODUS = 'P'.
      MESSAGE E405 WITH I_FNAME RAISING INVALID_FNAME.
    ENDIF.

*------- mögliche Feldnamen anzeigen -----------------------------------
  ELSE.

*------- ... Eingabemöglichkeiten vorhanden? ---------------------------
    DESCRIBE TABLE FELDTAB LINES TFILL.
    IF TFILL = 0.
      MESSAGE S406 RAISING NOTHING_FOUND.
      EXIT.
    ENDIF.

*------- ... Koordinaten des Popups bestimmen --------------------------
    IF  I_CUCOL > 0
    AND I_CUROW > 0.
      X1 = I_CUCOL.
      Y1 = I_CUROW.
    ELSE.
      X1 = SY-CUCOL.
      Y1 = SY-CUROW.
    ENDIF.
    IF X1 >= SY-SCOLS.
      X1 = 1.
    ENDIF.
    IF Y1 >= SY-SROWS
    OR Y1 = 0.
      Y1 = 1.
    ENDIF.
    X2 = X1 + LAENGE_FNAME + LAENGE_FTEXT.
    IF TFILL > 15.
      Y2 = Y1 + 17.
    ELSE.
      Y2 = Y1 + TFILL + 2.
    ENDIF.
    BREITE_POPUP = LAENGE_FNAME + LAENGE_FTEXT + 1.
    SROWS = SY-SROWS.

*------- ... Spaltenüberschriften für Liste setzen, FELDTAB sortieren --
    IF LAENGE_FNAME >= 10.
      HEADER1 = TEXT-001.
    ELSE.
      HEADER1 = TEXT-002.
    ENDIF.
    HEADER2 = TEXT-003.
    TRANSLATE HEADER1 USING '; '.
    TRANSLATE HEADER2 USING '; '.
    IF I_XTECH <> SPACE.
      SORT FELDTAB BY FNAME.
    ELSE.
      SORT FELDTAB BY FTEXT.
    ENDIF.
    INDEX = 1.

*------- ... Popup senden ----------------------------------------------
    INCLUDE = 'LFHL2U02'.
    CALL SCREEN 100
         STARTING AT X1 Y1
         ENDING   AT X2 Y2.
  ENDIF.

ENDFUNCTION.
