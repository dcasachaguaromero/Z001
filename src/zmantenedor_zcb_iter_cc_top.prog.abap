*&---------------------------------------------------------------------*
*&  Include           ZFIPG001_TOP
*&---------------------------------------------------------------------*

TABLES: ZCB_ITER_CC_EST,
        zcb_iter_cc,
        t001,
        t003,
        t003t.

DATA: resp(01).

DATA : BEGIN OF int_tabla  OCCURS 1.
        INCLUDE STRUCTURE zcb_iter_cc_est.
DATA   END OF int_tabla.

DATA: fill(4)       TYPE n,
      swerror(01)   TYPE n,
      swprimera(01) TYPE n,
      sw_ok(01),
      accion(01),
      titulo(40),
      d_bukrs(30),
      ws_land   TYPE land1.

* Tablas Dynpro
CONTROLS: tabla TYPE TABLEVIEW USING SCREEN 100.

DATA : BEGIN OF tab OCCURS 0,
         fcode LIKE rsmpe-func,
       END OF tab.
