DATA: l_domname TYPE domname,
l_domvalue_l TYPE domvalue_l.
IF is_bil_invoice-hd_gen-bil_cat = 'P'.
l_domname = 'FKTYP'.
l_domvalue_l = is_bil_invoice-hd_gen-bil_cat.
ELSE.
l_domname = 'VBTYP'.
l_domvalue_l = is_bil_invoice-hd_gen-bil_vbtype.
ENDIF.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE ddtext FROM dd07t INTO title
*WHERE domname = l_domname
*AND ddlanguage = control_parameters-langu
*AND domvalue_l = l_domvalue_l.
*
* NEW CODE
SELECT ddtext
UP TO 1 ROWS  FROM dd07t INTO title
WHERE domname = l_domname
AND ddlanguage = control_parameters-langu
AND domvalue_l = l_domvalue_l ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

