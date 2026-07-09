

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single lgpbe from mard
*into gv_lgpbe
*where  matnr = IS_MSEG-MATNR
*and    werks = IS_MSEG-WERKS
*and    lgort = IS_MSEG-LGORT.
*
* NEW CODE
SELECT lgpbe
UP TO 1 ROWS  from mard
into gv_lgpbe
where  matnr = IS_MSEG-MATNR
and    werks = IS_MSEG-WERKS
and    lgort = IS_MSEG-LGORT ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01























