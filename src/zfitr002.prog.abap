*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFITR002
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFITR002 NO STANDARD PAGE HEADING
                                   LINE-SIZE 132 .

*----------------------------------------------------------------------*
* Tablas usadas.
*----------------------------------------------------------------------*
TABLES : reguh,   "  Datos de pago del programa de pagos              02
         bseg,    "  Segmento de documento de Contabilidad            02
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
         bnka,    "  Maestro de banco                                 02
         bsak,    "  índice secundario para acreedores (part.comp.)   02
         bkpf.    "  Cabecera de documento para Contabilidad          02

* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.
PARAMETER : v_fecha  LIKE reguh-laufd DEFAULT sy-datum  ,
            v_nomina LIKE f110v-laufi DEFAULT 'STDER'   .

PARAMETER  :  "v_descr(25) DEFAULT 'PAGO'       ,
              archivo     LIKE rlgrap-filename DEFAULT 'C:\TRANSFER\'.

PARAMETERS : par_tes RADIOBUTTON GROUP test       " Ejecución en Test
                     DEFAULT 'X',
             par_di  RADIOBUTTON GROUP test.      " Ejecución real

*PARAMETER: FYLETYPE LIKE RLGRAP-FILETYPE.

SELECTION-SCREEN END OF BLOCK marco1 .

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
           rut_prov(12)        TYPE c ,
           nombre(40)          TYPE c ,
*           direccion(40)       TYPE c ,
*           comuna(15)          TYPE c ,
*           ciudad(15)          TYPE c ,
           suc_retiro(03)      TYPE n ,
           mod_pago(02)        TYPE n ,
           codigo_banco(04)    TYPE n ,
           cuenta_abono(18)    TYPE n ,
*           rut_retira(12)      TYPE c ,
*           nom_retira(40)      TYPE c,
           num_docto01(8)     TYPE n ,
           signo_docto01(01)   TYPE c ,
           monto_docto01(11)   TYPE n ,
           num_docto02(8)     TYPE n ,
           signo_docto02(01)   TYPE c ,
           monto_docto02(11)   TYPE n ,
           num_docto03(8)     TYPE n ,
           signo_docto03(01)   TYPE c ,
           monto_docto03(11)   TYPE n ,
           num_docto04(8)     TYPE n ,
           signo_docto04(01)   TYPE c ,
           monto_docto04(11)   TYPE n ,
           num_docto05(8)     TYPE n ,
           signo_docto05(01)   TYPE c ,
           monto_docto05(11)   TYPE n ,
           num_docto06(8)     TYPE n ,
           signo_docto06(01)   TYPE c ,
           monto_docto06(11)   TYPE n ,
           num_docto07(8)     TYPE n ,
           signo_docto07(01)   TYPE c ,
           monto_docto07(11)   TYPE n ,
           num_docto08(8)     TYPE n ,
           signo_docto08(01)   TYPE c ,
           monto_docto08(11)   TYPE n ,
           num_docto09(8)     TYPE n ,
           signo_docto09(01)   TYPE c ,
           monto_docto09(11)   TYPE n ,
           num_docto10(8)     TYPE n ,
           signo_docto10(01)   TYPE c ,
           monto_docto10(11)   TYPE n ,
           num_docto11(8)     TYPE n ,
           signo_docto11(01)   TYPE c ,
           monto_docto11(11)   TYPE n ,
*           sig_tot_pagar(01)   TYPE c,
           total_a_pagar(13)   TYPE n ,
       END OF reg_stder .

DATA: BEGIN OF out_reg_stder OCCURS 0,
           rut_prov(12)        TYPE c ,
           nombre(40)          TYPE c ,
*           direccion(40)       TYPE c ,
*           comuna(15)          TYPE c ,
*           ciudad(15)          TYPE c ,
           suc_retiro(03)      TYPE c ,
           mod_pago(02)        TYPE c ,
           codigo_banco(04)    TYPE c ,
           cuenta_abono(18)    TYPE c ,
*           rut_retira(12)      TYPE c ,
*           nom_retira(40)      TYPE c,
           num_docto01(8)     TYPE c ,
           signo_docto01(01)   TYPE c ,
           monto_docto01(11)   TYPE c ,
           num_docto02(8)     TYPE c ,
           signo_docto02(01)   TYPE c ,
           monto_docto02(11)   TYPE c ,
           num_docto03(8)     TYPE c ,
           signo_docto03(01)   TYPE c ,
           monto_docto03(11)   TYPE c ,
           num_docto04(8)     TYPE c ,
           signo_docto04(01)   TYPE c ,
           monto_docto04(11)   TYPE c ,
           num_docto05(8)     TYPE c ,
           signo_docto05(01)   TYPE c ,
           monto_docto05(11)   TYPE c ,
           num_docto06(8)     TYPE c ,
           signo_docto06(01)   TYPE c ,
           monto_docto06(11)   TYPE c ,
           num_docto07(8)     TYPE c ,
           signo_docto07(01)   TYPE c ,
           monto_docto07(11)   TYPE c ,
           num_docto08(8)     TYPE c ,
           signo_docto08(01)   TYPE c ,
           monto_docto08(11)   TYPE c ,
           num_docto09(8)     TYPE c ,
           signo_docto09(01)   TYPE c ,
           monto_docto09(11)   TYPE c ,
           num_docto10(8)     TYPE c ,
           signo_docto10(01)   TYPE c ,
           monto_docto10(11)   TYPE c ,
           num_docto11(8)     TYPE c ,
           signo_docto11(01)   TYPE c ,
           monto_docto11(11)   TYPE c ,
*           sig_tot_pagar(01)   TYPE c,
           total_a_pagar(13)   TYPE c .
DATA: END OF out_reg_stder.


DATA: BEGIN OF t_doctos OCCURS 0,
        belnr    LIKE bseg-belnr,  " docto
        bukrs    LIKE bseg-bukrs,  " sociedad
        gjahr    LIKE bseg-gjahr , " ejercicio
*        wrbtr    like bseg-wrbtr,  " $$ en la moneda documento
        dmbtr    LIKE bseg-dmbtr,  " $$ en MONEDA DOCUMENTO (HF)
        shkzg    LIKE bseg-shkzg,  " Indicador debe/haber
        qbshb    LIKE bseg-qbshb,  " $$retención en moneda docto
        zuonr    LIKE bseg-zuonr,  " Asignación
      END OF t_doctos.

DATA:    BEGIN OF t_items OCCURS 50,
           xauth(1)      TYPE c,                 " Berechtigung?
           xhell(1)      TYPE c.                 " Hell anzeigen?
        INCLUDE STRUCTURE rfpos.              " Listanzeigen-Struktur
INCLUDE rfeposc9.                     " Kunden-Sonderfelder
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
       monto_x(15)     TYPE c   VALUE 0 ,
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
       prov        LIKE lfa1-lifnr .

FIELD-SYMBOLS : <nombre1_> TYPE ANY ,
                <nombre2_> TYPE ANY ,
                <nombre3_> TYPE ANY .

DATA:  nombre1(25)          ,
       nombre2(25)          ,
       nombre3(25)          ,
       ndx(02)      TYPE n  ,
       lins(04)     TYPE c VALUE 0,
*       num_doc(16)  TYPE c  .
       num_doc(8)  TYPE c  .

DATA: v_rut_ret(12).
DATA: v_nombre_ret(40).

*---------------------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo .
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = archivo.

INITIALIZATION.

  CONCATENATE archivo 'BSANT' '_' sy-datum '_' sy-uzeit '.txt' INTO
  archivo.
  CONDENSE archivo NO-GAPS.


START-OF-SELECTION.

  PERFORM bancos.
  SORT t_bancos BY cod_ac.

* Rescatamos Datos.
  SELECT *  FROM  reguh      CLIENT SPECIFIED
           WHERE  mandt       = sy-mandt
             AND  laufd       = v_fecha
             AND  laufi       = v_nomina
             AND  xvorl       = ' '     .

    IF ( reguh-stcd1 IS INITIAL ) OR ( reguh-zstc1 IS INITIAL ).
      select single stcd1 into reguh-stcd1
        from lfa1 where lifnr = reguh-lifnr.
    ENDIF.

*    IF NOT ( reguh-stcd1 IS INITIAL ).
    IF ( NOT reguh-stcd1 IS INITIAL ) OR ( NOT reguh-zstc1 IS INITIAL ).
      MOVE-CORRESPONDING reguh TO tabla_00.

* Si es vale vista, el banco será el pagador
      IF tabla_00-rzawe = 'V' OR
         tabla_00-rzawe = 'X' OR
         tabla_00-rzawe = 'Y'.
        tabla_00-zbnkl = tabla_00-hbkid.
      ENDIF.

*      READ TABLE t_bancos WITH KEY cod_ac = TABLA_00-ZBNKL .
*      IF sy-subrc = 0.
*        tabla_00-zbnkl = t_bancos-cod_nw.
*      ELSE.
*        tabla_00-zbnkl = '????'.
*      ENDIF.
*
*      READ TABLE t_bancos WITH KEY cod_ac = TABLA_00-HBKID .
*      IF sy-subrc = 0.
*        tabla_00-hbkid = t_bancos-cod_nw.
*      ELSE.
*        tabla_00-hbkid = '????'.
*      ENDIF.

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
    WRITE : /,/, 'No se genero archivo....!!!!!!!!'.

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

*CASE tabla_00-rzawe.             " Vía de pago
*  WHEN 'V'.
*      reg_stder-mod_pago = '01'.              " Vale Vista
**     reg_stder-codigo_banco   =  '999'.      " VV Virtual
*      reg_stder-suc_retiro     =  '999'.      " VV Virtual
*
*  WHEN 'X' or 'Y'.
*      reg_stder-mod_pago = '01'.              " Vale Vista
*      case TABLA_00-ZBNKN+0(5).
*        when 'R0501'.
*              reg_stder-suc_retiro = '411'.
*        when 'R0801'.
*              reg_stder-suc_retiro = '112'.
*        when 'R1201'.
*              reg_stder-suc_retiro = '016'.
*        when 'R1301'.
*              reg_stder-suc_retiro = '266'.
*        when others.
**             clear reg_stder-suc_retiro .
*              reg_stder-suc_retiro = '999'.      " VV Virtual
*     endcase.
*     clear : TABLA_00-ZBNKN .
*
*  WHEN 'T'.
*      reg_stder-mod_pago = '03'.  "Abono en Cta. Cte.
*
*  WHEN 'H'.
*      reg_stder-mod_pago = '04'. " Abono en Cta. Ahorro
*
*  WHEN OTHERS.
*      reg_stder-mod_pago = tabla_00-rzawe.
*ENDCASE.

  TRANSLATE tabla_00-stcd1 USING '- ' .
  CONDENSE  tabla_00-stcd1 NO-GAPS    .

*  reg_stder-rut_prov         = tabla_00-stcd1.

*ARVM 09062009:  Se ajusta Rut a la Izquierda.
  WRITE tabla_00-stcd1 TO reg_stder-rut_prov RIGHT-JUSTIFIED.

  reg_stder-nombre           = tabla_00-znme1 .
*reg_stder-direccion        = tabla_00-stras .

  TRANSLATE  tabla_00-zbnkn USING '- '.
  CONDENSE tabla_00-zbnkn NO-GAPS.

  reg_stder-codigo_banco     =  tabla_00-zbnkl .
  reg_stder-cuenta_abono     =  tabla_00-zbnkn .

  IF tabla_00-rzawe = 'V'.
    reg_stder-mod_pago = '01'.
    reg_stder-suc_retiro = '999'.
    reg_stder-codigo_banco = '0000'.
*    reg_stder-rut_retira = '000000000000'.
*    reg_stder-nom_retira = ''.

*-------------------------------------------------
*Recuperamos Rut y Nombre de persona que retira el Vale Vista.
*Rut de quien retira Vale Vista

*    SELECT SINGLE stcd2
*      INTO v_rut_ret
*      FROM lfa1
*      WHERE lifnr = tabla_00-lifnr.
*
*    IF sy-subrc = 0.
*      TRANSLATE  v_rut_ret USING '- '.
*      CONDENSE v_rut_ret NO-GAPS.
*      WRITE v_rut_ret TO reg_stder-rut_retira RIGHT-JUSTIFIED.
*    ENDIF.
**-------------------------------------------------
**Nombre de quien retira vale vista
*
*    SELECT SINGLE kverm
*      INTO v_nombre_ret
*      FROM lfb1
*      WHERE lifnr = tabla_00-lifnr
*       AND  bukrs = tabla_00-zbukr.
*
*    IF sy-subrc = 0.
*      MOVE v_nombre_ret TO reg_stder-nom_retira.
*    ENDIF.
*-------------------------------------------------

  ELSE.
    reg_stder-mod_pago = tabla_00-zbkon.
  ENDIF.

*reg_stder-comuna          =
*reg_stder-ciudad          =
*reg_stder-suc_retiro      =

  acreedor = tabla_00-lifnr.

****Es multisociedad ???

  IF tabla_00-zbukr <> tabla_00-absbu.  " Soc_pagadora y Soc.emisora

*****
*** ff 02.03.06
*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
    SELECT SINGLE * FROM  bseg
      CLIENT SPECIFIED
              WHERE  mandt       = sy-mandt
                     AND bukrs   = tabla_00-zbukr
                     AND belnr   = tabla_00-vblnr
*agregamos la fecha (ff 01.03.06)
*                   AND AUGDT   = TABLA_00-ZALDT
                     AND zfbdt   = tabla_00-zaldt           " ff 150306
                     AND koart   = 'K'.

    IF sy-subrc = 0.
      eje_pago = bseg-gjahr.
    ENDIF.


*****
    SELECT SINGLE * FROM  bkpf CLIENT SPECIFIED
           WHERE  mandt  = sy-mandt
           AND    bukrs  = tabla_00-zbukr
           AND    belnr  = tabla_00-vblnr
           AND    gjahr  = eje_pago.          " (ff 01.03.06)

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
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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

*** ff 02.03.06
*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
    SELECT SINGLE * FROM  bseg   CLIENT SPECIFIED
              WHERE  mandt       = sy-mandt
                     AND bukrs   = tabla_00-zbukr
                     AND belnr   = tabla_00-vblnr
*agregamos la fecha (ff 01.03.06)
*                   AND AUGDT   = TABLA_00-ZALDT
                     AND zfbdt   = tabla_00-zaldt           " ff 150306
                     AND koart   = 'K'.

    IF sy-subrc = 0.
      eje_pago = bseg-gjahr.
    ENDIF.

***
    soc_pago = tabla_00-zbukr.
    doc_pago = tabla_00-vblnr.
*    acreedor = tabla_00-lifnr.
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

* buscamos doctos asociados
***SELECT *  FROM  bseg  CLIENT SPECIFIED
***         WHERE  mandt   = sy-mandt
***           AND  bukrs   = soc_pago    " soc.pagadora
***           AND  augbl   = doc_pago    " Núm. doc. pago
***           AND  koart   = 'K'.        " clase cta.
***
***        check bseg-augbl <>  bseg-belnr.
***
***        move-corresponding bseg to t_doctos.
***        append t_doctos.
***ENDSELECT.

  SELECT * FROM bsak CLIENT SPECIFIED
          WHERE mandt   = sy-mandt
            AND  bukrs  = soc_pago    " soc.pagadora
            AND  augbl  = doc_pago    " Núm. doc.
            AND  lifnr  = acreedor
            AND  auggj  = eje_pago.   " ff 02.03.06

    CHECK bsak-augbl <>  bsak-belnr.
    MOVE-CORRESPONDING bsak TO t_doctos.
**      el valor sera el total menos retencion
*        t_doctos-wrbtr = t_doctos-wrbtr - t_doctos-qbshb.
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
      APPEND reg_stder.
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
*     t_doctos-wrbtr = t_doctos-wrbtr * -1.
      t_doctos-dmbtr = t_doctos-dmbtr * -1.
    ENDIF.

*  t_doctos-wrbtr = t_doctos-wrbtr * 100.
    t_doctos-dmbtr = t_doctos-dmbtr * 100.

*  n_monto        = n_monto + t_doctos-wrbtr.
    n_monto        = n_monto + t_doctos-dmbtr.

*  t_doctos-wrbtr = abs( t_doctos-wrbtr ).
    t_doctos-dmbtr = ABS( t_doctos-dmbtr ).


** asignamos numero documento
*  concatenate t_doctos-belnr+00(02)
*              t_doctos-belnr+04(06) into num_doc.
*
*
*  SELECT SINGLE * FROM  BKPF CLIENT SPECIFIED
*         WHERE  MANDT  = sy-mandt
*         AND    BUKRS  = t_doctos-bukrs
*         AND    BELNR  = t_doctos-belnr
*         AND    GJAHR  = t_doctos-gjahr.
*
*  if sy-subrc = 0 and bkpf-xblnr is not initial.
*    num_doc = bkpf-xblnr.
*  endif.

*------------------------------------------
*ARVM 09062009: Se cambia largo de num_doc de 16 a 8

    num_doc = t_doctos-zuonr(8).


*  if sy-subrc = 0.
*
*     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*       EXPORTING
*         input  = reg_stder-rut_prov
*       IMPORTING
*         output = prov.
*
** buscamos si existe como funcionario
*      SELECT SINGLE * FROM  LFB1 CLIENT SPECIFIED
*              WHERE  MANDT  = sy-mandt
*                AND  PERNR  = prov(09).
*
*      if sy-subrc <> 0.
**     si no es funcionario nos quedamos con la referencia
*         condense BKPF-XBLNR no-gaps.
*         largo = strlen( BKPF-XBLNR ).
**        Revisamos que referencia tenga algo.
*         if largo <> 0.
**           revisamos si es numerico
*            translate BKPF-XBLNR using 'F C - '.
*            condense BKPF-XBLNR no-gaps.
*            if  BKPF-XBLNR co '1234567890 '.
**               colocamos campo referencia
*                num_doc = BKPF-XBLNR.
*            endif.
*         endif.
*      endif.
*
*
**     SELECT SINGLE * FROM  LFA1 CLIENT SPECIFIED
**            WHERE  MANDT  = sy-mandt
**              AND  LIFNR  = prov.
**
**     if sy-subrc = 0.
**       condense BKPF-XBLNR no-gaps.
**       largo = strlen( BKPF-XBLNR ).
***Revisamos que referencia tenga algo.
**       if largo <> 0.
**          if lfa1-brsch ne 'P017'.  " P017 = funcionario
***            revisamos si es numerico
**             translate BKPF-XBLNR using 'F C - '.
**             condense BKPF-XBLNR no-gaps.
**             if  BKPF-XBLNR co '1234567890 '.
***                colocamos campo referencia
**                 num_doc = BKPF-XBLNR.
**             endif.
**          endif.
**       endif.
**     endif.
*
*
*
* endif.
******
    CASE pos__ .

      WHEN 1.
        reg_stder-num_docto01    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto01 = '-'.
        ELSE.
          reg_stder-signo_docto01 = '+'.
        ENDIF.
*      reg_stder-signo_docto01  = '0'.
        reg_stder-monto_docto01  = t_doctos-dmbtr.
      WHEN 2.
        reg_stder-num_docto02    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto02 = '-'.
        ELSE.
          reg_stder-signo_docto02 = '+'.
        ENDIF.
*      reg_stder-signo_docto02  = '0'.
        reg_stder-monto_docto02  = t_doctos-dmbtr.
      WHEN 3.
        reg_stder-num_docto03    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto03 = '-'.
        ELSE.
          reg_stder-signo_docto03 = '+'.
        ENDIF.
*      reg_stder-signo_docto03  = '0'.
        reg_stder-monto_docto03  = t_doctos-dmbtr.
      WHEN 4.
        reg_stder-num_docto04    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto04 = '-'.
        ELSE.
          reg_stder-signo_docto04 = '+'.
        ENDIF.
*      reg_stder-signo_docto04  = '0'.
        reg_stder-monto_docto04  = t_doctos-dmbtr.
      WHEN 5.
        reg_stder-num_docto05    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto05 = '-'.
        ELSE.
          reg_stder-signo_docto05 = '+'.
        ENDIF.
*      reg_stder-signo_docto05  = '0'.
        reg_stder-monto_docto05  = t_doctos-dmbtr.
      WHEN 6.
        reg_stder-num_docto06    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto06 = '-'.
        ELSE.
          reg_stder-signo_docto06 = '+'.
        ENDIF.
*      reg_stder-signo_docto06  = '0'.
        reg_stder-monto_docto06  = t_doctos-dmbtr.
      WHEN 7.
        reg_stder-num_docto07    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto07 = '-'.
        ELSE.
          reg_stder-signo_docto07 = '+'.
        ENDIF.
*      reg_stder-signo_docto07  = '0'.
        reg_stder-monto_docto07  = t_doctos-dmbtr.
      WHEN 8.
        reg_stder-num_docto08    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto08 = '-'.
        ELSE.
          reg_stder-signo_docto08 = '+'.
        ENDIF.
*      reg_stder-signo_docto08  = '0'.
        reg_stder-monto_docto08  = t_doctos-dmbtr.
      WHEN 9.
        reg_stder-num_docto09    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto09 = '-'.
        ELSE.
          reg_stder-signo_docto09 = '+'.
        ENDIF.
*      reg_stder-signo_docto09  = '0'.
        reg_stder-monto_docto09  = t_doctos-dmbtr.
      WHEN 10.
        reg_stder-num_docto10    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto10 = '-'.
        ELSE.
          reg_stder-signo_docto10 = '+'.
        ENDIF.
*      reg_stder-signo_docto10  = '0'.
        reg_stder-monto_docto10  = t_doctos-dmbtr.
      WHEN 11.
        reg_stder-num_docto11    = num_doc.
        IF t_doctos-shkzg = 'S'.
          reg_stder-signo_docto11 = '-'.
        ELSE.
          reg_stder-signo_docto11 = '+'.
        ENDIF.
*      reg_stder-signo_docto11  = '0'.
        reg_stder-monto_docto11  = t_doctos-dmbtr.

    ENDCASE.

  ENDLOOP.

*ARVM
*Agrega signo a monto total.
  reg_stder-total_a_pagar = n_monto.
*  IF n_monto > 0.
*    reg_stder-sig_tot_pagar = '+'.
*  ELSE.
*    reg_stder-sig_tot_pagar = '-'.
*  ENDIF.
  APPEND reg_stder.

ENDFORM.                               " LLENA_ESTRUCTURA


*&---------------------------------------------------------------------*
*&      Form  bajar_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bajar_archivo.
*-----------------*

  DATA: BEGIN OF ti_archivo OCCURS 0,
          linea(500),
        END OF ti_archivo.

  DATA: v_encabezado LIKE LINE OF out_reg_stder.

  DATA: monto1(16), monto2(16), monto3(16), monto4(16), monto5(16), monto6(16), monto7(16), monto8(16), monto9(16), monto10(16),
        monto11(16).

  DATA : nombre_a  TYPE string.
  nombre_a = archivo.
  IF NOT reg_stder[] IS INITIAL.
*    concatenate 'Rut Beneficiario' 'Nombre Beneficiario' 'Cod. Modalidad' 'Cod Banco' 'Cta Abono' 'Cod Sucursal' 'N Factura 1' 'Monto 1' 'N Factura 2' 'Monto 2'
*                'N Factura 3' 'Monto 3' 'N Factura 4' 'Monto 4' 'N Factura 5' 'Monto 5' 'N Factura 6' 'Monto 6' 'N Factura 7' 'Monto 7' ' Factura 8' 'Monto 8'
*                'N Factura 9' 'Monto 9' 'N Factura 10' 'Monto 10' 'N Factura 11' 'Monto 11' 'Monto Total'
*                into ti_archivo-linea separated by ';'.


*    CONCATENATE 'Rut Beneficiario' 'Nombre Beneficiario' 'Cod. Modalidad' 'Cod Banco' 'Cta Abono' 'N Factura 1' 'Monto 1' 'N Factura 2' 'Monto 2'
*                'N Factura 3' 'Monto 3' 'N Factura 4' 'Monto 4' 'N Factura 5' 'Monto 5' 'N Factura 6' 'Monto 6' 'N Factura 7' 'Monto 7' 'N Factura 8' 'Monto 8'
*                'N Factura 9' 'Monto 9' 'N Factura 10' 'Monto 10' 'N Factura 11' 'Monto 11' 'Monto Total'
**                INTO ti_archivo-linea SEPARATED BY ';'.
*                 INTO v_encabezado.

*    v_encabezado-rut_prov      = 'Rut Beneficiario'.
*    v_encabezado-nombre        = 'Nombre Beneficiario'.
*    v_encabezado-mod_pago      = 'Cod. Modalidad'.
*    v_encabezado-codigo_banco  = 'Cod Banco'.
*    v_encabezado-cuenta_abono  = 'Cta Abono'.
*    v_encabezado-num_docto01   = 'N Factura 1'.
**v_encabezado-signo_docto01 =
*    v_encabezado-monto_docto01 = 'Monto 1'.
*    v_encabezado-num_docto02   = 'N Factura 2'.
**v_encabezado-signo_docto02 =
*    v_encabezado-monto_docto02 = 'Monto 2'.
*    v_encabezado-num_docto03   = 'N Factura 3'.
**v_encabezado-signo_docto03 =
*    v_encabezado-monto_docto03 = 'Monto 3'.
*    v_encabezado-num_docto04   = 'N Factura 4'.
**v_encabezado-signo_docto04 =
*    v_encabezado-monto_docto04 = 'Monto 4'.
*    v_encabezado-num_docto05   = 'N Factura 5'.
**v_encabezado-signo_docto05 =
*    v_encabezado-monto_docto05 = 'Monto 5'.
*    v_encabezado-num_docto06   = 'N Factura 6'.
**v_encabezado-signo_docto06 =
*    v_encabezado-monto_docto06 = 'Monto 6'.
*    v_encabezado-num_docto07   = 'N Factura 7'.
**v_encabezado-signo_docto07 =
*    v_encabezado-monto_docto07 = 'Monto 7'.
*    v_encabezado-num_docto08   = 'N Factura 8'.
**v_encabezado-signo_docto08 =
*    v_encabezado-monto_docto08 = 'Monto 8'.
*    v_encabezado-num_docto09   = 'N Factura 9'.
**v_encabezado-signo_docto09 =
*    v_encabezado-monto_docto09 = 'Monto 9'.
*    v_encabezado-num_docto10   = 'N Factura 10'.
**v_encabezado-signo_docto10 =
*    v_encabezado-monto_docto10 = 'Monto 10'.
*    v_encabezado-num_docto11   = 'N Factura 11'.
**v_encabezado-signo_docto11 =
*    v_encabezado-monto_docto11 = 'Monto 11'.
**v_encabezado-sig_tot_pagar =
*    v_encabezado-total_a_pagar =  'Monto Total'.
    APPEND ti_archivo.

  ENDIF.


  LOOP AT reg_stder.
    CLEAR ti_archivo.

    CONCATENATE reg_stder-signo_docto01
                reg_stder-monto_docto01 INTO monto1.
    CONCATENATE reg_stder-signo_docto02
                reg_stder-monto_docto02 INTO monto2.
    CONCATENATE reg_stder-signo_docto03
                reg_stder-monto_docto03 INTO monto3.
    CONCATENATE reg_stder-signo_docto04
                reg_stder-monto_docto04 INTO monto4.
    CONCATENATE reg_stder-signo_docto05
                reg_stder-monto_docto05 INTO monto5.
    CONCATENATE reg_stder-signo_docto06
                reg_stder-monto_docto06 INTO monto6.
    CONCATENATE reg_stder-signo_docto07
                reg_stder-monto_docto07 INTO monto7.
    CONCATENATE reg_stder-signo_docto08
                reg_stder-monto_docto08 INTO monto8.
    CONCATENATE reg_stder-signo_docto09
                reg_stder-monto_docto09 INTO monto9.
    CONCATENATE reg_stder-signo_docto10
                reg_stder-monto_docto10 INTO monto10.
    CONCATENATE reg_stder-signo_docto11
                reg_stder-monto_docto11 INTO monto11.

    CONCATENATE reg_stder-rut_prov
                reg_stder-nombre
                reg_stder-mod_pago
                reg_stder-codigo_banco
                reg_stder-cuenta_abono
*                reg_stder-suc_retiro
                reg_stder-num_docto01
*                reg_stder-signo_docto01
*                reg_stder-monto_docto01
                monto1
                reg_stder-num_docto02
*                reg_stder-signo_docto02
*                reg_stder-monto_docto02
                monto2
                reg_stder-num_docto03
*                reg_stder-signo_docto03
*                reg_stder-monto_docto03
                monto3
                reg_stder-num_docto04
*                reg_stder-signo_docto04
*                reg_stder-monto_docto04
                monto4
                reg_stder-num_docto05
*                reg_stder-signo_docto05
*                reg_stder-monto_docto05
                monto5
                reg_stder-num_docto06
*                reg_stder-signo_docto06
*                reg_stder-monto_docto06
                monto6
                reg_stder-num_docto07
*                reg_stder-signo_docto07
*                reg_stder-monto_docto07
                monto7
                reg_stder-num_docto08
*                reg_stder-signo_docto08
*                reg_stder-monto_docto08
                monto8
                reg_stder-num_docto09
*                reg_stder-signo_docto09
*                reg_stder-monto_docto09
                monto9
                reg_stder-num_docto10
*                reg_stder-signo_docto10
*                reg_stder-monto_docto10
                monto10
                reg_stder-num_docto11
*                reg_stder-signo_docto11
*                reg_stder-monto_docto10
                monto11
                reg_stder-total_a_pagar
*                INTO ti_archivo-linea SEPARATED BY ';'.
                INTO ti_archivo-linea.
    APPEND ti_archivo.
  ENDLOOP.


*  CALL FUNCTION 'GUI_DOWNLOAD'
*    EXPORTING
*      filename                = nombre_a
**      filetype                = 'ASC'
*      append                  = ' '
*      confirm_overwrite       = 'X'
*    TABLES
**      data_tab                = reg_stder
*      data_tab               = ti_archivo
*    EXCEPTIONS
*      file_write_error        = 1
*      no_batch                = 2
*      gui_refuse_filetransfer = 3
*      invalid_type            = 4
*      no_authority            = 5
*      unknown_error           = 6
*      header_not_allowed      = 7
*      separator_not_allowed   = 8
*      filesize_not_allowed    = 9
*      header_too_long         = 10
*      dp_error_create         = 11
*      dp_error_send           = 12
*      dp_error_write          = 13
*      unknown_dp_error        = 14
*      access_denied           = 15
*      dp_out_of_memory        = 16
*      disk_full               = 17
*      dp_timeout              = 18
*      file_not_found          = 19
*      dataprovider_exception  = 20
*      control_flush_error     = 21
*      OTHERS                  = 22.


*----------------------------------------------
*ARVM Se agrega Signo para montos positivos
*Se cambia archivo de salida, para que quede con anchos fijos.

*  MOVE-CORRESPONDING v_encabezado TO out_reg_stder.
*  APPEND out_reg_stder.
*  CLEAR  out_reg_stder.

  LOOP AT reg_stder.
    MOVE-CORRESPONDING reg_stder TO out_reg_stder.
    APPEND out_reg_stder.
    CLEAR  out_reg_stder.
  ENDLOOP.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = nombre_a
      filetype                = 'ASC'
      append                  = ' '
      confirm_overwrite       = 'X'
    TABLES
*      data_tab                = reg_stder
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
    WRITE : / 'Se genero archivo :', nombre_a.
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
  CLEAR t_bancos[].

*   select * from zbc_cod_bancos client specified.
*
*      move-corresponding zbc_cod_bancos to t_bancos.
*      APPEND t_bancos.
*   endselect.

*  t_bancos-cod_ac = 'BCHI'.t_bancos-cod_nw = '001'. " Bco. Chile
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'BICH'.t_bancos-cod_nw = '009'. " Bco.Internacional
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'BECH'.t_bancos-cod_nw = '012'. " Bco. Estado
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'BKSA'.t_bancos-cod_nw = '014'. " Scotiabank Sudam.
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'CRED'.t_bancos-cod_nw = '016'. " BCI
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'CONB'.t_bancos-cod_nw = '027'. " Corp Banca
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'BICE'.t_bancos-cod_nw = '028'. " Bice
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'CITI'.t_bancos-cod_nw = '033'. " Citibank
*  APPEND t_bancos.
  t_bancos-cod_ac = 'BSANT'.t_bancos-cod_nw = '037'. " Santander chile
  APPEND t_bancos.
*  t_bancos-cod_ac = 'FNBB'.t_bancos-cod_nw = '039'. " Bank Boston N.A.
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'BOTK'.t_bancos-cod_nw = '045'. " Tokio Mitsubishi
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'ABNA'.t_bancos-cod_nw = '046'. " ABN AMRO BANK
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'BSCL'.t_bancos-cod_nw = '049'. " Security
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'BHIF'.t_bancos-cod_nw = '504'. " BBVA
*  APPEND t_bancos.
*  t_bancos-cod_ac = 'BADE'.t_bancos-cod_nw = '507'. " Desarrollo
*  APPEND t_bancos.
ENDFORM.                    "bancos




*&---------------------------------------------------------------------*
*&      Form  listado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM listado.
*-----------*
*check 1 = 2.

  WRITE : /43   'NOMINA DE PAGO PROVEEDORES CUENTA BANCO SANTANDER' ,
          /,/53 'FECHA DEL INFORME ' , v_fecha                  ,
          /,/47 'Identificación De Propuesta de Pago', v_nomina .

  SKIP 1.

  WRITE sy-uline(125).

  WRITE : /01  'Mp'               ,   " 01   " mdiopago
           04  'Doc.Egreso'       ,   " 10
           15  'Soc'              ,   " 04
           22  'Referencia'       ,   " 25   " bkpf-xblnr 16
           41  'Proveedor'        ,   " 16
           60  'Nombre Proveedor' ,   " 35
           095 'Monto'            ,   " 15
           113 'Total'            .

  WRITE : / sy-uline(125).

  monto_p = 0.
  LOOP AT tabla_00.

    IF aux_prov <> tabla_00-stcd1.
      aux_prov = tabla_00-stcd1.
      IF monto_p <> 0.
        WRITE 107 monto_p CURRENCY 'CLP'.
      ENDIF.
      monto_p = 0.
    ENDIF.

    t_monto = 0.
    CLEAR t_items[].

    IF tabla_00-zbukr <> tabla_00-absbu.  " Soc_pagadora y Soc.emisora

      SELECT SINGLE * FROM  bkpf CLIENT SPECIFIED
            WHERE  mandt  = sy-mandt
            AND    bukrs  = tabla_00-zbukr  " Soc. Paga
            AND    belnr  = tabla_00-vblnr.  " Doc. pago
*          AND    gjahr  = '2004'.

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
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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
  WRITE 107 monto_p CURRENCY 'CLP'.

* Imprimimos total Final
  WRITE : /,/100 'Total' ,
             107  monto_z CURRENCY 'CLP'.

  SKIP 4.

  WRITE :/25 '___________________',   "Subrayado CAJA
          50 '___________________',   "Subrayado APODERADO
          75 '___________________'.   "Subrayado APODERADO
  SKIP .
  WRITE :/28 'Tesoreria' ,              "para firma de caja
          54 'Apoderado' ,            "para firma apoderado
          79 'Apoderado' .            "para firma apoderado

ENDFORM.                    "listado

*&---------------------------------------------------------------------*
*&      Form  doctos__
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM doctos__.
*------------*
  acreedor = tabla_00-lifnr.
  CLEAR t_doctos[].


*** ff 02.03.06
*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
  SELECT SINGLE * FROM  bseg   CLIENT SPECIFIED
            WHERE  mandt       = sy-mandt
                   AND bukrs   = tabla_00-zbukr
                   AND belnr   = tabla_00-vblnr
*agregamos la fecha (ff 01.03.06)
*                   AND AUGDT   = TABLA_00-ZALDT
                   AND zfbdt   = tabla_00-zaldt             " ff 150306
                   AND koart   = 'K'.

  IF sy-subrc = 0.
    eje_pago = bseg-gjahr.
  ENDIF.


*****

  SELECT * FROM bsak CLIENT SPECIFIED
          WHERE mandt   = sy-mandt
            AND  bukrs  = soc_pago    " soc.pagadora
            AND  augbl  = doc_pago    " Núm. doc.
            AND  lifnr  = acreedor
            AND  auggj  = eje_pago.

    CHECK bsak-augbl <>  bsak-belnr.

    MOVE-CORRESPONDING bsak TO t_doctos.
**      el valor sera el total menos retencion
*        t_doctos-dmbtr = t_doctos-dmbtr - t_doctos-qbshb.

    APPEND t_doctos.
  ENDSELECT.

  LOOP AT t_doctos.

* Buscamos textos
    SELECT SINGLE * FROM  bkpf CLIENT SPECIFIED
            WHERE  mandt  = sy-mandt
            AND    bukrs  = soc_pago          " Soc. Paga
            AND    gjahr  = t_doctos-gjahr
            AND    belnr  =  t_doctos-belnr.   " Doc. pago

*Invertimos signo para el listado

    IF t_doctos-shkzg = 'S'.
      t_doctos-dmbtr = t_doctos-dmbtr * -1.
    ENDIF.

    t_doctos-dmbtr = t_doctos-dmbtr .

    WRITE : /001 tabla_00-rzawe ,
             003 tabla_00-vblnr  ,  " t_doctos-belnr ,
             014 soc_pago       ,
*            019 bkpf-xblnr     ,  " bkpf-bktxt
             019 t_doctos-zuonr     ,  " referencia factura
             037 tabla_00-stcd1 ,
             054 tabla_00-znme1 ,
             090 t_doctos-dmbtr CURRENCY 'CLP'.
    t_monto = t_monto  + t_doctos-dmbtr.
    monto_p  = monto_p + t_doctos-dmbtr.

  ENDLOOP.



  monto_y = t_monto .

  monto_z = monto_z + monto_y.
ENDFORM.                    "doctos__
