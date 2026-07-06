*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_TOP
*&---------------------------------------------------------------------*


TABLES: zfipg001,
        zfipg002_cab,
        zfipg002_det,
        zfipg002_est,
        zfipg002_a_est,
        zfipg002_b_est,
        t001,
        bkpf,
        *bseg,
        bsik,
        regus,
        reguv,
        t042z,
        zmot_emis,
        zfolio_soc,
        zfolio_soc01,
        lfa1.  " LF
**

DATA: resp(01),
      bloqueo(01),
      asig(1),
      ref(1),
      rese(1).

DATA : BEGIN OF int_tabla  OCCURS 1.
         INCLUDE STRUCTURE zfipg002_est.
       DATA   END OF int_tabla.

DATA : BEGIN OF int_tabla2  OCCURS 1.
         INCLUDE STRUCTURE zfipg002_a_est.
       DATA   END OF int_tabla2.

DATA : BEGIN OF int_tabla3  OCCURS 1.
         INCLUDE STRUCTURE zfipg002_b_est.
       DATA   END OF int_tabla3.

DATA : BEGIN OF texcel  OCCURS 1,
         zzmot_emis(50),
         blart(50),
         gjahr(50),
         belnr(50),
         buzei(50),
         zfbdt(50),
         hbkid(50),
         zlsch(50),
         wrbtr(50),
         shkzg(50),
         lifnr(50),
         zuonr(50),
         zz_agencia(50),
         msg(50),
       END OF  texcel.

* Inicio Mod. 26.08.2013

TYPES: BEGIN OF reg1,
         codigo_identificacion(15),
         numero_empresa(10)        TYPE c,
         rut_emisor(9),
         cuenta_cargo(10)          TYPE n,
         nombre_beneficiario(50),
         rut_beneficiario(9),
         monto(15)                 TYPE n,
         numero_cheque(9),
         estado_pago(21),
         centro_pago(4)            TYPE n,
         fecha_recepcion(10),
         fecha_estado(10),
         numero_lote(3)            TYPE n,
       END OF reg1.

DATA: cheque(1) TYPE c,
      carta(1)  TYPE c,
      pagar(1)  TYPE c,
      entrar(1) TYPE c,
      monto1    LIKE bsik-wrbtr,
      banco     LIKE bsik-hbkid,
      gv_hktid  TYPE t012k-hktid, " LF
      gv_stcd1  TYPE lfa1-stcd1, " LF
      gv_hkont  TYPE t012k-hkont,
      gv_hkont3 TYPE t012k-hkont.

DATA: banco1(15) TYPE c.
DATA: r1(1) TYPE c,
      r2(2) TYPE c.

DATA: trec TYPE reg1 OCCURS 0 WITH HEADER LINE.
DATA: reg1x TYPE STANDARD TABLE OF reg1.

* Fin Mod. 26.08.2013

DATA : BEGIN OF tpago  OCCURS 1,
         zzmot_emis  LIKE bsik-zzmot_emis,
         waers       TYPE bsik-waers,
         zfbdt       LIKE bsik-zfbdt,
         zlsch       LIKE bsik-zlsch,
         hbkid       LIKE bsik-hbkid,
         docto(5)    TYPE p  DECIMALS 0,
         wrbtr       LIKE bsik-wrbtr,
         docto_r(5)  TYPE p  DECIMALS 0,
         wrbtr_r     LIKE bsik-wrbtr,
         docto_na(5) TYPE p  DECIMALS 0,
         wrbtr_na    LIKE bsik-wrbtr,
         zuonr       LIKE bsik-zuonr,
         lifnr       LIKE bsik-lifnr,
         belnr       LIKE bsik-belnr,
         gjahr       LIKE bsik-gjahr,
         buzei       LIKE bsik-buzei,
         msg(50),
         blart       LIKE bsik-blart,
         shkzg       LIKE bsik-shkzg,
         zz_agencia  LIKE bsik-zz_agencia,
* ini - 04-06-2020 - Waldo Alarcón - Visionone
         bvtyp       TYPE bsik-bvtyp,
* ini - 28-04-2022 - Waldo Alarcón - Visionone
         dmbtr       TYPE bsik-dmbtr,
         dmbtr_r     LIKE bsik-dmbtr,
         dmbtr_na    LIKE bsik-dmbtr,
         monto_ml_tc TYPE dmbtr_x8,
         ukurs       TYPE dec9_2,
       END OF  tpago.

DATA : BEGIN OF tprop1  OCCURS 1,
         zfbdt       LIKE bsik-zfbdt,
         hbkid       LIKE bsik-hbkid,
         zlsch       LIKE bsik-zlsch,
         zzmot_emis  LIKE bsik-zzmot_emis,
         docto(5)    TYPE p  DECIMALS 0,
         zz_agencia  LIKE bsik-zz_agencia,
         wrbtr       LIKE bsik-wrbtr,
* ini - 28-04-2022 - Waldo Alarcón - Visionone
         dmbtr       LIKE bsik-dmbtr,
         monto_ml_tc TYPE dmbtr_x8,
         waers       LIKE bsik-waers,
       END OF tprop1.

DATA : BEGIN OF tprop2  OCCURS 1,
         laufd       LIKE zfipg002_det-laufd,
         laufi       LIKE zfipg002_det-laufi,
         zfbdt       LIKE bsik-zfbdt,
         xzzmot_emis LIKE zfipg002_det-xzzmot_emis,
         hbkid       LIKE bsik-hbkid,
         zlsch       LIKE bsik-zlsch,
         docto(5)    TYPE p  DECIMALS 0,
         wrbtr       LIKE bsik-wrbtr,
* ini - 28-04-2022 - Waldo Alarcón - Visionone
         dmbtr       LIKE bsik-dmbtr,
         monto_ml_tc TYPE dmbtr_x8,
         waers       LIKE bsik-waers,
       END OF tprop2.

DATA: fill(4)         TYPE n,
      swerror(01)     TYPE n,
      swprimera(01)   TYPE n,
      sw_ok(01),
      accion(01),
      titulo(40),
      ws_land         TYPE land1,
      cursorfield(50).

DATA : BEGIN OF t_belnr OCCURS 0,
         belnr TYPE bkpf-belnr,
         stblg TYPE bkpf-stblg,
       END OF t_belnr.

* ini - 04-06-2020 - Waldo Alarcón - Visionone
DATA : gv_mensaje TYPE text100,
       gv_text1   TYPE text65,
       gv_text2   TYPE text65,
       gv_waers   TYPE waers.
* fin - 04-06-2020 - Waldo Alarcón - Visionone

* Tablas Dynpro
CONTROLS: tabla   TYPE TABLEVIEW USING SCREEN 150.
CONTROLS: tabla2  TYPE TABLEVIEW USING SCREEN 250.
CONTROLS: tabla3  TYPE TABLEVIEW USING SCREEN 350.

DATA cols  LIKE LINE OF tabla3-cols.

DATA : BEGIN OF tab OCCURS 0,
         fcode LIKE rsmpe-func,
       END OF tab.

INCLUDE zbatchinput.

DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.

*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE TEXT-001.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN: COMMENT 1(20) text0.

SELECTION-SCREEN POSITION 33.

PARAMETER : bukrs    LIKE bkpf-bukrs    VALUE CHECK OBLIGATORY .

SELECTION-SCREEN: COMMENT 45(40) text1.
SELECTION-SCREEN END OF LINE.

SELECT-OPTIONS : p_zfbdt    FOR  bkpf-budat.

PARAMETER : budat    LIKE  bkpf-budat.


SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN: COMMENT 1(20) text2.

SELECTION-SCREEN POSITION 33.

PARAMETER : zlsch    LIKE  bsik-zlsch.

SELECTION-SCREEN: COMMENT 45(40) text3.

SELECTION-SCREEN END OF LINE.

SELECT-OPTIONS : s_waers  FOR  bsik-waers DEFAULT 'CLP' OBLIGATORY
                                          NO-EXTENSION NO INTERVALS.

PARAMETER : xref1    LIKE  bsik-xref1.

SELECTION-SCREEN END OF BLOCK marco1 .

*---------------------------------------------------------------------------------

AT SELECTION-SCREEN ON xref1.
  IF NOT xref1 IS INITIAL AND  zlsch <> 'T'  AND zlsch <> 'V'.
    MESSAGE e004(zfi) WITH 'Proceso Transfer es Valido solo si Via de Pago es T o V.'.

  ENDIF.

AT SELECTION-SCREEN ON bukrs.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD bukrs.

  IF sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
    MESSAGE e526(icc_tr) WITH bukrs.
  ENDIF.

  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
  gv_waers = t001-waers.

AT SELECTION-SCREEN ON zlsch.

  SELECT SINGLE * FROM t042z WHERE land1 = 'CL'
                             AND   zlsch = zlsch.

  IF sy-subrc <> 0 OR ( zlsch <> 'C' AND zlsch <> 'T'  AND zlsch <> 'V').
    MESSAGE e004(zfi) WITH 'Via de Pago no Valida'.

  ENDIF.

  text3 = t042z-text1.

AT SELECTION-SCREEN OUTPUT.

  text1 = t001-butxt.

  text3 = t042z-text1.

INITIALIZATION.

  text0 = 'Sociedad'.
  text2 = 'Via de Pago'.
