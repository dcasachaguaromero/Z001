

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single * from konp
*into gs_konp
*where knumh = gs_a003-knumh.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  from konp
into gs_konp
where knumh = gs_a003-knumh ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single * from t685t
*into gs_t685t
*where spras = gv_language and kappl = 'TX'
*and kschl = gs_a003-kschl.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  from t685t
into gs_t685t
where spras = gv_language and kappl = 'TX'
and kschl = gs_a003-kschl ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


gs_konp-kbetr = gs_konp-kbetr / 10.
gv_tax = <FS>-netwr / 100 * gs_konp-kbetr.
GV_PERCENT = gs_konp-kbetr.

*fill table to calculate tax totals
GV_TELLER = GV_TELLER + 1.

GV_TAXTOTAL-TELLER = GV_TELLER.
GV_TAXTOTAL-TAXCODE = <fs>-mwskz.
GV_TAXTOTAL-TAXCOND = gs_a003-kschl.
GV_TAXTOTAL-TXNAME = gs_t685t-vtExt.
GV_TAXTOTAL-TXPERCENTAGE = GV_PERCENT.
GV_TAXTOTAL-TXAMOUNT = GV_TAX.

APPEND GV_TAXTOTAL to GT_TAXTOTALS.

sort gt_taxtotals by taxcode taxcond.













