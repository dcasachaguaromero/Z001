*&---------------------------------------------------------------------*
*& Report         ZWSPROXY
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

PROGRAM  zwsproxy0 MESSAGE-ID zfi.

INCLUDE Z_DEF_PUERTOLOGICO_TOP.
*INCLUDE zwsproxy_top.
PARAMETER: p_bukrs LIKE zws_puerto-sociedad OBLIGATORY.

START-OF-SELECTION.

  SELECT SINGLE * FROM t001 WHERE bukrs = p_bukrs.

  IF sy-subrc  <> 0.
    MESSAGE e004(zfi) WITH 'Sociedad no existe'.
  ENDIF.



  CALL SCREEN  100.



INCLUDE Z_DEF_PUERTOLOGICO_F01.
*  INCLUDE zwsproxy_f01.
INCLUDE Z_DEF_PUERTOLOGICO_F02.
*  INCLUDE zwsproxy_f02.
