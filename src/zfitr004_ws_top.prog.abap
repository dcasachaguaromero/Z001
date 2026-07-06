*&---------------------------------------------------------------------*
*&  Include           ZFITR004_TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Tablas usadas.
*----------------------------------------------------------------------*
TABLES : reguh,   "  Datos de pago del programa de pagos              02
         bseg,    "  Segmento de documento de Contabilidad            02
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
         t001,
         bnka,    "  Maestro de banco                                 02
         bsik,    "  índice secundario para acreedores (part.comp.)   02
         bkpf,    "  Cabecera de documento para Contabilidad          02
         zfitr004,
         zfitr004_est,
         t012.

DATA : monto_total(13).

DATA : BEGIN OF reg01,
         cod_reg(01)     TYPE c,
         operacion(07)   TYPE n,
         rut_emp(10)     TYPE n,
         dig_emp(01)     TYPE c,
         nombre_emp(40)  TYPE c,
         fecha_remes(08) TYPE n,
         ndocto(06)      TYPE n,
         total(15)       TYPE n,
         filler(249)     TYPE c,
       END OF reg01.

DATA : BEGIN OF reg02,
         cod_reg(01)       TYPE c,
         cod_prv(10)       TYPE n,
         rut_prv(10)       TYPE n,
         dig_prv(01)       TYPE c,
         nombre_prv(40)    TYPE c,
         direccion(60)     TYPE c,
         comuna(25)        TYPE c,
         ciudad(25)        TYPE c,
         pais(04)          TYPE n,
         codigo_pos(10)    TYPE c,
         casilla(40)       TYPE c,
         telefono(15)      TYPE c,
         fax(15)           TYPE c,
         cod_banco(05)     TYPE n VALUE 0,
         cod_sucursal(05)  TYPE n VALUE 0,
         cuenta_cte(20)    TYPE c,
         tipo_docto(01)    TYPE n,
         nro_docto(15)     TYPE c,
         moneda_docto(03)  TYPE n,
         valor_pago(15)    TYPE n,
         forma_pago(01)    TYPE c,
         fecha_emision(08) TYPE n,
         fecha_vcto(08)    TYPE n,
       END OF reg02.

DATA : BEGIN OF reg_stder OCCURS 0,
         zbukr(04)         TYPE c,
         rut_prov(11)      TYPE c,
         cod_prov(10)      TYPE c,
         nombre(40)        TYPE c,
         suc_retiro(03)    TYPE n,
         mod_pago(02)      TYPE c,
         codigo_banco(03)  TYPE c,
         cuenta_abono(18)  TYPE c,
         docto_sap1(10)    TYPE c,
         blart(2)          TYPE c,
         num_docto(10)     TYPE c,
         fecha_emision(08) TYPE c,
         fecha_vcto(08)    TYPE c,
         monto_docto(13)   TYPE p  DECIMALS 0,
         signo_docto(01)   TYPE c,
       END OF reg_stder.

DATA : BEGIN OF out_reg_stder OCCURS 0,
         reg(337) TYPE c,
       END OF out_reg_stder .

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
       END OF out_reg_bci .

DATA : BEGIN OF out_reg_bci_x OCCURS 0,
         registro(640) TYPE  c,
       END OF out_reg_bci_x.

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
      END OF t_doctos.

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

DATA: nombre1(25)           ,
      nombre2(25)          ,
      nombre3(25)          ,
      ndx(02)       TYPE n,
      lins(04)      TYPE c VALUE 0,
      num_doc(8)    TYPE c,
      archivo       LIKE rlgrap-filename VALUE 'C:\TRANSFER\',
      fill(4)       TYPE n,
      total         LIKE bseg-wrbtr,
      monto_p       LIKE bseg-wrbt2,
      t_monto       LIKE bseg-dmbtr,
      aux_prov      LIKE reguh-stcd1,
      secuencia(03) TYPE n.

DATA : BEGIN OF int_tabla  OCCURS 1.
         INCLUDE STRUCTURE zfitr004_est.
       DATA   END OF int_tabla.

DATA : BEGIN OF int_tabla1  OCCURS 1.
         INCLUDE STRUCTURE zfitr004_est.
       DATA   END OF int_tabla1.

* Tablas Dynpro
CONTROLS: tabla TYPE TABLEVIEW USING SCREEN 100.
CONTROLS: tabla1 TYPE TABLEVIEW USING SCREEN 200.

DATA : BEGIN OF tab OCCURS 0,
         fcode LIKE rsmpe-func,
       END OF tab.

DATA : p_bankl TYPE t012-bankl.
DATA : archivo_s(130)   TYPE c.

DATA : BEGIN OF wa_sociedad,
         bukrs  TYPE bukrs,
         stcd1  TYPE stcd1,
         puerto TYPE  char060,
       END OF wa_sociedad,
       BEGIN OF wa_selec,
         datum     TYPE datum,
         uname     TYPE syuname,
         convenio  TYPE zfitr016-convenio,
         tipo_pago TYPE zfitr016-tipo_pago,
       END OF wa_selec,
       gt_salida       TYPE TABLE OF zfi_log_ws,
       wa_zfitr016     TYPE zfitr016,
       gt_list         TYPE vrm_values,
       gt_convenio     TYPE vrm_values,
       gt_tipo_pago    TYPE vrm_values,
       gv_secuencia    TYPE numc2,
       gv_contabilizar TYPE char01,
       gv_repid        TYPE syrepid,
       gr_fac          TYPE RANGE OF bkpf-blart,
       gr_ncr          TYPE RANGE OF bkpf-blart,
       gr_proceso      TYPE RANGE OF char10.

CONSTANTS: gc_banco TYPE c LENGTH 15 VALUE '016',
           gc_x     TYPE c LENGTH 01 VALUE 'X',
           gc_tabla TYPE c LENGTH 30 VALUE 'ZFI_LOG_WS'.

CLASS lcl_evt_handler DEFINITION.
  PUBLIC SECTION.
    METHODS: event_close FOR EVENT close OF cl_gui_dialogbox_container IMPORTING sender.
ENDCLASS.
