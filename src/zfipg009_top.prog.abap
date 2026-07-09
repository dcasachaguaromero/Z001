*&---------------------------------------------------------------------*
*&  Include           ZFIPG008_TOP
*&---------------------------------------------------------------------*
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




DATA: fill(4)       TYPE n,
      swerror(01)   TYPE n,
      swprimera(01) TYPE n,
      sw_ok(01),
      accion(01),
      titulo(40),
      ws_land   TYPE land1,
      resto(3) TYPE n.


* Tablas Dynpro
CONTROLS: tabla  TYPE TABLEVIEW USING SCREEN 100.


DATA cols  LIKE LINE OF tabla-cols.



DATA : BEGIN OF tab OCCURS 0,
         fcode LIKE rsmpe-func,
       END OF tab.

DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.

*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

PARAMETER : bukrs    LIKE bkpf-bukrs     VALUE CHECK  OBLIGATORY .

select-options : nproceso for zfipg002_cab-nproceso,
                 v_fecha  for reguh-laufd,
                 v_nomina for reguh-laufi.

select-options  : v_hbkid for reguh-laufd.


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
