*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
REPORT ZFITR002 NO STANDARD PAGE HEADING
                                   line-count 60
                                   LINE-SIZE 132 .

*----------------------------------------------------------------------*
* Tablas usadas.
*----------------------------------------------------------------------*
TABLES : reguh,   "  Datos de pago del programa de pagos              02
         regup,
         bseg,    "  Segmento de documento de Contabilidad            02
         lfa1,    "  Maestro de proveedores (parte general)           02
         t001,
         lfb1,
         bnka,    "  Maestro de banco                                 02
         bsak,    "  índice secundario para acreedores (part.comp.)   02
         bkpf,    "  Cabecera de documento para Contabilidad          02
 zlog_pago_bancos. "HCD 05-10-2020
INCLUDE zbatchinput_v2."HCD 20210319
DATA : BEGIN OF tabla_00 OCCURS 0.
        INCLUDE STRUCTURE reguh.
DATA : END OF tabla_00.

DATA : monto_total(13)                    ,
       total_proveedor LIKE tabla_00-rwbtr.

DATA : BEGIN OF t_bancos OCCURS 0     ,
         cod_ac      LIKE reguh-zbnkl ,
         cod_nw(03)  TYPE c           ,
       END OF t_bancos                .

DATA : BEGIN OF REG01,
           tr(02)               type n,
           rut_emp(10)          TYPE n ,
           rut_emp_dv(01)       TYPE c ,
           monto_total_pago(13) type n,
           Cantidad_pago(10)    type n,
           Cantidad_docto(10)   type n,
           filler2(564)         type c,
END OF REG01.

DATA : BEGIN OF REG02,
           tr(02)               type n,
           rut_prv(10)          TYPE n,
           rut_prv_dv(01)       TYPE c,
           nombre_prv(60)       type c,
           direccion(35)        type c,
           comuna(15)           type c,
           ciudad(15)           type c,
           actividad(02)        type c,
           monto_pago(13)       type n,
           fecha_pago(08)       type c,
           medio_pago(02)       type c,
           cod_banco(03)        type n,
           of_destino(03)       type n,
           cuenta(22)           type c,
           des_pago(120)        type c,
           vv_acumulado(01)     type c,
           filler1(20)          type c,
           filler2(20)          type c,
           filler3(30)          type c,
           rut_con(10)          TYPE n,
           rut_con_dv(01)       TYPE c,
           Nombre_contacto(60)  type c,
           canal_aviso(1)       type c,
           codigo_area(04)      type c,
           numero_fono_fax(10)  type c,
           mail1(60)            type c,
           mail2(60)            type c,
           num_aviso(04)        type n,
           filler4(18)          type c,
END OF REG02.


DATA : BEGIN OF REG03,
           tr(02)               type n,
           tipo_docto(03)       TYPE c,
           num_docto(10)        TYPE c,
           num_cuota(03)        type n,
           monto_docto(13)      type n,
           monto_pago(13)       type n,
           fecha_emision(08)    type c,
           desc_docto(120)      type c,
           filler1(20)          type c,
           filler2(20)          type c,
           filler3(30)          type c,
           filler4(368)         type c,
END OF REG03.

DATA : BEGIN OF REG04,
           tr(02)               type n,
           num_aviso(04)        type n,
           glosa_aviso(320)     TYPE c,
           corr_aviso(05)       type c,
           filler2(279)         type c,
END OF REG04.




DATA : BEGIN OF ctachile,
           cta(12)              type c,
           filler(10)           TYPE c,
END OF ctachile.


DATA : BEGIN OF reg_stder OCCURS 0,
           zbukr(04)           type c,
           rut_prov(12)        TYPE c,
           nombre(40)          TYPE c,
           suc_retiro(03)      TYPE n,
           mod_pago(02)        TYPE n,
           codigo_banco(03)    TYPE n,
           cuenta_abono(18)    TYPE c,
           tipo_docto(03)      type c,
           num_docto(10)       TYPE n,
           monto_docto(13)     TYPE p decimals 0,
           fecha_emision(08)   type c,
           uno(05)             TYPE p decimals 0,
           mail(35)            type c ,

END OF reg_stder.


DATA : BEGIN OF out_reg_stder OCCURS 0,
           reg(610)           TYPE c ,
       END OF out_reg_stder .

DATA: BEGIN OF t_doctos OCCURS 0,
        blart    like bkpf-blart,
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
       P_CLAVE(40) TYPE C.

FIELD-SYMBOLS : <nombre1_> TYPE ANY ,
                <nombre2_> TYPE ANY ,
                <nombre3_> TYPE ANY .

DATA:  nombre1(25)          ,
       nombre2(25)          ,
       nombre3(25)          ,
       ndx(02)      TYPE n  ,
       lins(04)     TYPE c VALUE 0,
       num_doc(10)  TYPE c  .

DATA: v_rut_ret(12).
DATA: v_nombre_ret(40).

DATA:    BEGIN OF TLAUFK OCCURS 1.
        INCLUDE STRUCTURE ILAUFK.
DATA:    END OF TLAUFK.

data lt_dynpfields like dynpread occurs 1 with header line.
data lv_dynpro_prog like d020s-prog.

DATA: cuenta           LIKE reguh-ubhkt, "HCD 05-10-2020
        cuenta_2         LIKE reguh-ubhkt, "HCD 05-10-2020
        cuenta5           LIKE reguh-ubhkt, "HCD 05-10-2020
        cuenta3          LIKE reguh-ubhkt, "HCD 05-10-2020
        secuencia(2)     TYPE n, "HCD 05-10-2020
         sumpagos(15)     TYPE n, "HCD 05-10-2020
 lineas(5)        TYPE n,"HCD 05-10-2020
 gjahr            LIKE bkpf-gjahr,"HCD 05-10-2020
 contar(6)        TYPE n,"HCD 05-10-2020
 zaldt            LIKE reguh-zaldt,"HCD 05-10-2020
 total            LIKE bseg-dmbtr, "HCD 05-10-2020
  zzmot_emis       LIKE bseg-zzmot_emis,"HCD 05-10-2020
 contabilizar(1), "HCD 05-10-2020
 resp(1), "HCD 05-10-2020
  bktxtasi            LIKE bkpf-bktxt, "HCD 05-10-2020
  xblnr            LIKE bkpf-xblnr, "HCD 05-10-2020
        bktxt            LIKE bkpf-bktxt, "HCD 05-10-2020
  zvalut            LIKE reguh-valut, "HCD 05-10-2020
        belnr            LIKE bkpf-belnr,"HCD 05-10-2020
         itab          TYPE TABLE OF bdcmsgcoll WITH HEADER LINE,
                   v_nrotra   LIKE  zlog_pago_bancos-nrotran."HCD 05-10-2020
*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.
PARAMETER : bukrs    like bkpf-bukrs     obligatory,
            v_fecha  LIKE reguh-laufd    obligatory,
            v_nomina LIKE f110v-laufi    obligatory,
            v_pago   LIKE sy-datum       obligatory.

PARAMETER  : archivo     LIKE rlgrap-filename DEFAULT 'C:\TRANSFER\'.

PARAMETERS : par_tes RADIOBUTTON GROUP test       " Ejecución en Test
                     DEFAULT 'X',
             par_di  RADIOBUTTON GROUP test.      " Ejecución real

SELECTION-SCREEN END OF BLOCK marco1 .

*---------------------------------------------------------------------------------
AT SELECTION-SCREEN ON bukrs.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD BUKRS.

  IF SY-SUBRC <> 0.
*--------'No authorization for company code &'------------------------
    MESSAGE E526(ICC_TR) WITH BUKRS.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single * from t001 where bukrs = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  from t001 where bukrs = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_fecha.


  refresh lt_dynpfields.
  lt_dynpfields-fieldname = 'BUKRS'.
  append lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  call function 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
  read table lt_dynpfields index 1.
  bukrs = lt_dynpfields-fieldvalue .
  TRANSLATE bukrs TO UPPER CASE.

  REFRESH TLAUFK.
  TLAUFK-LAUFK = SPACE.
  TLAUFK-SIGN  = 'I'.
  APPEND TLAUFK.
  CALL FUNCTION 'ZF4_ZAHLLAUF'
    EXPORTING
      F1TYP = 'D'
      F2NME = 'F110V-LAUFI'
      BUKRS = bukrs
      BANCO = '001'
    IMPORTING
      LAUFD = v_fecha
      LAUFI = v_nomina
    TABLES
      LAUFK = TLAUFK.

  refresh lt_dynpfields.
  lt_dynpfields-fieldname = 'V_NOMINA'.
  append lt_dynpfields.

  lt_dynpfields-fieldname = 'ARCHIVO'.
  append lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  call function 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  read table lt_dynpfields index 1.
  lt_dynpfields-fieldvalue = v_nomina.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
  modify  lt_dynpfields index 1.


*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  read table lt_dynpfields index 2.
  CONCATENATE 'C:\TRANSFER\' bukrs '_BCHILE' '_' sy-datum '_' sy-uzeit '.txt' INTO
  lt_dynpfields-fieldvalue.

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
  modify  lt_dynpfields index 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
    TABLES
      dynpfields = lt_dynpfields.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR v_nomina.

  refresh lt_dynpfields.
  lt_dynpfields-fieldname = 'BUKRS'.
  append lt_dynpfields.


  lv_dynpro_prog = sy-repid.

  call function 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.


*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  read table lt_dynpfields index 1.
  bukrs = lt_dynpfields-fieldvalue .
  TRANSLATE bukrs TO UPPER CASE.

  REFRESH TLAUFK.
  TLAUFK-LAUFK = SPACE.
  TLAUFK-SIGN  = 'I'.
  APPEND TLAUFK.
  CALL FUNCTION 'ZF4_ZAHLLAUF'
    EXPORTING
      F1TYP = 'I'
      F2NME = 'F110V-LAUFD'
      BUKRS = bukrs
      BANCO = '001'
    IMPORTING
      LAUFD = v_fecha
      LAUFI = v_nomina
    TABLES
      LAUFK = TLAUFK.

  refresh lt_dynpfields.
  lt_dynpfields-fieldname = 'V_FECHA'.
  append lt_dynpfields.
  lt_dynpfields-fieldname = 'ARCHIVO'.
  append lt_dynpfields.

  lv_dynpro_prog = sy-repid.

  call function 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb     = '1000'
    TABLES
      dynpfields = lt_dynpfields.

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  read table lt_dynpfields index 1.
  concatenate v_fecha+06(2) '.' v_fecha+04(2) '.' v_fecha+0(4) into lt_dynpfields-fieldvalue.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
  modify  lt_dynpfields index 1.


*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  read table lt_dynpfields index 2.
  CONCATENATE 'C:\TRANSFER\' bukrs '_BCHILE' '_' sy-datum '_' sy-uzeit '.txt' INTO
   lt_dynpfields-fieldvalue.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
  modify  lt_dynpfields index 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
    TABLES
      dynpfields = lt_dynpfields.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo .
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = archivo.

INITIALIZATION.

  CONCATENATE archivo  'BCHILE' '_' sy-datum '_' sy-uzeit '.txt' INTO
  archivo.
  CONDENSE archivo NO-GAPS.


START-OF-SELECTION.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single * from reguh
*                 where laufd       = V_fecha
*                 and   laufi       = V_nomina
*                 and   ZBUKR       = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  from reguh
                 where laufd       = V_fecha
                 and   laufi       = V_nomina
                 and   ZBUKR       = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


  if sy-subrc <> 0.
    MESSAGE E004(ZFI) WITH 'Nomina no corresponde a Sociedad' BUKRS.

  endif.

  PERFORM bancos.
  SORT t_bancos BY cod_ac.

* Rescatamos Datos.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *  FROM  reguh
*           WHERE  laufd      = v_fecha
*           AND    laufi      = v_nomina
*           and    xvorl      = ' '
*           and    UBNKL      = '001'
*           and  ( RZAWE      = 'T' or RZAWE = 'V' ).
*
* NEW CODE
  SELECT *
  FROM  reguh
           WHERE  laufd      = v_fecha
           AND    laufi      = v_nomina
           and    xvorl      = ' '
           and    UBNKL      = '001'
           and  ( RZAWE      = 'T' or RZAWE = 'V' ) ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
 bukrs = reguh-ZBUKR.
*    IF ( reguh-stcd1 IS INITIAL ) OR ( reguh-zstc1 IS INITIAL ).
*      select single stcd1 into reguh-stcd1
*        from lfa1 where lifnr = reguh-lifnr.
*    ENDIF.
"INICIO HCD 06-10-2020 HCD
contar   = contar   + 1.
sumpagos = sumpagos + ( reguh-rbetr * -100 ).
CONCATENATE  reguh-zaldt+6(2) reguh-zaldt+4(2) reguh-zaldt+0(4) INTO zaldt.
CONCATENATE  reguh-valut+6(2) reguh-valut+4(2) reguh-valut+0(4) INTO zvalut.
cuenta = reguh-ubhkt.
CONCATENATE cuenta+0(9) '3' INTO cuenta_2.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
* SELECT  SINGLE bktxt INTO  bktxt FROM bkpf
*                               WHERE bukrs      = bukrs
*                                 AND belnr = reguh-vblnr
*                                 AND gjahr = reguh-zaldt(4).
*
* NEW CODE
 SELECT bktxt
 UP TO 1 ROWS  INTO  bktxt FROM bkpf
                               WHERE bukrs      = bukrs
                                 AND belnr = reguh-vblnr
                                 AND gjahr = reguh-zaldt(4) ORDER BY PRIMARY KEY.

 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

 bktxtasi  =  bktxt(8)." HCD 20210329 se solicita que texto de asignacion se coloque en el comprobante
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
*                                         AND laufi = reguh-laufi
*                                         AND xvorl = reguh-xvorl
*                                         AND zbukr = reguh-zbukr
*                                         AND lifnr = reguh-lifnr
*                                         AND kunnr = reguh-kunnr
*                                         AND empfg = reguh-empfg
*                                         AND vblnr = reguh-vblnr.
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
*          SELECT SINGLE  * FROM  bseg  WHERE bukrs = regup-bukrs
*                                         AND belnr = regup-belnr
*                                         AND gjahr = regup-gjahr
*                                         AND buzei = regup-buzei.
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
"FIN HCD 06-10-2020 HCD
    IF ( reguh-stcd1 IS INITIAL ) OR ( reguh-zstc1 IS INITIAL ).
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single stcd1 ADRNR into (reguh-stcd1, reguh-ADRNR)
*        from lfa1 where lifnr = reguh-lifnr.
*
* NEW CODE
      SELECT stcd1 ADRNR
      UP TO 1 ROWS  into (reguh-stcd1, reguh-ADRNR)
        from lfa1 where lifnr = reguh-lifnr ORDER BY PRIMARY KEY.

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
*      SELECT SINGLE *
*      FROM zlog_pago_bancos
*         WHERE bukrs = bukrs
*           AND ubnkl = '001'
*           AND laufd = v_fecha
*           AND laufi = v_nomina.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS 
      FROM zlog_pago_bancos
         WHERE bukrs = bukrs
           AND ubnkl = '001'
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
  "  CHECK par_di EQ 'X'.
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

  reg_stder-zbukr = tabla_00-zbukr.

  TRANSLATE tabla_00-stcd1 USING '- ' .
  CONDENSE  tabla_00-stcd1 NO-GAPS    .

* Se ajusta Rut a la Izquierda.
  WRITE tabla_00-stcd1 TO reg_stder-rut_prov left-JUSTIFIED.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single smtp_addr into reg_stder-mail from adr6 where ADDRNUMBER = tabla_00-ADRNR.
*
* NEW CODE
  SELECT smtp_addr
  UP TO 1 ROWS  into reg_stder-mail from adr6 where ADDRNUMBER = tabla_00-ADRNR ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


  TRANSLATE   tabla_00-zbnkn USING '- '.
  CONDENSE    tabla_00-zbnkn NO-GAPS.
  CONDENSE    tabla_00-zbnkl NO-GAPS.

  reg_stder-nombre           =  tabla_00-znme1.
  reg_stder-suc_retiro = '000'.
  reg_stder-codigo_banco     =  tabla_00-zbnkl.
  reg_stder-cuenta_abono     =  tabla_00-zbnkn.

  IF tabla_00-rzawe = 'V'.
    reg_stder-codigo_banco = '000'.
    clear reg_stder-cuenta_abono.
  endif.

  clear REG_STDER-MOD_PAGO.



  IF tabla_00-rzawe = 'V'.
    reg_stder-mod_pago = '02'.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE    CLAVE INTO P_CLAVE
*                     FROM  ZFITR001
*                     WHERE BANKL = '001'
*                     AND   BKONT = TABLA_00-ZBKON.
*
* NEW CODE
    SELECT CLAVE
    UP TO 1 ROWS  INTO P_CLAVE
                     FROM  ZFITR001
                     WHERE BANKL = '001'
                     AND   BKONT = TABLA_00-ZBKON ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF SY-SUBRC EQ 0.
      CONDENSE P_CLAVE NO-GAPS.
      REG_STDER-MOD_PAGO  = P_CLAVE.
    ENDIF.


    if reg_stder-codigo_banco <> '001'.
      reg_stder-mod_pago = '07'.
    endif.

    if REG_STDER-MOD_PAGO is initial.
      if reg_stder-codigo_banco = '001'.
        reg_stder-mod_pago = '01'.
      else.
        reg_stder-mod_pago = '07'.
      endif.
    ENDIF.
  endif.

  acreedor = tabla_00-lifnr.

****Es multisociedad?

  IF tabla_00-zbukr <> tabla_00-absbu.  " Soc_pagadora y Soc.emisora
*** buscamos ejercicio del docto de pago
*    SELECT SINGLE * FROM  bseg
*                    WHERE bukrs   = tabla_00-zbukr
*                    AND   belnr   = tabla_00-vblnr
*                    AND   zfbdt   = tabla_00-zaldt
*                    AND   koart   = 'K'.
*
*    IF sy-subrc = 0.
*      eje_pago = bseg-gjahr.
*    ENDIF.
*
*
******
*    SELECT SINGLE * FROM  bkpf
*           WHERE  bukrs  = tabla_00-zbukr
*           AND    belnr  = tabla_00-vblnr
*           AND    gjahr  = eje_pago.
*
*    CALL FUNCTION 'GET_CLEARED_ITEMS'
*      EXPORTING
*        i_belnr                = tabla_00-vblnr  " doc depago
*        i_bukrs                = tabla_00-zbukr  " soc pagadora
*        i_gjahr                = bkpf-gjahr
*        i_bvorg                = bkpf-bvorg
*      TABLES
*        t_items                = t_items
*      EXCEPTIONS
*        not_found              = 1
*        error_cleared_accounts = 2
*        OTHERS                 = 3.
*
*    IF sy-subrc <> 0.
*
*    ENDIF.
*
*    LOOP AT t_items.
*      IF t_items-augbl = t_items-belnr.
*        DELETE  t_items INDEX sy-tabix.
*      ELSE.
*        soc_pago = t_items-bukrs.
*        doc_pago = t_items-augbl.
*        PERFORM paga_sociedad.
*      ENDIF.
*    ENDLOOP.

SELECT * FROM REGUP CLIENT SPECIFIED
WHERE MANDT = SY-MANDT
AND LAUFD = V_FECHA
AND LAUFI = V_NOMINA
AND XVORL = ' '
AND LIFNR = ACREEDOR
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND VBLNR = TABLA_00-VBLNR.
AND VBLNR = TABLA_00-VBLNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *

      PERFORM PAGA_SOCIEDAD_.
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
  refresh T_DOCTOS.
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
FORM PAGA_SOCIEDAD_ .
  refresh T_DOCTOS.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM BSAK CLIENT SPECIFIED
*          WHERE MANDT   = SY-MANDT
*            AND  BUKRS  = REGUP-BUKRS    " soc.pagadora
*            AND  BELNR  = REGUP-BELNR    " Núm. doc.
*            AND  GJAHR  = REGUP-GJAHR
*            AND  BUZEI  = REGUP-BUZEI
*            AND  LIFNR  = REGUP-LIFNR.
*
* NEW CODE
  SELECT *
 FROM BSAK CLIENT SPECIFIED
          WHERE MANDT   = SY-MANDT
            AND  BUKRS  = REGUP-BUKRS    " soc.pagadora
            AND  BELNR  = REGUP-BELNR    " Núm. doc.
            AND  GJAHR  = REGUP-GJAHR
            AND  BUZEI  = REGUP-BUZEI
            AND  LIFNR  = REGUP-LIFNR ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    CHECK BSAK-AUGBL <>  BSAK-BELNR.
    MOVE-CORRESPONDING BSAK TO T_DOCTOS.
**      el valor sera el total menos retencion
*        t_doctos-wrbtr = t_doctos-wrbtr - t_doctos-qbshb.
    APPEND T_DOCTOS.
  ENDSELECT.

  IF SY-SUBRC = 0.
    PERFORM DISTRIBUCION.
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
    t_doctos-dmbtr = t_doctos-dmbtr * 10000.
    t_doctos-dmbtr = ABS( t_doctos-dmbtr ).

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  BKPF
*         WHERE  BUKRS  = t_doctos-bukrs
*         AND    BELNR  = t_doctos-belnr
*         AND    GJAHR  = t_doctos-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  BKPF
         WHERE  BUKRS  = t_doctos-bukrs
         AND    BELNR  = t_doctos-belnr
         AND    GJAHR  = t_doctos-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    if sy-subrc = 0 and bkpf-xblnr is not initial.
      condense BKPF-XBLNR no-gaps.
      num_doc = bkpf-xblnr.
    endif.

    reg_stder-num_docto      = num_doc.

    if reg_stder-num_docto  = '0000000000'.
      condense t_doctos-zuonr no-gaps.
      num_doc = t_doctos-zuonr.
      reg_stder-num_docto      = num_doc.
    endif.


    IF t_doctos-shkzg = 'S'.
      t_doctos-dmbtr =   t_doctos-dmbtr * -1.
    ENDIF.
" HCD 21092021 se agrega clase de documento AB

" agrego reglas propias para clinica viña HCD 01-06-2023 INI
 if t_doctos-bukrs ='CL29' or t_doctos-bukrs = 'CL30'.
    case t_doctos-BLART.
      when 'F1' or 'F2' or 'F3' or 'F4' or 'F5' or 'F6' or 'F0' or 'FA' or 'AB'."HCD 02.07.2014 agrego tipo documento F0 se agrega AB 022022
        reg_stder-tipo_docto = '30'.
      when 'N1' or 'N2' or 'N3' or 'N4' or 'N0' or 'NA'. " HCD 02.07.2014 agrego tipo documento N0 se agrega NA 022022
        reg_stder-tipo_docto = '60'.
      when 'D1' or 'D2' or 'D3' or 'D4'.
        reg_stder-tipo_docto = '55'.
      when 'B1' or 'B2' or 'B3' or 'B4' or 'B5' or 'B6'." HCD 02-06-2021 HCD se agrega clase boleta B6
* HCD 18.06.2014 agrego tipo documento B5
*        reg_stder-tipo_docto = '35'.
* Se cambia el tipo 35 por 39 HCD 17.06.2014
         reg_stder-tipo_docto = '35'.
      when 'F7' .
        reg_stder-tipo_docto = '30'.
      when 'SA' .
        reg_stder-tipo_docto = '999'.
    endcase.

else.
    case t_doctos-BLART.
      when 'F1' or 'F2' or 'F3' or 'F4' or 'F5' or 'F6' or 'F0' or 'FA' or 'AB'."HCD 02.07.2014 agrego tipo documento F0 se agrega AB 022022
        reg_stder-tipo_docto = '30'.
      when 'N1' or 'N2' or 'N3' or 'N4' or 'N0' or 'NA'. " HCD 02.07.2014 agrego tipo documento N0 se agrega NA 022022
        reg_stder-tipo_docto = '60'.
      when 'D1' or 'D2' or 'D3' or 'D4'.
        reg_stder-tipo_docto = '55'.
      when 'B1' or 'B2' or 'B3' or 'B4' or 'B5' or 'B6'." HCD 02-06-2021 HCD se agrega clase boleta B6
* HCD 18.06.2014 agrego tipo documento B5
*        reg_stder-tipo_docto = '35'.
* Se cambia el tipo 35 por 39 HCD 17.06.2014
         reg_stder-tipo_docto = '39'.
      when 'F7' .
        reg_stder-tipo_docto = '30'.
      when 'SA' .
        reg_stder-tipo_docto = '999'.
    endcase.
   ENDIF.

" agrego reglas propias para clinica viña HCD 01-06-2023 FIN
    reg_stder-uno           = 1.
    reg_stder-monto_docto   = t_doctos-dmbtr.
    reg_stder-fecha_emision = t_doctos-BLDAT.
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

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                  = nombre_a
      filetype                  = 'ASC'
      confirm_overwrite         = 'X'
      TRUNC_TRAILING_BLANKS_EOL = ''
    TABLES
      data_tab                  = out_reg_stder
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
  refresh t_bancos.
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

  read table tabla_00 index 1.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM  bkpf
*        WHERE  bukrs  = tabla_00-zbukr   " Soc. Paga
*        AND    belnr  = tabla_00-vblnr.  
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  bkpf
        WHERE  bukrs  = tabla_00-zbukr   " Soc. Paga
        AND    belnr  = tabla_00-vblnr ORDER BY PRIMARY KEY.  

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01" Doc. pago


  monto_p = 0.

  sort tabla_00 by STCD1.
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

*      SELECT SINGLE * FROM  bkpf
*            WHERE  bukrs  = tabla_00-zbukr   " Soc. Paga
*            AND    belnr  = tabla_00-vblnr.  " Doc. pago
*
*
*      CALL FUNCTION 'GET_CLEARED_ITEMS'
*        EXPORTING
*          i_belnr                = tabla_00-vblnr  " doc depago
*          i_bukrs                = tabla_00-zbukr  " soc pagadora
*          i_gjahr                = bkpf-gjahr
*          i_bvorg                = bkpf-bvorg
*        TABLES
*          t_items                = t_items
*        EXCEPTIONS
*          not_found              = 1
*          error_cleared_accounts = 2
*          OTHERS                 = 3.
*
*      IF sy-subrc <> 0.
*
*      ENDIF.
*
**Buscamos los documentos
*      LOOP AT t_items.
*        IF t_items-augbl = t_items-belnr.
*          DELETE  t_items INDEX sy-tabix.
*        ELSE.
*          soc_pago = t_items-bukrs.
*          doc_pago = t_items-augbl.
*          PERFORM doctos__.
*        ENDIF.
*      ENDLOOP.

SELECT * FROM REGUP CLIENT SPECIFIED
WHERE MANDT = SY-MANDT
AND LAUFD = V_FECHA
AND LAUFI = V_NOMINA
AND XVORL = ' '
AND LIFNR = tabla_00-lifnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND VBLNR = TABLA_00-VBLNR.
AND VBLNR = TABLA_00-VBLNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
        soc_pago = tabla_00-zbukr.
        doc_pago = tabla_00-vblnr.

        PERFORM DOCTOS__2.
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


top-of-page.
  WRITE : /1  t001-BUTXT,
           43   'NOMINA DE PAGO PROVEEDORES CUENTA BANCO DE CHILE' ,
           120 sy-datum,

          /120 sy-UZEIT ,
          /27 'Identificación De Propuesta de Pago : ',
              'Fecha Nomina: ',v_fecha, ' Nomina:' ,  v_nomina ,
          120 sy-PAGNO,
          / ,
          /'Fecha Contabilizacion Pago: ', bkpf-BUDAT.

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
  refresh t_doctos.


*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
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
             091 t_doctos-ZFBDT,
             101 t_doctos-dmbtr CURRENCY 'CLP'.
    hide: tabla_00-vblnr,soc_pago, eje_pago.

    t_monto = t_monto  + t_doctos-dmbtr.
    monto_p  = monto_p + t_doctos-dmbtr.

  ENDLOOP.

  clear tabla_00-vblnr .

  monto_y = t_monto .

  monto_z = monto_z + monto_y.
ENDFORM.                    "doctos__

*&---------------------------------------------------------------------*
*&      Form  DOCTOS__2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOCTOS__2 .

  ACREEDOR = TABLA_00-LIFNR.
  CLEAR T_DOCTOS[].

  eje_pago = tabla_00-zaldt+0(4).

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM BSAK CLIENT SPECIFIED
*           WHERE MANDT   = SY-MANDT
*             AND  BUKRS  = REGUP-BUKRS    " soc.pagadora
*             AND  BELNR  = REGUP-BELNR    " Núm. doc.
*             AND  GJAHR  = REGUP-GJAHR
*             AND  BUZEI  = REGUP-BUZEI
*             AND  LIFNR  = REGUP-LIFNR.
*
* NEW CODE
  SELECT *
 FROM BSAK CLIENT SPECIFIED
           WHERE MANDT   = SY-MANDT
             AND  BUKRS  = REGUP-BUKRS    " soc.pagadora
             AND  BELNR  = REGUP-BELNR    " Núm. doc.
             AND  GJAHR  = REGUP-GJAHR
             AND  BUZEI  = REGUP-BUZEI
             AND  LIFNR  = REGUP-LIFNR ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


    CHECK BSAK-AUGBL <>  BSAK-BELNR.

    MOVE-CORRESPONDING BSAK TO T_DOCTOS.

    APPEND T_DOCTOS.
  ENDSELECT.

  LOOP AT T_DOCTOS.

* Buscamos textos
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  BKPF CLIENT SPECIFIED
*            WHERE  MANDT  = SY-MANDT
*            AND    BUKRS  = T_DOCTOS-BUKRS          " Soc. Paga
*            AND    GJAHR  = T_DOCTOS-GJAHR
*            AND    BELNR  = T_DOCTOS-BELNR.   
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  BKPF CLIENT SPECIFIED
            WHERE  MANDT  = SY-MANDT
            AND    BUKRS  = T_DOCTOS-BUKRS          " Soc. Paga
            AND    GJAHR  = T_DOCTOS-GJAHR
            AND    BELNR  = T_DOCTOS-BELNR ORDER BY PRIMARY KEY.   

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01" Doc. pago

*Invertimos signo para el listado

    IF T_DOCTOS-SHKZG = 'S'.
      T_DOCTOS-DMBTR = T_DOCTOS-DMBTR * -1.
    ENDIF.

    T_DOCTOS-DMBTR = T_DOCTOS-DMBTR .



    WRITE : /001 tabla_00-rzawe ,
             003 tabla_00-vblnr  ,  " t_doctos-belnr ,
             014 tabla_00-absbu       ,
             019 bkpf-xblnr     ,  " bkpf-bktxt
             037 tabla_00-stcd1 ,
             054 tabla_00-znme1 ,
             091 t_doctos-zfbdt,
             101 t_doctos-dmbtr CURRENCY 'CLP'.
    HIDE: tabla_00-vblnr,soc_pago, eje_pago.

*    WRITE : /001 TABLA_00-RZAWE ,
*             003 TABLA_00-VBLNR ,  " t_doctos-belnr ,
*             014 TABLA_00-ABSBU ,
*             019 BKPF-XBLNR     ,  " bkpf-bktxt
*             037 TABLA_00-STCD1 ,
*             054 TABLA_00-ZNME1 ,
*             090 T_DOCTOS-DMBTR CURRENCY 'CLP'.



    T_MONTO = T_MONTO  + T_DOCTOS-DMBTR.
    MONTO_P  = MONTO_P + T_DOCTOS-DMBTR.

  ENDLOOP.

  MONTO_Y = T_MONTO .

  MONTO_Z = MONTO_Z + MONTO_Y.

  clear T_MONTO.

ENDFORM.                                                    " DOCTOS__2



AT LINE-SELECTION.
  IF not tabla_00-vblnr is initial.
    SET PARAMETER ID 'BLN' FIELD tabla_00-vblnr.
    SET PARAMETER ID 'BUK' FIELD soc_pago.
    SET PARAMETER ID 'GJR' FIELD eje_pago.
    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDIF.

  clear tabla_00-vblnr .


*&---------------------------------------------------------------------*
*&      Form  PREPARO_SALIDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PREPARO_SALIDA.
  data: rut(10)  type c.
  data: largo(3) type n.
  data: numero(4) type n.
  data: reg_stder_x  like reg_stder occurs 0 with header line.

  refresh out_reg_stder.
  clear out_reg_stder.

  sort reg_stder  by zbukr rut_prov.

  reg_stder_x[] = reg_stder[].

  loop at reg_stder.
    at new  zbukr .
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single paval into rut from t001z where bukrs = reg_stder-zbukr
*                                   and   party = 'TAXNR' .
*
* NEW CODE
      SELECT paval
      UP TO 1 ROWS  into rut from t001z where bukrs = reg_stder-zbukr
                                   and   party = 'TAXNR'  ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    endat.

    at new  rut_prov.
      REG01-Cantidad_pago = REG01-Cantidad_pago  + 1.
    endat.

    at last.
      sum.
      REG01-tr = '01'.
      REG01-rut_emp = rut+0(8).
      REG01-rut_emp_dv = rut+9(1).
      REG01-monto_total_pago = reg_stder-monto_docto.
      REG01-Cantidad_docto   = reg_stder-uno.
      move REG01 to out_reg_stder-reg.
      append out_reg_stder.
    ENDAT.
  endloop.

  numero = 1.

  loop at reg_stder.
    REG02-tr = '02'.
    largo = strlen( reg_stder-rut_prov ).
    largo =  largo - 1.
    REG02-rut_prv_dv = reg_stder-rut_prov+largo(1).
    REG02-rut_prv = reg_stder-rut_prov+0(largo).
    REG02-nombre_prv = reg_stder-nombre.
    REG02-direccion   = ''.
    REG02-comuna      = ''.
    REG02-ciudad      = ''.
    if REG02-rut_prv < 30000000.
      REG02-actividad  = 'B1'.
    else.
      REG02-actividad  = 'BC'.
    endif.
    REG02-fecha_pago+0(2)   = v_pago+6(2).
    REG02-fecha_pago+2(2)   = v_pago+4(2).
    REG02-fecha_pago+4(4)   = v_pago+0(4).
    REG02-medio_pago = reg_stder-mod_pago.
    REG02-cod_banco = reg_stder-codigo_banco.
    REG02-of_destino = 0.
    REG02-cuenta =   reg_stder-cuenta_abono.
    concatenate 'PAGO DE DOCUMENTOS POR PARTE DE' t001-BUTXT into REG02-des_pago separated by space.
    REG02-vv_acumulado = 'N'.
    REG02-rut_con = reg_stder-rut_prov+0(largo).
    REG02-rut_con_dv = reg_stder-rut_prov+largo(1).
    REG02-Nombre_contacto = reg_stder-nombre.
    if reg_stder-mail is initial.
      REG02-canal_aviso = ''.
    else.
      REG02-canal_aviso = '1'.
    endif.
    REG02-codigo_area = ''.
    REG02-numero_fono_fax = ''.
    REG02-mail1 = reg_stder-mail.
    REG02-mail2 = ''.

    .

    at end of rut_prov.
      sum.
      if reg_stder-monto_docto < 0.
        REG02-monto_pago = reg_stder-monto_docto *  -1.
      else.
        REG02-monto_pago = reg_stder-monto_docto.
      endif.

      REG02-num_aviso = numero.

      move REG02 to out_reg_stder-reg.
      append out_reg_stder.

      loop at reg_stder_x where zbukr      = reg_stder-zbukr
                            and   rut_prov = reg_stder-rut_prov.

        REG03-tr         = '03'.
        REG03-tipo_docto = reg_stder_x-tipo_docto.
        REG03-num_docto  =  reg_stder_x-num_docto.
        REG03-num_cuota  = 0.
        if reg_stder-monto_docto < 0.
          REG03-monto_pago  = reg_stder_x-monto_docto *  -1.
          REG03-monto_docto = reg_stder_x-monto_docto *  -1.
        else.
          REG03-monto_pago  = reg_stder_x-monto_docto.
          REG03-monto_docto = reg_stder_x-monto_docto.
        endif.
        REG03-fecha_emision+0(2)  = reg_stder_x-fecha_emision+6(2).
        REG03-fecha_emision+2(2)  = reg_stder_x-fecha_emision+4(2).
        REG03-fecha_emision+4(4)  = reg_stder_x-fecha_emision+0(4).

        if reg_stder_x-tipo_docto = '30'.
          concatenate 'PAGO/FA-' REG03-num_docto REG02-nombre_prv into REG03-desc_docto.
        elseif reg_stder_x-tipo_docto = '39' . " Se cambia el tipo '35' por '39' HCD 17.06.2014
          concatenate 'PAGO/BO-' REG03-num_docto REG02-nombre_prv into REG03-desc_docto.
        elseif reg_stder_x-tipo_docto = '55' .
          concatenate 'PAGO/ND-' REG03-num_docto REG02-nombre_prv into REG03-desc_docto.
        else.
          concatenate 'PAGO/NC-' REG03-num_docto REG02-nombre_prv into REG03-desc_docto.
        endif.

        move REG03 to out_reg_stder-reg.
        append out_reg_stder.
      endloop.

      REG04-tr = '04'.
      REG04-num_aviso = numero.
      concatenate 'SE A EFECTUADO EL PAGO DE DOCUMENTOS POR PARTE DE' t001-BUTXT ', FAVOR CONFIRMAR PAGOS' into REG04-glosa_aviso separated by space.
      REG04-corr_aviso = numero.
      move REG04 to out_reg_stder-reg.
      append out_reg_stder.
      numero = numero + 1.

    endat.

  endloop.


ENDFORM.                    " PREPARO_SALIDA

"HCD 05-10-2020 Agfrego log
FORM grabar_log.
    zlog_pago_bancos-bukrs = bukrs.
    zlog_pago_bancos-ubnkl = '001'.
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
                                bktxtasi."bktxt." se cambia xblnr. por bktxt por solicitur de usuario HCD 20200122

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
                                bktxtasi."bktxt." se cambia xblnr. por bktxt por solicitur de usuario HCD 20200122

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

  ENDFORM.
