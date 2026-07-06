*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <23-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
************************************************************************
**  This include file contains the PBO and PAI modules of screen 0001 **
**  of program RSWATCH0.  It also contains the 'F4' Help module.      **
**                                                                    **
**  Created/Last changed   Sept. 98                                   **
************************************************************************

MODULE STATUS_0001 OUTPUT.
   SET PF-STATUS 'USRDIRMN'.
   SET TITLEBAR '500'.
   SELECT * FROM USER_DIR INTO IUSER_DIR
      WHERE DIRNAME = A_DIRNAME.
   ENDSELECT.

ENDMODULE.                 " STATUS_0001  OUTPUT

*----------------------------------------------------------------------*
*  MODULE USER_COMMAND_0001 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_0001 INPUT.

  DATA txt TYPE string.

IF ( OKCODE = 'END' ) or ( okcode = 'EXIT' ).
  IF CHANGED = ' '.
    SET SCREEN 0.
    LEAVE SCREEN.
  ELSEIF SAVED = 'Y'.
    SAVED = ' '.
    SET SCREEN 0.
    LEAVE SCREEN.
  ELSE.
    IF IUSER_DIR-DIRNAME IS INITIAL.
      SET SCREEN 0.
      LEAVE SCREEN.
    ELSE.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
          EXPORTING
            textline1     = 'Data has not been saved.  '
                    TEXTLINE2      = 'Do you want to save data? '
                    TITEL          = ' '
                    DEFAULTOPTION  = 'N'
          IMPORTING
            answer        = my_answer
          EXCEPTIONS
            OTHERS        = 22.
      IF SY-SUBRC = 0.
        CASE MY_ANSWER.
          WHEN 'N'.
            SET SCREEN 0.
            LEAVE SCREEN.
          WHEN 'J'.
            IF IUSER_DIR-SVRNAME EQ SPACE.
                iuser_dir-svrname = all_server.
            ENDIF.
            APPEND IUSER_DIR.
            LOOP AT IUSER_DIR.
               MOVE-CORRESPONDING IUSER_DIR TO USER_DIR.
               INSERT USER_DIR.
               IF SY-SUBRC = 4.
                 UPDATE USER_DIR.
               ENDIF.
            ENDLOOP.
            SAVED = 'Y'.
            SET SCREEN 0.
            LEAVE SCREEN.
        WHEN 'A'. SET SCREEN SY-DYNNR.
        WHEN OTHERS.
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDIF.

elseif okcode = 'CANC'.
  set screen 0.
  leave screen.

ELSEIF OKCODE = 'ADD'.
    SAVED = 'N'.
    CLEAR: iuser_dir, a_dirname.
    iuser_dir-svrname = all_server.
*    APPEND iuser_dir.

  ELSEIF okcode = 'SAVE'.
    IF iuser_dir-dirname IS INITIAL.
      txt = text-024.
      IF txt IS INITIAL. txt = 'Cannot save: missing directory name...'. ENDIF."#EC NOTEXT
      message txt type 'I' display like 'E'.
    ELSE.
      IF iuser_dir-svrname EQ space.
        iuser_dir-svrname = all_server.
      ENDIF.
      DELETE FROM user_dir WHERE dirname = iuser_dir-dirname.
      MOVE-CORRESPONDING IUSER_DIR TO USER_DIR.
      INSERT USER_DIR.
      IF SY-SUBRC = 4.
        UPDATE USER_DIR.
      ENDIF.
*    ENDLOOP.
  SAVED = 'Y'.
  CHANGED = ' '.
  A_DIRNAME = ' '.
      txt = text-025.
      IF txt IS INITIAL. txt = 'Save successful!'. ENDIF.   "#EC NOTEXT
      message txt type 'S'.
    ENDIF.
*  ELSEIF okcode = 'RETR'.
*    saved = 'Y'.
*    SELECT * FROM user_dir
*      WHERE dirname = iuser_dir-dirname.
*      MOVE-CORRESPONDING user_dir TO iuser_dir.
*    ENDSELECT.
*    a_dirname = iuser_dir-dirname.
*    IF sy-subrc <> 0.
*      CALL FUNCTION 'POPUP_TO_INFORM'
*        EXPORTING
*          titel = ' '
*          txt1  = 'Record not in the database!'
*          txt2  = ' '
*          txt3  = ' '
*          txt4  = ' '.
*    ENDIF.

ELSEIF OKCODE = 'DELE'.
    USER_DIR-DIRNAME = IUSER_DIR-DIRNAME.
    DELETE USER_DIR.
    IF sy-subrc = 0.
      CLEAR: iuser_dir, a_dirname.
      txt = text-026.
      IF txt IS INITIAL. txt = 'Delete successful!'. ENDIF. "#EC NOTEXT
      message txt type 'S'.
*    a_dirname = ' '.
    ENDIF.
ENDIF.

ENDMODULE.                 " USER_COMMAND_0001  INPUT

*----------------------------------------------------------------------*
*  MODULE SHOW_DIRNAMES INPUT
*----------------------------------------------------------------------*
*  @AD, obsolete Version => see show_user_dir
*----------------------------------------------------------------------*
MODULE show_dirnames INPUT.
  DATA: BEGIN OF dirname_hlp_tbl OCCURS 20,
        svrname(40),
        dirname(60),
        aliass(30),
      END OF DIRNAME_HLP_TBL.
DATA: SELECTED_DIRNAME LIKE USER_DIR-DIRNAME.
DATA BEGIN OF FIELD_TBL OCCURS 10.
        INCLUDE STRUCTURE HELP_VALUE.
DATA END OF FIELD_TBL.

CLEAR DIRNAME_HLP_TBL.  REFRESH DIRNAME_HLP_TBL.

* enter the contents of user_dir so that they can be displayed
SELECT * FROM USER_DIR.
  DIRNAME_HLP_TBL-DIRNAME = USER_DIR-DIRNAME.
    dirname_hlp_tbl-aliass  = user_dir-aliass.
  DIRNAME_HLP_TBL-SVRNAME = USER_DIR-SVRNAME.
  APPEND DIRNAME_HLP_TBL.
ENDSELECT.

SORT DIRNAME_HLP_TBL BY DIRNAME ASCENDING.

FREE FIELD_TBL.
FIELD_TBL-TABNAME    = 'USER_DIR'.
FIELD_TBL-FIELDNAME  = 'DIRNAME'.
FIELD_TBL-SELECTFLAG = 'X'.
APPEND FIELD_TBL.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
    EXPORTING
      TABNAME             = FIELD_TBL-TABNAME
      FIELDNAME           = FIELD_TBL-FIELDNAME
      NO_CONVERSION       = 'X'
    IMPORTING
      SELECT_VALUE        = SELECTED_DIRNAME
    TABLES
      FIELDS              = FIELD_TBL
      VALUETAB            = DIRNAME_HLP_TBL
    EXCEPTIONS
      OTHERS              = 99.

IF SY-SUBRC EQ 0.
  IUSER_DIR-DIRNAME = SELECTED_DIRNAME+10(60).
ENDIF.
F4HELP = 'Y'.
ENDMODULE.                 " SHOW_DIRNAMES  INPUT

*----------------------------------------------------------------------*
*  MODULE CHANGE_VALUES
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE change_values.
  IF ( F4HELP = 'Y' ) AND ( SAVED = 'Y' ).
    CHANGED = 'N'.
  ELSEIF ( F4HELP = 'Y' ) AND ( SAVED = ' ' ).
    CHANGED = 'N'.
  ELSE.
    CHANGED = 'Y'.
  ENDIF.
  TEMP_DIRNAME = IUSER_DIR-DIRNAME.
ENDMODULE.                 " CHANGE_VALUES
*----------------------------------------------------------------------*
*  MODULE SHOW_DIRNAMES2 INPUT
*----------------------------------------------------------------------*
*  New version
*----------------------------------------------------------------------*
MODULE show_user_dir INPUT.

  DATA: BEGIN OF f4_dirname_tab OCCURS 0,
         svrname     TYPE msname2, "before 6.10 MSNAME
         aliass      TYPE dirprofilenames,
         dirname     TYPE dirname,
        END OF f4_dirname_tab.

  DATA: dirname_wa    LIKE LINE OF f4_dirname_tab,
        help_dirname  TYPE string,
        f4_return_tab TYPE TABLE OF ddshretval INITIAL SIZE 0,
        f4_return_wa  LIKE LINE OF f4_return_tab.

  DATA: t_dynpfield    TYPE STANDARD TABLE OF dynpread,
        wa_dynpfield   TYPE dynpread,
        dynpfn_aliass  TYPE string  VALUE 'IUSER_DIR-ALIASS',"#EC NOTEXT
        dynpfn_svrname TYPE string  VALUE 'IUSER_DIR-SVRNAME'."#EC NOTEXT

* enter the contents of user_dir so that they can be displayed
  SELECT * FROM user_dir
    INTO CORRESPONDING FIELDS OF TABLE f4_dirname_tab.

  SORT f4_dirname_tab BY dirname ASCENDING.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield   = 'DIRNAME'
      value_org  = 'S'
    TABLES
      value_tab  = f4_dirname_tab
      return_tab = f4_return_tab
    EXCEPTIONS
      OTHERS     = 99.

  IF lines( f4_return_tab ) > 0.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 23/12/2019 EY_DES02 ECDK917080 *
SORT F4_RETURN_TAB .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 23/12/2019 EY_DES02 ECDK917080 *
    READ TABLE f4_return_tab INTO f4_return_wa INDEX 1.
    TRANSLATE f4_return_wa-fieldval TO UPPER CASE. "#EC TRANSLANG

    LOOP AT f4_dirname_tab INTO dirname_wa.
      help_dirname = dirname_wa-dirname.
      TRANSLATE help_dirname TO UPPER CASE. "#EC TRANSLANG
      IF help_dirname = f4_return_wa-fieldval.
        CLEAR help_dirname.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF sy-subrc = 0.
    CLEAR wa_dynpfield. REFRESH t_dynpfield.
* directory name (unique)
      iuser_dir-dirname = dirname_wa-dirname.
* user defined parameter name
      wa_dynpfield-fieldname = dynpfn_aliass.
      wa_dynpfield-fieldvalue = dirname_wa-aliass.
      wa_dynpfield-fieldinp = 'X'.
      APPEND wa_dynpfield TO t_dynpfield.
* server name
      wa_dynpfield-fieldname = dynpfn_svrname.
      wa_dynpfield-fieldvalue = dirname_wa-svrname.
      wa_dynpfield-fieldinp = 'X'.
      APPEND wa_dynpfield TO t_dynpfield.

      CALL FUNCTION 'DYNP_VALUES_UPDATE'
        EXPORTING
          dyname     = sy-repid
          dynumb     = sy-dynnr
        TABLES
          dynpfields = t_dynpfield
        EXCEPTIONS
          OTHERS     = 99.

      f4help = 'Y'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " SHOW_DIRNAMES  INPUT
