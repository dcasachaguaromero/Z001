* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single evtxt from t027B into GV_SHIP_INST
*where SPRAS = sy-langu
*and EVERS = <FS>-EVERS.
*
* NEW CODE
SELECT evtxt
UP TO 1 ROWS  from t027B into GV_SHIP_INST
where SPRAS = sy-langu
and EVERS = <FS>-EVERS ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01



















