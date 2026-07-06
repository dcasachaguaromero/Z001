*&---------------------------------------------------------------------*
*&  Include           ZPARTIDAS_ACREEDOR_TOP
*&---------------------------------------------------------------------*

REPORT zpartidas_acreedor NO STANDARD PAGE HEADING.

TABLES: bsak, reguh.

TABLES :
         bseg,    "  Segmento de documento de Contabilidad            02
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
         t001,
         bnka,    "  Maestro de banco                                 02
         bkpf.    "  Cabecera de documento para Contabilidad          02


RANGES: r_zbukr FOR payr-zbukr.
RANGES: r_hbkid FOR payr-hbkid.
RANGES: r_hktid FOR payr-hktid.
RANGES: r_rzawe FOR payr-rzawe.

DATA: zw_laufd LIKE payr-laufd.


DATA : BEGIN OF tabla_00 OCCURS 0.
        INCLUDE STRUCTURE reguh.
DATA : END OF tabla_00.

DATA : monto_total(13)                    ,
       total_proveedor LIKE tabla_00-rwbtr.

DATA : BEGIN OF t_bancos OCCURS 0     ,
         cod_ac      LIKE reguh-zbnkl ,
         cod_nw(03)  TYPE c           ,
       END OF t_bancos                .

DATA : BEGIN OF reg01,
           rut_emp(11)          TYPE c ,
           num_reg(10)          TYPE n,
           monto_total_pago(15) TYPE n,
           tipo_servicio(10)    TYPE c,
           fondos(30)           TYPE c,
           cheque(30)           TYPE c,
           descripcion(40)      TYPE c,
END OF reg01.
DATA : BEGIN OF reg11,
           rut_emp(11)          TYPE c ,
           num_reg(10)          TYPE n,
           monto_total_pago(15) TYPE n,
           tipo_servicio(10)    TYPE c,
           fondos(30)           TYPE c,
           cheque(30)           TYPE c,
           descripcion(40)      TYPE c,
END OF reg11.

DATA : BEGIN OF reg02,
           rut_prv(11)          TYPE c,
           nombre_prv(255)      TYPE c,
           mail(255)            TYPE c,
           medio_pago(30)       TYPE c,
           cod_banco(03)        TYPE c,
           tipo_cuenta_abo(15)  TYPE c,
           cuenta_abo(50)       TYPE c,
           fecha_pago(10)       TYPE c,
           reference(255)       TYPE c,
           referenceid(255)     TYPE c,
           monto_pago(15)       TYPE n,
           tipo_cuenta_car(15)  TYPE c,
           cuenta_car(50)       TYPE c,
           sucursal(3)          TYPE c,
           ref_cliente(40)      TYPE c,
           detalle_pago(300)    TYPE c,
END OF reg02.
DATA : BEGIN OF reg12,
           rut_prv(11)          TYPE c,
           nombre_prv(255)      TYPE c,
           mail(255)            TYPE c,
           medio_pago(30)       TYPE c,
           cod_banco(03)        TYPE c,
           tipo_cuenta_abo(15)  TYPE c,
           cuenta_abo(50)       TYPE c,
           fecha_pago(10)       TYPE c,
           reference(255)       TYPE c,
           referenceid(255)     TYPE c,
           monto_pago(15)       TYPE n,
           tipo_cuenta_car(15)  TYPE c,
           cuenta_car(50)       TYPE c,
           sucursal(3)          TYPE c,
           ref_cliente(40)      TYPE c,
           detalle_pago(300)    TYPE c,
END OF reg12.


DATA : BEGIN OF ctachile,
           cta(12)              TYPE c,
           filler(10)           TYPE c,
END OF ctachile.


DATA : BEGIN OF reg_stder OCCURS 0,
           zbukr(04)           TYPE c ,
           rut_prov(11)        TYPE c ,
           nombre(40)          TYPE c ,
           suc_retiro(03)      TYPE n ,
           mod_pago(30)        TYPE c ,
           tipo_cta(30)        TYPE c ,
           codigo_banco(03)    TYPE n ,
           cuenta_abono(18)    TYPE c ,
           num_docto(10)       TYPE n ,
           monto_docto(13)     TYPE p  DECIMALS 0,
           signo_docto(01)     TYPE c ,
           chect    LIKE payr-chect,
END OF reg_stder.

DATA : reg_stder_aux LIKE reg_stder.

DATA : BEGIN OF out_reg_stder OCCURS 0,
           reg(400)           TYPE c ,
       END OF out_reg_stder .

DATA: BEGIN OF t_doctos OCCURS 0,
        belnr    LIKE bseg-belnr,  " docto
        bukrs    LIKE bseg-bukrs,  " sociedad
        gjahr    LIKE bseg-gjahr , " ejercicio
        dmbtr    LIKE bseg-dmbtr,  " $$ en MONEDA DOCUMENTO (HF)
        shkzg    LIKE bseg-shkzg,  " Indicador debe/haber
        qbshb    LIKE bseg-qbshb,  " $$retención en moneda docto
        zuonr    LIKE bseg-zuonr,  " Asignación
        bldat    LIKE bkpf-bldat,  " Fecha de documento en documento
        zfbdt    LIKE bseg-zfbdt,  " Fecha de Vencimiento,
        chect    LIKE payr-chect,
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

DATA : n_monto(13) TYPE c          ,
       largo(02)   TYPE c VALUE 0  ,
       dv(01)      TYPE c          ,
       r1(11)      TYPE n          ,
       monto_x(15) TYPE c   VALUE 0 ,
       monto_y     LIKE bseg-dmbtr ,
       monto_z     LIKE bseg-dmbtr ,
       t_monto     LIKE bseg-dmbtr ,
       aux_prov    LIKE reguh-stcd1 ,
       soc_pago    LIKE reguh-zbukr ,   " soc.pagadora
       doc_pago    LIKE reguh-vblnr ,
       eje_pago    LIKE bseg-gjahr  ,
       acreedor    LIKE bsak-lifnr ,
       pos__       LIKE sy-tabix   ,
       monto_p     LIKE bseg-wrbtr ,
       prov        LIKE lfa1-lifnr ,
       p_clave(40) TYPE c.

FIELD-SYMBOLS : <nombre1_> TYPE ANY ,
                <nombre2_> TYPE ANY ,
                <nombre3_> TYPE ANY .

DATA:  nombre1(25)          ,
       nombre2(25)          ,
       nombre3(25)          ,
       ndx(02)      TYPE n  ,
       lins(04)     TYPE c VALUE 0,
       num_doc(8)   TYPE c  .

DATA: v_rut_ret(12).
DATA: v_nombre_ret(40).


DATA:    BEGIN OF tlaufk OCCURS 1.
        INCLUDE STRUCTURE ilaufk.
DATA:    END OF tlaufk.

DATA lt_dynpfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
DATA lv_dynpro_prog LIKE d020s-prog.

TYPES: BEGIN OF g_type_s_test,
         amount  TYPE i,
         repid   TYPE syrepid,
         display TYPE i,
         dynamic TYPE sap_bool,
       END OF g_type_s_test.

TYPES: BEGIN OF ty_s_outtab,
        zbukr LIKE reguh-zbukr,
        laufd LIKE reguh-laufd,
        laufi LIKE reguh-laufi,
        hbkid LIKE reguh-hbkid,
        hktid LIKE reguh-hktid,
        absbu LIKE reguh-absbu,
        monto_docto(13)     TYPE p  DECIMALS 0,
        cant  TYPE i,
        estatus(20) TYPE c,
        END OF ty_s_outtab.
TYPES: ty_t_outtab TYPE TABLE OF ty_s_outtab.

CONSTANTS: BEGIN OF gc_s_display,
             list       TYPE i VALUE 1,
             fullscreen TYPE i VALUE 2,
             grid       TYPE i VALUE 3,
           END   OF gc_s_display.

DATA: gs_test     TYPE g_type_s_test.
DATA  archivo     LIKE rlgrap-filename.
*data: gt_outtab type standard table of alv_t_t2.

DATA: gr_table   TYPE REF TO cl_salv_table.

DATA: gr_container TYPE REF TO cl_gui_custom_container.

DATA: g_okcode TYPE syucomm.

CLASS lcl_handle_events DEFINITION DEFERRED.

DATA: gr_handle_events TYPE REF TO lcl_handle_events.

DATA: gr_outtab            TYPE ty_s_outtab,
      gt_bsak              TYPE TABLE OF bsak WITH HEADER LINE,
      gt_outtab            TYPE ty_t_outtab,
      gs_outtab            TYPE ty_s_outtab,
      g_butxt              TYPE butxt,
      g_address_value      TYPE addr1_val,
      g_paval              TYPE paval,
      gt_zfigiro           TYPE TABLE OF zfigiro,
      ti_reguh             LIKE STANDARD TABLE OF reguh WITH HEADER LINE,
      gt_t012k             TYPE STANDARD TABLE OF t012k.

DATA itab TYPE ty_t_outtab.

*----------------------------------------------------------------------*
* SELECTION-SCREEN - for demonstration purposes only                   *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-008.
PARAMETERS:     p_bukrs TYPE bukrs        OBLIGATORY.
SELECT-OPTIONS  s_laufd FOR reguh-laufd   OBLIGATORY.
PARAMETERS:     p_hbkid LIKE t012k-hbkid  ,
                p_hktid TYPE hktid  .
SELECT-OPTIONS  s_rzawe FOR reguh-rzawe OBLIGATORY.
SELECTION-SCREEN END OF BLOCK block1.
