*&---------------------------------------------------------------------*
*&  Include           ZCL_SEN_PRINT_ACEPTA_F01
*&---------------------------------------------------------------------*

* display content
*&---------------------------------------------------------------------*
*&      Form  SEND_PRINT_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TI_DOC_XBLNR  text
*----------------------------------------------------------------------*
FORM SEND_PRINT_DOC USING    P_DOC P_XBLNR P_NUMCOP
                    CHANGING MENSAJE.

  TABLES ZHOSTACEPTA.

  DATA T_LINES  TYPE STANDARD TABLE OF TLINE.
  DATA GS_LINES LIKE LINE OF T_LINES.
  DATA T_NAME   LIKE  THEAD-TDNAME.
  CLEAR: COM_ACC, T_NAME, STR_DAT, PATH, SCHEME, RC, SUBRC, ERRORTEXT, CLIENT, TIMEOUT, CONTENT, MENSAJE.

  COM_ACC = TEXT-000.
  T_NAME = P_DOC.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT                  = SY-MANDT
      ID                      = 'ZXML'
      LANGUAGE                = SY-LANGU
      NAME                    = T_NAME
      OBJECT                  = 'VBBK'
    TABLES
      LINES                   = T_LINES
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.
  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    LOOP AT T_LINES INTO GS_LINES.
      CONCATENATE STR_DAT GS_LINES-TDLINE INTO STR_DAT.
    ENDLOOP.
  ENDIF.

  SELECT SINGLE * FROM ZHOSTACEPTA WHERE SYSID EQ SY-SYSID.
  STR_NUMCOP = P_NUMCOP.
  CONCATENATE ZHOSTACEPTA-HOST P_XBLNR '&comando=' COM_ACC '&parametros='
              ZHOSTACEPTA-IMPRESORA ',' STR_NUMCOP '&datos=' STR_DAT
  INTO PATH.

* Checking if Path is SSL or not
  IF PATH(8) = 'https://' OR PATH(8) = 'HTTPS://'.
    SCHEME = 2.
    PATH = PATH+8(*).
  ELSEIF PATH(7) = 'http://' OR PATH(7) = 'HTTP://'.
    SCHEME = 1.
    PATH = PATH+7(*).
  ELSE.
    SCHEME = 1.
  ENDIF.

  IF PATH(30) CA ':'.
    OFF  = SY-FDPOS.
    HOST = PATH+0(OFF).
    ADD 1 TO OFF.
    PATH  = PATH+OFF(*).
    IF PATH CA '/'.
      OFF  = SY-FDPOS.
      PORT = PATH+0(OFF).
      "add 1 to off.
      PATH  = PATH+OFF(*).
    ENDIF.
  ELSE.
    IF PATH CA '/'.
      OFF  = SY-FDPOS.
      HOST = PATH+0(OFF).
      "add 1 to off.
      PATH  = PATH+OFF(*).
    ELSE.
      HOST = PATH.
      PATH = '/'.
    ENDIF.
  ENDIF.

* Setting the port, 80 or 443 for SSL
  IF PORT IS INITIAL.
    IF SCHEME = 1.
      PORT = '80'.
    ELSE.
      PORT = '443'.
    ENDIF.
  ENDIF.

  IF PATH IS INITIAL.
    PATH = '/'.
  ENDIF.

*create client object
  CALL METHOD CL_HTTP_CLIENT=>CREATE
    EXPORTING
      HOST    = HOST
      SERVICE = PORT
      SCHEME  = SCHEME
    IMPORTING
      CLIENT  = CLIENT.

* set http method GET

  CALL METHOD CLIENT->REQUEST->SET_METHOD( IF_HTTP_REQUEST=>CO_REQUEST_METHOD_GET ).
  CLIENT->REQUEST->SET_VERSION( IF_HTTP_REQUEST=>CO_PROTOCOL_VERSION_1_1 ).

* Set request uri (/<path>[?<querystring>])
  CL_HTTP_UTILITY=>SET_REQUEST_URI( REQUEST = CLIENT->REQUEST
                                    URI     = PATH ).
* Send and receive
  CALL METHOD CLIENT->SEND
    EXPORTING
      TIMEOUT                    = TIMEOUT
    EXCEPTIONS
      HTTP_COMMUNICATION_FAILURE = 1
      HTTP_INVALID_STATE         = 2
      HTTP_PROCESSING_FAILED     = 3
      OTHERS                     = 4.
  IF SY-SUBRC <> 0.
    CALL METHOD CLIENT->GET_LAST_ERROR
      IMPORTING
        CODE    = SUBRC
        MESSAGE = ERRORTEXT.
    WRITE: / 'Error de comunicasion en el envío',
           / 'Código: ', SUBRC, 'Mensage: ', ERRORTEXT.
    EXIT.
  ENDIF.

  CALL METHOD CLIENT->RECEIVE
    EXCEPTIONS
      HTTP_COMMUNICATION_FAILURE = 1
      HTTP_INVALID_STATE         = 2
      HTTP_PROCESSING_FAILED     = 3
      OTHERS                     = 4.
  IF SY-SUBRC <> 0.
    CALL METHOD CLIENT->GET_LAST_ERROR
      IMPORTING
        CODE    = SUBRC
        MESSAGE = ERRORTEXT.
    WRITE: / 'Error de comunicasion en el envío',
           / 'Código: ', SUBRC, 'Mensage: ', ERRORTEXT.
    EXIT.
  ENDIF.
* Did you get an error
  RC = SY-SUBRC.
  CLIENT->RESPONSE->GET_STATUS( IMPORTING CODE = HTTP_RC ).

  IF BINARY IS INITIAL.
    CONTENT = CLIENT->RESPONSE->GET_CDATA( ).
    FIND 'OK' IN CONTENT MATCH OFFSET OFF.
    IF SY-SUBRC = 0.
      MENSAJE = CONTENT+OFF.
    ELSE.
      CLEAR OFF.
      FIND 'Salida[impresora]:' IN CONTENT MATCH OFFSET OFF.
      MENSAJE = CONTENT+OFF.
    ENDIF.
  ENDIF.

ENDFORM.                    " SEND_PRINT_DOC
*&---------------------------------------------------------------------*
*&      Form  ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV .

  DATA INT_FCAT TYPE SLIS_T_FIELDCAT_ALV.
  IS_PRINT-NO_PRINT_SELINFOS  = TRUE.
  IS_PRINT-NO_PRINT_LISTINFOS = TRUE.
*
  IS_U_LAYOUT-ZEBRA = TRUE.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE     = 0
    IMPORTING
      ET_EVENTS       = GT_EVENTS
    EXCEPTIONS
      LIST_TYPE_WRONG = 1
      OTHERS          = 2.

  READ TABLE GT_EVENTS INTO WA_EVENT WITH KEY NAME = SLIS_EV_TOP_OF_PAGE.
  IF SY-SUBRC = 0.
    MOVE C_FORMNAME_TOP_OF_PAGE TO WA_EVENT-FORM.
    MODIFY GT_EVENTS FROM WA_EVENT INDEX SY-TABIX.
  ENDIF.
  READ TABLE GT_EVENTS INTO WA_EVENT WITH KEY NAME = SLIS_EV_TOP_OF_LIST.
  IF SY-SUBRC = 0.
    MOVE C_FORMNAME_TOP_OF_LIST TO WA_EVENT-FORM.
    MODIFY GT_EVENTS FROM WA_EVENT INDEX SY-TABIX.
  ENDIF.
  READ TABLE GT_EVENTS INTO WA_EVENT WITH KEY NAME = SLIS_EV_END_OF_LIST.
  IF SY-SUBRC = 0.
    MOVE C_FORMNAME_END_OF_LIST TO WA_EVENT-FORM.
    MODIFY GT_EVENTS FROM WA_EVENT INDEX SY-TABIX.
  ENDIF.

  DELETE GT_EVENTS WHERE FORM IS INITIAL.
* Create Fieldcatalogue from internal table
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INTERNAL_TABNAME     = 'TI_DOC'
      I_INCLNAME             = SY-REPID
    CHANGING
      CT_FIELDCAT            = INT_FCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

* Call for ALV list display
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IT_FIELDCAT        = INT_FCAT
      I_SAVE             = 'A'
    TABLES
      T_OUTTAB           = TI_DOC[]
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

ENDFORM.                    " ALV
