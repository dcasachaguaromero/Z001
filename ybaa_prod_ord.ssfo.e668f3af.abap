

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single lgpbe from mard
*into gv_lgpbe
*where  matnr = <COMP>-MATNR
*and    werks = <COMP>-WERKS
*and    lgort = <COMP>-LGORT.
*
* NEW CODE
SELECT lgpbe
UP TO 1 ROWS  from mard
into gv_lgpbe
where  matnr = <COMP>-MATNR
and    werks = <COMP>-WERKS
and    lgort = <COMP>-LGORT ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01























