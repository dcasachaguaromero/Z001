*----------------------------------------------------------------------*
*   INCLUDE LFHL2INT                                                   *
*----------------------------------------------------------------------*

*eject
*----------------------------------------------------------------------*
*        TOP-OF-PAGE                                                   *
*----------------------------------------------------------------------*
TOP-OF-PAGE.

  CASE INCLUDE.

*------- Include LFHL2U02 ----------------------------------------------
    WHEN 'LFHL2U02'.
      FORMAT COLOR COL_HEADING INTENSIFIED.
      IF I_XTECH <> SPACE.
        POS = LAENGE_FNAME + 2.
        WRITE: AT (LAENGE_FNAME) HEADER1 NO-GAP, SY-VLINE NO-GAP,
               AT POS(LAENGE_FTEXT) HEADER2.
      ELSE.
        WRITE: AT (BREITE_POPUP) HEADER2.
      ENDIF.
      WRITE: AT /(BREITE_POPUP) SY-ULINE.

*------- Include LFHL2U04 ----------------------------------------------
    WHEN 'LFHL2U04'.
      FORMAT COLOR COL_HEADING INTENSIFIED.
      WRITE: /(4) TEXT-021 NO-GAP, SY-VLINE NO-GAP, (60) TEXT-022.
      FORMAT RESET.
      WRITE: /(65) SY-ULINE.
  ENDCASE.

*eject
*----------------------------------------------------------------------*
*        AT LINE-SELECTION                                             *
*----------------------------------------------------------------------*
AT LINE-SELECTION.

  CASE INCLUDE.

*------- Include LFHL2U02 ----------------------------------------------
    WHEN 'LFHL2U02'.
      IF I_MODUS = 'W'.
        IF I_XFELD = SPACE.
          E_FNAME = FELDTAB-FNAME.
          PERFORM FELDN_TNAME_ERMITTELN.
        ELSE.
          E_FELDN = FELDTAB-FNAME.
        ENDIF.
        E_FTEXT = FELDTAB-FTEXT.
        E_DLENG = FELDTAB-DLENG.
        E_OUTPL = FELDTAB-OUTPL.
        E_INTTP = FELDTAB-INTTP.
        E_INTLN = FELDTAB-INTLN.
      ENDIF.

*------- Include LFHL2U04 ----------------------------------------------
    WHEN 'LFHL2U04'.
      IF I_XSHOW = SPACE.
        E_ZTERM = ZBTXT-ZTERM.
      ENDIF.
  ENDCASE.

  SET SCREEN 0.
  LEAVE SCREEN.

*eject
*----------------------------------------------------------------------*
*        AT USER-COMMAND                                               *
*----------------------------------------------------------------------*
AT USER-COMMAND.

  CASE SY-UCOMM.

*------- Abbrechen (CNCL) ----------------------------------------------
    WHEN 'CNCL'.
      SET SCREEN 0.
      LEAVE SCREEN.

*------- Suchen (SUCH) -------------------------------------------------
    WHEN 'SUCH'.
      PERFORM SUCHEN.

*------- Sortieren nach Feldbezeichnung (SORB) -------------------------
    WHEN 'SORB'.
      SORT FELDTAB BY FTEXT.
      INDEX = 1.
      SET SCREEN 100.
      LEAVE SCREEN.

*------- Sortieren nach Feldname (SORF) --------------------------------
    WHEN 'SORF'.
      SORT FELDTAB BY FNAME.
      INDEX = 1.
      SET SCREEN 100.
      LEAVE SCREEN.

*------- Techn. Name ein/aus (TECH) ------------------------------------
    WHEN 'TECH'.
      TRANSLATE I_XTECH USING 'X  X'.
      CLEAR: RFCU3-FNAME, RFCU1-FELDT.           " für 'Weiter suchen'
      INDEX = SY-STARO.
      SET SCREEN 100.
      LEAVE SCREEN.

*------- Weiter suchen (WESU) ------------------------------------------
    WHEN 'WESU'.
      IF  RFCU3-FNAME IS INITIAL
      AND RFCU1-FELDT IS INITIAL.
        PERFORM SUCHEN.
      ELSE.
        OLD_INDEX = SY-STARO.
        INDEX = SY-STARO.
        PERFORM SUCHEN_IN_FELDTAB USING INDEX.
        IF OLD_INDEX = INDEX.
          MESSAGE I408.
        ENDIF.
        IF INDEX > 0.
          SCROLL LIST TO PAGE 1 LINE INDEX.
        ELSE.
          SCROLL LIST TO PAGE 1 LINE OLD_INDEX.
        ENDIF.
        SET CURSOR 2 3.
      ENDIF.
  ENDCASE.
