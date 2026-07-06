PROGRAM ZRSWATCH0 MESSAGE-ID S1 NO STANDARD PAGE HEADING LINE-SIZE 512.
******************************************************************CAS***
*
* (c) SAP Aktiengesellschaft
*     Systeme, Anwendungen und Produkte in der Datenverarbeitung
*
*     ADATAR
*     12.09.98 - Added code to read and display userdefined directories
*                and to allow administrators to define directories.
*
*     Derwand / Kramer
*     3.1H / 06.05.97 - DIR_<DB>_HOME (o.ä.) je nach DB-System
*
*     PEHLJ
*     12.10.93 - ANZEIGE FUER BELIEBIGE DIRECTORIES WG. EARLYWATCH
*
*     Mittelstein
*     1.3 / 03.09.92 - Behebung des SY-UCOMM-Problems.
*                      Generelle Bereingung und Ordnung.
*     Garbe (CAS-Nord)
*     1.0 / 24.03.92 - Liste der Fehlerprotokolldateien,
*                    - Anzeige der Dateidetails
*                    - Inhaltsanzeige einer Fehlerprotokolldatei
*
******************************************************************CAS***

TYPES: NAME_OF_DIR(1024)        TYPE C.

DATA:  MAX_LEN_OF_FILENAME      TYPE I VALUE  260.

DATA:  BEGIN OF DIRLINES OCCURS 5,
       TEXT                     TYPE FILENAME_AL11,
       END   OF DIRLINES.

DATA:  BEGIN OF DIRECTORY_STACK OCCURS 5,
       NAME                     TYPE NAME_OF_DIR,
       END OF DIRECTORY_STACK.

DATA: SAP_YES(1)  VALUE 'X'
    , SAP_NO(1)   VALUE ' '
    , SRT(1)      VALUE 'T'
    , NO_CS       VALUE ' '          " no MUST_ContainString
    , ALL_GEN     VALUE '*'          " generic filename shall select all
    , STRLEN      LIKE  SY-FDPOS
    .

DATA: H_LIST_INDEX  TYPE P  " hided with each data line; otherwise 0
    , FCODE(4)      TYPE C
    .

DATA: BEGIN OF SEARCHPOINTS OCCURS 10,
        DIRNAME     TYPE DIRNAME_AL11, " name of directory.
        SP_NAME     TYPE FILENAME_AL11," name of entry. (may end with *)
        SP_CS(10)   TYPE C,            " ContainsString pattern for name
      END OF SEARCHPOINTS.

DATA: BEGIN OF ISEARCHPOINTS OCCURS 10,
        DIRNAME(75) TYPE C,            " name of directory.
        ALIASS(75)  TYPE C,            " alias for directory.
        SVRNAME(75) TYPE C,            " svr where directory is availabl
        SP_NAME(75) TYPE C,            " name of entry. (may end with *)
        SP_CS(10)   TYPE C,            " ContainsString pattern for name
      END OF ISEARCHPOINTS.

DATA: GLOBALDIRECTORY TYPE DIRNAME_AL11.

DATA: BEGIN OF FILE,
        DIRNAME     TYPE DIRNAME_AL11, " name of directory
        NAME        TYPE FILENAME_AL11," name of entry
        TYPE(10)    TYPE C,            " type of entry.
        LEN(8)      TYPE P,            " length in bytes.
        OWNER(8)    TYPE C,            " owner of the entry.
        MTIME(6)    TYPE P,            " last mod.date, sec since 1970
        MODE(9)     TYPE C,            " like "rwx-r-x--x": prot. mode
        USEABLE(1)  TYPE C,
        SUBRC(4)    TYPE C,
        ERRNO(3)    TYPE C,
        ERRMSG(40)  TYPE C,
        MOD_DATE    TYPE D,
        MOD_TIME(8) TYPE C,            " hh:mm:ss
        SEEN(1)     TYPE C,
        CHANGED(1)  TYPE C,
      END OF FILE.

DATA: BEGIN OF FILE_KEY,
        DIRNAME     TYPE DIRNAME_AL11, " name of directory
        NAME        TYPE FILENAME_AL11," name of entry
      END OF FILE_KEY.

DATA: BEGIN OF FILE_LIST OCCURS 100,
        DIRNAME     TYPE DIRNAME_AL11, " name of directory
        NAME        TYPE FILENAME_AL11," name of entry
        TYPE(10)    TYPE C,            " type of entry.
        LEN(8)      TYPE P,            " length in bytes.
        OWNER(8)    TYPE C,            " owner of the entry.
        MTIME(6)    TYPE P,            " last mod. date, sec since 1970
        MODE(9)     TYPE C,            " like "rwx-r-x--x": prot. mode
        USEABLE(1)  TYPE C,
        SUBRC(4)    TYPE C,
        ERRNO(3)    TYPE C,
        ERRMSG(40)  TYPE C,
        MOD_DATE    TYPE D,
        MOD_TIME(8) TYPE C,            " hh:mm:ss
        SEEN(1)     TYPE C,
        CHANGED(1)  TYPE C,
      END OF FILE_LIST.

DATA: TIMEZONE_SEC(5)  TYPE P, " seconds local time is later than GMT
      TIMEZONE_NAME(7) TYPE C.

DATA: CFLAG(1) VALUE 'X'.

DATA: MY_NAME(20).

*  data definitions for user defined directories
TABLES USER_DIR.

DATA: OKCODE(4).
DATA: BEGIN OF IUSER_DIR OCCURS 1,
      DIRNAME  LIKE USER_DIR-DIRNAME,
      ALIASS   LIKE USER_DIR-ALIASS,
      SVRNAME  LIKE USER_DIR-SVRNAME,
      SP_NAME  LIKE USER_DIR-SP_NAME,
      SP_CS    LIKE USER_DIR-SP_CS,
END OF IUSER_DIR.

DATA: ADMIN_AUTH.
DATA  SAVED.
DATA: CHANGED, F4HELP.
DATA  MY_ANSWER.
DATA  A_DIRNAME(75).
DATA  TEMP_DIRNAME(75).
DATA  FILE_SEPARATOR(1).
DATA  LIST_FILENAME TYPE DIRNAME_AL11.
DATA  LIST_FILE_ONLY(1).

*--- C5056155 Start Of ALV ------------------------------------------*
CLASS : LC_HANDLE_EVENTS DEFINITION DEFERRED.
CONSTANTS: GC_TRUE  TYPE SAP_BOOL VALUE 'X'.

DATA: GT_OUTTAB      TYPE STANDARD TABLE OF CST_RSWATCH01_ALV,
      GT_OUTTAB1     TYPE STANDARD TABLE OF CST_RSWATCH02_ALV,
      GT_OUT_DIR     TYPE STANDARD TABLE OF CST_RSWATCH03_ALV,
      GT_OUT_ATTRI   TYPE STANDARD TABLE OF CST_RSWATCH04_ALV,
      GT_OUT_DISP    TYPE STANDARD TABLE OF CST_RSWATCH05_ALV.

DATA: GS_OUTTAB      TYPE CST_RSWATCH01_ALV,
      GS_OUTTAB1     TYPE CST_RSWATCH02_ALV,
      GS_OUT_DIR     TYPE CST_RSWATCH03_ALV,
      GS_OUT_ATTRI   TYPE CST_RSWATCH04_ALV,
      GS_OUT_DISP    TYPE CST_RSWATCH05_ALV.

DATA: GR_TABLE       TYPE REF TO CL_SALV_TABLE,
      GR_TABLE1      TYPE REF TO CL_SALV_TABLE,
      GR_TABLE2      TYPE REF TO CL_SALV_TABLE,
      GR_EVENTS      TYPE REF TO LC_HANDLE_EVENTS.

DATA: G_OKCODE       TYPE SYUCOMM,
      GV_ROW         TYPE I,
      G_REPID        TYPE SY-REPID,
      G_DIR_FLAG     TYPE I,
      G_DIRNAME(1024) TYPE C,
      GV_FLAG        TYPE I VALUE 0,
      GV_PFKEY       TYPE SY-PFKEY.

CONSTANTS: ALL_SERVER TYPE STRING VALUE 'all'.              "#EC NOTEXT

MOVE : SY-REPID TO G_REPID.


************************************************************************
*         Class Definition
************************************************************************
CLASS LC_HANDLE_EVENTS DEFINITION.
  PUBLIC SECTION.
    METHODS:
      ON_BUTTON_CLICK FOR EVENT ADDED_FUNCTION OF CL_SALV_EVENTS
        IMPORTING E_SALV_FUNCTION,
      ON_DOUBLE_CLICK FOR EVENT DOUBLE_CLICK OF CL_SALV_EVENTS_TABLE
           IMPORTING ROW COLUMN.
ENDCLASS.                    "lc_handle_events DEFINITION

************************************************************************
*         Class Implementation
************************************************************************
CLASS LC_HANDLE_EVENTS IMPLEMENTATION.
  METHOD ON_BUTTON_CLICK.
    PERFORM DISPLAY_DIR  USING E_SALV_FUNCTION.
  ENDMETHOD.                    "on_button_click
  METHOD ON_DOUBLE_CLICK.
    PERFORM DOUBLE_CLICK USING ROW COLUMN.
  ENDMETHOD.                    "on_double_click
ENDCLASS.                    "lc_handle_events IMPLEMENTATION

*--- C5056155 End   Of ALV ------------------------------------------*

START-OF-SELECTION.
*Authority-check for EarlyWatch
  AUTHORITY-CHECK OBJECT 'S_ADMI_FCD'
                  ID     'S_ADMI_FCD'
                  FIELD  'ST0R'.
  IF SY-SUBRC <> 0.
    MESSAGE S202 WITH 'S_ADMI_FCD'.
  ELSE.
    IMPORT P1 TO LIST_FILENAME
           P2 TO FILE_LIST-DIRNAME
           P3 TO FILE_LIST-NAME
      FROM MEMORY ID 'ZRSWATCH0'.
    IF SY-SUBRC = 0.
      LIST_FILE_ONLY = 'X'.
      PERFORM SHOW_FILE.
    ELSE.
      PERFORM MAIN.
    ENDIF.
  ENDIF.

*--- C5056155 Start of ALV -------------------------------------------*
END-OF-SELECTION.

  IF LIST_FILE_ONLY = ' '.
    PERFORM DISPLAY_FULLSCREEN_GRID.
  ENDIF.
*--- C5056155 Start of ALV -------------------------------------------*

*---------------------------------------------------------------------*
*       FORM MAIN                                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM MAIN.
*-- C5056155 Start of ALV Code ---------------------------------------*
  SET TITLEBAR '000'.
*  SET PF-STATUS 'L000'.
*-- C5056155 Start of ALV Code ---------------------------------------*

* prepare time zone correction.
  CALL 'C_GET_TIMEZONE' ID 'NAME' FIELD TIMEZONE_NAME
                        ID 'SEC'  FIELD TIMEZONE_SEC.

  TIMEZONE_SEC = 0 - SY-TZONE.
  IF SY-DAYST = 'X'.
    SUBTRACT 3600 FROM TIMEZONE_SEC.
  ENDIF.

* Get DB home
  IF SY-DBSYS(3) = 'ADA'.
    PERFORM WRITE_DB_HOME.
  ENDIF.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_ATRA'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_ATRA'           TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_BINARY'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_BINARY'         TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory $DIR_CCMS
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_CCMS'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_CCMS'           TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_CT_LOGGING'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_CT_LOGGING'     TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_CT_RUN'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_CT_RUN'         TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_DATA'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.


  MOVE: 'DIR_DATA'           TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* Get DB home
  IF SY-DBSYS(3) = 'DB6'.
    PERFORM WRITE_DB_HOME.
  ENDIF.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_DBMS'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_DBMS'           TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_EXECUTABLE'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_EXECUTABLE'     TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_EXE_ROOT'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_EXE_ROOT'       TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

*get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_GEN'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_GEN'            TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_GEN_ROOT'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_GEN_ROOT'       TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_GLOBAL'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  GLOBALDIRECTORY = SEARCHPOINTS-DIRNAME.
  MOVE: 'DIR_GLOBAL'         TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_GRAPH_EXE'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_GRAPH_EXE'      TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_GRAPH_LIB'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_GRAPH_LIB'      TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_HOME'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_HOME'           TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* Get DB home
  IF SY-DBSYS(3) = 'INF'.
    PERFORM WRITE_DB_HOME.
  ENDIF.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_INSTALL'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_INSTALL'        TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_INSTANCE'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_INSTANCE'       TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_LIBRARY'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_LIBRARY'        TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_LOGGING'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_LOGGING'        TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the files written by the memory inspector
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_MEMORY_INSPECTOR'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_MEMORY_INSPECTOR' TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME   TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* Get DB home
  IF SY-DBSYS(3) = 'ORA'.
    PERFORM WRITE_DB_HOME.
  ENDIF.

*get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_PAGING'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_PAGING'         TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

*get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_PUT'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_PUT'            TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_PERF'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_PERF'           TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_PROFILE'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_PROFILE'        TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_PROTOKOLLS'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_PROTOKOLLS'     TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_REORG'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_REORG'          TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_ROLL'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_ROLL'           TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_RSYN'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_RSYN'           TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* calculate directory for saphostagent (no sapparam available...)
  IF ( SY-OPSYS(3) = 'WIN' ) OR ( SY-OPSYS(3) = 'Win' ).
    DATA: WINDIR_PATH(64),  PROGRAMFILES_PATH(64).
*   hoping that ProgramFiles is set in service user environment
    CALL 'C_GETENV' ID 'NAME'  FIELD 'ProgramFiles'
                    ID 'VALUE' FIELD PROGRAMFILES_PATH.

    IF PROGRAMFILES_PATH IS INITIAL.
*     %ProgramFiles% not available. guess from windir
      CALL 'C_GETENV' ID 'NAME'  FIELD 'windir'
                      ID 'VALUE' FIELD WINDIR_PATH.
*     e.g. S:\WINDOWS ==> S:\Program Files
      CONCATENATE WINDIR_PATH(3) 'Program Files' INTO PROGRAMFILES_PATH.
    ENDIF.

    CONCATENATE PROGRAMFILES_PATH '\SAP\hostctrl'
                                             INTO SEARCHPOINTS-DIRNAME.
  ELSE.
*   on UNIX, the path is hard coded
    SEARCHPOINTS-DIRNAME = '/usr/sap/hostctrl'.
  ENDIF.

  MOVE: 'DIR_SAPHOSTAGENT'           TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.


* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_SAPUSERS'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.
  IF SEARCHPOINTS-DIRNAME = '.'.
    IF SY-OPSYS = 'Windows NT'.
      SEARCHPOINTS-DIRNAME = '.\'.
    ELSE.
      SEARCHPOINTS-DIRNAME = './'.
    ENDIF.
  ENDIF.

  MOVE: 'DIR_SAPUSERS'       TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_SETUPS'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_SETUPS'         TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_SORTTMP'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_SORTTMP'        TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

*get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_SOURCE'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_SOURCE'         TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_TEMP'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_TEMP'           TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_TRANS'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_TRANS'          TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_TRFILES'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_TRFILES'        TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

* get name of directory with the error files
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_TRSUB'
                     ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.

  MOVE: 'DIR_TRSUB'          TO GS_OUTTAB-SAP_DIR,
        SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
  APPEND GS_OUTTAB TO GT_OUTTAB.
  CLEAR GS_OUTTAB.

  CLEAR SEARCHPOINTS-DIRNAME.
*  get the name of the current server.
  CALL 'C_SAPGPARAM' ID 'NAME' FIELD 'rdisp/myname'
                     ID 'VALUE' FIELD MY_NAME.

  CLEAR ISEARCHPOINTS.  REFRESH ISEARCHPOINTS.
* get the name and aliases of ALL userdefined directories
  SELECT * FROM USER_DIR INTO ISEARCHPOINTS
    WHERE SVRNAME = MY_NAME.
    APPEND ISEARCHPOINTS.
  ENDSELECT.

  SELECT * FROM USER_DIR INTO ISEARCHPOINTS
    WHERE SVRNAME = ALL_SERVER.
    APPEND ISEARCHPOINTS.
  ENDSELECT.

  LOOP AT ISEARCHPOINTS.
    MOVE-CORRESPONDING ISEARCHPOINTS TO SEARCHPOINTS.

    MOVE: ISEARCHPOINTS-ALIASS TO GS_OUTTAB-SAP_DIR,
          SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
    APPEND GS_OUTTAB TO GT_OUTTAB.
    CLEAR GS_OUTTAB.
    CLEAR SEARCHPOINTS-DIRNAME.
  ENDLOOP.


  LOOP AT GT_OUTTAB INTO GS_OUTTAB.

    CHECK NOT  GS_OUTTAB-SAP_DIR CS 'CHEQUES'.
*if SAP_DIR

    DELETE GT_OUTTAB INDEX SY-TABIX.

  ENDLOOP.

ENDFORM.                               "main.

*EJECT
*
*--- C5056155 Start Of ALV Code --------------------------------------*
*AT LINE-SELECTION.
**=================
*
**REAK-POINT.
**here we go
*  CASE sy-pfkey.
*    WHEN 'L000'.
*      PERFORM get_directory.
*    WHEN 'L100'.
*      fcode = 'PICK'.
*      PERFORM user_input.
*  ENDCASE.
*
*AT USER-COMMAND.
**===============
*
**reak-point.
**here we go
**added code here to facilatate administrator to add/delete
**directories
*  fcode = sy-ucomm.
*  CASE sy-pfkey.
*    WHEN 'L000'.
*      IF fcode = 'DISP'.
*        PERFORM get_directory.
*      ELSEIF fcode = 'CONF'.
*        PERFORM configuration USING searchpoints-dirname.
*        PERFORM refresh_main_list.
*      ENDIF.
*
*    WHEN 'L100'.
*      fcode = sy-ucomm.
*      PERFORM user_input.
*  ENDCASE.


*---------------------------------------------------------------------*
*       FORM GET_DIRECTORY                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM GET_DIRECTORY.
*--- C5056155 Start Of Comments --------------------------------------*
*  SET PF-STATUS 'L100'.
  SET TITLEBAR '100'.
*--- C5056155 End   Of Comments --------------------------------------*
  REFRESH FILE_LIST.
  REFRESH SEARCHPOINTS.

*---C5056155 Start of ALV -------------------------------------------*

  IF G_DIR_FLAG = 1.
    SEARCHPOINTS-DIRNAME = G_DIRNAME.
    G_DIR_FLAG = 0.
  ELSE.
    DATA : LS_OUTTAB LIKE LINE OF GT_OUTTAB.
    READ TABLE GT_OUTTAB INDEX GV_ROW INTO LS_OUTTAB.
    CLEAR GV_ROW.
    SEARCHPOINTS-DIRNAME = LS_OUTTAB-DIRNAME.
  ENDIF.

*-- C5056155 --- End of ALV  ---------------------------------------*
  SEARCHPOINTS-SP_NAME = ALL_GEN    .
  SEARCHPOINTS-SP_CS   = NO_CS      .
  APPEND SEARCHPOINTS.
  LOOP AT SEARCHPOINTS.
    PERFORM FILL_FILE_LIST USING SEARCHPOINTS-DIRNAME
                                 SEARCHPOINTS-SP_NAME
                                 SEARCHPOINTS-SP_CS
                                 .
  ENDLOOP.

  SRT = 'N'.
  SORT FILE_LIST BY NAME ASCENDING MTIME DESCENDING.
  PERFORM SHOW_FILE_LIST.
* LEAVE TO LIST-PROCESSING.
ENDFORM.                               "GET_DIRECTORY.


*---------------------------------------------------------------------*
*       FORM USER_INPUT                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM USER_INPUT.
*----==========-
*                Verarbeite eine interaktive Benutzereingabe,
*
*                FCODE    : CUA-Code der Eingabe.
*                SY-PFKEY : Zustand des Programms und Kennzeichung
*                           dessen, was gerade auf dem Bildschirm ist.
*
  DATA: CURPAGE LIKE SY-CPAGE,
       LV_LINES TYPE I.
  CASE SY-PFKEY.
    WHEN 'L100_ALV'.
      CASE FCODE.
* ->                                                         L100 + DIRL
        WHEN 'DIRL'.
          PERFORM SHOW_DIR_LIST.
* ->                                                         L100 + ATTR
        WHEN 'ATTR'.
*-- C5056155 Start Of ALV Code     ----------------------------------*
*          IF h_list_index > 0.
          IF GV_ROW > 0.
*-- C5056155 End of ALV Code     ------------------------------------*
            PERFORM SHOW_FILE_DETAILS.
          ELSE.
            MESSAGE S208. " Cursor befand sich außerhalb der Liste
          ENDIF.
* ->                                                         L100 + DISP
        WHEN 'DISP'.
*-- C5056155 Start Of ALV Code -------------------------------------*
*          IF h_list_index > 0.
          IF GV_ROW > 0.
*            READ TABLE file_list INDEX h_list_index.
            CLEAR GS_OUTTAB1.
            READ TABLE GT_OUTTAB1 INTO GS_OUTTAB1 INDEX GV_ROW.
            READ TABLE FILE_LIST WITH KEY NAME = GS_OUTTAB1-NAME.
*-- C5056155 End   Of ALV Code -------------------------------------*

            IF FILE_LIST-DIRNAME <> GLOBALDIRECTORY.
              IF FILE_LIST-SUBRC = 5.
                FILE_LIST-TYPE(1) = 'D'.
              ELSE.
                PERFORM SHOW_FILE_CONTENTS.
              ENDIF.
              IF FILE_LIST-TYPE(1) = 'D' OR FILE_LIST-TYPE(1) = 'd'.
                CASE FILE_LIST-NAME.
                  WHEN '.'.            "stay where ever you are
                    EXIT.
                  WHEN '..'.           "go up
                    DESCRIBE TABLE DIRECTORY_STACK LINES SY-TFILL.
                    IF SY-TFILL > 1.
                      DELETE DIRECTORY_STACK INDEX SY-TFILL.
                      ADD -1 TO SY-TFILL.
                      READ TABLE DIRECTORY_STACK INDEX SY-TFILL.
                      G_DIRNAME = DIRECTORY_STACK.
                      G_DIR_FLAG = 1.
                      PERFORM GET_DIRECTORY.
* further down the current directory is pushed to the directory stack
* again, thus I remove it here
                      DESCRIBE TABLE DIRECTORY_STACK LINES SY-TFILL.
                      DELETE DIRECTORY_STACK INDEX SY-TFILL.
                      ADD -1 TO SY-TFILL.
                    ELSE.
                      SY-LSIND = 0.
                      REFRESH DIRECTORY_STACK.
                      GR_TABLE1->CLOSE_SCREEN( ).
                      EXIT.
                    ENDIF.
                  WHEN OTHERS.         "go down
                    STRLEN = STRLEN( SEARCHPOINTS-DIRNAME ).
                    IF STRLEN > 1.     "never go higher than root
                      CASE SY-OPSYS.
                        WHEN 'VMS'.    "nothing
                        WHEN 'Windows NT'.
                          WRITE '\' TO SEARCHPOINTS-DIRNAME+STRLEN.
                          FILE_SEPARATOR = '\'.
                          STRLEN = STRLEN + 1.
                        WHEN OTHERS.   "UNIX
                          WRITE '/' TO SEARCHPOINTS-DIRNAME+STRLEN.
                          FILE_SEPARATOR = '/'.
                          STRLEN = STRLEN + 1.
                      ENDCASE.
                    ENDIF.
                    WRITE FILE_LIST-NAME TO SEARCHPOINTS-DIRNAME+STRLEN.
                ENDCASE.
*-- C5056155 Start Of ALV Code ---------------------------------------*
                MOVE: SEARCHPOINTS-DIRNAME TO G_DIRNAME.
                G_DIR_FLAG = 1.
                DIRECTORY_STACK-NAME = SEARCHPOINTS-DIRNAME.
                APPEND DIRECTORY_STACK.
                PERFORM GET_DIRECTORY. "here we go again
                GR_TABLE1->CLOSE_SCREEN( ).
                GV_FLAG = 0.
                PERFORM SHOW_FILE_LIST_GRID USING SEARCHPOINTS-DIRNAME.
*-- C5056155 End   Of ALV Code ---------------------------------------*
              ELSE.
*                leave to list-processing.
                MODIFY CURRENT LINE
                 FIELD VALUE FILE_LIST-SEEN FROM SAP_YES
                             FILE_LIST-CHANGED FROM SAP_NO.
*           MOVE SAP_YES TO SY-LISEL+2(1).
*           MOVE SAP_NO  TO SY-LISEL+4(1).
*           MODIFY LINE SY-CUROW OF CURRENT PAGE.
                MOVE SAP_YES TO FILE_LIST-SEEN.
                MOVE SAP_NO  TO FILE_LIST-CHANGED.
*-- C5056155 Start of ALV Code ----------------------------------**
*                MODIFY file_list INDEX h_list_index.
                DESCRIBE TABLE GT_OUT_DISP LINES LV_LINES.
                MODIFY  FILE_LIST TRANSPORTING SEEN CHANGED
                                  WHERE NAME = GS_OUTTAB1-NAME.
                MOVE: FILE_LIST-SEEN    TO GS_OUTTAB1-SEEN,
                      FILE_LIST-CHANGED TO GS_OUTTAB1-CHANGED.
                MODIFY GT_OUTTAB1 FROM GS_OUTTAB1 INDEX GV_ROW.
                GR_TABLE1->REFRESH( ).
*-- C5056155 End   of ALV Code ----------------------------------**
              ENDIF.
            ENDIF.
          ELSE.
            MESSAGE S208. " Cursor befand sich außerhalb der Liste
          ENDIF.
* ->                                                         L100 + UPDA
        WHEN 'UPDA'.
          PERFORM UPDATE_FILE_LIST.
          CURPAGE = SY-CPAGE.
          PERFORM SHOW_FILE_LIST.
*         SCROLL LIST INDEX sy-lsind TO PAGE curpage.
          GR_TABLE1->REFRESH( REFRESH_MODE = 2 ).
          GR_TABLE1->DISPLAY( ).
* ->                                                         L100 + NAME
        WHEN 'NAME'.
          SRT = 'N'.
          SORT FILE_LIST BY NAME ASCENDING MTIME DESCENDING.
          PERFORM SHOW_FILE_LIST.
* ->                                                         L100 + TIME
        WHEN 'TIME'.
          SRT = 'T'.
          SORT FILE_LIST BY MTIME DESCENDING NAME ASCENDING.
          PERFORM SHOW_FILE_LIST.
      ENDCASE.
      CLEAR H_LIST_INDEX.
    WHEN 'L200'.
      CASE FCODE.
* ->                                                         L200 + ATTR
        WHEN 'ATTR'.
          PERFORM SHOW_FILE_DETAILS.
* ->                                                         L200 + DIRL
        WHEN 'DIRL'.
          PERFORM SHOW_DIR_LIST.
      ENDCASE.
  ENDCASE.
ENDFORM.                    "USER_INPUT


*EJECT
FORM FILL_FILE_LIST USING A_DIR_NAME A_GENERIC_NAME A_MUST_CS.
  " Routine von M. Mittelstein
******************************************************************CAS***
* Es wird eine Liste von Dateinamen in die Tabelle FILE_LIST gelesen.
*
* A_DIR_NAME ....... directory name
* A_GENERIC_NAME ... generic filename (may end with *)
* A_MUST_CS ........ a contains pattern for legal filenames  OR NO_CS
*

  DATA: ERRCNT(2) TYPE P VALUE 0.
  IF A_DIR_NAME IS INITIAL.
    MESSAGE E220.     " 'Place cursor on valid line !'.
  ENDIF.

  CALL 'C_DIR_READ_FINISH'             " just to be sure
      ID 'ERRNO'  FIELD FILE_LIST-ERRNO
      ID 'ERRMSG' FIELD FILE_LIST-ERRMSG.

  CALL 'C_DIR_READ_START' ID 'DIR'    FIELD A_DIR_NAME
                          ID 'FILE'   FIELD A_GENERIC_NAME
                          ID 'ERRNO'  FIELD FILE-ERRNO
                          ID 'ERRMSG' FIELD FILE-ERRMSG.
  IF SY-SUBRC <> 0.
*   message i204 with sy-subrc 'C_DIR_READ_START'
*                     ' ' a_dir_name.
*   message i204 with sy-subrc 'C_DIR_READ_START...'
*                    file-errno file-errmsg.
    MESSAGE E204 WITH FILE_LIST-ERRMSG FILE-ERRMSG.
  ENDIF.

  DO.
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
    FILE-DIRNAME = A_DIR_NAME.
    MOVE SY-SUBRC TO FILE-SUBRC.
    IF SY-SUBRC = 5.
      SY-SUBRC = 0.
    ENDIF.
    CASE SY-SUBRC.
      WHEN 0.
        CLEAR: FILE-ERRNO, FILE-ERRMSG.
        CASE FILE-TYPE(1).
          WHEN 'F'.                    " normal file.
            PERFORM FILENAME_USEABLE USING FILE-NAME FILE-USEABLE.
          WHEN 'f'.                    " normal file.
            PERFORM FILENAME_USEABLE USING FILE-NAME FILE-USEABLE.
          WHEN OTHERS. " directory, device, fifo, socket,...
            MOVE SAP_NO  TO FILE-USEABLE.
        ENDCASE.
        IF FILE-LEN = 0.
          MOVE SAP_NO TO FILE-USEABLE.
        ENDIF.
      WHEN 1.
        EXIT.
      WHEN OTHERS.                     " SY-SUBRC >= 2
        ADD 1 TO ERRCNT.
        IF ERRCNT > 10.
          EXIT.
        ENDIF.
        MOVE SAP_NO TO FILE-USEABLE.
    ENDCASE.
    PERFORM P6_TO_DATE_TIME_TZ(RSTR0400) USING FILE-MTIME
                                               FILE-MOD_TIME
                                               FILE-MOD_DATE.
*   * Does the filename contains the requested pattern?
*   * Then store it, else forget it.
    IF A_MUST_CS = NO_CS.
      MOVE-CORRESPONDING FILE TO FILE_LIST.
      APPEND FILE_LIST.
    ELSE.
      IF FILE-NAME CS A_MUST_CS.
        MOVE-CORRESPONDING FILE TO FILE_LIST.
        APPEND FILE_LIST.
      ENDIF.
    ENDIF.
  ENDDO.

  CALL 'C_DIR_READ_FINISH'
      ID 'ERRNO'  FIELD FILE_LIST-ERRNO
      ID 'ERRMSG' FIELD FILE_LIST-ERRMSG.
  IF SY-SUBRC <> 0.
    WRITE: / 'C_DIR_READ_FINISH', 'SUBRC', SY-SUBRC.
  ENDIF.
  IF SRT = 'T'.
    SORT FILE_LIST BY MTIME DESCENDING NAME ASCENDING.
  ELSE.
    SORT FILE_LIST BY NAME ASCENDING MTIME DESCENDING.
  ENDIF.

ENDFORM.                    "FILL_FILE_LIST

*EJECT
FORM UPDATE_FILE_LIST.                 " Routine von M. Mittelstein
************************************************************************
* Die Liste der Fehlerprotokolldateien wird aufgefrischt.
*
*

  DATA: DISAPPEARED(2) TYPE P.

  CLEAR DISAPPEARED.

* First loop:
* Look for each file I know of, wether it disappeared.
  LOOP AT FILE_LIST.
    CALL 'C_DIR_READ_START' ID 'DIR'    FIELD FILE_LIST-DIRNAME
                            ID 'FILE'   FIELD FILE_LIST-NAME
                            ID 'ERRNO'  FIELD FILE-ERRNO
                            ID 'ERRMSG' FIELD FILE-ERRMSG.
    IF SY-SUBRC <> 0.
      MESSAGE I204 WITH SY-SUBRC 'C_DIR_READ_START'
                        ' ' FILE_LIST-NAME.
      MESSAGE I204 WITH SY-SUBRC 'C_DIR_READ_START...'
                        FILE-ERRNO FILE-ERRMSG.
    ENDIF.
    CLEAR FILE.
    CALL 'C_DIR_READ_NEXT'.
    MOVE SY-SUBRC TO FILE-SUBRC.
    IF SY-SUBRC <> 0.
      IF SY-SUBRC = 1.                 " File is not in directory
        DELETE FILE_LIST.
        ADD 1 TO DISAPPEARED.
      ELSE.
        IF SY-SUBRC <> FILE_LIST-SUBRC.
          MESSAGE I204 WITH SY-SUBRC 'C_DIR_READ_NEXT' ' '
                            FILE_LIST-NAME.
          "ELSE same error again.
        ENDIF.
      ENDIF.
    ENDIF.
    CALL 'C_DIR_READ_NEXT' .
    IF SY-SUBRC <> 1.                  " Should be: no more files...
      MESSAGE I204 WITH SY-SUBRC 'C_DIR_READ_NEXT'
                        FILE_LIST-NAME '2nd_read'.
    ENDIF.
    CALL 'C_DIR_READ_FINISH'
      ID 'ERRNO'  FIELD FILE-ERRNO
      ID 'ERRMSG' FIELD FILE-ERRMSG.
    IF SY-SUBRC <> 0.
      MESSAGE I204 WITH SY-SUBRC 'C_DIR_READ_FINISH'
                        FILE-ERRNO FILE-ERRMSG.
    ENDIF.
  ENDLOOP.
  IF DISAPPEARED > 0.
    MESSAGE I207 WITH DISAPPEARED.
  ENDIF.

* Second loop:
* Look through the directory, wether there are new file or
* a file has changed.

  LOOP AT SEARCHPOINTS.
    PERFORM SECOND_LOOP USING SEARCHPOINTS-DIRNAME
                              SEARCHPOINTS-SP_NAME
                              SEARCHPOINTS-SP_CS
                              .
  ENDLOOP.

  IF SRT = 'T'.
    SORT FILE_LIST BY MTIME DESCENDING NAME ASCENDING.
  ELSE.
    SORT FILE_LIST BY NAME ASCENDING MTIME DESCENDING.
  ENDIF.

ENDFORM.                    "UPDATE_FILE_LIST

*EJECT
FORM SECOND_LOOP USING A_DIR_NAME A_GENERIC_NAME A_MUST_CS.
******************************************************************CAS***
* Unterroutine zu UPDATE_FILE_LIST.
*
* A_DIR_NAME ....... directory name
* A_GENERIC_NAME ... generic filename (may end with *)
* A_MUST_CS ........ a contains pattern for legal filenames  OR NO_CS
*

  DATA: ERRCNT(2) TYPE P.

  CLEAR ERRCNT.

  CALL 'C_DIR_READ_START' ID 'DIR'    FIELD A_DIR_NAME
                          ID 'FILE'   FIELD A_GENERIC_NAME
                          ID 'ERRNO'  FIELD FILE-ERRNO
                          ID 'ERRMSG' FIELD FILE-ERRMSG.
  IF SY-SUBRC <> 0.
    MESSAGE I204 WITH SY-SUBRC 'C_DIR_READ_START'
                      ' ' A_DIR_NAME.
    MESSAGE I204 WITH SY-SUBRC 'C_DIR_READ_START...'
                      FILE-ERRNO FILE-ERRMSG.
  ENDIF.

  DO.
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
    FILE-DIRNAME = A_DIR_NAME.
    MOVE SY-SUBRC TO    FILE-SUBRC.
    IF FILE-SUBRC = 0.
      CLEAR: FILE-ERRNO, FILE-ERRMSG.
    ELSEIF FILE-SUBRC = 1.
      EXIT.
    ENDIF.
    CLEAR FILE_LIST.
    MOVE-CORRESPONDING FILE TO FILE_KEY.
    READ TABLE FILE_LIST WITH KEY FILE_KEY.
    IF SY-SUBRC = 0.                   " File was already in FILE_LIST.
      IF FILE_LIST-TYPE  <> FILE-TYPE  OR
         FILE_LIST-LEN   <> FILE-LEN   OR
         FILE_LIST-OWNER <> FILE-OWNER OR
         FILE_LIST-MTIME <> FILE-MTIME OR
         FILE_LIST-MODE  <> FILE-MODE  OR
         FILE_LIST-ERRNO <> FILE-ERRNO.
        PERFORM P6_TO_DATE_TIME_TZ(RSTR0400) USING FILE-MTIME
                                                   FILE-MOD_TIME
                                                   FILE-MOD_DATE.
        MOVE FILE_LIST-USEABLE TO FILE-USEABLE.
        MOVE FILE_LIST-SEEN    TO FILE-SEEN.
        MOVE-CORRESPONDING FILE TO FILE_LIST.
        MOVE SAP_YES TO FILE_LIST-CHANGED.
        MODIFY FILE_LIST INDEX SY-TABIX.
      ENDIF.
    ELSE.                              " File ist not yet in FILE_LIST.
      IF FILE-SUBRC <> 0.
        ADD 1 TO ERRCNT.
        IF ERRCNT > 10.
          EXIT.
        ENDIF.
        IF FILE-SUBRC = 5.
          MOVE: '???' TO FILE-TYPE,
                '???' TO FILE-OWNER,
                '???' TO FILE-MODE.
        ELSE.
          MESSAGE I204 WITH FILE-SUBRC 'C_DIR_READ_NEXT'
                            ' ' FILE-NAME.
        ENDIF.
        MOVE SAP_NO TO FILE-USEABLE.
      ELSE.
*       PERFORM filename_useable USING file-name file-useable.
        CLEAR: FILE-ERRNO, FILE-ERRMSG.
        CASE FILE-TYPE(1).
          WHEN 'F'.                    " normal file.
            PERFORM FILENAME_USEABLE USING FILE-NAME FILE-USEABLE.
          WHEN 'f'.                    " normal file.
            PERFORM FILENAME_USEABLE USING FILE-NAME FILE-USEABLE.
          WHEN OTHERS. " directory, device, fifo, socket,...
            MOVE SAP_NO  TO FILE-USEABLE.
        ENDCASE.
      ENDIF.
      IF FILE-LEN = 0.
        MOVE SAP_NO TO FILE-USEABLE.
      ENDIF.
      PERFORM P6_TO_DATE_TIME_TZ(RSTR0400) USING FILE-MTIME
                                                 FILE-MOD_TIME
                                                 FILE-MOD_DATE.
*     * Does the filename contains the requested pattern?
*     * Then store it, else forget it.
      IF A_MUST_CS = NO_CS.
        MOVE-CORRESPONDING FILE TO FILE_LIST.
        APPEND FILE_LIST.
      ELSE.
        IF FILE-NAME CS A_MUST_CS.
          MOVE-CORRESPONDING FILE TO FILE_LIST.
          APPEND FILE_LIST.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDDO.

  CALL 'C_DIR_READ_FINISH'
    ID 'ERRNO'  FIELD FILE-ERRNO
    ID 'ERRMSG' FIELD FILE-ERRMSG.
  IF SY-SUBRC <> 0.
    WRITE: / 'C_DIR_READ_FINISH', 'SUBRC', SY-SUBRC.
  ENDIF.

ENDFORM.                               " SECOND_LOOP

*EJECT
FORM SHOW_FILE_LIST.
  DATA: CFLAG(1) VALUE 'X'.
******************************************************************CAS***
* Liste der Fehlerprotokolldateien ausgeben.
*-- C5056155 -Start Of ALV Code ---------------------------------------*
*  NEW-PAGE NO-TITLE.
  REFRESH GT_OUTTAB1.
*-- C5056155 -End   Of ALV Code ---------------------------------------*
  SY-LSIND = 1.
  LOOP AT FILE_LIST.
*---C5056155 Start of ALV -----------------------------------------*
*    PERFORM flip_flop(rsora000) USING cflag.
*    WRITE: / file_list-useable,
*             file_list-seen,
*             file_list-changed,
*             file_list-name(30),
*             file_list-len,
*             file_list-owner,
*             file_list-mod_date DD/MM/YYYY,
*             file_list-mod_time.
    MOVE : FILE_LIST-USEABLE  TO GS_OUTTAB1-USEABLE,
           FILE_LIST-SEEN     TO GS_OUTTAB1-SEEN,
           FILE_LIST-CHANGED  TO GS_OUTTAB1-CHANGED,
           FILE_LIST-NAME     TO GS_OUTTAB1-NAME,
           FILE_LIST-LEN      TO GS_OUTTAB1-LEN,
           FILE_LIST-OWNER    TO GS_OUTTAB1-OWNER,
           FILE_LIST-MOD_DATE TO GS_OUTTAB1-MOD_DATE.
    REPLACE ALL OCCURRENCES OF ':' IN FILE_LIST-MOD_TIME WITH ''.
    WRITE FILE_LIST-MOD_TIME TO GS_OUTTAB1-MOD_TIME.
    APPEND GS_OUTTAB1 TO GT_OUTTAB1.
*---C5056155 End   of ALV -----------------------------------------*
    H_LIST_INDEX = SY-TABIX.
*---C5056155 Start of ALV -----------------------------------------*
*    HIDE: h_list_index. " , FILE_LIST-DIRNAME, FILE_LIST-NAME.
*---C5056155 End   of ALV -----------------------------------------*
  ENDLOOP.
  CLEAR: H_LIST_INDEX, FILE_LIST-DIRNAME, FILE_LIST-NAME.

ENDFORM.                    "SHOW_FILE_LIST

*EJECT
FORM SHOW_FILE_CONTENTS.
******************************************************************CAS***
* Inhalt einer Fehlerprotokolldatei
*
* FILE_LIST-header has the data

  DATA: BUFFER(510) TYPE C,
        PATH_NAME   TYPE DIRNAME_AL11,
        STNGLEN TYPE I.

  DATA: AUTH_CHECK_FILENAME LIKE AUTHB-FILENAME.

*--- C5056155 --Start Of ALV Code ----------------------------------**
*  SET PF-STATUS 'L200'.
*  SET TITLEBAR '200'.
*  LEAVE TO LIST-PROCESSING.
*  REFRESH gt_out_disp.
*--- C5056155 End    Of ALV Code ----------------------------------**

  IF FILE_LIST-USEABLE = SAP_YES.
    PATH_NAME        = FILE_LIST-DIRNAME.
    STRLEN = STRLEN( SEARCHPOINTS-DIRNAME ).
    STNGLEN = STRLEN + 1.
    IF STRLEN > 1.                     "never go higher than root
      IF SY-OPSYS <> 'VMS'.
        PATH_NAME+STRLEN(1)  = '/'.
*        PATH_NAME+75(1)  = '/'.
      ENDIF.
    ELSEIF STRLEN = 1.
      PATH_NAME+2(1) = '/'.
      CONDENSE PATH_NAME NO-GAPS.
*      stnglen = stnglen + 1.
    ENDIF.
*    PATH_NAME+76(75) = FILE_LIST-NAME.
    PATH_NAME+STNGLEN(MAX_LEN_OF_FILENAME) = FILE_LIST-NAME.
*    CONDENSE PATH_NAME NO-GAPS.


* here we have to do an authority check,
* because OPEN_DATASET raises a ABAP-DUMP
* in case of no authorization
    AUTH_CHECK_FILENAME = PATH_NAME.
    CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
      EXPORTING
*       PROGRAM          =
        ACTIVITY               = 'READ'
        FILENAME               = AUTH_CHECK_FILENAME
      EXCEPTIONS
       NO_AUTHORITY           = 1
       ACTIVITY_UNKNOWN       = 2
       OTHERS                 = 3.

    IF SY-SUBRC = 1.
      MESSAGE ID '00' TYPE 'E' NUMBER '149'
              WITH PATH_NAME.

    ELSE.
      EXPORT P1 = PATH_NAME
             P2 = FILE_LIST-DIRNAME
             P3 = FILE_LIST-NAME
          TO MEMORY ID 'RSWATCH0'.
      SUBMIT RSWATCH0 AND RETURN.

*      OPEN DATASET path_name IN TEXT MODE ENCODING DEFAULT FOR INPUT
*                             IGNORING CONVERSION ERRORS.
*     IF sy-subrc = 0.
*        TRY.
*          DO.
*            READ DATASET path_name INTO buffer.
*            IF sy-subrc <> 0.
*              EXIT.
*            ELSE.
*             IF buffer <> space."added to display blank lines in a file
*                NEW-LINE.
*                WRITE AT 1(510) buffer.
*              ELSE.
*                SKIP.
*              ENDIF.
*            ENDIF.
*          ENDDO.
*        CATCH cx_sy_conversion_error.
*          WRITE: / ' '.
*          MESSAGE S333 WITH TEXT-023.
*        ENDTRY.
*       CLOSE DATASET path_name.
*      ELSE.
*        WRITE: / ' '.
*        MESSAGE S333 WITH TEXT-018.
*      ENDIF.
    ENDIF.
  ELSE.
    IF NOT ( FILE_LIST-TYPE(1) = 'D' OR FILE_LIST-TYPE(1) = 'd' ).
      MESSAGE S333 WITH TEXT-018.
    ENDIF.
  ENDIF.

ENDFORM.                    "SHOW_FILE_CONTENTS

*EJECT
FORM SHOW_FILE_DETAILS.
******************************************************************CAS***
* Details zu einer Fehlerprotokolldatei

*-- C5056155 Start Of ALV Code ---------------------------------------*
*  SET PF-STATUS 'L300'.
  SET TITLEBAR '300'.
*  READ TABLE file_list INDEX h_list_index.
*  WRITE: / 'Directory......'(019), file_list-dirname,
*         / 'Name...........'(001), file_list-name,
*         / 'Typ............'(002), file_list-type,
*         / 'Länge..........'(003), file_list-len,
*         / 'Erzeuger.......'(004), file_list-owner,
*         / 'Letzte Änderung'(005), file_list-mod_date DD/MM/YYYY,
*                                    file_list-mod_time,
*         / 'Mode...........'(006), file_list-mode,
*         / 'Verwendbar.....'(007), file_list-useable,
*         / 'Fehlernummer...'(008), file_list-errno,
*         / 'Fehlermeldung..'(009), file_list-errmsg.

  REFRESH GT_OUT_ATTRI.
  CLEAR GS_OUTTAB1.
  READ TABLE GT_OUTTAB1 INTO GS_OUTTAB1 INDEX GV_ROW.
  READ TABLE FILE_LIST WITH KEY NAME = GS_OUTTAB1-NAME.
  CLEAR: GT_OUT_ATTRI,GS_OUT_ATTRI.

  MOVE: TEXT-019          TO GS_OUT_ATTRI-PROP,
        FILE_LIST-DIRNAME TO GS_OUT_ATTRI-VALUE.
  APPEND GS_OUT_ATTRI TO GT_OUT_ATTRI.
  CLEAR GS_OUT_ATTRI.

  MOVE: TEXT-001       TO GS_OUT_ATTRI-PROP,
        FILE_LIST-NAME TO GS_OUT_ATTRI-VALUE.
  APPEND GS_OUT_ATTRI TO GT_OUT_ATTRI.
  CLEAR GS_OUT_ATTRI.

  MOVE: TEXT-002       TO GS_OUT_ATTRI-PROP,
        FILE_LIST-TYPE TO GS_OUT_ATTRI-VALUE.
  APPEND GS_OUT_ATTRI TO GT_OUT_ATTRI.
  CLEAR GS_OUT_ATTRI.

  MOVE: TEXT-003      TO GS_OUT_ATTRI-PROP,
        FILE_LIST-LEN TO GS_OUT_ATTRI-VALUE.
  CONDENSE GS_OUT_ATTRI-VALUE.
  APPEND GS_OUT_ATTRI TO GT_OUT_ATTRI.
  CLEAR GS_OUT_ATTRI.

  MOVE: TEXT-004        TO GS_OUT_ATTRI-PROP,
        FILE_LIST-OWNER TO GS_OUT_ATTRI-VALUE.
  APPEND GS_OUT_ATTRI TO GT_OUT_ATTRI.
  CLEAR GS_OUT_ATTRI.

  MOVE: TEXT-005 TO GS_OUT_ATTRI-PROP.
  WRITE FILE_LIST-MOD_DATE TO GS_OUT_ATTRI-VALUE.
  MOVE: FILE_LIST-MOD_TIME TO GS_OUT_ATTRI-VALUE+12.
  APPEND GS_OUT_ATTRI TO GT_OUT_ATTRI.
  CLEAR GS_OUT_ATTRI.

  MOVE: TEXT-006       TO GS_OUT_ATTRI-PROP,
        FILE_LIST-MODE TO GS_OUT_ATTRI-VALUE.
  APPEND GS_OUT_ATTRI TO GT_OUT_ATTRI.
  CLEAR GS_OUT_ATTRI.

  MOVE: TEXT-007 TO GS_OUT_ATTRI-PROP.
  WRITE FILE_LIST-USEABLE AS CHECKBOX TO GS_OUT_ATTRI-VALUE.
  APPEND GS_OUT_ATTRI TO GT_OUT_ATTRI.
  CLEAR GS_OUT_ATTRI.

  MOVE: TEXT-008        TO GS_OUT_ATTRI-PROP,
        FILE_LIST-ERRNO TO GS_OUT_ATTRI-VALUE.
  APPEND GS_OUT_ATTRI TO GT_OUT_ATTRI.
  CLEAR GS_OUT_ATTRI.

  MOVE: TEXT-009         TO GS_OUT_ATTRI-PROP,
        FILE_LIST-ERRMSG TO GS_OUT_ATTRI-VALUE.
  APPEND GS_OUT_ATTRI TO GT_OUT_ATTRI.

  PERFORM DISP_ATTRI_GRID USING GT_OUT_ATTRI.
*-- C5056155 End   Of ALV Code ---------------------------------------*

ENDFORM.                    "SHOW_FILE_DETAILS

**EJECT
**-- C5056155 Start Of ALV Code ---------------------------------------*

TOP-OF-PAGE.
*******************************************************************CAS**
*
** Aufruf der Routine, die die Überschriften ausgibt.
*   PERFORM top_of_page.
  IF LIST_FILE_ONLY = 'X'.
    PERFORM SHOW_FILENAME.
  ENDIF.


******************************************************************CAS***

*EJECT
FORM SHOW_DIR_LIST.
*----=============-
**C5056155 Start of ALV -------------------------**
  DATA : LR_COLUMNS TYPE REF TO CL_SALV_COLUMNS,
         LR_COLUMN  TYPE REF TO CL_SALV_COLUMN.
  REFRESH GT_OUT_DIR.
*  SET PF-STATUS 'L400'.
  SET TITLEBAR '400'.
**C5056155 End   of ALV -------------------------**

  LOOP AT SEARCHPOINTS.
**C5056155 Start of ALV -------------------------**
*    WRITE: /(20) searchpoints-sp_name
*         , (10)  searchpoints-sp_cs
*         ,       searchpoints-dirname
*
    CLEAR GS_OUT_DIR.
    MOVE: SEARCHPOINTS-SP_NAME  TO GS_OUT_DIR-SP_NAME,
          SEARCHPOINTS-SP_CS    TO GS_OUT_DIR-SP_CS,
          SEARCHPOINTS-DIRNAME  TO GS_OUT_DIR-DIRNAME.
    APPEND GS_OUT_DIR TO GT_OUT_DIR.
**C5056155 End   of ALV -------------------------**
  ENDLOOP.
*-- C5056155 Start Of ALV Code ------------------**
  PERFORM SHOW_DIR_LIST_ALV.
*-- C5056155 End   Of ALV Code ------------------**
ENDFORM.                    "SHOW_DIR_LIST

*EJECT
FORM FILENAME_USEABLE USING A_NAME A_USEABLE.
*----================------------------------
  DATA L_NAME(75).

  L_NAME = A_NAME.
  IF L_NAME(4) = 'core'.
    A_USEABLE = SAP_NO.
  ELSE.
    A_USEABLE = SAP_YES.
  ENDIF.
ENDFORM.                    "FILENAME_USEABLE

* ---------------------- end of RSTR0006 ----------------------------- *
*&---------------------------------------------------------------------*
*&      Form  WRITE_DB_HOME
*&---------------------------------------------------------------------*
*       Write DB home directory
*----------------------------------------------------------------------*
*       no parameters
*----------------------------------------------------------------------*
FORM WRITE_DB_HOME.
  CLEAR SEARCHPOINTS-DIRNAME.
  CASE SY-DBSYS(3).
    WHEN 'ORA'.
      CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_ORAHOME'
                         ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.
*--- C5056155 Start of ALV -------------------------------*
*      PERFORM flip_flop(rsora000) USING cflag.
*      WRITE: / 'DIR_ORAHOME',       30 searchpoints-dirname.
      MOVE: 'DIR_ORAHOME'        TO GS_OUTTAB-SAP_DIR,
            SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
      APPEND GS_OUTTAB TO GT_OUTTAB.
      CLEAR GS_OUTTAB.
*--- C5056155 End   of ALV -------------------------------*

    WHEN 'ADA'.
      CALL 'C_GETENV' ID 'NAME'  FIELD 'DBROOT'
                      ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.
*--- C5056155 Start of ALV -------------------------------*
*      PERFORM flip_flop(rsora000) USING cflag.
*      WRITE: / 'DIR_ADA_DBROOT',    30 searchpoints-dirname.
      MOVE: 'DIR_ADA_DBROOT'     TO GS_OUTTAB-SAP_DIR,
            SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
      APPEND GS_OUTTAB TO GT_OUTTAB.
      CLEAR GS_OUTTAB.
*--- C5056155 End   of ALV -------------------------------*
    WHEN 'INF'.
      CALL 'C_GETENV' ID 'NAME'  FIELD 'INFORMIXDIR'
                      ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.
*--- C5056155 Start of ALV -------------------------------*
*      PERFORM flip_flop(rsora000) USING cflag.
*      WRITE: / 'DIR_INF_INFORMIXDIR', 30 searchpoints-dirname.
      MOVE: 'DIR_INF_INFORMIXDIR' TO GS_OUTTAB-SAP_DIR,
            SEARCHPOINTS-DIRNAME  TO GS_OUTTAB-DIRNAME.
      APPEND GS_OUTTAB TO GT_OUTTAB.
      CLEAR GS_OUTTAB.
*--- C5056155 End   of ALV -------------------------------*
    WHEN 'DB6'.
      CALL 'C_GETENV' ID 'NAME'  FIELD 'INSTHOME'
                      ID 'VALUE' FIELD SEARCHPOINTS-DIRNAME.
      IF SY-SUBRC = 0.
*--- C5056155 Start of ALV -------------------------------*
*        PERFORM flip_flop(rsora000) USING cflag.
*        WRITE: / 'DIR_DB2_HOME',    30 searchpoints-dirname.
        MOVE: 'DIR_DB2_HOME'       TO GS_OUTTAB-SAP_DIR,
              SEARCHPOINTS-DIRNAME TO GS_OUTTAB-DIRNAME.
        APPEND GS_OUTTAB TO GT_OUTTAB.
        CLEAR GS_OUTTAB.
*--- C5056155 End   of ALV -------------------------------*
      ELSE.
        EXIT.
      ENDIF.
    WHEN OTHERS.
      EXIT.
  ENDCASE.
  HIDE SEARCHPOINTS-DIRNAME.
ENDFORM.                    " WRITE_DB_HOME

*  form to help user to configure user defined directories.
FORM CONFIGURATION USING A_DIR_NAME.
* check user authorization before entering the screen.
  AUTHORITY-CHECK OBJECT 'S_RZL_ADM' ID 'ACTVT' FIELD '01'.
  IF SY-SUBRC = 0.
    ADMIN_AUTH = 'X'.
    IF A_DIR_NAME <> ' '.
      A_DIRNAME = A_DIR_NAME.
    ENDIF.
    CALL SCREEN '0001'.
  ELSE.
    ADMIN_AUTH = ' '.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        TITEL = ' '
        TXT1  = 'You are not authorized to Configure the list'
        TXT2  = ' '
        TXT3  = ' '
        TXT4  = ' '.
  ENDIF.

ENDFORM.                    " CONFIGURATION

INCLUDE ZRSUSRDIR.
*INCLUDE rsusrdir.

*  form to refresh list of directories to reflect the changes made
FORM REFRESH_MAIN_LIST.
  LEAVE TO TRANSACTION 'AL11'.
ENDFORM.                    " REFRESH_MAIN_LIST

*-- C5056155 Start Of ALV Code -------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FULLSCREEN_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_FULLSCREEN_GRID .

*... §2 create an ALV table
*    §2.2 just create an instance and do not set LIST_DISPLAY for
*         displaying the data as a Fullscreen Grid
  DATA : IV_NAME TYPE C,
         LR_CONTENT TYPE REF TO CL_SALV_FORM_LAYOUT_GRID.
  DATA: LR_FUNCTIONS TYPE REF TO CL_SALV_FUNCTIONS_LIST.
  DATA: LR_COLUMNS TYPE REF TO CL_SALV_COLUMNS.
  DATA: LR_EVENTS TYPE REF TO CL_SALV_EVENTS_TABLE.
  DATA: LS_LAYOUT TYPE SALV_S_LAYOUT_INFO,
        LS_KEY    TYPE SALV_S_LAYOUT_KEY,
        LR_LAYOUT TYPE REF TO CL_SALV_LAYOUT.

  TRY.
      CL_SALV_TABLE=>FACTORY(
*        exporting
*          list_display = 'X'
        IMPORTING
          R_SALV_TABLE = GR_TABLE
        CHANGING
          T_TABLE      = GT_OUTTAB ).
    CATCH CX_SALV_MSG.
  ENDTRY.
*... §3 Functions
*... §3.1 activate ALV generic Functions
  LR_FUNCTIONS = GR_TABLE->GET_FUNCTIONS( ).
  LR_FUNCTIONS->SET_ALL( GC_TRUE ).

*... set the columns technical
  LR_COLUMNS = GR_TABLE->GET_COLUMNS( ).
*  lr_columns->set_optimize( gc_true ).
  PERFORM SET_COLUMNS_TECHNICAL USING LR_COLUMNS.
*... §3.2 include own functions by setting own status
  GR_TABLE->SET_SCREEN_STATUS(
  PFSTATUS      =  'L000_ALV'
  REPORT        =  G_REPID
  SET_FUNCTIONS = GR_TABLE->C_FUNCTIONS_ALL ).

*... §4 set layout
  LS_KEY-REPORT = SY-REPID.
  LR_LAYOUT = GR_TABLE->GET_LAYOUT( ).

*... §4.1 set the Layout Key
  LS_KEY-REPORT = G_REPID.
  LR_LAYOUT->SET_KEY( LS_KEY ).

*... §4.2 set usage of default Layouts

  LR_LAYOUT->SET_DEFAULT( ABAP_TRUE ).
  LR_LAYOUT->SET_SAVE_RESTRICTION( '3' ).

*... §6 register to the events of cl_salv_table
  LR_EVENTS = GR_TABLE->GET_EVENT( ).
  CREATE OBJECT GR_EVENTS.

*... §6.1 register to the event USER_COMMAND
  SET HANDLER GR_EVENTS->ON_BUTTON_CLICK FOR LR_EVENTS.
*... §6.4 register to the event DOUBLE_CLICK
  SET HANDLER GR_EVENTS->ON_DOUBLE_CLICK FOR LR_EVENTS.

*... set list title
  GV_PFKEY = 'L000_ALV'.
*--
  PERFORM CREATE_ALV_FORM_CONTENT_TOL USING
                                      'SAP-Directories'
                                      IV_NAME
                                      GR_TABLE.
*... §4 display the table
  GV_FLAG = 0.
  GR_TABLE->DISPLAY( ).
  SET TITLEBAR '000'.
ENDFORM.                    " DISPLAY_FULLSCREEN_GRID
*&---------------------------------------------------------------------*
*&      Form  set_columns_technical
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LR_COLUMNS  text
*----------------------------------------------------------------------*
FORM SET_COLUMNS_TECHNICAL USING IR_COLUMNS TYPE REF TO CL_SALV_COLUMNS.

  DATA: LR_COLUMN TYPE REF TO CL_SALV_COLUMN.
  TRY.
      LR_COLUMN = IR_COLUMNS->GET_COLUMN( 'SAP_DIR' ).
      LR_COLUMN->SET_VISIBLE( IF_SALV_C_BOOL_SAP=>TRUE ).
    CATCH CX_SALV_NOT_FOUND.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      LR_COLUMN = IR_COLUMNS->GET_COLUMN( 'DIRNAME' ).
      LR_COLUMN->SET_VISIBLE( IF_SALV_C_BOOL_SAP=>TRUE ).
    CATCH CX_SALV_NOT_FOUND.                            "#EC NO_HANDLER
  ENDTRY.

ENDFORM.                    " set_columns_technical
*&---------------------------------------------------------------------*
*&      Form  double_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ROW  text
*      -->P_COLUMN  text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK   USING I_ROW TYPE I
                 I_COLUMN TYPE LVC_FNAME.
  MOVE I_ROW TO GV_ROW.
  CASE SY-PFKEY.
    WHEN 'L000_ALV'.
      GV_FLAG = 0.
      PERFORM GET_DIRECTORY.
      REFRESH DIRECTORY_STACK.
      DIRECTORY_STACK-NAME = SEARCHPOINTS-DIRNAME.
      APPEND DIRECTORY_STACK.
      PERFORM SHOW_FILE_LIST_GRID  USING SEARCHPOINTS-DIRNAME.
    WHEN 'L100_ALV'.
      FCODE = 'DISP'.
      PERFORM USER_INPUT.
  ENDCASE.
ENDFORM.                    " double_click

*&---------------------------------------------------------------------*
*&      Form  display_dir
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DIR USING I_FUNCTION TYPE SALV_DE_FUNCTION.

  DATA: LR_SELECTIONS TYPE REF TO CL_SALV_SELECTIONS,
          LT_ROWS TYPE SALV_T_ROW,
          L_ROW TYPE I,
          L_ROW_STRING(5) TYPE C.

  CLEAR: LT_ROWS,GV_ROW.
*   read table gt_outtab into ls_outtab with key objct = ls_cell-value.
  FCODE = SY-UCOMM.
  CASE SY-PFKEY.
    WHEN 'L000_ALV'.
      GV_FLAG = 0.
      LR_SELECTIONS = GR_TABLE->GET_SELECTIONS( ).
*         set selection mode
      LR_SELECTIONS->SET_SELECTION_MODE(
      IF_SALV_C_SELECTION_MODE=>NONE ).
      LT_ROWS = LR_SELECTIONS->GET_SELECTED_ROWS( ).
      READ TABLE LT_ROWS INTO GV_ROW INDEX 1.
      IF FCODE = 'DISP'.
        PERFORM GET_DIRECTORY.
        PERFORM SHOW_FILE_LIST_GRID USING SEARCHPOINTS-DIRNAME.
      ELSEIF FCODE = 'CONF'.
        PERFORM CONFIGURATION USING SEARCHPOINTS-DIRNAME.
        PERFORM REFRESH_MAIN_LIST.
      ENDIF.

    WHEN 'L100_ALV'.
      FCODE = SY-UCOMM.
      LR_SELECTIONS = GR_TABLE1->GET_SELECTIONS( ).
*           set selection mode
      LR_SELECTIONS->SET_SELECTION_MODE(
      IF_SALV_C_SELECTION_MODE=>NONE ).
      LT_ROWS = LR_SELECTIONS->GET_SELECTED_ROWS( ).
      READ TABLE LT_ROWS INTO GV_ROW INDEX 1.
      PERFORM USER_INPUT.
  ENDCASE.

ENDFORM.                    " display_dir
*&---------------------------------------------------------------------*
*&      Form  SHOW_FILE_LIST_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SHOW_FILE_LIST_GRID USING IV_DIR TYPE C.

  DATA : IV_NAME TYPE C,
         LR_CONTENT TYPE REF TO CL_SALV_FORM_LAYOUT_GRID.

  DATA: LS_LAYOUT TYPE SALV_S_LAYOUT_INFO,
        LS_KEY    TYPE SALV_S_LAYOUT_KEY,
        LR_LAYOUT TYPE REF TO CL_SALV_LAYOUT.

*****To call
  IF GV_FLAG = 0.
    TRY.
        CL_SALV_TABLE=>FACTORY(
           IMPORTING
              R_SALV_TABLE = GR_TABLE1
            CHANGING
              T_TABLE      =  GT_OUTTAB1 ).
      CATCH CX_SALV_MSG.
    ENDTRY.
    GV_FLAG = 1.
  ENDIF.
*    ... set the columns technical
  DATA: LR_COLUMNS TYPE REF TO CL_SALV_COLUMNS,
        LR_COLUMN  TYPE REF TO CL_SALV_COLUMN,
        LR_EVENTS TYPE REF TO LC_HANDLE_EVENTS,
        LR_EVENT  TYPE REF TO CL_SALV_EVENTS_TABLE.
*        ... §3.2 include own functions by setting own status
  GR_TABLE1->SET_SCREEN_STATUS(
  PFSTATUS      =  'L100_ALV'
  REPORT        =  G_REPID
  SET_FUNCTIONS = GR_TABLE1->C_FUNCTIONS_ALL ).
  GV_PFKEY = 'L100_ALV'.
*... set list title
  SET TITLEBAR '100'.
*  ... §3 set the top of list content
  PERFORM CREATE_ALV_FORM_CONTENT_TOL USING
                                 IV_DIR
                                 IV_NAME
                                 GR_TABLE1.
  LR_COLUMNS = GR_TABLE1->GET_COLUMNS( ).
  LR_COLUMNS->SET_OPTIMIZE( GC_TRUE ).

*... §4 set layout
  LR_LAYOUT =  GR_TABLE1->GET_LAYOUT( ).

*... §4.1 set the Layout Key
  LS_KEY-REPORT = G_REPID.
  LS_KEY-HANDLE = '0002'.                                   "#EC NOTEXT
  LR_LAYOUT->SET_KEY( LS_KEY ).

*... §4.2 set usage of default Layouts
  LR_LAYOUT->SET_DEFAULT( ABAP_TRUE ).
  LR_LAYOUT->SET_SAVE_RESTRICTION( '3' ).

*          perform set_columns_technical using lr_columns.
**For events
  LR_EVENT = GR_TABLE1->GET_EVENT( ).
  CREATE OBJECT LR_EVENTS.
*... §6.1 register to the event USER_COMMAND
  SET HANDLER LR_EVENTS->ON_BUTTON_CLICK FOR LR_EVENT.
*... §6.4 register to the event DOUBLE_CLICK
  SET HANDLER LR_EVENTS->ON_DOUBLE_CLICK FOR LR_EVENT.
  GR_TABLE1->DISPLAY( ).
*  gr_table1->refresh( refresh_mode = 1 ).

ENDFORM.                    " SHOW_FILE_LIST_GRID
*&---------------------------------------------------------------------*
*&      Form  SHOW_DIR_LIST_ALV
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SHOW_DIR_LIST_ALV .

  DATA : LR_COLUMNS TYPE REF TO CL_SALV_COLUMNS,
         LR_COLUMN  TYPE REF TO CL_SALV_COLUMN.

  DATA: LS_LAYOUT TYPE SALV_S_LAYOUT_INFO,
        LS_KEY    TYPE SALV_S_LAYOUT_KEY,
        LR_LAYOUT TYPE REF TO CL_SALV_LAYOUT.

  TRY.
      CL_SALV_TABLE=>FACTORY(
        IMPORTING
          R_SALV_TABLE = GR_TABLE2
        CHANGING
          T_TABLE      = GT_OUT_DIR ).
    CATCH CX_SALV_MSG.
  ENDTRY.
*  To set pf-status
  GR_TABLE2->SET_SCREEN_STATUS(
  PFSTATUS      =  'L400'
  REPORT        =  G_REPID
  SET_FUNCTIONS = GR_TABLE2->C_FUNCTIONS_ALL ).
*   set the columns technical
  LR_COLUMNS = GR_TABLE2->GET_COLUMNS( ).
  LR_COLUMNS->SET_OPTIMIZE( GC_TRUE ).
*... set list title
  GV_PFKEY = 'L400'.
  SET TITLEBAR '400'.
*  ... §3 set the top of list content
  PERFORM CREATE_ALV_FORM_CONTENT_TOL USING
                                      SY-TITLE
                                      ' '
                                      GR_TABLE2.
*... §4 set layout
  LR_LAYOUT = GR_TABLE2->GET_LAYOUT( ).

*... §4.1 set the Layout Key
  LS_KEY-REPORT = G_REPID.
  LS_KEY-HANDLE = '0003'.                                   "#EC NOTEXT
  LR_LAYOUT->SET_KEY( LS_KEY ).

*... §4.2 set usage of default Layouts
  LR_LAYOUT->SET_DEFAULT( ABAP_TRUE ).
  LR_LAYOUT->SET_SAVE_RESTRICTION( '3' ).

  GR_TABLE2->DISPLAY( ).
ENDFORM.                    " SHOW_DIR_LIST_ALV
*&---------------------------------------------------------------------*
*&      Form  disp_attri_grid
*&---------------------------------------------------------------------*
*  To Display attribute details in grid
*----------------------------------------------------------------------*
*      -->IT_OUT_ATTRI  LIKE GT_OUT_ATTRI
*----------------------------------------------------------------------*
FORM DISP_ATTRI_GRID  USING    IT_OUT_ATTRI LIKE GT_OUT_ATTRI.
  DATA : LR_ATTRI TYPE REF TO CL_SALV_TABLE.
  DATA: LR_DISPLAY_SETTINGS TYPE REF TO CL_SALV_DISPLAY_SETTINGS,
        L_TITLE TYPE LVC_TITLE.
  DATA: LS_LAYOUT TYPE SALV_S_LAYOUT_INFO,
      LS_KEY    TYPE SALV_S_LAYOUT_KEY,
      LR_LAYOUT TYPE REF TO CL_SALV_LAYOUT.

  TRY.
      CL_SALV_TABLE=>FACTORY(
        IMPORTING
          R_SALV_TABLE = LR_ATTRI
        CHANGING
          T_TABLE      = IT_OUT_ATTRI ).
    CATCH CX_SALV_MSG.
  ENDTRY.

*... set list title
  SET TITLEBAR '300'.
  L_TITLE = SY-TITLE.
  LR_DISPLAY_SETTINGS = LR_ATTRI->GET_DISPLAY_SETTINGS( ).
  LR_DISPLAY_SETTINGS->SET_LIST_HEADER( L_TITLE ).
*... §4 set layout
  LR_LAYOUT = LR_ATTRI->GET_LAYOUT( ).

*... §4.1 set the Layout Key
  LS_KEY-REPORT = G_REPID.
  LS_KEY-HANDLE = '0004'.                                   "#EC NOTEXT
  LR_LAYOUT->SET_KEY( LS_KEY ).

*... §4.2 set usage of default Layouts
  LR_LAYOUT->SET_DEFAULT( ABAP_TRUE ).
  LR_LAYOUT->SET_SAVE_RESTRICTION( '3' ).
  LR_ATTRI->DISPLAY( ).
ENDFORM.                    " disp_attri_grid

*&---------------------------------------------------------------------*
*&      Form  show_disp_grid
*&---------------------------------------------------------------------*
*       Display Selected file output in grid
*----------------------------------------------------------------------*
*      -->IT_OUT_DISP
*      -->IV_NAME
*      -->IV_DIR
*----------------------------------------------------------------------*
FORM SHOW_DISP_GRID  USING    IT_OUT_DISP LIKE GT_OUT_DISP
                              IV_NAME TYPE C
                              IV_DIR TYPE C.

  DATA : LR_DISP   TYPE REF TO CL_SALV_TABLE,
         LR_EVENTS TYPE REF TO LC_HANDLE_EVENTS,
         LR_EVENT  TYPE REF TO CL_SALV_EVENTS_TABLE.

  DATA: LS_LAYOUT TYPE SALV_S_LAYOUT_INFO,
        LS_KEY    TYPE SALV_S_LAYOUT_KEY,
        LR_LAYOUT TYPE REF TO CL_SALV_LAYOUT.

  TRY.
      CL_SALV_TABLE=>FACTORY(
        IMPORTING
          R_SALV_TABLE = LR_DISP
        CHANGING
          T_TABLE      = IT_OUT_DISP ).
    CATCH CX_SALV_MSG.
  ENDTRY.
  LR_DISP->SET_SCREEN_STATUS(
  PFSTATUS      =  'L200'
  REPORT        =  G_REPID
  SET_FUNCTIONS = LR_DISP->C_FUNCTIONS_ALL ).
  GV_PFKEY = 'L200'.

*  ... §3 set the top of list content
  PERFORM CREATE_ALV_FORM_CONTENT_TOL USING
                                      IV_DIR
                                      IV_NAME
                                      LR_DISP.
*... §4 set layout
  LR_LAYOUT = LR_DISP->GET_LAYOUT( ).

*... §4.1 set the Layout Key
  LS_KEY-REPORT = G_REPID.
  LS_KEY-HANDLE = '0005'.                                   "#EC NOTEXT
  LR_LAYOUT->SET_KEY( LS_KEY ).

*... §4.2 set usage of default Layouts
  LR_LAYOUT->SET_DEFAULT( ABAP_TRUE ).
  LR_LAYOUT->SET_SAVE_RESTRICTION( '3' ).

*  *Events
  LR_EVENT = LR_DISP->GET_EVENT( ).
  CREATE OBJECT LR_EVENTS.
  SET HANDLER LR_EVENTS->ON_BUTTON_CLICK FOR LR_EVENT.
  LR_DISP->DISPLAY( ).

ENDFORM.                    " show_disp_grid
*&---------------------------------------------------------------------*
*&      Form  create_alv_form_content_tol
*&---------------------------------------------------------------------*
*       Grid Title creation
*----------------------------------------------------------------------*
*      -->iv_dir  Directory
*      -->iv_name  filename
*----------------------------------------------------------------------*
FORM CREATE_ALV_FORM_CONTENT_TOL
                USING   IV_DIR TYPE C
                        IV_NAME  TYPE C
                        IR_TABLE TYPE REF TO CL_SALV_TABLE.

  DATA: LR_DISPLAY_SETTINGS TYPE REF TO CL_SALV_DISPLAY_SETTINGS,
        L_TITLE TYPE LVC_TITLE,
        LV_LINE(70).

  DATA: CA_DIR  TYPE NAME_OF_DIR,
        CA_LEN  LIKE SY-FDPOS.

* ir_top->set_grid_lines( 1 ).
  CASE GV_PFKEY.
    WHEN 'L000_ALV'.
      DATA: DBSERVER(20)  TYPE C VALUE 'no-host-yet '. "DB-server name
      DATA: DATUM_MASK(10),
            UZEIT_MASK(8).
*   display the first line in the header.
*     PERFORM get_dbserver(rsora000) USING dbserver.
      WRITE SY-DATUM TO DATUM_MASK.
      WRITE SY-UZEIT TO UZEIT_MASK USING EDIT MASK '__:__:__'.
      CONCATENATE 'SAP-Directories'
                  '(' DATUM_MASK
                   UZEIT_MASK
                   SY-SYSID
                   SY-HOST ')'
                   INTO LV_LINE SEPARATED BY SPACE.
      L_TITLE = LV_LINE.
    WHEN 'L100_ALV'.
*     shift directory name left until the rest fits into 58 chars
      CA_DIR = IV_DIR.
      CA_LEN = STRLEN( CA_DIR ).

      IF CA_LEN > 58.
        IF CA_DIR(1) = FILE_SEPARATOR.
          SHIFT CA_DIR LEFT.
        ENDIF.

        WHILE CA_LEN > 56 AND CA_LEN > 0 AND CA_DIR CS FILE_SEPARATOR.
          SHIFT CA_DIR LEFT UP TO FILE_SEPARATOR.
          CA_LEN = STRLEN( CA_DIR ).
          IF CA_LEN > 56.
            SHIFT CA_DIR LEFT.
          ENDIF.
        ENDWHILE.

        SHIFT CA_DIR RIGHT BY 2 PLACES.
        IF NOT ( CA_DIR CS FILE_SEPARATOR ).
          SHIFT CA_DIR RIGHT.
          CA_DIR+2(1) = FILE_SEPARATOR.
        ENDIF.
        CA_DIR(2) = '..'.
      ENDIF.

      CONCATENATE 'Directory :'  CA_DIR
                  INTO LV_LINE
                  SEPARATED BY SPACE.
      L_TITLE = LV_LINE.
    WHEN 'L200'.
      CONCATENATE 'Directory :'  IV_DIR '-'
                  TEXT-017 ':' IV_NAME
                  INTO LV_LINE
                  SEPARATED BY SPACE.
      L_TITLE = LV_LINE.
    WHEN 'L400'.
      L_TITLE = IV_DIR.
  ENDCASE.
  LR_DISPLAY_SETTINGS = IR_TABLE->GET_DISPLAY_SETTINGS( ).
  LR_DISPLAY_SETTINGS->SET_LIST_HEADER( L_TITLE ).
ENDFORM.                    " create_alv_form_content_tol

*-- C5056155 End Of ALV Code ------------------------------------------*


*-----------------------------------------------------------------------
*split long directory names into parts, which will fit to one line
*-----------------------------------------------------------------------
FORM SPLIT_DIRECTORY USING SD_DIRNAME.

  DATA: SD_SEPARATOR(1)    TYPE C,
        SD_TABIX           LIKE SY-TABIX,
        SD_POS             LIKE SY-FDPOS,
        SD_END             LIKE SY-FDPOS,
        SD_LEN             LIKE SY-FDPOS,
        SD_DIRLINE_SPLIT   LIKE SY-FDPOS   VALUE 80.

  DATA: BEGIN OF SD_COMPONENTS OCCURS 10,
        NAME               TYPE FILENAME_AL11,
        END   OF SD_COMPONENTS.

  CLEAR   DIRLINES.
  REFRESH DIRLINES.

  IF SD_DIRNAME CS '/'.
    SD_SEPARATOR = '/'.
  ELSE.
    SD_SEPARATOR = '\'.
  ENDIF.

  SD_POS = STRLEN( SD_DIRNAME ).
  IF SD_POS <= SD_DIRLINE_SPLIT.
    DIRLINES = SD_DIRNAME.
    APPEND DIRLINES.
  ELSE.
    SPLIT SD_DIRNAME AT SD_SEPARATOR INTO TABLE SD_COMPONENTS.
    SD_POS   = 0.
    SD_TABIX = 0.

    LOOP AT SD_COMPONENTS.

      ADD 1 TO SD_TABIX.
      SD_LEN = STRLEN( SD_COMPONENTS-NAME ).
      SD_END = SD_POS + SD_LEN + 1.

      IF SD_END > SD_DIRLINE_SPLIT AND DIRLINES > SPACE.
        APPEND DIRLINES.
        CLEAR  DIRLINES.
        SD_POS = 0.
      ENDIF.

      IF SD_LEN > 0.
        IF SD_TABIX = 1.
          WRITE SD_COMPONENTS-NAME TO DIRLINES(SD_LEN).
          ADD SD_LEN TO SD_POS.
        ELSE.
          WRITE SD_SEPARATOR       TO DIRLINES+SD_POS(1).
          ADD 1 TO SD_POS.
          WRITE SD_COMPONENTS-NAME TO DIRLINES+SD_POS(SD_LEN).
          ADD SD_LEN TO SD_POS.
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF DIRLINES > SPACE.
      APPEND DIRLINES.
    ENDIF.
  ENDIF.

ENDFORM.                    "split_directory

*-----------------------------------------------------------------------
* Display director and filename
*-----------------------------------------------------------------------
FORM SHOW_FILENAME.

  DATA: TP_POS_DIRNAME  LIKE SY-FDPOS.

  PERFORM SPLIT_DIRECTORY USING FILE_LIST-DIRNAME.

  FORMAT INTENSIFIED ON.

  TP_POS_DIRNAME = 13.
  WRITE: / 'Directory: '.
  LOOP AT DIRLINES.
    WRITE: AT TP_POS_DIRNAME DIRLINES.
    NEW-LINE.
    ADD 2 TO TP_POS_DIRNAME.
  ENDLOOP.
  WRITE: / 'Name:'(017),
         13 FILE_LIST-NAME.
  ULINE.

  FORMAT INTENSIFIED OFF.

ENDFORM.                    "show_filename

*-----------------------------------------------------------------------
* Show file contents (in normal ABAP-list)
*-----------------------------------------------------------------------
FORM SHOW_FILE.

  DATA: BUFFER(512).

  LEAVE TO LIST-PROCESSING.

  FORMAT INTENSIFIED OFF.

  OPEN DATASET LIST_FILENAME IN TEXT MODE ENCODING DEFAULT FOR INPUT
                              IGNORING CONVERSION ERRORS.
  IF SY-SUBRC = 0.
    TRY.
        DO.
          READ DATASET LIST_FILENAME INTO BUFFER.
          IF SY-SUBRC <> 0.
            EXIT.
          ELSE.
            IF BUFFER <> SPACE."added to display blank lines in a file
              NEW-LINE.
              WRITE AT 1(512) BUFFER.
            ELSE.
              SKIP.
            ENDIF.
          ENDIF.
        ENDDO.
      CATCH CX_SY_CONVERSION_ERROR.
        WRITE: / ' '.
        MESSAGE S333 WITH TEXT-023.
    ENDTRY.
    CLOSE DATASET LIST_FILENAME.
  ELSE.
    WRITE: / ' '.
    MESSAGE S333 WITH TEXT-018.
  ENDIF.

ENDFORM.                    "show_file
