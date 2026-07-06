**&---------------------------------------------------------------------*
*& ** GENERACION DE ARCHIVOS DE BANCO CHILE (001) JULIO 2020
*&---------------------------------------------------------------------*
FUNCTION zbanco_001_nvo.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(TIPPRO) TYPE  CHAR01
*"     REFERENCE(CONTAR) TYPE  NUMC06
*"     REFERENCE(SUMPAGOS) TYPE  NUMC15
*"     REFERENCE(V_FECHA) TYPE  DATS
*"     REFERENCE(NVOANT) TYPE  CHAR01
*"     REFERENCE(CONTARDOC) TYPE  NUMC06
*"     REFERENCE(ZZMOT_EMIS) TYPE  ZZMOT_EMIS OPTIONAL
*"     REFERENCE(NROTRA) TYPE  NUMC10 OPTIONAL
*"  TABLES
*"      TABLA_00 STRUCTURE  REGUH
*"      FILESALIDA
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& ** DEFINICION DE DATOS
*&---------------------------------------------------------------------*
  DATA: v_rut(10)        TYPE c,
        sumpago_aux(13)  TYPE n,
        f_rut(10)        TYPE c,
        enumero(09)      TYPE n,
        enumero2(09)     TYPE n,
        numero(10)       TYPE n,
        lineas(5)        TYPE n,
        monto_z(13),
        num_c(11)        TYPE c,
        folio_aux(15),
        largo(05)        TYPE n,
        largo1(05)       TYPE n,
        f_adrnr          TYPE adrc-addrnumber,
        v_adrnr          TYPE adrc-addrnumber,
        dv(1)            TYPE c,
        dv2(1)           TYPE c,
        v_mail           TYPE adr6-smtp_addr,
        v_ct(20)         TYPE c,
        v_cta            TYPE zfitr005-zctacte,
        v_vta            TYPE zfitr005-zctavta,
        v_cla            TYPE zfitr005-zclavemis,
        v_doc(16)        TYPE c,
        tipdoc(4)        TYPE c,
        td(1)            TYPE c,
        lv_glosa         TYPE char67,
        lv_lin           TYPE i,
        lv_corr4         TYPE numc4,
        v_monto(13),
        v_monto_temp(13),
        v_cod            TYPE zfitr005-zcodserv,
        archivo(130)     TYPE c,
        archivo_a(130)   TYPE c,
        sumpag1(15)      TYPE n,
        corr_avisoh(4)   TYPE n,
        corr_avisop(5)   TYPE n,
        glosa_aviso(320) TYPE c,
        bancoref         TYPE ztd_pagobanco-banco,
        v_flag.

  DATA : BEGIN OF file OCCURS 0,
           linea(400) TYPE c.
  DATA : END OF file.
  DATA : BEGIN OF reg01 OCCURS 0,
           rut_prv(08)       TYPE n,
           rut_dvr(01)       TYPE c,
           identificador(15) TYPE c,
           nombre(45)        TYPE c,
           tipo_proceso(01)  TYPE c,
           cod_banco(03)     TYPE c,
           cuenta_abo(20)    TYPE c,
           destino(01)       TYPE c,
           monto_pago(09)    TYPE n,
         END OF reg01.
" INI HCD 02-10-2020 agrego variables para secuencia
 DATA:  c_ceros(6)   TYPE c,
        secuencia(6)   TYPE n.
" FIN HCD 02-10-2020 agrego variables para secuencia
  DATA: wa_zfitr005 TYPE zfitr005,
        ti_adrc     TYPE adrc          OCCURS 0 WITH HEADER LINE,
        ti_set_fac  LIKE setleaf       OCCURS 0 WITH HEADER LINE,
        ti_set_ncr  LIKE setleaf       OCCURS 0 WITH HEADER LINE,
        tiposdoc    TYPE ztd_pagobanco OCCURS 0 WITH HEADER LINE.
*
  RANGES: r_fac FOR bkpf-blart,
          r_ncr FOR bkpf-blart.

*&---------------------------------------------------------------------*
*& ** INICIALIZACION DE VARIABLES                                      *
*&---------------------------------------------------------------------*
  CLEAR:   r_fac,
           r_ncr,
           ti_set_fac,
           ti_set_ncr,
           corr_avisoh,
           corr_avisop.

  REFRESH: r_fac,
           r_ncr,
           ti_set_fac,
           ti_set_ncr.
*&---------------------------------------------------------------------------
*&   PREPARA REGISTRO DE PAGOS
*&---------------------------------------------------------------------------
  REFRESH reg01.
  REFRESH: ti_adrc, file.
*
  SORT tabla_00 .
  READ TABLE tabla_00 INDEX 1.
*  Carga Clases de Documento, según sociedad y banco
  SELECT SINGLE *
        FROM ztd_pagobanco  WHERE banco = tabla_00-ubnkl.
  IF sy-subrc = 0.
    bancoref = tabla_00-ubnkl.
  ELSE.
    bancoref = '027'.
  ENDIF.
*
  SELECT * INTO CORRESPONDING FIELDS OF TABLE  tiposdoc
          FROM ztd_pagobanco WHERE banco = bancoref.
*
  SELECT SINGLE adrnr INTO v_adrnr
*V1 RVY 24.09.2020
*        FROM t001           WHERE bukrs EQ tabla_00-zbukr.
*V1 RVY 24.09.2020
         FROM t001           WHERE bukrs EQ tabla_00-absbu.
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
    enumero = num_c.
    numero  = num_c.
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
*
  SELECT SINGLE *
        FROM zfolio_pagobanco
          WHERE bukrs  = tabla_00-zbukr
            AND ubnkl  = tabla_00-ubnkl
            AND codigo = '001'.
  IF sy-subrc <> 0.
    zfolio_pagobanco-bukrs           = tabla_00-zbukr.
    zfolio_pagobanco-codigo          = '001'.
    zfolio_pagobanco-folio           = 0.
    zfolio_pagobanco-folio_propuesta = 0.
  ENDIF.
* Toma el folio que asignara a la propuesta y le suma 1
  zfolio_pagobanco-folio_propuesta = zfolio_pagobanco-folio_propuesta + 1.
*
*&---------------------------------------------------------------------*
*& ** RESCATA MOTIVOS DE EMISION
*&----------------------------------------------------------------------
*  Rescata motivos de emisión

  SELECT SINGLE *  FROM regup
                   WHERE laufd EQ TABLA_00-laufd
                   AND   laufi EQ TABLA_00-laufi
                   AND   xvorl NE 'X'.

  SELECT SINGLE *  FROM bsak
                   WHERE bukrs EQ regup-bukrs
                   and   lifnr EQ regup-lifnr
*V1 RVY 24.09.2020
*                  AND   augbl EQ regup-vblnr
*V1 RVY 24.09.2020
                   AND   belnr EQ regup-belnr.

 SELECT SINGLE * INTO wa_zfitr005
    FROM zfitr005 WHERE bukrs  EQ tabla_00-zbukr
                    AND hbkid  EQ tabla_00-hbkid
                    AND zmotiv EQ bsak-zzmot_emis.
*&---------------------------------------------------------------------------
*&   *** AQUI SE ARMA REGISTRO 1 = CABECERA DE NOMINA         ***************
*&---------------------------------------------------------------------------
  sumpago_aux = sumpagos * 100.
*
  file-linea+0(02)      = '01'.
  file-linea+2(09)      = enumero.
  file-linea+11(1)      = dv.
* file-linea+12(03)     = nrotra+7(3). "wa_zfitr005-zcodserv.
  file-linea+12(03)     = wa_zfitr005-zcodserv.
  file-linea+15(05)     = zfolio_pagobanco-folio_propuesta.

*  if tabla_00-zbukr = 'CL35' or tabla_00-zbukr = 'CL36'. "COMENTARIADO POR NO PRUEBAS DE CSM 18052023
*      file-linea+20(08)     =    v_fecha. " tabla_00-laufd."HCD 29-03-2021 "COMENTARIADO POR NO PRUEBAS DE CSM 18052023
*  else."COMENTARIADO POR NO PRUEBAS DE CSM 18052023
      file-linea+20(08)     =   tabla_00-laufd."HCD 29-03-2021"COMENTARIADO POR NO PRUEBAS DE CSM 18052023
*  endif."COMENTARIADO POR NO PRUEBAS DE CSM 18052023
  file-linea+28(01)     = '-'.
  file-linea+29(06)     = tabla_00-laufi.
  file-linea+35(06)     = ' '.
  file-linea+45(02)     = '01'.
  file-linea+47(04)     = tabla_00-laufd+0(4).
  file-linea+51(02)     = tabla_00-laufd+4(2).
  file-linea+53(02)     = tabla_00-laufd+6(2).
  file-linea+55(13)     = sumpago_aux.
  file-linea+68(03)     = '   '.
  file-linea+71(01)     = 'N'.
  file-linea+72(324)    = ' '.
  file-linea+396(04)    = '0503'.
  APPEND file.
  CLEAR  file.
*
  CLEAR lineas.
*&---------------------------------------------------------------------*
*& ** INICIO CICLO DE LECTURA DE TABLA DE PAGOS DE BANCO
*&----------------------------------------------------------------------
"INICIO HCD 10-02-2020 Inicializo variables para secuencia
  c_ceros = '000000'.
  secuencia = 0.
"FIN HCD 10-02-2020 Inicializo variables para secuencia

  LOOP AT tabla_00.
    CLEAR: v_rut, f_rut, v_ct.
*
    v_rut = tabla_00-stcd1.
    IF v_rut IS NOT INITIAL.
      SPLIT v_rut AT '-' INTO num_c dv2.
      enumero2 = num_c.
      numero   = num_c.
      CONCATENATE numero dv2 INTO f_rut.
    ENDIF.

    zfolio_pagobanco-folio =  zfolio_pagobanco-folio + 1.
    IF tippro = 'X'.
      MODIFY  zfolio_pagobanco.
    ENDIF.

* Si no está procesado, genera nuevo folio
    IF tabla_00-identif_pago IS INITIAL.
      CONCATENATE tabla_00-zbukr tabla_00-ubnkl zfolio_pagobanco-folio+3(8) INTO folio_aux .
    ELSE.
* Si ya existe un folio anterior, deja el folio existente
      CLEAR folio_aux.
      MOVE tabla_00-identif_pago TO folio_aux.
    ENDIF.
*
    CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
      EXPORTING
        intext  = tabla_00-name1
      IMPORTING
        outtext = tabla_00-name1.
*
    CLEAR:  f_adrnr, v_adrnr, ti_adrc, v_mail.
    REFRESH ti_adrc.
*
    SELECT SINGLE adrnd     INTO v_adrnr
           FROM knvk  WHERE lifnr EQ tabla_00-lifnr.

    SELECT SINGLE smtp_addr INTO v_mail
           FROM adr6  WHERE addrnumber EQ tabla_00-adrnr.
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
*
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = tabla_00-ubknt
      IMPORTING
        output = v_ct.

    monto_z = tabla_00-rbetr * -100.
    monto_z = monto_z * 100.
*
    REPLACE '.' WITH '' INTO monto_z.
    REPLACE ',' WITH '' INTO monto_z.
    CONDENSE monto_z NO-GAPS.
*
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = monto_z
      IMPORTING
        output = monto_z.

    corr_avisoh = corr_avisoh + 1.
*&---------------------------------------------------------------------*
*& ** PREPARACION DE REGISTROS DE PAGO (2)
*&----------------------------------------------------------------------
    file-linea+0(02)      = '02'.
    file-linea+2(09)      = enumero.
    file-linea+11(01)     = dv.
    file-linea+12(03)     = wa_zfitr005-zcodserv.
    file-linea+15(02)     = ' '.
    file-linea+17(05)     = zfolio_pagobanco-folio_propuesta.
    IF tabla_00-rzawe <> 'V'.
      IF tabla_00-zbnkl = '001'.
        file-linea+22(02)  = '01'.
      ELSE.
        file-linea+22(02)  = '07'.
      ENDIF.
      file-linea+169(03)  = tabla_00-zbnkl+0(3).
      file-linea+172(22)  = tabla_00-zbnkn.
    ELSE.
      file-linea+22(02)   = '02'.
    ENDIF.
    file-linea+24(10)     = enumero2.
    file-linea+33(01)     = dv2.
    file-linea+34(60)     = tabla_00-name1.
    file-linea+94(1)      = '0'.
    file-linea+95(35)     = v_adrnr.
    file-linea+130(15)    = ' '.
    file-linea+145(15)    = ' '.
    file-linea+160(07)    = ' '.
    IF tabla_00-rzawe = 'V'.
      IF num_c < 50000000.
        file-linea+167(02)  = 'BC'.
      ELSE.
        file-linea+167(02)  = 'B1'.
      ENDIF.
    ELSE.
      file-linea+167(02)    = '  '.
    ENDIF.
    file-linea+197(13)      = monto_z.
    file-linea+210(119)     = folio_aux.
    file-linea+329(04)      = '0000'." Se cambia S por 0000 01-10-2020 HCD
    file-linea+333(01)      = 'N'.
"INI CAMBIADO HCD 02-10-2020
    file-linea+334(14)      = ' '.

    secuencia = secuencia + 1.
    OVERLAY secuencia WITH c_ceros.
    file-linea+348(6)    = secuencia.

    file-linea+354(1)  = 'N'.
    file-linea+355(45) = ' '.
 " FIN CAMBIADO HCD 02-10-2020
 "   file-linea+334(03)      = '0000'.
 "   file-linea+337(10)      = '0000000000'.
 "   file-linea+347(01)      = '+'.
 "   file-linea+348(06)      = '000000'.
 "   file-linea+354(01)      = ' '.
 "   file-linea+355(45)      = ' '.
    APPEND file.
    CLEAR  file.

*&---------------------------------------------------------------------*
*& ** PREPARACION DE REGISTROS DE DETALLES COMPONENTES DE PAGO (3)
*&----------------------------------------------------------------------
"INIC 01-10-2020 Eliminar linea 03
 "   file-linea+0(02)      = '03'.
 "   file-linea+2(09)      = enumero.
 "   file-linea+11(1)      = dv.
 "   file-linea+12(3)      = wa_zfitr005-zcodserv.
 "   file-linea+15(2)      = ' '.
 "   file-linea+17(05)     = zfolio_pagobanco-folio_propuesta.
 "   file-linea+22(04)     = '0001'.
 "   file-linea+26(03)     = 'MES'.
 "   file-linea+29(96)     = ' '.
 "   file-linea+125(250)   = ' '.
 "   file-linea+375(02)    = ' '.
 "   file-linea+377(03)    = ' '.
 "   file-linea+380(20)    = ' '.
 "   APPEND file.
 "   CLEAR  file.
" FIN 01-10-2020 Eliminar linea 03 HCD
* --------------------------------------------------------------------------
* AQUI SE INICIA LOOP PARA REGISTRAR AVISOS PARA DOCUMENTOS QUE SE PAGAN ***
* (2do. LOOP DE REGUP)
* --------------------------------------------------------------------------
    CLEAR corr_avisop.
    SELECT * FROM  regup   WHERE   laufd = tabla_00-laufd
                             AND   laufi = tabla_00-laufi
                             AND   xvorl = tabla_00-xvorl
                             AND   lifnr = tabla_00-lifnr
                             AND   zbukr = tabla_00-zbukr
                             AND   kunnr = tabla_00-kunnr
                             AND   empfg = tabla_00-empfg
                             AND   vblnr = tabla_00-vblnr
                             ORDER BY PRIMARY KEY.
*
      corr_avisop = corr_avisop + 1.
*
      IF corr_avisop EQ 1.
        file-linea+0(02)      = '04'.
        file-linea+2(09)      = enumero.
        file-linea+11(1)      = dv.
        file-linea+12(3)      = wa_zfitr005-zcodserv.
        file-linea+15(2)      = ' '.
        file-linea+17(05)     = zfolio_pagobanco-folio_propuesta.
        file-linea+22(04)     = '0001'.
*
        lv_lin                = 27.
        lv_corr4              = 0.
      ENDIF.
*
      v_monto = regup-dmbtr * 10000.

      REPLACE '.' WITH '' INTO v_monto.
      REPLACE ',' WITH '' INTO v_monto.
      CONDENSE v_monto NO-GAPS.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = v_monto
        IMPORTING
          output = v_monto.

      CLEAR tipdoc.

      READ TABLE tiposdoc WITH KEY  banco = bancoref  codigo = regup-blart.
      IF sy-subrc = 0.
        MOVE tiposdoc-codban TO tipdoc.
      ELSE.
        tipdoc = '9999'.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = regup-xblnr
        IMPORTING
          output = v_doc.
*
      CLEAR lv_glosa.
      lv_glosa+00(02)      = tipdoc+2(2).
      lv_glosa+02(10)      = v_doc+6(10).
      lv_glosa+12(02)      = regup-bldat+6(2).
      lv_glosa+14(02)      = regup-bldat+4(2).
      lv_glosa+16(04)      = regup-bldat+0(4).
*
      file-linea+lv_lin(67) = lv_glosa.
      lv_lin                = lv_lin + 67.
      file-linea+lv_lin(13) = v_monto.
      lv_lin                = lv_lin + 13.
**
      lv_corr4              = lv_corr4 + 1.
      file-linea+397(03)    = lv_corr4+1(3).
*
* REINCICA EL CONTADOR CUANDO HAYA PRCESADO 4 DOCUMENTOS Y
* GRABA EL REGISTRO.
      IF corr_avisop EQ 4.
        corr_avisop = 0.

      "  APPEND file. "01-10-2020 HCD no registra registro 04
        CLEAR  file.
      ENDIF.
    ENDSELECT. " de revision de REGUP.
* GRABA EL ULTIMO REGISTRO PROCESADO SI EL REGISTRO FUE MENOR A 4.
    IF corr_avisop GT 0.
     " APPEND file. "01-10-2020 HCD no registra registro 04
      CLEAR  file.
    ENDIF.
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

    lineas   = lineas  + 1.
    monto_z  = monto_z + v_monto.

  ENDLOOP.                                                  " tabla_00

  CALL FUNCTION 'DEQUEUE_EZ_ZFOLIO_PAGBCO'
    EXPORTING
      mode_zfolio_pagobanco = 'E'
      mandt                 = sy-mandt
      bukrs                 = tabla_00-zbukr
      ubnkl                 = tabla_00-ubnkl
      codigo                = '001'.

*&---------------------------------------------------------------------*
*& ** PASA ARCHIVO A PAREMETRO DE SALIDA DE ESTA FUNCION
*&----------------------------------------------------------------------
  filesalida[] = file[].

*&---------------------------------------------------------------------*
*& ** DESBLOQUEA FOLIO DE SOCIEDAD BANCO CON FOLIO ACTUALIZADO
*&----------------------------------------------------------------------*

ENDFUNCTION.
