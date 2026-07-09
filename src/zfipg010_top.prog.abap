*&---------------------------------------------------------------------*
*&  Include           ZFIPG010_TOP
*&---------------------------------------------------------------------*

TABLES: bkpf,
        bsik,
        lfa1,
        t001,
        t042z,
        zfipg010_est,
        zfipg010_det_est.

DATA: resp(01).

DATA : BEGIN OF int_tabla  OCCURS 1.
        INCLUDE STRUCTURE zfipg010_est.
DATA   END OF int_tabla.

DATA : BEGIN OF int_tabla1  OCCURS 1.
        INCLUDE STRUCTURE zfipg010_det_est.
DATA   END OF int_tabla1.

DATA : BEGIN OF tpago  OCCURS 1,
       lifnr       LIKE bsik-lifnr,
       zlsch       LIKE bsik-zlsch,
       zfbdt       LIKE bsik-zfbdt,
       blart       LIKE bsik-blart,
       belnr       LIKE bsik-belnr,
       gjahr       LIKE bsik-gjahr,
       hbkid       LIKE bsik-hbkid,
       shkzg       LIKE bsik-shkzg,
       wrbtr       LIKE bsik-wrbtr,
       zuonr       LIKE bsik-zuonr,
       buzei       LIKE bsik-buzei,
       zzmot_emis  LIKE bsik-zzmot_emis,
       zz_agencia  LIKE bsik-zz_agencia,
       sgtxt       LIKE bsik-sgtxt,
       zterm       LIKE bsik-zterm,
END OF  tpago.

* Tablas Dynpro
CONTROLS: tabla  TYPE TABLEVIEW USING SCREEN 100.
CONTROLS: tabla1 TYPE TABLEVIEW USING SCREEN 200.

DATA: fill(4)       TYPE n,
      fill2(4)      TYPE n,
      swerror(01)   TYPE n,
      swprimera(01) TYPE n,
      sw_ok(01),
      accion(01),
      titulo(40),
      ws_land       TYPE land1,
      cursorfield(50),
      zzmot_emis_aux LIKE bsik-zzmot_emis,
      hbkid_aux      LIKE bsik-hbkid,
      zlsch_aux      LIKE bsik-zlsch,
      xlinea like tabla-top_line.


DATA cols  LIKE LINE OF tabla1-cols.

DATA : BEGIN OF tab OCCURS 0,
         fcode LIKE rsmpe-func,
       END OF tab.

INCLUDE zbatchinput.

DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.

DATA: BEGIN OF record OCCURS 0,
        belnr LIKE bsik-belnr,
        bukrs LIKE bsik-bukrs,
        gjahr LIKE bsik-gjahr,
        buzei LIKE bsik-buzei,
        hbkid LIKE bsik-hbkid,
*        fdlev like bsik-fdlev,       "*
        zzmot_emis LIKE bsik-zzmot_emis,
        zterm LIKE bsik-zterm,
        zfbdt LIKE bsik-zfbdt,
        zlspr LIKE bsik-zlspr,
        zlsch LIKE bsik-zlsch,
        zuonr LIKE bsik-zuonr,
        sgtxt LIKE bsik-sgtxt,
      END OF record.

DATA : BEGIN OF texcel  OCCURS 1,
       lifnr(50),
       name1(50),
       zlsch(50),
       docto_fac(50),
       monto_fac(50),
       docto_nc(50),
       monto_nc(50),
END OF  texcel.

*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN: COMMENT 1(20) text0.

SELECTION-SCREEN POSITION 33.

PARAMETER : bukrs    LIKE bkpf-bukrs    VALUE CHECK OBLIGATORY.

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

SELECTION-SCREEN END OF BLOCK marco1.

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
