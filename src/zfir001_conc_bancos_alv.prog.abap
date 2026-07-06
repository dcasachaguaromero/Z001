*&---------------------------------------------------------------------*
*&  Include           ZFIR001_CONC_BANCOS_ALV
*&---------------------------------------------------------------------*

**********************************************************************
* ALV INITIALIZATION *************************************************
**********************************************************************
FORM ALV_INITIALIZATION.

  G_REPID = SY-REPID.
  G_SAVE = 'A'.

  CLEAR G_VARIANT.
  G_VARIANT-REPORT = G_REPID.

  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      I_SAVE        = G_SAVE
    CHANGING
      CS_VARIANT    = GX_VARIANT
    EXCEPTIONS
      WRONG_INPUT   = 1
      NOT_FOUND     = 2
      PROGRAM_ERROR = 3
      OTHERS        = 4.

  IF SY-SUBRC = 0.
    S_VARI = GX_VARIANT-VARIANT.
  ENDIF.


ENDFORM.                    "ALV_INITIALIZATION



*********************************************************************
* FORM ROUTINES ALV *************************************************
*********************************************************************

* -------------------------------------------------------------------
* ------------------------------------------------------ ALV VARIANTS
FORM FOR_VARIANT.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
       EXPORTING
            IS_VARIANT          = G_VARIANT
            I_SAVE              = G_SAVE
*           it_default_fieldcat = XXXXXXXXX
       IMPORTING
            E_EXIT              = G_EXIT
            ES_VARIANT          = GX_VARIANT
       EXCEPTIONS
            NOT_FOUND = 2.

  IF SY-SUBRC = 2.

    MESSAGE ID SY-MSGID TYPE 'S'      NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.

    IF G_EXIT = SPACE.
      S_VARI = GX_VARIANT-VARIANT.
    ENDIF.

  ENDIF.

ENDFORM.                    "FOR_VARIANT


* -------------------------------------------------------------------
* -------------------------------------------------- ALV FIELDCATALOG
FORM FIELDCAT_INIT USING LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.
  REFRESH: fieldcat.
  CLEAR:   fieldcat.

  PERFORM ASIGNAR_CAMPOS.

  LT_FIELDCAT[] = fieldcat[].

ENDFORM.


* -------------------------------------------------------------------
* ---------------------------------------------------- ALV PAI MODULE
FORM PAI_OF_SELECTION_SCREEN.

  IF NOT S_VARI IS INITIAL.

    MOVE G_VARIANT TO GX_VARIANT.
    MOVE S_VARI TO GX_VARIANT-VARIANT.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        I_SAVE     = G_SAVE
      CHANGING
        CS_VARIANT = GX_VARIANT.
    G_VARIANT = GX_VARIANT.

  ELSE.

    CLEAR G_VARIANT.
    G_VARIANT-REPORT = G_REPID.

  ENDIF.

ENDFORM.                    "PAI_OF_SELECTION_SCREEN



* ------------------------------------------------------------------
* -------------------------------------------------- ALV HEADER TEXT
* ------------------------------------------------------------------
*                  ALV listheader information
* ------------------------------------------------------------------
FORM COMMENT_BUILD USING LT_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.


ENDFORM.                    "COMMENT_BUILD



* ------------------------------------------------------------------
* ----------------------------------------- ALV LAYOUT CONFIGURATION
FORM LAYOUT_BUILD USING LS_LAYOUT TYPE SLIS_LAYOUT_ALV.
DATA:  S_ZEBRA(1)   TYPE C VALUE 'X',
       S_COLOPT(1)  TYPE C VALUE ' '.

  LS_LAYOUT-ZEBRA                = S_ZEBRA.
  LS_LAYOUT-COLWIDTH_OPTIMIZE    = S_COLOPT.
  LS_LAYOUT-BOX_FIELDNAME        = SPACE.
  LS_LAYOUT-NO_INPUT             = 'X'.
  LS_LAYOUT-NO_VLINE             = 'X'.
  LS_LAYOUT-NO_COLHEAD           = ' '.
  LS_LAYOUT-LIGHTS_CONDENSE      = 'X'.
  LS_LAYOUT-INFO_FIELDNAME       = 'ALV_COLOR'.
  ls_layout-confirmation_prompt  = 'X'.
* ls_layout-detail_popup         = 'X'.
  ls_layout-detail_initial_lines = 'X'.
  ls_layout-detail_titlebar      = wa_titulo.


ENDFORM.                    "LAYOUT_BUILD




* ------------------------------------------------------------------
* --------------------------------------------------------- CALL ALV
FORM CALL_ALV.


  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
         I_CALLBACK_PROGRAM       = G_REPID
*         I_CALLBACK_PF_STATUS_SET = 'SET_STATUS'
         I_CALLBACK_USER_COMMAND  = 'USER_COMMAND2'
         I_STRUCTURE_NAME         = 'IT_DETALLE'
         IS_LAYOUT                = GS_LAYOUT
         IT_FIELDCAT              = GT_FIELDCAT[]
         I_SAVE                   = G_SAVE
         IS_VARIANT               = G_VARIANT
         IT_EVENTS                = GT_EVENTS[]
         IS_PRINT                 = GS_PRINT
    TABLES
         T_OUTTAB                 = IT_DETALLE
    EXCEPTIONS
         PROGRAM_ERROR            = 1
         OTHERS                   = 2
         .

  IF SY-SUBRC <> 0.
    message e301.
  ENDIF.

ENDFORM.                    "CALL_ALV



* ------------------------------------------------------------------
* ------------------------------------------------------- SET STATUS
FORM SET_STATUS USING  RT_EXTAB  TYPE  SLIS_T_EXTAB.
  SET PF-STATUS  'EIGENER_STATUS'      EXCLUDING RT_EXTAB.
ENDFORM.                    "SET_STATUS



* -------------------------------------------------------------------
* -------------------------------------------------------- EVENTS ALV
FORM EVENTTAB_BUILD USING
                    LT_EVENTS    TYPE SLIS_T_EVENT.

  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = LT_EVENTS.

  READ TABLE LT_EVENTS WITH KEY NAME = SLIS_EV_TOP_OF_PAGE
                           INTO LS_EVENT.
  IF SY-SUBRC = 0.
    MOVE GC_FORMNAME_TOP_OF_PAGE TO LS_EVENT-FORM.
    APPEND LS_EVENT TO LT_EVENTS.
  ENDIF.

  READ TABLE LT_EVENTS WITH KEY NAME = SLIS_EV_END_OF_LIST
                           INTO LS_EVENT.

  IF SY-SUBRC = 0.
    MOVE GC_FORMNAME_END_OF_LIST TO LS_EVENT-FORM.
    APPEND LS_EVENT TO LT_EVENTS.
  ENDIF.

  READ TABLE LT_EVENTS WITH KEY NAME = SLIS_EV_AFTER_LINE_OUTPUT
                            INTO LS_EVENT.

  IF SY-SUBRC = 0.
    MOVE GC_FORMNAME_AFTER_LINE_OUTPUT TO LS_EVENT-FORM.
    APPEND LS_EVENT TO LT_EVENTS.
  ENDIF.

  READ TABLE LT_EVENTS WITH KEY NAME = SLIS_EV_END_OF_PAGE
                          INTO LS_EVENT.

  IF SY-SUBRC = 0.
    MOVE GC_FORMNAME_END_OF_PAGE TO LS_EVENT-FORM.
    APPEND LS_EVENT TO LT_EVENTS.
  ENDIF.




ENDFORM.                    "EVENTTAB_BUILD

* ------------------------------------------------------------------
* ----------------------------------------- ALV LAYOUT CONFIGURATION
FORM PRINT_BUILD USING LS_PRINT TYPE SLIS_PRINT_ALV.

  ls_print-reserve_lines      = 8.

ENDFORM.                    "PRINT_BUILD
*&---------------------------------------------------------------------*
*&      Form  CALL_ALV_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_ALV_2 .
    PERFORM FIELDCAT_INIT      USING    GT_FIELDCAT[].
    PERFORM EVENTTAB_BUILD     USING    GT_EVENTS[].
    PERFORM LAYOUT_BUILD       USING    GS_LAYOUT.
    PERFORM PRINT_BUILD        USING    GS_PRINT.
    PERFORM CALL_ALV.

ENDFORM.                    " CALL_ALV_2
