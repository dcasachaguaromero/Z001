*----------------------------------------------------------------------*
***INCLUDE LZDTE_ENVIO_NOTIFICACIONF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ENVIO_FTP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM envio_ftp USING p_user     TYPE char30
                     p_pwd      TYPE char30
                     p_ip       TYPE char64
                     p_retorno  TYPE subrc
                     p_tpo_doc
                     p_folio.

  DATA: w_ftp TYPE zdte_ftp.

  SELECT SINGLE * INTO w_ftp
    FROM zdte_ftp
   WHERE programa EQ 'ZDTE_RESPUESTA'.

  IF sy-subrc EQ 0.
    lc_rfc_dest = w_ftp-rfc_dest  .
    p_user      = w_ftp-usuario   .
    p_pwd       = w_ftp-pwd       .
    p_ip        = w_ftp-host      .
    v_path_04   = w_ftp-ruta      .
  ENDIF.



  DATA: lv_pwd(30) TYPE c .
  lv_pwd_len = STRLEN( p_pwd ).

  CALL FUNCTION 'HTTP_SCRAMBLE'
    EXPORTING
      SOURCE      = p_pwd
      sourcelen   = lv_pwd_len
      key         = lc_key
    IMPORTING
      destination = lv_pwd.

*  connect to FTP server
  CALL FUNCTION 'FTP_CONNECT'
    EXPORTING
      user            = p_user
*      password        = p_pwd
      password        = lv_pwd
      host            = p_ip
      rfc_destination = lc_rfc_dest
    IMPORTING
      handle          = lv_handle
    EXCEPTIONS
       not_connected      .

  IF sy-subrc <> 0.
    p_retorno = sy-subrc.
    EXIT.
  ENDIF.

**
  PERFORM ftp_command USING 'set passive on'.

*Armamos comandos FTP
  CONCATENATE  'cd'  v_path_04   INTO  v_cmd_01 SEPARATED BY space. "Buscamos directorio procesados.
  PERFORM ftp_command USING v_cmd_01.

  CONCATENATE  'pwd'  ''  INTO  v_cmd_02 SEPARATED BY space.         "Buscamos los recibidos
  PERFORM ftp_command USING v_cmd_02.


  DATA: lv_tpo_doc TYPE c LENGTH 3,
        lv_len            TYPE i ,
        ixml  TYPE xstring.

  lv_tpo_doc =  p_tpo_doc.
  CONDENSE lv_tpo_doc.

*  CONCATENATE v_path_04 '/' sy-datum '_' sy-uzeit '_' lv_tpo_doc '_' p_folio '.txt' INTO  v_cmd_03.
  CONCATENATE sy-datum '_' sy-uzeit '_' lv_tpo_doc '_' p_folio '.txt' INTO  v_cmd_03.

*Dejo el archivo en el direcrtorio
  CALL FUNCTION 'FTP_R3_TO_SERVER'
    EXPORTING
      handle         = lv_handle
      fname          = v_cmd_03
      character_mode = 'X'
      blob_length    = lv_len
    TABLES
      text           = gt_data "li_data
    EXCEPTIONS
      tcpip_error    = 1
      command_error  = 2
      data_error     = 3
      OTHERS         = 4.


  CONCATENATE  'ls -c'  ''  INTO  v_cmd_02 SEPARATED BY space.         "Buscamos los recibidos
  PERFORM ftp_command USING v_cmd_02.

* Disconnect the FTP connection
  CALL FUNCTION 'FTP_DISCONNECT'
    EXPORTING
      handle = lv_handle.

*Disconnect the RFC connection between SAP and FTP.
  CALL FUNCTION 'RFC_CONNECTION_CLOSE'
    EXPORTING
      destination = lc_rfc_dest
    EXCEPTIONS
      OTHERS      = 1.

  p_retorno = sy-subrc.

ENDFORM.                    " ENVIO_FTP

*&---------------------------------------------------------------------*
*&      Form  ftp_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_COMMAND  text
*----------------------------------------------------------------------*
FORM ftp_command USING p_command.

  REFRESH li_result.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle        = lv_handle
      command       = p_command
    TABLES
      data          = li_result
    EXCEPTIONS
      tcpip_error   = 1
      command_error = 2
      data_error    = 3.

ENDFORM.                    "ftp_command
