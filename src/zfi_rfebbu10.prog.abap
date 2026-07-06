*----------------------------------------------------------------------*
* Report zum Interpretieren der Verwendungszweckzeilen                 *
*----------------------------------------------------------------------*
* ak271198 Revised algorithms 27 & 28 (TITO)                           *
* sb040399 Revised algorithm 28 (KIDNO with country spec. check)       *
* ak250399 Moved variables TREFFER, KIDNO_TAB, SPEICHER and            *
*          CLEARDATA to common-part of include RFEBBU03 (to enable     *
*          new transaction FEBSTS).                                    *
*          Introduced pattern-searching.                               *
* ak060599 Minor changes concerning call to IDENTIFY_BUSINESS_PARTNER. *
*          Should not affect the behaviour of the report but necessary *
*          for external call of the routine.                           *
* ak260599 applied note 134047                                         *
* ak200799 applied note 163507                                         *
* ak051199 Corrected form GERMAN_BZUE_WITH_BELNR.                      *
* ak101299 Enhancement pattern-searching.                              *
* ak281299 Introduced new interpretation-algorithm 033.                *
* ak090300 Applied note 206022.                                        *
* mo110700 applied note 206380                                         *
* C5060356 modification of 'BSPS_PATTERN_SETUP'                        *
*----------------------------------------------------------------------*
REPORT RFEBBU10 MESSAGE-ID FB
                LINE-SIZE 80
                NO STANDARD PAGE HEADING.


* --Common Data -------------------------------------------------------*
INCLUDE RFEBBU03.


DATA: FALSE           TYPE C VALUE ' '.

DATA: EP_CL_DATA      TYPE C.          "Ausgleichsinfo zu EP da?

DATA: HEAD(70)        TYPE C,
      CHAR            LIKE HEAD,
      HEAD-LEN(3)     TYPE N.

DATA: LENGTH(3)       TYPE N,
      LEN(3)          TYPE N.

DATA: MSTYP       LIKE FEBMKA-MSTYP,
      MSTXT       LIKE FEBMKA-MESSG.

DATA: OFF(3)          TYPE N.          " Offset

DATA: PUFFER(65000)   TYPE C.                               "hw607989

DATA: SFNAM           LIKE RFPDO1-FEBSELFD,
      STRING(770)     TYPE C.

DATA  TRUE            TYPE C VALUE 'X'.

DATA: UPDATE(1)       TYPE C.


DATA: CONVERT1(52)  TYPE C VALUE
             'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ',
      CONVERT2_norway(52)  TYPE C VALUE                     "note 398160
             '. , < > & " % ! ( ) = ? : # * + / $ # _ ',    "note 398160
      CONVERT2(52)  TYPE C VALUE
*            '. , < > & " % ! ( ) = ? ß : - # * + / $ # _ Ü Ä Ö ',  "46C
             '. , < > & " % ! ( ) = ? : - # * + / $ # _ ; ',"hw498406
      CONVERT3(02)  TYPE C VALUE
             ' ;'.

*eject
*---------------------------------------------------------------*
*  FORM EINZELPOSTEN_AUSWERTEN.                                 *
*---------------------------------------------------------------*
*  Einzelposten nach BELNR, usw. durchsuchen                    *
*---------------------------------------------------------------*
FORM EINZELPOSTEN_AUSWERTEN USING TESTRUN TYPE XFLAG.
*-- vars for patternsearching
  DATA:   EDGES_LIST       TYPE BSPS_EDGES_LIST_TABLE,
          PAT_HITS         TYPE BSPS_HITS_TABLE WITH HEADER LINE,
          BUS_PAR_FOUND(1) TYPE C.
  DATA:   UNDEFINED(1) TYPE C.         "<INSERT 140613
  DATA:   BEGIN OF YFEBCL OCCURS 14.
          INCLUDE STRUCTURE FEBCL.
  DATA:   END OF YFEBCL.
  DATA:   BEGIN OF YFEBKO OCCURS 0.
          INCLUDE STRUCTURE FEBKO.
  DATA:   END OF YFEBKO.
  DATA    DO_FI TYPE BOOLE_D.
  DATA    APPL_ERROR TYPE BOOLE_D.
  DATA:   BEGIN OF YFEBEP OCCURS 0.
          INCLUDE STRUCTURE FEBEP.
  DATA:   END OF YFEBEP.
  DATA: L_SELFD LIKE FEBCL-SELFD VALUE 'FB'.                   "loans
  DATA: L_SELVON LIKE FEBCL-SELVON VALUE 'FEB_2_BUCH_ABW_EKA'. "loans
  DATA: LC_SELFD_RE      LIKE FEBCL-SELFD  VALUE 'FB',         "RE
        LC_SELVON_RE_OP  LIKE FEBCL-SELVON VALUE 'FEB_2_IMMO_OP',
        LC_SELVON_RE_LSR LIKE FEBCL-SELVON VALUE 'FEB_2_IMMO_LASTSCHR',
        LC_SELVON_RE_INV LIKE FEBCL-SELVON VALUE 'FEB_2_RE_INV_CLEAR'.
  DATA: FIRST(1) TYPE C.                                    "ak200799

  CLASS CL_EXITHANDLER DEFINITION LOAD.
  DATA:  L_BADI TYPE REF TO IF_EX_FIEB_CHANGE_BS_DATA,
         L_BADI2 TYPE REF TO IF_EX_FIEB_CHANGE_STATEMNT,    "hw804508
         lt_febep type standard table of febep,             "hw804508
         lt_febcl type standard table of febcl,             "hw804508
         lt_changed_febep type standard table of febep,     "hw804508
         lt_changed_febcl type standard table of febcl,     "hw804508
         lt_delete_febcl type standard table of febcl,      "hw804508
         lt_febre type standard table of febre,             "hw804508
         HLP_LAND type land1,                               "hw804508
         L_SUBRC TYPE SY-SUBRC,
         L_MSGID TYPE SY-MSGID,
         L_MSGTY TYPE SY-MSGTY,
         L_MSGNO TYPE SY-MSGNO,
         L_MSGV1 TYPE SY-MSGV1,
         L_MSGV2 TYPE SY-MSGV2,
         L_MSGV3 TYPE SY-MSGV3,
         L_MSGV4 TYPE SY-MSGV4.
  field-symbols: <febcl> type febcl,                        "hw804508
                 <febep> type febep.                        "hw804508
  data:  l_note_to_payee type string,                       "hw597428
         l_avip_in type standard table of avip,             "hw597428
         l_avip_out type standard table of avip,            "hw597428
         l_funct(30) type c,                                "hw597428
         l_original_rsnum type i,                           "hw597428
         l_country like t001-land1.                         "hw597428

  CALL METHOD CL_EXITHANDLER=>GET_INSTANCE                  "hw804508
    EXPORTING                                               "hw804508
      EXIT_NAME              = 'FIEB_CHANGE_STATEMNT'       "hw804508
      NULL_INSTANCE_ACCEPTED = 'X'                          "hw804508
    CHANGING                                                "hw804508
      INSTANCE               = L_BADI2.                     "hw804508
  CALL METHOD CL_EXITHANDLER=>GET_INSTANCE
    EXPORTING
      EXIT_NAME              = 'FIEB_CHANGE_BS_DATA'        "hw561859
      NULL_INSTANCE_ACCEPTED = 'X'                          "hw561859
    CHANGING
      INSTANCE               = L_BADI.

*-- Save BELNR and XBLNR interval to ABAP Memory --           n907386
EXPORT TFILTER                                               "n907386
       FILTER                                                "n907386
  TO MEMORY ID 'FF5_INTERVALS'.                              "n907386

*-- Selection of all Transactions --
  REFRESH YFEBKO.
  CLEAR YFEBKO.
  SELECT * FROM FEBKO INTO TABLE YFEBKO
           WHERE KUKEY IN R_KUKEY.
*ziclos traemos todos los registros
*             AND KIPRE NE 'X'.

  IF SY-SUBRC = 0.                                          "ak200799
    FIRST = 'X'.                                            "ak200799
  ENDIF.                                                    "ak200799

  LOOP AT YFEBKO.
    FEBKO = YFEBKO.
    REFRESH YFEBEP.
    CLEAR YFEBEP.
    refresh: lt_febep, lt_febcl, lt_febre,                  "hw804508
             lt_changed_febep, lt_changed_febcl.            "hw804508
    SELECT * FROM FEBEP INTO TABLE YFEBEP
             WHERE KUKEY = FEBKO-KUKEY.

*ziclos tenemos que volver a pasar por los filtros todos
* los regsitros que no se hayan compensado
*               AND PIPRE NE 'X'.

*-- setup (compile) search patterns valid for this statement
    CALL FUNCTION 'BSPS_PATTERN_SETUP'
      EXPORTING
        BUKRS             = FEBKO-BUKRS
        HBKID             = FEBKO-HBKID
        HKTID             = FEBKO-HKTID
      TABLES
        EDGES_LIST        = EDGES_LIST
      EXCEPTIONS
        NOT_FOUND         = 1
        ERROR             = 2
        NO_PATTERNS_FOUND = 3
        OTHERS            = 4.

    CASE SY-SUBRC.
      WHEN 0.
*-- do nothing
      WHEN 3.
*-- no patterns defined for this statement - probably by intention -
      WHEN OTHERS.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDCASE.
*ziclos solo tomamos los que no están compensados
    LOOP AT YFEBEP where
                   belnr is initial.
      FEBEP = YFEBEP.
* Selection der zu interpretierenden Einzelposten
*  SELECT * FROM febko WHERE kukey IN r_kukey
*                        AND kipre NE 'X'.
*    SELECT * FROM febep WHERE kukey = febko-kukey
*                          AND pipre NE 'X'.
      CLEAR XFEBCL. REFRESH XFEBCL.
      CLEAR YFEBCL. REFRESH YFEBCL.
      IF ( FEBKO-EFART = 'M'    AND
         FEBKO-ANWND = '0001' ) OR
         FEBKO-ANWND = '0002'.
        SELECT * FROM FEBCL INTO TABLE XFEBCL
                 WHERE KUKEY = FEBEP-KUKEY
                   AND ESNUM = FEBEP-ESNUM.
        YFEBCL[] = XFEBCL[].
*        SELECT * FROM febcl INTO TABLE yfebcl
*                 WHERE kukey = febep-kukey
*                   AND esnum = febep-esnum.
      ELSE.
*        electronic statements only
        IF FIRST = 'X'.                                     "ak200799
*-- display at first non interpretated line item only
          PERFORM DISPLAY_PROCESS_STATUS USING  TEXT-007.
          CLEAR FIRST.                                      "ak200799
        ENDIF.                                              "ak200799
      ENDIF.
*-- select text from FEBRE; not if manual bank statement/cheque deposit
*--                         and no interpret. algorithm (PIPRE = 'Y')
      IF FEBEP-PIPRE = SPACE.
        REFRESH XFEBCL. CLEAR XFEBCL.
        EP_CL_DATA = FALSE.

        SELECT        * FROM  FEBRE INTO TABLE XFEBRE
               WHERE  KUKEY       = FEBEP-KUKEY
               AND    ESNUM       = FEBEP-ESNUM.
      ENDIF.

*-- everything selected -> OPEN FI ---
      PERFORM OPEN_FI_CALL USING TESTRUN.

* call badi!

      IF L_BADI IS INITIAL.
        CALL METHOD CL_EXITHANDLER=>GET_INSTANCE
          EXPORTING
            EXIT_NAME              = 'FIEB_CHANGE_BS_DATA'  "hw561859
            NULL_INSTANCE_ACCEPTED = 'X'                    "hw561859
          CHANGING
            INSTANCE               = L_BADI.
      ENDIF.

      if not l_badi is initial.                             "hw561859
        CALL METHOD L_BADI->CHANGE_DATA
          EXPORTING
            I_TESTRUN = TESTRUN
            T_FEBRE   = XFEBRE[]
          IMPORTING
            E_SUBRC   = L_SUBRC
            E_MSGID   = L_MSGID
            E_MSGTY   = L_MSGTY
            E_MSGNO   = L_MSGNO
            E_MSGV1   = L_MSGV1
            E_MSGV2   = L_MSGV2
            E_MSGV3   = L_MSGV3
            E_MSGV4   = L_MSGV4
          CHANGING
            C_FEBKO   = FEBKO
            C_FEBEP   = FEBEP
            T_FEBCL   = XFEBCL[].

        IF L_SUBRC <> 0.
          MESSAGE ID L_MSGID TYPE L_MSGTY NUMBER L_MSGNO
                  WITH L_MSGV1 L_MSGV2 L_MSGV3 L_MSGV4.
        ENDIF.
      endif.                                                "hw561859
*ziclos . desparece este control para que puedan pasar los cheque en segunda ejecución
*     IF FEBEP-PIPRE = SPACE.
        IF ( FEBEP-B1STD <> 'X' OR FEBEP-B2STD <> 'X' )
        and ( febep-b1err = ' ' and febep-b2err = ' ' ).    "hw662494
          REFRESH SPEICHER. CLEAR SPEICHER.
          LOOP AT XFEBRE.
            SPEICHER = XFEBRE-VWEZW.
            APPEND SPEICHER.
          ENDLOOP.

*       CHECT wird auch an Speicher angehängt, um den Interpretations-
*       algorithmen Zugriff auf CHECT zu ermöglichen.
          IF NOT FEBEP-CHECT IS INITIAL.
            SPEICHER = FEBEP-CHECT.
            APPEND SPEICHER.
          ENDIF.
*       KIDNO ebenfalls
          IF NOT FEBEP-KIDNO IS INITIAL.
            SPEICHER = FEBEP-KIDNO.
            APPEND SPEICHER.
          ENDIF.

          BUS_PAR_FOUND = FALSE.

          CLEAR: AGKON, AGKOA, KNA1, KNBK, LFA1, LFBK.      "note 331122
          IF EP_CL_DATA = FALSE                                 "n969358
             AND
               ( FEBEP-PAKTO IS NOT INITIAL
              OR FEBEP-PIBAN IS NOT INITIAL ).
*-- identify business-partner via bank-data only if no FEBCL-data could
*-- be found for this item
            PERFORM IDENTIFY_BUSINESS_PARTNER.
          ENDIF.

          IF FEBEP-AVKON NE SPACE.
            BUS_PAR_FOUND = TRUE.
          ENDIF.

          CLEAR PAT_HITS.
          REFRESH PAT_HITS.

*-- perform pattern-search - if pattern-list not empty
          IF NOT EDGES_LIST IS INITIAL.
            CALL FUNCTION 'BSPS_PATTERN_SEARCH'
              EXPORTING
                BUS_PAR_FOUND = BUS_PAR_FOUND
              TABLES
                EDGES_LIST    = EDGES_LIST
                NOTE_TO_PAYEE = XFEBRE
                HITS          = PAT_HITS
              CHANGING                                      "ak101299
                C_FEBKO       = FEBKO
                C_FEBEP       = FEBEP
              EXCEPTIONS
                ERROR         = 1
                NOT_FOUND     = 2
                OTHERS        = 3.

            IF SY-SUBRC <> 0 AND SY-SUBRC <> 2.
              MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            ELSE.
              IF AGKON IS INITIAL AND AGKOA IS INITIAL.   "note 780403
                AGKON = FEBEP-AVKON.
                AGKOA = FEBEP-AVKOA.
              ENDIF.
            ENDIF.
          ENDIF.

          DESCRIBE TABLE XFEBRE LINES XFEBRE-RSNUM.       "note 300271
          l_original_rsnum = xfebre-rsnum.                  "hw597428
          LOOP AT PAT_HITS WHERE TARGFI = SPACE.            "ak101299
            SPEICHER = PAT_HITS-MAPRES.
            APPEND SPEICHER.
            XFEBRE-VWEZW = PAT_HITS-MAPRES.               "note 300271
            ADD 1 TO XFEBRE-RSNUM.                        "note 300271
            APPEND XFEBRE.                                "note 300271
          ENDLOOP.

          CASE FEBEP-INTAG.
            WHEN '000'.
*         do nothing
            WHEN '001'.
*         Standardalgo: Führt Suche nach BELNR bzw. XBLNR aus,
*         wenn BELNR bzw. XBLNR Range nicht initial ist.
              IF NOT FILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
              ENDIF.
              IF NOT TFILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'XBLNR'.
              ENDIF.
            WHEN '011'.
*         Ausgangsscheck: Schecknummer ungleich Zahlungsbelegnummer
              PERFORM SEARCH_CHECK_IN_PAYR.
              DESCRIBE TABLE XFEBCL LINES TFILL_XFEBCL.     "45A
              IF TFILL_XFEBCL = 0.                          "45A
                PERFORM MOVE_DUMMY_BELNR_TO_XFEBCL USING 'S'."45A
              ENDIF.                                        "45A
            WHEN '012'.
*         Ausgangsscheck: Schecknummer gleich Zahlungsbelegnummer
              IF NOT FILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
              ENDIF.
              DESCRIBE TABLE XFEBCL LINES TFILL_XFEBCL.     "46A
              IF TFILL_XFEBCL = 0.                          "46A
                PERFORM MOVE_DUMMY_BELNR_TO_XFEBCL USING 'S'."46A
              ENDIF.                                        "46A
            WHEN '013'.
*         Ausgangsscheck: Schecknummer = oder <> Zahlungsbelegnummer
              PERFORM SEARCH_CHECK_IN_PAYR.
              DESCRIBE TABLE XFEBCL LINES TFILL_XFEBCL.
              IF TFILL_XFEBCL = 0.
                PERFORM SEARCH_CHECK_IN_BKPF.
              ENDIF.
              DESCRIBE TABLE XFEBCL LINES TFILL_XFEBCL.     "46A
              IF TFILL_XFEBCL = 0.                          "46A
                PERFORM MOVE_DUMMY_BELNR_TO_XFEBCL USING 'S'."46A
              ENDIF.                                        "46A
            WHEN '015'.                                     "40C
*         manual G/L lines with field allocation number      "40C
*         prerequisite: G/L account is in the posting rule   "40C
              PERFORM FILL_ALLOCATION_SELECTION.            "40C
              DESCRIBE TABLE XFEBCL LINES TFILL_XFEBCL.     "45B
              IF TFILL_XFEBCL = 0.                          "45B
                PERFORM MOVE_DUMMY_BELNR_TO_XFEBCL USING 'S'."45B
              ENDIF.                                        "45B
            WHEN '019'.
*         Referenznummer des Zahlprogramms zur Suche der Zahl.belegnr
*         oder der Zahlauftragsnummer
              PERFORM SEARCH_BELNR_OF_PAYM_PROG.
            WHEN '020'.
*         Search for BELNR
              IF NOT FILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
              ENDIF.
            WHEN '021'.
*         Search for XBLNR
              IF NOT TFILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'XBLNR'.
              ENDIF.
            WHEN '022'.
*         deutsches BZÜ-Verfahren
              PERFORM GERMAN_BZUE_WITH_BELNR.
            WHEN '023'.
*         deutsches BZÜ-Verfahren
              PERFORM GERMAN_BZUE_WITH_XBLNR.
            WHEN '024'.
*         Reserviert für Lastschriftrückläufer
            WHEN '025'.
*         Invoice List
              IF NOT TFILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'ILIST'.
              ENDIF.
            WHEN '026'.
*         SD Referenzbelegnummer. Hintergrund:
*         SD gibt 10-stellige Nummern in XBLNR mi führenden Nullen,
*         aber Kunde erhält führende Nullen nicht, daher müssen nach
*         der Interpretation führende Nullen aufgefüllt werden.
*         Betaversion: zu Release 3.0F nicht offiziell freigegeben,
*         aber mit   allerhöchster   Wahrscheinlichkeit korrekt.
              if 1 = 2.   " Don't search for BELNR          " \TP 738807
                IF NOT FILTER IS INITIAL.
                  PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
                ENDIF.
              endif. " 1 = 2                                " \TP 738807
              IF NOT TFILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'SDXBLNR'.
              ENDIF.
            WHEN '027'.
*         SEARCH FOR KIDNO (TITO)
              PERFORM ANALYSE_VERWENDUNGSZWECK USING 'KIDNO_T'.
            WHEN '028'.
*         SEARCH FOR KIDNO (converting programs via MULTICASH)
              PERFORM ANALYSE_VERWENDUNGSZWECK USING 'KIDNO'.
            WHEN '029'.
*         Search for number of Payment order PYORD
              IF NOT TFILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'PYORD'.
              ENDIF.
            WHEN '030'.
*           Brazilian Search, searches for BELNR, GJAHR and BUZEI
              PERFORM SEARCH_COBRANCA.
            WHEN '031'.
*         Search for BELNR - read BSEG
              IF NOT FILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK
                        USING 'BELNR2'.
              ENDIF.
            WHEN '032'.
*           SEARCH FOR ADVICE
              IF NOT FEBEP-CHECT IS INITIAL.
                PERFORM FIND_ADVICE USING FEBEP-CHECT
                                          FEBKO-BUKRS
                                          FEBKO-HKONT
                                          FEBEP-AVKON
                                          FEBEP-AVKOA
*                                         FEBEP-AVSID.   "<DELETE 140613
                                          FEBEP-AVSID    "<INSERT 140613
                                          UNDEFINED.     "<INSERT 140613
              ENDIF.
*             if febep-avsid is initial.                 "<DELETE 140613
              IF     FEBEP-AVSID IS INITIAL              "<INSERT 140613
                 AND UNDEFINED = ' '.  "<INSERT 140613
*              NO ADVICE FOUND, NO MULTIPLE ENTRIES
                IF NOT FILTER IS INITIAL.
*                    Search for BELNR - read BSEG
                  PERFORM ANALYSE_VERWENDUNGSZWECK
                     USING 'BELNR2'.
                ENDIF.
*                 IF NOT FILTER IS INITIAL.
*                    PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
*                 ENDIF.
                IF NOT TFILTER IS INITIAL.
                  PERFORM ANALYSE_VERWENDUNGSZWECK USING 'XBLNR'.
                ENDIF.
              ENDIF.
            WHEN '033'.
*-- search for payment-advice
              IF NOT TFILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'AVSID'.
                IF FEBEP-AVSID IS INITIAL.
*-- not successfull - try ordinary search
                  DELETE XFEBCL WHERE SELFD = 'WRBTR'.
                  PERFORM ANALYSE_VERWENDUNGSZWECK USING 'XBLNR'.
                  IF NOT FILTER IS INITIAL.
                    DELETE XFEBCL WHERE SELFD = 'WRBTR'.
                    PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
                  ENDIF.
                ENDIF.
              ENDIF.

            WHEN '034'.
*    Search for KIDNO (like '028') and write corresponding
*    PYORD in cleardata (only for Finnland -> note 388705)
              PERFORM ANALYSE_VERWENDUNGSZWECK USING 'KIDNO_TO_PYORD'.

            when '035'.
*    see comment of form multi_algorithm and note 555352)
              perform ANALYSE_VERWENDUNGSZWECK USING 'MULTI'." 555352

            WHEN '040'.                "loans
*         Treasury Search with priority Standard
* algorithms 040 and 041 are now executed in a loans/treasury BTE
* LOAN_EB_EVENT_00002810************************************mo051101
*              IF NOT FILTER IS INITIAL.
*                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
*              ENDIF.
*              IF NOT TFILTER IS INITIAL.
*                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'XBLNR'.
*              ENDIF.
*              DESCRIBE TABLE XFEBCL LINES TFILL_XFEBCL.
*              IF TFILL_XFEBCL = 0.
*                PERFORM SEARCH_TREASURY.
*                FLAG_TREA = '1'.
*              ENDIF.
            WHEN '041'.                "loans
* algorithms 040 and 041 are now executed in a loans/treasury BTE
* LOAN_EB_EVENT_00002810************************************mo051101
**         Treasury Search with priority loan-number
*              PERFORM SEARCH_TREASURY.
*              DESCRIBE TABLE XFEBCL LINES TFILL_XFEBCL.
*              IF TFILL_XFEBCL = 0.
*                IF NOT FILTER IS INITIAL.
*                  PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
*                ENDIF.
*                IF NOT TFILTER IS INITIAL.
*                  PERFORM ANALYSE_VERWENDUNGSZWECK USING 'XBLNR'.
*                ENDIF.
*              ELSE.
*                LOOP AT XFEBCL
*                  WHERE SELFD   = L_SELFD
*                  AND   SELVON = L_SELVON.
*                  EXIT.
*                ENDLOOP.
*                IF SY-SUBRC = 0.
*                  CLEAR XFEBCL.
*                  REFRESH XFEBCL.
*                  IF NOT FILTER IS INITIAL.
*                    PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
*                  ENDIF.
*                  IF NOT TFILTER IS INITIAL.
*                    PERFORM ANALYSE_VERWENDUNGSZWECK USING 'XBLNR'.
*                  ENDIF.
*                ELSE.
*                  FLAG_TREA = '1'.
*                ENDIF.
*              ENDIF.
            WHEN '050'.                "real estate
*          IS-RE Search with priority Standard
*          for RE-FX: algorithms 050 and 051 are now executed per BTE
*          for RE Classic: use algorithms 050 and 051
              INCLUDE ifre_begin_of_re_classic.
              IF NOT FILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
              ENDIF.
              IF NOT TFILTER IS INITIAL.
                PERFORM ANALYSE_VERWENDUNGSZWECK USING 'XBLNR'.
              ENDIF.
              LOOP AT XFEBCL
                  WHERE ( SELFD  = 'XBLNR' OR SELFD  = 'BELNR' ).
                EXIT.
              ENDLOOP.
              IF SY-SUBRC <> 0.
                CLEAR XFEBCL. REFRESH XFEBCL.
              ENDIF.
              DESCRIBE TABLE XFEBCL LINES TFILL_XFEBCL.
              IF TFILL_XFEBCL = 0.
                PERFORM SEARCH_IMMO.
                FLAG_IMMO = '1'.
              ENDIF.
              INCLUDE ifre_end_of_re_classic.
            WHEN '051'.                "real estate
*         IS-RE Search with priority rental agreement number
              INCLUDE ifre_begin_of_re_classic.
              PERFORM SEARCH_IMMO.
*             DESCRIBE TABLE XFEBCL LINES TFILL_XFEBCL.
*             IF TFILL_XFEBCL = 0.
              LOOP AT XFEBCL
                WHERE SELFD    = LC_SELFD_RE
                AND   ( SELVON = LC_SELVON_RE_OP  OR
                        SELVON = LC_SELVON_RE_LSR OR
                        SELVON = LC_SELVON_RE_INV ).
                EXIT.
              ENDLOOP.
              IF SY-SUBRC <> 0.
                CLEAR XFEBCL. REFRESH XFEBCL.
                IF NOT FILTER IS INITIAL.
                  PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
                ENDIF.
                IF NOT TFILTER IS INITIAL.
                  PERFORM ANALYSE_VERWENDUNGSZWECK USING 'XBLNR'.
                ENDIF.
              ELSE.
                FLAG_IMMO = '1'.
              ENDIF.
              INCLUDE ifre_end_of_re_classic.
            WHEN '060'.
*          Searches for Cleared documents via BELNR.        "note 837317
              PERFORM ANALYSE_VERWENDUNGSZWECK            "note 837317
                       USING 'CLEAREDBELNR'.              "note 837317
            WHEN '120'.                                     "note 454133
*          Searches for numbers which are in BELNR-filter   "note 454133
*          range, but doesn't check if the document exist.  "note 454133
              IF NOT FILTER IS INITIAL.                     "note 454133
                PERFORM ANALYSE_VERWENDUNGSZWECK            "note 454133
                         USING 'BELNR_NO_CHECK'.            "note 454133
              ENDIF.                                        "note 454133
            WHEN '121'.                                     "note 454133
*          Searches for numbers which are in XBLNR-filter   "note 454133
*          range, but doesn't check if the document exist.  "note 454133
              IF NOT TFILTER IS INITIAL.                    "note 454133
                PERFORM ANALYSE_VERWENDUNGSZWECK            "note 454133
                         USING 'XBLNR_NO_CHECK'.            "note 454133
              ENDIF.                                        "note 454133

            WHEN OTHERS.
* user algorithm according to naming convention            "hw597428
              concatenate 'Z_FIEB_' febep-intag '_ALGORITHM'
                into l_funct.
              call function 'FUNCTION_EXISTS'
                EXPORTING
                  funcname           = l_funct
                EXCEPTIONS
                  FUNCTION_NOT_EXIST = 1
                  OTHERS             = 2.
              if sy-subrc = 0.
* read country assigned to company code for user algorithm -
* see note 398160
                READ TABLE FEBCOUN WITH KEY BUKRS = FEBKO-BUKRS.
                IF SY-SUBRC <> 0.
                  SELECT SINGLE LAND1 FROM T001 INTO l_country
                        WHERE BUKRS = FEBKO-BUKRS.
                  IF SY-SUBRC <> 0.
                    MESSAGE E593 WITH FEBKO-BUKRS.
                  ENDIF.
                  FEBCOUN-BUKRS = FEBKO-BUKRS.
                  FEBCOUN-LAND  = l_country.
                  APPEND FEBCOUN.
                ENDIF.
                refresh l_avip_in.
                refresh l_avip_out.
                perform febre_to_puffer_cr tables xfebre
                                            using l_original_rsnum
                                         changing l_note_to_payee.
                LOOP AT PAT_HITS WHERE TARGFI = SPACE.
                  perform add_avip tables l_avip_in
                                   using 'MAPRES' pat_hits-mapres.
                ENDLOOP.
                perform add_avip tables l_avip_in
                                  using 'CHECT' febep-chect.
                perform add_avip tables l_avip_in
                                  using 'KIDNO' febep-kidno.
                call function l_funct
                  EXPORTING
                    I_NOTE_TO_PAYEE = l_note_to_payee
                    I_COUNTRY       = febcoun-land
                  TABLES
                    t_avip_in       = l_avip_in
                    t_avip_out      = l_avip_out
                    t_filter1       = filter
                    t_filter2       = tfilter.
                perform avip_to_xfebl tables l_avip_out.
* end of user algorithm                                    "hw597428
              else.
*         Standardalgo: Führt Suche nach BELNR bzw. XBLNR aus,
*         wenn BELNR bzw. XBLNR Range nicht initial ist.
                IF NOT FILTER IS INITIAL.
                  PERFORM ANALYSE_VERWENDUNGSZWECK USING 'BELNR'.
                ENDIF.
                IF NOT TFILTER IS INITIAL.
                  PERFORM ANALYSE_VERWENDUNGSZWECK USING 'XBLNR'.
                ENDIF.
              endif.
          ENDCASE.

          PERFORM OCMT_CURRENCY_EXPIRATION_CHECK.           "note 483920

          PERFORM BUENDEL_BILDEN.

        ENDIF.                         "DO_FI
*ziclos desaparece este IF porque los cheque no se compensan en la segunda ejecución
*      ENDIF.

      if febep-b1err = ' ' and febep-b2err = ' '.           "hw662494
        PERFORM USEREXIT USING TESTRUN.
      endif.                                                "hw662494
      if not l_badi2 is initial.                            "hw804508
        append lines of xfebcl to lt_febcl.                 "hw804508
        append lines of xfebre to lt_febre.                 "hw804508
        append febep to lt_febep.                           "hw804508
      endif.                                                "hw804508
      REFRESH XFEBRE. CLEAR XFEBRE.

*     XFEBCL endgültig speichern in FEBCL
      IF ( FEBKO-EFART = 'M'    AND
         FEBKO-ANWND = '0001' ) OR
         FEBKO-ANWND = '0002'.
        IF YFEBCL[] <> XFEBCL[].
          DELETE FEBCL FROM TABLE YFEBCL.
          PERFORM INSERT_FEBCL_FROM_XFEBCL.
        ENDIF.
      ELSE.
        PERFORM INSERT_FEBCL_FROM_XFEBCL.
      ENDIF.

      REFRESH XFEBCL. CLEAR XFEBCL.

*     Einzelposten wurde interpretiert
      if febep-b1err = 'C' or febep-b2err = 'C'             "hw662494
        or febep-b1err = '2' or febep-b2err = '2'.          "hw662494
        move 'C' to febko-kipre.                            "hw662494
      else.                                                 "hw662494
        MOVE 'X' TO FEBEP-PIPRE.
      endif.                                                "hw662494
      UPDATE FEBEP.
      IF SY-SUBRC NE 0.
        MESSAGE E760 WITH 'FEBEP'.
      ENDIF.
*   ENDSELECT.
    ENDLOOP.
*   BAdI für alle Einzelposten auf einmal                  "hw804508
    if not l_badi2 is initial and febko-kipre = ' '.
      SELECT SINGLE LAND1 FROM T001 INTO HLP_LAND
                        WHERE BUKRS = FEBKO-BUKRS.
      CALL METHOD L_BADI2->CHANGE_DATA
        EXPORTING
          FLT_VAL         = HLP_LAND
          ID_TESTRUN      = TESTRUN
          IT_FEBRE        = LT_FEBRE
          IT_FEBEP        = LT_FEBEP
          IT_FEBCL        = LT_FEBCL
        IMPORTING
          ED_SUBRC        = L_SUBRC
          ED_MSGID        = L_MSGID
          ED_MSGTY        = L_MSGTY
          ED_MSGNO        = L_MSGNO
          ED_MSGV1        = L_MSGV1
          ED_MSGV2        = L_MSGV2
          ED_MSGV3        = L_MSGV3
          ED_MSGV4        = L_MSGV4
          ET_FEBEP        = lt_changed_febep
          ET_FEBCL        = lt_changed_febcl
          ET_DELETE_FEBCL = lt_delete_febcl
        CHANGING
          CS_FEBKO        = FEBKO.

      IF L_SUBRC <> 0.
        MESSAGE ID L_MSGID TYPE L_MSGTY NUMBER L_MSGNO
                  WITH L_MSGV1 L_MSGV2 L_MSGV3 L_MSGV4.
      else.
        loop at lt_changed_febcl assigning <febcl>.
          modify febcl from <febcl>.
          if sy-subrc <> 0.
            message e760 with 'FEBCL'.
          endif.
        endloop.
        loop at lt_delete_febcl assigning <febcl>.
          delete febcl from <febcl>.
          if sy-subrc <> 0.
            message e760 with 'FEBCL'.
          endif.
        endloop.
        loop at lt_changed_febep assigning <febep>.
          update febep from <febep>.
          if sy-subrc <> 0.
            message e760 with 'FEBEP'.
          endif.
        endloop.
      ENDIF.
      refresh: lt_febep, lt_febcl, lt_febre,
               lt_changed_febep, lt_changed_febcl.
    endif.                                                  "hw804508
*   alle Einzelposten zu diesem KUKEY wurden interpretiert
    if febko-kipre <> 'C'.                                  "hw662494
      MOVE 'X' TO FEBKO-KIPRE.
    else.                                                   "hw662494
      clear febko-kipre.                                    "hw662494
    endif.                                                  "hw662494
    UPDATE FEBKO.
    IF SY-SUBRC NE 0.
      MESSAGE E760 WITH 'FEBKO'.
    ENDIF.
* ENDSELECT.
  ENDLOOP.

  FREE MEMORY ID 'FF5_INTERVALS'.                           "n907386

  COMMIT WORK.
ENDFORM.                    "EINZELPOSTEN_AUSWERTEN

*eject
*---------------------------------------------------------------*
*  FORM IDENTIFY_BUSINESS_PARTNER.                              *
*---------------------------------------------------------------*
*  Geschäftspartner identifizieren über Bankverbindung           *
*  nur dann wenn                                                *
*      - Bankverbindung angegeben                               *
*      - keine FEBCL-Daten zu diesem EP gefunden wurden         *
*---------------------------------------------------------------*
FORM IDENTIFY_BUSINESS_PARTNER.

  DATA: L_AVIK TYPE AVIK.                                   "hw485107
  DATA: L_STOP_SEARCH(1) TYPE C.
  DATA: L_SUBRC TYPE SY-SUBRC,                              "n969358
        L_TIBAN TYPE TIBAN,                                 "n969358
        LB_TECH_ACCNO TYPE C.                               "n969358

  CLEAR: AGKON, AGKOA.
  CLEAR: KNA1, KNBK.
  CLEAR: LFA1, LFBK.
  CLEAR L_AVIK.                                             "hw485107
* CHECK NOT ( febep-pablz IS INITIAL AND febep-pakto IS INITIAL )."HP31I
*  CHECK NOT FEBEP-PAKTO IS INITIAL.    "HP31I "ak060599
*  CHECK EP_CL_DATA = FALSE.           "ak060599

* - start - note 969358
  IF FEBEP-PAKTO IS INITIAL AND FEBEP-PIBAN IS NOT INITIAL.

    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        funcname = 'SEARCH_FOR_IBAN'
      EXCEPTIONS
        others   = 1.

    IF SY-SUBRC = 0.
      CALL FUNCTION 'SEARCH_FOR_IBAN'
        EXPORTING
          i_string = febep-piban
        IMPORTING
          e_tiban  = l_tiban
          e_subrc  = l_subrc.

      IF L_SUBRC = 1. "not an IBAN

        "should be impossible

      ELSEIF L_SUBRC = 2  "IBAN, but not in the system
          OR L_SUBRC = 3. "IBAN, but not unique

        "no chance to determine right account

      ELSE. "IBAN which is already in the system

        FEBEP-PABLZ = L_TIBAN-BANKL.
        FEBEP-PIBAN = L_TIBAN-IBAN.
        FEBEP-PABKS = L_TIBAN-BANKS.
        FEBEP-PAKTO = L_TIBAN-BANKN. "will be deleted if techn. acc. no.

      ENDIF.
    ENDIF.
  ENDIF.
* - end - note 969358

  IF FEBEP-VOZEI = 'C'
  OR FEBEP-VOZEI = 'RD'
  OR FEBEP-EPVOZ = 'H'.
*   Zahlungseingang. Debitor suchen.
    PERFORM IDENTIFY_CUSTOMER CHANGING L_STOP_SEARCH.       "n863132

    IF AGKON IS INITIAL AND L_STOP_SEARCH NE 'X'.           "n863132
*     Kreditor suchen / search vendor
      PERFORM IDENTIFY_VENDOR CHANGING L_STOP_SEARCH.
    ENDIF.

  ELSE.
*   Zahlungsausgang. Kreditor suchen
    PERFORM IDENTIFY_VENDOR CHANGING L_STOP_SEARCH.         "n863132

    IF AGKON IS INITIAL AND L_STOP_SEARCH NE 'X'.           "n863132
*     Debitor suchen / search customer
      PERFORM IDENTIFY_CUSTOMER CHANGING L_STOP_SEARCH.
    ENDIF.

  ENDIF.

  IF NOT AGKON IS INITIAL.                                  "hw432371
    FEBEP-AVKON = AGKON.
    L_AVIK-KONTO = FEBEP-AVKON.                             "hw485107
  ENDIF.                                                    "hw432371
  IF NOT AGKOA IS INITIAL.                                  "hw432371
    IF AGKOA CO 'DK'                                        "hw485107
    AND FEBEP-AVKOA CO 'DK'                                 "hw485107
    AND FEBEP-AVKOA <> AGKOA                                "hw485107
    AND NOT FEBEP-AVKOA IS INITIAL                          "hw485107
    AND NOT FEBEP-AVKON IS INITIAL                          "hw485107
    AND NOT FEBEP-AVSID IS INITIAL.                         "hw485107
      L_AVIK-BUKRS = FEBKO-BUKRS.                           "hw485107
      L_AVIK-KOART = FEBEP-AVKOA.                           "hw485107
      L_AVIK-AVSID = FEBEP-AVSID.                           "hw485107
      CALL FUNCTION 'REMADV_CHANGE_ACCOUNT'                 "hw485107
        EXPORTING                                           "hw485107
          I_AVIK           = L_AVIK                         "hw485107
          I_NEWKO          = FEBEP-AVKON                    "hw485107
          I_NEWKA          = AGKOA                          "hw485107
        EXCEPTIONS                                          "hw485107
          LOCKED           = 1                              "hw485107
          NO_AUTHORITY     = 2                              "hw485107
          ALREADY_EXISTING = 3                              "hw485107
          OTHERS           = 4.                             "hw485107
      IF SY-SUBRC <> 0.                                     "hw485107
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO   "hw485107
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.   "hw485107
      ENDIF.                                                "hw485107
    ENDIF.                                                  "hw485107
    FEBEP-AVKOA = AGKOA.
  ENDIF.                                                    "hw432371

* - start - note 969358
  CALL FUNCTION 'FUNCTION_EXISTS'
    EXPORTING
      funcname = 'FI_TECH_ACCNO_CHECK'
    EXCEPTIONS
      function_not_exist = 1
      others             = 2.

  IF SY-SUBRC = 0.
     CALL FUNCTION 'FI_TECH_ACCNO_CHECK'
      EXPORTING
          I_BANKN = FEBEP-PAKTO
        IMPORTING
          E_XTECH = LB_TECH_ACCNO.

    IF LB_TECH_ACCNO = 'X'. "technical account number
      CLEAR FEBEP-PAKTO.
    ENDIF.
  ENDIF.
* - end - note 969358


* WRITE: / FEBEP-KUKEY, FEBEP-ESNUM, FEBEP-AVKON, FEBEP-PABLZ,
*          FEBEP-PAKTO.
ENDFORM.                    "IDENTIFY_BUSINESS_PARTNER

*eject
*---------------------------------------------------------------*
*  FORM INSERT_FEBCL_FROM_XFEBCL.
*---------------------------------------------------------------*
FORM INSERT_FEBCL_FROM_XFEBCL.
  LOOP AT XFEBCL.
    FEBCL = XFEBCL.
    INSERT FEBCL.
    IF SY-SUBRC NE 0.
      UPDATE FEBCL.
      IF SY-SUBRC NE 0.
        MESSAGE I751 WITH 'FEBCL'.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "INSERT_FEBCL_FROM_XFEBCL

*eject
*---------------------------------------------------------------*
*  FORM USEREXIT.                                               *
*---------------------------------------------------------------*
FORM USEREXIT USING TESTRUN TYPE XFLAG.
  CLEAR: XFEBKO, XFEBEP.

*  CALL CUSTOMER-FUNCTION '001'
     call function 'EXIT_RFEBBU10_001'
      EXPORTING
          I_FEBKO    = FEBKO
          I_FEBEP    = FEBEP
          I_TESTRUN  = TESTRUN
      IMPORTING
          E_FEBKO    = XFEBKO
          E_FEBEP    = XFEBEP
          E_MSGTYP   = MSTYP
          E_MSGTEXT  = MSTXT
          E_UPDATE   = UPDATE
      TABLES
          T_FEBRE    = XFEBRE
          T_FEBCL    = XFEBCL.

  IF NOT MSTYP IS INITIAL.
    CASE MSTYP.
      WHEN 'E'.
        MESSAGE E899 WITH MSTXT.
      WHEN 'I'.
        MESSAGE I899 WITH MSTXT.
      WHEN 'S'.
        MESSAGE S899 WITH MSTXT.
      WHEN 'W'.
        MESSAGE W899 WITH MSTXT.
    ENDCASE.
  ENDIF.

  IF NOT XFEBKO IS INITIAL.
*   FEBKO updaten
    FEBKO = XFEBKO.
    UPDATE FEBKO.
    IF SY-SUBRC NE 0.
      MESSAGE S750 WITH 'FEBKO' FEBKO-ANWND FEBKO-ABSND FEBKO-AZIDT.
    ENDIF.
  ENDIF.

  IF NOT XFEBEP IS INITIAL.
*   FEBEP updaten
    FEBEP = XFEBEP.
    UPDATE FEBEP.
    IF SY-SUBRC NE 0.
      MESSAGE S750 WITH 'FEBKO' FEBKO-ANWND FEBKO-ABSND FEBKO-AZIDT.
    ENDIF.
  ENDIF.

ENDFORM.                    "USEREXIT



*eject
*---------------------------------------------------------------*
*  FORM ANALYSE_VERWENDUNGSZWECK.                               *
*---------------------------------------------------------------*
FORM ANALYSE_VERWENDUNGSZWECK USING SFNAM.
  DATA: RWBTR LIKE AVIK-RWBTR.                              "mp45B
  DATA: AVIS_WAERS LIKE AVIK-WAERS.                         "mp45B

  REFRESH TREFFER.
  CLEAR   TREFFER.

  PERFORM SPEICHER_TO_PUFFER.

* Schlüssel FEBCL initialisieren
  XFEBCL-KUKEY = FEBEP-KUKEY.
  XFEBCL-ESNUM = FEBEP-ESNUM.
* XFEBCL-CSNUM = 0.

*-------- Ausgleichsinformation suchen --------------------------------
  CASE SFNAM.
    WHEN 'BELNR'.
      PERFORM SEARCH_BELNR.
      PERFORM B-TREFFER_PROBELESEN.
    WHEN 'BELNR2'.
      PERFORM SEARCH_BELNR.
      PERFORM B2_TREFFER_PROBELESEN.
    WHEN 'XBLNR'.
      PERFORM SEARCH_XBLNR.
      PERFORM X-TREFFER_PROBELESEN.
    WHEN 'SDXBLNR'.
      perform read_sdxblnr_find_belnr.                      "hw784155
*      PERFORM SEARCH_XBLNR.                               "hw784155
*      PERFORM TRANSFORM_SD_TREFFER.                       "hw784155
*      PERFORM X-TREFFER_PROBELESEN.                       "hw784155
    WHEN 'ILIST'.
      PERFORM SEARCH_XBLNR.
      PERFORM I-TREFFER_PROBELESEN.
    WHEN 'KIDNO_T'.
      PERFORM SEARCH_KIDNO_T.
      PERFORM READ_KIDNO_HITS.
    WHEN 'KIDNO'.
      perform read_kidno_find_belnr.                        "hw597428
*      PERFORM SEARCH_KIDNO.                               "hw597428
*      PERFORM READ_KIDNO_HITS.                            "hw597428
    WHEN 'PYORD'.
      PERFORM SEARCH_PYORD.
      PERFORM PYORD_TREFFER_PROBELESEN.
    WHEN 'AVSID'.
      PERFORM SEARCH_XBLNR.
      PERFORM AVSID_TREFFER_PROBELESEN.
    WHEN 'KIDNO_TO_PYORD'.                                  "note 388705
      PERFORM SEARCH_KIDNO.                                 "note 388705
      PERFORM READ_KIDNO_FIND_PYORD.                        "note 388705
    WHEN 'BELNR_NO_CHECK'.                                  "note 454133
      PERFORM SEARCH_BELNR.                                "note 454133
      PERFORM WRITE_CLEARDATA_NO_CHECK  USING              "note 454133
              'BELNR' FEBEP-AVKOA FEBEP-AVKON.             "note 454133
    WHEN 'XBLNR_NO_CHECK'.                                  "note 454133
      PERFORM SEARCH_XBLNR.                                "note 454133
      PERFORM WRITE_CLEARDATA_NO_CHECK USING               "note 454133
              'XBLNR' FEBEP-AVKOA FEBEP-AVKON.             "note 454133
    when 'MULTI'.                                          "note 555352
      perform multi_algorithm.                             "note 555352
    when 'CLEAREDBELNR'.                                   "note 837317
      perform find_cleared_belnr.                          "note 837317
  ENDCASE.

  PERFORM CLEARDATA_TO_FEBCL.          " fill XFEBCL

  DESCRIBE TABLE XFEBCL LINES TFILL_XFEBCL.

*     Partner identifiziert, keine Ausgleichsinfo gefunden
*  IF NOT AGKON IS INITIAL AND TFILL_XFEBCL = 0.
*  IF NOT AGKON IS INITIAL.                                    "ak160500
  IF     ( NOT AGKON IS INITIAL )
     AND ( FEBEP-AVSID IS INITIAL ).                        "ak160500

    IF NOT ( FEBEP-FWAER IS INITIAL OR FEBEP-FWBTR IS INITIAL ) ."mpEURO
      RWBTR = FEBEP-FWBTR.             "mpEURO
      AVIS_WAERS = FEBEP-FWAER.        "mpEURO
    ELSE.                              "mpEURO

      RWBTR = FEBEP-KWBTR.                                  "mp45B
      AVIS_WAERS = FEBEP-KWAER.                             "mp45B

    ENDIF.                             "mpEURO

    IF FEBEP-EPVOZ = 'S'.                                   "mp45B
*   debit advices are stored with negative amounts
      MULTIPLY RWBTR BY -1.                                 "mp45B
    ENDIF.
                                                            "mp45B
    SELECT * FROM AVIK
                       WHERE BUKRS = FEBKO-BUKRS
                         AND KOART = AGKOA
                         AND KONTO = AGKON
*                        AND RWBTR = FEBEP-KWBTR                  "mp45B
                         AND RWBTR = RWBTR                  "mp45B
                         AND WAERS = AVIS_WAERS             "mp45B
                         AND AVSRT NE '02'
                         ORDER BY ERDAT.
    ENDSELECT.
    IF SY-SUBRC NE 0.
*     no advice found
      IF TFILL_XFEBCL = 0.
*       no clearing information available -> FB05 with amount
        XFEBCL-KUKEY  = FEBEP-KUKEY.
        XFEBCL-ESNUM  = FEBEP-ESNUM.
        XFEBCL-CSNUM  = 1.
        XFEBCL-KOART  = AGKOA.
        XFEBCL-AGKON  = AGKON.
        XFEBCL-SELFD  = 'WRBTR'.
        XFEBCL-SELVON = FEBEP-KWBTR.
        APPEND XFEBCL.
      ENDIF.
    ELSE.
      FEBEP-AVKOA  = AGKOA.
      FEBEP-AVKON  = AGKON.
      FEBEP-AVSID  = AVIK-AVSID.
    ENDIF.
  ENDIF.
ENDFORM.                    "ANALYSE_VERWENDUNGSZWECK

*eject
*---------------------------------------------------------------*
*  FORM SPEICHER_TO_PUFFER.                                     *
*---------------------------------------------------------------*
FORM SPEICHER_TO_PUFFER.
  CLEAR PUFFER.

*--------- fill PUFFER with delimiter  ---------------------------------
  LOOP AT SPEICHER.
    CONCATENATE PUFFER SPEICHER-ZEILE '!' INTO PUFFER.
    IF SY-SUBRC NE 0.
*     MESSAGE I764.                                         "30E
      EXIT.
    ENDIF.
  ENDLOOP.

*--------- fill PUFFER without delimiter to get doc that have been cut -
  LOOP AT SPEICHER.                                         "30E
    CONCATENATE PUFFER SPEICHER-ZEILE  INTO PUFFER.         "30E
    IF SY-SUBRC NE 0.                                       "30E
      EXIT.                                                 "30E
    ENDIF.                                                  "30E
  ENDLOOP.                                                  "30E
ENDFORM.                    "SPEICHER_TO_PUFFER


*eject
*---------------------------------------------------------------*
*  PUFFER_ZERLEGEN.                                             *
*---------------------------------------------------------------*
FORM PUFFER_ZERLEGEN.
  CALL FUNCTION 'STRING_SPLIT'
    EXPORTING
      DELIMITER = ';'
      STRING    = PUFFER
    IMPORTING
      HEAD      = HEAD
      TAIL      = PUFFER
    EXCEPTIONS
      NOT_FOUND = 1
      NOT_VALID = 2
      TOO_LONG  = 3
      TOO_SMALL = 4.

  CASE SY-SUBRC.
*       WHEN 0. WRITE: / FELD(20), '  ', STRING(40).
    WHEN 1.                                                 "note 495364
    WHEN 2.                                                 "note 495364
    WHEN 3.                                                 "note 495364
    WHEN 4.                                                 "note 495364
  ENDCASE.

ENDFORM.                    "PUFFER_ZERLEGEN

*eject
*---------------------------------------------------------------*
*  FORM DELETE_DOUBLE_TREFFER.                                  *
*---------------------------------------------------------------*
FORM DELETE_DOUBLE_TREFFER.
* lokale Variablen
  DATA: OLD-NUMMER LIKE TREFFER-NUMMER.

  SORT TREFFER.
* Doppelte Einträge loeschen
  OLD-NUMMER = SPACE.
  LOOP AT TREFFER.
    IF OLD-NUMMER = TREFFER-NUMMER.
      DELETE TREFFER.
    ENDIF.
    OLD-NUMMER = TREFFER-NUMMER.
  ENDLOOP.
ENDFORM.                    "DELETE_DOUBLE_TREFFER

*eject
*---------------------------------------------------------------*
*  FORM X-TREFFER_PROBELESEN.                                   *
*---------------------------------------------------------------*
*  Probelesen mit der Referenzbelegnummer (XBLNR)               *
*  Bei XBLNR wird auch BSEG nachgelesen, da eindeutigkeit       *
*  nicht zwingend ist. Daher wird bei XBLNR auch die           *
*  Ausgleichskontonummer mitgegeben                             *
*---------------------------------------------------------------*
FORM X-TREFFER_PROBELESEN.

  CLEAR TREFFER.

  LOOP AT TREFFER.
    SELECT * FROM BKPF WHERE BUKRS = FEBKO-BUKRS
                         AND BSTAT = ' '
                         AND XBLNR = TREFFER-NUMMER.
      SELECT * FROM BSEG WHERE BUKRS = BKPF-BUKRS
                           AND BELNR = BKPF-BELNR
                           AND GJAHR = BKPF-GJAHR
                           AND AUGBL = SPACE
                           AND ( KOART = 'D'
                              OR KOART = 'K' ).

*       CHECK BSEG-KOART = 'D' OR BSEG-KOART = 'K'.
*       gefunden: XBLNR in CLEARDATA
        IF BSEG-KOART = 'D'.
          CLEARDATA-KOART  = BSEG-KOART.
          CLEARDATA-AGKON  = BSEG-KUNNR.
          CLEARDATA-SELFD  = 'XBLNR'.
          CLEARDATA-SELVON = BKPF-XBLNR.
          APPEND CLEARDATA.
        ENDIF.
        IF BSEG-KOART = 'K'.
          CLEARDATA-KOART  = BSEG-KOART.
          CLEARDATA-AGKON  = BSEG-LIFNR.
          CLEARDATA-SELFD  = 'XBLNR'.
          CLEARDATA-SELVON = BKPF-XBLNR.
          APPEND CLEARDATA.
        ENDIF.
      ENDSELECT.
*-- ak260599: block out-commented - see note 134047
** limit selection to posting area 1 only
*      DATA: TMP_EPVOZ LIKE FEBEP-EPVOZ.
*      CLEAR TMP_EPVOZ.
*      IF FEBEP-EPVOZ = 'H'.
*        TMP_EPVOZ = 'S'.
*      ELSE.
*        TMP_EPVOZ = 'H'.
*      ENDIF.
*
*      SELECT * FROM BSEG WHERE BUKRS = BKPF-BUKRS
*                           AND BELNR = BKPF-BELNR
*                           AND GJAHR = BKPF-GJAHR
*                           AND AUGBL = SPACE
*                           AND SHKZG = TMP_EPVOZ
*                           AND KOART = 'S'.
** and debit/credit indicator is proper.
*        IF BSEG-KOART = 'S'.
*          CLEARDATA-KOART  = BSEG-KOART.
*          CLEARDATA-AGKON  = BSEG-HKONT.
*          CLEARDATA-SELFD  = 'BELNR'.  "Change to BELNR
*          CLEARDATA-SELVON = BKPF-BELNR.
*          APPEND CLEARDATA.
*        ENDIF.
*      ENDSELECT.
    ENDSELECT.
    IF SY-SUBRC NE 0.
*     Es wurden keine Daten in CLEARDATA aufgenommen
    ENDIF.
  ENDLOOP.
ENDFORM.                    "X-TREFFER_PROBELESEN

*---------------------------------------------------*
*  FORM B2_TREFFER_PROBELESEN.                      *
*---------------------------------------------------*
FORM B2_TREFFER_PROBELESEN.
  DATA: DKGEF(1) TYPE C.

  CLEAR TREFFER.
  CLEAR DKGEF.

  LOOP AT TREFFER.
    SELECT * FROM BKPF WHERE BUKRS = FEBKO-BUKRS
                         AND BELNR = TREFFER-NUMMER
                         ORDER BY GJAHR DESCENDING.
      CLEAR CLEARDATA.
      CLEARDATA-SELFD  = 'BELNR'.
      CLEARDATA-SELVON = BKPF-BELNR.
      SELECT * FROM BSEG WHERE BUKRS = BKPF-BUKRS
                           AND BELNR = BKPF-BELNR
                           AND GJAHR = BKPF-GJAHR
                           AND AUGBL = SPACE
                           AND ( KOART = 'D'
                              OR KOART = 'K' ).
*       gefunden: BELNR in CLEARDATA
        DKGEF = 'X'.
        CLEARDATA-KOART  = BSEG-KOART.
        CLEARDATA-AGKON  = BSEG-KUNNR.
        APPEND CLEARDATA.
      ENDSELECT.
      IF DKGEF IS INITIAL.
        IF CLEARDATA-KOART IS INITIAL. "no c/v in doc
          CLEARDATA-KOART  = 'S'.
          APPEND CLEARDATA.
        ENDIF.
      ENDIF.
    ENDSELECT.
  ENDLOOP.
ENDFORM.                    "B2_TREFFER_PROBELESEN

*eject
*---------------------------------------------------------------*
*  FORM B-TREFFER_PROBELESEN.                                   *
*---------------------------------------------------------------*
*  Probelesen mit der Belegnummer (BELNR)                       *
*---------------------------------------------------------------*
*   Zahlungsausgang oder Zahlungseingang mit Suche nach BELNR
FORM B-TREFFER_PROBELESEN.

  CLEAR TREFFER.

  LOOP AT TREFFER.
    SELECT * FROM BKPF WHERE BUKRS = FEBKO-BUKRS
                         AND BELNR = TREFFER-NUMMER.
    ENDSELECT.
    IF SY-SUBRC = 0.
      CLEAR CLEARDATA.
*-------- Set account type: D (cutomer) or K (vendor) from document type
*-------- If S (GL account) RFEBBU00 overwrites D or K deriving from the
*--------  posting type of customizing (trans OT59 ) -------------------
      SELECT SINGLE * FROM T003 WHERE BLART = BKPF-BLART.   "30D
      IF SY-SUBRC = 0.                                      "30D
        IF T003-KOARS CA 'D'.                               "30D
          CLEARDATA-KOART  = 'D'.                           "30D
        ELSEIF T003-KOARS CA 'K'.                           "30D
          CLEARDATA-KOART  = 'K'.                           "30D
        ELSE.                                               "30D
          CLEARDATA-KOART  = 'S'.                           "30D
        ENDIF.                                              "30D
      ELSE.                                                 "30D
        CLEARDATA-KOART  = 'D'.                             "30D
      ENDIF.                                                "30D
      CLEARDATA-SELFD  = 'BELNR'.                           "30D
      CLEARDATA-SELVON = BKPF-BELNR.                        "30D
      APPEND CLEARDATA.                                     "30D
*     IF FEBEP-VOZEI = 'C'                                     "30D
*     OR FEBEP-EPVOZ = 'H'.                                    "30D
*       Zahlungseingang -> Debitor ausziffern                  "30D
*       CLEARDATA-KOART  = 'D'.                                "30D
*       CLEARDATA-SELFD  = 'BELNR'.                            "30D
*       CLEARDATA-SELVON = BKPF-BELNR.                         "30D
*       APPEND CLEARDATA.                                      "30D
*     ELSE.                                                    "30D
*       Zahlungsausgang -> Sachkonto ausziffern                "30D
*       CLEARDATA-KOART  = 'S'.                                "30D
*       CLEARDATA-SELFD  = 'BELNR'.                            "30D
*       CLEARDATA-SELVON = BKPF-BELNR.                         "30D
*       APPEND CLEARDATA.                                      "30D
*     ENDIF.                                                   "30D
    ELSE.
*     Treffer wurde in BKPF nicht gefunden -> kein Treffer
    ENDIF.
  ENDLOOP.
ENDFORM.                    "B-TREFFER_PROBELESEN

*eject
*---------------------------------------------------------------*
*  FORM I-TREFFER_PROBELESEN.            new with 3.0F          *
*---------------------------------------------------------------*
*  Probelesen mit der Invoice List Nummer, die im Feld          *
*  Referenzbelegnummer (XBLNR) steht.                           *
*  Falls diese nicht gefunden wird, handelt es sich in der Regel*
*  um eine Teilzahlung. Hier werden die ursprünglichen Rechnungs*
*  nummern angegeben, die dann noch im Feld AWKEY drinstehen    *
*  Dann wird BELNR zum Ausgleich verwendet                      *
*  Bei XBLNR wird auch BSEG nachgelesen, da eindeutigkeit       *
*  nicht zwingend ist. Daher wird bei XBLNR auch die            *
*  Ausgleichskontonummer mitgegeben                             *
*---------------------------------------------------------------*
FORM I-TREFFER_PROBELESEN.

  CLEAR TREFFER.

  LOOP AT TREFFER.
    SELECT * FROM BKPF WHERE BUKRS = FEBKO-BUKRS
                         AND BSTAT = ' '
                         AND XBLNR = TREFFER-NUMMER.

      SELECT * FROM BSEG WHERE BUKRS = BKPF-BUKRS
                           AND BELNR = BKPF-BELNR
                           AND GJAHR = BKPF-GJAHR
                           AND AUGBL = SPACE
                           AND ( KOART = 'D'
                              OR KOART = 'K' ).

*       CHECK BSEG-KOART = 'D' OR BSEG-KOART = 'K'.
*       gefunden: XBLNR in CLEARDATA
        IF BSEG-KOART = 'D'.
          CLEARDATA-KOART  = BSEG-KOART.
          CLEARDATA-AGKON  = BSEG-KUNNR.
          CLEARDATA-SELFD  = 'XBLNR'.
          CLEARDATA-SELVON = BKPF-XBLNR.
          APPEND CLEARDATA.
        ENDIF.
        IF BSEG-KOART = 'K'.
          CLEARDATA-KOART  = BSEG-KOART.
          CLEARDATA-AGKON  = BSEG-LIFNR.
          CLEARDATA-SELFD  = 'XBLNR'.
          CLEARDATA-SELVON = BKPF-XBLNR.
          APPEND CLEARDATA.
        ENDIF.
      ENDSELECT.
    ENDSELECT.
    IF SY-SUBRC NE 0.
*-------- Teilzahlung?-----------------------------------
      SELECT * FROM BKPF WHERE BUKRS = FEBKO-BUKRS
                           AND AWTYP = 'VBRK'
                           AND AWKEY = TREFFER-NUMMER.
        SELECT * FROM BSEG WHERE BUKRS = BKPF-BUKRS
                             AND BELNR = BKPF-BELNR
                             AND GJAHR = BKPF-GJAHR
                             AND AUGBL = SPACE
                             AND ( KOART = 'D'
                                OR KOART = 'K' ).

*       CHECK BSEG-KOART = 'D' OR BSEG-KOART = 'K'.
*       gefunden: XBLNR in CLEARDATA
          IF BSEG-KOART = 'D'.
            CLEARDATA-KOART  = BSEG-KOART.
            CLEARDATA-AGKON  = BSEG-KUNNR.
            CLEARDATA-SELFD  = 'BELNR'.
            CLEARDATA-SELVON = BKPF-BELNR.
            APPEND CLEARDATA.
          ENDIF.
          IF BSEG-KOART = 'K'.
            CLEARDATA-KOART  = BSEG-KOART.
            CLEARDATA-AGKON  = BSEG-LIFNR.
            CLEARDATA-SELFD  = 'BELNR'.
            CLEARDATA-SELVON = BKPF-BELNR.
            APPEND CLEARDATA.
          ENDIF.
        ENDSELECT.
      ENDSELECT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "I-TREFFER_PROBELESEN


*eject
*---------------------------------------------------------------*
*  FORM CLEARDATA_TO_FEBCL.                                     *
*---------------------------------------------------------------*
FORM CLEARDATA_TO_FEBCL.
* lokale Variable
  DATA:  OLD-CLEARDATA LIKE CLEARDATA.

  SORT CLEARDATA.
* Doppelte Einträge loeschen
  CLEAR OLD-CLEARDATA.
  LOOP AT CLEARDATA.
    IF OLD-CLEARDATA = CLEARDATA.
      DELETE CLEARDATA.
    ENDIF.
    OLD-CLEARDATA = CLEARDATA.
  ENDLOOP.


* Daten in FEBCL moven
  LOOP AT CLEARDATA.
    XFEBCL-CSNUM  = XFEBCL-CSNUM + 1.
    XFEBCL-KOART  = CLEARDATA-KOART.
    XFEBCL-AGKON  = CLEARDATA-AGKON.
    XFEBCL-SELFD  = CLEARDATA-SELFD.
    XFEBCL-SELVON = CLEARDATA-SELVON.
    APPEND XFEBCL.
    EP_CL_DATA = TRUE.
  ENDLOOP.

  REFRESH CLEARDATA.
ENDFORM.                    "CLEARDATA_TO_FEBCL

*eject
*&---------------------------------------------------------------------*
*&      Form  SEARCH_CHECK_IN_PAYR
*&---------------------------------------------------------------------*
*       Schecknummer ungleich Belegnummer (Prenumbered Checks          *
*----------------------------------------------------------------------*
FORM SEARCH_CHECK_IN_PAYR.
* DATA:  L_BELNR LIKE BKPF-BELNR VALUE '-'.           "delete 167129
  DATA:  TPAYR-RWBTR LIKE PAYR-RWBTR.  "insert 167129
  DATA:  TFEBEP-KWBTR LIKE FEBEP-KWBTR."insert 167129

  PERFORM GET_NUMBER_CHECT_OR_1ST_FEBRE  USING CHECT.

*-- get lock for check ( will be released with 'commit work' )    209716
  CALL FUNCTION 'ENQUEUE_EFPAYR'
    EXPORTING
      ZBUKR = FEBKO-BUKRS
      HBKID = FEBKO-HBKID
      HKTID = FEBKO-HKTID
*      RZAWE = PAYR-RZAWE
      CHECT = CHECT
    EXCEPTIONS
      FOREIGN_LOCK = 8.

  IF NOT SY-SUBRC IS INITIAL.
    FEBEP-INFO1 = TEXT-015.
    REPLACE '&' WITH SY-MSGV1 INTO FEBEP-INFO1.
    FEBEP-INFO2 = TEXT-016.
    EXIT.
  ENDIF.

  SELECT * FROM PAYR WHERE ICHEC = SPACE
                     AND   ZBUKR = FEBKO-BUKRS
                     AND   HBKID = FEBKO-HBKID
                     AND   HKTID = FEBKO-HKTID
                     AND   CHECT = CHECT.
  ENDSELECT.

  IF SY-DBCNT = 1.

    TPAYR-RWBTR = ABS( PAYR-RWBTR ).   "insert 167129
    TFEBEP-KWBTR = ABS( FEBEP-KWBTR ). "insert 167129

* For prenumbered checks sy-dbcnt is ALWAYS sy-dbcnt = 1.
    IF NOT PAYR-VOIDR IS INITIAL.
*   check is voided in check register -> no posting
      FEBEP-INFO1 = TEXT-001.
*     FEBEP-INFO2 = TEXT-002.                         "delete 167129
*     FEBEP-VB1OK = 'X'.                              "delete 167129
*     FEBEP-VB2OK = 'X'.                              "delete 167129
*     FEBEP-BELNR = L_BELNR.                          "delete 167129
*     FEBEP-NBBLN = L_BELNR.                          "delete 167129
    ELSEIF NOT PAYR-XBANC IS INITIAL.
*   check has already been cashed -> no posting
      FEBEP-INFO1 = TEXT-003.
*     FEBEP-INFO2 = TEXT-002.                         "delete 167129
*     FEBEP-VB1OK = 'X'.                              "delete 167129
*     FEBEP-VB2OK = 'X'.                              "delete 167129
*     FEBEP-BELNR = L_BELNR.                          "delete 167129
*     FEBEP-NBBLN = L_BELNR.                          "delete 167129
    ELSEIF ( TPAYR-RWBTR <> TFEBEP-KWBTR ) AND
           ( PAYR-WAERS = FEBEP-KWAER ).              "insert 167129
*   check amount not match, don't mark it as cashed   "insert 167129
      FEBEP-INFO1 = TEXT-010.          "insert 167129
      FEBEP-INFO2 = PAYR-VBLNR.                             "ak050500
    ELSE.
*   check is not voided nor cashed
      SELECT SINGLE * FROM BKPF WHERE BUKRS = FEBKO-BUKRS
                                  AND BELNR = PAYR-VBLNR
                                  AND GJAHR = PAYR-GJAHR.
      IF SY-SUBRC = 0.
        PAYR-XBANC = 'X'.
        PAYR-BANCD = FEBEP-VALUT.
        UPDATE PAYR.
        FEBEP-INFO1 = TEXT-004.
        PERFORM MOVE_BELNR_TO_XFEBCL USING 'S' PAYR-GJAHR.  "hw485303
      ENDIF.
    ENDIF.
  ELSEIF SY-DBCNT GT 1.
*   check number found with several payment methods -> ERROR
    FEBEP-INFO1 = TEXT-005.
    FEBEP-INFO2 = TEXT-002.
  ELSE.
*   no check found -> no processing
    FEBEP-INFO1 = TEXT-006.
    FEBEP-INFO2 = TEXT-002.
  ENDIF.

ENDFORM.                    "SEARCH_CHECK_IN_PAYR


*eject
*&---------------------------------------------------------------------*
*&      Form  MOVE_BELNR_TO_XFEBCL
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
FORM MOVE_BELNR_TO_XFEBCL USING KOART L_GJAHR.              "hw485303
  XFEBCL-KUKEY  = FEBEP-KUKEY.
  XFEBCL-ESNUM  = FEBEP-ESNUM.
  XFEBCL-CSNUM  = 1.
  XFEBCL-KOART  = KOART.
  XFEBCL-SELFD  = 'BELNR'.
  XFEBCL-SELVON = BKPF-BELNR.
  IF NOT L_GJAHR IS INITIAL.                                "hw485303
    XFEBCL-SELVON+10(4) = L_GJAHR.                          "hw485303
  ENDIF.                                                    "hw485303
  APPEND XFEBCL.
ENDFORM.                               " MOVE_CHECK_BELNR_TO_XFEBCL

*&---------------------------------------------------------------------*
*&      Form  MOVE_DUMMY_BELNR_TO_XFEBCL
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
FORM MOVE_DUMMY_BELNR_TO_XFEBCL USING KOART.
  XFEBCL-KUKEY  = FEBEP-KUKEY.
  XFEBCL-ESNUM  = FEBEP-ESNUM.
  XFEBCL-CSNUM  = 1.
  XFEBCL-KOART  = KOART.
  XFEBCL-SELFD  = 'BELNR'.
  XFEBCL-SELVON = '*'.
  APPEND XFEBCL.
ENDFORM.                               " MOVE_CHECK_BELNR_TO_XFEBCL
*eject
*&---------------------------------------------------------------------*
*&      Form  SEARCH_CHECK_IN_BKPF
*&---------------------------------------------------------------------*
*       Schecknummer = Belegnummer                                     *
*----------------------------------------------------------------------*
FORM SEARCH_CHECK_IN_BKPF.
  DATA L_BELNR(10) TYPE N.                                  "hw357507

  PERFORM GET_NUMBER_CHECT_OR_1ST_FEBRE  USING CHECT.

  IF CHECT CO ' 0123456789'.                                "hw357507
    MOVE CHECT TO L_BELNR.                                  "hw357507
    IF CHECT = L_BELNR.                                     "hw357507
      SELECT * FROM BKPF WHERE BUKRS = FEBKO-BUKRS          "hw357507
                            AND BELNR = L_BELNR.            "hw357507
      ENDSELECT.                                            "hw357507
      IF SY-SUBRC = 0.                                      "hw357507
        PERFORM MOVE_BELNR_TO_XFEBCL USING 'S' SPACE.       "hw485303
      ENDIF.                                                "hw357507
    ELSE.                                                   "hw357507
*   ignore the check number since it is too big for BKPF    "hw357507
      MESSAGE S623.                                         "hw357507
    ENDIF.                                                  "hw357507
  ELSE.                                                     "hw357507
    SELECT * FROM BKPF WHERE BUKRS = FEBKO-BUKRS
                         AND BELNR = CHECT.
    ENDSELECT.
    IF SY-SUBRC = 0.
      PERFORM MOVE_BELNR_TO_XFEBCL USING 'S' SPACE.         "hw485303
    ENDIF.
  ENDIF.                                                    "hw357507
ENDFORM.                               " SEARCH_CHECK_IN_BKPF

*eject
*&---------------------------------------------------------------------*
*&      Form  SEARCH_BELNR_OF_PAYM_PROG
*&---------------------------------------------------------------------*
*       Diese Routine ermittelt mit der vom Zahlprogramm               *
*       vergebenen eindeutigen Referenznummer die Belege               *
*       eines Zahllaufs, damit sie auf dem Ausgangskonto               *
*       ausgeglichen werden können                                     *
*----------------------------------------------------------------------*
FORM SEARCH_BELNR_OF_PAYM_PROG.
  DATA: REFNO(10) TYPE N.

  CHECK NOT FEBEP-CHECT IS INITIAL.

  REFNO = FEBEP-CHECT.

  CHECK NOT REFNO IS INITIAL.                               "45B

  CALL FUNCTION 'GET_DOCUMENTS'
    EXPORTING
      I_BELEGE     = 'X'
      I_REFNO      = REFNO
      I_REGUT      = SPACE
    TABLES
      TAB_BELEGE   = DTA_BELEGE
    EXCEPTIONS
      NO_DOCUMENTS = 01
      NO_REGUT     = 02
      WRONG_NUMBER = 03.

  IF SY-SUBRC = 0.
    CALL FUNCTION 'SET_STATEMENT_DATA'
      EXPORTING
        I_REFNO        = FEBEP-CHECT
      EXCEPTIONS
        NO_TABLE_ENTRY = 01
        NO_UPDATE      = 02
        WRONG_NUMBER   = 03.

*    LOOP AT DTA_BELEGE.
*      IF DTA_BELEGE-PYORD IS INITIAL.
*        XFEBCL-KUKEY  = FEBEP-KUKEY.
*        XFEBCL-ESNUM  = FEBEP-ESNUM.
*        XFEBCL-CSNUM  = SY-TABIX.
*        XFEBCL-AGKON  = DTA_BELEGE-UBHKT.
*        XFEBCL-AGBUK  = DTA_BELEGE-BUKRS.
*        XFEBCL-KOART  = 'S'.
*        XFEBCL-SELFD  = 'BELNR'.
*        XFEBCL-SELVON = DTA_BELEGE-BELNR.
*      ELSE.
*        XFEBCL-KUKEY  = FEBEP-KUKEY.
*        XFEBCL-ESNUM  = FEBEP-ESNUM.
*        XFEBCL-CSNUM  = SY-TABIX.
*        CLEAR: XFEBCL-AGKON.
*        XFEBCL-AGBUK  = DTA_BELEGE-BUKRS.
*        XFEBCL-KOART  = 'S'.
*        XFEBCL-SELFD  = 'PYORD'.
*        XFEBCL-SELVON = DTA_BELEGE-PYORD.
*      ENDIF.
*      APPEND XFEBCL.
*    ENDLOOP.

    XFEBCL-KUKEY  = FEBEP-KUKEY.                           "note 206022
    XFEBCL-ESNUM  = FEBEP-ESNUM.                           "note 206022
    XFEBCL-CSNUM  = 1.                                     "note 206022
    XFEBCL-SELFD  = 'REFNO'.                               "note 206022
    XFEBCL-SELVON = REFNO.                                 "note 206022
    APPEND XFEBCL.                                         "note 206022

  ENDIF.
ENDFORM.                               " SEARCH_BELNR_OF_PAYM_PROG

*eject
*&---------------------------------------------------------------------*
*&      Form  GET_CHECK_NUMBER
*&---------------------------------------------------------------------*
*       Da die Schecknummer nicht immer im Feld FEBEP-CHECT steht,     *
*       wird sie aus der ersten Verwendungszeckzeile geholt, falls     *
*       FEBEP-CHECT leer ist                                           *
*----------------------------------------------------------------------*
*  <--  CHECKNUM  Schecknummer
*----------------------------------------------------------------------*
FORM GET_NUMBER_CHECT_OR_1ST_FEBRE  USING CHECKNUM.
  IF NOT FEBEP-CHECT IS INITIAL.
    CHECKNUM = FEBEP-CHECT.
  ELSE.
    LOOP AT XFEBRE WHERE KUKEY = FEBEP-KUKEY
                     AND ESNUM = FEBEP-ESNUM
                     AND RSNUM = 1.
      CLEAR PUFFER.
      PUFFER = XFEBRE-VWEZW.
*      TRANSLATE PUFFER TO UPPER CASE.                          "46C
      PERFORM DTA_TEXT_AUFBEREITEN USING PUFFER.            "46C
      TRANSLATE PUFFER USING CONVERT1.
      TRANSLATE PUFFER USING CONVERT2.
      CONDENSE PUFFER NO-GAPS.
      CHECKNUM = PUFFER.
      EXIT.
    ENDLOOP.
  ENDIF.
ENDFORM.                               " GET_CHECK_NUMBER

*eject
*&---------------------------------------------------------------------*
*&      Form  GERMAN_BZUE_WITH_BELNR.
*&---------------------------------------------------------------------*
*       Über das deutsche BZÜ-Verfahren kommt eine 13stellige          *
*       prüfzifferngesicherte Nummer zurück.                           *
*       Die Nummer steht entweder in FEBEP-CHECT oder ist die erste    *
*       Nummer im Verwendungszweck FEBRE-VWEZW                         *
*       Diese Routine erwartet eine Belegnummer der Form               *
*       00nnnnnnnnnP, wobei P = Prüfziffer                             *
*----------------------------------------------------------------------*
FORM GERMAN_BZUE_WITH_BELNR.
  CLEAR CHECT.
  PERFORM GET_NUMBER_CHECT_OR_1ST_FEBRE  USING CHECT.
  CHECT+12(1) = SPACE.
  SHIFT CHECT LEFT BY 2 PLACES.

*  SELECT SINGLE * FROM BKPF WHERE BUKRS = FEBKO-BUKRS         "ak051199
  SELECT * FROM BKPF WHERE BUKRS = FEBKO-BUKRS              "ak051199
                       AND BELNR = CHECT.                   "ak051199
*                              AND BELNR = PAYR-VBLNR          "ak051199
*                              AND GJAHR = PAYR-GJAHR.         "ak051199
  ENDSELECT.                                                "ak051199
  IF SY-SUBRC = 0.
*-- Set account type: D (cutomer) or K (vendor) from document type
*-- If S (GL account) RFEBBU00 overwrites D or K deriving from the
*-- posting type of customizing (trans OT59 )                   ak051199
    SELECT SINGLE * FROM T003 WHERE BLART = BKPF-BLART.
    IF SY-SUBRC = 0.
      IF T003-KOARS CA 'D'.
        PERFORM MOVE_BELNR_TO_XFEBCL USING 'D' SPACE.       "hw485303
      ELSEIF T003-KOARS CA 'K'.
        PERFORM MOVE_BELNR_TO_XFEBCL USING 'K' SPACE.       "hw485303
      ELSE.
        PERFORM MOVE_BELNR_TO_XFEBCL USING 'S' SPACE.       "hw485303
      ENDIF.
    ELSE.
      PERFORM MOVE_BELNR_TO_XFEBCL USING 'D' SPACE.         "hw485303
    ENDIF.
  ENDIF.

ENDFORM.                               " GERMAN_BZUE



*eject
*&---------------------------------------------------------------------*
*&      Form  GERMAN_BZUE_WITH_XBLNR.
*&---------------------------------------------------------------------*
*       Über das deutsche BZÜ-Verfahren kommt eine 13stellige          *
*       prüfzifferngesicherte Nummer zurück.                           *
*       Die Nummer steht entweder in FEBEP-CHECT oder ist die erste    *
*       Nummer im Verwendungszweck FEBRE-VWEZW                         *
*       Diese Routine erwartet eine Belegnummer der Form               *
*       nnnnnnnnnnnP, wobei P = Prüfziffer                             *
*       Leseversuch auf BKPF mit und Ohne Prüfziffer                   *
*----------------------------------------------------------------------*
FORM GERMAN_BZUE_WITH_XBLNR.
  CLEAR CHECT.
  PERFORM GET_NUMBER_CHECT_OR_1ST_FEBRE  USING CHECT.

  SELECT * FROM BKPF WHERE BUKRS = FEBKO-BUKRS
                       AND XBLNR = CHECT.
  ENDSELECT.
  IF SY-DBCNT NE 1.
    CHECT+12(1) = SPACE.
    SELECT * FROM BKPF WHERE BUKRS = FEBKO-BUKRS
                         AND XBLNR = CHECT.
    ENDSELECT.
  ENDIF.
  IF SY-DBCNT = 1.
    PERFORM MOVE_BELNR_TO_XFEBCL USING 'S' SPACE.           "hw485303
  ENDIF.

ENDFORM.                               " GERMAN_BZUE

*eject
*&---------------------------------------------------------------------*
*&      Form  BUENDEL_BILDEN
*&---------------------------------------------------------------------*
*       Je nach BDART wird FEBEP-GRPNR für die Bündelung gefüllt       *
*----------------------------------------------------------------------*
FORM BUENDEL_BILDEN.
  DATA: QUOT LIKE  FEBPDO-BDANZ.
  DATA: ESNUM LIKE  FEBEP-ESNUM.

  CASE BDART.
    WHEN SPACE.
    WHEN '1'.
*     Bündel je Buchhaltungssachbearbeiter.
      IF  AGKOA = 'D'
      AND NOT AGKON IS INITIAL.
        SELECT SINGLE * FROM KNB1 WHERE KUNNR = AGKON
                                    AND BUKRS = FEBKO-BUKRS.
        IF SY-SUBRC = 0.
          FEBEP-BUSAB = KNB1-BUSAB.
          FEBEP-GRPNR = KNB1-BUSAB.
        ENDIF.
      ENDIF.
      IF  AGKOA = 'K'
      AND NOT AGKON IS INITIAL.
        SELECT SINGLE * FROM LFB1 WHERE LIFNR = AGKON
                                    AND BUKRS = FEBKO-BUKRS.
        IF SY-SUBRC = 0.
          FEBEP-BUSAB = LFB1-BUSAB.
          FEBEP-GRPNR = LFB1-BUSAB.
        ENDIF.
      ENDIF.
    WHEN '2'.
*     Bündel je n Posten
      ESNUM       = FEBEP-ESNUM - 1.
      QUOT        = ESNUM DIV  BDANZ.
      FEBEP-GRPNR = QUOT+2(2).
  ENDCASE.
ENDFORM.                               " BUENDEL_BILDEN


*---------------------------------------------------------------------*
*       FORM SEARCH_NR                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  SELFD                                                         *
*---------------------------------------------------------------------*
FORM SEARCH_NR2 USING SELFD.
  DATA: NUM10(10) TYPE N.

*  TRANSLATE PUFFER TO UPPER CASE.                                "46C
  PERFORM DTA_TEXT_AUFBEREITEN USING PUFFER.                "46C
  TRANSLATE PUFFER USING CONVERT1.
  TRANSLATE PUFFER USING CONVERT2.
  CONDENSE PUFFER.
  TRANSLATE PUFFER USING CONVERT3.

  REFRESH TREFFER.

  DO.
    PERFORM PUFFER_ZERLEGEN.
    IF HEAD = SPACE OR SY-SUBRC NE 0.
      EXIT.
    ENDIF.
    CASE SELFD.
      WHEN 'BELNR'.
        IF HEAD CO ' 0123456789' AND HEAD IN FILTER.
          NUM10 = HEAD.                "   Führende Nullen
          TREFFER-NUMMER = NUM10.
          APPEND TREFFER.
        ENDIF.
      WHEN 'XBLNR'.
        IF HEAD IN FILTER.
          TREFFER-NUMMER = HEAD.
          APPEND TREFFER.
        ENDIF.
    ENDCASE.
  ENDDO.

  PERFORM DELETE_DOUBLE_TREFFER.

ENDFORM.                                                    "SEARCH_NR2

*---------------------------------------------------------------------*
*       FORM SEARCH_BELNR                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM SEARCH_BELNR.
*  TRANSLATE PUFFER TO UPPER CASE.                                "46C
  PERFORM DTA_TEXT_AUFBEREITEN USING PUFFER.                "46C
  TRANSLATE PUFFER USING CONVERT1.
  TRANSLATE PUFFER USING CONVERT2.
  CONDENSE PUFFER.
  TRANSLATE PUFFER USING CONVERT3.
  REFRESH TREFFER.
  DO.
    PERFORM PUFFER_ZERLEGEN.
    IF HEAD = SPACE OR SY-SUBRC NE 0.
      EXIT.
    ENDIF.
    IF HEAD CO ' 0123456789'.
      NUM10 = HEAD.                    "   Führende Nullen
      IF NUM10 IN FILTER.
        TREFFER-NUMMER = NUM10.
        APPEND TREFFER.
      ENDIF.
    ENDIF.
  ENDDO.

  PERFORM DELETE_DOUBLE_TREFFER.

ENDFORM.                    "SEARCH_BELNR

*---------------------------------------------------------------------*
*       FORM SEARCH_XBLNR                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM SEARCH_XBLNR.
  DATA: PUFFER2(910)     TYPE C.

*  TRANSLATE PUFFER TO UPPER CASE.                                "46C
  PERFORM DTA_TEXT_AUFBEREITEN USING PUFFER.                "46C
  TRANSLATE PUFFER USING CONVERT2.
  CONDENSE PUFFER.
  PUFFER2 = PUFFER.
  TRANSLATE PUFFER USING CONVERT3.
  REFRESH TREFFER.


*  Mögliche XBLNR AUS DEM PUFFER IN TREFFER ABSPEICHERN
  PERFORM IS_PUFFER_IN_TFILTER.

  PUFFER = PUFFER2.
  TRANSLATE PUFFER USING CONVERT1.
  CONDENSE PUFFER.
  TRANSLATE PUFFER USING CONVERT3.

*  Mögliche XBLNRS AUS DEM PUFFER IN TREFFER ABSPEICHERN
  PERFORM IS_PUFFER_IN_TFILTER.

  PERFORM DELETE_DOUBLE_TREFFER.

ENDFORM.                    "SEARCH_XBLNR

*---------------------------------------------------------------------*
*       FORM IS_PUFFER_IN_TFILTER                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM IS_PUFFER_IN_TFILTER.

  DO.
    PERFORM PUFFER_ZERLEGEN.
    IF HEAD = SPACE OR SY-SUBRC NE 0.
      EXIT.
    ENDIF.
    CHR16 = HEAD.
    SHIFT CHR16 RIGHT DELETING TRAILING ' '.
    IF CHR16 IN TFILTER.
      SHIFT CHR16 LEFT DELETING LEADING ' '.
      TREFFER-NUMMER = CHR16.
      APPEND TREFFER.
    ENDIF.
  ENDDO.

ENDFORM.                    "IS_PUFFER_IN_TFILTER
*&---------------------------------------------------------------------*
*&      Form  TRANSFORM_TREFFER
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM TRANSFORM_SD_TREFFER.
*****************************voided************************hw784155
*
*  DATA: LEN TYPE I.
*
*  DATA: NUM10(10) TYPE N.
*
*  LOOP AT TREFFER.
*
*    IF TREFFER-NUMMER CO ' 0123456789'.
*      LEN = STRLEN( TREFFER-NUMMER ).
*      IF LEN <= 10.
*        NUM10 = TREFFER-NUMMER.
*        TREFFER-NUMMER = NUM10.
*        MODIFY TREFFER.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*
*ENDFORM.                               " TRANSFORM_TREFFER
*&---------------------------------------------------------------------*
*&      Form  SEARCH_COBRANCA
*&---------------------------------------------------------------------*
*       Interpretation algorithm as used in Brazil for A/P
*----------------------------------------------------------------------*
FORM SEARCH_COBRANCA.

  CALL FUNCTION 'J_1B_SEARCH_ITEM_EM_COBRANCA'
    EXPORTING
      I_FEBKO = FEBKO
      I_FEBEP = FEBEP
    TABLES
      T_FEBCL = XFEBCL
    EXCEPTIONS
      OTHERS  = 1.             "#EC FB_PAR_MIS

ENDFORM.                               " SEARCH_COBRANCA
*----------------------------------------------------------------------*
*       Form  SEARCH_KIDNO_T
*----------------------------------------------------------------------*
*       kidno-search for tito-format
*----------------------------------------------------------------------*
FORM SEARCH_KIDNO_T.
  DATA: RC LIKE SY-SUBRC,
        HLP_VWEZW LIKE FEBRE-VWEZW,
        HLP_KIDNO LIKE FEBEP-KIDNO.

  CLEAR: KIDNO_TAB.
  REFRESH: KIDNO_TAB.

*-- use febep-kidno if available.

  IF FEBEP-KIDNO CO ' 0123456789' AND NOT FEBEP-KIDNO IS INITIAL.
    PERFORM CHECK_KIDNO USING FEBEP-KIDNO RC.
  ELSE.
    RC = 1.
  ENDIF.

  IF RC EQ 0.
*-- correct reference number in febep-kidno found: leading zeros and
*-- spaces (if any) have been removed in form 'check_kidno'
    KIDNO_TAB-NUMMER = FEBEP-KIDNO.
    APPEND KIDNO_TAB.
  ELSE.
*-- Search Xfebre for kidnos
    LOOP AT XFEBRE.
      CLEAR: HLP_VWEZW, HLP_KIDNO.
*-- only numerical entries in xfebre are checked
      IF XFEBRE-VWEZW CO ' 0123456789' AND XFEBRE-VWEZW <> SPACE.
        HLP_VWEZW = XFEBRE-VWEZW.
*-- field VWEZW is longer than KIDNO: shift contents left first
        SHIFT HLP_VWEZW LEFT DELETING LEADING SPACE.
*-- TITO-format doesn't deliver more than 20 digits: don't care here
*-- since form 'check_kidno' will check length for us later
        HLP_KIDNO = HLP_VWEZW.
*-- take only first number if string contains more than one number
*-- (separated by ' '): necessary since 'check_kidno' doesn't handle
*-- this properly (numbers are concatenated)
        SEARCH HLP_KIDNO FOR '. .'.
        IF SY-SUBRC = 0.
          HLP_KIDNO = HLP_KIDNO+0(SY-FDPOS).
        ENDIF.
        PERFORM CHECK_KIDNO USING HLP_KIDNO RC.
        IF RC = 0.
*-- correct reference number in febre-vwezw found
          KIDNO_TAB-NUMMER = HLP_KIDNO.
          APPEND KIDNO_TAB.
        ENDIF.
      ENDIF.
    ENDLOOP.                           "AT XFEBRE
  ENDIF.

  PERFORM DELETE_DOUBLE_KIDNOS.

ENDFORM.                               " SEARCH_KIDNO_T
*&---------------------------------------------------------------------*
*&      Form  CHECK_KIDNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FEBEP_KIDNO  text                                          *
FORM CHECK_KIDNO USING KIDNO RC.

  CALL FUNCTION 'COMPUTE_CHECKNUM_FI_001'
    EXPORTING
      I_CHECK_CORRECT    = 'X'
    CHANGING
      C_VALUE            = KIDNO
    EXCEPTIONS
      NUMBER_TOO_LONG    = 1
      NUMBER_TOO_SHORT   = 2
      NUMBER_NOT_CORRECT = 3
      OTHERS             = 4.

  RC = SY-SUBRC.

ENDFORM.                               " CHECK_KIDNO
*&---------------------------------------------------------------------*
*&      Form  DELETE_DOUBLE_KIDNOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_DOUBLE_KIDNOS.
* lokale Variablen
  DATA: OLD_NUMMER LIKE KIDNO_TAB-NUMMER.
  CLEAR: OLD_NUMMER.
  SORT KIDNO_TAB.
* Doppelte Einträge loeschen
  LOOP AT KIDNO_TAB.
    IF OLD_NUMMER = KIDNO_TAB-NUMMER.
      DELETE KIDNO_TAB.
    ENDIF.
    OLD_NUMMER = KIDNO_TAB-NUMMER.
  ENDLOOP.
ENDFORM.                               " DELETE_DOUBLE_KIDNOS

*----------------------------------------------------------------------*
*      Form  READ_KIDNO_HITS
*----------------------------------------------------------------------*
*      search BSID / BSIK: KIDNO must be stored there WITHOUT leading  *
*      zeros and LEFT JUSTIFIED                                        *
*----------------------------------------------------------------------*
FORM READ_KIDNO_HITS.
*******inserted according to note 206380************mo110700**********
  DATA: DBTABLE TYPE CHAR45,
  MAXLENGTH TYPE  INT2,
  CHARKEY TYPE  CHAR45,
  KEYNAME TYPE  CHAR45,
  s_bsik type standard table of bsik,                       "hw583577
  s_bsid type standard table of bsid,                       "hw583577
  h_bsik type bsik,                                         "hw583577
  h_bsid type bsid,                                         "hw583577
  EXCEPTION TYPE SY-SUBRC.

  FIELD-SYMBOLS: <RESULTSTRING> TYPE ANY.             "UC

  CLEAR: KIDNO_TAB, S_BSID, S_BSIK.

  LOOP AT KIDNO_TAB.
    DBTABLE = 'BSID'.
    ASSIGN S_BSID TO <RESULTSTRING>.                  "UC
    MAXLENGTH = 10.                "can be 20 according to TITO,
*                                  "but VBRK-KIDNOs are always 10 digits
    CHARKEY = KIDNO_TAB-NUMMER.
    KEYNAME = 'KIDNO'.

    PERFORM SEARCH_WITH_LEADING_ZEROES USING
    DBTABLE
    MAXLENGTH
    CHARKEY
    KEYNAME
    <RESULTSTRING>                                    "UC
    EXCEPTION.

    IF EXCEPTION = 0.

      loop at s_bsid into h_bsid.                           "hw583577

        cleardata-koart = 'D'.
        CLEARDATA-AGKON  = h_bsid-kunnr.                    "hw583577
        CLEARDATA-SELFD  = 'BELNR'.
        CLEARDATA-SELVON = h_bsid-belnr.                    "hw583577
        cleardata-selvon+10(4) = h_bsid-gjahr.              "hw485303
        APPEND CLEARDATA.

      endloop.                                              "hw583577

    ELSE.                "No debtors found. Search for creditors.

      DBTABLE = 'BSIK'.
      ASSIGN S_BSIK TO <RESULTSTRING>.                "UC

      PERFORM SEARCH_WITH_LEADING_ZEROES USING
      DBTABLE
      MAXLENGTH
      CHARKEY
      KEYNAME
      <RESULTSTRING>
      EXCEPTION.

      IF EXCEPTION = 0.

        loop at s_bsik into h_bsik.                         "hw583577

          CLEARDATA-KOART  = 'K'.
          CLEARDATA-AGKON  = h_bsik-lifnr.                  "hw583577
          CLEARDATA-SELFD  = 'BELNR'.
          CLEARDATA-SELVON = h_bsik-belnr.                  "hw583577
          cleardata-selvon+10(4) = h_bsik-gjahr.            "hw485303
          APPEND CLEARDATA.

        endloop.                                            "hw583577

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                               " READ_KIDNO_HITS

*---------------------------------------------------------------------*
*       FORM SEARCH_WITH_LEADING_ZEROES                               *
*       ........                                                      *
*                                                                     *
*    >  DBTABLE                                                       *
*    >  MAXLENGTH                                                     *
*    >  CHARKEY                                                       *
*    >  KEYNAME                                                       *
*    >  STRING                                                        *
*---------------------------------------------------------------------*

FORM SEARCH_WITH_LEADING_ZEROES USING
DBTABLE TYPE  CHAR45
MAXLENGTH TYPE  INT2
CHARKEY TYPE  CHAR45
KEYNAME TYPE  CHAR45
RESULTSTRING
EXCEPTION TYPE SY-SUBRC.


  DATA RESULT TYPE CHAR2048.                                "note 458054
  DATA: CONDTAB(72) OCCURS 10 WITH HEADER LINE.
  DATA I TYPE INT2.
  DATA LENGTH TYPE INT2.
  DATA MAXZEROES TYPE INT2.
  DATA HELPKEY LIKE CHARKEY.

  FIELD-SYMBOLS:  <H_RESULT> TYPE ANY,                         "UC
                  <resultstring> type standard table.       "hw583577

  I = 0.
  EXCEPTION = 0.
  REFRESH CONDTAB.
  CLEAR CONDTAB.
  CLEAR RESULT.
  CLEAR LENGTH.

  ASSIGN RESULT TO <H_RESULT> CASTING TYPE (DBTABLE).          "UC
  ASSIGN RESULTSTRING TO <RESULTSTRING>.                       "UC
  IF MAXLENGTH > 45.
    EXCEPTION = 1.                     "TOO_LONG_KEY.
    EXIT.
  ENDIF.
  refresh <resultstring>.                                   "hw597428

* search for the unmodified value

  CONCATENATE KEYNAME ' = ' ' ''' CHARKEY '''' INTO CONDTAB.
  APPEND CONDTAB.

  SELECT * FROM (DBTABLE) INTO <H_RESULT> WHERE (CONDTAB).     "UC

    IF SY-SUBRC = 0.
      append <h_result> to <resultstring>.                  "hw583577
    ENDIF.

  ENDSELECT.                                                   "UC

  IF NOT <RESULTSTRING> IS INITIAL.                            "UC
    EXIT.
  ENDIF.

* search for the maximum number of leading zeroes
* first, determine the length of the number
* passed to the routine

  LENGTH    = STRLEN( CHARKEY ).
  MAXZEROES = MAXLENGTH - LENGTH.

  IF MAXZEROES GT 0.

    HELPKEY = CHARKEY.
    SHIFT HELPKEY RIGHT BY MAXZEROES PLACES.
    HELPKEY(MAXZEROES) = '00000000000000000000'.
    REFRESH CONDTAB.
    CONCATENATE KEYNAME ' = ' ' ''' HELPKEY '''' INTO CONDTAB.
    APPEND CONDTAB.

    SELECT * FROM (DBTABLE) INTO <H_RESULT> WHERE (CONDTAB).     "UC

      IF SY-SUBRC = 0.
        append <h_result> to <resultstring>.                "hw583577
      ENDIF.

    ENDSELECT.                                                    "UC

  ENDIF.

  IF NOT <RESULTSTRING> IS INITIAL.                               "UC
    EXIT.
  ENDIF.


* The search for a number of leading zeroes in between
* has been deleted for better performance. Use function module
* SEARCH_WITH_LEADING_ZEROES for this possibility

  EXCEPTION = 4.                       "NOTHING FOUND

ENDFORM.                    "SEARCH_WITH_LEADING_ZEROES


**********end of insertion***************************mo110700********

*&---------------------------------------------------------------------*
*&      Form  SEARCH_TREASURY
*&---------------------------------------------------------------------*
FORM SEARCH_TREASURY.

  CALL FUNCTION 'ANALYSE_VW'                                "#EC EXISTS
    EXPORTING
      I_FEBEP   = FEBEP
      I_FEBKO   = FEBKO
    IMPORTING
      E_FEBEP   = XFEBEP
      E_FEBKO   = XFEBKO
      E_MSGTEXT = MSTXT
      E_MSGTYP  = MSTYP
      E_UPDATE  = UPDATE
    TABLES
      T_FEBCL   = XFEBCL
      T_FEBRE   = XFEBRE
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                               " SEARCH_TREASURY
*&---------------------------------------------------------------------*
*&      Form  SEARCH_IMMO
*&---------------------------------------------------------------------*
FORM SEARCH_IMMO.

  CALL FUNCTION 'ANALYSE_VW_RE'
    EXPORTING
      I_FEBEP   = FEBEP
      I_FEBKO   = FEBKO
    IMPORTING
      E_FEBEP   = XFEBEP
      E_FEBKO   = XFEBKO
      E_MSGTEXT = MSTXT
      E_MSGTYP  = MSTYP
      E_UPDATE  = UPDATE
    TABLES
      T_FEBCL   = XFEBCL
      T_FEBRE   = XFEBRE
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                               " SEARCH_IMMO

*&---------------------------------------------------------------------*
*&      Form  SEARCH_KIDNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEARCH_KIDNO.

  DATA: HLP_KIDNO LIKE FEBEP-KIDNO,
        HLP_LAND  LIKE T001-LAND1.     " get countr of com. code

*  TRANSLATE PUFFER TO UPPER CASE.                               "46C
  PERFORM DTA_TEXT_AUFBEREITEN USING PUFFER.                "46C
* delete all letters
  TRANSLATE PUFFER USING CONVERT1.
*   read country of company code from internal table        "note398160
*   otherwise from database.                                "note398160
  READ TABLE FEBCOUN WITH KEY BUKRS = FEBKO-BUKRS.          "note398160
  IF SY-SUBRC <> 0.                                         "note398160
    SELECT SINGLE LAND1 FROM T001 INTO HLP_LAND             "note398160
                        WHERE BUKRS = FEBKO-BUKRS.          "note398160
    IF SY-SUBRC <> 0. MESSAGE E593 WITH FEBKO-BUKRS. ENDIF. "note398160
    FEBCOUN-BUKRS = FEBKO-BUKRS.                            "note398160
    FEBCOUN-LAND  = HLP_LAND.                               "note398160
    APPEND FEBCOUN.                                         "note398160
  ENDIF.                                                    "note398160
  if febcoun-land = 'NO'.                                   "note398160
    TRANSLATE PUFFER USING CONVERT2_norway.                 "note398160
  else.                                                     "note398160
    TRANSLATE PUFFER USING CONVERT2.
  endif.                                                    "note398160
  CONDENSE PUFFER.
* all numbers are now 102 2456  ....
  TRANSLATE PUFFER USING CONVERT3.
*-- use table kidno_tab since field treffer-nummer only 16 chars long
  CLEAR: KIDNO_TAB.
  REFRESH: KIDNO_TAB.
  DO.
    PERFORM PUFFER_ZERLEGEN.
    IF HEAD = SPACE OR SY-SUBRC NE 0.
      EXIT. "puffer finished here: bail out loop
    ENDIF.
    IF HEAD CO ' 0123456789'  or                           "note 398160
      ( febcoun-land = 'NO' and HEAD CO ' 0123456789-' ).  "note 398160
      HLP_KIDNO = HEAD.
*   check KIDNO country specific
      CALL FUNCTION 'FI_PAYREF_CHECK'
        EXPORTING
          I_KIDNO       = HLP_KIDNO
          I_LAND1       = FEBCOUN-LAND
        EXCEPTIONS
          KIDNO_INVALID = 1.
      RC = SY-SUBRC.
      IF RC = 0.
        KIDNO_TAB-NUMMER = HLP_KIDNO.
        APPEND KIDNO_TAB.
      ENDIF.
    ENDIF.
  ENDDO.

  PERFORM DELETE_DOUBLE_KIDNOS.


ENDFORM.                               " SEARCH_KIDNO

*&---------------------------------------------------------------------*
*&      Form  SEARCH_PYORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEARCH_PYORD.
  DATA: L1 TYPE I.

*  TRANSLATE PUFFER TO UPPER CASE.                              "46C
  PERFORM DTA_TEXT_AUFBEREITEN USING PUFFER.                "46C
* delete all letters
  TRANSLATE PUFFER USING CONVERT1.
* delete all special signs (.%:...
  TRANSLATE PUFFER USING CONVERT2.
  CONDENSE PUFFER.
* all numbers are now 102 2456  ....
  TRANSLATE PUFFER USING CONVERT3.
  REFRESH TREFFER.
  DO.
    PERFORM PUFFER_ZERLEGEN.
    IF HEAD = SPACE OR SY-SUBRC NE 0.
      EXIT.
    ENDIF.
    CHECK HEAD CO ' 0123456789'.
    L1 = STRLEN( HEAD ).
    IF L1 GT 10.
      continue.                                             "note 559709
    ENDIF.

    PERFORM CHECK_FOR_PYORD.

  ENDDO.

ENDFORM.                               " SEARCH_PYORD

*&---------------------------------------------------------------------*
*&      Form  CHECK_FOR_PYORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_FOR_PYORD.
  DATA: L2 TYPE I, L3 TYPE I.
  DATA: CHAR16(16) TYPE C.
  DATA: NUMC10(10) TYPE N.

  SHIFT HEAD LEFT DELETING LEADING SPACE.
*   shift head left deleting leading '0'.
  L2 = STRLEN( HEAD ).
  L3 = 10 - L2.
  SHIFT HEAD RIGHT BY L3 PLACES.
  NUMC10 = HEAD.
  CONCATENATE 'ZR' NUMC10 INTO CHAR16.
  CONDENSE CHAR16 NO-GAPS.
  SHIFT CHAR16 RIGHT DELETING TRAILING SPACE.
  IF CHAR16 IN TFILTER.
    TREFFER-NUMMER = NUMC10.
    APPEND TREFFER.
  ENDIF.

ENDFORM.                               " CHECK_FOR_PYORD

*&---------------------------------------------------------------------*
*&      Form  PYORD_TREFFER_PROBELESEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PYORD_TREFFER_PROBELESEN.
  LOOP AT TREFFER.
    SELECT SINGLE * FROM PYORDH WHERE PYORD = TREFFER-NUMMER.
    IF SY-SUBRC = 0.
      IF NOT PYORDH-LIFNR IS INITIAL.
        CLEARDATA-KOART  = 'K'.
        CLEARDATA-AGKON  = PYORDH-LIFNR.
        CLEARDATA-SELFD  = 'PYORD'.
        CLEARDATA-SELVON = PYORDH-PYORD.
        APPEND CLEARDATA.
      ELSE.
        CLEARDATA-KOART  = 'D'.
        CLEARDATA-AGKON  = PYORDH-KUNNR.
        CLEARDATA-SELFD  = 'PYORD'.
        CLEARDATA-SELVON = PYORDH-PYORD.
        APPEND CLEARDATA.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM.                               " PYORD_TREFFER_PROBELESEN
*&---------------------------------------------------------------------*
*&      Form  FILL_ALLOCATION_SELECTION
*&---------------------------------------------------------------------*
*       new with 4.0C
*----------------------------------------------------------------------*
FORM FILL_ALLOCATION_SELECTION.

  CLEAR CHECT.
  PERFORM GET_NUMBER_CHECT_OR_1ST_FEBRE  USING CHECT.
  IF NOT ( CHECT IS INITIAL OR CHECT CO '0 ' ).
    IF FEBEP-AVKOA EQ 'D' OR FEBEP-AVKOA EQ 'K'.
      XFEBCL-KUKEY  = FEBEP-KUKEY.
      XFEBCL-ESNUM  = FEBEP-ESNUM.
      XFEBCL-CSNUM  = 1.
      XFEBCL-KOART  = FEBEP-AVKOA.
      XFEBCL-AGKON  = FEBEP-AVKON.
      XFEBCL-SELFD  = 'ZUONR'.
      XFEBCL-SELVON = CHECT.
      APPEND XFEBCL.
      FEBEP-ZUONR = CHECT.      "This is better than the automatic no
    ELSE.
      XFEBCL-KUKEY  = FEBEP-KUKEY.
      XFEBCL-ESNUM  = FEBEP-ESNUM.
      XFEBCL-CSNUM  = 1.
      XFEBCL-KOART  = 'S'.
      XFEBCL-SELFD  = 'ZUONR'.
      XFEBCL-SELVON = CHECT.
      APPEND XFEBCL.
      FEBEP-ZUONR = CHECT.      "This is better than the automatic no.
    ENDIF.
  ENDIF.

ENDFORM.                               " FILL_ALLOCATION_SELECTION
*&---------------------------------------------------------------------*
*&      Form  OPEN_FI_CALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DO_FI
*      -->P_APPL_ERROR
*----------------------------------------------------------------------*
FORM OPEN_FI_CALL USING TESTRUN TYPE XFLAG.


  CALL FUNCTION 'FEB_OPEN_FI_CALL_1'
    EXPORTING
      I_FEBKO   = FEBKO
      I_FEBEP   = FEBEP
      I_TESTRUN = TESTRUN
    IMPORTING
      E_FEBKO   = FEBKO
      E_FEBEP   = FEBEP
    TABLES
      T_FEBCL   = XFEBCL
      T_FEBRE   = XFEBRE.

ENDFORM.                               " OPEN_FI_CALL
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_PROCESS_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TEXT  text
*----------------------------------------------------------------------*
FORM DISPLAY_PROCESS_STATUS USING    P_TEXT.

  IF SY-BATCH NE 'X'.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        TEXT = P_TEXT.

  ENDIF.

ENDFORM.                               " DISPLAY_PROCESS_STATUS

*&---------------------------------------------------------------------*
*&      Form  FIND_ADVICE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FEBEP_CHECT  text
*      -->P_FEBKO_BUKRS  text
*      -->P_FEBKO_HKONT  text
*      -->P_FEBEP_AVKON  text
*      -->P_FEBEP_AVKOA  text
*      -->P_FEBEP_AVSID  text
*----------------------------------------------------------------------*
FORM FIND_ADVICE USING    P_CHECT
                          P_BUKRS
                          P_HKONT
                          P_AVKON
                          P_AVKOA
*                         P_AVSID.                      "<DELETE 140613
                          P_AVSID      "<INSERT 140613
                          P_UNDEFINED. "<INSERT 140613

  DATA: BEGIN OF I_AVIK OCCURS 1.
          INCLUDE STRUCTURE AVIK.
  DATA: END OF I_AVIK.
  DATA: I_AVIK_LINES TYPE I.
  DATA: I_AVIK_LINES_2 TYPE I.         "<INSERT 140613
  DATA: AVIS_WAERS LIKE AVIK-WAERS,
        AVIS_RWBTR LIKE AVIK-RWBTR.
  DATA: I_NUMBER TYPE I.               "<INSERT 140613
  DATA: CHAR30(30) TYPE C.             "<INSERT 140613
  DATA: CHAR4(4).                      "<INSERT 140613

* SELECT ALL POTENTIAL EDI ADVICES - MULTIPLE ENTRIES POSSIBLE
  SELECT * INTO TABLE I_AVIK FROM AVIK
         WHERE  BUKRS      = P_BUKRS
         AND    VGREF      = P_CHECT
         AND    PAKTO      = P_HKONT.

  IF SY-SUBRC = 0.
*  delete advices with account and account type
    LOOP AT I_AVIK WHERE KONTO IS INITIAL
                      OR KOART IS INITIAL.
      DELETE I_AVIK.
    ENDLOOP.

    LOOP AT I_AVIK.
*      IF I_AVIK-AVSID+0(2) EQ '05' OR                   "<DELETE 140613
*         I_AVIK-AVSID+0(2) EQ '06' OR                   "<DELETE 140613
*         I_AVIK-AVSID+0(2) EQ '07'.                     "<DELETE 140613
*         ONLY EDI ADVICES ARE ALLOWED                   "<DELETE 140613
*         IF ( NOT ( FEBEP-FWAER IS INITIAL OR           "<DELETE 140613
*                    FEBEP-FWBTR IS INITIAL ) ) AND      "<DELETE 140613
*                    I_AVIK-AVSID+0(2) NE '06'.          "<DELETE 140613

      IF I_AVIK-AVSID+0(2) EQ '06'.    "<INSERT 140613
*     ONLY EDI REMADV (CREDIT OR DEBIT) ADVICES ALLOWED  "<INSERT 140613
        IF  NOT ( FEBEP-FWAER IS INITIAL OR              "<INSERT 140613
                  FEBEP-FWBTR IS INITIAL ).              "<INSERT 140613
*       OCMT IN STATEMENT PROVIDED -> SEARCH ADVICE WITH OCMT
          AVIS_WAERS = FEBEP-FWAER.
          AVIS_RWBTR = FEBEP-FWBTR.
        ELSE.
*       NO OCMT PROVIDED -> ALL POSTINGS IN RFEBBU00 IN KWAER
          AVIS_WAERS = FEBEP-KWAER.
          AVIS_RWBTR = FEBEP-KWBTR.
        ENDIF.

        IF FEBEP-EPVOZ = 'S'.
*         DEBIT ADVICE ALWAYS WITH NEGATIVE AMOUNT IN DATA BASE
          MULTIPLY AVIS_RWBTR BY -1.
        ENDIF.

        IF I_AVIK-RWBTR NE AVIS_RWBTR OR
           I_AVIK-WAERS NE AVIS_WAERS.
          DELETE I_AVIK.
        ENDIF.
      ELSE.
        DELETE I_AVIK.
      ENDIF.
    ENDLOOP.
    DESCRIBE TABLE I_AVIK LINES I_AVIK_LINES.
    CASE I_AVIK_LINES.
      WHEN 0.
*      no valid hit
        EXIT.
      WHEN 1.
*      one advice found
        P_AVKOA = I_AVIK-KOART.
        P_AVKON = I_AVIK-KONTO.
        P_AVSID = I_AVIK-AVSID.
      WHEN OTHERS.
*      several valid advices found - take latest         "<DELETE 140613
*          SORT I_AVIK BY ERDAT ASCENDING.               "<DELETE 140613
*          READ TABLE I_AVIK INDEX 1.                    "<DELETE 140613
*          P_AVKOA = I_AVIK-KOART.                       "<DELETE 140613
*          P_AVKON = I_AVIK-KONTO.                       "<DELETE 140613
*          P_AVSID = I_AVIK-AVSID.                       "<DELETE 140613

*<<<<<<<<<< BEGIN OF INSERTION - note 140613 >>>>>>>>>>>>>>>>>>>>>>>>>*
*       several valid advices found - determine partner number
        PERFORM GET_NUMBER_PARTNER TABLES I_AVIK
                                   USING I_NUMBER.
        CASE I_NUMBER.
          WHEN 1.
*           all of one business partner -> take oldest
            SORT I_AVIK BY ERDAT ASCENDING.
            READ TABLE I_AVIK INDEX 1.
            P_AVKOA = I_AVIK-KOART.
            P_AVKON = I_AVIK-KONTO.
            P_AVSID = I_AVIK-AVSID.
          WHEN OTHERS.
*               several business partners involved
*               -> use agkon to determine right partner
            IF NOT AGKON IS INITIAL.
              LOOP AT I_AVIK WHERE KONTO NE AGKON
                               AND KOART NE AGKOA.
                DELETE I_AVIK.
              ENDLOOP.
              DESCRIBE TABLE I_AVIK LINES I_AVIK_LINES_2.
              IF I_AVIK_LINES_2 = 0.
*               no partner of advice not equal business partner
*               give notice and quit
                MOVE I_AVIK_LINES TO CHAR4.
                CONCATENATE  CHAR4 TEXT-008 INTO CHAR30.
                CONDENSE CHAR30.
                FEBEP-INFO1 = CHAR30.
                CLEAR CHAR30.
                CHAR30 = TEXT-009.
                FEBEP-INFO2 = CHAR30.
                P_UNDEFINED = 'X'.
              ELSEIF I_AVIK_LINES_2 = 1.
*               one advice identified via business partner
                READ TABLE I_AVIK INDEX 1.
                P_AVKOA = I_AVIK-KOART.
                P_AVKON = I_AVIK-KONTO.
                P_AVSID = I_AVIK-AVSID.
              ELSEIF I_AVIK_LINES_2 GE 1.
*               several advices identified via business partner
*               take oldest
                SORT I_AVIK BY ERDAT ASCENDING.
                READ TABLE I_AVIK INDEX 1.
                P_AVKOA = I_AVIK-KOART.
                P_AVKON = I_AVIK-KONTO.
                P_AVSID = I_AVIK-AVSID.
              ENDIF.
            ELSE.
*              several advices of different partner found
*              agkon not available -> give notice and quit
              MOVE I_AVIK_LINES TO CHAR4.
              CONCATENATE  CHAR4 TEXT-008 INTO CHAR30.
              CONDENSE CHAR30.
              FEBEP-INFO1 = CHAR30.
              CLEAR CHAR30.
              CHAR30 = TEXT-009.
              FEBEP-INFO2 = CHAR30.
              P_UNDEFINED = 'X'.
            ENDIF.
        ENDCASE.

*<<<<<<<<<< END OF INSERTION - note 140613 >>>>>>>>>>>>>>>>>>>>>>>>>*

    ENDCASE.

  ENDIF.



ENDFORM.                               " FIND_ADVICE
*&---------------------------------------------------------------------*
*&      Form  get_number_partner
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_NUMBER  text
*----------------------------------------------------------------------*

*<<<<<<<<<< Insert the follwing at end of RFEBBU10 >>>>>>>>>>>>>>>>>>>*
*<<<<<<<<<< BEGIN OF INSERTION - note 140613 >>>>>>>>>>>>>>>>>>>>>>>>>*

FORM GET_NUMBER_PARTNER TABLES I_AVIK
                        USING    P_I_NUMBER.

  DATA: BEGIN OF ITAB OCCURS 1.
          INCLUDE STRUCTURE AVIK.
  DATA: END OF ITAB.

  DATA: OLD_KOART LIKE AVIK-KOART,
        OLD_KONTO LIKE AVIK-KONTO.

* transfer data to internal work space
  ITAB[] = I_AVIK[].
* sort data
  SORT ITAB BY BUKRS KOART KONTO.
* find number of partners
  LOOP AT ITAB.
    IF OLD_KOART NE ITAB-KOART OR
       OLD_KONTO NE ITAB-KONTO.
      P_I_NUMBER = P_I_NUMBER + 1.
      OLD_KOART = ITAB-KOART.
      OLD_KONTO = ITAB-KONTO.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " get_number_partner

*<<<<<<<<<< END OF INSERTION - note 140613 >>>>>>>>>>>>>>>>>>>>>>>>>*
*&---------------------------------------------------------------------*
*&      Form  DTA_TEXT_AUFBEREITEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CHAR512  text
FORM DTA_TEXT_AUFBEREITEN USING PUFFER.

  CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
    EXPORTING
      INTEXT  = PUFFER
    IMPORTING
      OUTTEXT = PUFFER
    EXCEPTIONS
      OTHERS  = 01.
  IF SY-SUBRC <> 0.

  ENDIF.

  TRANSLATE PUFFER TO UPPER CASE.


ENDFORM.                               " DTA_TEXT_AUFBEREITEN
*----------------------------------------------------------------------*
* Form  AVSID_TREFFER_PROBELESEN                                       *
*----------------------------------------------------------------------*
FORM AVSID_TREFFER_PROBELESEN.

  DATA:
    XAVIK   LIKE AVIK OCCURS 0 WITH HEADER LINE,
    YAVIK   LIKE AVIK OCCURS 0 WITH HEADER LINE,
    NX      TYPE I,
    NY      TYPE I.

  CLEAR YAVIK[].
  LOOP AT TREFFER.
    SELECT * APPENDING TABLE YAVIK FROM AVIK
             WHERE AVSID = TREFFER-NUMMER.
  ENDLOOP.
  DESCRIBE TABLE YAVIK LINES NY.
*-- check if anything selected at all
  CHECK NY <> 0.
  NX = NY.
  XAVIK[] = YAVIK[].
  IF NY > 1.
*-- not unambiguous
    IF NOT FEBEP-AVKOA IS INITIAL.
*-- more than one advice selected - try to reduce number of hits
      DELETE YAVIK WHERE KOART <> FEBEP-AVKOA.
      DESCRIBE TABLE YAVIK LINES NY.
      IF NY > 0.
        XAVIK[] = YAVIK[].
        NX = NY.
      ELSE.
*-- too many deletions - return to original selection
        YAVIK[] = XAVIK[].
        NY = NX.
      ENDIF.
    ENDIF.
    IF NY > 1 AND NOT FEBEP-AVKON IS INITIAL.
*-- more than one advice selected - try to reduce number of hits
      DELETE YAVIK WHERE KONTO <> FEBEP-AVKON.
      DESCRIBE TABLE YAVIK LINES NY.
      IF NY > 0.
        XAVIK[] = YAVIK[].
        NX = NY.
      ELSE.
*-- too many deletions - return to original selection
        YAVIK[] = XAVIK[].
        NY = NX.
      ENDIF.
    ENDIF.
    IF NY > 1.
*-- still more than one advice selected - try to reduce number of hits
      DELETE YAVIK WHERE BUKRS <> FEBKO-BUKRS.
      DESCRIBE TABLE YAVIK LINES NY.
      IF NY > 0.
        XAVIK[] = YAVIK[].
        NX = NY.
      ELSE.
*-- too many deletions - return to original selection
        YAVIK[] = XAVIK[].
        NY = NX.
      ENDIF.
    ENDIF.
  ENDIF.
*-- if still more than one - take most recent advice
  SORT XAVIK BY ERDAT ASCENDING.
  READ TABLE XAVIK INDEX 1.
  FEBEP-AVSID = XAVIK-AVSID.
  IF FEBKO-BUKRS = XAVIK-BUKRS.
    FEBEP-AVKON = XAVIK-KONTO.
    FEBEP-AVKOA = XAVIK-KOART.
  ELSE.
    LOOP AT XFEBCL WHERE KUKEY = FEBEP-KUKEY
                   AND   ESNUM = FEBEP-ESNUM.
    ENDLOOP.
    XFEBCL-CSNUM = SY-TABIX.
    CLEAR: FEBEP-AVKON, FEBEP-AVKOA, XFEBCL-SELVON, XFEBCL-SELFD,
           XFEBCL-AGUMS, XFEBCL-XFIFO, XFEBCL-SELBIS.
    XFEBCL-KUKEY = FEBEP-KUKEY.
    XFEBCL-ESNUM = FEBEP-ESNUM.
    XFEBCL-AGKON = XAVIK-KONTO.
    XFEBCL-KOART = XAVIK-KOART.
    XFEBCL-AGBUK = XAVIK-BUKRS.
    APPEND XFEBCL.
  ENDIF.

ENDFORM.                               "AVSID_TREFFER_PROBELESEN

*&---------------------------------------------------------------------*
*&      Form  READ_KIDNO_FIND_PYORD
*&---------------------------------------------------------------------*
*       -> note 388705
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_KIDNO_FIND_PYORD.

  DATA: DBTABLE TYPE CHAR45,
  MAXLENGTH TYPE  INT2,
  CHARKEY TYPE  CHAR45,
  KEYNAME TYPE  CHAR45,
  s_bsik type standard table of bsik,                       "hw583577
  s_bsid type standard table of bsid,                       "hw583577
  h_bsik type bsik,                                         "hw583577
  h_bsid type bsid,                                         "hw583577
  EXCEPTION TYPE SY-SUBRC.

  FIELD-SYMBOLS: <RESULTSTRING> TYPE ANY.             "UC

  CLEAR: KIDNO_TAB, S_BSID, S_BSIK.

  LOOP AT KIDNO_TAB.
    DBTABLE = 'BSID'.
    ASSIGN S_BSID TO <RESULTSTRING>.                  "UC
    MAXLENGTH = 10.
    CHARKEY = KIDNO_TAB-NUMMER.
    KEYNAME = 'KIDNO'.

    PERFORM SEARCH_WITH_LEADING_ZEROES USING
    DBTABLE
    MAXLENGTH
    CHARKEY
    KEYNAME
    <RESULTSTRING>                                    "UC
    EXCEPTION.

    IF EXCEPTION = 0.

      loop at s_bsid into h_bsid.                           "hw583577

        select * from pyordp
                 where  bukrs  = h_bsid-bukrs               "hw583577
                 and    belnr  = h_bsid-belnr               "hw583577
                 and    gjahr  = h_bsid-gjahr               "hw583577
                 and    buzei  = h_bsid-buzei.              "hw583577
          select single * from pyordh where pyord = pyordp-pyord.
          if sy-subrc = 0.
            cleardata-koart  = 'D'.
            cleardata-agkon  = pyordh-kunnr.
            cleardata-selfd  = 'PYORD'.
            cleardata-selvon = pyordh-pyord.
            append cleardata.
          endif.
        endselect.

      endloop.                                              "hw583577

    ELSE.                "No debtors found. Search for creditors.

      DBTABLE = 'BSIK'.
      ASSIGN S_BSIK TO <RESULTSTRING>.                "UC
      PERFORM SEARCH_WITH_LEADING_ZEROES USING
      DBTABLE
      MAXLENGTH
      CHARKEY
      KEYNAME
      <RESULTSTRING>                                    "UC
      EXCEPTION.

      IF EXCEPTION = 0.

*      move resultstring to s_bsid.                   "UC

        loop at s_bsik into h_bsik.                         "hw583577

          select * from pyordp
                 where  bukrs  = h_bsik-bukrs               "hw583577
                 and    belnr  = h_bsik-belnr               "hw583577
                 and    gjahr  = h_bsik-gjahr               "hw583577
                 and    buzei  = h_bsik-buzei.              "hw583577

            select single * from pyordh where pyord = pyordp-pyord.
            if sy-subrc = 0.
              cleardata-koart  = 'K'.
              cleardata-agkon  = pyordh-lifnr.
              cleardata-selfd  = 'PYORD'.
              cleardata-selvon = pyordh-pyord.
              append cleardata.
            endif.
          endselect.

        endloop.                                            "hw583577

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " READ_KIDNO_FIND_PYORD

*&---------------------------------------------------------------------*
*&      Form  WRITE_CLEARDATA_NO_CHECK                      "note 454133
*&---------------------------------------------------------------------*

FORM WRITE_CLEARDATA_NO_CHECK                               "note 454133
           USING SELECTION_FIELD LIKE FEBCL-SELFD
                 ACCOUNT_TYPE    LIKE FEBCL-KOART
                 ACCOUNT         LIKE FEBEP-AVKON.

  if account_type is initial.
    account_type = 'D'.
  endif.
  CLEAR TREFFER.
  LOOP AT TREFFER.
    CLEARDATA-KOART  = ACCOUNT_TYPE.
    CLEARDATA-AGKON  = ACCOUNT.
    CLEARDATA-SELFD  = SELECTION_FIELD.
    CLEARDATA-SELVON = TREFFER-NUMMER.
    APPEND CLEARDATA.
  ENDLOOP.

ENDFORM.                    " WRITE_CLEARDATA_NO_CHECK      "note 454133

*&---------------------------------------------------------------------*
*&      Form  OCMT_CURRENCY_EXPIRATION_CHECK                "note 483920
*&
*&      if the OCMT-currency febep-fwaer is expired clear
*&      the OCMT-currency febep-fwaer and the OCMT-amount febep-fwbtr
*&---------------------------------------------------------------------*

FORM OCMT_CURRENCY_EXPIRATION_CHECK .                       "note 483920

  DATA: L_CHECKDATE LIKE SY-DATUM.

  IF NOT ( FEBEP-FWAER IS INITIAL OR FEBEP-FWBTR IS INITIAL ).
    IF FEBEP-BUDAT IS INITIAL.
      L_CHECKDATE = SY-DATUM.
    ELSE.
      L_CHECKDATE = FEBEP-BUDAT.
    ENDIF.
    CALL FUNCTION 'CURRENCY_EXPIRATION_CHECK'
      EXPORTING
        CURRENCY         = FEBEP-FWAER
        DATE             = L_CHECKDATE
        OBJECT           = 'BKPF'
        BUKRS            = FEBKO-BUKRS
      EXCEPTIONS
        WARNING_OCCURRED = 1
        ERROR_OCCURRED   = 2
        OTHERS           = 3.
    IF SY-SUBRC = 2.
      CLEAR: FEBEP-FWBTR, FEBEP-FWAER.
    ENDIF.
  ENDIF.
ENDFORM.               " OCMT_CURRENCY_EXPIRATION_CHECK     "note 483920

*---------------------------------------------------------------------*
*       FORM multi_algorithm                               "note 555352
* here we interprete references that are structured like:
* <tag_name1>value1</tag_name1> <tag_name2>value2</tag_name2>..
* the tag_name says which information the value string can contain:
* it can be different kinds of numbers in each value string, e.g. tag
* <BX> means that there can be document numbers (Belnr) AND Reference
* Document Numbers (XBlnr) in the value string.
* 'B' means it can contain Document number's (Belnr)
* 'X' means it can contain Reference Doc. number's (Xblnr)
* 'K' means it can contain Customers Payment Reference Number's (Kidno)
* 'P' means it can contain Payment Order Number's (Pyord)
* 'R' means it can contain Ref. Numbers of payment files (regut-Renum)
*---------------------------------------------------------------------*

form multi_algorithm.                                      "note 555352
  data: l_refs type string,
        begin of lt_hits occurs 20,
          value type string,
          tag_name type string,
        end of lt_hits,
        l_hit like line of lt_hits,
        l_xfound type c,
        l_save_febep_chect type febep-chect,
        l_xfebcl like xfebcl,
        l_xfebcl_csnum like xfebcl-csnum,
        l_xfebcl_index type sy-tabix.

  l_refs = puffer.
  clear puffer.
  do.
    clear l_xfound.
    perform get_next_hit changing l_refs
                                  l_hit-value
                                  l_hit-tag_name
                                  l_xfound.

    if l_xfound = 'X'.
      collect l_hit into lt_hits.
    else.
      exit.
    endif.
  enddo.

* 'B' means it can contain Document number's (Belnr)
  clear: treffer, treffer[], puffer.
  loop at lt_hits into l_hit
      where tag_name ca 'B'.
    concatenate puffer l_hit-value into puffer separated by SPACE.
  endloop.
  if sy-subrc = 0.
    perform search_belnr.
    perform b-treffer_probelesen.
  endif.

* 'X' means it can contain Reference Doc. number's (Xblnr)
  clear: treffer, treffer[], puffer.
  loop at lt_hits into l_hit
      where tag_name ca 'X'.
    concatenate puffer l_hit-value into puffer separated by SPACE.
  endloop.
  if sy-subrc = 0.
    perform search_xblnr.
    perform x-treffer_probelesen.
  endif.

* 'K' means it can contain Customers Payment Reference Number's (Kidno)
  clear: kidno_tab, kidno_tab[], puffer.
  loop at lt_hits into l_hit
      where tag_name ca 'K'.
    concatenate puffer l_hit-value into puffer separated by SPACE.
  endloop.
  if sy-subrc = 0.
    perform search_kidno.
    perform read_kidno_hits.
  endif.

* 'P' means it can contain Payment Order Number's (Pyord)
  clear: treffer, treffer[], puffer.
  loop at lt_hits into l_hit
      where tag_name ca 'P'.
    concatenate puffer l_hit-value into puffer separated by SPACE.
  endloop.
  if sy-subrc = 0.
    perform search_pyord.
    perform pyord_treffer_probelesen.
  endif.

* 'R' means it can contain Ref. Numbers of payment files (regut-Renum)
  l_save_febep_chect = febep-chect.
  l_xfebcl_csnum  = 1.
  loop at lt_hits into l_hit
      where tag_name ca 'R'.
    clear: l_xfebcl, l_xfebcl_index.
    febep-chect = l_hit-value.
    perform search_belnr_of_paym_prog.
    read table xfebcl with key csnum = 1 into l_xfebcl.
    if sy-subrc = 0.
      l_xfebcl_index = sy-tabix.
      l_xfebcl_csnum  = l_xfebcl_csnum  + 1.
      l_xfebcl-csnum = l_xfebcl_csnum.
      modify xfebcl from l_xfebcl index l_xfebcl_index.
    endif.
  endloop.
  if l_xfebcl_csnum > 1.
    loop at xfebcl into l_xfebcl.
      l_xfebcl-csnum = l_xfebcl-csnum - 1.
      modify xfebcl from l_xfebcl.
    endloop.
  endif.
  febep-chect = l_save_febep_chect.
endform.              "  multi_algorithm                  "note 555352

*---------------------------------------------------------------------*
* form get_next_hit                                         "note 555352
* searches in c_string (e.g. c_string = <K>1234</K><P>5678</P>)
* for the first 'taged value' (here <K>1234</K>) and puts out:
*  - the name of the tag c_tag_name (here K)
*  - the value c_value  (here 1234)
*  - c_xfound is 'X', if it has found a taged value
*  - it deletes in c_string the taged value (here it will be
*    c_string = <P>5678</P>)
*---------------------------------------------------------------------*

form get_next_hit changing                                 "note 555352
                       c_string type string
                       c_value type string
                       c_tag_name type string
                       c_xfound type c.

  data:l_name_start type i,
       l_name_length type i,
       l_value_start type i,
       l_value_length type i,
       l_start type i,
       l_delete_start type i,
       l_delete_end type i.

  l_start = 1.
  do.
    clear: l_name_start,
           l_name_length,
           l_value_start,
           l_value_length,
           l_delete_start,
           l_delete_end,
           c_value,
           c_tag_name.

*   search for begin-tag <..>.
    search c_string for '<' starting at l_start.
    if sy-subrc <> '0'.
*     there is no begin-tag at all -> exit
      exit.
    endif.
    l_name_start = l_start + sy-fdpos.
    l_start = l_name_start + 1.
    l_delete_start = l_name_start - 1.
    search c_string for '>' starting at l_name_start.
    if sy-subrc <> '0'.
      continue.
    endif.
    l_name_length = sy-fdpos - 1.
    l_value_start = l_name_start + l_name_length + 1.
    if l_name_start >= 0 and l_name_length > 0.
      c_tag_name = c_string+l_name_start(l_name_length).
    else.
      continue.
    endif.

*   search now for end-tag </..>
    clear: l_name_length,
           l_name_start.
    search c_string for '</' starting at l_value_start.
    if sy-subrc <> '0'.
      continue.
    endif.
    l_name_start = l_value_start + sy-fdpos + 1.
    l_value_length = sy-fdpos - 1.
    search c_string for '>' starting at l_name_start.
    if sy-subrc <> '0'.
      continue.
    endif.
    l_name_length = sy-fdpos - 1.
    l_delete_end = l_name_start + l_name_length + 1.
    if l_name_start >= 0 and l_name_length > 0.
      if c_string+l_name_start(l_name_length) <> c_tag_name.
*       end-tag is different from begin-tag!
        continue.
      else.
        if l_value_start >= 0 and l_value_length > 0.
          c_value = c_string+l_value_start(l_value_length).
*         delete the taged value from c_string
          concatenate c_string(l_delete_start)
                      c_string+l_delete_end into c_string.
          c_xfound = 'X'.
          exit.
        else.
          continue.
        endif.
      endif.
    else.
      continue.
    endif.
  enddo.

endform.                               " get_next_hit       "note 55535
*&---------------------------------------------------------------------*
*&      Form  avip_to_ftclear
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_AVIP  table of clearing information
*----------------------------------------------------------------------*
form avip_to_cleardata  tables  p_avip.
  field-symbols: <avip> type avip.
  loop at p_avip assigning <avip>.
    cleardata-koart = <avip>-koart.
    cleardata-agkon = <avip>-konto.
    cleardata-selfd = <avip>-sfeld.
    cleardata-selvon = <avip>-swert.
    append cleardata.
  endloop.
endform.                    " avip_to_ftclear
*&---------------------------------------------------------------------*
*&      Form  read_kidno_find_belnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form read_kidno_find_belnr .
  data: l_note_to_payee type string,
        l_avip_in type standard table of avip,
        l_avip_out type standard table of avip,
        hlp_land like t001-land1.

  READ TABLE FEBCOUN WITH KEY BUKRS = FEBKO-BUKRS.          "note 398160
  IF SY-SUBRC <> 0.                                         "note 398160
    SELECT SINGLE LAND1 FROM T001 INTO HLP_LAND             "note 398160
                        WHERE BUKRS = FEBKO-BUKRS.          "note 398160
    IF SY-SUBRC <> 0. MESSAGE E593 WITH FEBKO-BUKRS. ENDIF. "note 398160
    FEBCOUN-BUKRS = FEBKO-BUKRS.                            "note 398160
    FEBCOUN-LAND  = HLP_LAND.                               "note 398160
    APPEND FEBCOUN.                                         "note 398160
  ENDIF.                                                    "note 398160
  l_note_to_payee = puffer.
  refresh l_avip_in.
  refresh l_avip_out.
  call function 'FIEB_028_ALGORITHM'
    EXPORTING
      i_note_to_payee = l_note_to_payee
      i_country       = febcoun-land
    TABLES
      t_avip_in       = l_avip_in
      t_avip_out      = l_avip_out.
  perform avip_to_cleardata tables l_avip_out.


endform.                    " read_kidno_find_belnr

*&---------------------------------------------------------------------*
*&      Form  avip_to_xfebl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_AVIP  text
*----------------------------------------------------------------------*
form avip_to_xfebl tables p_avip.

  data: l_counter type i.
  field-symbols: <avip> type avip.

  describe table xfebcl lines l_counter.
  xfebcl-kukey = febep-kukey.
  xfebcl-esnum = febep-esnum.
  loop at p_avip assigning <avip>.
    l_counter = l_counter + 1.
    xfebcl-csnum = l_counter.
    if not <avip>-abwbu is initial and <avip>-abwbu <> <avip>-bukrs.
      xfebcl-agbuk = <avip>-abwbu.
    else.
      xfebcl-agbuk = <avip>-bukrs.
    endif.
    if not <avip>-abwka is initial and <avip>-abwka <> <avip>-koart.
      xfebcl-koart = <avip>-abwka.
    else.
      xfebcl-koart = <avip>-koart.
    endif.
    if not <avip>-abwko is initial and <avip>-abwko <> <avip>-konto.
      xfebcl-agkon = <avip>-abwko.
    else.
      xfebcl-agkon = <avip>-konto.
    endif.
    xfebcl-selfd = <avip>-sfeld.
    xfebcl-selvon = <avip>-swert.
    append xfebcl.
  endloop.
endform.                    " avip_to_xfebl

*&---------------------------------------------------------------------*
*&      Form  febre_to_puffer_cr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FEBRE          text
*      -->P_END_LINE       text
*      -->P_NOTE_TO_PAYEE  text
*----------------------------------------------------------------------*
form febre_to_puffer_cr tables p_febre
                     using p_end_line
                     changing p_note_to_payee.
  field-symbols: <febre> type febre.
  clear p_note_to_payee.
  LOOP AT p_febre assigning <febre> to p_end_line.
    CONCATENATE p_note_to_payee <febre>-vwezw
      cl_abap_char_utilities=>cr_lf
      INTO p_note_to_payee.
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "SPEICHER_TO_PUFFER_CR
*&---------------------------------------------------------------------*
*&      Form  add_avip
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
form add_avip  tables   p_avip
               using    p_name
                        p_value.

  data: h_avip type avip.

  check not p_value is initial.
  check not p_name is initial.

  h_avip-sfeld = p_name.
  h_avip-swert = p_value.
  append h_avip to p_avip.

endform.                    " add_avip


*&---------------------------------------------------------------------*
*&      Form  set_global_var
*&---------------------------------------------------------------------*
FORM set_global_var using p_febko  type febko
                          p_febep  type febep
                          p_agkoa  type febcl-koart
                          p_agkon  type febcl-agkon.

  febko = p_febko.
  febep = p_febep.
  agkoa = p_agkoa.
  agkon = p_agkon.

ENDFORM.                    " set_global_var
*&---------------------------------------------------------------------*
*&      Form  read_sdxblnr_find_belnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form read_sdxblnr_find_belnr.

  data: l_note_to_payee type string,
        h_avip type avip,
        l_avip_in type standard table of avip,
        l_avip_out type standard table of avip.

  l_note_to_payee = puffer.
  refresh l_avip_in.
  refresh l_avip_out.
  h_avip-bukrs = febko-bukrs.
  append h_avip to l_avip_in.
  call function 'FIEB_026_ALGORITHM'
    EXPORTING
      i_note_to_payee = l_note_to_payee
      i_country       = febcoun-land
    TABLES
      t_avip_in       = l_avip_in
      t_avip_out      = l_avip_out
      t_filter2       = tfilter.
  perform avip_to_cleardata tables l_avip_out.


endform.                    " read_sdxblnr_find_belnr

*&---------------------------------------------------------------------*
*&      Form  read_xblnr_find_belnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form read_xblnr_find_belnr.

  data: l_note_to_payee type string,
        h_avip type avip,
        l_avip_in type standard table of avip,
        l_avip_out type standard table of avip.

  l_note_to_payee = puffer.
  refresh l_avip_in.
  refresh l_avip_out.
  h_avip-bukrs = febko-bukrs.
  append h_avip to l_avip_in.
  call function 'FIEB_021_ALGORITHM'
    EXPORTING
      i_note_to_payee = l_note_to_payee
      i_country       = febcoun-land
    TABLES
      t_avip_in       = l_avip_in
      t_avip_out      = l_avip_out
      t_filter2       = tfilter.
  perform avip_to_cleardata tables l_avip_out.


endform.                    " read_xblnr_find_belnr


*&---------------------------------------------------------------------*
*&      Form  find_cleared_belnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form find_cleared_belnr.

  data: l_note_to_payee type string,
        h_avip type avip,
        l_avip_in type standard table of avip,
        l_avip_out type standard table of avip.

  l_note_to_payee = puffer.
  refresh l_avip_in.
  refresh l_avip_out.
  h_avip-bukrs = febko-bukrs.
  append h_avip to l_avip_in.
  call function 'FIEB_060_ALGORITHM'
    EXPORTING
      i_note_to_payee = l_note_to_payee
      i_country       = febcoun-land
    TABLES
      t_avip_in       = l_avip_in
      t_avip_out      = l_avip_out
      t_filter1       = filter.
  perform avip_to_cleardata tables l_avip_out.
endform.                    " find_cleared_belnr


*&---------------------------------------------------------------------*
*&      Form  set_global_rkukey
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KUKEY    text
*----------------------------------------------------------------------*
form set_global_rkukey using p_kukey type standard table.

  field-symbols: <fs> type any.

  loop at p_kukey ASSIGNING <fs>.
    move-corresponding <fs> to r_kukey.
    append r_kukey.
  endloop.

endform.                    "set_global_rkukey

*&---------------------------------------------------------------------*
*&      Form  set_global_filter
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FILTER   text
*      -->P_TFILTER  text
*----------------------------------------------------------------------*
form set_global_filter using p_filter type standard table
                             p_tfilter type standard table.

  field-symbols: <fs> type any.

  loop at p_filter ASSIGNING <fs>.
    move-corresponding <fs> to filter.
    append filter.
  endloop.

  loop at p_tfilter ASSIGNING <fs>.
    move-corresponding <fs> to tfilter.
    append tfilter.
  endloop.

endform.                    "set_global_filter

*&---------------------------------------------------------------------*
*&      Form  IDENTIFY_CUSTOMER
*&---------------------------------------------------------------------*
FORM IDENTIFY_CUSTOMER CHANGING L_STOP_SEARCH.

  IF FEBEP-PABLZ IS INITIAL.                                "HP31I
    SELECT * FROM KNBK WHERE BANKN = FEBEP-PAKTO.
    ENDSELECT.                                              "HP31I
  ELSE.                                                     "HP31I
    SELECT * FROM KNBK WHERE BANKL = FEBEP-PABLZ
                         AND BANKN = FEBEP-PAKTO.
    ENDSELECT.
  ENDIF.                                                    "HP31I
  IF SY-DBCNT = 1.
    L_STOP_SEARCH = 'X'.
*   Debitor eindeutig identifiziert. Versuch auf Kreditor
    IF FEBEP-PABLZ IS INITIAL.                              "HP31I
      SELECT * FROM LFBK WHERE BANKN = FEBEP-PAKTO.
      ENDSELECT.                                            "HP31I
    ELSE.                                                   "HP31I
      SELECT * FROM LFBK WHERE BANKL = FEBEP-PABLZ
                           AND BANKN = FEBEP-PAKTO.
      ENDSELECT.
    ENDIF.                                                  "HP31I
    IF SY-DBCNT = 0.
*       Nur Debitor mit dieser Bankverbindung
      AGKON = KNBK-KUNNR.
      AGKOA = 'D'.
    ELSEIF SY-DBCNT = 1.
*       prüfen ob Debitor = Kreditor
      SELECT SINGLE * FROM KNA1 WHERE KUNNR = KNBK-KUNNR.
      IF KNA1-LIFNR = LFBK-LIFNR.
        AGKON = KNBK-KUNNR.
        AGKOA = 'D'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " IDENTIFY_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  IDENTIFY_VENDOR
*&---------------------------------------------------------------------*
FORM IDENTIFY_VENDOR CHANGING L_STOP_SEARCH.

  IF FEBEP-PABLZ IS INITIAL.                                "HP31I
    SELECT * FROM LFBK WHERE BANKN = FEBEP-PAKTO.           "HP31I
    ENDSELECT.                                              "HP31I
  ELSE.                                                     "HP31I
    SELECT * FROM LFBK WHERE BANKL = FEBEP-PABLZ
                         AND BANKN = FEBEP-PAKTO.
    ENDSELECT.
  ENDIF.                                                    "HP31I
  IF SY-DBCNT = 1.
    L_STOP_SEARCH = 'X'.
*   Kreditor eindeutig identifiziert. Versuch auf Debitor
    IF FEBEP-PABLZ IS INITIAL.                              "HP31I
      SELECT * FROM KNBK WHERE BANKN = FEBEP-PAKTO.         "HP31I
      ENDSELECT.                                            "HP31I
    ELSE.                                                   "HP31I
      SELECT * FROM KNBK WHERE BANKL = FEBEP-PABLZ
                           AND BANKN = FEBEP-PAKTO.
      ENDSELECT.
    ENDIF.                                                  "HP31I
    IF SY-DBCNT = 0.
*       Nur Kreditor mit dieser Bankverbindung
      AGKON = LFBK-LIFNR.
      AGKOA = 'K'.
    ELSEIF SY-DBCNT = 1.
*       prüfen ob Debitor = Kreditor
      SELECT SINGLE * FROM LFA1 WHERE LIFNR = LFBK-LIFNR.
      IF LFA1-KUNNR = KNBK-KUNNR.
        AGKON = LFBK-LIFNR.
        AGKOA = 'K'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " IDENTIFY_VENDOR
