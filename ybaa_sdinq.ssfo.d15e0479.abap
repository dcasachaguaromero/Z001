data:
lv_page type numc5,
lv_jobpages type numc5.

write sfsy-page to lv_page left-justified.
write sfsy-jobpages to lv_jobpages left-justified.
concatenate 'Seite' lv_page 'von' lv_jobpages
into gv_pageno separated by space.

* Umsatzsteuer-ID ermitteln
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single stceg from kna1 into gv_ustid
*where kunnr = IS_VBDKA-KUNNR.
*
* NEW CODE
SELECT stceg
UP TO 1 ROWS  from kna1 into gv_ustid
where kunnr = IS_VBDKA-KUNNR ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

