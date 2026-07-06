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
         ZFITR004,
         ZFITR004_EST,
         T012.

DATA : monto_total(13).

DATA : BEGIN OF REG01,
           cod_reg(01)          TYPE c,
           operacion(07)        TYPE n,
           rut_emp(10)          TYPE n,
           dig_emp(01)          TYPE c,
           nombre_emp(40)       type c,
           fecha_remes(08)      type n,
           ndocto(06)           type n,
           total(15)            type n,
           filler(249)          type c,
END OF REG01.

DATA : BEGIN OF REG02,
           cod_reg(01)          TYPE c,
           cod_prv(10)          TYPE n,
           rut_prv(10)          TYPE n,
           dig_prv(01)          TYPE c,
           nombre_prv(40)       type c,
           direccion(60)        type c,
           comuna(25)           type c,
           ciudad(25)           type c,
           pais(04)             type n,
           codigo_pos(10)       type c,
           casilla(40)          type c,
           telefono(15)         type c,
           fax(15)              type c,
           cod_banco(05)        type n value 0,
           cod_Sucursal(05)     type n value 0,
           cuenta_cte(20)       type c,
           tipo_docto(01)       type n,
           nro_docto(15)        type c,
           moneda_docto(03)     type n,
           Valor_pago(15)       type n,
           forma_pago(01)       type c,
           fecha_emision(08)    type n,
           fecha_vcto(08)       type n,
eND OF REG02.

DATA : BEGIN OF reg_stder OCCURS 0,
           zbukr(04)           type c ,
           rut_prov(11)        TYPE c ,
           cod_prov(10)        TYPE c ,
           nombre(40)          TYPE c ,
           suc_retiro(03)      TYPE n ,
           mod_pago(02)        TYPE c ,
           codigo_banco(03)    TYPE c ,
           cuenta_abono(18)    TYPE c ,
           docto_sap1(10)      type c,
           BLART(2)            type c,
           num_docto(10)       type c,
           fecha_emision(08)   type c,
           fecha_vcto(08)      type c,
           monto_docto(13)     TYPE p  decimals 0,
           signo_docto(01)     TYPE c ,
END OF reg_stder.

DATA : BEGIN OF out_reg_stder OCCURS 0,
           reg(337)           TYPE c ,
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
         registro(335) TYPE  c,
       END OF out_reg_bci_x.

DATA: BEGIN OF t_doctos OCCURS 0,
        BLART    like bkpf-BLART,
        belnr    LIKE bseg-belnr,  " docto
        bukrs    LIKE bseg-bukrs,  " sociedad
        gjahr    LIKE bseg-gjahr , " ejercicio
        dmbtr    LIKE bseg-dmbtr,  " $$ en MONEDA DOCUMENTO (HF)
        shkzg    LIKE bseg-shkzg,  " Indicador debe/haber
        qbshb    LIKE bseg-qbshb,  " $$retención en moneda docto
        zuonr    LIKE bseg-zuonr,  " Asignación
        bldat    LIKE bkpf-bldat,  " Fecha de documento en documento
        ZFBDT    LIKE bseg-ZFBDT,  " Fecha de Vencimiento
      END OF t_doctos.

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

DATA:  nombre1(25)          ,
       nombre2(25)          ,
       nombre3(25)          ,
       ndx(02)       TYPE n  ,
       lins(04)      TYPE c VALUE 0,
       num_doc(8)    TYPE c,
       archivo       LIKE rlgrap-filename value 'C:\TRANSFER\',
       FILL(4)       TYPE N,
       total         LIKE bseg-wrbtr,
       monto_p       like bseg-WRBT2,
       t_monto       LIKE bseg-dmbtr ,
       aux_prov      LIKE reguh-stcd1,
       SECUENCIA(03) TYPE N.

DATA : BEGIN OF INT_TABLA  OCCURS 1.
        INCLUDE STRUCTURE ZFITR004_EST.
DATA   END OF INT_TABLA.

DATA : BEGIN OF INT_TABLA1  OCCURS 1.
        INCLUDE STRUCTURE ZFITR004_EST.
DATA   END OF INT_TABLA1.

* Tablas Dynpro
CONTROLS: TABLA TYPE TABLEVIEW USING SCREEN 100.
CONTROLS: TABLA1 TYPE TABLEVIEW USING SCREEN 200.

DATA : BEGIN OF TAB OCCURS 0,
       FCODE LIKE RSMPE-FUNC,
END OF TAB.
