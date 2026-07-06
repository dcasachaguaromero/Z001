*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
REPORT ZFITR001 NO STANDARD PAGE HEADING
                                   LINE-SIZE 132 .

*----------------------------------------------------------------------*
* Tablas usadas.
*----------------------------------------------------------------------*
TABLES : REGUH,   "  Datos de pago del programa de pagos              02
         BSEG,    "  Segmento de documento de Contabilidad            02
         LFA1,    "  Maestro de proveedores (parte general)           02
         LFB1,
         BNKA,    "  Maestro de banco                                 02
         BSAK,    "  índice secundario para acreedores (part.comp.)   02
         BKPF.    "  Cabecera de documento para Contabilidad          02

* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK MARCO1 WITH FRAME TITLE TEXT-001.
PARAMETER : V_FECHA  LIKE REGUH-LAUFD DEFAULT SY-DATUM  ,
            V_NOMINA LIKE F110V-LAUFI DEFAULT 'STDER'   .

PARAMETER  :  "v_descr(25) DEFAULT 'PAGO'       ,
              ARCHIVO     LIKE RLGRAP-FILENAME DEFAULT 'C:\TRANSFER\'.

PARAMETERS : PAR_TES RADIOBUTTON GROUP TEST       " Ejecución en Test
                     DEFAULT 'X',
             PAR_DI  RADIOBUTTON GROUP TEST.      " Ejecución real

*PARAMETER: FYLETYPE LIKE RLGRAP-FILETYPE.

SELECTION-SCREEN END OF BLOCK MARCO1 .

DATA : BEGIN OF TABLA_00 OCCURS 0.
        INCLUDE STRUCTURE REGUH.
DATA : END OF TABLA_00.

DATA : MONTO_TOTAL(13)                    ,
       TOTAL_PROVEEDOR LIKE TABLA_00-RWBTR.

DATA : BEGIN OF T_BANCOS OCCURS 0     ,
         COD_AC      LIKE REGUH-ZBNKL ,
         COD_NW(03)  TYPE C           ,
       END OF T_BANCOS                .

DATA : BEGIN OF REG_STDER OCCURS 0,
           RUT_PROV(12)        TYPE C ,
           NOMBRE(40)          TYPE C ,
*           direccion(40)       TYPE c ,
*           comuna(15)          TYPE c ,
*           ciudad(15)          TYPE c ,
           SUC_RETIRO(03)      TYPE N ,
           MOD_PAGO(02)        TYPE N ,
           CODIGO_BANCO(03)    TYPE N ,
           CUENTA_ABONO(18)    TYPE N ,
*           rut_retira(12)      TYPE c ,
*           nom_retira(40)      TYPE c,
           NUM_DOCTO01(8)     TYPE N ,
           SIGNO_DOCTO01(01)   TYPE C ,
           MONTO_DOCTO01(11)   TYPE N ,
           NUM_DOCTO02(8)     TYPE N ,
           SIGNO_DOCTO02(01)   TYPE C ,
           MONTO_DOCTO02(11)   TYPE N ,
           NUM_DOCTO03(8)     TYPE N ,
           SIGNO_DOCTO03(01)   TYPE C ,
           MONTO_DOCTO03(11)   TYPE N ,
           NUM_DOCTO04(8)     TYPE N ,
           SIGNO_DOCTO04(01)   TYPE C ,
           MONTO_DOCTO04(11)   TYPE N ,
           NUM_DOCTO05(8)     TYPE N ,
           SIGNO_DOCTO05(01)   TYPE C ,
           MONTO_DOCTO05(11)   TYPE N ,
           NUM_DOCTO06(8)     TYPE N ,
           SIGNO_DOCTO06(01)   TYPE C ,
           MONTO_DOCTO06(11)   TYPE N ,
           NUM_DOCTO07(8)     TYPE N ,
           SIGNO_DOCTO07(01)   TYPE C ,
           MONTO_DOCTO07(11)   TYPE N ,
           NUM_DOCTO08(8)     TYPE N ,
           SIGNO_DOCTO08(01)   TYPE C ,
           MONTO_DOCTO08(11)   TYPE N ,
           NUM_DOCTO09(8)     TYPE N ,
           SIGNO_DOCTO09(01)   TYPE C ,
           MONTO_DOCTO09(11)   TYPE N ,
           NUM_DOCTO10(8)     TYPE N ,
           SIGNO_DOCTO10(01)   TYPE C ,
           MONTO_DOCTO10(11)   TYPE N ,
           NUM_DOCTO11(8)     TYPE N ,
           SIGNO_DOCTO11(01)   TYPE C ,
           MONTO_DOCTO11(11)   TYPE N ,
*           sig_tot_pagar(01)   TYPE c,
           TOTAL_A_PAGAR(13)   TYPE N ,
       END OF REG_STDER .

DATA: BEGIN OF OUT_REG_STDER OCCURS 100,
           RUT_PROV(12)        TYPE C ,
           NOMBRE(40)          TYPE C ,
*           direccion(40)       TYPE c ,
*           comuna(15)          TYPE c ,
*           ciudad(15)          TYPE c ,
           SUC_RETIRO(03)      TYPE C ,
           MOD_PAGO(02)        TYPE C ,
           CODIGO_BANCO(03)    TYPE C ,
           CUENTA_ABONO(18)    TYPE C ,
*           rut_retira(12)      TYPE c ,
*           nom_retira(40)      TYPE c,
           NUM_DOCTO01(8)     TYPE C ,
           SIGNO_DOCTO01(01)   TYPE C ,
           MONTO_DOCTO01(11)   TYPE C ,
           NUM_DOCTO02(8)     TYPE C ,
           SIGNO_DOCTO02(01)   TYPE C ,
           MONTO_DOCTO02(11)   TYPE C ,
           NUM_DOCTO03(8)     TYPE C ,
           SIGNO_DOCTO03(01)   TYPE C ,
           MONTO_DOCTO03(11)   TYPE C ,
           NUM_DOCTO04(8)     TYPE C ,
           SIGNO_DOCTO04(01)   TYPE C ,
           MONTO_DOCTO04(11)   TYPE C ,
           NUM_DOCTO05(8)     TYPE C ,
           SIGNO_DOCTO05(01)   TYPE C ,
           MONTO_DOCTO05(11)   TYPE C ,
           NUM_DOCTO06(8)     TYPE C ,
           SIGNO_DOCTO06(01)   TYPE C ,
           MONTO_DOCTO06(11)   TYPE C ,
           NUM_DOCTO07(8)     TYPE C ,
           SIGNO_DOCTO07(01)   TYPE C ,
           MONTO_DOCTO07(11)   TYPE C ,
           NUM_DOCTO08(8)     TYPE C ,
           SIGNO_DOCTO08(01)   TYPE C ,
           MONTO_DOCTO08(11)   TYPE C ,
           NUM_DOCTO09(8)     TYPE C ,
           SIGNO_DOCTO09(01)   TYPE C ,
           MONTO_DOCTO09(11)   TYPE C ,
           NUM_DOCTO10(8)     TYPE C ,
           SIGNO_DOCTO10(01)   TYPE C ,
           MONTO_DOCTO10(11)   TYPE C ,
           NUM_DOCTO11(8)     TYPE C ,
           SIGNO_DOCTO11(01)   TYPE C ,
           MONTO_DOCTO11(11)   TYPE C ,
*           sig_tot_pagar(01)   TYPE c,
           TOTAL_A_PAGAR(13)   TYPE C .
DATA: END OF OUT_REG_STDER.


DATA: BEGIN OF T_DOCTOS OCCURS 0,
        BELNR    LIKE BSEG-BELNR,  " docto
        BUKRS    LIKE BSEG-BUKRS,  " sociedad
        GJAHR    LIKE BSEG-GJAHR , " ejercicio
*        wrbtr    like bseg-wrbtr,  " $$ en la moneda documento
        DMBTR    LIKE BSEG-DMBTR,  " $$ en MONEDA DOCUMENTO (HF)
        SHKZG    LIKE BSEG-SHKZG,  " Indicador debe/haber
        QBSHB    LIKE BSEG-QBSHB,  " $$retención en moneda docto
        ZUONR    LIKE BSEG-ZUONR,  " Asignación
      END OF T_DOCTOS.

DATA:    BEGIN OF T_ITEMS OCCURS 50,
           XAUTH(1)      TYPE C,                 " Berechtigung?
           XHELL(1)      TYPE C.                 " Hell anzeigen?
        INCLUDE STRUCTURE RFPOS.              " Listanzeigen-Struktur
INCLUDE RFEPOSC9.                     " Kunden-Sonderfelder
DATA:      XBKPF(1)      TYPE C,                 " BKPF nachgelesen?
           XBSEG(1)      TYPE C,                 " BSEG nachgelesen?
           XBSEC(1)      TYPE C,                 " BSEC nachgelesen?
           XBSED(1)      TYPE C,                 " BSED nachgelesen?
           XPAYR(1)      TYPE C,                 " PAYR nachgelesen?
           XBSEGC(1)     TYPE C,                 " BSEGC nachgelesen?
           XBSBV(1)      TYPE C,                 " BSBV nachgelesen?
           XMOD(1)       TYPE C,                 " POSTAB modifiziert?
         END OF T_ITEMS.

DATA : N_MONTO(13) TYPE C          ,
       LARGO(02)   TYPE C VALUE 0  ,
       DV(01)      TYPE C          ,
       R1(11)      TYPE N          ,
       MONTO_X(15)     TYPE C   VALUE 0 ,
       MONTO_Y     LIKE BSEG-DMBTR ,
       MONTO_Z     LIKE BSEG-DMBTR ,
       T_MONTO     LIKE BSEG-DMBTR ,
       AUX_PROV    LIKE REGUH-STCD1 ,
       SOC_PAGO    LIKE REGUH-ZBUKR ,   " soc.pagadora
       DOC_PAGO    LIKE REGUH-VBLNR ,
       EJE_PAGO    LIKE BSEG-GJAHR  ,
       ACREEDOR    LIKE BSAK-LIFNR ,
       POS__       LIKE SY-TABIX   ,
       MONTO_P     LIKE BSEG-WRBTR ,
       PROV        LIKE LFA1-LIFNR .

FIELD-SYMBOLS : <NOMBRE1_> TYPE ANY ,
                <NOMBRE2_> TYPE ANY ,
                <NOMBRE3_> TYPE ANY .

DATA:  NOMBRE1(25)          ,
       NOMBRE2(25)          ,
       NOMBRE3(25)          ,
       NDX(02)      TYPE N  ,
       LINS(04)     TYPE C VALUE 0,
*       num_doc(16)  TYPE c  .
       NUM_DOC(8)  TYPE C  .

DATA: V_RUT_RET(12).
DATA: V_NOMBRE_RET(40).

*---------------------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR ARCHIVO .
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      FILE_NAME = ARCHIVO.

INITIALIZATION.

  CONCATENATE ARCHIVO 'BSANT' '_' SY-DATUM '_' SY-UZEIT '.txt' INTO
  ARCHIVO.
  CONDENSE ARCHIVO NO-GAPS.


START-OF-SELECTION.

  PERFORM BANCOS.
  SORT T_BANCOS BY COD_AC.

* Rescatamos Datos.
  SELECT *  FROM  REGUH      CLIENT SPECIFIED
           WHERE  MANDT       = SY-MANDT
             AND  LAUFD       = V_FECHA
             AND  LAUFI       = V_NOMINA
             AND  XVORL       = ' '     .

    IF ( REGUH-STCD1 IS INITIAL ) OR ( REGUH-ZSTC1 IS INITIAL ).
      SELECT SINGLE STCD1 INTO REGUH-STCD1
        FROM LFA1 WHERE LIFNR = REGUH-LIFNR.
    ENDIF.

*    IF NOT ( reguh-stcd1 IS INITIAL ).
    IF ( NOT REGUH-STCD1 IS INITIAL ) OR ( NOT REGUH-ZSTC1 IS INITIAL ).
      MOVE-CORRESPONDING REGUH TO TABLA_00.

* Si es vale vista, el banco será el pagador
      IF TABLA_00-RZAWE = 'V' OR
         TABLA_00-RZAWE = 'X' OR
         TABLA_00-RZAWE = 'Y'.
        TABLA_00-ZBNKL = TABLA_00-HBKID.
      ENDIF.

* revisamos si paga a un beneficiario alternativo
      IF TABLA_00-STCD1 <> TABLA_00-ZSTC1.
        TABLA_00-STCD1 = TABLA_00-ZSTC1.
        TABLA_00-NAME1 = TABLA_00-ZNME1.
        TABLA_00-ORT01 = TABLA_00-ZORT1.
        TABLA_00-STRAS = TABLA_00-ZSTRA.
      ENDIF.

      APPEND TABLA_00.
    ENDIF.
  ENDSELECT.

*Procesamos Datos
  SORT TABLA_00 BY RZAWE LIFNR EMPFG.   " via.pago/prov/recep.pago

  LOOP AT TABLA_00.
    PERFORM ARMA_REGISTRO.
  ENDLOOP.

  DESCRIBE TABLE TABLA_00 LINES LINS.

  IF LINS <> 0.
    PERFORM LISTADO.  "informe.
    CHECK PAR_DI EQ 'X'.
    PERFORM BAJAR_ARCHIVO.
  ELSE.
    WRITE : /,/, 'No se genero archivo....!!!!!!!!'.

  ENDIF.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  arma_registro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ARMA_REGISTRO.
*--------------------*
  CLEAR   : REG_STDER, T_ITEMS.
  REFRESH : T_DOCTOS, T_DOCTOS[], T_ITEMS[].


  TRANSLATE TABLA_00-STCD1 USING '- ' .
  CONDENSE  TABLA_00-STCD1 NO-GAPS    .

*ARVM 09062009:  Se ajusta Rut a la Izquierda.
  WRITE TABLA_00-STCD1 TO REG_STDER-RUT_PROV RIGHT-JUSTIFIED.

  REG_STDER-NOMBRE           = TABLA_00-ZNME1 .
*reg_stder-direccion        = tabla_00-stras .

  TRANSLATE  TABLA_00-ZBNKN USING '- '.
  CONDENSE TABLA_00-ZBNKN NO-GAPS.
  CONDENSE TABLA_00-ZBNKL NO-GAPS.

  REG_STDER-CODIGO_BANCO     =  TABLA_00-ZBNKL.
  REG_STDER-CUENTA_ABONO     =  TABLA_00-ZBNKN.

  IF TABLA_00-RZAWE = 'V'.
    CLEAR REG_STDER-CUENTA_ABONO.
    REG_STDER-MOD_PAGO = '01'.
    REG_STDER-SUC_RETIRO = '999'.
    REG_STDER-CODIGO_BANCO = '000'.
  ELSE.
    DATA: P_CLAVE(40) TYPE C.

    SELECT SINGLE    CLAVE INTO P_CLAVE
       FROM ZFITR001
      WHERE
       BANKL = '037'
     AND BKONT = TABLA_00-ZBKON.
    IF SY-SUBRC EQ 0.
      CONDENSE P_CLAVE NO-GAPS.
      REG_STDER-MOD_PAGO = P_CLAVE+0(2).
    ENDIF.
*         reg_stder-mod_pago = tabla_00-zbkon.
  ENDIF.

  ACREEDOR = TABLA_00-LIFNR.

****Es multisociedad ???

  IF TABLA_00-ZBUKR <> TABLA_00-ABSBU.  " Soc_pagadora y Soc.emisora

*****
*** ff 02.03.06
*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
    SELECT SINGLE * FROM  BSEG
      CLIENT SPECIFIED
              WHERE  MANDT       = SY-MANDT
                     AND BUKRS   = TABLA_00-ZBUKR
                     AND BELNR   = TABLA_00-VBLNR
*agregamos la fecha (ff 01.03.06)
*                   AND AUGDT   = TABLA_00-ZALDT
                     AND ZFBDT   = TABLA_00-ZALDT           " ff 150306
                     AND KOART   = 'K'.

    IF SY-SUBRC = 0.
      EJE_PAGO = BSEG-GJAHR.
    ENDIF.


*****
    SELECT SINGLE * FROM  BKPF CLIENT SPECIFIED
           WHERE  MANDT  = SY-MANDT
           AND    BUKRS  = TABLA_00-ZBUKR
           AND    BELNR  = TABLA_00-VBLNR
           AND    GJAHR  = EJE_PAGO.          " (ff 01.03.06)

    CALL FUNCTION 'GET_CLEARED_ITEMS'
      EXPORTING
        I_BELNR                = TABLA_00-VBLNR  " doc depago
        I_BUKRS                = TABLA_00-ZBUKR  " soc pagadora
        I_GJAHR                = BKPF-GJAHR
        I_BVORG                = BKPF-BVORG
      TABLES
        T_ITEMS                = T_ITEMS
      EXCEPTIONS
        NOT_FOUND              = 1
        ERROR_CLEARED_ACCOUNTS = 2
        OTHERS                 = 3.

    IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT T_ITEMS.
      IF T_ITEMS-AUGBL = T_ITEMS-BELNR.
        DELETE  T_ITEMS INDEX SY-TABIX.
      ELSE.
        SOC_PAGO = T_ITEMS-BUKRS.
        DOC_PAGO = T_ITEMS-AUGBL.
        PERFORM PAGA_SOCIEDAD.
      ENDIF.
    ENDLOOP.

  ELSE..

*** ff 02.03.06
*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
    SELECT SINGLE * FROM  BSEG   CLIENT SPECIFIED
              WHERE  MANDT       = SY-MANDT
                     AND BUKRS   = TABLA_00-ZBUKR
                     AND BELNR   = TABLA_00-VBLNR
*agregamos la fecha (ff 01.03.06)
*                   AND AUGDT   = TABLA_00-ZALDT
                     AND ZFBDT   = TABLA_00-ZALDT           " ff 150306
                     AND KOART   = 'K'.

    IF SY-SUBRC = 0.
      EJE_PAGO = BSEG-GJAHR.
    ENDIF.

***
    SOC_PAGO = TABLA_00-ZBUKR.
    DOC_PAGO = TABLA_00-VBLNR.
*    acreedor = tabla_00-lifnr.
    PERFORM PAGA_SOCIEDAD.
  ENDIF.
****

ENDFORM.                    "arma_registro


*&---------------------------------------------------------------------*
*&      Form  paga_sociedad
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PAGA_SOCIEDAD.
*-----------------*

  SELECT * FROM BSAK CLIENT SPECIFIED
          WHERE MANDT   = SY-MANDT
            AND  BUKRS  = SOC_PAGO    " soc.pagadora
            AND  AUGBL  = DOC_PAGO    " Núm. doc.
            AND  LIFNR  = ACREEDOR
            AND  AUGGJ  = EJE_PAGO.   " ff 02.03.06

    CHECK BSAK-AUGBL <>  BSAK-BELNR.
    MOVE-CORRESPONDING BSAK TO T_DOCTOS.
**      el valor sera el total menos retencion
*        t_doctos-wrbtr = t_doctos-wrbtr - t_doctos-qbshb.
    APPEND T_DOCTOS.
  ENDSELECT.

  IF SY-SUBRC = 0.
    PERFORM DISTRIBUCION.
  ENDIF.

ENDFORM.                    "paga_sociedad

*&---------------------------------------------------------------------*
*&      Form  distribucion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISTRIBUCION.
*----------------*
  N_MONTO = 0.
  POS__   = 0.


* Ordenamos solo por monto ( sin signo )
* para que queden los reversos juntos.-
*sort t_doctos by wrbtr.
  SORT T_DOCTOS BY DMBTR.


  LOOP AT T_DOCTOS.
    ADD 1 TO POS__.

*Grabamos primeras 11 posiciones
    IF POS__ > 11.
      REG_STDER-TOTAL_A_PAGAR = N_MONTO.
      APPEND REG_STDER.
*    Limpiamos
      CLEAR : REG_STDER-NUM_DOCTO01, REG_STDER-SIGNO_DOCTO01,
              REG_STDER-MONTO_DOCTO01,
              REG_STDER-NUM_DOCTO02, REG_STDER-SIGNO_DOCTO02,
              REG_STDER-MONTO_DOCTO02,
              REG_STDER-NUM_DOCTO03, REG_STDER-SIGNO_DOCTO03,
              REG_STDER-MONTO_DOCTO03,
              REG_STDER-NUM_DOCTO04, REG_STDER-SIGNO_DOCTO04,
              REG_STDER-MONTO_DOCTO04,
              REG_STDER-NUM_DOCTO05, REG_STDER-SIGNO_DOCTO05,
              REG_STDER-MONTO_DOCTO05,
              REG_STDER-NUM_DOCTO06, REG_STDER-SIGNO_DOCTO06,
              REG_STDER-MONTO_DOCTO06,
              REG_STDER-NUM_DOCTO07, REG_STDER-SIGNO_DOCTO07,
              REG_STDER-MONTO_DOCTO07,
              REG_STDER-NUM_DOCTO08, REG_STDER-SIGNO_DOCTO08,
              REG_STDER-MONTO_DOCTO08,
              REG_STDER-NUM_DOCTO09, REG_STDER-SIGNO_DOCTO09,
              REG_STDER-MONTO_DOCTO09,
              REG_STDER-NUM_DOCTO10, REG_STDER-SIGNO_DOCTO10,
              REG_STDER-MONTO_DOCTO10,
              REG_STDER-NUM_DOCTO11, REG_STDER-SIGNO_DOCTO11,
              REG_STDER-MONTO_DOCTO11,
              REG_STDER-TOTAL_A_PAGAR.
      POS__ = 1.
      N_MONTO = 0.
    ENDIF.

*invertimos los signos para que el giro quede positivo !!!!!

    IF T_DOCTOS-SHKZG = 'S'.    "Invertimos los signos.....
      T_DOCTOS-DMBTR = T_DOCTOS-DMBTR * -1.
    ENDIF.

    T_DOCTOS-DMBTR = T_DOCTOS-DMBTR * 100.

    N_MONTO        = N_MONTO + T_DOCTOS-DMBTR.

    T_DOCTOS-DMBTR = ABS( T_DOCTOS-DMBTR ).


    SELECT SINGLE * FROM  BKPF CLIENT SPECIFIED
           WHERE  MANDT  = SY-MANDT
           AND    BUKRS  = T_DOCTOS-BUKRS
           AND    BELNR  = T_DOCTOS-BELNR
           AND    GJAHR  = T_DOCTOS-GJAHR.

    IF SY-SUBRC = 0 AND BKPF-XBLNR IS NOT INITIAL.
      CONDENSE BKPF-XBLNR NO-GAPS.
      NUM_DOC = BKPF-XBLNR.
    ENDIF.

******
    CASE POS__ .

      WHEN 1.
        REG_STDER-NUM_DOCTO01    = NUM_DOC.
        IF T_DOCTOS-SHKZG = 'S'.
          REG_STDER-SIGNO_DOCTO01 = '-'.
        ELSE.
          REG_STDER-SIGNO_DOCTO01 = '+'.
        ENDIF.
        REG_STDER-MONTO_DOCTO01  = T_DOCTOS-DMBTR.
      WHEN 2.
        REG_STDER-NUM_DOCTO02    = NUM_DOC.
        IF T_DOCTOS-SHKZG = 'S'.
          REG_STDER-SIGNO_DOCTO02 = '-'.
        ELSE.
          REG_STDER-SIGNO_DOCTO02 = '+'.
        ENDIF.
        REG_STDER-MONTO_DOCTO02  = T_DOCTOS-DMBTR.
      WHEN 3.
        REG_STDER-NUM_DOCTO03    = NUM_DOC.
        IF T_DOCTOS-SHKZG = 'S'.
          REG_STDER-SIGNO_DOCTO03 = '-'.
        ELSE.
          REG_STDER-SIGNO_DOCTO03 = '+'.
        ENDIF.
        REG_STDER-MONTO_DOCTO03  = T_DOCTOS-DMBTR.
      WHEN 4.
        REG_STDER-NUM_DOCTO04    = NUM_DOC.
        IF T_DOCTOS-SHKZG = 'S'.
          REG_STDER-SIGNO_DOCTO04 = '-'.
        ELSE.
          REG_STDER-SIGNO_DOCTO04 = '+'.
        ENDIF.
        REG_STDER-MONTO_DOCTO04  = T_DOCTOS-DMBTR.
      WHEN 5.
        REG_STDER-NUM_DOCTO05    = NUM_DOC.
        IF T_DOCTOS-SHKZG = 'S'.
          REG_STDER-SIGNO_DOCTO05 = '-'.
        ELSE.
          REG_STDER-SIGNO_DOCTO05 = '+'.
        ENDIF.
        REG_STDER-MONTO_DOCTO05  = T_DOCTOS-DMBTR.
      WHEN 6.
        REG_STDER-NUM_DOCTO06    = NUM_DOC.
        IF T_DOCTOS-SHKZG = 'S'.
          REG_STDER-SIGNO_DOCTO06 = '-'.
        ELSE.
          REG_STDER-SIGNO_DOCTO06 = '+'.
        ENDIF.
        REG_STDER-MONTO_DOCTO06  = T_DOCTOS-DMBTR.
      WHEN 7.
        REG_STDER-NUM_DOCTO07    = NUM_DOC.
        IF T_DOCTOS-SHKZG = 'S'.
          REG_STDER-SIGNO_DOCTO07 = '-'.
        ELSE.
          REG_STDER-SIGNO_DOCTO07 = '+'.
        ENDIF.
        REG_STDER-MONTO_DOCTO07  = T_DOCTOS-DMBTR.
      WHEN 8.
        REG_STDER-NUM_DOCTO08    = NUM_DOC.
        IF T_DOCTOS-SHKZG = 'S'.
          REG_STDER-SIGNO_DOCTO08 = '-'.
        ELSE.
          REG_STDER-SIGNO_DOCTO08 = '+'.
        ENDIF.
        REG_STDER-MONTO_DOCTO08  = T_DOCTOS-DMBTR.
      WHEN 9.
        REG_STDER-NUM_DOCTO09    = NUM_DOC.
        IF T_DOCTOS-SHKZG = 'S'.
          REG_STDER-SIGNO_DOCTO09 = '-'.
        ELSE.
          REG_STDER-SIGNO_DOCTO09 = '+'.
        ENDIF.
        REG_STDER-MONTO_DOCTO09  = T_DOCTOS-DMBTR.
      WHEN 10.
        REG_STDER-NUM_DOCTO10    = NUM_DOC.
        IF T_DOCTOS-SHKZG = 'S'.
          REG_STDER-SIGNO_DOCTO10 = '-'.
        ELSE.
          REG_STDER-SIGNO_DOCTO10 = '+'.
        ENDIF.
        REG_STDER-MONTO_DOCTO10  = T_DOCTOS-DMBTR.
      WHEN 11.
        REG_STDER-NUM_DOCTO11    = NUM_DOC.
        IF T_DOCTOS-SHKZG = 'S'.
          REG_STDER-SIGNO_DOCTO11 = '-'.
        ELSE.
          REG_STDER-SIGNO_DOCTO11 = '+'.
        ENDIF.
        REG_STDER-MONTO_DOCTO11  = T_DOCTOS-DMBTR.

    ENDCASE.

  ENDLOOP.

  REG_STDER-TOTAL_A_PAGAR = N_MONTO.

  APPEND REG_STDER.

ENDFORM.                               " LLENA_ESTRUCTURA


*&---------------------------------------------------------------------*
*&      Form  bajar_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BAJAR_ARCHIVO.
*-----------------*

  DATA: BEGIN OF TI_ARCHIVO OCCURS 0,
          LINEA(500),
        END OF TI_ARCHIVO.

  DATA: V_ENCABEZADO LIKE LINE OF OUT_REG_STDER.

  DATA: MONTO1(16), MONTO2(16), MONTO3(16), MONTO4(16), MONTO5(16), MONTO6(16), MONTO7(16), MONTO8(16), MONTO9(16), MONTO10(16),
        MONTO11(16).

  DATA : NOMBRE_A  TYPE STRING.
  NOMBRE_A = ARCHIVO.
  IF NOT REG_STDER[] IS INITIAL.
    APPEND TI_ARCHIVO.
  ENDIF.


  LOOP AT REG_STDER.
    CLEAR TI_ARCHIVO.

    CONCATENATE REG_STDER-SIGNO_DOCTO01
                REG_STDER-MONTO_DOCTO01 INTO MONTO1.
    CONCATENATE REG_STDER-SIGNO_DOCTO02
                REG_STDER-MONTO_DOCTO02 INTO MONTO2.
    CONCATENATE REG_STDER-SIGNO_DOCTO03
                REG_STDER-MONTO_DOCTO03 INTO MONTO3.
    CONCATENATE REG_STDER-SIGNO_DOCTO04
                REG_STDER-MONTO_DOCTO04 INTO MONTO4.
    CONCATENATE REG_STDER-SIGNO_DOCTO05
                REG_STDER-MONTO_DOCTO05 INTO MONTO5.
    CONCATENATE REG_STDER-SIGNO_DOCTO06
                REG_STDER-MONTO_DOCTO06 INTO MONTO6.
    CONCATENATE REG_STDER-SIGNO_DOCTO07
                REG_STDER-MONTO_DOCTO07 INTO MONTO7.
    CONCATENATE REG_STDER-SIGNO_DOCTO08
                REG_STDER-MONTO_DOCTO08 INTO MONTO8.
    CONCATENATE REG_STDER-SIGNO_DOCTO09
                REG_STDER-MONTO_DOCTO09 INTO MONTO9.
    CONCATENATE REG_STDER-SIGNO_DOCTO10
                REG_STDER-MONTO_DOCTO10 INTO MONTO10.
    CONCATENATE REG_STDER-SIGNO_DOCTO11
                REG_STDER-MONTO_DOCTO11 INTO MONTO11.

    CONCATENATE REG_STDER-RUT_PROV
                REG_STDER-NOMBRE
                REG_STDER-MOD_PAGO
                REG_STDER-CODIGO_BANCO
                REG_STDER-CUENTA_ABONO
*                reg_stder-suc_retiro
                REG_STDER-NUM_DOCTO01
                MONTO1
                REG_STDER-NUM_DOCTO02
                MONTO2
                REG_STDER-NUM_DOCTO03
                MONTO3
                REG_STDER-NUM_DOCTO04
                MONTO4
                REG_STDER-NUM_DOCTO05
                MONTO5
                REG_STDER-NUM_DOCTO06
                MONTO6
                REG_STDER-NUM_DOCTO07
                MONTO7
                REG_STDER-NUM_DOCTO08
                MONTO8
                REG_STDER-NUM_DOCTO09
                MONTO9
                REG_STDER-NUM_DOCTO10
                MONTO10
                REG_STDER-NUM_DOCTO11
                MONTO11
                REG_STDER-TOTAL_A_PAGAR
                INTO TI_ARCHIVO-LINEA.
    APPEND TI_ARCHIVO.
  ENDLOOP.



*----------------------------------------------
*ARVM Se agrega Signo para montos positivos
*Se cambia archivo de salida, para que quede con anchos fijos.

  LOOP AT REG_STDER.
    MOVE-CORRESPONDING REG_STDER TO OUT_REG_STDER.
    APPEND OUT_REG_STDER.
    CLEAR  OUT_REG_STDER.
  ENDLOOP.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME                = NOMBRE_A
      FILETYPE                = 'ASC'
      CONFIRM_OVERWRITE       = 'X'
    TABLES
*      data_tab                = reg_stder
      DATA_TAB                = OUT_REG_STDER
    EXCEPTIONS
      FILE_WRITE_ERROR        = 1
      NO_BATCH                = 2
      GUI_REFUSE_FILETRANSFER = 3
      INVALID_TYPE            = 4
      NO_AUTHORITY            = 5
      UNKNOWN_ERROR           = 6
      HEADER_NOT_ALLOWED      = 7
      SEPARATOR_NOT_ALLOWED   = 8
      FILESIZE_NOT_ALLOWED    = 9
      HEADER_TOO_LONG         = 10
      DP_ERROR_CREATE         = 11
      DP_ERROR_SEND           = 12
      DP_ERROR_WRITE          = 13
      UNKNOWN_DP_ERROR        = 14
      ACCESS_DENIED           = 15
      DP_OUT_OF_MEMORY        = 16
      DISK_FULL               = 17
      DP_TIMEOUT              = 18
      FILE_NOT_FOUND          = 19
      DATAPROVIDER_EXCEPTION  = 20
      CONTROL_FLUSH_ERROR     = 21
      OTHERS                  = 22.

  DATA ZZZ LIKE RLGRAP-FILENAME.
  WRITE NOMBRE_A TO ZZZ.

*CALL METHOD CL_GUI_FRONTEND_SERVICES=>


  IF SY-SUBRC <> 0.
    WRITE :/ 'error!!!!'  ,
           /  SY-MSGV1 ,
           /  SY-MSGV2 ,
           /  SY-MSGV3 ,
           /  SY-MSGV4 .

  ELSE.
    SKIP 2 .
    FORMAT COLOR 3 ON.
    WRITE : / 'Se genero archivo :', NOMBRE_A.
    FORMAT COLOR 3 OFF.
  ENDIF.
*----------------------------------------------
ENDFORM.                    "bajar_archivo

*&--------------------------------------------------------------------*
*&      Form  bancos
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM BANCOS.
*----------*
  CLEAR T_BANCOS[].

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
  T_BANCOS-COD_AC = 'BSANT'.T_BANCOS-COD_NW = '037'. " Santander chile
  APPEND T_BANCOS.
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
FORM LISTADO.
*-----------*
*check 1 = 2.

  WRITE : /43   'NOMINA DE PAGO PROVEEDORES CUENTA BANCO SANTANDER' ,
          /,/53 'FECHA DEL INFORME ' , V_FECHA                  ,
          /,/47 'Identificación De Propuesta de Pago', V_NOMINA .

  SKIP 1.

  WRITE SY-ULINE(125).

  WRITE : /01  'Mp'               ,   " 01   " mdiopago
           04  'Doc.Egreso'       ,   " 10
           15  'Soc'              ,   " 04
           22  'Referencia'       ,   " 25   " bkpf-xblnr 16
           41  'Proveedor'        ,   " 16
           60  'Nombre Proveedor' ,   " 35
           095 'Monto'            ,   " 15
           113 'Total'            .

  WRITE : / SY-ULINE(125).

  MONTO_P = 0.
  LOOP AT TABLA_00.

    IF AUX_PROV <> TABLA_00-STCD1.
      AUX_PROV = TABLA_00-STCD1.
      IF MONTO_P <> 0.
        WRITE 107 MONTO_P CURRENCY 'CLP'.
      ENDIF.
      MONTO_P = 0.
    ENDIF.

    T_MONTO = 0.
    CLEAR T_ITEMS[].

    IF TABLA_00-ZBUKR <> TABLA_00-ABSBU.  " Soc_pagadora y Soc.emisora

      SELECT SINGLE * FROM  BKPF CLIENT SPECIFIED
            WHERE  MANDT  = SY-MANDT
            AND    BUKRS  = TABLA_00-ZBUKR  " Soc. Paga
            AND    BELNR  = TABLA_00-VBLNR.  " Doc. pago
*          AND    gjahr  = '2004'.

      CALL FUNCTION 'GET_CLEARED_ITEMS'
        EXPORTING
          I_BELNR                = TABLA_00-VBLNR  " doc depago
          I_BUKRS                = TABLA_00-ZBUKR  " soc pagadora
          I_GJAHR                = BKPF-GJAHR
          I_BVORG                = BKPF-BVORG
        TABLES
          T_ITEMS                = T_ITEMS
        EXCEPTIONS
          NOT_FOUND              = 1
          ERROR_CLEARED_ACCOUNTS = 2
          OTHERS                 = 3.

      IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

*Buscamos los documentos
      LOOP AT T_ITEMS.
        IF T_ITEMS-AUGBL = T_ITEMS-BELNR.
          DELETE  T_ITEMS INDEX SY-TABIX.
        ELSE.
          SOC_PAGO = T_ITEMS-BUKRS.
          DOC_PAGO = T_ITEMS-AUGBL.
          PERFORM DOCTOS__.
        ENDIF.
      ENDLOOP.

    ELSE.
      SOC_PAGO = TABLA_00-ZBUKR.
      DOC_PAGO = TABLA_00-VBLNR.
      PERFORM DOCTOS__.
    ENDIF.

  ENDLOOP.

* Imprimimos total Parcial
  WRITE 107 MONTO_P CURRENCY 'CLP'.

* Imprimimos total Final
  WRITE : /,/100 'Total' ,
             107  MONTO_Z CURRENCY 'CLP'.

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
FORM DOCTOS__.
*------------*
  ACREEDOR = TABLA_00-LIFNR.
  CLEAR T_DOCTOS[].


*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
  SELECT SINGLE * FROM  BSEG   CLIENT SPECIFIED
            WHERE  MANDT       = SY-MANDT
                   AND BUKRS   = TABLA_00-ZBUKR
                   AND BELNR   = TABLA_00-VBLNR
*agregamos la fecha
*                   AND AUGDT   = TABLA_00-ZALDT
                   AND ZFBDT   = TABLA_00-ZALDT             " ff 150306
                   AND KOART   = 'K'.

  IF SY-SUBRC = 0.
    EJE_PAGO = BSEG-GJAHR.
  ENDIF.


*****

  SELECT * FROM BSAK CLIENT SPECIFIED
          WHERE MANDT   = SY-MANDT
            AND  BUKRS  = SOC_PAGO    " soc.pagadora
            AND  AUGBL  = DOC_PAGO    " Núm. doc.
            AND  LIFNR  = ACREEDOR
            AND  AUGGJ  = EJE_PAGO.

    CHECK BSAK-AUGBL <>  BSAK-BELNR.

    MOVE-CORRESPONDING BSAK TO T_DOCTOS.
**      el valor sera el total menos retencion
*        t_doctos-dmbtr = t_doctos-dmbtr - t_doctos-qbshb.

    APPEND T_DOCTOS.
  ENDSELECT.

  LOOP AT T_DOCTOS.

* Buscamos textos
    SELECT SINGLE * FROM  BKPF CLIENT SPECIFIED
            WHERE  MANDT  = SY-MANDT
            AND    BUKRS  = SOC_PAGO          " Soc. Paga
            AND    GJAHR  = T_DOCTOS-GJAHR
            AND    BELNR  =  T_DOCTOS-BELNR.   " Doc. pago

*Invertimos signo para el listado

    IF T_DOCTOS-SHKZG = 'S'.
      T_DOCTOS-DMBTR = T_DOCTOS-DMBTR * -1.
    ENDIF.

    T_DOCTOS-DMBTR = T_DOCTOS-DMBTR .

    WRITE : /001 TABLA_00-RZAWE ,
             003 TABLA_00-VBLNR  ,  " t_doctos-belnr ,
             014 SOC_PAGO       ,
            019 BKPF-XBLNR     ,  " bkpf-bktxt
*             019 t_doctos-zuonr     ,  " referencia factura
             037 TABLA_00-STCD1 ,
             054 TABLA_00-ZNME1 ,
             090 T_DOCTOS-DMBTR CURRENCY 'CLP'.
    T_MONTO = T_MONTO  + T_DOCTOS-DMBTR.
    MONTO_P  = MONTO_P + T_DOCTOS-DMBTR.

  ENDLOOP.



  MONTO_Y = T_MONTO .

  MONTO_Z = MONTO_Z + MONTO_Y.
ENDFORM.                    "doctos__
