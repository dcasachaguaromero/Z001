*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_TOP
*&---------------------------------------------------------------------*


TABLES: zfipg001,
        zfipg200_cab,
        zfipg200_det,
        zfipg200_det_2,
        zfipg200_est,
        zfipg200_a_est,
        zfipg200_b_est,
        zfipg201,
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
      rese(1),

      wrbtr_tot      LIKE bsik-wrbtr,
      wrbtr_tot1(18),
      Npagos_tot(08)  type n.

DATA : BEGIN OF int_tabla  OCCURS 1.
         INCLUDE STRUCTURE zfipg200_est.
       DATA   END OF int_tabla.

DATA : BEGIN OF int_tabla2  OCCURS 1.
         INCLUDE STRUCTURE zfipg200_a_est.
       DATA   END OF int_tabla2.

DATA : BEGIN OF int_tabla3  OCCURS 1.
         INCLUDE STRUCTURE zfipg200_b_est.
       DATA   END OF int_tabla3.


DATA : BEGIN OF int_motban  OCCURS 1,
         zzmot_emis LIKE zfipg201-zzmot_emis,
         bancop     LIKE zfipg201-bancop,
         rmaxp      LIKE zfipg201-rmaxp,
         rmaxb      LIKE zfipg201-rmaxb.
DATA   END OF int_motban.


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
         zfbdt       LIKE bsik-zfbdt,
         zzmot_emis  LIKE bsik-zzmot_emis,
         hbkid       LIKE bsik-hbkid,
         zlsch       LIKE bsik-zlsch,
         lifnr       LIKE bsik-lifnr,
         docto(5)    TYPE p  DECIMALS 0,
         wrbtr       LIKE bsik-wrbtr,
         docto_r(5)  TYPE p  DECIMALS 0,
         wrbtr_r     LIKE bsik-wrbtr,
         docto_na(5) TYPE p  DECIMALS 0,
         wrbtr_na    LIKE bsik-wrbtr,
         zuonr       LIKE bsik-zuonr,

         belnr       LIKE bsik-belnr,
         gjahr       LIKE bsik-gjahr,
         buzei       LIKE bsik-buzei,
         msg(50),
         blart       LIKE bsik-blart,
         shkzg       LIKE bsik-shkzg,
         zz_agencia  LIKE bsik-zz_agencia,
         waers       LIKE bsik-waers,
       END OF  tpago.

DATA : BEGIN OF tprop1  OCCURS 1,
         zfbdt        LIKE bsik-zfbdt,
         hbkid        LIKE bsik-hbkid,
         zlsch        LIKE bsik-zlsch,
         zzmot_emis   LIKE bsik-zzmot_emis,
         lifnr_dde    LIKE bsik-lifnr,
         lifnr_hta    LIKE bsik-lifnr,
         docto(5)     TYPE p  DECIMALS 0,
         docto_ban(5) TYPE p  DECIMALS 0,
         zz_agencia   LIKE bsik-zz_agencia,
         wrbtr        LIKE bsik-wrbtr,
       END OF tprop1.

DATA : BEGIN OF tprop2  OCCURS 1,
         laufd        LIKE zfipg200_det-laufd,
         laufi        LIKE zfipg200_det-laufi,
         zfbdt        LIKE bsik-zfbdt,
         xzzmot_emis  LIKE zfipg200_det-xzzmot_emis,
         hbkid        LIKE bsik-hbkid,
         zlsch        LIKE bsik-zlsch,
         lifnr_dde    LIKE bsik-lifnr,
         lifnr_hta    LIKE bsik-lifnr,
         docto(5)     TYPE p  DECIMALS 0,
         docto_ban(5) TYPE p  DECIMALS 0,
         wrbtr        LIKE bsik-wrbtr,
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

DATA: cregpro(06)   TYPE n,
      cregban(06)   TYPE n,
      flag_cc(02)   TYPE n,
      zfbdt_p       LIKE bsik-zfbdt,
      zzmot_emis_p  LIKE bsik-zzmot_emis,
      hbkid_p       LIKE bsik-hbkid,
      zlsch_p       LIKE bsik-zlsch,
      lifnr_p       LIKE bsik-lifnr,
      lifnr_p_dde   LIKE bsik-lifnr,
      docto_p       LIKE zfipg200_est-docto,
      wrbtr_p       LIKE zfipg200_est-monto,
      docto_r_p     LIKE zfipg200_est-docto_r,
      wrbtr_r_p     LIKE zfipg200_est-monto_r,
      docto_na_p    LIKE zfipg200_est-docto_na,
      wrbtr_na_p    LIKE zfipg200_est-monto_na,
      cdocscltes(6) TYPE n,
      reg_proc(6)   TYPE n,
      sw_p(01)      TYPE c.

DATA : BEGIN OF docs_cltes  OCCURS 1,
         zfbdt_dscs      LIKE bsik-zfbdt,
         zzmot_emis_dscs LIKE bsik-zzmot_emis,
         hbkid_dscs      LIKE bsik-hbkid,
         zlsch_dscs      LIKE bsik-zlsch,
         lifnr_dscs      LIKE bsik-lifnr,
         cantdocs(5)     TYPE n,
       END OF docs_cltes.

* Tablas Dynpro
CONTROLS: tabla  TYPE TABLEVIEW USING SCREEN 100.
CONTROLS: tabla2 TYPE TABLEVIEW USING SCREEN 200.
CONTROLS: tabla3 TYPE TABLEVIEW USING SCREEN 300.

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

PARAMETER : p_xzzmot   LIKE  *bseg-zzmot_emis  OBLIGATORY MATCHCODE OBJECT zmot_emis_2.

PARAMETER : p_hbkid    LIKE   bsik-hbkid       OBLIGATORY .

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

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t001 WHERE bukrs = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  SET PARAMETER ID 'BUK' FIELD bukrs.

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
