*DATA:
*lv_page TYPE numc5,
*lv_jobpages TYPE numc5.
*
*WRITE sfsy-page TO lv_page LEFT-JUSTIFIED.
*WRITE sfsy-jobpages TO lv_jobpages LEFT-JUSTIFIED.
*CONCATENATE 'Seite' lv_page 'von' lv_jobpages
*INTO gv_pageno SEPARATED BY space.

* Umsatzsteuer-ID ermitteln
SELECT SINGLE stceg FROM kna1 INTO gv_ustid
WHERE kunnr = is_vbdka-kunnr.
