REPORT zfitr010 NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132.

*----------------------------------------------------------------------*
* Tablas usadas.
*----------------------------------------------------------------------*
TABLES : reguh,   "  Datos de pago del programa de pagos              02
         regup,
         bkpf,
         bseg,
         payr,     "  Cheque pago
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
         t001,
         zfolio_bbva,
         zlog_bbva_vv.

DATA : BEGIN OF tabla_00 OCCURS 0.
        INCLUDE STRUCTURE reguh.
DATA : END OF tabla_00.



DATA : BEGIN OF reg01 OCCURS 0,
           rut_prv(08)           TYPE n,
           rut_dvr(01)           TYPE c,
           identificador(15)     TYPE c,
           nombre(45)            TYPE c,
           tipo_proceso(01)      TYPE c,
           cod_banco(03)         TYPE c,
           cuenta_abo(20)        TYPE c,
           destino(01)           TYPE c,
           monto_pago(09)        TYPE n,
 END OF reg01.


DATA: zaldt      LIKE reguh-zaldt,
      xblnr      LIKE bkpf-xblnr,
      bktxt      LIKE bkpf-bktxt,
      total(15),
      valut      LIKE reguh-valut,
      zzmot_emis LIKE bseg-zzmot_emis,
      gjahr      LIKE bkpf-gjahr,
      belnr      LIKE bkpf-belnr,
      cuenta     LIKE reguh-ubhkt,
      cuenta_2   LIKE reguh-ubhkt,
      contabilizar(1),
      resp(1).

DATA:    BEGIN OF tlaufk OCCURS 1.
        INCLUDE STRUCTURE ilaufk.
DATA:    END OF tlaufk.

DATA lt_dynpfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
DATA lv_dynpro_prog LIKE d020s-prog.

DATA:   monto_z     LIKE bseg-dmbtr ,
        lins(07)    TYPE c VALUE 0,
        lineas(5)    TYPE n,
        secuencia(2)   TYPE n,
        archivo_a(130) TYPE c.

INCLUDE zbatchinput.
DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.

*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.
PARAMETER : bukrs     LIKE bkpf-bukrs     OBLIGATORY,
            v_fecha   LIKE reguh-laufd    OBLIGATORY,
            v_nomina  LIKE f110v-laufi    OBLIGATORY.
*            v_fecpag  LIKE reguh-laufd    OBLIGATORY.

SELECTION-SCREEN SKIP 1.


PARAMETER  : v_nrotra   LIKE  zlog_bbva_vv-nrotran    OBLIGATORY.

"PARAMETER  : v_hbkid  LIKE payr-hbkid  OBLIGATORY,
"             v_hktid  LIKE payr-hktid  OBLIGATORY,
"             v_chect  LIKE payr-chect  OBLIGATORY.

SELECTION-SCREEN SKIP 1.

PARAMETER  : archivo     LIKE rlgrap-filename DEFAULT 'C:\TRANSFER\'.

SELECTION-SCREEN SKIP 1.

PARAMETERS : par_tes RADIOBUTTON GROUP test       " Ejecución en Test
                     DEFAULT 'X',
             par_di  RADIOBUTTON GROUP test.      " Ejecución real


SELECTION-SCREEN END OF BLOCK marco1 .


AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo .
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = archivo.

AT SELECTION-SCREEN ON bukrs.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD bukrs.

  IF sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
    MESSAGE e526(icc_tr) WITH bukrs.
  ENDIF.

  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_fecha.


  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'BUKRS'.
  APPEND lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

  READ TABLE lt_dynpfields INDEX 1.
  bukrs = lt_dynpfields-fieldvalue .
  TRANSLATE bukrs TO UPPER CASE.

  REFRESH tlaufk.
  tlaufk-laufk = space.
  tlaufk-sign  = 'I'.
  APPEND tlaufk.
  CALL FUNCTION 'ZF4_ZAHLLAUF'
    EXPORTING
      f1typ = 'D'
      f2nme = 'F110V-LAUFI'
      bukrs = bukrs
      banco = '504'
    IMPORTING
      laufd = v_fecha
      laufi = v_nomina
    TABLES
      laufk = tlaufk.

  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'V_NOMINA'.
  APPEND lt_dynpfields.

  lt_dynpfields-fieldname = 'ARCHIVO'.
  APPEND lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

  READ TABLE lt_dynpfields INDEX 1.
  lt_dynpfields-fieldvalue = v_nomina.
  MODIFY  lt_dynpfields INDEX 1.


  READ TABLE lt_dynpfields INDEX 2.
*  CONCATENATE 'C:\TRANSFER\' bukrs '_BCORPBANCA' '_' sy-datum '_' sy-uzeit '.txt' INTO
*  lt_dynpfields-fieldvalue.
  lt_dynpfields-fieldvalue = archivo.

  MODIFY  lt_dynpfields INDEX 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
    TABLES
      dynpfields = lt_dynpfields.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_nomina.

  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'BUKRS'.
  APPEND lt_dynpfields.


  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.


  READ TABLE lt_dynpfields INDEX 1.
  bukrs = lt_dynpfields-fieldvalue .
  TRANSLATE bukrs TO UPPER CASE.

  REFRESH tlaufk.
  tlaufk-laufk = space.
  tlaufk-sign  = 'I'.
  APPEND tlaufk.
  CALL FUNCTION 'ZF4_ZAHLLAUF'
    EXPORTING
      f1typ = 'I'
      f2nme = 'F110V-LAUFD'
      bukrs = bukrs
      banco = '027'
    IMPORTING
      laufd = v_fecha
      laufi = v_nomina
    TABLES
      laufk = tlaufk.

  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'V_FECHA'.
  APPEND lt_dynpfields.
  lt_dynpfields-fieldname = 'ARCHIVO'.
  APPEND lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

  READ TABLE lt_dynpfields INDEX 1.
  CONCATENATE v_fecha+06(2) '.' v_fecha+04(2) '.' v_fecha+0(4) INTO lt_dynpfields-fieldvalue.
  MODIFY  lt_dynpfields INDEX 1.


  READ TABLE lt_dynpfields INDEX 2.
  CONCATENATE 'C:\TRANSFER\' bukrs '_BCORPBANCA' '_' sy-datum '_' sy-uzeit '.txt' INTO
   lt_dynpfields-fieldvalue.
  MODIFY  lt_dynpfields INDEX 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
    TABLES
      dynpfields = lt_dynpfields.



AT SELECTION-SCREEN.


START-OF-SELECTION.

  "  SELECT SINGLE * FROM payr WHERE zbukr =  bukrs
  "                            AND   hbkid  = v_hbkid
  "                            AND   hktid  = v_hktid
  "                            AND   rzawe  = 'C'
  "                            AND   chect  = v_chect.

  "  IF sy-subrc <> 0.
  "    MESSAGE i004(zfi) WITH 'Cheque No Existe'.
  "  ELSE.
  "    PERFORM cargo_datos.
  "  ENDIF.
  "
  IF par_di = 'X'.
    SELECT SINGLE * FROM zlog_bbva_vv WHERE bukrs = bukrs
                                      AND   laufd = v_fecha
                                      AND   laufi = v_nomina.

    IF sy-subrc = 0.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'Confirmación '
          text_question         = 'Archivo ya Generado y Contabilizado. ¿Desea Continuar?'
          default_button        = '2'
          display_cancel_button = 'X'
        IMPORTING
          answer                = resp.

      IF  resp <> '1'.
        LEAVE PROGRAM.
      ENDIF.
      contabilizar = 'N'.

    ENDIF.

  ENDIF.

  IF v_nrotra IS INITIAL.
    MESSAGE i004(zfi) WITH 'Debe Ingresar Numero Transferencia'.
  ELSE.
    PERFORM cargo_datos.
*    Modificacion Herman graba tes_docpago
    if par_di = 'X'.
*        SET PARAMETER ID: 'BUKRS' FIELD bukrs,
*                  'V_FECHA' FIELD v_fecha,
*                  'V_NOMINA' field v_nomina.

*        CALL TRANSACTION 'ZJOB_INS_TRANSFER' AND SKIP FIRST SCREEN.

        submit ZJOB_INS_TRANSFER and return
                with bukrs = bukrs
                with v_fecha = v_fecha
                with v_nomina = v_nomina.

    endif.
*    Fin Modificacion
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  cargo_datos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cargo_datos.
  SELECT SINGLE * FROM reguh
                 WHERE laufd       = v_fecha
                 AND   laufi       = v_nomina
                 AND   zbukr       = bukrs.


  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Nomina no corresponde a Sociedad' bukrs.

  ENDIF.


* Rescatamos Datos.
  SELECT *  FROM  reguh
           WHERE  laufd      = v_fecha
           AND    laufi      = v_nomina
           AND    xvorl      = ' '
           AND  ( rzawe = 'V' ).

    IF ( reguh-stcd1 IS INITIAL ) OR ( reguh-zstc1 IS INITIAL ).
      SELECT SINGLE stcd1 INTO reguh-stcd1
        FROM lfa1 WHERE lifnr = reguh-lifnr.
    ENDIF.

    IF ( NOT reguh-stcd1 IS INITIAL ) OR ( NOT reguh-zstc1 IS INITIAL ).
      MOVE-CORRESPONDING reguh TO tabla_00.


* revisamos si paga a un beneficiario alternativo
      IF tabla_00-stcd1 <> tabla_00-zstc1.
        tabla_00-stcd1 = tabla_00-zstc1.
        tabla_00-name1 = tabla_00-znme1.
        tabla_00-ort01 = tabla_00-zort1.
        tabla_00-stras = tabla_00-zstra.
      ENDIF.
      APPEND tabla_00.
      IF sy-dbcnt = 1.
        CONCATENATE  reguh-zaldt+6(2) reguh-zaldt+4(2) reguh-zaldt+0(4) INTO zaldt.
        CONCATENATE  reguh-valut+6(2) reguh-valut+4(2) reguh-valut+0(4) INTO valut.
        cuenta = reguh-ubhkt.
* CBD - 2012-01-11 - MANEJO CUENTA CARGO
        CONCATENATE cuenta+0(9) '3' into cuenta_2.
* CBD - 2012-01-11 - MANEJO CUENTA CARGO
        SELECT  SINGLE bktxt INTO bktxt FROM bkpf WHERE belnr =  reguh-vblnr
                                          AND   gjahr = reguh-zaldt(4).

        SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
                                 AND   laufi = reguh-laufi
                                 AND   xvorl = reguh-xvorl
                                 AND   zbukr = reguh-zbukr
                                 AND   lifnr = reguh-lifnr
                                 AND   kunnr = reguh-kunnr
                                 AND   empfg = reguh-empfg
                                 AND   vblnr = reguh-vblnr.
        SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
                               AND  belnr = regup-belnr
                               AND  gjahr = regup-gjahr
                               AND  buzei = regup-buzei.

        IF sy-subrc = 0.
          zzmot_emis = bseg-zzmot_emis.
          IF zzmot_emis IS INITIAL.
            zzmot_emis = 'TESORERIA'.
          ENDIF.
        ELSE.
          zzmot_emis = 'TESORERIA'.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDSELECT.

*Procesamos Datos
  SORT tabla_00 BY  lifnr.   " prov

  DESCRIBE TABLE tabla_00 LINES lins.

  IF lins <> 0.
*    PERFORM listado.  "informe.

    PERFORM preparo_salida.

  ELSE.
    WRITE : /,/, 'No Existe Informacion Para Procesar....!!!!!!!!'.

  ENDIF.
ENDFORM.                    "cargo_datos

*&---------------------------------------------------------------------*
*&      Form  PREPARO_SALIDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM preparo_salida.
  DATA : folio_aux(15).
  DATA : largo(05) type n.
  DATA : largo1(05) type n.
  REFRESH reg01.

 call function 'ENQUEUE_EZFOLIO'
    exporting
      mode_zfolio_bbva = 'E'
      mandt            = sy-mandt
      bukrs            = bukrs
      codigo           = '001'.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
       with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  SELECT SINGLE * FROM zfolio_bbva WHERE bukrs = bukrs
                                   AND   codigo ='001'.
  IF sy-subrc <> 0.
    zfolio_bbva-bukrs = bukrs.
    zfolio_bbva-codigo ='001'.
    zfolio_bbva-folio = 0.
  ENDIF.

  lineas = 0.
  secuencia = 1.

  LOOP AT tabla_00.

    IF lineas = 9000.
      CONCATENATE archivo bukrs v_fecha v_nomina  secuencia INTO archivo_a.

      PERFORM bajar_archivo.
      CLEAR: lineas, monto_z.
    ENDIF.

    zfolio_bbva-folio =  zfolio_bbva-folio + 1.
    IF par_di = 'X'.
      MODIFY  zfolio_bbva.
    ENDIF.
    CONCATENATE bukrs zfolio_bbva-folio INTO folio_aux .
    TRANSLATE tabla_00-zstc1 USING '- ' .
    CONDENSE  tabla_00-zstc1 NO-GAPS    .
    largo = strlen( tabla_00-zstc1 ) - 1.
    reg01-rut_prv         =  tabla_00-zstc1+0(largo).
    reg01-rut_dvr        =  tabla_00-zstc1+largo(1).

    reg01-identificador   =  folio_aux.
    reg01-nombre          =  tabla_00-name1.
    reg01-tipo_proceso    = '1'.
    reg01-cod_banco       = '504'.
    reg01-cuenta_abo      =''.
    reg01-destino         = '3'.
    reg01-monto_pago = tabla_00-rbetr * -100.
    APPEND reg01.

    IF par_di = 'X'.
      UPDATE reguh
      SET    identif_pago = folio_aux
             fecha_envio = sy-datum
             usuario_envio = sy-uname
      WHERE  laufd =  tabla_00-laufd
      AND laufi = tabla_00-laufi
      AND xvorl = tabla_00-xvorl
      AND zbukr = tabla_00-zbukr
      AND lifnr = tabla_00-lifnr
      AND kunnr = tabla_00-kunnr
      AND empfg = tabla_00-empfg
      AND vblnr = tabla_00-vblnr.
    ENDIF.

    lineas = lineas + 1.
    monto_z  =   monto_z + ( tabla_00-rbetr * -1 ).
    .
  ENDLOOP.

CALL FUNCTION 'ENQUEUE_EZFOLIO'
 EXPORTING
   MODE_ZFOLIO_BBVA       = 'E'
   MANDT                  = SY-MANDT
   BUKRS                  = bukrs
   CODIGO                 = '001'.

  IF lineas > 0.
    CONCATENATE archivo bukrs v_fecha v_nomina  secuencia INTO archivo_a.
    PERFORM bajar_archivo.
  ENDIF.

ENDFORM.                    " PREPARO_SALIDA

*&---------------------------------------------------------------------*
*&      Form  bajar_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bajar_archivo.
*-----------------*
  DATA : nombre_a  TYPE string.

  nombre_a = archivo_a.

  sy-subrc = 0.

  IF par_di = 'X'.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = nombre_a
        filetype                = 'ASC'
        confirm_overwrite       = 'X'
      TABLES
        data_tab                = reg01
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.


  ENDIF.

  IF sy-subrc <> 0.
    WRITE :/ 'error!!!!'  ,
           /  sy-msgv1 ,
           /  sy-msgv2 ,
           /  sy-msgv3 ,
           /  sy-msgv4 .

  ELSE.
    SKIP 2 .
    FORMAT COLOR 3 ON.

    IF par_di = 'X'.
      WRITE : / 'Se genero archivo :', archivo_a.
      IF contabilizar <> 'N'.
        PERFORM  contabilizacion.
      ENDIF.
      PERFORM  grabar_log.
    ELSE.
      WRITE : / 'Se generara el siguiente archivo :', archivo_a.
    ENDIF.
    WRITE : /10 'total registros : ', lineas,
                'total monto  : ',  monto_z CURRENCY 'CLP'.
    FORMAT COLOR 3 OFF.
  ENDIF.

  secuencia = secuencia + 1.
  refresh reg01.

*----------------------------------------------
ENDFORM.                    "bajar_archivo



TOP-OF-PAGE.
  WRITE : /1  t001-butxt,
           43   'ARCHIVO DE PAGO PROVEEDORES BANCO BBVA' ,
           120 sy-datum,

          /120 sy-uzeit ,
          /27 'Identificación De Propuesta de Pago : ',
              'Fecha Nomina: ',v_fecha, ' Nomina:' ,  v_nomina ,
          120 sy-pagno.




  WRITE : / sy-uline(136).
*&---------------------------------------------------------------------*
*&      Form  GRABAR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM grabar_log.
  zlog_bbva_vv-bukrs = bukrs.
  zlog_bbva_vv-laufd = v_fecha.
  zlog_bbva_vv-laufi = v_nomina.
  zlog_bbva_vv-fecha_gen = sy-datum.
  zlog_bbva_vv-hora_gen = sy-uzeit.
  zlog_bbva_vv-uname = sy-uname.
  CONCATENATE bukrs v_fecha v_nomina  secuencia INTO zlog_bbva_vv-nombre_arc.
  zlog_bbva_vv-total  = monto_z.
  zlog_bbva_vv-lineas = lineas.
  zlog_bbva_vv-gjahr  =  gjahr.
  zlog_bbva_vv-belnr  =  belnr.
  zlog_bbva_vv-nrotran  =  v_nrotra.
  INSERT zlog_bbva_vv.

ENDFORM.                    "GRABAR_LOG
*&---------------------------------------------------------------------*
*&      Form  contabilizacion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM contabilizacion.

  CLEAR bdcdata.
  REFRESH bdcdata.

  WRITE  monto_z CURRENCY 'CLP'  TO total.
  CONCATENATE v_fecha v_nomina  secuencia INTO xblnr.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BKPF-BLDAT'
                                zaldt.
  PERFORM bdc_field       USING 'BKPF-BLART'
                                'SA'.
  PERFORM bdc_field       USING 'BKPF-BUKRS'
                                 bukrs.
  PERFORM bdc_field       USING 'BKPF-BUDAT'
                                zaldt.
  PERFORM bdc_field       USING 'BKPF-WAERS'
                                'CLP'.
  PERFORM bdc_field       USING 'BKPF-XBLNR'
                                xblnr.
  PERFORM bdc_field       USING 'BKPF-BKTXT'
                                bktxt.

  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                 '40'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                cuenta.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.

  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                total.
  PERFORM bdc_field       USING 'BSEG-VALUT'
                                 valut.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                                bktxt.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                bktxt.
  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                '50'.
* CBD - 2012-01-11 - MANEJO CTA CARGO - PERFORM bdc_field       USING 'RF05A-NEWKO'
* CBD - 2012-01-11 - MANEJO CTA CARGO -                               cuenta.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                cuenta_2.

  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'COBL-ZZMOT_EMIS'.
  PERFORM bdc_field       USING 'COBL-ZZMOT_EMIS'
                                 zzmot_emis.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BSEG-VALUT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                total.
  PERFORM bdc_field       USING 'BSEG-VALUT'
                                valut.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                bktxt.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                              xblnr.

  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'COBL-ZZMOT_EMIS'.
  PERFORM bdc_field       USING 'COBL-ZZMOT_EMIS'
                                zzmot_emis.

  CALL TRANSACTION 'F-02' USING bdcdata
                                  MODE 'E'
                                  UPDATE 'S'
                                  MESSAGES INTO itab.

  LOOP AT itab.
    IF itab-msgid = 'F5' AND     itab-msgnr = '312'.
      belnr = itab-msgv1.
      gjahr = zaldt+4(4).
    ENDIF.

  ENDLOOP.

ENDFORM.                    "contabilizacion
