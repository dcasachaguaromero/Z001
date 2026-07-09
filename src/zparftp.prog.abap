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

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t001 WHERE bukrs = p_bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t001 WHERE bukrs = p_bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc  <> 0.
    MESSAGE e004(zfi) WITH 'Sociedad no existe'.
  ENDIF.



  CALL SCREEN  100.



  INCLUDE zparftp_f01.
  INCLUDE zparftp_f02.
