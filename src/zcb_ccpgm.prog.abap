*&---------------------------------------------------------------------*
*& Report        ZCB_CCPGM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

PROGRAM  zcb_ccpgm MESSAGE-ID zfi.

INCLUDE zcb_ccpgm_top.
*PARAMETER: p_bukrs LIKE zcb_ccosto-bukrs OBLIGATORY.

*START-OF-SELECTION.

*  SELECT SINGLE * FROM t001 WHERE bukrs = p_bukrs.

* IF sy-subrc  <> 0.
*    MESSAGE e004(zfi) WITH 'Sociedad no existe'.
*  ENDIF.

  CALL SCREEN  100.



  INCLUDE zcb_ccpgm_f01.
  INCLUDE zcb_ccpgm_f02.
