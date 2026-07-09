*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
*& ** GENERACION DE ARCHIVOS DE BANCO SANTANDER (037)
*&---------------------------------------------------------------------*
FUNCTION zbanco_037.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(TIPPRO) TYPE  CHAR01
*"     REFERENCE(CONTAR) TYPE  NUMC06
*"     REFERENCE(SUMPAGOS) TYPE  NUMC15
*"     REFERENCE(V_FECHA) TYPE  DATS
*"     REFERENCE(NVOANT) TYPE  CHAR01
*"     REFERENCE(RET_VV) TYPE  CHAR01
*"  TABLES
*"      TABLA_00 STRUCTURE  REGUH
*"      FILESALIDA
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
*&---------------------------------------------------------------------*
*& ** DEFINICION DE DATOS
*&---------------------------------------------------------------------*

  DATA: v_rut(10)     TYPE c,
       f_rut(10)      TYPE c,
       numero(9)      TYPE n,
       numero4(4)     TYPE n,
       numero11(11)   TYPE n,
       numero18(18)   TYPE n,
       lineas(5)      TYPE n,
       monto_z(15),
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
       v_doc(16)      TYPE c,   " 07-03-2019 HCD se cambia de 8 a 16
       tipdoc(4)      TYPE c,
       td(1)          TYPE c,
       v_monto(13),
       v_signo(1)    TYPE c,
       v_monto_temp(15),
       v_cod          TYPE zfitr005-zcodserv,
       archivo(130)   TYPE c,
       archivo_a(130) TYPE c,
       sumpag1(15)    TYPE n,
       fil538(538)    TYPE c,
       fil477(477)    TYPE c,
       fil553(553)    TYPE c,
       v_rutn(8)        TYPE c,
       v_rutnn(11)    type N,
       v_rutd(1)        TYPE c,
       v_apellidop(15)  TYPE c,
       v_apellidom(15)  TYPE c,
       v_nombres(15)    TYPE c,
       v_Glosa_red(25)  type c,
       v_flag.

* constants: carro type abap_cr_lf value cl_abap_char_utilities=>cr_lf.
  DATA : carro TYPE char1.

  DATA : BEGIN OF file OCCURS 0,
          linea(581)  TYPE c.
  DATA : END OF file.

  DATA: ti_exc LIKE zfitr005 OCCURS 0 WITH HEADER LINE.


  DATA: ti_adrc TYPE adrc OCCURS 0 WITH HEADER LINE,
        ti_set_fac LIKE setleaf    OCCURS 0 WITH HEADER LINE,
        ti_set_ncr LIKE setleaf    OCCURS 0 WITH HEADER LINE.

  RANGES: r_fac FOR bkpf-blart,
          r_ncr FOR bkpf-blart.

*&---------------------------------------------------------------------*
*& ** INICIALIZACION DE VARIABLES
*&---------------------------------------------------------------------*

  carro =  cl_abap_char_utilities=>cr_lf+0(1).
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

  REFRESH: ti_adrc, file.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT TABLA_00 .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
  READ TABLE tabla_00 INDEX 1.

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
    numero11 = numero.
    CONCATENATE numero dv INTO f_rut.
  ENDIF.
*&---------------------------------------------------------------------*
*& ** GENERA REGISTRO DE IDENTIFICACION DE PROCESO DE PRUEBA
*&---------------------------------------------------------------------*
*  IF tippro <> 'X'.
*    file-linea+0(225)      = '*****ARCHIVO DE TEST*****'.
*    APPEND file.
*    CLEAR  file.
*  ENDIF.

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
*&   *** AQUI SE ARMA REGISTRO 0 = CABECERA DE MULTINOMINA    ***************
*&---------------------------------------------------------------------------
  file-linea+0(1)       = '0'.
*****  Cambio realizado el 20180108 PYV Limitada.                                             *********
*****  RUT cabecera de Archivo, se cambia a RUT de Empresa madre, si es VIDA TRES la Pagadora *********
  IF tabla_00-zbukr = 'CL24'.
    file-linea+1(12)      = '000965728007'.
  ELSE.
    file-linea+1(11)      = numero11.
    file-linea+12(1)      = dv.
  ENDIF.

  CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
    EXPORTING
      intext  = ti_adrc-name1
    IMPORTING
      outtext = ti_adrc-name1.

  IF ti_adrc-name1 CA ','.
    REPLACE ',' WITH ' ' INTO ti_adrc-name1.
    CONDENSE  ti_adrc-name1.
  ENDIF.

  IF tabla_00-zbukr = 'CL24'.
    file-linea+13(40)     = 'ISAPRE BANMEDICA'.
  ELSE.
    file-linea+13(40)     = ti_adrc-name1.
  ENDIF.

*  file-linea+13(40)     = ti_adrc-name1.
  file-linea+53(8)      = sy-datum.
  file-linea+61(6)      = sy-uzeit.
  file-linea+67(2)      = tabla_00-dtws4.
*  file-linea+69(1)      = carro.

  APPEND file.
  CLEAR  file.
*&---------------------------------------------------------------------------
*&   *** AQUI SE ARMA REGISTRO 1 = CABECERA DE NOMINA         ***************
*&---------------------------------------------------------------------------
  file-linea+0(01)       = '1'.
  file-linea+1(03)      = '001'.
  file-linea+4(02)      = tabla_00-dtws4.
  file-linea+6(11)      = numero11.
  file-linea+17(1)      = dv.
  file-linea+18(40)     = ti_adrc-name1.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *
*    FROM bsak
*    WHERE bukrs EQ tabla_00-zbukr
*      AND lifnr EQ tabla_00-lifnr
*      AND augbl EQ tabla_00-vblnr
*      AND belnr <> tabla_00-vblnr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
    FROM bsak
    WHERE bukrs EQ tabla_00-zbukr
      AND lifnr EQ tabla_00-lifnr
      AND augbl EQ tabla_00-vblnr
      AND belnr <> tabla_00-vblnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM zfitr005 WHERE bukrs  = tabla_00-zbukr
*                              AND hbkid  = tabla_00-hbkid
*                              AND zmotiv = bsak-zzmot_emis.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM zfitr005 WHERE bukrs  = tabla_00-zbukr
                              AND hbkid  = tabla_00-hbkid
                              AND zmotiv = bsak-zzmot_emis ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  MOVE: zfitr005-zctacte   TO v_cta,
        zfitr005-zctavta   TO v_vta,
        zfitr005-zclavemis TO v_cla.


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

  file-linea+58(18)      = v_cta.
  file-linea+76(18)      = v_vta.
  file-linea+94(08)      = tabla_00-zaldt.
  file-linea+102(02)     = '01'.
*  file-linea+581(1)      = carro.


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
      numero11 = numero.
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

** V1 RVY 06-05-2024
    IF RET_VV = ' '.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*       SELECT SINGLE smtp_addr
*              INTO v_mail
*              FROM adr6
*              WHERE addrnumber EQ tabla_00-adrnr.
*
* NEW CODE
       SELECT smtp_addr
       UP TO 1 ROWS 
              INTO v_mail
              FROM adr6
              WHERE addrnumber EQ tabla_00-adrnr ORDER BY PRIMARY KEY.

       ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    else.
       v_mail = ' '.
    endif.
** V1 RVY 06-05-2024

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

    monto_z = tabla_00-rbetr * -10000.

    REPLACE '.0000' WITH '' INTO monto_z.
    CONDENSE monto_z NO-GAPS.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = monto_z
      IMPORTING
        output = monto_z.
*&---------------------------------------------------------------------*
*& ** PREPARACION DE REGISTROS DE PAGO (2)
*&----------------------------------------------------------------------
    numero4  = tabla_00-zbnkl+0(3).
    numero18 = tabla_00-zbnkn+0(18).
    file-linea+0(01)       = '2'.
    file-linea+1(11)       = numero11.
    file-linea+12(01)      = dv.
    file-linea+13(40)      = tabla_00-name1.
    file-linea+53(3)       = '000'.
    file-linea+56(40)      = ti_adrc-street.
    file-linea+99(15)      = ti_adrc-city1.
    file-linea+132(3)      = '000'.
    IF tabla_00-rzawe = 'V'.
      file-linea+150(02)      = '05'.
      IF ret_VV = 'X'.
         file-linea+150(02)      = '14'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*         SELECT SINGLE rutn rutd apellidop apellidom nombres
*            FROM ZFITR026
*            INTO (v_rutn, v_rutd, v_apellidoP, V_apellidom, v_nombres)
*            WHERE bukrs = tabla_00-Zbukr AND
*                  BANKS = 'CL'           AND
*                  BANKL = '037'.
*
* NEW CODE
         SELECT rutn rutd apellidop apellidom nombres
         UP TO 1 ROWS 
            FROM ZFITR026
            INTO (v_rutn, v_rutd, v_apellidoP, V_apellidom, v_nombres)
            WHERE bukrs = tabla_00-Zbukr AND
                  BANKS = 'CL'           AND
                  BANKL = '037' ORDER BY PRIMARY KEY.

         ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
         v_rutNN             = v_rutN.
         file-linea+177(11)  = v_rutNn.
         file-linea+188(01)  = v_rutd.
         file-linea+189(40) = |{ V_APELLIDOP } { V_APELLIDOM } { V_NOMBRES }|.
*         CONCATENATE v_apellidoP ' ' v_apellidoM ' ' v_nombres into
*                     file-linea+189(40).
      endif.
    ELSE.
*&---------------------------------------------------------------------*
*&  Modificacion del 20180108, realizada por PYV Limitada              *
*& Cambio de modalidad de pago, si Transferencias a cuentas de otros   *
*& Bancos (no Santander) el còdigo debe ser 04, en lugar de 01         *
*&---------------------------------------------------------------------*
      IF tabla_00-zbnkl <> '037'.
        file-linea+150(02)      = '04'.
      ELSE.
        file-linea+150(02)      = '01'.
      ENDIF.
    ENDIF.
    file-linea+152(03)      = '999'.
    file-linea+155(18)      = numero18.
    file-linea+173(04)      = numero4.
*    file-linea+177(11)      = numero11.
*    file-linea+188(01)      = dv.
*    file-linea+189(40)      = tabla_00-name1.
    file-linea+229(01)      = '0'.
    file-linea+270(02)      = 'NO'.
    file-linea+272(01)      = 'N'.

    file-linea+323(15)      = monto_z.

    file-linea+338(1)       = 'S'.

    file-linea+339(40)     = folio_aux.
*    file-linea+576(1)     = carro.

    APPEND file.
    CLEAR  file.
    CLEAR v_monto_temp.
*&---------------------------------------------------------------------*
*& ** PREPARACION DE REGISTROS DE DETALLES COMPONENTES DE PAGO (3)
*&----------------------------------------------------------------------
    IF tabla_00-dtws4 = 02.
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

        REPLACE '.0000' WITH '' INTO v_monto.
        CONDENSE v_monto NO-GAPS.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = v_monto
          IMPORTING
            output = v_monto.

        v_signo = '+'.

        IF regup-shkzg = 'S'.
          v_signo = '-'.
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = regup-xblnr
          IMPORTING
            output = v_doc.
        file-linea+0(01)         = '3'.
        file-linea+1(08)         = v_doc.
        file-linea+9(01)         = v_signo.
        file-linea+10(13)        = v_monto.
        file-linea+23(553)       = fil553.
*        file-linea+576(1)        = carro.

*       CONCATENATE '3' v_doc  v_signo v_monto fil553 carro INTO file-linea.

        APPEND file.
        CLEAR  file.

      ENDSELECT. " de revision de REGUP.
    ENDIF.
*&---------------------------------------------------------------------*
*& ** SI PROCESO REAL ACTUALIZA REGISTROS DE CABECERA CONTABLE
*&----------------------------------------------------------------------*
    v_glosa_red = ' '.
*    IF tabla_00-zbukr = 'CL01' OR tabla_00-zbukr = 'CL25'.
       IF RET_VV = 'X'.
*          v_Glosa_red = 'CAMPAÑA_ROJA'.
          v_Glosa_red = 'RETIRO POR UN 3ERO'.
       endif.
*    endif.

    UPDATE reguh
       SET identif_pago   = folio_aux
           fecha_envio    = sy-datum
           usuario_envio  = sy-uname
           GLOSA_REDEPO   = v_glosa_red
       WHERE laufd          = tabla_00-laufd
         AND laufi          = tabla_00-laufi
         AND xvorl          = tabla_00-xvorl
         AND zbukr          = tabla_00-zbukr
         AND lifnr          = tabla_00-lifnr
         AND kunnr          = tabla_00-kunnr
         AND empfg          = tabla_00-empfg
         AND vblnr          = tabla_00-vblnr.

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
*& ** PREPARACION DE REGISTRO TOTAL DE NOMINA  (5)
*&----------------------------------------------------------------------
  file-linea+0(1)      = '5'.
  file-linea+1(2)      = '01'.
  file-linea+3(4)      = contar+2(4).             "    Cuenta registros nòmina
  sumpag1 = sumpagos * 100.
  file-linea+7(15)      = sumpag1.                "    Sumatoria de pagos nòmina
*  file-linea+560(1)     = carro.
  APPEND file.
  CLEAR  file.

*&---------------------------------------------------------------------*
*& ** PREPARACION DE REGISTRO TOTAL DE MULTI NOMINA  (9)
*&----------------------------------------------------------------------
  file-linea+0(1)        = '9'.
  file-linea+1(2)        = '01'.
*                                                 "    Cuenta registros multinomina
  file-linea+3(15)      = sumpag1.
*  file-linea+556(1)     = carro.              "    Sumatoria de pagos multinomina
  APPEND file.
  CLEAR  file.
*&---------------------------------------------------------------------*
*& ** PASA ARCHIVO A PAREMETRO DE SALIDA DE ESTA FUNCION
*&----------------------------------------------------------------------
  filesalida[] = file[].

*&---------------------------------------------------------------------*
*& ** DESBLOQUEA FOLIO DE SOCIEDAD BANCO CON FOLIO ACTUALIZADO
*&----------------------------------------------------------------------*

ENDFUNCTION.
