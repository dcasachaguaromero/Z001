
CLEAR GS_QM_CERT_CATEGORY.

SELECT SINGLE *
INTO GS_QM_CERT_CATEGORY
FROM tq05
WHERE zgtyp EQ <fs>-zgtyp.

IF sy-subrc EQ 0.
SELECT SINGLE kurztext INTO gs_qm_cert_txt
FROM tq05t
WHERE sprache EQ is_ekko-spras
AND   zgtyp   EQ <fs>-zgtyp.
ENDIF.



















