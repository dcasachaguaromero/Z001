
tables: kna1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single name1 from kna1 into z_customer
*where kunnr = is_afpod-kunnr.
*
* NEW CODE
SELECT name1
UP TO 1 ROWS  from kna1 into z_customer
where kunnr = is_afpod-kunnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01























