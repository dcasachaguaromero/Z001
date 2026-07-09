* DECDIDING THE LANGUAGE KEY
DATA: l_langu TYPE ddlanguage.
IF GV_LANGUAGE IS INITIAL.
l_langu = sy-langu.
ELSE.
l_langu = GV_LANGUAGE.
ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE grtxt FROM t157e INTO gv_grtxt
*WHERE bwart = is_mseg-bwart
*AND spras = l_langu
*AND grund = is_mseg-grund.
*
* NEW CODE
SELECT grtxt
UP TO 1 ROWS  FROM t157e INTO gv_grtxt
WHERE bwart = is_mseg-bwart
AND spras = l_langu
AND grund = is_mseg-grund ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


