*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <27-12-2019> *
*& Transport Number: < ECDK916964 > *
*&---------------------------------------------------------------------*
REPORT ZFITR001 NO STANDARD PAGE HEADING
                                   LINE-SIZE 132 .

*----------------------------------------------------------------------*
* Tablas usadas.
*----------------------------------------------------------------------*
TABLES : reguh,   "  Datos de pago del programa de pagos              02
         regup,
         bseg,    "  Segmento de documento de Contabilidad            02
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
         T001,
         bnka,    "  Maestro de banco                                 02
         bsak,    "  índice secundario para acreedores (part.comp.)   02
         bkpf.    "  Cabecera de documento para Contabilidad          02

DATA : BEGIN OF tabla_00 OCCURS 0.
        INCLUDE STRUCTURE reguh.
DATA : END OF tabla_00.

DATA : monto_total(13)                    ,
       total_proveedor LIKE tabla_00-rwbtr.

DATA : BEGIN OF t_bancos OCCURS 0     ,
         cod_ac      LIKE reguh-zbnkl ,
         cod_nw(03)  TYPE c           ,
       END OF t_bancos                .

DATA : BEGIN OF reg_stder OCCURS 0,
           ilinea(1) type N ,
           sec_grab(2) type N,
           sec_impr(6) type N,
           rut_prov(12)        TYPE c ,
           nombre(40)          TYPE c ,
           direccion(5) type n,
           CIUDAD(38) TYPE C,
           COD_COMUNA(3) TYPE n,
           COMUNA(15) TYPE C,
           COD_CIUDAD(3) TYPE n,
           CIUDAD2(15) TYPE C,
           MOD_PAGO(2) TYPE C,
           CAUSAL_PAGO(2) TYPE C,
           SUC_RETIRO(3) TYPE C,
           cuenta_abono(17)    TYPE c ,
           CODIGO_BANCO(5) TYPE n,
           RUT_RETIR(12) TYPE n,
           NOM_RETIR(40) TYPE C,
*           codigo_banco(03)    TYPE n ,
           num_docto01(8)      TYPE n ,
           monto_docto01(11)   TYPE n ,
           decimales01(2) type n,
           signo_docto01(01)   TYPE c ,
           num_docto02(8)      TYPE n ,
           monto_docto02(11)   TYPE n ,
           decimales02(2) type n,
           signo_docto02(01)   TYPE c ,
           num_docto03(8)      TYPE n ,
           monto_docto03(11)   TYPE n ,
           decimales03(2) type n,
           signo_docto03(01)   TYPE c ,
           num_docto04(8)      TYPE n ,
           monto_docto04(11)   TYPE n ,
           decimales04(2) type n,
           signo_docto04(01)   TYPE c ,
           num_docto05(8)      TYPE n ,
           monto_docto05(11)   TYPE n ,
           decimales05(2) type n,
           signo_docto05(01)   TYPE c ,
           num_docto06(8)      TYPE n ,
           monto_docto06(11)   TYPE n ,
           decimales06(2) type n,
           signo_docto06(01)   TYPE c ,
           num_docto07(8)      TYPE n ,
           monto_docto07(11)   TYPE n ,
           decimales07(2) type n,
           signo_docto07(01)   TYPE c ,
           num_docto08(8)      TYPE n ,
           monto_docto08(11)   TYPE n ,
           decimales08(2) type n,
           signo_docto08(01)   TYPE c ,
           num_docto09(8)      TYPE n ,
           monto_docto09(11)   TYPE n ,
           decimales09(2) type n,
           signo_docto09(01)   TYPE c ,
           num_docto10(8)      TYPE n ,
           monto_docto10(11)   TYPE n ,
           decimales10(2) type n,
           signo_docto10(01)   TYPE c ,
           num_docto11(8)      TYPE n ,
           monto_docto11(11)   TYPE n ,
           decimales11(2) type n,
           signo_docto11(01)   TYPE c ,
           total_a_pagar(13) type n,
           DECIMALES(2) type n,
           FLAG_LIQ1(1) type c,
           FLAG_LIQ2(3) type c,
           ACCION(27) type n,
           FILLER(50) type c,
       END OF reg_stder .

data: hsum type p.
constants: w_zeros value '0'.
data: tamano type i.
DATA: t(9) TYPE c ,
      string LIKE t,
      str(6) VALUE 'ghijkl'.

DATA: BEGIN OF t_doctos OCCURS 0,
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

DATA:    BEGIN OF t_items OCCURS 50,
         xauth(1)      TYPE c,                 " Berechtigung?
         xhell(1)      TYPE c.                 " Hell anzeigen?
        INCLUDE STRUCTURE rfpos.              " Listanzeigen-Struktur


DATA:      xbkpf(1)      TYPE c,                 " BKPF nachgelesen?
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
.

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

DATA:    BEGIN OF TLAUFK OCCURS 1.
        INCLUDE STRUCTURE ILAUFK.
DATA:    END OF TLAUFK.

data lt_dynpfields like dynpread occurs 1 with header line.
data lv_dynpro_prog like d020s-prog.

*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

PARAMETER :  bukrs    like t001-bukrs obligatory.

PARAMETER :  v_fecha  LIKE reguh-laufd obligatory,
             v_nomina LIKE f110v-laufi obligatory.

PARAMETER  : archivo     LIKE rlgrap-filename DEFAULT 'C:\TRANSFER\'.

PARAMETERS : par_tes RADIOBUTTON GROUP test       " Ejecución en Test
                     DEFAULT 'X',
             par_di  RADIOBUTTON GROUP test.      " Ejecución real

SELECTION-SCREEN END OF BLOCK marco1 .


*---------------------------------------------------------------------------------
INITIALIZATION.

  GET PARAMETER ID: 'SOC' FIELD bukrs,
                    'FEC' FIELD v_fecha,
                    'NOM' FIELD v_nomina,
                    'ARC' FIELD archivo.

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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo .
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = archivo.

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
      BANCO = '037'
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

  read table lt_dynpfields index 1.
  lt_dynpfields-fieldvalue = v_nomina.
  modify  lt_dynpfields index 1.


  read table lt_dynpfields index 2.
*  CONCATENATE 'C:\TRANSFER\' bukrs '_BSANT' '_' sy-datum '_' sy-uzeit '.txt' INTO
  lt_dynpfields-fieldvalue = ARCHIVO.

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
      BANCO = '037'
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

  read table lt_dynpfields index 1.
  concatenate v_fecha+06(2) '.' v_fecha+04(2) '.' v_fecha+0(4) into lt_dynpfields-fieldvalue.
  modify  lt_dynpfields index 1.


  read table lt_dynpfields index 2.
  CONCATENATE 'C:\TRANSFER\' bukrs '_BSANT' '_' sy-datum '_' sy-uzeit '.txt' INTO
   lt_dynpfields-fieldvalue.
  modify  lt_dynpfields index 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
    TABLES
      dynpfields = lt_dynpfields.


INITIALIZATION.

*  CONCATENATE archivo 'BSANT' '_' sy-datum '_' sy-uzeit '.txt' INTO
*  archivo.
  CONDENSE archivo NO-GAPS.

  loop at screen.
    if screen-name = 'V_NOMINA'.
      screen-input = 1.
      modify screen.
    endif.


  endloop.


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
*           WHERE  laufd       = v_fecha
*           AND    laufi       = v_nomina
*           and    xvorl       = ' '
*           and    UBNKL       = '037'
*           and  ( RZAWE       = 'T' or RZAWE = 'V' ).
*
* NEW CODE
  SELECT *
  FROM  reguh
           WHERE  laufd       = v_fecha
           AND    laufi       = v_nomina
           and    xvorl       = ' '
           and    UBNKL       = '037'
           and  ( RZAWE       = 'T' or RZAWE = 'V' ) ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


    IF ( reguh-stcd1 IS INITIAL ) OR ( reguh-zstc1 IS INITIAL ).
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single stcd1 into reguh-stcd1
*        from lfa1 where lifnr = reguh-lifnr.
*
* NEW CODE
      SELECT stcd1
      UP TO 1 ROWS  into reguh-stcd1
        from lfa1 where lifnr = reguh-lifnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.

    IF ( NOT reguh-stcd1 IS INITIAL ) OR ( NOT reguh-zstc1 IS INITIAL ).
      MOVE-CORRESPONDING reguh TO tabla_00.

* Si es vale vista, el banco será el pagador
      IF tabla_00-rzawe = 'V'.
*       tabla_00-zbnkl = tabla_00-hbkid.
        tabla_00-zbnkl = tabla_00-ubnkl.
      ENDIF.

* Se asigna a Banco Chile los bancos 029 y 033
      If tabla_00-zbnkl = '029' or  tabla_00-zbnkl = '033'.
          tabla_00-zbnkl = '001'.
      endif.

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

  IF lins <> 0.
    PERFORM listado.  "informe.
    CHECK par_di EQ 'X'.
    PERFORM bajar_archivo.
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

  data: ceros17(17) type c value '00000000000000000'.
  data: cuenta(17) type c value ''.

  CLEAR   : reg_stder, t_items.
  REFRESH : t_doctos, t_doctos[], t_items[].


  TRANSLATE tabla_00-stcd1 USING '- ' .
  CONDENSE  tabla_00-stcd1 NO-GAPS    .

* Se ajusta Rut a la Izquierda.
  WRITE tabla_00-stcd1 TO reg_stder-rut_prov RIGHT-JUSTIFIED.


  TRANSLATE   tabla_00-zbnkn USING '- '.
  CONDENSE    tabla_00-zbnkn NO-GAPS.
  CONDENSE    tabla_00-zbnkl NO-GAPS.

  reg_stder-nombre = tabla_00-znme1 .
  reg_stder-codigo_banco     =  tabla_00-zbnkl.


  write tabla_00-zbnkn  to  cuenta RIGHT-JUSTIFIED.
  overlay cuenta with ceros17.


  reg_stder-cuenta_abono     = cuenta.




  IF tabla_00-rzawe = 'V'.
    reg_stder-mod_pago = '01'.
    reg_stder-suc_retiro = '999'.
    reg_stder-codigo_banco = '000'.
    clear reg_stder-cuenta_abono.
  ELSE.
    reg_stder-suc_retiro = '999'.
    clear REG_STDER-MOD_PAGO.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE CLAVE INTO P_CLAVE
*                  FROM  ZFITR001
*                  WHERE BANKL = '037'
*                  AND   BKONT = TABLA_00-ZBKON.
*
* NEW CODE
    SELECT CLAVE
    UP TO 1 ROWS  INTO P_CLAVE
                  FROM  ZFITR001
                  WHERE BANKL = '037'
                  AND   BKONT = TABLA_00-ZBKON ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF SY-SUBRC EQ 0.
      CONDENSE P_CLAVE NO-GAPS.
      REG_STDER-MOD_PAGO = P_CLAVE.
    ENDIF.
    if  REG_STDER-MOD_PAGO is initial.
      reg_stder-mod_pago = '03'.
    ENDIF.
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
    SELECT *  FROM REGUP      CLIENT SPECIFIED
           WHERE  MANDT       = SY-MANDT
             AND  LAUFD       = V_FECHA
             AND  LAUFI       = V_NOMINA
             AND  XVORL       = ' '
             AND  LIFNR       = ACREEDOR
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916964*
*             AND  VBLNR       = TABLA_00-VBLNR.
             AND  VBLNR       = TABLA_00-VBLNR ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916964*
      PERFORM PAGA_SOCIEDAD_.
    ENDSELECT.



  ELSE..

*** buscamos ejercicio del docto de pago
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
  n_monto = 0.
  pos__   = 0.


* Ordenamos solo por monto ( sin signo )
* para que queden los reversos juntos.-
*sort t_doctos by wrbtr.
  SORT t_doctos BY dmbtr.


  LOOP AT t_doctos.
    ADD 1 TO pos__.

*Grabamos primeras 11 posiciones
    IF pos__ > 11.
      reg_stder-total_a_pagar = n_monto.
      if n_monto >= 1.
        APPEND reg_stder.
      endif.
*    Limpiamos
      CLEAR : reg_stder-num_docto01, reg_stder-signo_docto01,
              reg_stder-monto_docto01,
              reg_stder-num_docto02, reg_stder-signo_docto02,
              reg_stder-monto_docto02,
              reg_stder-num_docto03, reg_stder-signo_docto03,
              reg_stder-monto_docto03,
              reg_stder-num_docto04, reg_stder-signo_docto04,
              reg_stder-monto_docto04,
              reg_stder-num_docto05, reg_stder-signo_docto05,
              reg_stder-monto_docto05,
              reg_stder-num_docto06, reg_stder-signo_docto06,
              reg_stder-monto_docto06,
              reg_stder-num_docto07, reg_stder-signo_docto07,
              reg_stder-monto_docto07,
              reg_stder-num_docto08, reg_stder-signo_docto08,
              reg_stder-monto_docto08,
              reg_stder-num_docto09, reg_stder-signo_docto09,
              reg_stder-monto_docto09,
              reg_stder-num_docto10, reg_stder-signo_docto10,
              reg_stder-monto_docto10,
              reg_stder-num_docto11, reg_stder-signo_docto11,
              reg_stder-monto_docto11,
              reg_stder-total_a_pagar.
      pos__ = 1.
      n_monto = 0.
    ENDIF.

*invertimos los signos para que el giro quede positivo !!!!!

    IF t_doctos-shkzg = 'S'.    "Invertimos los signos.....
      t_doctos-dmbtr = t_doctos-dmbtr * -1.
    ENDIF.

    t_doctos-dmbtr = t_doctos-dmbtr * 100.

    n_monto        = n_monto + t_doctos-dmbtr.

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

******
    CASE pos__ .

      WHEN 1.
        reg_stder-num_docto01    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto01 = '-'.
        ELSE.
          reg_stder-signo_docto01 = '+'.
        ENDIF.
        reg_stder-monto_docto01  = t_doctos-dmbtr.
      WHEN 2.
        reg_stder-num_docto02    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto02 = '-'.
        ELSE.
          reg_stder-signo_docto02 = '+'.
        ENDIF.
        reg_stder-monto_docto02  = t_doctos-dmbtr.
      WHEN 3.
        reg_stder-num_docto03    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto03 = '-'.
        ELSE.
          reg_stder-signo_docto03 = '+'.
        ENDIF.
        reg_stder-monto_docto03  = t_doctos-dmbtr.
      WHEN 4.
        reg_stder-num_docto04    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto04 = '-'.
        ELSE.
          reg_stder-signo_docto04 = '+'.
        ENDIF.
        reg_stder-monto_docto04  = t_doctos-dmbtr.
      WHEN 5.
        reg_stder-num_docto05    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto05 = '-'.
        ELSE.
          reg_stder-signo_docto05 = '+'.
        ENDIF.
        reg_stder-monto_docto05  = t_doctos-dmbtr.
      WHEN 6.
        reg_stder-num_docto06    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto06 = '-'.
        ELSE.
          reg_stder-signo_docto06 = '+'.
        ENDIF.
        reg_stder-monto_docto06  = t_doctos-dmbtr.
      WHEN 7.
        reg_stder-num_docto07    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto07 = '-'.
        ELSE.
          reg_stder-signo_docto07 = '+'.
        ENDIF.
        reg_stder-monto_docto07  = t_doctos-dmbtr.
      WHEN 8.
        reg_stder-num_docto08    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto08 = '-'.
        ELSE.
          reg_stder-signo_docto08 = '+'.
        ENDIF.
        reg_stder-monto_docto08  = t_doctos-dmbtr.
      WHEN 9.
        reg_stder-num_docto09    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto09 = '-'.
        ELSE.
          reg_stder-signo_docto09 = '+'.
        ENDIF.
        reg_stder-monto_docto09  = t_doctos-dmbtr.
      WHEN 10.
        reg_stder-num_docto10    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto10 = '-'.
        ELSE.
          reg_stder-signo_docto10 = '+'.
        ENDIF.
        reg_stder-monto_docto10  = t_doctos-dmbtr.
      WHEN 11.
        reg_stder-num_docto11    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto11 = '-'.
        ELSE.
          reg_stder-signo_docto11 = '+'.
        ENDIF.
        reg_stder-monto_docto11  = t_doctos-dmbtr.
    ENDCASE.
  ENDLOOP.

  if n_monto >= 1.
    reg_stder-total_a_pagar = n_monto.
    APPEND reg_stder.
  endif.

ENDFORM.                               " LLENA_ESTRUCTURA


*&---------------------------------------------------------------------*
*&      Form  bajar_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bajar_archivo.
*-----------------*
  DATA : nombre_a  TYPE string.
  data: secuen type i.
  nombre_a = archivo.
  secuen = 0.
  SORT reg_stder by codigo_banco ASCENDING cuenta_abono ASCENDING rut_prov ASCENDING nombre ascending.
  LOOP AT reg_stder.
    reg_stder-ilinea = '3'.
    secuen = secuen + 1.
    reg_stder-sec_grab = secuen.
    reg_stder-sec_impr = secuen.
    reg_stder-mod_pago = '05'.
    reg_stder-CAUSAL_PAGO = '02'.
    reg_stder-SUC_RETIRO = '999'.
    reg_stder-FLAG_LIQ1 = 'S'.

    SHIFT reg_stder-rut_prov RIGHT DELETING TRAILING SPACE. " If U want leading 0s
    OVERLAY reg_stder-rut_prov with '000000000000'.

   clear reg_stder-cuenta_abono.
   clear reg_stder-CODIGO_BANCO.
   IF reg_stder-signo_docto01 IS INITIAL. reg_stder-signo_docto01 = '+'.  ENDIF.
   IF reg_stder-signo_docto02 IS INITIAL. reg_stder-signo_docto02 = '+'.  ENDIF.
   IF reg_stder-signo_docto03 IS INITIAL. reg_stder-signo_docto03 = '+'.  ENDIF.
   IF reg_stder-signo_docto04 IS INITIAL. reg_stder-signo_docto04 = '+'.  ENDIF.
   IF reg_stder-signo_docto05 IS INITIAL. reg_stder-signo_docto05 = '+'.  ENDIF.
   IF reg_stder-signo_docto06 IS INITIAL. reg_stder-signo_docto06 = '+'.  ENDIF.
   IF reg_stder-signo_docto07 IS INITIAL. reg_stder-signo_docto07 = '+'.  ENDIF.
   IF reg_stder-signo_docto08 IS INITIAL. reg_stder-signo_docto08 = '+'.  ENDIF.
   IF reg_stder-signo_docto09 IS INITIAL. reg_stder-signo_docto09 = '+'.  ENDIF.
   IF reg_stder-signo_docto10 IS INITIAL. reg_stder-signo_docto10 = '+'.  ENDIF.
   IF reg_stder-signo_docto11 IS INITIAL. reg_stder-signo_docto11 = '+'.  ENDIF.

    MODIFY reg_stder INDEX sy-tabix from reg_stder.
  ENDLOOP.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = nombre_a
      filetype                = 'ASC'
      confirm_overwrite       = 'X'
    TABLES
      data_tab                = reg_stder
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.

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

    SELECT *  FROM REGUP      CLIENT SPECIFIED
           WHERE  MANDT       = SY-MANDT
             AND  LAUFD       = V_FECHA
             AND  LAUFI       = V_NOMINA
             AND  XVORL       = ' '
             AND  LIFNR       = tabla_00-lifnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916964*
*             AND  VBLNR       = TABLA_00-VBLNR.
             AND  VBLNR       = TABLA_00-VBLNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916964*

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
           43   'NOMINA DE PAGO PROVEEDORES CUENTA BANCO SANTANDER DIVIDENDOS' ,
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
**             019 t_doctos-zuonr     ,  " referencia factura
*             037 TABLA_00-STCD1 ,
*             054 TABLA_00-ZNME1 ,
*             090 T_DOCTOS-DMBTR CURRENCY 'CLP'.
*




    T_MONTO = T_MONTO  + T_DOCTOS-DMBTR.
    MONTO_P  = MONTO_P + T_DOCTOS-DMBTR.

  ENDLOOP.

  MONTO_Y = T_MONTO .

  MONTO_Z = MONTO_Z + MONTO_Y.
  clear T_MONTO.

ENDFORM.                    " DOCTOS__2

AT LINE-SELECTION.
  IF not tabla_00-vblnr is initial.
    SET PARAMETER ID 'BLN' FIELD tabla_00-vblnr.
    SET PARAMETER ID 'BUK' FIELD soc_pago.
    SET PARAMETER ID 'GJR' FIELD eje_pago.
    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDIF.

  clear tabla_00-vblnr .
