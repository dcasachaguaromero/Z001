* DECDIDING THE LANGUAGE KEY
DATA: l_langu TYPE ddlanguage.
IF GV_LANGUAGE IS INITIAL.
l_langu = sy-langu.
ELSE.
l_langu = GV_LANGUAGE.
ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE htext FROM t157h INTO gv_subtitle
*
*
*WHERE spras = l_langu
*AND   tcode = is_mkpf-tcode2
*AND   bwart = is_mseg-bwart
*AND   sobkz = is_mseg-sobkz.
*
* NEW CODE
SELECT htext
UP TO 1 ROWS  FROM t157h INTO gv_subtitle


WHERE spras = l_langu
AND   tcode = is_mkpf-tcode2
AND   bwart = is_mseg-bwart
AND   sobkz = is_mseg-sobkz ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01




















