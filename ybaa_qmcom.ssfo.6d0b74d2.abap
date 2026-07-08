*papertext nachlesen
*sprachabh. von &is_wiprt-title& funktioniert nicht ...
*<ML>&IS_T390-papertext&</>

*auswertung copy text??

*ist work..language leer wird dt. gezogen - prüfen..

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single papertext from t390_t into h_papertext
*where spras   = gv_language
*and pm_appl   = is_t390-pm_appl
*and workpaper = is_t390-workpaper.
*
* NEW CODE
SELECT papertext
UP TO 1 ROWS  from t390_t into h_papertext
where spras   = gv_language
and pm_appl   = is_t390-pm_appl
and workpaper = is_t390-workpaper ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

























