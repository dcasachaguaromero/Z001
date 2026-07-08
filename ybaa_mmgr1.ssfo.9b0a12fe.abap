* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT grtxt FROM t157e INTO gv_grtxt
*
*WHERE bwart = is_mseg-bwart
*AND grund = is_mseg-grund
*AND SPRAS = IS_NAST-SPRAS.
*
* NEW CODE
SELECT grtxt
 FROM t157e INTO gv_grtxt

WHERE bwart = is_mseg-bwart
AND grund = is_mseg-grund
AND SPRAS = IS_NAST-SPRAS ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

ENDSELECT.


