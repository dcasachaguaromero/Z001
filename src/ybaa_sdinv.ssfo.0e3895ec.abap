*TABLES: likp.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE bolnr FROM likp INTO g_bolnr
*WHERE vbeln = is_bil_invoice-hd_ref-deliv_numb.
*
* NEW CODE
SELECT bolnr
UP TO 1 ROWS  FROM likp INTO g_bolnr
WHERE vbeln = is_bil_invoice-hd_ref-deliv_numb ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01














