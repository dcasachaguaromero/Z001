***********************************************************************
*@(#)SAPMSBDC   %I%   SAP %E%
***********************************************************************
*
*     SAP AG Walldorf
*     Systeme, Anwendungen und Produkte in der Datenverarbeitung
*
*     (C) Copyright SAP AG 1997 - 2000
*
***********************************************************************
*
*  Projekt:          R/3  Batch-Input Monitoring
*  Autor:            SAP
*
***********************************************************************
*  24.02.98 vs millenium 4-digits. Search with '*' and '+'
*  24.09.98 es enjoy - redesign
*  09.10.98 es save user-specific options
*  03.11.98 es new session analysis (report RSBDC_ANALYSE)
*  23.12.98 es new protocol overview (report RSBDC_PROTOCOL)
*  03.02.99 es ALV-listviewer for printing the session overview
*  14.07.99 es deleted lots of redundant coding
*  18.08.99 es fix: starten_mappe
*  06.12.99 es fix: update status of selected sessions correctly
*  29.12.99 es fix: native SQL in upper case
*  02.06.00 es lock date handling, lock date 'today' possible
*  04.09.00 es check authorization: S_TCODE for SHDB and SM37
*  04.09.00 es reload of APQI not for all ok-codes (performance)
*  06.09.00 es info footline
*  11.10.00 es Goto->Queue obsolete ->Queue-Dump now in session analysis
*  11.10.00 es no exec sql anymore (form dynamic_sql)
*  12.10.00 es correct setting of batchsys after F5 (d1050_fcode)
************************************************************************

PROGRAM zsapmsbdc_cc MESSAGE-ID 00 NO STANDARD PAGE HEADING.

INCLUDE <icon>.

TABLES: apqi,                          "Queue Info
        apqd,                          "Queue Data
        apql,                          "TemSe Log Info
        spop,                          "infostruktur popup_to_confirm
        usr02,                         "sap-benutzer
        bdcuseop,                      "Benutzereinstellungen
        d0100,                         "Dynpro 100
        d0200,                         "Dynpro 200
        d0300,                         "Dynpro 300
        d0500.                         "Dynpro 500
*
DATA:                                  "counter
  dcount    TYPE i VALUE 0, bdcount   TYPE i VALUE 0,
  qcount    TYPE i VALUE 0, pcnt#     TYPE i VALUE 0,
  pricnt    TYPE i VALUE 0, pricnt1   TYPE i VALUE 0,
  del_prot  TYPE i VALUE 0, null      TYPE i VALUE 0,
  on        TYPE i VALUE 1, off       TYPE i VALUE 0,
  upd_ok    TYPE i VALUE 0, screen#   TYPE i VALUE 0,
  noenqueue TYPE i VALUE 0,            " enqueueschalter
  apqd_dela TYPE i VALUE 1000,         " maximale anzahl zu loeschende
  apqd_delb TYPE i VALUE 5000,         " maximale anzahl zu loeschende
  " apqd-saetze
  apqd_drua TYPE i VALUE 5000.         " maximale anzahl fuer drucken
" im batch
DATA:                                  "reports
  subreport(12) TYPE c VALUE 'RSBDCBTC',   " Submit Batch
  logreport(16) TYPE c VALUE 'ZRSBDC_PROTOCOL', " Protokoll
  dmpreport(12) TYPE c VALUE 'RSBDCDMP',       " Queue Dump
  drureport(12) TYPE c VALUE 'RSBDCDRU',       " Mappeninhalt drucken
  datreport(12) TYPE c VALUE 'RSBDCDAT',       " Mappe ex- oder import.
  anareport(16) TYPE c VALUE 'RSBDC_ANALYSE'.  " Mappeninhalt analys.
DATA:
  jobrele           LIKE btch0000-char1,
  decision(01),
  batchsys          LIKE msxxlist-host,
  return(3)         TYPE n,
  qreturn(3)        TYPE n,
  save_subrc        LIKE sy-subrc,
  old_qstate        LIKE apqi-qstate,         "Mappenstatus (gerettet)
  string(20),                          "string fuer fehlerausgabe
  string1(20),                         "string fuer fehlerausgabe
  string2(20),                         "string fuer fehlerausgabe
  string3(20),                         "string fuer fehlerausgabe
  mod(3),                              "modify flag
  amodus(1),                           "Abspielmodus
  lmodus(1),                           "Protokollmodus
  ldefsize(1),                         "Defaultsize
  star(1)           VALUE '*',                   "Asteric
  x(1)              VALUE 'X', e(1) VALUE 'E',
  bi(12)            VALUE 'BATCH-INPUT',          "Batch-Input
  b_d_c(4)          VALUE 'BDC ',               "Datatyp = Batch-Input
  zw_modp(20),                         "hilfsfeld fuer key
  jnumb             LIKE rsjobinfo-jobnumb,
  jname             LIKE tbtco-jobname,
  auth_rc           LIKE sy-subrc,               "hilfsfeld für berechtigungen
  btc_auth_rc       LIKE sy-subrc,           "hilfsfeld für berechtigungen
  par_name(60),                        "hilfsfeld für Profile Name
  par_user_wert(60),                   "hilfsfeld für Profile Wert
  opt_simubatch(1).                    "hilfsfeld für SY-BATCH sim.
*
DATA:
  target_system TYPE msxxlist-host,      "Zielsystem
  target_server TYPE btctgtsrvr-srvname, "Ziel-AppServer
  target_group  TYPE bpsrvgrp.           "Ziel-AppServer-Gruppe


DATA: BEGIN OF bim,                    "Aktivitaeten Uebersicht
        aonl(4) VALUE 'AONL',                "Mappen-Abspielen im Online
        abtc(4) VALUE 'ABTC',                "Mappen-Abspielen im Batch
        free(4) VALUE 'FREE',                "Freigeben einer Mappe
        lock(4) VALUE 'LOCK',        "Sperren und Entsperren von Mappen
        dele(4) VALUE 'DELE',        "Sperren und Entsperren von Mappen
        anal(4) VALUE 'ANAL',                "Analysieren einer Mappen
      END OF bim.
*
DATA: BEGIN OF job  OCCURS 0,
        numb     LIKE rsjobinfo-jobnumb,       "jobnummer
        name     LIKE apqi-groupid,            "jobname
        qid      LIKE apqi-qid    ,            "jobqid
        sub(7)                  ,            "ort des fehlers
        rc       LIKE sy-subrc    ,            "return-code
        date     LIKE sy-datum,                "creation date
        time     LIKE sy-uzeit,                "creation  time
        sdate    LIKE sy-datum,                "jobdatum submit
        stime    LIKE sy-uzeit,                "jobzeit  submit
        user     LIKE sy-uname,                "jobuser
        buser    LIKE sy-uname,                "batchuser
        group    LIKE apqi-groupid,            "jobgruppe
        batchsys LIKE msxxlist-host,         "server
      END OF job.

DATA: BEGIN OF anal,
        count  TYPE i VALUE 0,               " zaehler
        ecount TYPE i VALUE 0,               " zaehler
        ba     LIKE apqd-trans,              " block anfang
        be     LIKE apqd-trans,              " block ende
        oba    LIKE apqd-trans,              " block anfang  old
        obe    LIKE apqd-trans,              " block ende    old
        fkt1   LIKE apqd-trans,              " faktor1
        fkt2   LIKE apqd-trans,              " faktor2
        blk#   LIKE apqd-trans,              " lfd. blocknr
        maxblk LIKE apqd-trans,              " max .block
      END OF anal.
*
DATA: BEGIN OF mtab OCCURS 0.
        INCLUDE STRUCTURE apqi.
      DATA: END OF mtab.
*
DATA:
  BEGIN OF q,
    id  LIKE apqi-qid, tnr LIKE apqd-trans, mnr LIKE apqd-block,
  END OF q.
*
DATA:
  BEGIN OF z,                          "Hilfsstruktur fuer sy-lisel
    trcd(04), filler1(08), stat(03), filler2(09),
    prog(08), filler3(01), dyn(04), filler4(44),
  END OF z.
*
DATA:
  BEGIN OF t ,                         "Counter fuer Transaktionsstatus
    count       TYPE i VALUE 0, fin(4)  TYPE n VALUE 0,
    err(4)      TYPE n VALUE 0, book(4) TYPE n VALUE 0,
    del(4)      TYPE n VALUE 0, ges(4)  TYPE n VALUE 0,
    son(4)      TYPE n VALUE 0, anz_err_map TYPE i VALUE 0,
  END OF t.
*
DATA:                               "Hilfsfelder System-Zeit und -Datum
  BEGIN OF zw,
    datum1 LIKE sy-datum, uzeit1 LIKE sy-uzeit,
    datum2 LIKE sy-datum, uzeit2 LIKE sy-uzeit,
  END OF zw.
*
DATA BEGIN OF log.
INCLUDE STRUCTURE rlog.        "Uebergabeparameter RSBDCLOG
DATA END OF log.
*
DATA BEGIN OF params.
INCLUDE STRUCTURE pri_params.
DATA END   OF params.
*
DATA BEGIN OF arcparams.
INCLUDE STRUCTURE arc_params.
DATA END   OF arcparams.
*
DATA: count(3) TYPE n VALUE 1,
      spoolid  LIKE sy-spono,
      valid.

DATA: apqdvarlen    TYPE i,
      maxvardatalen TYPE i VALUE 0.

DATA: BEGIN OF enq  ,
        datatyp LIKE apqi-datatyp,    "enqueue-object
        groupid LIKE apqi-groupid ,   "enqueue-object
        object  LIKE apqi-qid,        "enqueue-object
        rc      LIKE sy-subrc,        "enqueue-rc
        user    LIKE sy-uname,        "enqueue-user
        mappe   LIKE apqi-groupid,    "enqueue-mappe
      END OF enq.
*
DATA: BEGIN OF enql OCCURS 0.
        INCLUDE STRUCTURE seqg3.
      DATA: END OF enql.
*
DATA: lgarg       LIKE seqg3-garg,
      enq_entries TYPE i.
DATA: gname    LIKE  seqg3-gname.
DATA: gtarg    LIKE  seqg3-gtarg.
DATA: guname   LIKE  seqg3-guname.
DATA: gclient  LIKE  seqg3-gclient.

*----------------------------------------------------------------------*
*  Daten und Funktionen fuer Tabstrip und Tableview (Einstiegsbild)    *
*----------------------------------------------------------------------*

CONTROLS:
  d1000_tabstrip TYPE TABSTRIP,
  tc_apqi        TYPE TABLEVIEW USING SCREEN 1010,
  tc_mtab        TYPE TABLEVIEW USING SCREEN 1050.

DATA:
  tc_wa LIKE LINE OF tc_apqi-cols.

DATA:
  d1000_fcode         TYPE fcode,              " okcode des dynpros
  tc_mark,         " Markierungszelle fuer table control.
  i_lines             TYPE i,  " Anzahl der Zeilen einer Tabelle (-> describe table)
  i_apqi              TYPE i,  " dito, fuer die Tabelle itab_apqi benutzt
  current_page        LIKE sy-tabix VALUE 1,  "Felder für's Scrollen im
  new_page            LIKE sy-tabix,          "Table Control
  total_pages         LIKE sy-tabix,
  new_line            LIKE sy-tabix,
  entries             LIKE sy-tabix,
  loopc               LIKE sy-loopc,
  tc_field(32),                        "Felder für Cursorposition
  tc_line             LIKE sy-stepl,
  selected_index      LIKE sy-index,
  wa                  LIKE LINE OF tc_apqi-cols,        "Felder für die Ermittlung
  offset              TYPE i,                       "der markierten Spalte
  selected_column(32),
  sort_direction(1),                   "U: up, D: down
  reload_apqi(1)      VALUE 'X'.

TYPES:
  BEGIN OF s_itab_apqi.
    INCLUDE STRUCTURE apqi.
    TYPES status(32) TYPE c.
TYPES status_text(32) TYPE c.
TYPES:
  END OF s_itab_apqi.

DATA:
  itab_apqi     TYPE s_itab_apqi OCCURS 0 WITH HEADER LINE,
  itab_selected LIKE apqi OCCURS 0 WITH HEADER LINE.

DATA:
  d1020_fcode       TYPE fcode,
  opt_initialize(1) VALUE 'X',
  opt_exist(1)      VALUE ' ',
  d1050_fcode       TYPE fcode,
  d1050_scr         LIKE sy-dynnr,
* some variables for storing temporary copies of option flags
  rb_e, rb_b, rb_r, rb_c, rb_s, rb_sperr, rb_alle, rb_f,
  opt_creator       LIKE apqi-creator,
  opt_groupid       LIKE apqi-groupid.

*----------------------------------------------------------------------*
*                 Status fuer DYNPRO 1000 setzen                       *
*----------------------------------------------------------------------*
MODULE d1000_status OUTPUT.
  DATA fcode TYPE TABLE OF sy-ucomm.
*
  APPEND 'RECO' TO fcode.
  SET PF-STATUS '0100' EXCLUDING fcode.
  SET TITLEBAR '005'.

* Benutzereinstellungen laden.
  IF opt_initialize = 'X'.
    SELECT SINGLE * FROM bdcuseop WHERE bdcuser = sy-uname
                                    AND tid     = 'SM35'.
    IF sy-subrc = 0.
*     Einstellungen wurden gespeichert -> laden und setzen
      opt_exist = 'X'.
      d0100-mapn = bdcuseop-groupid.
      d0100-creator = bdcuseop-creator.
      CASE bdcuseop-entry_view.
        WHEN ' '. d1000_tabstrip-activetab = 'ALLE'.
        WHEN 'L'. d1000_tabstrip-activetab = 'GESPERRT'.
        WHEN 'E'. d1000_tabstrip-activetab = 'FEHLERHAFT'.
        WHEN 'B'. d1000_tabstrip-activetab = 'NEU'.
        WHEN 'R'. d1000_tabstrip-activetab = 'BATCH'.
        WHEN 'S'. d1000_tabstrip-activetab = 'HINTERGRUND'.
        WHEN 'C'. d1000_tabstrip-activetab = 'ERSTELLUNG'.
        WHEN 'F'. d1000_tabstrip-activetab = 'VERARBEITET'.
        WHEN OTHERS.
          d1000_tabstrip-activetab = 'ALLE'.
      ENDCASE.
    ELSE.
*   Keine Einstellungen gespeichert -> Defaultwerte setzen und
*   Memory Parameter auslesen
      GET PARAMETER ID 'MPN' FIELD d0100-mapn.
      GET PARAMETER ID 'BDC_CREATOR' FIELD d0100-creator.
      d1000_tabstrip-activetab = 'ALLE'.
    ENDIF.
    CLEAR opt_initialize.
  ENDIF.

  IF d0100-mapn IS INITIAL. d0100-mapn = '*'. ENDIF.
  IF d0100-creator IS INITIAL. d0100-creator = '*'. ENDIF.
  CLEAR d1000_fcode.

ENDMODULE.

*----------------------------------------------------------------------*
*             Funktionscodes in DYNPRO 1000 bearbeiten                 *
*----------------------------------------------------------------------*
MODULE d1000_cmd INPUT.

  SET PARAMETER ID 'MPN' FIELD d0100-mapn.
  SET PARAMETER ID 'BDC_CREATOR' FIELD d0100-creator.
  DESCRIBE TABLE mtab LINES i_lines.

  IF i_lines = 0.
    PERFORM check_cursor_on_groupid.
  ENDIF.

  CASE d1000_fcode.

    WHEN 'REFR'.                       "Return-Taste
      reload_apqi = 'X'.

    WHEN 'NEU' OR 'FEHLERHAFT' OR 'VERARBEITET' OR 'BATCH'
               OR 'ERSTELLUNG' OR 'HINTERGRUND' OR 'GESPERRT'
               OR 'ALLE'.
      d1000_tabstrip-activetab = d1000_fcode.
      tc_apqi-top_line = 1.
      reload_apqi = 'X'.

    WHEN 'MEXP'.
      IF i_lines > 1.
        MESSAGE s303. "Mehrere Mappen zu verarbeiten ist nicht moeglich.
      ELSE.
        IF i_lines = 1.
          screen# = 120.
        ELSE.
          screen# = 100.
        ENDIF.
        PERFORM mappe_exportieren.
      ENDIF.

    WHEN 'MIMP'.
      screen# = 120.
      PERFORM mappe_importieren.

    WHEN 'ANM'.
      IF i_lines = 0.
        MESSAGE s311 WITH 'Keine'(065).
      ELSEIF i_lines > 1.
        MESSAGE s303. "Mehrere Mappen zu verarbeiten ist nicht moeglich.
      ELSE.
        SUBMIT (anareport) WITH queue_id  EQ mtab-qid AND RETURN.
*       sessions can be unlocked and the 'keep' flag can be changed
*       within RSBDC_ANALYSE. We need to know whether the APQI display
*       must be updated.
        IMPORT reload_apqi FROM MEMORY ID 'RELOAD_APQI'.
        IF sy-subrc <> 0.
          CLEAR reload_apqi.
        ENDIF.
        EXPORT space TO MEMORY ID 'RELOAD_APQI'.
      ENDIF.

    WHEN 'DEL'.
      dcount = i_lines.          "wird in pop_up... noch so verwendet
      PERFORM loeschen_mappen.
      reload_apqi = 'X'.

    WHEN 'STA'.
      IF i_lines = 0.
        MESSAGE s311 WITH 'Keine'(065).
      ELSEIF i_lines > 1.
        MESSAGE s303. "Mehrere Mappen zu verarbeiten ist nicht moeglich.
      ELSE.
        PERFORM starten_mappe.
      ENDIF.

    WHEN 'MSUB'.
      IF i_lines = 0.
        MESSAGE s311 WITH 'Keine'(065).
      ELSE.
        CALL SCREEN 1050 STARTING AT 5 5.  "Zielrechner ?
        CHECK d1050_fcode = 'SEL'.
        par_name = 'bdc/protocol/errorforceend'.
        CALL 'C_SAPGPARAM' ID 'NAME'  FIELD par_name
                           ID 'VALUE' FIELD par_user_wert.
        IF par_user_wert = 'on'.
          d0300-errfend = 'X'.
        ELSE.
          CLEAR d0300-errfend.
        ENDIF.
        PERFORM submit_mappen.
      ENDIF.
      reload_apqi = 'X'.

    WHEN 'STK'.
      IF i_lines > 1.
        MESSAGE s303. "Mehrere Mappen zu verarbeiten ist nicht moeglich.
      ELSEIF i_lines = 0.
        MESSAGE s311 WITH 'Keine'(065).
      ELSE.
        CALL SCREEN 500 STARTING AT 10 10.
      ENDIF.

    WHEN 'SPER'.
      IF i_lines = 0.
        MESSAGE s311 WITH 'Keine'(065).
      ELSE.
        PERFORM sperren_mappen.
        reload_apqi = 'X'.
      ENDIF.

    WHEN 'ULOC'.
      IF i_lines = 0.
        MESSAGE s311 WITH 'Keine'(065).
      ELSE.
        PERFORM upd_mappe.
        reload_apqi = 'X'.
      ENDIF.

    WHEN 'FREI'.
      IF i_lines = 0.
        MESSAGE s311 WITH 'Keine'(065).
      ELSE.
        PERFORM mappen_freigeben.
        reload_apqi = 'X'.
      ENDIF.

    WHEN 'DUMP'.
      IF i_lines = 0.
        MESSAGE s311 WITH 'Keine'(065).
      ELSEIF i_lines > 1.
        MESSAGE s303.
      ELSE.
        PERFORM bim_berechtigung USING bim-anal x.
        IF auth_rc = 0.
          q-id = mtab-qid.
          q-tnr = 0.
          q-mnr = 0.
          SUBMIT (dmpreport) AND RETURN
                  WITH queue_id EQ q-id
                  WITH trans-nr EQ q-tnr
                  WITH mess-nr  EQ q-mnr.
        ENDIF.
      ENDIF.

    WHEN 'ANAQ'.
      CLEAR log.                       "Struktur zur Parameteruebergabe
      IF i_lines = 0.                  "Keine Selektion?
        SUBMIT (logreport)
           WITH session  = d0100-mapn
           WITH from_dat = d0100-von
           WITH to_dat   = d0100-bis
           WITH user     = d0100-creator
           AND RETURN.
      ELSEIF i_lines = 1.              "Genau eine Mappe selektiert?
        SUBMIT (logreport)
           WITH queue_id = mtab-qid
           AND RETURN.
      ELSE.
        MESSAGE i303.         "E: Mehrfachselektion unzulaessig.
      ENDIF.

    WHEN 'RECO'.
      AUTHORITY-CHECK OBJECT 'S_TCODE'
              ID 'TCD' FIELD 'SHDB'.
      IF sy-subrc = 0.
        CALL TRANSACTION 'SHDB'.
        reload_apqi = 'X'.
      ELSE.
        MESSAGE i172(00) WITH 'SHDB'.
      ENDIF.

    WHEN 'BTCI'.
      AUTHORITY-CHECK OBJECT 'S_TCODE'
              ID 'TCD' FIELD 'SM37'.
      IF sy-subrc = 0.
        CALL TRANSACTION 'SM37' AND SKIP FIRST SCREEN.
      ELSE.
        MESSAGE i172(00) WITH 'SM37'.
      ENDIF.

    WHEN 'BTCZ'.
      CALL SCREEN 1050 STARTING AT 5 5.

    WHEN 'BACK' OR 'RET'.
      LEAVE PROGRAM.

    WHEN 'MPRI'.
      IF i_lines = 0.
        MESSAGE i311 WITH '0'.
      ELSE.
        IF i_lines > 1.
          CALL SCREEN 1050 STARTING AT 5 5.
          CHECK d1050_fcode = 'SEL'.
        ENDIF.
        PERFORM bim_berechtigung USING bim-anal x.
        IF auth_rc = 0.
          PERFORM mappeninhalt_drucken.
        ENDIF.
      ENDIF.

    WHEN 'UMRK'.                       "Markierungen entfernen
      CLEAR itab_selected. REFRESH itab_selected.

    WHEN 'AMRK'.                       "Alle Mappen markieren
      CLEAR: mtab, itab_selected.
      REFRESH: mtab, itab_selected.
      LOOP AT itab_apqi.
        MOVE: itab_apqi TO mtab, itab_apqi TO itab_selected.
        APPEND: mtab, itab_selected.
      ENDLOOP.

    WHEN 'SORT_UP'.
      PERFORM get_tc_selected_column.
      sort_direction = 'U'.

    WHEN 'SORT_DOWN'.
      PERFORM get_tc_selected_column.
      sort_direction = 'D'.

    WHEN 'P-' OR 'P--' OR 'P+' OR 'P++'.
* Interne Tabelle blättern nach SAP Style Guide:
      CALL FUNCTION 'SCROLLING_IN_TABLE'
        EXPORTING
          entry_act             = tc_apqi-top_line
          entry_from            = 1
          entry_to              = i_apqi
          ok_code               = d1000_fcode
          last_page_full        = ' '
          overlapping           = ' '
          loops                 = loopc
        IMPORTING
          entries_sum           = entries
          entry_new             = new_line
          pages_sum             = total_pages
          page_new              = new_page
        EXCEPTIONS
          no_entry_or_page_act  = 01
          no_entry_to           = 02
          no_ok_code_or_page_go = 03.

      tc_apqi-top_line = new_line.

    WHEN 'INFO'.
      PERFORM batch_input_hilfe.

    WHEN 'OPTI'.
      CALL SCREEN '1020' STARTING AT 5 5.
      reload_apqi = 'X'.

    WHEN 'ALV_PRINT'.
      PERFORM print_alv_list.

    WHEN OTHERS.
      "
  ENDCASE.

  PERFORM send_msg.

ENDMODULE.

*----------------------------------------------------------------------*
*             Subscreen des DYNPRO 1000 initialisieren                 *
*              (Daten fuer die table controls lesen)                   *
*----------------------------------------------------------------------*
MODULE init_subscreen OUTPUT.

* APQI-Eintraege zum aktiven Tab einlesen und in itab_apqi kopieren:

  CASE d1000_tabstrip-activetab.
    WHEN 'NEU' OR space.
      PERFORM fill_itab USING ' '.
    WHEN 'FEHLERHAFT'.
      PERFORM fill_itab USING 'E'.
    WHEN 'VERARBEITET'.
      PERFORM fill_itab USING 'F'.
    WHEN 'ERSTELLUNG'.
      PERFORM fill_itab USING 'C'.
    WHEN 'BATCH'.
      PERFORM fill_itab USING 'R'.
    WHEN 'HINTERGRUND'.
      PERFORM fill_itab USING 'S'.
    WHEN 'GESPERRT'.
      PERFORM fill_itab USING '*'.
      LOOP AT itab_apqi.
        DELETE itab_apqi WHERE startdate LE d0100-von.
      ENDLOOP.
    WHEN 'ALLE'.
      PERFORM fill_itab USING '*'.
  ENDCASE.

* Table control initialisieren
  DESCRIBE TABLE itab_apqi LINES i_lines.
  i_apqi = i_lines.
  tc_apqi-lines = i_lines.
* Vertikalen Scrollbalken zurücksetzen, falls nicht mehr gültig
  IF tc_apqi-top_line > tc_apqi-lines.
    tc_apqi-top_line = 1.
  ENDIF.

* Fuellen des Statusfeldes
  LOOP AT itab_apqi.
    CASE itab_apqi-qstate.
      WHEN ' '.
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name   = icon_create
            info   = 'neu'(036)
          IMPORTING
            result = itab_apqi-status
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          itab_apqi-status = icon_status_ok.
        ENDIF.
        itab_apqi-status_text = 'neu'(036).
      WHEN 'F'.
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name   = icon_status_ok
            info   = 'verarbeitet'(037)
          IMPORTING
            result = itab_apqi-status
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          itab_apqi-status = icon_status_ok.
        ENDIF.
        itab_apqi-status_text = 'verarbeitet'(037).
      WHEN 'E'.
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name   = icon_status_critical
            info   = 'fehlerhaft'(035)
          IMPORTING
            result = itab_apqi-status
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          itab_apqi-status = icon_status_critical.
        ENDIF.
        itab_apqi-status_text = 'fehlerhaft'(035).
      WHEN 'R'.
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name   = icon_execute_object
            info   = 'in Bearbeitung'(038)
          IMPORTING
            result = itab_apqi-status
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          itab_apqi-status = icon_execute_object.
        ENDIF.
        itab_apqi-status_text = 'in Bearbeitung'(038).
      WHEN 'C'.
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name   = icon_create_text
            info   = 'in Erstellung'(039)
          IMPORTING
            result = itab_apqi-status
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          itab_apqi-status = icon_create_text.
        ENDIF.
        itab_apqi-status_text = 'in Erstellung'(039).
      WHEN 'S'.
        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            name   = icon_background_job
            info   = 'im Hintergrund'(046)
          IMPORTING
            result = itab_apqi-status
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc <> 0.
          itab_apqi-status = icon_background_job.
        ENDIF.
        itab_apqi-status_text = 'im Hintergrund'(046).
      WHEN OTHERS.
        itab_apqi-status = '?'.
        itab_apqi-status_text = '?'.
    ENDCASE.
    MODIFY itab_apqi.
  ENDLOOP.

* Sortieren
  IF selected_column = 'STATUS'.
    IF d1000_tabstrip-activetab = 'ALLE'
    OR d1000_tabstrip-activetab = 'GESPERRT'.
      selected_column = 'QSTATE'.      " Umsetzen auf das APQI-Feld
    ELSE.
      "Spalte wird nicht angezeigt -> Default-Sortierung
      CLEAR selected_column.
    ENDIF.
  ENDIF.

  IF NOT selected_column IS INITIAL.
    CASE sort_direction.
      WHEN 'D'.
        SORT itab_apqi BY (selected_column) DESCENDING
                          credate DESCENDING
                          cretime DESCENDING
                          qid DESCENDING.
      WHEN 'U'.
        SORT itab_apqi BY (selected_column) ASCENDING
                          credate ASCENDING
                          cretime ASCENDING
                          qid ASCENDING.
    ENDCASE.
  ELSE.
    SORT itab_apqi BY credate DESCENDING
                      cretime DESCENDING
                      qid DESCENDING.
  ENDIF.

  IF NOT tc_field IS INITIAL.
    SET CURSOR FIELD tc_field LINE tc_line.
  ENDIF.

ENDMODULE.

*----------------------------------------------------------------------*
*       Markierte Eintraege aus Table control nach mtab kopieren       *
*----------------------------------------------------------------------*

MODULE extract_selected INPUT.
* Eine Kopie der Eintraege wird in itab_selected gespeichert; diese
* Tabelle wird im PBO nicht initialisiert und wird dort zum erneuten
* Markieren der dann noch vorhandenen markiert gewesenen Mappen genutzt.
  IF tc_mark = 'X'.
*   neue Markierung ?
    READ TABLE itab_selected WITH KEY qid = itab_apqi-qid.
    IF sy-subrc = 4.                   " war nicht markiert -> einfuegen
      MOVE itab_apqi TO itab_selected.
      APPEND itab_selected.
    ENDIF.
  ELSE.
*   war die Zeile vorher markiert ?
    READ TABLE itab_selected WITH KEY qid = itab_apqi-qid.
    IF sy-subrc = 0.                   " war markiert -> loeschen
      DELETE itab_selected WHERE qid = itab_apqi-qid.
    ENDIF.
  ENDIF.
ENDMODULE.
*----------------------------------------------------------------------*
*       Module  FILL_TC  OUTPUT
*----------------------------------------------------------------------*

MODULE fill_tc OUTPUT.
  IF itab_apqi-groupid IS INITIAL.
    EXIT FROM STEP-LOOP.
  ELSE.
* In itab_selected wurden die markierten Mappen gemerkt; diese sollen
* beim erneuten Aufbau des Table Controls wieder markiert sein, falls
* noch vorhanden.
    READ TABLE itab_selected WITH KEY qid = itab_apqi-qid.
    IF sy-subrc = 0.
      tc_mark = 'X'.
*     Da sich der Mappenstatus geändert haben kann, muss itab_selected
*     aktualiasiert werden.
      itab_selected = itab_apqi.
      MODIFY itab_selected INDEX sy-tabix.
    ENDIF.
  ENDIF.
  loopc = sy-loopc.
ENDMODULE.                             " CHECK_IF_EMPTY  OUTPUT
*----------------------------------------------------------------------*
*       Module  CLEAR_ITAB_SELECTED  OUTPUT
*----------------------------------------------------------------------*
MODULE clear_itab_selected OUTPUT.
* Loeschen aller Eintraege, die nicht mehr in itab_apqi enthalten sind:
  LOOP AT itab_selected.
    READ TABLE itab_apqi WITH KEY qid = itab_selected-qid.
    IF sy-subrc = 4.
      DELETE itab_selected.
    ENDIF.
  ENDLOOP.
ENDMODULE.                             " D1000_PAI  OUTPUT
*----------------------------------------------------------------------*
*       Module  CHECK_SELECTION  INPUT
*----------------------------------------------------------------------*
MODULE check_selection INPUT.
*
  IF d0100-von GT 0 AND
    d0100-bis EQ 0.
    d0100-bis = sy-datum.
  ENDIF.

  IF d0100-von GT d0100-bis.
    MESSAGE e208 WITH 'Bitte Datumsangaben korrigieren.'(072).
  ENDIF.
*
ENDMODULE.                             " CHECK_SELECTION  INPUT

*----------------------------------------------------------------------*
*       MODULE get_tc_cursor
*----------------------------------------------------------------------*
MODULE get_tc_cursor INPUT.
  GET CURSOR FIELD tc_field LINE tc_line.
  selected_index = tc_apqi-top_line + tc_line - 1.
ENDMODULE.

*----------------------------------------------------------------------*
*       FORM check_dclk_groupid
*----------------------------------------------------------------------*
FORM check_cursor_on_groupid.
* Falls keine Mappe 'hart' markiert ist, aber der Cursor auf einer
* Mappe steht, Info in die mtab kopieren (weiche Selektion)
  IF tc_line > 0.
    READ TABLE itab_apqi INDEX selected_index INTO mtab.
    APPEND mtab.
    i_lines = 1.
  ELSE.
    REFRESH mtab. CLEAR mtab.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
*       FORM get_tc_selected_column
*----------------------------------------------------------------------*
FORM get_tc_selected_column.
  CLEAR selected_column.
  LOOP AT tc_apqi-cols INTO wa WHERE selected = 'X'.
    "Einfachselektion wird vorausgesetzt
    SEARCH wa-screen-name FOR '-'.
    offset = sy-fdpos + 1.
    selected_column = wa-screen-name+offset.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------*
*       Module  COPY_SELECTIONS_TO_MTAB  INPUT
*----------------------------------------------------------------------*
MODULE copy_selections_to_mtab INPUT.
  CLEAR mtab. REFRESH mtab.
  LOOP AT itab_selected.
    MOVE itab_selected TO mtab. APPEND mtab.
  ENDLOOP.
ENDMODULE.                             " COPY_SELECTIONS_TO_MTAB  INPUT

*----------------------------------------------------------------------*
*      Module d1020_status
*----------------------------------------------------------------------*
MODULE d1020_init OUTPUT.
  SET PF-STATUS '0210'.
  SET TITLEBAR '021' WITH sy-uname.
  CLEAR: rb_alle, rb_b, rb_e, rb_f, rb_r, rb_c, rb_s, rb_sperr.
  CLEAR: opt_groupid, opt_creator.
  IF opt_exist = 'X'.
    SELECT SINGLE * FROM bdcuseop WHERE bdcuser = sy-uname
                                    AND tid     = 'SM35'.
    opt_groupid = bdcuseop-groupid.
    opt_creator = bdcuseop-creator.
    CASE bdcuseop-entry_view.
      WHEN 'B'. rb_b = 'X'.
      WHEN 'E'. rb_e = 'X'.
      WHEN 'F'. rb_f = 'X'.
      WHEN 'R'. rb_r = 'X'.
      WHEN 'C'. rb_c = 'X'.
      WHEN 'S'. rb_s = 'X'.
      WHEN 'L'. rb_sperr = 'X'.
    ENDCASE.
  ENDIF.
ENDMODULE.

*----------------------------------------------------------------------*
*      Module d1020_fcode
*----------------------------------------------------------------------*
MODULE d1020_fcode.
  CASE d1020_fcode.
*   nur uebernehmen, nicht speichern
    WHEN 'OPT_OK'.
      PERFORM set_options_from_dialog.
*   uebernehmen und speichern
    WHEN 'OPT_SAVE'.
      PERFORM set_options_from_dialog.
      bdcuseop-bdcuser = sy-uname.
      bdcuseop-groupid = opt_groupid.
      bdcuseop-creator = opt_creator.
      bdcuseop-tid     = 'SM35'.
      IF rb_alle = 'X'.  bdcuseop-entry_view = ' '. ENDIF.
      IF rb_e = 'X'.     bdcuseop-entry_view = 'E'. ENDIF.
      IF rb_f = 'X'.     bdcuseop-entry_view = 'F'. ENDIF.
      IF rb_b = 'X'.     bdcuseop-entry_view = 'B'. ENDIF.
      IF rb_r = 'X'.     bdcuseop-entry_view = 'R'. ENDIF.
      IF rb_c = 'X'.     bdcuseop-entry_view = 'C'. ENDIF.
      IF rb_s = 'X'.     bdcuseop-entry_view = 'S'. ENDIF.
      IF rb_sperr = 'X'. bdcuseop-entry_view = 'L'. ENDIF.
      IF opt_exist = 'X'.
        UPDATE bdcuseop.
      ELSE.
        INSERT bdcuseop.
      ENDIF.
      IF sy-subrc = 0.
        opt_exist = 'X'.
      ENDIF.

*   auf Datenbank loeschen
    WHEN 'OPT_DELETE'.
      IF opt_exist = 'X'.
        DELETE FROM bdcuseop WHERE bdcuser = sy-uname
                               AND tid     = 'SM35'.
        IF sy-subrc = 0. CLEAR opt_exist. ENDIF.
      ENDIF.
    WHEN 'OPT_CANCEL'.
  ENDCASE.
  LEAVE TO SCREEN 0.
ENDMODULE.
*----------------------------------------------------------------------*
*      Form set_options_from_dialog
*----------------------------------------------------------------------*
FORM set_options_from_dialog.
  d0100-mapn = opt_groupid.
  d0100-creator = opt_creator.
  IF rb_alle = 'X'.  d1000_tabstrip-activetab = 'ALLE'.        ENDIF.
  IF rb_e = 'X'.     d1000_tabstrip-activetab = 'FEHLERHAFT'.  ENDIF.
  IF rb_f = 'X'.     d1000_tabstrip-activetab = 'VERARBEITET'. ENDIF.
  IF rb_b = 'X'.     d1000_tabstrip-activetab = 'NEU'.         ENDIF.
  IF rb_r = 'X'.     d1000_tabstrip-activetab = 'BATCH'.       ENDIF.
  IF rb_c = 'X'.     d1000_tabstrip-activetab = 'ERSTELLUNG'.  ENDIF.
  IF rb_s = 'X'.     d1000_tabstrip-activetab = 'HINTERGRUND'. ENDIF.
  IF rb_sperr = 'X'. d1000_tabstrip-activetab = 'GESPERRT'.    ENDIF.
ENDFORM.
*----------------------------------------------------------------------*
*      Module d1050_status
*----------------------------------------------------------------------*
MODULE d1050_status OUTPUT.
  tc_mtab-lines = i_lines.
  CLEAR d1050_fcode.

* Aufruf in Zusammenhang mit Hintergrundverarbeitung:
* Eingabefeld für Zielrechner aktivieren.
  IF d1000_fcode = 'MSUB' OR d1000_fcode = 'BTCZ'.
    LOOP AT SCREEN.
      IF screen-name = 'FRM_TARGET'.
        screen-active = 1.
        MODIFY SCREEN.
        screen-invisible = 0. screen-output = 1.
        MODIFY SCREEN.
      ELSEIF screen-name = 'D0300-BATCHSYS'.
        screen-invisible = 0.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
* Falls nur Eingabe des Zielsystems für Hintergrundverarbeitung:
* Tableview und Anzeige der Anzahl/Mappen ausblenden.
  IF d1000_fcode = 'BTCZ'.
    LOOP AT SCREEN.
      IF screen-name = 'I_LINES' OR
         screen-name = 'TXT_SELNO'.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    LOOP AT tc_mtab-cols INTO tc_wa.
      tc_wa-invisible = 1.
      MODIFY tc_mtab-cols FROM tc_wa.
    ENDLOOP.
  ENDIF.

  CASE d1000_fcode.
    WHEN 'MSUB'. SET TITLEBAR '014'.
    WHEN 'FREI'. SET TITLEBAR '018'.
    WHEN 'DEL'.  SET TITLEBAR '019'.
    WHEN 'MPRI'. SET TITLEBAR '020'.
    WHEN 'BTCZ'. SET TITLEBAR '022'.

  ENDCASE.

  SET PF-STATUS '0220'.
  SET CURSOR FIELD 'MTAB-GROUPID' LINE 1.

ENDMODULE.

*----------------------------------------------------------------------*
*       Module exit
*----------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE PROGRAM.
ENDMODULE.

*----------------------------------------------------------------------*
*       Module d1050_fcode
*----------------------------------------------------------------------*
MODULE d1050_fcode INPUT.
  IF d1050_fcode = 'SEL' OR d1050_fcode = 'CONT'.
    batchsys = d0300-batchsys.
    REFRESH CONTROL 'TC_MTAB' FROM SCREEN '1050'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE D0200_INIT                              PBO            *
*---------------------------------------------------------------------*
* Initialisierung der Felder des Dynpros 0200                         *
*---------------------------------------------------------------------*
MODULE d0200_init OUTPUT.
*
  CLEAR: d0100-fcode, d0200-fcode, d0200-startdate.
*
  SET PF-STATUS '0200'.
  SET TITLEBAR '002'.
*
ENDMODULE.                             " D0200_INIT.
*/
*---------------------------------------------------------------------*
*       MODULE D0300_INIT                              PBO            *
*---------------------------------------------------------------------*
MODULE d0300_init OUTPUT.
*
  SET PF-STATUS '0300'.
  SET TITLEBAR '006' WITH mtab-groupid.
*
  CLEAR: d0300-logall, d0300-expert.
  d0300-dydefsize = 'X'.

  par_name = 'bdc/protocol/errorforceend'.
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD par_name
                     ID 'VALUE' FIELD par_user_wert.

  IF par_user_wert = 'on'.
    d0300-errfend = 'X'.
  ELSE.
    CLEAR d0300-errfend.
  ENDIF.

ENDMODULE.                             " D0300_INIT.
*/
*---------------------------------------------------------------------*
*       MODULE D0500_INIT                              PBO            *
*---------------------------------------------------------------------*
MODULE d0500_init OUTPUT.

  SET PF-STATUS '0500'.
  SET TITLEBAR '010' WITH mtab-groupid.
*
  d0500-txtcre  = 'Gesamt'(033).
  d0500-tcrecnt = mtab-transcnt.
  d0500-mcrecnt = mtab-msgcnt.
*
  d0500-txterr = 'fehlerhaft'(003).
  d0500-terrcnt = mtab-transcnte.
  d0500-merrcnt = mtab-msgcnte.
*
  d0500-txtfin = 'verarbeitet'(004).
  d0500-tfincnt = mtab-transcntf.
  d0500-mfincnt = mtab-msgcntf.
*
  d0500-txtdel = 'gelöscht'(026).
  d0500-tdelcnt = mtab-transcntd.
  d0500-mdelcnt = mtab-msgcntd.
*
  d0500-txtson  = 'noch zu verarbeiten'(031).
  d0500-tsoncnt = mtab-transcnt -
       ( mtab-transcnte + mtab-transcntf + mtab-transcntd ).
*
  d0500-msoncnt = mtab-msgcnt -
     ( mtab-msgcnte + mtab-msgcntf + mtab-msgcntd ).

  CLEAR: d0500-fcode.
*
ENDMODULE.                             " D0500_INIT.
*/
*---------------------------------------------------------------------*
*       MODULE D0200_FCODE                             PAI            *
*---------------------------------------------------------------------*
MODULE d0200_fcode.
*
  IF d0200-fcode = '   ' OR d0200-fcode = 'LLOC'.
    IF d0200-startdate >= sy-datum AND d0200-startdate > mtab-credate.
      d0200-fcode = 'SPER'.
    ELSE.
      MESSAGE e302 WITH d0200-startdate.
    ENDIF.
  ENDIF.

ENDMODULE.                             " D0200_FCODE
*/
*---------------------------------------------------------------------*
*       MODULE D0300_START                                            *
*---------------------------------------------------------------------*
* Starten einer Batch-Input Mappe                                     *
*---------------------------------------------------------------------*
MODULE d0300_start.
*
* Falls nötig, OK-Code für Batch-Verarbeitung umsetzen
  IF d0300-batch = 'X' AND d0300-fcode = 'ABSP'.
    d0300-fcode = 'MSUB'.
  ENDIF.

* Parameter für Aufruf von BDC_START_GROUP setzen
  IF d0300-hell = 'X'.
    string = 'HELL'.
    amodus = 'A'.
  ELSEIF d0300-error EQ 'X'.
    string = 'im Modus ERROR'(062).
    amodus = 'E'.
  ENDIF.

  IF d0300-logall = 'X'.
    lmodus = 'A'.
  ELSE.
    CLEAR lmodus.
  ENDIF.
  IF d0300-dydefsize = 'X'.
    ldefsize = 'S'.
  ELSE.
    CLEAR ldefsize.
  ENDIF.

  CASE  d0300-fcode.
    WHEN 'BACK' OR 'CONT'.             "f3 zurueck
      PERFORM dequeue.
      SET SCREEN 0.
      LEAVE SCREEN.
      EXIT.
    WHEN 'ABSP' .
      PERFORM bim_berechtigung USING bim-aonl x.
      sy-subrc = 0.
      CALL 'BDC_START_GROUP' ID 'GROUP'         FIELD mtab-groupid
                             ID 'QUID'          FIELD mtab-qid
                             ID 'DISPLAY'       FIELD amodus
                             ID 'LOG'           FIELD lmodus
                             ID 'EXPERT'        FIELD d0300-expert
                             ID 'DYSIZE'        FIELD ldefsize
                             ID 'ERRORFORCEEND' FIELD d0300-errfend
                             ID 'SIMUBATCH'     FIELD opt_simubatch.
      IF sy-subrc NE 0.
        save_subrc = sy-subrc.
        PERFORM dequeue.
        sy-subrc = save_subrc.
        PERFORM queue_error .
      ENDIF.
    WHEN 'MSUB' .
      MOVE d0300-batchsys TO batchsys.
      PERFORM bim_berechtigung USING bim-abtc e.
      PERFORM submit_mappen.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN OTHERS .
  ENDCASE.                             "D0300-FCODE
*
  PERFORM send_msg.
*
ENDMODULE.                             " d0300_start
*
*---------------------------------------------------------------------*
*       MODULE D0500_FCODE                             PAI            *
*---------------------------------------------------------------------*
MODULE d0500_fcode.
  LEAVE SCREEN.
ENDMODULE.                             " d0500_fcode

*---------------------------------------------------------------------*
*             : Modul SHOW_TARGET_SYSTEMS für die PF4-Behandlung des  *
*               Feldes BTCH1140-BTCSYSTEM (Zielrechnerangabe)         *
*---------------------------------------------------------------------*
* Dieses Modul zeigt die Liste aller Batch-Server an.                 *
*---------------------------------------------------------------------*
MODULE show_target_systems.

  DATA: rc              TYPE i VALUE 0,
        selected_system LIKE d0300-batchsys.

  DATA BEGIN OF btc_sys_tbl OCCURS 10.
  INCLUDE STRUCTURE btctgtitbl.
  DATA END OF btc_sys_tbl.
*
  DATA BEGIN OF btc_sys_host_tbl OCCURS 10.
  DATA btcsystem TYPE btctgtsys.
  DATA instname(22).
  DATA END OF btc_sys_host_tbl.
*
  DATA: field_tbl LIKE dfies OCCURS 0 WITH HEADER LINE.
  DATA: return_tbl LIKE ddshretval OCCURS 0 WITH HEADER LINE.
  DATA: dynpfields_tbl LIKE dynpread OCCURS 0 WITH HEADER LINE.
*
  DATA: grp_hlp_tbl1 TYPE TABLE OF bpsrvgrpi,
        my_grp       TYPE bpsrvgrpi.

  PERFORM get_btc_systems USING rc.

  IF rc = 1.                           " TGT_HOST_CHK_HAS_FAILED.
    MESSAGE e208
      WITH 'Liste der Batch-Server konnte nicht gelesen werden.'(070).
  ELSEIF rc = 4.                       " NO_FREE_BATCH_SERVER.
    MESSAGE e208
      WITH 'Kein freier Batch-Server gefunden.'(071).
  ENDIF.

  FREE btc_sys_host_tbl.
  LOOP AT btc_sys_tbl.
    btc_sys_host_tbl-btcsystem = btc_sys_tbl-btcsystem.
    btc_sys_host_tbl-instname  = btc_sys_tbl-instname.
    APPEND btc_sys_host_tbl.
  ENDLOOP.

* server groups are treated as pseudo-instances
  REFRESH grp_hlp_tbl1.
  CALL METHOD cl_bp_group_factory=>get_group_names
    IMPORTING
      o_grouplist = grp_hlp_tbl1.

  SORT grp_hlp_tbl1 BY grpname ASCENDING.

  LOOP AT grp_hlp_tbl1 INTO my_grp.
    CLEAR btc_sys_host_tbl.
    IF my_grp-grpname NE 'SAP_DEFAULT_BTC'.
      CONCATENATE '<' my_grp-grpname '>' INTO btc_sys_host_tbl-instname.
      APPEND btc_sys_host_tbl.
    ENDIF.
  ENDLOOP.
* server groups are in the list now: <GRP_NAME>

  FREE field_tbl.
  CLEAR field_tbl.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname    = 'BTCTGTITBL'
      lfieldname = 'INSTNAME'
    IMPORTING
      dfies_wa   = field_tbl
    EXCEPTIONS
      OTHERS     = 3.
  IF sy-subrc EQ 0.
    field_tbl-leng      = field_tbl-leng + 2.
    field_tbl-intlen    = field_tbl-intlen + ( 2 * cl_abap_char_utilities=>charsize ).
    field_tbl-outputlen = field_tbl-outputlen + 2.
  ELSE.
    field_tbl-tabname    = 'BTCTGTITBL'.
    field_tbl-fieldname  = 'INSTNAME'.
  ENDIF.
  APPEND field_tbl.

  CLEAR field_tbl.
  field_tbl-tabname    = 'BTCTGTITBL'.
  field_tbl-fieldname  = 'BTCSYSTEM'.
  APPEND field_tbl.

  FREE return_tbl.
  CLEAR return_tbl.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'INSTNAME'
      value_org       = 'S'
    TABLES
      value_tab       = btc_sys_host_tbl
      field_tab       = field_tbl
      return_tab      = return_tbl
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc EQ 0 AND return_tbl-fieldval NE space.
    FREE dynpfields_tbl.
    CLEAR dynpfields_tbl.
    MOVE 'D0300-BATCHSYS' TO dynpfields_tbl-fieldname.
    MOVE return_tbl-fieldval TO dynpfields_tbl-fieldvalue.
    APPEND dynpfields_tbl.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname               = 'ZSAPMSBDC_CC'
        dynumb               = sy-dynnr
      TABLES
        dynpfields           = dynpfields_tbl
      EXCEPTIONS
        invalid_abapworkarea = 1
        invalid_dynprofield  = 2
        invalid_dynproname   = 3
        invalid_dynpronummer = 4
        invalid_request      = 5
        no_fielddescription  = 6
        undefind_error       = 7
        OTHERS               = 8.
  ENDIF.

ENDMODULE.                             " SHOW_TARGET_SYSTEMS

*&---------------------------------------------------------------------*
*&      Form  batch_input_hilfe
*&---------------------------------------------------------------------*
FORM batch_input_hilfe.
  DATA:
    docu_object LIKE dokhl-object,
    docu_id     LIKE dokhl-id,
    docu_spras  LIKE dokhl-langu,
    tx_header   LIKE thead,
    tx_lines    LIKE tline OCCURS 0 WITH HEADER LINE.

  docu_object = 'BDC_INFO'.
  docu_id = 'TX'.
  docu_spras = sy-langu.
  CALL FUNCTION 'DOCU_GET'
    EXPORTING
      object                 = docu_object
      id                     = docu_id
      langu                  = docu_spras
      version_active_or_last = 'A'
    IMPORTING
      head                   = tx_header
    TABLES
      line                   = tx_lines
    EXCEPTIONS
      OTHERS                 = 1.

  CALL FUNCTION 'PRINT_TEXT'
    EXPORTING
      application = 'TX'
      device      = 'SCREEN'
      header      = tx_header
    TABLES
      lines       = tx_lines
    EXCEPTIONS
      OTHERS      = 1.

ENDFORM.                               " batch_input_hilfe .
*/
*---------------------------------------------------------------------*
* FORM : submit_mappen.                                               *
*---------------------------------------------------------------------*
FORM submit_mappen.
*
*** Submit von Mappen in den Hintergrund (mit Batch).
*
  CLEAR: string,                  " Variabler Teil der Fehlermeldung
         jnumb,
         return.
*
  MOVE ' SUBMIT ' TO string.
  CLEAR: dcount.
*
  PERFORM map_batchsys_onto_target.
*
  LOOP AT mtab.
    PERFORM bim_berechtigung USING bim-abtc x.
    CHECK auth_rc = 0.

    IF mtab-userid IS NOT INITIAL.
      CALL FUNCTION 'SUSR_USER_CHECK_EXISTENCE'
        EXPORTING
          user_name            = mtab-userid
        EXCEPTIONS
          user_name_not_exists = 1
          OTHERS               = 2.
      IF sy-subrc <> 0.
        CONCATENATE TEXT-015 mtab-groupid INTO string SEPARATED BY space.
        MESSAGE i336 WITH string mtab-userid.
*         Mappe &, User .&. ist ungültig
        CONTINUE.
      ENDIF.
    ENDIF.

    PERFORM enqueue USING mtab-datatyp mtab-groupid mtab-qid.
    qreturn = return.
    IF qreturn GT 0.
      PERFORM send_msg. EXIT.
    ELSE.
      PERFORM ist_mappe_abspielbar.
      IF qreturn GT 0.
        PERFORM dequeue.
        MESSAGE i309. EXIT.
      ENDIF.
    ENDIF.
    IF mtab-startdate LT sy-datum.
      CLEAR: job-rc,
             job-buser,
             job-sub,
             job-batchsys.
      job-buser = mtab-userid.
      job-date  = mtab-credate.
      job-time  = mtab-cretime.
      job-name  = mtab-groupid.
      job-qid   = mtab-qid.
      jname = mtab-groupid.
      old_qstate = mtab-qstate.
*
      CALL FUNCTION 'JOB_OPEN'
        EXPORTING
          jobgroup         = bi
          jobname          = jname
        IMPORTING
          jobcount         = jnumb
        EXCEPTIONS
          cant_create_job  = 1
          invalid_job_data = 2
          jobname_missing  = 3
          OTHERS           = 99.
      IF sy-subrc EQ 0.
        SUBMIT (subreport)
                     USER mtab-userid
                     VIA JOB mtab-groupid
                         NUMBER jnumb
                     WITH queue_id  EQ mtab-qid
                     WITH mappe     EQ mtab-groupid
                     WITH modus     EQ 'N'
                     WITH logall    EQ 'A'
                     WITH errfend   EQ d0300-errfend
        AND RETURN.

        IF sy-subrc EQ 0.
          CLEAR jobrele.

          CALL FUNCTION 'JOB_CLOSE'
            EXPORTING
              jobcount             = jnumb
              jobname              = jname
              strtimmed            = x
              targetsystem         = target_system
              targetserver         = target_server
              targetgroup          = target_group
              dont_release         = x
            IMPORTING
              job_was_released     = jobrele
            EXCEPTIONS
              cant_start_immediate = 1
              invalid_startdate    = 2
              jobname_missing      = 3
              job_close_failed     = 4
              job_nosteps          = 5
              job_notex            = 6
*             no_release_privilege_given = 7
              invalid_target       = 8
              OTHERS               = 99.
          IF sy-subrc GT 0.
            job-sub = 'CLOSE'.           " fehler bei job_close ?
            job-batchsys = batchsys.
            job-rc  = sy-subrc.
            return  = 390.
          ENDIF.
        ELSE.
          job-sub = 'SUBMIT'.            " fehler bei job submit ?
          job-rc  = sy-subrc.
          return  = 390.
        ENDIF.
      ELSE.
        job-sub = 'OPEN'.              " fehler bei job_open ?
        job-rc  = sy-subrc.
        return  = 390.
      ENDIF.

      IF sy-subrc EQ 0.
        dcount = dcount + 1.
        PERFORM upd_mappen_info USING 'SUBM'.

        CALL FUNCTION 'BP_JOB_RELEASE'
          EXPORTING
            jobname                     = jname
            jobcount                    = jnumb
*          changing
*           ret                         =
          EXCEPTIONS
            missing_jobname             = 1
            missing_jobcount            = 2
            missing_start_date          = 3
            status_not_scheduled        = 4
            cant_enq_job                = 5
            cant_start_job_immediately  = 6
            no_privilege_to_release_job = 7
            cant_release_job            = 8
            job_not_exist               = 9
            job_have_no_steps           = 10
            error_job_modify            = 11
            OTHERS                      = 12.
        IF sy-subrc <> 0.             " job ist nicht freigegeben
          dcount = dcount - 1.
          PERFORM upd_mappen_info USING 'RESE'. " status zuruecksetzen
          job-sub = 'RELEASE'.
          job-rc  = 99.
          return  = 390.
          sy-subrc = 99.
        ENDIF.
      ENDIF.

      PERFORM job_submit_fehler USING 'A'.
    ELSE.
      job-sub = 'LOCK  '.              " Mappe gesperrt
      job-rc  = 9.
    ENDIF.
    PERFORM job_statistik.
    PERFORM dequeue.
  ENDLOOP.                             "  mtab.
*
ENDFORM.                               " submit_mappen.
*/
*---------------------------------------------------------------------*
* FORM : JOB_STATISTIK                                                *
*---------------------------------------------------------------------*
FORM job_statistik .
*
  IF dcount EQ 1.
    REFRESH: job.
    CLEAR:   job.
  ENDIF.
*
  MOVE: sy-uname                 TO job-user,
        bi                       TO job-group,
        jnumb                    TO job-numb,
        sy-uzeit                 TO job-time,
        sy-datum                 TO job-date.
  APPEND job.
*
ENDFORM.                               " JOB_STATISTIK .
*/
*---------------------------------------------------------------------*
* FORM : JOB_SUBMIT_FEHLER
*---------------------------------------------------------------------*
FORM job_submit_fehler USING VALUE(subart).
*
*** fehler bei job_open, submit job oder close_job
*
  IF return EQ 390.                    "job wird gelöscht
    IF job-sub NE 'OPEN'.              "falls angelegt
      CALL FUNCTION 'BP_JOB_DELETE'
        EXPORTING
          jobname    = jname
          jobcount   = jnumb
          forcedmode = x
        EXCEPTIONS
          OTHERS     = 99.
      sy-subrc = 0.
    ENDIF.
  ENDIF.
*
  CASE subart.
    WHEN 'T'.
      IF return EQ 309.
        return = 0.
        MESSAGE i309.
      ENDIF.
    WHEN 'S'.
      IF return EQ 390.
        return = 0.
        MESSAGE e390 WITH job-name.
      ENDIF.
    WHEN OTHERS.
      IF return EQ 390.
        IF job-sub EQ 'CLOSE' AND job-rc EQ 8.
          MESSAGE i690 WITH job-batchsys.
        ELSE.
          MESSAGE i390 WITH job-name.
        ENDIF.
      ENDIF.
  ENDCASE.
*
  return = 388.
*
ENDFORM.                               " JOB_SUBMIT_FEHLER
*/
*---------------------------------------------------------------------*
* FORM : ist_mappe_abspielbar.
*---------------------------------------------------------------------*
FORM ist_mappe_abspielbar.
*
*** nachlesen ob mappe nicht anderweitig abgespielt wird.
*
  CLEAR apqi.
  CLEAR qreturn.
  SELECT SINGLE FOR UPDATE * FROM apqi
  WHERE destsys        =    mtab-destsys      " select single ist n
  AND   destapp        =    mtab-destapp      " fuer eindeutigen statu
  AND   datatyp        =    mtab-datatyp
  AND   groupid        =    mtab-groupid
  AND   progid         =    mtab-progid
  AND   formid         =    mtab-formid
  AND   mandant        =    mtab-mandant
  AND   qattrib        =    mtab-qattrib
  AND   qid            =    mtab-qid.
*
  IF sy-subrc EQ 0.
    IF apqi-qstate(1) NE  ' '   AND    "nur mappen mit
       apqi-qstate(1) NE  'E' .        "status ' ' und 'E'
      qreturn = 309.                   "werden abgespielt
    ENDIF.
  ENDIF.
*
ENDFORM.                               " IST_MAPPE_ABSPIELBAR.
*/
*---------------------------------------------------------------------*
* FORM : fill_itab                                                    *
*---------------------------------------------------------------------*
FORM fill_itab USING mode.
*
  DATA: cnt         LIKE sy-dbcnt,
        string(128).

  CHECK NOT reload_apqi IS INITIAL.

  CLEAR:
    itab_apqi, mtab.
  REFRESH:
    itab_apqi, mtab.

  CALL FUNCTION 'BDC_OBJECT_COUNT'
    EXPORTING
      name            = d0100-mapn
      session_creator = d0100-creator
      datatype        = b_d_c
      client          = sy-mandt
      qstate          = mode
      date_from       = d0100-von
      date_to         = d0100-bis
    IMPORTING
      count           = cnt
    EXCEPTIONS
      OTHERS          = 1.

  IF sy-subrc = 0.
    CLEAR string.
    WRITE cnt TO string LEFT-JUSTIFIED.
    CONCATENATE string TEXT-080 INTO string.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = string.
  ENDIF.

  CALL FUNCTION 'BDC_OBJECT_SELECT'
    EXPORTING
      name            = d0100-mapn
      session_creator = d0100-creator
      datatype        = b_d_c
      client          = sy-mandt
      qstate          = mode
      date_from       = d0100-von
      date_to         = d0100-bis
    TABLES
      apqitab         = itab_apqi
    EXCEPTIONS
      OTHERS          = 1.

  CLEAR reload_apqi.
*
ENDFORM.
*
*---------------------------------------------------------------------*
* FORM : starten_mappe                                                *
*---------------------------------------------------------------------*
FORM starten_mappe.
*
  CLEAR return.
*
  PERFORM enqueue USING mtab-datatyp mtab-groupid mtab-qid.
  qreturn = return.
  IF return GT 0.
    PERFORM send_msg.
    CLEAR return.
    EXIT.
  ENDIF.
*
* nur neue oder fehlerhafte Mappen abspielen
  IF mtab-qstate(1) = ' ' OR
     mtab-qstate(1) = 'E'.
*   prüfen, ob Status noch korrekt ist
    PERFORM ist_mappe_abspielbar.
    IF qreturn = 309.
      PERFORM dequeue.
      return = 309.
    ENDIF.
  ELSE.
    return = 309.
  ENDIF.
*
  CHECK return = 0.

  IF mtab-startdate GE sy-datum.       "Mappe ist gesperrt
    return = 312.
    PERFORM dequeue.
    EXIT.
  ENDIF.
*
  MOVE: space TO d0300-hell,
        space TO d0300-dunkel,
        space TO d0300-error.
*
  PERFORM read_queue_params.
*
  CALL SCREEN 300                      " Aufrufen Startdynpro
       STARTING AT 5 5.
*
  PERFORM dequeue.
*
ENDFORM.                               " starten_mappe.
*/
*---------------------------------------------------------------------*
* FORM : sperren_mappen                                               *
*---------------------------------------------------------------------*
FORM sperren_mappen .
*
  CALL SCREEN 200 STARTING AT 10 10.
*
  IF d0200-fcode = 'SPER'.
    PERFORM upd_mappe.
  ENDIF.
  CLEAR d0200.
*
ENDFORM.                               " sperren_mappen.
*/
*---------------------------------------------------------------------*
* FORM : loeschen_mappen
*---------------------------------------------------------------------*
FORM loeschen_mappen.
*
  DATA: del2btc LIKE apqd_delb.

  DATA:
    np     LIKE sy-dbcnt,
    i_apql LIKE apql OCCURS 0 WITH HEADER LINE.

  CALL SCREEN 1050 STARTING AT 5 5.
  CHECK d1050_fcode = 'SEL'.

  PERFORM looking_for_protokoll.       "gibt es protokolle?
*
  IF log-retc EQ 'PROT'.                                    "ja
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'N'
        textline1     = TEXT-052
        textline2     = TEXT-049
        titel         = TEXT-051
      IMPORTING
        answer        = decision.
*
    CASE decision.
      WHEN 'A'. EXIT.               "Abbrechen
      WHEN 'J'. del_prot = on.      "Protokolle löschen
      WHEN 'N'. del_prot = off.     "Nur Mappen löschen
    ENDCASE.
  ELSE.
    del_prot = off.
  ENDIF.

*   --- zuerst werden die daten (APQD)
*   --- dann   die   info-daten (APQI) geloescht
*   Vorteil: Beim timeout, loeschen von apqd-saetzen,  kann ein
*            zweites mal geloescht werden,
*            da der info-satz immer noch vorhanden ist.
*
  CLEAR: dcount, pcnt#, string1.
*
  LOOP AT mtab.
    PERFORM bim_berechtigung USING bim-dele x.
    IF auth_rc  EQ null.
      PERFORM enqueue USING mtab-datatyp mtab-groupid mtab-qid.
      qreturn = return.
      IF qreturn GT 0.
        PERFORM send_msg.
      ENDIF.
      CHECK qreturn EQ 0.
*
      PERFORM check_batch_jobs.
      IF return EQ 299.
        return = 838.
        PERFORM send_msg.
        dcount = dcount - 1.
        EXIT.
      ENDIF.
*
      PERFORM upd_mappen_info USING 'RELE'.  "infoteil in Bearbeitung
      PERFORM check_batch_authority USING mtab-userid.
      IF btc_auth_rc EQ 0.
        PERFORM dynamic_sql USING 1.
      ELSE.
        qcount = 0.
      ENDIF.
      del2btc = apqd_delb.
      IF qcount GT del2btc.
        string1 = 'IM BATCH'(054).
        PERFORM mappe_loeschen_im_batch.     " loeschen im batch
        return = 304.                  " + eventl. Protokoll
        MOVE 'DAL' TO mod.
        mtab-putactive = 'D'.          "tabelleneintrag als geloescht
        MODIFY mtab.                   "gekennzeichnet
      ELSE.
        PERFORM del_mappe_data_neu.    " loeschen im dialog
        IF return EQ 304.
          DELETE FROM apqi
           WHERE destsys       =   mtab-destsys       "loeschen  mappe
           AND   destapp       =   mtab-destapp       "infoteil
           AND   datatyp       =   mtab-datatyp
           AND   groupid       =   mtab-groupid
           AND   progid        =   mtab-progid
           AND   qid           =   mtab-qid.

          IF sy-subrc NE 0.
            return = 317.
          ELSE.
            IF del_prot EQ on.
              CLEAR np.
              CALL FUNCTION 'BDC_PROTOCOL_SELECT_QID'
                EXPORTING
                  queue_id = mtab-qid
                IMPORTING
                  dbcnt    = np
                TABLES
                  apqltab  = i_apql
                EXCEPTIONS
                  OTHERS   = 1.
              IF sy-subrc = 0.
                LOOP AT i_apql.
                  CALL FUNCTION 'BDC_PROTOCOL_DELETE'
                    EXPORTING
                      temse_id = i_apql-temseid
                    EXCEPTIONS
                      OTHERS   = 1.
                ENDLOOP.
                pcnt# = pcnt# + np.
              ENDIF.
            ENDIF.
            return = 304.
            MOVE 'DAL' TO mod.
            mtab-putactive = 'D'.      "tabelleneintrag als geloescht
            MODIFY mtab.               "gekennzeichnet
          ENDIF.
          PERFORM dequeue.
        ENDIF.
      ENDIF.
*
      IF return = 304.
        COMMIT WORK.
        dcount = dcount + 1.
        IF pcnt# NE 0.
          return = 313.
        ENDIF.
      ENDIF.
    ENDIF.                             " sy-subrc
  ENDLOOP.                             "  mtab.
*
ENDFORM.                               " loeschen_mappen
*/
*---------------------------------------------------------------------*
* FORM :mappen_freigeben.
*---------------------------------------------------------------------*
FORM mappen_freigeben.
*
  IF i_lines > 1.
    d1050_scr = 1051.
    CALL SCREEN 1050 STARTING AT 5 5.
    CHECK d1050_fcode = 'SEL'.
  ENDIF.

  CLEAR: dcount,
         string1.
*
  LOOP AT mtab.
*   CHECK MTAB-QSTATE  EQ  'C' OR
*         MTAB-QSTATE  EQ  'R' OR
*         MTAB-QSTATE  EQ  'S' .
    SELECT SINGLE FOR UPDATE * FROM apqi
    WHERE destsys        =    mtab-destsys      " select single ist n
    AND   destapp        =    mtab-destapp      " fuer eindeutigen statu
    AND   datatyp        =    mtab-datatyp
    AND   groupid        =    mtab-groupid
    AND   progid         =    mtab-progid
    AND   formid         =    mtab-formid
    AND   mandant        =    mtab-mandant
    AND   qattrib        =    mtab-qattrib
    AND   qid            =    mtab-qid.
*
    IF sy-subrc EQ 0.
      IF apqi-qstate(1) NE  'C'   AND  "nur mappen mit
         apqi-qstate(1) NE  'R'   AND  "status 'R' und 'C' und 'S'
         apqi-qstate(1) NE  'S' .
        MESSAGE s327.
        EXIT.
      ENDIF.
    ENDIF.
    PERFORM bim_berechtigung USING bim-free x.
    IF auth_rc  EQ null.
      PERFORM enqueue USING mtab-datatyp mtab-groupid mtab-qid.
      IF return EQ 0.
        PERFORM upd_mappen_info USING 'FREI'.
        dcount = dcount + 1.
      ELSE.
        PERFORM send_msg.
      ENDIF.
    ENDIF.
  ENDLOOP.                             "  mtab.
*
ENDFORM.                               " mappen_freigeben.

*---------------------------------------------------------------------*
* FORM : looking_for_protokoll                                        *
*---------------------------------------------------------------------*
FORM looking_for_protokoll.
*
  LOOP AT mtab.
    SELECT SINGLE * FROM apql WHERE qid = mtab-qid.     "#EC CI_NOFIELD
    IF sy-subrc = 0.
      log-retc = 'PROT'.
      EXIT.
    ENDIF.
  ENDLOOP.
*
ENDFORM.                               " looking_for_protokoll
*/
*---------------------------------------------------------------------*
* FORM : mappeninhalt_drucken                                         *
*---------------------------------------------------------------------*
FORM mappeninhalt_drucken.
*
  DATA: prilen  TYPE i,
        prioff  TYPE i,
        priname LIKE  pri_params-plist,
        pritext LIKE  pri_params-prtxt.

*
  CLEAR: pricnt, prioff, pricnt1, string1.
*
  LOOP AT mtab.
    PERFORM dynamic_sql USING 1.
    pricnt = pricnt + 1.
    priname = mtab-groupid.
    prilen = strlen( mtab-groupid ).
    prioff = 0.
    WRITE mtab-groupid TO pritext+prioff(prilen).
    prioff = prilen .
    prilen = 1.
    WRITE '_' TO pritext+prioff(prilen).
    prioff = prioff + prilen.
    prilen = strlen( mtab-credate ).
    WRITE mtab-credate TO pritext+prioff(prilen).
    prioff = prioff + prilen .
    prilen = 1.
    WRITE '_' TO pritext+prioff(prilen).
    prioff = prioff + prilen.
    prilen = strlen( mtab-cretime ).
    WRITE mtab-cretime TO pritext+prioff(prilen).
*
    CLEAR: valid.
    IF pricnt EQ 1.
      PERFORM print_param USING
        priname
        pritext
        valid
        'X'.                           "dialog
    ELSE.
      PERFORM print_param USING
        priname
        pritext
        valid
        ' '.                           "dialog
    ENDIF.
*
    IF valid NE space.
      pricnt1 = pricnt1 + 1.
      IF qcount LE apqd_drua.
        SUBMIT (drureport)  TO SAP-SPOOL
          AND RETURN
          SPOOL PARAMETERS params
          ARCHIVE PARAMETERS arcparams
          WITHOUT SPOOL DYNPRO
          WITH queue_id EQ mtab-qid.
        GET PARAMETER ID 'SPI' FIELD spoolid.
      ELSE.
        PERFORM mappe_drucken_im_batch.
        string1 = 'IM BATCH'(054).
      ENDIF.
    ENDIF.
*
  ENDLOOP.                             "  mtab.
*
  return = 351.
*
ENDFORM.                               " MAPPENINHALT_DRUCKEN.
*/
*---------------------------------------------------------------------*
* FORM : PRINT_PARAM                                                  *
*---------------------------------------------------------------------*
FORM print_param USING h_name h_text valid dialog.
*
*** Printer-Parameter einstellen
*
  IF dialog NE space.
    CALL FUNCTION 'GET_PRINT_PARAMETERS'
      EXPORTING
*       DESTINATION            = H_PRINTER
        copies                 = count
        list_name              = h_name
        list_text              = h_text
*       IMMEDIATELY            = ' '
*       RELEASE                = ' '
        new_list_id            = 'X'
*       EXPIRATION             = DAYS
        line_size              = 100
*       LINE_COUNT             = 65
*       LAYOUT                 = 'X_PAPER'
        sap_cover_page         = 'D'
*       COVER_PAGE             = 'X'
        receiver               = sy-uname
*       DEPARTMENT             = H_DEPARTMENT
*       NO_DIALOG              = 'X'
      IMPORTING
        out_parameters         = params
        out_archive_parameters = arcparams
        valid                  = valid.
  ELSE.
    CALL FUNCTION 'GET_PRINT_PARAMETERS'
      EXPORTING
        destination            = params-pdest
        copies                 = count
        list_name              = h_name
        list_text              = h_text
*       IMMEDIATELY            = ' '
*       RELEASE                = ' '
        new_list_id            = 'X'
*       EXPIRATION             = DAYS
        line_size              = 100
*       LINE_COUNT             = 65
*       LAYOUT                 = 'X_PAPER'
        sap_cover_page         = 'D'
*       COVER_PAGE             = 'X'
        receiver               = sy-uname
*       DEPARTMENT             = H_DEPARTMENT
        no_dialog              = 'X'
        in_parameters          = params
      IMPORTING
        out_parameters         = params
        out_archive_parameters = arcparams
        valid                  = valid.
  ENDIF.
  COMMIT WORK.
*
ENDFORM.                               "PRINT_PARAM
*
*/
*---------------------------------------------------------------------*
* FORM : upd_mappe                                                    *
*---------------------------------------------------------------------*
FORM upd_mappe.
*
  CLEAR: dcount.
*
  LOOP AT mtab.
    PERFORM bim_berechtigung USING bim-lock x.
    IF auth_rc = null.
      PERFORM enqueue USING mtab-datatyp mtab-groupid mtab-qid.
      qreturn = return.
      IF qreturn GT 0.
        PERFORM send_msg.
      ENDIF.
      CHECK qreturn EQ 0.
      IF mtab-qstate EQ 'E' OR
         mtab-qstate EQ ' ' .
        PERFORM upd_mappen_info USING d1000_fcode.
        dcount = dcount + 1.
      ENDIF.
    ENDIF.                             "sy-subrc
    PERFORM dequeue.
  ENDLOOP.                             "  mtab.
*
ENDFORM.                               " upd_mappe.

*/
*---------------------------------------------------------------------*
* FORM : upd_mappen_info                                              *
*---------------------------------------------------------------------*
FORM upd_mappen_info USING VALUE(uart).
*
*** Aendern einer Batch-Input Mappe
*
  DATA: qstate LIKE mtab-qstate.
*
*--------------------------------------------------update sperren/entsp
  IF uart = 'SPER' OR                  "sperrdatum updaten
     uart = 'ULOC'.                    "sperrdatum = 0 / space
*
    IF d0200-startdate EQ 0.
      MOVE space TO d0200-startdate.
    ENDIF.
    IF mtab-startdate EQ space AND
       uart = 'ULOC'.
      return = 305.
      string = 'ENTSPERRT'(041).
      EXIT.                            "kein update auf db noetig
    ENDIF.
*
    mtab-startdate = d0200-startdate .
    MODIFY mtab.
*
    UPDATE apqi
    SET   startdate     =  d0200-startdate
*
    WHERE destsys       =  mtab-destsys
    AND   destapp       =  mtab-destapp
    AND   datatyp       =  mtab-datatyp
    AND   groupid       =  mtab-groupid
    AND   progid        =  mtab-progid
    AND   formid        =  mtab-formid
    AND   qid           =  mtab-qid.
*
    MOVE mtab-formid TO zw_modp.
*
    IF sy-subrc NE 0.
      return = 327.
    ELSE .
      COMMIT WORK.
      MOVE 'UPD' TO mod.
      CLEAR: string.
      IF d0200-startdate NE 0.
        string = 'GESPERRT'(043).
      ELSE.
        string = 'ENTSPERRT'(041).
      ENDIF.
      return = 305.
    ENDIF.
  ENDIF.
*--------------------------------------------------update freigeben---
  IF uart = 'FREI'.         "mappen als noch zu bearbeiten kennzeich.
*
    PERFORM check_batch_jobs.
    IF return EQ 299.
      PERFORM send_msg.
      dcount = dcount - 1.
      PERFORM dequeue.
      EXIT.
    ENDIF.
*
    PERFORM check_update_requests.
    IF return EQ 839.
      PERFORM send_msg.
      dcount = dcount - 1.
      PERFORM dequeue.
      EXIT.
    ENDIF.
*
    PERFORM check_batch_authority USING mtab-userid.
    IF btc_auth_rc EQ 0.
      PERFORM dynamic_sql USING 1.
    ELSE.
      qcount = 0.
    ENDIF.
    IF qcount GT apqd_dela.
      old_qstate = mtab-qstate.
      PERFORM upd_mappen_info USING 'SUBM'.
      string1 = 'IM BATCH'(054).
      PERFORM mappe_freigeben_im_batch." freigabe im batch
      COMMIT WORK.
      MOVE 'UPD' TO mod.
      CLEAR: string.
      string = 'FREIGEGEBEN'(023).
      return = 305.
      EXIT.
    ENDIF.
*
    CLEAR qstate.
    IF mtab-qstate EQ 'C'.
      qstate = 'C'.
    ENDIF.
    mtab-qstate = space.               " freigabe im dialog
    MODIFY mtab.
*
    PERFORM zaehler_korrigieren.
*
    mtab-putactive = space.
    mtab-putpid = 0.
*
    IF qstate EQ 'C'.                  " mappen in erstellung
      mtab-puttrans = mtab-transcnt.
      mtab-putblock = mtab-transcnt + mtab-msgcnt.
      mtab-putactive = space.
      PERFORM update_create_mode .
    ELSE.                              " mappen in bearbeitung
      PERFORM update_release_mode .
    ENDIF.
*
*
    MOVE mtab-formid TO zw_modp.
*
    IF sy-subrc NE 0 OR
       return EQ 327.
      return = 327.
    ELSE .
      COMMIT WORK.
      MOVE 'UPD' TO mod.
      CLEAR: string.
      string = 'FREIGEGEBEN'(023).
      return = 305.
    ENDIF.
    PERFORM dequeue.
  ENDIF.
*
*--------------------------------------------------update submittet---
  IF uart = 'SUBM'.         "mappen als submittet kennzeichnen
*
    mtab-qstate = 'S'.
    MODIFY mtab.
*
    UPDATE apqi
    SET   qstate        =  mtab-qstate
*
    WHERE destsys       =  mtab-destsys
    AND   destapp       =  mtab-destapp
    AND   datatyp       =  mtab-datatyp
    AND   groupid       =  mtab-groupid
    AND   progid        =  mtab-progid
    AND   formid        =  mtab-formid
    AND   qid           =  mtab-qid.
*
    COMMIT WORK.
*
  ENDIF.                               "subm
*
*--------------------------------------------------update released ---
  IF uart = 'RELE'.         "mappe  als 'in Bearbeitung kennzeichnen
*
    mtab-qstate = 'R'.
    MODIFY mtab.
*
*
    UPDATE apqi
    SET   qstate        =  mtab-qstate
*
    WHERE destsys       =  mtab-destsys
    AND   destapp       =  mtab-destapp
    AND   datatyp       =  mtab-datatyp
    AND   groupid       =  mtab-groupid
    AND   progid        =  mtab-progid
    AND   formid        =  mtab-formid
    AND   qid           =  mtab-qid.
*
    COMMIT WORK.
*
  ENDIF.                               "rele
*
*--------------------------------------------------update reset-------
  IF uart = 'RESE'.         "mappenstatus zuruecksetzen
*
    mtab-qstate = old_qstate.
    MODIFY mtab.
*
*
    UPDATE apqi
    SET   qstate        =  mtab-qstate
*
    WHERE destsys       =  mtab-destsys
    AND   destapp       =  mtab-destapp
    AND   datatyp       =  mtab-datatyp
    AND   groupid       =  mtab-groupid
    AND   progid        =  mtab-progid
    AND   formid        =  mtab-formid
    AND   qid           =  mtab-qid.
*
    COMMIT WORK.
*
  ENDIF.                               "rese
*
ENDFORM.                               " upd_mappe_info.

*/
*---------------------------------------------------------------------*
* FORM : zaehler_korrigieren.                                         *
*---------------------------------------------------------------------*
FORM zaehler_korrigieren.
*
*** Batch-Input Transaktions- und Messagezaehler neu bestimmen
*** nur bei Mappen die freigegeben werden
*
  CLEAR: t,
         apqd,
         mtab-transcnt,
         mtab-msgcnt,
         mtab-transcnte,
         mtab-msgcnte,
         mtab-transcntd,
         mtab-msgcntd,
         mtab-transcntf,
         mtab-msgcntf.
*
  SELECT * FROM apqd
  WHERE qid        =     mtab-qid.
    CHECK apqd-vardata(1) EQ 'S'.
*                          in case of performance: dynamic-sql
    PERFORM dynamic_sql USING 2.
*
    IF apqd-vardata+1(1) = 'E'.
      mtab-transcnte = mtab-transcnte + 1.
      mtab-msgcnte =   mtab-msgcnte + ( t-count - 1 ).
      mtab-transcnt  = mtab-transcnt  + 1.
      mtab-msgcnt  =   mtab-msgcnt  + ( t-count - 1 ).
    ENDIF.
*
    IF apqd-vardata+1(1) = 'F'.
      mtab-transcntf = mtab-transcntf + 1.
      mtab-msgcntf =   mtab-msgcntf + ( t-count - 1 ).
      mtab-transcnt  = mtab-transcnt  + 1.
      mtab-msgcnt  =   mtab-msgcnt  + ( t-count - 1 ).
    ENDIF.
*
    IF apqd-vardata+1(1) = 'S' OR
       apqd-vardata+1(1) = 'D' .
      mtab-transcntd = mtab-transcntd + 1.
      mtab-msgcntd =   mtab-msgcntd + ( t-count - 1 ).
      mtab-transcnt  = mtab-transcnt  + 1.
      mtab-msgcnt  =   mtab-msgcnt  + ( t-count - 1 ).
    ENDIF.
*
    IF apqd-vardata+1(1) = 'B' OR
       apqd-vardata+1(1) = ' ' OR
       apqd-vardata+1(1) = 'C' OR
       apqd-vardata+1(1) = 'R'.
      mtab-transcnt  = mtab-transcnt  + 1.
      mtab-msgcnt  =   mtab-msgcnt  + ( t-count - 1 ).
    ENDIF.
*
  ENDSELECT.
*
ENDFORM.                               " zaehler_korrigieren.
*/
*---------------------------------------------------------------------*
* FORM : update_create_mode .                                         *
*---------------------------------------------------------------------*
FORM update_create_mode .
*
*** Batch-Input Update auf die Tabelle APQI um dei Zaehler neu
*** zu bestimmen     modus   create
*** nur bei Mappen die freigegeben werden
*
  UPDATE apqi
  SET   qstate        =  space
        putactive     =  mtab-putactive
        putpid        =  mtab-putpid
        puttrans      =  mtab-puttrans
        putblock      =  mtab-putblock
        transcnt      =  mtab-transcnt
        msgcnt        =  mtab-msgcnt
        transcnte     =  mtab-transcnte
        msgcnte       =  mtab-msgcnte
        transcntf     =  mtab-transcntf
        msgcntf       =  mtab-msgcntf
        transcntd     =  mtab-transcntd
        msgcntd       =  mtab-msgcntd
*
  WHERE destsys       =  mtab-destsys
  AND   destapp       =  mtab-destapp
  AND   datatyp       =  mtab-datatyp
  AND   groupid       =  mtab-groupid
  AND   progid        =  mtab-progid
  AND   formid        =  mtab-formid
  AND   qid           =  mtab-qid.
*
  IF sy-subrc NE 0 .
    return = 327.
  ELSE.
    return = 0.
  ENDIF.
*
ENDFORM.                               " UPDATE_CREATE_MODE .
*/
*---------------------------------------------------------------------*
* FORM : update_release_mode .                                        *
*---------------------------------------------------------------------*
FORM update_release_mode .
*
*** Batch-Input Update auf die Tabelle APQI um dei Zaehler neu
*** zu bestimmen     modus   create
*** nur bei Mappen die freigegeben werden
*
  UPDATE apqi
  SET   qstate        =  space
        putactive     =  mtab-putactive
        transcnt      =  mtab-transcnt
        msgcnt        =  mtab-msgcnt
        transcnte     =  mtab-transcnte
        msgcnte       =  mtab-msgcnte
        transcntf     =  mtab-transcntf
        msgcntf       =  mtab-msgcntf
        transcntd     =  mtab-transcntd
        msgcntd       =  mtab-msgcntd
*
  WHERE destsys       =  mtab-destsys
  AND   destapp       =  mtab-destapp
  AND   datatyp       =  mtab-datatyp
  AND   groupid       =  mtab-groupid
  AND   progid        =  mtab-progid
  AND   formid        =  mtab-formid
  AND   qid           =  mtab-qid.
*
  IF sy-subrc NE 0.
    return = 327.
  ELSE.
    return = 0.
  ENDIF.
*
ENDFORM.                               " update_release_mode .
*/
*---------------------------------------------------------------------*
* FORM : del_mappe_data_neu                                           *
*---------------------------------------------------------------------*
FORM del_mappe_data_neu.
*
*** Loeschen  einer Batch-Input Mappe    Datenteil
*   in Partitionen  zu jeweils 1000 Sätzen
*
  apqd-trans = 1.
  PERFORM dynamic_sql USING 2.         " ermitteln anzahl saetze/trans.
  IF t-count EQ 0.
    t-count = 10.
  ENDIF.
*
  PERFORM dynamic_sql USING 1.         " ermitteln gesamtanzahl saetze
*
  IF qcount EQ 0.                      " nix da
    return = 304.
    EXIT.
  ENDIF.

  IF qcount LE apqd_dela.              " max. 1000 saetze loeschen
    DELETE FROM apqd
    WHERE qid   =    mtab-qid.         " loeschen einer mappe

    IF sy-subrc NE 0.
      return = 317.
    ELSE.
      MOVE 'DEL' TO mod.
      return = 304.
      COMMIT WORK.
    ENDIF.
  ELSE.
    CLEAR: anal.
    anal-fkt1 = apqd_dela / t-count.   "blockfaktor
    IF anal-fkt1 LE 0.
      anal-fkt1 = 1.
    ENDIF.
*
*     timeout bei delete abfangen
*     verhindern dass das rollbacksegment der DB platzt
*     durch commit work
    DO.                                "timeout bei delete abfangen
      anal-count = anal-count + 1.     " partitionierung der mappe
      IF anal-count EQ 1.
        anal-ba = 1.
      ELSE.
        anal-ba = anal-be.
      ENDIF.

      anal-be = anal-be + anal-fkt1.
      IF anal-be GT qcount.
        anal-be = qcount.
      ENDIF.

      DELETE FROM apqd                 " loeschen einer mappe
      WHERE qid   =    mtab-qid
      AND   trans BETWEEN  anal-ba AND anal-be.

      IF sy-subrc NE 0.
*         RETURN = 317.
      ELSE.
*         RETURN = 304.
        COMMIT WORK.
      ENDIF.

      IF anal-be GE qcount.
        EXIT.
      ENDIF.
    ENDDO.

    qcount = 0.
    PERFORM dynamic_sql USING 1.       " ermitteln gesamtanzahl saetze
    IF qcount GT 0.                    " nachlesen
*       RETURN = 317.
      DELETE FROM apqd
      WHERE qid   =    mtab-qid.       " loeschen einer mappe
      IF sy-subrc NE 0.                " endgültig  !!!!
        return = 317.
      ELSE.
        MOVE 'DEL' TO mod.
        return = 304.
        COMMIT WORK.
      ENDIF.
    ELSE.
      MOVE 'DEL' TO mod.
      return = 304.
      sy-subrc = 0.
    ENDIF.
  ENDIF.
*
ENDFORM.                               " del_mappe_data_neu.

*---------------------------------------------------------------------*
* FORM : send_msg                                                     *
*---------------------------------------------------------------------*
FORM send_msg.
*
  CASE return.
    WHEN 0.
*
    WHEN 299.      " Freigabe nicht möglich:
      " Für Mappe & existiert noch ein Hintergrund-Job
      MESSAGE i299 WITH string
                        string1
                        string2
                        string3.
    WHEN 304.                          " $ Mappe(n)  geloescht
      MESSAGE s304 WITH dcount string1.
      CLEAR: dcount.
    WHEN 305.       " $ Mappe(n) wurden gesperrt/entsperrt.
      MESSAGE s305 WITH  dcount string string1.
      CLEAR: dcount.
    WHEN 317.      " Fehler beim 'LOESCHEN' der Mappe 'TAB-MAPN'.
      MESSAGE s307 WITH 'LOESCHEN'(032) mtab-groupid  zw_modp.
    WHEN 327.      " Fehler beim 'AENDERN' der Mappe 'TAB-MAPN'.
      MESSAGE s307 WITH 'AENDERN'(047)  mtab-groupid  zw_modp.
    WHEN 309.      " Die angeforderte Mappe ist belegt
      MESSAGE s309.
    WHEN 312.       " System beschaeftigt, bitte warten
      MESSAGE s312.
    WHEN 313.       " $ Mappe(n) und Protokoll geloescht
      MESSAGE s313 WITH dcount string1.
      CLEAR: dcount.
    WHEN 322.      " Mappe & geschützt durch Benutzer &
      MESSAGE i322 WITH enq-mappe '-' enq-user.
    WHEN 351.                          " mappen werden gedruckt
      MESSAGE s351 WITH pricnt1 string1.
    WHEN 353.                          " systemfehler beim enqueue
      MESSAGE i353 WITH enq-mappe.
    WHEN 388.      " $ Mappen werden im Hintergrund abgespielt
      MESSAGE s388 WITH dcount.
      CLEAR: dcount.
    WHEN 390.                          " Fehler bei Submit.........
      " wird anderweitig abgehandelt
    WHEN 838.      " Löschen nicht möglich:
      " Für Mappe & existiert noch ein Hintergrund-Job
      MESSAGE i838 WITH string
                        string1
                        string2
                        string3.
    WHEN 839.      " Freigabe nicht möglich:
      " Es existiert noch ein Verbuchungsauftrag
      MESSAGE i839 WITH string
                        string1
                        string2
                        string3.
    WHEN OTHERS.
      MESSAGE s399.
  ENDCASE.
*
  CLEAR: return.
*
ENDFORM.                               " send_msg.

*---------------------------------------------------------------------*
*       FORM bim_berechtigung                                         *
*---------------------------------------------------------------------*
FORM bim_berechtigung USING aktivity
                            msgart.
*
  DATA: o_aktivity(4).
*
  CLEAR: auth_rc.
*
  AUTHORITY-CHECK OBJECT 'S_BDC_MONI'
              ID 'BDCAKTI'     FIELD aktivity
              ID 'BDCGROUPID'  FIELD mtab-groupid.
*
  IF sy-subrc > 0.
    auth_rc = sy-subrc.
*
    IF mtab-creator EQ sy-uname. "eigene Mappe?
*     Zusätzliche Berechtigungsprüfung auf BDCAKTI beginnend mit
*     O und den ersten drei Buchstaben der Benutzer-Aktivität
      o_aktivity = aktivity.
      SHIFT o_aktivity BY 1 PLACES RIGHT.
      o_aktivity+0(1) = 'O'.
*
      AUTHORITY-CHECK OBJECT 'S_BDC_MONI'
                  ID 'BDCAKTI'     FIELD o_aktivity
                  ID 'BDCGROUPID'  FIELD mtab-groupid.
*
      auth_rc = sy-subrc.
    ENDIF.
  ENDIF.
*
  IF auth_rc > 0.
    CASE aktivity.
      WHEN bim-aonl.         "keine berechtig. fuer abspielen/onl
        MESSAGE e391 WITH mtab-groupid.
      WHEN bim-abtc.         "keine berechtig. fuer abspielen/btc
        IF msgart EQ e.
          MESSAGE e392 WITH mtab-groupid.
        ELSE.
          MESSAGE i392 WITH mtab-groupid.
        ENDIF.
      WHEN bim-free.                   "keine berechtig. fuer freigeben
        MESSAGE i393 WITH mtab-groupid.
      WHEN bim-lock.         "keine berechtig. fuer sperren/entsp.
        MESSAGE i394 WITH mtab-groupid.
      WHEN bim-dele.                   "keine berechtig. fuer loeschen
        MESSAGE i395 WITH mtab-groupid.
      WHEN bim-anal.                   "keine berechtig. fuer analyse
        MESSAGE s396 WITH mtab-groupid.
    ENDCASE.
  ENDIF.
*
ENDFORM.                               "bim_berechtigung
*/
*---------------------------------------------------------------------*
*       FORM dynamic_sql                                              *
*---------------------------------------------------------------------*
FORM dynamic_sql      USING acces.
*
*  vh said: in case of performance: dynamic-sql
*
*  es says: yeah, open sql is now as fast as can be ... and not as prone
*           to typos.

  CASE acces.

    WHEN 1.                            "ermitteln anzahl apqd-saetze
*     exec sql.
*        select count(*) from apqd
*        where qid = :mtab-qid
*        into :qcount
*      endexec.
      SELECT COUNT(*) FROM apqd INTO qcount WHERE qid = mtab-qid.

    WHEN 2.                            "ermitteln anzahl apqd-saetze
*      exec sql.
*        select count(*) from apqd
*        where qid   = :mtab-qid
*        and   trans = :apqd-trans
*        into :t-count
*      endexec.
      SELECT COUNT(*) FROM apqd INTO t-count
        WHERE qid = mtab-qid AND trans = apqd-trans.
  ENDCASE.
*
ENDFORM.                               "dynamic_sql
*/
*---------------------------------------------------------------------*
*       FORM queue_error                                              *
*---------------------------------------------------------------------*
FORM queue_error.
*
*       auswerten eines queue_fehlers                                 *
*
  CASE sy-subrc.
    WHEN 1.
      MESSAGE a208 WITH TEXT-055.
    WHEN 2.
      MESSAGE a208 WITH TEXT-056.
    WHEN 3.
      MESSAGE a208 WITH TEXT-057.
    WHEN 4.
      MESSAGE a208 WITH TEXT-058.
    WHEN 5.
      MESSAGE a208 WITH TEXT-059.
    WHEN 6.
      MESSAGE a208 WITH TEXT-060.
    WHEN OTHERS.
      MESSAGE a208 WITH TEXT-061.
  ENDCASE.
*
ENDFORM.                               "QUEUE_ERROR.
*/
*---------------------------------------------------------------------*
* FORM : mappe_freigeben_im_batch
*---------------------------------------------------------------------*
FORM  mappe_freigeben_im_batch.
*
*** Submit von Mappen in den Hintergrund (mit Batch).
*
  DATA: rel_mode(1) VALUE 'F'.
*
  CLEAR: string,                  " Variabler Teil der Fehlermeldung
         jnumb,
         return,
         bdcount,
         batchsys.
*
  MOVE ' SUBMIT ' TO string.
*
  CLEAR: job-rc,
         job-sub.
  jname = mtab-groupid.
  job-buser = mtab-userid.
  job-date  = mtab-credate.
  job-time  = mtab-cretime.
  job-name  = mtab-groupid.
  job-qid   = mtab-qid.
*
  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobgroup         = bi
      jobname          = jname
    IMPORTING
      jobcount         = jnumb
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 99.
  IF sy-subrc EQ 0.                    " fehler bei job_open ?
    IF old_qstate EQ 'C'.
      rel_mode = 'C'. "freigeben einer Mappe aus 'in Erstellung'
    ELSE.
      rel_mode = 'F'.
    ENDIF.
    SUBMIT (subreport)
                 USER mtab-userid
                 VIA JOB    jname
                     NUMBER jnumb
                 WITH queue_id  EQ mtab-qid
                 WITH mappe     EQ mtab-groupid
                 WITH modus     EQ rel_mode
                 WITH logall    EQ space
                 WITH errfend   EQ space
    AND RETURN.

    IF sy-subrc EQ 0.
      CLEAR jobrele.
      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobcount             = jnumb
          jobname              = jname
          strtimmed            = x
          targetsystem         = batchsys
        IMPORTING
          job_was_released     = jobrele
        EXCEPTIONS
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
*         no_release_privilege_given = 7
          OTHERS               = 99.
      IF sy-subrc GT 0.                  " fehler bei job_close ?
        job-sub = 'CLOSE'.
        job-rc  = sy-subrc.
        return  = 390.
      ELSE.
        IF jobrele NE x.                 " job ist nicht freigegeben
          job-sub = 'CLOSE'.
          job-rc  = 99.
          return  = 390.
          sy-subrc = 99.
        ENDIF.
      ENDIF.
    ELSE.
      job-sub = 'SUBMIT'.                " fehler bei submit job ?
      job-rc  = sy-subrc.
      return  = 390.
    ENDIF.
  ELSE.
    job-sub = 'OPEN'.
    job-rc  = sy-subrc.
    return  = 390.
  ENDIF.

  IF sy-subrc EQ 0.
    bdcount = bdcount + 1.
  ENDIF.
  PERFORM job_statistik.
  PERFORM job_submit_fehler USING 'S'.
*
  IF bdcount GT 0.
    return = 305.
  ENDIF.
*
ENDFORM.                               " mappe_freigeben_im_batch
*/
*---------------------------------------------------------------------*
* FORM : mappe_loeschen_im_batch
*---------------------------------------------------------------------*
FORM  mappe_loeschen_im_batch.
*
  DATA: delmod(01).
*
  CLEAR: string,                  " Variabler Teil der Fehlermeldung
         jnumb,
         return,
         bdcount,
         batchsys.
*
  MOVE ' SUBMIT ' TO string.
*
  IF del_prot EQ on.                   " geloescht werden --->
    delmod = 'P'.                      " protokoll und mappe
  ELSE.
    delmod = 'D'.                      " nur mappe
  ENDIF.
*
  CLEAR: job-rc,
         job-sub.
  jname = mtab-groupid.
  job-buser = mtab-userid.
  job-date  = mtab-credate.
  job-time  = mtab-cretime.
  job-name  = mtab-groupid.
  job-qid   = mtab-qid.
*
  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobgroup         = bi
      jobname          = jname
    IMPORTING
      jobcount         = jnumb
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 99.
  IF sy-subrc EQ 0.                    " fehler bei job_open ?
    SUBMIT (subreport)
                 USER mtab-userid
                 VIA JOB    jname
                     NUMBER jnumb
                 WITH queue_id  EQ mtab-qid
                 WITH mappe     EQ mtab-groupid
                 WITH modus     EQ delmod        " 'D' - Mappe
                 WITH logall    EQ space         " 'P' - Map+Prot
                 WITH errfend   EQ space
    AND RETURN.

    IF sy-subrc EQ 0.
      CLEAR jobrele.
      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobcount             = jnumb
          jobname              = jname
          strtimmed            = x
          targetsystem         = batchsys
        IMPORTING
          job_was_released     = jobrele
        EXCEPTIONS
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
*         no_release_privilege_given = 7
          OTHERS               = 99.
      IF sy-subrc GT 0.                  " fehler bei job_close ?
        job-sub = 'CLOSE'.
        job-rc  = sy-subrc.
        return  = 390.
      ELSE.
        IF jobrele NE x.                 " job ist nicht freigegeben
          job-sub = 'CLOSE'.
          job-rc  = 99.
          return  = 390.
          sy-subrc = 99.
        ENDIF.
      ENDIF.
    ELSE.
      job-sub = 'SUBMIT'.                " fehler bei submit job ?
      job-rc  = sy-subrc.
      return  = 390.
    ENDIF.
  ELSE.
    job-sub = 'OPEN'.
    job-rc  = sy-subrc.
    return  = 390.
  ENDIF.

  IF sy-subrc EQ 0.
    bdcount = bdcount + 1.
  ENDIF.
  PERFORM job_statistik.
  PERFORM job_submit_fehler USING 'S'.
*
  IF bdcount GT 0.
    return = 304.
  ENDIF.
*
ENDFORM.                               " mappe_freigeben_im_batch
*/
*---------------------------------------------------------------------*
* FORM : mappe_drucken_im_batch
*---------------------------------------------------------------------*
FORM  mappe_drucken_im_batch.
*
  CLEAR: string,                  " Variabler Teil der Fehlermeldung
         jnumb,
         return,
         bdcount,
         batchsys.
*
  MOVE ' DRUCKEN' TO string.
*
  CLEAR: job-rc,
         job-sub.
  jname = mtab-groupid.
  job-buser = sy-uname.           "Correction of Note 1558752
  job-date  = mtab-credate.
  job-time  = mtab-cretime.
  job-name  = mtab-groupid.
  job-qid   = mtab-qid.
*
  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobgroup         = bi
      jobname          = jname
    IMPORTING
      jobcount         = jnumb
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 99.
  IF sy-subrc EQ 0.                    " fehler bei job_open ?
    SUBMIT (drureport)
                 TO SAP-SPOOL WITHOUT SPOOL DYNPRO
                 SPOOL PARAMETERS params
                 ARCHIVE PARAMETERS arcparams
                 USER sy-uname         "Correction of Note 1558752
                 VIA JOB    jname
                     NUMBER jnumb
                 WITH queue_id EQ mtab-qid
    AND RETURN.

    IF sy-subrc EQ 0.
      CLEAR jobrele.
      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobcount             = jnumb
          jobname              = jname
          strtimmed            = x
          targetsystem         = batchsys
        IMPORTING
          job_was_released     = jobrele
        EXCEPTIONS
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
*         no_release_privilege_given = 7
          OTHERS               = 99.
      IF sy-subrc GT 0.                  " fehler bei job_close ?
        job-sub = 'CLOSE'.
        job-rc  = sy-subrc.
        return  = 390.
      ELSE.
        IF jobrele NE x.                 " job ist nicht freigegeben
          job-sub = 'CLOSE'.
          job-rc  = 99.
          return  = 390.
          sy-subrc = 99.
        ENDIF.
      ENDIF.
    ELSE.
      job-sub = 'SUBMIT'.                " fehler bei submit job ?
      job-rc  = sy-subrc.
      return  = 390.
    ENDIF.
  ELSE.
    job-sub = 'OPEN'.
    job-rc  = sy-subrc.
    return  = 390.
  ENDIF.

  bdcount = bdcount + 1.
  PERFORM job_statistik.
*
ENDFORM.                               " mappe_drucken_im_batch
*/
*---------------------------------------------------------------------*
* FORM : GET_BTC_SYSTEMS                                              *
*---------------------------------------------------------------------*
FORM get_btc_systems USING rc.

  DATA: BEGIN OF sys_tabl OCCURS 50.
          INCLUDE STRUCTURE msxxlist.
        DATA: END OF sys_tabl.

  DATA:
    batch              LIKE msxxlist-msgtypes VALUE 8,
    batch_server_found TYPE i,
    num_lines          TYPE i.

  FREE sys_tabl.
*
* Liste aller Batchinstanzen (beim Messageserver) abholen
*
  CALL FUNCTION 'TH_SERVER_LIST'
    EXPORTING
      services = batch
    TABLES
      list     = sys_tabl
    EXCEPTIONS
      OTHERS   = 99.

  IF sy-subrc <> 0.
    rc = 1. " Liste kann nicht beschafft werden
    EXIT.
  ENDIF.

  DESCRIBE TABLE sys_tabl LINES num_lines.

  IF num_lines EQ 0.
    rc = 4.                            " keine Batchserver vorhanden
    EXIT.
  ENDIF.

  SORT sys_tabl BY name ASCENDING.

  FREE btc_sys_tbl.
  LOOP AT sys_tabl.
    btc_sys_tbl-btcsystem = sys_tabl-host.
    btc_sys_tbl-instname  = sys_tabl-name.
    APPEND btc_sys_tbl.
  ENDLOOP.

  rc = 0.

ENDFORM.                               " GET_BTC_SYSTEMS

*---------------------------------------------------------------------*
* FORM : check_batch_authority                                        *
*---------------------------------------------------------------------*
* Es wird vorab geprüft ob ein Report im Batch laufen kann.           *
* Regeln:                                                             *
* 1.Benutzer(sy-uname) ungleich Batch-Benutzer                        *
*   - auth check                                                      *
*   - Batch-Benutzer existiert                                        *
* 2.Batch-Benutzer  darf Job einplanen                                *
* 3.Batch-Benutzer  darf Job freigeben                                *
*---------------------------------------------------------------------*
FORM check_batch_authority USING auth_user.
*
  DATA: auth_field1 LIKE tobj-fiel1,
        auth_field2 LIKE tobj-fiel1,
        auth_field3 LIKE tobj-fiel1,
        auth_value1 LIKE xu180-value,
        auth_value2 LIKE xu180-value,
        auth_value3 LIKE xu180-value,
*       AUTH_USER   LIKE USR04-BNAME,
        auth_object LIKE usr12-objct.
*
  CLEAR btc_auth_rc.

  CLEAR:auth_field1,
        auth_value1,
        auth_field2,
        auth_value2,
        auth_field3,
        auth_value3.

* 1.Benutzer(sy-uname) ungleich Batch-Benutzer                        *

  SELECT SINGLE * FROM usr02
    WHERE bname = auth_user.

  IF sy-subrc GT 0.
    btc_auth_rc = btc_auth_rc + 1.
    EXIT.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'S_BTCH_NAM'
            ID 'BTCUNAME'    FIELD auth_user.
  IF sy-subrc NE 0.
    btc_auth_rc = btc_auth_rc + 1.
    EXIT.
  ENDIF.
*
*   Batch-Benutzer  hat Administrationsberechtigung                   *

  auth_object = 'S_BTCH_ADM'.
  auth_field1 = 'BTCADMIN'.
  auth_value1 = 'Y'.

  CALL FUNCTION 'AUTHORITY_CHECK'      " Jobs einplanen
    EXPORTING
      field1             = auth_field1
      field2             = auth_field2
      field3             = auth_field3
      object             = auth_object
      user               = auth_user
      value1             = auth_value1
      value2             = auth_value2
      value3             = auth_value3
    EXCEPTIONS
      user_is_authorized = 1
      OTHERS             = 99.

  IF sy-subrc EQ 0.
    btc_auth_rc = 0.
    EXIT.
  ELSE.
    sy-subrc = 0.
  ENDIF.
*
* 2.Batch-Benutzer  darf Job einplanen                                *

  auth_object = 'S_BTCH_JOB'.
  auth_field1 = 'JOBGROUP'.
  auth_value1 = '*'.
  auth_field2 = 'JOBACTION'.

  auth_value2 = 'PLAN'.

  CALL FUNCTION 'AUTHORITY_CHECK'      " Jobs einplanen
    EXPORTING
      field1             = auth_field1
      field2             = auth_field2
      field3             = auth_field3
      object             = auth_object
      user               = auth_user
      value1             = auth_value1
      value2             = auth_value2
      value3             = auth_value3
    EXCEPTIONS
      user_is_authorized = 1
      OTHERS             = 99.

  IF sy-subrc NE 1.
    btc_auth_rc = btc_auth_rc + 1.
    EXIT.
  ENDIF.
*
* 3.Batch-Benutzer  darf Job freigeben                                *

  auth_value2 = 'RELE'.

  CALL FUNCTION 'AUTHORITY_CHECK'      " Jobs ausführen
    EXPORTING
      field1             = auth_field1
      field2             = auth_field2
      field3             = auth_field3
      object             = auth_object
      user               = auth_user
      value1             = auth_value1
      value2             = auth_value2
      value3             = auth_value3
    EXCEPTIONS
      user_is_authorized = 1
      OTHERS             = 99.

  IF sy-subrc NE 1.
    btc_auth_rc = btc_auth_rc + 1.
    EXIT.
  ENDIF.
*
ENDFORM.                               " CHECK_BATCH_AUTHORITY .
*/
*---------------------------------------------------------------------*
* FORM : enqueue                                                      *
*---------------------------------------------------------------------*
* sperren einer qid gegen weitere verarbeitung                        *
*---------------------------------------------------------------------*
FORM enqueue   USING    bityp
                        bigroup
                        object .
*
  CLEAR enq.

  IF noenqueue GT 0.
    EXIT.
  ENDIF.

  enq-datatyp = bityp.
  enq-groupid = bigroup.
  enq-object  = object.

  CLEAR return.
*
  CALL FUNCTION 'ENQUEUE_BDC_QID'
    EXPORTING
      datatyp        = enq-datatyp
      groupid        = enq-groupid
      qid            = enq-object
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 99.
*
  enq-rc    = sy-subrc.
  enq-mappe = mtab-groupid.
  enq-user  = sy-msgv1.
*
  CASE enq-rc.
    WHEN 0.
      return = 0.
    WHEN 1.
      return = 322.
    WHEN OTHERS.
      return = 353.
  ENDCASE.
*
ENDFORM.                               " ENQUEUE_OBJECT_QID
*/
*---------------------------------------------------------------------*
* FORM : dequeue                                                      *
*---------------------------------------------------------------------*
* entsperren einer qid für weitere verarbeitung                       *
*---------------------------------------------------------------------*
FORM dequeue .
*
  IF noenqueue GT 0.
    EXIT.
  ENDIF.
*
  CALL FUNCTION 'DEQUEUE_BDC_QID'
    EXPORTING
      datatyp = enq-datatyp
      groupid = enq-groupid
      qid     = enq-object.
*
ENDFORM.                               " DEQUEUE
*/
*---------------------------------------------------------------------*
* FORM : mappe_importieren                                            *
*---------------------------------------------------------------------*
FORM mappe_importieren .
*
  DATA:  session_name LIKE apqi-groupid.
  FIELD-SYMBOLS <z>.
*
  ASSIGN sy-datlo+2(*) TO <z>.
  session_name = <z>.
* WRITE SY-DATLO TO SESSION_NAME(12).

  SUBMIT (datreport)   VIA SELECTION-SCREEN
                   WITH import    EQ x
                   WITH export    EQ space
                   WITH mappe     EQ x
                   WITH record    EQ space
                   WITH session   EQ session_name
          AND RETURN.
*
ENDFORM.                               "  mappe_importieren
*/
*---------------------------------------------------------------------*
* FORM : mappe_exportieren                                            *
*---------------------------------------------------------------------*
FORM mappe_exportieren .
*
  DATA: session_name LIKE apqi-groupid,
        session_qid  LIKE apqi-qid.
*
  IF screen# EQ 100.
    session_name = star.
    session_qid  = 0.
  ENDIF.
*
  IF screen# EQ 120.
    session_name = mtab-groupid.
    session_qid  = mtab-qid.
  ENDIF.
*
  SUBMIT (datreport)  VIA SELECTION-SCREEN
                   WITH import    EQ space
                   WITH export    EQ x
                   WITH mappe     EQ x
                   WITH record    EQ space
                   WITH session   EQ session_name
                   WITH queue_id  EQ session_qid
   AND RETURN.
*
*
ENDFORM.                               "  mappe_importieren
*
*&---------------------------------------------------------------------*
*&      Form  PRINT_ALV_LIST
*&---------------------------------------------------------------------*
*  LIST_BDCLD mit ABAP List Viewer im Bildschirm angezeigt und drucken
*----------------------------------------------------------------------*
FORM print_alv_list.
* Data declaration
  TYPE-POOLS: slis.

  DATA:   gt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA:   gs_print TYPE slis_print_alv.
  DATA:   g_repid LIKE sy-repid.
  DATA:   gt_outtab  TYPE s_itab_apqi OCCURS 0 WITH HEADER LINE.
  DATA:   gs_variant LIKE disvariant.
  DATA:   g_save(1) TYPE c.
*
  g_repid = sy-repid.
  gt_outtab[] = itab_apqi[].
*
*  gs_print-print              = 'X'.   "nur drucken
*  gs_print-no_coverpage       = 'X'.   "keine Statistik
  gs_print-no_print_listinfos = 'X'.   "    -"-
*
  g_save              = 'A'.
  gs_variant-report   = sy-repid.
  gs_variant-username = sy-uname.
*
  PERFORM fieldcat_init USING gt_fieldcat[].
*
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = g_repid
      it_fieldcat        = gt_fieldcat[]
      is_print           = gs_print
      i_save             = g_save
      is_variant         = gs_variant
    TABLES
      t_outtab           = gt_outtab.
*
ENDFORM.                               " PRINT_ALV_LIST
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Initialization fieldcatalog
*---------------------------------------------------------------------*
FORM fieldcat_init
      USING rt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA: pos TYPE i VALUE 1.

* Initialization of fields and attributes to structure field

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'GROUPID'.
  ls_fieldcat-datatype        = 'CHAR12'.
  ls_fieldcat-outputlen       =  12.
  ls_fieldcat-seltext_s       =  'Mappe'(015).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'CREATOR'.
  ls_fieldcat-datatype        = 'CHAR12'.
  ls_fieldcat-outputlen       =  12.
  ls_fieldcat-seltext_s       = 'Ersteller'(073).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'CREDATE'.
  ls_fieldcat-datatype        = 'DATS'.
  ls_fieldcat-outputlen       =  10.
  ls_fieldcat-seltext_s       =  TEXT-016. "Datum
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'CRETIME'.
  ls_fieldcat-datatype        = 'TIMS'.
  ls_fieldcat-outputlen       =  8.
  ls_fieldcat-seltext_s       =  'Zeit'(017).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'PROGID'.
  ls_fieldcat-datatype        = 'CHAR40'.
  ls_fieldcat-outputlen       =  12.
  ls_fieldcat-seltext_s       =  'Programm'(076).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'STARTDATE'.
  ls_fieldcat-datatype        = 'DATS'.
  ls_fieldcat-outputlen       =  8.
  ls_fieldcat-seltext_s       =  'Sperre'(074).
  ls_fieldcat-seltext_m       =  'gesperrt bis'(020).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'USERID'.
  ls_fieldcat-outputlen       =  12.
  ls_fieldcat-seltext_s       =  'Berechtigung'(034).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'STATUS_TEXT'.
  ls_fieldcat-outputlen       =  16.
  ls_fieldcat-seltext_s       =  'Status'(007).
* wegen ALV-Filter
  ls_fieldcat-lowercase       =  'X'.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'TRANSCNT'.
  ls_fieldcat-datatype        = 'INT4'.
  ls_fieldcat-outputlen       =  10.
  ls_fieldcat-seltext_s       =  'Trans.'(018).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'TRANSCNTE'.
  ls_fieldcat-datatype        = 'INT4'.
  ls_fieldcat-outputlen       =  10.
  ls_fieldcat-seltext_s       =  'fehlerhaft'(035).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'TRANSCNTF'.
  ls_fieldcat-datatype        = 'INT4'.
  ls_fieldcat-outputlen       =  10.
  ls_fieldcat-seltext_s       =  'verarbeitet'(037).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'MSGCNT'.
  ls_fieldcat-datatype        = 'INT4'.
  ls_fieldcat-outputlen       =  10.
  ls_fieldcat-seltext_s       =  'Dynpros'(019).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'QERASE'.
  ls_fieldcat-outputlen       =  1.
  ls_fieldcat-seltext_s       =  'löschen'(032).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos         =  pos.
  ls_fieldcat-fieldname       = 'QID'.
  ls_fieldcat-outputlen       =  20.
  ls_fieldcat-seltext_s       =  'Queue ID'(075).
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  pos = pos + 1.


ENDFORM.                               " fieldcat_init
*
*&---------------------------------------------------------------------*
*&      Form  read_queue_params
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*  get flag opt_simubatch from queue transaction header
*----------------------------------------------------------------------*
FORM read_queue_params.
  DATA: pos TYPE i,
        len TYPE i,
        th  TYPE bdcth,
        ctp TYPE ctu_params.

* read only first transaction header (block = 1)
  SELECT SINGLE * FROM apqd WHERE qid = mtab-qid AND block = 1.
  IF sy-subrc = 0.
    DESCRIBE DISTANCE BETWEEN th-mtype AND th-reser
      INTO pos IN CHARACTER MODE. "char position of BDCTH-RESER
    DESCRIBE FIELD ctp LENGTH len IN CHARACTER MODE.
    pos = pos + len.              "add offset CTU_PARAMS in RESER
    IF apqd-vardata+pos(1) = 'J'. "Batch 'J'ob simulation?
      opt_simubatch = 'X'.
    ELSE.
      opt_simubatch = space.
    ENDIF.
  ENDIF.
ENDFORM.                    " read_queue_params
*
*&---------------------------------------------------------------------*
*&      Form  check_batch_jobs
*&---------------------------------------------------------------------*
*  check batch jobs for existing RSBDCBTC step with actual QID
*----------------------------------------------------------------------*
FORM check_batch_jobs.
  DATA: jobsel_param  TYPE btcselect,
        var_program   TYPE syrepid,
        var_variant   TYPE syslset,
        job_exists(1) VALUE 'F'.

  DATA: joblist      LIKE tbtcjob  OCCURS 0 WITH HEADER LINE,
        steplist     LIKE tbtcstep OCCURS 0 WITH HEADER LINE,
        var_valuetab LIKE rsparams OCCURS 0 WITH HEADER LINE.

  CLEAR jobsel_param.
  jobsel_param-jobname   = mtab-groupid.
  jobsel_param-username  = '*'.
  jobsel_param-abapname  = 'RSBDCBTC*'.

  jobsel_param-prelim   = 'X'.
  jobsel_param-schedul  = 'X'.
  jobsel_param-ready    = 'X'.
  jobsel_param-running  = 'X'.
  jobsel_param-finished = ' '.
  jobsel_param-aborted  = 'X'.

  REFRESH joblist.
  CALL FUNCTION 'BP_JOB_SELECT'
    EXPORTING
      jobselect_dialog    = 'N'
      jobsel_param_in     = jobsel_param
*     ENDDATE             = '        '
*     ENDTIME             = '      '
*   IMPORTING
*     JOBSEL_PARAM_OUT    =
    TABLES
      jobselect_joblist   = joblist
    EXCEPTIONS
      invalid_dialog_type = 1
      jobname_missing     = 2
      no_jobs_found       = 3
      selection_canceled  = 4
      username_missing    = 5
      OTHERS              = 6.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  LOOP AT joblist.
    IF job_exists = 'T'.
      EXIT.
    ENDIF.

    REFRESH steplist.
    CALL FUNCTION 'BP_JOB_READ'
      EXPORTING
        job_read_jobcount     = joblist-jobcount
        job_read_jobname      = joblist-jobname
        job_read_opcode       = 20  " BTC_READ_ALL_JOBDATA
*     IMPORTING
*       JOB_READ_JOBHEAD      =
      TABLES
        job_read_steplist     = steplist
      EXCEPTIONS
        invalid_opcode        = 1
        job_doesnt_exist      = 2
        job_doesnt_have_steps = 3
        OTHERS                = 4.
    IF sy-subrc EQ 0.
      LOOP AT steplist.
        IF job_exists = 'T'.
          EXIT.
        ENDIF.

        IF steplist-program = 'RSBDCBTC'
        OR steplist-program = 'RSBDCBTC_SUB'.
          REFRESH var_valuetab.

          var_program = steplist-program.
          var_variant = steplist-parameter.

          CALL FUNCTION 'RS_VARIANT_CONTENTS'
            EXPORTING
              report               = var_program
              variant              = var_variant
*             MOVE_OR_WRITE        = 'W'
*             NO_IMPORT            = ' '
              execute_direct       = 'X'
*           IMPORTING
*             SP                   =
            TABLES
*             L_PARAMS             =
*             L_PARAMS_NONV        =
*             L_SELOP              =
*             L_SELOP_NONV         =
              valutab              = var_valuetab
*             OBJECTS              =
*             FREE_SELECTIONS_DESC =
*             FREE_SELECTIONS_VALUE       =
            EXCEPTIONS
              variant_non_existent = 1
              variant_obsolete     = 2
              OTHERS               = 3.
          IF sy-subrc EQ 0.
            LOOP AT var_valuetab.
              IF var_valuetab-selname EQ 'QUEUE_ID'.
                IF var_valuetab-low EQ mtab-qid.
                  job_exists = 'T'.
                  EXIT.
                ENDIF.
              ENDIF.
            ENDLOOP. "at var_program
          ENDIF.

        ENDIF.
      ENDLOOP.  "at steplist
    ENDIF.

  ENDLOOP.  "at joblist

  IF job_exists EQ 'T'.
    string  = joblist-jobname.
    string1 = joblist-sdluname.
    WRITE joblist-sdlstrtdt TO string2.
    WRITE joblist-sdlstrttm TO string3.
    return = 299.
  ENDIF.

ENDFORM.                    " check_batch_jobs
*
*&---------------------------------------------------------------------*
*&      Form  check_update_requests
*&---------------------------------------------------------------------*
*  check VB data for existing BDC_END_VB module with actual QID
*----------------------------------------------------------------------*
FORM check_update_requests.
  DATA: wa_vbmod TYPE vbmod.
  DATA: itab_vbmod LIKE TABLE OF vbmod.

  DATA: bi_data TYPE apqd.

  TYPES: BEGIN OF vbtabline,
           vblen  TYPE vbdata-vblen,
           vbdata TYPE vbdata-vbdata,
         END OF vbtabline.
  DATA: lt_vbdata TYPE STANDARD TABLE OF vbtabline.
  DATA: wa_vbhdr TYPE vbhdr.
  DATA: vbhdr_datum LIKE sy-datum,
        vbhdr_zeit  LIKE sy-uzeit.


  SELECT * FROM vbmod
           INTO TABLE itab_vbmod
           WHERE vbfunc = 'BDC_END_VB'.                 "#EC CI_NOFIELD

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.


  LOOP AT itab_vbmod INTO wa_vbmod.

    SELECT vblen vbdata FROM vbdata
                        INTO TABLE lt_vbdata
                        WHERE vbkey = wa_vbmod-vbkey
                          AND vbmodcnt = wa_vbmod-vbmodcnt.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.


    IMPORT bistruc TO bi_data
      FROM INTERNAL TABLE lt_vbdata.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.


    IF bi_data-qid EQ mtab-qid.
      CLEAR: string, string1, string2, string3.
      string  = mtab-groupid.
      WRITE bi_data-trans TO string1 LEFT-JUSTIFIED.

      SELECT SINGLE * FROM vbhdr
                      INTO wa_vbhdr
                      WHERE vbkey = wa_vbmod-vbkey.

      IF sy-subrc EQ 0.
        vbhdr_datum = wa_vbhdr-vbdate(8).
        vbhdr_zeit = wa_vbhdr-vbdate+8.
        WRITE vbhdr_datum TO string3.
        WRITE vbhdr_zeit TO string2.
        CONCATENATE string3 string2 INTO string3 SEPARATED BY space.
        string2 = wa_vbhdr-vbusr.
        return = 839.
      ENDIF.

      RETURN.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " check_update_requests
*
*&---------------------------------------------------------------------*
*&      Form  map_batchsys_onto_target
*&---------------------------------------------------------------------*
*  map batch-system onto target group/server/host
*----------------------------------------------------------------------*
FORM map_batchsys_onto_target.
*
  DATA: chk_string TYPE string.
*
  CLEAR:
    target_system,
    target_server,
    target_group.
*
* vaildation-check for incoming data
  IF batchsys EQ space.
    RETURN.
  ENDIF.
*
  IF batchsys(1) EQ '<'.  "is target a <servergroupname>?
    chk_string = batchsys.
*   eliminate the <parenthesis> ...
    TRANSLATE chk_string USING '< > '.
    CONDENSE chk_string.
    target_group = chk_string.
    RETURN.
  ENDIF.
*
* check whether batchsys has a targetserver name-konvention:
* "HOSTNAME_SID_NO"
* with: HOSTNAME name of the host machine
*       SID      system id (3 characters)
*       NO       instance number (2 characters)
  chk_string = batchsys.
  IF strlen( chk_string ) > 7. "is the name long enough?
    SHIFT chk_string BY 7 PLACES RIGHT CIRCULAR.
*   now, we should have "_SID_NOHOSTNAME" for a targetserver...
    IF chk_string(1) EQ '_'.
      IF chk_string+4(1) EQ '_'.  "underscores mask fits?
        target_server = batchsys. "okay, it's a targetserver
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.
*
  target_system = batchsys. "default: use hostname as target
*
ENDFORM.                    " map_batchsys_onto_target
*&---------------------------------------------------------------------*
*&      Module  USER_NAME  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_name OUTPUT.

  d0100-creator = sy-uname.
ENDMODULE.
