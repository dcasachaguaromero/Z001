* read foreign trade data
CLEAR gs_it_ft.

READ TABLE is_dlv_delnote-it_ft INTO gs_it_ft
WITH KEY deliv_numb = gs_it_gen-deliv_numb
         itm_number = gs_it_gen-itm_number BINARY SEARCH.

























