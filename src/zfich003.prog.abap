*&---------------------------------------------------------------------*
*& Report         ZFICH003
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

PROGRAM  zfich003 MESSAGE-ID zfi.

INCLUDE zfich003_top.
PARAMETER: p_bukrs LIKE zfich002-bukrs OBLIGATORY.

START-OF-SELECTION.

  SELECT SINGLE * FROM t001 WHERE bukrs = p_bukrs.

  IF sy-subrc  <> 0.
    MESSAGE e004(zfi) WITH 'Sociedad no existe'.
  ENDIF.



  CALL SCREEN  100.



  INCLUDE zfich003_f01.
  INCLUDE zfich003_f02.
