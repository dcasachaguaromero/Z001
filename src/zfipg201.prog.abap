PROGRAM  zfipg201 MESSAGE-ID zfi.


INCLUDE zfipg201_top.

PARAMETER : bukrs    LIKE bkpf-bukrs     OBLIGATORY .
*----------------------------------------------------------------------*
* Parametros de Proceso
*----------------------------------------------------------------------*
START-OF-SELECTION.

  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.

  IF sy-subrc  <> 0.
    MESSAGE e004(zfi) WITH 'Sociedad No Existe'.
  ENDIF.



  CALL SCREEN  100.


  INCLUDE zfipg201_100.

  INCLUDE zfipg201_200.
