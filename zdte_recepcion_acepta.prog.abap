*&---------------------------------------------------------------------*
*& Report  ZFTP_TEST
*&
*&---------------------------------------------------------------------*
*&SCL 2018
*&
*&---------------------------------------------------------------------*

REPORT  zdte_recepcion_acepta.
INCLUDE zdte_recepcion_acepta_top.


AT SELECTION-SCREEN OUTPUT.

START-OF-SELECTION.

END-OF-SELECTION.

**Set de datos
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*    FROM setleaf
*    INTO TABLE t_set
*   WHERE setname = 'ZDTE_CARGA_DTE'.
*
* NEW CODE
  SELECT *

    FROM setleaf
    INTO TABLE t_set
   WHERE setname = 'ZDTE_CARGA_DTE' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  REFRESH: s_tipodte, s_tipodte_ref.
*Cargamos una tabla ranges
  LOOP AT t_set .
    s_tipodte-sign    = t_set-valsign.
    s_tipodte-option  = t_set-valoption.
    s_tipodte-low     = t_set-valfrom.
    APPEND s_tipodte.
  ENDLOOP.
  IF s_tipodte[] IS INITIAL .
    WRITE:/ 'Set de Datos vacío. Ingresar TipoDte a procesar ZDTE_CARGA_DTE'.
    EXIT.
  ENDIF.

****Tipo de documentos de referencia validos
  s_tipodte_ref-sign    = 'I'.
  s_tipodte_ref-option  = 'EQ'.
  s_tipodte_ref-low = 'HES'.APPEND s_tipodte_ref.
  s_tipodte_ref-low = '801'.APPEND s_tipodte_ref.
  s_tipodte_ref-low = '50'. APPEND s_tipodte_ref.
  s_tipodte_ref-low = '52'. APPEND s_tipodte_ref.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * INTO w_ftp
*    FROM zdte_ftp
*   WHERE programa EQ 'ZDTE_RECEPCION_ACEPTA'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  INTO w_ftp
    FROM zdte_ftp
   WHERE programa EQ 'ZDTE_RECEPCION_ACEPTA' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc EQ 0.
    lc_rfc_dest = w_ftp-rfc_dest  .
    p_user      = w_ftp-usuario   .
    p_pwd       = w_ftp-pwd       .
    p_ip        = w_ftp-host      .
    v_path_01   = w_ftp-ruta      .
  ELSE.
    WRITE:/ 'Error, Sin parámetros de FTP'.
    EXIT.
  ENDIF.

***FTP
  PERFORM iniciar_conexion.

***Buscar archivos en el FTP
*Armamos comandos FTP
  CONCATENATE  'cd'  v_path_01   INTO  v_cmd_01 SEPARATED BY space. "Buscamos directorio procesados.
  CONCATENATE  'ls'  ''  INTO  v_cmd_02 SEPARATED BY space. "Buscamos los recibidos

  REFRESH li_result.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle        = lv_handle
      command       = v_cmd_01
    TABLES
      data          = li_result
    EXCEPTIONS
      tcpip_error   = 1
      command_error = 2
      data_error    = 3.


  REFRESH li_result.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle        = lv_handle
      command       = v_cmd_02
    TABLES
      data          = li_result
    EXCEPTIONS
      tcpip_error   = 1
      command_error = 2
      data_error    = 3.

*Buscamos los xml dentro del directorio y los guardamos en una tabla interna.
  LOOP AT li_result.
    IF li_result CS '.XML' OR li_result CS '.xml'.
      gt_dte = li_result.
      APPEND gt_dte.
    ENDIF.
  ENDLOOP.


  CREATE OBJECT gcl_xml.
  CREATE OBJECT lo_xml.
  CREATE OBJECT lo_xml_dte.

  LOOP AT  gt_dte.
    REFRESH : li_data , gt_xml_data.
    CLEAR   : li_data ,  gv_xml_string, l_decode_str , gwa_xml_data, wa_doc_rec , wa_doc_rec_ref , c_error.

    wa_doc_rec-fchrec  = sy-datum. "gt_dte-fecha.
    wa_doc_rec-horrec  = sy-uzeit. "gt_dte-hora.

*Transfer data in internal table li_data to FTP
    CALL FUNCTION 'FTP_SERVER_TO_R3'
      EXPORTING
        handle         = lv_handle
        fname          = gt_dte-nombre
        character_mode = 'X'
      TABLES
        text           = li_data
      EXCEPTIONS
        tcpip_error    = 1
        command_error  = 2
        data_error     = 3
        OTHERS         = 4.

    IF sy-subrc EQ 1 .
      PERFORM iniciar_conexion.

      CALL FUNCTION 'FTP_SERVER_TO_R3'
        EXPORTING
          handle         = lv_handle
          fname          = gt_dte-nombre
          character_mode = 'X'
        TABLES
          text           = li_data
        EXCEPTIONS
          tcpip_error    = 1
          command_error  = 2
          data_error     = 3
          OTHERS         = 4.

    ENDIF.

    IF li_data[] IS INITIAL.
      WRITE:/ 'Error FTP TO R3 ,Archivo -->' ,gt_dte-nombre , ' TCPIP_ERROR '.
      CONTINUE.
    ELSE.
      WRITE:/ 'FTP TO R3 OK ,Archivo -->' ,gt_dte-nombre.
    ENDIF.

*****Rutinas para descomponer XML

* Consulta
    CLEAR request_data.
    LOOP AT li_data.
      CONCATENATE request_data li_data INTO request_data.
    ENDLOOP.

* Proceso
*  Parseamos el XML principal

    CALL METHOD lo_xml->parse_string
      EXPORTING
        stream = request_data.

*Obtenemos URL Factura
    lo_node             = lo_xml->find_node( name = 'URI' ).
    IF lo_node IS NOT INITIAL.
      l_xml_dte          = lo_node->get_value( ).

      wa_doc_rec-url     = l_xml_dte.
    ENDIF.

*Obtenemos el cuerpo del XML
    lo_node             = lo_xml->find_node( name = 'XML_DTE' ).
    IF lo_node IS NOT INITIAL.
      l_xml_dte          = lo_node->get_value( ).

    ENDIF.

*Decodifico  el  xml que esta en base 64
    CALL METHOD cl_http_utility=>if_http_utility~decode_base64
      EXPORTING
        encoded = l_xml_dte
      RECEIVING
        decoded = l_decode_str.

*  Parseamos el  cuerpo del XML
    CALL METHOD lo_xml_dte->parse_string
      EXPORTING
        stream = l_decode_str.


    CALL METHOD lo_xml_dte->render_2_xstring
      IMPORTING
        retcode = gv_subrc
        stream  = gv_xml_string
        size    = gv_size.


* Convert XML to internal table
    CALL FUNCTION 'SMUM_XML_PARSE'
      EXPORTING
        xml_input = gv_xml_string
      TABLES
        xml_table = gt_xml_data
        return    = gt_return.

    IF gt_xml_data[] IS INITIAL.
      c_error = 'X'.
      LOOP AT gt_return INTO wa_return.
        WRITE: / wa_return-message.
      ENDLOOP .
    ENDIF.

    CLEAR cont_ref_ult.
    LOOP AT gt_xml_data INTO gwa_xml_data.
      CASE gwa_xml_data-cname.
        WHEN 'TipoDTE'.
          wa_doc_rec-tipodte   = gwa_xml_data-cvalue.
        WHEN 'Folio'.
          wa_doc_rec-folio     = gwa_xml_data-cvalue.

*********quitar ceros
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = wa_doc_rec-folio
            IMPORTING
              output = wa_doc_rec-folio.

        WHEN 'FchEmis'.
          REPLACE ALL OCCURRENCES OF  '-' IN gwa_xml_data-cvalue WITH ''.
          CONDENSE gwa_xml_data-cvalue NO-GAPS.
          MOVE     gwa_xml_data-cvalue TO wa_doc_rec-fchemis.
        WHEN 'RUTEmisor'.
          wa_doc_rec-rutemisor  = gwa_xml_data-cvalue.
        WHEN 'RznSoc'.
          wa_doc_rec-rznsoc     = gwa_xml_data-cvalue.
        WHEN 'RUTRecep'.
          wa_doc_rec-rutrecep   = gwa_xml_data-cvalue.
        WHEN 'RznSocRecep'.
          wa_doc_rec-rznrecep   = gwa_xml_data-cvalue.
        WHEN 'GiroRecep'.
          wa_doc_rec-girorecep  = gwa_xml_data-cvalue.
        WHEN 'DirRecep'.
          wa_doc_rec-dirrecep   = gwa_xml_data-cvalue.
        WHEN 'MntNeto'.
          PERFORM conv_importe_interno USING gwa_xml_data-cvalue wa_doc_rec-mntneto.
*          wa_doc_rec-mntneto    = gwa_xml_data-cvalue.
        WHEN 'MntExe'.
          PERFORM conv_importe_interno USING gwa_xml_data-cvalue wa_doc_rec-mntexe.
*          wa_doc_rec-mntexe     = gwa_xml_data-cvalue.
        WHEN 'TasaIVA'.
          PERFORM conv_importe_interno USING gwa_xml_data-cvalue wa_doc_rec-tasaiva.
*          wa_doc_rec-tasaiva    = gwa_xml_data-cvalue.
        WHEN 'IVA'.
          PERFORM conv_importe_interno USING gwa_xml_data-cvalue wa_doc_rec-iva.
*          wa_doc_rec-iva        = gwa_xml_data-cvalue.
        WHEN 'MntTotal'.
          PERFORM conv_importe_interno USING gwa_xml_data-cvalue wa_doc_rec-mnttotal.
*          wa_doc_rec-mnttotal   = gwa_xml_data-cvalue.
        WHEN 'FmaPago'.
          wa_doc_rec-formapago  = gwa_xml_data-cvalue.
          CONDENSE wa_doc_rec-formapago NO-GAPS.
        WHEN 'CdgIntRecep'.
          wa_doc_rec-numero_cliente   = gwa_xml_data-cvalue.
*********tabla de referencia.
        WHEN 'NroLinRef'." 1 2 3 4 5 6
          IF wa_doc_rec_ref-nrolinref EQ space.
            wa_doc_rec_ref-nrolinref = gwa_xml_data-cvalue.
          ELSE.
            cont_ref_ult = 'X'.
            wa_doc_rec_ref_ant-nrolinref = gwa_xml_data-cvalue.
          ENDIF.

        WHEN 'TpoDocRef'.
          wa_doc_rec_ref-tpodocref = gwa_xml_data-cvalue.
          CONDENSE wa_doc_rec_ref-tpodocref NO-GAPS.
        WHEN 'FolioRef'.
          wa_doc_rec_ref-folioref = gwa_xml_data-cvalue.
*********quitar ceros
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = wa_doc_rec_ref-folioref
            IMPORTING
              output = wa_doc_rec_ref-folioref.

        WHEN 'FchRef'.
          REPLACE ALL OCCURRENCES OF  '-' IN gwa_xml_data-cvalue WITH ''.
          CONDENSE gwa_xml_data-cvalue NO-GAPS.
          MOVE     gwa_xml_data-cvalue TO wa_doc_rec_ref-fchref.
        WHEN 'CodRef'.
          wa_doc_rec_ref-codref     = gwa_xml_data-cvalue(1).
        WHEN 'RE'.
          wa_doc_rec_ref-rutemisor  = gwa_xml_data-cvalue.
          wa_doc_rec_ref-rutotr     = gwa_xml_data-cvalue.
        WHEN 'RazonRef'.
          wa_doc_rec_ref-razonref = gwa_xml_data-cvalue.

      ENDCASE.

      IF cont_ref_ult EQ 'X'.
        PERFORM update_doc_rec_ref.
      ENDIF.

    ENDLOOP.
    PERFORM update_doc_rec_ref.
    wa_doc_rec-waers  = c_waers .
    wa_doc_rec-erdat  = sy-datum.
    wa_doc_rec-erzet  = sy-timlo.
    wa_doc_rec-ernam  = sy-uname.
    wa_doc_rec-uname  = sy-uname.
    IF wa_doc_rec-formapago EQ '1'.
      wa_doc_rec-estado = 'PC'.
    ELSE.
      wa_doc_rec-estado = 'NU'.
    ENDIF.

****Factura mixta
    IF wa_doc_rec-mntneto > 0 AND wa_doc_rec-mntexe > 0.
      wa_doc_rec-estado = 'FM'.
    ENDIF.

    wa_doc_rec-estado = 'XX'."20018.08.14 - Estado XX

    IF wa_doc_rec-tipodte IN s_tipodte.

      IF wa_doc_rec-folio NE space.
*    Verifica que folio no existe
        SELECT COUNT(*)
          FROM zdte_doc_rec
         WHERE rutemisor = wa_doc_rec-rutemisor
           AND tipodte = wa_doc_rec-tipodte
           AND folio   = wa_doc_rec-folio.

        IF sy-subrc = 0.
          WRITE:/ 'Folio ya procesado, ', wa_doc_rec-folio.
        ELSE.
          WRITE:/ 'Folio Nuevo Ingresado, ', wa_doc_rec-folio.
          MODIFY  zdte_doc_rec FROM wa_doc_rec.
        ENDIF.
      ENDIF.
    ENDIF.


    IF c_error EQ 'X' .
      PERFORM mover_dte_errores USING gt_dte-nombre li_data.
    ELSE.
      PERFORM mover_dte_procesados USING gt_dte-nombre li_data.
    ENDIF.
*Cargamos Referencias



  ENDLOOP.


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

*  EXPORT gt_data FROM gt_data TO SHARED MEMORY indx(aa) ID 'DT'.
*  SUBMIT zdte_gest_doc_rec_upl AND RETURN.


*&---------------------------------------------------------------------*
*&      Form  MOVER_DTE_PROCESADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DTE_NOMBRE  text
*      -->P_LI_DATA  text
*----------------------------------------------------------------------*
FORM mover_dte_procesados  USING    p_gt_dte_nombre
                                    p_li_data.

  CONCATENATE v_path_02 '/'  gt_dte-nombre INTO  v_cmd_03.
*Dejo el archivo en el direcrtorio
  CALL FUNCTION 'FTP_R3_TO_SERVER'
    EXPORTING
      handle         = lv_handle
      fname          = v_cmd_03
      character_mode = 'X'
    TABLES
      text           = li_data
    EXCEPTIONS
      tcpip_error    = 1
      command_error  = 2
      data_error     = 3
      OTHERS         = 4.

*Elimino archivo del directorio recibidos
  CONCATENATE v_path_01 '/'  gt_dte-nombre INTO  v_cmd_03.CONDENSE v_cmd_03 NO-GAPS.
  CONCATENATE 'del' v_cmd_03 INTO v_cmd_03 SEPARATED BY space.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle        = lv_handle
      command       = v_cmd_03
    TABLES
      data          = li_result
    EXCEPTIONS
      tcpip_error   = 1
      command_error = 2
      data_error    = 3.
ENDFORM.                    " MOVER_DTE_PROCESADOS
*&---------------------------------------------------------------------*
*&      Form  INICIAR_CONEXION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM iniciar_conexion .
*  get the length of the password
  CLEAR lv_pwd_len.
  DATA: p_pwd_scramble(30)  TYPE c .

  lv_pwd_len = STRLEN( p_pwd ).

*  get the hexa decimal password
  CALL FUNCTION 'HTTP_SCRAMBLE'
    EXPORTING
      SOURCE      = p_pwd
      sourcelen   = lv_pwd_len
      key         = lc_key
    IMPORTING
      destination = p_pwd_scramble.

*  connect to FTP server
  CALL FUNCTION 'FTP_CONNECT'
    EXPORTING
      user            = p_user
      password        = p_pwd_scramble
      host            = p_ip
      rfc_destination = lc_rfc_dest
    IMPORTING
      handle          = lv_handle
    EXCEPTIONS
       not_connected      .
  IF sy-subrc NE 0.
    WRITE:/ 'Error de conexion al FTP.'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle          = lv_handle
      command         = 'set passive on'
      rfc_destination = lc_rfc_dest
    TABLES
      data            = li_result
    EXCEPTIONS
      tcpip_error     = 1
      command_error   = 2
      data_error      = 3.


ENDFORM.                    " INICIAR_CONEXION
*&---------------------------------------------------------------------*
*&      Form  MOVER_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mover_dte_errores USING p_gt_dte_nombre
                             p_li_data.

  CONCATENATE v_path_03 '/'  gt_dte-nombre INTO  v_cmd_03.
*Dejo el archivo en el direcrtorio
  CALL FUNCTION 'FTP_R3_TO_SERVER'
    EXPORTING
      handle         = lv_handle
      fname          = v_cmd_03
      character_mode = 'X'
    TABLES
      text           = li_data
    EXCEPTIONS
      tcpip_error    = 1
      command_error  = 2
      data_error     = 3
      OTHERS         = 4.

*Elimino archivo del directorio recibidos
  CONCATENATE v_path_01 '/'  gt_dte-nombre INTO  v_cmd_03.CONDENSE v_cmd_03 NO-GAPS.
  CONCATENATE 'del' v_cmd_03 INTO v_cmd_03 SEPARATED BY space.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle        = lv_handle
      command       = v_cmd_03
    TABLES
      data          = li_result
    EXCEPTIONS
      tcpip_error   = 1
      command_error = 2
      data_error    = 3.
ENDFORM.                    " MOVER_ERROR
*&---------------------------------------------------------------------*
*&      Form  CONV_IMPORTE_INTERNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM conv_importe_interno USING p_importe p_internal  .
  CONDENSE p_importe.

  DATA:  vl_value TYPE  bapicurr-bapicurr.
  vl_value = p_importe.

  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
    EXPORTING
      currency                   = 'CLP'
      amount_external            = vl_value
    max_number_of_digits       = 23
   IMPORTING
     amount_internal            = vl_value
*   RETURN                     =
            .
*  CONDENSE p_value.
  MOVE vl_value TO p_internal.

ENDFORM.                    " CONV_IMPORTE_INTERNO
*&---------------------------------------------------------------------*
*&      Form  UPDATE_DOC_REC_REF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_doc_rec_ref .

  wa_doc_rec_ref-rutemisor  = wa_doc_rec-rutemisor.
  wa_doc_rec_ref-folio      = wa_doc_rec-folio.
  wa_doc_rec_ref-tipodte    = wa_doc_rec-tipodte.
  wa_doc_rec_ref-indglobal  = '1'.
  IF wa_doc_rec_ref-tpodocref IN s_tipodte_ref.
    MODIFY  zdte_doc_rec_ref FROM wa_doc_rec_ref.
  ENDIF.
  CLEAR: cont_ref_ult , wa_doc_rec_ref.
  wa_doc_rec_ref-nrolinref = wa_doc_rec_ref_ant-nrolinref.

ENDFORM.                    " UPDATE_DOC_REC_REF
