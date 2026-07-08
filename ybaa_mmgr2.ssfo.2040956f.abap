

TABLES: makt.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE maktx FROM makt INTO gv_maktx
*WHERE matnr = is_mseg-matnr
*AND spras = gv_language.
*
* NEW CODE
SELECT maktx
UP TO 1 ROWS  FROM makt INTO gv_maktx
WHERE matnr = is_mseg-matnr
AND spras = gv_language ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

if sy-subrc <> 0.
gv_maktx = IS_EKPO-txz01.
endif.
