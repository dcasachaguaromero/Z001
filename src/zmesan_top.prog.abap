*&---------------------------------------------------------------------*
*&  Include          ZCB_CCOSTOS_TOP
*&---------------------------------------------------------------------*
TABLES: zfimotemisan,
        zmot_emis,
        T001.

DATA: RESP(01).

DATA : BEGIN OF INT_TABLA  OCCURS 1,
        bukrs like zfimotemisan-bukrs,
        butxt like t001-butxt,
        zmotiv like zfimotemisan-zmotiv,
        znumero like zfimotemisan-znumero,
        zletras like zfimotemisan-zletras,
        zaccion like zfimotemisan-zaccion,
        sel(1) type c,
 END OF INT_TABLA.

DATA : BEGIN OF  zfimotemisan_EST OCCURS 1,
        bukrs like zfimotemisan-bukrs,
        butxt like t001-butxt,
        zmotiv like zfimotemisan-zmotiv,
        znumero like zfimotemisan-znumero,
        zletras like zfimotemisan-zletras,
        zaccion like zfimotemisan-zaccion,
        sel(1) type c,
END OF zfimotemisan_EST.

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
