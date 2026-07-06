*---------------------------------------------------------------*
*   Report zum Verarbeiten des Elektronischen Kontoauszugs      *
*---------------------------------------------------------------*
REPORT RFEBKA30 MESSAGE-ID FB
                LINE-SIZE 132
                NO STANDARD PAGE HEADING.

*---------------------------------------------------------------*
*  Include Common Data                                          *
*---------------------------------------------------------------*
INCLUDE RFEBKA03.
INCLUDE RFEBFR03.                      " Data France
INCLUDE RFEKAP00.                                             "n927883

TABLES: RFSDO,
        SSCRFIELDS.
data:   l_avsrt type avik-avsrt value '02',               "note 596474
        l_febep type febep,                               "note 596474
        l_xexit type c.                                   "note 596474
*---------------------------------------------------------------*
*  Parameters                                                   *
*---------------------------------------------------------------*
*------- Dateiangaben -------------------------------------------------
SELECTION-SCREEN  BEGIN OF BLOCK 1 WITH FRAME TITLE TEXT-177.
*SELECT-OPTIONS: S_ANWND FOR FEBKO-ANWND,
select-options:                                   "note 620244
                S_AZDAT FOR FEBKO-AZDAT,
                S_AZNUM FOR FEBKO-AZNUM,
                S_HBKID FOR FEBKO-HBKID,
                S_HKTID FOR FEBKO-HKTID,
*                s_ktonr FOR febko-ktonr,
                S_BUKRS FOR FEBKO-BUKRS,
                S_WAERS FOR FEBKO-WAERS.
SELECTION-SCREEN  END OF BLOCK 1.

*------- Buchungsparameter ---------------------------------------------
SELECTION-SCREEN  BEGIN OF BLOCK 2 WITH FRAME TITLE TEXT-160.
SELECTION-SCREEN  BEGIN OF LINE.
PARAMETERS: PA_XCALL LIKE FEBPDO-XCALL    RADIOBUTTON GROUP 1.
SELECTION-SCREEN
  COMMENT 03(29) TEXT-161 FOR FIELD PA_XCALL.
PARAMETERS: PA_XBKBU LIKE FEBPDO-XBKBU.
SELECTION-SCREEN
  COMMENT 35(16) TEXT-171 FOR FIELD PA_XBKBU.
PARAMETERS: PA_MODE  LIKE RFPDO-ALLGAZMD NO-DISPLAY.
*   SELECTION-SCREEN
*     COMMENT 55(20) TEXT-162 FOR FIELD PA_MODE NO-DISPLAY.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN  BEGIN OF LINE.
PARAMETERS: PA_XBDC  LIKE FEBPDO-XBINPT   RADIOBUTTON GROUP 1.
SELECTION-SCREEN
  COMMENT 03(29) TEXT-163 FOR FIELD PA_XBDC.
SELECTION-SCREEN
  COMMENT 35(15) TEXT-164 FOR FIELD MREGEL.
PARAMETERS: MREGEL   LIKE RFPDO1-FEBMREGEL DEFAULT '1'.
SELECTION-SCREEN: END OF LINE.
SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS: PA_TEST LIKE RFPDO1-FEBTESTL RADIOBUTTON GROUP 1.
SELECTION-SCREEN
  COMMENT 03(29) TEXT-168 FOR FIELD PA_TEST.
PARAMETERS: pa_no_pp type no_pp_eb.                         "note 596474
SELECTION-SCREEN                                            "note 596474
  COMMENT 55(30) TEXT-179 FOR FIELD pa_no_pp.               "note 596474
SELECTION-SCREEN: END OF LINE.

PARAMETERS: VALUT_ON     LIKE RFPDO2-FEBVALUT DEFAULT 'X'.
SELECTION-SCREEN  END OF BLOCK 2.

*------- Finanzdisposition ---------------------------------------------
*ziclos modificacion
*SELECTION-SCREEN  BEGIN OF BLOCK 5 WITH FRAME TITLE TEXT-172.
*SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS: PA_XDISP LIKE FEBPDO-XDISP no-display.  "ziclos
*SELECTION-SCREEN
*  COMMENT 03(29) TEXT-170 FOR FIELD PA_XDISP.
PARAMETERS: PA_VERD  LIKE RFFFPDO1-FFDISXVERD no-display. "ziclos
*SELECTION-SCREEN
*  COMMENT 34(15) TEXT-174 FOR FIELD PA_VERD.
*SELECTION-SCREEN
*  COMMENT 55(15) TEXT-173 FOR FIELD PA_DSART.
PARAMETERS: PA_DSART LIKE FDES-DSART no-display.
*SELECTION-SCREEN: END OF LINE.
*SELECTION-SCREEN  END OF BLOCK 5.


*------- Interpretationsparameter --------------------------------------
*ziclos
*SELECTION-SCREEN  BEGIN OF BLOCK 3 WITH FRAME TITLE TEXT-166.
**ARAMETERS: USEREXIT     LIKE RFPDO1-FEBUEXIT.                   "30D
**SELECTION-SCREEN: BEGIN OF LINE.
**SELECTION-SCREEN
**  COMMENT 01(31) TEXT-169 FOR FIELD SELFD.
**PARAMETERS: SELFD        LIKE RFPDO1-FEBSELFD.
**PARAMETERS: SELFDLEN     LIKE RFPDO1-FEBSELFDL.
**SELECTION-SCREEN: END OF LINE.
DATA: NUM10(10) TYPE N.
DATA: CHR16(16) TYPE C.
*SELECT-OPTIONS: S_FILTER FOR  RFSDO-FEBFILTER.
SELECT-OPTIONS: S_FILTER FOR  FEBPDO-FEBFILTER1 no-display.  "ziclos
SELECT-OPTIONS: T_FILTER FOR  FEBPDO-FEBFILTER2 no-display.  "ziclos
*SELECTION-SCREEN: BEGIN OF LINE.
*SELECTION-SCREEN
*   COMMENT 01(31) TEXT-176 FOR FIELD PA_BDART.
PARAMETERS: PA_BDART     LIKE FEBPDO-BDART  no-display.  "ziclos
*SELECTION-SCREEN
*   COMMENT 36(21) TEXT-178 FOR FIELD PA_BDANZ.
PARAMETERS: PA_BDANZ     LIKE FEBPDO-BDANZ no-display.   "ziclos
*SELECTION-SCREEN: END OF LINE.
*SELECTION-SCREEN  END OF BLOCK 3.

*------- Ausgabeparameter ----------------------------------------------
SELECTION-SCREEN  BEGIN OF BLOCK 4 WITH FRAME TITLE TEXT-167.
PARAMETERS: BATCH        LIKE RFPDO2-FEBBATCH,
*             SPOOL        LIKE RFPDO2-FEBSPOOL,
            P_KOAUSZ     LIKE RFPDO1-FEBPAUSZ,   " Kontoauszug drucken
            P_BUPRO      LIKE RFPDO2-FEBBUPRO,
            P_STATIK     LIKE RFPDO2-FEBSTAT,
            PA_LSEPA     LIKE FEBPDO-LSEPA.
SELECTION-SCREEN  END OF BLOCK 4.




*eject
*---------------------------------------------------------------*
*  AT SELECTION-SCREEN                                          *
*---------------------------------------------------------------*

*------- Dateiangaben -------------------------------------------------
AT SELECTION-SCREEN ON BLOCK 1.



*------- Buchungsparameter --------------------------------------------
AT SELECTION-SCREEN ON BLOCK 2.

  IF NOT PA_XBDC IS INITIAL.
*   Batch Input erzeugen
    IF MREGEL IS INITIAL.
      SET CURSOR FIELD 'MREGEL'.
      MESSAGE E619(FV).
    ENDIF.
    IF NOT PA_XBKBU IS INITIAL.
      SET CURSOR FIELD 'PA_XBKBU'.
      MESSAGE E611(FV).
    ENDIF.
  ENDIF.


*------- Algorithmen  -------------------------------------------------
*ziclos no hace falta
*AT SELECTION-SCREEN ON BLOCK 3.
*  CLEAR T_FILTER.
*
*  LOOP AT T_FILTER.
*    SHIFT T_FILTER-LOW  RIGHT DELETING TRAILING ' '.
*    SHIFT T_FILTER-HIGH RIGHT DELETING TRAILING ' '.
*    MODIFY T_FILTER.
*  ENDLOOP.
*
*  CASE PA_BDART.
*    WHEN 1.
*      IF NOT PA_BDANZ IS INITIAL.
*        SET CURSOR FIELD 'PA_BDANZ'.
*        MESSAGE E618(FV).
*      ENDIF.
*    WHEN 2.
*      IF PA_BDANZ IS INITIAL.
*        SET CURSOR FIELD 'PA_BDANZ'.
*        MESSAGE E615(FV).
*      ENDIF.
*  ENDCASE.
*---- Ausgabesteuerung
AT SELECTION-SCREEN ON BLOCK 4.
  IF SY-BATCH = 'X'.
    IF BATCH NE 'X'.
      BATCH = 'X'.
    ENDIF.
  ENDIF.

*---- Program started with EXEC+PRINT online
  IF BATCH NE 'X'.
    IF P_BUPRO = 'X' OR P_STATIK = 'X'.
      IF SSCRFIELDS-UCOMM = 'PRIN'.
        EXECPRI = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

*------- Finanzdisposition --------------------------------------------
*ziclos modificacions
*AT SELECTION-SCREEN ON BLOCK 5.
*  IF NOT PA_XDISP IS INITIAL.
**   Call Transaktion
*    IF NOT PA_XCALL IS INITIAL.
*      SET CURSOR FIELD 'PA_XDISP'.
*      MESSAGE E610(FV).
*    ENDIF.
*    IF PA_DSART IS INITIAL.
*      SET CURSOR FIELD 'PA_DSART'.
*      MESSAGE E612(FV).
*    ENDIF.
*  ENDIF.






*eject
*---------------------------------------------------------------*
*  START-OF-SELECTION                                           *
*---------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM SET_PRINT_PARAMETERS USING EXECPRI
                                     PRI_PARAM
                                     ARC_PARAM.
  PERFORM INITIALIZATION.
  VGEXT_OK = TRUE.


*---------------------------------------------------------------*
*  Selektion der Kontoauszuege                                  *
*---------------------------------------------------------------*
*  SELECT * FROM FEBKO WHERE ANWND IN S_ANWND AND
  SELECT * FROM FEBKO WHERE ANWND = ANWND AND        "note 620244
                            ASTAT <> '8' AND          "hw380862
                            AZDAT IN S_AZDAT.
    CHECK FEBKO-AZNUM IN S_AZNUM.
    CHECK FEBKO-BUKRS IN S_BUKRS.
    CHECK FEBKO-WAERS IN S_WAERS.
    CHECK FEBKO-HBKID IN S_HBKID.
    CHECK FEBKO-HKTID IN S_HKTID.
*    CHECK febko-ktonr IN s_ktonr.
    clear l_xexit.
    if pa_no_pp = 'X'.                                      "note 596474
      select * from febep into l_febep                      "note 596474
                         where kukey = febko-kukey.         "note 596474
        if not ( l_febep-vb1ok is initial                   "note 596474
           and l_febep-belnr is initial                     "note 596474
           and l_febep-ak1bl is initial                     "note 596474
           and l_febep-b1doc is initial                     "note 596474
           and l_febep-vb2ok is initial                     "note 596474
           and l_febep-nbbln is initial                     "note 596474
           and l_febep-akbln is initial                     "note 596474
           and l_febep-b2doc is initial ).                  "note 596474
          l_xexit = 'X'.                                    "note 596474
          exit.                                             "note 596474
        endif.                                              "note 596474
      endselect.                                            "note 596474
    endif.                                                  "note 596474
    check l_xexit is initial.                               "note 596474
    CLEAR S_KUKEY.
    S_KUKEY-SIGN   = 'I'.
    S_KUKEY-OPTION = 'EQ'.
    S_KUKEY-LOW    =   FEBKO-KUKEY.
    APPEND S_KUKEY.
  ENDSELECT.


*---------------------------------------------------------------*
*  Export Print Parameters to Memory                            *
*  Moved ahead, together with close_print_parameters       "hw819271
*---------------------------------------------------------------*
  PERFORM EXPORT_PRI_PARAMS USING EXECPRI
                            PRI_PARAM ARC_PARAM.
  PERFORM CLOSE_PRINT_PARAMETERS  USING EXECPRI.           "hw819271


*---------------------------------------------------------------*
*  Kontoauszug drucken                                          *
*---------------------------------------------------------------*
  IF P_KOAUSZ = 'X'.
*   die zu druckenden Kontoauszuege sind in Range S_KUKEY (Global Data)
    DESCRIBE TABLE S_KUKEY LINES TFILL_S_KUKEY.
    IF TFILL_S_KUKEY > 0 AND VGEXT_OK = TRUE.          "MP
*    IF TFILL_S_KUKEY > 0.                             "MP
      PERFORM SET_PRINT_PARAMETERS USING BATCH
                                     PRI_PARAM
                                     ARC_PARAM.
      PERFORM DRUCK_KONTOAUSZUG.
      PERFORM EXPORT_PRINT_PARAMETERS USING BATCH
                                      PRI_PARAM
                                      ARC_PARAM.
      PERFORM CLOSE_PRINT_PARAMETERS USING BATCH.
    ENDIF.
  ENDIF.


*---------------------------------------------------------------*
*  Finanzdispo Avise erzeugen                                   *
*---------------------------------------------------------------*
  IF PA_XDISP = 'X'.
    PERFORM FINANZDISPO_AVISE_ERZEUGEN.
  ENDIF.


*---------------------------------------------------------------*
*  Verbuchung aufrufen                                          *
*---------------------------------------------------------------*

  IF  PA_XDISP  = 'X'
  AND PA_TEST   = 'X'.
*   falls FINANZDISPOAVISE und NICHT BUCHEN Verbuchung nicht aufrufen
  ELSE.
*   Verbuchung aufrufen, falls externe Vorgänge in T028G
    IF VGEXT_OK = TRUE.
      PERFORM VERBUCHUNG_AUFRUFEN.
    ELSE.
      DESCRIBE TABLE S_KUKEY LINES TFILL_S_KUKEY.            "MP30F
      IF TFILL_S_KUKEY > 0.                                  "MP30F
        PERFORM SET_PRINT_PARAMETERS USING BATCH
                                       PRI_PARAM
                                       ARC_PARAM.
          PERFORM WRITE_WRONG_T028G.
          PERFORM DRUCK_KONTOAUSZUG.                         "MP30F
          PERFORM CLOSE_PRINT_PARAMETERS USING BATCH.
          PERFORM DELETE_STATEMENT.                          "MP30F
      ENDIF.                                                 "MP30F
    ENDIF.
  ENDIF.



** Begin of insertion by C5053252 - Added to RFEBKA30 with note 927883
* To decide which list is having data and which one should be displayed
* first
* Used to control set pf status
* Layout setting
  gv_list_control = 0.

  DESCRIBE TABLE ITAB_BASE_REC_TRANS LINES GV_COUNT_LIST0 .
  DESCRIBE TABLE ITAB_BASE_REC_TRANS_HEADER LINES GV_COUNT_LIST01 .
  DESCRIBE TABLE gt_outtab LINES  GV_COUNT_LIST1 .
  DESCRIBE TABLE gt_outtab2 LINES GV_COUNT_LIST2 .
  DESCRIBE TABLE gt_outtab3 LINES GV_COUNT_LIST3 .
  describe table gt_rfebbu01_output lines gv_count_list_rfebbu01.
  describe table gt_rfebfd00_h lines gv_count_list_rfebfd00.
  describe table gt_messages lines gv_count_messages.

  clear gv_RFEBFI20_ALV .

  IF  NOT GV_COUNT_LIST0  IS INITIAL and
      NOT GV_COUNT_LIST01 IS INITIAL .
    gv_RFEBFI20_ALV = 'X'.
  ENDIF .

  perform end_of_list.

** End of insertion by C5053252 - Added to RFEBKA30 with note 927883

*eject
*--------------------------------------------------------------*
*  Seitenanfangsverarbeitung                                   *
*--------------------------------------------------------------*
TOP-OF-PAGE.
*------------------------Batch-Heading-Routine aufrufen--------*
  PERFORM BATCH-HEADING(RSBTCHH0).

  WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.

  IF PRINTFLAG = 'A'.
    PERFORM DRUCK_BANKUEBERSCHRIFT.
  ENDIF.

END-OF-SELECTION.
  IF SY-BATCH <> 'X'.
    DESCRIBE TABLE S_KUKEY LINES TFILL_S_KUKEY.
    IF TFILL_S_KUKEY > 0.
      MESSAGE S612.
    ELSE.
      MESSAGE I613.
    ENDIF.
  ENDIF.


*eject
****************************************************************
** Form-Routinen                                               *
****************************************************************
*---------------------------------------------------------------*
*  FORM VERBUCHUNG_AUFRUFEN.                                    *
*---------------------------------------------------------------*
FORM VERBUCHUNG_AUFRUFEN.

* Wenn Range leer und Einlesen angeXt, dann gab es keine zu verbuchenden
* Kontoauszüge. Z.B. wenn alle Ktoauszüge schon eingelesen wurden.
  DESCRIBE TABLE S_KUKEY LINES TFILL_S_KUKEY.
  IF TFILL_S_KUKEY = 0.
    EXIT.
  ENDIF.

* Felder für Reportaufruf füllen.
  IF BATCH = 'X'.
    JOBNAME(8)     = SY-REPID.
    JOBNAME+8(1)   = '-'.
    JOBNAME+9(14)  = TEXT-002.

    EXPORTID(8)    = SY-REPID.
    EXPORTID+8(8)  = SY-DATUM.
    EXPORTID+16(6) = SY-UZEIT.
    LOOP AT S_KUKEY.
      EXPORTID+23(8) = S_KUKEY-LOW.
      EXIT.
    ENDLOOP.
  ENDIF.

* IF SPOOL = 'X'.                       " QHA  GB
*    CLEAR PRI_PARAM.                   " QHA  GB
*    PRI_PARAM = %_PRINT.               " QHA  GB
*    EXPORT PRI_PARAM TO MEMORY.        " QHA  GB
*    IF SY-SUBRC NE 0.                  " QHA  GB
*       SPOOL = ' '.                    " QHA  GB
*    ENDIF.                             " QHA  GB
* ENDIF.                                " QHA  GB



* Verbuchungsreport aufrufen falls Buchungen erzeugt werden sollen.
  IF BUBER NE SPACE.
    SUBMIT ZFI_RFEBBU01 AND RETURN
                    USER SY-UNAME
                    WITH ANWND    =  ANWND
                    WITH S_KUKEY  IN S_KUKEY
                    WITH JOBNAME  =  JOBNAME
                    WITH EXPORTID =  EXPORTID
                    WITH BUBER    =  BUBER
*                   WITH USEREXIT =  USEREXIT                     "30D
*                    WITH SELFD    =  SELFD
*                    WITH SELFDLEN =  SELFDLEN
                    WITH S_FILTER IN S_FILTER
                    WITH T_FILTER IN T_FILTER
                    WITH PA_BDART =  PA_BDART
                    WITH PA_BDANZ =  PA_BDANZ
                    WITH FUNCTION =  FUNCTION
                    WITH MODE     =  MODE
                    WITH MREGEL   =  MREGEL
                    WITH PA_EFART =  EFART
                    WITH P_BUPRO  =  P_BUPRO
*                   WITH SPOOL    =  SPOOL
                    WITH P_STATIK =  P_STATIK
                    WITH VALUT_ON =  VALUT_ON
                    WITH TESTL    =  PA_TEST
                    WITH EXECPRI  = EXECPRI.

*   Jobcount importieren
    IMPORT JOBCOUNT FROM MEMORY ID EXPORTID.

*   WRITE: / 'Jobcount = ', JOBCOUNT.
  ENDIF.
ENDFORM.

*eject
*&---------------------------------------------------------------------*
*&      Form  FINANZDISPO_AVISE_ERZEUGEN
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
FORM FINANZDISPO_AVISE_ERZEUGEN.
  LOOP AT S_KUKEY.
    SELECT * FROM FEBKO WHERE KUKEY = S_KUKEY-LOW.
    ENDSELECT.
    IF SY-SUBRC = 0.
      SUBMIT RFEBFD00 AND RETURN
                      USER SY-UNAME
                      WITH P_BUKRS  =  FEBKO-BUKRS
                      WITH P_HBKID  =  FEBKO-HBKID
                      WITH P_HKTID  =  FEBKO-HKTID
                      WITH R_AZNUM  =  FEBKO-AZNUM
                      WITH R_AZDAT  =  FEBKO-AZDAT
                      WITH BI-NAME  =  SY-REPID
                      WITH BI-DSART =  PA_DSART
                      WITH P_VERD   =  PA_VERD.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " FINANZDISPO_AVISE_ERZEUGEN

*eject
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       Felder initialisieren                                          *
*----------------------------------------------------------------------*
FORM INITIALIZATION.
  IF NOT PA_XCALL IS INITIAL.
    FUNCTION = 'C'.
  ENDIF.
  IF NOT PA_XBDC  IS INITIAL.
    FUNCTION = 'B'.
  ENDIF.
  MODE     = PA_MODE.

  IF  PA_XCALL = 'X'
  AND PA_XBKBU = 'X'.
    BUBER    = '1'.
  ELSE.
    BUBER    = 'A'.
  ENDIF.
  ANWND    = '0001'.                   "Anwendung Zwischenspeicher
  EFART    = 'E'.                      "Electronischer Kontoauszug

* IF SY-PDEST NE SPACE.                             " QHA
*    SPOOL  = 'X'.                                  " QHA
* ENDIF.                                            " QHA

ENDFORM.                               " INITIALIZATION


*eject
*&---------------------------------------------------------------------*
*&      Form  WRITE_WRONG_T028G
*&---------------------------------------------------------------------*
*       Ausgabe der fehlenden Einträge in T028G                        *
*----------------------------------------------------------------------*
FORM WRITE_WRONG_T028G.
  PRINTFLAG = SPACE.
  NEW-PAGE.
*     Druck der ext. Vorgänge, die nicht in T028G enhalten sind.
  WRITE: /01 SY-VLINE,  TEXT-010,  132 SY-VLINE.
  WRITE: /01 SY-VLINE,  TEXT-011,  132 SY-VLINE.
  WRITE: /01 SY-VLINE,  TEXT-012,  132 SY-VLINE.
  WRITE: /01 SY-VLINE,  TEXT-013,  132 SY-VLINE.
  WRITE: /01 SY-VLINE,  TEXT-014,  132 SY-VLINE.
  WRITE: /01 SY-VLINE,  TEXT-015,  132 SY-VLINE.
  WRITE: /01 SY-VLINE,  TEXT-017,  132 SY-VLINE.
*  WRITE: /01 SY-VLINE,  TEXT-018,  132 SY-VLINE.           "MP
*  WRITE: /01 SY-VLINE,  TEXT-019,  132 SY-VLINE.           "MP
*  WRITE: /01 SY-VLINE,  TEXT-020,  132 SY-VLINE.           "MP
  WRITE: /01 SY-VLINE,  TEXT-010,  132 SY-VLINE.
  WRITE: /01 SY-VLINE,  TEXT-030,  132 SY-VLINE.
  WRITE: /01 SY-VLINE,  TEXT-031,  132 SY-VLINE.

  WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.

  LOOP AT NOTT028G.
    WRITE: /01     SY-VLINE,
            03(08) NOTT028G-VGTYP,
            12(27) NOTT028G-VGEXT,
            40(01) NOTT028G-VOZPM,
            44(20) TEXT-032,
            65(15) NOTT028G-BANKL,
            81(18) NOTT028G-KTONR,
           100(05) NOTT028G-AZNUM,
           106(08) NOTT028G-KUKEY,
           115(05) NOTT028G-ESNUM,
           132     SY-VLINE.
  ENDLOOP.

  WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.

  MESSAGE S773.
ENDFORM.                               " WRITE_WRONG_T028G




*&---------------------------------------------------------------------*
*&      Form  EXPORT_PRINT_PARAMETERS
*&---------------------------------------------------------------------*
*       export print parameters to memory if batch run                 *
*----------------------------------------------------------------------*
FORM EXPORT_PRINT_PARAMETERS USING P_BATCH
                             P_PRI_PARAM
                             P_ARC_PARAM.

  IF  SY-BATCH = 'X' OR P_BATCH = 'X'.
    CLEAR PRI_KEY.
    PRI_KEY-REPID = 'RFEBBU00'.
    LOOP AT S_KUKEY.
      PRI_KEY-KUKEY = S_KUKEY-LOW.
      EXIT.
    ENDLOOP.

    EXPORT   PRI_PARAM   ARC_PARAM TO MEMORY
                                      ID PRI_KEY.
  ENDIF.
ENDFORM.                    " EXPORT_PRINT_PARAMETERS


*eject
*&---------------------------------------------------------------------*
*&      Form  SET_PRINT_PARAMETERS
*&---------------------------------------------------------------------*
*       set print parameters if program runs in batch                  *
*----------------------------------------------------------------------*
FORM SET_PRINT_PARAMETERS USING P_BATCH
                            P_PRI_PARAM
                            P_ARC_PARAM.
  DATA: LIST_NAME LIKE PRI_PARAMS-PLIST.

  IF SY-BATCH = 'X' OR P_BATCH = 'X'.
    LIST_NAME     = SY-REPID.
    CALL FUNCTION 'GET_PRINT_PARAMETERS'
         EXPORTING
              NO_DIALOG              = 'X'
              LIST_NAME              = LIST_NAME
              MODE                   = 'CURRENT'
         IMPORTING
              OUT_ARCHIVE_PARAMETERS = P_ARC_PARAM
              OUT_PARAMETERS         = P_PRI_PARAM.

    NEW-PAGE  PRINT ON  PARAMETERS P_PRI_PARAM
                ARCHIVE PARAMETERS P_ARC_PARAM
                                   NO DIALOG.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM CLOSE_PRINT_PARAMETERS                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_BATCH                                                       *
*---------------------------------------------------------------------*
FORM CLOSE_PRINT_PARAMETERS USING P_BATCH.
  IF SY-BATCH = 'X' OR P_BATCH = 'X'.
    NEW-PAGE  PRINT OFF.
    MESSAGE I640(FV) WITH SY-SPONO.
  ENDIF.
ENDFORM.                               " CLOSE_PRINT_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  DELETE_STATEMENT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_STATEMENT.
  SELECT * FROM FEBKO  WHERE KUKEY IN S_KUKEY AND ANWND = '0001'.
    DELETE FROM FEBRE WHERE KUKEY = FEBKO-KUKEY.
    DELETE FROM FEBEP WHERE KUKEY = FEBKO-KUKEY.

    MOVE-CORRESPONDING FEBKO TO FEBVW.
    DELETE FEBVW.
    DELETE FEBKO.
  ENDSELECT.
ENDFORM.                    " DELETE_STATEMENT

*&---------------------------------------------------------------------*
*&      Form  EXPORT_PRI_PARAMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EXECPRI  text                                              *
*      -->P_PRI_PARAMS  text                                           *
*----------------------------------------------------------------------*
FORM EXPORT_PRI_PARAMS USING    P_EXECPRI
                                P_PRI_PARAM
                                P_ARC_PARAM.

 IF P_EXECPRI = 'X' OR ( ( BATCH = 'X' ) AND
    ( P_KOAUSZ NE 'X' ) ).
    CLEAR PRI_KEY.
    PRI_KEY-REPID = 'RFEBBU00'.
    LOOP AT S_KUKEY.
      PRI_KEY-KUKEY = S_KUKEY-LOW.
      EXIT.
    ENDLOOP.
    EXPORT   PRI_PARAM   ARC_PARAM TO MEMORY
                                   ID PRI_KEY.

  ENDIF.

ENDFORM.                               " EXPORT_PRI_PARAMS
*----------------------------------------------------------------------*
