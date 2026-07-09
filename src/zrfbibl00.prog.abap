*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
REPORT zrfbibl00 MESSAGE-ID fb.

*----------------------------------------------------------------------*
*        Datendeklaration                                              *
*----------------------------------------------------------------------*
TABLES:
  dd02l.

DATA:
  xon     VALUE 'X',
  no_prot VALUE 'X'.

DATA:
  saprl  LIKE sy-saprl,
  sysid  LIKE sy-sysid,
  new_gn,
  gdate  LIKE sy-datum,
  gtime  LIKE sy-uzeit.



DATA:
  BEGIN OF tabtab OCCURS 3,
    tabname   LIKE dd02l-tabname,
    vorhanden,
  END OF tabtab.

DATA:
  BEGIN OF rep OCCURS 700,
    z(72),
  END OF rep.



*eject
*----------------------------------------------------------------------*
*        Selektionsbild                                                *
*----------------------------------------------------------------------*
*------- Aufbau des Selektionsbildes
************************************************************************
*        Falls 'Call Transaction ... Using ...' gewünscht, bitte die
*        die NO-DISPLAY-Zeilen bei Parameters ausstenen
*        Vor der Benutzung des 'Call Transaction ... Using ...'
*        bitte die Datei prüfen.
************************************************************************
SELECTION-SCREEN SKIP 1.

PARAMETERS: ds_name     LIKE rfpdo-rfbifile.  " Dateiname

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN SKIP 1.

PARAMETERS: fl_check LIKE rfpdo-rfbichck,    " Datei nur prüfen
            os_xon   LIKE  rfpdo-rfbioldstr, " Alte Strukturen ?
            xnonunic TYPE  rfpdo-rfbinonunic. "Nonunicode File
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN SKIP 1.
PARAMETERS: callmode    LIKE rfpdo-rfbifunct OBLIGATORY,
            max_comm(4) TYPE n DEFAULT '1000',  " Max Belege pro Commit
            pa_xprot(1) TYPE c.                 " erweitertes Protokoll
*                                              NO-DISPLAY.
*           ANZ_MODE:        A=alles N=nichts E=Error
PARAMETERS: anz_mode    LIKE rfpdo-allgazmd  " DEFAULT 'N'  Comentado por H_Foubert 28.05.2013
                                               NO-DISPLAY.
*           UPDATE:          S=Synchron A=Asynchron
PARAMETERS: update      LIKE rfpdo-allgvbmd    DEFAULT 'S'
                                               NO-DISPLAY.

* info messages as popup, log or no info
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
PARAMETERS: xpop TYPE c RADIOBUTTON GROUP rbl1,
            xlog TYPE c RADIOBUTTON GROUP rbl1,
            xinf TYPE c RADIOBUTTON GROUP rbl1.
SELECTION-SCREEN END   OF BLOCK bl1.

AT SELECTION-SCREEN ON callmode.
  IF callmode NA 'BCD'.
    MESSAGE e031.
  ENDIF.


LOAD-OF-PROGRAM.

  CLASS cl_abap_char_utilities DEFINITION LOAD.
  IF cl_abap_char_utilities=>charsize = 1.
    xnonunic = 'X'.
  ENDIF.



*eject
*---------------------------------------------------------------*
*  START-OF-SELECTION                                           *
*---------------------------------------------------------------*
START-OF-SELECTION.

*----------------------------------------------------------------------*
*        Hauptablauf                                                   *
*----------------------------------------------------------------------*

* Informationen zu Z-Strukturen einlesen
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM dd02l WHERE ( tabname = 'ZBSEG' OR
*                              tabname = 'ZSELP' )
*                      AND   as4local = 'A'
*                      AND   tabclass = 'INTTAB'.
*
* NEW CODE
  SELECT *
 FROM dd02l WHERE ( tabname = 'ZBSEG' OR
                              tabname = 'ZSELP' )
                      AND   as4local = 'A'
                      AND   tabclass = 'INTTAB' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    MOVE-CORRESPONDING dd02l TO tabtab.
    APPEND tabtab.
  ENDSELECT.

* Informationen aus RFBIBL02 einlesen
  READ REPORT 'RFBIBL02' INTO rep.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
  SORT rep .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
  READ TABLE rep INDEX 5.           "read release
  saprl = rep-z+30.
*ReSQ: No Need Of Change Internal Table REP Already Sorted
  READ TABLE rep INDEX 6.
  sysid = rep-z+30.
*ReSQ: No Need Of Change Internal Table REP Already Sorted
  READ TABLE rep INDEX 12.
  PERFORM tables_pruefen.
*ReSQ: No Need Of Change Internal Table REP Already Sorted
  READ TABLE rep INDEX 13.
  PERFORM tables_pruefen.

*ReSQ: No Need Of Change Internal Table REP Already Sorted
  READ TABLE rep INDEX 3.             "read generated date
  gdate = rep-z+30.
*ReSQ: No Need Of Change Internal Table REP Already Sorted
  READ TABLE rep INDEX 4.             "read generated time
  gtime = rep-z+30.
* Informationen zum Include COPABBSEG einlesen
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM dd02l WHERE tabname = 'COPABBSEG'
*                             AND   as4local = 'A'
*                             AND   tabclass = 'INTTAB'.
*
* NEW CODE
  SELECT *
 FROM dd02l WHERE tabname = 'COPABBSEG'
                             AND   as4local = 'A'
                             AND   tabclass = 'INTTAB' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    IF  dd02l-as4date GT gdate
    OR ( dd02l-as4date EQ gdate AND dd02l-as4time GT gtime ).
      MOVE-CORRESPONDING dd02l TO tabtab.
      APPEND tabtab.
    ENDIF.
  ENDSELECT.

* Informationen zu BBSEG einlesen
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM dd02l WHERE tabname = 'BBSEG'
*                             AND   as4local = 'A'
*                             AND   tabclass = 'INTTAB'.
*
* NEW CODE
  SELECT *
 FROM dd02l WHERE tabname = 'BBSEG'
                             AND   as4local = 'A'
                             AND   tabclass = 'INTTAB' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    IF  dd02l-as4date GT gdate
    OR ( dd02l-as4date EQ gdate AND dd02l-as4time GT gtime ).
      MOVE-CORRESPONDING dd02l TO tabtab.
      APPEND tabtab.
    ENDIF.
  ENDSELECT.

  LOOP AT tabtab WHERE vorhanden = space.
    new_gn = xon.
    EXIT.
  ENDLOOP.


* Neugenerierung von RFBIBL02 wenn notwendig.
  IF saprl <> sy-saprl OR sysid <> sy-sysid OR new_gn = xon.
    SUBMIT rfbiblg0 AND RETURN.
  ENDIF.


* Report RFBIBL01 aufrufen
* INI - JOROZCO 21.01.2020
*  SUBMIT RFBIBL01 WITH  DS_NAME   =   DS_NAME
  SUBMIT zrfbibl01_v2 WITH  ds_name   =   ds_name
* FIN - JOROZCO 21.01.2020
                      WITH  fl_check  =   fl_check
                      WITH  os_xon    =   os_xon
                      WITH  xnonunic =    xnonunic
                      WITH  callmode  =   callmode
                      WITH  max_comm  =   max_comm
                      WITH  pa_xprot  =   pa_xprot
                      WITH  anz_mode  =   anz_mode
                      WITH  update    =   update
                      WITH  xpop      =   xpop
                      WITH  xlog      =   xlog
                      WITH  xinf      =   xinf
                      AND RETURN.
*----------------------------------------------------------------------*
*        FORM TABLES_PRUEFEN                                           *
*----------------------------------------------------------------------*
*        Prüfen ob zur TABLES-Anweisung Tabelle vorhanden ist          *
*----------------------------------------------------------------------*
FORM tables_pruefen.

  IF rep(6) = 'TABLES'.
    tabtab = space.
    tabtab-tabname = rep+7(6).
    READ TABLE tabtab.
    IF sy-subrc = 0.
      tabtab-vorhanden = xon.
      MODIFY tabtab INDEX sy-tabix.
    ELSE.
      new_gn = xon.
    ENDIF.
  ENDIF.

ENDFORM.



*----------------------------------------------------------------------*
