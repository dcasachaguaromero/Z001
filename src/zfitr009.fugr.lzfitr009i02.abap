*----------------------------------------------------------------------*
***INCLUDE LZFITR009I02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  DATOS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE datos INPUT.
  IF NOT zfitr009-datab IS INITIAL AND NOT zfitr009-datbi IS INITIAL AND zfitr009-datab >= zfitr009-datbi.
    MESSAGE e888(sabapdocu) WITH 'Error en las fechas'.
  ENDIF.

  zfitr009-datum = sy-datum.
  zfitr009-ubname = sy-uname.
  zfitr009-uzeit = sy-uzeit.

ENDMODULE.                 " DATOS  INPUT
