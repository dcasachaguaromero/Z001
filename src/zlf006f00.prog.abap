************************************************************************
*                                                                      *
*                Form-Routinen / List-Processing                       *
*                                                                      *
************************************************************************


************************************************************************
*        TOP-OF-PAGE                                                   *
*        AT LINE-SELECTION                                             *
*        FORM BILDTAB_SICHERN                                          *
*        FORM CROSSTAB_BEARBEITEN                                      *
*        FORM DOKTAB_AUFBAUEN                                          *
*        FORM DOKTAB_DEBUGGING                                         *
*        FORM EINTRAG_MERKEN                                           *
*        FORM GRUPPE_VORBEREITEN                                       *
*        FORM KOART_ERMITTELN                                          *
*        FORM LISTE_AUSGEBEN                                           *
*        FORM LISTE_AUSGEBEN_U03                                       *
*        FORM OUTGOINGSTRING_AUFBAUEN                                  *
*        FORM SPLITTAB_AUFBAUEN                                        *
*        FORM WRITE_FELD                                               *
*        FORM WRITE_KOART                                              *
*        FORM WRITE_KOPF                                               *
*        FORM WRITE_GGRUP                                              *
*        FORM WRITE_MODI                                               *
************************************************************************



*----------------------------------------------------------------------*
*        TOP-OF-PAGE                                                   *
*----------------------------------------------------------------------*
TOP-OF-PAGE.

  CASE SY-DYNNR.
  WHEN '0501'.
    WRITE: /(20) TEXT-T10              COLOR COL_HEADING INVERSE,
           21    U03_FSTVARIANTE       COLOR COL_HEADING INTENSIFIED,
           26    U03_FSTVARIANTENTEXT  COLOR COL_NORMAL  INVERSE,
           /(20) TEXT-T11              COLOR COL_HEADING INVERSE,
           21    U03_FSTGRUPPE         COLOR COL_HEADING INTENSIFIED,
           26    U03_FSTGRUPPENTEXT    COLOR COL_NORMAL  INVERSE.
    SKIP.
    WRITE: /(68)  SY-ULINE,
           /1     SY-VLINE,
            2(4)  TEXT-T20  COLOR COL_HEADING INTENSIFIED,
            6     SY-VLINE,
            7(10) TEXT-T21  COLOR COL_HEADING INTENSIFIED,
           17     SY-VLINE,
           18(50) TEXT-T22  COLOR COL_HEADING INTENSIFIED,
           68     SY-VLINE,
           /(68)  SY-ULINE.
  ENDCASE.



*----------------------------------------------------------------------*
*        AT LINE-SELECTION                                             *
*----------------------------------------------------------------------*
AT LINE-SELECTION.

  IF XHIDE IS INITIAL.
    MESSAGE S155.
    EXIT.
  ENDIF.
  CLEAR XHIDE.
  CHECK CROSSTAB-TAB <> SPACE.
  CHECK CROSSTAB-FELD <> SPACE.
  TABNAME = CROSSTAB-TAB.
  FIELDNAME = CROSSTAB-FELD.
  SET TITLEBAR 'GFV' WITH CROSSTAB-TEXT.
  CALL FUNCTION 'HELP_DOCU_SHOW_FOR_FIELD'
       EXPORTING
            FIELDNAME = FIELDNAME
            TABNAME = TABNAME.
  SET TITLEBAR 'GFE'.



*----------------------------------------------------------------------*
*        FORM BILDTAB_SICHERN                                          *
*----------------------------------------------------------------------*
FORM BILDTAB_SICHERN.

  CLEAR XHELL.
  CLEAR AEFLG.
  LOOP AT BILDTAB.
    READ TABLE FAUSTAB WITH KEY BILDTAB-GRUPP.
    IF SY-SUBRC = 0.
      FAUSTAB = BILDTAB.
      MODIFY FAUSTAB INDEX SY-TABIX.
      IF FAUSTAB-XOBLG = 'X' OR
         FAUSTAB-XOPTN = 'X' OR
         FAUSTAB-XDISP = 'X'.
        XHELL = 'X'.
      ENDIF.
    ELSE.
      MESSAGE E362 WITH 'FAUSTAB'.
    ENDIF.
  ENDLOOP.
  READ TABLE GRUPTAB WITH KEY FAUSTAB-GGRUP.
  IF SY-SUBRC = 0.
    IF XHELL = 'X'.
      GRUPTAB-XHELL = 'X'.
    ELSE.
      CLEAR GRUPTAB-XHELL.
    ENDIF.
    MODIFY GRUPTAB INDEX SY-TABIX.
  ENDIF.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM CROSSTAB_BEARBEITEN                                      *
*----------------------------------------------------------------------*
FORM CROSSTAB_BEARBEITEN.

DATA:
    BEGIN OF DKS,
        D,
        K,
        S,
    END OF DKS,
    BEGIN OF A_TAB OCCURS 50,
        GGRUP(5),
        MODI(3)    TYPE N,
        TAB(5),
        FELD(10),
        TEXT(60),
    END OF A_TAB,
    BEGIN OF CROSSTAB2 OCCURS 50,
        GGRUP(5),
        MODI(3)    TYPE N,
        TAB(5),
        FELD(10),
        KOART,
        TEXT(60),
    END OF CROSSTAB2.


*------- CROSSTAB2 aufbauen (KOART nach hinten sortiert) --------------*
  REFRESH CROSSTAB2.
  LOOP AT CROSSTAB.
    MOVE-CORRESPONDING CROSSTAB TO CROSSTAB2.
    IF CROSSTAB2-KOART CO 'AM'.
      CROSSTAB2-KOART = 'S'.
    ENDIF.
    COLLECT CROSSTAB2.
  ENDLOOP.
  SORT CROSSTAB2.

*------- Felder suchen, die in allen KOARTen existieren ---------------*
  CLEAR DKS.
  REFRESH A_TAB.
  LOOP AT CROSSTAB2.
    CASE CROSSTAB2-KOART.
    WHEN 'D'.
      DKS-D = 'X'.
    WHEN 'K'.
      DKS-K = 'X'.
    WHEN 'S'.
      DKS-S = 'X'.
      MOVE-CORRESPONDING CROSSTAB2 TO A_TAB.
    ENDCASE.
    AT END OF FELD.
      IF DKS CO 'X'.
        APPEND A_TAB.
      ENDIF.
      CLEAR DKS.
    ENDAT.
  ENDLOOP.

*------- Felder die in allen KOARTen existieren aus CROSSTAB2 löschen -*
  LOOP AT A_TAB.
    LOOP AT CROSSTAB2 WHERE GGRUP = A_TAB-GGRUP
                      AND   MODI  = A_TAB-MODI
                      AND   TAB   = A_TAB-TAB
                      AND   FELD  = A_TAB-FELD.
      DELETE CROSSTAB2.
    ENDLOOP.
  ENDLOOP.

*------- CROSSTAB aus CROSSTAB2 und A_TAB neu aufbauen ----------------*
  REFRESH CROSSTAB.
  LOOP AT CROSSTAB2.
    MOVE-CORRESPONDING CROSSTAB2 TO CROSSTAB.
    APPEND CROSSTAB.
  ENDLOOP.
  LOOP AT A_TAB.
    MOVE-CORRESPONDING A_TAB TO CROSSTAB.
    CROSSTAB-KOART = 'A'.
    APPEND CROSSTAB.
  ENDLOOP.
  SORT CROSSTAB.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM DOKTAB_AUFBAUEN                                          *
*----------------------------------------------------------------------*
FORM DOKTAB_AUFBAUEN USING STRING_ID.

  CHECK DYNPFIELDS-INPUT_FLD = XON.
  CHECK ( DYNPFIELDS-GROUP1 <> SPACE AND DYNPFIELDS-GROUP1 <> 0 )
  OR    (   DYNPFIELDS-REQU_ENTRY = XON
        AND DYNPFIELDS-GROUP1 = SPACE
        AND DYNPFIELDS-GROUP2 = SPACE
        AND DYNPFIELDS-GROUP3 = SPACE
        AND DYNPFIELDS-GROUP4 = SPACE ).
  REPLACE 'MSEGK' WITH 'MSEG' INTO DYNPFIELDS-NAME.
  REPLACE 'GLACCOUNT_SCREEN_CCODE' WITH 'SKB1' INTO DYNPFIELDS-NAME.
  DOKTAB-TAB = DYNPFIELDS-NAME.
  SHIFT DOKTAB-TAB UP TO '-' RIGHT.
  SHIFT DOKTAB-TAB RIGHT.
  SHIFT DOKTAB-TAB LEFT DELETING LEADING SPACE.
  SHIFT DYNPFIELDS-NAME UP TO '-'.
  SHIFT DYNPFIELDS-NAME.
  DOKTAB-FELD = DYNPFIELDS-NAME.
  DOKTAB-MODI = DYNPFIELDS-GROUP1.
  CASE string_id.
  WHEN 'SKB1-FAUS1 '.
    IF DYNPFIELDS-GROUP4 = 'NOB'.
      DOKTAB-XRELE = SPACE.
    ELSE.
       DOKTAB-XRELE = XON.
    ENDIF.
  WHEN 'T077S-FAUSS'.
    IF dynpfields-group2 = 'NOB'.
      doktab-xrele = space.
    ELSE.
       doktab-xrele = xon.
    ENDIF.
  ENDCASE.
  LOOP AT SPLITTAB WHERE PROG = SCR-PROG
                   AND   DNUM = SCR-DNUM.
    DOKTAB-KOART = SPLITTAB-KOART.
    DOKTAB-UMSKS = SPLITTAB-UMSKS.
    COLLECT DOKTAB.
    PERFORM DOKTAB_DEBUGGING.
  ENDLOOP.
  IF SY-SUBRC <> 0.
    PERFORM KOART_ERMITTELN.
    DOKTAB-UMSKS = SPACE.
    COLLECT DOKTAB.
    PERFORM DOKTAB_DEBUGGING.
  ENDIF.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM DOKTAB_DEBUGGING                                         *
*----------------------------------------------------------------------*
FORM DOKTAB_DEBUGGING.

* Lokale Felder
STATICS:
    SEARCH,
    SEARCH_SCREEN(4),
    SEARCH_MODIF(11).

* Ablauf
  CHECK SEARCH = XON.
  CHECK SEARCH_SCREEN IS INITIAL OR SEARCH_SCREEN = SCR-DNUM.
  CHECK SEARCH_MODIF IS INITIAL OR SEARCH_MODIF CS DOKTAB-MODI.
  WRITE: / '>>>>', DOKTAB-MODI, DOKTAB+3, SCR-PROG(8), SCR-DNUM, '<<<<'.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM EINTRAG_MERKEN                                           *
*----------------------------------------------------------------------*
FORM EINTRAG_MERKEN.

  CLEAR CROSSTAB.
  CROSSTAB-GGRUP = TMODO-GGRUP.
  CROSSTAB-MODI  = TMODU-MODIF.
  CROSSTAB-KOART = TMODU-KOART.
  CROSSTAB-TAB   = TMODU-TABNM.
  CROSSTAB-FELD  = TMODU-FELDN.
  PERFORM SCHLUESSELWORT_LESEN2(SAPFS003)
          USING CROSSTAB-TAB CROSSTAB-FELD CROSSTAB-TEXT SY-SUBRC.
  APPEND CROSSTAB.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM GRUPPE_VORBEREITEN                                       *
*----------------------------------------------------------------------*
FORM GRUPPE_VORBEREITEN.

  READ TABLE GRUPTAB INDEX DY-LINN2.
  IF SY-SUBRC <> 0.
    MESSAGE E155.
  ENDIF.
  LF006-TEXT4 = GRUPTAB-FTEXT.
  REFRESH BILDTAB.
  LOOP AT FAUSTAB WHERE GGRUP = GRUPTAB-GGRUP.
    BILDTAB = FAUSTAB.
    APPEND BILDTAB.
  ENDLOOP.
  DESCRIBE TABLE BILDTAB LINES TABIX.
  CLEAR OK-CODE.
  SET SCREEN 400.
  LEAVE SCREEN.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM KOART_ERMITTELN.                                         *
*----------------------------------------------------------------------*
FORM KOART_ERMITTELN.

  DOKTAB-KOART = SPACE.
  CASE DYNTAB-FAUNA(6).
  WHEN 'T077D-'.
    DOKTAB-KOART = 'D'.
  WHEN 'T077K-'.
    DOKTAB-KOART = 'K'.
  WHEN 'T077S-'.
    DOKTAB-KOART = 'S'.
  WHEN OTHERS.
    CASE SCR-PROG.
    WHEN 'SAPMM08R'.
      DOKTAB-KOART = 'S'.
    WHEN 'SAPMM08P'.
      DOKTAB-KOART = 'S'.
    WHEN 'SAPMM08K'.
      DOKTAB-KOART = 'S'.
    WHEN 'SAPMM07M'.
      DOKTAB-KOART = 'S'.
    ENDCASE.
  ENDCASE.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM KONSISTENZ_PRUEFEN.                                      *
*----------------------------------------------------------------------*
FORM KONSISTENZ_PRUEFEN.

* Lokale Daten
DATA:
    QTEXT(64),
    ZTEXT(64).
DATA:
    BEGIN OF CHECKTAB OCCURS 2,      "(Später auf S-Tabelle umstellen?)
       FAUNA  LIKE TMODO-FAUNA,
       QMODI  LIKE TMODO-MODIF,
       QWERT(1),
       ZMODI  LIKE TMODO-MODIF,
       ZWERT(3),
    END OF CHECKTAB.

* CHECKTAB füllen (Später auf S-Tabelle umstellen?)
  REFRESH CHECKTAB.
  CLEAR CHECKTAB.
* Feldauswahl für Buchen
  CHECKTAB-FAUNA = 'SKB1-FAUS1'.
* CO (Leistungsart nur wenn Kostenstelle eingeblendet)
  CHECKTAB-QMODI = '010'.
  CHECKTAB-ZMODI = '098'.
  CHECKTAB-QWERT = '+'.
  CHECKTAB-ZWERT = '+.-'.
  APPEND CHECKTAB.
  CHECKTAB-QWERT = '.'.
  CHECKTAB-ZWERT = '.-'.
  APPEND CHECKTAB.
  CHECKTAB-QWERT = '-'.
  CHECKTAB-ZWERT = '-'.
  APPEND CHECKTAB.
* Joint-Venture
  CHECKTAB-QMODI = '092'.
  CHECKTAB-ZMODI = '045'.
  CHECKTAB-QWERT = '+'.
  CHECKTAB-ZWERT = '+'.
  APPEND CHECKTAB.
  CHECKTAB-QWERT = '.'.
  CHECKTAB-ZWERT = '.+'.
  APPEND CHECKTAB.

* Konsistenz prüfen
  IF CHFLG = XON.
    LOOP AT CHECKTAB WHERE FAUNA = TMODF-FAUNA.
      READ TABLE FAUSTAB WITH KEY CHECKTAB-QMODI.
      CHECK SY-SUBRC = 0.
      CASE CHECKTAB-QWERT.
      WHEN '+'.
        CHECK FAUSTAB-XOBLG = XON.
      WHEN '.'.
        CHECK FAUSTAB-XOPTN = XON.
      WHEN '*'.
        CHECK FAUSTAB-XDISP = XON.
      WHEN '-'.
        CHECK FAUSTAB-XOBLG = SPACE
        AND   FAUSTAB-XOPTN = SPACE
        AND   FAUSTAB-XDISP = SPACE.
      ENDCASE.
      READ TABLE FAUSTAB WITH KEY CHECKTAB-ZMODI.
      IF SY-SUBRC = 0.
        IF FAUSTAB-XOBLG = XON.
          CHECK CHECKTAB-ZWERT NA '+'.
        ELSEIF FAUSTAB-XOPTN = XON.
          CHECK CHECKTAB-ZWERT NA '.'.
        ELSEIF FAUSTAB-XDISP = XON.
          CHECK CHECKTAB-ZWERT NA '*'.
        ELSE.
          CHECK CHECKTAB-ZWERT NA '-'.
        ENDIF.
        READ TABLE GRUPTAB WITH KEY FAUSTAB-GGRUP.
        ZTEXT = GRUPTAB-FTEXT.
        ZTEXT+31 = '->'.
        ZTEXT+34 = FAUSTAB-FTEXT.
        CONDENSE ZTEXT.
        READ TABLE FAUSTAB WITH KEY CHECKTAB-QMODI.
        READ TABLE GRUPTAB WITH KEY FAUSTAB-GGRUP.
        QTEXT = GRUPTAB-FTEXT.
        QTEXT+31 = '->'.
        QTEXT+34 = FAUSTAB-FTEXT.
        CONDENSE QTEXT.
        MESSAGE W198 WITH QTEXT CHECKTAB-QWERT ZTEXT CHECKTAB-ZWERT.
      ELSE.
        MESSAGE W362 WITH 'CHECKTAB'.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM LISTE_AUSGEBEN                                           *
*----------------------------------------------------------------------*
FORM LISTE_AUSGEBEN.

  REFRESH LASTTAB.
  LOOP AT CROSSTAB.
    AT NEW MODI.
      LASTTAB-MODIF = CROSSTAB-MODI.
      APPEND LASTTAB.
    ENDAT.
  ENDLOOP.
  LAST_GGRUP = CROSSTAB-GGRUP.
  LAST_MODIF = CROSSTAB-MODI.
  LAST_KOART = CROSSTAB-KOART.
  LOOP AT LASTTAB.
    LOOP AT CROSSTAB WHERE MODI = LASTTAB-MODIF.
      LASTTAB-KOART = CROSSTAB-KOART.
    ENDLOOP.
    MODIFY LASTTAB.
  ENDLOOP.

* Liste ausgeben
  LEAVE TO LIST-PROCESSING.

  PERFORM WRITE_KOPF.
  LOOP AT CROSSTAB.
    AT NEW GGRUP.
      PERFORM WRITE_GGRUP.
    ENDAT.
    AT NEW MODI.
      PERFORM WRITE_MODI.
    ENDAT.
    AT NEW KOART.
      PERFORM WRITE_KOART.
    ENDAT.
    PERFORM WRITE_FELD.
  ENDLOOP.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM LISTE_AUSGEBEN_U02                                       *
*----------------------------------------------------------------------*
FORM LISTE_AUSGEBEN_U02.

  LEAVE TO LIST-PROCESSING.

  FORMAT COLOR COL_HEADING INVERSE.
  WRITE: / U02_KONTENPLAN,
         7 U02_FELDSTATUSGRUPPE,
        15 U02_FELDSTATUSTEXT.
  FORMAT COLOR COL_HEADING INTENSIFIED INVERSE OFF.
  WRITE: /(63) SY-ULINE,
         /     SY-VLINE,
         2(10) TEXT-T21,
        12     SY-VLINE,
        13(50) TEXT-T22,
        63     SY-VLINE,
         /(63) SY-ULINE.
  FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM SKA1 WHERE KTOPL = U02_KONTENPLAN
*                     AND   KTOKS = U02_FELDSTATUSGRUPPE.
*
* NEW CODE
  SELECT *
 FROM SKA1 WHERE KTOPL = U02_KONTENPLAN
                     AND   KTOKS = U02_FELDSTATUSGRUPPE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    SKAT-TXT50 = '?'.
    CALL FUNCTION 'READ_HAUPTBUCH_TEXT'
                  EXPORTING  KONTENPLAN = U02_KONTENPLAN
                             SACHKONTO  = SKA1-SAKNR
                             SPRACHE    = U02_LANGUAGE
                  IMPORTING  TEXT_WA    = SKAT
                  EXCEPTIONS TEXT_NOT_FOUND.
    WRITE: / SY-VLINE,
           2 SKA1-SAKNR,
          12 SY-VLINE,
          13 SKAT-TXT50,
          63 SY-VLINE.
  ENDSELECT.
  WRITE: /     SY-VLINE,
         2(10) SY-ULINE,
        12     SY-VLINE,
        13(50) SY-ULINE,
        63     SY-VLINE.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM LISTE_AUSGEBEN_U03                                       *
*----------------------------------------------------------------------*
FORM LISTE_AUSGEBEN_U03.

  LEAVE TO LIST-PROCESSING.

  U03_FOUND = SPACE.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM T001 WHERE FSTVA = U03_FSTVARIANTE.
*
* NEW CODE
  SELECT *
 FROM T001 WHERE FSTVA = U03_FSTVARIANTE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM SKB1 WHERE BUKRS = T001-BUKRS
*                       AND   FSTAG = U03_FSTGRUPPE.
*
* NEW CODE
    SELECT *
 FROM SKB1 WHERE BUKRS = T001-BUKRS
                       AND   FSTAG = U03_FSTGRUPPE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      U03_FOUND = 'X'.
      CALL FUNCTION 'READ_HAUPTBUCH_TEXT'
                     EXPORTING  KONTENPLAN     = T001-KTOPL
                                SACHKONTO      = SKB1-SAKNR
                                SPRACHE        = SY-LANGU
                     IMPORTING  TEXT_WA        = SKAT
                     EXCEPTIONS TEXT_NOT_FOUND = 1.
      IF SY-SUBRC = 0.
        WRITE: /18 SKAT-TXT50  COLOR COL_NORMAL INTENSIFIED OFF.
      ELSE.
        WRITE: /18(50) TEXT-T01  COLOR COL_NORMAL INVERSE.
      ENDIF.
      WRITE:  1 SY-VLINE,
              2 T001-BUKRS  COLOR COL_NORMAL INTENSIFIED OFF,
              6 SY-VLINE,
              7 SKB1-SAKNR  COLOR COL_NORMAL INTENSIFIED OFF,
             17 SY-VLINE,
             68 SY-VLINE.
    ENDSELECT.
  ENDSELECT.
  IF U03_FOUND = 'X'.
    WRITE: /(68) SY-ULINE.
  ENDIF.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM OUTGOINGSTRING_AUFBAUEN                                  *
*----------------------------------------------------------------------*
FORM OUTSTRING_AUFBAUEN.

  LOOP AT FAUSTAB.
    SHIFT C500 LEFT.
    IF FAUSTAB-XOBLG = 'X'.
      C500+499(1) = '+'.
    ELSEIF FAUSTAB-XOPTN = 'X'.
      C500+499(1) = '.'.
    ELSEIF FAUSTAB-XDISP = 'X'.
      C500+499(1) = '*'.
    ELSEIF 1 = 1.
      C500+499(1) = '-'.
    ENDIF.
  ENDLOOP.
  CONDENSE C500 NO-GAPS.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM SPLITTAB_AUFBAUEN                                        *
*----------------------------------------------------------------------*
*        Dynproattribute ermitteln (KOART)                             *
*----------------------------------------------------------------------*
FORM SPLITTAB_AUFBAUEN.

  REFRESH SPLITTAB.

*------- Für SAPMF05A -------------------------------------------------*
  SPLITTAB-PROG = 'SAPMF05A'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM T019 WHERE KOART <> SPACE.
*
* NEW CODE
  SELECT *
 FROM T019 WHERE KOART <> SPACE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    SPLITTAB-DNUM = T019-DYNNR.
    SPLITTAB-KOART = T019-KOART.
    CASE T019-UMSKZ.
    WHEN ' '.
      SPLITTAB-UMSKS = T019-UMSKZ.
    WHEN 'A'.
      SPLITTAB-UMSKS = T019-UMSKZ.
    WHEN 'W'.
      SPLITTAB-UMSKS = T019-UMSKZ.
    WHEN 'S'.
      SPLITTAB-UMSKS = space.
    WHEN OTHERS.
      SPLITTAB-UMSKS = 'X'.
    ENDCASE.
    COLLECT SPLITTAB.
  ENDSELECT.
  SPLITTAB-UMSKS = ' '.
  SPLITTAB-DNUM = '0330'.
  SPLITTAB-KOART = 'S'.
  COLLECT SPLITTAB.
  SPLITTAB-DNUM = '0331'.
  SPLITTAB-KOART = 'D'.
  COLLECT SPLITTAB.
  SPLITTAB-DNUM = '0332'.
  SPLITTAB-KOART = 'K'.
  COLLECT SPLITTAB.

*------- Für SAPMF05L -------------------------------------------------*
  SPLITTAB-PROG = 'SAPMF05L'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM T019 WHERE KOART <> SPACE
*                     AND   ( DYNCL = 'A' OR DYNCL = 'V' )
*                     AND   DYNNR BETWEEN '0300' AND '0399'.
*
* NEW CODE
  SELECT *
 FROM T019 WHERE KOART <> SPACE
                     AND   ( DYNCL = 'A' OR DYNCL = 'V' )
                     AND   DYNNR BETWEEN '0300' AND '0399' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    SPLITTAB-DNUM = T019-DYNNR.
    SPLITTAB-KOART = T019-KOART.
    COLLECT SPLITTAB.
  ENDSELECT.
*------- Für SAPMM08R -------------------------------------------------*
  SPLITTAB-PROG = 'SAPMM08R'.
  SPLITTAB-KOART = 'K'.
  SPLITTAB-DNUM = '0110'.
  APPEND SPLITTAB.
  SPLITTAB-DNUM = '0111'.
  APPEND SPLITTAB.
  SPLITTAB-DNUM = '0501'.
  APPEND SPLITTAB.
  SPLITTAB-DNUM = '2110'.
  APPEND SPLITTAB.
  SPLITTAB-DNUM = '3110'.
  APPEND SPLITTAB.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM WRITE_FELD                                               *
*----------------------------------------------------------------------*
FORM WRITE_FELD.

* Lokale Felder
DATA:
    FNAME(16).

* Ausgabe
  CHECK ST_FELD <> 0.

  CASE ST_FELD.
  WHEN 3.
    IF LAST_KOART <> CROSSTAB-KOART.
      WRITE: /2(1) SY-VLINE,
              7(1) SY-VLINE.
    ELSE.
      WRITE: /7(1) SY-VLINE.
    ENDIF.
    WRITE:  8(3) SY-ULINE,
           11    CROSSTAB-TEXT COLOR COL_NORMAL INTENSIFIED.
  WHEN 4.
    CLEAR LASTTAB.
    LASTTAB-MODIF = CROSSTAB-MODI.
    READ TABLE LASTTAB.
    IF LAST_MODIF <> CROSSTAB-MODI.
      WRITE: /2(1) SY-VLINE.
      IF LASTTAB-KOART <> CROSSTAB-KOART.
        WRITE 7(1) SY-VLINE.
      ENDIF.
      WRITE 12(1) SY-VLINE.
    ELSE.
      IF LASTTAB-KOART <> CROSSTAB-KOART.
        WRITE: /7(1) SY-VLINE,
               12(1) SY-VLINE.
      ELSE.
        WRITE /12(1) SY-VLINE.
      ENDIF.
    ENDIF.
    WRITE: 13(3) SY-ULINE,
           16    CROSSTAB-TEXT COLOR COL_NORMAL INTENSIFIED.
  ENDCASE.
  IF CROSSEB = 'N'.
    FNAME = CROSSTAB-TAB.
    FNAME+5 = '-'.
    FNAME+6 = CROSSTAB-FELD.
    CONDENSE FNAME NO-GAPS.
    WRITE: 44(1) SPACE,
           45    FNAME COLOR COL_NORMAL INTENSIFIED.
  ENDIF.

  XHIDE = XON.
  HIDE: CROSSTAB-TAB, CROSSTAB-FELD, CROSSTAB-TEXT, XHIDE.
  CLEAR XHIDE.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM WRITE_GGRUP                                              *
*----------------------------------------------------------------------*
FORM WRITE_GGRUP.

  CHECK ST_GGRUP <> 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM TMODG WHERE SPRAS = SY-LANGU
*                             AND   FAUNA = TMODO-FAUNA
*                             AND   GGRUP = CROSSTAB-GGRUP.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM TMODG WHERE SPRAS = SY-LANGU
                             AND   FAUNA = TMODO-FAUNA
                             AND   GGRUP = CROSSTAB-GGRUP ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF SY-SUBRC <> 0.
    TMODG-FTEXT = TEXT-NGG.
  ENDIF.
  CASE ST_GGRUP.
  WHEN 1.
    WRITE: / TMODG-FTEXT COLOR COL_GROUP INTENSIFIED.
    IF ST_KOART = 0.
      WRITE: /2(1) SY-VLINE.
    ENDIF.
  WHEN 2.
    WRITE: /2(1) SY-VLINE.
    WRITE: /2(1) SY-VLINE,
            3(3) SY-ULINE,
            6    TMODG-FTEXT COLOR COL_GROUP INTENSIFIED.
    IF LAST_GGRUP <> CROSSTAB-GGRUP.
      WRITE: /2(1) SY-VLINE,
              7(1) SY-VLINE.
    ELSE.
      WRITE: /7(1) SY-VLINE.
    ENDIF.
  ENDCASE.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM WRITE_KOART                                              *
*----------------------------------------------------------------------*
FORM WRITE_KOART.

  CHECK ST_KOART <> 0.

  CASE CROSSTAB-KOART.
  WHEN ' '.
    TEXT_KOART = TEXT-KA_.
  WHEN 'A'.
    TEXT_KOART = TEXT-KAA.
  WHEN 'D'.
    TEXT_KOART = TEXT-KAD.
  WHEN 'K'.
    TEXT_KOART = TEXT-KAK.
  WHEN 'S'.
    TEXT_KOART = TEXT-KAS.
  ENDCASE.

  CASE ST_KOART.
  WHEN 2.
    WRITE: /2(1) SY-VLINE.
    WRITE: /2(1)  SY-VLINE,
            3(3)  SY-ULINE,
            6     TEXT_KOART COLOR COL_NORMAL INTENSIFIED OFF.
    IF LAST_KOART <> CROSSTAB-KOART.
      WRITE: /2(1) SY-VLINE,
              7(1) SY-VLINE.
    ELSE.
      WRITE /7(1) SY-VLINE.
    ENDIF.
  WHEN 3.
    CLEAR LASTTAB.
    LASTTAB-MODIF = CROSSTAB-MODI.
    READ TABLE LASTTAB.
    IF LAST_MODIF <> CROSSTAB-MODI.
      WRITE: /2(1) SY-VLINE,
              7(1) SY-VLINE.
      WRITE: /2(1) SY-VLINE,
              7(1) SY-VLINE.
    ELSE.
      WRITE: /7(1) SY-VLINE.
      WRITE: /7(1) SY-VLINE.
    ENDIF.
    WRITE: 8(3)  SY-ULINE,
          11     TEXT_KOART COLOR COL_NORMAL INTENSIFIED OFF.
    IF LAST_MODIF <> CROSSTAB-MODI.
      WRITE /2(1) SY-VLINE.
      IF LASTTAB-KOART <> CROSSTAB-KOART.
        WRITE 7(1) SY-VLINE.
      ENDIF.
      WRITE 12(1) SY-VLINE.
    ELSE.
      IF LASTTAB-KOART <> CROSSTAB-KOART.
        WRITE: /7(1) SY-VLINE,
               12(1) SY-VLINE.
      ELSE.
        WRITE /12(1) SY-VLINE.
      ENDIF.
    ENDIF.
  ENDCASE.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM WRITE_KOPF                                               *
*----------------------------------------------------------------------*
FORM WRITE_KOPF.

  CHECK ST_FAUNA <> 0.
  WRITE / UTEXT COLOR COL_HEADING INTENSIFIED.

ENDFORM.



*----------------------------------------------------------------------*
*        FORM WRITE_MODI                                               *
*----------------------------------------------------------------------*
FORM WRITE_MODI.

  CHECK ST_MODIF <> 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM TMODP WHERE SPRAS = SY-LANGU
*                             AND   FAUNA = TMODO-FAUNA
*                             AND   MODIF = CROSSTAB-MODI.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM TMODP WHERE SPRAS = SY-LANGU
                             AND   FAUNA = TMODO-FAUNA
                             AND   MODIF = CROSSTAB-MODI ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF SY-SUBRC <> 0.
    TMODP-FTEXT = TEXT-NGP.
  ENDIF.
  CASE ST_MODIF.
  WHEN 1.
    WRITE TMODP-FTEXT COLOR COL_GROUP INTENSIFIED OFF.
  WHEN 2.
    IF ST_KOART <> 0.
      WRITE: /2(1) SY-VLINE.
    ENDIF.
    WRITE: /2(1) SY-VLINE,
            3(3) SY-ULINE,
            6    TMODP-FTEXT COLOR COL_GROUP INTENSIFIED OFF.
  WHEN 3.
    IF LAST_GGRUP <> CROSSTAB-GGRUP.
      WRITE: /2(1) SY-VLINE,
              7(1) SY-VLINE.
    ELSE.
      WRITE: /7(1) SY-VLINE.
    ENDIF.
    WRITE: 8(3) SY-ULINE,
          11    TMODP-FTEXT COLOR COL_GROUP INTENSIFIED OFF.
  ENDCASE.
  IF CROSSEB CA 'PN'.
    WRITE TMODP-MODIF COLOR COL_GROUP INTENSIFIED OFF.
  ENDIF.

ENDFORM.



*----------------------------------------------------------------------*
