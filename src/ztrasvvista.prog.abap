
* Programa :  ZTRASVVISTA
* Módulo   : FI - Finanzas
* Documento:
* Usuario responsable:
* Consultor funcional:
* Consultor ABAP     : HCASTILLO
* Descripción: Programa de Carga archivo plano a oracle
* Transacción:
* Juego de datos:
************************************************************************
REPORT  ztrasvvista.
INCLUDE ole2incl.
DATA: con TYPE ole2_object,
      rec TYPE ole2_object,
       contador   TYPE i,
       v_error TYPE REF TO cx_sy_native_sql_error.

*=======================================================================
* Tablas
*=======================================================================

"Definimos las tablas que vamos a leer
DATA: BEGIN OF tline OCCURS 0,
    linea(186),
END OF tline.
DATA : sql(1023),
       xvalor(186),
       x_numero_empresa(10),
       x_rut_emisor(9),
       x_cuenta_cargo(10),
       x_nombre_beneficiario(50),
       x_rut_beneficiario(9),
       x_monto(15),
       x_numero_cheque(9),
       x_estado_pago(21),
       x_centro_pago(4),
       x_fecha_recepcion(10),
       x_numero_lote(3),
       x_codigo_identificacion(15),
       x_fecha_pago(10),
       x_fecha_estado(10).
.



SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-t01.
PARAMETERS:
     leer LIKE rlgrap-filename DEFAULT 'C:\' .
SELECTION-SCREEN END OF BLOCK data.

*=======================================================================
* Start-of-selection
*=======================================================================
AT SELECTION-SCREEN ON VALUE-REQUEST FOR leer .
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = leer.

START-OF-SELECTION.

  CASE leer.
    WHEN ''.
      MESSAGE i004(zfi) WITH 'Escribe una Ruta'(i02).
    WHEN 'C:\'.
      MESSAGE i004(zfi) WITH 'Escribe un Nombre al Archivo " .TXT "'(i02).
    WHEN OTHERS.
      CALL FUNCTION 'WS_UPLOAD'
        EXPORTING
          filename            = leer
          filetype            = 'DAT'
        TABLES
          data_tab            = tline
        EXCEPTIONS
          conversion_error    = 1
          file_open_error     = 2
          file_read_error     = 3
          invalid_table_width = 4
          invalid_type        = 5
          no_batch            = 6
          unknown_error       = 7
          OTHERS              = 8.

      IF sy-subrc <> 0.
        WRITE: / 'Error Uploading',  leer , sy-subrc.
        MESSAGE i004(zfi) WITH 'Proceso erroneo '(i02).
        STOP.
      ENDIF.
      PERFORM get_rec.
      MESSAGE i004(zfi) WITH 'Proceso Generado '(i02).
  ENDCASE.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  Get_Rec
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_rec.

  PERFORM openconnection.
  contador = 0.
* WRITE: / 'EMPIEZA CARGA:'.
  TRY.
      LOOP AT tline.
        xvalor = tline-linea.
        x_numero_empresa         = xvalor+0(10).
        x_rut_emisor             = xvalor+10(9).
        x_cuenta_cargo           = xvalor+19(10).
        x_nombre_beneficiario    = xvalor+29(50).
        x_rut_beneficiario       = xvalor+79(9).
        x_monto                  = xvalor+88(15).
        x_numero_cheque          = xvalor+103(9).
        x_estado_pago            = xvalor+112(21).
        x_centro_pago            = xvalor+133(4).
        x_fecha_recepcion        = xvalor+137(10).
        x_numero_lote            = xvalor+147(3).
        x_codigo_identificacion  = xvalor+150(15).
        x_fecha_pago             = xvalor+165(10).
        x_fecha_estado           = xvalor+175(10).

        OVERLAY x_codigo_identificacion WITH '000000000000000'.
        OVERLAY x_centro_pago  WITH '0000'.

        EXEC SQL.
*      INSERT INTO  SAPBBVA_EMITIDOS_NOCOBRADOS
*      (NUMERO_EMPRESA,RUT_EMISOR,CUENTA_CARGO,
*       NOMBRE_BENEFICIARIO,RUT_BENEFICIARIO,
*       MONTO,NUMERO_CHEQUE,ESTADO_PAGO,CENTRO_PAGO,
*       FECHA_RECEPCION,NUMERO_LOTE,CODIGO_IDENTIFICACION,FECHA_PAGO,FECHA_ESTADO
*      )
*      values (
*       :X_NUMERO_EMPRESA,
*       :X_RUT_EMISOR,
*       :X_CUENTA_CARGO,
*       :X_NOMBRE_BENEFICIARIO,
*       :X_RUT_BENEFICIARIO,
*       :X_MONTO,
*       :X_NUMERO_CHEQUE,
*       :X_ESTADO_PAGO,
*       :X_CENTRO_PAGO,
*       :X_FECHA_RECEPCION,
*       :X_NUMERO_LOTE,
*       :X_CODIGO_IDENTIFICACION,
*       :X_FECHA_PAGO,
*       :X_FECHA_ESTADO)

          EXECUTE PROCEDURE PL_INSERT_EMITIDOS_NOCOBRADOS(
          IN :X_NUMERO_EMPRESA,
          IN :X_RUT_EMISOR,
          IN :X_CUENTA_CARGO,
          IN :X_NOMBRE_BENEFICIARIO,
          IN :X_RUT_BENEFICIARIO,
          IN :X_MONTO,
          IN :X_NUMERO_CHEQUE,
          IN :X_ESTADO_PAGO,
          IN :X_CENTRO_PAGO,
          IN :X_FECHA_RECEPCION,
          IN :X_NUMERO_LOTE,
          IN :X_CODIGO_IDENTIFICACION,
          IN :X_FECHA_PAGO,
          IN :X_FECHA_ESTADO)

        ENDEXEC.
        contador = contador + 1.
      ENDLOOP.
*   EXEC SQL.
*     EXECUTE PROCEDURE prc_tr_act_estados
*   endexec.
      WRITE: / 'REGISTROS TRASPASADOS:', contador.

    CATCH cx_sy_native_sql_error INTO v_error.
      WRITE: / 'ERROR:', v_error->kernel_errid.

  ENDTRY.
  PERFORM closeconnection.

*  PERFORM generate_job.


*    CALL TRANSACTION 'ZFITR012' AND SKIP FIRST SCREEN.

ENDFORM.                    "Get_Rec

*----------------------------------------------------------------------*
* RUTINAS DE CONEXION  *
*----------------------------------------------------------------------*
FORM openconnection.
  EXEC SQL.
    connect to 'SAPCSC' as 'CON'
  ENDEXEC.
  EXEC SQL.
    set connection 'CON'
  ENDEXEC.
ENDFORM.                    "openconnection
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM closeconnection.
  EXEC SQL.
    SET CONNECTION DEFAULT
  ENDEXEC.
ENDFORM.                    "closeconnection
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GENERATE_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM generate_job .
  DATA: jobname LIKE tbtcjob-jobname VALUE
                             'CAMBIO ESTADO OP'.
  DATA: jobcount LIKE tbtcjob-jobcount,
        host LIKE msxxlist-host.
  DATA: BEGIN OF starttime.
          INCLUDE STRUCTURE tbtcstrt.
  DATA: END OF starttime.
  DATA: starttimeimmediate LIKE btch0000-char1 VALUE 'X',
        str_date(10) TYPE c.

*    CONCATENATE  v_fecha+6(2) v_fecha+4(2) v_fecha+0(4) into str_date SEPARATED BY '.' .
*   Job open
  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      delanfrep        = ' '
      jobgroup         = ' '
      jobname          = jobname
      sdlstrtdt        = sy-datum
      sdlstrttm        = sy-uzeit
    IMPORTING
      jobcount         = jobcount
    EXCEPTIONS
      cant_create_job  = 01
      invalid_job_data = 02
      jobname_missing  = 03.
  IF sy-subrc NE 0.
    "error processing
  ENDIF.

*   Insert process into job
  SUBMIT zfitr011 AND RETURN
                 USER sy-uname
                 VIA JOB jobname
                 NUMBER jobcount.
  IF sy-subrc > 0.
    "error processing
  ENDIF.

*   Close job
  starttime-sdlstrtdt = sy-datum + 1.
  starttime-sdlstrttm = '220000'.
  CALL FUNCTION 'JOB_CLOSE'
       EXPORTING
"            event_id             = starttime-eventid
"            event_param          = starttime-eventparm
"            event_periodic       = starttime-periodic
            jobcount             = jobcount
            jobname              = jobname
"            laststrtdt           = starttime-laststrtdt
"            laststrttm           = starttime-laststrttm
"            prddays              = 1
"            prdhours             = 0
"            prdmins              = 0
"            prdmonths            = 0
"            prdweeks             = 0
"            sdlstrtdt            = starttime-sdlstrtdt
"            sdlstrttm            = starttime-sdlstrttm
            strtimmed            = starttimeimmediate
"            targetsystem         = host
       EXCEPTIONS
            cant_start_immediate = 01
            invalid_startdate    = 02
            jobname_missing      = 03
            job_close_failed     = 04
            job_nosteps          = 05
            job_notex            = 06
            lock_failed          = 07
            OTHERS               = 99.
  IF sy-subrc EQ 0.
    "error processing
  ENDIF.

  WRITE: /, 'Se ha creado el JOB con el siguiente Nombre: ',
          jobname.
ENDFORM.                    " GENERATE_JOB
