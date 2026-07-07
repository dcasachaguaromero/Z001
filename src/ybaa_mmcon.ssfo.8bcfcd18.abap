
CLEAR GS_QM_CERT_CATEGORY.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE *
*INTO GS_QM_CERT_CATEGORY
*FROM tq05
*WHERE zgtyp EQ <fs>-zgtyp.
*
* NEW CODE
SELECT *
UP TO 1 ROWS 
INTO GS_QM_CERT_CATEGORY
FROM tq05
WHERE zgtyp EQ <fs>-zgtyp ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE kurztext INTO gs_qm_cert_txt
*FROM tq05t
*WHERE sprache EQ is_ekko-spras
*AND   zgtyp   EQ <fs>-zgtyp.
*
* NEW CODE
SELECT kurztext
UP TO 1 ROWS  INTO gs_qm_cert_txt
FROM tq05t
WHERE sprache EQ is_ekko-spras
AND   zgtyp   EQ <fs>-zgtyp ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
ENDIF.



















