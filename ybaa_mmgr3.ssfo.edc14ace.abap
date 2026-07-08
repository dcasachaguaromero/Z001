TABLES: t001l.

*lager

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE lgobe FROM t001l INTO gv_lgobe
*WHERE werks = <traptab>-werks
*AND lgort = <traptab>-lgort.
*
* NEW CODE
SELECT lgobe
UP TO 1 ROWS  FROM t001l INTO gv_lgobe
WHERE werks = <traptab>-werks
AND lgort = <traptab>-lgort ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc <> 0.
CLEAR gv_lgobe.
ENDIF.
























