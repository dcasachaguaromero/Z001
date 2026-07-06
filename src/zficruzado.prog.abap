*&---------------------------------------------------------------------*
*& Report  ZFICRUZADO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFICRUZADO.

tables: bseg.

select-options: p_belnr for bseg-belnr ,
                p_bukrs for bseg-bukrs,
                p_gjahr for bseg-gjahr.

UPDATE bseg SET xref3 = 'X'
WHERE belnr in p_belnr
  AND gjahr in p_gjahr
  AND bschl = '31'
  AND bukrs in p_bukrs.

IF sy-subrc EQ 0.
  COMMIT WORK AND WAIT.
ENDIF.
