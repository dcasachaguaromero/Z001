DATA lt_komvd TYPE STANDARD TABLE OF komvd.

DATA lt_ztvbdpa TYPE t_vbdpa_tab.
lt_ztvbdpa[] = it_vbdpa[].

PERFORM get_head_price_table
USING lt_ztvbdpa
is_vbdka
gv_price_print_mode
is_nast-spras
CHANGING
gt_komv
gt_head_disp_cond
gs_last_komk.






















