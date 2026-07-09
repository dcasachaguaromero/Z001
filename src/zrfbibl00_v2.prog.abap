REPORT zrfbibl00_v2 MESSAGE-ID fb.

*----------------------------------------------------------------------*
*        Datendeklaration                                              *
*----------------------------------------------------------------------*
TABLES:
    dd02l.

DATA:
    xon         VALUE 'X',
    no_prot     VALUE 'X'.

DATA:
    saprl       LIKE sy-saprl,
    sysid       LIKE sy-sysid,
    new_gn,
    gdate       LIKE sy-datum,
    gtime       LIKE sy-uzeit.



DATA:
    BEGIN OF tabtab OCCURS 3,
        tabname     LIKE dd02l-tabname,
        vorhanden,
    END OF tabtab.

DATA:
    BEGIN OF rep OCCURS 700,
        z(72),
    END OF rep.

DATA  l_bmv0 TYPE xfeld.

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

PARAMETERS: fl_check    LIKE rfpdo-rfbichck,    " Datei nur prüfen
            os_xon      LIKE  rfpdo-rfbioldstr MODIF ID ec1, " Alte Strukturen ?
            xnonunic    TYPE  rfpdo-rfbinonunic MODIF ID ec1. "Nonunicode File
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN SKIP 1.
PARAMETERS: callmode    LIKE rfpdo-rfbifunct OBLIGATORY,
            max_comm(4) TYPE n DEFAULT '1000' MODIF ID ec1,  " Max Belege pro Commit
            pa_xprot(1) TYPE c MODIF ID ec1.                 " erweitertes Protokoll
*                                              NO-DISPLAY.
*           ANZ_MODE:        A=alles N=nichts E=Error
PARAMETERS: anz_mode    LIKE rfpdo-allgazmd    DEFAULT 'N'
                                               NO-DISPLAY.
*           UPDATE:          S=Synchron A=Asynchron
PARAMETERS: update      LIKE rfpdo-allgvbmd    DEFAULT 'S'
                                               NO-DISPLAY.

* info messages as popup, log or no info
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: xpop  TYPE c RADIOBUTTON GROUP rbl1 MODIF ID ec1,
            xlog  TYPE c RADIOBUTTON GROUP rbl1 MODIF ID ec1,
            xinf  TYPE c RADIOBUTTON GROUP rbl1 MODIF ID ec1.
SELECTION-SCREEN END   OF BLOCK bl1.

* ECS-fields
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
PARAMETERS: p_iftype  LIKE gle_tecs_if001-type MODIF ID ec2,
            p_run_re  TYPE gle_ecs_item-runid_ext MODIF ID ec2 MATCHCODE OBJECT gle_h_ecs_di_restart_runid.
SELECTION-SCREEN END   OF BLOCK bl2.

* Modify screen for callmode ECS-Direct Input (E)
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF callmode = 'E'.
      IF screen-group1 = 'EC1'.
        screen-active = '0'.
      ENDIF.

      IF screen-name = 'P_IFTYPE'.
        screen-required = '1'.
      ENDIF.
    ENDIF.
    IF cl_fagl_switch_check=>fagl_fin_err_corr( ) IS INITIAL
      AND screen-group1 = 'EC2'.
      screen-active = '0'.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN ON callmode.
  IF cl_fagl_switch_check=>fagl_fin_err_corr( ) IS INITIAL.
    IF callmode NA 'BCD'.
      MESSAGE e031.
    ENDIF.
  ELSE.
    IF callmode NA 'BCDE'.
      MESSAGE e031.
    ENDIF.
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
  IF callmode = 'E'.
*   Check input parameters and submit to ECS report
    IF p_iftype IS INITIAL.
      MESSAGE e054(gle_al_ecs_srv).
    ENDIF.

    IF sy-batch IS NOT INITIAL.
      CALL FUNCTION 'GET_JOB_RUNTIME_INFO'
          EXCEPTIONS
            OTHERS                  = 2.
       IF sy-subrc = 0.
         l_bmv0 = gle_if_ecs_constants=>con_true.
       ELSE.
         CLEAR l_bmv0.
       ENDIF.
    ENDIF.

    CALL FUNCTION 'NUMBER_GET_INFO'
      EXPORTING
        nr_range_nr = '01'
        object      = gle_if_ecs_constants=>con_nrobj_ecs_runid
      EXCEPTIONS
        OTHERS      = 1.
    IF sy-subrc <> 0.
      MESSAGE e004(fagl_runadm) WITH gle_if_ecs_constants=>con_nrobj_ecs_runid.
    ENDIF.

    SUBMIT rgle_ecs_direct_input_pp
            WITH p_file   = ds_name
            WITH p_iftype = p_iftype
            "WITH p_rstart = '' "will be drived inside ECS report from BMV0 info
            WITH p_bmv0   = l_bmv0
            WITH p_run_re = p_run_re
            WITH p_sim    = fl_check.

  ENDIF.

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
  READ TABLE rep INDEX 5.           "read release
  saprl = rep-z+30.
  READ TABLE rep INDEX 6.
  sysid = rep-z+30.
  READ TABLE rep INDEX 12.
  PERFORM tables_pruefen.
  READ TABLE rep INDEX 13.
  PERFORM tables_pruefen.

  READ TABLE rep INDEX 3.             "read generated date
  gdate = rep-z+30.
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
* INI ----------------------------------------------------- JOROZCO 18.02.2020
*  SUBMIT rfbibl01 WITH  ds_name   =   ds_name
  SUBMIT zrfbibl01_v2 WITH  ds_name   =   ds_name
* FIN ----------------------------------------------------- JOROZCO 18.02.2020
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

ENDFORM.                    "TABLES_PRUEFEN



*----------------------------------------------------------------------*
