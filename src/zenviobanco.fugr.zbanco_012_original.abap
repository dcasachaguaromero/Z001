*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION ZBANCO_012_ORIGINAL.
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
*& ** FUNCION PREPARACION DE ENVIO DE PAGOS BANCO ESTADO (012)
*&---------------------------------------------------------------------*
*"----------------------------------------------------------------------
*& ** DEFINICION DE DATOS
*&----------------------------------------------------------------------*
  data: v_rut(10)     type c,
    f_rut(10)     type c,
    numero(9)     type n,
    linea(5)      type n,
    monto_z(13)   type n,
    v_monto13(13) type n,
    num_c(8)      type c,
    folio_aux(15),
    f_adrnr       type adrc-addrnumber,
    v_adrnr       type adrc-addrnumber,
    dv,
    v_mail        type adr6-smtp_addr,
    v_ct(20)      type c,
    v_doc(10)     type c,
    tipdoc(2)     type c,
    v_flag.

  data : begin of file occurs 0,
          linea(640) type c.
  data : end of file.

  data: ti_adrc    type adrc          occurs 0 with header line,
        tiposdoc   type ztd_pagobanco occurs 0 with header line.

*"----------------------------------------------------------------------
*& ** INICIO DE PROCESO
*&---------------------------------------------------------------------*
  refresh: file.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT TABLA_00 .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
  read table tabla_00 index 1.

*  Carga Clases de Documento, según sociedad y banco
  select *
  from ztd_pagobanco
  into corresponding fields of table  tiposdoc
       where banco = tabla_00-ubnkl.

  select single adrnr
         from t001
         into v_adrnr
         where bukrs eq tabla_00-zbukr.

  f_adrnr = v_adrnr.

  if f_adrnr is not initial.

    call function 'RTP_US_DB_ADRC_READ'
      exporting
        i_address_number = f_adrnr
      importing
        e_adrc           = ti_adrc
      exceptions
        not_found        = 1
        others           = 2.
  endif.

  v_rut = ti_adrc-sort1.

  if v_rut is not initial.
    split v_rut at '-' into num_c dv.
    numero = num_c.
    concatenate numero dv into f_rut.
  endif.
*"----------------------------------------------------------------------
*& ** SI PROCESO ES TEST GENERA REGISTRO INICAL EN ARCHIVO DE SALIDA
*&---------------------------------------------------------------------*
  if tippro <> 'X'.
    file-linea+0(225)      = '*****ARCHIVO DE TEST*****'.
    append file.
    clear  file.
  endif.
*"----------------------------------------------------------------------
*& ** SE GENERA REGISTRO DE CABECERA DE PAGOS DE SOCIEDAD BANCO
*&---------------------------------------------------------------------*
  file-linea+0(1)      = '1'.
  file-linea+1(9)      =  numero.
  file-linea+10(1)     =  dv.
  file-linea+11(10)    = '0000000001'.
  concatenate sy-datum+06(2) sy-datum+04(2) sy-datum+0(4) into file-linea+21(8).
  file-linea+29(6)      = sy-uzeit.
  concatenate v_fecha+06(2) v_fecha+04(2) v_fecha+0(4) into file-linea+35(8).
  file-linea+43(10)     = '0000000000'.
  file-linea+53(6)      = contar.
  file-linea+59(15)     = sumpagos.
  append file.
  clear  file.
*"----------------------------------------------------------------------
*& ** BLOQUEA Y RECUPERA FOLIOS DE SOCIEDAD Y BANCO
*&---------------------------------------------------------------------*
  call function 'ENQUEUE_EZ_ZFOLIO_PAGBCO'
    exporting
      mode_zfolio_pagobanco = 'E'
      mandt                 = sy-mandt
      bukrs                 = tabla_00-zbukr
      ubnkl                 = tabla_00-ubnkl
      codigo                = '001'.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
       with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  select single * from zfolio_pagobanco  where bukrs  = tabla_00-zbukr
                                            and ubnkl  = tabla_00-ubnkl
                                            and codigo = '001'.
*"----------------------------------------------------------------------
*& ** SI PUDO OBTENER FOLIOS SE HACE LOOP EN TABLA DE PAGOS
*&---------------------------------------------------------------------*
  if sy-subrc <> 0.
    zfolio_pagobanco-bukrs = tabla_00-zbukr.
    zfolio_pagobanco-codigo ='001'.
    zfolio_pagobanco-folio = 0.
  endif.

  loop at tabla_00.
*   Header Proveedor
    clear: v_rut, f_rut.
    v_rut = tabla_00-stcd1.
    if v_rut is not initial.
      split v_rut at '-' into num_c dv.
      numero = num_c.
      concatenate numero dv into f_rut.
    endif.

    zfolio_pagobanco-folio =  zfolio_pagobanco-folio + 1.
    if tippro = 'X'.
      modify  zfolio_pagobanco.
    endif.

* Si no está procesado, genera nuevo folio
    if tabla_00-identif_pago is initial.
* CBD
      concatenate tabla_00-zbukr tabla_00-ubnkl zfolio_pagobanco-folio+3(8)  into folio_aux .
    else.
* Si ya existe un folio anterior, deja el folio existente
      clear folio_aux.
* CBD
* CBD      MOVE tabla_00-identif_pago TO folio_aux.
      move tabla_00-identif_pago to folio_aux.
* CBD
    endif.

    call function 'SCP_REPLACE_STRANGE_CHARS'
      exporting
        intext  = tabla_00-name1
      importing
        outtext = tabla_00-name1.

    clear:  f_adrnr, v_adrnr, v_mail.

    select single adrnd
           into v_adrnr
           from knvk
           where lifnr eq tabla_00-lifnr.

    select single smtp_addr
           into v_mail
           from adr6
           where addrnumber eq tabla_00-adrnr.

    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = tabla_00-ubknt
      importing
        output = v_ct.

    v_monto13 = tabla_00-rbetr * -100.

    replace '.0000' with '' into v_monto13.
    condense v_monto13 no-gaps.

    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = v_monto13
      importing
        output = v_monto13.
*"----------------------------------------------------------------------
*& ** GENERA REGISTRO DE PAGO
*&---------------------------------------------------------------------*
    file-linea+0(1)      = '2'.
    file-linea+1(9)      = numero.
    file-linea+10(1)     = dv.
    file-linea+11(30)    = tabla_00-name1.
    file-linea+41(15)    = '               '.
    file-linea+56(15)    = '               '.
    if tabla_00-rzawe = 'V'.
      file-linea+71(2)     = '23'.
      file-linea+73(3)     = '012'.
      file-linea+76(17)    = '00000000000000000'.
    else.
      file-linea+71(2)     = '01'.
      file-linea+73(3)     = tabla_00-zbnkl.
      file-linea+76(17)    = tabla_00-zbnkn.
    endif.
    file-linea+93(13)    = v_monto13.
    file-linea+106(40)   = v_mail.
    file-linea+146(15)   = folio_aux.
    if tabla_00-rzawe = 'V'.
      file-linea+161(3)    = '001'.
      file-linea+164(2)    = '38'.
    else.
      file-linea+161(3)    = '000'.
      file-linea+164(2)    = '00'.
    endif.
    file-linea+166(200)  = '                    '.
    file-linea+366(256)  = '                    '.
    monto_z = monto_z + v_monto13.
    append file.
    clear  file.

* --------------------------------------------------------------------------
* SI FORMATO ES CON DETALLE PAGOS SE HACE LOOP EN DETALLE CONTABLES
* --------------------------------------------------------------------------
    if nvoant = '2'.
select * from regup where laufd = tabla_00-laufd
and laufi = tabla_00-laufi
and xvorl = tabla_00-xvorl
and lifnr = tabla_00-lifnr
and kunnr = tabla_00-kunnr
and empfg = tabla_00-empfg
and vblnr = tabla_00-vblnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES01 ECDK917080 *
*and zbukr = tabla_00-zbukr.
AND ZBUKR = TABLA_00-ZBUKR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES01 ECDK917080 *

        v_monto13 = regup-dmbtr * -100.

        replace '.0000' with '' into v_monto13.
        condense v_monto13 no-gaps.

        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = v_monto13
          importing
            output = v_monto13.
*"----------------------------------------------------------------------
*& ** RECUPERA Y TRADUCE TIPO DE DOCUMENTO SEGUN TABLA BANCOS
*&----------------------------------------------------------------------
        clear tipdoc.

        read table tiposdoc with key
        banco = tabla_00-ubnkl  codigo = regup-blart.
        if sy-subrc = 0.
          tipdoc = tiposdoc-codban+2(2).
        else.
          tipdoc = '99'.
        endif.

        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = regup-xblnr
          importing
            output = v_doc.
*"----------------------------------------------------------------------
*& ** GENERA REGISTRO DE DETALLE DE DOCUMENTO PAGADO
*&---------------------------------------------------------------------*
        file-linea+0(1)      = '3'.
        concatenate regup-bldat+06(2) regup-bldat+04(2) regup-bldat+0(4) into file-linea+1(8).
        file-linea+9(13)     = v_monto13.
        if regup-shkzg = 'S'.
          file-linea+13(01) = '-'.
        endif.
        file-linea+22(10)    = v_doc.
        file-linea+32        = tipdoc.
        file-linea+34(250)   = 'Otros Pagos Isapre'.
        append file.
        clear  file.
      endselect.
    endif.
*"---------------------------------------------------------------------------
*& ** SI PROCESO ES DEFINITIVO (REAL) SE ACTUALIZAN LOS PAGOS EN CONTABILIDAD
*&---------------------------------------------------------------------------
    if tippro = 'X'.
      update reguh
         set identif_pago   = folio_aux
             fecha_envio    = sy-datum
             usuario_envio  = sy-uname
       where laufd          = tabla_00-laufd
         and laufi          = tabla_00-laufi
         and xvorl          = tabla_00-xvorl
         and zbukr          = tabla_00-zbukr
         and lifnr          = tabla_00-lifnr
         and kunnr          = tabla_00-kunnr
         and empfg          = tabla_00-empfg
         and vblnr          = tabla_00-vblnr.
    endif.

  endloop.                                                  " tabla_00
*"----------------------------------------------------------------------
*& ** DESBLOQUEA ARCHIVO DE FOLIOS DE SOCIEDAD BANCO ACTUALIZADO
*&---------------------------------------------------------------------*
  call function 'DEQUEUE_EZ_ZFOLIO_PAGBCO'
    exporting
      mode_zfolio_pagobanco = 'E'
      mandt                 = sy-mandt
      bukrs                 = tabla_00-zbukr
      ubnkl                 = tabla_00-ubnkl
      codigo                = '001'.
*"----------------------------------------------------------------------
*& ** ASIGNA EL RESULTADO DE ARCHIVO GENERADO A PARAMETRO SALIDA FUNCION
*&---------------------------------------------------------------------*
  filesalida[] = file[].

ENDFUNCTION.
