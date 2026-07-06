* check for existing batches
READ TABLE
is_dlv_delnote-it_gen INTO gs_it_gen_batch
WITH KEY deliv_numb = gs_it_gen-deliv_numb
uecha = gs_it_gen-itm_number.
IF sy-subrc NE 0.
CLEAR gs_it_gen_batch.
ENDIF.



