*&---------------------------------------------------------------------*
*&  Include           ZFITR045_NEW_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&     Programa que procesa datos de Sociedad, Banco y Nomina
*&---------------------------------------------------------------------*
*&     Definición de variabes y tablas internas
*&---------------------------------------------------------------------*
TABLES: reguh,
        regup,
        bseg,
        bsis,
        lfb1,
        t001,
        zctarechazobco,
        znovedadbanco,
        zfitr045_est_001,
        zfitr045_est_002.
TYPES: BEGIN OF novedad,
         mandante    TYPE mandt,
         sociedad(4) TYPE c,
         banco(15)   TYPE c,
         nomina(15)  TYPE n,
         fecha       TYPE dats,
         hora        TYPE tims,
         identif(15) TYPE c,
         numemp(10)  TYPE c,
         rutemi(9)   TYPE c,
         cuenta(18)  TYPE c,
         nomben(50)  TYPE c,
         rutben(9)   TYPE c,
         montow(15)  TYPE n,
         numche(9)   TYPE c,
         estpag(21)  TYPE c,
         cenpag(4)   TYPE n,
         fecrec      TYPE dats,
         numlot(3)   TYPE n,
         fecpro      TYPE dats,
         fecpag      TYPE dats,
         fecest      TYPE dats,
         estado(1)   TYPE c,
         ingres(10)  TYPE c,                      " Cambio PYV R01046
         vvmcad(1),
       END OF novedad.

TYPES: BEGIN OF rg,
         cod_mandt                 TYPE mandt,
         cod_sociedad(4)           TYPE c,
         cod_banco(15)             TYPE c,
         nomina(15)                TYPE n,
         fecha                     TYPE dats,
         hora                      TYPE tims,
         codigo_identificacion(15),
         numero_empresa(10)        TYPE c,
         rut_emisor(9),
         cuenta_cargo(18)          TYPE c,
         nombre_beneficiario(50),
         rut_beneficiario(9),
         monto(15)                 TYPE n,
         numero_cheque(9),
         estado_pago(21),
         centro_pago(4)            TYPE n,
         fecha_recepcion           TYPE dats,
         numero_lote(3)            TYPE n,
         fecha_proceso             LIKE sy-datum,
         fecha_pago                TYPE dats,
         fecha_estado              TYPE dats,
         estado(1),
         vvmcad(1),
       END OF rg.

TYPES: BEGIN OF reg1,
         estado_pago(21),
         cuenta_cargo(18)          TYPE c,
         numero_lote(3)            TYPE n,
         fecha_pago                TYPE dats,
         correl(5)                 TYPE n,
         codigo_identificacion(15),
         numero_empresa(10)        TYPE c,
         rut_emisor(9),
         nombre_beneficiario(50),
         rut_beneficiario(9),
         monto(15)                 TYPE p DECIMALS 0,
         numero_cheque(9),
         centro_pago(4)            TYPE n,
         fecha_recepcion           TYPE dats,
         fecha_estado              TYPE dats,
         estado(1),
         vvmcad(1),
         ingres(10)                TYPE c,    " Cambio PYV R01046
         ctacadmat(10)             TYPE c,
       END OF reg1.

TYPES: BEGIN OF reg2,                               " Cambio PYV R01061
         bukrs                     LIKE reguh-zbukr,       " Cambio PYV R01061
         belnr                     LIKE regup-vblnr,       " Cambio PYV R01061
         gjahr                     LIKE regup-gjahr,       " Cambio PYV R01061
         codigo_identificacion(15),                 " Cambio PYV R01061
       END OF reg2.                                 " Cambio PYV R01061

* ini Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte
TYPES: BEGIN OF ty_outtab.
         INCLUDE STRUCTURE zfitr045_est_001.
         TYPES:   linsel  TYPE numc05,
         celltab TYPE lvc_t_styl,
         color   TYPE lvc_t_scol,
         mensaje TYPE char50,
       END OF ty_outtab,
*
       BEGIN OF ty_tdep,
         estado_pago(21),
         cuenta_cargo(10) TYPE n,
         numero_lote(3)   TYPE n,
         fecha_recepcion  TYPE dats,
         correl(5)        TYPE n,
         secuencia(4)     TYPE n,
         hkont            LIKE  bsis-hkont,
         budat            LIKE  bsis-budat,
         belnr            LIKE  bsis-belnr,
         wrbtr            LIKE  bsis-wrbtr,
         shkzg            LIKE  bsis-shkzg,
         gjahr            LIKE  bsis-gjahr,
         estado(1),
         vvmcad(1),
       END OF ty_tdep.
* fin Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte
*
DATA p1(01)                  TYPE c VALUE '0'.
DATA oref                    TYPE REF TO cx_root.
DATA observacion(100).
DATA fecha_aux(08).
DATA cta_pagar               LIKE bseg-hkont VALUE '2011730046'.
DATA fec_estado              LIKE sy-datum.
DATA fill(4)                 TYPE n.
DATA cursorfield(50).
DATA sw_dato(1).
DATA subrc                   LIKE sy-subrc.
DATA monto_aux(15)           TYPE p DECIMALS 0.
DATA itab                    TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.
DATA titulo(30).
DATA: totalbco LIKE zfitr045_est_001-montopend.
DATA: totaldep LIKE zfitr045_est_001-montopend.
DATA: totalsel LIKE zfitr045_est_001-montopend.
DATA : nuevo(01),
       lineas(05)       TYPE n,
       tlineas(05)      TYPE n,
       filas(05)        TYPE n,
       lineas_dep(05)   TYPE n,
       fecha(08),
       fecha1(08),
       docpag(16),
       valor(15),
       total            LIKE regup-dmbtr,
       total_des        LIKE regup-dmbtr,
*      banco          LIKE bseg-hbkid,
       cuenta           LIKE bseg-hktid,
       gjahr            LIKE bkpf-gjahr,
       belnr            LIKE bkpf-belnr,
       largo(5)         TYPE n,
       cant_imp(6)      TYPE n,
       cuenta_cargo(10),
       asignacion(18),
       mensaje(100),
       bancopropio(5)   TYPE c,
       v_lineas         TYPE i,
       tipdoc(2)        TYPE c,                 " Cambio PYV R01046
       rut_aux(16),
       correlativo(5)   TYPE n.
DATA: messtab TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE.
DATA: w_mode.
DATA: tcode TYPE c LENGTH 10.
DATA: x_registros(16) TYPE n."hcd 20200421
DATA reg1x TYPE STANDARD TABLE OF reg1.
DATA reg2x TYPE STANDARD TABLE OF reg2.             " Cambio PYV R01061
DATA:  nov     TYPE  novedad OCCURS 0 WITH HEADER LINE.
DATA:  reg     TYPE  rg      OCCURS 0 WITH HEADER LINE.
DATA:  tdev    TYPE  reg1    OCCURS 0 WITH HEADER LINE.
DATA:  tdep    TYPE  ty_tdep OCCURS 0 WITH HEADER LINE. "WAJ 23-04-2020
DATA:  trec    TYPE  reg1    OCCURS 0 WITH HEADER LINE.
DATA:  tdevm   TYPE  reg1    OCCURS 0 WITH HEADER LINE.
DATA:  tredep  TYPE  reg1    OCCURS 0 WITH HEADER LINE.
DATA:  bsegx   TYPE  bseg    OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF tpro OCCURS 0,
        codigo_identificacion TYPE char15,
        rut_beneficiario      TYPE char9,
        estado_pago           TYPE char21,
        fecha_recepcion       TYPE char08,
        fecha_estado          TYPE char08,
        correl                TYPE numc05,
        belnr_dev             LIKE reguh-belnr_dev,
        gjahr_dev             LIKE reguh-gjahr_dev,
      END OF tpro.

DATA : BEGIN OF tcuenta  OCCURS 0,
         bukrs      LIKE  zctarechazobco-bukrs,
         rzawe      LIKE  zctarechazobco-rzawe,
         hkont_orig LIKE  zctarechazobco-hkont_orig,
         hkont_dest LIKE  zctarechazobco-hkont_dest,
         hbkid_dest LIKE  zctarechazobco-hbkid_dest,
         hktid_dest LIKE  zctarechazobco-hktid_dest,
       END OF tcuenta.

* ini Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte
*DATA : BEGIN OF tdep  OCCURS 0,
*         estado_pago(21),
*         cuenta_cargo(10) TYPE n,
*         numero_lote(3)   TYPE n,
*         fecha_recepcion  TYPE dats,
*         correl(5)        TYPE n,
*         secuencia(4)     TYPE n,
*         hkont            LIKE  bsis-hkont,
*         budat            LIKE  bsis-budat,
*         belnr            LIKE  bsis-belnr,
*         wrbtr            LIKE  bsis-wrbtr,
*         shkzg            LIKE  bsis-shkzg,
*         gjahr            LIKE  bsis-gjahr,
*         estado(1),
*         vvmcad(1),
*       END OF tdep.
* fin Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte
*
CONTROLS: tabla  TYPE TABLEVIEW USING SCREEN 100.
CONTROLS: tabla2 TYPE TABLEVIEW USING SCREEN 200.
CONTROLS: tabla3 TYPE TABLEVIEW USING SCREEN 250.
*
DATA cols  LIKE LINE OF tabla-cols.
DATA : BEGIN OF tab OCCURS 0,
         fcode LIKE rsmpe-func,
       END OF tab.

DATA : BEGIN OF int_tabla  OCCURS 1.
         INCLUDE STRUCTURE zfitr045_est_001.
       DATA   END OF int_tabla.

DATA : BEGIN OF int_tabla2  OCCURS 1.
         INCLUDE STRUCTURE zfitr045_est_002.
       DATA   END OF int_tabla2.

* ini Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS catch_hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING
        e_row_id
        e_column_id
        es_row_no.
    METHODS: catch_doubleclick
        FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
        e_column
        es_row_no
        sender.
ENDCLASS.
*
DATA: gt_outtab          TYPE ty_outtab OCCURS 0 WITH HEADER LINE,
      gs_outtab          TYPE ty_outtab,
      g_container        TYPE scrfname VALUE 'REPORTE',
      g_grid1            TYPE REF TO cl_gui_alv_grid,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      g_event_receiver   TYPE REF TO lcl_event_receiver,
      gt_fieldcat        TYPE lvc_t_fcat,
      gs_layout          TYPE lvc_s_layo,
      gt_exclude         TYPE ui_functions,
      gv_banka           TYPE banka,
      gv_error           TYPE text100,
      ok_code            LIKE sy-ucomm,
      gv_char10          TYPE char10,
      gv_char18          TYPE char18,
      save_ok            LIKE sy-ucomm.
*
CLASS lcl_event_receiver IMPLEMENTATION.
*
  METHOD catch_hotspot_click.
    DATA: ls_outtab TYPE ty_outtab,
          l_linsel  TYPE numc05.
*
    CHECK e_column_id-fieldname EQ 'SEL'.

    READ TABLE gt_outtab INTO ls_outtab INDEX es_row_no-row_id.
    IF ls_outtab-sel IS INITIAL.
      IF ls_outtab-montodif <> '0.00'.
        MESSAGE i004(zfi) WITH 'Existen diferencias en linea seleccionada'.
      ELSE.
        IF ls_outtab-montodev = '0.00' AND ls_outtab-montopend = '0.00'.
          MESSAGE i004(zfi) WITH 'Valores en cero en linea seleccionada'.
        ELSE.
          ls_outtab-sel = 'X'.
        ENDIF.
      ENDIF.
    ELSE.
      ls_outtab-sel     = ' '.
      ls_outtab-linsel  = ' '.
    ENDIF.
    MODIFY gt_outtab FROM ls_outtab INDEX es_row_no-row_id.
*
    LOOP AT gt_outtab INTO ls_outtab WHERE sel EQ 'X'.
      ADD 1 TO l_linsel.
      ls_outtab-linsel  = l_linsel.
      MODIFY gt_outtab FROM ls_outtab INDEX sy-tabix.
    ENDLOOP.
    IF l_linsel GE 480.
      gv_error = TEXT-adv.
    ELSE.
      CLEAR gv_error.
    ENDIF.
*
    CALL METHOD g_grid1->refresh_table_display.
  ENDMETHOD.
*
  METHOD catch_doubleclick.
    DATA: ls_outtab  TYPE ty_outtab,
          ls_celltab TYPE lvc_s_styl.
*
    CASE e_column-fieldname.
      WHEN 'MONTODEV'.
        READ TABLE gt_outtab INTO gs_outtab INDEX es_row_no-row_id.
        PERFORM muestra_montodev USING gs_outtab.
      WHEN 'MONTOPEND'.
        READ TABLE gt_outtab INTO gs_outtab INDEX es_row_no-row_id.
        PERFORM muestra_montopend USING gs_outtab.
      WHEN OTHERS.
        EXIT.
    ENDCASE.
*
    CALL METHOD sender->refresh_table_display.
  ENDMETHOD.
ENDCLASS.
* fin Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte
