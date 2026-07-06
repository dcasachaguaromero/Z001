*&---------------------------------------------------------------------*
*& Include ZFILB005_TOP                                      Report ZFILB005
*&
*&---------------------------------------------------------------------*

REPORT   ZFILB005.
TABLES: SKA1.
TYPE-POOLS SLIS.

TYPES: BEGIN OF TY_S_OUTTAB,
*          hkont   TYPE hkont,
          HKONT   TYPE TXT40,
          BUDAT   TYPE BUDAT,
          BUKRS   TYPE BUKRS,
          GJAHR   TYPE GJAHR,
          BELNR   TYPE BELNR_D,
          BLART   TYPE BLART,
          BUZEI   TYPE BUZEI,
          SGTXT   TYPE SGTXT,
          SGTXT2  TYPE SGTXT,
          DMBTR_H TYPE DMBTR,
          DMBTR_S TYPE DMBTR,
          SALDO_START TYPE DMBTR,
          SALDO_END   TYPE DMBTR,
          WAERS   TYPE WAERS,
       END OF TY_S_OUTTAB.

TYPES: BEGIN OF TY_S_GRPTAB,
*          hkont   TYPE hkont,
          HKONT   TYPE TXT40,
          DMBTR_H TYPE DMBTR,
          DMBTR_S TYPE DMBTR,
       END OF TY_S_GRPTAB,
           TY_T_GRPTAB TYPE TABLE OF TY_S_GRPTAB.

TYPES: BEGIN OF TY_S_SAKNR,
        SAKNR TYPE SAKNR,
       END OF TY_S_SAKNR.
TYPES: TY_T_SAKNR TYPE TABLE OF TY_S_SAKNR.
TYPES: TY_T_OUTTAB TYPE TABLE OF TY_S_OUTTAB.
TYPES: BEGIN OF TY_S_TABTOT,
         BLART   TYPE BLART,
         DMBTR_H TYPE DMBTR,
         DMBTR_S TYPE DMBTR,
         WAERS   TYPE WAERS,
       END OF TY_S_TABTOT,
        TY_T_TABTOT TYPE TABLE OF TY_S_TABTOT.
TYPES: BEGIN OF TY_S_DOWNLOAD,
          DATA TYPE C LENGTH 255,
       END OF TY_S_DOWNLOAD.
TYPES: TY_T_DOWNLOAD TYPE TABLE OF TY_S_DOWNLOAD.

DATA: LT_EXTAB             TYPE SLIS_T_EXTAB,
    G_FAGL_ACTIVE           TYPE BOOLE_D,
    GS_FAGL_S_DOC_DETAILS  TYPE  FAGL_S_DOC_DETAILS,
    GT_FILTER              TYPE SLIS_T_FILTER_ALV,
    GT_SLIS_SP_GROUP_ALV   TYPE SLIS_T_SP_GROUP_ALV,
    GS_VARIANT             TYPE DISVARIANT,
    GT_LIST_TOP_OF_PAGE    TYPE SLIS_T_LISTHEADER,
    GT_SORT                TYPE SLIS_T_SORTINFO_ALV,
    GT_FIELDCAT            TYPE SLIS_T_FIELDCAT_ALV,
    GT_OUTTAB              TYPE TY_T_OUTTAB,
    GT_OUTTAB_TREE         TYPE TY_T_OUTTAB,
    GT_DOWNLOAD            TYPE TY_T_DOWNLOAD,
    GS_OUTTAB              TYPE TY_S_OUTTAB,
    GT_BKPF                TYPE TABLE OF BKPF,
    GS_BKPF                TYPE BKPF,
    GT_BSEG                TYPE TABLE OF BSEG,
    GT_ZFIGIRO             TYPE TABLE OF ZFIGIRO,
    GT_TABTOT              TYPE TY_T_TABTOT,
    GS_TABTOT              TYPE TY_S_TABTOT,
    GT_GRPTAB              TYPE TY_T_GRPTAB,
    GS_GRPTAB              TYPE TY_S_GRPTAB,
    GS_BSEG                TYPE BSEG,
    GT_SAKNR               TYPE TY_T_SAKNR,
    GS_LAYOUT              TYPE SLIS_LAYOUT_ALV,
    GS_EXIT_CAUSED_BY_USER TYPE SLIS_EXIT_BY_USER,
    G_REPID                LIKE SY-REPID,
    GT_EVENTS              TYPE SLIS_T_EVENT,
    GS_EVENT               TYPE SLIS_ALV_EVENT,
    G_NUM                  TYPE I,
    G_BUTXT                TYPE BUTXT,
    G_TXT20                TYPE TXT20_SKAT,
    L_CALLBACK_HTML_TOP_OF_PAGE  TYPE SLIS_FORMNAME VALUE 'HTML_TOP_OF_PAGE',
    L_CALLBACK_HTML_END_OF_LIST  TYPE SLIS_FORMNAME  VALUE 'HTML_END_OF_LIST',
    L_CALLBACK_TOP_OF_PAGE TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
    G_EXPA                 TYPE C VALUE 'X',
    G_UCOMM                TYPE SY-UCOMM,
    RB_TXT,
    RB_XLS,
    DMBTR_H               TYPE DMBTR,
    DMBTR_S               TYPE DMBTR,
    G_SALDO_S             TYPE DMBTR,
    G_SALDO_E             TYPE DMBTR,
    G_HTML_HEIGHT_TOP     TYPE I VALUE 30,
    G_ADDRESS_VALUE       TYPE ADDR1_VAL,
    G_PAVAL               TYPE PAVAL,
    G_LINE                TYPE I VALUE 50,
    G_PATH                TYPE C LENGTH 255.

DATA: G_ALV_TREE         TYPE REF TO CL_GUI_ALV_TREE,
      G_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GT_FIELDCATALOG TYPE LVC_T_FCAT.

*  VALORES DE SALDO ACUMULADO TOTAL
DATA : G_SALDO_S1 TYPE DMBTR,
       G_SALDO_E1 TYPE DMBTR.

DATA: GT_GLT0  TYPE FAGL_T_GLT0,
      GS_GLT0 TYPE GLT0,
      RANGE_RACCT TYPE FAGL_RANGE_T_RACCT.
RANGES: R_BSTAT FOR BKPF-BSTAT.

CONSTANTS: C_LINE TYPE C LENGTH 255  VALUE '-----------------------------------------------------------------------------------------------------------------------------------------------------',
           C_LINE_2 TYPE C LENGTH 255  VALUE '-----------------------------------------'.
*----------------------------------------------------------------------*
*       CLASS lcl_tree_event_receiver DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_TREE_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.
*§2. Define an event handler method for each event you want to react to.
    METHODS HANDLE_NODE_DOUBLE_CLICK
      FOR EVENT NODE_DOUBLE_CLICK OF CL_GUI_ALV_TREE
      IMPORTING NODE_KEY SENDER.

ENDCLASS.                    "lcl_tree_event_receiver DEFINITION
******************************************************************
CLASS LCL_TREE_EVENT_RECEIVER IMPLEMENTATION.
*§3. Implement your event handler methods.

  METHOD HANDLE_NODE_DOUBLE_CLICK.
    DATA: LT_CHILDREN TYPE LVC_T_NKEY.
*first check if the node is a leaf, i.e. can not be expanded

    CALL METHOD SENDER->GET_CHILDREN
      EXPORTING
        I_NODE_KEY  = NODE_KEY
      IMPORTING
        ET_CHILDREN = LT_CHILDREN.

    IF NOT LT_CHILDREN IS INITIAL.

      CALL METHOD SENDER->EXPAND_NODE
        EXPORTING
          I_NODE_KEY    = NODE_KEY
          I_LEVEL_COUNT = 2.
    ENDIF.

  ENDMETHOD.                    "handle_node_double_click

ENDCLASS.                    "lcl_tree_event_receiver IMPLEMENTATION
SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-010.
PARAMETERS: P_BUKRS TYPE BUKRS OBLIGATORY.
SELECT-OPTIONS: S_SAKNR FOR SKA1-SAKNR.
PARAMETERS:P_RLDNR      TYPE RLDNR OBLIGATORY  MATCHCODE OBJECT FAGL_RLDNR_AND_ROLLUP_W_LEAD.
SELECTION-SCREEN END OF BLOCK BLOCK1.


SELECTION-SCREEN BEGIN OF BLOCK BLOCK2 WITH FRAME TITLE TEXT-020.
PARAMETERS: P_GJAHR TYPE GJAHR OBLIGATORY,
            P_MONAT TYPE MONAT OBLIGATORY,
            P_MOV TYPE C AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK BLOCK2.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK BLOCK3  WITH FRAME TITLE TEXT-020.
PARAMETERS: P_PATH TYPE LOCALFILE LOWER CASE ." DEFAULT 'C:\Users\Alfredo Rivera\Desktop\DESCARGA TEST'.
SELECTION-SCREEN END OF BLOCK BLOCK3.
