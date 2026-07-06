*data:
*lv_page type numc5,
*lv_jobpages type numc5.
*
*write sfsy-page to lv_page left-justified.
*write sfsy-jobpages to lv_jobpages left-justified.
*concatenate 'Seite' lv_page 'von' lv_jobpages
*into gv_pageno separated by space.

* Umsatzsteuer-ID ermitteln
select single stceg from kna1 into gv_ustid
where kunnr = IS_VBDKA-KUNNR.
