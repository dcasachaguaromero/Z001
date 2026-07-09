*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ragitt_ALV01                                                *
*&         mit ALV Unterstützung                                       *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT zac_ragitt_alv01 MESSAGE-ID ab
                    LINE-SIZE 132
                    NO STANDARD PAGE HEADING.

NODES: anla0,
       anlav,
       anlb,
       anek,
       anepv,
       anlcv.

TABLES: anlh.

* Abg-Simu: Benoetigte Tabellen fuer FB-Call von ANEP_AFARECHNEN.
TABLES: ants,
        anep,
        anea,
        anfm,
        anlz.

TABLES:
*       Zuordnungen BWA --> BWA-Gruppe, Gittergruppe.
        tabw,
*       BWA-Gruppen.
        tabwg,
*       Entity-Tabelle fuer Gitterversionen.
        tabwp,
*       Zuordnungen BWA-Untergruppe --> Gitterposition.
        tabwm,
*       Zuordnungen Gitterposition --> Spaltenueberschrift.
        tabwn,
*       Bezeichnug der Gitterversion.
        tabwo.

* Allgemeine DATA-, TABLES-, ... Anweisungen.
INCLUDE zaf_rasort_alv04.
*INCLUDE rasort_alv04.

INCLUDE zaf_rasort_alv_data_fieldcat.
*INCLUDE rasort_alv_data_fieldcat.
DATA:     gt_events      TYPE slis_t_event,
          gt_list_top_of_page TYPE slis_t_listheader,
          rt_events TYPE slis_t_event,
          ls_event TYPE slis_alv_event.

DATA:
*     Anzahl der im Anforderungsbild erlaubten AfA-Bereiche.
      sav_anzbe(1) TYPE c VALUE '1',
*     Flag: Postenausgabe Ja='1'/Nein='0'.
*     Muss gesetzt sein, da Summen via Summenberichtsgenerator
*     erzeugt und ausgegeben werden!
      flg_postx(1) TYPE c VALUE '1',
*     Summenbericht: Maximale Anzahl Wertfelder/Zeile.
      con_wrtzl(2) TYPE p VALUE 8.

* Arbeitsversion von TABW.
DATA: BEGIN OF yabw OCCURS 100,
        bwasl  LIKE tabw-bwasl,
        bwagrp LIKE tabw-bwagrp,
        gittgr LIKE tabw-gittgr,
      END OF yabw.

* Abg-Simu: Arbeitsversion von TABWG.
DATA: BEGIN OF yabwg OCCURS 100,
        bwagrp LIKE tabwg-bwagrp,
        xzugne LIKE tabwg-xzugne,
      END OF yabwg.

* Arbeitsversion von TABWM.
DATA: BEGIN OF xabwm OCCURS 50,
        bwagrp LIKE tabwm-bwagrp,
        lfdnr  LIKE tabwm-lfdnr,
        gitzl0 LIKE tabwm-gitzl0,
        gitsp0 LIKE tabwm-gitsp0,
        gitzl1 LIKE tabwm-gitzl0,
        gitsp1 LIKE tabwm-gitsp0,
        gitzl2 LIKE tabwm-gitzl0,
        gitsp2 LIKE tabwm-gitsp0,
        gitzl3 LIKE tabwm-gitzl0,
        gitsp3 LIKE tabwm-gitsp0,
        gitzl4 LIKE tabwm-gitzl0,
        gitsp4 LIKE tabwm-gitsp0,
        gitzl5 LIKE tabwm-gitzl0,
        gitsp5 LIKE tabwm-gitsp0,
        gitzl6 LIKE tabwm-gitzl0,
        gitsp6 LIKE tabwm-gitsp0,
        gitzl7 LIKE tabwm-gitzl0,
        gitsp7 LIKE tabwm-gitsp0,
      END OF xabwm.

* Spaltenueberschriften zu Gitterpositionen.
DATA: BEGIN OF uebs OCCURS 80,
        gitzl  LIKE tabwn-gitzl,
        gitsp  LIKE tabwn-gitsp,
        gitspt LIKE tabwn-gitspt,
      END OF uebs.

* Key fuer Tabelle UEBS.
DATA: BEGIN OF key_uebs,
        gitzl  LIKE tabwn-gitzl,
        gitsp  LIKE tabwn-gitsp,
      END OF key_uebs.

DATA:
*     Zu reservierende Zeilen bei Nicht-Summenbericht.
      con_resgi TYPE i.

* Gitterposition mit Betrag (je Anlage).
DATA: BEGIN OF apos OCCURS 80,
        gitzl  LIKE tabwn-gitzl,
        gitsp  LIKE tabwn-gitsp,
        betrag LIKE anlcv-kansw,
      END OF apos.

* Hilfstabelle: Vorhandene Spalten gemaess vorhandenen Ueberschriften.
DATA: BEGIN OF splt OCCURS 8,
        gitsp LIKE tabwn-gitsp,
      END OF splt.

* Hilfstabelle: Vorhandene Zeilen gemaess vorhandenen Ueberschriften.
DATA: BEGIN OF zeil OCCURS 10,
        gitzl LIKE tabwn-gitzl,
      END OF zeil.

DATA:
*     Position letztes VLINE der letzten Wertfeldkolonne.
      con_endsp(2) TYPE p VALUE 0.

* Sammeltabelle fuer ANEPVs je Anlage.
DATA: BEGIN OF sav_anepv OCCURS 10.
        INCLUDE STRUCTURE anepv.
DATA: END OF sav_anepv.

* Hilfsfeld zum Speichern der ANLCV.
DATA: BEGIN OF sav_anlcv.
        INCLUDE STRUCTURE anlcv.
DATA: END OF sav_anlcv.

* Deklarationen ALV
DATA: itab_data LIKE fiaa_salvtab_ragitt OCCURS 10 WITH HEADER LINE.

DATA: p_vari TYPE disvariant-variant.     " Nur DUMMY, da nicht benötigt

DATA: xtabwn    LIKE tabwn OCCURS 0 WITH HEADER LINE,
      index     TYPE n,
      indexint  TYPE i,
      zaehler   TYPE i,
      ok        TYPE i,
      fieldname LIKE x_fieldcat-fieldname.

DATA : it_ucomm TYPE TABLE OF sy-ucomm.


DATA : v_key LIKE sy-pfkey.

DATA: BEGIN OF xzeile OCCURS 0,
        zeile LIKE tabwn-gitzl,
      END OF xzeile.

DATA: BEGIN OF xspalte OCCURS 0,
        spalte LIKE tabwn-gitsp,
      END OF xspalte.

DATA: BEGIN OF xzlsp OCCURS 0,
        zl  LIKE tabwn-gitzl,
        sp  LIKE tabwn-gitsp,
      END OF xzlsp.

DATA:  sort          TYPE slis_t_sortinfo_alv WITH HEADER LINE,
       fieldcat      TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       print         TYPE slis_print_alv,
       layout        TYPE slis_layout_alv.


DATA :   wa_titulo   TYPE lvc_title,
         tit01(10),
         repid LIKE sy-repid.


* Anzeigevarianten werden hier nicht benötigt!
SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE text-bl0.
*   PARAMETERS: p_vari TYPE disvariant-variant.
PARAMETERS: p_grid TYPE xgrid.
SELECTION-SCREEN END OF BLOCK bl0.

SELECTION-SCREEN BEGIN OF BLOCK bl1                        "AB
                 WITH FRAME                                "AB
                 TITLE text-bl1.                           "AB

SELECT-OPTIONS:
*               Anlagenbestandskonto.
              so_ktanw FOR anlav-ktansw NO DATABASE SELECTION ,
*               Aktivierungsdatum.
              so_aktiv FOR anlav-aktiv,
*               Abschreibungsschlüssel
              so_afasl FOR anlb-afasl.
SELECTION-SCREEN END   OF BLOCK bl1.                       "AB

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK bl2                        "AB
                 WITH FRAME                                "AB
                 TITLE text-bl2.                           "AB
PARAMETERS:
* Gitterversion.
          pa_gitvs LIKE tabwo-gitvrs.
* SELECTION-SCREEN COMMENT  44(36) git_txt
SELECTION-SCREEN COMMENT  44(50) git_txt                    "> 711367
                          FOR FIELD pa_gitvs.
PARAMETERS:
* Gebuchte AfA .
          pa_xgbaf LIKE anla0-xgbaf.
SELECTION-SCREEN END   OF BLOCK bl2.                       "AB
SELECTION-SCREEN SKIP.

* Abg-Simu.
SELECTION-SCREEN BEGIN OF BLOCK bl3                        "AB
                 WITH FRAME                                "AB
                 TITLE text-c04.                           "AB
*SELECTION-SCREEN SKIP.
* Klassen von GWGs.
SELECT-OPTIONS: so_gwgkl FOR rarep-gwgkl.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) text-001 FOR FIELD pa_simdv.
* Von/Bis-Datum bei GWG-Abgangssimulation.
PARAMETERS: pa_simdv LIKE rarep-simdt.
SELECTION-SCREEN COMMENT 52(05) text-050 FOR FIELD pa_simdb.
PARAMETERS: pa_simdb LIKE rarep-simdt.
SELECTION-SCREEN END OF LINE.
* Klassen von immateriellen WG.
SELECT-OPTIONS: so_imwgk FOR rarep-imwgkl.

SELECTION-SCREEN END OF BLOCK bl3.
* Gebuchtwerte
SELECTION-SCREEN SKIP.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK bl4                       "AB
                 WITH FRAME                                "AB
                 TITLE text-c03.                           "AB
PARAMETERS:
*           Zusatzueberschrift.
          pa_titel LIKE rarep-titel DEFAULT space,
*           Flag: Listseparation gemaess Tabelle TLSEP.
*            pa_lssep LIKE bhdgd-separ, "no 394136
*           Flag: Mikrofichezeile ausgeben.
          pa_mikro LIKE bhdgd-miffl.
SELECTION-SCREEN END   OF BLOCK bl4.                       "AB

* Flag für SAP-Endmontage (SAP-only).
PARAMETERS: pa_endm  LIKE rarep-xendmont NO-DISPLAY.
SELECT-OPTIONS: so_deakt FOR anlav-deakt NO-DISPLAY.

INITIALIZATION.



  v_key = sy-pfkey.


  APPEND : 'GET' TO it_ucomm.
  APPEND : 'SPOS' TO it_ucomm.
  APPEND : 'DYNS' TO it_ucomm.



  CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
    EXPORTING
      p_status  = v_key
      p_program = ' '
    TABLES
      p_exclude = it_ucomm.


  LOOP AT SCREEN.


    IF screen-group4 = '005' OR
      screen-group4 = '006' OR
      screen-group4 = '054' OR
      screen-group4 = '055' OR
      screen-group4 = '056' OR
      screen-group4 = '057' OR
      screen-group4 = '058' OR
      screen-group4 = '059' OR
      screen-group4 = '061' OR
      screen-group4 = '085' OR
      screen-group4 = '089' OR
      screen-group4 = '090' OR
      screen-group4 = '091' OR
      screen-group4 = '123' OR
      screen-group4 = '124' OR
      screen-group4 = '125' OR
      screen-group4 = '131' OR
      screen-group4 = '120' OR
      screen-group4 = '138' OR
      screen-group4 = '142' OR
      screen-group4 = '147' OR
      screen-group4 = '148' OR
      screen-group4 = '135' OR
      screen-group4 = '140'.

      screen-invisible = 1.
      screen-active = 0.

      MODIFY SCREEN.
    ENDIF.

    IF screen-name = 'BUKRS-HIGH' OR
       screen-name = '%_BUKRS_%_APP_%-VALU_PUSH'.
      screen-invisible = 1.
      screen-active = 0.

      MODIFY SCREEN.
    ENDIF.
    IF screen-name = 'SRTVR' OR
      screen-name = 'PA_GITVS'.
      screen-input = 0.


      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.




* Sortiervariante vorschlagen.
  MOVE: '0001' TO srtvr,
* Gitterversion vorschlagen.
        'ZBTR' TO pa_gitvs,
* Gitterversion vorschlagen.
        '1'    TO flg_gitter.
* ALV Grid NICHT als Standard vorschlagen
*  MOVE: ' '    TO p_grid.


  so_deakt-option = 'EQ'.
  so_deakt-sign = 'I'.
  so_deakt-low = '00000000'.
  APPEND so_deakt.
  so_deakt-option = 'GE'.
  so_deakt-sign   = 'I'.
  so_deakt-low    = '&FDAY'.
  APPEND so_deakt.



  PERFORM gitbez_lesen.

* Report wird nicht von außen aufgerufen. Lesen der PickUp-Informationen
* aus dem Memory d.h. der ursprünglich eingegebenen Programmabgrenzungen
  IMPORT flg_not_first FROM MEMORY ID 'flg'.

* Allgemeine Verarbeitung der PA/SO-Eingaben.
  INCLUDE zaf_rasort_alv08.
*INCLUDE rasort_alv08.

* Process on value request
* Anzeigevariante wird hier nicht benötigt.
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
*   PERFORM varianten_auswahl CHANGING p_vari.

* Pruefung, ob Gitterversion in TABWO vorhanden ist.


AT SELECTION-SCREEN ON pa_gitvs.
  PERFORM gitbez_lesen.

* Pruefung, Berichtsdatum bei Gebuchtwerten
AT SELECTION-SCREEN ON pa_xgbaf.
  IF NOT pa_xgbaf IS INITIAL.
     *anla0-xgbaf = anla0-xgbaf = pa_xgbaf.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
v_key = sy-pfkey.


  APPEND : 'GET' TO it_ucomm.
  APPEND : 'SPOS' TO it_ucomm.
  APPEND : 'DYNS' TO it_ucomm.



  CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
    EXPORTING
      p_status  = v_key
      p_program = ' '
    TABLES
      p_exclude = it_ucomm.


  LOOP AT SCREEN.


    IF screen-group4 = '005' OR
      screen-group4 = '006' OR
      screen-group4 = '054' OR
      screen-group4 = '055' OR
      screen-group4 = '056' OR
      screen-group4 = '057' OR
      screen-group4 = '058' OR
      screen-group4 = '059' OR
      screen-group4 = '061' OR
      screen-group4 = '085' OR
      screen-group4 = '089' OR
      screen-group4 = '090' OR
      screen-group4 = '091' OR
      screen-group4 = '123' OR
      screen-group4 = '124' OR
      screen-group4 = '125' OR
      screen-group4 = '131' OR
      screen-group4 = '120' OR
      screen-group4 = '138' OR
      screen-group4 = '142' OR
      screen-group4 = '147' OR
      screen-group4 = '148' OR
      screen-group4 = '135' OR
      screen-group4 = '140'.

      screen-invisible = 1.
      screen-active = 0.

      MODIFY SCREEN.
    ENDIF.

    IF screen-name = 'BUKRS-HIGH' OR
       screen-name = '%_BUKRS_%_APP_%-VALU_PUSH'.
      screen-invisible = 1.
      screen-active = 0.

      MODIFY SCREEN.
    ENDIF.
    IF screen-name = 'SRTVR' OR
      screen-name = 'PA_GITVS'.
      screen-input = 0.


      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*---------------------------------------------------------------------*

START-OF-SELECTION.

* anderer Title bei Gebuchter AFA
  IF NOT pa_xgbaf IS INITIAL.
    SET TITLEBAR '002'.
  ENDIF.

* Sichern der Selektionsoptionen bzw. Einlesen der Sortierwerte bei
* PickUp.
  PERFORM info_pick_up.

* K e i n  automatisches Uline am Ende einer Gruppenstufe.
  flg_enduline = off.

* Gitterstruktur für ALV bestimmen
  SELECT * FROM tabwn INTO TABLE xtabwn
    WHERE spras  EQ sy-langu
    AND   gitvrs EQ pa_gitvs
    ORDER BY PRIMARY KEY.

  LOOP AT xtabwn.
    xzeile-zeile = xtabwn-gitzl.
    COLLECT xzeile.
  ENDLOOP.

  LOOP AT xtabwn.
    xspalte-spalte = xtabwn-gitsp.
    COLLECT xspalte.
  ENDLOOP.

  SORT: xzeile, xspalte.


* Positionen in xtabwn in Tabellenposition umrechnen
* und in xzlsp stellen
  LOOP AT xtabwn.
    LOOP AT xzeile WHERE zeile = xtabwn-gitzl.
      xzlsp-zl = sy-tabix.
    ENDLOOP.
    LOOP AT xspalte WHERE spalte = xtabwn-gitsp.
      xzlsp-sp = sy-tabix.
    ENDLOOP.
    APPEND xzlsp.
  ENDLOOP.

* Interne Arbeitstabellen initialisieren.
  PERFORM tabellen_init.

* Bestimmung des Sortierfeldes auf unterster Gruppenstufe.
  ASSIGN sav_dummy TO <b>.
*
  ASSIGN sav_dummy TO <p>.
  ASSIGN sav_dummy TO <q>.

* Allgemeines Coding nach START-OF-SELECTION. Aufbau des HEADERs.
  INCLUDE zaf_rasort_alv10.
*INCLUDE rasort_alv10.

* Steuerungskennzeichen für LDB setzen
   *anla0-xgbaf = pa_xgbaf.

* Setzen der UserStrukturen für die log. Datenbank
* (2 Stück - für Header und Item Tabelle)
*  *anla0-selfield_structure1 = 'FIAA_SALVTAB_RABEST_U'.
   *anla0-selfield_structure1 = 'CI_REPRAGITT'.
   *anla0-selfield_structure2 = ''.

* keine DB-Summierung wenn Abgangssimulation gewünscht
  IF NOT so_gwgkl[] IS INITIAL OR NOT so_imwgk[] IS INITIAL OR
     NOT pa_simdv   IS INITIAL OR NOT pa_simdb   IS INITIAL .
     *anla0-xcalc = con_x.
  ENDIF.
  IF NOT so_afasl[] IS INITIAL .
     *anla0-xnodbs = 'X'.
  ENDIF.

GET anla0.


GET anlav FIELDS aktiv deakt zugdt txt50 txa50 xanlgr anlkl ktogr.

* Das check select-options ist ab 3.0 nur noch für die Bestandskonten
* interessant. Bei Gruppensummen darf der CHECK erst erfolgen, wenn
* die ANEPs auch gelesen worden sind, weil sonst die Datenbank falsch
* summiert und ANEPs nicht liest.

  IF summb IS INITIAL.
    CHECK SELECT-OPTIONS.
  ENDIF.

* Nur Anlagen seleketieren, die aktiviert wurden ...
  CHECK NOT anlav-zugdt IS INITIAL.
* ... und zwar vor dem Berichtsdatum.
  CHECK     anlav-zugdt LE berdatum.

* Verarbeitungen ON CHANGE OF ANLAV-XXXXX.
  INCLUDE zaf_rasort14.
*  INCLUDE rasort14.

* Im VJ deaktivierte Anlagen nicht selektieren.
  IF NOT anlav-deakt IS INITIAL.
    CHECK anlav-deakt GE sav_gjbeg.
  ENDIF.

* Information AfA-Bereich fuer Header.
  ON CHANGE OF anlav-bukrs.
*   Individueller Teil des Headers
    WRITE: '-'       TO head-info4,
           bereich1  TO head-info5,
           sav_afbe1 TO head-info6.
*
    CONDENSE head.
  ENDON.

* Zuordnungstabelle APOS zuruecksetzen und als initiale
* Zeilen/Spaltenmatrix aufbauen.
  PERFORM apos_init.

* Bewegungstabelle SAV_ANEPV zuruecksetzen.
  REFRESH sav_anepv.


GET anlb FIELDS afasl afabg safbg ndjar ndper perfy
                xnega xgwgk zinbg wbind alind aprop umjar
                schrw lgjan anlgr anlgr2.

  CLEAR sav_anlcv.

  CHECK SELECT-OPTIONS.

* Keine Normal-AfA ==> AfA-Beginn = Sonder-AfA-Beginn.
  IF anlb-afabg IS INITIAL.
    MOVE anlb-safbg TO anlb-afabg.
  ENDIF.


GET anlcv.

  CHECK SELECT-OPTIONS.
  MOVE anlcv TO sav_anlcv.

  PERFORM store_errors.                                     "> 1002552

GET anepv.

  CHECK SELECT-OPTIONS.
* Nur Bewegungen des Jahres des Berichtsdatums durchlassen.
  CHECK anepv-bzdat GE sav_gjbeg.

* Bewegungen in SAV_ANEPV sammeln.
  MOVE anepv TO sav_anepv.
  APPEND sav_anepv.


GET anlb LATE.

* Check auf Bestandskonto bei Gruppensummen erst hier, wegen
* fehlender Abgänge/Umbuchungen
  IF NOT summb IS INITIAL.
    IF NOT anlav-ktansw IN so_ktanw.
      REJECT 'ANLAV'.
    ENDIF.
  ENDIF.

* ANLCV aus Save-Area zurueckholen.
  CHECK NOT sav_anlcv-anln1 IS INITIAL.
  MOVE sav_anlcv TO anlcv.

* Abg-Simu: Abgang simulieren.
  PERFORM abga_simulieren.

* Einarbeiten der Jahresanfangswerte in das Gitter.
  PERFORM ya_berechnen.
* Einarbeiten der Jahreswerte in das Gitter.
  PERFORM yy_berechnen.
* Einarbeiten der Jahresendwerte in das Gitter.
  PERFORM yz_berechnen.
* Einarbeiten der Bewegungswerte in das Gitter.
  PERFORM nn_berechnen.

* Daten gegen Sortierwerte beim PickUp checken.
  PERFORM sort_check.

  CLEAR itab_data.
  PERFORM sort_felder_vorbereiten.

  MOVE-CORRESPONDING anlb TO itab_data.                     "> 671702
  MOVE-CORRESPONDING anlav TO itab_data.

* Über Werte in apos loopen
  zaehler = 0.
  LOOP AT apos.
    ok = 0.

* Nur Werte nehmen, die in Tabelle sollen da apos
* Lücken in Tabelle mit Wert 0 belegt
    LOOP AT xzlsp WHERE zl = apos-gitzl.
      IF xzlsp-sp = apos-gitsp.
        ok = 1.
        EXIT.
      ENDIF.
    ENDLOOP.
    CHECK ok = 1.

*  Werte in interne Tabelle einarbeiten
*  unschoen da nicht flexibel (nur bis 18 Werte moeglich)
    DATA: btrz(2), tbtrfeld(5).
    FIELD-SYMBOLS: <btrfeld>.

    zaehler = zaehler + 1.
    btrz = zaehler.
    CONCATENATE 'BTR' btrz INTO tbtrfeld.
    ASSIGN COMPONENT tbtrfeld OF STRUCTURE itab_data TO <btrfeld>.
    <btrfeld> = apos-betrag.
  ENDLOOP.

  itab_data-waers = sav_waer1.
  itab_data-flg_pick_up = 'X'.
* Daten zur Anlage haben RANGE = 1.
  itab_data-range = 1.

* Die Datenzeilen sind immer in der vollen Sortierung
  itab_data-hlp_level = con_srtst.      " == Anzahl Summenstufen

* Bestand für Summenbericht aufbereiten
  IF summb NE space.
    PERFORM hashsum_collection USING itab_data.
  ELSE.
*   ITAB_DATA nur dann aufbauen, wenn KEIN Summenbericht
    APPEND itab_data.
  ENDIF.

  range = '1'.

* DATEN extrahieren.
*ALV  EXTRACT daten.

  PERFORM tcollect_fuellen.




END-OF-SELECTION.




  PERFORM lista .
*---------------------------------------------------------------------*


*---------------------------------------------------------------------*


FORM tabellen_init.

  DATA: l_tabix   LIKE sy-tabix.

* Teile von TABW in Arbeitstabelle laden.
  SELECT * FROM tabw
    ORDER BY PRIMARY KEY.
    MOVE: tabw-bwasl  TO yabw-bwasl,
          tabw-bwagrp TO yabw-bwagrp,
          tabw-gittgr TO yabw-gittgr.
    APPEND yabw.
  ENDSELECT.

* Abg-Simu: Teile von TABWG in Arbeitstabelle laden.
  SELECT * FROM tabwg
    ORDER BY PRIMARY KEY.
    MOVE: tabwg-bwagrp TO yabwg-bwagrp,
          tabwg-xzugne TO yabwg-xzugne.
    APPEND yabwg.
  ENDSELECT.

* TABWP einlesen.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM tabwp
*    WHERE gitvrs EQ pa_gitvs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM tabwp
    WHERE gitvrs EQ pa_gitvs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* Fuer Report-Header: Version vollstaendig/unvollstaendig.
* Vollständigkeitsprüfung Gitter

  CALL FUNCTION 'FIAA_CHECK_HISTORYSHEET'
    EXPORTING
      i_gitvrs = pa_gitvs
    IMPORTING
      e_xcompl = tabwp-xcompl.

  IF tabwp-xcompl IS INITIAL.
    WRITE text-101 TO sav_compltxt.
  ELSE.
    WRITE text-100 TO sav_compltxt.
  ENDIF.

* Arbeitstabelle XABWM (BWA-Untergruppe --> Gitterposition) aufbauen.
  SELECT * FROM tabwm
    WHERE gitvrs EQ pa_gitvs
    ORDER BY PRIMARY KEY.
    MOVE: tabwm-bwagrp TO xabwm-bwagrp,
          tabwm-lfdnr  TO xabwm-lfdnr,
          tabwm-gitzl0 TO xabwm-gitzl0,
          tabwm-gitsp0 TO xabwm-gitsp0,
          tabwm-gitzl1 TO xabwm-gitzl1,
          tabwm-gitsp1 TO xabwm-gitsp1,
          tabwm-gitzl2 TO xabwm-gitzl2,
          tabwm-gitsp2 TO xabwm-gitsp2,
          tabwm-gitzl3 TO xabwm-gitzl3,
          tabwm-gitsp3 TO xabwm-gitsp3,
          tabwm-gitzl4 TO xabwm-gitzl4,
          tabwm-gitsp4 TO xabwm-gitsp4,
          tabwm-gitzl5 TO xabwm-gitzl5,
          tabwm-gitsp5 TO xabwm-gitsp5,
          tabwm-gitzl6 TO xabwm-gitzl6,
          tabwm-gitsp6 TO xabwm-gitsp6,
          tabwm-gitzl7 TO xabwm-gitzl7,
          tabwm-gitsp7 TO xabwm-gitsp7.
    APPEND xabwm.
  ENDSELECT.

* Bezeichnungen zu Gitterpositionen in Tabelle UEBS.
  SELECT * FROM tabwn
    WHERE spras  EQ sy-langu
    AND   gitvrs EQ pa_gitvs
    ORDER BY PRIMARY KEY.
    MOVE: tabwn-gitzl  TO uebs-gitzl,
          tabwn-gitsp  TO uebs-gitsp,
          tabwn-gitspt TO uebs-gitspt.
    APPEND uebs.
  ENDSELECT.

* Tabelle SPLT der vorhandenen Spalten aufbauen.
* Anzahl CON_GITSP der vorhandenen Spalten ermitteln.
  LOOP AT uebs.
*   Spalte schon registriert?
    READ TABLE splt WITH KEY uebs-gitsp.
*   Nein --> dann registrieren.
    IF sy-subrc NE 0.
      MOVE uebs-gitsp TO splt-gitsp.
      APPEND splt.
*     Anzahl Gitterspalten hochzaehlen.
      con_gitsp = con_gitsp + 1.
    ENDIF.

  ENDLOOP.
  SORT splt BY gitsp.

* Letzte Spalte der Wertfelder merken.
  MOVE con_gitsp TO cnt_count.
  con_endsp = cnt_count * 16 + 1.
* Uline in Laenge der Wertfeldspalten merken.
  WRITE sy-uline TO hlp_uline+0(con_endsp).

* Tabelle ZEIL der vorhandenen Zeilen aufbauen.
* Anzahl CON_GITZL der vorhandenen Zeilen ermitteln.
  LOOP AT uebs.
*   Zeile schon registriert?
    READ TABLE zeil WITH KEY uebs-gitzl.
*   Nein --> dann registrieren.
    IF sy-subrc NE 0.
      MOVE uebs-gitzl TO zeil-gitzl.
      APPEND zeil.
*     Anzahl Gitterzeilen hochzaehlen.
      con_gitzl = con_gitzl + 1.
    ENDIF.
  ENDLOOP.
  SORT zeil BY gitzl.

* Zu reservierende Zeilen bei Nicht-Summenbericht:
* Anzahl Gitterzeilen + Anlagenzeile + 2 Unterstriche + 1 Deaktivierung
  con_resgi = con_gitzl + 4.

* Fehlende Positionsbezeichnungen in UEBS ergaenzen.
  LOOP AT zeil.
*Begin of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
SORT UEBS  .
*End of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
    LOOP AT splt.
      MOVE: zeil-gitzl TO key_uebs-gitzl,
            splt-gitsp TO key_uebs-gitsp.
      READ TABLE uebs WITH KEY key_uebs BINARY SEARCH.
      CASE sy-subrc.
        WHEN 4.
          MOVE: zeil-gitzl TO uebs-gitzl,
                splt-gitsp TO uebs-gitsp,
                space      TO uebs-gitspt.
          INSERT uebs INDEX sy-tabix.
        WHEN 8.
          MOVE: zeil-gitzl TO uebs-gitzl,
                splt-gitsp TO uebs-gitsp,
                space      TO uebs-gitspt.
          APPEND uebs.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.

* Natuerliches durchnummerieren der Zeilen + Spalten in XABWM.
  LOOP AT xabwm.
    l_tabix = sy-tabix.
*   BWA-Untergruppe 0.
    IF NOT xabwm-gitzl0 IS INITIAL.
      READ TABLE splt WITH KEY xabwm-gitsp0 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitsp0.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl0, xabwm-gitsp0.
      ENDIF.
      READ TABLE zeil WITH KEY xabwm-gitzl0 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitzl0.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl0, xabwm-gitsp0.
      ENDIF.
    ENDIF.
*   BWA-Untergruppe 1.
    IF NOT xabwm-gitzl1 IS INITIAL.
      READ TABLE splt WITH KEY xabwm-gitsp1 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitsp1.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl1, xabwm-gitsp1.
      ENDIF.
      READ TABLE zeil WITH KEY xabwm-gitzl1 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitzl1.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl1, xabwm-gitsp1.
      ENDIF.
    ENDIF.
*   BWA-Untergruppe 2.
    IF NOT xabwm-gitzl2 IS INITIAL.
      READ TABLE splt WITH KEY xabwm-gitsp2 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitsp2.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl2, xabwm-gitsp2.
      ENDIF.
      READ TABLE zeil WITH KEY xabwm-gitzl2 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitzl2.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl2, xabwm-gitsp2.
      ENDIF.
    ENDIF.
*   BWA-Untergruppe 3.
    IF NOT xabwm-gitzl3 IS INITIAL.
      READ TABLE splt WITH KEY xabwm-gitsp3 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitsp3.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl3, xabwm-gitsp3.
      ENDIF.
      READ TABLE zeil WITH KEY xabwm-gitzl3 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitzl3.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl3, xabwm-gitsp3.
      ENDIF.
    ENDIF.
*   BWA-Untergruppe 4.
    IF NOT xabwm-gitzl4 IS INITIAL.
      READ TABLE splt WITH KEY xabwm-gitsp4 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitsp4.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl4, xabwm-gitsp4.
      ENDIF.
      READ TABLE zeil WITH KEY xabwm-gitzl4 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitzl4.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl4, xabwm-gitsp4.
      ENDIF.
    ENDIF.
*   BWA-Untergruppe 5.
    IF NOT xabwm-gitzl5 IS INITIAL.
      READ TABLE splt WITH KEY xabwm-gitsp5 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitsp5.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl5, xabwm-gitsp5.
      ENDIF.
      READ TABLE zeil WITH KEY xabwm-gitzl5 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitzl5.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl5, xabwm-gitsp5.
      ENDIF.
    ENDIF.
*   BWA-Untergruppe 6.
    IF NOT xabwm-gitzl6 IS INITIAL.
      READ TABLE splt WITH KEY xabwm-gitsp6 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitsp6.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl6, xabwm-gitsp6.
      ENDIF.
      READ TABLE zeil WITH KEY xabwm-gitzl6 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitzl6.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl6, xabwm-gitsp6.
      ENDIF.
    ENDIF.
*   BWA-Untergruppe 7.
    IF NOT xabwm-gitzl7 IS INITIAL.
      READ TABLE splt WITH KEY xabwm-gitsp7 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitsp7.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl7, xabwm-gitsp7.
      ENDIF.
      READ TABLE zeil WITH KEY xabwm-gitzl7 BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO xabwm-gitzl7.
      ELSE.
        MOVE '00' TO:  xabwm-gitzl7, xabwm-gitsp7.
      ENDIF.
    ENDIF.
*
    MODIFY xabwm.
*
  ENDLOOP.

* Natuerliches Durchnummerieren der Spalten in UEBS.
  LOOP AT uebs.
    READ TABLE splt WITH KEY uebs-gitsp.
    MOVE sy-tabix TO uebs-gitsp.
    READ TABLE zeil WITH KEY uebs-gitzl.
    MOVE sy-tabix TO uebs-gitzl.
    MODIFY uebs.
  ENDLOOP.

ENDFORM.                    "tabellen_init


*&---------------------------------------------------------------------*
*&      Form  ya_berechnen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ya_berechnen.

  LOOP AT xabwm
    WHERE bwagrp EQ 'YA'.
*
    IF NOT xabwm-gitzl0 IS INITIAL.
      MOVE: xabwm-gitzl0 TO apos-gitzl,
            xabwm-gitsp0 TO apos-gitsp.
      apos-betrag = anlcv-kansw.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl1 IS INITIAL.
      MOVE: xabwm-gitzl1 TO apos-gitzl,
            xabwm-gitsp1 TO apos-gitsp.
      apos-betrag = anlcv-knafa.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl2 IS INITIAL.
      MOVE: xabwm-gitzl2 TO apos-gitzl,
            xabwm-gitsp2 TO apos-gitsp.
      apos-betrag = anlcv-ksafa.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl3 IS INITIAL.
      MOVE: xabwm-gitzl3 TO apos-gitzl,
            xabwm-gitsp3 TO apos-gitsp.
      apos-betrag = anlcv-kaafa.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl4 IS INITIAL.
      MOVE: xabwm-gitzl4 TO apos-gitzl,
            xabwm-gitsp4 TO apos-gitsp.
      apos-betrag = anlcv-kmafa.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl5 IS INITIAL.
      MOVE: xabwm-gitzl5 TO apos-gitzl,
            xabwm-gitsp5 TO apos-gitsp.
      apos-betrag = anlcv-kaufw.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl6 IS INITIAL.
      MOVE: xabwm-gitzl6 TO apos-gitzl,
            xabwm-gitsp6 TO apos-gitsp.
      apos-betrag = anlcv-kaufn.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl7 IS INITIAL.
      MOVE: xabwm-gitzl7 TO apos-gitzl,
            xabwm-gitsp7 TO apos-gitsp.
      apos-betrag = anlcv-kinvz.
      COLLECT apos.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "ya_berechnen


*&---------------------------------------------------------------------*
*&      Form  yy_berechnen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM yy_berechnen.

  LOOP AT xabwm
    WHERE bwagrp EQ 'YY'.
*
    IF NOT xabwm-gitzl0 IS INITIAL.
      MOVE: xabwm-gitzl0 TO apos-gitzl,
            xabwm-gitsp0 TO apos-gitsp.
      apos-betrag = anlcv-answl.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl1 IS INITIAL.
      MOVE: xabwm-gitzl1 TO apos-gitzl,
            xabwm-gitsp1 TO apos-gitsp.
      apos-betrag = anlcv-nafap.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl2 IS INITIAL.
      MOVE: xabwm-gitzl2 TO apos-gitzl,
            xabwm-gitsp2 TO apos-gitsp.
      apos-betrag = anlcv-safap.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl3 IS INITIAL.
      MOVE: xabwm-gitzl3 TO apos-gitzl,
            xabwm-gitsp3 TO apos-gitsp.
      apos-betrag = anlcv-aafap.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl4 IS INITIAL.
      MOVE: xabwm-gitzl4 TO apos-gitzl,
            xabwm-gitsp4 TO apos-gitsp.
      apos-betrag = anlcv-mafap.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl5 IS INITIAL.
      MOVE: xabwm-gitzl5 TO apos-gitzl,
            xabwm-gitsp5 TO apos-gitsp.
      apos-betrag = anlcv-aufwp.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl6 IS INITIAL.
      MOVE: xabwm-gitzl6 TO apos-gitzl,
            xabwm-gitsp6 TO apos-gitsp.
      apos-betrag = anlcv-aufnp.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl7 IS INITIAL.
      MOVE: xabwm-gitzl7 TO apos-gitzl,
            xabwm-gitsp7 TO apos-gitsp.
      apos-betrag = anlcv-invzm.
      COLLECT apos.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "yy_berechnen


*&---------------------------------------------------------------------*
*&      Form  yz_berechnen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM yz_berechnen.

  LOOP AT xabwm
    WHERE bwagrp EQ 'YZ'.
*
    IF NOT xabwm-gitzl0 IS INITIAL.
      MOVE: xabwm-gitzl0 TO apos-gitzl,
            xabwm-gitsp0 TO apos-gitsp.
      apos-betrag = anlcv-kansw + anlcv-answl.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl1 IS INITIAL.
      MOVE: xabwm-gitzl1 TO apos-gitzl,
            xabwm-gitsp1 TO apos-gitsp.
      apos-betrag = anlcv-knafa + anlcv-nafap
                  + anlcv-nafav + anlcv-nafal
                  + anlcv-zusna.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl2 IS INITIAL.
      MOVE: xabwm-gitzl2 TO apos-gitzl,
            xabwm-gitsp2 TO apos-gitsp.
      apos-betrag = anlcv-ksafa + anlcv-safap
                  + anlcv-safav + anlcv-safal
                  + anlcv-zussa.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl3 IS INITIAL.
      MOVE: xabwm-gitzl3 TO apos-gitzl,
            xabwm-gitsp3 TO apos-gitsp.
      apos-betrag = anlcv-kaafa + anlcv-aafap
                  + anlcv-aafav + anlcv-aafal
                  + anlcv-zusaa.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl4 IS INITIAL.
      MOVE: xabwm-gitzl4 TO apos-gitzl,
            xabwm-gitsp4 TO apos-gitsp.
      apos-betrag = anlcv-kmafa + anlcv-mafap
                  + anlcv-mafav + anlcv-mafal
                  + anlcv-zusma.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl5 IS INITIAL.
      MOVE: xabwm-gitzl5 TO apos-gitzl,
            xabwm-gitsp5 TO apos-gitsp.
      apos-betrag = anlcv-kaufw + anlcv-aufwp
                  + anlcv-aufwv + anlcv-aufwl.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl6 IS INITIAL.
      MOVE: xabwm-gitzl6 TO apos-gitzl,
            xabwm-gitsp6 TO apos-gitsp.
      apos-betrag = anlcv-kaufn + anlcv-aufnp
                  + anlcv-aufnv + anlcv-aufnl.
      COLLECT apos.
    ENDIF.
*
    IF NOT xabwm-gitzl7 IS INITIAL.
      MOVE: xabwm-gitzl7 TO apos-gitzl,
            xabwm-gitsp7 TO apos-gitsp.
      apos-betrag = anlcv-kinvz + anlcv-invzm
                  + anlcv-invzv + anlcv-invzl.
      COLLECT apos.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "yz_berechnen


*&---------------------------------------------------------------------*
*&      Form  nn_berechnen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM nn_berechnen.

  LOOP AT sav_anepv.
*   Bewegungsartengruppe zu zu Bewegungsart.
    READ TABLE yabw WITH KEY sav_anepv-bwasl.
    CHECK sy-subrc EQ 0.
*   In alle Zuordnungen zu dieser Gittergruppe einarbeiten.
    LOOP AT xabwm
      WHERE bwagrp EQ yabw-gittgr.
*
      IF NOT xabwm-gitzl0 IS INITIAL.
        MOVE: xabwm-gitzl0 TO apos-gitzl,
              xabwm-gitsp0 TO apos-gitsp.
        apos-betrag = sav_anepv-anbtr.
        COLLECT apos.
      ENDIF.
*
      IF NOT xabwm-gitzl1 IS INITIAL.
        MOVE: xabwm-gitzl1 TO apos-gitzl,
              xabwm-gitsp1 TO apos-gitsp.
        apos-betrag = sav_anepv-nafal + sav_anepv-nafav.
        COLLECT apos.
      ENDIF.
*
      IF NOT xabwm-gitzl2 IS INITIAL.
        MOVE: xabwm-gitzl2 TO apos-gitzl,
              xabwm-gitsp2 TO apos-gitsp.
        apos-betrag = sav_anepv-safal + sav_anepv-safav.
        COLLECT apos.
      ENDIF.
*
      IF NOT xabwm-gitzl3 IS INITIAL.
        MOVE: xabwm-gitzl3 TO apos-gitzl,
              xabwm-gitsp3 TO apos-gitsp.
        apos-betrag = sav_anepv-aafal + sav_anepv-aafav.
        COLLECT apos.
      ENDIF.
*
      IF NOT xabwm-gitzl4 IS INITIAL.
        MOVE: xabwm-gitzl4 TO apos-gitzl,
              xabwm-gitsp4 TO apos-gitsp.
        apos-betrag = sav_anepv-mafal + sav_anepv-mafav.
        COLLECT apos.
      ENDIF.
*
      IF NOT xabwm-gitzl5 IS INITIAL.
        MOVE: xabwm-gitzl5 TO apos-gitzl,
              xabwm-gitsp5 TO apos-gitsp.
        apos-betrag = sav_anepv-aufwl + sav_anepv-aufwv.
        COLLECT apos.
      ENDIF.
*
      IF NOT xabwm-gitzl6 IS INITIAL.
        MOVE: xabwm-gitzl6 TO apos-gitzl,
              xabwm-gitsp6 TO apos-gitsp.
        apos-betrag = sav_anepv-aufnl + sav_anepv-aufnv.
        COLLECT apos.
      ENDIF.
*
      IF NOT xabwm-gitzl7 IS INITIAL.
        MOVE: xabwm-gitzl7 TO apos-gitzl,
              xabwm-gitsp7 TO apos-gitsp.
        apos-betrag = sav_anepv-invzl + sav_anepv-invzv.
        COLLECT apos.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    "nn_berechnen


*&---------------------------------------------------------------------*
*&      Form  stufe_aufreissen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM stufe_aufreissen.

  LOOP AT apos.
    WRITE: apos-gitzl  TO sum5-sukey(2),
           apos-gitsp  TO sum5-supos.
    MOVE:  apos-betrag TO sum5-betrag.
    COLLECT sum5.
  ENDLOOP.

ENDFORM.                    "stufe_aufreissen


*&---------------------------------------------------------------------*
*&      Form  apos_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM apos_init.

  REFRESH apos.
* Geruest der Tabelle APOS: Zu jeder Position ein Eintrag.
  LOOP AT uebs.
    MOVE: uebs-gitzl TO apos-gitzl,
          uebs-gitsp TO apos-gitsp,
          0          TO apos-betrag.
    APPEND apos.
  ENDLOOP.

ENDFORM.                    "apos_init


*&---------------------------------------------------------------------*
*&      Form  abgsimuflag_setzen1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FLAG       text
*----------------------------------------------------------------------*
FORM abgsimuflag_setzen1 USING flag.

* Default: Keine Abgangssimulation.
  flag = off.

* GWG-Klasse?
  MOVE anlav-anlkl TO rarep-gwgkl.
  READ TABLE so_gwgkl INDEX 1.
  IF sy-subrc EQ 0.
    CHECK so_gwgkl.
  ELSE.
    EXIT.
  ENDIF.

* ... Ja ! Aktivdatum im Simulationszeitraum?
  IF     NOT pa_simdv IS INITIAL AND
         NOT pa_simdb IS INITIAL .
    CHECK anlav-aktiv GE pa_simdv AND
          anlav-aktiv LE pa_simdb .
*
  ELSEIF     pa_simdv IS INITIAL AND
         NOT pa_simdb IS INITIAL .
    CHECK anlav-aktiv LE pa_simdb .
*
  ELSEIF NOT pa_simdv IS INITIAL AND
             pa_simdb IS INITIAL .
    CHECK anlav-aktiv GE pa_simdv .
*
  ELSE.
*   ... nein!
    EXIT.
  ENDIF.

* Zugang- und Abgang im gleichen Jahr
  IF ( anlav-aktiv BETWEEN sav_gjbeg AND sav_gjend ) AND
     ( anlav-deakt BETWEEN sav_gjbeg AND sav_gjend ).
*    EXIT.                                                     "> 683961
  ENDIF.

* Anlage ohne Werte
  IF anlcv-gja_kansw = 0    AND
     anlcv-gje_kansw = 0    AND
     anlcv-answl     = 0.
    EXIT.
  ENDIF.

* ... ja, dann Abg-Simu.
  flag = on.

ENDFORM.                    "abgsimuflag_setzen1


*&---------------------------------------------------------------------*
*&      Form  abgsimuflag_setzen2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FLAG       text
*----------------------------------------------------------------------*
FORM abgsimuflag_setzen2 USING flag.

* Default: Keine Abgangssimulation.
  flag = off.

* Klasse immaterieller WG?
  MOVE anlav-anlkl TO rarep-imwgkl.
  READ TABLE so_imwgk INDEX 1.
  IF sy-subrc EQ 0.
    CHECK so_imwgk.
  ELSE.
    EXIT.
  ENDIF.

* ... ja!
  flag = on.

ENDFORM.                    "abgsimuflag_setzen2


*&---------------------------------------------------------------------*
*&      Form  abga_simulieren
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM abga_simulieren.

  DATA:
*       Flag: Abgangssimulation fuer GWG erwuenscht.
        flg_abgsim1(1)    TYPE c,
*       Flag: Abgangssimulation fuer immaterielles WG erwuenscht.
        flg_abgsim2(1)    TYPE c,
*       Abgelaufene Nutzungsdauer bei immateriellen WGs.
        abg_ndjar         LIKE anlb-ndjar,
        abg_ndper         LIKE anlb-ndper,
*       decision indicator for new retirement simulation with newDCP
        ld_dec_ind        TYPE sy-tabix,                    "> 1060616
        ld_function       TYPE funcname.                    "> 1060616

* keine Abgangssimulation für deaktivierte Anlage oder Anlagen ohne
* Werte.
* IF ( NOT anlav-deakt IS INITIAL AND anlav-deakt <= berdatum )
*                   OR
*    ( anlcv-kansw IS INITIAL AND anlcv-answl IS INITIAL ).
*
*    EXIT.
* ENDIF.
* Default: Keine Abgangssimulationen.
  MOVE off TO: flg_abgsim1,
               flg_abgsim2.

* GWG mit Abg-Simu ==> Abg-Simu-Flag setzen.
  PERFORM abgsimuflag_setzen1 USING flg_abgsim1.
* Immaterielles WG mit Abg-Simu ==> Abg-Simu-Flag setzen.
  PERFORM abgsimuflag_setzen2 USING flg_abgsim2.

* Keine Simulation angefordert ==> Nix machen.
  CHECK flg_abgsim1 EQ on OR
        flg_abgsim2 EQ on.

* Abgangssimulation fuer ein GWG.
  IF flg_abgsim1 EQ on.

*   Buchwert zu GJ-Beginn = 0 ...
    IF anlcv-gja_bchwrt EQ 0 AND
*      ... und im LJ höchstens Abgänge ...
       anlcv-answl      LE 0 AND
*      ... Vorsicht: Abgang auf Neuzugang
       anlav-aktiv      LT sav_gjbeg.
*     ... dann so tun, als sei Anlage bereits Ende letzten Jahres
*     abgegangen (Kontinuitätsprinzip).
      REJECT 'ANLAV'.
    ENDIF.

*   If asset is low value asset, and capitalization date before start
*   of simulation time range, then cumulative values have to be kept at
*   fiscal year start
    IF anlav-aktiv LT pa_simdv.                             "> 1060616
      ADD 1 TO ld_dec_ind.                                  "> 1060616
    ENDIF.                                                  "> 1060616

*   Anlage vor dem LJ aktiviert aber Buchwert zu Beginn LJ = 0?
    IF anlcv-gja_bchwrt EQ 0        AND
*      ANLCV-GJE_BCHWRT NE 0         AND
       anlav-aktiv      LT sav_gjbeg .
*     Ja, dann Abgang zum Ende VJ simulieren.
      IF hlp_old_afar = con_x.                              "> 1060616
        PERFORM abga_simu_vj.
      ELSE.                                                 "> 1060616
        ADD 3 TO ld_dec_ind.                                "> 1060616
      ENDIF.                                                "> 1060616
    ENDIF.

*   Buchwert zu Ende LJ = 0 ?
    IF anlcv-gje_bchwrt EQ 0.
*     Ja, dann Abgang zum Ende LJ simulieren.
      IF hlp_old_afar = con_x.                              "> 1060616
        PERFORM abga_simu_lj.
      ELSE.                                                 "> 1060616
        ADD 7 TO ld_dec_ind.                                "> 1060616
      ENDIF.                                                "> 1060616
    ENDIF.

  ENDIF.

* Abgangssimulation fuer immaterielles WG.
  IF flg_abgsim2 EQ on
*   If already retirement simulation for LVA has been processed, then no
*   further retirement simulation on immaterial assets should be done.
    AND ld_dec_ind < 3.                                     "> 1060616

*   Abgelaufene Nutzungsdauer zum Ende VJ.
    abg_ndjar = anlcv-ndabj.
    abg_ndper = anlcv-ndabp.

*   Abg-Simu zum Ende VJ, wenn WG das Ende der Nutzungsdauer zu
*   diesem Zeitpunkt erreicht oder ueberschritten hat.
    IF    abg_ndjar GT anlb-ndjar     OR
        ( abg_ndjar EQ anlb-ndjar AND
          abg_ndper GE anlb-ndper )   .

*     Buchwert zu GJ-Beginn = 0 ...
      IF anlcv-gja_bchwrt EQ 0 AND
*        ... und keine Bewegungen im LJ ...
         anlcv-answl      EQ 0.
*       ... dann sogar so tun, als sei Anlage bereits Ende letzten
*       Jahres abgegangen (Kontinuitätsprinzip).
        REJECT 'ANLAV'.
      ENDIF.

*     Anlage vor dem LJ aktiviert aber Buchwert zu Beginn LJ = 0?
      IF anlcv-gja_bchwrt EQ 0         AND
         anlav-aktiv      LT sav_gjbeg .
*       Ja, dann Abgang zum Ende VJ simulieren.
        IF hlp_old_afar = con_x.                            "> 1060616
          PERFORM abga_simu_vj.
        ELSE.                                               "> 1060616
          ADD 15 TO ld_dec_ind.                             "> 1060616
        ENDIF.                                              "> 1060616
      ENDIF.

    ENDIF.

*   Abgelaufene Nutzungsdauer zum Ende LJ.
    abg_ndjar = anlcv-ndabj + '001'.
    abg_ndper = anlcv-ndabp.

*   Abg-Simu zum Ende LJ, wenn WG das Ende der Nutzungsdauer zu
*   diesem Zeitpunkt erreicht oder ueberschritten hat.
    IF    abg_ndjar GT anlb-ndjar     OR
        ( abg_ndjar EQ anlb-ndjar AND
          abg_ndper GE anlb-ndper )   .

*     Buchwert zu Ende LJ = 0 ?
      IF anlcv-gje_bchwrt EQ 0.
*       Ja, dann Abgang zum Ende LJ simulieren.
        IF ( anlav-deakt IS INITIAL OR anlav-deakt > berdatum )
                  AND NOT
           ( anlcv-kansw IS INITIAL AND anlcv-answl IS INITIAL ).
          IF hlp_old_afar = con_x.                          "> 1060616
            PERFORM abga_simu_lj.
          ELSE.                                             "> 1060616
            ADD 31 TO ld_dec_ind.                           "> 1060616
          ENDIF.                                            "> 1060616
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.

*** begin of insertion note 1060616
* In case of new depreciation calculation logic, simulate retirement
* according to decision indicators
  CHECK ld_dec_ind > 1 AND hlp_old_afar IS INITIAL.

  TRY.
*   decision indicator for low value and immaterial asset retirement
*   simulation
*   LVA (low value asset)           immaterial asset
*   1       3       7               15          31
*   1         = delete cumulative values for LVA
*   3 and 15  = skip prior year APC transactions in simulation for current year
*   7 and 31  = process simulation of current year acquisitions
      ld_function = 'FAA_DC_ENGINE_CALL_ON_RET_SIM'.
      CALL FUNCTION ld_function
        EXPORTING
          is_anlav              = anlav
          is_anlcv              = anlcv
          is_anlb               = anlb
          iv_reporting_date     = berdatum
          iv_decision_indicator = ld_dec_ind
        IMPORTING
          es_anlcv              = anlcv
        TABLES
          ct_anepv              = sav_anepv
        EXCEPTIONS                                          "> 1158549
          OTHERS                = 1.                        "> 1158549

    CATCH cx_sy_dyn_call_illegal_func.
  ENDTRY.

* wenn keine ANEPS gefunden dann reject.
  IF sav_anepv[] IS INITIAL.
    REJECT 'ANLAV'.
  ENDIF.
*** end of insertion note 1060616
ENDFORM.                    "abga_simulieren


*&---------------------------------------------------------------------*
*&      Form  abga_simu_vj
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM abga_simu_vj.

  DATA: BEGIN OF hlp_ants.
          INCLUDE STRUCTURE ants.
  DATA: END OF hlp_ants.

  DATA: BEGIN OF hlp_anlc OCCURS 1.
          INCLUDE STRUCTURE anlc.
  DATA: END OF hlp_anlc.

  DATA: BEGIN OF hlp_anea OCCURS 1.
          INCLUDE STRUCTURE anea.
  DATA: END OF hlp_anea.

  DATA: BEGIN OF hlp_anep OCCURS 1.
          INCLUDE STRUCTURE anep.
  DATA: END OF hlp_anep.

  DATA: BEGIN OF hlp_anlb OCCURS 1.
          INCLUDE STRUCTURE anlb.
  DATA: END OF hlp_anlb.

  DATA: BEGIN OF hlp_anfm OCCURS 1.
          INCLUDE STRUCTURE anfm.
  DATA: END OF hlp_anfm.

  DATA: BEGIN OF hlp_anlz OCCURS 1.
          INCLUDE STRUCTURE anlz.
  DATA: END OF hlp_anlz.

* Nicht-Wertfelder von HLP_ANLC aus ANLCV fuellen.
  CLEAR hlp_anlc.
  MOVE: anlcv-mandt  TO hlp_anlc-mandt,
        anlcv-bukrs  TO hlp_anlc-bukrs,
        anlcv-anln1  TO hlp_anlc-anln1,
        anlcv-anln2  TO hlp_anlc-anln2,
        anlcv-gjahr  TO hlp_anlc-gjahr,
        anlcv-afabe  TO hlp_anlc-afabe,
        anlcv-zujhr  TO hlp_anlc-zujhr,
        anlcv-zucod  TO hlp_anlc-zucod,
        anlcv-afblpe TO hlp_anlc-afblpe,
        anlcv-afbanz TO hlp_anlc-afbanz,
        anlcv-ndabj  TO hlp_anlc-ndabj,
        anlcv-ndabp  TO hlp_anlc-ndabp,
        anlcv-andsj  TO hlp_anlc-andsj,
        anlcv-andsp  TO hlp_anlc-andsp.
*
  APPEND hlp_anlc.

  MOVE-CORRESPONDING anlav TO hlp_ants.
  MOVE               anlb TO hlp_anlb. APPEND hlp_anlb.

* HLP_ANLC = ANLC-Segment nur aus Bewegungen auf Neuzugang.
  LOOP AT sav_anepv.
*   Nur Bewegungen auf Neuzugang durchlassen.
    READ TABLE yabw WITH KEY sav_anepv-bwasl.
    IF sy-subrc NE 0.
      DELETE sav_anepv.
      CHECK '1' EQ '0'.
    ENDIF.
    READ TABLE yabwg WITH KEY yabw-bwagrp.
    IF sy-subrc NE 0.
      DELETE sav_anepv.
      CHECK '1' EQ '0'.
    ENDIF.
    IF yabwg-xzugne IS INITIAL.
      DELETE sav_anepv.
      CHECK '1' EQ '0'.
    ENDIF.
*
    CLEAR:   hlp_anep, hlp_anea.
    REFRESH: hlp_anep, hlp_anea.
    MOVE-CORRESPONDING sav_anepv TO hlp_anep. APPEND hlp_anep.
    MOVE-CORRESPONDING sav_anepv TO hlp_anea. APPEND hlp_anea.
*   HLP_ANLC sukzessive hochaddieren.
    CALL FUNCTION 'ANEP_AFARECHNEN'
      EXPORTING
        i_ants              = hlp_ants
        i_cal_closed_fyears = 'X'
      TABLES
        t_anep              = hlp_anep
        t_anea              = hlp_anea
        t_anlb              = hlp_anlb
        t_anlc              = hlp_anlc
        t_anfm              = hlp_anfm
        t_anlz              = hlp_anlz.

  ENDLOOP.
* wenn keine ANEPS gefunden dann reject.
  IF hlp_anep[] IS INITIAL.
    REJECT 'ANLAV'.
  ENDIF.

  READ TABLE hlp_anlc INDEX 1.
  MOVE-CORRESPONDING hlp_anlc TO anlcv.

ENDFORM.                    "abga_simu_vj


*&---------------------------------------------------------------------*
*&      Form  abga_simu_lj
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM abga_simu_lj.

  DATA: BEGIN OF hlp_anlc OCCURS 1.
          INCLUDE STRUCTURE anlc.
  DATA: END OF hlp_anlc.

  DATA: BEGIN OF hlp_anepi OCCURS 1.
          INCLUDE STRUCTURE anepi.
  DATA: END OF hlp_anepi.

*********************** BEGIN OF NOTE 683961 ***************************
  DATA: ls_tabw             TYPE tabw.
  DATA: ls_tabwg            TYPE tabwg.
  DATA: ld_anbtr_neu        TYPE anbtr.
  DATA: ld_anbtr_alt        TYPE anbtr.

  FIELD-SYMBOLS: <fs_anepv> TYPE anepv.

  LOOP AT sav_anepv ASSIGNING <fs_anepv>.
    CALL FUNCTION 'TABW_READ'
      EXPORTING
        i_bwasl   = <fs_anepv>-bwasl
      IMPORTING
        f_tabw    = ls_tabw
        e_tabwg   = ls_tabwg
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF ls_tabwg-xzugne = con_x.
      ADD <fs_anepv>-anbtr TO ld_anbtr_neu.
    ELSE.
      ADD <fs_anepv>-anbtr TO ld_anbtr_alt.
    ENDIF.
  ENDLOOP.
*********************** END OF NOTE 683961 *****************************

  IF NOT anlav-deakt IS INITIAL AND anlav-deakt > sav_gjbeg.
    CLEAR anlav-deakt.
  ENDIF.

  MOVE-CORRESPONDING anlcv TO hlp_anlc. APPEND hlp_anlc.

* -------------- Begin Of Insertion Note 583014 ------------------------
  CALL FUNCTION 'LVA_RETIREMENT_SIMULATE'
    EXPORTING
      i_anlav                      = anlav
      i_gjahr                      = hlp_anlc-gjahr
*     i_bzdat                      = sav_gjend
      i_bzdat                      = berdatum               "> 683961
      i_waers                      = sav_waer1
      i_anbtr_neu                  = ld_anbtr_neu           "> 683961
      i_anbtr_alt                  = ld_anbtr_alt           "> 683961
    TABLES
      t_anepi                      = hlp_anepi
      t_anlc                       = hlp_anlc
    EXCEPTIONS
      error_occured                = 1
      OTHERS                       = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
* -------------- End Of Insertion Note 583014 --------------------------

* Neues ANLCV bilden.
  READ TABLE hlp_anlc INDEX 1.
  MOVE-CORRESPONDING hlp_anlc TO anlcv.

* Neuen ANEPV aus neuem ANEP/ANEA aufbauen ...
  LOOP AT hlp_anepi.
    CLEAR sav_anepv.                                        "> 926691
    MOVE-CORRESPONDING hlp_anepi TO sav_anepv.
*   ... und an SAV_ANEPV anhaengen.                            "> 926691
    APPEND sav_anepv.                                       "> 926691
  ENDLOOP.

  "<<< BEGIN OF INSERTION NOTE 68323

  IF t093b-abgja GE anlcv-gjahr.
    anlcv-answl = anlcv-answl + sav_anepv-anbtr.
    anlcv-nafap = anlcv-nafap + sav_anepv-nafab.
    anlcv-safap = anlcv-safap + sav_anepv-safab.
    anlcv-nafal = anlcv-nafal + sav_anepv-nafal.
    anlcv-nafav = anlcv-nafav + sav_anepv-nafav.
    anlcv-safal = anlcv-safal + sav_anepv-safal.
    anlcv-safav = anlcv-safav + sav_anepv-safav.
    anlcv-aafal = anlcv-aafal + sav_anepv-aafal.
    anlcv-aafav = anlcv-aafav + sav_anepv-aafav.
    anlcv-mafal = anlcv-mafal + sav_anepv-mafal.
    anlcv-mafav = anlcv-mafav + sav_anepv-mafav.
  ENDIF.
  "<<< END OF INSERTION NOTE 68323

ENDFORM.                    "abga_simu_lj


*&---------------------------------------------------------------------*
*&      Form  gitbez_lesen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM gitbez_lesen.
* TABWO einlesen.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM tabwo
*    WHERE spras  EQ sy-langu
*    AND   gitvrs EQ pa_gitvs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM tabwo
    WHERE spras  EQ sy-langu
    AND   gitvrs EQ pa_gitvs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* Gitterversion nicht in TABWO ==> Fehler.
  IF sy-subrc NE 0.
    MESSAGE e004 WITH sy-langu pa_gitvs.
  ELSE.
    MOVE tabwo-gitbez TO git_txt.
    MOVE tabwo-gitbez TO gitbez.
  ENDIF.
ENDFORM.                    "gitbez_lesen



* Allgemeine FORM-Routinen.
INCLUDE zaf_rasort_alv_misc.

* Formroutinen für den ABAP List Viewer
INCLUDE zaf_rasort_alv_tools.



*&---------------------------------------------------------------------*
*&      Form  lista
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM lista.


  REFRESH: fieldcat.
  CLEAR: fieldcat, layout, print.


* ALV
* Definicion de parametros de layout
  layout-no_keyfix = ' '.
  layout-zebra = 'X'.
  layout-colwidth_optimize = 'X'.

  wa_titulo = 'CUADRO FINANCIERO ACTIVO FIJO'.

  tit01 = 'SOCI'.



  PERFORM f_monta_fieldcat USING:
 '1'   'S1'      'ITAB_DATA' '' '0' ''        '' '' 'X' ''  '0' '' '' 'BUKRS'  'ANLAV',
 '1'   'S1_TEXT' 'ITAB_DATA' '' '0' ''        '' '' 'X' 'X' '0' '' '' ''       '',
 '1'  'S2'      'ITAB_DATA' '' '0' ''        '' '' 'X' ''  '0' '' '' 'GSBER'  'ANLAV',
 '1'  'S2_TEXT' 'ITAB_DATA' '' '0' ''        '' '' 'X' 'X' '0' '' '' ''       '',
 '1'  'S3'      'ITAB_DATA' '' '0' ''        '' '' 'X' ''  '0' '' '' 'ERGSO'  'ANLAV',
 '1'  'S3_TEXT' 'ITAB_DATA' '' '0' ''        '' '' 'X' 'X' '0' '' '' ''       '',
 '1'  'S4'      'ITAB_DATA' '' '0' '==ALPHA' '' '' 'X' ''  '0' '' '' 'KTANSW' 'ANLAV',
 '1'  'S4_TEXT' 'ITAB_DATA' '' '0' ''        '' '' 'X' 'X' '0' '' '' ''       '',
 '1'  'S5'      'ITAB_DATA' '' '0' '==ALPHA' '' '' 'X' ''  '0' '' '' 'ANLKL'  'ANLAV',
 '1'  'S5_TEXT' 'ITAB_DATA' '' '0' ''        '' '' 'X' 'X' '0' '' '' ''       '',
 '1'   'ANLN0'   'ITAB_DATA' ''      '0' '' 'C700' ''  '' '' '0'  'Activo fijo'     ''     '' 'ANLAV',
 '2'  'ANLN2'   'ITAB_DATA' ''      '0' '' 'C700' ''   '' '' '0'  'SNº'             ''     '' 'ANLAV',
 '3'  'AKTIV'   'ITAB_DATA' ''      '0' '' 'C700' ''   '' '' '0'  'Fe.capit.'       ''     '' 'ANLAV',
 '4'  'TXT50'   'ITAB_DATA' ''      '0' '' 'C700' ''   '' '' '0'  'Denominación AF' ''     '' 'ANLAV',
 '5'  'WAERS'   'ITAB_DATA' ''      '0' '' 'C700' ''   '' '' '0'  'Mon.'            ''     '' 'T093B',
 '6'  'BTR1'     'ITAB_DATA' 'WAERS' '0' '' ''     'X' '' '' '16' 'Valor Inic. Ej'  'CURR' '' '',
 '7'  'BTR2'    'ITAB_DATA' 'WAERS' '0' '' ''     'X' '' '' '16' 'Adiciones Año'   'CURR' '' '',
 '8'  'BTR3'    'ITAB_DATA' 'WAERS' '0' '' ''     'X' '' '' '16' 'Dep Baja'        'CURR' '' '',
 '9'  'BTR4'     'ITAB_DATA' 'WAERS' '0' '' ''     'X' '' '' '16' 'CM Año Act.'     'CURR' '' '',
 '10' 'BTR6'     'ITAB_DATA' 'WAERS' '0' '' ''     'X' '' '' '16' 'Dep Ej. Anter'   'CURR' '' '',
 '11' 'BTR7'    'ITAB_DATA' 'WAERS' '0' '' ''     'X' '' '' '16' 'Bajas Año'       'CURR' '' '',
 '12' 'BTR8'     'ITAB_DATA' 'WAERS' '0' '' ''     'X' '' '' '16' 'Dep Traslado'    'CURR' '' '',
 '13' 'BTR9'     'ITAB_DATA' 'WAERS' '0' '' ''     'X' '' '' '16' 'CM Dep Acum.'    'CURR' '' '',
 '14' 'BTR11'   'ITAB_DATA' 'WAERS' '0' ''  ''     'X' '' '' '16' 'ValCon In Ejer'  'CURR' '' '',
 '15' 'BTR12'   'ITAB_DATA' 'WAERS' '0' ''  ''     'X' '' '' '16' 'Traslados'       'CURR' '' '',
 '16' 'BTR13'   'ITAB_DATA' 'WAERS' '0' ''  ''     'X' '' '' '16' 'Dep Ejercicio'   'CURR' '' '',
 '17' 'BTR14'   'ITAB_DATA' 'WAERS' '0' ''  ''     'X' '' '' '16' 'CM Año Ant.'     'CURR' '' '',
 '18' 'BTR15'   'ITAB_DATA' 'WAERS' '0' ''  ''     'X' '' '' '16' 'Val Adq Ini'     'CURR' '' '',
 '19' 'BTR16'   'ITAB_DATA' 'WAERS' '0' ''  ''     'X' '' '' '16' 'Val.Cont.Actua'  'CURR' '' '',
 '20' 'BTR17'   'ITAB_DATA' 'WAERS' '0' ''  ''     'X' '' '' '16' 'Dep Acumulada'   'CURR' '' '',
 '21' 'BTR18'   'ITAB_DATA' 'WAERS' '0' ''  ''     'X' '' '' '16' 'CM Total'        'CURR' '' '',
 '22' 'BTR19'   'ITAB_DATA' 'WAERS' '0' ''  ''     'X' '' '' '16' 'CM Bajas'        'CURR' '' '',
 '23' 'BTR20'   'ITAB_DATA' 'WAERS' '0' ''  ''     'X' '' '' '16' 'CM DepAcum Ant'  'CURR' '' ''.

  print-no_print_listinfos = 'X'.
  print-no_print_selinfos  = 'X'.

  repid = sy-repid.

  DATA: ls_line TYPE slis_listheader.


  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = rt_events.
  READ TABLE rt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE 'TOP_OF_PAGE' TO ls_event-form.
    APPEND ls_event TO rt_events.
  ENDIF.



* LIST HEADING LINE: TYPE H
  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Sociedad         :'.
  ls_line-info = bukrs-low.
  APPEND ls_line TO gt_list_top_of_page.
* STATUS LINE: TYPE S
  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Area Valoracion  :'.
  ls_line-info = bereich1.
  APPEND ls_line TO gt_list_top_of_page.
  ls_line-key  = 'Fecha de Informe : '.
  CONCATENATE  berdatum+6(2) '/' berdatum+4(2) '/'  berdatum+0(4)  INTO ls_line-info.
  APPEND ls_line TO gt_list_top_of_page.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = repid
      i_structure_name         = 'itab_data'
      i_grid_title             = wa_titulo
      is_layout                = layout
      it_events                = rt_events[]
      it_fieldcat              = fieldcat[]
      is_print                 = print
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_pf_status_set = 'SET_STATUS'
    TABLES
      t_outtab                 = itab_data
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.                    "lista

*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM set_status  USING rt_extab TYPE slis_t_extab .         "#EC *
  SET PF-STATUS 'STATUS' EXCLUDING rt_extab.
ENDFORM.                    "set_statusnd
*---------------------------------------------------
* Monta el Fieldcat
*---------------------------------------------------
FORM f_monta_fieldcat USING  x_col_pos
                             x_field
                             x_tab
                             x_cfieldname
                             x_round
                             x_edit_mask
                             x_emphasize
                             x_do_sum
                             x_no_out
                             x_tech
                             x_largo
                             x_seltext_l
                             x_datatype
                             x_ref
                             x_ref_f.



  fieldcat-col_pos       = x_col_pos.
  fieldcat-fieldname     = x_field.
  fieldcat-tabname       = x_tab.
  fieldcat-cfieldname    = x_cfieldname.
  fieldcat-round         = x_round.
  fieldcat-edit_mask     =  x_edit_mask.
  fieldcat-emphasize     = x_emphasize.
  fieldcat-do_sum        = x_do_sum.
  fieldcat-no_out        = x_no_out.
  fieldcat-tech        = x_tech.
  fieldcat-outputlen     = x_largo.
  fieldcat-seltext_l     = x_seltext_l.
  fieldcat-datatype = x_datatype.
  fieldcat-ref_tabname   = x_ref.
  fieldcat-ref_fieldname = x_ref_f.


  APPEND fieldcat.
  CLEAR fieldcat.

ENDFORM.                    " Total_NAME_RSM

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                                      rs_selfield TYPE slis_selfield.


  IF r_ucomm = 'DOWN'.

    PERFORM guardo_informacion .

  ENDIF.






ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_list_top_of_page.
ENDFORM.                    "top_of_page
*&---------------------------------------------------------------------*
*&      Form  GUARDO_INFORMACION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM guardo_informacion .
  TABLES: zaf_ctribu, zaf_ctribu_log.
  DATA: total(8) TYPE n.
  DATA v_ans.
  SELECT COUNT(*)  FROM zaf_ctribu INTO total WHERE bukrs = bukrs-low
                           AND  afabe = bereich1
                           AND   brdatu = berdatum.

  IF total > 0.
    CALL FUNCTION 'POPUP_CONTINUE_YES_NO'
      EXPORTING
        defaultoption = 'Y'
        textline1     = 'Informacion para para parametros ingresados ya existe. '
        textline2     = 'Desea generar nuevamente?'
        titel         = 'Genracion de Informacion'
        start_column  = 25
        start_row     = 6
      IMPORTING
        answer        = v_ans.

  ELSE.
    v_ans = 'J'.
  ENDIF.

  IF v_ans EQ 'J'.
    DELETE FROM zaf_ctribu WHERE bukrs = bukrs-low
                           AND  afabe = bereich1
                           AND   brdatu = berdatum.

    zaf_ctribu-datum = sy-datum.
    zaf_ctribu-uzeit = sy-uzeit.
    zaf_ctribu-uname = sy-uname.

    zaf_ctribu_log-bukrs = bukrs-low.
    zaf_ctribu_log-afabe = bereich1.
    zaf_ctribu_log-brdatu = berdatum.

    zaf_ctribu_log-datum = zaf_ctribu-datum.
    zaf_ctribu_log-uzeit = zaf_ctribu-uzeit.
    zaf_ctribu_log-uname = zaf_ctribu-uname.

    INSERT zaf_ctribu_log.

    LOOP AT itab_data.
      zaf_ctribu-bukrs = bukrs-low.
      zaf_ctribu-afabe = bereich1.
      zaf_ctribu-brdatu = berdatum.
      zaf_ctribu-anln0 = itab_data-anln0.
      zaf_ctribu-anln2 = itab_data-anln2.
      zaf_ctribu-gsber = itab_data-s2.
      zaf_ctribu-ergso = itab_data-s3.
      zaf_ctribu-ktansw =  itab_data-s4.
      zaf_ctribu-anlkl =  itab_data-s5.
      zaf_ctribu-aktivd  = itab_data-aktiv.
      zaf_ctribu-txt50  = itab_data-txt50.
      zaf_ctribu-waers =  itab_data-waers.
      zaf_ctribu-valai15 = itab_data-btr15.
      zaf_ctribu-dpean06 = itab_data-btr6.
      zaf_ctribu-cmaan14 = itab_data-btr14.
      zaf_ctribu-cmdaa20 = itab_data-btr20.
      zaf_ctribu-valci11 = itab_data-btr11.
      zaf_ctribu-valie01 = itab_data-btr1.
      zaf_ctribu-adica02 = itab_data-btr2.
      zaf_ctribu-bajaa07 = itab_data-btr7.
      zaf_ctribu-trasl12 = itab_data-btr12.
      zaf_ctribu-dpeje13 = itab_data-btr13.
      zaf_ctribu-dpbaj03 = itab_data-btr3.
      zaf_ctribu-dptra08 = itab_data-btr8.
      zaf_ctribu-cmdpa09 = itab_data-btr9.
      zaf_ctribu-dpacu17 = itab_data-btr17.
      zaf_ctribu-cmbaj19 = itab_data-btr19.
      zaf_ctribu-cmaac04 = itab_data-btr4.
      zaf_ctribu-cmtot18 = itab_data-btr18.
      zaf_ctribu-valca16 = itab_data-btr16.
      zaf_ctribu-datum = sy-datum.
      zaf_ctribu-uzeit = sy-uzeit.
      zaf_ctribu-uname = sy-uname.

      INSERT zaf_ctribu.





    ENDLOOP.


  ENDIF.

  LEAVE TO SCREEN 0.

ENDFORM.                    " GUARDO_INFORMACION
