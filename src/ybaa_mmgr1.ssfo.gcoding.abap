*****************************************************
PERFORM     GET_PRINT_LANGUAGE
USING     CONTROL_PARAMETERS
CHANGING  GV_LANGUAGE.
*****************************************************

*Landesabhängige Aufbereitung von Datum und Betrag
*in Tab. t005x steht Aufbereitung
*bei Materialbelegen Land aus Werk ziehen
SET COUNTRY IS_T001W-land1.

*if is_nast-spras     = 'E'.
*  SET COUNTRY 'US'.
*elseif is_nast-spras = 'D'.
*  set country 'DE'.
*endif.
















