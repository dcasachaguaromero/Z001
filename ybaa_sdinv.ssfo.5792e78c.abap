tables: kna1.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single * from kna1 where
*kunnr = gs_hd_gen-sold_to_party.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  from kna1 where
kunnr = gs_hd_gen-sold_to_party ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

CUST_VAT = kna1-stceg.



