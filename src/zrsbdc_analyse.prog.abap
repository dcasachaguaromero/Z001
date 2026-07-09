*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*                     REPORT    RSBDC_ANALYSE
*
*      Analysis of batch input sessions for a given queue id
*              Report is called by transaction SM35
*
*                      (C) SAP AG 1998 - 2000
*
*                      version history:
*
* 03.11.1998 es - first completed version
* 03.02.1999 es - minor interface changes and other fixes
* 24.03.1999 es - (new) handling of TemSe log files enabled
* 29.03.1999 es - complete CUA (scrolling)
* 03.08.1999 es - small fixes: status of deleted trx, tc initialization
* 05.05.2000 es - update trx name and status in header correctly
* 04.09.2000 es - display RABAX in form show_ltext correctly
* 06.10.2000 es - (new) unicode-save queue dump
* 11.10.2000 es - unlock sessions/modify keep flag in APQI dump display
* 12.10.2000 es - refresh protocol (while watching running sessions)
* 08.12.2000 es - don't jump back to transaction 1 when changing tabs
*
*----------------------------------------------------------------------*

REPORT  ZRSBDC_ANALYSE MESSAGE-ID 00.

PARAMETERS:
  QUEUE_ID LIKE APQI-QID,
  TCOD_IDX TYPE I NO-DISPLAY,
  DYNP_IDX TYPE I NO-DISPLAY.

INCLUDE RSBDCIL3.   "Read plain log from TemSe
TYPE-POOLS: ICON, SDYDO.

TABLES:
  APQI, APQD, APQL, T100, SNAP, BDC_SESSIO.

CONTROLS:
  TC_TCODES   TYPE TABLEVIEW USING SCREEN 200,
  TC_DYNPRO   TYPE TABLEVIEW USING SCREEN 300,
  TC_PROTOCOL TYPE TABLEVIEW USING SCREEN 400,
  TC_BDCLD    TYPE TABLEVIEW USING SCREEN 600,
  TC_Q_TCODES TYPE TABLEVIEW USING SCREEN 700,
  TAB_DYNPRO  TYPE TABSTRIP,
  TAB_APQI    TYPE TABSTRIP.

FIELD-SYMBOLS:
  <MTXT>,
  <VTXT>.

DATA:
* this table keeps those tcodes actually displayed
  BEGIN OF BDC_TCODES OCCURS 0,
    INDEX TYPE I, TCODE LIKE SY-TCODE, STATUS(1), S_TEXT(16),
  END OF BDC_TCODES,
* this table keeps all tcodes of the session
  BEGIN OF ALL_BDC_TCODES OCCURS 0,
    INDEX TYPE I, TCODE LIKE SY-TCODE, STATUS(1), S_TEXT(16),
  END OF ALL_BDC_TCODES.

DATA:
* this table keeps those dynpros actually displayed
  BEGIN OF BDC_DYNPRO OCCURS 0,
    PROGRAM LIKE SY-CPROG, DYNPRO LIKE SY-DYNNR,
    FNAM LIKE BDCDATA-FNAM, FVAL LIKE BDCDATA-FVAL,
    INDEX(5) TYPE C,
  END OF BDC_DYNPRO,
* this table keeps all dynpros of the session
  BEGIN OF ALL_BDC_DYNPRO OCCURS 0,
    PROGRAM LIKE SY-CPROG, DYNPRO LIKE SY-DYNNR,
    FNAM LIKE BDCDATA-FNAM, FVAL LIKE BDCDATA-FVAL,
    INDEX(5) TYPE C,
  END OF ALL_BDC_DYNPRO,

  DYNPRO_INDEX TYPE I,
  CAT_BDCDATA LIKE BDCDATA OCCURS 0 WITH HEADER LINE.

DATA:
* this table keeps protocol lines to be displayed
  BEGIN OF BDC_PROTOCOL OCCURS 0.
        INCLUDE STRUCTURE BDCLM.
DATA:
    LONGTEXT TYPE BDC_MPAR,
  END OF BDC_PROTOCOL.

DATA:
  IT_APQD LIKE APQD OCCURS 0 WITH HEADER LINE,
  UDAT LIKE APQD-VARDATA, SDAT LIKE APQD-VARDATA.

DATA:
  BEGIN OF TF OCCURS 0,       "interne tabelle mit dynprofeldern
    COUNT TYPE I VALUE 0,     "zum abmischen
    TRCD(4),STAT(4),
    PGM(8),                   "programmname
    DYN(4) TYPE N,            "dynpronummer
    FNAME(35), FARG(132), FSTART(5) TYPE P, FENDE(5) TYPE P,
  END OF TF.

* needed for check if TemSe interface is active:
DATA: PROTPARAM(60) VALUE 'bdc/new_protocol',
      NEWPROT(3)    VALUE 'off'.

* message header
DATA:
  BEGIN OF BDCMH,
    MTYPE, STATE,
    TCODE(20),                                              " (4 -> 20)
    PROG(40),                                               " (8 -> 40)
    DYNR(4), SEPC, FILLER,
  END OF BDCMH.

* transaction header
DATA:
  BEGIN OF BDCTH,
    MTYPE, STATE,
    TCODE(20),                                              " (4 -> 20)
    POSTG, PRINT,
    MSGID(20),                                              " (2 -> 20)
  END OF BDCTH.

DATA:
  BDCMHLEN TYPE I VALUE 68, " (20 -> 68 ) MessageHeaderlaenge
  DCNT TYPE I, TCNT TYPE I, GENCNT TYPE I, DELCNT TYPE I, WCOUNT TYPE I,
  MFSTART TYPE I, MFENDE TYPE I, MFLEN TYPE I, MFART(2).

DATA BEGIN OF BDCLM  OCCURS 0.     " ITabelle der Messageseintraege
        INCLUDE STRUCTURE BDCLM.  " LogTabelle
DATA: COUNTER TYPE I,
      LONGTEXT TYPE BDC_MPAR,
      ISDETAIL(1) TYPE C,
      END OF BDCLM .

DATA: LM LIKE BDCLM,
      SAVE_MPAR TYPE BDC_MPAR.

DATA BEGIN OF BDCLD  OCCURS 0.     " ITabelle der Verzeichniseintraege
        INCLUDE STRUCTURE BDCLD.   " LogTabelle aller Protokolle
DATA: LOGNAME(80),                 " protokollpfad
      LOCAL_HOST(12),              " lokaler rechner
      CNT TYPE I,                  " satzzaehler
      ACTIVE(1) TYPE C,            " active flag
      TEMSEID TYPE RSTSONAME.      " TemSe ID
DATA END OF BDCLD .

DATA:
   LOGTAB LIKE BDCLD OCCURS 0 WITH HEADER LINE,
   LOGTAB_TEMSE LIKE APQL OCCURS 0 WITH HEADER LINE.

DATA:
  MAIN_OKCODE TYPE FCODE,
  D0500_FCODE TYPE FCODE,
  D0600_FCODE TYPE FCODE,
  D0700_FCODE TYPE FCODE,
  D0701_FCODE TYPE FCODE,
  TC_MARK(1),
  COUNTER TYPE I,
  STATUS_ICON(32),
  DYNPROTAB_SUBSCREEN_DYNPRO LIKE SY-DYNNR,
  HEADER_SUBSCREEN_DYNPRO LIKE SY-DYNNR.

DATA:
  EX_DATE(12), STRING(48), TAB_PROTO(48).

* Radio buttons and checkbox on screen 0500
DATA:
  BEGIN OF RB,
     TCODES_ALL VALUE 'X', TCODES_ERROR,
     FIELDLIST VALUE ' ',
     PRO_ALL VALUE 'X', PRO_TCODE, PRO_SESSION,
     LOG_DETAIL,
  END OF RB.

DATA:
* Flags for identifying contents of the bdc_... tables
  BDC_TCODES_CONTENT(1),   "a: all, e: errors
  BDC_DYNPRO_CONTENT(1),   "f: fieldlist, s: screens only
  BDC_PROTOCOL_CONTENT(1), "a: all, t: for transaction, s: for session

  BDC_LINES LIKE SY-INDEX,
  C_FIELD(132),
  C_LINE TYPE I,
  SELECTED_INDEX LIKE SY-INDEX,
  SELECTED_PROTOCOL LIKE SY-INDEX,
  TC_INDEX LIKE SY-INDEX,
  TC_SELECT LIKE SY-INDEX,
  TCODE_INDEX LIKE BDC_TCODES-INDEX,
  TCODE_INDEX_APQD LIKE BDC_TCODES-INDEX,
  1ST_BDC_TCODE_INDEX LIKE BDC_TCODES-INDEX,
  I_TCODES TYPE I,
  I_PROTOCOLS TYPE I,
  TCODE LIKE SY-TCODE,
  TCODE_STATUS(16),
  PREVIOUS_TAB(64).

* Data needed for CATT simulation of screens
DATA:
  BEGIN OF BDC_SUBSCREEN,
    PROGRAM LIKE SY-CPROG,
    DYNPRO  LIKE SY-DYNNR,
    SUBSCR(64),
  END OF BDC_SUBSCREEN.

* Table for keeping fcodes to be excluded from pf-status
DATA:
  BEGIN OF EX_CUA OCCURS 2,
    FCODE LIKE RSMPE-FUNC,
  END OF EX_CUA.

* data for keeping scoll infos
DATA:
  CURRENT_PAGE LIKE SY-TABIX VALUE 1,
  NEW_PAGE     LIKE SY-TABIX,
  TOTAL_PAGES  LIKE SY-TABIX,
  NEW_LINE     LIKE SY-TABIX,
  ENTRIES      LIKE SY-TABIX,
  LOOPC        LIKE SY-LOOPC.

* data for queue dump
DATA:
  BEGIN OF Q,
    TCODE_INDEX LIKE ALL_BDC_TCODES-INDEX,
    ITAB_INDEX LIKE ALL_BDC_TCODES-INDEX,
    C_FIELD(132),
    C_LINE LIKE SY-INDEX,
    C_AREA(132),
    WA LIKE LINE OF ALL_BDC_TCODES,
    CONTROL_INIT VALUE 'X',
    REUSE_CONTROL,
    UC_BYTES TYPE I,
    C(1),
    SHOW_HEX VALUE ' ',
  END OF Q.

DATA:
  T TYPE SDYDO_TEXT_ELEMENT,
  C(128).

TYPES:
  BEGIN OF BLOCK,
    DT     TYPE REF TO CL_DD_TABLE_ELEMENT,
    DTA    TYPE REF TO CL_DD_TABLE_AREA,
  END OF BLOCK.

DATA:
  IT_BLOCKS TYPE STANDARD TABLE OF BLOCK,
  B_WA TYPE BLOCK.

DATA:
  DD      TYPE REF TO CL_DD_DOCUMENT,
  CUST    TYPE REF TO CL_GUI_CUSTOM_CONTAINER.

TYPES:
  BEGIN OF CX,
    CHAR(1) TYPE C,
    HEX(4)  TYPE X,
    XTOC(8) TYPE C,
  END OF CX,
  UC_1(1) TYPE X,
  UC_2(2) TYPE X,
  UC_4(4) TYPE X.

DATA:
  IT_CX TYPE STANDARD TABLE OF CX,
  CX TYPE CX.

FIELD-SYMBOLS:
  <C> TYPE C,
  <X>.

DATA:
  BEGIN OF COUNT,
    START TYPE I,
    INDEX TYPE I,
    PART  TYPE I,
    REST  TYPE I,
  END OF COUNT.

DATA:
  CSPAN TYPE I.

CONSTANTS:
  NR_COLS TYPE I VALUE 64,
  RELOAD_APQI VALUE 'X'.

DATA:
  BEGIN OF APQDCNT,
    TRANSCNTB TYPE APQ_TRAN,  "neu
    MSGCNTB   TYPE APQ_RECO,
    TRANSCNTE TYPE APQ_TRAN,  "fehlerhaft
    MSGCNTE   TYPE APQ_RECO,
    TRANSCNTO TYPE APQ_TRAN,  "noch zu verarbeiten
    MSGCNTO   TYPE APQ_RECO,
    TRANSCNTF TYPE APQ_TRAN,  "verarbeitet
    MSGCNTF   TYPE APQ_RECO,
    TRANSCNTD TYPE APQ_TRAN,  "gelöscht
    MSGCNTD   TYPE APQ_RECO,
    TRANSCNT  TYPE APQ_TRAN,  "enthält aktuell
    MSGCNT    TYPE APQ_RECO,
    TRANSCNTX TYPE APQ_TRAN,  "entfernt
    MSGCNTX   TYPE APQ_RECO,
    TRANSCNTP TYPE APQ_TRAN,  "angelegt
    MSGCNTP   TYPE APQ_RECO,
  END OF APQDCNT.

DATA:
  DYNPRO_CNT TYPE I,
  SHOW_DYNPRO_CNT VALUE ' '.

TYPES: BEGIN OF TY_DATA,
  BUKRS LIKE  BSEG-BUKRS,
  BELNR LIKE  BSEG-BELNR,
  BUZEI LIKE  BSEG-BUZEI,
  GJAHR LIKE  BSEG-GJAHR,
  HKONT LIKE  BSEG-HKONT,
  STATUS LIKE ICON-ID,
  CHEK1(1) TYPE C,
  WRBTR LIKE BSEG-WRBTR,
  CHECT LIKE  PAYR-CHECT,
  HKONTD LIKE  BSEG-HKONT, " se deja cuenta de destino.
  SGTXT  LIKE  BSEG-SGTXT, " TEXTO
  DATEV  TYPE I,
  ESTADO(51) TYPE C,
  VBLNR  LIKE  PAYR-VBLNR,
  BLDAT  LIKE  BKPF-BLDAT,
END OF TY_DATA.
* DefiniciÃ³n de tablas internas.
DATA: T_OK type standard table of TY_DATA.


*----------------------------------------------------------------------*
*----------------------------------------------------------------------*

START-OF-SELECTION.

  PERFORM PREPARE USING QUEUE_ID.
  IMPORT ti_data to T_OK from memory id 'DESTARE2'.
*
  LOOP AT BDCLM.

write: BDCLM-LONGTEXT.

  ENDLOOP.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  prepare
*&---------------------------------------------------------------------*

FORM PREPARE USING QID TYPE APQI-QID.

  CLEAR: BDC_TCODES_CONTENT, BDC_DYNPRO_CONTENT, BDC_PROTOCOL_CONTENT.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM APQI WHERE QID = QID.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM APQI WHERE QID = QID ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF SY-SUBRC <> 0.
    MESSAGE I307(00) WITH 'Lesen'(010) 'mit Queue-ID'(011) QID.
    LEAVE PROGRAM.
  ENDIF.
* check authority first
  AUTHORITY-CHECK OBJECT 'S_BDC_MONI'
             ID 'BDCAKTI'     FIELD 'ANAL'
             ID 'BDCGROUPID'  FIELD APQI-GROUPID.
  IF SY-SUBRC > 0.
    MESSAGE S396(00) WITH APQI-GROUPID. LEAVE PROGRAM.
  ENDIF.

* goto fieldlist if index-parameters are filled
  IF TCOD_IDX > 0 AND
     DYNP_IDX > 0.
    TCODE_INDEX  = TCOD_IDX.
    DYNPRO_INDEX = DYNP_IDX.
    PERFORM SCAN_TRANSACTION USING TCODE_INDEX.
    MAIN_OKCODE = 'DISPLAY'.
    TAB_DYNPRO-ACTIVETAB = 'TAB_LIST'.
  ENDIF.

* read transaction information
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      TEXT = 'Transaktionen einlesen ...'(003).
  PERFORM FILL_ALL_BDC_TCODES.        " find all transactions

* find all protocols
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      TEXT = 'Protokolle suchen ...'(004).
  PERFORM GET_LOGFILES_FOR_QID.       " logfiles -> bdcld
  IF SELECTED_PROTOCOL > 0.
    PERFORM GET_LOG USING 1.          " most recent log -> bdclm
    PERFORM EXTEND_MESSAGE_TEXTS.     " extended texts -> bdclm
    SELECTED_PROTOCOL = 1.
  ENDIF.

  GET PARAMETER ID 'RSBDC_ANALYSE_RB' FIELD RB.
  IF SY-SUBRC <> 0.
    RB-TCODES_ALL = 'X'. RB-PRO_ALL = 'X'.
  ENDIF.

  EX_CUA-FCODE = 'FL_ON'.   APPEND EX_CUA.
  EX_CUA-FCODE = 'FL_OFF'.  APPEND EX_CUA.
  EX_CUA-FCODE = 'GOTO_FL'. APPEND EX_CUA.

ENDFORM.                    "prepare

*----------------------------------------------------------------------*
*       Module loopc
*----------------------------------------------------------------------*

MODULE LOOPC OUTPUT.
  LOOPC = SY-LOOPC.
ENDMODULE.                    "loopc OUTPUT

*----------------------------------------------------------------------*
*       Module status_main
*----------------------------------------------------------------------*

MODULE STATUS_MAIN OUTPUT.

  CLEAR MAIN_OKCODE.
  SET TITLEBAR '0100' WITH APQI-GROUPID.

  LOOP AT SCREEN.
* set text of tabstrip tab for protocol display or set tab invisible if
* no protocol was found for the qid
    IF SCREEN-NAME = 'TAB_PROTO'.
      IF SELECTED_PROTOCOL IS INITIAL.
        SCREEN-INVISIBLE = 1. MODIFY SCREEN.
      ELSE.
        WRITE BDCLD-EDATE TO EX_DATE.
        CONCATENATE '@96@' 'Protokoll vom'(020) EX_DATE    "ICON_HISTORY
                    INTO TAB_PROTO SEPARATED BY ' '.
      ENDIF.
    ENDIF.
  ENDLOOP.

* set header and subscreen dynpro depending on active tab
  CASE TAB_DYNPRO-ACTIVETAB.
    WHEN 'TAB_TCODES'.
      PERFORM BUILD_EX_CUA USING 'FL_ON' 'FL_OFF' 'GOTO_FL' ''.
      SET PF-STATUS 'PF_MAIN' EXCLUDING EX_CUA.
      DYNPROTAB_SUBSCREEN_DYNPRO = '0200'.
      HEADER_SUBSCREEN_DYNPRO    = '0201'.
    WHEN 'TAB_LIST'.
      IF RB-FIELDLIST = 'X'.
        PERFORM BUILD_EX_CUA USING 'FL_ON' 'GOTO_FL' '' ''.
      ELSE.
        PERFORM BUILD_EX_CUA USING 'FL_OFF' 'GOTO_FL' '' ''.
      ENDIF.
      SET PF-STATUS 'PF_MAIN_NAVI' EXCLUDING EX_CUA.
      DYNPROTAB_SUBSCREEN_DYNPRO = '0300'.
      HEADER_SUBSCREEN_DYNPRO    = '0301'.
    WHEN 'TAB_PROTO'.
      PERFORM BUILD_EX_CUA USING 'FL_ON' 'FL_OFF' '' ''.
      IF RB-PRO_TCODE = 'X'.
        SET PF-STATUS 'PF_MAIN_NAVI' EXCLUDING EX_CUA.
      ELSE.
        SET PF-STATUS 'PF_MAIN' EXCLUDING EX_CUA.
      ENDIF.
      DYNPROTAB_SUBSCREEN_DYNPRO = '0400'.
      HEADER_SUBSCREEN_DYNPRO    = '0401'.
    WHEN OTHERS.
      PERFORM BUILD_EX_CUA USING 'FL_ON' 'FL_OFF' 'GOTO_FL' ''.
      SET PF-STATUS 'PF_MAIN' EXCLUDING EX_CUA.
      TAB_DYNPRO-ACTIVETAB = 'TAB_TCODES'.
      DYNPROTAB_SUBSCREEN_DYNPRO = '0200'.
      HEADER_SUBSCREEN_DYNPRO    = '0201'.
  ENDCASE.

* is this the first call?
  IF TCODE_INDEX IS INITIAL.
    TCODE_INDEX  = 1.
    TCODE        = ALL_BDC_TCODES-TCODE.
    TCODE_STATUS = ALL_BDC_TCODES-S_TEXT.
  ELSE.
*   tcode_index was already set in PAI
    TCODE        = BDC_TCODES-TCODE.
    TCODE_STATUS = BDC_TCODES-S_TEXT.
  ENDIF.

ENDMODULE.                    "status_main OUTPUT

*----------------------------------------------------------------------*
*       Module exit_main
*----------------------------------------------------------------------*

MODULE EXIT_MAIN INPUT.
  SET PARAMETER ID 'RSBDC_ANALYSE_RB' FIELD RB.
  LEAVE PROGRAM.
ENDMODULE.                    "exit_main INPUT

*----------------------------------------------------------------------*
*       Module user_command_main
*----------------------------------------------------------------------*

MODULE USER_COMMAND_MAIN INPUT.

  IF TAB_DYNPRO-ACTIVETAB <> 'TAB_TCODES'.
    PREVIOUS_TAB = TAB_DYNPRO-ACTIVETAB.
  ENDIF.

  CASE MAIN_OKCODE.
*   change the active tab
    WHEN 'TAB_TCODES'.
      TAB_DYNPRO-ACTIVETAB = 'TAB_TCODES'.
    WHEN 'TAB_LIST'.
      TAB_DYNPRO-ACTIVETAB = 'TAB_LIST'.
    WHEN 'TAB_PROTO'.
      TAB_DYNPRO-ACTIVETAB = 'TAB_PROTO'.
*   select entry for display
    WHEN 'DISPLAY' OR 'GOTO_FL'.
      PERFORM SET_NEW_DISPLAY.
*   change the viewing options
    WHEN 'VIEW_OPT'.
      CALL SCREEN 500 STARTING AT 5 5.
*   show list of protocols
    WHEN 'PROTO'.
      IF SELECTED_PROTOCOL > 0.
        CALL SCREEN 600 STARTING AT 5 5.
      ELSE.
        MESSAGE S324(00).
      ENDIF.
    WHEN 'PROTO_REFRESH'.
*  reload protocol file (while watching running sessions)
      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          TEXT = 'Protokoll wird erneut gelesen ...'(006).
      PERFORM GET_LOG USING SELECTED_PROTOCOL.
      PERFORM EXTEND_MESSAGE_TEXTS.
      CLEAR BDC_PROTOCOL_CONTENT.
*   switch field list on or off
    WHEN 'FL_ON'. RB-FIELDLIST = 'X'.
    WHEN 'FL_OFF'. RB-FIELDLIST = ' '.
*   go to first transaction
    WHEN 'FIRST'.
      IF TCODE_INDEX > 1.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT BDC_TCODES .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
        READ TABLE BDC_TCODES INDEX 1.
        TCODE_INDEX = 1.
        PERFORM SCAN_TRANSACTION USING BDC_TCODES-INDEX.
        CLEAR: BDC_DYNPRO_CONTENT, BDC_PROTOCOL_CONTENT.
      ENDIF.
*   go to next transaction
    WHEN 'NEXT'.
      IF TCODE_INDEX < I_TCODES.
        TCODE_INDEX = TCODE_INDEX + 1.
*ReSQ: No Need Of Change Internal Table BDC_TCODES Already Sorted
        READ TABLE BDC_TCODES INDEX TCODE_INDEX.
        PERFORM SCAN_TRANSACTION USING BDC_TCODES-INDEX.
        CLEAR: BDC_DYNPRO_CONTENT, BDC_PROTOCOL_CONTENT.
      ENDIF.
*   go to previous transaction
    WHEN 'PREV'.
      IF TCODE_INDEX > 1.
        TCODE_INDEX = TCODE_INDEX - 1.
*ReSQ: No Need Of Change Internal Table BDC_TCODES Already Sorted
        READ TABLE BDC_TCODES INDEX TCODE_INDEX.
        PERFORM SCAN_TRANSACTION USING BDC_TCODES-INDEX.
        CLEAR: BDC_DYNPRO_CONTENT, BDC_PROTOCOL_CONTENT.
      ENDIF.
*   go to last transaction
    WHEN 'LAST'.
      IF TCODE_INDEX < I_TCODES.
        TCODE_INDEX = I_TCODES.
*ReSQ: No Need Of Change Internal Table BDC_TCODES Already Sorted
        READ TABLE BDC_TCODES INDEX I_TCODES.
        PERFORM SCAN_TRANSACTION USING BDC_TCODES-INDEX.
        CLEAR: BDC_DYNPRO_CONTENT, BDC_PROTOCOL_CONTENT.
      ENDIF.
*   scrolling in table controls
    WHEN 'P-' OR 'P--' OR 'P+' OR 'P++'.
      PERFORM SCROLLING.
*   display queue dump
    WHEN 'QUEUE'.
      CALL SCREEN '0700'.
*   display header (APQI)
    WHEN 'APQI'.
      CALL SCREEN '0701'.
*   recalculate dynpro counters
    WHEN 'DISP_CNT'.
      PERFORM RECALCULATE_COUNTERS.
*   leave this nice program
    WHEN 'BACK' OR 'END'.
      SET PARAMETER ID 'RSBDC_ANALYSE_RB' FIELD RB.
      LEAVE PROGRAM.
    WHEN OTHERS.
      "
  ENDCASE.

* if field list or protocol chosen, but no transaction has been
* scanned yet, it's now time to read the first transaction from APQD
  IF ( MAIN_OKCODE = 'TAB_LIST' OR
       MAIN_OKCODE = 'TAB_PROTO' ) AND
     TCODE_INDEX_APQD IS INITIAL.

*ReSQ: No Need Of Change Internal Table BDC_TCODES Already Sorted
    READ TABLE BDC_TCODES INDEX 1.
    IF SY-SUBRC = 0.
      PERFORM SCAN_TRANSACTION USING BDC_TCODES-INDEX.
      TCODE_INDEX_APQD = BDC_TCODES-INDEX.
    ENDIF.
  ENDIF.

ENDMODULE.                    "user_command_main INPUT
*----------------------------------------------------------------------*
*        Module fill_bdc_tcodes
*          copy transactions from all_bdc_tcodes to bdc_tcodes
*          according to rb-settings
*----------------------------------------------------------------------*
MODULE FILL_BDC_TCODES OUTPUT.

* check whether contents are already up to date

  IF SHOW_DYNPRO_CNT = 'X'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'DCT'.
        SCREEN-INVISIBLE = 0.
        SCREEN-ACTIVE = 1.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-NAME = 'CMD_DISP_CNT'.
        SCREEN-INVISIBLE = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF BDC_TCODES_CONTENT = 'A' AND RB-TCODES_ALL = 'X'.
    EXIT.
  ELSEIF BDC_TCODES_CONTENT = 'E' AND RB-TCODES_ERROR = 'X'.
    EXIT.
  ENDIF.

* fill bdc_tcodes according to the settings in screen 500

  CLEAR BDC_TCODES. REFRESH BDC_TCODES.

  IF RB-TCODES_ALL ='X'.
    LOOP AT ALL_BDC_TCODES.
      BDC_TCODES = ALL_BDC_TCODES. APPEND BDC_TCODES.
    ENDLOOP.
    BDC_TCODES_CONTENT = 'A'.
  ELSEIF RB-TCODES_ERROR = 'X'.
    LOOP AT ALL_BDC_TCODES WHERE STATUS = 'E'.
      BDC_TCODES = ALL_BDC_TCODES. APPEND BDC_TCODES.
    ENDLOOP.
    BDC_TCODES_CONTENT = 'E'.
  ENDIF.

  DESCRIBE TABLE BDC_TCODES LINES BDC_LINES.
  I_TCODES = BDC_LINES.
  TC_TCODES-LINES = BDC_LINES.
  CLEAR TCODE_INDEX_APQD.

*ReSQ: No Need Of Change Internal Table BDC_TCODES Already Sorted
  READ TABLE BDC_TCODES INDEX 1.
  1ST_BDC_TCODE_INDEX = BDC_TCODES-INDEX.
  TCODE_INDEX = 1.

ENDMODULE.                    "fill_bdc_tcodes OUTPUT

*----------------------------------------------------------------------*
*        Module fill_bdc_dynpro
*          copy dynpro data from all_bdc_dynpro to bdc_bdc_dynpro
*          according to rb-settings
*----------------------------------------------------------------------*
MODULE FILL_BDC_DYNPRO OUTPUT.

  DATA: WA LIKE LINE OF TC_DYNPRO-COLS,
        TLINE LIKE SY-INDEX.

  TLINE = TC_DYNPRO-TOP_LINE.
  TC_DYNPRO-TOP_LINE = TLINE.

* hide fields if no detailed field list shall be displayed
  LOOP AT TC_DYNPRO-COLS INTO WA.
    IF SY-TABIX = 4 OR SY-TABIX = 5.
      IF RB-FIELDLIST = 'X'.
        CLEAR WA-INVISIBLE.
      ELSE.
        WA-INVISIBLE = 1.
      ENDIF.
      MODIFY TC_DYNPRO-COLS FROM WA.
    ENDIF.
  ENDLOOP.

* is bdc_dynpro_content already correctly filled ?
  IF RB-FIELDLIST = ' ' AND BDC_DYNPRO_CONTENT = 'S'.
    EXIT.
  ELSEIF RB-FIELDLIST = 'X' AND BDC_DYNPRO_CONTENT = 'F'.
    EXIT.
  ENDIF.

  CLEAR BDC_DYNPRO. REFRESH BDC_DYNPRO.

  IF RB-FIELDLIST = ' '.
    IF DYNPRO_INDEX = 0.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT ALL_BDC_DYNPRO .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
      READ TABLE ALL_BDC_DYNPRO INDEX TLINE.
      IF SY-SUBRC = 0.
        DYNPRO_INDEX = ALL_BDC_DYNPRO-INDEX.
      ENDIF.
    ENDIF.
    LOOP AT ALL_BDC_DYNPRO WHERE NOT PROGRAM IS INITIAL.
      BDC_DYNPRO = ALL_BDC_DYNPRO.
      APPEND BDC_DYNPRO.
    ENDLOOP.
    BDC_DYNPRO_CONTENT = 'S'.
  ELSEIF RB-FIELDLIST = 'X'.
    IF DYNPRO_INDEX = 0.
      DYNPRO_INDEX = TLINE.
    ENDIF.
    LOOP AT ALL_BDC_DYNPRO.
      BDC_DYNPRO = ALL_BDC_DYNPRO.
      IF ALL_BDC_DYNPRO-PROGRAM IS INITIAL.
        CLEAR BDC_DYNPRO-INDEX.
      ENDIF.
      APPEND BDC_DYNPRO.
    ENDLOOP.
    BDC_DYNPRO_CONTENT = 'F'.
  ENDIF.

  DESCRIBE TABLE BDC_DYNPRO LINES BDC_LINES.
  TC_DYNPRO-LINES = BDC_LINES.
  TC_DYNPRO-TOP_LINE = 1.

  IF DYNPRO_INDEX > 0.
    LOOP AT BDC_DYNPRO.
      IF BDC_DYNPRO-INDEX = DYNPRO_INDEX.
        TC_DYNPRO-TOP_LINE = SY-TABIX.
        EXIT.
      ENDIF.
    ENDLOOP.
    CLEAR DYNPRO_INDEX.
  ENDIF.

ENDMODULE.                    "fill_bdc_dynpro OUTPUT

*----------------------------------------------------------------------*
*        Module fill_bdc_protocol
*          copy messages from bdclm to bdc_protocol
*          according to rb-settings
*----------------------------------------------------------------------*
MODULE FILL_BDC_PROTOCOL OUTPUT.

  IF RB-PRO_ALL = 'X' AND BDC_PROTOCOL_CONTENT = 'A'.
    EXIT.
  ELSEIF RB-PRO_TCODE = 'X' AND BDC_PROTOCOL_CONTENT = 'T'.
    EXIT.
  ELSEIF RB-PRO_SESSION = 'X' AND BDC_PROTOCOL_CONTENT = 'S'.
    EXIT.
  ENDIF.

  CLEAR BDC_PROTOCOL. REFRESH BDC_PROTOCOL.

  IF RB-PRO_ALL = 'X'.
    LOOP AT BDCLM.
      IF RB-LOG_DETAIL  = ' ' AND BDCLM-ISDETAIL = 'X'.
        CONTINUE.
      ENDIF.
      MOVE-CORRESPONDING BDCLM TO BDC_PROTOCOL.
      APPEND BDC_PROTOCOL.
    ENDLOOP.
    BDC_PROTOCOL_CONTENT = 'A'.
  ELSEIF RB-PRO_TCODE = 'X'.
    LOOP AT BDCLM WHERE TCNT = TCODE_INDEX_APQD.
      IF RB-LOG_DETAIL  = ' ' AND BDCLM-ISDETAIL = 'X'.
        CONTINUE.
      ENDIF.
      MOVE-CORRESPONDING BDCLM TO BDC_PROTOCOL.
      APPEND BDC_PROTOCOL.
    ENDLOOP.
    BDC_PROTOCOL_CONTENT = 'T'.
  ELSEIF RB-PRO_SESSION = 'X'.
    LOOP AT BDCLM WHERE TCNT = ' '.
      MOVE-CORRESPONDING BDCLM TO BDC_PROTOCOL.
      APPEND BDC_PROTOCOL.
    ENDLOOP.
    BDC_PROTOCOL_CONTENT = 'S'.
  ENDIF.

  DESCRIBE TABLE BDC_PROTOCOL LINES BDC_LINES.
  TC_PROTOCOL-LINES = BDC_LINES.
  TC_PROTOCOL-TOP_LINE = 1.

ENDMODULE.                    "fill_bdc_protocol OUTPUT

*----------------------------------------------------------------------*
*        Module check_bdc_tcodes
*----------------------------------------------------------------------*

MODULE CHECK_BDC_PROTOCOL OUTPUT.
* display lines intensified if they contain e- or a-messages
  IF BDC_PROTOCOL-MART = 'E'
  OR BDC_PROTOCOL-MART = 'A'.
    LOOP AT SCREEN.
      SCREEN-INTENSIFIED = 1. MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
* skip empty lines
  IF BDC_PROTOCOL-INDATE IS INITIAL.
    EXIT FROM STEP-LOOP.
  ENDIF.
ENDMODULE.                    "check_bdc_protocol OUTPUT

*----------------------------------------------------------------------*
*        Module get_cursor_position
*----------------------------------------------------------------------*

MODULE GET_CURSOR_POSITION INPUT.
  GET CURSOR FIELD C_FIELD LINE C_LINE.
  IF C_LINE > 0.
    CASE TAB_DYNPRO-ACTIVETAB.
      WHEN 'TAB_TCODES'.
        SELECTED_INDEX = TC_TCODES-TOP_LINE + C_LINE - 1.
      WHEN 'TAB_LIST'.
        SELECTED_INDEX = TC_DYNPRO-TOP_LINE + C_LINE - 1.
      WHEN 'TAB_PROTO'.
        SELECTED_INDEX = TC_PROTOCOL-TOP_LINE + C_LINE - 1.
    ENDCASE.
  ELSE.
    SELECTED_INDEX = 0.
  ENDIF.
ENDMODULE.                    "get_cursor_position INPUT

*----------------------------------------------------------------------*
*         Module d0500_init
*----------------------------------------------------------------------*

MODULE D0500_INIT OUTPUT.
  SET PF-STATUS 'POPUP'.
  SET TITLEBAR  '0500'.
ENDMODULE.                    "d0500_init OUTPUT

*----------------------------------------------------------------------*
*         Module d0500_fcode
*----------------------------------------------------------------------*
MODULE D0500_FCODE INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                    "d0500_fcode INPUT

*----------------------------------------------------------------------*
*         Module d0600_init
*----------------------------------------------------------------------*

MODULE D0600_INIT OUTPUT.
  SET PF-STATUS 'POPUP'.
  SET TITLEBAR  '0600'.
  CLEAR D0600_FCODE.
  DESCRIBE TABLE BDCLD LINES I_PROTOCOLS.
  TC_BDCLD-LINES = I_PROTOCOLS.
ENDMODULE.                    "d0600_init OUTPUT

*----------------------------------------------------------------------*
*         Module d0500_fcode
*           read and process another protocol which was selected on
*           popup dynpro 500
*----------------------------------------------------------------------*
MODULE D0600_FCODE INPUT.
  CASE D0600_FCODE.
    WHEN 'POP_CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'POP_OKAY'.
*   read selected protocol
      IF TC_SELECT <> SELECTED_PROTOCOL.
        CLEAR BDCLM. REFRESH BDCLM.
        CLEAR BDC_PROTOCOL_CONTENT.
        PERFORM GET_LOG USING TC_SELECT.
        PERFORM EXTEND_MESSAGE_TEXTS.
        SELECTED_PROTOCOL = TC_SELECT.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
*   scroll in table
  ENDCASE.
ENDMODULE.                    "d0600_fcode INPUT

*----------------------------------------------------------------------*
*      Module set_mark
*        set table view marker for the actual selected protocol
*        (dynpro 500)
*----------------------------------------------------------------------*
MODULE SET_MARK OUTPUT.
  TC_INDEX = TC_BDCLD-TOP_LINE + TC_BDCLD-CURRENT_LINE - 1.
  IF TC_INDEX = SELECTED_PROTOCOL.
    TC_MARK = 'X'.
  ENDIF.
ENDMODULE.                    "set_mark OUTPUT

*----------------------------------------------------------------------*
*      Module get_mark
*        get index of selected protocol on popup 500
*----------------------------------------------------------------------*
MODULE GET_MARK INPUT.
  IF TC_MARK = 'X'.
    TC_SELECT = TC_BDCLD-TOP_LINE + TC_BDCLD-CURRENT_LINE - 1.
  ENDIF.
ENDMODULE.                    "get_mark INPUT

*----------------------------------------------------------------------*
* FORM: fill_bdc_tcodes
*   Read all transaction codes from apqd and fill internal table
*----------------------------------------------------------------------*
FORM FILL_ALL_BDC_TCODES.

* read APQD blocks 1 for QID
  CLEAR ALL_BDC_TCODES. REFRESH ALL_BDC_TCODES.
  SELECT * FROM APQD WHERE QID = QUEUE_ID AND BLOCK = 1
         ORDER BY PRIMARY KEY.
    MOVE APQD-VARDATA TO BDCTH.
    ALL_BDC_TCODES-INDEX = APQD-TRANS.
    ALL_BDC_TCODES-TCODE = BDCTH-TCODE.
    ALL_BDC_TCODES-STATUS = BDCTH-STATE.
    APPEND ALL_BDC_TCODES.
  ENDSELECT.

* convert status flag to long text
* calculate transaction counters
  CLEAR APQDCNT.
  LOOP AT ALL_BDC_TCODES.
    ADD 1 TO APQDCNT-TRANSCNT.
    CASE ALL_BDC_TCODES-STATUS.
      WHEN 'D' OR 'G'.
        ALL_BDC_TCODES-S_TEXT = 'gelöscht'(005).
        ADD 1 TO APQDCNT-TRANSCNTD.
      WHEN 'F'.
        ALL_BDC_TCODES-S_TEXT = 'verarbeitet'(002).
        ADD 1 TO APQDCNT-TRANSCNTF.
      WHEN 'E'.
        ALL_BDC_TCODES-S_TEXT = 'fehlerhaft'(001).
        ADD 1 TO APQDCNT-TRANSCNTE.
      WHEN 'B'.
        ALL_BDC_TCODES-S_TEXT = ' '.  "neu
        ADD 1 TO APQDCNT-TRANSCNTB.
      WHEN OTHERS.
        ALL_BDC_TCODES-S_TEXT = ' '.
    ENDCASE.
    MODIFY ALL_BDC_TCODES.
  ENDLOOP.

  APQDCNT-TRANSCNTO =   APQDCNT-TRANSCNTB
                      + APQDCNT-TRANSCNTE.

  APQDCNT-TRANSCNTD =   APQDCNT-TRANSCNT
                      - APQDCNT-TRANSCNTF
                      - APQDCNT-TRANSCNTE
                      - APQDCNT-TRANSCNTB.

  APQDCNT-TRANSCNTP =   APQI-PUTTRANS.

  APQDCNT-TRANSCNTX =   APQDCNT-TRANSCNTP
                      - APQDCNT-TRANSCNT.

  IF APQI-MSGCNT < 1000.
    PERFORM RECALCULATE_COUNTERS.
  ENDIF.

ENDFORM.                    "fill_all_bdc_tcodes

*----------------------------------------------------------------------*
* FORM scan_transaction
*   Read all APQD data for a selected transaction
*----------------------------------------------------------------------*
FORM SCAN_TRANSACTION USING TCNT.

  CLEAR IT_APQD. REFRESH IT_APQD.
  CLEAR ALL_BDC_DYNPRO. REFRESH ALL_BDC_DYNPRO.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM APQD INTO TABLE IT_APQD
*         WHERE QID = QUEUE_ID AND TRANS = TCNT.
*
* NEW CODE
  SELECT *
 FROM APQD INTO TABLE IT_APQD
         WHERE QID = QUEUE_ID AND TRANS = TCNT ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  TCODE_INDEX_APQD = TCNT. "Display correct index in header screens

  CLEAR DYNPRO_INDEX.
  LOOP AT IT_APQD.
    IF IT_APQD-VARDATA(1) = 'M'.     "it's a message header
      DYNPRO_INDEX = DYNPRO_INDEX + 1.
      PERFORM SCAN_DYNPRO.
    ENDIF.
  ENDLOOP.
  CLEAR DYNPRO_INDEX.
ENDFORM.                    "scan_transaction

*----------------------------------------------------------------------*
* FORM: scan_dynpro
*   Scan APQD data for a single dynpro screen
*   and put it into a BDCDATA table
*----------------------------------------------------------------------*
FORM SCAN_DYNPRO.
*
  MOVE IT_APQD-VARDATA TO BDCMH.
  TRANSLATE BDCMH TO UPPER CASE.

* get program name and screen number
  CLEAR ALL_BDC_DYNPRO.
  WRITE DYNPRO_INDEX TO ALL_BDC_DYNPRO-INDEX RIGHT-JUSTIFIED NO-SIGN.
  ALL_BDC_DYNPRO-PROGRAM = BDCMH-PROG.
  ALL_BDC_DYNPRO-DYNPRO  = BDCMH-DYNR.
  APPEND ALL_BDC_DYNPRO.

* get all the fnam/fval pairs
  MOVE IT_APQD-VARDATA TO SDAT.
  SHIFT SDAT BY BDCMHLEN PLACES.
  WCOUNT = BDCMHLEN.
  MFSTART = WCOUNT.
  MFART = 'FN'.
  WHILE WCOUNT LE IT_APQD-VARLEN.
    IF SDAT(1) = BDCMH-SEPC.
      MFENDE  = WCOUNT.
      PERFORM MOVE_TF.
    ENDIF.
    SHIFT SDAT.
    WCOUNT = WCOUNT + 1.
  ENDWHILE.
ENDFORM.                    "scan_dynpro

*----------------------------------------------------------------------*
* Parse the apqd-vardata field for FNAM/FVAL pairs
* FORM: move_tf
* fills TF-FNAME and TF-FARG
*----------------------------------------------------------------------*
FORM MOVE_TF.

  MFLEN = MFENDE  - MFSTART.

  CASE MFART.
    WHEN 'FN'.
      CLEAR: TF-FNAME,  UDAT.
      TF-FSTART = MFSTART.
      MOVE IT_APQD-VARDATA TO UDAT.
      SHIFT UDAT BY MFSTART PLACES.
      WRITE UDAT TO TF-FNAME+0(MFLEN).
      TRANSLATE TF-FNAME TO UPPER CASE.
      MFSTART   = MFENDE + 1.
      MFENDE    = 0.
      MOVE 'FA' TO MFART.
    WHEN 'FA'.
      CLEAR: TF-FARG,  UDAT.
      TF-FENDE  = MFENDE.
      MOVE IT_APQD-VARDATA TO UDAT.
      SHIFT UDAT BY MFSTART PLACES.
      WRITE UDAT TO TF-FARG+0(MFLEN).
      APPEND TF.
      TF-STAT = SPACE.
      MFSTART   = MFENDE + 1.
      MFENDE = 0.
      MOVE 'FN' TO MFART.
*         copy to bdcdata table if fname/fval is not empty
      CHECK NOT TF-FNAME IS INITIAL.
*         CHECK NOT TF-FARG IS INITIAL.
      CLEAR ALL_BDC_DYNPRO.
      WRITE DYNPRO_INDEX TO ALL_BDC_DYNPRO-INDEX
            RIGHT-JUSTIFIED NO-SIGN.
      ALL_BDC_DYNPRO-FNAM  = TF-FNAME.
      ALL_BDC_DYNPRO-FVAL  = TF-FARG.
      APPEND ALL_BDC_DYNPRO.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    "move_tf

*----------------------------------------------------------------------*
*     Form: get_logfiles_for_qid
*----------------------------------------------------------------------*
DATA:
  PARAMNAME(11) VALUE 'bdc/logfile',
  LOGNAME(80),
  LOGNAME1(80),
  OLD_LOGFILE(06) VALUE 'bdclog',
  NEW_LOGFILE(04) VALUE 'BI* ',
  SHIFTLEN TYPE I VALUE 0,
  PROTFLEN TYPE I VALUE 0,
  PROTFOFF TYPE I VALUE 0,
  RLEN     TYPE I VALUE 0,
  BDCLD# TYPE I, ONE TYPE I, EC TYPE I, RETURN TYPE I,
  PROTCNT TYPE I.

DATA:
  BEGIN OF PROT_LIST OCCURS 0.
INCLUDE     RSTR0112.
DATA: SEEN(1), TO_BE_DELETED(1), HAS_CHANGED(1), LOCAL_HOST(24),
END OF PROT_LIST.

DATA:
  BEGIN OF FILE.
INCLUDE RSTR0112.
DATA END OF FILE.

DATA:
  BEGIN OF BDCLDA  OCCURS 0.
        INCLUDE STRUCTURE BDCLD.
DATA END OF BDCLDA .

DATA:
  DIGITS(10) TYPE C VALUE '0123456789',
  MTEXT(124) TYPE C,                  "Messagetext
  MTEXT1(124) TYPE C,                 "Messagetext
  MTEXT2(273) TYPE C,                 "Messagetext
  DO_CONDENSE TYPE C,
  MTVAROFF TYPE I,
  SHOWTYP(05) TYPE C,                 "showtyp
  LMAPN(12) TYPE C,                  "Hilfsfeld log-mapn
  DATE1  TYPE D,
  LINCT0      LIKE SY-LINCT,

  PARCNT  TYPE I,
  SP_LEN  TYPE I,
  CHARCNT TYPE I,
  WCNT TYPE I,
  MPARCNT TYPE I,
  QFOUND(04) TYPE N,
  X(1) VALUE 'X'.

DATA:                                "Aufbereitung Messagetext
  BEGIN OF MT,
   OFF(02) TYPE N,
   LEN(02) TYPE N,
   TEXT(99),
 END OF MT.

DATA:                                "Aufbereitung Messagetext
  BEGIN OF MTTAB  OCCURS 4,
   OFF(02) TYPE N,
   LEN(02) TYPE N,
   TEXT(99),
 END OF MTTAB.

DATA:                                "Hilfsfelder
  BEGIN OF OLD,
   TCNT LIKE BDCLM-TCNT,
   MCNT LIKE BDCLM-MCNT,
 END OF OLD.

DATA:                                "ParameterAufbereitung
  BEGIN OF PAR,
   LEN(02) TYPE N,
   TEXT(254),
 END OF PAR.

*----------------------------------------------------------------------*
* Form get_logfiles_for_qid
*   find all log files for the session in analysis,
*   either in common log or in TemSe
*----------------------------------------------------------------------*

FORM GET_LOGFILES_FOR_QID.

*** profile parameter bdc/logfile & bdc/new_protocol
*** not supported since 6.10
**
*** first check whether log files are in the common log or if TemSe
*** interface is active
**  call 'C_SAPGPARAM'  id 'NAME'   field protparam
**                      id 'VALUE'  field newprot.
**
**  translate newprot to upper case.
**  if newprot = 'OFF'.
***  get logs from common log file
**    call 'C_SAPGPARAM' id 'NAME'   field paramname
**                       id 'VALUE'  field logname.
**
**    perform list_protocol_files.
**
**    loop at prot_list.
**      logname = prot_list-name.
**      perform log_dir.
**    endloop.
**  else.

*  get logs from TemSe
  PERFORM GET_LOGFILES_FROM_TEMSE.

**  endif.

*  now bdcld contains the log files for the given qid
  SORT BDCLD BY EDATE DESCENDING ETIME DESCENDING.
  DESCRIBE TABLE BDCLD LINES SELECTED_PROTOCOL.

ENDFORM.                    "get_logfiles_for_qid

*----------------------------------------------------------------------*
*     Form: log_dir
*----------------------------------------------------------------------*

FORM LOG_DIR.
*
  CLEAR BDCLDA. REFRESH BDCLDA.

  CALL 'ReadLogDirA'       ID 'LOGN'  FIELD LOGNAME
                           ID 'DTAB'  FIELD BDCLDA-*SYS*
                           ID 'AINF'  FIELD ONE
                           ID 'ECNT'  FIELD EC.
*
  IF SY-SUBRC NE 0 OR EC = 0.
    EXIT.
  ENDIF.

  LOOP AT BDCLDA WHERE LMAND = SY-MANDT AND QUID = QUEUE_ID.
    MOVE-CORRESPONDING BDCLDA TO BDCLD.
    MOVE LOGNAME TO BDCLD-LOGNAME.
    MOVE PROT_LIST-LOCAL_HOST TO BDCLD-LOCAL_HOST.
    APPEND BDCLD.
  ENDLOOP.
ENDFORM.                               " log_dir.

*----------------------------------------------------------------------*
*      Form: list_protocol_files
*      Suche nach allen aktiven Protokolldateien -> Tabelle prot_list
*----------------------------------------------------------------------*
FORM LIST_PROTOCOL_FILES.

  CLEAR:   LOGNAME1, PROT_LIST, PROTCNT.
  REFRESH: PROT_LIST.

  PROTFLEN = STRLEN( LOGNAME ).
  MOVE LOGNAME TO LOGNAME1.

  WHILE SHIFTLEN LE PROTFLEN.
    IF  LOGNAME1 CP '*#B#I*'.          "suchen nach muster *#B#I*
      IF SY-FDPOS EQ 0.                "nur großbuchstaben
        SHIFTLEN = 2.
      ELSE.
        SHIFTLEN = SY-FDPOS.
      ENDIF.
      PROTFOFF = PROTFOFF + SHIFTLEN.
      SHIFT LOGNAME1 BY SHIFTLEN PLACES.
    ELSE.
      SHIFTLEN = PROTFLEN + 1.
      PROTFOFF = PROTFOFF - 2.
    ENDIF.
  ENDWHILE.
*
  IF PROTFOFF LE 0.
    PROTFOFF = 0.
  ENDIF.
*
  RLEN = 80 - PROTFOFF.
*
  WRITE SPACE       TO LOGNAME+PROTFOFF(RLEN).
  WRITE NEW_LOGFILE TO LOGNAME+PROTFOFF(4).
*
  PERFORM SEARCH_PROT USING LOGNAME.

ENDFORM.                               " FILL_PROT_LIST
*
*---------------------------------------------------------------------*
* FORM : search_prot                                                  *
*---------------------------------------------------------------------*
FORM SEARCH_PROT    USING PROT_FILES.
*
  DATA: ERRCNT(2) TYPE P VALUE 0.
*
  CALL 'C_DIR_READ_START' ID 'FILE'   FIELD PROT_FILES
     ID 'ERRNO'  FIELD FILE-ERRNO
     ID 'ERRMSG' FIELD FILE-ERRMSG.

  IF SY-SUBRC <> 0.
    MESSAGE I398(00)
            WITH SY-SUBRC 'C_DIR_READ_START' ' ' PROT_FILES.
    MESSAGE I398(00)
            WITH SY-SUBRC 'C_DIR_READ_START...'
                 FILE-ERRNO FILE-ERRMSG.
  ENDIF.

  DO.                 "aufbau der internen tabelle fuer alle
    "BI-Protokolle
    CLEAR FILE.

    CALL 'C_DIR_READ_NEXT'
      ID 'TYPE'   FIELD FILE-TYPE
      ID 'NAME'   FIELD FILE-NAME
      ID 'LEN'    FIELD FILE-LEN
      ID 'OWNER'  FIELD FILE-OWNER
      ID 'MTIME'  FIELD FILE-MTIME
      ID 'MODE'   FIELD FILE-MODE
      ID 'ERRNO'  FIELD FILE-ERRNO
      ID 'ERRMSG' FIELD FILE-ERRMSG.

    MOVE SY-SUBRC TO    FILE-SUBRC.

    CASE SY-SUBRC.
      WHEN 0.
        CASE FILE-TYPE(1).
          WHEN 'F'.                    " normal file.
            MOVE 1       TO FILE-USEABLE.
          WHEN 'f'.                    " normal file.
            MOVE 1       TO FILE-USEABLE.
          WHEN OTHERS. " Directory, device, fifo, socket,...
            MOVE 0       TO FILE-USEABLE.
        ENDCASE.
        IF FILE-LEN = 0.
          MOVE 0      TO FILE-USEABLE.
        ENDIF.
      WHEN 1.
        EXIT.
      WHEN OTHERS.                     " SY-SUBRC >= 2
        ADD 1 TO ERRCNT.
        IF ERRCNT > 10.
          EXIT.
        ENDIF.
        IF SY-SUBRC = 5.
          MOVE: '???' TO FILE-TYPE,
                '???' TO FILE-OWNER,
                '???' TO FILE-MODE.
        ELSE.
        ENDIF.
        FILE-USEABLE = 0.
    ENDCASE.

    MOVE-CORRESPONDING FILE TO PROT_LIST.
    SHIFT FILE-NAME BY PROTFOFF PLACES.
    PROT_LIST-LOCAL_HOST = FILE-NAME.
    PROTCNT = PROTCNT + 1.
    APPEND PROT_LIST.

  ENDDO.

  CALL 'C_DIR_READ_FINISH'
      ID 'ERRNO'  FIELD FILE-ERRNO
      ID 'ERRMSG' FIELD FILE-ERRMSG.

  IF SY-SUBRC <> 0.
*   WRITE: / 'C_DIR_READ_FINISH'(999), 'SUBRC', SY-SUBRC.
  ENDIF.

ENDFORM.                               " search_prot

*----------------------------------------------------------------------*
*      Form: get_log
*----------------------------------------------------------------------*
FORM GET_LOG USING LOG_INDEX.

  DATA: BEGIN OF LOGTABLE OCCURS 50,  " plain log information in TemSe
          ENTERDATE LIKE BTCTLE-ENTERDATE,
          ENTERTIME LIKE BTCTLE-ENTERTIME,
          LOGMESSAGE(400) TYPE C,
        END OF LOGTABLE.
  DATA:
        EXTERNAL_DATE(10),
        INTERNAL_DATE TYPE D.

  READ TABLE BDCLD INDEX LOG_INDEX.
  LOGNAME = BDCLD-LOGNAME.

  IF NEWPROT = 'OFF'.
* get logfile contents from common log file
    CALL 'ReadLogPartitionA'     ID 'LOGN'    FIELD LOGNAME
                                 ID 'ETAB'    FIELD BDCLM-*SYS*
                                 ID 'PART'    FIELD BDCLD
                                 ID 'ECNT'    FIELD EC.

    IF SY-SUBRC <> 0. MESSAGE S325(00). ENDIF.
    IF EC = 0.        MESSAGE S324(00). ENDIF.
  ELSE.
* get logfile contents from TemSe
    PERFORM READ_BDC_LOG_PLAIN
      TABLES LOGTABLE
      USING  BDCLD-TEMSEID BDCLD-LMAND.

    IF SY-SUBRC <> 0.                    " Fehler beim Lesen
      MESSAGE S004(TS).
      EXIT.
    ENDIF.

    CLEAR BDCLM[].
    LOOP AT LOGTABLE.
*----------------------------------------------------------------------*
*       Es wird geprüft, ob von TEMSE das Datum korrekt geliefert wurde
*       wenn nicht wird einfach der Satz ignoriert und nicht gelesen
*----------------------------------------------------------------------*
      CALL 'DATE_CONV_INT_TO_EXT'
           ID 'DATINT' FIELD LOGTABLE-ENTERDATE
           ID 'DATEXT' FIELD EXTERNAL_DATE.

      CALL 'DATE_CONV_EXT_TO_INT'
           ID 'DATEXT' FIELD EXTERNAL_DATE
           ID 'DATINT' FIELD INTERNAL_DATE.
      IF SY-SUBRC NE 0.         " Datum ist nicht gültig
        CONTINUE.
      ENDIF.

      CLEAR BDCLM.
      BDCLM-INDATE  = LOGTABLE-ENTERDATE.
      BDCLM-INTIME  = LOGTABLE-ENTERTIME.
      BDCLM+14(352) = LOGTABLE-LOGMESSAGE.
      IF BDCLM-MCNT > 0.
        BDCLM-MCNT = BDCLM-MCNT - 1.
      ENDIF.

      IF BDCLM-MID EQ '00'.
        IF   ( BDCLM-MNR EQ '162' )
          OR ( BDCLM-MNR EQ '368' ).
          BDCLM-ISDETAIL = 'X'.
        ENDIF.
      ENDIF.

      APPEND BDCLM.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "get_log

*----------------------------------------------------------------------*
*     Form: get_logfiles_from_temse
*----------------------------------------------------------------------*
FORM GET_LOGFILES_FROM_TEMSE.
* are there any logs in the TemSe for this QID ?
  CLEAR LOGTAB_TEMSE[].
  CLEAR BDCLD[].

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM APQL INTO TABLE LOGTAB_TEMSE
*           WHERE QID = APQI-QID.
*
* NEW CODE
  SELECT *
 FROM APQL INTO TABLE LOGTAB_TEMSE
           WHERE QID = APQI-QID ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  CHECK SY-SUBRC = 0.
* some logs were found: now put this info into table bdcld.
  DATA: WA_LOG LIKE LINE OF LOGTAB_TEMSE,
        WA_LD  LIKE LINE OF BDCLD.

  LOOP AT LOGTAB_TEMSE INTO WA_LOG.
    CLEAR WA_LD.
    WA_LD-TEMSEID = WA_LOG-TEMSEID.
    WA_LD-LMAND   = WA_LOG-MANDANT.
    WA_LD-EDATE   = WA_LOG-CREDATE.
    WA_LD-ETIME   = WA_LOG-CRETIME.
    WA_LD-LUSER   = WA_LOG-CREATOR.
    WA_LD-GRPN    = WA_LOG-GROUPID.
    WA_LD-QUID    = WA_LOG-QID.
    WA_LD-LOCAL_HOST = WA_LOG-DESTSYS(8).
    APPEND WA_LD TO BDCLD.
  ENDLOOP.

ENDFORM.                    "get_logfiles_from_temse
*----------------------------------------------------------------------*
*     Form: extend_message_texts
*----------------------------------------------------------------------*
FORM EXTEND_MESSAGE_TEXTS.

  LOOP AT BDCLM.
    LM = BDCLM. SAVE_MPAR = BDCLM-MPAR.
    PERFORM GET_TEXT.
    BDCLM-LONGTEXT = MTEXT.
    BDCLM-MPAR = SAVE_MPAR.
    MODIFY BDCLM.
  ENDLOOP.
ENDFORM.                    "extend_message_texts

*---------------------------------------------------------------------*
* FORM : get_text                                                     *
*---------------------------------------------------------------------*
FORM GET_TEXT.
*
*** Aufbereiten des Messagetextes
*
  DATA: SHIFTLN TYPE I,
        VARTCNT TYPE I,
        FDPOS LIKE SY-FDPOS.

  IF BDCLM-MPARCNT CN DIGITS.        "Korrupter Datensatz:
    BDCLM-MPARCNT = 0.               "z.B. Hexnullen
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM T100
*   WHERE SPRSL = SY-LANGU
*   AND  ARBGB  = BDCLM-MID
*   AND  MSGNR  = BDCLM-MNR.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM T100
   WHERE SPRSL = SY-LANGU
   AND  ARBGB  = BDCLM-MID
   AND  MSGNR  = BDCLM-MNR ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
  IF SY-SUBRC EQ 0.
    CLEAR: MTEXT,
           PARCNT,
           MPARCNT,
           CHARCNT,
           WCNT,
           MT,
           SP_LEN,
           SY-FDPOS.
*
    MOVE BDCLM-MPARCNT TO MPARCNT.
*
    IF T100-TEXT CA '$&'.            "Kennung fuer parameter:
      MOVE T100-TEXT TO MTEXT1.      " alt '$' --- neu '&'
    ELSE.
      MOVE T100-TEXT TO MTEXT.
      EXIT.
    ENDIF.
* variable teile aus batch-input protokoll in mttab bringen.
    REFRESH MTTAB.
    CLEAR SHIFTLN.
    DO MPARCNT TIMES.
      CLEAR: PAR, MTTAB.
      MOVE BDCLM-MPAR TO PAR.
      IF PAR-LEN CN DIGITS OR PAR-LEN EQ 0.       "convert_no_number
        PAR-LEN  = 1.                             "entschärfen
        PAR-TEXT = ' '.
        SHIFTLN  = 2.
      ELSE.
        SHIFTLN = PAR-LEN + 2.
      ENDIF.
      WRITE PAR-TEXT TO MTTAB-TEXT(PAR-LEN).
      MOVE PAR-LEN  TO MTTAB-LEN.
      MOVE MPARCNT  TO MTTAB-OFF.
      APPEND MTTAB.
      SHIFT BDCLM-MPAR BY SHIFTLN PLACES.
    ENDDO.
*
    MTEXT2 = MTEXT1.
    IF BDCLM-MID EQ  '00' AND    " sonderbehandlung s00368
       BDCLM-MNR EQ '368' AND
       BDCLM-MART EQ 'S'.
      CLEAR MTEXT2.
      CLEAR MTTAB.
      READ TABLE MTTAB INDEX 1.
      WRITE MTTAB-TEXT TO MTEXT2+0(MTTAB-LEN).
      CLEAR MTTAB.
      READ TABLE MTTAB INDEX 2.
      WRITE MTTAB-TEXT TO MTEXT2+35(MTTAB-LEN).
      MTEXT = MTEXT2.
      EXIT.
    ENDIF.

    DO_CONDENSE = X.
    CLEAR: MT, VARTCNT, MTVAROFF.
    WHILE VARTCNT LE 3.
      VARTCNT = VARTCNT + 1.
      IF MTEXT1 CA '$&'.
        PARCNT = PARCNT + 1.
        IF SY-FDPOS GT 0.
          FDPOS = SY-FDPOS - 1.                    " neu sy-fdpos -1
        ELSE.
          FDPOS = SY-FDPOS.
        ENDIF.
        SHIFT MTEXT1 BY SY-FDPOS PLACES.
        IF MTEXT1(1) EQ '&'.
          SHIFT MTEXT1 BY 1 PLACES.
          CASE MTEXT1(1).
            WHEN ' '.                              "'& '
              PERFORM REPLACE_VAR USING '& ' PARCNT FDPOS.
            WHEN '$'.                              "'&&'
              PERFORM REPLACE_VAR USING '&&' 0      FDPOS.
            WHEN '1'.                                       "'&1'
              PERFORM REPLACE_VAR USING '&1' 1      FDPOS.
            WHEN '2'.                                       "'&2'
              PERFORM REPLACE_VAR USING '&2' 2      FDPOS.
            WHEN '3'.                                       "'&3'
              PERFORM REPLACE_VAR USING '&3' 3      FDPOS.
            WHEN '4'.                                       "'&4'
              PERFORM REPLACE_VAR USING '&4' 4      FDPOS.
            WHEN OTHERS.                           "'&'
              PERFORM REPLACE_VAR USING '&<' PARCNT FDPOS.
          ENDCASE.
        ENDIF.
        IF MTEXT1(1) EQ '$'.
          SHIFT MTEXT1 BY 1 PLACES.
          CASE MTEXT1(1).
            WHEN ' '.                              "'$ '
              PERFORM REPLACE_VAR USING '$ ' PARCNT  FDPOS.
            WHEN '$'.                              "'$$'
              PERFORM REPLACE_VAR USING '$$' 0       FDPOS.
            WHEN '1'.                                       "'$1'
              PERFORM REPLACE_VAR USING '$1' 1       FDPOS.
            WHEN '2'.                                       "'$2'
              PERFORM REPLACE_VAR USING '$2' 2       FDPOS.
            WHEN '3'.                                       "'$3'
              PERFORM REPLACE_VAR USING '$3' 3       FDPOS.
            WHEN '4'.                                       "'$4'
              PERFORM REPLACE_VAR USING '$4' 4       FDPOS.
            WHEN OTHERS.                           "'$'
              PERFORM REPLACE_VAR USING '$<' PARCNT  FDPOS.
          ENDCASE.
        ENDIF.
      ENDIF.
    ENDWHILE.
*
    IF MTEXT2 CA '%%_D_%%'.
      REPLACE '%%_D_%%' WITH '$' INTO MTEXT2.
    ENDIF.
    IF MTEXT2 CA '%%_A_%%'.
      REPLACE '%%_A_%%' WITH '&' INTO MTEXT2.
    ENDIF.
    IF DO_CONDENSE EQ SPACE.
      MTEXT = MTEXT2.
    ELSE.
      CONDENSE MTEXT2 .
      MTEXT = MTEXT2.
    ENDIF.
  ELSE.
    MTEXT = '???????????????????????????????????????????????????'.
  ENDIF.
*
ENDFORM.                                                    " get_text1
*---------------------------------------------------------------------*
* FORM : replace_var                                                  *
*                                                                     *
*---------------------------------------------------------------------*
FORM REPLACE_VAR USING VARK VARI VARPOS.
*
*   ersetzen der variablen teile einer fehlermeldung
*
  DATA: VAR(02),
        VAR1,
        MOFF TYPE I.
*
  CLEAR: MTTAB , MOFF.
  VAR = VARK.
  SHIFT VAR BY 1 PLACES.
  CASE VAR.
    WHEN ' '.                              "'& '
      READ TABLE MTTAB INDEX VARI.
      IF SY-SUBRC EQ 0.
        MOFF = VARPOS + MTVAROFF.
        ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
        ASSIGN MTTAB-TEXT(MTTAB-LEN) TO <VTXT>.
        VAR1 = VARK.
        REPLACE VAR1 WITH <VTXT>     INTO <MTXT>.
        MTVAROFF = MTTAB-LEN.
      ELSE.
        IF VARI GT MPARCNT.
          MOFF = VARPOS + MTVAROFF.
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
          REPLACE VARK WITH '  ' INTO <MTXT>.
          MTVAROFF = 2.
        ELSE.
          MOFF = VARPOS + MTVAROFF.
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
          REPLACE VARK WITH '%%_Z_%%' INTO <MTXT>.
          MTVAROFF = 7.
        ENDIF.
      ENDIF.
    WHEN '$'.                              "'&&'
      MOFF = VARPOS + MTVAROFF.
      ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
      REPLACE VARK WITH '%%_D_%%' INTO <MTXT>.
      MTVAROFF = 7.
    WHEN '&'.                              "'&&'
      MOFF = VARPOS + MTVAROFF.
      ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
      REPLACE VARK WITH '%%_A_%%' INTO <MTXT>.
      MTVAROFF = 7.
    WHEN '<'.                                               "'&1'
      READ TABLE MTTAB INDEX VARI.
      IF SY-SUBRC EQ 0.
        IF VARK EQ '&<'.
          MOFF = VARPOS + MTVAROFF.
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
          ASSIGN MTTAB-TEXT(MTTAB-LEN) TO <VTXT>.
          REPLACE '&' WITH <VTXT>     INTO <MTXT>.
          MTVAROFF = MTTAB-LEN.
        ENDIF.
        IF VARK EQ '$<'.
          MOFF = VARPOS + MTVAROFF.
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
          ASSIGN MTTAB-TEXT(MTTAB-LEN) TO <VTXT>.
          REPLACE '$' WITH <VTXT>     INTO <MTXT>.
          MTVAROFF = MTTAB-LEN.
        ENDIF.
      ELSE.
        IF VARK EQ '&<'.
          MOFF = VARPOS + MTVAROFF.
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
          REPLACE '&' WITH ' ' INTO <MTXT>.
          MTVAROFF = 1.
        ENDIF.
        IF VARK EQ '$<'.
          MOFF = VARPOS + MTVAROFF.
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
          REPLACE '$' WITH ' ' INTO <MTXT>.
          MTVAROFF = 1.
        ENDIF.
      ENDIF.
    WHEN '1'.                                               "'&1'
      READ TABLE MTTAB INDEX 1.
      IF SY-SUBRC EQ 0.
        MOFF = VARPOS + MTVAROFF.
        ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
        ASSIGN MTTAB-TEXT(MTTAB-LEN) TO <VTXT>.
        REPLACE VARK WITH <VTXT>     INTO <MTXT>.
        MTVAROFF = MTTAB-LEN.
      ELSE.
        IF VARI GT MPARCNT.
          MOFF = VARPOS + MTVAROFF.
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
          REPLACE VARK WITH '  ' INTO <MTXT>.
          MTVAROFF = 2.
        ELSE.
          MOFF = VARPOS + MTVAROFF.
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
          REPLACE VARK WITH '%%_Z_%%' INTO <MTXT>.
          MTVAROFF = 7.
        ENDIF.
      ENDIF.
    WHEN '2'.                                               "'&2'
      READ TABLE MTTAB INDEX 2.
      IF SY-SUBRC EQ 0.
        MOFF = VARPOS + MTVAROFF.
        ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
        ASSIGN MTTAB-TEXT(MTTAB-LEN) TO <VTXT>.
        REPLACE VARK WITH <VTXT>     INTO <MTXT>.
        MTVAROFF = MTTAB-LEN.
      ELSE.
        IF VARI GT MPARCNT.
          MOFF = VARPOS + MTVAROFF.
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
          REPLACE VARK WITH '  ' INTO <MTXT>.
          MTVAROFF = 2.
        ELSE.
          MOFF = VARPOS + MTVAROFF.
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.
          REPLACE VARK WITH '%%_Z_%%' INTO <MTXT>.
          MTVAROFF = 7.
        ENDIF.
      ENDIF.
    WHEN '3'.                                               "'&3'
      READ TABLE MTTAB INDEX 3.
      IF SY-SUBRC EQ 0.
        MOFF = VARPOS + MTVAROFF.                    "neu
        ASSIGN MTEXT2+MOFF(*) TO <MTXT>.              "neu
        ASSIGN MTTAB-TEXT(MTTAB-LEN) TO <VTXT>.
        REPLACE VARK WITH <VTXT>     INTO <MTXT>.     "neu
        MTVAROFF = MTTAB-LEN.                        "neu
      ELSE.
        IF VARI GT MPARCNT.
          MOFF = VARPOS + MTVAROFF.                    "neu
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.              "neu
          REPLACE VARK WITH '  ' INTO <MTXT>.     "neu
          MTVAROFF = 2.                        "neu
        ELSE.
          MOFF = VARPOS + MTVAROFF.                    "neu
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.              "neu
          REPLACE VARK WITH '%%_Z_%%' INTO <MTXT>.     "neu
          MTVAROFF = 7.                   "neu
        ENDIF.
      ENDIF.
    WHEN '4'.                                               "'&4'
      READ TABLE MTTAB INDEX 4.
      IF SY-SUBRC EQ 0.
        MOFF = VARPOS + MTVAROFF.                    "neu
        ASSIGN MTEXT2+MOFF(*) TO <MTXT>.              "neu
        ASSIGN MTTAB-TEXT(MTTAB-LEN) TO <VTXT>.
        REPLACE VARK WITH <VTXT>     INTO <MTXT>.     "neu
        MTVAROFF = MTTAB-LEN.                        "neu
      ELSE.
        IF VARI GT MPARCNT.
          MOFF = VARPOS + MTVAROFF.                    "neu
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.              "neu
          REPLACE VARK WITH '  ' INTO <MTXT>.     "neu
          MTVAROFF = 2.                        "neu
        ELSE.
          MOFF = VARPOS + MTVAROFF.                    "neu
          ASSIGN MTEXT2+MOFF(*) TO <MTXT>.              "neu
          REPLACE VARK WITH '%%_Z_%%' INTO <MTXT>.     "neu
          MTVAROFF = 7.                   "neu
        ENDIF.
      ENDIF.
*
  ENDCASE.
*
  DO_CONDENSE = SPACE.
*
ENDFORM.                                     "replace_var

*----------------------------------------------------------------------*
*           Form: set_new_display
*----------------------------------------------------------------------*
FORM SET_NEW_DISPLAY.

  CASE TAB_DYNPRO-ACTIVETAB.

    WHEN 'TAB_TCODES'.
*     F2 in tcodes list: choose new transaction:
      CHECK SELECTED_INDEX > 0.
      READ TABLE BDC_TCODES INDEX SELECTED_INDEX.
      CHECK SY-SUBRC = 0.
      PERFORM SCAN_TRANSACTION USING BDC_TCODES-INDEX.
      CLEAR: BDC_DYNPRO_CONTENT, BDC_PROTOCOL_CONTENT, DYNPRO_INDEX.
      TCODE_INDEX  = SELECTED_INDEX.
      TCODE_STATUS = BDC_TCODES-S_TEXT.
      TCODE        = BDC_TCODES-TCODE.
      IF PREVIOUS_TAB IS INITIAL.
        TAB_DYNPRO-ACTIVETAB = 'TAB_LIST'.
      ELSE.
        TAB_DYNPRO-ACTIVETAB = PREVIOUS_TAB.
      ENDIF.

    WHEN 'TAB_LIST'.
*     F2 in screens list: simulate screen
      CHECK SELECTED_INDEX > 0.
*     simulate screen
      PERFORM SIMULATE_DYNPRO.

    WHEN 'TAB_PROTO'.
*     F2 in protocol list: show message long text:
      IF SELECTED_INDEX = 0.
        MESSAGE S519(00).
        RETURN.
      ENDIF.
      READ TABLE BDC_PROTOCOL INDEX SELECTED_INDEX.
      CHECK SY-SUBRC = 0.
      IF MAIN_OKCODE = 'GOTO_FL'.
        TCODE_INDEX = BDC_PROTOCOL-TCNT.
*ReSQ: No Need Of Change Internal Table BDC_TCODES Already Sorted
        READ TABLE BDC_TCODES
                   WITH KEY INDEX = TCODE_INDEX
                   BINARY SEARCH.
        IF SY-SUBRC <> 0.
          MESSAGE S501(SY).
          RETURN.
        ENDIF.
        PERFORM SCAN_TRANSACTION USING BDC_TCODES-INDEX.
        CLEAR: BDC_DYNPRO_CONTENT.

        MAIN_OKCODE = 'DISPLAY'.
        TAB_DYNPRO-ACTIVETAB = 'TAB_LIST'.
        IF RB-FIELDLIST = 'X'.
          SET PF-STATUS 'PF_MAIN_NAVI' EXCLUDING 'FL_ON'.
        ELSE.
          SET PF-STATUS 'PF_MAIN_NAVI' EXCLUDING 'FL_OFF'.
        ENDIF.

        DYNPRO_INDEX = BDC_PROTOCOL-MCNT.
      ELSE.
        PERFORM SHOW_LTEXT.
      ENDIF.

  ENDCASE.

ENDFORM.                    "set_new_display

*---------------------------------------------------------------------*
* FORM : show_ltext
*  display long text for a log message
*---------------------------------------------------------------------*
FORM SHOW_LTEXT.
*
  DATA:
    DOCNT TYPE I.

  DATA:
    BEGIN OF MY,
      MSGV1 LIKE SY-MSGV1,
      MSGV2 LIKE SY-MSGV2,
      MSGV3 LIKE SY-MSGV3,
      MSGV4 LIKE SY-MSGV4,
    END OF MY.

  DATA:
    MSG_TEXT  LIKE SHKONTEXT-MELDUNG,
    MSG_ARBGB LIKE SHKONTEXT-MELD_ID,
    MSG_NR    LIKE SHKONTEXT-MELD_NR,
    MSG_TITLE LIKE SHKONTEXT-TITEL.

*
* RABAX- or T100 message ?
*
  IF BDC_PROTOCOL-MID EQ '00' AND      "Rabax
    BDC_PROTOCOL-MNR EQ '341'.
    CLEAR: PAR.

* extract Rabax-ID and key fields from message string
    PAR = BDC_PROTOCOL-MPAR.
    IF PAR-LEN CN DIGITS. EXIT. ENDIF. "corrupt string"
    MY-MSGV1 = PAR-TEXT(PAR-LEN).
    SHIFT PAR LEFT BY PAR-LEN PLACES.
    SHIFT PAR LEFT BY 2 PLACES.
    IF PAR-LEN CN DIGITS. EXIT. ENDIF. "corrupt string"
    SNAP = PAR-TEXT(PAR-LEN).

* Rabax display
    CALL DIALOG 'RS_RUN_TIME_ERROR'
      EXPORTING
        SNAP-MANDT
        SNAP-DATUM
        SNAP-UZEIT
        SNAP-AHOST
        SNAP-UNAME
        SNAP-MODNO.
    EXIT.
  ENDIF.

*
* no RABAX
*
  DOCNT = 0.
*
  CLEAR: MY.
  IF BDC_PROTOCOL-MPARCNT CN DIGITS.        "Korrupter Datensatz:
    BDC_PROTOCOL-MPARCNT = 0.               "z.B. Hexnullen
  ENDIF.

  DO BDC_PROTOCOL-MPARCNT TIMES.
    IF BDC_PROTOCOL-MPAR(1) EQ SPACE.
      EXIT.
    ENDIF.
    DOCNT = DOCNT + 1.
    CLEAR PAR.
    MOVE BDC_PROTOCOL-MPAR TO PAR.
*
    IF PAR-LEN CN DIGITS.              "convert_no_number
      PAR-LEN = 1.                     "entschärfen
    ENDIF.
*
    CASE DOCNT.
      WHEN 1.
        WRITE PAR-TEXT TO MY-MSGV1(PAR-LEN).
      WHEN 2.
        WRITE PAR-TEXT TO MY-MSGV2(PAR-LEN).
      WHEN 3.
        WRITE PAR-TEXT TO MY-MSGV3(PAR-LEN).
      WHEN 4.
        WRITE PAR-TEXT TO MY-MSGV4(PAR-LEN).
    ENDCASE.
    PAR-LEN = PAR-LEN + 2.
    SHIFT BDC_PROTOCOL-MPAR BY PAR-LEN PLACES.
  ENDDO.

  MSG_ARBGB = BDC_PROTOCOL-MID.
  MSG_NR    = BDC_PROTOCOL-MNR.
  MSG_TEXT =  MTEXT.
  MSG_TITLE = SY-TITLE.
  CALL FUNCTION 'HELPSCREEN_NA_CREATE'
    EXPORTING
      MELDUNG = MSG_TEXT
      MELD_ID = MSG_ARBGB
      MELD_NR = MSG_NR
      MSGV1   = MY-MSGV1
      MSGV2   = MY-MSGV2
      MSGV3   = MY-MSGV3
      MSGV4   = MY-MSGV4
      TITEL   = MSG_TITLE.

ENDFORM.                               " show_ltext.

*----------------------------------------------------------------------*
*  FORM: simulate_dynpro
*    use function module CAT_SIMULATE_DYNPRO to simulate a dynpro
*    with contents according to APQD data of session
*----------------------------------------------------------------------*
FORM SIMULATE_DYNPRO.

  DATA:
    CAT_OKCODE LIKE SY-UCOMM,
    CAT_PARAMS LIKE CATP OCCURS 0 WITH HEADER LINE,
    ON_SUBSCREEN.

  CLEAR CAT_BDCDATA. REFRESH CAT_BDCDATA.
  READ TABLE BDC_DYNPRO INDEX SELECTED_INDEX.
  LOOP AT ALL_BDC_DYNPRO WHERE INDEX = BDC_DYNPRO-INDEX.
    MOVE-CORRESPONDING ALL_BDC_DYNPRO TO CAT_BDCDATA.
    APPEND CAT_BDCDATA.
  ENDLOOP.
  READ TABLE CAT_BDCDATA INDEX 1.
  CAT_BDCDATA-DYNBEGIN = 'X'. MODIFY CAT_BDCDATA INDEX 1.

* now we need some extra work to generate the correct input data
* format for FUNCTION 'CAT_SIMULATE_DYNPRO' for subscreen fields.
  CLEAR ON_SUBSCREEN.
  LOOP AT CAT_BDCDATA.
*   check if there is a new subscreen
    IF CAT_BDCDATA-FNAM = 'BDC_SUBSCR'.
      MOVE CAT_BDCDATA-FVAL TO BDC_SUBSCREEN.
      CLEAR CAT_BDCDATA-FVAL.
      CONCATENATE BDC_SUBSCREEN-PROGRAM
                  BDC_SUBSCREEN-DYNPRO
                  BDC_SUBSCREEN-SUBSCR
                  INTO CAT_BDCDATA-FVAL SEPARATED BY ' '.
      MODIFY CAT_BDCDATA.
      ON_SUBSCREEN = 'X'.
    ENDIF.
  ENDLOOP.

  READ TABLE CAT_BDCDATA INDEX 1.
  SET PF-STATUS 'CSIM'.
  SET TITLEBAR '0300' WITH CAT_BDCDATA-PROGRAM CAT_BDCDATA-DYNPRO.
  MESSAGE S223(TT).

  CALL FUNCTION 'CAT_SIMULATE_DYNPRO'
    EXPORTING
      MPOOL            = CAT_BDCDATA-PROGRAM
      DYNNR            = CAT_BDCDATA-DYNPRO
      DISPLAY_ONLY     = 'X'
      OWN_STATUS_TITLE = 'X'
    TABLES
      FIELDDATA        = CAT_BDCDATA
      PARAMLIST        = CAT_PARAMS
    EXCEPTIONS
      NO_DYNPRO        = 1
      DYNPRO_NOT_FOUND = 2
      GEN_ERROR        = 3
      ENQ_ERROR        = 4
      SUBSCR_ERROR     = 5
      OTHERS           = 6.

  CASE SY-SUBRC.
    WHEN 1. MESSAGE S221(TT).
    WHEN 2.
      MESSAGE S219(TT)
      WITH CAT_BDCDATA-PROGRAM CAT_BDCDATA-DYNPRO.
    WHEN 3. MESSAGE S236(TT) WITH ' ' ' '.
    WHEN 4. MESSAGE S215(TT).
    WHEN 5. MESSAGE S238(TT) WITH ' ' ' '.
    WHEN 6. MESSAGE S258(00).
  ENDCASE.

ENDFORM.                    "simulate_dynpro

*----------------------------------------------------------------------*
*  Form: scrolling
*    scrolling in table controls according to SAP style guide
*----------------------------------------------------------------------*
FORM SCROLLING.
  DATA:
    TOP_LINE  LIKE SY-INDEX,
    LAST_LINE LIKE SY-INDEX.

  CASE TAB_DYNPRO-ACTIVETAB.
    WHEN 'TAB_TCODES'.
      TOP_LINE = TC_TCODES-TOP_LINE.
      DESCRIBE TABLE BDC_TCODES LINES LAST_LINE.
    WHEN 'TAB_LIST'.
      TOP_LINE = TC_DYNPRO-TOP_LINE.
      DESCRIBE TABLE BDC_DYNPRO LINES LAST_LINE.
    WHEN 'TAB_PROTO'.
      TOP_LINE = TC_PROTOCOL-TOP_LINE.
      DESCRIBE TABLE BDC_PROTOCOL LINES LAST_LINE.
  ENDCASE.

  CALL FUNCTION 'SCROLLING_IN_TABLE'
    EXPORTING
      ENTRY_ACT             = TOP_LINE
      ENTRY_FROM            = 1
      ENTRY_TO              = LAST_LINE
      OK_CODE               = MAIN_OKCODE
      LAST_PAGE_FULL        = ' '
      OVERLAPPING           = ' '
      LOOPS                 = LOOPC
    IMPORTING
      ENTRIES_SUM           = ENTRIES
      ENTRY_NEW             = NEW_LINE
      PAGES_SUM             = TOTAL_PAGES
      PAGE_NEW              = NEW_PAGE
    EXCEPTIONS
      NO_ENTRY_OR_PAGE_ACT  = 01
      NO_ENTRY_TO           = 02
      NO_OK_CODE_OR_PAGE_GO = 03.

  CHECK SY-SUBRC = 0.

  CASE TAB_DYNPRO-ACTIVETAB.
    WHEN 'TAB_TCODES'.
      TC_TCODES-TOP_LINE = NEW_LINE.
    WHEN 'TAB_LIST'.
      TC_DYNPRO-TOP_LINE = NEW_LINE.
    WHEN 'TAB_PROTO'.
      TC_PROTOCOL-TOP_LINE = NEW_LINE.
  ENDCASE.

ENDFORM.                    "scrolling

*&---------------------------------------------------------------------*
*&      Module  d0700_init  OUTPUT
*&---------------------------------------------------------------------*
MODULE D0700_INIT OUTPUT.

  CLEAR D0700_FCODE.

  SET TITLEBAR 'QUEUE_DUMP' WITH APQI-GROUPID.
  SET PF-STATUS 'PF_QUEUE'.

  IF Q-TCODE_INDEX IS INITIAL.
    IF NOT TCODE_INDEX_APQD IS INITIAL.
      Q-TCODE_INDEX = TCODE_INDEX_APQD.
    ELSE.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT ALL_BDC_TCODES .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
      READ TABLE ALL_BDC_TCODES INTO Q-WA INDEX 1.
      Q-TCODE_INDEX = Q-WA-INDEX.
    ENDIF.
  ENDIF.

* check for unicode; how many byte's a character?
  DESCRIBE FIELD Q-C LENGTH Q-UC_BYTES IN BYTE MODE.

* read all blocks (dynpros) of the currently selected transaction
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM APQD INTO TABLE IT_APQD
*         WHERE QID = QUEUE_ID AND TRANS = Q-TCODE_INDEX.
*
* NEW CODE
  SELECT *
 FROM APQD INTO TABLE IT_APQD
         WHERE QID = QUEUE_ID AND TRANS = Q-TCODE_INDEX ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

ENDMODULE.                 " d0700_init  OUTPUT

*&---------------------------------------------------------------------*
*&      Module d0700_fcode  INPUT
*&---------------------------------------------------------------------*
MODULE D0700_FCODE INPUT.
  CASE D0700_FCODE.
    WHEN 'BACK'.
      CLEAR Q-TCODE_INDEX.
      LEAVE TO SCREEN 0.
    WHEN 'END'.
      CLEAR Q-TCODE_INDEX.
      LEAVE PROGRAM.
    WHEN 'TOGGLE'.
      IF Q-SHOW_HEX IS INITIAL.
        Q-SHOW_HEX = 'X'.
      ELSE.
        CLEAR Q-SHOW_HEX.
      ENDIF.
    WHEN 'APQI'.
      CALL SCREEN '0701'.
    WHEN OTHERS.
      "nop
  ENDCASE.
ENDMODULE.                 " ok_700  INPUT

*&---------------------------------------------------------------------*
*&      Module  exit_700  INPUT
*&---------------------------------------------------------------------*
MODULE D0700_EXIT INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " exit_700  INPUT

*&---------------------------------------------------------------------*
*&      Module  set_status_icon  OUTPUT
*&---------------------------------------------------------------------*
MODULE SET_STATUS_ICON OUTPUT.

  DATA: ICON_NAME(4),
        ICON_INFO(32).

  CASE ALL_BDC_TCODES-STATUS.
    WHEN 'F'.
      ICON_NAME = ICON_STATUS_OK.
      ICON_INFO = 'verarbeitet'(002).
    WHEN 'E'.
      ICON_NAME = ICON_STATUS_CRITICAL.
      ICON_INFO = 'fehlerhaft'(001).
    WHEN 'D'.
      ICON_NAME = ICON_DELETE.
      ICON_INFO = 'gelöscht'(005).
    WHEN ' ' OR 'B'.
      ICON_NAME = ICON_CREATE.
      ICON_INFO = 'neu'(034).
    WHEN OTHERS.
      ICON_NAME = ALL_BDC_TCODES-STATUS.
      ICON_INFO = '???'.
  ENDCASE.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      NAME   = ICON_NAME
      INFO   = ICON_INFO
    IMPORTING
      RESULT = STATUS_ICON
    EXCEPTIONS
      OTHERS = 1.
  IF SY-SUBRC <> 0.
    STATUS_ICON = ICON_NAME.
  ENDIF.

  IF ALL_BDC_TCODES-INDEX = Q-TCODE_INDEX.
    LOOP AT SCREEN.
      SCREEN-INTENSIFIED = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " set_status_icon  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  d0700_get_cursor  INPUT
*&---------------------------------------------------------------------*
MODULE D0700_GET_CURSOR INPUT.

  GET CURSOR FIELD Q-C_FIELD LINE Q-C_LINE AREA Q-C_AREA.
  IF SY-SUBRC = 0.
    CHECK Q-C_AREA = 'TC_Q_TCODES'.
    CHECK Q-C_LINE > 0.
    Q-ITAB_INDEX = TC_Q_TCODES-TOP_LINE + Q-C_LINE - 1.
*ReSQ: No Need Of Change Internal Table ALL_BDC_TCODES Already Sorted
    READ TABLE ALL_BDC_TCODES INTO Q-WA INDEX Q-ITAB_INDEX.
    Q-TCODE_INDEX = Q-WA-INDEX.
  ENDIF.

ENDMODULE.                 " d0700_get_cursor  INPUT

*&---------------------------------------------------------------------*
*&      Module  d0700_control_init  OUTPUT
*&---------------------------------------------------------------------*
MODULE D0700_CONTROL_INIT OUTPUT.

  CHECK Q-CONTROL_INIT = 'X'.

*   create custom container and dynamic document

  CREATE OBJECT CUST
    EXPORTING
      CONTAINER_NAME = 'CUSTOM_CONTAINER'
      DYNNR = '0700'
      REPID = 'RSBDC_ANALYSE'
*       lifetime = cntl_lifetime_dynpro
    EXCEPTIONS
      OTHERS = 1.

  CREATE OBJECT DD
    EXPORTING
      BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA.

  CLEAR Q-CONTROL_INIT.

ENDMODULE.                 " d0700_control_init  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  d0700_display  OUTPUT
*&---------------------------------------------------------------------*
MODULE D0700_DISPLAY OUTPUT.

  CALL METHOD DD->INITIALIZE_DOCUMENT
    EXPORTING
      BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA.

  REFRESH IT_BLOCKS.

* loop at all apqd blocks for the current transaction and built up the
* dynamic document for each block
  LOOP AT IT_APQD.
    PERFORM BUILD_QUEUE_DD.
  ENDLOOP.

  CALL METHOD DD->MERGE_DOCUMENT.
  CALL METHOD DD->DISPLAY_DOCUMENT
    EXPORTING
      PARENT             = CUST
      REUSE_CONTROL      = Q-REUSE_CONTROL
    EXCEPTIONS
      HTML_DISPLAY_ERROR = 1.

* if the HTML control for the DD is already created, we can re-use it.
  IF Q-REUSE_CONTROL IS INITIAL.
    Q-REUSE_CONTROL = 'X'.
  ENDIF.

ENDMODULE.                 " d0700_display  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  build_queue_dd
*&---------------------------------------------------------------------*
FORM BUILD_QUEUE_DD.

  DATA: OFF LIKE SY-INDEX.

* write the most important apqd header fields

  DD->NEW_LINE( ).
  WRITE IT_APQD-QID TO C.
  CONCATENATE 'Queue-ID:'(030) C INTO T SEPARATED BY SPACE.
  DD->ADD_TEXT( TEXT = T ).

  DD->NEW_LINE( ).
  WRITE IT_APQD-TRANS TO C.
  CONCATENATE 'Transaktion:'(031) C INTO T SEPARATED BY SPACE.
  DD->ADD_TEXT( TEXT = T ).

  DD->NEW_LINE( ).
  WRITE IT_APQD-BLOCK TO C.
  CONCATENATE 'Block:'(032) C INTO T SEPARATED BY SPACE.
  DD->ADD_TEXT( TEXT = T
                SAP_COLOR = CL_DD_TABLE_AREA=>LIST_POSITIVE ).

  DD->NEW_LINE( ).
  WRITE IT_APQD-VARLEN TO C.
  CONCATENATE 'VARDATA-Länge:'(033) C INTO T SEPARATED BY SPACE.
  DD->ADD_TEXT( TEXT = T ).

  DD->NEW_LINE( ).

* now add a DD table to it_blocks for the current APQD block

  CLEAR B_WA.
  REFRESH IT_CX.

  CALL METHOD DD->ADD_TABLE
    EXPORTING
      NO_OF_COLUMNS               = NR_COLS
      CELL_BACKGROUND_TRANSPARENT = SPACE
      BORDER                      = '0'
      WIDTH                       = '100%'
    IMPORTING
      TABLEAREA                   = B_WA-DTA
      TABLE                       = B_WA-DT
    EXCEPTIONS
      OTHERS                      = 1.

  APPEND B_WA TO IT_BLOCKS.

* prepare ascii/hex table

  DO IT_APQD-VARLEN TIMES.
    OFF = SY-INDEX - 1.
    ASSIGN IT_APQD-VARDATA+OFF(1) TO <C>.
    CASE Q-UC_BYTES.
      WHEN 1.
        ASSIGN <C> TO <X> CASTING TYPE UC_1.
      WHEN 2.
        ASSIGN <C> TO <X> CASTING TYPE UC_2.
      WHEN 4.
        ASSIGN <C> TO <X> CASTING TYPE UC_4.
      WHEN OTHERS.
        " exception, to be coded
    ENDCASE.
    CX-CHAR = <C>.
    CX-HEX  = <X>.
    WRITE CX-HEX TO CX-XTOC.
    APPEND CX TO IT_CX.
  ENDDO.

* write apqd-vardata (as prepared in it_cx ) to the DD list
  PERFORM VARDATA_LINES.

ENDFORM.                    " build_queue_dd

*&---------------------------------------------------------------------*
*&      Form  vardata_lines
*&---------------------------------------------------------------------*
FORM VARDATA_LINES.

  COUNT-START = 0.
  COUNT-REST  = IT_APQD-VARLEN.
  IF IT_APQD-VARLEN < NR_COLS.
    COUNT-PART = IT_APQD-VARLEN.
  ELSE.
    COUNT-PART = NR_COLS.
  ENDIF.

  DO.

    CSPAN = NR_COLS - COUNT-PART.

*   1. the ASCII - Value

    B_WA-DTA->NEW_ROW( SAP_COLOR = CL_DD_TABLE_AREA=>LIST_HEADING ).

    DO COUNT-PART TIMES.
      COUNT-INDEX = COUNT-START + SY-INDEX.
      READ TABLE IT_CX INTO CX INDEX COUNT-INDEX.
      IF NOT CX-HEX IS INITIAL.
        T = CX-CHAR.
        B_WA-DTA->ADD_TEXT( TEXT = T ).
      ELSE.
        T = SPACE.
        B_WA-DTA->ADD_TEXT( TEXT = T
                          SAP_COLOR = CL_DD_TABLE_AREA=>LIST_NEGATIVE ).
      ENDIF.
    ENDDO.
    IF COUNT-REST < NR_COLS.
      T = SPACE.
      DO CSPAN TIMES.
        B_WA-DTA->ADD_TEXT( TEXT = T
                            SAP_COLOR =
                              CL_DD_TABLE_AREA=>LIST_BACKGROUND ).
      ENDDO.
    ENDIF.

    IF Q-SHOW_HEX = 'X'.

*     2. at least one Byte hex-code for non-unicode systems

      B_WA-DTA->NEW_ROW( SAP_STYLE = CL_DD_TABLE_AREA=>LIST_NORMAL ).
      PERFORM HEX_LINE USING CX-XTOC+0(1).
      B_WA-DTA->NEW_ROW( SAP_STYLE = CL_DD_TABLE_AREA=>LIST_NORMAL ).
      PERFORM HEX_LINE USING CX-XTOC+1(1).

*     3. two-byte unicode:

      IF ( Q-UC_BYTES = 2 OR Q-UC_BYTES = 4 ).
        B_WA-DTA->NEW_ROW( SAP_STYLE = CL_DD_TABLE_AREA=>LIST_NORMAL ).
        PERFORM HEX_LINE USING CX-XTOC+2(1).
        B_WA-DTA->NEW_ROW( SAP_STYLE = CL_DD_TABLE_AREA=>LIST_NORMAL ).
        PERFORM HEX_LINE USING CX-XTOC+3(1).
      ENDIF.

*     3. four-byte unicode:

      IF ( Q-UC_BYTES = 4 ).
        B_WA-DTA->NEW_ROW( SAP_STYLE = CL_DD_TABLE_AREA=>LIST_NORMAL ).
        PERFORM HEX_LINE USING CX-XTOC+4(1).
        B_WA-DTA->NEW_ROW( SAP_STYLE = CL_DD_TABLE_AREA=>LIST_NORMAL ).
        PERFORM HEX_LINE USING CX-XTOC+5(1).
        B_WA-DTA->NEW_ROW( SAP_STYLE = CL_DD_TABLE_AREA=>LIST_NORMAL ).
        PERFORM HEX_LINE USING CX-XTOC+6(1).
        B_WA-DTA->NEW_ROW( SAP_STYLE = CL_DD_TABLE_AREA=>LIST_NORMAL ).
        PERFORM HEX_LINE USING CX-XTOC+7(1).
      ENDIF.

    ENDIF.

    B_WA-DTA->NEW_ROW( SAP_STYLE = CL_DD_TABLE_AREA=>LIST_NORMAL ).

*   calculate new counter values for next line(s)

    COUNT-REST  = COUNT-REST - NR_COLS.
    IF COUNT-REST < 0.
      EXIT.
    ELSE.
      COUNT-START = COUNT-START + NR_COLS.
      IF COUNT-REST < NR_COLS.
        COUNT-PART = COUNT-REST.
      ELSE.
        COUNT-PART = NR_COLS.
      ENDIF.
    ENDIF.

  ENDDO.

ENDFORM.                    " vardata_lines

*&---------------------------------------------------------------------*
*&      Form  hex_line
*&---------------------------------------------------------------------*
*      -->P_T  text
*----------------------------------------------------------------------*
FORM HEX_LINE USING P_T.
  DO COUNT-PART TIMES.
    COUNT-INDEX = COUNT-START + SY-INDEX.
    READ TABLE IT_CX INTO CX INDEX COUNT-INDEX.
    T = P_T.
    B_WA-DTA->ADD_TEXT( TEXT = T ).
  ENDDO.
  IF COUNT-REST < NR_COLS.
    DO CSPAN TIMES.
      T = SPACE.
      B_WA-DTA->ADD_TEXT( TEXT = T ).
    ENDDO.
  ENDIF.
ENDFORM.                    " hex_line

*&---------------------------------------------------------------------*
*&      Module  d0701_init  OUTPUT
*&---------------------------------------------------------------------*
MODULE D0701_INIT OUTPUT.
  DATA:
    EXTAB TYPE STANDARD TABLE OF FCODE.

  REFRESH EXTAB.
  APPEND 'TOGGLE' TO EXTAB.
  APPEND 'APQI'   TO EXTAB.

  SET PF-STATUS 'PF_QUEUE' EXCLUDING EXTAB.
  SET TITLEBAR 'APQI_DUMP' WITH APQI-GROUPID.

ENDMODULE.                 " d0701_init  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  d0701_fcode  INPUT
*&---------------------------------------------------------------------*
MODULE D0701_FCODE INPUT.
  CASE D0701_FCODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'END'.
      LEAVE PROGRAM.
    WHEN 'UNLOCK'.
      PERFORM SESSION_UNLOCK.
    WHEN 'TOGGLE_KEEP'.
      PERFORM SESSION_TOGGLE_KEEP_FLAG.
    WHEN OTHERS.
      "nop
  ENDCASE.
ENDMODULE.                 " d0701_fcode  INPUT

*&---------------------------------------------------------------------*
*&      Form  session_unlock
*&---------------------------------------------------------------------*
FORM SESSION_UNLOCK.

  DATA: USER LIKE SY-UNAME.

  AUTHORITY-CHECK OBJECT 'S_BDC_MONI'
              ID 'BDCAKTI'     FIELD 'LOCK'
              ID 'BDCGROUPID'  FIELD APQI-GROUPID.

  IF SY-SUBRC <> 0. MESSAGE I394 WITH APQI-GROUPID. EXIT. ENDIF.

  CALL FUNCTION 'ENQUEUE_BDC_QID'
    EXPORTING
      DATATYP        = 'BDC'
      GROUPID        = APQI-GROUPID
      QID            = APQI-QID
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 99.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        USER = SY-MSGV1.
        MESSAGE I322 WITH APQI-GROUPID APQI-QID USER.
      WHEN 99. MESSAGE I353 WITH APQI-GROUPID.
    ENDCASE.
    EXIT.
  ENDIF.

  CLEAR APQI-STARTDATE. UPDATE APQI. COMMIT WORK.

  CALL FUNCTION 'DEQUEUE_BDC_QID'
    EXPORTING
      DATATYP = 'BDC'
      GROUPID = APQI-GROUPID
      QID     = APQI-QID.

* tell SM35 to reload table APQI
  EXPORT RELOAD_APQI TO MEMORY ID 'RELOAD_APQI'.

ENDFORM.                    " session_unlock

*&---------------------------------------------------------------------*
*&      Form  session_toggle_keep_flag
*&---------------------------------------------------------------------*
FORM SESSION_TOGGLE_KEEP_FLAG.

  DATA: USER LIKE SY-UNAME.

* since setting or deleting the apqi-qerase flag can be considered of
* being equal to deleting a session, we check for the corresponding
* authorization. There's no special 'KEEP' activity for S_BDC_MONI :-(
  AUTHORITY-CHECK OBJECT 'S_BDC_MONI'
              ID 'BDCAKTI'     FIELD 'DELE'
              ID 'BDCGROUPID'  FIELD APQI-GROUPID.

  IF SY-SUBRC <> 0. MESSAGE I395 WITH APQI-GROUPID. EXIT. ENDIF.

  CALL FUNCTION 'ENQUEUE_BDC_QID'
    EXPORTING
      DATATYP        = 'BDC'
      GROUPID        = APQI-GROUPID
      QID            = APQI-QID
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 99.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.
      WHEN 1.
        USER = SY-MSGV1.
        MESSAGE I322 WITH APQI-GROUPID APQI-QID USER.
      WHEN 99.
        MESSAGE I353 WITH APQI-GROUPID.
    ENDCASE.
    EXIT.
  ENDIF.

  IF APQI-QERASE = 'X'.
    CLEAR APQI-QERASE.
  ELSE.
    APQI-QERASE = 'X'.
  ENDIF.
  UPDATE APQI. COMMIT WORK.

  CALL FUNCTION 'DEQUEUE_BDC_QID'
    EXPORTING
      DATATYP = 'BDC'
      GROUPID = APQI-GROUPID
      QID     = APQI-QID.

* tell SM35 to reload table APQI
  EXPORT RELOAD_APQI TO MEMORY ID 'RELOAD_APQI'.

ENDFORM.                    " session_toggle_keep_flag

*&---------------------------------------------------------------------*
*&      Module  d0702_init  OUTPUT
*&---------------------------------------------------------------------*
MODULE D0702_INIT OUTPUT.

  IF APQI-STARTDATE IS INITIAL.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'PB_UNLOCK'.
        SCREEN-INVISIBLE = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF     (     ( APQI-STARTPGID+1(1) >= '1' )
           AND ( APQI-STARTPGID+1(1) <= '6' ) )
      OR ( APQI-STARTPGID+1(1) = '#' ).
    BDC_SESSIO-DCPFM = APQI-STARTPGID+0(1).
    BDC_SESSIO-DATFM = APQI-STARTPGID+1(1).
  ELSE.
    LOOP AT SCREEN.
      IF    ( SCREEN-NAME = 'BDC_SESSIO-DCPFM' )
         OR ( SCREEN-NAME = 'BDC_SESSIO-DATFM' ).
        SCREEN-INVISIBLE = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " d0702_init  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MARK_TCODE  OUTPUT
*&---------------------------------------------------------------------*
MODULE MARK_TCODE OUTPUT.

  IF (      ( TCODE_INDEX_APQD = 0 )
        AND ( BDC_TCODES-INDEX =  1ST_BDC_TCODE_INDEX ) )
    OR ( BDC_TCODES-INDEX = TCODE_INDEX_APQD ).
    LOOP AT SCREEN.
      SCREEN-INTENSIFIED = 1. MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " mark_tcode output

*----------------------------------------------------------------------*
* FORM count_dynpros
*   Count dynpros for a selected transaction
*----------------------------------------------------------------------*
FORM COUNT_DYNPROS USING TCNT.

  CLEAR IT_APQD. REFRESH IT_APQD.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM APQD INTO TABLE IT_APQD
*         WHERE QID = QUEUE_ID AND TRANS = TCNT.
*
* NEW CODE
  SELECT *
 FROM APQD INTO TABLE IT_APQD
         WHERE QID = QUEUE_ID AND TRANS = TCNT ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  CLEAR DYNPRO_CNT.
  LOOP AT IT_APQD.
    IF IT_APQD-VARDATA(1) = 'M'.     "it's a message header
      DYNPRO_CNT = DYNPRO_CNT + 1.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "count_dynpros

*----------------------------------------------------------------------*
* FORM recalculate_counters
*   recalculate dynpro counters
*----------------------------------------------------------------------*
FORM RECALCULATE_COUNTERS.

  CLEAR: APQDCNT-MSGCNTB,
         APQDCNT-MSGCNTE,
         APQDCNT-MSGCNTO,
         APQDCNT-MSGCNTF,
         APQDCNT-MSGCNTD,
         APQDCNT-MSGCNT,
         APQDCNT-MSGCNTX,
         APQDCNT-MSGCNTP.

  LOOP AT ALL_BDC_TCODES.
    PERFORM COUNT_DYNPROS USING ALL_BDC_TCODES-INDEX.
    ADD DYNPRO_CNT TO APQDCNT-MSGCNT.
    CASE ALL_BDC_TCODES-STATUS.
      WHEN 'D' OR 'G'.
        ADD DYNPRO_CNT TO APQDCNT-MSGCNTD.
      WHEN 'F'.
        ADD DYNPRO_CNT TO APQDCNT-MSGCNTF.
      WHEN 'E'.
        ADD DYNPRO_CNT TO APQDCNT-MSGCNTE.
      WHEN 'B'.
        ADD DYNPRO_CNT TO APQDCNT-MSGCNTB.
    ENDCASE.
  ENDLOOP.

  APQDCNT-MSGCNTO   =   APQDCNT-MSGCNTB
                      + APQDCNT-MSGCNTE.

  APQDCNT-MSGCNTD   =   APQDCNT-MSGCNT
                      - APQDCNT-MSGCNTF
                      - APQDCNT-MSGCNTE
                      - APQDCNT-MSGCNTB.

  APQDCNT-MSGCNTP   =   APQI-PUTBLOCK
                      - APQI-PUTTRANS.

  APQDCNT-MSGCNTX   =   APQDCNT-MSGCNTP
                      - APQDCNT-MSGCNT.

  SHOW_DYNPRO_CNT = 'X'.

ENDFORM.    "recalculate_counters

*----------------------------------------------------------------------*
* FORM build_ex_cua
*   build cua excluding list ex_cua
*----------------------------------------------------------------------*
FORM BUILD_EX_CUA
     USING P1 P2 P3 P4.

  DELETE EX_CUA FROM 1.
  IF P1 IS NOT INITIAL.
    EX_CUA-FCODE = P1.  APPEND EX_CUA.
  ENDIF.
  IF P2 IS NOT INITIAL.
    EX_CUA-FCODE = P2.  APPEND EX_CUA.
  ENDIF.
  IF P3 IS NOT INITIAL.
    EX_CUA-FCODE = P3.  APPEND EX_CUA.
  ENDIF.
  IF P4 IS NOT INITIAL.
    EX_CUA-FCODE = P4.  APPEND EX_CUA.
  ENDIF.

ENDFORM.    "build_ex_cua
