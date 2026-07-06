*&---------------------------------------------------------------------*
*& ** RUTINAS PARA RUEBA DE GENERACION DE ARCHIVOS DE BANCOS:
*&         012    Banco Estado
*&
*&---------------------------------------------------------------------*

form nvo_formato_012.
REFRESH: ti_adrc, file.
  select single adrnr
         from t001
         into v_adrnr
         where bukrs eq bukrs.

  f_adrnr = v_adrnr.

  if f_adrnr is not initial.
    perform datos_direccion012 using    f_adrnr
                            changing ti_adrc.
  endif.

  read table tabla_00 index 1.

  v_rut = ti_adrc-sort1.

  IF v_rut IS NOT INITIAL.
    PERFORM formatea_rut012 USING    v_rut
                         CHANGING f_rut.
  ENDIF.

  IF par_di <> 'X'.
    file-linea+0(225)      = '*****ARCHIVO DE TEST*****'.
    APPEND file.
    CLEAR  file.
  ENDIF.

  file-linea+0(1)      = '1'.
  file-linea+1(9)      =  f_rut+1(9).
  file-linea+10(1)     =  f_rut+9(1).
  file-linea+20(10)    = '0000000000'.
  concatenate sy-datum+06(2) sy-datum+04(2) sy-datum+0(4) into file-linea+28(10).
  file-linea+38(6)      = sy-uzeit.
  file-linea+44(10)     = '0000000000'.
  file-linea+54(6)      = contar.
  file-linea+60(15)     = sumpagos.
  APPEND file.
  CLEAR  file.

  CALL FUNCTION 'ENQUEUE_EZ_ZFOLIO_PAGBCO'
    EXPORTING
      mode_zfolio_pagobanco = 'E'
      mandt            = sy-mandt
      bukrs            = bukrs
      ubnkl            = v_banco
      codigo           = '001'.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SELECT SINGLE *  FROM zfolio_pagobanco  WHERE bukrs  = bukrs
                                            AND ubnkl  = tabla_00-ubnkl
                                            AND codigo = '001'.
  IF sy-subrc <> 0.
    zfolio_pagobanco-bukrs = bukrs.
    zfolio_pagobanco-codigo ='001'.
    zfolio_pagobanco-folio = 0.
  ENDIF.

  CLEAR lineas.

  LOOP AT tabla_00.
*   Header Proveedor
      CLEAR: v_rut, f_rut, v_ct.
      v_rut = tabla_00-stcd1.
      IF v_rut IS NOT INITIAL.

        PERFORM formatea_rut012  USING v_rut
                           CHANGING f_rut.
      ENDIF.

      zfolio_pagobanco-folio =  zfolio_pagobanco-folio + 1.
      IF par_di = 'X'.
         MODIFY  zfolio_pagobanco.
      ENDIF.

* Si no está procesado, genera nuevo folio
      IF tabla_00-identif_pago IS INITIAL.
* CBD
        CONCATENATE bukrs zfolio_pagobanco-folio INTO folio_aux .
      ELSE.
* Si ya existe un folio anterior, deja el folio existente
        CLEAR folio_aux.
* CBD
* CBD      MOVE tabla_00-identif_pago TO folio_aux.
        MOVE tabla_00-identif_pago TO folio_aux.
* CBD
      ENDIF.

      CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
           EXPORTING
              intext  = tabla_00-name1
           IMPORTING
              outtext = tabla_00-name1.

      CLEAR:  f_adrnr, v_adrnr, ti_adrc, v_mail.
      REFRESH ti_adrc.

      SELECT SINGLE adrnd
             INTO v_adrnr
             FROM knvk
             WHERE lifnr EQ tabla_00-lifnr.

      SELECT SINGLE smtp_addr
             INTO v_mail
             FROM adr6
             WHERE addrnumber EQ tabla_00-adrnr.

      f_adrnr = v_adrnr.

      IF f_adrnr IS NOT INITIAL.
        PERFORM datos_direccion012  USING f_adrnr
                              CHANGING ti_adrc.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
              input  = tabla_00-ubknt
           IMPORTING
              output = v_ct.

      v_monto13 = tabla_00-rbetr * -100.

      REPLACE '.0000' WITH '' INTO v_monto13.
      CONDENSE v_monto13 NO-GAPS.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
               input  = v_monto13
          IMPORTING
               output = v_monto13.


     file-linea+0(1)      = '2'.
     file-linea+1(9)      = f_rut+0(9).
     file-linea+10(1)     = f_rut+9(1).
     file-linea+11(30)    = tabla_00-name1.
     file-linea+41(15)    = '               '.
     file-linea+56(15)    = '               '.
     file-linea+71(2)     = '23'.
     file-linea+73(3)     = '012'.
     file-linea+76(17)    = '00000000000000000'.
     file-linea+93(13)    = v_monto13.
     file-linea+110(40)   = v_mail.
     file-linea+150(15)   = folio_aux.
     file-linea+165(3)    = '001'.
     file-linea+168(2)    = '38'.
     file-linea+170(200)  = '                    '.
     file-linea+370(256)  = '                    '.
     monto_z = monto_z + v_monto13.
     APPEND file.
     CLEAR  file.

     concatenate sy-datum+06(2) sy-datum+04(2) sy-datum+0(4) into file-linea+28(10).
     file-linea+38(6)      = sy-uzeit.
     file-linea+44(10)     = '0000000000'.
     file-linea+54(6)      = contar.
     file-linea+60(15)     = sumpagos.
     APPEND file.
     CLEAR  file.

     concatenate v_fecha+06(2) '/' v_fecha+04(2) '/' v_fecha+0(4) into file-linea+0(10).
      file-linea+10(10)      = f_rut.
      file-linea+21(45)     = tabla_00-name1.
      file-linea+66(15)     = tabla_00-rbetr * -100.
      file-linea+81(30)     = 'Vale vista virtual'.
      file-linea+111(3)     = '027'.
      file-linea+114(18)    = '                  '.
      file-linea+132(25)    = 'Pago en proceso'.
      file-linea+157(50)    = '                                                          '.
      file-linea+207(100)   = '                                                          '.
      if tabla_00-xavis = '4'.
         file-linea+319(2)  = 'SI'.
      else.
         file-linea+319(2)  = 'NO'.
      endif.
      file-linea+321(3)     = contar.
      APPEND file.
      CLEAR  file.


* --------------------------------------------------------------------------
* AQUI DEBE ESTAR EL LOOP DE REGUP
* --------------------------------------------------------------------------
      SELECT * FROM  regup   WHERE   laufd = tabla_00-laufd
                               AND   laufi = tabla_00-laufi
                               AND   xvorl = tabla_00-xvorl
                               AND   lifnr = tabla_00-lifnr
                               AND   zbukr = tabla_00-zbukr.

         v_monto13 = regup-dmbtr.

         REPLACE '.0000' WITH '' INTO v_monto13.
         CONDENSE v_monto13 NO-GAPS.

         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                 input  = v_monto13
              IMPORTING
                 output = v_monto13.

         clear bsik.

         select single *
            from  bsik
           where lifnr  = regup-lifnr
             and bukrs  = regup-bukrs
             and gjahr  = regup-gjahr
             and belnr  = regup-belnr
             and buzei  = regup-buzei.

         perform busca_tipdoc012.

         file-linea+0(04)     = tipdoc.

         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
             EXPORTING
               input  = bsik-xblnr
             IMPORTING
               output = v_doc.


           file-linea+0(1)      = '3'.
           concatenate bsik-bldat+06(2) bsik-bldat+04(2) bsik-bldat+0(4) into file-linea+1(8).
           file-linea+9(13)     = v_monto13.
           file-linea+22(10)    = v_doc.
           file-linea+32(4)    = tipdoc.
           file-linea+36(250)  = bsik-sgtxt.
           APPEND file.
           CLEAR  file.

  ENDSELECT.

        IF par_di = 'X'.
          UPDATE reguh
             SET identif_pago   = folio_aux
                 fecha_envio    = sy-datum
                 usuario_envio  = sy-uname
           WHERE laufd          = tabla_00-laufd
             AND laufi          = tabla_00-laufi
             AND xvorl          = tabla_00-xvorl
             AND zbukr          = tabla_00-zbukr
             AND lifnr          = tabla_00-lifnr
             AND kunnr          = tabla_00-kunnr
             AND empfg          = tabla_00-empfg
             AND vblnr          = tabla_00-vblnr.
        ENDIF.

        lineas = lineas + 1.
  ENDLOOP.      " tabla_00

 CALL FUNCTION 'DEQUEUE_EZ_ZFOLIO_PAGBCO'
    EXPORTING
      mode_zfolio_pagobanco = 'E'
      mandt            = sy-mandt
      bukrs            = bukrs
      ubnkl            = v_banco
      codigo           = '001'.

  If lineas > 0.
     PERFORM baja_archivo012.
  Endif.
ENDFORM.                    " NVO_FORMATO
*&---------------------------------------------------------------------*
*&      Form  BAJA_ARCHIVO
*&---------------------------------------------------------------------*
FORM baja_archivo012 .

  DATA : nombre_a  TYPE string,
         lv_largo TYPE i,
         lv_char TYPE c..

  lv_largo = STRLEN( archivo ).

  lv_largo = lv_largo - 1.
  lv_char = archivo+lv_largo(1).

  IF lv_char = '/' OR
     lv_char = '\'.
  ELSE.
    CONCATENATE archivo '/'
      INTO archivo.
  ENDIF.

  IF par_di = 'X'.
    IF sw IS NOT INITIAL.
      CONCATENATE archivo bukrs v_fecha v_banco v_nomina '_cc' '.txt'
             INTO archivo_a.
    ELSE.
      CONCATENATE archivo bukrs v_fecha v_banco v_nomina '.txt'
             INTO archivo_a.
    ENDIF.
  ELSE.
    IF sw IS NOT INITIAL.
      CONCATENATE archivo 'TEST_' bukrs v_fecha v_banco v_nomina '_cc' '.txt'
             INTO archivo_a.
    ELSE.
      CONCATENATE archivo 'TEST_' bukrs v_fecha v_banco v_nomina '.txt'
             INTO archivo_a.
    ENDIF.
  ENDIF.

  nombre_a = archivo_a.

  IF par_di = 'X'.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = nombre_a
        filetype                = 'ASC'
        confirm_overwrite       = 'X'
      TABLES
        data_tab                = file
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
        PERFORM  contabilizacion012.
      ENDIF.
      PERFORM  grabar_log012.
    ELSE.
      WRITE : / 'Se generara el siguiente archivo :', archivo_a.
    ENDIF.
* CBD - SE CAMBIA EL FORMATEO A CLP, YA NO ES NECESARIO
*    WRITE : /10 'total registros : ', lineas,
*                'total monto  : ',  monto_z CURRENCY 'CLP'.
    WRITE : /10 'total registros : ', lineas,
                  'total monto  : ',  monto_z.
* CBD - SE CAMBIA EL FORMATEO A CLP, YA NO ES NECESARIO
    FORMAT COLOR 3 OFF.
    CLEAR: lineas, monto_z.
  ENDIF.

  secuencia = secuencia + 1.
  REFRESH reg01.
ENDFORM.                    " BAJA_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  FORMATEA_RUT
*&---------------------------------------------------------------------*
FORM formatea_rut012  USING    p_rut
                   CHANGING p_f_rut.

  SPLIT p_rut AT '-' INTO num_c dv.
  numero = num_c.
  CONCATENATE numero dv INTO p_f_rut.

ENDFORM.                    " FORMATEA_RUT
*&---------------------------------------------------------------------*
*&      Form  DATOS_DIRECCION
*&---------------------------------------------------------------------*
FORM datos_direccion012  USING    p_f_adrnr
                      CHANGING p_ti_adrc.

  CALL FUNCTION 'RTP_US_DB_ADRC_READ'
    EXPORTING
      i_address_number = p_f_adrnr
    IMPORTING
      e_adrc           = p_ti_adrc
    EXCEPTIONS
      not_found        = 1
      OTHERS           = 2.
endform.
*&---------------------------------------------------------------------*
*&      Form  Grabar LOG de archivo generado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM grabar_log012.
  zlog_pago_bancos-bukrs = bukrs.
  zlog_pago_bancos-ubnkl = v_banco.
  shift zlog_pago_bancos-ubnkl left deleting leading space.
  zlog_pago_bancos-laufd = v_fecha.
  zlog_pago_bancos-laufi = v_nomina.
  zlog_pago_bancos-fecha_gen = sy-datum.
  zlog_pago_bancos-hora_gen = sy-uzeit.
  zlog_pago_bancos-uname = sy-uname.
  CONCATENATE bukrs v_fecha v_nomina  secuencia INTO zlog_pago_bancos-nombre_arc.
  zlog_pago_bancos-total  = monto_z.
  zlog_pago_bancos-lineas = lineas.
  zlog_pago_bancos-gjahr  =  gjahr.
  zlog_pago_bancos-belnr  =  belnr.
  zlog_pago_bancos-nrotran  =  v_nrotra.
  INSERT zlog_pago_bancos.

ENDFORM.                    "GRABAR_LOG
*&---------------------------------------------------------------------*
*&      Form  contabilizacion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM contabilizacion012.
  DATA: valor(18) TYPE c.

  CLEAR bdcdata.
  REFRESH bdcdata.
* CBD - SE SACA FORMATEO A 'CLP'
* LSC
  valor = monto_z.
  REPLACE '.00' WITH '' INTO valor.
  CONDENSE valor NO-GAPS.
  total = monto_z.
* CBD WRITE  monto_z                 TO total.
* CBD - SE SACA FORMATEO A 'CLP'
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
                                valor. "total. LSC
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
                                valor. "total. LSC
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
*&---------------------------------------------------------------------*
*&      Form  Busca tipo de documento
*&            de acuerdo a conversion para el banco
*&---------------------------------------------------------------------*
FORM Busca_tipdoc012.
 Clear tipdoc.
 SELECT SINGLE codban
         into tipdoc
         FROM  ztd_pagobanco
         WHERE banco  = v_banco
           and codigo = bsik-bukrs.

ENDFORM.                    "busca tipo documento
