*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_TOP
*&---------------------------------------------------------------------*


TABLES: zfipg002_cab,
        zfipg002_det,
        zfipg003,
        zfipg003_est,
        zfipg003_a_est,
        t001,
        reguh ,
        reguv,
        zfirmadigital,
        t042z.

DATA: resp(01),
      band TYPE c.

DATA : BEGIN OF int_tabla  OCCURS 1.
        INCLUDE STRUCTURE zfipg003_est.
DATA  END OF int_tabla.


DATA : BEGIN OF texcel  OCCURS 1,
       descr(50),
       estado(10),
       listopara(50),
       laufi(50),
       laufd(50),
       hbkid(50),
       zfbdt(50),
       xzzmot_emis(50),
       monto(50),
       nchequ(50),
       ult_remesa(50),
       tot_remesa(50),
       nchequ_s(50),
       nhojas(50),
       msg(50),
END OF  texcel.

DATA : BEGIN OF int_tabla1  OCCURS 1.
        INCLUDE STRUCTURE zfipg003_a_est.
DATA   END OF int_tabla1.



DATA: fill(4)       TYPE n,
      swerror(01)   TYPE n,
      swprimera(01) TYPE n,
      sw_ok(01),
      accion(01),
      titulo(40),
      ws_land   TYPE land1,
      resto(3) TYPE n.

DATA ti_pcec LIKE STANDARD TABLE OF pcec WITH HEADER LINE.
DATA ln_pcec TYPE i.

* Tablas Dynpro
CONTROLS: tabla  TYPE TABLEVIEW USING SCREEN 100.

CONTROLS: tabla1 TYPE TABLEVIEW USING SCREEN 200.

DATA cols  LIKE LINE OF tabla-cols.



DATA : BEGIN OF tab OCCURS 0,
         fcode LIKE rsmpe-func,
       END OF tab.

INCLUDE zbatchinput.


DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.


DATA:       nfirma1(70) TYPE c,
            dir_org1 TYPE rlgrap-filename,
            dir_des1 TYPE rlgrap-filename,
            pass1(25)  TYPE c.
DATA:       nfirma2(70) TYPE c,
            dir_org2 TYPE rlgrap-filename,
            dir_des2 TYPE rlgrap-filename,
            pass2(25)  TYPE c.



DATA: ti_firma TYPE STANDARD TABLE OF zfirmadigital WITH HEADER LINE,
      firma1 TYPE zfirmadigital,
      firma2 TYPE zfirmadigital,
      okcode TYPE sy-ucomm,
      pasword1 TYPE char50,
      pasword2 TYPE char50,
      estado1(10) TYPE c,
      estado2(10) TYPE c,
      source TYPE char50,
      destination TYPE char50,
      pwd TYPE char50,
      tdname_001 TYPE bdcdata-fval,
      filename_004 TYPE bdcdata-fval,
      tdname_005 TYPE bdcdata-fval,
      tdname_008 TYPE bdcdata-fval,
      messtab TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE,
      rfcdest TYPE rfcdes-rfcdest,
      v_fecha      LIKE reguh-laufd,
      v_nomina     LIKE f110v-laufi,
      v_fecpag     LIKE reguh-laufd,
      v_resfon     TYPE zresfon,
      v_numche(10) TYPE n,
      v_archivo    LIKE rlgrap-filename,
      archivo      LIKE rlgrap-filename,
      par_tes      TYPE c ,
      v_bankl      LIKE t012-bankl.




*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN: COMMENT 1(20) text0.

SELECTION-SCREEN POSITION 33.

PARAMETER : bukrs    LIKE bkpf-bukrs     VALUE CHECK  OBLIGATORY .



SELECTION-SCREEN: COMMENT 45(40) text1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN: COMMENT 1(20) text2.

SELECTION-SCREEN POSITION 33.

PARAMETER : zlsch    LIKE  bsik-zlsch  OBLIGATORY .



SELECTION-SCREEN: COMMENT 45(40) text3.
SELECTION-SCREEN END OF LINE.



SELECTION-SCREEN END OF BLOCK marco1 .

*---------------------------------------------------------------------------------

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



AT SELECTION-SCREEN ON zlsch.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t042z WHERE land1 = 'CL'
*                             AND   zlsch = zlsch.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t042z WHERE land1 = 'CL'
                             AND   zlsch = zlsch ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0 OR ( zlsch <> 'C' AND zlsch <> 'T' AND zlsch <> 'V' ).
    MESSAGE e004(zfi) WITH 'Via de Pago no Valida'.

  ENDIF.

  text3 = t042z-text1.

AT SELECTION-SCREEN OUTPUT.

  text1 = t001-butxt.
  text3 = t042z-text1.

INITIALIZATION.

  text0 = 'Sociedad'.
  text2 = 'Via de Pago'.
