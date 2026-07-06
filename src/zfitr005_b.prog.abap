*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFITR005_B
*&
*&---------------------------------------------------------------------*
*&
*&Genera archivo de transfer para Bco estado.
*&---------------------------------------------------------------------*
REPORT zfitr005_B NO STANDARD PAGE HEADING
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
   DATA: ti_adrc       TYPE adrc       OCCURS 0 WITH HEADER LINE,
       " t_items       TYPE bapi3008_2 OCCURS 0 WITH HEADER LINE,
        ti_set_fac    LIKE setleaf    OCCURS 0 WITH HEADER LINE,
        ti_set_ncr    LIKE setleaf    OCCURS 0 WITH HEADER LINE,
        ti_bsak       LIKE bsak       OCCURS 0 WITH HEADER LINE,
        ti_exc        LIKE zfitr005   OCCURS 0 WITH HEADER LINE,
        itab          TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.
        "lt_dynpfields LIKE dynpread   OCCURS 1 WITH HEADER LINE.
DATA : BEGIN OF tabla_00 OCCURS 0.
        INCLUDE STRUCTURE reguh.
DATA : END OF tabla_00 .

DATA : monto_total(13)                    ,
       total_proveedor LIKE tabla_00-rwbtr.

DATA : BEGIN OF t_bancos OCCURS 0     ,
         cod_ac      LIKE reguh-zbnkl ,
         cod_nw(03)  TYPE c           ,
       END OF t_bancos                .




DATA : BEGIN OF ctachile,
           cta(12)              TYPE c,
           filler(10)           TYPE c,
END OF ctachile.

" cambio monto_docto(13) por monto_docto(10) HCD 20120628
DATA : BEGIN OF reg_stder OCCURS 0,
           zbukr(04)           TYPE c ,
           rut_prov(11)        TYPE c ,
           cod_prov(10)        TYPE c ,
           nombre(40)          TYPE c ,
           mail(35)            TYPE c ,
           suc_retiro(03)      TYPE n ,
           mod_pago(03)        TYPE c ,
           codigo_banco(03)    TYPE c ,
           cuenta_abono(18)    TYPE c ,
           docto_sap1(10)      TYPE c,
           fecha_emision(08)   TYPE c,
           fecha_vcto(08)      TYPE c,
           blart(2)            TYPE c,
           num_docto(10)       TYPE n ,
           monto_docto(10)     TYPE p  DECIMALS 0," cambio de 13 a 10
           signo_docto(01)     TYPE c ,
           docto_sap2(10)      TYPE c,
           rut_ret(11)         TYPE c ,
           nombre_ret(40)      TYPE c ,
           codigo(11)          TYPE c,"HCD 20120424
           via_pago(1)         TYPE c,"HCD 20120424
END OF reg_stder.

" Cambio valor_info(12) a valor_info(10) valor_pago(12) a valor_pago(10) HCD 20120628
DATA : BEGIN OF out_reg_stder,
           mod_servico(1)           TYPE c,
           rut_prv(08)              TYPE n,
           rut_prv_dvr(01)          TYPE c,
           unidad(5)                TYPE c,
           nombre_prv(45)           TYPE c,
           medio_aviso(1)           TYPE c,
           direc_aviso(35)          TYPE c,
           comuna_aviso(4)          TYPE n,
           forma_pago(3)            TYPE c,
           cod_banco(03)            TYPE n,
           cuenta_cte(20)           TYPE n,
           cod_sucursal(03)         TYPE n,
           tipo_docto(03)           TYPE c,
           nro_docto(10)            TYPE n,
           nro_docto_rel(10)        TYPE n,
           valor_info(10)           TYPE n, " cambio de 12 a 10
           valor_pago(10)           TYPE n, " cambio de 12 a 10
           nro_doctox(12)            TYPE n,
           nro_docto_relx(12)        TYPE n,
           valor_infox(10)           TYPE n," cambio de 11 a 10
           valor_pagox(10)           TYPE n," cambio de 11 a 10
           estado_pago(03)          TYPE c,
           fecha_vcto(08)           TYPE c,
           fecha_pago(8)            TYPE c,
           glosa(200)               TYPE c,
           rut_ret1(08)             TYPE n,
           rut_ret1_dvr(01)         TYPE c,
           paterno1(15)             TYPE c,
           materno1(15)             TYPE c,
           nombre1(15)              TYPE c,
           rut_ret2(08)             TYPE n,
           rut_ret2_dvr(01)         TYPE c,
           paterno2(15)             TYPE c,
           materno2(15)             TYPE c,
           nombre2(15)              TYPE c,
           codigo(11)               TYPE c, "HCD 20120424
       END OF out_reg_stder .


DATA : BEGIN OF out_reg_stder_x OCCURS 0,
          registro(505)            TYPE  c,

       END OF out_reg_stder_x .

DATA : BEGIN OF out_reg_stder_x1 OCCURS 0,
          registro(257),
       END OF out_reg_stder_x1 .





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
       p_clave(40) TYPE c,
       adrnr       LIKE lfa1-adrnr,
        cuenta           LIKE reguh-ubhkt, "HCD 05-10-2020
        cuenta_2         LIKE reguh-ubhkt, "HCD 05-10-2020
        cuenta5           LIKE reguh-ubhkt, "HCD 05-10-2020
        cuenta3          LIKE reguh-ubhkt, "HCD 05-10-2020
        secuencia(2)     TYPE n, "HCD 05-10-2020
         sumpagos(15)     TYPE n, "HCD 05-10-2020
 lineas(5)        TYPE n,"HCD 05-10-2020
 gjahr            LIKE bkpf-gjahr,"HCD 05-10-2020
 contar(6)        TYPE n,"HCD 05-10-2020
 zaldt            LIKE reguh-zaldt,"HCD 05-10-2020
  zzmot_emis       LIKE bseg-zzmot_emis,"HCD 05-10-2020
 contabilizar(1), "HCD 05-10-2020
 resp(1), "HCD 05-10-2020
  total            LIKE bseg-dmbtr, "HCD 05-10-2020
  xblnr            LIKE bkpf-xblnr, "HCD 05-10-2020
        bktxt            LIKE bkpf-bktxt, "HCD 05-10-2020
  zvalut            LIKE reguh-valut, "HCD 05-10-2020
        belnr            LIKE bkpf-belnr,"HCD 05-10-2020
         v_nrotra   LIKE  zlog_pago_bancos-nrotran,"HCD 05-10-2020
       codigo(11)   TYPE c. " Agrego variable codigo para proceso de CL13 CL17 HCD 20120424

FIELD-SYMBOLS : <nombre1_> TYPE ANY ,
                <nombre2_> TYPE ANY ,
                <nombre3_> TYPE ANY .

DATA:  nombre1(25)          ,
       nombre2(25)          ,
       nombre3(25)          ,
       ndx(02)      TYPE n  ,
       lins(04)     TYPE c VALUE 0,
       num_doc(8)   TYPE c.
DATA: v_rut_ret(12).
DATA: v_nombre_ret(40).


DATA:    BEGIN OF tlaufk OCCURS 1.
        INCLUDE STRUCTURE ilaufk.
DATA:    END OF tlaufk.

DATA lt_dynpfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
DATA lv_dynpro_prog LIKE d020s-prog.


*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.
PARAMETER : bukrs    LIKE bkpf-bukrs     OBLIGATORY,
            v_fecha  LIKE reguh-laufd    OBLIGATORY,
            v_nomina LIKE f110v-laufi    OBLIGATORY,
            v_fecpag LIKE reguh-laufd    OBLIGATORY.

PARAMETER  : archivo     LIKE rlgrap-filename DEFAULT 'C:\TRANSFER\'.

PARAMETERS : par_tes RADIOBUTTON GROUP test       " Ejecución en Test
                     DEFAULT 'X',
             par_di  RADIOBUTTON GROUP test.      " Ejecución real

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

  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.


  SELECT SINGLE * FROM zfitr002 WHERE bukrs = bukrs.

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
SORT LT_DYNPFIELDS .
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
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 1.


*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 2.
  CONCATENATE 'C:\TRANSFER\' bukrs '_EST01' '_' sy-datum '_' sy-uzeit '.txt' INTO
  lt_dynpfields-fieldvalue.

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
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
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 1.


*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 2.
  CONCATENATE 'C:\TRANSFER\' bukrs '_EST01' '_' sy-datum '_' sy-uzeit '.txt' INTO
   lt_dynpfields-fieldvalue.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
SORT LT_DYNPFIELDS .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  MODIFY  lt_dynpfields INDEX 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
    TABLES
      dynpfields = lt_dynpfields.

INITIALIZATION.

  CONCATENATE archivo 'EST01' '_' sy-datum '_' sy-uzeit '.txt' INTO
  archivo.
  CONDENSE archivo NO-GAPS.


START-OF-SELECTION.

  SELECT SINGLE * FROM reguh
                 WHERE laufd       = v_fecha
                 AND   laufi       = v_nomina
                 AND   zbukr       = bukrs.


  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Nomina no corresponde a Sociedad' bukrs.

  ENDIF.
CONCATENATE  reguh-zaldt+6(2) reguh-zaldt+4(2) reguh-zaldt+0(4) INTO zaldt.
CONCATENATE  reguh-valut+6(2) reguh-valut+4(2) reguh-valut+0(4) INTO zvalut.
  PERFORM bancos.
  SORT t_bancos BY cod_ac.

* Rescatamos Datos.
  SELECT *  FROM  reguh
           WHERE  laufd       = v_fecha
             AND  laufi       = v_nomina
             AND  xvorl       = ' '
             AND  ubnkl       = '012'
             AND  ( rzawe     = 'T' OR rzawe = 'V' ).
 contar   = contar   + 1.
 sumpagos = sumpagos + ( reguh-rbetr * -100 ).
 CONCATENATE  reguh-zaldt+6(2) reguh-zaldt+4(2) reguh-zaldt+0(4) INTO zaldt.
CONCATENATE  reguh-valut+6(2) reguh-valut+4(2) reguh-valut+0(4) INTO zvalut.
 lineas  =  contar.
 cuenta = reguh-ubhkt.
  CONCATENATE cuenta+0(9) '3' INTO cuenta_2.
 SELECT  SINGLE bktxt INTO  bktxt FROM bkpf
                               WHERE bukrs      = bukrs
                                 AND belnr = reguh-vblnr
                                 AND gjahr = reguh-zaldt(4).
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
          SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
                                         AND laufi = reguh-laufi
                                         AND xvorl = reguh-xvorl
                                         AND zbukr = reguh-zbukr
                                         AND lifnr = reguh-lifnr
                                         AND kunnr = reguh-kunnr
                                         AND empfg = reguh-empfg
                                         AND vblnr = reguh-vblnr.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
          SELECT SINGLE  * FROM  bseg  WHERE bukrs = regup-bukrs
                                         AND belnr = regup-belnr
                                         AND gjahr = regup-gjahr
                                         AND buzei = regup-buzei.
           IF sy-subrc = 0.
            zzmot_emis = bseg-zzmot_emis.
          ENDIF.
    IF ( reguh-stcd1 IS INITIAL ) OR ( reguh-zstc1 IS INITIAL ).
      SELECT SINGLE stcd1 adrnr INTO (reguh-stcd1, reguh-adrnr)
        FROM lfa1 WHERE lifnr = reguh-lifnr.
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

      SELECT SINGLE *
      FROM zlog_pago_bancos
         WHERE bukrs = bukrs
           AND ubnkl = '016'
           AND laufd = v_fecha
           AND laufi = v_nomina.

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

  reg_stder-zbukr = tabla_00-zbukr.

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


  SELECT SINGLE smtp_addr INTO reg_stder-mail FROM adr6 WHERE addrnumber = tabla_00-adrnr.

  TRANSLATE   tabla_00-zbnkn USING '- '.
  CONDENSE    tabla_00-zbnkn NO-GAPS.
  CONDENSE    tabla_00-zbnkl NO-GAPS.

  reg_stder-cod_prov         =  tabla_00-lifnr.
  reg_stder-codigo_banco     =  tabla_00-zbnkl.
  reg_stder-cuenta_abono     =  tabla_00-zbnkn.
  reg_stder-docto_sap1       =  tabla_00-vblnr.




  IF tabla_00-rzawe = 'V'.
    reg_stder-codigo_banco = ''.
    reg_stder-cuenta_abono = ''.
  ENDIF.

  CLEAR reg_stder-mod_pago.

SELECT SINGLE * FROM bsak
          WHERE  bukrs  = tabla_00-zbukr   " soc.pagadora
            AND  augbl  = tabla_00-vblnr    " Núm. doc.
            AND  lifnr  = tabla_00-LIFNR
            AND  auggj  = tabla_00-zaldt+0(4)
            AND  SHKZG  = 'H'.   " HCD 12042018

  IF tabla_00-rzawe  = 'V'.
      IF bsak-zterm = 'ZEFE'. "tabla_00-zbukr = 'CL19'. "or tabla_00-zbukr = 'CL17'. "HCD 20120424
          reg_stder-mod_pago  = 'EFE'.
          reg_stder-via_pago  = 'V'.
      ELSE.
          reg_stder-mod_pago  = 'VVC'.
      ENDIF.
          reg_stder-codigo_banco = 012.
          reg_stder-suc_retiro = 245.
  ELSE.
    SELECT SINGLE clave INTO p_clave
                  FROM  zfitr001
                  WHERE bankl = '012'
                  AND   bkont = tabla_00-zbkon.
    IF sy-subrc EQ 0.
      CONDENSE p_clave NO-GAPS.
      reg_stder-mod_pago = p_clave.
    ENDIF.
  ENDIF.

  IF  tabla_00-rzawe  = 'T'.
    IF reg_stder-codigo_banco <> 012.
      reg_stder-mod_pago  = 'OTC'.
    ENDIF.
    IF tabla_00-zbukr = 'CL19'. " or tabla_00-zbukr = 'CL17'."HCD 20120424
      IF reg_stder-codigo_banco = 012 or reg_stder-codigo_banco = 509 or reg_stder-codigo_banco = 050.
        reg_stder-mod_pago  = 'CCT'.
      ENDIF.
    endif.
      reg_stder-via_pago  = 'T'.
  ENDIF.

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


SELECT * FROM regup CLIENT SPECIFIED
WHERE mandt = sy-mandt
AND laufd = v_fecha
AND laufi = v_nomina
AND xvorl = ' '
AND lifnr = acreedor
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND vblnr = tabla_00-vblnr.
AND VBLNR = TABLA_00-VBLNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
      PERFORM paga_sociedad_.
    ENDSELECT.


  ELSE..

*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
    SELECT SINGLE * FROM  bseg
              WHERE   bukrs   = tabla_00-zbukr
              AND     belnr   = tabla_00-vblnr
              AND     zfbdt   = tabla_00-zaldt              " ff 150306
              AND     koart   = 'K'.

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
  refresh t_doctos.
  SELECT * FROM bsak CLIENT SPECIFIED
          WHERE mandt   = sy-mandt
            AND  bukrs  = soc_pago    " soc.pagadora
            AND  augbl  = doc_pago    " Núm. doc.
            AND  lifnr  = acreedor
            AND  auggj  = eje_pago.   " ff 02.03.06

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

  refresh t_doctos.

  SELECT * FROM bsak CLIENT SPECIFIED
          WHERE mandt   = sy-mandt
            AND  bukrs  = regup-bukrs    " soc.pagadora
            AND  belnr  = regup-belnr    " Núm. doc.
            AND  gjahr  = regup-gjahr
            AND  buzei  = regup-buzei
            AND  lifnr  = regup-lifnr.

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
    t_doctos-dmbtr = ABS( t_doctos-dmbtr ).

    SELECT SINGLE * FROM  bkpf
         WHERE  bukrs  = t_doctos-bukrs
         AND    belnr  = t_doctos-belnr
         AND    gjahr  = t_doctos-gjahr.

    IF sy-subrc = 0 AND bkpf-xblnr IS NOT INITIAL.
      CONDENSE bkpf-xblnr NO-GAPS.
      num_doc = bkpf-xblnr.
    ENDIF.


    if bkpf-blart   = 'SA' or bkpf-blart   = 'F7'.
      condense t_doctos-zuonr no-gaps.
      num_doc = t_doctos-zuonr.
      reg_stder-num_docto      = num_doc.
    endif.




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
        trunc_trailing_blanks_eol = ''
      TABLES
        data_tab                  = out_reg_stder_x1
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
        trunc_trailing_blanks_eol = 'X'
      TABLES
        data_tab                  = out_reg_stder_x
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

  SELECT SINGLE * FROM  bkpf
        WHERE  bukrs  = tabla_00-zbukr   " Soc. Paga
        AND    belnr  = tabla_00-vblnr.  " Doc. pago


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
AND VBLNR = TABLA_00-VBLNR ORDER BY PRIMARY KEY.
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
  SELECT SINGLE * FROM  bseg
            WHERE   bukrs   = tabla_00-zbukr
            AND     belnr   = tabla_00-vblnr
            AND     zfbdt   = tabla_00-zaldt                " ff 150306
            AND     koart   = 'K'.

  IF sy-subrc = 0.
    eje_pago = bseg-gjahr.
  ENDIF.


*****

  SELECT * FROM bsak
          WHERE  bukrs  = soc_pago    " soc.pagadora
            AND  augbl  = doc_pago    " Núm. doc.
            AND  lifnr  = acreedor
            AND  auggj  = eje_pago.

    CHECK bsak-augbl <>  bsak-belnr.

    MOVE-CORRESPONDING bsak TO t_doctos.
    APPEND t_doctos.
  ENDSELECT.

  LOOP AT t_doctos.

* Buscamos textos
    SELECT SINGLE * FROM  bkpf
            WHERE  bukrs  = soc_pago          " Soc. Paga
            AND    gjahr  = t_doctos-gjahr
            AND    belnr  = t_doctos-belnr.   " Doc. pago

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

  SELECT * FROM bsak CLIENT SPECIFIED
           WHERE mandt   = sy-mandt
             AND  bukrs  = regup-bukrs    " soc.pagadora
             AND  belnr  = regup-belnr    " Núm. doc.
             AND  gjahr  = regup-gjahr
             AND  buzei  = regup-buzei
             AND  lifnr  = regup-lifnr.


    CHECK bsak-augbl <>  bsak-belnr.

    MOVE-CORRESPONDING bsak TO t_doctos.

    APPEND t_doctos.
  ENDSELECT.

  LOOP AT t_doctos.

* Buscamos textos
    SELECT SINGLE * FROM  bkpf CLIENT SPECIFIED
            WHERE  mandt  = sy-mandt
            AND    bukrs  = t_doctos-bukrs          " Soc. Paga
            AND    gjahr  = t_doctos-gjahr
            AND    belnr  = t_doctos-belnr.   " Doc. pago

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

*    WRITE : /001 TABLA_00-RZAWE ,
*             003 TABLA_00-VBLNR ,  " t_doctos-belnr ,
*             014 TABLA_00-ABSBU ,
*             019 BKPF-XBLNR     ,  " bkpf-bktxt
**             019 t_doctos-zuonr     ,  " referencia factura
*             037 TABLA_00-STCD1 ,
*             054 TABLA_00-ZNME1 ,
*             090 T_DOCTOS-DMBTR CURRENCY 'CLP'.
*


    t_monto = t_monto  + t_doctos-dmbtr.
    monto_p  = monto_p + t_doctos-dmbtr.

  ENDLOOP.

  monto_y = t_monto .

  monto_z = monto_z + monto_y.
  clear T_MONTO.

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

  REFRESH out_reg_stder_x.
  SORT reg_stder  BY zbukr rut_prov .





  LOOP AT reg_stder.

    out_reg_stder-mod_servico = 'G'.
    largo = STRLEN( reg_stder-rut_prov ).
    largo =  largo - 1.
    out_reg_stder-rut_prv_dvr = reg_stder-rut_prov+largo(1).
    out_reg_stder-rut_prv = reg_stder-rut_prov+0(largo).
    out_reg_stder-unidad = ''.
    out_reg_stder-nombre_prv = reg_stder-nombre.
    out_reg_stder-medio_aviso = 'E'.
    out_reg_stder-direc_aviso = reg_stder-mail.
    out_reg_stder-comuna_aviso = 0.

    out_reg_stder-forma_pago = reg_stder-mod_pago.

    out_reg_stder-cod_banco = reg_stder-codigo_banco.
    out_reg_stder-cuenta_cte = reg_stder-cuenta_abono.
    out_reg_stder-cod_sucursal = reg_stder-suc_retiro.
    IF reg_stder-monto_docto < 0.
      reg_stder-monto_docto = reg_stder-monto_docto * -1.
    ENDIF.

    IF reg_stder-mod_pago  = 'VVC'.
      CASE reg_stder-blart.
        WHEN 'F1' OR 'F2' OR 'F3' OR 'F4' OR 'F5' OR 'F6'.
          out_reg_stder-tipo_docto = 'FAC'.
        WHEN 'N1' OR 'N2' OR 'N3' OR 'N4'.
          out_reg_stder-tipo_docto = 'NCR'.
        WHEN 'D1' OR 'D2' OR 'D3' OR 'D4'.
          out_reg_stder-tipo_docto = 'NDB'.
      ENDCASE.
    ELSE.
      out_reg_stder-tipo_docto = 'ABO'.
    ENDIF.


    out_reg_stder-nro_docto  = reg_stder-num_docto.


    out_reg_stder-nro_docto_rel = 0.
    out_reg_stder-valor_info = reg_stder-monto_docto.
    out_reg_stder-valor_pago = reg_stder-monto_docto.
    out_reg_stder-estado_pago = 'OK'.
    CONCATENATE v_fecpag+6(2) v_fecpag+4(2)   v_fecpag+0(4) INTO out_reg_stder-fecha_pago .
    CONCATENATE reg_stder-fecha_vcto+6(2) reg_stder-fecha_vcto+4(2)   reg_stder-fecha_vcto+0(4) INTO out_reg_stder-fecha_vcto.
    out_reg_stder-glosa = ''.

    largo = STRLEN( reg_stder-rut_prov ).
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
*      out_reg_stder-paterno1  = reg_stder-nombre_ret+0(15).
*      out_reg_stder-materno1  = reg_stder-nombre_ret+14(15).
*      out_reg_stder-nombre1   = reg_stder-nombre_ret+29(10).
      out_reg_stder-paterno1 = '               '.
      out_reg_stder-materno1 = '               '.
      out_reg_stder-nombre1  = '               '.
    ENDIF.

    out_reg_stder-rut_ret2   = 0.
    out_reg_stder-rut_ret2_dvr = ' '.
    out_reg_stder-paterno2   = '               '.
    out_reg_stder-materno2   = '               '.
    out_reg_stder-nombre2    = '               '.


    if reg_stder-via_pago = 'T'. " Se agrega esta opcion para DAVILA Y SIS HCD 20120424
      out_reg_stder-codigo = '00000000001'.
    else.
      out_reg_stder-codigo = '99900000001'.
    endif.

*    append out_reg_stder.

    PERFORM formateo.
  ENDLOOP.

ENDFORM.                    " PREPARO_SALIDA


*&---------------------------------------------------------------------*
*&      Form  formateo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM formateo.
  DATA: desde(3) TYPE n.
  DATA: inicio(3) TYPE c.

  IF zfitr002-zmodser <> 0.
    desde = zfitr002-zmodser - 1.
    out_reg_stder_x-registro+desde(1) =  out_reg_stder-mod_servico.
  ENDIF.

  IF zfitr002-zrutpro <> 0.
    desde = zfitr002-zrutpro - 1.
    out_reg_stder_x-registro+desde(8) = out_reg_stder-rut_prv.
  ENDIF.

  IF zfitr002-zdrrpor <> 0.
    desde = zfitr002-zdrrpor - 1.
    out_reg_stder_x-registro+desde(1) = out_reg_stder-rut_prv_dvr.
  ENDIF.

  IF zfitr002-zunidad <> 0.
    desde = zfitr002-zunidad - 1.
    out_reg_stder_x-registro+desde(5) = out_reg_stder-unidad.
  ENDIF.

  IF zfitr002-znombre <> 0.
    desde = zfitr002-znombre - 1.
    out_reg_stder_x-registro+desde(45) = out_reg_stder-nombre_prv.
  ENDIF.

  IF zfitr002-zmedavi <> 0.
    desde = zfitr002-zmedavi - 1.
    out_reg_stder_x-registro+desde(1) = out_reg_stder-medio_aviso.
  ENDIF.

  IF zfitr002-zdiravi <> 0.
    desde = zfitr002-zdiravi - 1.
    out_reg_stder_x-registro+desde(35) = out_reg_stder-direc_aviso.
  ENDIF.

  IF zfitr002-zcodcom <> 0.
    desde = zfitr002-zcodcom - 1.
    out_reg_stder_x-registro+desde(4) = out_reg_stder-comuna_aviso.
  ENDIF.

  IF zfitr002-zforpag <> 0.
    desde = zfitr002-zforpag - 1.
    out_reg_stder_x-registro+desde(3) = out_reg_stder-forma_pago.
  ENDIF.

  IF   zfitr002-zcodbco <> 0.
    desde = zfitr002-zcodbco - 1.
    out_reg_stder_x-registro+desde(3) = out_reg_stder-cod_banco.
  ENDIF.

  IF  zfitr002-zctacte <> 0.
    desde = zfitr002-zctacte - 1.
    out_reg_stder_x-registro+desde(20) = out_reg_stder-cuenta_cte.
  ENDIF.

  IF zfitr002-zsuccta <> 0.
    desde = zfitr002-zsuccta - 1.
    out_reg_stder_x-registro+desde(3) = out_reg_stder-cod_sucursal.
  ENDIF.


  IF zfitr002-ztipdoc <> 0.
    desde = zfitr002-ztipdoc - 1.
    out_reg_stder_x-registro+desde(3) =  out_reg_stder-tipo_docto.
  ENDIF.

  IF bukrs = 'CL27'.

    IF zfitr002-znumdoc <> 0.
      desde = zfitr002-znumdoc - 1.
      out_reg_stder_x-registro+desde(10) =  out_reg_stder-nro_docto.
    ENDIF.
    IF zfitr002-zdocrel <> 0.
      desde = zfitr002-zdocrel - 1.
      out_reg_stder_x-registro+desde(10) =  out_reg_stder-nro_docto_rel.
    ENDIF.
    IF zfitr002-zmoninf <> 0.
      desde = zfitr002-zmoninf - 1.
      out_reg_stder_x-registro+desde(12) =  out_reg_stder-valor_info.
    ENDIF.
    IF zfitr002-zmonpag <> 0.
      desde = zfitr002-zmonpag - 1.
      out_reg_stder_x-registro+desde(12) =  out_reg_stder-valor_pago.
    ENDIF.
  ELSEIF bukrs = 'CL17' or  bukrs = 'CL13' or  bukrs = 'CL19'.  " Se agrega esta opcion para DAVILA Y SIS HCD 20120424 y HONODAV agregado el 13012016 JGFY
    out_reg_stder-nro_doctox = out_reg_stder-nro_docto.
    out_reg_stder-nro_docto_relx = out_reg_stder-nro_docto_rel.
    out_reg_stder-valor_infox = out_reg_stder-valor_info.
    out_reg_stder-valor_pagox = out_reg_stder-valor_pago.

    IF zfitr002-znumdoc <> 0.
      desde = zfitr002-znumdoc - 1.
      out_reg_stder_x-registro+desde(11) =  out_reg_stder-codigo. " out_reg_stder-nro_doctox.
    ENDIF.
    IF zfitr002-zdocrel <> 0.
      desde = zfitr002-zdocrel - 1.
      out_reg_stder_x-registro+desde(12) =  out_reg_stder-nro_docto_relx.
    ENDIF.
    IF zfitr002-zmoninf <> 0.
      desde = zfitr002-zmoninf - 1.
      out_reg_stder_x-registro+desde(11) =  out_reg_stder-valor_infox.
    ENDIF.
    IF zfitr002-zmonpag <> 0.
      desde = zfitr002-zmonpag - 1.
      out_reg_stder_x-registro+desde(11) =  out_reg_stder-valor_pagox.
    ENDIF.
  ELSE.
    out_reg_stder-nro_doctox = out_reg_stder-nro_docto.
    out_reg_stder-nro_docto_relx = out_reg_stder-nro_docto_rel.
    out_reg_stder-valor_infox = out_reg_stder-valor_info.
    out_reg_stder-valor_pagox = out_reg_stder-valor_pago.

    IF zfitr002-znumdoc <> 0.
      desde = zfitr002-znumdoc - 1.
      out_reg_stder_x-registro+desde(12) =  out_reg_stder-nro_doctox.
    ENDIF.
    IF zfitr002-zdocrel <> 0.
      desde = zfitr002-zdocrel - 1.
      out_reg_stder_x-registro+desde(12) =  out_reg_stder-nro_docto_relx.
    ENDIF.
    IF zfitr002-zmoninf <> 0.
      desde = zfitr002-zmoninf - 1.
      out_reg_stder_x-registro+desde(11) =  out_reg_stder-valor_infox.
    ENDIF.
    IF zfitr002-zmonpag <> 0.
      desde = zfitr002-zmonpag - 1.
      out_reg_stder_x-registro+desde(11) =  out_reg_stder-valor_pagox.
    ENDIF.
  ENDIF.



  IF zfitr002-zestpag <> 0.
    desde = zfitr002-zestpag - 1.
    out_reg_stder_x-registro+desde(3) =  out_reg_stder-estado_pago.
  ENDIF.

  IF zfitr002-zfecvct <> 0.
    desde = zfitr002-zfecvct - 1.
    out_reg_stder_x-registro+desde(8) =  out_reg_stder-fecha_vcto.
  ENDIF.

  IF zfitr002-zfecpag <> 0.
    desde = zfitr002-zfecpag - 1.
    out_reg_stder_x-registro+desde(8) =  out_reg_stder-fecha_pago.
  ENDIF.

  IF zfitr002-zglosa <> 0.
    desde = zfitr002-zglosa - 1.
    out_reg_stder_x-registro+desde(91) =  out_reg_stder-glosa(91).
  ENDIF.

  IF  zfitr002-zrutre1 <> 0.
    desde = zfitr002-zrutre1 - 1.
    out_reg_stder_x-registro+desde(8) =  out_reg_stder-rut_ret1.
  ENDIF.

  IF zfitr002-zdvrre1 <> 0.
    desde = zfitr002-zdvrre1 - 1.
    out_reg_stder_x-registro+desde(1) =  out_reg_stder-rut_ret1_dvr.
  ENDIF.

  IF zfitr002-zappre1 <> 0.
    desde = zfitr002-zappre1 - 1.
    out_reg_stder_x-registro+desde(15) =  out_reg_stder-paterno1.
  ENDIF.

  IF zfitr002-zapmre1 <> 0.
    desde = zfitr002-zapmre1 - 1.
    out_reg_stder_x-registro+desde(15) =  out_reg_stder-materno1.
  ENDIF.

  IF zfitr002-znomre1 <> 0.
    desde = zfitr002-znomre1 - 1.
    out_reg_stder_x-registro+desde(15) =  out_reg_stder-nombre1.
  ENDIF.

  IF zfitr002-zrutre2 <> 0.
    desde = zfitr002-zrutre2 - 1.
    out_reg_stder_x-registro+desde(8) =  out_reg_stder-rut_ret2.
  ENDIF.

  IF zfitr002-zdvrre2 <> 0.
    desde = zfitr002-zdvrre2 - 1.
    out_reg_stder_x-registro+desde(1) =  out_reg_stder-rut_ret2_dvr.
  ENDIF.

  IF zfitr002-zappre2 <> 0.
    desde = zfitr002-zappre2 - 1.
    out_reg_stder_x-registro+desde(15) =  out_reg_stder-paterno2.
  ENDIF.

  IF zfitr002-zapmre2 <> 0.
    desde = zfitr002-zapmre2 - 1.
    out_reg_stder_x-registro+desde(15) =  out_reg_stder-materno2.
  ENDIF.

  IF zfitr002-znomre2 <> 0.
    desde = zfitr002-znomre2 - 1.
    out_reg_stder_x-registro+desde(15) =  out_reg_stder-nombre2.
  ENDIF.

  out_reg_stder_x1-registro = out_reg_stder_x-registro+0(257).
  APPEND out_reg_stder_x1.
  APPEND out_reg_stder_x.

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
