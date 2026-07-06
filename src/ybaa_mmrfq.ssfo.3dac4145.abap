CLEAR GT_CONF_OUT.

CALL FUNCTION 'ME_VAR_GET_CLASSIFICATION'
EXPORTING
I_MATNR       = <FS>-EMATN
I_SPRAS       = GV_LANGUAGE
I_EBELP       = <FS>-EBELP
I_CUOBJ       = <FS>-CUOBJ
I_DATE        = IS_EKKO-BEDAT
I_LIFNR       = IS_EKKO-LIFNR
I_UPTYP       = <FS>-UPTYP
I_WERKS       = <FS>-WERKS
TABLES
T_CONF_OUT    = GT_CONF_OUT
EXCEPTIONS
ERROR_MESSAGE = 1
OTHERS        = 2.
** Configuration of items are stored in **
** internal table GT_CONF_OUT           **
























