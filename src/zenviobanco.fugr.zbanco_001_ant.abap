*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
*& ** GENERACION DE ARCHIVOS DE BANCO CHILE (001) MARZO 2016
*&---------------------------------------------------------------------*
FUNCTION ZBANCO_001_ANT.
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

  DATA: v_rut(10)     TYPE c,
        sumpago_aux(13) TYPE n,
       f_rut(10)      TYPE c,
       numero(10)      TYPE n,
       lineas(5)      TYPE n,
       monto_z(13),
       num_c(11)      TYPE c,
       folio_aux(15),
       largo(05)      TYPE n,
       largo1(05)     TYPE n,
       f_adrnr        TYPE adrc-addrnumber,
       v_adrnr        TYPE adrc-addrnumber,
       dv(1)          TYPE c,
       v_mail         TYPE adr6-smtp_addr,
       v_ct(20)       TYPE c,
       v_cta          TYPE zfitr005-zctacte,
       v_vta          TYPE zfitr005-zctavta,
       v_cla          TYPE zfitr005-zclavemis,
       v_doc(16)      TYPE c,
       tipdoc(4)      TYPE c,
       td(1)          TYPE c,
       v_monto(13),
       v_monto_temp(13),
       v_cod          TYPE zfitr005-zcodserv,
       archivo(130)   TYPE c,
       archivo_a(130) TYPE c,
       sumpag1(15)    TYPE n,
       corr_avisoh(4) TYPE n,
       corr_avisop(5) TYPE n,
       glosa_aviso(320) TYPE c,
       bancoref       TYPE ztd_pagobanco-banco,
       v_flag.

  DATA : BEGIN OF file OCCURS 0,
          linea(610)  TYPE c.
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
        ti_set_ncr LIKE setleaf    OCCURS 0 WITH HEADER LINE,
        tiposdoc   TYPE ztd_pagobanco OCCURS 0 WITH HEADER LINE.

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

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT TABLA_00 .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
  READ TABLE tabla_00 INDEX 1.

*  Carga Clases de Documento, según sociedad y banco
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *
*         FROM ztd_pagobanco
*         WHERE banco = tabla_00-ubnkl.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
         FROM ztd_pagobanco
         WHERE banco = tabla_00-ubnkl ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc = 0.
    bancoref = tabla_00-ubnkl.
  ELSE.
    bancoref = '027'.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*          FROM ztd_pagobanco
*          INTO CORRESPONDING FIELDS OF TABLE  tiposdoc
*          WHERE banco = bancoref.
*
* NEW CODE
  SELECT *

          FROM ztd_pagobanco
          INTO CORRESPONDING FIELDS OF TABLE  tiposdoc
          WHERE banco = bancoref ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE adrnr
*         FROM t001
*         INTO v_adrnr
*         WHERE bukrs EQ tabla_00-zbukr.
*
* NEW CODE
  SELECT adrnr
  UP TO 1 ROWS 
         FROM t001
         INTO v_adrnr
         WHERE bukrs EQ tabla_00-zbukr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

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

*&---------------------------------------------------------------------*
*& ** RESCATA MOTIVOS DE EMISION
*&----------------------------------------------------------------------
* Rescata motivos de emisión
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE ti_exc
*    FROM zfitr005
*    WHERE bukrs = tabla_00-zbukr
*      AND hbkid = tabla_00-hbkid.
*
* NEW CODE
  SELECT *

    INTO CORRESPONDING FIELDS OF TABLE ti_exc
    FROM zfitr005
    WHERE bukrs = tabla_00-zbukr
      AND hbkid = tabla_00-hbkid ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*&---------------------------------------------------------------------------
*&   *** AQUI SE ARMA REGISTRO 1 = CABECERA DE NOMINA         ***************
*&---------------------------------------------------------------------------
  file-linea+0(02)      = '01'.
  file-linea+2(10)      = numero.
  file-linea+12(1)      = dv.
  sumpago_aux = sumpagos * 100.
  file-linea+13(13)     = sumpago_aux.
  file-linea+26(04)     = '0000'.
  file-linea+30(06)     = contar.
  file-linea+36(04)     = '0000'.
  file-linea+40(06)     = contardoc.

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

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *  FROM zfolio_pagobanco  WHERE bukrs  = tabla_00-zbukr
*                                            AND ubnkl  = tabla_00-ubnkl
*                                            AND codigo = '001'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS   FROM zfolio_pagobanco  WHERE bukrs  = tabla_00-zbukr
                                            AND ubnkl  = tabla_00-ubnkl
                                            AND codigo = '001' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
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

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE adrnd
*           INTO v_adrnr
*           FROM knvk
*           WHERE lifnr EQ tabla_00-lifnr.
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
*    SELECT SINGLE smtp_addr
*           INTO v_mail
*           FROM adr6
*           WHERE addrnumber EQ tabla_00-adrnr.
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

    monto_z = tabla_00-rbetr * -100.
    monto_z = monto_z * 100.

    REPLACE '.' WITH '' INTO monto_z.
    REPLACE ',' WITH '' INTO monto_z.
    CONDENSE monto_z NO-GAPS.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = monto_z
      IMPORTING
        output = monto_z.

    corr_avisoh = corr_avisoh + 1.

*&---------------------------------------------------------------------*
*& ** PREPARACION DE REGISTROS DE PAGO (2)
*&----------------------------------------------------------------------
    file-linea+0(02)       = '02'.
    file-linea+2(10)       = numero.
    file-linea+12(01)      = dv.
    file-linea+13(60)      = tabla_00-name1.
    IF tabla_00-rzawe = 'V'.
      IF num_c < 50000000.
        file-linea+138(02)     = 'BC'.
      ELSE.
        file-linea+138(02)     = 'B1'.
      ENDIF.
    ELSE.
      file-linea+138(02)     = '  '.
    ENDIF.
    file-linea+140(13)     = monto_z.
    file-linea+153(02)     = tabla_00-laufd+6(2).
    file-linea+155(02)     = tabla_00-laufd+4(2).
    file-linea+157(04)     = tabla_00-laufd+0(4).
    IF tabla_00-rzawe <> 'V'.
      IF tabla_00-zbnkl = '001'.
        file-linea+161(02)  = '01'.
      ELSE.
        file-linea+161(02)  = '07'.
      ENDIF.
      file-linea+163(03)  = tabla_00-zbnkl+0(3).
      file-linea+169(22)  = tabla_00-zbnkn.
    ELSE.
      file-linea+161(02)  = '02'.
    ENDIF.
    file-linea+191(120)     = folio_aux.
    file-linea+311(01)      = 'S'.
    file-linea+453(01)      = '1'.
    file-linea+454(04)      = '0000'.
    file-linea+458(10)      = '0000000000'.
    file-linea+468(60)      = v_mail.
    file-linea+588(04)      = corr_avisoh.

    APPEND file.
    CLEAR  file.
    CLEAR v_monto_temp.
*&---------------------------------------------------------------------*
*& ** PREPARACION DE REGISTROS DE DETALLES COMPONENTES DE PAGO (3)
*&----------------------------------------------------------------------

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

      v_monto = regup-dmbtr * 10000.

      REPLACE '.' WITH '' INTO v_monto.
      REPLACE ',' WITH '' INTO v_monto.
      CONDENSE v_monto NO-GAPS.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = v_monto
        IMPORTING
          output = v_monto.

*      IF regup-shkzg = 'S'.
*        v_monto+0(1) = '-'.
*      ENDIF.

*      IF regup-blart IN r_ncr.
*        v_monto+0(1) = '-'.
*      ENDIF.

      CLEAR tipdoc.

      READ TABLE tiposdoc WITH KEY
      banco = bancoref  codigo = regup-blart.
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

      file-linea+0(02)       = '03'.
      file-linea+02(02)      = tipdoc+2(2).
      file-linea+05(10)      = v_doc+6(10).
      file-linea+15(03)      = '001'.
      file-linea+18(13)      = v_monto.
      file-linea+31(13)      = v_monto.
      file-linea+44(02)      = regup-bldat+6(2).
      file-linea+46(02)      = regup-bldat+4(2).
      file-linea+48(04)      = regup-bldat+0(4).

      APPEND file.
      CLEAR  file.

    ENDSELECT. " de revision de REGUP.

    CLEAR corr_avisop.

* --------------------------------------------------------------------------
* AQUI SE INICIA LOOP PARA REGISTRAR AVISOS PARA DOCUMENTOS QUE SE PAGAN ***
* (2do. LOOP DE REGUP)
* --------------------------------------------------------------------------
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM  regup   WHERE   laufd = tabla_00-laufd
*                             AND   laufi = tabla_00-laufi
*                             AND   xvorl = tabla_00-xvorl
*                             AND   lifnr = tabla_00-lifnr
*                             AND   zbukr = tabla_00-zbukr
*                             AND   kunnr = tabla_00-kunnr
*                             AND   empfg = tabla_00-empfg
*                             AND   vblnr = tabla_00-vblnr.
*
* NEW CODE
    SELECT *
 FROM  regup   WHERE   laufd = tabla_00-laufd
                             AND   laufi = tabla_00-laufi
                             AND   xvorl = tabla_00-xvorl
                             AND   lifnr = tabla_00-lifnr
                             AND   zbukr = tabla_00-zbukr
                             AND   kunnr = tabla_00-kunnr
                             AND   empfg = tabla_00-empfg
                             AND   vblnr = tabla_00-vblnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

      corr_avisop = corr_avisop + 1.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = regup-xblnr
        IMPORTING
          output = v_doc.

      CONCATENATE 'Pago de número de documento:' v_doc+6(10) INTO glosa_aviso.

      file-linea+0(02)       = '04'.
      file-linea+02(04)      = corr_avisoh.
      file-linea+06(320)     = glosa_aviso.
      file-linea+326(05)     = corr_avisop.

      APPEND file.
      CLEAR  file.

    ENDSELECT. " de revision de REGUP.

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
