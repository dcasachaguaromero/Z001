

TABLES: makt.
SELECT SINGLE maktx FROM makt INTO gv_maktx
WHERE matnr = is_mseg-matnr
AND spras = gv_language.

if sy-subrc <> 0.
gv_maktx = IS_EKPO-txz01.
endif.
