*****************************************************
PERFORM     GET_PRINT_LANGUAGE
USING     CONTROL_PARAMETERS
CHANGING  GV_LANGUAGE.
*****************************************************

DATA: BEGIN OF nast_key,
mblnr LIKE mkpf-mblnr,
mjahr LIKE mkpf-mjahr,
zeile LIKE mseg-zeile,
END OF nast_key.
DATA: wa_traptab LIKE LINE OF gs_traptab.


DATA: wa_mkpf LIKE mkpf.
DATA: wa_mseg LIKE mseg.
nast_key = is_nast-objky.

SELECT * FROM mseg INTO wa_mseg WHERE mblnr = is_mkpf-mblnr
AND   mjahr = is_mkpf-mjahr.
IF sy-subrc NE 0.
EXIT.
ELSE.
MOVE-CORRESPONDING is_mkpf TO wa_traptab.
MOVE-CORRESPONDING wa_mseg TO wa_traptab.
APPEND  wa_traptab TO gs_traptab.
ENDIF.
ENDSELECT.

*Landesabhängige Aufbereitung von Datum und Betrag
*in Tab. t005x steht Aufbereitung
*bei Materialbelegen Land aus Werk ziehen
SET COUNTRY IS_T001W-land1.

*if is_nast-spras     = 'E'.
*  SET COUNTRY 'US'.
*elseif is_nast-spras = 'D'.
*  set country 'DE'.
*endif.

