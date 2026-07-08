* DECDIDING THE LANGUAGE KEY
DATA: l_langu TYPE ddlanguage.
IF GV_LANGUAGE IS INITIAL.
l_langu = sy-langu.
ELSE.
l_langu = GV_LANGUAGE.
ENDIF.

TABLES: makt.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE maktx FROM makt INTO gv_maktx
*WHERE matnr = <TRAPTAB>-matnr
*AND spras = l_langu.
*
* NEW CODE
SELECT maktx
UP TO 1 ROWS  FROM makt INTO gv_maktx
WHERE matnr = <TRAPTAB>-matnr
AND spras = l_langu ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

if sy-subrc <> 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single TXZ01 from ekpo into gv_maktx
*   where ebeln = <TRAPTAB>-EBELN
*   and   ebelp = <TRAPTAB>-EBELp.
*
* NEW CODE
  SELECT TXZ01
  UP TO 1 ROWS  from ekpo into gv_maktx
   where ebeln = <TRAPTAB>-EBELN
   and   ebelp = <TRAPTAB>-EBELp ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
endif.

















