TABLES:likp.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * INTO gs_likp FROM likp
*WHERE vbeln = is_dlv_delnote-hd_gen-deliv_numb.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  INTO gs_likp FROM likp
WHERE vbeln = is_dlv_delnote-hd_gen-deliv_numb ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01







