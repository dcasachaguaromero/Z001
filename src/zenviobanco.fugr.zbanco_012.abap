*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
*& ** GENERACION DE ARCHIVOS DE BANCO ESTADO (012)
*&---------------------------------------------------------------------*
FUNCTION zbanco_012.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(TIPPRO) TYPE  CHAR01
*"     REFERENCE(CONTAR) TYPE  NUMC06
*"     REFERENCE(SUMPAGOS) TYPE  NUMC15
*"     REFERENCE(V_FECHA) TYPE  DATS
*"     REFERENCE(NVOANT) TYPE  CHAR01
*"  TABLES
*"      TABLA_00 STRUCTURE  REGUH
*"      FILESALIDA
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& ** DEFINICION DE DATOS
*&---------------------------------------------------------------------*

  DATA: v_rut(10)     TYPE c,
       f_rut(10)     TYPE c,
       numero(9)     TYPE n,
       lineas(5)      TYPE n,
       monto_z(15),
       num_c(8)      TYPE c,
       folio_aux(15),
       largo(05)     TYPE n,
       largo1(05)    TYPE n,
       f_adrnr       TYPE adrc-addrnumber,
       v_adrnr       TYPE adrc-addrnumber,
       dv,
       v_mail        TYPE adr6-smtp_addr,
       v_ct(20)      TYPE c,
       v_cta         TYPE zfitr005-zctacte,
       v_vta         TYPE zfitr005-zctavta,
       v_cla         TYPE zfitr005-zclavemis,
       v_doc(15)     TYPE c,
       tipdoc(4)     TYPE c,
       td(1)         TYPE c,
       v_monto(15),
       v_monto_temp(15),
       v_cod        TYPE zfitr005-zcodserv,
       archivo(130) TYPE c,
       archivo_a(130) TYPE c,
       v_flag.

  DATA : BEGIN OF file OCCURS 0,
          linea(400) TYPE c.
  DATA : END OF file.

  DATA: ti_exc LIKE zfitr005 OCCURS 0 WITH HEADER LINE.

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

  DATA: ti_adrc TYPE adrc OCCURS 0 WITH HEADER LINE,
        ti_set_fac LIKE setleaf    OCCURS 0 WITH HEADER LINE,
        ti_set_ncr LIKE setleaf    OCCURS 0 WITH HEADER LINE.

  RANGES: r_fac FOR bkpf-blart,
        r_ncr FOR bkpf-blart.

*&---------------------------------------------------------------------*
*& ** INICIALIZACION DE VARIABLES
*&---------------------------------------------------------------------*
  CLEAR:   r_fac,
           r_ncr,
           ti_set_fac,
           ti_set_ncr.

  REFRESH: r_fac,
           r_ncr,
           ti_set_fac,
           ti_set_ncr.

*&---------------------------------------------------------------------------
*&   PREPARA REGISTRO DE PAGOS
*&---------------------------------------------------------------------------
  REFRESH reg01.

  REFRESH: ti_adrc, file.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT TABLA_00 .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
  READ TABLE tabla_00 INDEX 1.

  SELECT SINGLE adrnr
         FROM t001
         INTO v_adrnr
         WHERE bukrs EQ tabla_00-zbukr.

  f_adrnr = v_adrnr.

  IF f_adrnr IS NOT INITIAL.
    CALL FUNCTION 'RTP_US_DB_ADRC_READ'
      EXPORTING
        i_address_number = f_adrnr
      IMPORTING
        e_adrc           = ti_adrc
      EXCEPTIONS
        not_found        = 1
        OTHERS           = 2.
  ENDIF.

  v_rut = ti_adrc-sort1.

  IF v_rut IS NOT INITIAL.
    SPLIT v_rut AT '-' INTO num_c dv.
    numero = num_c.
    CONCATENATE numero dv INTO f_rut.
  ENDIF.
*&---------------------------------------------------------------------*
*& ** GENERA REGISTRO DE IDENTIFICACION DE PROCESO DE PRUEBA
*&---------------------------------------------------------------------*
  IF tippro <> 'X'.
    file-linea+0(225)      = '*****ARCHIVO DE TEST*****'.
    APPEND file.
    CLEAR  file.
  ENDIF.

  IF nvoant = '2'.
*&---------------------------------------------------------------------*
*& ** RESCATA MOTIVOS DE EMISION
*&----------------------------------------------------------------------
* Rescata motivos de emisión
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE ti_exc
      FROM zfitr005
      WHERE bukrs = tabla_00-zbukr
        AND hbkid = tabla_00-hbkid.

*&---------------------------------------------------------------------------
*&   *** AQUI INICIA PREPARACION DE ARCHIVO EN FOMATO NUEVO   ***************
*&---------------------------------------------------------------------------
    file-linea+0(1)       = '1'.
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

    SELECT SINGLE *
      FROM bsak
      WHERE bukrs EQ tabla_00-zbukr
        AND lifnr EQ tabla_00-lifnr
        AND augbl EQ tabla_00-vblnr
        AND belnr <> tabla_00-vblnr.

    READ TABLE ti_exc WITH KEY bukrs = tabla_00-zbukr
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
*&---------------------------------------------------------------------*
*& ** BLOQUEO Y RECUPERA FOLIO DE SOCIEDAD BANCO
*&----------------------------------------------------------------------
    CALL FUNCTION 'ENQUEUE_EZ_ZFOLIO_PAGBCO'
      EXPORTING
        mode_zfolio_pagobanco = 'E'
        mandt                 = sy-mandt
        bukrs                 = tabla_00-zbukr
        ubnkl                 = tabla_00-ubnkl
        codigo                = '001'.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    SELECT SINGLE *  FROM zfolio_pagobanco  WHERE bukrs  = tabla_00-zbukr
                                              and ubnkl  = tabla_00-ubnkl
                                              AND codigo = '001'.
    IF sy-subrc <> 0.
      zfolio_pagobanco-bukrs = tabla_00-zbukr.
      zfolio_pagobanco-codigo ='001'.
      zfolio_pagobanco-folio = 0.
    ENDIF.

    CLEAR lineas.
*&---------------------------------------------------------------------*
*& ** INICIO CICLO DE LECTURA DE TABLA DE PAGOS DE BANCO
*&----------------------------------------------------------------------
    LOOP AT tabla_00.
      IF tabla_00-zpfor = 'NVO'.
*&---------------------------------------------------------------------*
*& ** AQUI ARMA PAGO SI SE TRATA DE FORMATO NUEVO (CON DETALLE PAGOS)
*&----------------------------------------------------------------------*
        CLEAR: v_rut, f_rut, v_ct.
        v_rut = tabla_00-stcd1.

        IF v_rut IS NOT INITIAL.
          SPLIT v_rut AT '-' INTO num_c dv.
          numero = num_c.
          CONCATENATE numero dv INTO f_rut.
        ENDIF.

        zfolio_pagobanco-folio =  zfolio_pagobanco-folio + 1.

        IF tippro = 'X'.
          MODIFY  zfolio_pagobanco.
        ENDIF.

* Si no está procesado, genera nuevo folio
        IF tabla_00-identif_pago IS INITIAL.
* CBD
          CONCATENATE tabla_00-zbukr tabla_00-ubnkl zfolio_pagobanco-folio+3(8) INTO folio_aux .
        ELSE.
* Si ya existe un folio anterior, deja el folio existente
          CLEAR folio_aux.
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

          CALL FUNCTION 'RTP_US_DB_ADRC_READ'
            EXPORTING
              i_address_number = f_adrnr
            IMPORTING
              e_adrc           = ti_adrc
            EXCEPTIONS
              not_found        = 1
              OTHERS           = 2.
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = tabla_00-ubknt
          IMPORTING
            output = v_ct.

        file-linea+0(1)       = '2'.
        file-linea+1(10)      = f_rut.
        file-linea+11(20)     = folio_aux.

        file-linea+31(30)     = tabla_00-name1.
        IF tabla_00-rzawe = 'V'.
          file-linea+61(3)      = tabla_00-ubnkl.
          file-linea+64(20)     = '                    '.
          file-linea+84(1)      = '3'.
        ELSE.
          file-linea+61(3)      = tabla_00-zbnkl.
          file-linea+64(20)     = tabla_00-zbnkn.
          file-linea+84(1)      = '1'.
        ENDIF.

* SE DEJA EN BLANCO LA CUENTA CTE DEL PROVEEDOR YA QUE ES PAGO CON V.V. antes se había asignado v_ct.

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
* --------------------------------------------------------------------------
* AQUI SE INICIA LOOP PARA RECUPERAR DETALLE DE DOCUMENTOS QUE SE PAGAN ***
* (LOOP DE REGUP)
* --------------------------------------------------------------------------
SELECT * FROM regup WHERE laufd = tabla_00-laufd
AND laufi = tabla_00-laufi
AND xvorl = tabla_00-xvorl
AND lifnr = tabla_00-lifnr
AND zbukr = tabla_00-zbukr
AND kunnr = tabla_00-kunnr
AND empfg = tabla_00-empfg
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES01 ECDK917080 *
*AND vblnr = tabla_00-vblnr.
AND VBLNR = TABLA_00-VBLNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES01 ECDK917080 *

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

          file-linea+0(1)     = '3'.
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

          CLEAR regup-sgtxt.
          SELECT SINGLE bktxt
            INTO regup-sgtxt
            FROM bkpf
            WHERE bukrs = regup-bukrs
              AND belnr = regup-belnr
              AND gjahr = regup-gjahr.
          file-linea+33(20)   = regup-sgtxt.
*    Resta montos correspondientes a descuentos.
*      if v_monto_temp > 0.
*        call function 'CONVERSION_EXIT_ALPHA_INPUT'
*          exporting
*            input  = v_monto_temp
*          importing
*            output = v_monto_temp.
*
*        v_monto = v_monto - v_monto_temp.
*        clear v_monto_temp.
*
*        call function 'CONVERSION_EXIT_ALPHA_INPUT'
*          exporting
*            input  = v_monto
*          importing
*            output = v_monto.
*      endif.

          file-linea+53(15)   = v_monto.

*     Valida Motivo de Emisión
          SELECT SINGLE *
          FROM bsak
             WHERE bukrs EQ tabla_00-zbukr
               AND lifnr EQ tabla_00-lifnr
               AND augbl EQ tabla_00-vblnr
               AND belnr <> tabla_00-vblnr.

          file-linea+68(20)   = folio_aux.
          file-linea+88(10)   = bsak-zzmot_emis.

          APPEND file.
          CLEAR  file.
*&---------------------------------------------------------------------*
*& ** SI PROCESO REAL ACTUALIZA REGISTROS DE CABECERA CONTABLE
*&----------------------------------------------------------------------*
          IF tippro = 'X'.
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

        ENDSELECT. " de revision de REGUP.
      ENDIF.
    ENDLOOP.                                                " tabla_00

    CALL FUNCTION 'DEQUEUE_EZ_ZFOLIO_PAGBCO'
      EXPORTING
        mode_zfolio_pagobanco = 'E'
        mandt                 = sy-mandt
        bukrs                 = tabla_00-zbukr
        ubnkl                 = tabla_00-ubnkl
        codigo                = '001'.

    filesalida[] = file[].
*&---------------------------------------------------------------------*
*& ** AQUI ARMA PAGO SI SE TRATA DE FORMATO ANTIGUO (SIN DETALLE PAGOS)
*&----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*& ** AQUI ARMA PAGO SI SE TRATA DE FORMATO ANTIGUO (SIN DETALLE PAGOS)
*&----------------------------------------------------------------------*
  ELSE.
*&---------------------------------------------------------------------*
*& ** RECUPERA Y BLOQUEA FOLIO DE SOCIEDAD BANCO
*&---------------------------------------------------------------------*
    CALL FUNCTION 'ENQUEUE_EZ_ZFOLIO_PAGBCO'
      EXPORTING
        mode_zfolio_pagobanco = 'E'
        mandt                 = sy-mandt
        bukrs                 = tabla_00-zbukr
        ubnkl                 = tabla_00-ubnkl
        codigo                = '001'.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    SELECT SINGLE * FROM zfolio_pagobanco WHERE bukrs  = tabla_00-zbukr
                                            AND ubnkl  = tabla_00-ubnkl
                                            AND codigo ='001'.
    IF sy-subrc <> 0.
      zfolio_pagobanco-bukrs = tabla_00-zbukr.
      zfolio_pagobanco-codigo ='001'.
      zfolio_pagobanco-folio = 0.
    ENDIF.

    lineas = 0.
*&---------------------------------------------------------------------*
*& ** EL CICLO DE RECUPERACION DE PAGOS PARA GENERAR REGISTRO
*&----------------------------------------------------------------------*
    LOOP AT tabla_00.
      IF tabla_00-zpfor = 'ANT'.
        IF lineas = 9000.
*&       CONCATENATE archivo tabla_00-zbukr v_fecha v_nomina  secuencia INTO archivo_a.

          CLEAR: lineas, monto_z.
        ENDIF.
        zfolio_pagobanco-folio =  zfolio_pagobanco-folio + 1.
        IF tippro = 'X'.
          MODIFY  zfolio_pagobanco.
        ENDIF.

        IF tabla_00-identif_pago IS INITIAL.
          CONCATENATE tabla_00-zbukr tabla_00-ubnkl zfolio_pagobanco-folio+3(8) INTO folio_aux .
        ELSE.
          CLEAR folio_aux.
          MOVE tabla_00-identif_pago TO folio_aux.
        ENDIF.

        TRANSLATE tabla_00-zstc1 USING '- ' .
        CONDENSE  tabla_00-zstc1 NO-GAPS    .
        largo = STRLEN( tabla_00-zstc1 ) - 1.
        reg01-rut_prv         =  tabla_00-zstc1+0(largo).
        reg01-rut_dvr         =  tabla_00-zstc1+largo(1).

        reg01-identificador   =  folio_aux.
        reg01-nombre          =  tabla_00-name1.
        reg01-tipo_proceso    = '1'.
        reg01-cod_banco       = '012'.
        reg01-cuenta_abo      =''.
        reg01-destino         = '3'.
        reg01-monto_pago = tabla_00-rbetr * -100.
        APPEND reg01.

        IF tippro = 'X'.
          UPDATE reguh
          SET    identif_pago  = folio_aux
                 fecha_envio   = sy-datum
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
        monto_z  =   monto_z + ( tabla_00-rbetr * -100 ).
      ENDIF.
    ENDLOOP.
*&---------------------------------------------------------------------*
*& ** DESBLOQUEA FOLIO DE SOCIEDAD BANCO CON FOLIO ACTUALIZADO
*&----------------------------------------------------------------------*
    CALL FUNCTION 'DEQUEUE_EZ_ZFOLIO_PAGBCO'
      EXPORTING
        mode_zfolio_pagobanco = 'E'
        mandt                 = sy-mandt
        bukrs                 = tabla_00-zbukr
        ubnkl                 = tabla_00-ubnkl
        codigo                = '001'.
*&---------------------------------------------------------------------*
*& ** PASA ARCHIVO GENERADO A PARAMETRO DE LA FUNCION
*&----------------------------------------------------------------------*
    filesalida[] = reg01[].

  ENDIF.


ENDFUNCTION.
