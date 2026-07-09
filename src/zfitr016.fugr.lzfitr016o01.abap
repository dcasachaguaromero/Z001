*----------------------------------------------------------------------*
***INCLUDE LZFITR016O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  LEE_TEXTO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE lee_texto OUTPUT.
  CHECK  zfitr016-bukrs IS NOT INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE butxt INTO gv_butxt
*         FROM t001 WHERE bukrs EQ  zfitr016-bukrs.
*
* NEW CODE
  SELECT butxt
  UP TO 1 ROWS  INTO gv_butxt
         FROM t001 WHERE bukrs EQ  zfitr016-bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE paval INTO gv_rut
*     FROM t001z WHERE bukrs EQ zfitr016-bukrs
*                  AND party EQ 'TAXNR'.
*
* NEW CODE
  SELECT paval
  UP TO 1 ROWS  INTO gv_rut
     FROM t001z WHERE bukrs EQ zfitr016-bukrs
                  AND party EQ 'TAXNR' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CONDENSE gv_rut NO-GAPS.

ENDMODULE.
