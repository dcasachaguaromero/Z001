*&--------------------------------------------------------------------*
*&      Form  GET_PRINT_LANGUAGE
*&--------------------------------------------------------------------*
FORM get_print_language
USING     is_control_parameters TYPE ssfctrlop
is_nast     TYPE nast
CHANGING  cv_language TYPE ddlanguage.

IF NOT is_control_parameters-langu IS INITIAL.
cv_language = is_control_parameters-langu.
ELSEIF NOT is_nast-spras IS INITIAL.
cv_language = is_nast-spras.
ELSE.
cv_language = sy-langu.
ENDIF.

ENDFORM.                    "GET_PRINT_LANGUAGE
*--------------------------------------------------------------------*
*      Form  compare_dlv_addr_sch
*--------------------------------------------------------------------*
FORM compare_dlv_addr_sch
USING
is_zvbdka        TYPE vbdka
it_ztvbdpa       TYPE t_vbdpa_tab
CHANGING
cv_dif_addr_flag    TYPE xflag
cv_dif_schdate_flag TYPE xflag.

DATA  lv_adrnr_we TYPE ad_addrnum.
DATA  lv_edatu    TYPE edatu.
DATA  lv_item_num TYPE sytfill.
DATA  ls_ztvbdpa  TYPE vbdpa.
DATA  l_edatu(10) TYPE c.

CLEAR: cv_dif_addr_flag,
lv_adrnr_we.

LOOP AT  it_ztvbdpa INTO ls_ztvbdpa .
IF ls_ztvbdpa-adrnr_we <> is_zvbdka-adrnr_we AND
NOT ls_ztvbdpa-adrnr_we IS INITIAL.
cv_dif_addr_flag = 'X'.
EXIT.
ENDIF.
ENDLOOP.

LOOP AT  it_ztvbdpa INTO ls_ztvbdpa .
WRITE ls_ztvbdpa-edatu TO l_edatu.
"IF L_EDATU <> IS_ZVBDKA-LFDAT.
IF is_zvbdka-lfdat IS INITIAL AND
NOT ls_ztvbdpa-edatu IS INITIAL.
cv_dif_schdate_flag = 'X'.
EXIT.
ENDIF.
ENDLOOP.
ENDFORM.                    "COMPARE_DLV_ADDR


*&--------------------------------------------------------------------*
*&      Form  GET_ITM_PRICE_TABLE
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
FORM get_itm_price_table
USING
is_vbdpa             TYPE vbdpa
is_vbdka             TYPE vbdka
iv_price_print_mode  TYPE c
iv_spras             TYPE spras
CHANGING
ct_komv              TYPE t_komv_tab
ct_komvd             TYPE t_komvd_tab
cs_komk              TYPE komk.

DATA ls_komp TYPE komp.
DATA ls_komk TYPE komk.
*  DATA lt_tkomv  TYPE STANDARD TABLE OF komv.

IF ls_komk-knumv NE is_vbdka-knumv OR
ls_komk-knumv IS INITIAL.
CLEAR ls_komk.
ls_komk-mandt = sy-mandt.
ls_komk-kalsm = is_vbdka-kalsm.
ls_komk-kappl = 'V'.
ls_komk-waerk = is_vbdka-waerk.
ls_komk-knumv = is_vbdka-knumv.
ls_komk-knuma = is_vbdka-knuma.
ls_komk-vbtyp = is_vbdka-vbtyp.
ls_komk-land1 = is_vbdka-land1.
ls_komk-vkorg = is_vbdka-vkorg.
ls_komk-vtweg = is_vbdka-vtweg.
ls_komk-spart = is_vbdka-spart.
ls_komk-bukrs = is_vbdka-bukrs_vf.
ls_komk-hwaer = is_vbdka-waers.
ls_komk-prsdt = is_vbdka-erdat.
ls_komk-kurst = is_vbdka-kurst.
ls_komk-kurrf = is_vbdka-kurrf.
ls_komk-kurrf_dat = is_vbdka-kurrf_dat.
ENDIF.

ls_komp-kposn = is_vbdpa-posnr.
ls_komp-kursk = is_vbdpa-kursk.
ls_komp-kursk_dat = is_vbdpa-kursk_dat.
IF is_vbdka-vbtyp CA 'HKNOT6'.
IF is_vbdpa-shkzg CA ' A'.
ls_komp-shkzg = 'X'.
ENDIF.
ELSE.
IF is_vbdpa-shkzg CA 'BX'.
ls_komp-shkzg = 'X'.
ENDIF.
ENDIF.


IF iv_price_print_mode EQ 'A'.
CALL FUNCTION 'RV_PRICE_PRINT_ITEM'
EXPORTING
comm_head_i = ls_komk
comm_item_i = ls_komp
language    = iv_spras
IMPORTING
comm_head_e = ls_komk
comm_item_e = ls_komp
TABLES
tkomv       = ct_komv
tkomvd      = ct_komvd.
ELSE.
CALL FUNCTION 'RV_PRICE_PRINT_ITEM_BUFFER'
EXPORTING
comm_head_i = ls_komk
comm_item_i = ls_komp
language    = iv_spras
IMPORTING
comm_head_e = ls_komk
comm_item_e = ls_komp
TABLES
tkomv       = ct_komv
tkomvd      = ct_komvd.
ENDIF.
cs_komk = ls_komk.
ENDFORM.                    "get_itm_price_table


*--------------------------------------------------------------*
*       FORM get_itm_price_info
*--------------------------------------------------------------*
*--------------------------------------------------------------*
FORM get_itm_price_info_new
USING
iv_doc_con_num TYPE knumv
iv_itm_num     TYPE posnr
iv_contr_langu TYPE spras
it_komvd       TYPE t_komvd_tab
CHANGING
cs_itm_price       TYPE komvd
cv_itm_amount      TYPE kwert
cv_itm_fright_tot  TYPE kwert
cv_itm_tax_tot     TYPE kwert
cv_itm_all_tot     TYPE kwert
ct_itm_disp_konv   TYPE t_komvd_tab
ct_itm_vat_konv    TYPE t_komvd_tab.

DATA ls_konv TYPE komvd.

CLEAR cv_itm_fright_tot.
CLEAR ct_itm_vat_konv.

LOOP AT it_komvd INTO ls_konv.
DATA lv_vtext TYPE vtxtk.

IF sy-tabix = 1 AND
( ls_konv-koaid = 'B' OR ls_konv-kschl = space ).
" The first condition line AND condition
" class KOAID = 'B' (Prices)
" CS_ITM_PRICE is the item overview price info
cs_itm_price = ls_konv.
ADD ls_konv-kwert TO cv_itm_all_tot.
MOVE ls_konv-kwert TO cv_itm_amount.
ELSEIF ls_konv-mwskz NE ''.
" Tax condition
ADD ls_konv-kwert TO cv_itm_all_tot.
ADD ls_konv-kwert TO cv_itm_tax_tot.
APPEND ls_konv    TO ct_itm_disp_konv.
APPEND ls_konv    TO ct_itm_vat_konv.
ELSEIF ls_konv-kntyp = 'F'.
" Freight condition
ADD ls_konv-kwert TO cv_itm_fright_tot.
ADD ls_konv-kwert TO cv_itm_all_tot.
APPEND ls_konv    TO ct_itm_disp_konv.
ELSEIF ls_konv-kschl = 'PNTP'.
" if PNTP EXIST, COPY THIS CONDITION VALUE TO ITEM NET VALUE
cs_itm_price = ls_konv.
MOVE ls_konv-kwert TO cv_itm_all_tot.
APPEND ls_konv    TO ct_itm_disp_konv.
ELSEIF ls_konv-kwert IS INITIAL.
ELSE.
ADD ls_konv-kwert TO cv_itm_all_tot.
APPEND ls_konv    TO ct_itm_disp_konv.
ENDIF.
ENDLOOP.

ENDFORM.                    "get_itm_price_info

*--------------------------------------------------------------*
*       FORM GET_HEAD_PRICE_TABLE
*--------------------------------------------------------------*
*--------------------------------------------------------------*
FORM get_head_price_table
USING
it_vbdpa             TYPE t_vbdpa_tab
is_vbdka             TYPE vbdka
iv_price_print_mode  TYPE c
iv_spras             TYPE spras
CHANGING
ct_komv              TYPE t_komv_tab
ct_komvd             TYPE t_komvd_tab
cs_komk              TYPE komk.

DATA ls_vbdpa TYPE vbdpa.
DATA ls_komp  TYPE komp.
DATA ls_komk  TYPE komk.
*  DATA lt_komv  TYPE STANDARD TABLE OF komv.

IF ls_komk-knumv NE is_vbdka-knumv OR
ls_komk-knumv IS INITIAL.
CLEAR ls_komk.
ls_komk-mandt = sy-mandt.
ls_komk-kalsm = is_vbdka-kalsm.
ls_komk-kappl = 'V'.
ls_komk-waerk = is_vbdka-waerk.
ls_komk-knumv = is_vbdka-knumv.
ls_komk-knuma = is_vbdka-knuma.
ls_komk-vbtyp = is_vbdka-vbtyp.
ls_komk-land1 = is_vbdka-land1.
ls_komk-vkorg = is_vbdka-vkorg.
ls_komk-vtweg = is_vbdka-vtweg.
ls_komk-spart = is_vbdka-spart.
ls_komk-bukrs = is_vbdka-bukrs_vf.
ls_komk-hwaer = is_vbdka-waers.
ls_komk-prsdt = is_vbdka-erdat.
ls_komk-kurst = is_vbdka-kurst.
ls_komk-kurrf = is_vbdka-kurrf.
ls_komk-kurrf_dat = is_vbdka-kurrf_dat.
ENDIF.

LOOP AT it_vbdpa INTO ls_vbdpa.
CALL FUNCTION 'SD_TAX_CODE_MAINTAIN'
EXPORTING
key_knumv           = is_vbdka-knumv
key_kposn           = ls_vbdpa-posnr
i_application       = ' '
i_pricing_procedure = is_vbdka-kalsm
TABLES
xkomv               = ct_komv.
ENDLOOP.

IF iv_price_print_mode EQ 'A'.
CALL FUNCTION 'RV_PRICE_PRINT_HEAD'
EXPORTING
comm_head_i = ls_komk
language    = iv_spras
IMPORTING
comm_head_e = ls_komk
TABLES
tkomv       = ct_komv
tkomvd      = ct_komvd.
ELSE.
CALL FUNCTION 'RV_PRICE_PRINT_HEAD_BUFFER'
EXPORTING
comm_head_i = ls_komk
language    = iv_spras
IMPORTING
comm_head_e = ls_komk
TABLES
tkomv       = ct_komv
tkomvd      = ct_komvd.
ENDIF.
cs_komk = ls_komk.

ENDFORM.                    "GET_HEAD_PRICE_TABLE














