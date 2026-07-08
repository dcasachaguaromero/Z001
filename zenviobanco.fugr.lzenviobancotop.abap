FUNCTION-POOL zenviobanco.                  "MESSAGE-ID ..
TABLES: reguh,
        regup,
        bkpf,
        bsik,
        zfitr005,
        zfitr002,
        bsak,
        setleaf,
        znovedadbanco,
        ztd_pagobanco,
        zfolio_pagobanco,
        bseg,
        bsis,
        lfb1,
        t001,
        zctarechazo,
        zestadosbanco,
        zfitr011_est_001,
        zfitr011_est_002,
        adrc,
        zfolio_soc02.

TYPES: BEGIN OF texto037,
         todo(581) TYPE c,
       END OF texto037.

* ini - Waldo Alarcón - Visionone - 23-03-2022
TYPES : BEGIN OF ty_key_reguh,
          laufd	       TYPE laufd,
          laufi	       TYPE laufi,
          xvorl	       TYPE xvorl,
          zbukr	       TYPE dzbukr,
          lifnr	       TYPE lifnr,
          kunnr	       TYPE kunnr,
          empfg	       TYPE empfg,
          vblnr	       TYPE vblnr,
          identif_pago TYPE ze_identif_pago,
          ubnkl        TYPE ubnkl,
        END OF ty_key_reguh.
* fin - Waldo Alarcón - Visionone - 23-03-2022

DATA: nombre1(25)           ,
      nombre2(25)          ,
      nombre3(25)          ,
      ndx(02)     TYPE n,
      lins(04)    TYPE c VALUE 0,
      num_doc(8)  TYPE c,
      codigo(11)  TYPE c,
      fei_pago    LIKE reguh-laufd,
      ide_pago    LIKE reguh-laufi,
      soc_doct    LIKE reguh-zbukr,
      soc_pago    LIKE reguh-zbukr,
      doc_pago    LIKE reguh-vblnr,
      eje_pago    LIKE bseg-gjahr,
      acreedor    LIKE bsak-lifnr,
      pos__       LIKE sy-tabix,
      monto_p     LIKE bseg-wrbtr,
      prov        LIKE lfa1-lifnr,
      p_clave(40) TYPE c,
      adrnr       LIKE lfa1-adrnr.

DATA: BEGIN OF t_doctos16 OCCURS 0,
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
      END OF t_doctos16.

DATA : BEGIN OF reg_stder OCCURS 0,
         zbukr(04)         TYPE c,
         rut_prov(11)      TYPE c,
         cod_prov(10)      TYPE c,
         nombre(40)        TYPE c,
         mail(35)          TYPE c,
         suc_retiro(03)    TYPE n,
         mod_pago(03)      TYPE c,
         codigo_banco(03)  TYPE c,
         cuenta_abono(18)  TYPE c,
         docto_sap1(10)    TYPE c,
         fecha_emision(08) TYPE c,
         fecha_vcto(08)    TYPE c,
         blart(2)          TYPE c,
         num_docto(10)     TYPE n,
         monto_docto(10)   TYPE p  DECIMALS 0, " cambio de 13 a 10
         signo_docto(01)   TYPE c,
         docto_sap2(10)    TYPE c,
         rut_ret(11)       TYPE c,
         nombre_ret(40)    TYPE c,
         codigo(11)        TYPE c, "HCD 20120424
         via_pago(1)       TYPE c, "HCD 20120424
       END OF reg_stder.

" Cambio valor_info(12) a valor_info(10) valor_pago(12) a valor_pago(10) HCD 20120628
DATA : BEGIN OF out_reg_stder,
         mod_servico(1)     TYPE c,
         rut_prv(08)        TYPE n,
         rut_prv_dvr(01)    TYPE c,
         unidad(5)          TYPE c,
         nombre_prv(45)     TYPE c,
         medio_aviso(1)     TYPE c,
         direc_aviso(35)    TYPE c,
         comuna_aviso(4)    TYPE n,
         forma_pago(3)      TYPE c,
         cod_banco(03)      TYPE n,
         cuenta_cte(20)     TYPE n,
         cod_sucursal(03)   TYPE n,
         tipo_docto(03)     TYPE c,
         nro_docto(10)      TYPE n,
         nro_docto_rel(10)  TYPE n,
         valor_info(10)     TYPE n, " cambio de 12 a 10
         valor_pago(10)     TYPE n, " cambio de 12 a 10
         nro_doctox(12)     TYPE n,
         nro_docto_relx(12) TYPE n,
         valor_infox(10)    TYPE n, " cambio de 11 a 10
         valor_pagox(10)    TYPE n, " cambio de 11 a 10
         estado_pago(03)    TYPE c,
         fecha_vcto(08)     TYPE c,
         fecha_pago(8)      TYPE c,
         glosa(200)         TYPE c,
         rut_ret1(08)       TYPE n,
         rut_ret1_dvr(01)   TYPE c,
         paterno1(15)       TYPE c,
         materno1(15)       TYPE c,
         nombre1(15)        TYPE c,
         rut_ret2(08)       TYPE n,
         rut_ret2_dvr(01)   TYPE c,
         paterno2(15)       TYPE c,
         materno2(15)       TYPE c,
         nombre2(15)        TYPE c,
         codigo(11)         TYPE c, "HCD 20120424
       END OF out_reg_stder .


DATA : BEGIN OF out_reg_stder_x OCCURS 0,
         registro(505) TYPE  c,

       END OF out_reg_stder_x .

DATA : BEGIN OF out_reg_stder_x1 OCCURS 0,
         registro(257),
       END OF out_reg_stder_x1 .

DATA : BEGIN OF reg_bci OCCURS 0,
         zbukr(04)         TYPE c,
         rut_prov(11)      TYPE c,
         cod_prov(10)      TYPE c,
         nombre(40)        TYPE c,
         mail(35)          TYPE c,
         suc_retiro(03)    TYPE n,
         mod_pago(03)      TYPE c,
         codigo_banco(03)  TYPE c,
         cuenta_abono(18)  TYPE c,
         docto_sap1(10)    TYPE c,
         fecha_emision(08) TYPE c,
         fecha_vcto(08)    TYPE c,
         blart(2)          TYPE c,
         num_docto(10)     TYPE n,
         monto_docto(10)   TYPE p  DECIMALS 0, " cambio de 13 a 10
         signo_docto(01)   TYPE c,
         docto_sap2(10)    TYPE c,
         rut_ret(11)       TYPE c,
         nombre_ret(40)    TYPE c,
         codigo(11)        TYPE c, "HCD 20120424
         via_pago(1)       TYPE c, "HCD 20120424
         fecha_f110(08)    TYPE c,
* ini - Waldo Alarcón - Visionone - 23-03-2022
         key_reguh         TYPE ty_key_reguh,
* fin - Waldo Alarcón - Visionone - 23-03-2022
       END OF reg_bci.

* ini - Waldo Alarcón - Visionone - 16-11-2022
DATA : gv_proceso_ws TYPE char01.
* fin - Waldo Alarcón - Visionone - 16-11-2022

DATA : BEGIN OF out_reg_bci,
         mod_servico(1)    TYPE c,
         rut_prv(08)       TYPE n,
         rut_prv_dvr(01)   TYPE c,
         unidad(5)         TYPE c,
         nombre_prv(45)    TYPE c,
         medio_aviso(1)    TYPE c,
         direc_aviso(35)   TYPE c,
         comuna_aviso(4)   TYPE n,
         forma_pago(3)     TYPE c,
         cod_banco(03)     TYPE n,
         cuenta_cte(20)    TYPE n,
         cod_sucursal(03)  TYPE n,
         tipo_docto(03)    TYPE c,
         nro_docto(12)     TYPE n,
         nro_docto_rel(12) TYPE n,
         valor_info(11)    TYPE n, " cambio de 12 a 10
         valor_pago(11)    TYPE n, " cambio de 12 a 10
         estado_pago(03)   TYPE c,
         fecha_vcto(08)    TYPE c,
         fecha_pago(8)     TYPE c,
         glosa(30)         TYPE c,
         rut_ret1(08)      TYPE n,
         rut_ret1_dvr(01)  TYPE c,
         paterno1(15)      TYPE c,
         materno1(15)      TYPE c,
         nombre1(15)       TYPE c,
         rut_ret2(08)      TYPE n,
         rut_ret2_dvr(01)  TYPE c,
         paterno2(15)      TYPE c,
         materno2(15)      TYPE c,
         nombre2(15)       TYPE c,
       END OF out_reg_bci.


DATA : BEGIN OF out_reg_bci_x OCCURS 0,
         registro(335) TYPE  c,
       END OF out_reg_bci_x.
