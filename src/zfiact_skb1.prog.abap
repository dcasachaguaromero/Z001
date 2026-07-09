*&---------------------------------------------------------------------*
*& Report  ZFIACT_T30H
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfiact_skb1.

TABLES: SKB1.

DATA subrc LIKE sy-subrc.

DATA:
  BEGIN OF datos  OCCURS 100,
    bukrs(04),
    fill(01),
    hkont(10),
  END OF datos.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
     ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

CALL FUNCTION 'UPLOAD'
  TABLES
    data_tab = datos.


LOOP AT datos.
  Update SKB1 SET XOPVW = ' '
          WHERE BUKRS = datos-bukrs and
                SAKNR = datos-hkont.

  ENDLOOP .
