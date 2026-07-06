TABLES: t001l.

*lager

SELECT SINGLE lgobe FROM t001l INTO gv_lgobe
WHERE werks = <traptab>-werks
AND lgort = <traptab>-lgort.

IF sy-subrc <> 0.
CLEAR gv_lgobe.
ENDIF.
























