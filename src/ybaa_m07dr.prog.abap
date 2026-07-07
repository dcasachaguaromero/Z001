INCLUDE M07DRTOP.           "inc.aufgelöst
*INCLUDE /SMBA0/AA_M07DRTOP.
TABLES:
  arc_params,
   toa_dara.

*INCLUDE /SMBA0/AA_M07DRMTA. "userexit raus

INCLUDE M07DRMMA.

INCLUDE M07DRMBE.           "subrc clear

INCLUDE M07DRMFA.           "oss312712 fehlt

INCLUDE M07DRKON.

*INCLUDE /SMBA0/AA_M07DRF01. "userexits raus

*INCLUDE /SMBA0/AA_M07DRF02. "userexits raus

INCLUDE M07DRE01.           "oss512568 fehlt/SC-druck

*INCLUDE /SMBA0/AA_M07DRE02.

INCLUDE M07DRE03.           "WINDOW 'RÜKOPF'

INCLUDE M07DRA01.

INCLUDE M07DRA02.

INCLUDE M07DRA03.

INCLUDE M07DRLB3.

INCLUDE M07DRETI.

INCLUDE M07DRKTO.

*INCLUDE /SMBA0/AA_M07DRENT. "SF-aufruf

INCLUDE M07DRLOB.

*INCLUDE /SMBA0/AA_M07DRAUS. "SF-aufruf

*INCLUDE /SMBA0/AA_M07DRSON. "SC-aufruf raus

*---------------------------------------------------------------------------*
*alle SMBA0-Includes müssen hier aufgelöst werden
*(autom. SW-verteilung kann dies für smb* nicht)
*---------------------------------------------------------------------------*

*---------------------------------------------------------------------------*
*include /SMBA0/AA_M07DRMTA
*---------------------------------------------------------------------------*
*------Lesen Tabelle T001----------------------------------------------*
FORM TAB001_LESEN.
  IF NOT T001-BUKRS = MSEG-BUKRS.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T001 WHERE BUKRS = MSEG-BUKRS.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T001 WHERE BUKRS = MSEG-BUKRS ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.
ENDFORM.                    "TAB001_LESEN

*-------Lesen Tabelle T001w--------------------------------------------*
FORM TAB001W_LESEN.
  IF NOT T001W-WERKS = MSEG-WERKS.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T001W WHERE WERKS = MSEG-WERKS.
**
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T001W WHERE WERKS = MSEG-WERKS ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.
  R_WERKS = T001W-WERKS.
  R_NAME1 = T001W-NAME1.
* Sprache für Formular aus Kondition, sonst aus Werk
  IF NOT NAST-SPRAS IS INITIAL.
    LANGUAGE = NAST-SPRAS.
  ELSE.
    LANGUAGE = T001W-SPRAS.
  ENDIF.
  SET LANGUAGE LANGUAGE.
ENDFORM.                    "TAB001W_LESEN

*-------Lesen Tabelle T001w bei Werkswechsel --------------------------*
FORM TAB001W_LESEN_2.
  IF NOT MSEG-WERKS = T001W-WERKS.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T001W WHERE WERKS = MSEG-WERKS.
**
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T001W WHERE WERKS = MSEG-WERKS ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.
ENDFORM.                    "TAB001W_LESEN_2
*--------Lesen Tabelle T156--------------------------------------------*
FORM TAB156_LESEN.
  IF NOT T156-BWART = MSEG-BWART.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T156 WHERE BWART = MSEG-BWART.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T156 WHERE BWART = MSEG-BWART ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.
ENDFORM.                    "TAB156_LESEN

*-------Lesen Tabelle T156t--------------------------------------------*
FORM TAB156T_LESEN.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM T156T WHERE SPRAS = LANGUAGE
*                             AND   BWART = MSEG-BWART
*                             AND   SOBKZ = MSEG-SOBKZ
*                             AND   KZBEW = MSEG-KZBEW
*                             AND   KZZUG = MSEG-KZZUG
*                             AND   KZVBR = MSEG-KZVBR.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM T156T WHERE SPRAS = LANGUAGE
                             AND   BWART = MSEG-BWART
                             AND   SOBKZ = MSEG-SOBKZ
                             AND   KZBEW = MSEG-KZBEW
                             AND   KZZUG = MSEG-KZZUG
                             AND   KZVBR = MSEG-KZVBR ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

ENDFORM.                    "TAB156T_LESEN

*------Lesen Tabelle T024----------------------------------------------*
FORM TAB024_LESEN.
  IF NOT T024-EKGRP = EKKO-EKGRP.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T024 WHERE EKGRP = EKKO-EKGRP.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T024 WHERE EKGRP = EKKO-EKGRP ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.
ENDFORM.                    "TAB024_LESEN
*------Lesen Tabelle T024D---------------------------------------------*
FORM TAB024D_LESEN.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM T024D WHERE WERKS = MSEG-WERKS
*                             AND   DISPO = AFKO-DISPO.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM T024D WHERE WERKS = MSEG-WERKS
                             AND   DISPO = AFKO-DISPO ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

ENDFORM.                    "TAB024D_LESEN

*---------------------- T027B,C lesen ---------------------------------*
FORM T027_LESEN.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM T027B WHERE SPRAS = LANGUAGE
*                             AND   EVERS = MSEG-EVERS.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM T027B WHERE SPRAS = LANGUAGE
                             AND   EVERS = MSEG-EVERS ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  CHECK NOT MSEG-EVERE IS INITIAL.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM T027C WHERE EVERS = MSEG-EVERS
*                             AND   EVERE = MSEG-EVERE.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM T027C WHERE EVERS = MSEG-EVERS
                             AND   EVERE = MSEG-EVERE ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF NOT T027C-EVDRK IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T027D WHERE SPRAS = LANGUAGE
*                               AND   EVERS = MSEG-EVERS
*                               AND   EVERE = MSEG-EVERE.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T027D WHERE SPRAS = LANGUAGE
                               AND   EVERS = MSEG-EVERS
                               AND   EVERE = MSEG-EVERE ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

ENDFORM.                                                    "T027_LESEN
*------------ Lesen der Tabelle T159P Barcode oder Mehrfachdruck ------*
*----------------------- gewünscht ? ----------------------------------*
FORM LESEN_T159P.
  IF NOT T159P-TDDEST = NAST-LDEST.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T159P WHERE TDDEST = NAST-LDEST.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T159P WHERE TDDEST = NAST-LDEST ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.
ENDFORM.                    "LESEN_T159P
*&---------------------------------------------------------------------*
*&      Form  T064B_LESEN
*&---------------------------------------------------------------------*
*       Lesen Text zur Bestandsart Qualität/Gesperrt bei WE
*----------------------------------------------------------------------*
FORM T064B_LESEN.
  DATA: BSTAR LIKE T064B-BSTAR.
  CASE MSEG-INSMK.
    WHEN SPACE.
      CLEAR T064B.
      EXIT.
    WHEN F.
      CLEAR T064B.
      EXIT.
    WHEN X.
      BSTAR = ZWEI.
    WHEN ZWEI.
      BSTAR = ZWEI.
    WHEN S.
      BSTAR = VIER.
    WHEN DREI.
      BSTAR = VIER.
  ENDCASE.
  IF NOT T064B-BSTAR = BSTAR.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T064B WHERE SPRAS = LANGUAGE
*                               AND   BSTAR = BSTAR.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T064B WHERE SPRAS = LANGUAGE
                               AND   BSTAR = BSTAR ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.
ENDFORM.                    " T064B_LESEN
*end /SMBA0/AA_M07DRMTA

*---------------------------------------------------------------------------*
*include /SMBA0/AA_M07DRF01
*---------------------------------------------------------------------------*
FORM WF01_DRUCK.
  CALL FUNCTION 'START_FORM'
    EXPORTING
      FORM     = TNAPR-FONAM
      LANGUAGE = LANGUAGE.
  BELPOS-MBLNR = MKPF-MBLNR.
  BELPOS-ZEILE = MSEG-ZEILE.
  CONDENSE BELPOS NO-GAPS.
  AM07M-BELPOS = BELPOS.
  IF T156-SHKZG = H.
    AM07M-HDLNE = TEXT-020.
  ELSE.
    AM07M-HDLNE = TEXT-010.
  ENDIF.
  IF NOT T159P-BACOD IS INITIAL.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'W1BACOKOPF'.
  ELSE.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'W1KOPF'.
  ENDIF.
  IF XPSTY       IS INITIAL.
    IF MSEG-XBLVS IS INITIAL.
      PERFORM WF1_LAGERMATERIAL.             "Lagermaterial
    ELSE.
      PERFORM WF1_LVSMATERIAL.               "LVS-Material
    ENDIF.
  ELSE.
    PERFORM WF1_VERBRAUCHSMATERIAL.
  ENDIF.
  CALL FUNCTION 'END_FORM'.
  PERFORM MKTO_DRUCK.
ENDFORM.                                                    "WF01_DRUCK
*------------ Drucken Lagermaterial ---------------------------------*
FORM WF1_LAGERMATERIAL.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'W1LGMAT'.
  IF T156-SHKZG = H AND
    NOT MSEG-GRUND IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T157E WHERE BWART = MSEG-BWART
*                               AND   GRUND = MSEG-GRUND
*                               AND   SPRAS = LANGUAGE.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T157E WHERE BWART = MSEG-BWART
                               AND   GRUND = MSEG-GRUND
                               AND   SPRAS = LANGUAGE ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'RUELGGRUND'.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'LGAUSST'.
ENDFORM.                    "WF1_LAGERMATERIAL

*&---------------------------------------------------------------------*
*&      Form  WF1_LVSMATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM WF1_LVSMATERIAL.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'W1LVSMAT'.
  IF T156-SHKZG = H AND
    NOT MSEG-GRUND IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T157E WHERE BWART = MSEG-BWART
*                               AND   GRUND = MSEG-GRUND
*                               AND   SPRAS = LANGUAGE.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T157E WHERE BWART = MSEG-BWART
                               AND   GRUND = MSEG-GRUND
                               AND   SPRAS = LANGUAGE ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'RUELVSGRUND'.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'LVSAUSST'.
ENDFORM.                    "WF1_LVSMATERIAL

*-------------Drucken Verbrauchsmaterial------------------------------*
FORM WF1_VERBRAUCHSMATERIAL.

  CASE XPSTY.

    WHEN XKDANR.                             "Kundenauftrag
      MOVE SPACE TO KUNDE.
      CLEAR AM07M-KOTXT.
      AM07M-KOTXT = TEXT-030.
      KUNDE-KDAUF = MSEG-KDAUF.
      KUNDE-KDPOS = MSEG-KDPOS.
      KUNDE-KDEIN = MSEG-KDEIN.
      MOVE SPACE TO AM07M-KONTIERUNG.
      CONDENSE KUNDE NO-GAPS.
      AM07M-KONTIERUNG = KUNDE.
    WHEN XANLAGE.                            "Anlage
      MOVE SPACE TO ANLAGE.
      CLEAR AM07M-KOTXT.
      AM07M-KOTXT = TEXT-040.
      ANLAGE-ANLN1 = MSEG-ANLN1.
      ANLAGE-ANLN2 = MSEG-ANLN2.
      MOVE SPACE TO AM07M-KONTIERUNG.
      CONDENSE ANLAGE NO-GAPS.
      AM07M-KONTIERUNG = ANLAGE.
    WHEN XKOSTL.                             "Kostenstelle
      CLEAR AM07M-KOTXT.
      AM07M-KOTXT = TEXT-050.
      AM07M-KONTIERUNG = MSEG-KOSTL.

    WHEN XPROJN.                             "Projekt/Netzplan
      CLEAR AM07M-KOTXT.
      IF MSEG-NPLNR IS INITIAL.
        AM07M-KOTXT = TEXT-060.
        PERFORM PSP_CONVERT USING MSEG-PS_PSP_PNR.
      ELSE.
        AM07M-KOTXT = TEXT-061.
        AM07M-KONTIERUNG = MSEG-NPLNR.
        PERFORM NW_VORGANG_LESEN USING MSEG-AUFPL MSEG-APLZL.
        IF NOT N_VORNR IS INITIAL.
          MOVE '/'     TO AM07M-KONTIERUNG+12.
          MOVE N_VORNR TO AM07M-KONTIERUNG+13.
        ENDIF.
      ENDIF.
  ENDCASE.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'W1VERBRMAT'.
  IF T156-SHKZG = H AND
    NOT MSEG-GRUND IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T157E WHERE BWART = MSEG-BWART
*                               AND   GRUND = MSEG-GRUND
*                               AND   SPRAS = LANGUAGE.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T157E WHERE BWART = MSEG-BWART
                               AND   GRUND = MSEG-GRUND
                               AND   SPRAS = LANGUAGE ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'RUELVERBRGRUND'.
  ENDIF.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'VERBRAUSST'.
ENDFORM.                    "WF1_VERBRAUCHSMATERIAL
*end /SMBA0/AA_M07DRF01

*---------------------------------------------------------------------------*
*include /SMBA0/AA_M07DRF02
*---------------------------------------------------------------------------*
FORM WF02_DRUCK.
  T001W-WERKS = R_WERKS.
  T001W-NAME1 = R_NAME1.
  CALL FUNCTION 'START_FORM'
    EXPORTING
      FORM     = TNAPR-FONAM
      LANGUAGE = LANGUAGE.
  PERFORM PRUEFTEXT_LESEN.
  IF T156-SHKZG = 'H'.           "Kennzeichen Haben ?
    AM07M-HDLNE = TEXT-020.
  ELSE.
    AM07M-HDLNE = TEXT-010.
  ENDIF.
  IF NOT T159P-BACOD IS INITIAL.
    BELPOS-MBLNR = MKPF-MBLNR.
    BELPOS-ZEILE = MSEG-ZEILE.
    CONDENSE BELPOS NO-GAPS.
    AM07M-BELPOS = BELPOS.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'WE2BACOKOPF'.
  ELSE.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'WE2KOPF'.
  ENDIF.
  IF XPSTY       IS INITIAL.        "Lagermaterial ?
    PERFORM W2_LAGERMATERIAL.
  ELSE.
    PERFORM W2_VERBRAUCHSMATERIAL.
  ENDIF.
  CALL FUNCTION 'END_FORM'.
  PERFORM MKTO_DRUCK.
ENDFORM.                                                    "WF02_DRUCK

*-------------- Lagermaterial WE-Version 2 ---------------------------*
FORM WF2_LAGERMATERIAL.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'WE2LGMAT'.
  IF T156-SHKZG = H AND
     NOT MSEG-GRUND IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T157E WHERE BWART = MSEG-BWART
*                               AND   GRUND = MSEG-GRUND
*                               AND   SPRAS = LANGUAGE.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T157E WHERE BWART = MSEG-BWART
                               AND   GRUND = MSEG-GRUND
                               AND   SPRAS = LANGUAGE ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'RUELGGRUND'.
  ENDIF.
  THEAD-TDID     = THEADER-TDID.
  THEAD-TDNAME   = THEADER-TDNAME.
  THEAD-TDOBJECT = THEADER-TDOBJECT.
  THEAD-TDSPRAS  = THEADER-TDSPRAS.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'PRTXTLGMAT'.

ENDFORM.                    "WF2_LAGERMATERIAL

*------------ Verbrauchsmaterial WE-Version 2 ----------------------*
FORM WF2_VERBRAUCHSMATERIAL.
  CASE XPSTY.
    WHEN XKDANR.
      MOVE SPACE TO KUNDE.
      CLEAR AM07M-KOTXT.
      AM07M-KOTXT = TEXT-030.
      KUNDE-KDAUF = MSEG-KDAUF.
      KUNDE-KDPOS = MSEG-KDPOS.
      KUNDE-KDEIN = MSEG-KDEIN.
      MOVE SPACE TO AM07M-KONTIERUNG.
      CONDENSE KUNDE NO-GAPS.
      AM07M-KONTIERUNG = KUNDE.
    WHEN XANLAGE.
      MOVE SPACE TO ANLAGE.
      CLEAR AM07M-KOTXT.
      AM07M-KOTXT = TEXT-040.
      ANLAGE-ANLN1 = MSEG-ANLN1.
      ANLAGE-ANLN2 = MSEG-ANLN2.
      MOVE SPACE TO AM07M-KONTIERUNG.
      CONDENSE ANLAGE NO-GAPS.
      AM07M-KONTIERUNG = ANLAGE.
    WHEN XKOSTL.
      CLEAR AM07M-KOTXT.
      AM07M-KOTXT = TEXT-050.
      AM07M-KONTIERUNG = MSEG-KOSTL.

    WHEN XPROJN.
      CLEAR AM07M-KOTXT.
      IF MSEG-NPLNR IS INITIAL.
        AM07M-KOTXT = TEXT-060.
        PERFORM PSP_CONVERT USING MSEG-PS_PSP_PNR.
      ELSE.
        AM07M-KOTXT = TEXT-061.
        AM07M-KONTIERUNG = MSEG-NPLNR.
        PERFORM NW_VORGANG_LESEN USING MSEG-AUFPL MSEG-APLZL.
        IF NOT N_VORNR IS INITIAL.
          MOVE '/'     TO AM07M-KONTIERUNG+12.
          MOVE N_VORNR TO AM07M-KONTIERUNG+13.
        ENDIF.
      ENDIF.
  ENDCASE.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'WE2VERBRMAT'.
  IF T156-SHKZG = H AND
    NOT MSEG-GRUND IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T157E WHERE BWART = MSEG-BWART
*                               AND   GRUND = MSEG-GRUND
*                               AND   SPRAS = LANGUAGE.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T157E WHERE BWART = MSEG-BWART
                               AND   GRUND = MSEG-GRUND
                               AND   SPRAS = LANGUAGE ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'RUEVERBRGRUND'.
  ENDIF.
  THEAD-TDID     = THEADER-TDID.
  THEAD-TDNAME   = THEADER-TDNAME.
  THEAD-TDOBJECT = THEADER-TDOBJECT.
  THEAD-TDSPRAS  = THEADER-TDSPRAS.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'PRTXTVERBRMAT'.
ENDFORM.                    "WF2_VERBRAUCHSMATERIAL
*end /SMBA0/AA_M07DRF02

*---------------------------------------------------------------------------*
*include /SMBA0/AA_M07DRE02
*---------------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM WE02_DRUCK                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM WE02_DRUCK.
  T001W-WERKS = R_WERKS.
  T001W-NAME1 = R_NAME1.
  CALL FUNCTION 'START_FORM'
    EXPORTING
      FORM     = TNAPR-FONAM
      LANGUAGE = LANGUAGE.
  PERFORM PRUEFTEXT_LESEN.
  IF NOT MSEG-VFDAT IS INITIAL.
    AM07M-MHTXT = TEXT-105.
  ENDIF.
  IF NOT AM07M-MHDAT IS INITIAL.
    AM07M-MHZTX = TEXT-106.
  ENDIF.
  IF EKKO-BSART = 'UB'.
    AM07M-LITXT = TEXT-101.
    AM07M-LIBZG = EKKO-RESWK.
  ELSE.
    AM07M-LITXT = TEXT-100.
    AM07M-LIBZG = EKKO-LIFNR.
    IF NOT EKKO-LLIEF IS INITIAL.
      AM07M-LIBZ2 = EKKO-LLIEF.
    ELSE.
      AM07M-LIBZ2 = EKKO-LIFNR.
    ENDIF.
  ENDIF.
  IF T156-SHKZG = 'H'.                 "Kennzeichen Haben ?
    AM07M-HDLNE = TEXT-020.
  ELSE.
    AM07M-HDLNE = TEXT-010.
  ENDIF.
  IF NOT T159P-BACOD IS INITIAL.
    BELPOS-MBLNR = MKPF-MBLNR.
    BELPOS-ZEILE = MSEG-ZEILE.
    CONDENSE BELPOS NO-GAPS.
    AM07M-BELPOS = BELPOS.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'WE2BACOKOPF'.
  ELSE.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'WE2KOPF'.
  ENDIF.
  IF XPSTY       IS INITIAL.           "Lagermaterial ?
* User-Exit über Erweiterung MBCF0005
    CALL CUSTOMER-FUNCTION '001'
         EXPORTING
              I_MKPF  = MKPF
              I_MSEG  = MSEG
              I_EKKO  = EKKO
              I_EKPO  = EKPO
              I_NAST  = NAST
              I_TNAPR = TNAPR
         TABLES
              I_EKKN  = XEKKN
         CHANGING
              C_AM07M = AM07M
         EXCEPTIONS
              OTHERS  = 0.

    IF MSEG-XBLVS IS INITIAL.
      PERFORM W2_LAGERMATERIAL.             "Lagermaterial
    ELSE.
      PERFORM W2_LVSMATERIAL.               "LVS-Material
    ENDIF.
  ELSE.
    PERFORM W2_VERBRAUCHSMATERIAL.
  ENDIF.

  CALL FUNCTION 'END_FORM'.
  PERFORM MKTO_DRUCK.
ENDFORM.                                                    "WE02_DRUCK

*-------------- Lagermaterial WE-Version 2 ---------------------------*
FORM W2_LAGERMATERIAL.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'WE2LGMAT'.
  IF T156-SHKZG = H AND
     NOT MSEG-GRUND IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T157E WHERE BWART = MSEG-BWART
*                               AND   GRUND = MSEG-GRUND
*                               AND   SPRAS = LANGUAGE.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T157E WHERE BWART = MSEG-BWART
                               AND   GRUND = MSEG-GRUND
                               AND   SPRAS = LANGUAGE ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'RUELGGRUND'.
  ENDIF.
  THEAD-TDID     = THEADER-TDID.
  THEAD-TDNAME   = THEADER-TDNAME.
  THEAD-TDOBJECT = THEADER-TDOBJECT.
  THEAD-TDSPRAS  = THEADER-TDSPRAS.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'PRTXTLGMAT'.

ENDFORM.                    "W2_LAGERMATERIAL

*-------------- LVS-Daten     WE-Version 2 ---------------------------*
FORM W2_LVSMATERIAL.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'W1LVSMAT'.
  IF T156-SHKZG = H AND
     NOT MSEG-GRUND IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T157E WHERE BWART = MSEG-BWART
*                               AND   GRUND = MSEG-GRUND
*                               AND   SPRAS = LANGUAGE.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T157E WHERE BWART = MSEG-BWART
                               AND   GRUND = MSEG-GRUND
                               AND   SPRAS = LANGUAGE ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'RUELVSGRUND'.
  ENDIF.
  THEAD-TDID     = THEADER-TDID.
  THEAD-TDNAME   = THEADER-TDNAME.
  THEAD-TDOBJECT = THEADER-TDOBJECT.
  THEAD-TDSPRAS  = THEADER-TDSPRAS.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'PRTXTLVSMAT'.

ENDFORM.                    "W2_LVSMATERIAL

*------------ Verbrauchsmaterial WE-Version 2 ----------------------*
FORM W2_VERBRAUCHSMATERIAL.
  CLEAR: AM07M-KOTXT, AM07M-KONTIERUNG.
  CASE XPSTY.
    WHEN XFERT.                        "Fertigungsauftrag
      AM07M-KOTXT = TEXT-062.
      IF X_KONT1 IS INITIAL.
        AM07M-KONTIERUNG = MSEG-AUFNR.
      ELSE.
        AM07M-KONTIERUNG = EKKN-AUFNR.
      ENDIF.
    WHEN XKDE.
      MOVE SPACE TO KUNDE.
      AM07M-KOTXT = TEXT-030.
      IF X_KONT1 IS INITIAL.
        KUNDE-KDAUF = MSEG-KDAUF.
        KUNDE-KDPOS = MSEG-KDPOS.
      ELSE.
        KUNDE-KDAUF = EKKN-VBELN.
        KUNDE-KDPOS = EKKN-VBELP.
      ENDIF.
      MOVE SPACE TO AM07M-KONTIERUNG.
      CONDENSE KUNDE NO-GAPS.
      AM07M-KONTIERUNG = KUNDE.
    WHEN XKDANR.
      MOVE SPACE TO KUNDE.
      AM07M-KOTXT = TEXT-030.
      IF X_KONT1 IS INITIAL.
        KUNDE-KDAUF = MSEG-KDAUF.
        KUNDE-KDPOS = MSEG-KDPOS.
        KUNDE-KDEIN = MSEG-KDEIN.
      ELSE.
        KUNDE-KDAUF = EKKN-VBELN.
        KUNDE-KDPOS = EKKN-VBELP.
        KUNDE-KDEIN = EKKN-VETEN.
      ENDIF.
      MOVE SPACE TO AM07M-KONTIERUNG.
      CONDENSE KUNDE NO-GAPS.
      AM07M-KONTIERUNG = KUNDE.
    WHEN XANLAGE.
      MOVE SPACE TO ANLAGE.
      AM07M-KOTXT = TEXT-040.
      IF X_KONT1 IS INITIAL.
        ANLAGE-ANLN1 = MSEG-ANLN1.
        ANLAGE-ANLN2 = MSEG-ANLN2.
      ELSE.
        ANLAGE-ANLN1 = EKKN-ANLN1.
        ANLAGE-ANLN2 = EKKN-ANLN2.
      ENDIF.
      MOVE SPACE TO AM07M-KONTIERUNG.
      CONDENSE ANLAGE NO-GAPS.
      AM07M-KONTIERUNG = ANLAGE.
    WHEN XKOSTL.
      AM07M-KOTXT = TEXT-050.
      IF X_KONT1 IS INITIAL.
        AM07M-KONTIERUNG = MSEG-KOSTL.
      ELSE.
        AM07M-KONTIERUNG = EKKN-KOSTL.
      ENDIF.

    WHEN XPROJN.
      IF X_KONT1 IS INITIAL.
        IF MSEG-NPLNR IS INITIAL.
          AM07M-KOTXT = TEXT-060.
          PERFORM PSP_CONVERT USING MSEG-PS_PSP_PNR.
        ELSE.
          AM07M-KOTXT = TEXT-061.
          AM07M-KONTIERUNG = MSEG-NPLNR.
          PERFORM NW_VORGANG_LESEN USING MSEG-AUFPL MSEG-APLZL.
          IF NOT N_VORNR IS INITIAL.
            MOVE '/'     TO AM07M-KONTIERUNG+12.
            MOVE N_VORNR TO AM07M-KONTIERUNG+13.
          ENDIF.
        ENDIF.
      ELSE.
        IF EKKN-NPLNR IS INITIAL.
          AM07M-KOTXT = TEXT-060.
          PERFORM PSP_CONVERT USING EKKN-PS_PSP_PNR.
        ELSE.
          AM07M-KOTXT = TEXT-061.
          AM07M-KONTIERUNG = EKKN-NPLNR.
          PERFORM NW_VORGANG_LESEN USING EKKN-AUFPL EKKN-APLZL.
          IF NOT N_VORNR IS INITIAL.
            MOVE '/'     TO AM07M-KONTIERUNG+12.
            MOVE N_VORNR TO AM07M-KONTIERUNG+13.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
  CLEAR X_KONT1.
* User-Exit über Erweiterung MBCF0005
  CALL CUSTOMER-FUNCTION '001'
       EXPORTING
            I_MKPF  = MKPF
            I_MSEG  = MSEG
            I_EKKO  = EKKO
            I_EKPO  = EKPO
            I_NAST  = NAST
            I_TNAPR = TNAPR
       TABLES
            I_EKKN  = XEKKN
       CHANGING
            C_AM07M = AM07M
       EXCEPTIONS
            OTHERS  = 0.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'WE2VERBRMAT'.
  IF T156-SHKZG = H AND
    NOT MSEG-GRUND IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM T157E WHERE BWART = MSEG-BWART
*                               AND   GRUND = MSEG-GRUND
*                               AND   SPRAS = LANGUAGE.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM T157E WHERE BWART = MSEG-BWART
                               AND   GRUND = MSEG-GRUND
                               AND   SPRAS = LANGUAGE ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'RUEVERBRGRUND'.
  ENDIF.
  THEAD-TDID     = THEADER-TDID.
  THEAD-TDNAME   = THEADER-TDNAME.
  THEAD-TDOBJECT = THEADER-TDOBJECT.
  THEAD-TDSPRAS  = THEADER-TDSPRAS.
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'PRTXTVERBRMAT'.
ENDFORM.                    "W2_VERBRAUCHSMATERIAL
*end /SMBA0/AA_M07DRE02

*---------------------------------------------------------------------------*
*include /SMBA0/AA_M07DRENT
*---------------------------------------------------------------------------*
*----------- Wareneingangsschein Version 1 ----------------------------*
FORM entry_we01 USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen USING nast-objky.
  ent_retco = retco.
  PERFORM ausgabe_we01.
ENDFORM.                                                    "entry_we01
*----------- Wareneingangsschein Version 2 ----------------------------*
FORM entry_we02 USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen USING nast-objky.
  ent_retco = retco.
  PERFORM bestellkopf_lesen.
  PERFORM ausgabe_we02.
ENDFORM.                                                    "entry_we02
*----------- Wareneingangsschein Version 3 ----------------------------*
FORM entry_we03 USING ent_retco ent_screen.

  xscreen = ent_screen.
  CLEAR ent_retco.
  CLEAR lgortsplit.
  PERFORM lesen USING nast-objky.
  ent_retco = retco.
  PERFORM print_smartform.
  ent_retco = retco.
ENDFORM.                                                    "entry_we03
*----------- Wareneingangsschein Version 3 mit Lagerortsplitt ---------*
FORM entry_we03l USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  lgortsplit = 'X'.
  PERFORM lesen_wes USING nast-objky lgortsplit.
  ent_retco = retco.
ENDFORM.                    "entry_we03l
*----------- Kanbankarte bei WE ---------------------------------------*
FORM entry_wek1 USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen USING nast-objky.
  PERFORM ausgabe_wek1.
ENDFORM.                                                    "entry_wek1
*----------------------------------------------------------------------*
*--------------- Warenausgangsscheine ---------------------------------*
*----------------------------------------------------------------------*
*---------------- Warenausgangsschein Version 1 -----------------------*
FORM entry_wa01 USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen_wa USING nast-objky.
  ent_retco = retco.
  PERFORM ausgabe_we01.
ENDFORM.                                                    "entry_wa01
*---------------- Warenausgangsschein Version 2 -----------------------*
FORM entry_wa02 USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen_wa USING nast-objky.
  ent_retco = retco.
  PERFORM ausgabe_we02.
ENDFORM.                                                    "entry_wa02
*---------------- Warenausgangsschein Version 3 -----------------------*
FORM entry_wa03 USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  CLEAR lgortsplit.
  PERFORM lesen_was USING nast-objky lgortsplit.
  ent_retco = retco.
  PERFORM print_smartform.
ENDFORM.                                                    "entry_wa03
*---------------- Warenausgangsschein Version 3 mit Lagerortsplit------*
FORM entry_wa03l USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  lgortsplit = 'X'.
  PERFORM lesen_was USING nast-objky lgortsplit.
  ent_retco = retco.
ENDFORM.                    "entry_wa03l
*----------------------------------------------------------------------*
*--------------- Etikettendruck beim Warenausgang ---------------------*
*----------------------------------------------------------------------*
FORM entry_etia USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen_wa USING nast-objky.
  ent_retco = retco.
  PERFORM ausgabe_eti.
ENDFORM.                    "entry_etia
*----------------------------------------------------------------------*
*---------- Etikettendruck beim Wareneingang --------------------------*
*----------------------------------------------------------------------*
FORM entry_etie USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen USING nast-objky.
  ent_retco = retco.
  PERFORM bestellkopf_lesen.
  PERFORM ausgabe_eti.
ENDFORM.                    "entry_etie
*----------------------------------------------------------------------*
*------ Etikettendruck beim Wareneingang Version 3 --------------------*
*----------------------------------------------------------------------*
FORM entry_eties USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen_wese USING nast-objky.
  ent_retco = retco.
ENDFORM.                    "entry_eties
*----------------------------------------------------------------------*
*----- Etikettendruck beim Warenausgang Version 3 ---------------------*
*----------------------------------------------------------------------*
FORM entry_etias USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen_wase USING nast-objky.
  ent_retco = retco.
ENDFORM.                    "entry_etias
*----------------------------------------------------------------------*
*--------------- Warenausgangsscheine ---------------------------------*
*----------------------------------------------------------------------*
*------ Warenausgangsschein Lohnbearbeiter Vers1. ---------------------*
FORM entry_wlb1 USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen_wlb USING nast-objky.
  ent_retco = retco.
  PERFORM ausgabe_wlb1.
ENDFORM.                                                    "entry_wlb1
*----------------------------------------------------------------------*
*--------------- Warenausgangsscheine ---------------------------------*
*----------------------------------------------------------------------*
*------ Warenausgangsschein Lohnbearbeiter Vers2. ---------------------*
FORM entry_wlb2 USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen_wlb USING nast-objky.
  ent_retco = retco.
  PERFORM ausgabe_wlb2.
ENDFORM.                                                    "entry_wlb2
*eject
*------------- Warenausgangsschein LB Version 3 -----------------------*
FORM entry_wlb3 USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen_wlbs USING nast-objky.
  ent_retco = retco.
ENDFORM.                                                    "entry_wlb3
*------- Wareneingangsscheine für Fertigungsaufträge ------------------*
*----------------------------------------------------------------------*
*----------- Wareneingangsschein Version 1 ----------------------------*
FORM entry_wf01 USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen_wf USING nast-objky.
  ent_retco = retco.
  PERFORM ausgabe_we01. "SF-Ausgabe
*  PERFORM ausgabe_wf01.
ENDFORM.                                                    "entry_wf01
*----------- Wareneingangsschein Version 2 ----------------------------*
FORM entry_wf02 USING ent_retco ent_screen.
  xscreen = ent_screen.
  CLEAR ent_retco.
  PERFORM lesen_wf USING nast-objky.
  ent_retco = retco.
  PERFORM bestellkopf_lesen.
*  PERFORM ausgabe_wf02.
  PERFORM ausgabe_we02. "SF-Ausgabe
ENDFORM.                                                    "entry_wf02
*end /SMBA0/AA_M07DENT

*---------------------------------------------------------------------------*
*include /SMBA0/AA_M07DRAUS
*---------------------------------------------------------------------------*

*------------- Wareneingangsschein Version 1 --------------------------*
FORM ausgabe_we01.
  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_control_param      TYPE ssfctrlop.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: ls_recipient          TYPE swotobjid.
  DATA: ls_sender             TYPE swotobjid.
  DATA: lf_formname           TYPE tdsfname.
  DATA: ls_addr_key           LIKE addr_key.
  data: ls_job_info           type ssfcrescl.
  data: l_spoolid             type rspoid.

  PERFORM lesen_t159p.
  PERFORM itcpo_fuellen.
  IF NOT t159p-xmehr IS INITIAL.
    IF mseg-weanz GT 0.
      anzahl = mseg-weanz.
    ELSE.
      anzahl = 1.
    ENDIF.
  ELSE.
    anzahl = 1.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
                            CHANGING ls_control_param
                                     ls_composer_param
                                     ls_recipient
                                     ls_sender
                                     retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(ssfcomposer).
  ENDIF.

* determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
       EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
       IMPORTING  fm_name            = lf_fm_name
       EXCEPTIONS no_form            = 1
                  no_function_module = 2
                  OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.
  DO anzahl TIMES.
    CALL FUNCTION lf_fm_name
      EXPORTING
         archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
         archive_parameters         = arc_params
         control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
         mail_recipient             = ls_recipient
         mail_sender                = ls_sender
         output_options             = ls_composer_param
         user_settings              = ' '
         is_mseg                       = mseg
         is_ekpo                       = ekpo
         is_t157e                      = t157e
         is_am07m                      = am07m
         is_mkpf                       = mkpf
         is_nast                       = nast
         is_t159p                      =  t159p
         is_t001w                      = t001w
         is_ekko                       = ekko
         is_t024                       = t024
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
 EXCEPTIONS
   formatting_error           = 1
   internal_error             = 2
   send_error                 = 3
   user_canceled              = 4
   OTHERS                     = 5
              .
    IF sy-subrc <> 0.
      retco = sy-subrc.
      PERFORM protocol_update_i.
* get SmartForm protocoll and store it in the NAST protocoll
      PERFORM add_smfrm_prot.
    else.
      read table ls_job_info-spoolids into l_spoolid index 1.
      if sy-subrc is initial.
        export spoolid = l_spoolid to memory id 'KYK_SPOOLID'.
      endif.
    ENDIF.
  ENDDO.
ENDFORM.                    "ausgabe_we01
*eject.
*------------- Wareneingangsschein Version 2 --------------------------*
FORM ausgabe_we02.
*smartform input parameters
  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_control_param      TYPE ssfctrlop.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: ls_recipient          TYPE swotobjid.
  DATA: ls_sender             TYPE swotobjid.
  DATA: lf_formname           TYPE tdsfname.
  DATA: ls_addr_key           LIKE addr_key.
  PERFORM lesen_t159p.
  PERFORM itcpo_fuellen.
  IF NOT t159p-xmehr IS INITIAL.
    IF mseg-weanz GT 0.
      anzahl = mseg-weanz.
    ELSE.
      anzahl = 1.
    ENDIF.
  ELSE.
    anzahl = 1.
  ENDIF.
  PERFORM set_print_param USING      ls_addr_key
                          CHANGING ls_control_param
                                   ls_composer_param
                                   ls_recipient
                                   ls_sender
                                   retco.

*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(ssfcomposer).
  ENDIF.

* determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
       EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
       IMPORTING  fm_name            = lf_fm_name
       EXCEPTIONS no_form            = 1
                  no_function_module = 2
                  OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.

  DO anzahl TIMES.
    CALL FUNCTION lf_fm_name
      EXPORTING
         archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
         archive_parameters         = arc_params
         control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
         mail_recipient             = ls_recipient
         mail_sender                = ls_sender
         output_options             = ls_composer_param
         user_settings              = ' '
         is_mseg                       = mseg
         is_ekpo                       = ekpo
         is_t157e                      = t157e
         is_am07m                      = am07m
         is_mkpf                       = mkpf
         is_nast                       = nast
         is_t159p                      =  t159p
         is_t001w                      = t001w
         is_ekko                       = ekko
         is_t024                       = t024
   EXCEPTIONS
     formatting_error           = 1
     internal_error             = 2
     send_error                 = 3
     user_canceled              = 4
     OTHERS                     = 5
              .
    IF sy-subrc <> 0.
      retco = sy-subrc.
      PERFORM protocol_update_i.
* get SmartForm protocoll and store it in the NAST protocoll
      PERFORM add_smfrm_prot.
    ENDIF.
  ENDDO.
ENDFORM.                    "ausgabe_we02
*------------- Kanbankarte bei WE -------------------------------------*
FORM ausgabe_wek1.
  TABLES pkps.
  IF NOT mseg-aufnr IS INITIAL.
    pkps-aufnr = mseg-aufnr.
  ELSEIF NOT mseg-ebeln IS INITIAL.
    pkps-ebeln = mseg-ebeln.
    pkps-ebelp = mseg-ebelp.
  ELSEIF NOT mseg-rsnum IS INITIAL.
    pkps-rsnum = mseg-rsnum.
  ENDIF.
  PERFORM itcpo_fuellen.
  CALL FUNCTION 'PK_PRINT_KANBAN_GR'
    EXPORTING
      ipkps   = pkps
      iitcpo  = itcpo
      itdform = tnapr-fonam
      imblnr  = mseg-mblnr.
ENDFORM.                    "ausgabe_wek1
*eject.
*------------- Warenausgangsschein Version 1 --------------------------*
FORM ausgabe_wa01.
  PERFORM open_form.
  PERFORM wa01_druck.
  PERFORM close_form.
ENDFORM.                    "ausgabe_wa01
*eject.
*------------- Warenausgangsschein Version 2 --------------------------*
FORM ausgabe_wa02.
  PERFORM open_form.
  PERFORM wa02_druck.
  PERFORM close_form.
ENDFORM.                    "ausgabe_wa02
*eject.
*------------- Lesen und Ausgabe für WE-Sammelschein ------------------*
FORM lesen_wes USING objky lgortsplit.
  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_control_param      TYPE ssfctrlop.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: ls_recipient          TYPE swotobjid.
  DATA: ls_sender             TYPE swotobjid.
  DATA: lf_formname           TYPE tdsfname.
  DATA: ls_addr_key           LIKE addr_key.

  REFRESH traptab.
  CLEAR retco.
  CLEAR: xkopfdr, new_page.
  nast_key = objky.
  PERFORM lesen_t159p.
  PERFORM itcpo_fuellen.
  IF NOT t159p-xmehr IS INITIAL.
    IF mseg-weanz GT 0.
      anzahl = mseg-weanz.
    ELSE.
      anzahl = 1.
    ENDIF.
  ELSE.
    anzahl = 1.
  ENDIF.

  PERFORM set_print_param USING      ls_addr_key
                          CHANGING ls_control_param
                                   ls_composer_param
                                   ls_recipient
                                   ls_sender
                                   retco.
  lf_formname = tnapr-fonam.
* determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
       EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
       IMPORTING  fm_name            = lf_fm_name
       EXCEPTIONS no_form            = 1
                  no_function_module = 2
                  OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    retco = sy-subrc.
    PERFORM protocol_update_i.
  ENDIF.


  DO anzahl TIMES.
    CALL FUNCTION lf_fm_name
      EXPORTING
         archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
         archive_parameters         = arc_params
         control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
         mail_recipient             = ls_recipient
         mail_sender                = ls_sender
         output_options             = ls_composer_param
         user_settings              = 'X'
         nast                       = nast
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
 EXCEPTIONS
   formatting_error           = 1
   internal_error             = 2
   send_error                 = 3
   user_canceled              = 4
   OTHERS                     = 5
              .
    IF sy-subrc <> 0.
      retco = sy-subrc.
      PERFORM protocol_update_i.
* get SmartForm protocoll and store it in the NAST protocoll
      PERFORM add_smfrm_prot.
    ENDIF.
  ENDDO.
ENDFORM.                    "lesen_wes
**eject.
**-------------- Lesen und  Ausgabe Warenausgangssammelschein
*----------*
FORM lesen_was USING objky lgortsplit.
  REFRESH traptab.
  nast_key = objky.
  CLEAR retco.
  CLEAR: xkopfdr, new_page.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mkpf WHERE mblnr = nast_key-mblnr
*                            AND   mjahr = nast_key-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mkpf WHERE mblnr = nast_key-mblnr
                            AND   mjahr = nast_key-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  MOVE-CORRESPONDING mkpf TO traptab.
  zaehler_m = 1.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM mseg WHERE mblnr = mkpf-mblnr
*                     AND   mjahr = mkpf-mjahr.
*
* NEW CODE
  SELECT *
 FROM mseg WHERE mblnr = mkpf-mblnr
                     AND   mjahr = mkpf-mjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    IF sy-subrc NE 0.
      retco = sy-subrc.
      EXIT.
    ENDIF.
    CHECK mseg-xauto IS INITIAL.
    IF zaehler_m = 1.
      CLEAR zaehler_m.
      PERFORM tab001w_lesen.
    ENDIF.
    MOVE-CORRESPONDING mseg TO traptab.
    APPEND traptab.
  ENDSELECT.
*  perform open_form_sammel.
*  sort traptab by werks lgort zeile.
*  loop at traptab.
*    move-corresponding traptab to mkpf.
*    move-corresponding traptab to mseg.
*    perform tab156_lesen.
*    check not t156-kzdru is initial.                        " 108942
*    xskkz = t156-rstyp.
*    perform tab001w_lesen_2.
*    if not mseg-matnr is initial.
*      perform material_lesen.
*    endif.
*    perform ladr_lesen.
*    perform helpdata1.
*    perform wa03_ausgabe using lgortsplit.
*    perform helpdata2.
*  endloop.
*  perform close_form.
ENDFORM.                    "lesen_was
*eject.
*------------------- Ausgabe Etiketten --------------------------------*
FORM ausgabe_eti.
  PERFORM open_form.
  PERFORM eti_druck.
  PERFORM close_form.
ENDFORM.                    "ausgabe_eti
*eject.
*------------- Etikettendruck bei Version 3 Wareneingang --------------*
FORM lesen_wese USING objky.
  CLEAR retco.
  nast_key = objky.
  zaehler_m = 1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mkpf WHERE mblnr = nast_key-mblnr
*                            AND   mjahr = nast_key-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mkpf WHERE mblnr = nast_key-mblnr
                            AND   mjahr = nast_key-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM mseg WHERE mblnr = mkpf-mblnr
*                     AND   mjahr = mkpf-mjahr.
*
* NEW CODE
  SELECT *
 FROM mseg WHERE mblnr = mkpf-mblnr
                     AND   mjahr = mkpf-mjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    IF sy-subrc NE 0.
      retco = sy-subrc.
      EXIT.
    ENDIF.
    IF zaehler_m = 1.
      CLEAR zaehler_m.
      PERFORM tab001w_lesen.
      PERFORM open_form.
    ENDIF.
    PERFORM tab156_lesen.
    CHECK NOT t156-kzdru IS INITIAL.
    xskkz = t156-rstyp.
    IF NOT mseg-evers IS INITIAL.      "Versandvorschriften lesen.
      PERFORM t027_lesen.
    ENDIF.
    PERFORM bestellung_lesen.
    IF mseg-matnr IS INITIAL.
      mseg-menge = mseg-bpmng.
      mseg-meins = mseg-bprme.
      PERFORM bestelltext_lesen.
    ELSE.
      PERFORM material_lesen.
    ENDIF.
    PERFORM tab024_lesen.
    PERFORM tab001w_lesen_2.
    PERFORM helpdata1.
    PERFORM eti_druck.
    PERFORM helpdata2.
  ENDSELECT.
  PERFORM close_form.
ENDFORM.                    "lesen_wese
*eject.
*------------ Etikettendruck Warenausgang Version 3 -------------------*
FORM lesen_wase USING objky.
  nast_key = objky.
  CLEAR retco.
  zaehler_m = 1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mkpf WHERE mblnr = nast_key-mblnr
*                            AND   mjahr = nast_key-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mkpf WHERE mblnr = nast_key-mblnr
                            AND   mjahr = nast_key-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM mseg WHERE mblnr = mkpf-mblnr
*                     AND   mjahr = mkpf-mjahr.
*
* NEW CODE
  SELECT *
 FROM mseg WHERE mblnr = mkpf-mblnr
                     AND   mjahr = mkpf-mjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    IF sy-subrc NE 0.
      retco = sy-subrc.
      EXIT.
    ENDIF.
    IF zaehler_m = 1.
      CLEAR zaehler_m.
      PERFORM tab001w_lesen.
      PERFORM open_form.
    ENDIF.
    PERFORM tab156_lesen.
    CHECK NOT t156-kzdru IS INITIAL.                        " 108942
    xskkz = t156-rstyp.
    PERFORM tab001w_lesen_2.
    IF NOT mseg-matnr IS INITIAL.
      PERFORM material_lesen.
    ENDIF.
    PERFORM helpdata1.
    PERFORM eti_druck.
    PERFORM helpdata2.
  ENDSELECT.
  PERFORM close_form.
ENDFORM.                    "lesen_wase
*eject.
*------------- Warenausgangsschein LB Version 1 -----------------------*
FORM ausgabe_wlb1.
  PERFORM open_form.
  PERFORM wa01_druck.
  PERFORM close_form.
ENDFORM.                    "ausgabe_wlb1
*eject.
*------------- Warenausgangsschein LB Version 2 -----------------------*
FORM ausgabe_wlb2.
  PERFORM open_form.
  PERFORM wa02_druck.
  PERFORM close_form.
ENDFORM.                    "ausgabe_wlb2
*eject.
*------- Lesen und Ausgabe Warenausgangssammelsch. LB -----------------*
FORM lesen_wlbs USING objky.
  nast_key = objky.
  CLEAR retco.
  CLEAR: xkopfdr, new_page.
  zaehler_m = 1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mkpf WHERE mblnr = nast_key-mblnr
*                            AND   mjahr = nast_key-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mkpf WHERE mblnr = nast_key-mblnr
                            AND   mjahr = nast_key-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM mseg INTO TABLE xmseg
*                     WHERE mblnr = mkpf-mblnr
*                     AND   mjahr = mkpf-mjahr.
*
* NEW CODE
  SELECT *
 FROM mseg INTO TABLE xmseg
                     WHERE mblnr = mkpf-mblnr
                     AND   mjahr = mkpf-mjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  LOOP AT xmseg.
    mseg = xmseg.
    CHECK mseg-sobkz IS INITIAL OR
          ( mseg-sobkz = o AND mseg-xauto IS INITIAL ).
    IF sy-subrc NE 0.
      retco = sy-subrc.
      EXIT.
    ENDIF.
    IF zaehler_m = 1.
      CLEAR zaehler_m.
      PERFORM tab001w_lesen.
      PERFORM open_form_sammel.
    ENDIF.
    PERFORM tab156_lesen.
    xskkz = t156-rstyp.
    IF NOT mseg-matnr IS INITIAL.
      PERFORM material_lesen.
    ENDIF.
    ON CHANGE OF mseg-lifnr.
      PERFORM read_address.
    ENDON.
    PERFORM tab001w_lesen_2.
    PERFORM helpdata1.
    PERFORM lb03_ausgabe.
    PERFORM helpdata2.
  ENDLOOP.
  PERFORM close_form.
ENDFORM.                    "lesen_wlbs
*eject.
*----------------------------------------------------------------------*
*------------------ Ausgaberoutinen -----------------------------------*
*----------------------------------------------------------------------*
*------------- WE Schein Für Fert.Auftr Vers. 1 -----------------------*
FORM ausgabe_wf01.
  PERFORM open_form.
  IF NOT t159p-xmehr IS INITIAL.
    IF mseg-weanz GT 0.
      anzahl = mseg-weanz.
    ELSE.
      anzahl = 1.
    ENDIF.
  ELSE.
    anzahl = 1.
  ENDIF.
  DO anzahl TIMES.
    PERFORM wf01_druck.
  ENDDO.
  PERFORM close_form.
ENDFORM.                    "ausgabe_wf01
*eject.
*------------- WE Schein für Fert.Auftrag Vers 2.----------------------*
FORM ausgabe_wf02.
  PERFORM open_form.
  IF NOT t159p-xmehr IS INITIAL.
    IF mseg-weanz GT 0.
      anzahl = mseg-weanz.
    ELSE.
      anzahl = 1.
    ENDIF.
  ELSE.
    anzahl = 1.
  ENDIF.
  DO anzahl TIMES.
    PERFORM wf02_druck.
  ENDDO.
  PERFORM close_form.
ENDFORM.                    "ausgabe_wf02
*end /SMBA0/AA_M07DRAUS

*---------------------------------------------------------------------------*
*include /SMBA0/AA_M07DRSON
*---------------------------------------------------------------------------*
*----------------------------------------------------------------------*
*---------------- diverse Subroutines --------------------------------*
*----------------------------------------------------------------------*
FORM lesen USING objky.
  nast_key = objky.
  CLEAR retco.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mkpf WHERE mblnr = nast_key-mblnr
*                            AND   mjahr = nast_key-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mkpf WHERE mblnr = nast_key-mblnr
                            AND   mjahr = nast_key-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mseg WHERE mblnr = mkpf-mblnr
*                            AND   zeile = nast_key-zeile
*                            AND   mjahr = mkpf-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mseg WHERE mblnr = mkpf-mblnr
                            AND   zeile = nast_key-zeile
                            AND   mjahr = mkpf-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc NE 0.
    retco = sy-subrc.
    EXIT.
  ENDIF.
  PERFORM tab156_lesen.
  xskkz = t156-rstyp.
  PERFORM tab001w_lesen.
  IF NOT mseg-evers IS INITIAL.        "Versandvorschriften lesen.
    PERFORM t027_lesen.
  ENDIF.
  PERFORM bestellung_lesen.
  IF NOT ekpo-knttp IS INITIAL AND NOT
         ekpo-weunb IS INITIAL.
    PERFORM kontierung_lesen.          "für multikontierte Bestellungen
  ENDIF.
  IF NOT mseg-ematn IS INITIAL.
    PERFORM lesen_htn.
  ELSE.                                                     "111277/PH
    CLEAR am07m-mfrpn.                                      "111277/PH
  ENDIF.
  IF mseg-matnr IS INITIAL.
    mseg-menge = mseg-bpmng.
    mseg-meins = mseg-bprme.
    PERFORM bestelltext_lesen.
    CLEAR mabdr.
  ELSE.
    PERFORM material_lesen.
  ENDIF.
  PERFORM tab024_lesen.
  PERFORM t064b_lesen.
  PERFORM ladr_lesen.
ENDFORM.                    "lesen
*--------------- Lesen für WE-Schein Fert.Auftrag ---------------------*
FORM lesen_wf USING objky.
  nast_key = objky.
  CLEAR retco.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mkpf WHERE mblnr = nast_key-mblnr
*                            AND   mjahr = nast_key-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mkpf WHERE mblnr = nast_key-mblnr
                            AND   mjahr = nast_key-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mseg WHERE mblnr = mkpf-mblnr
*                            AND   zeile = nast_key-zeile
*                            AND   mjahr = mkpf-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mseg WHERE mblnr = mkpf-mblnr
                            AND   zeile = nast_key-zeile
                            AND   mjahr = mkpf-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc NE 0.
    retco = sy-subrc.
    EXIT.
  ENDIF.
  PERFORM tab156_lesen.
  xskkz = t156-rstyp.
  PERFORM tab001w_lesen.
  PERFORM auftrag_lesen.
  IF NOT mseg-matnr IS INITIAL.
    PERFORM material_lesen.
  ELSE.
    mseg-menge = mseg-erfmg.
    mseg-meins = mseg-erfme.
  ENDIF.
  PERFORM tab024d_lesen.
  PERFORM t064b_lesen.
  PERFORM ladr_lesen.
ENDFORM.                    "lesen_wf
*-------------- Lesen für Warenausgang --------------------------------*
FORM lesen_wa USING objky.
  nast_key = objky.
  CLEAR retco.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mkpf WHERE mblnr = nast_key-mblnr
*                            AND   mjahr = nast_key-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mkpf WHERE mblnr = nast_key-mblnr
                            AND   mjahr = nast_key-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mseg WHERE mblnr = mkpf-mblnr
*                            AND   zeile = nast_key-zeile
*                            AND   mjahr = mkpf-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mseg WHERE mblnr = mkpf-mblnr
                            AND   zeile = nast_key-zeile
                            AND   mjahr = mkpf-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc NE 0.
    retco = sy-subrc.
    EXIT.
  ENDIF.
  PERFORM tab156_lesen.
  xskkz = t156-rstyp.
  PERFORM tab001w_lesen.
  IF NOT mseg-matnr IS INITIAL.
    PERFORM material_lesen.
  ENDIF.
  PERFORM ladr_lesen.
ENDFORM.                    "lesen_wa
*-------------- Druck Vorbereiten -------------------------------------*
FORM open_form.
  PERFORM itcpo_fuellen.
*  CALL FUNCTION 'OPEN_FORM'
*  EXPORTING device = 'PRINTER'
*          language = language
*           options =  itcpo
*            dialog = ' '.
  PERFORM lesen_t159p.
  x_open = x.
ENDFORM.                    "open_form
*-------------- Druck Vorbereiten Sammelscheine -----------------------*
FORM open_form_sammel.
  PERFORM lesen_t159p.
  PERFORM itcpo_fuellen.
*  CALL FUNCTION 'OPEN_FORM'
*  EXPORTING device = 'PRINTER'
*          language = language
*           options = itcpo
*              form = tnapr-fonam
*            dialog = ' '.
*  x_open = x.
ENDFORM.                    "open_form_sammel
*-------------- Druck schließen ---------------------------------------*
FORM close_form.
  CHECK NOT x_open IS INITIAL.
*  CALL FUNCTION 'CLOSE_FORM'.
  CLEAR x_open.
ENDFORM.                    "close_form
*------------- Hilfsfelder versorgen für Sammelscheindruck ------------*
FORM helpdata1.
   *mkpf = mkpf.
   *mseg-lgort = mseg-lgort.
   *ladr = ladr.
  save_mkpf = *mkpf-usnam.
  save_mblnr = *mkpf-mblnr.
  save_budat = *mkpf-budat.
  save_cpudt = *mkpf-cpudt.
  save_ematn = *mseg-ematn.
  save_lgort = *mseg-lgort.
  save_ladr = *ladr.
   *t001w = t001w.
  save_werks = *t001w-werks.
  save_name1 = *t001w-name1.
   *ekko = ekko.
   *am07m = am07m.
  save_lifnr = *ekko-lifnr.
  save_ebeln = *ekko-ebeln.
  save_ekgrp = *ekko-ekgrp.
  save_linam = *am07m-name1.
  save_lina2 = *am07m-name2.
   *t024 = t024.
  save_eknam = *t024-eknam.
  save_ektel = *t024-ektel.
   *mkpf-usnam = old_mkpf.
   *mkpf-mblnr = old_mblnr.
   *mkpf-cpudt = old_cpudt.
   *mkpf-budat = old_budat.
   *mseg-ematn = old_ematn.
   *mseg-lgort = old_lgort.
   *ladr = old_ladr.
   *t001w-werks = old_werks.
   *t001w-name1 = old_name1.
   *t024-eknam = old_eknam.
   *t024-ektel = old_ektel.
   *ekko-lifnr = old_lifnr.
   *ekko-ebeln = old_ebeln.
   *ekko-ekgrp = old_ekgrp.
   *am07m-name1 = old_linam.
   *am07m-name2 = old_lina2.
  save_lfa1  = lfa1.
  IF NOT old_lfa1 IS INITIAL.
    lfa1  = old_lfa1.
  ENDIF.
ENDFORM.                                                    "helpdata1
*--- Versorgung der Hilfsfelder vor CLOSE_FORM bei Sammelscheindruck --*
FORM helpdata2.
  old_lfa1 = save_lfa1.
  lfa1     = save_lfa1.
  old_mkpf = save_mkpf.
  old_lgort = save_lgort.
  old_ladr = save_ladr.
  old_budat = save_budat.
  old_cpudt = save_cpudt.
  old_werks = save_werks.
  old_name1 = save_name1.
  old_mblnr = save_mblnr.
  old_lifnr = save_lifnr.
  old_linam = save_linam.
  old_lina2 = save_lina2.
  old_ebeln = save_ebeln.
  old_ekgrp = save_ekgrp.
  old_eknam = save_eknam.
  old_ektel = save_ektel.
  old_ematn = save_ematn.
   *mkpf-usnam = save_mkpf.
   *mkpf-mblnr = save_mblnr.
   *mkpf-budat = save_budat.
   *mkpf-cpudt = save_cpudt.
   *mseg-ematn = save_ematn.
   *mseg-lgort = save_lgort.
   *ladr = save_ladr.
   *t001w-werks = save_werks.
   *t001w-name1 = save_name1.
   *t024-eknam  = save_eknam.
   *t024-ektel  = save_ektel.
   *ekko-lifnr  = save_lifnr.
   *ekko-ebeln  = save_ebeln.
   *ekko-ekgrp  = save_ekgrp.
   *am07m-name1 = save_linam.
   *am07m-name2 = save_lina2.
ENDFORM.                                                    "helpdata2
*----------- Form Lesen Warenausgang Lohnbearbeiter -------------------*
FORM lesen_wlb USING objky.
  nast_key = objky.
  CLEAR retco.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mkpf WHERE mblnr = nast_key-mblnr
*                            AND   mjahr = nast_key-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mkpf WHERE mblnr = nast_key-mblnr
                            AND   mjahr = nast_key-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM mseg WHERE mblnr = mkpf-mblnr
*                            AND   zeile = nast_key-zeile
*                            AND   mjahr = mkpf-mjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM mseg WHERE mblnr = mkpf-mblnr
                            AND   zeile = nast_key-zeile
                            AND   mjahr = mkpf-mjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc NE 0.
    retco = sy-subrc.
    EXIT.
  ENDIF.
  PERFORM tab156_lesen.
  xskkz = t156-rstyp.
  PERFORM tab001w_lesen.
  IF NOT mseg-matnr IS INITIAL.
    PERFORM material_lesen.
  ENDIF.
  ON CHANGE OF mseg-lifnr.
    PERFORM read_address.
  ENDON.
ENDFORM.                    "lesen_wlb
*eject
*---------------------- Fuellen der ITCPO -----------------------------*
FORM itcpo_fuellen.
  IF xscreen NE space.
*- Testausgabe auf Bildschirm ----------------------------------------
    itcpo-tdpreview = 'X'.
    itcpo-tdnoprint = 'X'.
  ELSE.
    CLEAR: itcpo-tdpreview,
           itcpo-tdnoprint.
  ENDIF.
  MOVE-CORRESPONDING nast TO itcpo.
  itcpo-tdcover   = nast-tdocover.
  itcpo-tddest    = nast-ldest.
  itcpo-tddataset = nast-dsnam.
  itcpo-tdsuffix1 = nast-dsuf1.
  itcpo-tdsuffix2 = nast-dsuf2.
  itcpo-tdimmed   = nast-dimme.
  itcpo-tddelete  = nast-delet.
  itcpo-tdcopies  = nast-anzal.
  itcpo-tdprogram = sy-repid.
* ITCPO-TDTELELAND = US_COUNTRY.
  itcpo-tdsenddate = nast-vsdat.
  itcpo-tdsendtime = nast-vsura.
  itcpo-tdnewid   = x.
ENDFORM.                    "itcpo_fuellen
*eject.

* ------------ FORM lesen der Lagerortadr. ---------------------------*
FORM ladr_lesen.
  DATA:    BEGIN OF addr_sel.
          INCLUDE STRUCTURE addr1_sel.
  DATA:    END OF addr_sel.
  CLEAR ladr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM twlad WHERE werks = mseg-werks
*                       AND  lgort = mseg-lgort
*                       AND  lfdnr = '001'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM twlad WHERE werks = mseg-werks
                       AND  lgort = mseg-lgort
                       AND  lfdnr = '001' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF NOT twlad-adrnr IS INITIAL AND sy-subrc IS INITIAL.
    MOVE twlad-adrnr TO addr_sel-addrnumber.
  ENDIF.
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = addr_sel
    IMPORTING
      sadr              = ladr
    EXCEPTIONS
      OTHERS            = 1.
ENDFORM.                    "ladr_lesen
*&---------------------------------------------------------------------*
*&      Form  set_print_param
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_ADDR_KEY  text
*      <--P_LS_CONTROL_PARAM  text
*      <--P_LS_COMPOSER_PARAM  text
*      <--P_LS_RECIPIENT  text
*      <--P_LS_SENDER  text
*      <--P_ENT_RETCO  text
*----------------------------------------------------------------------*
FORM set_print_param USING    is_addr_key LIKE addr_key
                     CHANGING cs_control_param TYPE ssfctrlop
                              cs_composer_param TYPE ssfcompop
                              cs_recipient TYPE  swotobjid
                              cs_sender TYPE  swotobjid
                              cf_retcode TYPE sy-subrc.
  DATA: ls_itcpo     TYPE itcpo.
  DATA: lf_repid     TYPE sy-repid.
  DATA: lf_device    TYPE tddevice.
  DATA: ls_recipient TYPE swotobjid.
  DATA: ls_sender    TYPE swotobjid.

  lf_repid = sy-repid.

  CALL FUNCTION 'WFMC_PREPARE_SMART_FORM'
    EXPORTING
      pi_nast       = nast
      pi_addr_key   = is_addr_key
      pi_repid      = lf_repid
    IMPORTING
      pe_returncode = cf_retcode
      pe_itcpo      = ls_itcpo
      pe_device     = lf_device
      pe_recipient  = cs_recipient
      pe_sender     = cs_sender.

  IF cf_retcode = 0.
    MOVE-CORRESPONDING ls_itcpo TO cs_composer_param.
*   CS_CONTROL_PARAM-NO_OPEN
*   CS_CONTROL_PARAM-NO_CLOSE
    cs_control_param-device      = lf_device.
    cs_control_param-no_dialog   = 'X'.
    cs_control_param-preview     = xscreen.
    cs_control_param-getotf      = ls_itcpo-tdgetotf.
    cs_control_param-langu       = nast-spras.
*   CS_CONTROL_PARAM-REPLANGU1
*   CS_CONTROL_PARAM-REPLANGU2
*   CS_CONTROL_PARAM-REPLANGU3
*   CS_CONTROL_PARAM-STARTPAGE
  ENDIF.

ENDFORM.                               " set_print_param
*&---------------------------------------------------------------------*
*&      Form  get_addr_key
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_ADDR_KEY  text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  protocol_update_i
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM protocol_update_i.
  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.
ENDFORM.                               " protocol_update_i
*&---------------------------------------------------------------------*
*&      Form  add_smfrm_prot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_smfrm_prot.
  DATA: lt_errortab             TYPE tsferror.
  DATA: lf_msgnr                TYPE sy-msgno.
  DATA:  l_s_log                TYPE bal_s_log,
         p_loghandle            TYPE balloghndl,
         l_s_msg                TYPE bal_s_msg.

  FIELD-SYMBOLS: <fs_errortab>  TYPE LINE OF tsferror.

* get smart form protocoll
  CALL FUNCTION 'SSF_READ_ERRORS'
    IMPORTING
      errortab = lt_errortab.

* add smartform protocoll to nast protocoll
  LOOP AT lt_errortab ASSIGNING <fs_errortab>.
    CLEAR lf_msgnr.
    lf_msgnr = <fs_errortab>-errnumber.
    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
      EXPORTING
        msg_arbgb = <fs_errortab>-msgid
        msg_nr    = lf_msgnr
        msg_ty    = <fs_errortab>-msgty
        msg_v1    = <fs_errortab>-msgv1
        msg_v2    = <fs_errortab>-msgv2
        msg_v3    = <fs_errortab>-msgv3
        msg_v4    = <fs_errortab>-msgv4
      EXCEPTIONS
        OTHERS    = 1.
  ENDLOOP.
* open the application log
*  l_s_log-extnumber    = sy-uname.
*
*  CALL FUNCTION 'BAL_LOG_CREATE'
*    EXPORTING
*      i_s_log      = l_s_log
*    IMPORTING
*      e_log_handle = p_loghandle
*    EXCEPTIONS
*      OTHERS       = 1.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*  LOOP AT lt_errortab ASSIGNING <fs_errortab>.
*    MOVE-CORRESPONDING <fs_errortab> TO l_s_msg.
*    CALL FUNCTION 'BAL_LOG_MSG_ADD'
*      EXPORTING
*        i_log_handle = p_loghandle
*        i_s_msg      = l_s_msg
*      EXCEPTIONS
*        OTHERS       = 1.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*  ENDLOOP.
*
*  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

ENDFORM.                               " add_smfrm_prot
*&---------------------------------------------------------------------*
*&      Form  print_smartform
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_smartform.
  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_control_param      TYPE ssfctrlop.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: ls_recipient          TYPE swotobjid.
  DATA: ls_sender             TYPE swotobjid.
  DATA: lf_formname           TYPE tdsfname.
  DATA: ls_addr_key           LIKE addr_key.
  DATA: it_ekpo LIKE ekpo OCCURS 0.
  data: ls_job_info           type ssfcrescl.
  data: l_spoolid             type rspoid.

  REFRESH traptab.
  CLEAR retco.
  CLEAR: xkopfdr, new_page.
*  nast_key = objky.
  PERFORM lesen_t159p.
  PERFORM itcpo_fuellen.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM ekpo INTO TABLE it_ekpo WHERE
*                          ebeln = ekko-ebeln.
*
* NEW CODE
  SELECT *
 FROM ekpo INTO TABLE it_ekpo WHERE
                          ebeln = ekko-ebeln ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  IF NOT t159p-xmehr IS INITIAL.
    IF mseg-weanz GT 0.
      anzahl = mseg-weanz.
    ELSE.
      anzahl = 1.
    ENDIF.
  ELSE.
    anzahl = 1.
  ENDIF.

  PERFORM set_print_param USING      ls_addr_key
                          CHANGING ls_control_param
                                   ls_composer_param
                                   ls_recipient
                                   ls_sender
                                   retco.
*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(ssfcomposer).
  ENDIF.

* determine smartform function module for invoice
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
       EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
       IMPORTING  fm_name            = lf_fm_name
       EXCEPTIONS no_form            = 1
                  no_function_module = 2
                  OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    retco = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(ssfcomposer).
    ENDIF.
    PERFORM protocol_update_i.
  ENDIF.


  DO anzahl TIMES.
    CALL FUNCTION lf_fm_name
      EXPORTING
         archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
         archive_parameters         = arc_params
         control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
         mail_recipient             = ls_recipient
         mail_sender                = ls_sender
         output_options             = ls_composer_param
         user_settings              = ' '
         is_mseg                       = mseg
         is_ekpo                       = ekpo
         is_t157e                      = t157e
         is_am07m                      = am07m
         is_mkpf                       = mkpf
         is_nast                       = nast
         is_t159p                      =  t159p
         is_t001w                      = t001w
         is_ekko                       = ekko
         is_t024                       = t024
         TABLES
         it_ekpo                    = it_ekpo
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
 EXCEPTIONS
   formatting_error           = 1
   internal_error             = 2
   send_error                 = 3
   user_canceled              = 4
   OTHERS                     = 5
              .
    IF sy-subrc <> 0.
      retco = sy-subrc.
      PERFORM protocol_update_i.
* get SmartForm protocoll and store it in the NAST protocoll
      PERFORM add_smfrm_prot.
    else.
      read table ls_job_info-spoolids into l_spoolid index 1.
      if sy-subrc is initial.
        export spoolid = l_spoolid to memory id 'KYK_SPOOLID'.
      endif.

    ENDIF.
  ENDDO.

ENDFORM.                               " print_smartform

*end /SMBA0/AA_M07DRSON
