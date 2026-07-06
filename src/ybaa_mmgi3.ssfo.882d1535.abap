
* DECDIDING THE LANGUAGE KEY
DATA: L_LANGU TYPE DDLANGUAGE.
IF GV_LANGUAGE IS INITIAL.
L_LANGU = SY-LANGU.
ELSE.
L_LANGU = GV_LANGUAGE.
ENDIF.

*S WE / H WA
SELECT SINGLE shkzg FROM t156 INTO gv_shkzg
WHERE bwart = is_mseg-bwart.

IF gv_shkzg = 'S'.
SELECT SINGLE ltext FROM t003t INTO gv_title
WHERE spras = l_langu
AND  blart = 'WE'.
*AND  BLART = IS_MKPF-BLART.
ELSE.
SELECT SINGLE ltext FROM t003t INTO gv_title
WHERE spras = l_langu
AND  blart = 'WA'.
ENDIF.












