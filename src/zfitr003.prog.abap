REPORT zfitr003 NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132 .

*----------------------------------------------------------------------*
* Tablas usadas.
*----------------------------------------------------------------------*
TABLES : reguh,   "  Datos de pago del programa de pagos              02
         bseg,    "  Segmento de documento de Contabilidad            02
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
         t001,
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

DATA : BEGIN OF reg01,
           rut_emp(11)          TYPE c ,
           num_reg(10)          TYPE n,
           monto_total_pago(15) TYPE n,
           tipo_servicio(10)    TYPE c,
           fondos(30)           TYPE c,
           cheque(30)           TYPE c,
           descripcion(40)      TYPE c,
END OF reg01.

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
           fecha_venc          LIKE reguh-ausfd,
END OF reg_stder.


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
        zfbdt    LIKE bseg-zfbdt,  " Fecha de Vencimiento
        xblnr    LIKE bsak-xblnr,   " Referencia
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



*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.
PARAMETER : bukrs     LIKE bkpf-bukrs     OBLIGATORY,
            v_fecha   LIKE reguh-laufd    OBLIGATORY,
            v_nomina  LIKE f110v-laufi    OBLIGATORY,
            v_fecpag  LIKE reguh-laufd    OBLIGATORY.

SELECTION-SCREEN SKIP 1.

PARAMETER  : v_resfon        TYPE    zresfon VALUE CHECK OBLIGATORY,
             v_numche(10)    TYPE    n.

SELECTION-SCREEN SKIP 1.

PARAMETER  : archivo     LIKE rlgrap-filename DEFAULT 'C:\TRANSFER\'.

SELECTION-SCREEN SKIP 1.

PARAMETERS : par_tes RADIOBUTTON GROUP test       " Ejecución en Test
                     DEFAULT 'X',
             par_di  RADIOBUTTON GROUP test.      " Ejecución real


SELECTION-SCREEN END OF BLOCK marco1 .

*---------------------------------------------------------------------------------
INITIALIZATION.

  GET PARAMETER ID: 'SOC' FIELD bukrs,
                    'FEC' FIELD v_fecha,
                    'NOM' FIELD v_nomina,
                    'ARC' FIELD archivo,
                    'FEP' FIELD v_fecpag,
                    'RSF' FIELD v_resfon,
                    'NUM' FIELD v_numche.

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
      banco = '027'
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

  READ TABLE lt_dynpfields INDEX 1.
  lt_dynpfields-fieldvalue = v_nomina.
  MODIFY  lt_dynpfields INDEX 1.


  READ TABLE lt_dynpfields INDEX 2.
*  CONCATENATE 'C:\TRANSFER\' bukrs '_BCORPBANCA' '_' sy-datum '_' sy-uzeit '.txt' INTO
*  lt_dynpfields-fieldvalue.
  lt_dynpfields-fieldvalue = archivo.

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
      banco = '027'
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

  READ TABLE lt_dynpfields INDEX 1.
  CONCATENATE v_fecha+06(2) '.' v_fecha+04(2) '.' v_fecha+0(4) INTO lt_dynpfields-fieldvalue.
  MODIFY  lt_dynpfields INDEX 1.


  READ TABLE lt_dynpfields INDEX 2.
  CONCATENATE 'C:\TRANSFER\' bukrs '_BCORPBANCA' '_' sy-datum '_' sy-uzeit '.txt' INTO
   lt_dynpfields-fieldvalue.
  MODIFY  lt_dynpfields INDEX 2.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = lv_dynpro_prog
      dynumb
      ='1000'
    TABLES
      dynpfields = lt_dynpfields.



AT SELECTION-SCREEN.


  IF v_resfon  = 'CHEQUE' AND v_numche IS INITIAL.
    MESSAGE e004(zfi) WITH 'Debe ingresar numero de cheque'.
  ENDIF.

  IF v_resfon  = 'CTACTE'.
    CLEAR v_numche.
  ENDIF.

INITIALIZATION.

*  CONCATENATE archivo 'BCORPBANCA' '_' sy-datum '_' sy-uzeit '.txt' INTO
*  archivo.
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

  PERFORM bancos.
  SORT t_bancos BY cod_ac.

* Rescatamos Datos.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *  FROM  reguh
*           WHERE  laufd      = v_fecha
*           AND    laufi      = v_nomina
*           AND    xvorl      = ' '
*           AND    ubnkl      = '027'
*           AND  ( rzawe      = 'T' OR rzawe = 'V' ).
*
* NEW CODE
  SELECT *
  FROM  reguh
           WHERE  laufd      = v_fecha
           AND    laufi      = v_nomina
           AND    xvorl      = ' '
           AND    ubnkl      = '027'
           AND  ( rzawe      = 'T' OR rzawe = 'V' ) ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    IF ( reguh-stcd1 IS INITIAL ) OR ( reguh-zstc1 IS INITIAL ).
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE stcd1 INTO reguh-stcd1
*        FROM lfa1 WHERE lifnr = reguh-lifnr.
*
* NEW CODE
      SELECT stcd1
      UP TO 1 ROWS  INTO reguh-stcd1
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

  IF lins <> 0.
    PERFORM listado.  "informe.
    CHECK par_di EQ 'X'.
    PERFORM preparo_salida.
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
  CLEAR   : reg_stder, t_items.
  REFRESH : t_doctos, t_doctos[], t_items[].

  reg_stder-zbukr = tabla_00-zbukr.

  TRANSLATE tabla_00-stcd1 USING '- ' .
  CONDENSE  tabla_00-stcd1 NO-GAPS    .

* Se ajusta Rut a la Izquierda.
  WRITE tabla_00-stcd1 TO reg_stder-rut_prov LEFT-JUSTIFIED.


  TRANSLATE   tabla_00-zbnkn USING '- '.
  CONDENSE    tabla_00-zbnkn NO-GAPS.
  CONDENSE    tabla_00-zbnkl NO-GAPS.

  reg_stder-nombre           =  tabla_00-znme1 .
  reg_stder-codigo_banco     =  tabla_00-zbnkl.
  reg_stder-cuenta_abono     =  tabla_00-zbnkn.
  reg_stder-fecha_venc       =  tabla_00-ausfd.
  CLEAR reg_stder-tipo_cta.

  IF  tabla_00-rzawe = 'V'.
    reg_stder-mod_pago  = 'CAT_CSH_VIRTUAL_OFFICE_CHECK'.
    reg_stder-tipo_cta =   '1350040000'.
    reg_stder-codigo_banco     =  027.
    reg_stder-cuenta_abono     =  '0'.

  ELSE.
    reg_stder-mod_pago  = 'CAT_CSH_TRANSFER'.
  ENDIF.

  IF reg_stder-mod_pago = 'CAT_CSH_TRANSFER'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE clave INTO p_clave
*                  FROM zfitr001
*                  WHERE   bankl = '027'
*                  AND     bkont = tabla_00-zbkon.
*
* NEW CODE
    SELECT clave
    UP TO 1 ROWS  INTO p_clave
                  FROM zfitr001
                  WHERE   bankl = '027'
                  AND     bkont = tabla_00-zbkon ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
      CONDENSE p_clave NO-GAPS.
      reg_stder-tipo_cta = p_clave.
    ENDIF.
    IF reg_stder-tipo_cta IS INITIAL.
      reg_stder-tipo_cta = 'CAT_CSH_CCTE'.
    ENDIF.
  ENDIF.




  acreedor = tabla_00-lifnr.

****Es multisociedad?

  IF tabla_00-zbukr <> tabla_00-absbu.  " Soc_pagadora y Soc.emisora
*** buscamos ejercicio del docto de pago
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  bseg
*                    WHERE bukrs   = tabla_00-zbukr
*                    AND   belnr   = tabla_00-vblnr
*                    AND   zfbdt   = tabla_00-zaldt
*                    AND   koart   = 'K'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  bseg
                    WHERE bukrs   = tabla_00-zbukr
                    AND   belnr   = tabla_00-vblnr
                    AND   zfbdt   = tabla_00-zaldt
                    AND   koart   = 'K' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0.
      eje_pago = bseg-gjahr.
    ENDIF.


*****
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  bkpf
*           WHERE  bukrs  = tabla_00-zbukr
*           AND    belnr  = tabla_00-vblnr
*           AND    gjahr  = eje_pago.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  bkpf
           WHERE  bukrs  = tabla_00-zbukr
           AND    belnr  = tabla_00-vblnr
           AND    gjahr  = eje_pago ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    CALL FUNCTION 'GET_CLEARED_ITEMS'
      EXPORTING
        i_belnr                = tabla_00-vblnr  " doc depago
        i_bukrs                = tabla_00-zbukr  " soc pagadora
        i_gjahr                = bkpf-gjahr
        i_bvorg                = bkpf-bvorg
      TABLES
        t_items                = t_items
      EXCEPTIONS
        not_found              = 1
        error_cleared_accounts = 2
        OTHERS                 = 3.

    IF sy-subrc <> 0.

    ENDIF.

    LOOP AT t_items.
      IF t_items-augbl = t_items-belnr.
        DELETE  t_items INDEX sy-tabix.
      ELSE.
        soc_pago = t_items-bukrs.
        doc_pago = t_items-augbl.
        PERFORM paga_sociedad.
      ENDIF.
    ENDLOOP.

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
  refresh t_doctos.
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

*############################################################
*# Cambio C.INFANTE 08/06/2010
*############################################################
*    SELECT SINGLE * FROM  bkpf
*         WHERE  bukrs  = t_doctos-bukrs
*         AND    belnr  = t_doctos-belnr
*         AND    gjahr  = t_doctos-gjahr.

*    IF sy-subrc = 0 AND bkpf-xblnr IS NOT INITIAL.
*      CONDENSE bkpf-xblnr NO-GAPS.
*      num_doc = bkpf-xblnr.
*    ENDIF.
    IF t_doctos-zuonr IS INITIAL.
      num_doc = t_doctos-xblnr.
    ELSE.
      num_doc = t_doctos-zuonr.
    ENDIF.
*#############################################################
    reg_stder-num_docto      = num_doc.
    IF t_doctos-shkzg = 'S'.
      t_doctos-dmbtr =   t_doctos-dmbtr * -1.
      reg_stder-signo_docto   = '-'.
    ELSE.
      reg_stder-signo_docto  = '+'.
    ENDIF.
    reg_stder-monto_docto   = t_doctos-dmbtr.
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
      filename                = nombre_a
      filetype                = 'ASC'
      confirm_overwrite       = 'X'
    TABLES
      data_tab                = out_reg_stder
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

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM  bkpf
*            WHERE  bukrs  = tabla_00-zbukr   " Soc. Paga
*            AND    belnr  = tabla_00-vblnr.  
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM  bkpf
            WHERE  bukrs  = tabla_00-zbukr   " Soc. Paga
            AND    belnr  = tabla_00-vblnr ORDER BY PRIMARY KEY.  

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01" Doc. pago


      CALL FUNCTION 'GET_CLEARED_ITEMS'
        EXPORTING
          i_belnr                = tabla_00-vblnr  " doc depago
          i_bukrs                = tabla_00-zbukr  " soc pagadora
          i_gjahr                = bkpf-gjahr
          i_bvorg                = bkpf-bvorg
        TABLES
          t_items                = t_items
        EXCEPTIONS
          not_found              = 1
          error_cleared_accounts = 2
          OTHERS                 = 3.

      IF sy-subrc <> 0.

      ENDIF.

*Buscamos los documentos
      LOOP AT t_items.
        IF t_items-augbl = t_items-belnr.
          DELETE  t_items INDEX sy-tabix.
        ELSE.
          soc_pago = t_items-bukrs.
          doc_pago = t_items-augbl.
          PERFORM doctos__.
        ENDIF.
      ENDLOOP.

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
           43   'NOMINA DE PAGO PROVEEDORES CUENTA BANCO CORPBANCA' ,
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

*########################################################
*# Cambio C.INFANTE 08/06/2010
*########################################################
*    WRITE : /001 tabla_00-rzawe ,
*             003 tabla_00-vblnr  ,  " t_doctos-belnr ,
*             014 soc_pago       ,
*             019 bkpf-xblnr     ,  " bkpf-bktxt
*             037 tabla_00-stcd1 ,
*             054 tabla_00-znme1 ,
*             091 t_doctos-zfbdt,
*             101 t_doctos-dmbtr CURRENCY 'CLP'.
*#########################################################
    WRITE : /001 tabla_00-rzawe ,
             003 tabla_00-vblnr ,  " t_doctos-belnr ,
             014 soc_pago       .

    IF t_doctos-zuonr IS INITIAL.
      WRITE:   019 t_doctos-xblnr .
    ELSE.
      WRITE:   019 t_doctos-zuonr .  " bkpf-bktxt
    ENDIF.

    WRITE:   037 tabla_00-stcd1 ,
             054 tabla_00-znme1 ,
             091 t_doctos-zfbdt ,
             101 t_doctos-dmbtr CURRENCY 'CLP'.

    HIDE: tabla_00-vblnr,soc_pago, eje_pago.

    t_monto = t_monto  + t_doctos-dmbtr.
    monto_p  = monto_p + t_doctos-dmbtr.

  ENDLOOP.

  CLEAR tabla_00-vblnr .

  monto_y = t_monto .

  monto_z = monto_z + monto_y.
  clear T_MONTO.
ENDFORM.                    "doctos__



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

  REFRESH out_reg_stder.

  SORT reg_stder  BY zbukr rut_prov .


  LOOP AT reg_stder.
    AT NEW  zbukr .
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE paval INTO rut FROM t001z WHERE bukrs = reg_stder-zbukr
*                                   AND   party = 'TAXNR' .
*
* NEW CODE
      SELECT paval
      UP TO 1 ROWS  INTO rut FROM t001z WHERE bukrs = reg_stder-zbukr
                                   AND   party = 'TAXNR'  ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t001 WHERE bukrs = reg_stder-zbukr.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t001 WHERE bukrs = reg_stder-zbukr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      WRITE rut TO rut LEFT-JUSTIFIED.


      TRANSLATE  rut USING '- '.
      CONDENSE    rut NO-GAPS.

    ENDAT.
    AT NEW  rut_prov .
      numero = numero + 1.
    ENDAT.
    AT LAST.
      SUM.
      reg01-rut_emp = rut.
      reg01-num_reg = numero.
      reg01-monto_total_pago = reg_stder-monto_docto.
      reg01-tipo_servicio = '1350040000'.
      IF v_resfon = 'CTACTE'.
        reg01-fondos = 'CAT_CSH_CONTRACT_ACCOUNT'.
      ELSE.
        reg01-fondos = 'CAT_CSH_CHECK'.

      ENDIF.

      reg01-cheque(30) = v_numche.

      CONCATENATE  'Pago Proveedores' t001-butxt INTO reg01-descripcion  SEPARATED BY space.


      CONCATENATE  reg01-rut_emp
                   ','
                   reg01-num_reg
                    ','
                   reg01-monto_total_pago
                    ','
                   reg01-tipo_servicio
                    ','
                   reg01-fondos
                    ','
                   reg01-cheque
                    ','
                   reg01-descripcion INTO out_reg_stder-reg.
      APPEND out_reg_stder.
    ENDAT.
  ENDLOOP.


  LOOP AT reg_stder.
    reg02-rut_prv = reg_stder-rut_prov.
    reg02-nombre_prv = reg_stder-nombre.
    reg02-mail = ''.

    reg02-medio_pago = reg_stder-mod_pago .
    reg02-tipo_cuenta_abo = reg_stder-tipo_cta .

    reg02-cod_banco = reg_stder-codigo_banco.
    reg02-cuenta_abo = reg_stder-cuenta_abono.
*    CONCATENATE sy-datum+6(2) '/' sy-datum+4(2) '/' sy-datum+0(4) INTO reg02-fecha_pago.
    CONCATENATE reg_stder-fecha_venc+6(2) '/' reg_stder-fecha_venc+4(2) '/'reg_stder-fecha_venc+0(4) INTO reg02-fecha_pago.
    reg02-reference =''.
    reg02-referenceid =''.
    reg02-tipo_cuenta_car = ''.
    reg02-cuenta_car = ''.
    IF reg_stder-codigo_banco =  027.
      reg02-sucursal = '001'.
    ELSE.
      reg02-sucursal = ''.
    ENDIF.
    reg02-ref_cliente = ''.

    IF reg02-detalle_pago IS INITIAL.
      reg02-detalle_pago = reg_stder-num_docto.
    ELSE.
      CONCATENATE reg02-detalle_pago '-' reg_stder-num_docto INTO reg02-detalle_pago.
    ENDIF.

    AT END OF  rut_prov .
      SUM.
      reg02-monto_pago = reg_stder-monto_docto.


      CONCATENATE
      reg02-rut_prv
                    ','
      reg02-nombre_prv
                          ','
      reg02-mail
                          ','
      reg02-medio_pago
                          ','
      reg02-cod_banco
                          ','
      reg02-tipo_cuenta_abo
                          ','
      reg02-cuenta_abo
                          ','
      reg02-fecha_pago
                          ','
      reg02-reference
                          ','
      reg02-referenceid
                          ','
      reg02-monto_pago
                          ','
      reg02-tipo_cuenta_car
                          ','
      reg02-cuenta_car
                          ','
      reg02-sucursal
                          ','
      reg02-ref_cliente
                          ','
      reg02-detalle_pago

        INTO out_reg_stder-reg.
      APPEND out_reg_stder.
      CLEAR reg02.
    ENDAT.
  ENDLOOP.

ENDFORM.                    " PREPARO_SALIDA
