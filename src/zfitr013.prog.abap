*&---------------------------------------------------------------------*
*& Modulpool         ZFITR013
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

PROGRAM  zfitr013.

TABLES: t001,
        reguh,
        t042z,
        lfa1,
        *lfa1,
        zfitr013_est,
        zfitr013_est1,
        zagencia,
        regup,
        bseg,
        t012t,
        bkpf,
        zctarechazo,
        lfb1.

* Tablas Dynpro
CONTROLS: tabla   TYPE TABLEVIEW USING SCREEN 100.

* Tablas Dynpro
CONTROLS: tabla2  TYPE TABLEVIEW USING SCREEN 100.

DATA : BEGIN OF tab OCCURS 0,
         fcode LIKE rsmpe-func,
       END OF tab.

DATA cols  LIKE LINE OF tabla-cols.

DATA : BEGIN OF tage  OCCURS 0,
          bukrs          LIKE  zagencia-bukrs,
          zzcod_unidad   LIKE  zagencia-zzcod_unidad,
          zzdescr        LIKE  zagencia-zzdescr,
       END OF tage.


DATA : BEGIN OF tcuenta  OCCURS 0,
           bukrs          LIKE  zctarechazo-bukrs,
          rzawe          LIKE  zctarechazo-rzawe,
          hkont_orig     LIKE  zctarechazo-hkont_orig,
          rzawe_d        LIKE  zctarechazo-rzawe_d,
          hkont_dest     LIKE  zctarechazo-hkont_dest,
          hbkid_dest     LIKE  zctarechazo-hbkid_dest,
          hktid_dest     LIKE  zctarechazo-hktid_dest,
END OF tcuenta.


DATA : BEGIN OF int_tabla  OCCURS 1.
        INCLUDE STRUCTURE zfitr013_est.
DATA  END OF int_tabla.


DATA : BEGIN OF int_tabla2  OCCURS 1.
        INCLUDE STRUCTURE zfitr013_est1.
DATA  END OF int_tabla2.

DATA: monto_p       LIKE reguh-rbetr,
      canti_p(6) TYPE p DECIMALS 0,
      fill(4)       TYPE n,
      motivo_rechazo_gen(30),
      monto_i       LIKE reguh-rbetr,
      canti_i(6)    TYPE p DECIMALS 0,
      resp(01),
      salir(02).

DATA : BEGIN OF tabsrd  OCCURS 1,
       sociedad(4),
       fecha_registro type date ,
       comprobante_rechazo(13),
       rut_afiliado(10),
       monto_pago(9) type p decimals 0,
       banco_pagado(6),
       via_pago(1),
       fecha_vencimiento type date ,
       motivo_emision(15),
       agencia_origen(10) ,
       folio_documento(15),
       motivo_rechazo(30),
       motivo_tesoreria(10),
       usuario_responsable(10).
DATA  END OF tabsrd.

SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

PARAMETER : bukrs    LIKE bkpf-bukrs     VALUE CHECK  OBLIGATORY .

PARAMETER : v_hbkid LIKE  reguh-hbkid OBLIGATORY.

SELECT-OPTIONS : v_fecha  FOR reguh-valut OBLIGATORY.

PARAMETER  : rzawe LIKE  reguh-rzawe OBLIGATORY.

PARAMETER  : monto_r LIKE  reguh-rbetr OBLIGATORY.
PARAMETER  : canti_r(6) TYPE  p DECIMALS 0  OBLIGATORY.

SELECTION-SCREEN END OF BLOCK marco1 .

*---------------------------------------------------------------------------------

AT SELECTION-SCREEN ON bukrs.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD bukrs.

  IF sy-subrc <> 0.
    MESSAGE e526(icc_tr) WITH bukrs.
  ENDIF.

  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.


AT SELECTION-SCREEN ON rzawe.

  SELECT SINGLE * FROM t042z WHERE land1 = 'CL'
                             AND   zlsch = rzawe.
  IF sy-subrc <> 0.
    MESSAGE e001(z1) WITH 'Medio de Pago no Existe' rzawe.
  ENDIF.

*  IF rzawe = 'C'.
*
*    MESSAGE e016(z1) WITH 'Medio de Pago debe ser distinto de cheque' .
*  ENDIF.

AT SELECTION-SCREEN ON v_hbkid.

  SELECT SINGLE * FROM t012t WHERE spras = sy-langu
                             AND   bukrs = bukrs
                             AND   hbkid = v_hbkid.

  IF sy-subrc <> 0.
    MESSAGE e016(z1) WITH 'Banco no existe ' .
  ENDIF.

INITIALIZATION.
  t001-waers = 'CLP'.



START-OF-SELECTION.

  SELECT *  FROM zagencia INTO CORRESPONDING FIELDS OF TABLE tage.
  SELECT *  FROM zctarechazo INTO CORRESPONDING FIELDS OF TABLE tcuenta
                             WHERE bukrs = bukrs
                             and rzawe_d <> ''.


  SORT tcuenta BY bukrs rzawe hkont_orig rzawe_d.


  CLEAR:   monto_p,   canti_p,
           monto_i,   canti_i.

  REFRESH: int_tabla, int_tabla2.

  CALL SCREEN 100.


END-OF-SELECTION.
  INCLUDE zbatchinput.

  INCLUDE zfitr013_100.

  INCLUDE zfitr013_200.
