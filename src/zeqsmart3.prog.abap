*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Program name: ZEQSMART3                     Date written: yyyy.mm.dd *
* Authors name:   Deloitte                                   *
* Program title:  eQSmart download program 4.7, ECC5 and ECC6	       *
* Corr. version: V3.3 15-11-2012                                       *
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
*                                                                      *
*----------------------------------------------------------------------*
* Quality assured by:                                                  *
* Date              :                                                  *
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
* RKuijpers          15-11-2012    1.brackets on line 842 changed from *
*                                  [] to () because of errors that     *
*                                  occurred for SAP ECC 6.0 EHP 5      *
*----------------------------------------------------------------------*

REPORT zeq20secdwn3 .
**--------------------------------------------------------------------**
* DATA DECLARATIONS
**--------------------------------------------------------------------**
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
      gv_path TYPE string.


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
  lvers1 = 'R/3 Version:'.
  vers1 = sy-saprl.
  lrole1 = 'User Assigned:'.
  IF sy-saprl+0(1) = '3'.
    role1 = 'Profiles only.'.
  ELSE.
    role1 = 'Roles and Profiles.'.
  ENDIF.

  gc_langu = 'Language Key'.
  cpath    = 'Download Directory'.
  opt1     = 'System Information'.
  opt2     = 'Download Options'.
  cclient  = 'R/3 Client'.
  ccliento = ' to '.
  cloc     = 'Download to local PC'.
  cbak     = 'Note, uncheck for background execution.'.

  CLEAR pahi.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM pahi WHERE parstate = 'A'
*    AND parname = 'abap/timeout'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM pahi WHERE parstate = 'A'
    AND parname = 'abap/timeout' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  p_langu = syst-langu.

  IF sy-subrc = 0.
    IF pahi-parvalue < 512.
      CONCATENATE 'ABAP Program timeout set to '
        pahi-parvalue 'seconds. Background execution recommended.'
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
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM t000 WHERE mandt GE clientf AND mandt LE clientt.
*
* NEW CODE
  SELECT *
 FROM t000 WHERE mandt GE clientf AND mandt LE clientt ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    MOVE-CORRESPONDING t000 TO g_t000.
    CASE t000-cccoractiv.
      WHEN '1'.
        MOVE 'Auto-recording of changes in transport request' TO
    g_t000-change.
      WHEN '2'.
        MOVE 'No customizing changes allowed' TO g_t000-change.
      WHEN '3'.
        MOVE 'Customizing possible, but no transport allowed'
    TO g_t000-change.
      WHEN OTHERS.
        MOVE 'Customizing possible without automatic recording' TO
    g_t000-change.
    ENDCASE.
    MOVE sy-datum TO g_t000-date.
    APPEND g_t000.

  ENDSELECT.

* Begin of Changes done at R10 by Arnab and Vishal

* Fetching the EDTFLAG for Program ID 'HEAD' and Object 'SYST'
  SELECT  edtflag    "Flag : Object can be edited with special editor
    FROM  tadir
      UP  TO  1 ROWS
    INTO  lv_edtflag
   WHERE  pgmid  EQ 'HEAD'
     AND  object EQ 'SYST'.
  ENDSELECT.

  IF sy-subrc EQ 0 AND lv_edtflag EQ 'N'.
* If EDTFLAG is equal to 'N'
    g_t000-sys_chg = 'Not Modifiable'.
    MODIFY g_t000 TRANSPORTING sys_chg WHERE mandt IS NOT INITIAL.
  ELSE.
* If EDTFLAG is not 'N'
    g_t000-sys_chg = 'Modifiable'.
    MODIFY g_t000 TRANSPORTING sys_chg WHERE mandt IS NOT INITIAL.
  ENDIF.

* End of Changes done at R10 by Arnab and Vishal

** Concatenate filepath
  CONCATENATE path 'spClients.txt' INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES g_t000 USING gv_path.
  ELSE.
    PERFORM download_server TABLES g_t000 USING gv_path.
  ENDIF.

  DESCRIBE TABLE g_t000 LINES sy-tfill.
  WRITE :/ 'Download from version ', sy-saprl, ' system.'.
  WRITE :/ 'Clients', 40 sy-tfill.


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

  CLEAR gv_path.

  LOOP AT g_t000.

* status bar
    DESCRIBE TABLE g_t000 LINES sy-tfill.
    i_count_mandt = i_count_mandt + 1.
    i_perc = i_count_mandt / sy-tfill * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = i_perc
        text       = 'Compiling spUsers.txt'.

**  Select usr02
    CLEAR: usr02.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM usr02 CLIENT SPECIFIED WHERE mandt EQ g_t000-mandt.
*
* NEW CODE
    SELECT *
 FROM usr02 CLIENT SPECIFIED WHERE mandt EQ g_t000-mandt ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

      CHECK usr02-bname NE space.
      MOVE-CORRESPONDING usr02 TO g_usr02.
      IF usr02-gltgv = '00000000'.
        g_usr02-valfr = usr02-erdat.
      ELSE.
        g_usr02-valfr = usr02-gltgv.
      ENDIF.
      IF usr02-gltgb = '00000000'.
        g_usr02-valto = '99991231'.
      ELSE.
        g_usr02-valto = usr02-gltgb.
      ENDIF.
      IF usr02-trdat NE 0.
        g_usr02-idays = sy-datum - usr02-trdat.
      ELSE.
        g_usr02-idays = 99999.
      ENDIF.

      n_uflag       = usr02-uflag.
      g_usr02-uflag = n_uflag.

      CLEAR user_usr03.

*  Start of addition by KREDDY
      PERFORM get_usr03 USING usr02-bname g_t000-mandt.

      CALL FUNCTION 'SUSR_USER_ADDRESS_READ'
        EXPORTING
          user_name              = usr02-bname
        IMPORTING
          user_usr03             = user_usr03
        EXCEPTIONS
          user_address_not_found = 1
          OTHERS                 = 2.

      IF NOT user_usr03-name1 IS INITIAL.
        CONCATENATE user_usr03-name1 user_usr03-name2 INTO g_usr02-name1
                                     SEPARATED BY space.
      ELSE.
        CONCATENATE user_usr03-name1 user_usr03-name2 INTO g_usr02-name1
 .
      ENDIF.
* End of addition by KREDDY

* Start of addition by KREDDY
      IF g_usr02-name1 IS INITIAL.
* If name1 is blank then move id to name1
        MOVE usr02-bname TO g_usr02-name1.
      ENDIF.
* End of addition by KREDDY

      APPEND g_usr02.

    ENDSELECT.

  ENDLOOP.

** Concatenate filepath
  CONCATENATE path 'spUsers.txt' INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES g_usr02 USING gv_path.
  ELSE.
    PERFORM download_server TABLES g_usr02 USING gv_path.
  ENDIF.

  DESCRIBE TABLE g_usr02 LINES sy-tfill.
  WRITE :/ 'Users', 40 sy-tfill.

ENDFORM.                    "SPUSERS

*&---------------------------------------------------------------------*
*&      Form  spUsersandRoles
*&---------------------------------------------------------------------*
*       Get roles and profiles directly attached to users from
*       AGR_USERS and UST04
*----------------------------------------------------------------------*
FORM spusersandroles.

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

  LOOP AT g_usr02.

* status bar
    i_count_users = i_count_users + 1.
    i_perc = i_count_users / l_total_recs * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = i_perc
        text       = 'Compiling spUsersandRoles.txt'.

    IF sy-saprl+0(1) <> '3'.
      TABLES: agr_users. "Roles assigned to Users

** Select agr_users
      CLEAR agr_users.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT mandt
*             uname
*             agr_name
*        FROM agr_users CLIENT SPECIFIED
*        APPENDING TABLE l_usrol
*        WHERE uname EQ g_usr02-bname
*        AND mandt EQ g_usr02-mandt
*        AND from_dat LE sy-datum
*        AND to_dat GE sy-datum.
*
* NEW CODE
      SELECT mandt
             uname
             agr_name

        FROM agr_users CLIENT SPECIFIED
        APPENDING TABLE l_usrol
        WHERE uname EQ g_usr02-bname
        AND mandt EQ g_usr02-mandt
        AND from_dat LE sy-datum
        AND to_dat GE sy-datum ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    ENDIF.

* Select ust04
    CLEAR ust04.
* Begin of change Deloitte R10 Ritesh 06-Sep-2007   >>>>> 3
*    SELECT mandt
*           bname
*           profile
*      FROM ust04 CLIENT SPECIFIED
*      APPENDING TABLE l_usrol
*      WHERE mandt EQ g_usr02-mandt
*      AND bname EQ g_usr02-bname.
*Exclude generated roles from SPUSERSANDROLES
    SELECT ust04~mandt
           ust04~bname
           ust04~profile
      APPENDING TABLE l_usrol
      FROM ust04
      INNER JOIN usr10 ON ust04~mandt   = usr10~mandt AND
                          ust04~profile = usr10~profn
      CLIENT specified
      WHERE ust04~mandt EQ g_usr02-mandt
      AND ust04~bname EQ g_usr02-bname
      AND usr10~aktps = 'A'
      AND usr10~typ  NE 'G'.
* End of change Deloitte R10 Ritesh   06-Sep-2007  >>>>> 3
  ENDLOOP.

  SORT l_usrol.
  DELETE ADJACENT DUPLICATES FROM l_usrol COMPARING ALL FIELDS.

** Concatenate filepath
  CONCATENATE path 'spUsersandRoles.txt' INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES l_usrol USING gv_path.
  ELSE.
    PERFORM download_server TABLES l_usrol USING gv_path.
  ENDIF.

  DESCRIBE TABLE l_usrol LINES sy-tfill.
  WRITE :/ 'Users and Roles', 40 sy-tfill.
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
        text       = 'Compiling Roles into spRoles.txt'.

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

*Begin of change Deloitte R10 Ritesh 06-Sep-2007
*                         Exclude Generated profiles. >>>>> 1
* Getting texts for all profiles in the system
*  SELECT usr10~mandt
*         usr10~profn
*         usr10~modbe
*         usr11~ptext
*    INTO TABLE l_profiles
*    FROM usr10
*    LEFT OUTER JOIN usr11
*      ON usr11~mandt = usr10~mandt AND
*         usr11~profn = usr10~profn AND
*         usr11~langu = p_langu     AND
*         usr11~aktps = 'A'
*    CLIENT specified
*    FOR ALL ENTRIES IN g_t000
*    WHERE usr10~mandt = g_t000-mandt and
*          usr10~aktps = 'A'.

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
        text       = 'Compiling Profiles into spRoles.txt'.

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

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT mandt
*         profn
*         modbe
*    INTO TABLE l_usr10
*    FROM usr10 CLIENT SPECIFIED
*    FOR ALL ENTRIES IN g_agr_1251
*    WHERE mandt EQ g_agr_1251-mandt AND
*          profn = g_agr_1251-profn.
*
* NEW CODE
  SELECT mandt
         profn
         modbe

    INTO TABLE l_usr10
    FROM usr10 CLIENT SPECIFIED
    FOR ALL ENTRIES IN g_agr_1251
    WHERE mandt EQ g_agr_1251-mandt AND
          profn = g_agr_1251-profn ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*Begin of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 19/12/2019 EY_DES04 ECDK917080 *
SORT L_USR10 BY MANDT PROFN .
*End of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 19/12/2019 EY_DES04 ECDK917080 *
  LOOP AT g_agr_1251 WHERE agr_name = space.
    READ TABLE g_agr_texts WITH KEY mandt   = g_agr_1251-mandt
                                   agr_name(12) = g_agr_1251-profn.
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
  WRITE :/ 'Roles', 40 sy-tfill.

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

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT mandt
*         profn
*         nraut
*         auths
*    INTO TABLE l_usr10_data
*    FROM usr10 CLIENT SPECIFIED
*    FOR ALL ENTRIES IN g_t000
*    WHERE mandt EQ g_t000-mandt AND
*          aktps EQ 'A'          AND
*          typ   NE 'C'.
*
* NEW CODE
  SELECT mandt
         profn
         nraut
         auths

    INTO TABLE l_usr10_data
    FROM usr10 CLIENT SPECIFIED
    FOR ALL ENTRIES IN g_t000
    WHERE mandt EQ g_t000-mandt AND
          aktps EQ 'A'          AND
          typ   NE 'C' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  l_total_recs = sy-dbcnt.

  LOOP AT l_usr10_data.
* status bar
    i_count = i_count + 1.
    i_perc = i_count / l_total_recs * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = i_perc
        text       = 'Compiling spAuthorisations.txt'.


    CLEAR l_agr_1251.

    l_agr_1251-mandt = l_usr10_data-mandt.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE agr_name
*      FROM agr_1016 CLIENT SPECIFIED
*      INTO l_agr_1251-agr_name
*      WHERE mandt   = l_usr10_data-mandt AND
*            profile = l_usr10_data-profn.
*
* NEW CODE
    SELECT agr_name
    UP TO 1 ROWS 
      FROM agr_1016 CLIENT SPECIFIED
      INTO l_agr_1251-agr_name
      WHERE mandt   = l_usr10_data-mandt AND
            profile = l_usr10_data-profn ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

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
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM usr12 CLIENT SPECIFIED
*        WHERE mandt = l_usr10_data-mandt
*        AND objct = l_usr10-objct
*        AND auth = l_usr10-auths
*        AND aktps = 'A'.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM usr12 CLIENT SPECIFIED
        WHERE mandt = l_usr10_data-mandt
        AND objct = l_usr10-objct
        AND auth = l_usr10-auths
        AND aktps = 'A' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

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
  CONCATENATE path 'spAuthorisations.txt' INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES l_agr_1251 USING gv_path.
  ELSE.
    PERFORM download_server TABLES l_agr_1251 USING gv_path.
  ENDIF.

  DESCRIBE TABLE l_agr_1251 LINES sy-tfill.
  WRITE :/ 'Authorisation Values', 40 sy-tfill.

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

** Select table for development user
  CLEAR devaccess.
  SELECT * FROM devaccess.

** Select logon data
    CLEAR usr02.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM usr02 CLIENT SPECIFIED
*      WHERE bname EQ devaccess-uname
*        AND mandt GE clientf AND mandt LE clientt.
*
* NEW CODE
    SELECT *
 FROM usr02 CLIENT SPECIFIED
      WHERE bname EQ devaccess-uname
        AND mandt GE clientf AND mandt LE clientt ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
** Select clients
      CLEAR t000.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM t000
*      WHERE mandt = usr02-mandt.
*
* NEW CODE
      SELECT *
 FROM t000
      WHERE mandt = usr02-mandt ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        MOVE-CORRESPONDING devaccess TO o_devacc.
        o_devacc-mandt = usr02-mandt.
        COLLECT o_devacc.
      ENDSELECT.
    ENDSELECT.
  ENDSELECT.

** Concatenate filepath
  CONCATENATE path 'spDevelopers.txt' INTO gv_path.

** Download tabl to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES o_devacc USING gv_path.
  ELSE.
    PERFORM download_server TABLES o_devacc USING gv_path.
  ENDIF.

  DESCRIBE TABLE o_devacc LINES sy-tfill.
  WRITE :/ 'Developers', 40 sy-tfill.

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
  SELECT * FROM usr40 INTO TABLE lit_usr40.

** Concatenate filepath
  CONCATENATE path 'spPasswords.txt' INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES lit_usr40 USING gv_path.
  ELSE.
    PERFORM download_server TABLES lit_usr40 USING gv_path.
  ENDIF.

  DESCRIBE TABLE lit_usr40 LINES sy-tfill.
  WRITE :/ 'Prohibited Passwords', 40 sy-tfill.

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
          hostname(8),
          systemid(2),
          pardate(8),
          parname(64),
          parstate(1),
          parvalue(64),
        END OF t_pahi.

  CLEAR gv_path.

** Select history of system, DB and SAP parameter
  CLEAR pahi.
  SELECT * FROM pahi.

    MOVE-CORRESPONDING pahi TO t_pahi.
    APPEND t_pahi.
  ENDSELECT.

** Concatenate filepath
  CONCATENATE path 'spParameters.txt' INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES t_pahi USING gv_path.
  ELSE.
    PERFORM download_server TABLES t_pahi USING gv_path.
  ENDIF.

  DESCRIBE TABLE t_pahi LINES sy-tfill.
  WRITE :/ 'Parameters', 40 sy-tfill.

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

  CLEAR gv_path.

** Select relation Transaction   > Auth. Object (Customer)
  CLEAR usobt_c.
  SELECT * FROM usobt_c.
    IF usobt_c-low+0(1) = '$'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM usvart
*        WHERE varbl = usobt_c-low
*        AND langu = p_langu.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM usvart
        WHERE varbl = usobt_c-low
        AND langu = p_langu ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      t_usobt_c-low = usvart-vtext.
    ELSE.
      t_usobt_c-low = usobt_c-low.
    ENDIF.

    t_usobt_c-name = usobt_c-name.
    t_usobt_c-object = usobt_c-object.
    t_usobt_c-field = usobt_c-field.
    APPEND t_usobt_c.
  ENDSELECT.

** Concatenate filepath
  CONCATENATE path 'spTransactions.txt' INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES t_usobt_c USING gv_path.
  ELSE.
    PERFORM download_server TABLES t_usobt_c USING gv_path.
  ENDIF.

  DESCRIBE TABLE t_usobt_c LINES sy-tfill.
  WRITE :/ 'Transaction to Authorisation Objects C/M', 40 sy-tfill.

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
**mod ini
*  SELECT DISTINCT vtext FROM usvart INTO TABLE t_usvart WHERE langu =
*  p_langu.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT vtext FROM usvart
*  INTO TABLE t_usvart
*  WHERE langu = p_langu.
*
* NEW CODE
  SELECT vtext
 FROM usvart
  INTO TABLE t_usvart
  WHERE langu = p_langu ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  SORT t_usvart BY vtext.
  DELETE ADJACENT DUPLICATES FROM t_usvart COMPARING vtext.
**mod fin
** Concatenate filepath
  CONCATENATE path 'spVariables.txt' INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES t_usvart USING gv_path.
  ELSE.
    PERFORM download_server TABLES t_usvart USING gv_path.
  ENDIF.

  DESCRIBE TABLE t_usvart LINES sy-tfill.
  WRITE :/ 'Variables', 40 sy-tfill.

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
    TABLES
      data_tab         = lit_table
    EXCEPTIONS
      file_write_error = 1.

  IF sy-subrc = 1.
    WRITE: / 'Invalid Directory:',lv_path,'Please select an'.
    WRITE / 'already existing directory and try again.'.
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

** Only in SAP R/3 version 4.7 and higher
  OPEN DATASET lv_path IN TEXT MODE ENCODING DEFAULT FOR OUTPUT.

** Only in SAP R/3 version 4.6c and lower
*  OPEN DATASET lv_path IN TEXT MODE FOR OUTPUT.
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
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM usr21
*                               CLIENT SPECIFIED
*                               WHERE bname = bname
*                               AND   mandt = mandt.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM usr21
                               CLIENT SPECIFIED
                               WHERE bname = bname
                               AND   mandt = mandt ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

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
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT  mandt
*          agr_name
*          child_agr
*    FROM  agr_agrs CLIENT SPECIFIED
*    INTO  TABLE g_comp
*    FOR  ALL ENTRIES IN g_t000
*    WHERE  mandt EQ g_t000-mandt.
*
* NEW CODE
  SELECT mandt
          agr_name
          child_agr

    FROM  agr_agrs CLIENT SPECIFIED
    INTO  TABLE g_comp
    FOR  ALL ENTRIES IN g_t000
    WHERE  mandt EQ g_t000-mandt ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

** Concatenate filepath
  CONCATENATE path 'spComposites.txt' INTO gv_path.

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

  TABLES: tstc.

* Selecting the Tcode from the TSTC Table
  SELECT * FROM tstc.
* Checking whether the Tcode is Locked or not
    IF tstc-cinfo O x20.
      g_tcode-tcode = tstc-tcode.
* If the Tcode is locked fetch the Tcode Text from TSTCT Table
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT  SINGLE ttext
*        FROM  tstct
*        INTO  g_tcode-ttext
*       WHERE  sprsl EQ p_langu
*         AND  tcode EQ tstc-tcode.
*
* NEW CODE
      SELECT ttext
      UP TO 1 ROWS 
        FROM  tstct
        INTO  g_tcode-ttext
       WHERE  sprsl EQ p_langu
         AND  tcode EQ tstc-tcode ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      APPEND g_tcode.
      CLEAR  g_tcode.
    ENDIF.
  ENDSELECT.

** Concatenate filepath
  CONCATENATE path 'spLockedtcodes.txt' INTO gv_path.

** Download tabl to frontend or server
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
        codebew LIKE usr02-bcode VALUE 'BD5E494D3ECBF5E2'.

  DATA:
    BEGIN OF l_t000 OCCURS 10,
      mandt LIKE t000-mandt,
    END OF l_t000.

* Check every client
  SELECT mandt INTO t000-mandt FROM t000.

*   Check SAP*
    CLEAR usr02.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM usr02 CLIENT SPECIFIED
*           WHERE mandt = t000-mandt
*           AND   bname = 'SAP*'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM usr02 CLIENT SPECIFIED
           WHERE mandt = t000-mandt
           AND   bname = 'SAP*' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc <> 0.
      PERFORM write_state USING t000-mandt 'SAP*' 2.
    ELSE.
      CASE usr02-codvn.
        WHEN 'A'.
          IF usr02-bcode = codeas1.
            PERFORM write_state USING t000-mandt 'SAP*' 3.
          ELSEIF usr02-bcode = codeas2.
            PERFORM write_state USING t000-mandt 'SAP*' 4.
          ELSE.
            PERFORM write_state USING t000-mandt 'SAP*' 1.
          ENDIF.
        WHEN 'B'.
          IF usr02-bcode = codebs1.
            PERFORM write_state USING t000-mandt 'SAP*' 3.
          ELSEIF usr02-bcode = codebs2.
            PERFORM write_state USING t000-mandt 'SAP*' 4.
          ELSE.
            PERFORM write_state USING t000-mandt 'SAP*' 1.
          ENDIF.
      ENDCASE.
    ENDIF.

*   Check DDIC
    CLEAR usr02.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM usr02 CLIENT SPECIFIED
*           WHERE mandt = t000-mandt
*           AND   bname = 'DDIC'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM usr02 CLIENT SPECIFIED
           WHERE mandt = t000-mandt
           AND   bname = 'DDIC' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc <> 0.
      PERFORM write_state USING t000-mandt 'DDIC' 5.
    ELSE.
      CASE usr02-codvn.
        WHEN 'A'.
          IF usr02-bcode = codead1.
            PERFORM write_state USING t000-mandt 'DDIC' 3.
          ELSEIF usr02-bcode = codead2.
            PERFORM write_state USING t000-mandt 'DDIC' 4.
          ELSE.
            PERFORM write_state USING t000-mandt 'DDIC' 1.
          ENDIF.
        WHEN 'B'.
          IF usr02-bcode = codebd1.
            PERFORM write_state USING t000-mandt 'DDIC' 3.
          ELSEIF usr02-bcode = codebd2.
            PERFORM write_state USING t000-mandt 'DDIC' 4.
          ELSE.
            PERFORM write_state USING t000-mandt 'DDIC' 1.
          ENDIF.
      ENDCASE.
    ENDIF.

*   Check SAPCPIC
    CLEAR usr02.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM usr02 CLIENT SPECIFIED
*           WHERE mandt = t000-mandt
*           AND   bname = 'SAPCPIC'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM usr02 CLIENT SPECIFIED
           WHERE mandt = t000-mandt
           AND   bname = 'SAPCPIC' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc <> 0.
      PERFORM write_state USING t000-mandt 'SAPCPIC' 5.
    ELSE.
      CASE usr02-codvn.
        WHEN 'A'.
          IF usr02-bcode = codeacp.
            PERFORM write_state USING t000-mandt 'SAPCPIC' 6.
          ELSE.
            PERFORM write_state USING t000-mandt 'SAPCPIC' 1.
          ENDIF.
        WHEN 'B'.
          IF usr02-bcode = codebcp.
            PERFORM write_state USING t000-mandt 'SAPCPIC' 6.
          ELSE.
            PERFORM write_state USING t000-mandt 'SAPCPIC' 1.
          ENDIF.
      ENDCASE.
    ENDIF.

*   Check EARLYWATCH
    CLEAR usr02.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM usr02 CLIENT SPECIFIED
*           WHERE mandt = t000-mandt
*           AND   bname = 'EARLYWATCH'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM usr02 CLIENT SPECIFIED
           WHERE mandt = t000-mandt
           AND   bname = 'EARLYWATCH' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc <> 0.
      IF t000-mandt = '066'.
        PERFORM write_state USING t000-mandt 'EARLYWATCH' 5.
      ENDIF.
    ELSE.
      CASE usr02-codvn.
        WHEN 'A'.
          IF usr02-bcode = codeaew.
            PERFORM write_state USING t000-mandt 'EARLYWATCH' 7.
          ELSE.
            PERFORM write_state USING t000-mandt 'EARLYWATCH' 1.
          ENDIF.
        WHEN 'B'.
          IF usr02-bcode = codebew.
            PERFORM write_state USING t000-mandt 'EARLYWATCH' 7.
          ELSE.
            PERFORM write_state USING t000-mandt 'EARLYWATCH' 1.
          ENDIF.
      ENDCASE.
    ENDIF.

  ENDSELECT.
  ULINE /(80).
  CLEAR usr02.

** Concatenate filepath
  CONCATENATE path 'spDefaults.txt' INTO gv_path.

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
      g_defaults-status = 'Exists; Password not trivial.'.
      APPEND g_defaults.
      CLEAR  g_defaults.
    WHEN 2.
      CLEAR sapstar_value.
**add comment ini
      CALL 'C_SAPGPARAM' ID 'NAME'
                               FIELD 'login/no_automatic_user_sapstar'
                         ID 'VALUE' FIELD sapstar_value."#EC CI_CCALL
**add comment fin
      IF sapstar_value = '1'.

        CONCATENATE 'Does not exist. Logon not possible. '
                    'See SAP Note 2383'
          INTO g_defaults-status.

      ELSE.
        CONCATENATE 'Does not exist.Logon possible with p/w PASS. '
                    'See Note 2383'
          INTO g_defaults-status.
      ENDIF.
      APPEND g_defaults.
      CLEAR  g_defaults.
    WHEN 3.
      g_defaults-status = 'Password 06071992 well known.'.
      APPEND g_defaults.
      CLEAR  g_defaults.

    WHEN 4.
      g_defaults-status = 'Password 19920706 well known.'.
      APPEND g_defaults.
      CLEAR  g_defaults.
    WHEN 5.
      g_defaults-status = 'Does not exist.'.
      APPEND g_defaults.
      CLEAR  g_defaults.
    WHEN 6.
      g_defaults-status =
      'Password ADMIN well known. See SAP Note 29276'.
      APPEND g_defaults.
      CLEAR  g_defaults.
    WHEN 7.
      g_defaults-status = 'Password SUPPORT well known.'.
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

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT mandt
*         profn
*         typ
*         nraut
*         auths
*    INTO TABLE g_usr10
*    FROM usr10 CLIENT SPECIFIED
*    FOR ALL ENTRIES IN g_t000
*    WHERE mandt EQ g_t000-mandt AND
*          aktps EQ 'A'          AND
*          typ   EQ 'C'.
*
* NEW CODE
  SELECT mandt
         profn
         typ
         nraut
         auths

    INTO TABLE g_usr10
    FROM usr10 CLIENT SPECIFIED
    FOR ALL ENTRIES IN g_t000
    WHERE mandt EQ g_t000-mandt AND
          aktps EQ 'A'          AND
          typ   EQ 'C' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  l_total_recs = sy-dbcnt.

  LOOP AT g_usr10.

* status bar
    i_count = i_count + 1.
    i_perc = i_count / l_total_recs * 100.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = i_perc
        text       = 'Compiling spProfiles.txt'.


    CLEAR g_profiles.

    g_profiles-mandt = g_usr10-mandt.
    g_profiles-profn = g_usr10-profn.

    PERFORM get_singles USING g_usr10-nraut
                              g_usr10-auths.


  ENDLOOP.

** Concatenate filepath
  CLEAR gv_path.
  CONCATENATE path 'spProfiles.txt' INTO gv_path.

** Download table to frontend or server
  IF loc = 'X'.
    PERFORM download_local TABLES g_profiles USING gv_path.
  ELSE.
    PERFORM download_server TABLES g_profiles USING gv_path.
  ENDIF.

  DESCRIBE TABLE g_profiles LINES sy-tfill.
  WRITE :/ 'Composite Profiles', 40 sy-tfill.


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
