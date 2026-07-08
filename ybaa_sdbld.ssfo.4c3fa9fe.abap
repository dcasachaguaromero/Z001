CLEAR gs_it_qm.
* read quality message
READ TABLE
is_dlv_delnote-it_qm INTO gs_it_qm
WITH KEY deliv_numb = gs_it_gen-deliv_numb
itm_number = gs_it_gen-itm_number BINARY SEARCH.


