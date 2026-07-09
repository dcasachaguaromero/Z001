*&---------------------------------------------------------------------*
*& Include ZFIPG006_TOP                                      Modulpool        ZFIPG006
*&
*&---------------------------------------------------------------------*

PROGRAM  zfipg006.

TABLES zfipg003.

DATA: p_bukrs LIKE zfipg003-bukrs.

DATA: valor TYPE string.
TYPES:  BEGIN OF ty_tabla,
RUTA_SAP LIKE zfirma_digital-ruta_sap,
 END OF  ty_tabla.
DATA: ti_tabla TYPE TABLE OF ty_tabla,
      wa_tabla TYPE ty_tabla.

DATA: BEGIN OF it_match OCCURS 0,
        shlpname  LIKE ddshretval-shlpname,
        fieldname LIKE ddshretval-fieldname,
        recordpos LIKE ddshretval-recordpos,
        fieldval  LIKE ddshretval-fieldval,
        retfield  LIKE ddshretval-retfield,
      END OF it_match.
