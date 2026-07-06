*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFITR010_NVO_FORMATO .
*&---------------------------------------------------------------------*
*&      Form  NVO_FORMATO
*&---------------------------------------------------------------------*
FORM nvo_formato.

  DATA: ti_adrc TYPE adrc OCCURS 0 WITH HEADER LINE.

  DATA: v_adrnr   TYPE adrc-addrnumber,
        f_adrnr   TYPE adrc-addrnumber,
        v_rut(10) TYPE c,
        f_rut(10) TYPE c,
        v_cod     TYPE zfitr005-zcodserv,
        v_flag,
        v_cta     TYPE zfitr005-zctacte,
        v_vta     TYPE zfitr005-zctavta,
        v_ct(20)  TYPE c,
        v_ctcta(20)  TYPE c,
        v_cla     TYPE zfitr005-zclavemis,
        folio_aux(15),
        rut       TYPE adrc-sort1,
        v_mail    TYPE adr6-smtp_addr,
        td,
        v_monto(15),
        v_monto_temp(15),
        xblnr_w     TYPE regup-xblnr,
        motivo_w    TYPE bsak-zzmot_emis,
        v_doc(15) TYPE c.

* Crea Header Sociedad
  CLEAR:   ti_adrc, file, v_adrnr, numero, num_c, rut, f_rut, v_rut, dv, v_cod, v_flag, v_cta, v_vta, v_cla, td, lineas, monto_z.
  REFRESH: ti_adrc, file.

  SELECT SINGLE adrnr  FROM t001  INTO v_adrnr
                       WHERE bukrs EQ bukrs.
  f_adrnr = v_adrnr.
  IF f_adrnr IS NOT INITIAL.
    PERFORM datos_direccion USING    f_adrnr
                            CHANGING ti_adrc.
  ENDIF.
  rut = ti_adrc-sort1.

  IF rut IS NOT INITIAL.
    PERFORM formatea_rut USING    rut
                         CHANGING f_rut.
  ENDIF.

  IF par_di <> 'X'.
    file-linea+0(225)      = '*****ARCHIVO DE TEST*****'.
    APPEND file.
    CLEAR  file.
  ENDIF.

*Puebla y Graba Registroo Cabecera (1)

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

  READ TABLE tabla_00 INDEX 1.
  SELECT SINGLE *  FROM bsak
                   WHERE bukrs EQ bukrs
                   AND   lifnr EQ tabla_00-lifnr
                   AND   augbl EQ tabla_00-vblnr
                   AND   belnr <> tabla_00-vblnr.
  READ TABLE ti_exc WITH KEY bukrs = bukrs
                             hbkid = tabla_00-hbkid
                             zmotiv = bsak-zzmot_emis.

  motivo_w  = bsak-zzmot_emis.

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
  if  v_fpago is initial.
     file-linea+89(8)      =  v_fecha.
  else.
      file-linea+89(8)      = v_fpago." HCASTILLO 15052024 v_fecha.
  endif.

  file-linea+97(12)     = '            '.
  file-linea+109(8)     = sy-datum.
  file-linea+117(15)    = v_cla.
  APPEND file.
  CLEAR  file.


* Puebla y Graba identificacion Proveedor (2)

  CALL FUNCTION 'ENQUEUE_EZFOLIO'
    EXPORTING
      mode_zfolio_bbva = 'E'
      mandt            = sy-mandt
      bukrs            = bukrs
      codigo           = '001'.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SELECT SINGLE *  FROM zfolio_bbva  WHERE bukrs  = bukrs
                                     AND codigo = '001'.
  IF sy-subrc <> 0.
    zfolio_bbva-bukrs = bukrs.
    zfolio_bbva-codigo ='001'.
    zfolio_bbva-folio = 0.
  ENDIF.

  CLEAR lineas.

  LOOP AT tabla_00.
*   Header Proveedor
    CLEAR: rut, f_rut, v_ct.
    rut = tabla_00-stcd1.
    IF rut IS NOT INITIAL.
      PERFORM formatea_rut USING  rut CHANGING f_rut.
    ENDIF.

    zfolio_bbva-folio =  zfolio_bbva-folio + 1.
    IF par_di = 'X'.
      MODIFY  zfolio_bbva.
    ENDIF.
* Si no está procesado, genera nuevo folio
    IF tabla_00-identif_pago IS INITIAL.
      CONCATENATE bukrs zfolio_bbva-folio INTO folio_aux .
    ELSE.
      MOVE tabla_00-identif_pago TO folio_aux.
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

    SELECT SINGLE adrnd  INTO v_adrnr  FROM knvk
       WHERE lifnr EQ tabla_00-lifnr.

    SELECT SINGLE smtp_addr  INTO v_mail  FROM adr6
       WHERE addrnumber EQ tabla_00-adrnr.

    f_adrnr = v_adrnr.

    IF f_adrnr IS NOT INITIAL.
      PERFORM datos_direccion USING    f_adrnr
                              CHANGING ti_adrc.
    ENDIF.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = tabla_00-ubknt
      IMPORTING
        output = v_ct.

" Manejo de formato de cuenta corriente 12-06-2024 INICIO
      IF tabla_00-rzawe = 'T' and (  bukrs = 'CL01' or  bukrs ='CL24').
          v_ctcta = tabla_00-zbnkn.
      elseif tabla_00-rzawe = 'T'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = tabla_00-zbnkn
                IMPORTING
                  output = v_ctcta.
      endif.
" Manejo de formato de cuenta corriente 12-06-2024 FIN

    file-linea+31(30)     = tabla_00-name1.
    IF tabla_00-rzawe = 'V'.
      file-linea+61(3)      = tabla_00-ubnkl.
      file-linea+64(20)      = '                    '.
      file-linea+84(1)      = '3'.
    ELSE.
      REPLACE ALL OCCURRENCES OF '-' IN tabla_00-zbnkl WITH ''. "Elimino guiones de las cuentas 12062024
      file-linea+61(3)     = tabla_00-zbnkl.
      file-linea+64(20)     = v_ctcta.  "tabla_00-zbnkn.
      file-linea+84(1)      = '1'.
    ENDIF.
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
    CLEAR v_monto_temp.

SELECT * FROM regup WHERE laufd = tabla_00-laufd
AND laufi = tabla_00-laufi
AND xvorl = tabla_00-xvorl
AND zbukr = tabla_00-zbukr
AND lifnr = tabla_00-lifnr
AND kunnr = tabla_00-kunnr
AND empfg = tabla_00-empfg
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND vblnr = tabla_00-vblnr.
AND VBLNR = TABLA_00-VBLNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *



      v_monto = regup-dmbtr * 100.

      REPLACE '.0000' WITH '' INTO v_monto.
      CONDENSE v_monto NO-GAPS.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = v_monto
        IMPORTING
          output = v_monto.

      IF regup-shkzg = 'S'.
        v_monto+0(1) = '-'.
      ENDIF.

      IF regup-blart     IN r_fac.
        td = '1'.
      ELSEIF regup-blart IN r_ncr.
        td = '2'.
        v_monto+0(1) = '-'.
      ELSE.
        td = '3'.
      ENDIF.

      file-linea+0(1)     = posiciones.
      file-linea+1(1)     = td.
      file-linea+2(8)     = regup-bldat.
      file-linea+10(8)    = regup-zfbdt.

      xblnr_w = regup-xblnr.

      If motivo_w = 'PAGOPRES' or motivo_w ='PAGOPRES_C'.
         If regup-blart = 'SA' or  regup-blart = 'XG'.
            xblnr_w = regup-zuonr.
         endif.
      endif.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
*          input  = regup-xblnr
           input  = xblnr_w
        IMPORTING
          output = v_doc.
      file-linea+18(15)   = v_doc.



* CBD SE CAMBIA V_DOC POR EL COMPROBANTE POR LA ASIGNACION (XBLNR).

      CLEAR regup-sgtxt.
      SELECT SINGLE bktxt
        INTO regup-sgtxt
        FROM bkpf
        WHERE bukrs = regup-bukrs
          AND belnr = regup-belnr
          AND gjahr = regup-gjahr.
      file-linea+33(20)   = regup-sgtxt.

*    Resta montos correspondientes a descuentos.
      IF v_monto_temp > 0.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = v_monto_temp
          IMPORTING
            output = v_monto_temp.

        v_monto = v_monto - v_monto_temp.
        CLEAR v_monto_temp.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = v_monto
          IMPORTING
            output = v_monto.
      ENDIF.

      file-linea+53(15)   = v_monto.


      SELECT SINGLE * FROM bsak
                      WHERE bukrs EQ bukrs
                      AND lifnr EQ tabla_00-lifnr
                      AND augbl EQ tabla_00-vblnr
                      AND belnr <> tabla_00-vblnr.
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
      monto_z  =   monto_z + v_monto.
    ENDSELECT.

  ENDLOOP.

  CALL FUNCTION 'DEQUEUE_EZFOLIO'
    EXPORTING
      mode_zfolio_bbva = 'E'
      mandt            = sy-mandt
      bukrs            = bukrs
      codigo           = '001'.

  PERFORM baja_archivo.
ENDFORM.                    " NVO_FORMATO
*&---------------------------------------------------------------------*
*&      Form  BAJA_ARCHIVO
*&---------------------------------------------------------------------*
FORM baja_archivo .

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
      CONCATENATE archivo bukrs v_fecha v_nomina '_cc' '.txt'
             INTO archivo_a.
    ELSE.
      CONCATENATE archivo bukrs v_fecha v_nomina '.txt'
             INTO archivo_a.
    ENDIF.
  ELSE.
    IF sw IS NOT INITIAL.
      CONCATENATE archivo 'TEST_' bukrs v_fecha v_nomina '_cc' '.txt'
             INTO archivo_a.
    ELSE.
      CONCATENATE archivo 'TEST_' bukrs v_fecha v_nomina '.txt'
             INTO archivo_a.
    ENDIF.
  ENDIF.

  nombre_a = archivo_a.

*  IF par_di = 'X'.
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
*  ENDIF.

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
FORM formatea_rut  USING    p_rut
                   CHANGING p_f_rut.

  SPLIT p_rut AT '-' INTO num_c dv.
  numero = num_c.
  CONCATENATE numero dv INTO p_f_rut.

ENDFORM.                    " FORMATEA_RUT
*&---------------------------------------------------------------------*
*&      Form  DATOS_DIRECCION
*&---------------------------------------------------------------------*
FORM datos_direccion  USING    p_f_adrnr
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
