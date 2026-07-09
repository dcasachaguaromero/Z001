*&---------------------------------------------------------------------*
*& Report: ZFITR005_B_NEW                                              *
*& Author: VisionOne (Ramón Vasquez)                                   *
*& Description: Genera archivo de pagos para el banco Estado.          *
*&              Se toma como base el programa actual ZFITR005_B        *
*& Date: <04.10.2021                                                   *
*& Transport Number: < ECDK920938 >                                    *
*&---------------------------------------------------------------------*
REPORT zfitr005_b_new NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132 .
*----------------------------------------------------------------------*
* Tablas usadas.
*----------------------------------------------------------------------*
TABLES : reguh,   "  Datos de pago del programa de pagos              02
         regup,
         bseg,    "  Segmento de documento de Contabilidad            02
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
         adr6,
         t001,
         zfitr002,
         bnka,    "  Maestro de banco                                 02
         bsak,    "  índice secundario para acreedores (part.comp.)   02
         bkpf,    "  Cabecera de documento para Contabilidad          02
         zlog_pago_bancos. "HCD 20201006
INCLUDE zbatchinput_v2.

*-> BEG INS V1-CNN
TYPES: BEGIN OF lty_reg1,
         data TYPE c LENGTH 621,
         eol  TYPE c LENGTH 1,
       END OF lty_reg1,

       BEGIN OF lty_reg2,
         data TYPE c LENGTH 283,
         eol  TYPE c LENGTH 1,
       END OF lty_reg2,

       BEGIN OF lty_reg_stder_xx,
         linea TYPE string,
       END OF lty_reg_stder_xx.

DATA: ls_reg1         TYPE lty_reg1,
      ls_reg2         TYPE lty_reg2,
      ls_reg_stder_xx TYPE lty_reg_stder_xx.

DATA : BEGIN OF out_reg_stder_xx OCCURS 0,
         linea TYPE string,
       END OF out_reg_stder_xx.
*-> END INS V1-CNN


DATA: ti_adrc    TYPE adrc       OCCURS 0 WITH HEADER LINE,
      ti_set_fac LIKE setleaf    OCCURS 0 WITH HEADER LINE,
      ti_set_ncr LIKE setleaf    OCCURS 0 WITH HEADER LINE,
      ti_bsak    LIKE bsak       OCCURS 0 WITH HEADER LINE,
      ti_exc     LIKE zfitr005   OCCURS 0 WITH HEADER LINE,
      itab       TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.
"lt_dynpfields LIKE dynpread   OCCURS 1 WITH HEADER LINE.
DATA : BEGIN OF tabla_00 OCCURS 0.
         INCLUDE STRUCTURE reguh.
       DATA : END OF tabla_00 .

DATA : monto_total(13)                    ,
       total_proveedor LIKE tabla_00-rwbtr.

DATA : BEGIN OF t_bancos OCCURS 0     ,
         cod_ac     LIKE reguh-zbnkl,
         cod_nw(03) TYPE c,
       END OF t_bancos                .

DATA : BEGIN OF ctachile,
         cta(12)    TYPE c,
         filler(10) TYPE c,
       END OF ctachile.

" cambio monto_docto(13) por monto_docto(10) HCD 20120628
DATA : BEGIN OF reg_stder OCCURS 0,
         laufd(08)         TYPE c,
         laufi(06)         TYPE c,
         xvorl(01)         TYPE c,
         zbukr(04)         TYPE c,
         cod_prov(10)      TYPE c,
         cod_clie(10)      TYPE c,
         empfg(16)         TYPE c,
         docto_sap1(10)    TYPE c,
         absbu(04)         TYPE c,
         rut_prov(11)      TYPE c,
         nombre(40)        TYPE c,
         mail(35)          TYPE c,
         suc_retiro(03)    TYPE n,
         mod_pago(02)      TYPE c,
         codigo_banco(03)  TYPE c,
         cuenta_abono(18)  TYPE c,
         monto_pago(10)    TYPE n,
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

" Cambio valor_info(12) a valor_info(10) valor_pago(12) a valor_pago(10) HCD 20120628
DATA : BEGIN OF out_reg2_stder,
         relleno(1)       TYPE c,
         rut_prv(09)      TYPE n,
         rut_prv_dvr(01)  TYPE c,
         nombre_prv(60)   TYPE c,
         forma_pago(2)    TYPE n,
         cod_banco(03)    TYPE n,
         cuenta_cte(17)   TYPE n,
         monto(13)        TYPE n,
         email(40)        TYPE c,
         cod_empresa(15)  TYPE n,
         sucursal_bco(03) TYPE n,
         sector_fin(02)   TYPE n,
         glosa_vv(200)    TYPE c,
         glosa_1(27)      TYPE c,
         dato_1(08)       TYPE c,
         indicador_1(01)  TYPE c,
         glosa_2(27)      TYPE c,
         dato_2(08)       TYPE c,
         indicador_2(01)  TYPE c,
         glosa_3(27)      TYPE c,
         dato_3(08)       TYPE c,
         indicador_3(01)  TYPE c,
         glosa_4(27)      TYPE c,
         dato_4(08)       TYPE c,
         indicador_4(01)  TYPE c,
         glosa_5(27)      TYPE c,
         dato_5(08)       TYPE c,
         indicador_5(01)  TYPE c,
         glosa_6(27)      TYPE c,
         dato_6(08)       TYPE c,
         indicador_6(01)  TYPE c,
         glosa_7(27)      TYPE c,
         dato_7(08)       TYPE c,
         indicador_7(01)  TYPE c,
         cod_seg(03)      TYPE n,
       END OF out_reg2_stder.

DATA: BEGIN OF t_doctos2 OCCURS 0,
        relleno(1)     TYPE c,
        fecha_doc(08)  TYPE c,
        monto_doc(13)  TYPE n,
        numero_doc(10) TYPE c,
        tipo_doc(02)   TYPE n,
        glosa_doc(249) TYPE c,
      END OF t_doctos2.

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

DATA : n_monto(13)     TYPE c,
       largo(02)       TYPE c VALUE 0,
       dv(01)          TYPE c,
       r1(11)          TYPE n,
       monto_x(15)     TYPE c   VALUE 0,
       monto_y         LIKE bseg-dmbtr,
       monto_z         LIKE bseg-dmbtr,
       t_monto         LIKE bseg-dmbtr,
       aux_prov        LIKE reguh-stcd1,
       soc_pago        LIKE reguh-zbukr ,   " soc.pagadora
       doc_pago        LIKE reguh-vblnr,
       eje_pago        LIKE bseg-gjahr,
       acreedor        LIKE bsak-lifnr,
       pos__           LIKE sy-tabix,
       monto_p         LIKE bseg-wrbtr,
       prov            LIKE lfa1-lifnr,
       p_clave(40)     TYPE c,
       adrnr           LIKE lfa1-adrnr,
       cuenta          LIKE reguh-ubhkt, "HCD 05-10-2020
       cuenta_2        LIKE reguh-ubhkt, "HCD 05-10-2020
       cuenta5         LIKE reguh-ubhkt, "HCD 05-10-2020
       cuenta3         LIKE reguh-ubhkt, "HCD 05-10-2020
       secuencia(2)    TYPE n, "HCD 05-10-2020
       sumpagos(15)    TYPE n, "HCD 05-10-2020
       lineas(5)       TYPE n, "HCD 05-10-2020
       gjahr           LIKE bkpf-gjahr, "HCD 05-10-2020
       contar(6)       TYPE n, "HCD 05-10-2020
       zaldt           LIKE reguh-zaldt, "HCD 05-10-2020
       zzmot_emis      LIKE bseg-zzmot_emis, "HCD 05-10-2020
       contabilizar(1),       "HCD 05-10-2020
       resp(1),               "HCD 05-10-2020
       total           LIKE bseg-dmbtr, "HCD 05-10-2020
       xblnr           LIKE bkpf-xblnr, "HCD 05-10-2020
       bktxt           LIKE bkpf-bktxt, "HCD 05-10-2020
       zvalut          LIKE reguh-valut, "HCD 05-10-2020
       belnr           LIKE bkpf-belnr, "HCD 05-10-2020
       v_nrotra        LIKE  zlog_pago_bancos-nrotran, "HCD 05-10-2020
       codigo(11)      TYPE c. " Agrego variable codigo para proceso de CL13 CL17 HCD 20120424

FIELD-SYMBOLS : <nombre1_> TYPE any,
                <nombre2_> TYPE any,
                <nombre3_> TYPE any.

DATA: nombre1(25)           ,
      nombre2(25)          ,
      nombre3(25)          ,
      ndx(02)     TYPE n,
      lins(04)    TYPE c VALUE 0,
      num_doc(8)  TYPE c.
DATA: v_rut_ret(12).
DATA: v_nombre_ret(40).

DATA:    BEGIN OF tlaufk OCCURS 1.
           INCLUDE STRUCTURE ilaufk.
         DATA:    END OF tlaufk.

DATA lt_dynpfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
DATA lv_dynpro_prog LIKE d020s-prog.
DATA gv_gato TYPE c LENGTH 2 VALUE cl_abap_char_utilities=>form_feed.

*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE TEXT-001.
PARAMETERS: bukrs    LIKE bkpf-bukrs     OBLIGATORY,
            v_fecha  LIKE reguh-laufd    OBLIGATORY,
            v_nomina LIKE f110v-laufi    OBLIGATORY,
            v_fecpag LIKE reguh-laufd    OBLIGATORY.

PARAMETERS : archivo     LIKE rlgrap-filename DEFAULT 'C:\TRANSFER\'.

PARAMETERS : par_tes RADIOBUTTON GROUP test       " Ejecución en Test
                     DEFAULT 'X',
             par_di  RADIOBUTTON GROUP test.      " Ejecución real
** INI V1 08-01-23
SELECTION-SCREEN SKIP 1.
PARAMETERS :
             par_JUD AS CHECKBOX.
SELECTION-SCREEN SKIP 1.
** FIN V1 08-01-23
SELECTION-SCREEN END OF BLOCK marco1 .

*---------------------------------------------------------------------------------

AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo .
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = archivo.

AT SELECTION-SCREEN ON bukrs.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD bukrs.

  IF sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
    MESSAGE e526(icc_tr) WITH bukrs.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t001 WHERE bukrs = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM zfitr002 WHERE bukrs = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM zfitr002 WHERE bukrs = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Debe Definir Formato Para Sociedad' bukrs.

  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_fecha.

  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'BUKRS'.
  APPEND lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
  SORT lt_dynpfields .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
  READ TABLE lt_dynpfields INDEX 1.
  bukrs = lt_dynpfields-fieldvalue .
  TRANSLATE bukrs TO UPPER CASE.

  REFRESH tlaufk.
  tlaufk-laufk = space.
  tlaufk-sign  = 'I'.
  APPEND tlaufk.
  CALL FUNCTION 'ZF4_ZAHLLAUF'
    EXPORTING
      f1typ = 'D'
      f2nme = 'F110V-LAUFI'
      bukrs = bukrs
      banco = '012'
    IMPORTING
      laufd = v_fecha
      laufi = v_nomina
    TABLES
      laufk = tlaufk.

  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'V_NOMINA'.
  APPEND lt_dynpfields.

  lt_dynpfields-fieldname = 'ARCHIVO'.
  APPEND lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 1.
  lt_dynpfields-fieldvalue = v_nomina.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  SORT lt_dynpfields .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 1.

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 2.
  CONCATENATE 'C:\TRANSFER\' bukrs '_EST01' '_' sy-datum '_' sy-uzeit '.txt' INTO
  lt_dynpfields-fieldvalue.

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  SORT lt_dynpfields .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_nomina.

  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'BUKRS'.
  APPEND lt_dynpfields.


  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.


*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 1.
  bukrs = lt_dynpfields-fieldvalue .
  TRANSLATE bukrs TO UPPER CASE.

  REFRESH tlaufk.
  tlaufk-laufk = space.
  tlaufk-sign  = 'I'.
  APPEND tlaufk.
  CALL FUNCTION 'ZF4_ZAHLLAUF'
    EXPORTING
      f1typ = 'I'
      f2nme = 'F110V-LAUFD'
      bukrs = bukrs
      banco = '012'
    IMPORTING
      laufd = v_fecha
      laufi = v_nomina
    TABLES
      laufk = tlaufk.

  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'V_FECHA'.
  APPEND lt_dynpfields.
  lt_dynpfields-fieldname = 'ARCHIVO'.
  APPEND lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 1.
  CONCATENATE v_fecha+06(2) '.' v_fecha+04(2) '.' v_fecha+0(4) INTO lt_dynpfields-fieldvalue.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  SORT lt_dynpfields .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 1.

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 2.
  CONCATENATE 'C:\TRANSFER\' bukrs '_EST01' '_' sy-datum '_' sy-uzeit '.txt' INTO
   lt_dynpfields-fieldvalue.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  SORT lt_dynpfields .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

INITIALIZATION.

  CONCATENATE archivo 'EST01' '_' sy-datum '_' sy-uzeit '.txt' INTO
  archivo.
  CONDENSE archivo NO-GAPS.

START-OF-SELECTION.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM reguh
*                 WHERE laufd       = v_fecha
*                 AND   laufi       = v_nomina
*                 AND   zbukr       = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM reguh
                 WHERE laufd       = v_fecha
                 AND   laufi       = v_nomina
                 AND   zbukr       = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Nomina no corresponde a Sociedad' bukrs.

  ENDIF.
  CONCATENATE  reguh-zaldt+6(2) reguh-zaldt+4(2) reguh-zaldt+0(4) INTO zaldt.
  CONCATENATE  reguh-valut+6(2) reguh-valut+4(2) reguh-valut+0(4) INTO zvalut.
  PERFORM bancos.
  SORT t_bancos BY cod_ac.

* Rescatamos Datos.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *  FROM  reguh
*           WHERE  laufd       = v_fecha
*             AND  laufi       = v_nomina
*             AND  xvorl       = ' '
*             AND  ubnkl       = '012'
*             AND  ( rzawe     = 'T' OR rzawe = 'V' ).
*
* NEW CODE
  SELECT *
  FROM  reguh
           WHERE  laufd       = v_fecha
             AND  laufi       = v_nomina
             AND  xvorl       = ' '
             AND  ubnkl       = '012'
             AND  ( rzawe     = 'T' OR rzawe = 'V' ) ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    contar   = contar   + 1.
    sumpagos = sumpagos + ( reguh-rbetr * -100 ).
    CONCATENATE  reguh-zaldt+6(2) reguh-zaldt+4(2) reguh-zaldt+0(4) INTO zaldt.
    CONCATENATE  reguh-valut+6(2) reguh-valut+4(2) reguh-valut+0(4) INTO zvalut.
    lineas  =  contar.
    cuenta = reguh-ubhkt.
    CONCATENATE cuenta+0(9) '3' INTO cuenta_2.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT  SINGLE bktxt INTO  bktxt FROM bkpf
*                                 WHERE bukrs      = bukrs
*                                   AND belnr = reguh-vblnr
*                                   AND gjahr = reguh-zaldt(4).
*
* NEW CODE
    SELECT bktxt
    UP TO 1 ROWS  INTO  bktxt FROM bkpf
                                 WHERE bukrs      = bukrs
                                   AND belnr = reguh-vblnr
                                   AND gjahr = reguh-zaldt(4) ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
*                                   AND laufi = reguh-laufi
*                                   AND xvorl = reguh-xvorl
*                                   AND zbukr = reguh-zbukr
*                                   AND lifnr = reguh-lifnr
*                                   AND kunnr = reguh-kunnr
*                                   AND empfg = reguh-empfg
*                                   AND vblnr = reguh-vblnr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  regup WHERE laufd = reguh-laufd
                                   AND laufi = reguh-laufi
                                   AND xvorl = reguh-xvorl
                                   AND zbukr = reguh-zbukr
                                   AND lifnr = reguh-lifnr
                                   AND kunnr = reguh-kunnr
                                   AND empfg = reguh-empfg
                                   AND vblnr = reguh-vblnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  * FROM  bseg  WHERE bukrs = regup-bukrs
*                                   AND belnr = regup-belnr
*                                   AND gjahr = regup-gjahr
*                                   AND buzei = regup-buzei.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  bseg  WHERE bukrs = regup-bukrs
                                   AND belnr = regup-belnr
                                   AND gjahr = regup-gjahr
                                   AND buzei = regup-buzei ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      zzmot_emis = bseg-zzmot_emis.
    ENDIF.
    IF ( reguh-stcd1 IS INITIAL ) OR ( reguh-zstc1 IS INITIAL ).
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE stcd1 adrnr INTO (reguh-stcd1, reguh-adrnr)
*        FROM lfa1 WHERE lifnr = reguh-lifnr.
*
* NEW CODE
      SELECT stcd1 adrnr
      UP TO 1 ROWS  INTO (reguh-stcd1, reguh-adrnr)
        FROM lfa1 WHERE lifnr = reguh-lifnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.

    IF ( NOT reguh-stcd1 IS INITIAL ) OR ( NOT reguh-zstc1 IS INITIAL ).
      MOVE-CORRESPONDING reguh TO tabla_00.

* Si es vale vista, el banco será el pagador
      IF tabla_00-rzawe = 'V'.
        tabla_00-zbnkl = tabla_00-hbkid.
      ENDIF.

* revisamos si paga a un beneficiario alternativo
      IF tabla_00-stcd1 <> tabla_00-zstc1.
        tabla_00-stcd1 = tabla_00-zstc1.
        tabla_00-name1 = tabla_00-znme1.
        tabla_00-ort01 = tabla_00-zort1.
        tabla_00-stras = tabla_00-zstra.
      ENDIF.
      APPEND tabla_00.
    ENDIF.
  ENDSELECT.

*Procesamos Datos
  SORT tabla_00 BY rzawe lifnr empfg.   " via.pago/prov/recep.pago

  LOOP AT tabla_00.
    PERFORM arma_registro.
  ENDLOOP.

  DESCRIBE TABLE tabla_00 LINES lins.
  " INI HCD 05-10-2020
  contabilizar = 'N'.
  IF par_di = 'X'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM zlog_pago_bancos
*       WHERE bukrs = bukrs
*         AND ubnkl = '016'
*         AND laufd = v_fecha
*         AND laufi = v_nomina.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM zlog_pago_bancos
       WHERE bukrs = bukrs
         AND ubnkl = '016'
         AND laufd = v_fecha
         AND laufi = v_nomina ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'Confirmación '
          text_question         = 'Archivo ya Generado y Contabilizado. ¿Desea Continuar?'
          default_button        = '2'
          display_cancel_button = 'X'
        IMPORTING
          answer                = resp.

      IF  resp <> '1'.
        LEAVE PROGRAM.
      ENDIF.
      contabilizar = 'N'.
    ELSE.
      contabilizar = 'S'.
    ENDIF.



  ENDIF.
  " FIN HCD 05-10-2020
  IF lins <> 0.
    PERFORM listado.  "informe.
    CHECK par_di EQ 'X'.
    PERFORM preparo_salida.
    PERFORM bajar_archivo.
    IF contabilizar <> 'N'.
      CONCATENATE cuenta+0(9) '5' INTO cuenta5.
      CONCATENATE cuenta+0(9) '3' INTO cuenta3.
      CONCATENATE v_fecha v_nomina  secuencia INTO xblnr.
      PERFORM  contabilizacion.
      PERFORM  grabar_log.
    ENDIF.

  ELSE.
    WRITE : /,/, 'No Existe Informacion Para Procesar....!!!!!!!!'.

  ENDIF.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  arma_registro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM arma_registro.
*--------------------*
  CLEAR   : reg_stder, t_items.
  REFRESH : t_doctos, t_doctos[], t_items[].

  reg_stder-laufd         =  tabla_00-laufd.
  reg_stder-laufi         =  tabla_00-laufi.
  reg_stder-xvorl         =  tabla_00-xvorl.
  reg_stder-empfg         =  tabla_00-empfg.

  reg_stder-zbukr         = tabla_00-zbukr.
  reg_stder-absbu         = tabla_00-absbu.

  TRANSLATE tabla_00-stcd1 USING '- ' .
  CONDENSE  tabla_00-stcd1 NO-GAPS    .

* Se ajusta Rut a la Izquierda.
  WRITE tabla_00-stcd1 TO reg_stder-rut_prov LEFT-JUSTIFIED.
  reg_stder-nombre           =  tabla_00-name1.


  TRANSLATE tabla_00-zstc1 USING '- ' .
  CONDENSE  tabla_00-zstc1 NO-GAPS    .

* Se ajusta Rut retirador a la Izquierda.
  WRITE tabla_00-zstc1 TO reg_stder-rut_ret LEFT-JUSTIFIED.
  reg_stder-nombre_ret           =  tabla_00-znme1 .

**Buscamos el correo a partir de la sociedad
  SELECT addrnumber, persnumber, comm_type, date_from,
         consnumber, remark
    INTO TABLE @DATA(ti_adrt)
    FROM adrt
    WHERE addrnumber = @tabla_00-adrnr.
  IF sy-subrc EQ 0.
    LOOP AT ti_adrt INTO DATA(wa_adrt) WHERE remark CS tabla_00-zbukr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE smtp_addr
*        INTO reg_stder-mail
*        FROM adr6
*        WHERE addrnumber = wa_adrt-addrnumber
*          AND persnumber = wa_adrt-persnumber
*          AND date_from  = wa_adrt-date_from
*          AND consnumber = wa_adrt-consnumber.
*
* NEW CODE
      SELECT smtp_addr
      UP TO 1 ROWS 
        INTO reg_stder-mail
        FROM adr6
        WHERE addrnumber = wa_adrt-addrnumber
          AND persnumber = wa_adrt-persnumber
          AND date_from  = wa_adrt-date_from
          AND consnumber = wa_adrt-consnumber ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      EXIT.
    ENDLOOP.
  ENDIF.

  IF reg_stder-mail IS INITIAL.
*V1 RVY 01.09.2022
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE smtp_addr INTO reg_stder-mail
*                  FROM  adr6
*                  WHERE addrnumber = tabla_00-adrnr AND
*                        persnumber = ' ' AND
*                        consnumber = '001' AND
*                        flgdefault = 'X'.
*
* NEW CODE
    SELECT smtp_addr
    UP TO 1 ROWS  INTO reg_stder-mail
                  FROM  adr6
                  WHERE addrnumber = tabla_00-adrnr AND
                        persnumber = ' ' AND
                        consnumber = '001' AND
                        flgdefault = 'X' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*V1 RVY 01.09.2022              .
  ENDIF.

  TRANSLATE   tabla_00-zbnkn USING '- '.
  CONDENSE    tabla_00-zbnkn NO-GAPS.
  CONDENSE    tabla_00-zbnkl NO-GAPS.

  reg_stder-cod_prov         =  tabla_00-lifnr.
  reg_stder-cod_clie         =  tabla_00-kunnr.

  reg_stder-codigo_banco     =  tabla_00-zbnkl.
  reg_stder-cuenta_abono     =  tabla_00-zbnkn.
  reg_stder-docto_sap1       =  tabla_00-vblnr.
  reg_stder-monto_pago       =  tabla_00-rwbtr * 100.


  IF tabla_00-rzawe = 'V'.
    reg_stder-codigo_banco = ''.
    reg_stder-cuenta_abono = ''.
  ENDIF.

  CLEAR reg_stder-mod_pago.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM bsak
*          WHERE  bukrs  = tabla_00-zbukr   " soc.pagadora
*            AND  augbl  = tabla_00-vblnr    " Núm. doc.
*            AND  lifnr  = tabla_00-lifnr
*            AND  auggj  = tabla_00-zaldt+0(4)
*            AND  shkzg  = 'H'.   
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM bsak
          WHERE  bukrs  = tabla_00-zbukr   " soc.pagadora
            AND  augbl  = tabla_00-vblnr    " Núm. doc.
            AND  lifnr  = tabla_00-lifnr
            AND  auggj  = tabla_00-zaldt+0(4)
            AND  shkzg  = 'H' ORDER BY PRIMARY KEY.   

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01" HCD 12042018

  IF tabla_00-rzawe  = 'V'.
    IF bsak-zterm = 'ZEFE'. "tabla_00-zbukr = 'CL19'. "or tabla_00-zbukr = 'CL17'. "HCD 20120424
      reg_stder-mod_pago  = '29'.
      reg_stder-via_pago  = 'V'.
    ELSE.
      reg_stder-mod_pago  = '20'.
    ENDIF.
    reg_stder-codigo_banco = 012.
    reg_stder-suc_retiro = 245.
  ELSE.
*     SELECT SINGLE clave INTO p_clave
*                  FROM  zfitr001
*                  WHERE bankl = '012'
*                  AND   bkont = tabla_00-zbkon.
*     IF sy-subrc EQ 0.
*        CONDENSE p_clave NO-GAPS.
*      reg_stder-mod_pago = p_clave.
*     ENDIF.
*  ENDIF.
    IF tabla_00-rzawe  = 'T'.
** INI V1 08-01-23
       IF par_jud = 'X'.
           reg_stder-mod_pago  = '02'.
       ELSE.
           reg_stder-mod_pago  = '01'.
       endif.
    ENDIF.
** FIN V1 08-01-23
    reg_stder-via_pago  = 'T'.
  ENDIF.
  " HCd 10112022 INI
  "IF reg_stder-mod_pago  <> '02'.
  "  reg_stder-mod_pago  = '01'.
  " ENDIF.
  " HCd 10112022 FIN


  acreedor = tabla_00-lifnr.

****Es multisociedad?

  IF tabla_00-zbukr <> tabla_00-absbu.  " Soc_pagadora y Soc.emisora

    SELECT * FROM regup CLIENT SPECIFIED
       WHERE mandt = sy-mandt
       AND laufd = v_fecha
       AND laufi = v_nomina
       AND xvorl = ' '
       AND lifnr = acreedor
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND vblnr = tabla_00-vblnr.
       AND vblnr = tabla_00-vblnr ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
      PERFORM paga_sociedad_.
    ENDSELECT.

  ELSE..
*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  bseg
*             WHERE   bukrs   = tabla_00-zbukr
*             AND     belnr   = tabla_00-vblnr
*             AND     zfbdt   = tabla_00-zaldt               " ff 150306
*             AND     koart   = 'K'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  bseg
             WHERE   bukrs   = tabla_00-zbukr
             AND     belnr   = tabla_00-vblnr
             AND     zfbdt   = tabla_00-zaldt               " ff 150306
             AND     koart   = 'K' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0.
      eje_pago = bseg-gjahr.
    ENDIF.
***
    soc_pago = tabla_00-zbukr.
    doc_pago = tabla_00-vblnr.

    PERFORM paga_sociedad.
  ENDIF.
****
ENDFORM.                    "arma_registro

*&---------------------------------------------------------------------*
*&      Form  paga_sociedad
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM paga_sociedad.
*-----------------*
  REFRESH t_doctos.
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
    MOVE-CORRESPONDING bsak TO t_doctos.
    APPEND t_doctos.
  ENDSELECT.

  PERFORM distribucion.

ENDFORM.                    "paga_sociedad


*&---------------------------------------------------------------------*
*&      Form  PAGA_SOCIEDAD_
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM paga_sociedad_ .

  REFRESH t_doctos.

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
    MOVE-CORRESPONDING bsak TO t_doctos.
**      el valor sera el total menos retencion
*        t_doctos-wrbtr = t_doctos-wrbtr - t_doctos-qbshb.
    APPEND t_doctos.
  ENDSELECT.

  IF sy-subrc = 0.
    PERFORM distribucion.
  ENDIF.

ENDFORM.                    " PAGA_SOCIEDAD_

*&---------------------------------------------------------------------*
*&      Form  distribucion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM distribucion.
*----------------*
  SORT t_doctos BY dmbtr.

  LOOP AT t_doctos.
*invertimos los signos para que el giro quede positivo !!!!!
    IF t_doctos-shkzg = 'S'.    "Invertimos los signos.....
      t_doctos-dmbtr = t_doctos-dmbtr * -1.
    ENDIF.
    t_doctos-dmbtr = t_doctos-dmbtr * 100.
    t_doctos-dmbtr = abs( t_doctos-dmbtr ).

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  bkpf
*         WHERE  bukrs  = t_doctos-bukrs
*         AND    belnr  = t_doctos-belnr
*         AND    gjahr  = t_doctos-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  bkpf
         WHERE  bukrs  = t_doctos-bukrs
         AND    belnr  = t_doctos-belnr
         AND    gjahr  = t_doctos-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0 AND bkpf-xblnr IS NOT INITIAL.
      CONDENSE bkpf-xblnr NO-GAPS.
      num_doc = bkpf-xblnr.
    ENDIF.


    IF bkpf-blart   = 'SA' OR bkpf-blart   = 'F7'.
      CONDENSE t_doctos-zuonr NO-GAPS.
      num_doc = t_doctos-zuonr.
      reg_stder-num_docto      = num_doc.
    ENDIF.

    reg_stder-num_docto      = num_doc.

    IF t_doctos-shkzg = 'S'.
      t_doctos-dmbtr =   t_doctos-dmbtr * -1.
      reg_stder-signo_docto   = '-'.
    ELSE.
      reg_stder-signo_docto  = '+'.
    ENDIF.

    reg_stder-monto_docto   = t_doctos-dmbtr.
    reg_stder-docto_sap2    = t_doctos-belnr.
    reg_stder-fecha_emision   =  t_doctos-bldat.
    reg_stder-fecha_vcto   =  t_doctos-zfbdt.
    reg_stder-blart =   t_doctos-blart.

    APPEND reg_stder.
  ENDLOOP.
ENDFORM.                               " LLENA_ESTRUCTURA


*&---------------------------------------------------------------------*
*&      Form  bajar_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bajar_archivo.
*-----------------*
  DATA : nombre_a  TYPE string.
  nombre_a = archivo.

  IF bukrs = 'CL27'.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                  = nombre_a
        filetype                  = 'ASC'
        confirm_overwrite         = 'X'
*       trunc_trailing_blanks_eol = ''
        trunc_trailing_blanks_eol = ' '
        write_lf_after_last_line  = ' '
      TABLES
        data_tab                  = out_reg_stder_xx
      EXCEPTIONS
        file_write_error          = 1
        no_batch                  = 2
        gui_refuse_filetransfer   = 3
        invalid_type              = 4
        no_authority              = 5
        unknown_error             = 6
        header_not_allowed        = 7
        separator_not_allowed     = 8
        filesize_not_allowed      = 9
        header_too_long           = 10
        dp_error_create           = 11
        dp_error_send             = 12
        dp_error_write            = 13
        unknown_dp_error          = 14
        access_denied             = 15
        dp_out_of_memory          = 16
        disk_full                 = 17
        dp_timeout                = 18
        file_not_found            = 19
        dataprovider_exception    = 20
        control_flush_error       = 21
        OTHERS                    = 22.
  ELSE.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                  = nombre_a
        filetype                  = 'ASC'
        confirm_overwrite         = 'X'
        trunc_trailing_blanks_eol = ' '
        write_lf_after_last_line  = ' '
      TABLES
        data_tab                  = out_reg_stder_xx
      EXCEPTIONS
        file_write_error          = 1
        no_batch                  = 2
        gui_refuse_filetransfer   = 3
        invalid_type              = 4
        no_authority              = 5
        unknown_error             = 6
        header_not_allowed        = 7
        separator_not_allowed     = 8
        filesize_not_allowed      = 9
        header_too_long           = 10
        dp_error_create           = 11
        dp_error_send             = 12
        dp_error_write            = 13
        unknown_dp_error          = 14
        access_denied             = 15
        dp_out_of_memory          = 16
        disk_full                 = 17
        dp_timeout                = 18
        file_not_found            = 19
        dataprovider_exception    = 20
        control_flush_error       = 21
        OTHERS                    = 22.
  ENDIF.


  IF sy-subrc <> 0.
    WRITE :/ 'error!!!!'  ,
           /  sy-msgv1 ,
           /  sy-msgv2 ,
           /  sy-msgv3 ,
           /  sy-msgv4 .

  ELSE.
    SKIP 2 .
    FORMAT COLOR 3 ON.
    WRITE : / 'Se genero archivo :', archivo.
    FORMAT COLOR 3 OFF.
  ENDIF.
*----------------------------------------------
ENDFORM.                    "bajar_archivo

*&--------------------------------------------------------------------*
*&      Form  bancos
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM bancos.
*----------*
  REFRESH t_bancos.
  t_bancos-cod_ac = 'BSANT'.
  t_bancos-cod_nw = '037'.
  APPEND t_bancos.
ENDFORM.                    "bancos

*&---------------------------------------------------------------------*
*&      Form  listado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM listado.
*-----------*

  READ TABLE tabla_00 INDEX 1.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM  bkpf
*        WHERE  bukrs  = tabla_00-zbukr   " Soc. Paga
*        AND    belnr  = tabla_00-vblnr   " Doc. pago
*        AND    gjahr  = tabla_00-zaldt+0(4).
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  bkpf
        WHERE  bukrs  = tabla_00-zbukr   " Soc. Paga
        AND    belnr  = tabla_00-vblnr   " Doc. pago
        AND    gjahr  = tabla_00-zaldt+0(4) ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  monto_p = 0.

  SORT tabla_00 BY stcd1.
  LOOP AT tabla_00.

    IF aux_prov <> tabla_00-stcd1.
      aux_prov = tabla_00-stcd1.
      IF monto_p <> 0.
        WRITE 118 monto_p CURRENCY 'CLP'.
      ENDIF.
      monto_p = 0.
    ENDIF.

    t_monto = 0.
    CLEAR t_items[].

    IF tabla_00-zbukr <> tabla_00-absbu.  " Soc_pagadora y Soc.emisora
      SELECT * FROM regup CLIENT SPECIFIED
        WHERE mandt = sy-mandt
        AND laufd = v_fecha
        AND laufi = v_nomina
        AND xvorl = ' '
        AND lifnr = tabla_00-lifnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND vblnr = tabla_00-vblnr.
        AND vblnr = tabla_00-vblnr ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
        soc_pago = tabla_00-zbukr.
        doc_pago = tabla_00-vblnr.
        PERFORM doctos__2.
      ENDSELECT.
    ELSE.
      soc_pago = tabla_00-zbukr.
      doc_pago = tabla_00-vblnr.
      PERFORM doctos__.
    ENDIF.

  ENDLOOP.

* Imprimimos total Parcial
  WRITE 118 monto_p CURRENCY 'CLP'.

* Imprimimos total Final
  WRITE : /,/111 'Total' ,
             118  monto_z CURRENCY 'CLP'.

  SKIP 4.

  WRITE :/25 '___________________',   "Subrayado CAJA
          50 '___________________',   "Subrayado APODERADO
          75 '___________________'.   "Subrayado APODERADO
  SKIP .
  WRITE :/28 'Tesoreria' ,              "para firma de caja
          54 'Apoderado' ,            "para firma apoderado
          79 'Apoderado' .            "para firma apoderado

ENDFORM.                    "listado


TOP-OF-PAGE.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM  bkpf
*       WHERE  bukrs  = tabla_00-zbukr   " Soc. Paga
*       AND    belnr  = tabla_00-vblnr   " Doc. pago
*       AND    gjahr  = tabla_00-zaldt+0(4).
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  bkpf
       WHERE  bukrs  = tabla_00-zbukr   " Soc. Paga
       AND    belnr  = tabla_00-vblnr   " Doc. pago
       AND    gjahr  = tabla_00-zaldt+0(4) ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  WRITE : /1  t001-butxt,
           43   'NOMINA DE PAGO PROVEEDORES CUENTA BANCO ESTADO' ,
           120 sy-datum,

          /120 sy-uzeit ,
          /27 'Identificación De Propuesta de Pago : ',
              'Fecha Nomina: ',v_fecha, ' Nomina:' ,  v_nomina ,
          120 sy-pagno,
          / ,
          /'Fecha Contabilizacion Pago: ', bkpf-budat.

  WRITE sy-uline(136).

  WRITE : /01  'Mp'               ,   " 01   " mdiopago
           04  'Doc.Egreso'       ,   " 10
           15  'Soc'              ,   " 04
           19  'Referencia'       ,   " 25   " bkpf-xblnr 16
           37  'Proveedor'        ,   " 16
           54  'Nombre Proveedor' ,   " 35

           91  'Fecha Vcto',
           111 'Monto'            ,   " 15
           127 'Total'            .

  WRITE : / sy-uline(136).

*&---------------------------------------------------------------------*
*&      Form  doctos__
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM doctos__.
*------------*
  acreedor = tabla_00-lifnr.
  REFRESH t_doctos.

*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM  bseg
*            WHERE   bukrs   = tabla_00-zbukr
*            AND     belnr   = tabla_00-vblnr
*            AND     zfbdt   = tabla_00-zaldt                " ff 150306
*            AND     koart   = 'K'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  bseg
            WHERE   bukrs   = tabla_00-zbukr
            AND     belnr   = tabla_00-vblnr
            AND     zfbdt   = tabla_00-zaldt                " ff 150306
            AND     koart   = 'K' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc = 0.
    eje_pago = bseg-gjahr.
  ENDIF.
*****
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM bsak
*          WHERE  bukrs  = soc_pago    " soc.pagadora
*            AND  augbl  = doc_pago    " Núm. doc.
*            AND  lifnr  = acreedor
*            AND  auggj  = eje_pago.
*
* NEW CODE
  SELECT *
 FROM bsak
          WHERE  bukrs  = soc_pago    " soc.pagadora
            AND  augbl  = doc_pago    " Núm. doc.
            AND  lifnr  = acreedor
            AND  auggj  = eje_pago ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    CHECK bsak-augbl <>  bsak-belnr.

    MOVE-CORRESPONDING bsak TO t_doctos.
    APPEND t_doctos.
  ENDSELECT.

  LOOP AT t_doctos.

* Buscamos textos
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  bkpf
*            WHERE  bukrs  = soc_pago          " Soc. Paga
*            AND    gjahr  = t_doctos-gjahr
*            AND    belnr  = t_doctos-belnr.   
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  bkpf
            WHERE  bukrs  = soc_pago          " Soc. Paga
            AND    gjahr  = t_doctos-gjahr
            AND    belnr  = t_doctos-belnr ORDER BY PRIMARY KEY.   

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01" Doc. pago

*Invertimos signo para el listado

    IF t_doctos-shkzg = 'S'.
      t_doctos-dmbtr = t_doctos-dmbtr * -1.
    ENDIF.

    t_doctos-dmbtr = t_doctos-dmbtr .

    WRITE : /001 tabla_00-rzawe ,
             003 tabla_00-vblnr  ,  " t_doctos-belnr ,
             014 soc_pago       ,
             019 bkpf-xblnr     ,  " bkpf-bktxt
             037 tabla_00-stcd1 ,
             054 tabla_00-znme1 ,
             091 t_doctos-zfbdt,
             101 t_doctos-dmbtr CURRENCY 'CLP'.
    HIDE: tabla_00-vblnr,soc_pago, eje_pago.

    t_monto = t_monto  + t_doctos-dmbtr.
    monto_p  = monto_p + t_doctos-dmbtr.

  ENDLOOP.

  CLEAR tabla_00-vblnr .

  monto_y = t_monto .

  monto_z = monto_z + monto_y.
ENDFORM.                    "doctos__

*&---------------------------------------------------------------------*
*&      Form  DOCTOS__2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM doctos__2 .

  acreedor = tabla_00-lifnr.
  CLEAR t_doctos[].

  eje_pago = tabla_00-zaldt+0(4).

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM bsak CLIENT SPECIFIED
*           WHERE mandt   = sy-mandt
*             AND  bukrs  = regup-bukrs    " soc.pagadora
*             AND  belnr  = regup-belnr    " Núm. doc.
*             AND  gjahr  = regup-gjahr
*             AND  buzei  = regup-buzei
*             AND  lifnr  = regup-lifnr.
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

    MOVE-CORRESPONDING bsak TO t_doctos.

    APPEND t_doctos.
  ENDSELECT.

  LOOP AT t_doctos.

* Buscamos textos
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  bkpf CLIENT SPECIFIED
*            WHERE  mandt  = sy-mandt
*            AND    bukrs  = t_doctos-bukrs          " Soc. Paga
*            AND    gjahr  = t_doctos-gjahr
*            AND    belnr  = t_doctos-belnr.   
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  bkpf CLIENT SPECIFIED
            WHERE  mandt  = sy-mandt
            AND    bukrs  = t_doctos-bukrs          " Soc. Paga
            AND    gjahr  = t_doctos-gjahr
            AND    belnr  = t_doctos-belnr ORDER BY PRIMARY KEY.   

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01" Doc. pago

*Invertimos signo para el listado

    IF t_doctos-shkzg = 'S'.
      t_doctos-dmbtr = t_doctos-dmbtr * -1.
    ENDIF.

    t_doctos-dmbtr = t_doctos-dmbtr .

    WRITE : /001 tabla_00-rzawe ,
             003 tabla_00-vblnr  ,  " t_doctos-belnr ,
             014 tabla_00-absbu       ,
             019 bkpf-xblnr     ,  " bkpf-bktxt
             037 tabla_00-stcd1 ,
             054 tabla_00-znme1 ,
             091 t_doctos-zfbdt,
             101 t_doctos-dmbtr CURRENCY 'CLP'.
    HIDE: tabla_00-vblnr,soc_pago, eje_pago.

    t_monto = t_monto  + t_doctos-dmbtr.
    monto_p  = monto_p + t_doctos-dmbtr.

  ENDLOOP.

  monto_y = t_monto .

  monto_z = monto_z + monto_y.
  CLEAR t_monto.

ENDFORM.                                                    " DOCTOS__2

AT LINE-SELECTION.
  IF NOT tabla_00-vblnr IS INITIAL.
    SET PARAMETER ID 'BLN' FIELD tabla_00-vblnr.
    SET PARAMETER ID 'BUK' FIELD soc_pago.
    SET PARAMETER ID 'GJR' FIELD eje_pago.
    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDIF.

  CLEAR tabla_00-vblnr .

*&---------------------------------------------------------------------*
*&      Form  PREPARO_SALIDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM preparo_salida.

  DATA: rut(11)  TYPE c.
  DATA: largo(3) TYPE n.
  DATA: numero(10) TYPE n.
  DATA: primer(1)  TYPE n.
  DATA: docto(10)  TYPE n.

  primer = 0.

  REFRESH out_reg_stder_xx.
* SORT reg_stder  BY zbukr rut_prov .
* V1 RVY 17.08.2022
  SORT reg_stder  BY zbukr docto_sap1.
* V1 RVY 17.08.2022
  LOOP AT reg_stder.
    IF primer = 0.
      PERFORM cabecera_reg.
      PERFORM detalle_reg.
      primer = 1.
      docto = reg_stder-docto_sap1.
    ELSE.
      IF docto <> reg_stder-docto_sap1.
        PERFORM cabecera_reg.
        PERFORM detalle_reg.
        docto = reg_stder-docto_sap1.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " PREPARO_SALIDA

*&---------------------------------------------------------------------*
*&      Form  CABECERA-REG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cabecera_reg.

  out_reg2_stder-relleno = '2'.
  out_reg2_stder-glosa_vv = ' '.
  out_reg2_stder-glosa_1  = ' '.
  out_reg2_stder-glosa_2  = ' '.
  out_reg2_stder-glosa_3  = ' '.
  out_reg2_stder-glosa_4  = ' '.
  out_reg2_stder-glosa_5  = ' '.
  out_reg2_stder-glosa_6  = ' '.
  out_reg2_stder-glosa_7  = ' '.
  out_reg2_stder-dato_1   = ' '.
  out_reg2_stder-dato_2   = ' '.
  out_reg2_stder-dato_3   = ' '.
  out_reg2_stder-dato_4   = ' '.
  out_reg2_stder-dato_5   = ' '.
  out_reg2_stder-dato_6   = ' '.
  out_reg2_stder-dato_7   = ' '.
  out_reg2_stder-indicador_1 = ' '.
  out_reg2_stder-indicador_2 = ' '.
  out_reg2_stder-indicador_3 = ' '.
  out_reg2_stder-indicador_4 = ' '.
  out_reg2_stder-indicador_5 = ' '.
  out_reg2_stder-indicador_6 = ' '.
  out_reg2_stder-indicador_7 = ' '.
  out_reg2_stder-cod_seg     = ' '.

  largo = strlen( reg_stder-rut_prov ).
  largo =  largo - 1.
  out_reg2_stder-rut_prv_dvr = reg_stder-rut_prov+largo(1).
  out_reg2_stder-rut_prv     = reg_stder-rut_prov+0(largo).
  out_reg2_stder-nombre_prv  = reg_stder-nombre.
  TRANSLATE out_reg2_stder-nombre_prv
      USING 'ÁAÉEÍIÓOÚUáaéeíióoúuÑNñn; : \ ~ ¨ , / % $S| ° #N& -'.
  out_reg2_stder-email       = reg_stder-mail.

  out_reg2_stder-forma_pago  = reg_stder-mod_pago.

  out_reg2_stder-cod_banco    = reg_stder-codigo_banco.
  out_reg2_stder-cuenta_cte   = reg_stder-cuenta_abono.
  TRANSLATE out_reg2_stder-cuenta_cte
      USING 'ÁAÉEÍIÓOÚUáaéeíióoúuÑNñn; : \ ~ ¨ , / % $S| ° #N& -'.
  out_reg2_stder-sucursal_bco = reg_stder-suc_retiro.
  out_reg2_stder-monto        = reg_stder-monto_pago.

  out_reg2_stder-sector_fin   = '26'.

  out_reg_stder-nro_docto  = reg_stder-num_docto.

  out_reg_stder-nro_docto_rel = 0.
  out_reg_stder-valor_info = reg_stder-monto_docto.
  out_reg_stder-valor_pago = reg_stder-monto_docto.
  out_reg_stder-estado_pago = 'OK'.
  CONCATENATE v_fecpag+6(2) v_fecpag+4(2) v_fecpag+0(4) INTO out_reg_stder-fecha_pago .
  CONCATENATE reg_stder-fecha_vcto+6(2) reg_stder-fecha_vcto+4(2)   reg_stder-fecha_vcto+0(4) INTO out_reg_stder-fecha_vcto.
  out_reg_stder-glosa = ''.

  largo = strlen( reg_stder-rut_prov ).
  IF largo > 0.
    largo =  largo - 1.
    out_reg_stder-rut_ret1_dvr = reg_stder-rut_ret+largo(1).
    out_reg_stder-rut_ret1     = reg_stder-rut_ret+0(largo).
    out_reg_stder-paterno1     = reg_stder-nombre_ret+0(15).
    out_reg_stder-materno1     = reg_stder-nombre_ret+14(15).
    out_reg_stder-nombre1      = reg_stder-nombre_ret+29(10).
  ELSE.
    out_reg_stder-rut_ret1 = 0.
    out_reg_stder-rut_ret1_dvr = ' '.
    out_reg_stder-paterno1 = '               '.
    out_reg_stder-materno1 = '               '.
    out_reg_stder-nombre1  = '               '.
  ENDIF.

  out_reg_stder-rut_ret2   = 0.
  out_reg_stder-rut_ret2_dvr = ' '.
  out_reg_stder-paterno2   = '               '.
  out_reg_stder-materno2   = '               '.
  out_reg_stder-nombre2    = '               '.

  IF reg_stder-via_pago = 'T'. " Se agrega esta opcion para DAVILA Y SIS HCD 20120424
    out_reg_stder-codigo = '00000000001'.
  ELSE.
    out_reg_stder-codigo = '99900000001'.
  ENDIF.

  PERFORM formateo.

ENDFORM.                    " CABECERA_REG

*&---------------------------------------------------------------------*
*&      Form  DETALLE_REG
*&---------------------------------------------------------------------*
FORM detalle_reg.
  DATA: g_string(10) TYPE c.
  DATA: g_type TYPE dd01v-datatype.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM  regup
*                 WHERE  laufd = reg_stder-laufd
*                 AND    laufi = reg_stder-laufi
*                 AND    xvorl = reg_stder-xvorl
*                 AND    lifnr = reg_stder-cod_prov
*                 AND    zbukr = reg_stder-zbukr
*                 AND    kunnr = reg_stder-cod_clie
*                 AND    empfg = reg_stder-empfg
*                 AND    vblnr = reg_stder-docto_sap1.
*
* NEW CODE
  SELECT *
 FROM  regup
                 WHERE  laufd = reg_stder-laufd
                 AND    laufi = reg_stder-laufi
                 AND    xvorl = reg_stder-xvorl
                 AND    lifnr = reg_stder-cod_prov
                 AND    zbukr = reg_stder-zbukr
                 AND    kunnr = reg_stder-cod_clie
                 AND    empfg = reg_stder-empfg
                 AND    vblnr = reg_stder-docto_sap1 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    CASE regup-blart.
      WHEN 'F0' OR 'FB'.
        t_doctos2-tipo_doc = '32'.
      WHEN 'F1' OR 'F2' OR 'F5' OR 'F7' OR 'F8' OR 'FR' OR 'RE' OR 'RN'.
        t_doctos2-tipo_doc = '30'.
      WHEN 'F3' OR 'F4' OR 'F6' OR 'F9'.
        t_doctos2-tipo_doc = '33'.
      WHEN 'FA' OR 'FC'.
        t_doctos2-tipo_doc = '34'.
      WHEN 'B1' OR 'B3'.
        t_doctos2-tipo_doc = '35'.
      WHEN 'B2' OR 'B4'.
        t_doctos2-tipo_doc = '39'.
      WHEN 'FR'.
        t_doctos2-tipo_doc = '41'.
      WHEN 'D1' OR 'D2'.
        t_doctos2-tipo_doc = '55'.
      WHEN 'D3' OR 'D4'.
        t_doctos2-tipo_doc = '56'.
      WHEN 'N0' OR 'N1' OR 'N2' OR 'NB'.
        t_doctos2-tipo_doc = '60'.
      WHEN 'N3' OR 'N4' OR 'NA' OR 'NC'.
        t_doctos2-tipo_doc = '61'.
      WHEN OTHERS.
        t_doctos2-tipo_doc = '99'.
    ENDCASE.

    t_doctos2-relleno = '3'.

    CONCATENATE regup-zfbdt+6(2) regup-zfbdt+4(2) regup-zfbdt(4) INTO t_doctos2-fecha_doc.
    IF regup-shkzg = 'S'.
      t_doctos2-monto_doc =  regup-dmbtr * -100.
    ELSE.
      t_doctos2-monto_doc =  regup-dmbtr * 100.
    ENDIF.

    t_doctos2-numero_doc = regup-xblnr.
* V1 RVY 17-08-2022
    TRANSLATE t_doctos2-numero_doc
     USING 'ÁAÉEÍIÓOÚUáaéeíióoúuÑNñn; : \ ~ ¨ , / % $S| ° #N& - . '.
    CONDENSE  t_doctos2-numero_doc  NO-GAPS.
    TRANSLATE t_doctos2-numero_doc TO UPPER CASE.
    TRANSLATE t_doctos2-numero_doc
     USING 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'.
    CONDENSE t_doctos2-numero_doc NO-GAPS.
    t_doctos2-glosa_doc   = ' '.
* V1 RVY 17-08-2022
*HCD 07022023 INI
    IF bukrs = 'CL17' OR  bukrs = 'CL13' OR  bukrs = 'CL19'.
      IF regup-blart = 'SA'.
        g_string  = t_doctos2-numero_doc.
        IF g_string IS INITIAL.
          g_string = 'SINDATOS'.
        ENDIF.

        CALL FUNCTION 'NUMERIC_CHECK'
          EXPORTING
            string_in = g_string
          IMPORTING
            htype     = g_type.

        IF g_type = 'CHAR'.
          t_doctos2-numero_doc = '0000000000'.
        ENDIF.
      ENDIF.
    ENDIF.
*HCD 07022023 FIN


*-> BEG INS V1-CNN
    CLEAR: ls_reg2, ls_reg_stder_xx.
    ls_reg2-data = t_doctos2.
    ls_reg2-eol  = ' '.

    CONCATENATE ls_reg2-data ls_reg2-eol
      INTO ls_reg_stder_xx-linea RESPECTING BLANKS.

    out_reg_stder_xx = ls_reg_stder_xx.
    APPEND out_reg_stder_xx.
*-> END INS V1-CNN
    CLEAR  t_doctos2.

  ENDSELECT. " de revision de REGUP.

ENDFORM.                    " DETALLE_REG

FORM formateo.

  DATA lv_gato TYPE c LENGTH 2 VALUE cl_abap_char_utilities=>cr_lf.
  DATA: desde(3) TYPE n.
  DATA: inicio(3) TYPE c.

  IF bukrs = 'CL17' OR  bukrs = 'CL13' OR  bukrs = 'CL19'.  " Se agrega esta opcion para DAVILA Y SIS
    out_reg_stder-nro_doctox     = out_reg_stder-nro_docto.
    out_reg_stder-nro_docto_relx = out_reg_stder-nro_docto_rel.
    out_reg_stder-valor_infox    = out_reg_stder-valor_info.
    out_reg_stder-valor_pagox    = out_reg_stder-valor_pago.
  ELSE.
    out_reg_stder-nro_doctox     = out_reg_stder-nro_docto.
    out_reg_stder-nro_docto_relx = out_reg_stder-nro_docto_rel.
    out_reg_stder-valor_infox    = out_reg_stder-valor_info.
    out_reg_stder-valor_pagox    = out_reg_stder-valor_pago.
  ENDIF.

*-> BEG INS V1-CNN
  CLEAR: ls_reg1, ls_reg_stder_xx.
  ls_reg1-data = out_reg2_stder.
  ls_reg1-eol  = ' '.

  CONCATENATE ls_reg1-data ls_reg1-eol
    INTO ls_reg_stder_xx-linea RESPECTING BLANKS.

  out_reg_stder_xx = ls_reg_stder_xx.
  APPEND out_reg_stder_xx.

  CLEAR out_reg2_stder.

ENDFORM.                    "formateo


"HCD 05-10-2020 Agfrego log
FORM grabar_log.
  zlog_pago_bancos-bukrs = bukrs.
  zlog_pago_bancos-ubnkl = '016'.
  SHIFT zlog_pago_bancos-ubnkl LEFT DELETING LEADING space.
  zlog_pago_bancos-laufd = v_fecha.
  zlog_pago_bancos-laufi = v_nomina.
  zlog_pago_bancos-fecha_gen = sy-datum.
  zlog_pago_bancos-hora_gen = sy-uzeit.
  zlog_pago_bancos-uname = sy-uname.
  CONCATENATE bukrs v_fecha v_nomina  secuencia INTO zlog_pago_bancos-nombre_arc.
  zlog_pago_bancos-total  = sumpagos.
  zlog_pago_bancos-lineas = lineas.
  zlog_pago_bancos-gjahr  =  gjahr.
  zlog_pago_bancos-belnr  =  belnr.
  zlog_pago_bancos-nrotran  =  v_nomina.
  INSERT zlog_pago_bancos.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  contabilizacion
*&---------------------------------------------------------------------*
FORM contabilizacion.
  DATA: valor(18) TYPE c.

  CLEAR bdcdata.
  REFRESH bdcdata.
  valor = sumpagos.
  REPLACE '.00' WITH '' INTO valor.
  CONDENSE valor NO-GAPS.
  total = sumpagos.
*
  CONCATENATE v_fecha v_nomina  secuencia INTO xblnr.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BKPF-BLDAT'
                                zaldt.
  PERFORM bdc_field       USING 'BKPF-BLART'
                                'SA'.
  PERFORM bdc_field       USING 'BKPF-BUKRS'
                                 bukrs.
  PERFORM bdc_field       USING 'BKPF-BUDAT'
                                zaldt.
  PERFORM bdc_field       USING 'BKPF-WAERS'
                                'CLP'.
  PERFORM bdc_field       USING 'BKPF-XBLNR'
                                xblnr.
  PERFORM bdc_field       USING 'BKPF-BKTXT'
                                bktxt.

  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                 '40'.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                cuenta.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.

  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                valor. "total. LSC
  PERFORM bdc_field       USING 'BSEG-VALUT'
                                 zvalut.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                                bktxt.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                bktxt.
  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                '50'.
* CBD - 2012-01-11 - MANEJO CTA CARGO - PERFORM bdc_field       USING 'RF05A-NEWKO'
* CBD - 2012-01-11 - MANEJO CTA CARGO -                               cuenta.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                cuenta_2.

  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'COBL-ZZMOT_EMIS'.
  PERFORM bdc_field       USING 'COBL-ZZMOT_EMIS'
                                 zzmot_emis.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BSEG-VALUT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                valor. "total. LSC
  PERFORM bdc_field       USING 'BSEG-VALUT'
                                zvalut.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                bktxt.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                              xblnr.

  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'COBL-ZZMOT_EMIS'.
  PERFORM bdc_field       USING 'COBL-ZZMOT_EMIS'
                                zzmot_emis.

  CALL TRANSACTION 'F-02' USING bdcdata
                                  MODE 'E'
                                  UPDATE 'S'
                                  MESSAGES INTO itab.

  LOOP AT itab.
    IF itab-msgid = 'F5' AND     itab-msgnr = '312'.
      belnr = itab-msgv1.
      gjahr = zaldt+4(4).
    ENDIF.

  ENDLOOP.

ENDFORM.                    "contabilizacion
