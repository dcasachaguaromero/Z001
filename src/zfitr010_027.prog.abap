*&---------------------------------------------------------------------*
*& ** RUTINAS PARA GENERACION DE ARCHIVOS DE PAGOS A BANCOS:
*&         027    Banco Corpbanca
*&---------------------------------------------------------------------*
*
*
  FORM nvo_formato_027.

  IF par_di <> 'X'.
    file-linea+0(225)      = '*****ARCHIVO DE TEST*****'.
    APPEND file.
    CLEAR  file.
  ENDIF.


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

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *  FROM zfolio_pagobanco  WHERE bukrs  = bukrs
*                                            AND UBNKL  = REGUH-UBNKL
*                                            AND codigo = '001'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS   FROM zfolio_pagobanco  WHERE bukrs  = bukrs
                                            AND UBNKL  = REGUH-UBNKL
                                            AND codigo = '001' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc <> 0.
    zfolio_pagobanco-bukrs = bukrs.
    zfolio_pagobanco-codigo ='001'.
    zfolio_pagobanco-folio = 0.
  ENDIF.

  CLEAR lineas.

  LOOP AT tabla_00.

*   Datos de pagos por cada pago

      v_rut = tabla_00-stcd1.

      IF v_rut IS NOT INITIAL.

        PERFORM formatea_rut027  USING v_rut
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

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
              input  = tabla_00-ubknt
           IMPORTING
              output = v_ct.

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
      monto_z = monto_z + ( tabla_00-rbetr * -100 ).
      APPEND file.
      CLEAR  file.

* --------------------------------------------------------------------------
* AQUI DEBE ESTAR EL LOOP DE REGUP
* --------------------------------------------------------------------------
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM  regup   WHERE   laufd = tabla_00-laufd
*                               AND   laufi = tabla_00-laufi
*                               AND   xvorl = tabla_00-xvorl
*                               AND   lifnr = tabla_00-lifnr
*                               AND   zbukr = tabla_00-zbukr.
*
* NEW CODE
      SELECT *
 FROM  regup   WHERE   laufd = tabla_00-laufd
                               AND   laufi = tabla_00-laufi
                               AND   xvorl = tabla_00-xvorl
                               AND   lifnr = tabla_00-lifnr
                               AND   zbukr = tabla_00-zbukr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

         v_monto = regup-dmbtr.

         REPLACE '.0000' WITH '' INTO v_monto.
         CONDENSE v_monto NO-GAPS.

         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                 input  = v_monto
              IMPORTING
                 output = v_monto.

         clear bsik.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*         select single *
*            from  bsik
*           where lifnr  = regup-lifnr
*             and bukrs  = regup-bukrs
*             and gjahr  = regup-gjahr
*             and belnr  = regup-belnr
*             and buzei  = regup-buzei.
*
* NEW CODE
         SELECT *
         UP TO 1 ROWS 
            from  bsik
           where lifnr  = regup-lifnr
             and bukrs  = regup-bukrs
             and gjahr  = regup-gjahr
             and belnr  = regup-belnr
             and buzei  = regup-buzei ORDER BY PRIMARY KEY.

         ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

         perform busca_tipdoc027.
         file-linea+0(04)     = tipdoc.
         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
             EXPORTING
               input  = bsik-xblnr
             IMPORTING
               output = v_doc.
           file-linea+04(20)    = v_doc.
           file-linea+24(11)    = tabla_00-stcd1.
           file-linea+35(15)    = v_monto.

           concatenate bsik-bldat+06(2) '/' bsik-bldat+04(2) '/' bsik-bldat+0(4) into file-linea+50(10).
           concatenate v_fecha+06(2) '/' v_fecha+04(2) '/' v_fecha+0(4) into file-linea+60(10).

           file-linea+70(04)     = '0000'.
           file-linea+74(20)     = '00000000000000000000'.

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
     PERFORM baja_archivo027.
  Endif.
ENDFORM.                    " NVO_FORMATO
*&---------------------------------------------------------------------*
*&      Form  BAJA_ARCHIVO
*&---------------------------------------------------------------------*
FORM baja_archivo027.

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
        PERFORM  contabilizacion027.
      ENDIF.
      PERFORM  grabar_log027.
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
FORM formatea_rut027  USING    p_rut
                   CHANGING p_f_rut.

  SPLIT p_rut AT '-' INTO num_c dv.
  numero = num_c.
  CONCATENATE numero dv INTO p_f_rut.

ENDFORM.                    " FORMATEA_RUT

*&---------------------------------------------------------------------*
*&      Form  Grabar LOG de archivo generado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM grabar_log027.
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
FORM contabilizacion027.
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
FORM Busca_tipdoc027.
 Clear tipdoc.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
* SELECT SINGLE codban
*         into tipdoc
*         FROM  ztd_pagobanco
*         WHERE banco  = v_banco
*           and codigo = bsik-bukrs.
*
* NEW CODE
 SELECT codban
 UP TO 1 ROWS 
         into tipdoc
         FROM  ztd_pagobanco
         WHERE banco  = v_banco
           and codigo = bsik-bukrs ORDER BY PRIMARY KEY.

 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

ENDFORM.                    "busca tipo documento
