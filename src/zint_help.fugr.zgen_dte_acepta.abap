FUNCTION ZGEN_DTE_ACEPTA.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(I_DOC) LIKE  VBRK-BELNR
*"     REFERENCE(I_PRINT) TYPE  SELKZ OPTIONAL
*"  EXPORTING
*"     REFERENCE(URLPDF) TYPE  CHAR255
*"     REFERENCE(ERROR) TYPE  C
*"  EXCEPTIONS
*"      HTTP_COMMUNICATION_FAILURE
*"      HTTP_INVALID_STATE
*"      HTTP_PROCESSING_FAILED
*"----------------------------------------------------------------------

  CASE I_PRINT.
    WHEN 'X'.
      COM_ACC = 'imprimir'.
    WHEN SPACE.
      COM_ACC = 'generar'.
  ENDCASE.

* Generar mapeo de documento con los campos del XML
  CONCATENATE '<Documento>'
                '<Encabezado>'
                '<IdDoc>'
                '<TipoDTE>33</TipoDTE>'
                '<Folio>102</Folio>'
                '<FchEmis>2011-10-27</FchEmis>'
                '</IdDoc>'
                '<Emisor>'
                '<RUTEmisor>96565480-1</RUTEmisor>'
                '<RznSoc>RAZON SOCIAL</RznSoc>'
                '<GiroEmis>GIRO EMISOR</GiroEmis>'
                '<Acteco>1</Acteco>'
                '<DirOrigen>DIRECCION</DirOrigen>'
                '<CmnaOrigen>COMUNA</CmnaOrigen>'
                '<CiudadOrigen>CIUDAD</CiudadOrigen>'
                '</Emisor>'
                '<Receptor>'
                '<RUTRecep>96565480-1</RUTRecep>'
                '<RznSocRecep>RAZON SOCIAL RECEPTOR</RznSocRecep>'
                '<GiroRecep>GIRO</GiroRecep>'
                '<DirRecep>DIRECCION</DirRecep>'
                '<CmnaRecep>COMUNA</CmnaRecep>'
                '<CiudadRecep>CIUDAD</CiudadRecep>'
                '</Receptor>'
                '<Totales>'
                '<MntNeto>100</MntNeto>'
                '<MntExe>0</MntExe>'
                '<IVA>19</IVA>'
                '<MntTotal>119</MntTotal>'
                '</Totales>'
                '</Encabezado>'
                '<Detalle>'
                '<NroLinDet>1</NroLinDet>'
                '<IndExe>1</IndExe>'
                '<NmbItem>1</NmbItem>'
                '<DscItem>DESCRIPCIN</DscItem>'
                '<MontoItem>100</MontoItem>'
                '</Detalle><Referencia>'
                '<NroLinRef>1</NroLinRef>'
                '<TpoDocRef>1</TpoDocRef>'
                '<FolioRef>1</FolioRef>'
                '<FchRef>2011-10-25</FchRef>'
                '<CodRef>1</CodRef>'
                '</Referencia>'
                '<Adjuntos>'
                '<TmstFirma>2011-10-25T09:49:34</TmstFirma>'
                '</Adjuntos>'
                '</Documento>'
  INTO STR_DAT.

  HOST  = '10.0.0.70'.
  PORT  = '5001'.
  FOLIO = I_DOC.

  CONCATENATE 'http://' HOST ':' PORT '/ca4xml?docid=' FOLIO '&comando=' COM_ACC '&parametros=&datos=' STR_DAT
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

* Create client object
  CALL METHOD CL_HTTP_CLIENT=>CREATE
    EXPORTING
      HOST    = HOST
      SERVICE = PORT
      SCHEME  = SCHEME
    IMPORTING
      CLIENT  = CLIENT.

* Set http method GET

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
    WRITE: / 'Error de comunicación en el envío',
           / 'Código: ', SUBRC, 'Mensage: ', ERRORTEXT.
    EXIT.
  ENDIF.

  CALL METHOD CLIENT->RECEIVE
    EXCEPTIONS
      HTTP_COMMUNICATION_FAILURE = 1
      HTTP_INVALID_STATE         = 2
      HTTP_PROCESSING_FAILED     = 3
      OTHERS                     = 4.

* Did you get an error
  RC = SY-SUBRC.
  CLIENT->RESPONSE->GET_STATUS( IMPORTING CODE = HTTP_RC ).

* Analisisi content
  IF BINARY IS INITIAL.
    CONTENT = CLIENT->RESPONSE->GET_CDATA( ).
    TMP = CONTENT.
    CASE RC.
      WHEN '0'.
        FIND '|' IN CONTENT MATCH OFFSET OFF.
        RESP_ACEPTA = TMP(OFF).
        CASE RESP_ACEPTA.
          WHEN 'OK'.
            TMP = TMP+OFF.
            FIND 'http://' IN TMP MATCH OFFSET OFF.
            URLPDF = TMP+OFF.
          WHEN 'ERROR'.
            TMP = TMP+OFF.
            ERROR = 'X'.
            URLPDF = TMP.
        ENDCASE.
      WHEN '1'.
        RAISE HTTP_COMMUNICATION_FAILURE.
      WHEN '2'.
        RAISE HTTP_INVALID_STATE.
      WHEN '3'.
        RAISE HTTP_PROCESSING_FAILED.
      WHEN OTHERS.
        RAISE NO_DATA_FOUND.
    ENDCASE.
  ELSE.
    XCONTENT = CLIENT->RESPONSE->GET_DATA( ).
  ENDIF.

* Close
  CALL METHOD CLIENT->CLOSE
    EXCEPTIONS
      HTTP_INVALID_STATE = 1
      OTHERS             = 2.

ENDFUNCTION.
