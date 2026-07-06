SELECT SINGLE lgobe FROM t001l INTO gv_lgobe
WHERE werks = is_mseg-werks
AND   lgort = is_mseg-lgort.

IF sy-subrc <> 0.
CLEAR gv_lgobe.
ENDIF.






















