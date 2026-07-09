
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single name1 from lfa1 into z_vendor_name
*where lifnr = <ops>-lifnr.
*
* NEW CODE
SELECT name1
UP TO 1 ROWS  from lfa1 into z_vendor_name
where lifnr = <ops>-lifnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01























