DATA    cv_itm_unit_price   TYPE kbetr.
DATA    cv_itm_amount       TYPE kwert.
DATA    cv_itm_freight_tot  TYPE kwert.
DATA    cv_itm_tax_tot      TYPE kwert.
DATA    ct_itm_vat_konv     TYPE TABLE OF komvd.

CLEAR gt_itm_disp_konv.
CLEAR gv_itm_amount.
CLEAR gv_itm_all_tot.

DATA    lt_komvd       TYPE t_komvd_tab.
PERFORM get_itm_price_table
USING     <fs>
is_vbdka
gv_price_print_mode
is_nast-spras
CHANGING
gt_komv
lt_komvd
gs_last_komk.

PERFORM get_itm_price_info_new
USING     is_vbdka-knumv
<fs>-posnr
control_parameters-langu
lt_komvd
CHANGING    gs_itm_price
*            GV_ITM_UNIT_PRICE
gv_itm_amount
*            GV_ITM_NET_VAL
cv_itm_freight_tot
cv_itm_tax_tot
gv_itm_all_tot
gt_itm_disp_konv
ct_itm_vat_konv.

*************************************
*ADD GV_ITM_NET_VAL     TO GV_NET_SUM.
*ADD GV_ITM_ALL_TOT     TO GV_ALL_SUM.
ADD cv_itm_tax_tot     TO gv_tax_sum.
ADD cv_itm_freight_tot TO gv_freight_sum.

*GT_ITM_DISP_KONV[] = CT_ITM_DISP_KONV[]

DATA ls_itm_tax_konv TYPE komvd.
DATA ls_tax_konv     TYPE komvd.
LOOP AT ct_itm_vat_konv INTO ls_itm_tax_konv.
ADD ls_itm_tax_konv-kawrt TO gv_tax_base_sum.
READ TABLE gt_tax_konv INTO ls_tax_konv
WITH KEY mwskz = ls_itm_tax_konv-mwskz.
IF sy-subrc = 0.
ADD: ls_itm_tax_konv-kawrt TO ls_tax_konv-kawrt,
ls_itm_tax_konv-kwert TO ls_tax_konv-kwert.
MODIFY gt_tax_konv FROM ls_tax_konv
TRANSPORTING kawrt kwert WHERE
mwskz = ls_tax_konv-mwskz .
ELSE.
APPEND ls_itm_tax_konv TO gt_tax_konv.
ENDIF.
ENDLOOP.

