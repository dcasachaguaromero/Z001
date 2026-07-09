* Umsatzsteuer-ID ermitteln
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single stceg from lfa1 into gv_ustid
*where lifnr = IS_EKKO-LIFNR.
*
* NEW CODE
SELECT stceg
UP TO 1 ROWS  from lfa1 into gv_ustid
where lifnr = IS_EKKO-LIFNR ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01























