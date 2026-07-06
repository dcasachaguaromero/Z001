DATA: l_domname TYPE domname,
l_domvalue_l TYPE domvalue_l.
IF is_bil_invoice-hd_gen-bil_cat = 'P'.
l_domname = 'FKTYP'.
l_domvalue_l = is_bil_invoice-hd_gen-bil_cat.
ELSE.
l_domname = 'VBTYP'.
l_domvalue_l = is_bil_invoice-hd_gen-bil_vbtype.
ENDIF.
SELECT SINGLE ddtext FROM dd07t INTO title
WHERE domname = l_domname
AND ddlanguage = control_parameters-langu
AND domvalue_l = l_domvalue_l.

