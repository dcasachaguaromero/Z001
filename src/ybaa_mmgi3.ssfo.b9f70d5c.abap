* DECDIDING THE LANGUAGE KEY
DATA: l_langu TYPE ddlanguage.
IF GV_LANGUAGE IS INITIAL.
l_langu = sy-langu.
ELSE.
l_langu = GV_LANGUAGE.
ENDIF.

TABLES: makt.
SELECT SINGLE maktx FROM makt INTO gv_maktx
WHERE matnr = <TRAPTAB>-matnr
AND spras = l_langu.

if sy-subrc <> 0.
  select single TXZ01 from ekpo into gv_maktx
   where ebeln = <TRAPTAB>-EBELN
   and   ebelp = <TRAPTAB>-EBELp.
endif.

















