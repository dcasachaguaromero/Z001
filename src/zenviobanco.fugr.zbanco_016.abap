*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: VisionOne            *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *.
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
*& ** GENERACION DE ARCHIVOS DE BANCO CHILE (001) MARZO 2016
*&---------------------------------------------------------------------*
FUNCTION zbanco_016.
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
*"     REFERENCE(CONFIRMING) TYPE  CHAR01 OPTIONAL
*"     REFERENCE(PROCESO_WS) TYPE  CHAR01 OPTIONAL
*"     REFERENCE(RET_VV) TYPE  CHAR1
*"  TABLES
*"      TABLA_00 STRUCTURE  REGUH
*"      FILESALIDA
*"      TI_OUT_REG_BCI OPTIONAL
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
          xauth(1)  TYPE c,                 " Berechtigung?
          xhell(1)  TYPE c.                 " Hell anzeigen?
          INCLUDE STRUCTURE rfpos.               " Listanzeigen-Struktur

          DATA:  xbkpf(1)  TYPE c,                 " BKPF nachgelesen?
          xbseg(1)  TYPE c,                 " BSEG nachgelesen?
          xbsec(1)  TYPE c,                 " BSEC nachgelesen?
          xbsed(1)  TYPE c,                 " BSED nachgelesen?
          xpayr(1)  TYPE c,                 " PAYR nachgelesen?
          xbsegc(1) TYPE c,                 " BSEGC nachgelesen?
          xbsbv(1)  TYPE c,                 " BSBV nachgelesen?
          xmod(1)   TYPE c,                 " POSTAB modifiziert?
        END OF t_items.

  DATA: BEGIN OF t_doctos OCCURS 0,
          blart LIKE bkpf-blart,
          belnr LIKE bseg-belnr,  " docto
          bukrs LIKE bseg-bukrs,  " sociedad
          gjahr LIKE bseg-gjahr , " ejercicio
          dmbtr LIKE bseg-dmbtr,  " $$ en MONEDA DOCUMENTO (HF)
          shkzg LIKE bseg-shkzg,  " Indicador debe/haber
          qbshb LIKE bseg-qbshb,  " $$retención en moneda docto
          zuonr LIKE bseg-zuonr,  " Asignación
          bldat LIKE bkpf-bldat,  " Fecha de documento en documento
          zfbdt LIKE bseg-zfbdt,  " Fecha de Vencimiento
          zlsch LIKE bseg-zlsch,  "via de pago HCD 20120424
        END OF t_doctos.

  DATA: v_rut(10)        TYPE c,
        v_nomina         LIKE f110v-laufi,
        v_fec_nomi       LIKE f110v-laufd,
        sumpago_aux(13)  TYPE n,
        bukrs            LIKE bkpf-bukrs,
** INI V1 RVY 17-05-23
        v_NUM_pago       LIKE BKPF-BELNR,
        v_prim_reg(1)    TYPE n,
** FIN V1 RVY 17-05-23
        v_fecpag         TYPE dats,
        f_rut(10)        TYPE c,
        "numero(10)      TYPE n,
        lineas(5)        TYPE n,
        monto_z(13),
        num_c(11)        TYPE c,
        folio_aux(15),
        " largo(05)      TYPE n,
        largo1(05)       TYPE n,
        f_adrnr          TYPE adrc-addrnumber,
        v_adrnr          TYPE adrc-addrnumber,
        dv(1)            TYPE c,
        v_mail           TYPE adr6-smtp_addr,
        v_ct(20)         TYPE c,
        v_cta            TYPE zfitr005-zctacte,
        v_vta            TYPE zfitr005-zctavta,
        v_cla            TYPE zfitr005-zclavemis,
        v_doc(16)        TYPE c,
        tipdoc(4)        TYPE c,
        td(1)            TYPE c,
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
        v_rutn(8)        TYPE c,
        v_rutd(1)        TYPE c,
        v_apellidop(15)  TYPE c,
        v_apellidom(15)  TYPE c,
        v_nombres(15)    TYPE c,
        v_rutn2(8)       TYPE c,
        v_rutd2(1)       TYPE c,
        v_apellidop2(15) TYPE c,
        v_apellidom2(15) TYPE c,
        v_nombres2(15)   TYPE c,
        V_glosa_red(25)  TYPE c,
        v_flag.

  DATA : BEGIN OF file OCCURS 0,
           linea(610) TYPE c.
  DATA : END OF file.

  DATA: ti_exc LIKE zfitr005 OCCURS 0 WITH HEADER LINE.

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

  DATA: ti_adrc        TYPE adrc OCCURS 0 WITH HEADER LINE,
        ti_set_fac     LIKE setleaf    OCCURS 0 WITH HEADER LINE,
        ti_set_ncr     LIKE setleaf    OCCURS 0 WITH HEADER LINE,
        tiposdoc       TYPE ztd_pagobanco OCCURS 0 WITH HEADER LINE,
* Ini - Waldo Alarcón - Visionone - 09-07-2022
        lt_out_reg_bci LIKE TABLE OF out_reg_bci,
        lt_reg_bci_fac LIKE TABLE OF reg_bci,
        lt_reg_bci     LIKE TABLE OF reg_bci,
        wa_reg_bci     LIKE reg_bci,
        wa_tabla_00    TYPE reguh,
        lr_blart       TYPE RANGE OF blart.
* Fin - Waldo Alarcón - Visionone - 09-07-2022
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
           ti_set_ncr,
* Ini - Waldo Alarcón - Visionone - 09-07-2022
           lt_out_reg_bci.
  gv_proceso_ws = proceso_ws.
* Fin - Waldo Alarcón - Visionone - 09-07-2022
*&---------------------------------------------------------------------------
*&   PREPARA REGISTRO DE PAGOS
*&---------------------------------------------------------------------------
  REFRESH reg01.

  REFRESH: ti_adrc, file.

  SORT tabla_00 .
  READ TABLE tabla_00 INDEX 1.
  v_fecpag = v_fecha.

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

* Ini - Waldo Alarcón - Visionone - 09-07-2022
*&---------------------------------------------------------------------*
*& ** BLOQUEO Y RECUPERA FOLIO DE SOCIEDAD BANCO
*&----------------------------------------------------------------------
  IF proceso_ws EQ 'X'.

    wa_tabla_00  = tabla_00.
    CALL FUNCTION 'ENQUEUE_EZ_ZFOLIO_PAGBCO'
      EXPORTING
        mode_zfolio_pagobanco = 'E'
        mandt                 = sy-mandt
        bukrs                 = wa_tabla_00-zbukr
        ubnkl                 = wa_tabla_00-ubnkl
        codigo                = '001'.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *  FROM zfolio_pagobanco  WHERE bukrs  = wa_tabla_00-zbukr
*                                              AND ubnkl  = wa_tabla_00-ubnkl
*                                              AND codigo = '001'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS   FROM zfolio_pagobanco  WHERE bukrs  = wa_tabla_00-zbukr
                                              AND ubnkl  = wa_tabla_00-ubnkl
                                              AND codigo = '001' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc <> 0.
      zfolio_pagobanco-bukrs = wa_tabla_00-zbukr.
      zfolio_pagobanco-codigo ='001'.
      zfolio_pagobanco-folio = 0.
    ENDIF.
  ENDIF.
* Fin - Waldo Alarcón - Visionone - 09-07-2022

*&---------------------------------------------------------------------*
*& ** DESBLOQUEA FOLIO DE SOCIEDAD BANCO CON FOLIO ACTUALIZADO
*&----------------------------------------------------------------------*
*-------- PREPARA SALIDA

  CLEAR   : reg_bci, t_items.
  REFRESH : t_doctos, t_doctos[], t_items[].

  DATA(lv_zbukr) = tabla_00-zbukr.
  v_fec_nomi     = tabla_00-laufd.
  v_nomina       = tabla_00-laufi.

  LOOP AT tabla_00.
    CLEAR   : reg_bci.

    reg_bci-zbukr =  lv_zbukr.
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

** V1 RVY 06-05-2024
    IF RET_VV = ' '.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*       SELECT SINGLE smtp_addr INTO reg_bci-mail FROM adr6 WHERE addrnumber = tabla_00-adrnr.
*
* NEW CODE
       SELECT smtp_addr
       UP TO 1 ROWS  INTO reg_bci-mail FROM adr6 WHERE addrnumber = tabla_00-adrnr ORDER BY PRIMARY KEY.

       ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ELSE.
       reg_bci-mail = ' '.
    ENDIF.
** V1 RVY 06-05-2024

    TRANSLATE   tabla_00-zbnkn USING '- '.
    CONDENSE    tabla_00-zbnkn NO-GAPS.
    CONDENSE    tabla_00-zbnkl NO-GAPS.

    reg_bci-cod_prov         =  tabla_00-lifnr.
    reg_bci-codigo_banco     =  tabla_00-zbnkl.
    reg_bci-cuenta_abono     =  tabla_00-zbnkn.
    reg_bci-docto_sap1       =  tabla_00-vblnr.
    reg_bci-fecha_f110       =  tabla_00-laufd.

    IF tabla_00-rzawe = 'V'.
*      reg_bci-codigo_banco = ''.
      reg_bci-codigo_banco = '016'.
      reg_bci-cuenta_abono = ''.
    ENDIF.
    "INI HCD 13032023 Se agrega codigo de sucursal para vespucio
    CASE wa_tabla_00-zbukr.
* V1 INI RVY 12-08-2024
*      WHEN 'CL27' OR 'CL28'.
      WHEN 'CL27' OR 'CL28'.
        IF tabla_00-rzawe = 'V'.
          reg_bci-suc_retiro = '103'.
        ENDIF.
     WHEN 'CL02' OR 'CL50'.
        IF tabla_00-rzawe = 'V'.
          reg_bci-suc_retiro = '120'.
        ENDIF.
* V1 INI RVY 09-06-2025
     WHEN 'CL29' OR 'CL30'.
        IF tabla_00-rzawe = 'V'.
          reg_bci-suc_retiro = '245'.
        ENDIF.
* V1 FIN RVY 09-06-2025
     WHEN OTHERS.
        reg_bci-suc_retiro = ''.
    ENDCASE.
    "FIN HCD 13032023 Se agrega codigo de sucursal para vespucio
    CLEAR reg_bci-mod_pago.

** V1 INI RVY 12-07-2024
    IF RET_VV = 'X'.
       reg_bci-suc_retiro = '400'.
    endif.
** V1 FIN RVY 12-07-2024

    IF tabla_00-rzawe  = 'V'.
      reg_bci-mod_pago  = 'VVC'.
    ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE clave INTO p_clave
*                    FROM  zfitr001
*                    WHERE bankl = '016'
*                    AND   bkont = tabla_00-zbkon.
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

    IF tabla_00-rzawe  = 'T'.
      IF reg_bci-codigo_banco <> 016.
        reg_bci-mod_pago  = 'OTC'.
      ELSE.
        reg_bci-mod_pago  = 'CCT'.
      ENDIF.
    ENDIF.

    acreedor = tabla_00-lifnr.

* ini - Waldo Alarcón - Visionone - 23-03-2022
    MOVE-CORRESPONDING tabla_00 TO reg_bci-key_reguh.
* fin - Waldo Alarcón - Visionone - 23-03-2022

*    v_nomina = nrotra.
    IF tabla_00-zbukr <> tabla_00-absbu.  " Soc_pagadora y Soc.emisora
      SELECT * FROM regup CLIENT SPECIFIED
               WHERE mandt = sy-mandt
               AND laufd = v_fec_nomi
               AND laufi = v_nomina
               AND xvorl = ' '
               AND lifnr = acreedor
               AND vblnr = tabla_00-vblnr ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*V1 INI RVY 27-08.24
*        PERFORM paga_sociedad_ .
       IF tabla_00-waers = 'CLP'.
          PERFORM paga_sociedad_ .
       ELSE.
          PERFORM paga_sociedad__ME.
       ENDIF.
*V1 FIN RVY 27-08-24
      ENDSELECT.
    ELSE..

*** buscamos ejercicio del docto de pago
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM  bseg
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
      fei_pago = tabla_00-laufd.
      ide_pago = tabla_00-laufi.
      soc_pago = tabla_00-zbukr.
      doc_pago = tabla_00-vblnr.
      soc_doct = tabla_00-zbukr.
*V1 INI RVY 27-08-24
*     PERFORM paga_sociedad.*
      IF tabla_00-waers = 'CLP'.
         PERFORM paga_sociedad.
      ELSE.
         PERFORM paga_sociedad_ME.
      ENDIF.
*V1 FIN  RVY
    ENDIF.

  ENDLOOP.

  DESCRIBE TABLE tabla_00 LINES lins.

  REFRESH out_reg_bci_x.
  SORT reg_bci  BY zbukr rut_prov .

* Ini - Waldo Alarcón - Visionone - 09-07-2022
  IF proceso_ws EQ 'X'.
* ACUMULA LAS FACYURAS PARA LUEGO VERIFICAR SI EXISTEN NC O ND ASOCIADAS A ELLAS.
    lr_blart = VALUE #( sign = 'I' option = 'EQ'
                        ( low = 'F1')
                        ( low = 'F2')
                        ( low = 'F3')
                        ( low = 'F4')
                        ( low = 'F5')
                        ( low = 'F6')
                        ( low = 'F0')
                        ( low = 'F8')
                        ( low = 'F9')
                        ( low = 'FA')
                        ( low = 'FB')
                        ( low = 'FC')
                        ( low = 'FR')
                         ).
* PROCESA ACUMULCION DE DOCUMENTOS.
** BEG V1 RVY 10.05.2023                         ).
*    LOOP AT reg_bci INTO wa_reg_bci WHERE blart IN lr_blart.
*      CLEAR :  wa_reg_bci-signo_docto, wa_reg_bci-docto_sap2, wa_reg_bci-fecha_emision, wa_reg_bci-fecha_vcto.
*      wa_reg_bci-blart      = 'F3'.
*      wa_reg_bci-docto_sap2 = wa_reg_bci-num_docto.
*      COLLECT wa_reg_bci INTO lt_reg_bci_fac.
*    ENDLOOP.
** END V1 RVY 10.05.2023
* PROCESA ACUMULCION DE DOCUMENTOS.
    SORT reg_bci  BY zbukr rut_prov docto_sap1 ASCENDING signo_docto DESCENDING.
    LOOP AT reg_bci INTO wa_reg_bci.
* Para FAC, NDB y NCR se mantienes los datos y distinto sera luego ABO, limpiando los datos.
      CLEAR :  wa_reg_bci-signo_docto, wa_reg_bci-docto_sap2, wa_reg_bci-fecha_emision, wa_reg_bci-fecha_vcto.

      CASE wa_reg_bci-blart.
        WHEN 'F1' OR 'F2' OR 'F3' OR 'F4' OR 'F5' OR 'F6' OR
             'F0' OR 'F8' OR 'F9' OR 'FA' OR 'FB' OR
             'FC' OR 'FR'.
*           'FAC'.
          wa_reg_bci-blart      = 'F3'.
          wa_reg_bci-docto_sap2 = wa_reg_bci-num_docto.
          COLLECT wa_reg_bci INTO lt_reg_bci.
        WHEN 'N1' OR 'N2' OR 'N3' OR 'N4' OR
             'N0' OR 'NA' OR 'NB' OR 'NC' OR 'NR' OR
*
             'D1' OR 'D2' OR 'D3' OR 'D4' OR
             'DA' OR 'DG' OR 'DP' OR 'DR' OR 'DY' OR 'DZ'.
* VERIFICA SI LA NC O ND TIENE UNA FACTURA ASOCIADA, PARA DEJAR LOS DATOS DE ESTA EN LA ACUMULACION.
          DATA(lv_index) = line_index( lt_reg_bci_fac[ rut_prov   = wa_reg_bci-rut_prov
                                                       cod_prov   = wa_reg_bci-cod_prov
                                                       docto_sap1 = wa_reg_bci-docto_sap1 ] ).
          IF lv_index GT 0.
            wa_reg_bci-blart      = 'F3'.
            wa_reg_bci-num_docto  = lt_reg_bci_fac[ lv_index ]-num_docto.
            wa_reg_bci-docto_sap2 = lt_reg_bci_fac[ lv_index ]-num_docto.
            COLLECT wa_reg_bci INTO lt_reg_bci.
            LOOP AT lt_reg_bci_fac INTO DATA(lw_reg_bci_fac) WHERE rut_prov   EQ wa_reg_bci-rut_prov
                                                              AND  cod_prov   EQ wa_reg_bci-cod_prov
                                                              AND  docto_sap1 EQ wa_reg_bci-docto_sap1.
              wa_reg_bci-blart        = 'F3'.
              wa_reg_bci-monto_docto  = lw_reg_bci_fac-monto_docto.
              wa_reg_bci-num_docto    = lt_reg_bci_fac[ lv_index ]-num_docto.
              wa_reg_bci-docto_sap2   = lt_reg_bci_fac[ lv_index ]-num_docto.
              COLLECT wa_reg_bci INTO lt_reg_bci.

              DELETE reg_bci WHERE rut_prov   = lw_reg_bci_fac-rut_prov   AND
                                   cod_prov   = lw_reg_bci_fac-cod_prov   AND
                                   docto_sap1 = lw_reg_bci_fac-docto_sap1 AND
                                   num_docto  = lw_reg_bci_fac-num_docto.
            ENDLOOP.
          ELSE.
            wa_reg_bci-docto_sap2 = wa_reg_bci-num_docto.
            COLLECT wa_reg_bci INTO lt_reg_bci.
          ENDIF.
        WHEN OTHERS.
          CLEAR : wa_reg_bci-blart, wa_reg_bci-num_docto.
          COLLECT wa_reg_bci INTO lt_reg_bci.
      ENDCASE.
    ENDLOOP.
*
    REFRESH reg_bci. CLEAR reg_bci.
    v_prim_reg = 0.
    LOOP AT lt_reg_bci INTO wa_reg_bci.
*
      IF wa_reg_bci-key_reguh-identif_pago IS INITIAL.
** INI V1 RVY 17-05-2023
         if v_prim_reg = 0.
            v_num_pago = wa_reg_bci-Docto_sap1.
            v_prim_reg = 1.
            zfolio_pagobanco-folio =  zfolio_pagobanco-folio + 1.
            CONCATENATE wa_reg_bci-zbukr wa_reg_bci-key_reguh-ubnkl zfolio_pagobanco-folio+3(8) INTO folio_aux .
            IF tippro = 'X'.
               MODIFY  zfolio_pagobanco.
            ENDIF.
         else.
            if wa_reg_bci-Docto_sap1 <> v_num_pago.
               zfolio_pagobanco-folio =  zfolio_pagobanco-folio + 1.
               CONCATENATE wa_reg_bci-zbukr wa_reg_bci-key_reguh-ubnkl zfolio_pagobanco-folio+3(8) INTO folio_aux .
               IF tippro = 'X'.
                  MODIFY  zfolio_pagobanco.
               ENDIF.
               v_num_pago = wa_reg_bci-Docto_sap1.
            endif.
         endif.
** FIN V1 RVY 17-05-2023
      ELSE.
        CLEAR folio_aux.
        MOVE wa_reg_bci-key_reguh-identif_pago TO folio_aux.
      ENDIF.

      wa_reg_bci-num_docto = folio_aux.

      APPEND wa_reg_bci TO reg_bci.
*
      MOVE-CORRESPONDING wa_reg_bci-key_reguh TO tabla_00.

      IF tippro = 'X'.
         v_Glosa_red = ' '.
*         IF tabla_00-zbukr = 'CL01' OR tabla_00-zbukr = 'CL25'.
            IF RET_VV = 'X'.
*              v_Glosa_red = 'CAMPAÑA_ROJA'.
               v_Glosa_red = 'RETIRO POR UN 3ERO'.
            endif.
*         endif.

         UPDATE reguh SET : identif_pago   = folio_aux
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
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'DEQUEUE_EZ_ZFOLIO_PAGBCO'
      EXPORTING
        mode_zfolio_pagobanco = 'E'
        mandt                 = sy-mandt
        bukrs                 = wa_tabla_00-zbukr
        ubnkl                 = wa_tabla_00-ubnkl
        codigo                = '001'.
  ENDIF.
* Fin - Waldo Alarcón - Visionone - 09-07-2022

  LOOP AT reg_bci.

    out_reg_bci-mod_servico  = confirming. "'G'.  WALDO ALARCON - VISIONONE - ASIGNACION 564
    largo                    = strlen( reg_bci-rut_prov ).
    largo                    = largo - 1.
    out_reg_bci-rut_prv_dvr  = reg_bci-rut_prov+largo(1).
    out_reg_bci-rut_prv      = reg_bci-rut_prov+0(largo).
    out_reg_bci-unidad       = ''.
    out_reg_bci-nombre_prv   = reg_bci-nombre.
    out_reg_bci-medio_aviso  = 'E'.
*Ini V1 RVY 16-08-2024
    IF RET_VV = 'X'.
       out_reg_bci-medio_aviso  = ' '.
    ENDIF.
*Fin V1 RVY 16-08-2024
    out_reg_bci-direc_aviso  = reg_bci-mail.
    out_reg_bci-comuna_aviso = 0.
    out_reg_bci-forma_pago   = reg_bci-mod_pago.
    out_reg_bci-cod_banco    = reg_bci-codigo_banco.
    out_reg_bci-cuenta_cte   = reg_bci-cuenta_abono.
    out_reg_bci-cod_sucursal = reg_bci-suc_retiro.
** INI RVY 26-04-2022
*   IF reg_bci-monto_docto < 0.
*     reg_bci-monto_docto = reg_bci-monto_docto * -1.
*   ENDIF.
** FIN RVY 26-04-2022
** INI RVY 27-05-2022
    CASE reg_bci-blart.
      WHEN 'F1' OR 'F2' OR 'F3' OR 'F4' OR 'F5' OR 'F6' OR
           'F0' OR 'F8' OR 'F9' OR 'FA' OR 'FB' OR
           'FC' OR 'FR'.
        out_reg_bci-tipo_docto = 'FAC'.
      WHEN 'N1' OR 'N2' OR 'N3' OR 'N4' OR
           'N0' OR 'NA' OR 'NB' OR 'NC' OR 'NR'.
        out_reg_bci-tipo_docto = 'NCR'.
      WHEN 'D1' OR 'D2' OR 'D3' OR 'D4' OR
           'DA' OR 'DG' OR 'DP' OR 'DR' OR 'DY' OR 'DZ'.
        out_reg_bci-tipo_docto = 'NDB'.
      WHEN 'SA' OR 'F7' OR 'RH'.
        IF reg_bci-monto_docto < 0.
*Ini V1 RVY 16-08-2024
         out_reg_bci-tipo_docto = 'DES'.
*          out_reg_bci-tipo_docto = 'ABO'.
*Fin V1 RVY 16-08-2024
        ELSE.
*Ini V1 RVY 16-08-2024
         out_reg_bci-tipo_docto = 'ABO'.
*           out_reg_bci-tipo_docto = 'DES'.
*Fin V1 RVY 16-08-2024
        ENDIF.
      WHEN 'B1' OR 'B2' OR 'B3' OR 'B4' OR 'B5' OR 'B6'.
        out_reg_bci-tipo_docto = 'ABO'.
      WHEN 'AB'.
        out_reg_bci-tipo_docto = 'FAC'.
* Ini - Waldo Alarcón - Visionone - 09-07-2022
      WHEN OTHERS.
        IF proceso_ws EQ 'X'.
          out_reg_bci-tipo_docto = 'ABO'.
        ENDIF.
* Fin - Waldo Alarcón - Visionone - 09-07-2022
    ENDCASE.
** FIN RVY 27-05-2022

* INI RVY 26-04-2022
    IF reg_bci-monto_docto < 0.
      reg_bci-monto_docto = reg_bci-monto_docto * -1.
    ENDIF.
* FIN RVY 26-04-2022

* ini - Waldo Alarcón - Visionone - 16-11-2022
    CASE gv_proceso_ws.
      WHEN 'X'.
        out_reg_bci-nro_docto      = |{ reg_bci-num_docto  ALPHA = OUT }|.
        out_reg_bci-nro_docto_rel  = |{ reg_bci-docto_sap2 ALPHA = OUT }|.
      WHEN OTHERS.
        out_reg_bci-nro_docto     = reg_bci-num_docto.
        out_reg_bci-nro_docto_rel = 0.
    ENDCASE.
* fin - Waldo Alarcón - Visionone - 16-11-2022

    out_reg_bci-valor_info    = reg_bci-monto_docto.
    out_reg_bci-valor_pago    = reg_bci-monto_docto.
    out_reg_bci-estado_pago   = 'OK'.
*    CONCATENATE v_fecpag+6(2) v_fecpag+4(2)   v_fecpag+0(4) INTO out_reg_bci-fecha_pago .
*    CONCATENATE reg_bci-fecha_vcto+6(2) reg_bci-fecha_vcto+4(2)   reg_bci-fecha_vcto+0(4) INTO out_reg_bci-fecha_vcto.
*    CONCATENATE v_fecpag+6(2)           v_fecpag+4(2)           v_fecpag+0(4)           INTO out_reg_bci-fecha_vcto.
*    CONCATENATE reg_bci-fecha_vcto+6(2) reg_bci-fecha_vcto+4(2) reg_bci-fecha_vcto+0(4) INTO out_reg_bci-fecha_pago.
    CONCATENATE v_fecpag+6(2)           v_fecpag+4(2)           v_fecpag+0(4)           INTO out_reg_bci-fecha_pago.
*    CONCATENATE reg_bci-fecha_vcto+6(2) reg_bci-fecha_vcto+4(2) reg_bci-fecha_vcto+0(4) INTO out_reg_bci-fecha_vcto.
    CONCATENATE reg_bci-fecha_f110+6(2) reg_bci-fecha_f110+4(2) reg_bci-fecha_f110+0(4) INTO out_reg_bci-fecha_vcto.

    out_reg_bci-glosa         = ''.

    largo = strlen( reg_bci-rut_prov ).
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

    IF RET_VV = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*       SELECT SINGLE rutn rutd apellidop apellidom nombres
*                     rutn2 rutd2 apellidop2 apellidom2 nombres2
*            FROM ZFITR026
*            INTO (v_rutn, v_rutd, v_apellidoP, V_apellidom, v_nombres,
*                  v_rutn2, v_rutd2, v_apellidoP2, V_apellidom2, v_nombres2)
*            WHERE bukrs = reg_bci-Zbukr AND
*                  BANKS = 'CL'          AND
*                  BANKL = '016'.
*
* NEW CODE
       SELECT rutn rutd apellidop apellidom nombres
                     rutn2 rutd2 apellidop2 apellidom2 nombres2
       UP TO 1 ROWS 
            FROM ZFITR026
            INTO (v_rutn, v_rutd, v_apellidoP, V_apellidom, v_nombres,
                  v_rutn2, v_rutd2, v_apellidoP2, V_apellidom2, v_nombres2)
            WHERE bukrs = reg_bci-Zbukr AND
                  BANKS = 'CL'          AND
                  BANKL = '016' ORDER BY PRIMARY KEY.

       ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
       out_reg_bci-rut_ret1_dvr = v_rutd.
       out_reg_bci-rut_ret1     = v_rutn.
       out_reg_bci-paterno1     = v_apellidoP.
       out_reg_bci-materno1     = v_apellidoM.
       out_reg_bci-nombre1      = v_nombres.
       out_reg_bci-rut_ret2_dvr = v_rutd2.
       out_reg_bci-rut_ret2     = v_rutn2.
       out_reg_bci-paterno2     = v_apellidoP2.
       out_reg_bci-materno2     = v_apellidoM2.
       out_reg_bci-nombre2      = v_nombres2.
       out_reg_bci-cod_sucursal = '400'.
    else.
       out_reg_bci-rut_ret2   = 0.
       out_reg_bci-rut_ret2_dvr = ' '.
       out_reg_bci-paterno2   = '               '.
       out_reg_bci-materno2   = '               '.
       out_reg_bci-nombre2    = '               '.
    endif.
* ini - Waldo Alarcón - Visionone - 17-01-2023
    IF gv_proceso_ws EQ 'X'.
      PERFORM actualiza_texto CHANGING out_reg_bci-nombre_prv.
      PERFORM actualiza_texto CHANGING out_reg_bci-paterno1.
      PERFORM actualiza_texto CHANGING out_reg_bci-paterno2.
      PERFORM actualiza_texto CHANGING out_reg_bci-materno1.
      PERFORM actualiza_texto CHANGING out_reg_bci-materno2.
      PERFORM actualiza_texto CHANGING out_reg_bci-nombre1.
      PERFORM actualiza_texto CHANGING out_reg_bci-nombre2.
    ENDIF.
* fin - Waldo Alarcón - Visionone - 17-01-2023

    out_reg_bci_x = out_reg_bci.
    APPEND out_reg_bci_x.

* Ini - Waldo Alarcón - Visionone - 09-07-2022
    APPEND out_reg_bci TO lt_out_reg_bci.
* Fin - Waldo Alarcón - Visionone - 09-07-2022
  ENDLOOP.

  filesalida[] = out_reg_bci_x[].
* Ini - Waldo Alarcón - Visionone - 09-07-2022
  ti_out_reg_bci[] = lt_out_reg_bci[].
* Fin - Waldo Alarcón - Visionone - 09-07-2022
ENDFUNCTION.


FORM distribucion.
*----------------*
  SORT t_doctos16 BY dmbtr.

  LOOP AT t_doctos16.
*invertimos los signos para que el giro quede positivo !!!!!
    IF t_doctos16-shkzg = 'S'.    "Invertimos los signos.....
      t_doctos16-dmbtr = t_doctos16-dmbtr * -1.
    ENDIF.
    t_doctos16-dmbtr = t_doctos16-dmbtr * 100.
    t_doctos16-dmbtr = abs( t_doctos16-dmbtr ).

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

    IF bkpf-blart   = 'SA' OR bkpf-blart   = 'F7' OR bkpf-blart   = 'RH'.
      CONDENSE t_doctos16-zuonr NO-GAPS.
      num_doc = t_doctos16-zuonr.
      reg_bci-num_docto      = num_doc.
    ENDIF.

    reg_bci-num_docto      = num_doc.

    IF t_doctos16-shkzg = 'S'.
      t_doctos16-dmbtr =   t_doctos16-dmbtr * -1.
      reg_bci-signo_docto   = '-'.
    ELSE.
      reg_bci-signo_docto  = '+'.
    ENDIF.

    reg_bci-monto_docto   = t_doctos16-dmbtr.
    reg_bci-docto_sap2    = t_doctos16-belnr.
    reg_bci-fecha_emision = t_doctos16-bldat.
    reg_bci-fecha_vcto    = t_doctos16-zfbdt.
    reg_bci-blart         = t_doctos16-blart.

    APPEND reg_bci.
  ENDLOOP.
ENDFORM.                               " LLENA_ESTRUCTURA

FORM paga_sociedad .
*-----------------*
  REFRESH t_doctos16.
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

  PERFORM distribucion .

ENDFORM.                    "paga_sociedad

*v1 INI RVY 27-08.24
FORM paga_sociedad_ME.
*--------------------*
  REFRESH t_doctos16.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM REGUP CLIENT SPECIFIED
*          WHERE mandt   = sy-mandt
*            AND  LAUFD  = fei_pago
*            AND  LAUFI  = ide_pago
*            AND  BUKRS  = soc_pago
*            AND  VBLNR  = doc_pago.
*
* NEW CODE
  SELECT *
 FROM REGUP CLIENT SPECIFIED
          WHERE mandt   = sy-mandt
            AND  LAUFD  = fei_pago
            AND  LAUFI  = ide_pago
            AND  BUKRS  = soc_pago
            AND  VBLNR  = doc_pago ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    MOVE-CORRESPONDING REGUP TO t_doctos16.
    t_doctos16-dmbtr = regup-dmbtr + regup-gdiff.
    APPEND t_doctos16.
  ENDSELECT.

  PERFORM distribucion .

ENDFORM.                    "paga_sociedad

FORM paga_sociedad__ME.
*-----------------*
  REFRESH t_doctos16.
  MOVE-CORRESPONDING REGUP TO t_doctos16.
  t_doctos16-dmbtr = regup-dmbtr + regup-gdiff.
  APPEND t_doctos16.

  PERFORM distribucion .

ENDFORM.                    "paga_sociedad
*v1 FIN RVY 27-08.24

FORM paga_sociedad_ .

  REFRESH t_doctos16.

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
    PERFORM distribucion .
  ENDIF.

ENDFORM.                    " PAGA_SOCIEDAD_

FORM actualiza_texto CHANGING p_texto.

  CHECK p_texto IS NOT INITIAL.
  REPLACE ALL OCCURRENCES OF 'Ñ'  IN p_texto WITH 'N'.
  REPLACE ALL OCCURRENCES OF 'ñ'  IN p_texto WITH 'n'.
  REPLACE ALL OCCURRENCES OF '?'  IN p_texto WITH 'N'.
  REPLACE ALL OCCURRENCES OF '¿'  IN p_texto WITH 'N'.
  REPLACE ALL OCCURRENCES OF 'Á'  IN p_texto WITH 'A'.
  REPLACE ALL OCCURRENCES OF 'É'  IN p_texto WITH 'E'.
  REPLACE ALL OCCURRENCES OF 'Í'  IN p_texto WITH 'I'.
  REPLACE ALL OCCURRENCES OF 'Ó'  IN p_texto WITH 'O'.
  REPLACE ALL OCCURRENCES OF 'Ú'  IN p_texto WITH 'U'.
  REPLACE ALL OCCURRENCES OF 'á'  IN p_texto WITH 'a'.
  REPLACE ALL OCCURRENCES OF 'é'  IN p_texto WITH 'e'.
  REPLACE ALL OCCURRENCES OF 'í'  IN p_texto WITH 'i'.
  REPLACE ALL OCCURRENCES OF 'ó'  IN p_texto WITH 'o'.
  REPLACE ALL OCCURRENCES OF 'ú'  IN p_texto WITH 'u'.
  REPLACE ALL OCCURRENCES OF '''' IN p_texto WITH ''.
  REPLACE ALL OCCURRENCES OF '"'  IN p_texto WITH ''.

" HCD   20230428 INI Funcion que elimina caracteres especiales
  call function 'SCP_REPLACE_STRANGE_CHARS'
  exporting
    INTEXT = p_texto
  importing
  OUTTEXT = p_texto.
" HCD   20230428 FIN
ENDFORM.
