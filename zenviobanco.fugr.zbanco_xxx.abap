*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *.
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
*& ** GENERACION DE ARCHIVOS DE BANCO CHILE (001) MARZO 2016
*&---------------------------------------------------------------------*
FUNCTION ZBANCO_XXX.
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
 DATA: rut(11)  TYPE c.
  DATA: largo(3) TYPE n.
  DATA: numero(10) TYPE n.

  DATA: desde(3) TYPE n.
  DATA: inicio(3) TYPE c.
  DATA: BEGIN OF t_items OCCURS 50,
       xauth(1)      TYPE c,                 " Berechtigung?
       xhell(1)      TYPE c.                 " Hell anzeigen?
        INCLUDE STRUCTURE rfpos.               " Listanzeigen-Struktur
DATA:  xbkpf(1)      TYPE c,                 " BKPF nachgelesen?
       xbseg(1)      TYPE c,                 " BSEG nachgelesen?
       xbsec(1)      TYPE c,                 " BSEC nachgelesen?
       xbsed(1)      TYPE c,                 " BSED nachgelesen?
       xpayr(1)      TYPE c,                 " PAYR nachgelesen?
       xbsegc(1)     TYPE c,                 " BSEGC nachgelesen?
       xbsbv(1)      TYPE c,                 " BSBV nachgelesen?
       xmod(1)       TYPE c,                 " POSTAB modifiziert?
      END OF t_items.
DATA: BEGIN OF t_doctos OCCURS 0,
        blart    LIKE bkpf-blart,
        belnr    LIKE bseg-belnr,  " docto
        bukrs    LIKE bseg-bukrs,  " sociedad
        gjahr    LIKE bseg-gjahr , " ejercicio
        dmbtr    LIKE bseg-dmbtr,  " $$ en MONEDA DOCUMENTO (HF)
        shkzg    LIKE bseg-shkzg,  " Indicador debe/haber
        qbshb    LIKE bseg-qbshb,  " $$retención en moneda docto
        zuonr    LIKE bseg-zuonr,  " Asignación
        bldat    LIKE bkpf-bldat,  " Fecha de documento en documento
        zfbdt    LIKE bseg-zfbdt,  " Fecha de Vencimiento
        zlsch    LIKE bseg-zlsch,  "via de pago HCD 20120424
END OF t_doctos.


  DATA: v_rut(10)     TYPE c,
          v_nomina  LIKE f110v-laufi,
        sumpago_aux(13) TYPE n,
        bukrs    LIKE bkpf-bukrs ,
        v_fecpag  type dats,
       f_rut(10)      TYPE c,
       "numero(10)      TYPE n,
       lineas(5)      TYPE n,
       monto_z(13),
       num_c(11)      TYPE c,
       folio_aux(15),
      " largo(05)      TYPE n,
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
v_fecpag = V_FECHA.
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
    bancoref = '016'.
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
*& ** DESBLOQUEA FOLIO DE SOCIEDAD BANCO CON FOLIO ACTUALIZADO
*&----------------------------------------------------------------------*
*-------- PREPARA SALIDA

  CLEAR   : reg_bci, t_items.
  REFRESH : t_doctos, t_doctos[], t_items[].

  reg_bci-zbukr = tabla_00-zbukr.

  TRANSLATE tabla_00-stcd1 USING '- ' .
  CONDENSE  tabla_00-stcd1 NO-GAPS    .

* Se ajusta Rut a la Izquierda.
  WRITE tabla_00-stcd1 TO reg_bci-rut_prov LEFT-JUSTIFIED.
  reg_bci-nombre           =  tabla_00-name1.


  TRANSLATE tabla_00-zstc1 USING '- ' .
  CONDENSE  tabla_00-zstc1 NO-GAPS    .

* Se ajusta Rut retirador a la Izquierda.
  WRITE tabla_00-zstc1 TO reg_bci-rut_ret LEFT-JUSTIFIED.
  reg_bci-nombre_ret           =  tabla_00-znme1 .


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE smtp_addr INTO reg_bci-mail FROM adr6 WHERE addrnumber = tabla_00-adrnr.
*
* NEW CODE
  SELECT smtp_addr
  UP TO 1 ROWS  INTO reg_bci-mail FROM adr6 WHERE addrnumber = tabla_00-adrnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  TRANSLATE   tabla_00-zbnkn USING '- '.
  CONDENSE    tabla_00-zbnkn NO-GAPS.
  CONDENSE    tabla_00-zbnkl NO-GAPS.

  reg_bci-cod_prov         =  tabla_00-lifnr.
  reg_bci-codigo_banco     =  tabla_00-zbnkl.
  reg_bci-cuenta_abono     =  tabla_00-zbnkn.
  reg_bci-docto_sap1       =  tabla_00-vblnr.




  IF tabla_00-rzawe = 'V'.
    reg_bci-codigo_banco = ''.
    reg_bci-cuenta_abono = ''.
  ENDIF.

  CLEAR reg_bci-mod_pago.

  IF tabla_00-rzawe  = 'V'.
      IF tabla_00-zbukr = 'CL13' or tabla_00-zbukr = 'CL17'. "HCD 20120424
          reg_bci-mod_pago  = 'EFE'.
          reg_bci-via_pago  = 'V'.
      ELSE.
          reg_bci-mod_pago  = 'VVC'.
      ENDIF.
          reg_bci-codigo_banco = 016.
          reg_bci-suc_retiro = 245.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE clave INTO p_clave
*                  FROM  zfitr001
*                  WHERE bankl = '016'
*                  AND   bkont = tabla_00-zbkon.
*
* NEW CODE
    SELECT clave
    UP TO 1 ROWS  INTO p_clave
                  FROM  zfitr001
                  WHERE bankl = '016'
                  AND   bkont = tabla_00-zbkon ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
      CONDENSE p_clave NO-GAPS.
      reg_bci-mod_pago = p_clave.
    ENDIF.
  ENDIF.

  IF  tabla_00-rzawe  = 'T'.
    IF reg_bci-codigo_banco <> 016.
      reg_bci-mod_pago  = 'OTC'.
    ENDIF.
    IF tabla_00-zbukr = 'CL13' or tabla_00-zbukr = 'CL17' or tabla_00-zbukr = 'CL27' or tabla_00-zbukr = 'CL28'." HCD 04-09-2020 agrego 27 y 28 HCD 20120424
      IF reg_bci-codigo_banco = 016 or reg_bci-codigo_banco = 509 or reg_bci-codigo_banco = 050.
        reg_bci-mod_pago  = 'CCT'.
      ENDIF.
    endif.
      reg_bci-via_pago  = 'T'.
  ENDIF.

  acreedor = tabla_00-lifnr.

v_nomina = NROTRA.
  IF tabla_00-zbukr <> tabla_00-absbu.  " Soc_pagadora y Soc.emisora


SELECT * FROM regup CLIENT SPECIFIED
WHERE mandt = sy-mandt
AND laufd = v_fecha
AND laufi = v_nomina
AND xvorl = ' '
AND lifnr = acreedor
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND vblnr = tabla_00-vblnr.
AND VBLNR = TABLA_00-VBLNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
      PERFORM paga_sociedad_1.
    ENDSELECT.


  ELSE..

*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  bseg
*              WHERE   bukrs   = tabla_00-zbukr
*              AND     belnr   = tabla_00-vblnr
*              AND     zfbdt   = tabla_00-zaldt              " ff 150306
*              AND     koart   = 'K'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  bseg
              WHERE   bukrs   = tabla_00-zbukr
              AND     belnr   = tabla_00-vblnr
              AND     zfbdt   = tabla_00-zaldt              " ff 150306
              AND     koart   = 'K' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0.
      eje_pago = bseg-gjahr.
    ENDIF.

***
    soc_pago = tabla_00-zbukr.
    doc_pago = tabla_00-vblnr.

    PERFORM paga_sociedad1.
  ENDIF.
 DESCRIBE TABLE tabla_00 LINES lins.

 REFRESH out_reg_bci_x.
  SORT reg_bci  BY zbukr rut_prov .





  LOOP AT reg_bci.

    out_reg_bci-mod_servico = 'G'.
    largo = STRLEN( reg_bci-rut_prov ).
    largo =  largo - 1.
    out_reg_bci-rut_prv_dvr = reg_bci-rut_prov+largo(1).
    out_reg_bci-rut_prv = reg_bci-rut_prov+0(largo).
    out_reg_bci-unidad = ''.
    out_reg_bci-nombre_prv = reg_bci-nombre.
    out_reg_bci-medio_aviso = 'E'.
    out_reg_bci-direc_aviso = reg_bci-mail.
    out_reg_bci-comuna_aviso = 0.

    out_reg_bci-forma_pago = reg_bci-mod_pago.

    out_reg_bci-cod_banco = reg_bci-codigo_banco.
    out_reg_bci-cuenta_cte = reg_bci-cuenta_abono.
    out_reg_bci-cod_sucursal = reg_bci-suc_retiro.
    IF reg_bci-monto_docto < 0.
      reg_bci-monto_docto = reg_bci-monto_docto * -1.
    ENDIF.

    IF reg_bci-mod_pago  = 'VVC'.
        CASE reg_bci-blart.
          WHEN 'F1' OR 'F2' OR 'F3' OR 'F4' OR 'F5' OR 'F6'.
            out_reg_bci-tipo_docto = 'FAC'.
          WHEN 'N1' OR 'N2' OR 'N3' OR 'N4'.
            out_reg_bci-tipo_docto = 'NCR'.
          WHEN 'D1' OR 'D2' OR 'D3' OR 'D4'.
            out_reg_bci-tipo_docto = 'NDB'.
          WHEN 'SA'.
             IF reg_bci-monto_docto < 0.
                out_reg_bci-tipo_docto = 'NCR'.
             ELSE.
                out_reg_bci-tipo_docto = 'FAC'.
             ENDIF.
        ENDCASE.
    ELSE." SE AGREGA 04-09-2020
        IF tabla_00-zbukr = 'CL13' or tabla_00-zbukr = 'CL17' or tabla_00-zbukr = 'CL27' or tabla_00-zbukr = 'CL28'.
            CASE reg_bci-blart.
              WHEN 'F1' OR 'F2' OR 'F3' OR 'F4' OR 'F5' OR 'F6'.
                out_reg_bci-tipo_docto = 'FAC'.
              WHEN 'N1' OR 'N2' OR 'N3' OR 'N4'.
                out_reg_bci-tipo_docto = 'NCR'.
              WHEN 'D1' OR 'D2' OR 'D3' OR 'D4'.
                out_reg_bci-tipo_docto = 'NDB'.
            ENDCASE.
        ELSE.
            out_reg_bci-tipo_docto = 'ABO'.
        ENDIF.
    ENDIF.


    out_reg_bci-nro_docto  = reg_bci-num_docto.


    out_reg_bci-nro_docto_rel = 0.
    out_reg_bci-valor_info = reg_bci-monto_docto.
    out_reg_bci-valor_pago = reg_bci-monto_docto.
    out_reg_bci-estado_pago = 'OK'.
    CONCATENATE v_fecpag+6(2) v_fecpag+4(2)   v_fecpag+0(4) INTO out_reg_bci-fecha_pago .
    CONCATENATE reg_bci-fecha_vcto+6(2) reg_bci-fecha_vcto+4(2)   reg_bci-fecha_vcto+0(4) INTO out_reg_bci-fecha_vcto.
    out_reg_bci-glosa = ''.

    largo = STRLEN( reg_bci-rut_prov ).
    IF largo > 0.
      largo =  largo - 1.
      out_reg_bci-rut_ret1_dvr = reg_bci-rut_ret+largo(1).
      out_reg_bci-rut_ret1     = reg_bci-rut_ret+0(largo).
      out_reg_bci-paterno1     = reg_bci-nombre_ret+0(15).
      out_reg_bci-materno1     = reg_bci-nombre_ret+14(15).
      out_reg_bci-nombre1      = reg_bci-nombre_ret+29(10).
    ELSE.
      out_reg_bci-rut_ret1 = 0.
      out_reg_bci-rut_ret1_dvr = ' '.
*      out_reg_bci-paterno1  = reg_bci-nombre_ret+0(15).
*      out_reg_bci-materno1  = reg_bci-nombre_ret+14(15).
*      out_reg_bci-nombre1   = reg_bci-nombre_ret+29(10).
      out_reg_bci-paterno1 = '               '.
      out_reg_bci-materno1 = '               '.
      out_reg_bci-nombre1  = '               '.
    ENDIF.

    out_reg_bci-rut_ret2   = 0.
    out_reg_bci-rut_ret2_dvr = ' '.
    out_reg_bci-paterno2   = '               '.
    out_reg_bci-materno2   = '               '.
    out_reg_bci-nombre2    = '               '.


*    if reg_bci-via_pago = 'T'. " Se agrega esta opcion para DAVILA Y SIS HCD 20120424
*      out_reg_bci-codigo = '00000000001'.
*    else.
*      out_reg_bci-codigo = '99900000001'.
*    endif.

*    append out_reg_bci.

 "*   PERFORM formateo.

  IF zfitr002-zmodser <> 0.
    desde = zfitr002-zmodser - 1.
    out_reg_bci_x-registro+desde(1) =  out_reg_bci-mod_servico.
  ENDIF.

  IF zfitr002-zrutpro <> 0.
    desde = zfitr002-zrutpro - 1.
    out_reg_bci_x-registro+desde(8) = out_reg_bci-rut_prv.
  ENDIF.

  IF zfitr002-zdrrpor <> 0.
    desde = zfitr002-zdrrpor - 1.
    out_reg_bci_x-registro+desde(1) = out_reg_bci-rut_prv_dvr.
  ENDIF.

  IF zfitr002-zunidad <> 0.
    desde = zfitr002-zunidad - 1.
    out_reg_bci_x-registro+desde(5) = out_reg_bci-unidad.
  ENDIF.

  IF zfitr002-znombre <> 0.
    desde = zfitr002-znombre - 1.
    out_reg_bci_x-registro+desde(45) = out_reg_bci-nombre_prv.
  ENDIF.

  IF zfitr002-zmedavi <> 0.
    desde = zfitr002-zmedavi - 1.
    out_reg_bci_x-registro+desde(1) = out_reg_bci-medio_aviso.
  ENDIF.

  IF zfitr002-zdiravi <> 0.
    desde = zfitr002-zdiravi - 1.
    out_reg_bci_x-registro+desde(35) = out_reg_bci-direc_aviso.
  ENDIF.

  IF zfitr002-zcodcom <> 0.
    desde = zfitr002-zcodcom - 1.
    out_reg_bci_x-registro+desde(4) = out_reg_bci-comuna_aviso.
  ENDIF.

  IF zfitr002-zforpag <> 0.
    desde = zfitr002-zforpag - 1.
    out_reg_bci_x-registro+desde(3) = out_reg_bci-forma_pago.
  ENDIF.

  IF   zfitr002-zcodbco <> 0.
    desde = zfitr002-zcodbco - 1.
    out_reg_bci_x-registro+desde(3) = out_reg_bci-cod_banco.
  ENDIF.

  IF  zfitr002-zctacte <> 0.
    desde = zfitr002-zctacte - 1.
    out_reg_bci_x-registro+desde(20) = out_reg_bci-cuenta_cte.
  ENDIF.

  IF zfitr002-zsuccta <> 0.
    desde = zfitr002-zsuccta - 1.
    out_reg_bci_x-registro+desde(3) = out_reg_bci-cod_sucursal.
  ENDIF.


  IF zfitr002-ztipdoc <> 0.
    desde = zfitr002-ztipdoc - 1.
    out_reg_bci_x-registro+desde(3) =  out_reg_bci-tipo_docto.
  ENDIF.

*  IF bukrs = 'CL27'.
*
*    IF zfitr002-znumdoc <> 0.
*      desde = zfitr002-znumdoc - 1.
*      out_reg_bci_x-registro+desde(10) =  out_reg_bci-nro_docto.
*    ENDIF.
*    IF zfitr002-zdocrel <> 0.
*      desde = zfitr002-zdocrel - 1.
*      out_reg_bci_x-registro+desde(10) =  out_reg_bci-nro_docto_rel.
*    ENDIF.
*    IF zfitr002-zmoninf <> 0.
*      desde = zfitr002-zmoninf - 1.
*      out_reg_bci_x-registro+desde(12) =  out_reg_bci-valor_info.
*    ENDIF.
*    IF zfitr002-zmonpag <> 0.
*      desde = zfitr002-zmonpag - 1.
*      out_reg_bci_x-registro+desde(12) =  out_reg_bci-valor_pago.
*    ENDIF.
*  ELSEIF bukrs = 'CL17' or  bukrs = 'CL13'.  " Se agrega esta opcion para DAVILA Y SIS HCD 20120424
*    out_reg_bci-nro_doctox = out_reg_bci-nro_docto.
*    out_reg_bci-nro_docto_relx = out_reg_bci-nro_docto_rel.
*    out_reg_bci-valor_infox = out_reg_bci-valor_info.
*    out_reg_bci-valor_pagox = out_reg_bci-valor_pago.
*
*    IF zfitr002-znumdoc <> 0.
*      desde = zfitr002-znumdoc - 1.
*      out_reg_bci_x-registro+desde(11) =  out_reg_bci-codigo. " out_reg_bci-nro_doctox.
*    ENDIF.
*    IF zfitr002-zdocrel <> 0.
*      desde = zfitr002-zdocrel - 1.
*      out_reg_bci_x-registro+desde(12) =  out_reg_bci-nro_docto_relx.
*    ENDIF.
*    IF zfitr002-zmoninf <> 0.
*      desde = zfitr002-zmoninf - 1.
*      out_reg_bci_x-registro+desde(11) =  out_reg_bci-valor_infox.
*    ENDIF.
*    IF zfitr002-zmonpag <> 0.
*      desde = zfitr002-zmonpag - 1.
*      out_reg_bci_x-registro+desde(11) =  out_reg_bci-valor_pagox.
*    ENDIF.
*  ELSE.
*    out_reg_bci-nro_doctox = out_reg_bci-nro_docto.
*    out_reg_bci-nro_docto_relx = out_reg_bci-nro_docto_rel.
*    out_reg_bci-valor_infox = out_reg_bci-valor_info.
*    out_reg_bci-valor_pagox = out_reg_bci-valor_pago.
*
*    IF zfitr002-znumdoc <> 0.
*      desde = zfitr002-znumdoc - 1.
*      out_reg_bci_x-registro+desde(12) =  out_reg_bci-nro_doctox.
*    ENDIF.
*    IF zfitr002-zdocrel <> 0.
*      desde = zfitr002-zdocrel - 1.
*      out_reg_bci_x-registro+desde(12) =  out_reg_bci-nro_docto_relx.
*    ENDIF.
*    IF zfitr002-zmoninf <> 0.
*      desde = zfitr002-zmoninf - 1.
*      out_reg_bci_x-registro+desde(11) =  out_reg_bci-valor_infox.
*    ENDIF.
*    IF zfitr002-zmonpag <> 0.
*      desde = zfitr002-zmonpag - 1.
*      out_reg_bci_x-registro+desde(11) =  out_reg_bci-valor_pagox.
*    ENDIF.
*  ENDIF.
*
*
*
*  IF zfitr002-zestpag <> 0.
*    desde = zfitr002-zestpag - 1.
*    out_reg_bci_x-registro+desde(3) =  out_reg_bci-estado_pago.
*  ENDIF.
*
*  IF zfitr002-zfecvct <> 0.
*    desde = zfitr002-zfecvct - 1.
*    out_reg_bci_x-registro+desde(8) =  out_reg_bci-fecha_vcto.
*  ENDIF.
*
*  IF zfitr002-zfecpag <> 0.
*    desde = zfitr002-zfecpag - 1.
*    out_reg_bci_x-registro+desde(8) =  out_reg_bci-fecha_pago.
*  ENDIF.
*
*  IF zfitr002-zglosa <> 0.
*    desde = zfitr002-zglosa - 1.
*    out_reg_bci_x-registro+desde(91) =  out_reg_bci-glosa(91).
*  ENDIF.
*
*  IF  zfitr002-zrutre1 <> 0.
*    desde = zfitr002-zrutre1 - 1.
*    out_reg_bci_x-registro+desde(8) =  out_reg_bci-rut_ret1.
*  ENDIF.
*
*  IF zfitr002-zdvrre1 <> 0.
*    desde = zfitr002-zdvrre1 - 1.
*    out_reg_bci_x-registro+desde(1) =  out_reg_bci-rut_ret1_dvr.
*  ENDIF.
*
*  IF zfitr002-zappre1 <> 0.
*    desde = zfitr002-zappre1 - 1.
*    out_reg_bci_x-registro+desde(15) =  out_reg_bci-paterno1.
*  ENDIF.
*
*  IF zfitr002-zapmre1 <> 0.
*    desde = zfitr002-zapmre1 - 1.
*    out_reg_bci_x-registro+desde(15) =  out_reg_bci-materno1.
*  ENDIF.
*
*  IF zfitr002-znomre1 <> 0.
*    desde = zfitr002-znomre1 - 1.
*    out_reg_bci_x-registro+desde(15) =  out_reg_bci-nombre1.
*  ENDIF.
*
*  IF zfitr002-zrutre2 <> 0.
*    desde = zfitr002-zrutre2 - 1.
*    out_reg_bci_x-registro+desde(8) =  out_reg_bci-rut_ret2.
*  ENDIF.
*
*  IF zfitr002-zdvrre2 <> 0.
*    desde = zfitr002-zdvrre2 - 1.
*    out_reg_bci_x-registro+desde(1) =  out_reg_bci-rut_ret2_dvr.
*  ENDIF.
*
*  IF zfitr002-zappre2 <> 0.
*    desde = zfitr002-zappre2 - 1.
*    out_reg_bci_x-registro+desde(15) =  out_reg_bci-paterno2.
*  ENDIF.
*
*  IF zfitr002-zapmre2 <> 0.
*    desde = zfitr002-zapmre2 - 1.
*    out_reg_bci_x-registro+desde(15) =  out_reg_bci-materno2.
*  ENDIF.
*
*  IF zfitr002-znomre2 <> 0.
*    desde = zfitr002-znomre2 - 1.
*    out_reg_bci_x-registro+desde(15) =  out_reg_bci-nombre2.
*  ENDIF.
*
*  out_reg_bci_x1-registro = out_reg_bci_x-registro+0(257).
*  APPEND out_reg_bci_x1.
*  APPEND out_reg_bci_x.
*
  ENDLOOP.
*IF bukrs = 'CL27'.
* filesalida[] = out_reg_bci_x1[].
*else.
*  filesalida[] = out_reg_bci_x[].
*endif.

ENDFUNCTION.


FORM distribucion_.
*----------------*
  SORT t_doctos16 BY dmbtr.

  LOOP AT t_doctos16.
*invertimos los signos para que el giro quede positivo !!!!!
    IF t_doctos16-shkzg = 'S'.    "Invertimos los signos.....
      t_doctos16-dmbtr = t_doctos16-dmbtr * -1.
    ENDIF.
    t_doctos16-dmbtr = t_doctos16-dmbtr * 100.
    t_doctos16-dmbtr = ABS( t_doctos16-dmbtr ).

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  bkpf
*         WHERE  bukrs  = t_doctos16-bukrs
*         AND    belnr  = t_doctos16-belnr
*         AND    gjahr  = t_doctos16-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  bkpf
         WHERE  bukrs  = t_doctos16-bukrs
         AND    belnr  = t_doctos16-belnr
         AND    gjahr  = t_doctos16-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0 AND bkpf-xblnr IS NOT INITIAL.
      CONDENSE bkpf-xblnr NO-GAPS.
      num_doc = bkpf-xblnr.
    ENDIF.


    if bkpf-blart   = 'SA' or bkpf-blart   = 'F7'.
      condense t_doctos16-zuonr no-gaps.
      num_doc = t_doctos16-zuonr.
      reg_bci-num_docto      = num_doc.
    endif.




    reg_bci-num_docto      = num_doc.


    IF t_doctos16-shkzg = 'S'.
      t_doctos16-dmbtr =   t_doctos16-dmbtr * -1.
      reg_bci-signo_docto   = '-'.
    ELSE.
      reg_bci-signo_docto  = '+'.
    ENDIF.


    reg_bci-monto_docto   = t_doctos16-dmbtr.
    reg_bci-docto_sap2    = t_doctos16-belnr.
    reg_bci-fecha_emision   =  t_doctos16-bldat.
    reg_bci-fecha_vcto   =  t_doctos16-zfbdt.
    reg_bci-blart =   t_doctos16-blart.

    APPEND reg_bci.
  ENDLOOP.
ENDFORM.                               " LLENA_ESTRUCTURA
FORM paga_sociedad1.
*-----------------*
  refresh t_doctos16.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM bsak CLIENT SPECIFIED
*          WHERE mandt   = sy-mandt
*            AND  bukrs  = soc_pago    " soc.pagadora
*            AND  augbl  = doc_pago    " Núm. doc.
*            AND  lifnr  = acreedor
*            AND  auggj  = eje_pago.   
*
* NEW CODE
  SELECT *
 FROM bsak CLIENT SPECIFIED
          WHERE mandt   = sy-mandt
            AND  bukrs  = soc_pago    " soc.pagadora
            AND  augbl  = doc_pago    " Núm. doc.
            AND  lifnr  = acreedor
            AND  auggj  = eje_pago ORDER BY PRIMARY KEY.   

* END. 07-07-2026 - ATC - ATC-03" ff 02.03.06

    CHECK bsak-augbl <>  bsak-belnr.
    MOVE-CORRESPONDING bsak TO t_doctos16.
    APPEND t_doctos16.
  ENDSELECT.

  PERFORM distribucion.

ENDFORM.                    "paga_sociedad
FORM paga_sociedad_1.

  refresh t_doctos16.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM bsak CLIENT SPECIFIED
*          WHERE mandt   = sy-mandt
*            AND  bukrs  = regup-bukrs    " soc.pagadora
*            AND  belnr  = regup-belnr    " Núm. doc.
*            AND  gjahr  = regup-gjahr
*            AND  buzei  = regup-buzei
*            AND  lifnr  = regup-lifnr.
*
* NEW CODE
  SELECT *
 FROM bsak CLIENT SPECIFIED
          WHERE mandt   = sy-mandt
            AND  bukrs  = regup-bukrs    " soc.pagadora
            AND  belnr  = regup-belnr    " Núm. doc.
            AND  gjahr  = regup-gjahr
            AND  buzei  = regup-buzei
            AND  lifnr  = regup-lifnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    CHECK bsak-augbl <>  bsak-belnr.
    MOVE-CORRESPONDING bsak TO t_doctos16.
**      el valor sera el total menos retencion
*        t_doctos-wrbtr = t_doctos-wrbtr - t_doctos-qbshb.
    APPEND t_doctos16.
  ENDSELECT.

  IF sy-subrc = 0.
    PERFORM distribucion_.
  ENDIF.

ENDFORM.                    " PAGA_SOCIEDAD_
