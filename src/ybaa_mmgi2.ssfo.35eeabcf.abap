* DECDIDING THE LANGUAGE KEY
DATA: l_langu TYPE ddlanguage.
IF GV_LANGUAGE IS INITIAL.
l_langu = sy-langu.
ELSE.
l_langu = GV_LANGUAGE.
ENDIF.

SELECT SINGLE htext FROM t157h INTO gv_subtitle
WHERE spras = l_langu
AND   tcode = is_mkpf-tcode2
AND   bwart = is_mseg-bwart
AND   sobkz = is_mseg-sobkz.

























