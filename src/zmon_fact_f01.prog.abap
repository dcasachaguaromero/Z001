*&---------------------------------------------------------------------*
*&  Include           ZMON_FACT_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCATALOG.

* get fieldcatalog
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME = 'ZCABPEDEXT'
    CHANGING
      CT_FIELDCAT      = GT_FIELDCATALOG.

* change fieldcatalog
  LOOP AT GT_FIELDCATALOG INTO LS_FIELDCATALOG.
    CASE LS_FIELDCATALOG-FIELDNAME.
      WHEN 'ZBLART'.
        LS_FIELDCATALOG-NO_OUT = TRUE.
        LS_FIELDCATALOG-KEY    = ''.
      WHEN 'STATUS'.
        LS_FIELDCATALOG-ICON     = TRUE.
        LS_FIELDCATALOG-OUTPUTLEN = 11.
      WHEN OTHERS.
        CHECK LS_FIELDCATALOG-FIELDNAME NE 'ZTIP_CAMBIO_REF'.
        LS_FIELDCATALOG-DO_SUM = TRUE.
    ENDCASE.
    MODIFY GT_FIELDCATALOG FROM LS_FIELDCATALOG.
  ENDLOOP.

ENDFORM.                               " BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  BUILD_OUTTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_OUTTAB.

  SELECT * FROM ZCABPEDEXT.
    MOVE-CORRESPONDING ZCABPEDEXT TO GT_CABPEDEXT.
    SELECT SINGLE KUNNR INTO GT_CABPEDEXT-ZRUT_CLI_PAGADOR FROM KNA1 WHERE STCD1 EQ ZCABPEDEXT-ZRUT_CLI_PAGADOR.
    SELECT SINGLE KUNNR INTO GT_CABPEDEXT-ZRUT_CLI_FACT    FROM KNA1 WHERE STCD1 EQ ZCABPEDEXT-ZRUT_CLI_FACT.
    CASE ZCABPEDEXT-ERROR.
      WHEN TRUE.
        NAME = 'ICON_LED_RED'.
        INFO = 'Documento con error'.
      WHEN OTHERS.
        IF NOT ZCABPEDEXT-PEDIDO IS INITIAL AND NOT ZCABPEDEXT-FACTURA IS INITIAL.
          NAME = 'ICON_LED_GREEN'.
          INFO = 'Documento tratado'.
        ELSE.
          NAME = 'ICON_LED_YELLOW'.
          INFO = 'Documento sin tratar'.
        ENDIF.
    ENDCASE.

    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        NAME                  = NAME
        INFO                  = INFO
        ADD_STDINF            = SPACE
      IMPORTING
        RESULT                = GT_CABPEDEXT-STATUS
      EXCEPTIONS
        ICON_NOT_FOUND        = 1
        OUTPUTFIELD_TOO_SHORT = 2
        OTHERS                = 3.
    APPEND GT_CABPEDEXT.
  ENDSELECT.

ENDFORM.                               " BUILD_OUTTAB

*&---------------------------------------------------------------------*
*&      Form  BUILD_SORT_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_SORT_TABLE.

  DATA LS_SORT_WA TYPE LVC_S_SORT.

  LS_SORT_WA-SPOS = 1.
  LS_SORT_WA-FIELDNAME = 'FEC_CAR'.
  LS_SORT_WA-UP = 'X'.
  LS_SORT_WA-SUBTOT = 'X'.
  APPEND LS_SORT_WA TO GT_SORT.

  LS_SORT_WA-SPOS = 2.
  LS_SORT_WA-FIELDNAME = 'ZBLART'.
  LS_SORT_WA-UP = 'X'.
  LS_SORT_WA-SUBTOT = 'X'.
  APPEND LS_SORT_WA TO GT_SORT.

* create sort-table
  LS_SORT_WA-SPOS = 3.
  LS_SORT_WA-FIELDNAME = 'ZNUM_DOC_CORE'.
  LS_SORT_WA-UP = 'X'.
  LS_SORT_WA-SUBTOT = 'X'.
  APPEND LS_SORT_WA TO GT_SORT.

ENDFORM.                               " BUILD_SORT_TABLE
*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       free object and leave program
*----------------------------------------------------------------------*
FORM EXIT_PROGRAM.

  CALL METHOD TREE1->FREE.
  LEAVE PROGRAM.

ENDFORM.                               " exit_program
*&---------------------------------------------------------------------*
*&      Form  register_events
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REGISTER_EVENTS.
* define the events which will be passed to the backend
  DATA: LT_EVENTS TYPE CNTL_SIMPLE_EVENTS,
        L_EVENT TYPE CNTL_SIMPLE_EVENT.

* define the events which will be passed to the backend
  L_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_NODE_CONTEXT_MENU_REQ.
  APPEND L_EVENT TO LT_EVENTS.

  L_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_ITEM_CONTEXT_MENU_REQ.
  APPEND L_EVENT TO LT_EVENTS.

  L_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_HEADER_CONTEXT_MEN_REQ.
  APPEND L_EVENT TO LT_EVENTS.

  L_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_EXPAND_NO_CHILDREN.
  APPEND L_EVENT TO LT_EVENTS.

  L_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_HEADER_CLICK.
  APPEND L_EVENT TO LT_EVENTS.

  L_EVENT-EVENTID    = CL_GUI_SIMPLE_TREE=>EVENTID_NODE_DOUBLE_CLICK.
  L_EVENT-APPL_EVENT = 'X'.
  APPEND L_EVENT TO LT_EVENTS.

  L_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_ITEM_KEYPRESS.
  APPEND L_EVENT TO LT_EVENTS.

  L_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_ITEM_DOUBLE_CLICK.
  APPEND L_EVENT TO LT_EVENTS.

  CALL METHOD TREE1->SET_REGISTERED_EVENTS
    EXPORTING
      EVENTS                    = LT_EVENTS
    EXCEPTIONS
      CNTL_ERROR                = 1
      CNTL_SYSTEM_ERROR         = 2
      ILLEGAL_EVENT_COMBINATION = 3.

* set Handler
  DATA: L_EVENT_RECEIVER TYPE REF TO LCL_TREE_EVENT_RECEIVER.
  CREATE OBJECT L_EVENT_RECEIVER.
  SET HANDLER L_EVENT_RECEIVER->ON_ADD_HIERARCHY_NODE FOR TREE1.
  SET HANDLER L_EVENT_RECEIVER->ON_ITEM_DOUBLE_CLICK  FOR TREE1.

ENDFORM.                               " register_events
*&---------------------------------------------------------------------*
*&      Form  build_header
*&---------------------------------------------------------------------*
*       build table for html_header
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_COMMENT USING
      PT_LIST_COMMENTARY TYPE SLIS_T_LISTHEADER
      P_LOGO             TYPE SDYDO_VALUE.

  DATA: LS_LINE TYPE SLIS_LISTHEADER.
*
  CLEAR LS_LINE.
  LS_LINE-TYP  = 'H'.
  LS_LINE-INFO = 'Monitor de Facturación'.
  APPEND LS_LINE TO PT_LIST_COMMENTARY.
*
  CLEAR LS_LINE.
  LS_LINE-TYP  = 'S'.
  LS_LINE-KEY  = 'Valido desde'.
  LS_LINE-INFO = SY-DATLO.
  APPEND LS_LINE TO PT_LIST_COMMENTARY.
*
  LS_LINE-KEY  = 'Horario'.
  LS_LINE-INFO = SY-TIMLO.
  APPEND LS_LINE TO PT_LIST_COMMENTARY.
*
* P_LOGO = 'ENJOYSAP_LOGO'.

ENDFORM.                    "build_comment
*&---------------------------------------------------------------------*
*&      Form  init_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_TREE.

* create info-table for html-header
  DATA: LT_LIST_COMMENTARY TYPE SLIS_T_LISTHEADER,
        L_LOGO             TYPE SDYDO_VALUE.
  DATA: LS_VARIANT TYPE DISVARIANT.
  DATA  LS_EXCEPTION_FIELD  TYPE LVC_S_L004.

  PERFORM BUILD_FIELDCATALOG.
  PERFORM BUILD_OUTTAB.
  PERFORM BUILD_SORT_TABLE.

  L_TREE_CONTAINER_NAME = 'TREE1'.

  CREATE OBJECT L_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME              = L_TREE_CONTAINER_NAME
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

* create tree control
  CREATE OBJECT TREE1
    EXPORTING
      I_PARENT                    = L_CUSTOM_CONTAINER
      I_NODE_SELECTION_MODE       = CL_GUI_COLUMN_TREE=>NODE_SEL_MODE_MULTIPLE
      I_ITEM_SELECTION            = 'X'
      I_NO_HTML_HEADER            = ''
      I_NO_TOOLBAR                = ''
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      ILLEGAL_NODE_SELECTION_MODE = 5
      FAILED                      = 6
      ILLEGAL_COLUMN_NAME         = 7.

  PERFORM BUILD_COMMENT USING LT_LIST_COMMENTARY L_LOGO.

* Repid for saving variants
  LS_VARIANT-REPORT = SY-REPID.
  LOOP AT GT_CABPEDEXT INTO LS_CABPEDEXT.

  ENDLOOP.
* Register events
  PERFORM REGISTER_EVENTS.
* Create hierarchy
  CALL METHOD TREE1->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IT_LIST_COMMENTARY = LT_LIST_COMMENTARY
*      I_LOGO             = L_LOGO
*      I_BACKGROUND_ID    = 'ALV_BACKGROUND'
      I_SAVE             = 'A'
      IS_VARIANT         = LS_VARIANT
    CHANGING
      IT_SORT            = GT_SORT[]
      IT_OUTTAB          = GT_CABPEDEXT[]
      IT_FIELDCATALOG    = GT_FIELDCATALOG[].

* Extend functions of standard toolbar
  PERFORM CHANGE_TOOLBAR.

* Optimize column-width
  CALL METHOD TREE1->COLUMN_OPTIMIZE
    EXPORTING
      I_START_COLUMN = TREE1->C_HIERARCHY_COLUMN_NAME
      I_END_COLUMN   = TREE1->C_HIERARCHY_COLUMN_NAME.

ENDFORM.                    " init_tree

*&---------------------------------------------------------------------*
*&      Form  CHANGE_TOOLBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHANGE_TOOLBAR.

* §1.Get toolbar instance of your ALV Tree.
* When you instantiate an instance of CL_GUI_ALV_TREE the constructor
* of the base class (CL_ALV_TREE_BASE) creates a toolbar.
* Fetch its reference with the following method if you want to
* modify it:
  CALL METHOD TREE1->GET_TOOLBAR_OBJECT
    IMPORTING
      ER_TOOLBAR = G_TOOLBAR.

  CHECK NOT G_TOOLBAR IS INITIAL. "could happen if you do not use the
  "standard toolbar

* §2.Modify toolbar with methods of CL_GUI_TOOLBAR:
* add seperator to toolbar
  CALL METHOD G_TOOLBAR->ADD_BUTTON
    EXPORTING
      FCODE     = ''
      ICON      = ''
      BUTN_TYPE = CNTB_BTYPE_SEP.

* add Standard Button to toolbar (for Delete Subtree)
  CALL METHOD G_TOOLBAR->ADD_BUTTON
    EXPORTING
      FCODE     = 'GENFAC'
      ICON      = '@39@'
      BUTN_TYPE = CNTB_BTYPE_BUTTON
      TEXT      = TEXT-GEN
      QUICKINFO = TEXT-GEN.   "Delete subtree

ENDFORM.                    "CHANGE_TOOLBAR
*&---------------------------------------------------------------------*
*&      Form  COMPLETA_CABECERA_ORDEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_EMPRESA_VKORG  text
*      -->P_L_VTWEG  text
*      -->P_C_SPART  text
*      -->P_L_FECHA  text
*      -->P_T_CABECERA_NRO_HABITACION  text
*      -->P_L_TAXK1  text
*      -->P_C_AUART2  text
*      -->P_L_VKBUR  text
*      -->P_L_KONDA  text
*      -->P_T_CABECERA_NUM_DOC_LEGAL  text
*      -->P_L_FORMA_PAGO  text
*      <--P_ORDER_HEADER_IN  text
*----------------------------------------------------------------------*
FORM COMPLETA_CABECERA_ORDEN  USING    P_VKORG
                                       P_VTWEG
                                       P_SPART
                                       P_BSTDK
                                       P_BSTKD
                                       P_TAXK1
                                       P_AUART
                                       P_VKBUR
                                       P_KONDA
                                       P_XBLNR
                                       P_VERSION
                                       P_IND_E
                         CHANGING P_ORDER_HEADER_IN  STRUCTURE BAPISDHD1
                                  P_ORDER_HEADER_INX STRUCTURE BAPISDHD1X.
*
  CASE P_AUART.
    WHEN 'G1' OR 'G2' OR 'G3' OR 'G4'. "Factura
      P_ORDER_HEADER_IN-DOC_TYPE = 'ZFAC'.
    WHEN 'J1' OR 'J2' OR 'J3' OR 'J4'. "NC
      P_ORDER_HEADER_IN-DOC_TYPE = 'ZNC'.
    WHEN 'L1' OR 'L2' OR 'L3' OR 'L4'. "ND
      P_ORDER_HEADER_IN-DOC_TYPE = 'ZND'.
    WHEN 'O1' OR 'O2' OR 'O3' OR 'O4'. "BO
      P_ORDER_HEADER_IN-DOC_TYPE = 'ZBOL'.
  ENDCASE.
  P_ORDER_HEADER_INX-DOC_TYPE = TRUE.

  IF P_IND_E NE SPACE.
    P_ORDER_HEADER_IN-CUST_GRP1 = '01'.
  ELSE.
    P_ORDER_HEADER_IN-CUST_GRP1 = '02'.
  ENDIF.
  P_ORDER_HEADER_INX-CUST_GRP1 = TRUE.
  CASE P_AUART.
    WHEN 'G1' OR 'G3' OR 'J1' OR 'J3' OR 'L1' OR 'L3' OR 'O1' OR 'O3'.
      P_ORDER_HEADER_IN-CUST_GRP2 = '01'.
    WHEN OTHERS.
      P_ORDER_HEADER_IN-CUST_GRP2 = '02'.
  ENDCASE.
  P_ORDER_HEADER_INX-CUST_GRP2 = TRUE.
*
  P_ORDER_HEADER_IN-SALES_ORG   = P_VKORG.  " Organizacion de venta
  P_ORDER_HEADER_INX-SALES_ORG  = TRUE.
  P_ORDER_HEADER_IN-DISTR_CHAN  = P_VTWEG.  " Canal de ditribucucion
  P_ORDER_HEADER_INX-DISTR_CHAN = TRUE.
  P_ORDER_HEADER_IN-DIVISION    = P_SPART.  " Sector
  P_ORDER_HEADER_INX-DIVISION   = TRUE.
*
  P_ORDER_HEADER_IN-PURCH_NO_C  = 'Externo'.  "n° de check
  P_ORDER_HEADER_INX-PURCH_NO_C = TRUE.
*  P_ORDER_HEADER_IN-ALTTAX_CLS  = P_TAXK1.  "Clasificación fiscal
  P_ORDER_HEADER_IN-PMNTTRMS    = 'ZD00'.   "Condicion de pago.
  P_ORDER_HEADER_INX-PMNTTRMS   = TRUE.
*  P_ORDER_HEADER_IN-VERSION     = P_VERSION."FORMA DE PAGO
*  P_ORDER_HEADER_IN-PRICE_GRP   = P_KONDA.  "Grupo de precios - Cliente
*  P_ORDER_HEADER_IN-SALES_OFF   = P_VKBUR.  "Oficina de Ventas
*  P_ORDER_HEADER_IN-REF_DOC_L   = P_XBLNR.  "Referencia
*  P_ORDER_HEADER_IN-PRICE_DATE  = P_BSTDK.  "Fecha det. precios
*
  P_ORDER_HEADER_IN-REQ_DATE_H  = P_BSTDK.  "Fecha preferente entrega
  P_ORDER_HEADER_INX-REQ_DATE_H = TRUE.
  P_ORDER_HEADER_IN-PURCH_DATE  = P_BSTDK.  "Fecha del pedido
  P_ORDER_HEADER_INX-PURCH_DATE = TRUE.
  P_ORDER_HEADER_IN-PRICE_DATE  = P_BSTDK.  "Fecha pedido del destinat.
  P_ORDER_HEADER_INX-PRICE_DATE = TRUE.
  P_ORDER_HEADER_IN-PO_DAT_S    = P_BSTDK.
  P_ORDER_HEADER_INX-PO_DAT_S   = TRUE.
*
ENDFORM.                    " completa_cabecera_orden
*&---------------------------------------------------------------------*
*&      Form  COMPLETA_PARTNER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ORDER_PARTNERS  text
*----------------------------------------------------------------------*
FORM COMPLETA_PARTNER TABLES ORDER_PARTNERS STRUCTURE BAPIPARNR
                       USING BILL_DATA      STRUCTURE  BAPIVBRK
                             PAGADOR
                             CLI_FACT.
*
  ORDER_PARTNERS-PARTN_ROLE = 'AG'.
  BILL_DATA-BILL_TO = ORDER_PARTNERS-PARTN_NUMB = PAGADOR.
  APPEND ORDER_PARTNERS.
  CLEAR ORDER_PARTNERS.
*
  ORDER_PARTNERS-PARTN_ROLE = 'RG'.
  ORDER_PARTNERS-PARTN_NUMB = PAGADOR.
  APPEND ORDER_PARTNERS.
  CLEAR ORDER_PARTNERS.
*
  ORDER_PARTNERS-PARTN_ROLE = 'RE'.
  BILL_DATA-SHIP_TO = ORDER_PARTNERS-PARTN_NUMB = CLI_FACT.
  APPEND ORDER_PARTNERS.
  CLEAR ORDER_PARTNERS.
*
  ORDER_PARTNERS-PARTN_ROLE = 'WE'.
  BILL_DATA-PAYER = ORDER_PARTNERS-PARTN_NUMB = PAGADOR.
  APPEND ORDER_PARTNERS.
  CLEAR ORDER_PARTNERS.
*
ENDFORM.                    " COMPLETA_PARTNER
*&---------------------------------------------------------------------*
*&      Form  COMPLETA_POSICION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ORDER_ITEMS_IN  text
*      -->P_ORDER_ITEMS_INX  text
*----------------------------------------------------------------------*
FORM COMPLETA_POSICION TABLES ORDER_ITEMS_IN       STRUCTURE BAPISDITM
                              ORDER_ITEMS_INX      STRUCTURE BAPISDITMX
                              ORDER_PARTNERS       STRUCTURE BAPIPARNR
                              ORDER_SCHEDULES_IN   STRUCTURE BAPISCHDL
                              ORDER_SCHEDULES_INX  STRUCTURE BAPISCHDLX
                              ORDER_CONDITIONS_IN  STRUCTURE BAPICOND
                              ORDER_CONDITIONS_INX STRUCTURE BAPICONDX
                        USING GT_CABPEDEXT         STRUCTURE ZCABPEDEXT
                              LS_DETPEDEXT         STRUCTURE ZDETPEDEXT
                              TABIX.

  ORDER_CONDITIONS_IN-ITM_NUMBER = ORDER_ITEMS_INX-ITM_NUMBER = ORDER_ITEMS_IN-ITM_NUMBER  = TABIX * 10.
  ORDER_ITEMS_INX-UPDATEFLAG = TRUE.
*
  ORDER_ITEMS_IN-MATERIAL    = LS_DETPEDEXT-MATNR.
  ORDER_ITEMS_INX-MATERIAL   = TRUE.
*
  ORDER_ITEMS_IN-PLANT       = GT_CABPEDEXT-ZCENTRO.
  ORDER_ITEMS_INX-PLANT      = TRUE.
*
  ORDER_ITEMS_IN-TARGET_QTY  = LS_DETPEDEXT-MENGE.
  ORDER_ITEMS_INX-TARGET_QTY = TRUE.
*
  ORDER_SCHEDULES_IN-ITM_NUMBER  = ORDER_ITEMS_IN-ITM_NUMBER.
  ORDER_SCHEDULES_INX-ITM_NUMBER = TRUE.
*
  ORDER_SCHEDULES_IN-REQ_QTY     = LS_DETPEDEXT-MENGE.
  ORDER_SCHEDULES_INX-REQ_QTY    = TRUE.
*
  ORDER_ITEMS_IN-PURCH_DATE      = SY-DATUM.
  ORDER_ITEMS_INX-PURCH_DATE     = TRUE.
*
  ORDER_ITEMS_IN-PO_DAT_S    = SY-DATUM.
  ORDER_ITEMS_INX-PO_DAT_S   = TRUE.

  ORDER_PARTNERS-PARTN_ROLE = 'ZB'.
  SELECT SINGLE KUNNR INTO ORDER_PARTNERS-PARTN_NUMB FROM KNA1 WHERE STCD1 EQ LS_DETPEDEXT-ZRUT_BENEFICIARI.
  ORDER_PARTNERS-ITM_NUMBER = ORDER_ITEMS_IN-ITM_NUMBER.

********************************************************
  ORDER_CONDITIONS_IN-COND_TYPE   = 'ZPR0'.
  ORDER_CONDITIONS_INX-COND_TYPE  = TRUE.
*
  ORDER_CONDITIONS_IN-COND_VALUE  = LS_DETPEDEXT-ZPREC.  "valor
  ORDER_CONDITIONS_INX-COND_VALUE = TRUE.
*
  ORDER_CONDITIONS_IN-CURRENCY   = GT_CABPEDEXT-WAERS.
  ORDER_CONDITIONS_INX-CURRENCY  = TRUE.
*
  APPEND: ORDER_CONDITIONS_IN, ORDER_CONDITIONS_INX.
********************************************************
  ORDER_CONDITIONS_IN-COND_TYPE   = 'ZRE1'.
  ORDER_CONDITIONS_INX-COND_TYPE  = TRUE.
*
  ORDER_CONDITIONS_IN-COND_VALUE  = LS_DETPEDEXT-ZREC_AD.
  ORDER_CONDITIONS_INX-COND_VALUE = TRUE.
*
  ORDER_CONDITIONS_IN-CURRENCY   = GT_CABPEDEXT-WAERS.
  ORDER_CONDITIONS_INX-CURRENCY  = TRUE.
*
  APPEND: ORDER_CONDITIONS_IN, ORDER_CONDITIONS_INX.
********************************************************
  ORDER_CONDITIONS_IN-COND_TYPE   = 'ZDC2'.
  ORDER_CONDITIONS_INX-COND_TYPE  = TRUE.
*
  ORDER_CONDITIONS_IN-COND_VALUE  = LS_DETPEDEXT-ZDES_AD.
  ORDER_CONDITIONS_INX-COND_VALUE = TRUE.
*
  ORDER_CONDITIONS_IN-CURRENCY   = GT_CABPEDEXT-WAERS.
  ORDER_CONDITIONS_INX-CURRENCY  = TRUE.
*
  APPEND: ORDER_CONDITIONS_IN, ORDER_CONDITIONS_INX.
********************************************************
  ORDER_CONDITIONS_IN-COND_TYPE   = 'ZDC1'.
  ORDER_CONDITIONS_INX-COND_TYPE  = TRUE.
*
  ORDER_CONDITIONS_IN-COND_VALUE  = LS_DETPEDEXT-ZDCTO_CONV.
  ORDER_CONDITIONS_INX-COND_VALUE = TRUE.
*
  ORDER_CONDITIONS_IN-CURRENCY   = GT_CABPEDEXT-WAERS.
  ORDER_CONDITIONS_INX-CURRENCY  = TRUE.
*
  APPEND: ORDER_CONDITIONS_IN, ORDER_CONDITIONS_INX.
********************************************************
  ORDER_CONDITIONS_IN-COND_TYPE   = 'ZDC3'.
  ORDER_CONDITIONS_INX-COND_TYPE  = TRUE.
*
  ORDER_CONDITIONS_IN-COND_VALUE  = LS_DETPEDEXT-ZDCTO_CONV.
  ORDER_CONDITIONS_INX-COND_VALUE = TRUE.
*
  ORDER_CONDITIONS_IN-CURRENCY   = GT_CABPEDEXT-WAERS.
  ORDER_CONDITIONS_INX-CURRENCY  = TRUE.
*
  APPEND: ORDER_CONDITIONS_IN, ORDER_CONDITIONS_INX.
********************************************************
  ORDER_CONDITIONS_IN-COND_TYPE   = 'ZDC4'.
  ORDER_CONDITIONS_INX-COND_TYPE  = TRUE.
*
  ORDER_CONDITIONS_IN-COND_VALUE  = LS_DETPEDEXT-ZDCTO_PROM.
  ORDER_CONDITIONS_INX-COND_VALUE = TRUE.
*
  ORDER_CONDITIONS_IN-CURRENCY   = GT_CABPEDEXT-WAERS.
  ORDER_CONDITIONS_INX-CURRENCY  = TRUE.
*
  APPEND: ORDER_CONDITIONS_IN, ORDER_CONDITIONS_INX.
********************************************************
  ORDER_CONDITIONS_IN-COND_TYPE   = 'ZDC5'.
  ORDER_CONDITIONS_INX-COND_TYPE  = TRUE.
*
  ORDER_CONDITIONS_IN-COND_VALUE  = LS_DETPEDEXT-ZDCTO_ESP_T.
  ORDER_CONDITIONS_INX-COND_VALUE = TRUE.
*
  ORDER_CONDITIONS_IN-CURRENCY   = GT_CABPEDEXT-WAERS.
  ORDER_CONDITIONS_INX-CURRENCY  = TRUE.
*
  APPEND: ORDER_CONDITIONS_IN, ORDER_CONDITIONS_INX.
********************************************************
  ORDER_CONDITIONS_IN-COND_TYPE   = 'ZPR1'.
  ORDER_CONDITIONS_INX-COND_TYPE  = TRUE.
*
  ORDER_CONDITIONS_IN-COND_VALUE  = LS_DETPEDEXT-ZDCTO_ESP_T.
  ORDER_CONDITIONS_INX-COND_VALUE = TRUE.
*
  ORDER_CONDITIONS_IN-CURRENCY   = GT_CABPEDEXT-WAERS.
  ORDER_CONDITIONS_INX-CURRENCY  = TRUE.
*
  APPEND: ORDER_CONDITIONS_IN, ORDER_CONDITIONS_INX.
********************************************************
  ORDER_CONDITIONS_IN-COND_TYPE   = 'ZPR2'.
  ORDER_CONDITIONS_INX-COND_TYPE  = TRUE.
*
  ORDER_CONDITIONS_IN-COND_VALUE  = LS_DETPEDEXT-ZOTRO_ING.
  ORDER_CONDITIONS_INX-COND_VALUE = TRUE.
*
  ORDER_CONDITIONS_IN-CURRENCY   = GT_CABPEDEXT-WAERS.
  ORDER_CONDITIONS_INX-CURRENCY  = TRUE.
*
  APPEND: ORDER_CONDITIONS_IN, ORDER_CONDITIONS_INX.
********************************************************


ENDFORM.                    " COMPLETA_POSICION
