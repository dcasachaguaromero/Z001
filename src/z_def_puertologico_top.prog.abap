*&---------------------------------------------------------------------*
*&  Include           ZWSPROXY_TOP
*&---------------------------------------------------------------------*
TABLES: ZWS_PUERTO,
        ZWS_PUERTO_EST,
        T001.

DATA: RESP(01).

DATA : BEGIN OF INT_TABLA  OCCURS 1.
        INCLUDE STRUCTURE ZWS_PUERTO_EST.
DATA   END OF INT_TABLA.



DATA: FILL(4)       TYPE N,
      SWERROR(01)   TYPE N,
      SWPRIMERA(01) TYPE N,
      SW_OK(01),
      ACCION(01),
      TITULO(30).

* Tablas Dynpro
CONTROLS: TABLA TYPE TABLEVIEW USING SCREEN 100.

DATA : BEGIN OF TAB OCCURS 0,
       FCODE LIKE RSMPE-FUNC,
END OF TAB.
