*&---------------------------------------------------------------------*
*& Report         ZPARFTP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

PROGRAM  zparftp MESSAGE-ID zfi.

INCLUDE zparftp_top.
PARAMETER: p_bukrs LIKE ztparamftp-zbukr OBLIGATORY.

START-OF-SELECTION.

  SELECT SINGLE * FROM t001 WHERE bukrs = p_bukrs.

  IF sy-subrc  <> 0.
    MESSAGE e004(zfi) WITH 'Sociedad no existe'.
  ENDIF.



  CALL SCREEN  100.



  INCLUDE zparftp_f01.
  INCLUDE zparftp_f02.
