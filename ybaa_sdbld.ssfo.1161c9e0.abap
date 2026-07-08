* object text name item
CLEAR gf_tdname_item.
gf_tdname_item = gs_it_gen-deliv_numb.
WRITE gs_it_gen-itm_number TO gf_tdname_item+10(6).




