*----------------------------------------------------------------------*
***INCLUDE ZFITR010_504.
*&---------------------------------------------------------------------*
*&      Form  NVO_FORMATO_504
*&---------------------------------------------------------------------*
  FORM nvo_formato_504.

  DATA: ti_adrc TYPE adrc OCCURS 0 WITH HEADER LINE.


  REFRESH: ti_adrc, file.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE adrnr
*         FROM t001
*         INTO v_adrnr
*         WHERE bukrs EQ bukrs.
*
* NEW CODE
  SELECT adrnr
  UP TO 1 ROWS 
         FROM t001
         INTO v_adrnr
         WHERE bukrs EQ bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  f_adrnr = v_adrnr.

  IF f_adrnr IS NOT INITIAL.
    PERFORM datos_direccion504 USING    f_adrnr
                            CHANGING ti_adrc.
  ENDIF.

  READ TABLE tabla_00 INDEX 1.

  v_rut = ti_adrc-sort1.

  IF v_rut IS NOT INITIAL.
    PERFORM formatea_rut504 USING  v_rut
                         CHANGING f_rut.
  ENDIF.

  IF par_di <> 'X'.
    file-linea+0(225)      = '*****ARCHIVO DE TEST*****'.
    APPEND file.
    CLEAR  file.
  ENDIF.

  file-linea+0(1)       = header_soc.
  file-linea+1(10)      = f_rut.

  CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
    EXPORTING
      intext  = ti_adrc-name1
    IMPORTING
      outtext = ti_adrc-name1.

  IF ti_adrc-name1 CA ','.
    REPLACE ',' WITH ' ' INTO ti_adrc-name1.
    CONDENSE  ti_adrc-name1.
  ENDIF.

  file-linea+11(30)     = ti_adrc-name1.
  file-linea+41(8)      = num_c.
  file-linea+49(1)      = dv.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *
*    FROM bsak
*    WHERE bukrs EQ bukrs
*      AND lifnr EQ tabla_00-lifnr
*      AND augbl EQ tabla_00-vblnr
*      AND belnr <> tabla_00-vblnr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
    FROM bsak
    WHERE bukrs EQ bukrs
      AND lifnr EQ tabla_00-lifnr
      AND augbl EQ tabla_00-vblnr
      AND belnr <> tabla_00-vblnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  READ TABLE ti_exc WITH KEY bukrs = bukrs
                             hbkid = tabla_00-hbkid
                             zmotiv = bsak-zzmot_emis.

  MOVE: ti_exc-zcodserv  TO v_cod,
        ti_exc-zflag     TO v_flag,
        ti_exc-zctacte   TO v_cta,
        ti_exc-zctavta   TO v_vta,
        ti_exc-zclavemis TO v_cla.

  file-linea+50(3)      = v_cod.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = v_cta
    IMPORTING
      output = v_cta.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = v_vta
    IMPORTING
      output = v_vta.

  file-linea+53(18)     = v_cta.
  file-linea+71(18)     = v_vta.
  file-linea+89(8)      = v_fecha.
  file-linea+97(12)     = '            '.
  file-linea+109(8)     = sy-datum.
  file-linea+117(15)    = v_cla.

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

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *  FROM zfolio_pagobanco  WHERE bukrs  = bukrs
*                                            AND codigo = '001'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS   FROM zfolio_pagobanco  WHERE bukrs  = bukrs
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
    if tabla_00-zpfor = 'NVO'.
*   Header Proveedor
      CLEAR: v_rut, f_rut, v_ct.
      v_rut = tabla_00-stcd1.
      IF v_rut IS NOT INITIAL.

        PERFORM formatea_rut504 USING    v_rut
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

      file-linea+0(1)       = header_prov.
      file-linea+1(10)      = f_rut.
      file-linea+11(20)     = folio_aux.

      CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
           EXPORTING
              intext  = tabla_00-name1
           IMPORTING
              outtext = tabla_00-name1.

      CLEAR:  f_adrnr, v_adrnr, ti_adrc, v_mail.
      REFRESH ti_adrc.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE adrnd
*             INTO v_adrnr
*             FROM knvk
*             WHERE lifnr EQ tabla_00-lifnr.
*
* NEW CODE
      SELECT adrnd
      UP TO 1 ROWS 
             INTO v_adrnr
             FROM knvk
             WHERE lifnr EQ tabla_00-lifnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE smtp_addr
*             INTO v_mail
*             FROM adr6
*             WHERE addrnumber EQ tabla_00-adrnr.
*
* NEW CODE
      SELECT smtp_addr
      UP TO 1 ROWS 
             INTO v_mail
             FROM adr6
             WHERE addrnumber EQ tabla_00-adrnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      f_adrnr = v_adrnr.

      IF f_adrnr IS NOT INITIAL.
        PERFORM datos_direccion504 USING    f_adrnr
                              CHANGING ti_adrc.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
           EXPORTING
              input  = tabla_00-ubknt
           IMPORTING
              output = v_ct.

      file-linea+31(30)     = tabla_00-name1.
      file-linea+61(3)      = tabla_00-ubnkl.
* SE DEJA EN BLANCO LA CUENTA CTE DEL PROVEEDOR YA QUE ES PAGO CON V.V. antes se había asignado v_ct.
      file-linea+64(20)     = '                    '.
      file-linea+84(1)      = '3'.
      file-linea+85(1)      = '1'.
      file-linea+86(30)     = tabla_00-stras.
      file-linea+116(15)    = tabla_00-ort01.
      file-linea+131(15)    = tabla_00-ztelf.

      CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
           EXPORTING
              intext  = ti_adrc-name1
           IMPORTING
              outtext = ti_adrc-name1.

      file-linea+146(20)    = ti_adrc-name1.
      file-linea+166(4)     = '0000'.
      file-linea+170(30)    = v_mail.
      file-linea+200(30)    = ti_adrc-name1.
      file-linea+230(30)    = ti_adrc-street.
      file-linea+260(15)    = ti_adrc-city1.
      file-linea+275(2)     = ti_adrc-tel_extens.
      file-linea+277(8)     = ti_adrc-tel_number.
      file-linea+285(8)     = '        '.

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
*        select single *
*          from  bsik
*          where lifnr  = regup-lifnr
*            and bukrs  = regup-bukrs
*            and gjahr  = regup-gjahr
*            and belnr  = regup-belnr
*            and buzei  = regup-buzei.
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

        IF bsik-blart    IN r_fac.
          td = '1'.
        ELSEIF bsik-blart IN r_ncr.
          td = '2'.
          v_monto+0(1) = '-'.
        ELSE.
          td = '3'.
        ENDIF.

        file-linea+0(1)     = posiciones.
        file-linea+1(1)     = td.
        file-linea+2(8)     = bsik-bldat.
        file-linea+10(8)    = bsik-zfbdt.

* CBD SE CAMBIA V_DOC POR EL COMPROBANTE POR LA ASIGNACION (XBLNR).

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
             EXPORTING
               input  = bsik-xblnr
             IMPORTING
               output = v_doc.

        file-linea+18(15)   = v_doc.

        file-linea+33(20)   = bsik-sgtxt.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = v_monto
            IMPORTING
              output = v_monto.

        file-linea+53(15)   = v_monto.

*     Valida Motivo de Emisión
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE *
*        FROM bsak
*           WHERE bukrs EQ bukrs
*             AND lifnr EQ tabla_00-lifnr
*             AND augbl EQ tabla_00-vblnr
*             AND belnr <> tabla_00-vblnr.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS 
        FROM bsak
           WHERE bukrs EQ bukrs
             AND lifnr EQ tabla_00-lifnr
             AND augbl EQ tabla_00-vblnr
             AND belnr <> tabla_00-vblnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        file-linea+68(20)   = folio_aux.
        file-linea+88(10)   = bsak-zzmot_emis.

        APPEND file.
        CLEAR  file.

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
* CBD - MONTO ERRONEO SE CAMBIA UTILIZANDO t_items-lc_amount en vez de tabla_oo-rbetr
*        monto_z  =   monto_z + ( tabla_00-rbetr * -1 ).

*        monto_z  =   monto_z + t_items-lc_amount.
        monto_z  =   monto_z + v_monto.

* CBD - MONTO ERRONEO SE CAMBIA UTILIZANDO t_items-lc_amount en vez de tabla_oo-rbetr
      ENDSELECT. " de revision de REGUP.
    endif.
  ENDLOOP.      " tabla_00

 CALL FUNCTION 'DEQUEUE_EZ_ZFOLIO_PAGBCO'
    EXPORTING
      mode_zfolio_pagobanco = 'E'
      mandt            = sy-mandt
      bukrs            = bukrs
      ubnkl            = v_banco
      codigo           = '001'.

  If lineas > 0.
     PERFORM baja_archivo504.
  Endif.
ENDFORM.                    " NVO_FORMATO
*&---------------------------------------------------------------------*
*&      Form  BAJA_ARCHIVO
*&---------------------------------------------------------------------*
FORM baja_archivo504 .

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
        PERFORM  contabilizacion504.
      ENDIF.
      PERFORM  grabar_log504.
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
FORM formatea_rut504  USING    p_rut
                   CHANGING p_f_rut.

  SPLIT p_rut AT '-' INTO num_c dv.
  numero = num_c.
  CONCATENATE numero dv INTO p_f_rut.

ENDFORM.                    " FORMATEA_RUT
*&---------------------------------------------------------------------*
*&      Form  DATOS_DIRECCION
*&---------------------------------------------------------------------*
FORM datos_direccion504  USING    p_f_adrnr
                      CHANGING p_ti_adrc.

  CALL FUNCTION 'RTP_US_DB_ADRC_READ'
    EXPORTING
      i_address_number = p_f_adrnr
    IMPORTING
      e_adrc           = p_ti_adrc
    EXCEPTIONS
      not_found        = 1
      OTHERS           = 2.

ENDFORM.                    " DATOS_DIRECCION
FORM ant_formato_504.
*&---------------------------------------------------------------------*
*&      Form  ANT_FORMATO_504
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  data : folio_aux(15).
  data : largo(05) type n.
  data : largo1(05) type n.
  refresh reg01.

  call function 'ENQUEUE_EZ_ZFOLIO_PAGBCO'
      exporting
       mode_zfolio_pagobanco = 'E'
       mandt                  = sy-mandt
       bukrs                  = bukrs
       ubnkl                  = v_banco
       codigo                 = '001'.
          .
  if sy-subrc <> 0.
     message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single * from zfolio_pagobanco where bukrs  = bukrs
*                                          and ubnkl  = v_banco
*                                          and codigo ='001'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  from zfolio_pagobanco where bukrs  = bukrs
                                          and ubnkl  = v_banco
                                          and codigo ='001' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  if sy-subrc <> 0.
    zfolio_pagobanco-bukrs = bukrs.
    zfolio_pagobanco-codigo ='001'.
    zfolio_pagobanco-folio = 0.
  endif.

  lineas = 0.
  secuencia = 1.

  loop at tabla_00.
    if tabla_00-zpfor = 'ANT'.
       if lineas = 9000.
         concatenate archivo bukrs v_fecha v_nomina  secuencia into archivo_a.

          clear: lineas, monto_z.
       endif.

       zfolio_pagobanco-folio =  zfolio_pagobanco-folio + 1.
       if par_di = 'X'.
         modify  zfolio_pagobanco.
       endif.

       if tabla_00-identif_pago is initial.
         concatenate bukrs zfolio_pagobanco-folio into folio_aux .
       else.
         clear folio_aux.
         move tabla_00-identif_pago to folio_aux.
       endif.

       translate tabla_00-zstc1 using '- ' .
       condense  tabla_00-zstc1 no-gaps    .
       largo = strlen( tabla_00-zstc1 ) - 1.
       reg01-rut_prv         =  tabla_00-zstc1+0(largo).
       reg01-rut_dvr         =  tabla_00-zstc1+largo(1).

       reg01-identificador   =  folio_aux.
       reg01-nombre          =  tabla_00-name1.
       reg01-tipo_proceso    = '1'.
       reg01-cod_banco       = '504'.
       reg01-cuenta_abo      =''.
       reg01-destino         = '3'.
       reg01-monto_pago = tabla_00-rbetr * -100.
       append reg01.

       if par_di = 'X'.
         update reguh
         set    identif_pago  = folio_aux
                fecha_envio   = sy-datum
                usuario_envio = sy-uname
         where  laufd =  tabla_00-laufd
           and laufi = tabla_00-laufi
           and xvorl = tabla_00-xvorl
           and zbukr = tabla_00-zbukr
           and lifnr = tabla_00-lifnr
           and kunnr = tabla_00-kunnr
           and empfg = tabla_00-empfg
           and vblnr = tabla_00-vblnr.
       endif.

       lineas = lineas + 1.
* CBD - SE MULTIPLICA POR 100 PARA IGUAL CON CAMBIO EN NVO_FORMATO
* CBD    monto_z  =   monto_z + ( tabla_00-rbetr * -1 ).
    monto_z  =   monto_z + ( tabla_00-rbetr * -100 ).
* CBD - SE MULTIPLICA POR 100 PARA IGUAL CON CAMBIO EN NVO_FORMATO
      endif.
    endloop.

 call function 'DEQUEUE_EZ_ZFOLIO_PAGBCO'
 exporting
   mode_zfolio_pagobanco  = 'E'
   mandt                  = sy-mandt
   bukrs                  = bukrs
   ubnkl                  = v_banco
   codigo                 = '001'.

  if lineas > 0.
    if par_di = 'X'.
      concatenate archivo bukrs v_fecha v_banco v_nomina  secuencia into archivo_a.
    else.
      concatenate archivo 'TEST_' bukrs v_fecha v_banco v_nomina  secuencia into archivo_a.
    endif.
    perform bajar_archivo504.
  endif.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  bajar_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form bajar_archivo504.
*--------------------*
  data : nombre_a  type string.

  concatenate archivo_a '_ant.txt'
    into archivo_a.

  nombre_a = archivo_a.

  sy-subrc = 0.

  if par_di = 'X'.
    call function 'GUI_DOWNLOAD'
      exporting
        filename                = nombre_a
        filetype                = 'ASC'
        confirm_overwrite       = 'X'
      tables
        data_tab                = reg01
      exceptions
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
        others                  = 22.

  endif.

  if sy-subrc <> 0.
    write :/ 'error!!!!'  ,
           /  sy-msgv1 ,
           /  sy-msgv2 ,
           /  sy-msgv3 ,
           /  sy-msgv4 .

  else.
    skip 2 .
    format color 3 on.

    if par_di = 'X'.
      write : / 'Se genero archivo :', archivo_a.
      if contabilizar <> 'N'.
        perform  contabilizacion504.
      endif.
      perform  grabar_log504.
    else.
      write : / 'Se generara el siguiente archivo :', archivo_a.
    endif.
* CBD - SE CAMBIA PARA IGUALAR CON NVO_FORMATO
* CBD    WRITE : /10 'total registros : ', lineas,
* CBD                'total monto  : ',  monto_z CURRENCY 'CLP'.
    write : /10 'total registros : ', lineas,
                'total monto  : ',  monto_z.
* CBD - SE CAMBIA PARA IGUALAR CON NVO_FORMATO
    format color 3 off.
    clear: lineas, monto_z.
  endif.

  secuencia = secuencia + 1.
  refresh reg01.

*----------------------------------------------
endform.                    "bajar_archivo
*&---------------------------------------------------------------------*
*&      Form  Grabar LOG de archivo generado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM grabar_log504.
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
FORM contabilizacion504.
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
