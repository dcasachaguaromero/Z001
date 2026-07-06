FUNCTION ZFIBL_CHECK_SHLP_EXIT.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCR_TAB_T
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR_T
*"     REFERENCE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------
* The callcontrol-step = SELECT may be called twice.
* The first time the function is called is with the parameters
* given by starting the F4-Help. If these parameters results
* in selecting to many "objects" the callcontrol-step = PRESEL
* is activated. Here the user is able to decrease the number
* of found "objects" by adding detailed selection-options. After
* This function is called for the second and last time. Now the
* select is based on the selection-options.

  CHECK CALLCONTROL-STEP = 'SELECT'.

  TYPES: BEGIN OF SELOPT,
         SIGN   LIKE DDSHSELOPT-SIGN,
         OPTION LIKE DDSHSELOPT-OPTION,
         LOW    LIKE DDSHSELOPT-LOW,
         HIGH   LIKE DDSHSELOPT-HIGH,
       END OF SELOPT.
* iscalled keeps track of whether this is the first (equal initial)
* or second (equal 'X') time the function is activated. First the
* user can decrease the number of found record if maxrecords is
* exceeded. After the user has tried to decrease the number of found
* record and still maxrecords is exceeded the records are displayed.
  STATICS: L_ISCALLED TYPE C.

  DATA: LT_CHECT LIKE SELOPT OCCURS 0 WITH HEADER LINE,
        LT_HBKID LIKE SELOPT OCCURS 0 WITH HEADER LINE,
        LT_HKTID LIKE SELOPT OCCURS 0 WITH HEADER LINE,
        LT_ZBUKR LIKE SELOPT OCCURS 0 WITH HEADER LINE,
        LT_VOIDR LIKE SELOPT OCCURS 0 WITH HEADER LINE,
        INDEX TYPE I,
        L_NEWSTEP LIKE DDSHF4CTRL-STEP,

       BEGIN OF LS_RESULT,
          ZBUKR      TYPE PAYR-ZBUKR,
          HBKID      TYPE PAYR-HBKID,
          HKTID      TYPE PAYR-HKTID,
          VOIDR      TYPE PAYR-VOIDR,
          CHECT      TYPE PAYR-CHECT,
          CHECF      TYPE PAYR-CHECF,
          ZNME1      TYPE PAYR-ZNME1,
          RWBTR      TYPE PAYR-RWBTR,
          WAERS      TYPE PAYR-WAERS,
       END OF LS_RESULT,

       LT_RESULT LIKE TABLE OF LS_RESULT,
       LT_SELOPT LIKE DDSHSELOPT OCCURS 0 WITH HEADER LINE.

  L_NEWSTEP = 'DISP'.

  DATA:  DYFIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.


  DYFIELDS-FIELDNAME = 'BUKRS'.
  APPEND DYFIELDS.
  DYFIELDS-FIELDNAME = 'HBKID'.
  APPEND DYFIELDS.
  DYFIELDS-FIELDNAME = 'HKTID'.
  APPEND DYFIELDS.


  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'ZFIMDP001'
      DYNUMB     = '0100'
    TABLES
      DYNPFIELDS = DYFIELDS.

 IF SY-SUBRC = 0.
    READ TABLE DYFIELDS WITH KEY FIELDNAME = 'BUKRS'.
    IF SY-SUBRC EQ 0.
    SET PARAMETER ID '01' FIELD  DYFIELDS-FIELDVALUE.
    ENDIF.
    READ TABLE DYFIELDS WITH KEY FIELDNAME = 'HBKID'.
    IF SY-SUBRC EQ 0.
    SET PARAMETER ID '02' FIELD  DYFIELDS-FIELDVALUE.
    ENDIF.
    READ TABLE DYFIELDS WITH KEY FIELDNAME = 'HKTID'.
    IF SY-SUBRC EQ 0.
    SET PARAMETER ID '03' FIELD  DYFIELDS-FIELDVALUE.
    ENDIF.
  ENDIF.





*  CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
*       EXPORTING
*            PARAMETER         = 'ZBUKR'
*       TABLES
*            SHLP_TAB          = SHLP_TAB
*            RECORD_TAB        = RECORD_TAB
*            SELOPT_TAB        = lt_selopt
*       CHANGING
*            SHLP              = SHLP
*            CALLCONTROL       = CALLCONTROL
*       EXCEPTIONS
*            PARAMETER_UNKNOWN = 1
*            OTHERS            = 2.
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ELSE.
*    LOOP AT lt_selopt.
*       move-corresponding lt_selopt TO lt_zbukr.
*       APPEND lt_zbukr.
*    ENDLOOP.
*  ENDIF.
*
*  CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
*       EXPORTING
*            PARAMETER         = 'HBKID'
*       TABLES
*            SHLP_TAB          = SHLP_TAB
*            RECORD_TAB        = RECORD_TAB
*            SELOPT_TAB        = lt_selopt
*       CHANGING
*            SHLP              = SHLP
*            CALLCONTROL       = CALLCONTROL
*       EXCEPTIONS
*            PARAMETER_UNKNOWN = 1
*            OTHERS            = 2.
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ELSE.
*    LOOP AT lt_selopt.
*       move-corresponding lt_selopt TO lt_hbkid.
*       APPEND lt_hbkid.
*    ENDLOOP.
*  ENDIF.
*
*  CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
*       EXPORTING
*            PARAMETER         = 'HKTID'
*       TABLES
*            SHLP_TAB          = SHLP_TAB
*            RECORD_TAB        = RECORD_TAB
*            SELOPT_TAB        = lt_selopt
*       CHANGING
*            SHLP              = SHLP
*            CALLCONTROL       = CALLCONTROL
*       EXCEPTIONS
*            PARAMETER_UNKNOWN = 1
*            OTHERS            = 2.
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ELSE.
*    LOOP AT lt_selopt.
*       move-corresponding lt_selopt TO lt_hktid.
*       APPEND lt_hktid.
*    ENDLOOP.
*  ENDIF.
*
*  CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
*       EXPORTING
*            PARAMETER         = 'CHECT'
*       TABLES
*            SHLP_TAB          = SHLP_TAB
*            RECORD_TAB        = RECORD_TAB
*            SELOPT_TAB        = lt_selopt
*       CHANGING
*            SHLP              = SHLP
*            CALLCONTROL       = CALLCONTROL
*       EXCEPTIONS
*            PARAMETER_UNKNOWN = 1
*            OTHERS            = 2.
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ELSE.
*    LOOP AT lt_selopt.
*       move-corresponding lt_selopt TO lt_chect.
*       APPEND lt_chect.
*    ENDLOOP.
*  ENDIF.
*
*  CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
*       EXPORTING
*            PARAMETER         = 'VOIDR'
*       TABLES
*            SHLP_TAB          = SHLP_TAB
*            RECORD_TAB        = RECORD_TAB
*            SELOPT_TAB        = lt_selopt
*       CHANGING
*            SHLP              = SHLP
*            CALLCONTROL       = CALLCONTROL
*       EXCEPTIONS
*            PARAMETER_UNKNOWN = 1
*            OTHERS            = 2.
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ELSE.
*    LOOP AT lt_selopt.
*       move-corresponding lt_selopt TO lt_voidr.
*       APPEND lt_voidr.
*    ENDLOOP.
*  ENDIF.


  DATA: T_ZBUKR LIKE PAYR-ZBUKR,
        T_HBKID LIKE PAYR-HBKID,
        T_HKTID LIKE PAYR-HKTID.
  GET PARAMETER ID '01' FIELD T_ZBUKR.
  GET PARAMETER ID '02' FIELD T_HBKID.
  GET PARAMETER ID '03' FIELD T_HKTID.



  SELECT * FROM PAYR
     WHERE ICHEC EQ ''
       AND ZBUKR EQ T_ZBUKR
       AND HBKID EQ T_HBKID
       AND HKTID EQ T_HKTID.
*       AND chect IN lt_chect
*       AND voidr IN lt_voidr.

    CALL FUNCTION 'FIBL_CHECK_PAYR_AUTHORITY'
      EXPORTING
        IM_PAYR      = PAYR
      EXCEPTIONS
        NO_AUTHORITY = 1
        OTHERS       = 2.
    IF SY-SUBRC EQ 0.
      IF INDEX GE CALLCONTROL-MAXRECORDS AND
         CALLCONTROL-MAXRECORDS NE 0.
        IF L_ISCALLED IS INITIAL.
          L_NEWSTEP ='PRESEL'.
          L_ISCALLED = 'X'.
          MESSAGE S803(DH) WITH CALLCONTROL-MAXRECORDS.
*         Es gibt mehr als & Eingabemöglichkeiten
        ENDIF.
        EXIT.
      ENDIF.
      MOVE-CORRESPONDING PAYR TO LS_RESULT.
      APPEND LS_RESULT TO LT_RESULT.
      INDEX = INDEX + 1.
    ENDIF.
  ENDSELECT.

  IF L_NEWSTEP EQ 'DISP'.
    CALL FUNCTION 'F4UT_RESULTS_MAP'
*     EXPORTING
*       SOURCE_STRUCTURE         =
*       APPLY_RESTRICTIONS       = ' '
      TABLES
        SHLP_TAB                 = SHLP_TAB
        RECORD_TAB               = RECORD_TAB
        SOURCE_TAB               = LT_RESULT
      CHANGING
        SHLP                     = SHLP
        CALLCONTROL              = CALLCONTROL
      EXCEPTIONS
        ILLEGAL_STRUCTURE        = 1
        OTHERS                   = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    CLEAR L_ISCALLED.
  ENDIF.

  CALLCONTROL-STEP = L_NEWSTEP.

ENDFUNCTION.
