*&---------------------------------------------------------------------*
*& Report        ZMESAN
*&
*&---------------------------------------------------------------------*
*&  Para mantener tabla de Motivos emision e HUB Santander
*&
*&---------------------------------------------------------------------*

PROGRAM  zmesan MESSAGE-ID zfi.

INCLUDE zmesan_top.
*PARAMETER: p_bukrs LIKE zcb_ccosto-bukrs OBLIGATORY.

*START-OF-SELECTION.

*  SELECT SINGLE * FROM t001 WHERE bukrs = p_bukrs.

* IF sy-subrc  <> 0.
*    MESSAGE e004(zfi) WITH 'Sociedad no existe'.
*  ENDIF.

  CALL SCREEN  100.

  INCLUDE zmesan_f01.
  INCLUDE zmesan_f02.
