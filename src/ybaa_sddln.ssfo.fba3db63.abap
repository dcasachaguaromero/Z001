
* read order data
CLEAR gs_it_reford.

READ TABLE is_dlv_delnote-it_reford INTO gs_it_reford
WITH KEY deliv_numb = gs_it_gen-deliv_numb
itm_number = gs_it_gen-itm_number BINARY SEARCH.
*
* read purchase order data
CLEAR gs_it_refpurord.
READ TABLE is_dlv_delnote-it_refpurord INTO gs_it_refpurord
WITH KEY deliv_numb = gs_it_gen-deliv_numb
itm_number = gs_it_gen-itm_number BINARY SEARCH.


