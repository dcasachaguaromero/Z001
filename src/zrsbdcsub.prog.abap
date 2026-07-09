*****************************************************************
*@(#)RSBDCSUB   %I%   SAP %E%
*****************************************************************
*
*     SAP AG Walldorf
*     Systeme, Anwendungen und Produkte in der Datenverarbeitung
*
*     (C) Copyright SAP AG 1997
*
*****************************************************************
*
*  Projekt:          R/3 BatchInput
*  Entwickl.-Stand:  SAP   , BIN-Datenbank
*
*  Source-Typ:       Report
*
*  Autor:            SAP AG, Basis
*
*****************************************************************
REPORT RSBDCSUB MESSAGE-ID 00 LINE-SIZE 100
                 NO STANDARD PAGE HEADING.
*---------------------------------------------------------------------*
* Dieser Report dient zum Abspielen von Batch-Input-Mappen            *
* im Hintergrund (Batch).                                             *
* Automatisch abgespielt werden alle Mappen die den Status            *
* - Neu/Noch zu verarbeiten       oder                                *
* - Fehlerhaft                                                        *
* haben.                                                              *
*                                                                     *
* 1. Die Tabelle APQI ist der Info-Teil.                              *
*                                                                     *
* 2. Die Tabelle APQD ist der Daten-Teil,                             *
*    beschreibt einen Eintrag innerhalb der Datensegmente der Queue.  *
*---------------------------------------------------------------------*
*-- Datendefinitionen zum Report                                   ---*
*---------------------------------------------------------------------*
TABLES: APQI, D0100.                   "Queue Info
*
INCLUDE ZBDCRECXY.
DATA: MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
DATA:
  BCOUNT    TYPE I VALUE 0,            " Mappen mit Status ' ' int.Tab.
  ECOUNT    TYPE I VALUE 0,            " Mappen mit Status 'E' int Tab.
  MCOUNT    TYPE I VALUE 0,            " Platzhalter fuer die Liste
  CCOUNT    TYPE I VALUE 0.            " Zaehler fuer Wildcard
DATA:
  TCOUNT    TYPE I VALUE 0,            " $ Mappen gelesen in MTAB
  DCOUNT    TYPE I VALUE 0,            " $ Mappen abgespielt
  NCOUNT    TYPE I VALUE 0,            " $ Mappen nicht in DB
  ACOUNT    TYPE I VALUE 0,            " $ Mappen: User ohne Berecht.
  SCOUNT    TYPE I VALUE 0,            " $ Mappen ohne Staus ' ', 'E'
  GCOUNT    TYPE I VALUE 0,            " $ Mappen mit BI-Sperrdatum
  FCOUNT    TYPE I VALUE 0,            " $ Mappen mit ABAP-Sperre
  KCOUNT    TYPE I VALUE 0,            " $ ABAP-Sperre nicht ord.
  JO_COUNT    TYPE I VALUE 0,          " $ Jobs nicht geöffnet
  JC_COUNT    TYPE I VALUE 0,          " $ Jobs nicht geschlossen
  JR_COUNT    TYPE I VALUE 0,          " $ Jobs nicht freigegeben
  JS_COUNT    TYPE I VALUE 0.          " $ Submit RSBDCBTC nicht ord.
*
DATA:
 SUBREPORT(12) TYPE C VALUE 'RSBDCBTC_SUB'. " Submit Batch
*
DATA:
  JOBRELE LIKE BTCH0000-CHAR1,
  RETURN(3) TYPE N,
  OLD_QSTATE  LIKE APQI-QSTATE,        "Mappenstatus (gerettet)
  LMODUS(1),                           "Abspielmodus
  X(1) VALUE 'X',                                           "X
  E(1) VALUE 'E',                                           "E
  ART(3),                                                   "
  STAR(1) VALUE '*',                   "Asteric
  BI LIKE TBTCJOB-JOBGROUP VALUE 'BATCH-INPUT',
  B_D_C(4) VALUE 'BDC ',               "Datatyp = Batch-Input
  WILDCARD(1) VALUE '%',               "Percent
  ZW_MAPN(12),                         "Mappenname zwischenwert
  JNUMB   LIKE RSJOBINFO-JOBNUMB,
  JNAME   LIKE TBTCO-JOBNAME.

DATA: BEGIN OF BIM,                    "Aktivitaeten Uebersicht
  AONL(4) VALUE 'AONL',                "Mappen-Abspielen im Online
  ABTC(4) VALUE 'ABTC',                "Mappen-Abspielen im Batch
  FREE(4) VALUE 'FREE',                "Freigeben   von   Mappen
  LOCK(4) VALUE 'LOCK',        "Sperren und Entsperren von Mappen
  DELE(4) VALUE 'DELE',                "Loeschen    von   Mappen
  ANAL(4) VALUE 'ANAL',                "Analysieren von   Mappen
      END OF BIM.
*
DATA: BEGIN OF JOB  OCCURS 0,                             "#EC NEEDED )
  NUMB   LIKE RSJOBINFO-JOBNUMB,       "jobnummer
  NAME   LIKE APQI-GROUPID,            "jobname
  QID    LIKE APQI-QID    ,            "jobqid
  RC     LIKE SY-SUBRC    ,            "return-code
  DATE   LIKE SY-DATUM,                "creationdate mappe
  TIME   LIKE SY-UZEIT,                "creationtime mappe
  SDATE  LIKE SY-DATUM,                "jobdatum submit
  STIME  LIKE SY-UZEIT,                "jobzeit  submit
  USER   LIKE SY-UNAME,                "jobuser
  BUSER  LIKE SY-UNAME,                "Batchberechtigter
  GROUP  LIKE APQI-GROUPID,            "jobgruppe
      END OF JOB.

****** interne Tabelle ---
*
DATA: BEGIN OF BTAB OCCURS 0.
        INCLUDE STRUCTURE APQI.
DATA: END OF BTAB.
*
DATA: BEGIN OF ETAB OCCURS 0.
        INCLUDE STRUCTURE APQI.
DATA: END OF ETAB.
*
DATA: BEGIN OF MTAB OCCURS 0.
        INCLUDE STRUCTURE APQI.
DATA: END OF MTAB.
*
DATA: BEGIN OF ENQ  ,                  "for ABAP-enqueue/dequeue
         DATATYP LIKE APQI-DATATYP,
         GROUPID LIKE APQI-GROUPID ,
         OBJECT  LIKE APQI-QID,
         RC      LIKE SY-SUBRC,
         USER    LIKE SY-UNAME,
*         MAPPE   LIKE APQI-GROUPID,
      END OF ENQ.
*
DATA:
     DATE1 TYPE D.                     "funktioniert 18.11.91 Harms
*
DATA: JOB_DELETE(1) TYPE C VALUE ' '.
*
****************** Parameters  Input from Values **********************
*                                                                      *
SELECTION-SCREEN SKIP.
SELECTION-SCREEN  BEGIN OF BLOCK SESSION_PROCESS
                   WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) FOR FIELD MAPPE.    "Mappenname
PARAMETERS MAPPE LIKE D0100-MAPN DEFAULT STAR.
SELECTION-SCREEN COMMENT (35) TEXT-002."(generisch...
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT /1(20) TEXT-049.          "Erstellungsdatum
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 3(18) FOR FIELD VON.      "von
PARAMETERS VON   LIKE D0100-VON.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 3(18) FOR FIELD BIS.      "bis
PARAMETERS BIS   LIKE D0100-BIS.
SELECTION-SCREEN END OF LINE.
*
SELECTION-SCREEN SKIP.
*SELECTION-SCREEN BEGIN OF BLOCK STATUS_MARK.         "Status mark
SELECTION-SCREEN COMMENT /1(20) TEXT-050.          "Mappenstatus
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 3(22) FOR FIELD Z_VERARB.      "Status neu
PARAMETERS Z_VERARB LIKE D0100-BOOKED AS CHECKBOX  DEFAULT  'X'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 3(22) FOR FIELD FEHLER.  "Status fehlerhaft
PARAMETERS FEHLER LIKE D0100-ERR AS CHECKBOX  DEFAULT  'X'.
SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN END OF BLOCK STATUS_MARK.
*
SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT /1(20) TEXT-052.           "Hintergrundsystem
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 3(18) FOR FIELD BATCHSYS.  "Zielrechner
PARAMETERS BATCHSYS(20) LOWER CASE DEFAULT SPACE.
*
*PARAMETERS BATCHSYS LIKE D0300-BATCHSYS visible length 20
*                                        LOWER CASE DEFAULT SPACE.
*PARAMETERS BATCHSYS LIKE D0300-BATCHSYS(20)
*                                        LOWER CASE DEFAULT SPACE.
*PARAMETERS BATCHSYS type D0300_btcs LOWER CASE DEFAULT SPACE.
*
SELECTION-SCREEN END OF LINE.
*
SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT /1(20) TEXT-057.           "Protokoll
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 3(22) FOR FIELD LOGALL.    "Erw. Protokol
PARAMETERS LOGALL LIKE D0300-LOGALL AS CHECKBOX DEFAULT SPACE.
SELECTION-SCREEN END OF LINE.
*
SELECTION-SCREEN END OF BLOCK SESSION_PROCESS.
*
PARAMETERS: QUEUE_ID LIKE APQI-QID DEFAULT SPACE NO-DISPLAY.
*
AT SELECTION-SCREEN.                   " ON BLOCK STATUS_MARK.
  IF Z_VERARB EQ ' ' AND FEHLER EQ ' '.
    SET CURSOR FIELD 'Z_VERARB'.
    MESSAGE E368 WITH TEXT-018 TEXT-019.
  ENDIF.
*
AT SELECTION-SCREEN ON HELP-REQUEST FOR BATCHSYS.
  CALL FUNCTION 'HELP_OBJECT_SHOW_FOR_FIELD'
      EXPORTING
           DOKLANGU                      = SY-LANGU
*         DOKTITLE                      = ' '
*         CALLED_BY_TCODE               =
*         CALLED_BY_PROGRAM             =
*         CALLED_BY_DYNP                =
           CALLED_FOR_TAB                = 'D0300'
           CALLED_FOR_FIELD              = 'BATCHSYS'
*         CALLED_FOR_TAB_FLD_BTCH_INPUT =
*         CALLED_BY_CUAPROG             =
*         CALLED_BY_CUASTAT             =
*         MERGE_DZ_IF_AVAILABLE         =
*         MEMORYID                      =
*         EXPLICIT_MEMORYID             = ' '
*    TABLES
*         LINKS                         =
*         EXCLUDEFUN                    =
*    EXCEPTIONS
*         OBJECT_NOT_FOUND              = 1
*         SAPSCRIPT_ERROR               = 2
*         OTHERS                        = 3
            .
*IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.

*
***********  start of selection ***************************************
START-OF-SELECTION.

*
  SET PF-STATUS '0100'.
*
  SET TITLEBAR  '001'.
*
  PERFORM D0100_FCODE.
  PERFORM JOB_STATISTIK.

*
*---------------------------------------------------------------------*
*----  FORM ROUTINEN     ZU REPORT     RSBDCSUB   --------------------*
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM   D0100_FCODE                                            *
*---------------------------------------------------------------------*

FORM D0100_FCODE.
*
  MOVE: MAPPE     TO D0100-MAPN,
        VON       TO D0100-VON,
        BIS       TO D0100-BIS,
        Z_VERARB  TO D0100-BOOKED,    "new-status
        FEHLER    TO D0100-ERR.       "error-status

  CLEAR: RETURN.
*
  IF QUEUE_ID = SPACE.
    PERFORM CHECK_MAPN.                  " pruefe  mappenname
    PERFORM CHECK_SELECTION.

    IF RETURN GT 0.
      PERFORM SEND_MSG.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.
*
  PERFORM FILL_TABLES.
*
*  IF RETURN = 305.   "Markieren Status 'neu' und/oder 'fehlerhaft'
*    PERFORM SEND_MSG.
*    LEAVE SCREEN.
*  ENDIF.
*
  IF RETURN = 306.   "Keine Mappe mit Status 'neu' oder 'fehlerhaft' gef
    PERFORM SEND_MSG.
    LEAVE SCREEN.
  ENDIF.
*
  IF RETURN EQ 0.
    PERFORM SUBMIT_MAPPEN.
  ENDIF.
*
  PERFORM SEND_MSG.
*
  SORT JOB BY QID.
  LOOP AT MTAB.
    READ TABLE JOB WITH KEY QID = MTAB-QID BINARY SEARCH.
    PERFORM WRITE_LISTE.
  ENDLOOP.
*
  IF MCOUNT GT 0.
    WRITE:/01(100) SY-ULINE.
  ENDIF.
*
  SET CURSOR 2 1.
*
ENDFORM.                               " D0100_FCODE
*
*---------------------------------------------------------------------*
* FORM : check_mapn                                                   *
*---------------------------------------------------------------------*
FORM CHECK_MAPN.
*
*** Ausgabe der internen Tabelle tab
*
  MOVE 'GEN'      TO ART.              " generisch suchen default
*
  IF D0100-MAPN = SPACE .
    MOVE STAR TO D0100-MAPN.
  ENDIF.
*
  MOVE D0100-MAPN TO ZW_MAPN.
*
  IF ZW_MAPN(1) = STAR.
    WRITE WILDCARD TO D0100-MAPN+CCOUNT(1).
    MOVE 'GEN' TO ART.
  ENDIF.
*
  CCOUNT = 0.
*
  DO 12 TIMES.
    SHIFT ZW_MAPN.
    ADD 1 TO CCOUNT.
    IF ZW_MAPN(1) = STAR.
      WRITE WILDCARD TO D0100-MAPN+CCOUNT(1).
      MOVE 'GEN' TO ART.
    ENDIF.
    IF ZW_MAPN(1) = SPACE.
      EXIT.
    ENDIF.
  ENDDO.
*
ENDFORM.                               " check_mapn
*
*---------------------------------------------------------------------*
* FORM : check_selection                                             *
*                                                                     *
*---------------------------------------------------------------------*
FORM CHECK_SELECTION.
*
*** Pruefen der Selctionskriterien
*
  CLEAR: RETURN.
*
  IF D0100-VON  EQ 0 AND
     D0100-BIS  EQ 0.
*        ok.
  ELSE.
    MOVE 'GEB'  TO ART.
    IF D0100-VON GT 0 AND
       D0100-BIS EQ 0.
      D0100-BIS = SY-DATUM.
    ENDIF.
    IF D0100-VON GT D0100-BIS.
      MTAB-STARTDATE = D0100-VON.
      RETURN = 302.                    " Datum ungueltig
      EXIT.
    ENDIF.
    IF D0100-VON EQ 0 AND D0100-BIS GT 0.
      MTAB-STARTDATE = D0100-VON.
      RETURN = 302.
      EXIT.
    ENDIF.
  ENDIF.
*
ENDFORM.                               " check_selection
*/
*---------------------------------------------------------------------*
* FORM : fill_tables                                                  *
*                                                                     *
*---------------------------------------------------------------------*
FORM FILL_TABLES.
*
*** Fuellen der internen Tabellen  tab
*
  CLEAR:   APQI,
           RETURN,
           BCOUNT,
           ECOUNT.
*
********** "Mappen mit Stati ' ' (neu) und/oder 'E' (fehlerhaft) selekt.
*
*  IF D0100-BOOKED EQ X OR
*     D0100-ERR    EQ X .
*    " ok auswerten der selektion, go on
*  ELSE.
*    RETURN = 305.          "ankreuzen Status neu und/oder fehlerhaft
*    EXIT.
*  ENDIF.
*
  IF QUEUE_ID = SPACE.
********** "Selection der Mappen mit Status neu
*
    IF D0100-BOOKED EQ X.
      PERFORM FILL_BTAB.
    ENDIF.
*
********** "Selection der Mappen mit Status fehlerhaft
*
    IF D0100-ERR EQ X.
      PERFORM FILL_ETAB.
    ENDIF.
*
  ENDIF.
*
  PERFORM MERGE_TABLES.
*
*
ENDFORM.                               " FILL_TABles
*/
*---------------------------------------------------------------------*
* FORM : fill_btab                                                    *
*---------------------------------------------------------------------*
FORM FILL_BTAB.
*
*** Fuellen der internen Tabellenfelder  btab
*
  REFRESH: BTAB.                       " interne Tabellen initialisieren
  CLEAR:   BTAB,                       " Kopfzeile initialisieren
           BCOUNT.
*
  IF ART = 'GEN'.                      " ohne  Datumseingrenzung
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM  APQI
*     WHERE GROUPID LIKE D0100-MAPN
*     AND  MANDANT  EQ SY-MANDT
*     AND  DATATYP  EQ B_D_C
*     AND   QSTATE  EQ SPACE.
*
* NEW CODE
    SELECT *
 FROM  APQI
     WHERE GROUPID LIKE D0100-MAPN
     AND  MANDANT  EQ SY-MANDT
     AND  DATATYP  EQ B_D_C
     AND   QSTATE  EQ SPACE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      BCOUNT = BCOUNT + 1.
      MOVE-CORRESPONDING  APQI TO BTAB.
      APPEND BTAB.
    ENDSELECT.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM  APQI
*     WHERE GROUPID LIKE D0100-MAPN     " mit Datumseingrenzung
*     AND   MANDANT  EQ SY-MANDT
*     AND   DATATYP  EQ B_D_C
*     AND   CREDATE BETWEEN D0100-VON AND D0100-BIS
*     AND   QSTATE EQ SPACE.
*
* NEW CODE
    SELECT *
 FROM  APQI
     WHERE GROUPID LIKE D0100-MAPN     " mit Datumseingrenzung
     AND   MANDANT  EQ SY-MANDT
     AND   DATATYP  EQ B_D_C
     AND   CREDATE BETWEEN D0100-VON AND D0100-BIS
     AND   QSTATE EQ SPACE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      BCOUNT = BCOUNT + 1.
      MOVE-CORRESPONDING  APQI TO BTAB.
      APPEND BTAB.
    ENDSELECT.
  ENDIF.
*
  SORT BTAB BY  CREDATE DESCENDING  CRETIME DESCENDING.
*
ENDFORM.                               " fill_btab
*/
*---------------------------------------------------------------------*
* FORM : fill_etab                                                    *
*                                                                     *
*---------------------------------------------------------------------*
FORM FILL_ETAB.
*
*** Fuellen der internen Tabellenfelder  etab
*
  REFRESH: ETAB.                       " interne Tabellen initialisieren
  CLEAR:   ETAB,                       " Kopfzeile initialisieren
           ECOUNT.
*
  IF ART = 'GEN'.                      " ohne  Datumseingrenzung
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM  APQI
*     WHERE GROUPID LIKE D0100-MAPN
*     AND  MANDANT  EQ SY-MANDT
*     AND  DATATYP  EQ B_D_C
*     AND   QSTATE  EQ 'E'.
*
* NEW CODE
    SELECT *
 FROM  APQI
     WHERE GROUPID LIKE D0100-MAPN
     AND  MANDANT  EQ SY-MANDT
     AND  DATATYP  EQ B_D_C
     AND   QSTATE  EQ 'E' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      ECOUNT = ECOUNT + 1.
      MOVE-CORRESPONDING  APQI TO ETAB.
      APPEND ETAB.
    ENDSELECT.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM  APQI
*     WHERE GROUPID LIKE D0100-MAPN     " mit Datumseingrenzung
*     AND   MANDANT  EQ SY-MANDT
*     AND   DATATYP  EQ B_D_C
*     AND   CREDATE BETWEEN D0100-VON AND D0100-BIS
*     AND   QSTATE EQ 'E'.
*
* NEW CODE
    SELECT *
 FROM  APQI
     WHERE GROUPID LIKE D0100-MAPN     " mit Datumseingrenzung
     AND   MANDANT  EQ SY-MANDT
     AND   DATATYP  EQ B_D_C
     AND   CREDATE BETWEEN D0100-VON AND D0100-BIS
     AND   QSTATE EQ 'E' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      ECOUNT = ECOUNT + 1.
      MOVE-CORRESPONDING  APQI TO ETAB.
      APPEND ETAB.
    ENDSELECT.
  ENDIF.
*
  SORT ETAB BY  CREDATE DESCENDING  CRETIME DESCENDING.
*
ENDFORM.                               " fill_etab
*/
*---------------------------------------------------------------------*
* FORM : merge_tables                                                 *
*                                                                     *
*---------------------------------------------------------------------*
FORM  MERGE_TABLES.
*
*** Fuellen der internen Tabelle mtab
*
  CLEAR: MTAB.
  REFRESH: MTAB.
*
  IF QUEUE_ID <> SPACE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM APQI
*     WHERE QID     EQ QUEUE_ID
*     AND  MANDANT  EQ SY-MANDT
*     AND  DATATYP  EQ B_D_C.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM APQI
     WHERE QID     EQ QUEUE_ID
     AND  MANDANT  EQ SY-MANDT
     AND  DATATYP  EQ B_D_C ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF SY-SUBRC = 0.
      IF   ( D0100-BOOKED EQ X AND APQI-QSTATE = ' ' )
        OR ( D0100-ERR    EQ X AND APQI-QSTATE = 'E' ).
        MOVE-CORRESPONDING APQI TO MTAB.
        MCOUNT = 1.
        APPEND MTAB.
      ELSE.
        RETURN = 306.
        EXIT.
      ENDIF.
    ELSE.
      RETURN = 306.
      EXIT.
    ENDIF.
  ELSE.
    IF BCOUNT EQ 0 AND
       ECOUNT EQ 0 .
      RETURN = 306.
      FREE: BTAB,
            ETAB.
      EXIT.
    ENDIF.
    CLEAR: MCOUNT.
  ENDIF.
*
  IF BCOUNT GT 0.
    MOVE TEXT-036 TO MTAB-FORMID.

    LOOP AT BTAB.
      CLEAR: MTAB.
      MOVE-CORRESPONDING  BTAB TO MTAB.
      MCOUNT = MCOUNT + 1.
*
      APPEND MTAB.
    ENDLOOP.
  ENDIF.
*
  IF ECOUNT GT 0.
    MOVE TEXT-035 TO MTAB-FORMID.

    LOOP AT ETAB.
      CLEAR: MTAB.
      MOVE-CORRESPONDING  ETAB TO MTAB.
      MCOUNT = MCOUNT + 1.
*
      APPEND MTAB.
    ENDLOOP.
  ENDIF.
*
  FREE: BTAB,
        ETAB.
*
ENDFORM.                               " merge_tables
*/
*---------------------------------------------------------------------*
* FORM : write_liste                                                  *
*                                                                     *
*---------------------------------------------------------------------*
FORM WRITE_LISTE.
*
*** Mainlist
*
  FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
*
  IF JOB-RC GT 0.
    FORMAT COLOR COL_KEY.
  ELSE.
    FORMAT COLOR COL_NORMAL.
  ENDIF.
******
  WRITE:/100(01) '.'.                  "leerzeile fuer text
*
  WRITE: 02(08) JOB-STIME USING EDIT MASK '__:__:__'.
*
  WRITE: 12(13) MTAB-GROUPID           "mappenname
                          COLOR COL_KEY    INTENSIFIED ON.
  DATE1 = MTAB-CREDATE.
  WRITE: 26(10) DATE1 DD/MM/YYYY,      "erstellungsdatum
         37(08) MTAB-CRETIME USING EDIT MASK '__:__:__'.  "erst.-zeit
*
  WRITE: 46(08) JOB-NUMB.         "Job-Nummer
  WRITE: 63(20) MTAB-QID.
*
  PERFORM WRITE_VLINE USING  1.
  PERFORM WRITE_VLINE USING 11.
  PERFORM WRITE_VLINE USING 25.
  PERFORM WRITE_VLINE USING 36.
  PERFORM WRITE_VLINE USING 45.
  PERFORM WRITE_VLINE USING 62.
  PERFORM WRITE_VLINE USING 100.
******
  WRITE:/100(01) '.'.                  "leerzeile fuer text
*
  PERFORM WRITE_VLINE USING  1.
  PERFORM WRITE_VLINE USING 11.
  PERFORM WRITE_VLINE USING 25.
  PERFORM WRITE_VLINE USING 36.
  PERFORM WRITE_VLINE USING 45.
  PERFORM WRITE_VLINE USING 62.
  PERFORM WRITE_VLINE USING 100.
*
  PERFORM WRITE_JOB_NUMB_MSG.
*
  FORMAT RESET.
*
ENDFORM.                               " WRITE_LISTE
*
*---------------------------------------------------------------------*
* FORM : submit_mappen.                                               *
*                                                                     *
*---------------------------------------------------------------------*
FORM SUBMIT_MAPPEN.
*
*** Submit von Mappen in den Hintergrund (mit Batch).
*
  CLEAR: RETURN.
*
  REFRESH:JOB.
  CLEAR: JOB, TCOUNT, DCOUNT, NCOUNT, ACOUNT, GCOUNT, SCOUNT, FCOUNT,
         KCOUNT, JO_COUNT, JC_COUNT, JR_COUNT, JS_COUNT.
*
  LMODUS = SPACE.
  IF LOGALL NE SPACE.
    LMODUS =  'A'.                       "erweitertes Protokoll
  ENDIF.
*
  LOOP AT MTAB WHERE ( QSTATE  EQ ' ' OR
                       QSTATE  EQ 'E' ).
    TCOUNT = TCOUNT + 1.
*
    CLEAR: JOB-RC,JOB-BUSER.
    CLEAR: RETURN, JOB_DELETE.
    CLEAR: JNUMB.
*
    CLEAR APQI.
    SELECT SINGLE FOR UPDATE * FROM APQI
                WHERE DESTSYS  =  MTAB-DESTSYS
                AND   DESTAPP  =  MTAB-DESTAPP
                AND   DATATYP  =  MTAB-DATATYP
                AND   GROUPID  =  MTAB-GROUPID
                AND   PROGID   =  MTAB-PROGID
                AND   FORMID   =  MTAB-FORMID
                AND   MANDANT  =  MTAB-MANDANT
                AND   QATTRIB  =  MTAB-QATTRIB
                AND   QID      =  MTAB-QID.
*
    IF SY-SUBRC EQ 0.                  "Mappe noch in DB
      IF APQI-QSTATE(1) NE  ' ' AND    "nur mappen mit status ' '
         APQI-QSTATE(1) NE  'E' .      "oder 'E' werden abgespielt
        JOB-RC = 3.
        SCOUNT = SCOUNT + 1.
        PERFORM SET_JOB_NUMB_MSG.
        RETURN = 309.
        PERFORM SEND_MSG.
        CONTINUE.
      ENDIF.
    ELSE.                              "Mappe nicht mehr in DB
      JOB-RC = 2.
      NCOUNT = NCOUNT + 1.
      PERFORM SET_JOB_NUMB_MSG.
      RETURN = 309.
      PERFORM SEND_MSG.
      CONTINUE.
    ENDIF.
*
    JOB-BUSER = MTAB-USERID.
    JOB-DATE  = MTAB-CREDATE.
    JOB-TIME  = MTAB-CRETIME.
    JOB-NAME  = MTAB-GROUPID.
    JOB-QID   = MTAB-QID.
*
    PERFORM BIM_BERECHTIGUNG USING BIM-ABTC X.
*
    IF SY-SUBRC EQ 0.                  "user with authority
      IF MTAB-STARTDATE LT SY-DATUM.   "Mappe ohne Sperren-Datum
        OLD_QSTATE = APQI-QSTATE.
*
        PERFORM UPD_MAPPEN_INFO USING 'SUBM'.      "Mappenstatus 'S' und
*                                                  "Commit work
        CLEAR ENQ.
        ENQ-DATATYP = MTAB-DATATYP.
        ENQ-GROUPID = MTAB-GROUPID.
        ENQ-OBJECT  = MTAB-QID.
*
        PERFORM ENQUEUE USING  ENQ-DATATYP
                               ENQ-GROUPID
                               ENQ-OBJECT
                      CHANGING ENQ-RC
                               ENQ-USER.
*
        CASE RETURN.
          WHEN 0.           " Die Mappe wurde korrekt gesperrt
*             OK
          WHEN  322.        " Die Mappe war schon von anderem gesperrt
            JOB-RC = 10.
            FCOUNT = FCOUNT + 1.       "counter für logische Sperre
            PERFORM SET_JOB_NUMB_MSG.
            CONTINUE.
          WHEN OTHERS.
            JOB-RC = 20.               "others Systemfehler enqueue
            KCOUNT = KCOUNT + 1.       "für Systemfehler bei Sperre
            PERFORM SET_JOB_NUMB_MSG.
            CONTINUE.
        ENDCASE.
*
        JNAME = MTAB-GROUPID.
        CALL FUNCTION 'JOB_OPEN'
          EXPORTING
            JOBGROUP         = BI
            JOBNAME          = JNAME
** Modificado por L_FOUBERT 31.05.2013 Se agrega prioridad Alta a JOB tx: ZFITR007
            JOBCLASS         = 'A'
** END L_FOUBERT 31.05.2013 Se agrega prioridad Alta a JOB tx: ZFITR007
          IMPORTING
            JOBCOUNT         = JNUMB
          EXCEPTIONS
            CANT_CREATE_JOB  = 1
            INVALID_JOB_DATA = 2
            JOBNAME_MISSING  = 3
            OTHERS           = 99.
*
        IF SY-SUBRC EQ 0.              "Job_open OK
*
          SUBMIT (SUBREPORT)
                       USER MTAB-USERID
                       VIA JOB MTAB-GROUPID
                           NUMBER JNUMB
                       WITH QUEUE_ID  EQ MTAB-QID
                       WITH MAPPE     EQ MTAB-GROUPID
                       WITH MODUS     EQ 'N'
                       WITH LOGALL    EQ LMODUS
          AND RETURN.
*
          IF SY-SUBRC EQ 0.            "submit OK
            CLEAR JOBRELE.
            CALL FUNCTION 'JOB_CLOSE'
              EXPORTING
                JOBCOUNT             = JNUMB
                JOBNAME              = JNAME
                STRTIMMED            = X
                TARGETSYSTEM         = BATCHSYS
              IMPORTING
                JOB_WAS_RELEASED     = JOBRELE
              EXCEPTIONS
                CANT_START_IMMEDIATE = 1
                INVALID_STARTDATE    = 2
                JOBNAME_MISSING      = 3
                JOB_CLOSE_FAILED     = 4
                JOB_NOSTEPS          = 5
                JOB_NOTEX            = 6
                LOCK_FAILED          = 7
                OTHERS               = 99.
*
            IF SY-SUBRC EQ 0.          "Job_close is OK
              IF JOBRELE EQ X.         "job is release/freigelassen
                DCOUNT = DCOUNT + 1.
                PERFORM SET_JOB_NUMB_MSG.
              ELSE.                    "job is no release/nicht freigel.
                JOB-RC  = 7.
                JR_COUNT = JR_COUNT + 1.
                JOB_DELETE = 'X'.
                PERFORM UPD_MAPPEN_INFO USING 'RESE'. "Zuruecksetzen
                PERFORM SET_JOB_NUMB_MSG.
                CLEAR JOB_DELETE.
              ENDIF.
            ELSE.                      "Job_close is no OK
              JOB-RC  = 6.
              JC_COUNT = JC_COUNT + 1.
              JOB_DELETE = 'X'.
              PERFORM UPD_MAPPEN_INFO USING 'RESE'.   "Zuruecksetzen
              PERFORM SET_JOB_NUMB_MSG.
              CLEAR JOB_DELETE.
            ENDIF.
          ELSE.                        "submit is no OK
            JOB-RC  = 8.
            JS_COUNT = JS_COUNT + 1.
            JOB_DELETE = 'X'.
            PERFORM UPD_MAPPEN_INFO USING 'RESE'.     "Zuruecksetzen
            PERFORM SET_JOB_NUMB_MSG.
            CLEAR JOB_DELETE.
          ENDIF.
        ELSE.                          "Job_open is not OK
          JOB-RC  = 5.
          JO_COUNT = JO_COUNT + 1.
          JOB_DELETE = 'X'.
          PERFORM UPD_MAPPEN_INFO USING 'RESE'.       "Zuruecksetzen
          PERFORM SET_JOB_NUMB_MSG.
          CLEAR JOB_DELETE.
        ENDIF.
*
        PERFORM DEQUEUE.
*
      ELSE.                            "Mappe mit Sperre-Datum
        JOB-RC  = 9 .
        GCOUNT = GCOUNT + 1.
        PERFORM SET_JOB_NUMB_MSG.
      ENDIF.
    ELSE.                              "user whithout authority
      JOB-RC  = 1 .
      ACOUNT = ACOUNT + 1.
      PERFORM SET_JOB_NUMB_MSG.
    ENDIF.                             "bim_berechtigung
  ENDLOOP.                             "int. Tabelle MTAB.
*
  RETURN = 388.    "$ Mappen an die Hintergrundverarbeitung übergeben
*
ENDFORM.                               " submit_mappen.
*/
*---------------------------------------------------------------------*
* FORM : SET_JOB_NUMB_MSG
*                                                                     *
*---------------------------------------------------------------------*
FORM SET_JOB_NUMB_MSG .
*
*    batch-job wird geloescht, wenn bei job open, submit RSBDCBTC,
*    job close oder job freigegeben SY-SUBRC NE 0 ist.
*
  IF JOB_DELETE EQ 'X'.                "job wird gelöscht
    CALL FUNCTION 'BP_JOB_DELETE'
      EXPORTING
        JOBNAME    = JNAME
        JOBCOUNT   = JNUMB
        FORCEDMODE = X
      EXCEPTIONS
        OTHERS     = 99.
    SY-SUBRC = 0.
  ENDIF.
*
  MOVE: SY-UNAME      TO JOB-USER,
        BI            TO JOB-GROUP,
        JNUMB         TO JOB-NUMB,
        SY-UZEIT      TO JOB-STIME,
        SY-DATUM      TO JOB-SDATE.
  APPEND JOB.
*
ENDFORM.                               " SET_JOB_NUMB_MSG .
*/
*---------------------------------------------------------------------*
* FORM : WRITE_JOB_NUMB_MSG
*                                                                     *
*---------------------------------------------------------------------*
FORM WRITE_JOB_NUMB_MSG .
*
*    Abhängig von JOB-RC wird eine Meldung in der 'zweite Zeile' der
*    Liste geschrieben. Die Liste der Mappen hat pro Mappe zwei Zeile:
*    Die erste für die Attributen: Mappen-Name, Job-nummer, QID, etc.
*    und der zweite für eine eventuelle Meldung.
*
  CASE JOB-RC.
    WHEN 0.
*     WRITE 26 'SUBMIT erfolgreich'(045).
    WHEN 1.
      WRITE 26 'Keine Berechtigung - Abspielen im Batch'(048).
    WHEN 2.
      WRITE 26 'Mappe wird anderweitig gerade abgespielt'(058).
    WHEN 3.
      WRITE 26 'Nur Mappe mit Status ''neu'' oder ''felehrhaft'' '(020).
    WHEN 5.
      WRITE 26 'Öffnen des Jobs nicht erfolgreich '(021).
    WHEN 6.
      WRITE 26 'Schließen des Jobs nicht erfolgreich '(022).
    WHEN 7.
      WRITE 26 'Freigeben des Jobs nicht erfolgreich '(023).
    WHEN 8.
      WRITE 26 'Submit RSBDCBTC nicht erfolgreich gelaufen'(045).
    WHEN 9.
      WRITE 26 'Mappe besitzt ein Sperrdatum'(047).
    WHEN 10.
      WRITE 26 'Mappe wird anderweitig gerade abgespielt von'(024).
    WHEN OTHERS.
      WRITE 26 'Mappe nicht erfolgreich'(046).
  ENDCASE.
*
ENDFORM.                               " WRITE_JOB_NUMB_MSG .
*/
*-----------------------------------------------------------------
* FORM : upd_mappen_info
*
*-----------------------------------------------------------------
FORM UPD_MAPPEN_INFO USING VALUE(UART).
*
*** Aendern einer Batch-Input Mappe
*
*--------------------------------------------------update submitten
  IF UART = 'SUBM'.         "mappen als submittet kennzeichnen
*
    MTAB-QSTATE = 'S'.
    MODIFY MTAB.
*
    UPDATE APQI SET QSTATE = MTAB-QSTATE
*
    WHERE DESTSYS  =  MTAB-DESTSYS
    AND   DESTAPP  =  MTAB-DESTAPP
    AND   DATATYP  =  MTAB-DATATYP
    AND   GROUPID  =  MTAB-GROUPID
    AND   PROGID   =  MTAB-PROGID
    AND   FORMID   =  MTAB-FORMID
    AND   MANDANT  =  MTAB-MANDANT
    AND   QATTRIB  =  MTAB-QATTRIB
    AND   QID      =  MTAB-QID.
*
    COMMIT WORK.
*
  ENDIF.                               "subm
*--------------------------------------------------update reset
  IF UART = 'RESE'.                    "mappenstatus zuruecksetzen
*
    MTAB-QSTATE = OLD_QSTATE.
    MODIFY MTAB.
*
    UPDATE APQI SET QSTATE = MTAB-QSTATE
*
    WHERE DESTSYS       =  MTAB-DESTSYS
    AND   DESTAPP       =  MTAB-DESTAPP
    AND   DATATYP       =  MTAB-DATATYP
    AND   GROUPID       =  MTAB-GROUPID
    AND   PROGID        =  MTAB-PROGID
    AND   FORMID        =  MTAB-FORMID
    AND   MANDANT       =  MTAB-MANDANT
    AND   QATTRIB       =  MTAB-QATTRIB
    AND   QID           =  MTAB-QID.
*
    COMMIT WORK.
*
  ENDIF.                               "rese
*
*
ENDFORM.                               " upd_mappe_info.
*/
*---------------------------------------------------------------------*
* FORM : send_msg                                                     *
*                                                                     *
*---------------------------------------------------------------------*
FORM SEND_MSG.
*
*** Ausgabe von Bildschirmnachrichten
*
  CASE RETURN.
    WHEN 0.
*
    WHEN 302.                          " Datum ungueltig
      MESSAGE S302 WITH MTAB-STARTDATE.
*    WHEN 305.   "Markieren Status 'neu' und/oder 'fehlerhaft'
*      MESSAGE S368  with text-018 text-019.
    WHEN 306.   "Keine Mappe mit Status 'neu' oder 'fehlerhaft' gefunden
      MESSAGE S306.
    WHEN 309.      " Die angeforderte Mappe ist belegt
      MESSAGE S309.
    WHEN 388.      " $ Mappen werden im Hintergrund abgespielt
      MESSAGE S388 WITH DCOUNT.
    WHEN OTHERS.   " Batch-Input (Unbekannter Returnwert)
      MESSAGE S399.
  ENDCASE.
*
  CLEAR: RETURN.
*
ENDFORM.                               " send_msg.
*/
*---------------------------------------------------------------------*
*       FORM bim_berechtigung                                         *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
FORM BIM_BERECHTIGUNG USING AKTIVITY
                            MSGART.
*
  AUTHORITY-CHECK OBJECT 'S_BDC_MONI'
              ID 'BDCAKTI'     FIELD AKTIVITY
              ID 'BDCGROUPID'  FIELD MTAB-GROUPID.
*
  IF SY-SUBRC > 0.
    CASE AKTIVITY.
      WHEN BIM-AONL.         "keine berechtig. fuer abspielen/onl
        MESSAGE E391 WITH MTAB-GROUPID.
      WHEN BIM-ABTC.         "keine berechtig. fuer abspielen/btc
        IF MSGART EQ E.
          MESSAGE E392 WITH MTAB-GROUPID.
        ELSE.
*         MESSAGE I392 WITH MTAB-GROUPID.
        ENDIF.
      WHEN BIM-FREE.                   "keine berechtig. fuer freigeben
        MESSAGE S393 WITH MTAB-GROUPID.
      WHEN BIM-LOCK.         "keine berechtig. fuer sperren/entsp.
        MESSAGE S394 WITH MTAB-GROUPID.
      WHEN BIM-DELE.                   "keine berechtig. fuer loeschen
        MESSAGE S395 WITH MTAB-GROUPID.
      WHEN BIM-ANAL.                   "keine berechtig. fuer analyse
        MESSAGE S396 WITH MTAB-GROUPID.
    ENDCASE.
  ENDIF.
*
ENDFORM.                               "bim_berechtigung
*/
*---------------------------------------------------------------------*
* FORM : enqueue_object_qid                                           *
*---------------------------------------------------------------------*
* sperren einer qid gegen weitere verarbeitung                        *
*---------------------------------------------------------------------*
FORM ENQUEUE USING ENQ_DATATYP LIKE ENQ-DATATYP
                   ENQ_GROUPID LIKE ENQ-GROUPID
                   ENQ_OBJECT  LIKE ENQ-OBJECT
          CHANGING ENQ_RC      LIKE ENQ-RC
                   ENQ_USER    LIKE ENQ-USER.
*
  CLEAR RETURN.
  CALL FUNCTION 'ENQUEUE_BDC_QID'
    EXPORTING
      DATATYP        = ENQ_DATATYP
      GROUPID        = ENQ_GROUPID
      QID            = ENQ_OBJECT
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 99.
*
  ENQ_RC    = SY-SUBRC.
  ENQ_USER  = SY-MSGV1.
*
  CASE ENQ_RC.
    WHEN 0.
      RETURN = 0.
    WHEN 1.
      RETURN = 322.
    WHEN OTHERS.
      RETURN = 353.
  ENDCASE.
*
ENDFORM.                               " ENQUEUE_OBJECT_QID
*---------------------------------------------------------------------*
* FORM : dequeue                                                      *
*---------------------------------------------------------------------*
* entsperren einer qid für weitere verarbeitung                       *
*---------------------------------------------------------------------*
FORM DEQUEUE .
*
  CALL FUNCTION 'DEQUEUE_BDC_QID'
    EXPORTING
      DATATYP = ENQ-DATATYP
      GROUPID = ENQ-GROUPID
      QID     = ENQ-OBJECT.
*
ENDFORM.                               " DEQUEUE
*/
*---------------------------------------------------------------------*
* FORM : write_vline                                                  *
*                                                                     *
*---------------------------------------------------------------------*
FORM WRITE_VLINE USING POS.
*
*** Vline schreiben
*
  POSITION POS.
  WRITE: SY-VLINE.
*
ENDFORM.                               " write_vline
*
*---------------------------------------------------------------------*
******  ZEITPUNKTE DER LISTVERARBEITUNG  ******************************
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
* TOP OF PAGE  -  EREIGNIS                                            *
*---------------------------------------------------------------------*
TOP-OF-PAGE.
*
*** Ausgabe Ueberschriften
*
  WRITE:/01(100) SY-ULINE.
  FORMAT COLOR COL_HEADING INTENSIFIED ON.
  WRITE:/12 'Überschrift'(053), 72 SY-DATUM.
  PERFORM WRITE_VLINE USING  1.
  PERFORM WRITE_VLINE USING  100.
  WRITE:/01(100) SY-ULINE.
*
*      DATE1 = SY-DATUM.
  WRITE:/02(08) 'Uhrzeit'(009),
         12(12) 'Mappenname'(015),
         26(10) 'Datum     '(016),
         37(08) 'Zeit    '(017),
         46(08) 'Job-Nr'(051),
         63(20) 'Queue_ID'(006).
  PERFORM WRITE_VLINE USING  1.
  PERFORM WRITE_VLINE USING 11.
  PERFORM WRITE_VLINE USING 25.
  PERFORM WRITE_VLINE USING 36.
  PERFORM WRITE_VLINE USING 45.
  PERFORM WRITE_VLINE USING 62.
  PERFORM WRITE_VLINE USING 100.
*
  WRITE:/01(100) SY-ULINE.
*
  PERFORM WRITE_VLINE USING  1.
  PERFORM WRITE_VLINE USING 11.
  PERFORM WRITE_VLINE USING 25.
  PERFORM WRITE_VLINE USING 36.
  PERFORM WRITE_VLINE USING 45.
  PERFORM WRITE_VLINE USING 62.
  PERFORM WRITE_VLINE USING 100.
*                                       " top-of-page.
*---------------------------------------------------------------------*
* AT  USER-COMMAND -  EREIGNIS                                        *
*---------------------------------------------------------------------*
*     Auswerten gedrueckter Funktionstasten in Listverarbeitung       *
*---------------------------------------------------------------------*
AT USER-COMMAND.
*
  CASE SYST-UCOMM.
    WHEN 'BACK'.
      LEAVE.
    WHEN 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'END '.
      LEAVE TO SCREEN 0.
    WHEN 'SM35'.
*
*      DATA: ZMAPN TYPE D0100-MAPN.
*      ZMAPN = MAPPE.
*
*      MOVE MAPPE TO D0100-MAPN.
*
*      SET PARAMETER ID 'MAPN' FIELD D0100-MAPN.
**      SET PARAMETER ID 'D0100-VON' FIELD '00000000'.
**      SET PARAMETER ID 'D0100-BIS' FIELD '00000000'.
**      SET PARAMETER ID 'D0100-CREATOR' FIELD '*'.
       CALL TRANSACTION 'SM35'.

*      PERFORM CALL_SM35 USING MAPPE.

    WHEN OTHERS.
*
  ENDCASE.                             "sy-ucomm
*
*&---------------------------------------------------------------------*
*&      Form  job_statistik
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM JOB_STATISTIK.

  WRITE:/02  TCOUNT, 'Mappe(n) wurden selektiert, um abzuspielen '(060).

  WRITE:/02  DCOUNT, 'Mappe(n) wurden ordnungsgemäß abgespielt '(061).

  IF NCOUNT GT 0.
    WRITE:/02  NCOUNT,
    'Mappe(n) werden gerade abgespielt oder sind gelöscht '(062).
  ENDIF.
  IF ACOUNT GT 0.
    WRITE:/02  ACOUNT,
          'Mappe(n) zu denen der Benutzer keine Berechtigung hat'(063).
  ENDIF.
  IF GCOUNT GT 0.
    WRITE:/02  GCOUNT,
           'Mappe(n) besitzen ein Sperrdatum in der Zukunft'(064).
  ENDIF.
  IF SCOUNT GT 0.
    WRITE:/02  SCOUNT,
           'Mappe(n) ohne Status neu oder fehlerhaf'(065).
  ENDIF.
  IF FCOUNT GT 0.
    WRITE:/02  FCOUNT,
           'Mappe(n) mit ABAP-Sperre gefunden'(070).
  ENDIF.
  IF KCOUNT GT 0.
    WRITE:/02  KCOUNT,
           'ABAP-Sperre nicht ordnungsmäß gelaufen'(071).
  ENDIF.

  IF JO_COUNT GT 0.
    WRITE:/02  JO_COUNT, 'JOB_OPEN nicht ordnungsgemäß gelaufen'(066).
  ENDIF.
  IF JC_COUNT GT 0.
    WRITE:/02  JC_COUNT, 'JOB_CLOSE nicht ordnungsgemäß gelaufen'(067).
  ENDIF.
  IF JR_COUNT GT 0.
    WRITE:/02  JR_COUNT, 'Jobs nicht freigegeben'(068).
  ENDIF.
  IF JS_COUNT GT 0.
    WRITE:/02  JS_COUNT,
          'Submit RSBDCBTC nicht erfolgreich gelaufen'(069).
  ENDIF.
ENDFORM.                               " job_statistik
*&---------------------------------------------------------------------*
*&      Form  CALL_SM35
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MAPPE  text
*----------------------------------------------------------------------*
FORM CALL_SM35  USING    P_MAPPE.

  CLEAR BDCDATA.
  REFRESH BDCDATA.

  PERFORM BDC_DYNPRO      USING 'SAPMSBDC_CC' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=REFR'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'D0100-MAPN'.
  PERFORM BDC_FIELD       USING 'D0100-MAPN'
                                P_MAPPE.




      DATA: CTUMODE LIKE CTU_PARAMS-DISMODE VALUE 'A'.
      DATA: CUPDATE LIKE CTU_PARAMS-UPDMODE VALUE 'L'.
      DATA OPT TYPE CTU_PARAMS.
      OPT-NOBINPT = 'X'.
      OPT-DISMODE = CTUMODE.
      OPT-UPDMODE = CUPDATE.

      CLEAR MESSTAB.
      REFRESH MESSTAB.

      CALL TRANSACTION 'SM35' USING BDCDATA
                        OPTIONS FROM OPT
                       MESSAGES INTO MESSTAB.

ENDFORM.                                                    " CALL_SM35
