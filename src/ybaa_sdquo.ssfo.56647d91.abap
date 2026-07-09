CONSTANTS lc_charx TYPE c VALUE 'X'.

DATA lt_da_t_cabn LIKE cabn OCCURS 10 WITH HEADER LINE.
DATA ls_conf_out  TYPE conf_out.

DATA: BEGIN OF ls_da_key,
mandt LIKE cabn-mandt,
atinn LIKE cabn-atinn,
END OF ls_da_key.

REFRESH gt_conf_out.

CHECK NOT <fs>-cuobj IS INITIAL AND
<fs>-attyp NE '02'.
"----- ATTYP: '02', Variant----------

CALL FUNCTION 'VC_I_GET_CONFIGURATION'
EXPORTING
instance      = <fs>-cuobj
language      = is_nast-spras
print_sales   = lc_charx
TABLES
configuration = gt_conf_out
EXCEPTIONS
OTHERS        = 4.

RANGES lr_da_in_cabn FOR lt_da_t_cabn-atinn.

CLEAR   lr_da_in_cabn.
REFRESH lr_da_in_cabn.

LOOP AT gt_conf_out INTO ls_conf_out.
lr_da_in_cabn-option = 'EQ'.
lr_da_in_cabn-sign   = 'I'.
lr_da_in_cabn-low    = ls_conf_out-atinn.
APPEND lr_da_in_cabn.
ENDLOOP.

CLEAR   lt_da_t_cabn.
REFRESH lt_da_t_cabn.

CALL FUNCTION 'CLSE_SELECT_CABN'
TABLES
in_cabn        = lr_da_in_cabn
t_cabn         = lt_da_t_cabn
EXCEPTIONS
no_entry_found = 1
OTHERS         = 2.

SORT lt_da_t_cabn.

LOOP AT gt_conf_out INTO ls_conf_out.
ls_da_key-mandt = sy-mandt.
ls_da_key-atinn = ls_conf_out-atinn.
READ TABLE lt_da_t_cabn WITH KEY ls_da_key BINARY SEARCH.
IF sy-subrc <> 0 OR
( ( lt_da_t_cabn-attab = 'SDCOM' AND lt_da_t_cabn-atfel = 'VKOND') OR
( lt_da_t_cabn-attab = 'VCSD_UPDATE' ) ) .
DELETE gt_conf_out.
ENDIF.
ENDLOOP.
