PROGRAM  zfipg201 MESSAGE-ID zfi.


INCLUDE zfipg201_top.

PARAMETER : bukrs    LIKE bkpf-bukrs     OBLIGATORY .
*----------------------------------------------------------------------*
* Parametros de Proceso
*----------------------------------------------------------------------*
START-OF-SELECTION.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t001 WHERE bukrs = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc  <> 0.
    MESSAGE e004(zfi) WITH 'Sociedad No Existe'.
  ENDIF.



  CALL SCREEN  100.


  INCLUDE zfipg201_100.

  INCLUDE zfipg201_200.
