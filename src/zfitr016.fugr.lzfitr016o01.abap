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
  SELECT SINGLE butxt INTO gv_butxt
         FROM t001 WHERE bukrs EQ  zfitr016-bukrs.
*
  SELECT SINGLE paval INTO gv_rut
     FROM t001z WHERE bukrs EQ zfitr016-bukrs
                  AND party EQ 'TAXNR'.
  CONDENSE gv_rut NO-GAPS.

ENDMODULE.
