* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE lgobe FROM t001l INTO gv_lgobe
*WHERE werks = is_mseg-werks
*AND   lgort = is_mseg-lgort.
*
* NEW CODE
SELECT lgobe
UP TO 1 ROWS  FROM t001l INTO gv_lgobe
WHERE werks = is_mseg-werks
AND   lgort = is_mseg-lgort ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc <> 0.
CLEAR gv_lgobe.
ENDIF.






















