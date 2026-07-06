*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Program name: ZEQSMART4                     Date written: 2014.03.31 *
* Authors name:   Deloitte                                   *
* Program title:  eQSmart download program ECC5 and ECC6         *
* Corr. version: V4.0 31-03-2014                                       *
*----------------------------------------------------------------------*
* DESCRIPTION:                                                         *
*                                                                      *
*  In order to review your SAP R/3 system, eQSmart requires key SAP R/3*
*  security data.  In order to obtain the key security data, an ABAP   *
*  program is installed in the SAP R/3 system.  The program will       *
*  download the data into plain text files in a directory specified at *
*  run time.  The data can then zipped and uploaded into eQSmart via   *
*  secure communication (Secure Sockets Layer) as detailed in the      *
*  eQSmart user documentation.                                         *
*                            A                                          *
*----------------------------------------------------------------------*
* Quality assured by:   eQSmart Developement team                      *
* Date              :     31-3-2014                                    *
*----------------------------------------------------------------------*
* CORRECTION HISTORY                                                   *
*                                                                      *
* Correction no  Init  Date        Description                         *
*                                                                      *
* V3.2:                                                                *
* Users in a non-existing client error - fixed                         *
* Authorisation buffer overflow error - fixed                          *
* Role descriptions copying to other roles - fixed                     *
* Allows for background execution.                                     *
* English profile descriptions.                                        *
*                                                                      *
* TQH                01-09-2004    Restructering the program for time- *
*                                  out problem.                        *
* TQH                20-10-2004    Replace Hardcoded language key by   *
*                                  parameter                           *
* TQH                14-01-2005    Change endif statement for SAP      *
*                                  standard profile check              *
* TQH                17-01-2005    Refresh and clear internal tables   *
*                                  and structures                      *
* Bas Maertzdorf     01-08-2005    Insert of slash in file path during *
*                                  background processing fixed.        *
* TQH                02-26-2007    1. Program should flag all the user *
*                                  with lock statuses except 0 and 128 *
*                                  2. File spAutorisations.txt should  *
*                                  also contain the dummy values presnt*
*                                  in the autorisation data. The dummy *
*                                  value (' ') is replaced by an empty *
*                                  field, this should not be the case. *
*                                  It should be included in the output *
*                                  file.                               *
*                                  3. Insert User Names in SpUsers.txt *
* Arnab              14-05-2007    1. New text file for Composite roles*
*                                  being created.                      *
*                                  2. spRoles.txt should contain compo-*
*                                  site as well as single role informa-*
*                                  tion.                               *
*                                  3. All authorisation data, even if  *
*                                  not attached to users, should be    *
*                                  downloaded to spAuthorisations file *
*                                  4. New file spDefaults.txt should   *
*                                  list all standard user-ids with a   *
*                                  default password.                   *
*                                  5. System Change option information *
*                                  should be downloaded to spClients   *
*                                  file.                               *
*                                  6. Lock status of users should be   *
*                                  downloaded instead of just a flag.  *
*                                  7. New file called spLockedtcodes   *
*                                  should list all locked transactions *
* Ritesh             06-09-2007    1.spRoles file should not contain   *
*                                  the generated profiles              *
*                                  2.All the single roles listed in    *
*                                  AGR_AGRS should exist in spRoles.txt*
*                                  3.spUsersandRoles-Generated profiles*
*                                  should be excluded from UST04       *
*                                  4.spAuthorisations “Orphan” profiles*
*                                  identified in spAuthorisations.txt  *
*                                  should be added to the spRoles      *
*Naveen              07-12-2011    ABAP fixes                          *
*Developer           31-03-2014	   1.Enable test of TMSADM default     *
*          passwords.            *
*                                  2.Enlarge field for application     *
*          server in spParameters.txt          *
*	                                                               *
*----------------------------------------------------------------------*

REPORT zeqsmart4 .
**--------------------------------------------------------------------**
* DATA DECLARATIONS
**--------------------------------------------------------------------**

type-POOLS: abap.
TABLES:   pahi,       "Parameter history
          usr02,      "User base table
          ust04,      "Profiles for user
          ust10c,     "Composite profiles to simple profiles
          usr10,      "Profile definition
          usr12,      "Authorisation definition
          usr40,      "Prohibited passwords
          t000,       "Clients
          tadir,      "System change option
          devaccess,  "Developer access
          usvart,     "Variable definitions
          usobt_c,    "Check indicators
          agr_texts,  "Role texts
          usr11.      "Profile texts

DATA: plength TYPE i,
      gv_path TYPE string,
      gv_codepage TYPE cpcodepage.


DATA: BEGIN OF g_t000 OCCURS 0,
        mandt LIKE sy-mandt,
        mtext LIKE t000-mtext,
        change(50),
        sys_chg(50) TYPE c,   "New column added in the spClients file
        date LIKE sy-datum,
      END OF g_t000.

DATA: BEGIN OF g_usr02 OCCURS 1000,
        mandt LIKE sy-mandt,
        bname LIKE usr02-bname,
        class LIKE usr02-class,
        name1 LIKE usr03-name1,
        trdat LIKE usr02-trdat,
        idays(5) TYPE n,
        valfr(8),
        valto(8),
        ustyp LIKE usr02-ustyp,
        uflag(3) TYPE c, " status in field 'UFLAG'
      END OF g_usr02.

DATA: BEGIN OF g_agr_texts OCCURS 100,
        mandt LIKE agr_texts-mandt,
        agr_name LIKE agr_texts-agr_name,
        text LIKE agr_texts-text,
        sap_std(1),
      END OF g_agr_texts.

DATA: BEGIN OF user_usr03 OCCURS 1.
        INCLUDE STRUCTURE usr03.
DATA: END OF user_usr03.

* Final Structure of the Composite Role File
DATA: BEGIN OF g_comp OCCURS 200,
        mandt     LIKE agr_agrs-mandt,       "Client
        agr_name  TYPE agr_agrs-agr_name,    "Composite Role
        child_agr TYPE agr_agrs-child_agr,   "Single Role
      END OF g_comp.

* Structure Declared for the Locked Tcode File
DATA: BEGIN OF g_tcode OCCURS 100,
        tcode TYPE tstc-tcode,     "Transaction Code
        ttext TYPE tstct-ttext,    "Transaction Code Text
      END OF g_tcode.

* Structure to store USR02 data for passwords
DATA: BEGIN OF g_usr02_def OCCURS 0,
        mandt LIKE usr02-mandt,
        bname LIKE usr02-bname,
        bcode LIKE usr02-bcode,
      END OF g_usr02_def.

* Structure for capturing User ID's with Default passwords
DATA: BEGIN OF g_defaults OCCURS 100,
        mandt TYPE usr02-mandt,
        bname TYPE usr02-bname,
        status(60) TYPE c,
      END OF g_defaults.

* Structure capturing the entire list of existing roles
DATA: BEGIN OF g_roles OCCURS 100,
        mandt     TYPE  sy-mandt,              " Client
        agr_name  TYPE  agr_define-agr_name,   " Role Name
        change_usr TYPE agr_define-change_usr, " Changed by
        text      TYPE  agr_texts-text,        " Role Description
      END OF g_roles.

DATA:
  BEGIN OF g_usr10 OCCURS 0,
    mandt LIKE usr10-mandt,
    profn LIKE usr10-profn,
    typ   LIKE usr10-typ,
    nraut LIKE usr10-nraut,
    auths LIKE usr10-auths,
  END OF g_usr10.

DATA:
  BEGIN OF g_profiles OCCURS 0,
    mandt LIKE usr10-mandt,
    profn LIKE usr10-profn,
    profn_single LIKE usr10-profn,
  END OF g_profiles.

*Structure for spAuthorisations with Orphan profiles to be checked in
* spRoles
DATA: BEGIN OF g_agr_1251 OCCURS 10000,
          mandt LIKE sy-mandt,
          agr_name LIKE agr_1251-agr_name,
          profn LIKE usr10-profn,
          auth LIKE agr_1251-auth,
          object LIKE agr_1251-object,
          field LIKE agr_1251-field,
          low(20) TYPE c,
          high(20) TYPE c,
        END OF g_agr_1251.

* Data Declaration
DATA: x20 TYPE x VALUE '20'.

**--------------------------------------------------------------------**
* SELECTION-SCREEN
**--------------------------------------------------------------------**
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE opt1.

SELECTION-SCREEN COMMENT /1(14) lvers1.
SELECTION-SCREEN COMMENT 21(30) vers1.
SELECTION-SCREEN COMMENT /1(14) lrole1.
SELECTION-SCREEN COMMENT 21(36) role1.
SELECTION-SCREEN COMMENT /1(79) ctime.
SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) cclient.
PARAMETERS clientf LIKE t000-mandt DEFAULT '000'.
SELECTION-SCREEN COMMENT 32(9) ccliento.
PARAMETERS clientt LIKE t000-mandt DEFAULT '999'.
SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) gc_langu.
PARAMETERS: p_langu LIKE syst-langu DEFAULT syst-langu.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE opt2.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) cpath.
PARAMETERS path LIKE rlgrap-filename OBLIGATORY DEFAULT 'C:\TEMP\'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(20) cloc.
PARAMETERS loc AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN COMMENT 35(39) cbak.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK blk2.

**--------------------------------------------------------------------**
*  INITIALIZATION
**--------------------------------------------------------------------**
INITIALIZATION.
** Parameter texts
  lvers1 = 'R/3 Version:'(001).
  vers1 = sy-saprl.
  lrole1 = 'User Assigned:'(002).
  IF sy-saprl+0(1) = '3'.
    role1 = 'Profiles only.'(003).
  ELSE.
    role1 = 'Roles and Profiles.'(004).
  ENDIF.

  gc_langu = 'Language Key'(005).
  cpath    = 'Download Directory'(006).
  opt1     = 'System Information'(007).
  opt2     = 'Download Options'(008).
  cclient  = 'R/3 Client'(009).
  ccliento = ' to'(010).
  cloc     = 'Download to local PC'(011).
  cbak     = 'Note, uncheck for background execution.'(012).

  CLEAR pahi.

  SELECT * UP TO 1 ROWS FROM pahi WHERE parstate = 'A'
    AND parname = 'abap/timeout'.
  ENDSELECT.
  p_langu = syst-langu.

  IF sy-subrc = 0.
    IF pahi-parvalue < 512.
      CONCATENATE 'ABAP Program timeout set to'(013)
        pahi-parvalue 'seconds. Background execution recommended.'(014)
        INTO ctime SEPARATED BY space.
      loc = ' '.
    ENDIF.
  ENDIF.

**--------------------------------------------------------------------**
*  START-OF-SELECTION
**--------------------------------------------------------------------**
START-OF-SELECTION.

  IF clientt = ''.
    clientt = clientf.
  ENDIF.

* Authorization Check
  AUTHORITY-CHECK OBJECT 'S_USER_GRP'
      ID 'CLASS' FIELD '*'
      ID 'ACTVT' FIELD '03'.

  IF sy-subrc NE 0. LEAVE. ENDIF.

  AUTHORITY-CHECK OBJECT 'S_USER_PRO'
      ID 'PROFILE' FIELD '*'
      ID 'ACTVT' FIELD '03'.

  IF sy-subrc NE 0. LEAVE. ENDIF.

  AUTHORITY-CHECK OBJECT 'S_USER_AUT'
      ID 'OBJECT' DUMMY
      ID 'AUTH' FIELD '*'
      ID 'ACTVT' FIELD '03'.

  IF sy-subrc NE 0. LEAVE. ENDIF.

  plength = STRLEN( path ) - 1.
  IF path+plength(1) NE '\' AND loc EQ 'X'.
    CONCATENATE path '\' INTO path.
  ENDIF.

** Refresh internal tables
  REFRESH: g_t000, g_usr02, g_agr_texts.
**Get the Code Page
  PERFORM spclients.
  IF sy-subrc <> 2.
    PERFORM spcomposites.
    PERFORM splockedtcodes.
    PERFORM spusers.
    PERFORM spdefaults.
    PERFORM spusersandroles.
*   PERFORM sproles.  " Commented by Deloitte R10 - Ritesh 06-Sep-2007
*                                called after spauthorisation_new
    PERFORM spauthorisation_new.
    PERFORM sproles.   " Changed by Deloitte R10 - Ritesh 06-Sep-2007
*                                      called after spauthorisation_new
    PERFORM spprofiles.
    PERFORM spdevelopers.
    PERFORM sppasswords.
    PERFORM spparameters.
    PERFORM sptransactions.
    PERFORM spvariables.

  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  spClients
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM spclients.

  DATA : lv_edtflag TYPE tadir-edtflag.

  CLEAR: gv_path,
        t000.

** Select T000
  SELECT * FROM t000 WHERE mandt GE clientf AND mandt LE clientt.

    MOVE-CORRESPONDING t000 TO g_t000.
    CASE t000-cccoractiv.
      WHEN '1'.
        MOVE 'Auto-recording of changes in transport request'(015) TO
    g_t000-change.
      WHEN '2'.
        MOVE 'No customizing changes allowed'(016) TO g_t000-change.
      WHEN '3'.
        MOVE 'Customizing possible, but no transport allowed'(017)
    TO g_t000-change.
      WHEN OTHERS.
        MOVE 'Customizing possible without automatic recording'(018) TO
    g_t000-change.
    ENDCASE.
    MOVE sy-datum TO g_t000-date.
    APPEND g_t000.

  ENDSELECT.

* Begin of Changes done at R10 by Arnab and Vishal

* Fetching the EDTFLAG for Program ID 'HEAD' and Object 'SYST'
SELECT edtflag "Flag : Object can be edited with special editor
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*FROM tadir BYPASSING BUFFER
FROM tadir
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
UP TO 1 ROWS
INTO lv_edtflag
WHERE pgmid EQ 'HEAD'
AND object EQ 'SYST' .
  ENDSELECT.

  IF sy-subrc EQ 0 AND lv_edtflag EQ 'N'.
* If EDTFLAG is equal to 'N'
    g_t000-sys_chg = 'Not Modifiable'(019).
    MODIFY g_t000 TRANSPORTING sys_chg WHERE mandt IS NOT INITIAL.
  ELSE.
* If EDTFLAG is not 'N'
    g_t000-sys_chg = 'Modifiable'(020).
    MODIFY g_t000 TRANSPORTING sys_chg WHERE mandt IS NOT INITIAL.
  ENDIF.

* End of Changes done at R10 by Arnab and Vishal

** Concatenate filepath
  CONCATENATE path 'spClients.txt'(021) INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES g_t000 USING gv_path.
  ELSE.
    PERFORM download_server TABLES g_t000 USING gv_path.
  ENDIF.

  DESCRIBE TABLE g_t000 LINES sy-tfill.
  WRITE :/ 'Download from version'(022), sy-saprl, ' system.'(023).
  WRITE :/ 'Clients'(024), 40 sy-tfill.


ENDFORM.                    "SPCLIENTS

*&---------------------------------------------------------------------*
*&      Form  spUsers
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM spusers.

  DATA i_count_mandt TYPE i VALUE 0. "status bar
  DATA i_perc TYPE p. "status bar
  DATA n_uflag(3) TYPE n.
  DATA: lv_name_text type NAME_TEXT.   "07 June 2012
  CLEAR gv_path.

  DATA: BEGIN OF l_usr02 OCCURS 1000,
        mandt TYPE mandt,     "Client
        bname TYPE xubname,   "User Name in User Master Record
        gltgv TYPE xugltgv,   "User valid from
        gltgb TYPE xugltgb,   "User valid to
        USTYP type XUUSTYP,   "user type
        class TYPE XUCLASS,
        uflag TYPE xuuflag,   "User Lock Status
        erdat TYPE xuerdat,   "Creation Date of the User Master Record
        trdat TYPE xuldate,   "Last Logon Date
        END OF l_usr02.

  IF NOT g_t000[] IS INITIAL.
**  Select usr02
    CLEAR: usr02.
SELECT mandt
bname
gltgv
gltgb
USTYP
CLASS
uflag
erdat
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*trdat FROM usr02 CLIENT SPECIFIED BYPASSING BUFFER INTO TABLE l_usr02
trdat FROM usr02 CLIENT SPECIFIED INTO TABLE l_usr02
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
FOR ALL ENTRIES IN g_t000 WHERE mandt EQ g_t000-mandt.

    IF sy-subrc = 0.
      SORT l_usr02 BY mandt bname.
    ENDIF.

  ENDIF.

  LOOP AT g_t000.
* status bar
    DESCRIBE TABLE g_t000 LINES sy-tfill.
    i_count_mandt = i_count_mandt + 1.
    i_perc = i_count_mandt / sy-tfill * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = i_perc
        text       = 'Compiling spUsers.txt'(025).

    LOOP AT l_usr02 WHERE mandt = g_t000-mandt.
      CHECK l_usr02-bname NE space.
      MOVE-CORRESPONDING l_usr02 TO g_usr02.
      IF l_usr02-gltgv = '00000000'.
        g_usr02-valfr = l_usr02-erdat.
      ELSE.
        g_usr02-valfr = l_usr02-gltgv.
      ENDIF.
      IF l_usr02-gltgb = '00000000'.
        g_usr02-valto = '99991231'.
      ELSE.
        g_usr02-valto = l_usr02-gltgb.
      ENDIF.
      IF l_usr02-trdat NE 0.
        g_usr02-idays = sy-datum - l_usr02-trdat.
      ELSE.
        g_usr02-idays = 99999.
      ENDIF.

      n_uflag       = l_usr02-uflag.
      g_usr02-uflag = n_uflag.

      CLEAR user_usr03.

*  Start of addition by KREDDY
      PERFORM get_usr03 USING l_usr02-bname g_t000-mandt.

      CALL FUNCTION 'SUSR_USER_ADDRESS_READ'
        EXPORTING
          user_name              = l_usr02-bname
*          READ_DB_DIRECTLY        = 'X'
*          CACHE_RESULTS          = ' '
        IMPORTING
          user_usr03             = user_usr03
        EXCEPTIONS
          user_address_not_found = 1
          OTHERS                 = 2.

******<<<<07 June 2012
clear: lv_name_text.
Select single NAME_TEXT from V_USERNAME into lv_name_text
        where BNAME = l_usr02-bname.
        if sy-subrc = 0.
         g_usr02-name1 = lv_name_text.
        else.
         g_usr02-name1 = space.
        endif.


*      IF NOT user_usr03-name1 IS INITIAL.
*        CONCATENATE user_usr03-name1 user_usr03-name2 INTO g_usr02-name1
*                                     SEPARATED BY space.
*      ELSE.   "if No entry found, fill space
**        CONCATENATE user_usr03-name1 user_usr03-name2 INTO g_usr02-name1  "22 MAy 2012 NDEVABATHINI
*           g_usr02-name1 = space. "22 MAy 2012 NDEVABATHINI
*      ENDIF.
******>>>>07 June 2012
* End of addition by KREDDY

* Start of addition by KREDDY
      IF g_usr02-name1 IS INITIAL.
* If name1 is blank then move id to name1
        MOVE l_usr02-bname TO g_usr02-name1.
      ENDIF.
* End of addition by KREDDY

      APPEND g_usr02.
      clear: l_usr02,g_usr02,user_usr03. "22 MAY 2012 NDEVABATHINI
    ENDLOOP.

  ENDLOOP.

*** Concatenate filepath
  CONCATENATE path 'spUsers.txt'(026) INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES g_usr02 USING gv_path.
  ELSE.
    PERFORM download_server TABLES g_usr02 USING gv_path.
  ENDIF.

  DESCRIBE TABLE g_usr02 LINES sy-tfill.
  WRITE :/ 'Users'(027), 40 sy-tfill.

ENDFORM.                    "SPUSERS

*&---------------------------------------------------------------------*
*&      Form  spUsersandRoles
*&---------------------------------------------------------------------*
*       Get roles and profiles directly attached to users from
*       AGR_USERS and UST04
*----------------------------------------------------------------------*
FORM spusersandroles.

  DATA: BEGIN OF l_usrol_tmp OCCURS 1000,
          mandt LIKE sy-mandt,
          uname LIKE agr_users-uname,
         agr_name LIKE agr_users-agr_name,
        END OF l_usrol_tmp.

  DATA: BEGIN OF l_usrol OCCURS 1000,
          mandt LIKE sy-mandt,
          uname LIKE agr_users-uname,
         agr_name LIKE agr_users-agr_name,
        END OF l_usrol.

* Begin of change Deloitte R10 Ritesh 06-Sep-2007  >>>>> 3
  DATA:  BEGIN OF l_usr10 OCCURS 10000,
          mandt LIKE sy-mandt,
          profn LIKE usr10-profn,
          typ LIKE usr10-typ,
         END OF l_usr10.
  DATA: l_index TYPE sy-tabix.
* End of change Deloitte R10 Ritesh 06-Sep-2007  >>>>> 3
  DATA i_count_users TYPE i VALUE 0. "status bar
  DATA i_perc TYPE p. "status bar
  DATA: l_total_recs TYPE sy-tfill.

  DATA l_more_lvls TYPE c VALUE 1.

  CLEAR gv_path.

  DESCRIBE TABLE g_usr02 LINES l_total_recs.
  IF NOT g_usr02[] IS INITIAL.
SELECT mandt
uname
agr_name
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*FROM agr_users CLIENT SPECIFIED BYPASSING BUFFER
FROM agr_users CLIENT SPECIFIED
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
INTO TABLE l_usrol_tmp
FOR ALL ENTRIES IN g_usr02
WHERE uname EQ g_usr02-bname
AND mandt EQ g_usr02-mandt
AND from_dat LE sy-datum
AND to_dat GE sy-datum.
    IF sy-subrc = 0.
      SORT l_usrol_tmp BY mandt  uname agr_name.
    ENDIF.

*Exclude generated roles from SPUSERSANDROLES
    SELECT ust04~mandt
           ust04~bname
           ust04~profile
      APPENDING  TABLE l_usrol_tmp
      FROM ust04
      INNER JOIN usr10 ON ust04~mandt   = usr10~mandt AND
                          ust04~profile = usr10~profn
      CLIENT specified
      FOR ALL ENTRIES IN g_usr02
      WHERE ust04~mandt EQ g_usr02-mandt
      AND ust04~bname EQ g_usr02-bname
      AND usr10~aktps = 'A'
      AND usr10~typ  NE 'G'.
    IF sy-subrc = 0.
      SORT l_usrol_tmp BY mandt  uname agr_name.
    ENDIF.
  ENDIF.

  LOOP AT g_usr02.

* status bar
    i_count_users = i_count_users + 1.
    i_perc = i_count_users / l_total_recs * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = i_perc
        text       = 'Compiling spUsersandRoles.txt'(028).

    IF sy-saprl+0(1) <> '3'.
*          TABLES: agr_users. "Roles assigned to Users

      LOOP AT l_usrol_tmp WHERE uname = g_usr02-bname AND
                                  mandt =  g_usr02-mandt.
        MOVE l_usrol_tmp TO l_usrol.
        APPEND l_usrol.
        CLEAR:  l_usrol_tmp,
                g_usr02.
      ENDLOOP.
    ENDIF.
  ENDLOOP.


  SORT l_usrol.
  DELETE ADJACENT DUPLICATES FROM l_usrol COMPARING ALL FIELDS.

** Concatenate filepath
  CONCATENATE path 'spUsersandRoles.txt'(029) INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES l_usrol USING gv_path.
  ELSE.
    PERFORM download_server TABLES l_usrol USING gv_path.
  ENDIF.

  DESCRIBE TABLE l_usrol LINES sy-tfill.
  WRITE :/ 'Users and Roles'(030), 40 sy-tfill.
ENDFORM.                    "SPUSERSANDROLES
*&---------------------------------------------------------------------*
*&      Form  spRoles
*&---------------------------------------------------------------------*
*       Get all the roles and their description from AGR_DEFINE and
*       AGR_TEXTS. Also get all the profiles and their texts from
*       USR10 and USR11.
*----------------------------------------------------------------------*
FORM sproles.

  DATA i_count TYPE i VALUE 0. "status bar
  DATA i_perc TYPE p. "status bar
  DATA: l_total_recs TYPE sy-tfill.
* Begin of change Deloitte R10 Ritesh 06-Sep-2007 >>>>> 2
  DATA: l_comp LIKE g_comp OCCURS 0 WITH HEADER LINE.
  DATA: l_roles LIKE g_roles OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF l_usr10 OCCURS 0,
        mandt LIKE usr10-mandt,
        profn LIKE usr10-profn,
        modbe LIKE usr10-modbe,
      END OF l_usr10.

* End of change Deloitte R10 Ritesh 06-Sep-2007 >>>>> 2

  DATA:
    BEGIN OF l_profiles OCCURS 0,
      mandt LIKE usr10-mandt,
      profn LIKE usr10-profn,
      modbe LIKE usr10-modbe,
      ptext LIKE usr11-ptext,
    END OF l_profiles.

  CLEAR gv_path.

* Getting all role descriptions
* Fetching the Entire list of existing roles from 'AGR_DEFINE' table
  SELECT  agr_define~mandt
          agr_define~agr_name
          agr_define~change_usr
          agr_texts~text
    INTO TABLE g_roles
    FROM agr_define
    LEFT OUTER JOIN agr_texts
      ON agr_define~mandt    = agr_texts~mandt AND
         agr_define~agr_name = agr_texts~agr_name AND
         agr_texts~spras     = p_langu      AND
         agr_texts~line      = '00000'
    CLIENT specified
    FOR ALL ENTRIES IN g_t000
    WHERE agr_define~mandt EQ g_t000-mandt.

  l_total_recs = sy-dbcnt.

  LOOP AT g_roles.
* status bar
    i_count = i_count + 1.
    i_perc = i_count / l_total_recs * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = i_perc
        text       = 'Compiling Roles into spRoles.txt'(031).

    g_agr_texts-mandt    = g_roles-mandt.
    g_agr_texts-agr_name = g_roles-agr_name.
    g_agr_texts-text     = g_roles-text.

    IF g_roles-change_usr EQ 'SAP' OR
       g_roles-change_usr EQ 'DDIC'.
      g_agr_texts-sap_std  = '0'.
    ELSE.
      g_agr_texts-sap_std  = '1'.
    ENDIF.
    APPEND g_agr_texts.
    CLEAR  g_agr_texts.
  ENDLOOP.
* Begin of change Deloitte R10 Ritesh 06-Sep-2007 >>>>> 2
* Sort table before read.
  SORT g_agr_texts ASCENDING BY mandt agr_name.
  APPEND LINES OF g_comp TO l_comp.
  SORT l_comp BY mandt child_agr.
  DELETE ADJACENT DUPLICATES FROM l_comp COMPARING mandt child_agr.
* SPRoles - role flag has to be set in all cases (0 or 1)
  SELECT  agr_define~mandt
          agr_define~agr_name
          agr_define~change_usr
          agr_texts~text
    INTO TABLE l_roles
    FROM agr_define
    LEFT OUTER JOIN agr_texts
      ON agr_define~mandt    = agr_texts~mandt AND
         agr_define~agr_name = agr_texts~agr_name AND
         agr_texts~spras     = p_langu      AND
         agr_texts~line      = '00000'
    CLIENT specified
    FOR ALL ENTRIES IN l_comp
    WHERE agr_define~mandt EQ l_comp-mandt
    AND agr_define~agr_name EQ l_comp-child_agr.
*
*Begin of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 19/12/2019 EY_DES04 ECDK917080 *
SORT L_ROLES BY MANDT AGR_NAME .
*End of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 19/12/2019 EY_DES04 ECDK917080 *
  LOOP AT l_comp. " table from spComposite
    READ TABLE g_agr_texts WITH KEY mandt    =  l_comp-mandt
                                    agr_name =  l_comp-child_agr
                                  BINARY SEARCH.
    IF sy-subrc NE 0.
      g_agr_texts-mandt    = l_comp-mandt.
      g_agr_texts-agr_name = l_comp-child_agr.
* Read l_roles table to set Role flag to identify a role is
* standard SAP or not.
      READ TABLE l_roles WITH KEY mandt    =  l_comp-mandt
                                  agr_name =  l_comp-child_agr
                                              BINARY SEARCH.
      IF sy-subrc = 0.
        IF l_roles-change_usr EQ 'SAP' OR
           l_roles-change_usr EQ 'DDIC'.
          g_agr_texts-sap_std  = '0'.
        ELSE.
          g_agr_texts-sap_std  = '1'.
        ENDIF.
        g_agr_texts-text = l_roles-text.

      ENDIF.
      APPEND g_agr_texts.
      CLEAR  g_agr_texts.
    ENDIF.
  ENDLOOP.
* delete duplicate rows
  SORT g_agr_texts ASCENDING BY mandt agr_name.
  DELETE ADJACENT DUPLICATES FROM g_agr_texts COMPARING mandt agr_name.
  FREE l_comp.
* End of change Deloitte R10 Ritesh   06-Sep-2007    >>>>> 2

* Getting texts for all profiles excluding
*Generated profiles in the system.
  SELECT usr10~mandt
         usr10~profn
         usr10~modbe
         usr11~ptext
    INTO TABLE l_profiles
    FROM usr10
    LEFT OUTER JOIN usr11
      ON usr11~mandt = usr10~mandt AND
         usr11~profn = usr10~profn AND
         usr11~langu = p_langu     AND
         usr11~aktps = 'A'
    CLIENT specified
    FOR ALL ENTRIES IN g_t000
    WHERE usr10~mandt = g_t000-mandt AND
          usr10~aktps = 'A' AND
          usr10~typ NE 'G'.   " Exclude Generate profiles
* End of change Deloitte R10 Ritesh   06-Sep-2007   >>>>> 1

  CLEAR l_total_recs.
  l_total_recs = sy-dbcnt.
  CLEAR i_count.

  LOOP AT l_profiles.

* status bar
    i_count = i_count + 1.
    i_perc = i_count / l_total_recs * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = i_perc
        text       = 'Compiling Profiles into spRoles.txt'(032).

    g_agr_texts-mandt    = l_profiles-mandt.
    g_agr_texts-agr_name = l_profiles-profn.
    g_agr_texts-text     = l_profiles-ptext.

    IF l_profiles-modbe EQ 'SAP' OR
       l_profiles-modbe EQ 'DDIC'.
      g_agr_texts-sap_std  = '0'.
    ELSE.
      g_agr_texts-sap_std  = '1'.
    ENDIF.

    APPEND g_agr_texts.
    CLEAR  g_agr_texts.
  ENDLOOP.

*  SORT g_agr_texts. " Commented by Deloitte R10 Ritesh 06-Sep-2007
*                      Generated profiles "Orphan" Added .  >>>>> 4
  SORT g_agr_texts ASCENDING BY mandt agr_name.
  DELETE ADJACENT DUPLICATES FROM g_agr_texts COMPARING ALL FIELDS.
*Begin of change Deloitte R10 Ritesh 06-Sep-2007
* Generated profiles "Orphan" Added .  >>>>> 4
* Check for "Orphan" profiles in spAuthorisations
* that are not in spRoles
  SORT g_agr_1251 ASCENDING BY mandt agr_name profn.
  DELETE ADJACENT DUPLICATES FROM g_agr_1251 COMPARING mandt agr_name profn.

SELECT mandt
profn
modbe
INTO TABLE l_usr10
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*FROM usr10 CLIENT SPECIFIED BYPASSING BUFFER
FROM usr10 CLIENT SPECIFIED
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
FOR ALL ENTRIES IN g_agr_1251
WHERE mandt EQ g_agr_1251-mandt AND
profn = g_agr_1251-profn.

*Begin of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 19/12/2019 EY_DES04 ECDK917080 *
SORT L_USR10 BY MANDT PROFN .
*End of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 19/12/2019 EY_DES04 ECDK917080 *
  LOOP AT g_agr_1251 WHERE agr_name = space.
*    READ TABLE g_agr_texts WITH KEY mandt   = g_agr_1251-mandt
*                                   agr_name+[12] = g_agr_1251-profn.
*                                                 BINARY SEARCH.
    READ TABLE g_agr_texts WITH KEY mandt   = g_agr_1251-mandt
                               agr_name+0(12) = g_agr_1251-profn.
*                                                 BINARY SEARCH.
    IF sy-subrc NE 0.
      g_agr_texts-mandt    = g_agr_1251-mandt.
      g_agr_texts-agr_name = g_agr_1251-profn.
*        g_agr_texts-text     =  .   "cannot get text since
*                                      it's an orphan profile

      READ TABLE l_usr10 WITH KEY mandt   = g_agr_1251-mandt
                                  profn   = g_agr_1251-profn
                                              BINARY SEARCH.
      IF l_usr10-modbe EQ 'SAP' OR
          l_usr10-modbe EQ 'DDIC'.
        g_agr_texts-sap_std  = '0'.
      ELSE.
        g_agr_texts-sap_std  = '1'.
      ENDIF.

      APPEND g_agr_texts.
      CLEAR  g_agr_texts.
    ENDIF.

  ENDLOOP.

* delte duplicate entries
*  SORT g_agr_texts ASCENDING BY mandt agr_name.
*  DELETE ADJACENT DUPLICATES FROM g_agr_texts COMPARING mandt agr_name.
*End of change Deloitte R10 Ritesh 06-Sep-2007
*                    Generated profiles "Orphan" Added .  >>>>> 4

** Concatenate filepath
  CONCATENATE path 'spRoles.txt' INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES g_agr_texts USING gv_path.
  ELSE.
    PERFORM download_server TABLES g_agr_texts USING gv_path.
  ENDIF.

  DESCRIBE TABLE g_agr_texts LINES sy-tfill.
  WRITE :/ 'Roles'(065), 40 sy-tfill.

ENDFORM.                    "SPROLES

*&---------------------------------------------------------------------*
*&      Form  spAuthorisation_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM spauthorisation_new.

  DATA: BEGIN OF l_agr_1251 OCCURS 10000,
          mandt LIKE sy-mandt,
          agr_name LIKE agr_1251-agr_name,
          profn LIKE usr10-profn,
          auth LIKE agr_1251-auth,
          object LIKE agr_1251-object,
          field LIKE agr_1251-field,
          low(20) TYPE c,
          high(20) TYPE c,
        END OF l_agr_1251.

  DATA: i_count TYPE i VALUE 0, "status bar
        i_perc TYPE p, "status bar
        setfill LIKE sy-tfill,
        i_num_auth TYPE i VALUE 0,
        l_curr_auth LIKE agr_1251-auth VALUE 'ZZZZZ'.

  DATA: l_total_recs TYPE i VALUE 0.

  CLEAR gv_path.

  DATA: BEGIN OF l_usr10_data OCCURS 0,
          mandt LIKE usr10-mandt,
          profn LIKE usr10-profn,
          nraut LIKE usr10-nraut,
          auths LIKE usr10-auths,
        END OF l_usr10_data.

  DATA: BEGIN OF l_usr10 OCCURS 1,
           profn LIKE usr10-profn,
           objct(10) TYPE c,
           auths(12) TYPE c,
        END OF l_usr10.

  DATA: i_nrpro LIKE usr04-nrpro,

        off TYPE i,
        vtyp,
        clng(2),
        glng(2),
        lng TYPE i,
        intflag TYPE i VALUE 0,
        rc LIKE sy-subrc.

  FIELD-SYMBOLS : <text>.


** Select user master authorization profiles
  CLEAR usr10.

SELECT mandt
profn
nraut
auths
INTO TABLE l_usr10_data
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*FROM usr10 CLIENT SPECIFIED BYPASSING BUFFER
FROM usr10 CLIENT SPECIFIED
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
FOR ALL ENTRIES IN g_t000
WHERE mandt EQ g_t000-mandt AND
aktps EQ 'A' AND
typ NE 'C'.

  l_total_recs = sy-dbcnt.

  LOOP AT l_usr10_data.
* status bar
    i_count = i_count + 1.
    i_perc = i_count / l_total_recs * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = i_perc
        text       = 'Compiling spAuthorisations.txt'(033).


    CLEAR l_agr_1251.

    l_agr_1251-mandt = l_usr10_data-mandt.

SELECT SINGLE agr_name
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*FROM agr_1016 CLIENT SPECIFIED BYPASSING BUFFER
FROM agr_1016 CLIENT SPECIFIED
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
INTO l_agr_1251-agr_name
WHERE mandt = l_usr10_data-mandt AND
profile = l_usr10_data-profn.

    l_agr_1251-profn    = l_usr10_data-profn.

    REFRESH l_usr10.

    i_nrpro = ( l_usr10_data-nraut - 2 ) / 22.
    SHIFT l_usr10_data-auths LEFT BY 2 PLACES.
    l_usr10-profn = l_usr10_data-profn.
    DO i_nrpro TIMES.
      l_usr10-objct = l_usr10_data-auths(10).
      l_usr10-auths = l_usr10_data-auths+10(12).
      APPEND l_usr10.
      SHIFT l_usr10_data-auths LEFT BY 22 PLACES.
    ENDDO.
* obtain authorisation values

    LOOP AT l_usr10.
      l_agr_1251-auth = l_usr10-auths.
      IF l_curr_auth NE l_agr_1251-auth.
        l_curr_auth = l_agr_1251-auth.
        i_num_auth = i_num_auth + 1.
      ENDIF.
      l_agr_1251-auth = i_num_auth.

** Select user master authorization values
      CLEAR usr12.
      SELECT SINGLE * FROM usr12 CLIENT SPECIFIED
        WHERE mandt = l_usr10_data-mandt
        AND objct = l_usr10-objct
        AND auth = l_usr10-auths
        AND aktps = 'A'.

      setfill = 0.

      l_agr_1251-object = usr12-objct.
      off = 2.
      ASSIGN usr12-vals+off(1) TO <text>.
      WRITE <text> TO vtyp.
* Added by KREDDY for downloading the empty values too
      IF vtyp = space AND NOT usr12-objct IS INITIAL.
        l_agr_1251-high = space.
        l_agr_1251-low  = space.
        APPEND l_agr_1251.
      ENDIF.
* End of Addition by KREDDY
      WHILE vtyp <> '  ' AND off < usr12-lng.
        off = off + 1.
        CASE vtyp.
          WHEN 'F'.  "Field Name
            off = off + 5.
            ASSIGN usr12-vals+off(2) TO <text>.
            WRITE <text> TO clng.
            lng = clng.
            IF lng <= 0.
              rc = 1.
              EXIT.
            ENDIF.
            off = off + 2.
            ASSIGN usr12-vals+off(10) TO <text>.
            WRITE <text> TO l_agr_1251-field.
            off = off + 10.
          WHEN 'E'.
            ASSIGN usr12-vals+off(lng) TO <text>.
            WRITE <text> TO l_agr_1251-low.
            APPEND l_agr_1251.
            setfill = setfill + 1.
            off = off + lng.
          WHEN 'G'.
            ASSIGN usr12-vals+off(2) TO <text>.
            WRITE <text> TO clng.
            glng = clng.
            off = off + 2.
            ASSIGN usr12-vals+off(lng) TO <text>.
            IF intflag = 0.
              WRITE <text> TO l_agr_1251-low.
              WRITE <text> TO l_agr_1251-high.
              IF glng < 19.
                WRITE 'ZZZZZZZZZZZZZZZZZZ' TO l_agr_1251-high+glng.
              ENDIF.
            ELSE.
              WRITE <text> TO l_agr_1251-high.
              IF glng < 19.
                WRITE 'ZZZZZZZZZZZZZZZZZZ' TO l_agr_1251-high+glng.
              ENDIF.
              intflag = 0.
            ENDIF.
            IF l_agr_1251-low = '' AND
              l_agr_1251-high = 'ZZZZZZZZZZZZZZZZZZ'.
              l_agr_1251-low = '*'.
              l_agr_1251-high = space.
            ENDIF.
            APPEND l_agr_1251.
            setfill = setfill + 1.
            l_agr_1251-low = space.
            l_agr_1251-high = space.
            off = off + lng.
          WHEN 'V'.
            intflag = 1.
            ASSIGN usr12-vals+off(lng) TO <text>.
            WRITE <text> TO l_agr_1251-low.
            off = off + lng.
          WHEN 'B'.
            intflag = 0.
            ASSIGN usr12-vals+off(lng) TO <text>.
            WRITE <text> TO l_agr_1251-high.
            IF l_agr_1251-low = '' AND
              l_agr_1251-high = 'ZZZZZZZZZZZZZZZZZZ'.
              l_agr_1251-low = '*'.
              l_agr_1251-high = space.
            ENDIF.
            APPEND l_agr_1251.
            setfill = setfill + 1.
            l_agr_1251-low = space.
            l_agr_1251-high = space.
            off = off + lng.
        ENDCASE.
        ASSIGN usr12-vals+off(1) TO <text>.
        WRITE <text> TO vtyp.
      ENDWHILE.
    ENDLOOP.
  ENDLOOP.
  APPEND LINES OF l_agr_1251 TO g_agr_1251.
** Concatenate filepath
  CONCATENATE path 'spAuthorisations.txt'(034) INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES l_agr_1251 USING gv_path.
  ELSE.
    PERFORM download_server TABLES l_agr_1251 USING gv_path.
  ENDIF.

  DESCRIBE TABLE l_agr_1251 LINES sy-tfill.
  WRITE :/ 'Authorisation Values'(035), 40 sy-tfill.

ENDFORM.                    "SPAUTHORISATION_new

*&---------------------------------------------------------------------*
*&      Form  spDevelopers
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM spdevelopers.

  CLEAR gv_path.

  DATA:BEGIN OF o_devacc OCCURS 0,
          mandt LIKE sy-mandt,
          uname LIKE devaccess-uname,
        END OF o_devacc.

  DATA:BEGIN OF l_devacc OCCURS 1000.
          INCLUDE STRUCTURE devaccess.
  DATA     END OF l_devacc.

  DATA: BEGIN OF l_usr02 OCCURS 1000.
          INCLUDE STRUCTURE usr02.
  DATA: END OF l_usr02.

  DATA: BEGIN OF l_t000 OCCURS 1000.
          INCLUDE STRUCTURE t000.
  DATA: END OF l_t000.

** Select table for development user
  CLEAR : devaccess,usr02.
  SELECT * FROM devaccess INTO TABLE l_devacc.
  IF sy-subrc = 0.
* Select logon data
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*SELECT * FROM usr02 CLIENT SPECIFIED BYPASSING BUFFER INTO TABLE l_usr02
SELECT * FROM usr02 CLIENT SPECIFIED INTO TABLE l_usr02
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
FOR ALL ENTRIES IN l_devacc
WHERE bname EQ l_devacc-uname
AND mandt GE clientf AND mandt LE clientt.
    IF sy-subrc = 0.
      SELECT * FROM t000 INTO TABLE l_t000
        FOR ALL ENTRIES IN l_usr02
         WHERE mandt = l_usr02-mandt.
    ENDIF.

  ENDIF.

  LOOP AT  l_devacc.
    LOOP AT  l_usr02 WHERE  bname EQ l_devacc-uname.
      LOOP AT l_t000 WHERE mandt = l_usr02-mandt.
        MOVE-CORRESPONDING l_devacc TO o_devacc.
        o_devacc-mandt = l_usr02-mandt.
        COLLECT o_devacc.
        CLEAR: l_t000.
      ENDLOOP.
      CLEAR: l_usr02.
    ENDLOOP.
    CLEAR: l_devacc.
  ENDLOOP.

** Concatenate filepath
  CONCATENATE path 'spDevelopers.txt'(036) INTO gv_path.

** Download tabl  to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES o_devacc USING gv_path.
  ELSE.
    PERFORM download_server TABLES o_devacc USING gv_path.
  ENDIF.

  DESCRIBE TABLE o_devacc LINES sy-tfill.
  WRITE :/ 'Developers'(037), 40 sy-tfill.

ENDFORM.                    "SPDEVELOPERS

*&---------------------------------------------------------------------*
*&      Form  spPasswords
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sppasswords.
  DATA lit_usr40 LIKE usr40 OCCURS 0.

  CLEAR gv_path.

** Select table for illegal passwords
  CLEAR usr40.
  SELECT * FROM usr40 INTO TABLE lit_usr40 .

** Concatenate filepath
  CONCATENATE path 'spPasswords.txt'(038) INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES lit_usr40 USING gv_path.
  ELSE.
    PERFORM download_server TABLES lit_usr40 USING gv_path.
  ENDIF.

  DESCRIBE TABLE lit_usr40 LINES sy-tfill.
  WRITE :/ 'Prohibited Passwords'(039), 40 sy-tfill.

ENDFORM.                    "SPPASSWORDS

*&---------------------------------------------------------------------*
*&      Form  spParameters
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM spparameters.
  DATA: BEGIN OF t_pahi OCCURS 1000,
          hostname TYPE stunhost,
          systemid  TYPE systemid,
          pardate   TYPE sydatum,
          parname TYPE parname,
          parstate TYPE parstate,
          parvalue  TYPE parvalue,
        END OF t_pahi.

  CLEAR gv_path.
********************************************************
*** Select history of system, DB and SAP parameter
*  CLEAR pahi.
*  SELECT * FROM pahi.
*
*    MOVE-CORRESPONDING pahi TO t_pahi.
*    APPEND t_pahi.
*  ENDSELECT.
*******************************************************

** Select history of system, DB and SAP parameter
  CLEAR pahi.
  SELECT hostname
          systemid
          pardate
          parname
          parstate
          parvalue FROM pahi INTO TABLE t_pahi.


** Concatenate filepath
  CONCATENATE path 'spParameters.txt'(040) INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES t_pahi USING gv_path.
  ELSE.
    PERFORM download_server TABLES t_pahi USING gv_path.
  ENDIF.

  DESCRIBE TABLE t_pahi LINES sy-tfill.
  WRITE :/ 'Parameters'(041), 40 sy-tfill.

ENDFORM.                    "SPPARAMETERS

*&---------------------------------------------------------------------*
*&      Form  spTransactions
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sptransactions.
   DATA: BEGIN OF t_usobt_c OCCURS 10000,
           name(20),
           object LIKE usobt_c-object,
           field LIKE usobt_c-field,
           low(50),
         END OF t_usobt_c.

  DATA: BEGIN OF l_usobt_c OCCURS 10000,
        name TYPE xupname,
        type type USOBTYPE,
        object TYPE xuobject,
        field TYPE xufield,
        low TYPE xuval,
        END OF  l_usobt_c.

  DATA: BEGIN OF l_usvart OCCURS 10000.
          INCLUDE STRUCTURE usvart.
  DATA: END OF l_usvart.

  CLEAR gv_path.

** Select relation Transaction   > Auth. Object (Customer)
  CLEAR usobt_c.
SELECT name
type
object
field
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*low FROM usobt_c BYPASSING BUFFER INTO TABLE l_usobt_c.
low FROM usobt_c INTO TABLE l_usobt_c.
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
  IF sy-subrc = 0.
    SELECT  * FROM usvart INTO TABLE l_usvart
      FOR ALL ENTRIES IN  l_usobt_c
       WHERE varbl = l_usobt_c-low
       AND langu = p_langu.

    IF sy-subrc = 0.
      SORT l_usvart BY varbl.
    ENDIF.
  ENDIF.


  LOOP AT l_usobt_c.
    IF l_usobt_c-low+0(1) = '$'.
      READ TABLE l_usvart WITH KEY varbl = l_usobt_c-low  BINARY SEARCH.
      IF sy-subrc = 0.
        t_usobt_c-low = l_usvart-vtext.
      else.  "if no entry in USVART table  22 MAY 2012
         t_usobt_c-low = l_usobt_c-low.
      ENDIF.
    ELSE.
      t_usobt_c-low = l_usobt_c-low.
    ENDIF.

    t_usobt_c-name = l_usobt_c-name.
    t_usobt_c-object = l_usobt_c-object.
    t_usobt_c-field = l_usobt_c-field.
    APPEND t_usobt_c.
    CLEAR: l_usobt_c,
           l_usvart,
*           Begin of Change by NDEVABATHINI 18 Jan 2012
           t_usobt_c.
*    End of Change by NDEVABATHINI 18 Jan 2012
  ENDLOOP.

** Concatenate filepath
  CONCATENATE path 'spTransactions.txt'(042) INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES t_usobt_c USING gv_path.
  ELSE.
    PERFORM download_server TABLES t_usobt_c USING gv_path.
  ENDIF.

  DESCRIBE TABLE t_usobt_c LINES sy-tfill.
  WRITE :/ 'Transaction to Authorisation Objects C/M'(043), 40 sy-tfill.

ENDFORM.                    "SPTRANSACTIONS

*&---------------------------------------------------------------------*
*&      Form  spVariables
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM spvariables.
  DATA: BEGIN OF t_usvart OCCURS 100,
          vtext LIKE usvart-vtext,
        END OF t_usvart.

  CLEAR gv_path.

** Select possible authorization fields as variables
  CLEAR usvart.
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*SELECT DISTINCT vtext FROM usvart BYPASSING BUFFER INTO TABLE t_usvart WHERE langu =
SELECT DISTINCT vtext FROM usvart INTO TABLE t_usvart WHERE langu =
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
p_langu.

** Concatenate filepath
  CONCATENATE path 'spVariables.txt'(044) INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES t_usvart USING gv_path.
  ELSE.
    PERFORM download_server TABLES t_usvart USING gv_path.
  ENDIF.

  DESCRIBE TABLE t_usvart LINES sy-tfill.
  WRITE :/ 'Variables'(045), 40 sy-tfill.

ENDFORM.                    "SPVARIABLES

*&---------------------------------------------------------------------*
*&      Form  download_local
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LIT_TABLE  text
*      -->LV_PATH  text
*----------------------------------------------------------------------*
FORM download_local  TABLES   lit_table
                     USING    lv_path TYPE string.

*  CALL FUNCTION 'WS_DOWNLOAD'
*    EXPORTING
*      filename         = lv_path
*    TABLES
*      data_tab         = lit_table
*    EXCEPTIONS
*      file_write_error = 2.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename         = lv_path
      codepage         = '4103'
      write_bom        = 'X'
    TABLES
      data_tab         = lit_table
    EXCEPTIONS
      file_write_error = 1.

  IF sy-subrc = 1.
    WRITE: / 'Invalid Directory:'(046),lv_path,'Please select an'(047).
    WRITE / 'already existing directory and try again.'(048).
    EXIT.
  ENDIF.

ENDFORM.                    " download_local
*&---------------------------------------------------------------------*
*&      Form  download_server
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LIT_TABLE  text
*      -->LV_PATH  text
*----------------------------------------------------------------------*
FORM download_server  TABLES   lit_table
                      USING    lv_path.
  DATA: lv_msg        TYPE string,
        l_conv        TYPE ref to cl_abap_conv_x2x_ce,
        l_content_in  TYPE xstring,
        lv_tempfile   TYPE string,
        lv_cp         TYPE char4,
        lv_cp_alt     TYPE abap_encoding,
        l_content_out TYPE xstring.

** Only in SAP R/3 version 4.7 and higher
  OPEN DATASET lv_path IN TEXT MODE ENCODING UTF-8 FOR OUTPUT WITH BYTE-ORDER MARK.

  LOOP AT lit_table.
    TRANSFER lit_table TO lv_path.
  ENDLOOP.
  CLOSE DATASET lv_path.
ENDFORM.                    " download_server
*&---------------------------------------------------------------------*
*&      Form  get_usr03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BNAME  text
*      -->P_MANDT  text
*----------------------------------------------------------------------*
FORM get_usr03  USING    bname
                         mandt.

  TABLES: usr03, usr21, tsad3t, adcp.                       "USR0340A
                                                            "*367i

* global data necessary for FB SUSR_USER_ADDRESS_READ
  DATA: g_last_user_name LIKE usr01-bname,
        g_last_usr21 LIKE usr21,
        g_last_adcp LIKE adcp.
*----------------------------------------- "*367i+
* buffer for FB SUSR_USER_ADDRESS_READ
  DATA: BEGIN OF g_user_data OCCURS 0,
          user LIKE usr01-bname,
          data LIKE v_addr_usr,
        END OF g_user_data.

  DATA: g_update_active TYPE c.
  CONSTANTS: c_y TYPE c VALUE 'Y',
             c_n TYPE c VALUE 'N'.

  DATA: addr_sel LIKE addr3_sel.
  DATA: addr_val LIKE addr3_val.

  DATA: v_addr_usr_wa LIKE v_addr_usr.
  DATA: save_subrc LIKE sy-subrc.
  DATA: save_tabix LIKE sy-tabix.
*------- "*367i-
  CLEAR usr21.
  CLEAR usr03.                                              "USR0340A

  IF bname <> g_last_user_name.                             "*227i
    SELECT SINGLE * FROM usr21
                               CLIENT SPECIFIED
                               WHERE bname = bname
                               AND   mandt = mandt.

    IF sy-subrc <> 0.
      CLEAR g_last_usr21.                                   "*227i
      g_last_user_name = bname.                             "*227i
    ENDIF.
    g_last_usr21 = usr21.                                   "*227i
  ELSE.                                                     "*227i
    IF NOT g_last_usr21 IS INITIAL.                         "*227i
      usr21 = g_last_usr21.                                 "*227i
    ENDIF.                                                  "*227i
  ENDIF.                                                    "*227i

  IF usr21-persnumber <> space
     AND usr21-addrnumber <> space.
    addr_sel-persnumber = usr21-persnumber.
    addr_sel-addrnumber = usr21-addrnumber.
    addr_sel-date       = '00010101'.
  ENDIF.
*----------- "*367i+
*   check in buffer if update is active
  IF g_update_active IS INITIAL.
*----------- "*367i-
    DATA: ev_upginfo LIKE uvers.
    CALL FUNCTION 'UPG_GET_ACTIVE_COMP_UPGRADE'
      EXPORTING
        iv_upgtype             = 'A'
        iv_buffered            = 'X'
      IMPORTING
        ev_upginfo             = ev_upginfo
      EXCEPTIONS
        no_upgrade_active      = 1
        ambigious_entries      = 2
        invalid_component_name = 3
        OTHERS                 = 4.
    IF sy-subrc = 1
       OR ( sy-subrc = 0 AND ev_upginfo-putstatus <> 'B'
            AND ev_upginfo-putstatus <> 'S' ).
*-------------------------------------------------------------- "*367i+
      g_update_active = c_n.
    ELSE.
      g_update_active = c_y.
    ENDIF.
  ENDIF.
  IF g_update_active = c_n.
    user_usr03-mandt = sy-mandt.
                                                            "USR0340A
    user_usr03-bname = bname.
                                                            "USR0340A
    user_usr03-name2 = bname.

  ENDIF.   " if sy-subrc <> 1 (vom FB upg_get_active_comp_upgrade)

ENDFORM.                                                    " get_usr03
*&---------------------------------------------------------------------*
*&      Form  spcomposites
*&---------------------------------------------------------------------*
*       Get the child roles for all composite roles in each of the
*       clients from AGR_AGRS table. Download to spComposites.
*----------------------------------------------------------------------*
FORM spcomposites .

* Fetching the list of roles and the flag value which indicates
* whether a role is a composite role or not
SELECT mandt
agr_name
child_agr
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*FROM agr_agrs CLIENT SPECIFIED BYPASSING BUFFER
FROM agr_agrs CLIENT SPECIFIED
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
INTO TABLE g_comp
FOR ALL ENTRIES IN g_t000
WHERE mandt EQ g_t000-mandt.

** Concatenate filepath
  CONCATENATE path 'spComposites.txt'(049) INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES g_comp USING gv_path.
  ELSE.
    PERFORM download_server TABLES g_comp USING gv_path.
  ENDIF.


ENDFORM.                    " spcomposites
*&---------------------------------------------------------------------*
*&      Form  splockedtcodes
*&---------------------------------------------------------------------*
*       Get details of Locked Transaction codes from TSTC and TTEXT
*       tables. Download to spLockedtcodes file
*----------------------------------------------------------------------*
FORM splockedtcodes .

*  DATA: BEGIN OF l_tstc OCCURS 100,
*          tcode TYPE tcode,   "Transaction Code
*         cinfo TYPE syhex01,  "HEX01 data element for SYST
*        END OF l_tstc.
*
*  DATA: BEGIN OF l_tstct OCCURS 100,
*          tcode TYPE tcode,   "Transaction Code
*         ttext TYPE ttext_stct,  "Transaction Text
*        END OF l_tstct.
** Selecting the Tcode from the TSTC Table (Client Independent Table)
*  SELECT tcode
*         cinfo FROM tstc  BYPASSING BUFFER INTO TABLE l_tstc .
*
** fetch the Tcode Text from TSTCT Table
*  IF NOT l_tstc[] IS INITIAL.
*    SELECT  tcode
*            ttext
*      FROM  tstct  BYPASSING BUFFER
*      INTO  TABLE l_tstct
*      FOR ALL ENTRIES IN l_tstc
*     WHERE  sprsl EQ p_langu
*       AND  tcode EQ l_tstc-tcode.
*    IF sy-subrc = 0.
*      SORT l_tstc BY tcode.
*      SORT l_tstct BY tcode.
*    ENDIF.
*  ENDIF.

** Checking whether the Tcode is Locked or not
*  LOOP AT l_tstc .
*    IF l_tstc-cinfo O x20.
*      READ TABLE l_tstct WITH KEY tcode = l_tstc-tcode BINARY SEARCH.
*      IF sy-subrc = 0.
*        g_tcode-tcode = l_tstc-tcode.
*        g_tcode-ttext =  l_tstct-ttext.
*        APPEND g_tcode.
*        CLEAR  g_tcode.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.


  TABLES: tstc.

* Selecting the Tcode from the TSTC Table
  SELECT * FROM tstc.
* Checking whether the Tcode is Locked or not
    IF tstc-cinfo O x20.
      g_tcode-tcode = tstc-tcode.
* If the Tcode is locked fetch the Tcode Text from TSTCT Table
      SELECT  SINGLE ttext
        FROM  tstct
        INTO  g_tcode-ttext
       WHERE  sprsl EQ p_langu
         AND  tcode EQ tstc-tcode.
      APPEND g_tcode.
      CLEAR  g_tcode.
    ENDIF.
  ENDSELECT.



** Concatenate filepath
  CONCATENATE path 'spLockedtcodes.txt'(050) INTO gv_path.

** Download tabl  to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES g_tcode USING gv_path.
  ELSE.
    PERFORM download_server TABLES g_tcode USING gv_path.
  ENDIF.

ENDFORM.                    " splockedtcodes
*&---------------------------------------------------------------------*
*&      Form  spdefaults
*&---------------------------------------------------------------------*
*       Check password hashes of default user ids. Code in this
*       routine has been copied from standard program RSUSR003.
*----------------------------------------------------------------------*
FORM spdefaults .

* Hashvalues of default passwords
  DATA: codeas1 LIKE usr02-bcode VALUE 'C75E6D9600AB5710',
        codeas2 LIKE usr02-bcode VALUE '5F1000863FC70B6D',
        codead1 LIKE usr02-bcode VALUE 'C7CC6D670030F310',
        codead2 LIKE usr02-bcode VALUE '5FA752863FB70BA9',
        codeacp LIKE usr02-bcode VALUE 'FC49DBF6F3FDCF36',
        codeaew LIKE usr02-bcode VALUE '13C810002A147DEE',
        codebs1 LIKE usr02-bcode VALUE 'D0BFF4276DA1E208',
        codebs2 LIKE usr02-bcode VALUE '4B31EAA71FDDEAE2',
        codebd1 LIKE usr02-bcode VALUE '9A32C3A07A595E4E',
        codebd2 LIKE usr02-bcode VALUE '61D26428640DBAB5',
        codebcp LIKE usr02-bcode VALUE '7D806C248F03813D',
        codebew LIKE usr02-bcode VALUE 'BD5E494D3ECBF5E2',
        codetms1a LIKE usr02-bcode VALUE '7671D2F2729F27F0',
        codetms1b LIKE usr02-bcode VALUE '942B9DC0F2394D85',
        codetms2a LIKE usr02-bcode VALUE '05CB79BE189802A0',
        codetms2b LIKE usr02-bcode VALUE 'B7E2F82C0A3E54C4'.
      DATA:
    BEGIN OF l_t000 OCCURS 10,
      mandt LIKE t000-mandt,
    END OF l_t000.

  CONSTANTS:
   lc_ewa TYPE xucode VALUE '13C810002A147DEE', "codaew
   lc_ewb TYPE xucode VALUE 'BD5E494D3ECBF5E2', "codebew
   lc_ewd TYPE xucode VALUE '573822832DF89B9C', "
   lc_ewe TYPE xucode VALUE 'B3ADDFE95DCD036F',
   lc_ewf1 TYPE hash160x VALUE '924127D88EE3C1820A2C88495EC4825E819C9249',
   lc_ewf2 TYPE hash160x VALUE '760293CCD7AC111298A7AC70D3304242E442320F',
   lc_cpa TYPE xucode VALUE 'FC49DBF6F3FDCF36',   "codeacp
   lc_cpb TYPE xucode VALUE '7D806C248F03813D',   "codebcp
   lc_cpd TYPE xucode VALUE '35C7AB28316EA22F',
   lc_cpe TYPE xucode VALUE '5A5F45726821A147',
   lc_cpf1 TYPE hash160x VALUE '57CF364A7D83FA563025C7BCFFFB3B579DFB23F3',
   lc_cpf2 TYPE hash160x VALUE '38AE55102813F3BBBC3B3BCA09285ED5A9E0423F',
   lc_dda TYPE xucode VALUE '5FA752863FB70BA9',	            "codead2
   lc_ddb TYPE xucode VALUE '61D26428640DBAB5',             "codebd2
   lc_ddd TYPE xucode VALUE 'DCA44BB71C073A05',
   lc_dde TYPE xucode VALUE '08FA7683A46D9AA9',
   lc_ddf TYPE hash160x VALUE '905F5E6CE67B7C60D0F7BA9C4063AAF0D8602B45',
   lc_saa TYPE xucode VALUE 'C75E6D9600AB5710',             "codeas1
   lc_sab TYPE xucode VALUE 'D0BFF4276DA1E208',             "codebs1
   lc_sad TYPE xucode VALUE 'A83ECB9EC4D34C08',
   lc_sae TYPE xucode VALUE '95984B6A25BA20E9',
   lc_saf TYPE hash160x VALUE '8948310AF768FA9061598E8F68FD144CE65B7480',
   lc_tms1a TYPE xucode VALUE '7671D2F2729F27F0',
   lc_tms1b TYPE xucode VALUE '942B9DC0F2394D85',
   lc_tms1d TYPE xucode VALUE '7C6433CE69099272',
   lc_tms1e TYPE xucode VALUE '940BAB0E12A36DC2',
   lc_tms1  TYPE hash160x VALUE 'C9AA19DA354DC8397D7AC8EA8B4C04DF49CB58FF',
   lc_tms2a TYPE xucode VALUE '05CB79BE189802A0',
   lc_tms2b TYPE xucode VALUE 'B7E2F82C0A3E54C4',
   lc_tms2d TYPE xucode VALUE '4DD4438D3C19138C',
   lc_tms2e TYPE xucode VALUE 'D527A90BC0CAF484',
   lc_tms2  TYPE hash160x VALUE 'A6BF38EE57F90B78C8D88A5212BBF1BA9A966ABB'.


*  DATA: BEGIN OF l_usr02 OCCURS 0,
*        mandt   TYPE mandt,
*        bname   TYPE xubname,   "User Name in User Master Record
*        bcode   TYPE xucode,    "Password Hash Key
*        codvn    TYPE xucodever2,  "Code Version of Password Hash Algorithm (New Systems)
*        passcode    TYPE pwd_sha1,  "Password Hash Value (SHA1, 160 Bit)
*        END OF l_usr02.

DATA: BEGIN OF l_usr02 OCCURS 0.
  INCLUDE STRUCTURE USR02.
  DATA: END OF l_usr02.

** Select T000
  SELECT mandt FROM t000 INTO TABLE l_t000.
  IF sy-subrc = 0.
*   Check SAP*
    CLEAR usr02.
*    SELECT mandt
*           bname
*           bcode
*           codvn
*      passcode
*           FROM usr02 CLIENT SPECIFIED  BYPASSING BUFFER INTO TABLE l_usr02
*           FOR ALL ENTRIES IN l_t000
*           WHERE mandt =  l_t000-mandt
*           AND  ( bname =  'SAP*'
*      OR   bname = 'DDIC' OR
*                         bname = 'SAPCPIC' OR  bname = 'EARLYWATCH' ).

*Select * should be used as the structure of USR02 is varying in different SAP releases
* xucodever2, doesnt exist in ECC4.7
   SELECT  * FROM usr02 CLIENT SPECIFIED
           INTO TABLE l_usr02
           FOR ALL ENTRIES IN l_t000
           WHERE mandt =  l_t000-mandt
           AND  ( bname =  'SAP*'
      OR   bname = 'DDIC' OR
                         bname = 'SAPCPIC' OR  bname = 'EARLYWATCH' OR bname = 'TMSADM').

    IF sy-subrc = 0.
      SORT l_usr02 BY mandt bname.
    ENDIF.
  ENDIF.


  LOOP AT l_t000.
    READ TABLE l_usr02 WITH KEY mandt = l_t000-mandt
                                 bname = 'SAP*' BINARY SEARCH.
    IF sy-subrc <> 0.
      PERFORM write_state USING l_t000-mandt 'SAP*' 2.
    ELSE.
      CASE l_usr02-codvn.
        WHEN 'A'.
          IF l_usr02-bcode = codeas1.
            PERFORM write_state USING l_t000-mandt 'SAP*' 3.
          ELSEIF l_usr02-bcode = codeas2.
            PERFORM write_state USING l_t000-mandt 'SAP*' 4.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAP*' 1.
          ENDIF.
        WHEN 'B'.
          IF l_usr02-bcode = codebs1.
            PERFORM write_state USING l_t000-mandt 'SAP*' 3.
          ELSEIF l_usr02-bcode = codebs2.
            PERFORM write_state USING l_t000-mandt 'SAP*' 4.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAP*' 1.
          ENDIF.
**<<<Begin of NDEVABATHINI
        WHEN 'D'.
          IF l_usr02-bcode =  lc_sad.
            PERFORM write_state USING l_t000-mandt 'SAP*' 3.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAP*' 1.
          ENDIF.
        WHEN 'E'.
          IF l_usr02-bcode =  lc_sae.
            PERFORM write_state USING l_t000-mandt 'SAP*' 3.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAP*' 1.
          ENDIF.
        WHEN 'G'.
          IF l_usr02-bcode =  codebs1 AND l_usr02-passcode = lc_saf .
            PERFORM write_state USING l_t000-mandt 'SAP*' 3.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAP*' 1.
          ENDIF.
        WHEN 'F'.
          IF l_usr02-bcode = space .
            PERFORM write_state USING l_t000-mandt 'SAP*' 3.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAP*' 1.
          ENDIF.
           WHEN 'H'.
                      PERFORM write_state USING l_t000-mandt 'SAP*' 10.
        WHEN 'I'.
          IF l_usr02-bcode =  codebs1 AND l_usr02-passcode = lc_saf .
            PERFORM write_state USING l_t000-mandt 'SAP*' 3.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAP*' 1.
          ENDIF.
*>>End of NDEVABATHINI
      ENDCASE.
    ENDIF.

    READ TABLE l_usr02 WITH KEY mandt = l_t000-mandt
                                bname = 'DDIC' BINARY SEARCH.
    IF sy-subrc <> 0.
      PERFORM write_state USING l_t000-mandt 'DDIC' 5.
    ELSE.
      CASE l_usr02-codvn.
        WHEN 'A'.
          IF l_usr02-bcode = codead1.
            PERFORM write_state USING l_t000-mandt 'DDIC' 4.
          ELSEIF l_usr02-bcode = codead2.
            PERFORM write_state USING l_t000-mandt 'DDIC' 4.
          ELSE.
*Begin of Change By Ndevabathini 18-Jan-2012
            PERFORM write_state USING l_t000-mandt 'DDIC' 1.
*            PERFORM write_state USING l_t000-mandt 'DDIC' 4.
*End of Change By Ndevabathini 18-Jan-2012
          ENDIF.
        WHEN 'B'.
          IF l_usr02-bcode = codebd1.
            PERFORM write_state USING l_t000-mandt 'DDIC' 4.
          ELSEIF l_usr02-bcode = codebd2.
            PERFORM write_state USING l_t000-mandt 'DDIC' 4.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'DDIC' 1.
          ENDIF.
        WHEN 'D'.
          IF l_usr02-bcode = lc_ddd.
            PERFORM write_state USING l_t000-mandt 'DDIC' 4.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'DDIC' 1.
          ENDIF.
        WHEN 'E'.
          IF l_usr02-bcode = lc_dde.
            PERFORM write_state USING l_t000-mandt 'DDIC' 4.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'DDIC' 1.
          ENDIF.
        WHEN 'G'.
          IF l_usr02-bcode = codebd2 AND l_usr02-passcode = lc_ddf.
            PERFORM write_state USING l_t000-mandt 'DDIC' 4.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'DDIC' 1.
          ENDIF.
        WHEN 'F'.
          IF l_usr02-bcode = space.
*            Begin of Change by NDEVABA 12-May 2012
*            PERFORM write_state USING l_t000-mandt 'DDIC' 3.
            PERFORM write_state USING l_t000-mandt 'DDIC' 4.
*            End of change by NDEVABA 12-May 2012
          ELSE.
            PERFORM write_state USING l_t000-mandt 'DDIC' 1.
          ENDIF.
           WHEN 'H'.
                      PERFORM write_state USING l_t000-mandt 'DDIC' 10.
        WHEN 'I'.
          IF l_usr02-bcode = codebd2 AND l_usr02-passcode = lc_ddf.
            PERFORM write_state USING l_t000-mandt 'DDIC' 4.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'DDIC' 1.
          ENDIF.

      ENDCASE.
    ENDIF.

READ TABLE l_usr02 WITH KEY mandt = l_t000-mandt
                                bname = 'TMSADM' BINARY SEARCH.
    IF sy-subrc <> 0.
      PERFORM write_state USING l_t000-mandt 'TMSADM' 5.
    ELSE.
      CASE l_usr02-codvn.
        WHEN 'A'.
          IF l_usr02-bcode = codetms1a.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 8.
          ELSEIF l_usr02-bcode = codetms1b.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 8.
            ELSEIF usr02-bcode = codetms2a.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 9.
          ELSEIF usr02-bcode = codetms2b.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 9.
                ELSE.
*Begin of Change By Ndevabathini 18-Jan-2012
            PERFORM write_state USING l_t000-mandt 'TMSADM' 1.
*            PERFORM write_state USING l_t000-mandt 'DDIC' 4.
*End of Change By Ndevabathini 18-Jan-2012
          ENDIF.
        WHEN 'B'.
          IF l_usr02-bcode = codetms1a.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 8.
          ELSEIF usr02-bcode = codetms1b.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 8.
          ELSEIF usr02-bcode = codetms2a.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 9.
          ELSEIF usr02-bcode = codetms2b.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 9.
                    ELSE.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 1.
          ENDIF.
        WHEN 'D'.
          IF l_usr02-bcode = lc_tms1d.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 8.
          ELSEIF l_usr02-bcode = lc_tms2d.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 9.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 1.
          ENDIF.
        WHEN 'E'.
          IF l_usr02-bcode = lc_tms1e.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 8.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 1.
          ENDIF.
        WHEN 'G'.
          IF l_usr02-bcode = codetms1b AND l_usr02-passcode = lc_tms1.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 8.
            ELSEIF l_usr02-bcode = codetms2b AND l_usr02-passcode = lc_tms2.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 9.
                             ELSE.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 1.
          ENDIF.
        WHEN 'F'.
          IF l_usr02-bcode = space.
*            Begin of Change by NDEVABA 12-May 2012
*            PERFORM write_state USING l_t000-mandt 'DDIC' 3.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 8.
*            End of change by NDEVABA 12-May 2012
          ELSE.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 1.
          ENDIF.
           WHEN 'H'.
                      PERFORM write_state USING l_t000-mandt 'TMSADM' 10.
        WHEN 'I'.
          IF l_usr02-bcode = codetms1b AND l_usr02-passcode = lc_tms1.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 8.
            ELSEIF l_usr02-bcode = codetms2b AND l_usr02-passcode = lc_tms2.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 9.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'TMSADM' 1.
          ENDIF.

      ENDCASE.
    ENDIF.

    READ TABLE l_usr02 WITH KEY mandt = l_t000-mandt
                                bname = 'SAPCPIC' BINARY SEARCH.
    IF sy-subrc <> 0.
      PERFORM write_state USING l_t000-mandt 'SAPCPIC' 5.
    ELSE.
      CASE l_usr02-codvn.
        WHEN 'A'.
          IF l_usr02-bcode = codeacp.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 6.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 1.
          ENDIF.
        WHEN 'B'.
          IF l_usr02-bcode = codebcp.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 6.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 1.
          ENDIF.
        WHEN 'D'.
          IF l_usr02-bcode = lc_cpd.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 6.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 1.
          ENDIF.
        WHEN 'E'.
          IF l_usr02-bcode = lc_cpe.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 6.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 1.
          ENDIF.
        WHEN 'G'.
          IF l_usr02-bcode = codebcp AND l_usr02-passcode = lc_cpf1.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 6.
          ELSEIF usr02-bcode = codebcp AND usr02-passcode = lc_cpf2.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 6.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 1.
          ENDIF.
        WHEN 'F'.
          IF l_usr02-bcode = space.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 6.
          ELSEIF l_usr02-passcode = lc_cpf1.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 6.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 1.
          ENDIF.
        WHEN 'H'.
                      PERFORM write_state USING l_t000-mandt 'SAPCPIC' 10.
                WHEN 'I'.
          IF l_usr02-bcode = codebcp AND l_usr02-passcode = lc_cpf1.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 6.
          ELSE.
            PERFORM write_state USING l_t000-mandt 'SAPCPIC' 1.
          ENDIF.
      ENDCASE.
    ENDIF.

    READ TABLE l_usr02 WITH KEY mandt = l_t000-mandt
                                bname = 'EARLYWATCH' BINARY SEARCH.
*    IF sy-subrc = 0.
      IF sy-subrc <> 0.
        IF l_t000-mandt = '066'.
          PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 5.
        ENDIF.
      ELSE.
        CASE l_usr02-codvn.
          WHEN 'A'.
            IF usr02-bcode = codeaew.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 7.
            ELSE.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 1.
            ENDIF.
          WHEN 'B'.
            IF l_usr02-bcode = codebew.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 7.
            ELSE.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 1.
            ENDIF.
          WHEN 'D'.
            IF l_usr02-bcode = lc_ewd.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 7.
            ELSE.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 1.
            ENDIF.
          WHEN 'E'.
            IF l_usr02-bcode = lc_ewe.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 7.
            ELSE.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 1.
            ENDIF.
          WHEN 'G'.
            IF l_usr02-bcode = codebew AND l_usr02-passcode = lc_ewf1.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 7.
            ELSEIF l_usr02-bcode = codebew AND l_usr02-passcode = lc_ewf2.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 7.
            ELSE.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 1.
            ENDIF.
 WHEN 'H'.
                      PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 10.
          WHEN 'F'.
            IF l_usr02-bcode = space.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 7.
            ELSEIF l_usr02-passcode =  lc_ewf1 .
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 7.
            ELSE.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 1.
            ENDIF.
          WHEN 'I'.
            IF l_usr02-bcode = codebew AND l_usr02-passcode = lc_ewf1.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 7.
            ELSE.
              PERFORM write_state USING l_t000-mandt 'EARLYWATCH' 1.
            ENDIF.
        ENDCASE.
      ENDIF.
*    ENDIF.
  ENDLOOP.

  ULINE /(80).
  CLEAR usr02.

** Concatenate filepath
  CONCATENATE path 'spDefaults.txt'(051) INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES g_defaults USING gv_path.
  ELSE.
    PERFORM download_server TABLES g_defaults USING gv_path.
  ENDIF.


ENDFORM.                    " spdefaults
*&---------------------------------------------------------------------*
*&      Form  WRITE_STATE
*&---------------------------------------------------------------------*
*       Sets appropriate text based on state id. Code for this routine
*       has been adopted from standard program RSUSR003 and modified.
*----------------------------------------------------------------------*
*      -->MANDT     Client
*      -->USER      User id
*      -->STATE_ID  State id
*----------------------------------------------------------------------*
FORM write_state  USING    p_mandt
                           p_bname
                           p_state_id.

  DATA: sapstar_value(60).

  g_defaults-mandt = p_mandt.
  g_defaults-bname = p_bname.


  CASE p_state_id.
    WHEN 1.
      g_defaults-status = 'Exists; Password not trivial.'(052).
      APPEND g_defaults.
      CLEAR  g_defaults.
    WHEN 2.
      CLEAR sapstar_value.
      CALL 'C_SAPGPARAM' ID 'NAME'
                               FIELD 'login/no_automatic_user_sapstar'
                         ID 'VALUE' FIELD sapstar_value.

      IF sapstar_value = '1'.

        CONCATENATE 'Does not exist. Logon not possible.'(053)
                    'See SAP Note 2383'(054)
          INTO g_defaults-status.

      ELSE.
        CONCATENATE 'Does not exist.Logon possible with p/w PASS.'(055)
                    'See Note 2383'(056)
          INTO g_defaults-status.
      ENDIF.
      APPEND g_defaults.
      CLEAR  g_defaults.
    WHEN 3.
      g_defaults-status = 'Password 06071992 well known.'(057).
      APPEND g_defaults.
      CLEAR  g_defaults.

    WHEN 4.
      g_defaults-status = 'Password 19920706 well known.'(058).
      APPEND g_defaults.
      CLEAR  g_defaults.
    WHEN 5.
      g_defaults-status = 'Does not exist.'(059).
      APPEND g_defaults.
      CLEAR  g_defaults.
    WHEN 6.
      g_defaults-status =
      'Password ADMIN well known. See SAP Note 29276'(060).
      APPEND g_defaults.
      CLEAR  g_defaults.
    WHEN 7.
      g_defaults-status = 'Password SUPPORT well known.'(061).
      APPEND g_defaults.
      CLEAR  g_defaults.
      WHEN 8.
      g_defaults-status = 'Password PASSWORD well known.'(062).
      APPEND g_defaults.
      CLEAR  g_defaults.
      WHEN 9.
      g_defaults-status = 'Password $1Pawd2& well known.'(063).
      APPEND g_defaults.
      CLEAR  g_defaults.
      WHEN 10.
      g_defaults-status = 'Salted hash, check RSUSR003 in SAP.'(064).
      APPEND g_defaults.
      CLEAR  g_defaults.
  ENDCASE.


ENDFORM.                    " WRITE_STATE
*&---------------------------------------------------------------------*
*&      Form  spProfiles
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM spprofiles .


  DATA:
    l_total_recs LIKE sy-dbcnt,
    i_count TYPE i VALUE 0, "status bar
    i_perc TYPE p. "status bar

SELECT mandt
profn
typ
nraut
auths
*Begin of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
*INTO TABLE g_usr10 BYPASSING BUFFER
INTO TABLE g_usr10
*End of change: ReSQ Correction for BYPASS BUFFER 19/12/2019 EY_DES04 ECDK917080 *
FROM usr10 CLIENT SPECIFIED
FOR ALL ENTRIES IN g_t000
WHERE mandt EQ g_t000-mandt AND
aktps EQ 'A' AND
typ EQ 'C'.

  l_total_recs = sy-dbcnt.

  LOOP AT g_usr10.

* status bar
    i_count = i_count + 1.
    i_perc = i_count / l_total_recs * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = i_perc
        text       = 'Compiling spProfiles.txt'(062).


    CLEAR g_profiles.

    g_profiles-mandt = g_usr10-mandt.
    g_profiles-profn = g_usr10-profn.

    PERFORM get_singles USING g_usr10-nraut
                              g_usr10-auths.


  ENDLOOP.

** Concatenate filepath
  CLEAR gv_path.
  CONCATENATE path 'spProfiles.txt'(063) INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES g_profiles USING gv_path.
  ELSE.
    PERFORM download_server TABLES g_profiles USING gv_path.
  ENDIF.

  DESCRIBE TABLE g_profiles LINES sy-tfill.
  WRITE :/ 'Composite Profiles'(064), 40 sy-tfill.


ENDFORM.                    " spProfiles
*&---------------------------------------------------------------------*
*&      Form  get_singles
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_USR10_NRAUT  text
*      -->P_L_USR10_AUTHS  text
*----------------------------------------------------------------------*
FORM get_singles  USING    value(p_nraut) TYPE usr10-nraut
                           value(p_auths) TYPE usr10-auths.

  DATA:
    i_nrpro TYPE i VALUE 0.

  i_nrpro = ( p_nraut - 2 ) / 12.

  SHIFT p_auths LEFT BY 2 PLACES.

  DO i_nrpro TIMES.
    g_profiles-profn_single = p_auths(12).

    READ TABLE g_usr10 WITH KEY profn = g_profiles-profn_single.
    IF sy-subrc NE 0.
      READ TABLE g_profiles
        WITH KEY mandt        = g_profiles-mandt
                 profn        = g_profiles-profn
                 profn_single = g_profiles-profn_single
        TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        APPEND g_profiles.
      ENDIF.
      SHIFT p_auths LEFT BY 12 PLACES.
    ELSE.
      PERFORM get_singles USING g_usr10-nraut
                                g_usr10-auths.
      SHIFT p_auths LEFT BY 12 PLACES.
    ENDIF.
  ENDDO.

ENDFORM.                    " get_singles
