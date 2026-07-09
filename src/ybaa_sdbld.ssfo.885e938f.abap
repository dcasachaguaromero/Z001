CLEAR gs_hd_adr.
* get shipping adress number
READ TABLE
is_dlv_delnote-hd_adr INTO gs_hd_adr
WITH KEY deliv_numb = is_dlv_delnote-hd_gen-deliv_numb
partn_role = 'WE'.
IF sy-subrc NE 0.
CLEAR gs_hd_adr.
ENDIF.
