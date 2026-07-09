*----------------------------------------------------------------------*
***INCLUDE LZFICO_REP05O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  LEE_NOMBRE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE lee_nombre OUTPUT.
  CHECK zfico_rep05-bukrs IS NOT INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE butxt INTO gv_butxt
*        FROM t001 WHERE bukrs EQ zfico_rep05-bukrs.
*
* NEW CODE
  SELECT butxt
  UP TO 1 ROWS  INTO gv_butxt
        FROM t001 WHERE bukrs EQ zfico_rep05-bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

ENDMODULE.
