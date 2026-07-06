*&--------------------------------------------------------------------*
*&      Form  GET_PRINT_LANGUAGE
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
FORM get_print_language
USING     is_control_parameters TYPE ssfctrlop
CHANGING  cv_language TYPE ddlanguage.

IF is_control_parameters-langu IS INITIAL.
cv_language = sy-langu.
ELSE.
cv_language = is_control_parameters-langu.
ENDIF.

ENDFORM.                    "GET_PRINT_LANGUAGE
*&--------------------------------------------------------------------*
*&      Form  GET_VENDER_LAND
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
FORM get_vender_land
USING     is_ekko TYPE ekko
is_nast TYPE nast
CHANGING  cv_vender_land.

DATA l_lfa1 LIKE lfa1.
DATA l_lfm1 LIKE lfm1.

IF  is_nast-parnr NE space AND
is_nast-parnr NE is_ekko-lifnr.
SELECT SINGLE land1 FROM lfa1 INTO cv_vender_land
WHERE lifnr = is_nast-parnr.
ELSE.
"--Get address number from table LFA1--
SELECT SINGLE land1 FROM lfa1 INTO cv_vender_land

WHERE lifnr = is_ekko-lifnr.
ENDIF.
ENDFORM.                    "GET_VENDER_LAND

*&--------------------------------------------------------------------*
*&      Form  GET_CUR_DECIMAL_FLAG
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
FORM get_cur_decimal_flag
USING     iv_waers TYPE waers
CHANGING  cv_flag  TYPE c.
DATA ls_tcurx TYPE tcurx.
SELECT SINGLE * FROM tcurx INTO ls_tcurx
WHERE currkey = iv_waers.
IF sy-subrc = 0.
cv_flag = 'X'.
ELSE.
CLEAR cv_flag.
ENDIF.
ENDFORM.                    "GET_CUR_DECIMAL_FLAG
*&--------------------------------------------------------------------*
*&      Form  GET_STO_FLAG
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*

FORM get_sto_flag
USING is_ekko TYPE ekko
CHANGING cv_sto_flag.
CHECK is_ekko-bstyp EQ 'F'.
DATA: ls_brefn TYPE brefn.
SELECT SINGLE brefn FROM t161
INTO ls_brefn WHERE bsart EQ is_ekko-bsart.
IF sy-subrc EQ 0.
IF ls_brefn EQ 'UBF'.
cv_sto_flag = 'X'.
ELSE.
CLEAR cv_sto_flag.
ENDIF.
ENDIF.
ENDFORM.                    "GET_STO_FLAG
*----------------------------------------------------------------------*
*      Form  GET_VARIANT_DESC                                          *
*----------------------------------------------------------------------*
*      determine description of a variant condition                    *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM get_variant_desc
USING    iv_spras TYPE sylangu
iv_knumh TYPE knumb
CHANGING cs_bezei TYPE vtxtk.

CLEAR cs_bezei.

DATA: BEGIN OF lt_vcondtext OCCURS 1.
INCLUDE STRUCTURE vcondtext.
DATA: END OF lt_vcondtext.

* initialize and assign values
REFRESH lt_vcondtext.
CLEAR   lt_vcondtext.
lt_vcondtext-knumh = iv_knumh.
APPEND lt_vcondtext.

* determine description of variant conditin (kntyp = 'O')
CALL FUNCTION 'RV_GET_VARCOND_DESCR'
EXPORTING
language            = iv_spras
TABLES
condition_text      = lt_vcondtext
EXCEPTIONS
cond_does_not_exist = 1.

IF sy-subrc = 0.
READ TABLE lt_vcondtext INDEX 1.
IF sy-subrc = 0.
cs_bezei = lt_vcondtext-vctext.
ENDIF.
ENDIF.

ENDFORM.                    "GET_VARIANT_DESC


*&--------------------------------------------------------------------*
*&      Form  JUDGE_PRINT_INDICATOR
*&--------------------------------------------------------------------*
FORM judge_print_indicator
USING     is_ko             TYPE komv
is_previous_value TYPE kwert
CHANGING  cv_indicator      TYPE xflag
.
* Printing at item level (previous procedure)
IF is_ko-drukz = 'X'.
cv_indicator = 'X'.

* Printing at totals level (previous procedure)
ELSEIF is_ko-drukz = 'S'.
cv_indicator = 'S'.

* Total: General
ELSEIF is_ko-drukz = 'A'.
cv_indicator = 'S'.

* Total: if value <> zero
ELSEIF is_ko-drukz = 'B'.
IF is_ko-kwert <> 0.
cv_indicator = 'S'.
ELSE.
cv_indicator = ' '.
ENDIF.
* Total: if value <> previous value
ELSEIF is_ko-drukz = 'C'.
*    CHECK SY-INDEX NE 1.
IF is_ko-kwert <> is_previous_value.
cv_indicator = 'S'.
ELSE.
cv_indicator = ' '.
ENDIF.

* Total: if value <> zero and value <> previous value
ELSEIF is_ko-drukz = 'D'.
*    CHECK SY-INDEX NE 1.
IF is_ko-kwert <> is_previous_value
AND is_ko-kwert <> 0
.
cv_indicator = 'S'.
ELSE.
cv_indicator = ' '.
ENDIF.

* at item: General
ELSEIF is_ko-drukz = 'a'.
cv_indicator = 'X'.

* at item: if value <> zero
ELSEIF is_ko-drukz = 'b'.
IF is_ko-kwert <> 0.
cv_indicator = 'X'.
ELSE.
cv_indicator = ' '.
ENDIF.

*  at item: if value <> previous value
ELSEIF is_ko-drukz = 'c'.
*    CHECK SY-TABIX NE 1.
IF is_ko-kwert <> is_previous_value.
cv_indicator = 'X'.
ELSE.
cv_indicator = ' '.
ENDIF.

*  at item: if value <> zero and value <> previous value
ELSEIF is_ko-drukz = 'd'.
*    CHECK SY-INDEX NE 1.
IF is_ko-kwert <> is_previous_value
AND is_ko-kwert <> 0.
cv_indicator = 'X'.
ELSE.
cv_indicator = ' '.
ENDIF.

ELSE.
cv_indicator = ' '.
ENDIF.

ENDFORM.                    "JUDGE_PRINT_INDICATOR

*&---------------------------------------------------------------------*
*&      Form  GET_PLANT_ADDRESS
*&---------------------------------------------------------------------*
FORM get_plant_address USING    is_werks LIKE t001w-werks
CHANGING cv_adrnr
cs_sadr LIKE sadr.

* parameter cv_adrnr without type since there are several address
* fields with different domains

DATA: l_ekko LIKE ekko,
l_address LIKE addr1_val.

CHECK NOT is_werks IS INITIAL.
l_ekko-reswk = is_werks.
l_ekko-bsakz = 'T'.
CALL FUNCTION 'MM_ADDRESS_GET'
EXPORTING
i_ekko    = l_ekko
IMPORTING
e_address = l_address
e_sadr    = cs_sadr.
cv_adrnr = l_address-addrnumber.

ENDFORM.                               " GET_PLANT_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  GET_VENDOR_ADDRESS
*&---------------------------------------------------------------------*
FORM get_vendor_address USING    is_emlif LIKE lfa1-lifnr
CHANGING cv_adrnr.
* parameter cv_adrnr without type since there are several address
* fields with different domains

DATA: l_lfa1 LIKE lfa1.

CHECK NOT is_emlif IS INITIAL.
CALL FUNCTION 'VENDOR_MASTER_DATA_SELECT_00'
EXPORTING
i_lfa1_lifnr     = is_emlif
i_data           = 'X'
i_partner        = ' '
IMPORTING
a_lfa1           = l_lfa1
EXCEPTIONS
vendor_not_found = 1.
IF sy-subrc EQ 0.
cv_adrnr = l_lfa1-adrnr.
ELSE.
CLEAR cv_adrnr.
ENDIF.

ENDFORM.                               " GET_VENDOR_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOMER_ADDRESS
*&---------------------------------------------------------------------*
FORM get_customer_address USING    is_kunnr LIKE ekpo-kunnr
CHANGING cv_adrnr.
* parameter cv_adrnr without type since there are several address
* fields with different domains

DATA: l_adrnr LIKE kna1-adrnr.

CHECK NOT is_kunnr IS INITIAL.
SELECT SINGLE adrnr FROM  kna1 INTO (l_adrnr)
WHERE  kunnr  = is_kunnr.
IF sy-subrc EQ 0.
cv_adrnr = l_adrnr.
ELSE.
CLEAR cv_adrnr.
ENDIF.

ENDFORM.                               " GET_CUSTOMER_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  ERGAENZEN_XAEND
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM  ergaenzen_xaend
USING    is_ekpo  TYPE ekpo
is_pekpo TYPE pekpo
is_ekko  TYPE ekko
CHANGING ct_xaend TYPE ty_meein_xaend_tab.

DATA lv_insert.
DATA lv_h_ind   LIKE sy-tabix.
DATA ls_xaend   TYPE ty_meein_xaend.

LOOP AT ct_xaend INTO ls_xaend WHERE ebelp EQ is_pekpo-ebelp.
lv_h_ind = sy-tabix.

" Sonderbearbeitung ------------------
" neue Position ----------------------
IF ls_xaend-insert NE space.
lv_insert = 'X'.
ls_xaend-text_case = 'X'.
MODIFY ct_xaend FROM ls_xaend.
EXIT.
ENDIF.
CHECK ls_xaend-rounr NE 0.
CASE ls_xaend-rounr.
" Einteilungsaenderung ---------------
WHEN 1.
IF is_pekpo-eindt NE 0.
ls_xaend-ctxnr = 'S1-1'.
ELSE.
ls_xaend-ctxnr = 'S1-2'.
ENDIF.
" Zielmenge/Anfragemenge -------------
WHEN 2.
IF is_ekko-bstyp EQ 'A'.
ls_xaend-ctxnr = 'S2-A'.
ELSE.
ls_xaend-ctxnr = 'S2-R'.
ENDIF.
" Loeschkennzeichen ------------------
WHEN 3.
CASE is_ekpo-loekz.
WHEN 'L'.
ls_xaend-ctxnr = 'S3-L'.
WHEN 'S'.
ls_xaend-ctxnr = 'S3-S'.
WHEN ' '.
ls_xaend-ctxnr = 'S3-X'.
ENDCASE.
ENDCASE.
MODIFY ct_xaend FROM ls_xaend INDEX lv_h_ind.
ENDLOOP.
IF sy-subrc EQ 0 AND NOT is_ekpo-uebpo IS INITIAL.
READ TABLE ct_xaend WITH KEY ebelp = is_ekpo-uebpo
BINARY SEARCH TRANSPORTING NO FIELDS.
IF sy-subrc NE 0.
CLEAR ls_xaend.
ls_xaend-ebelp = is_ekpo-uebpo.
INSERT ls_xaend INTO  ct_xaend INDEX sy-tabix.
ENDIF.
ENDIF.

" bei neuer Position keine anderen Änderungen drucken --
IF lv_insert NE space.
LOOP AT ct_xaend INTO ls_xaend
WHERE ebelp  EQ is_pekpo-ebelp
AND   insert EQ space.
DELETE ct_xaend.
ENDLOOP.
ENDIF.

ENDFORM.                    "ERGAENZEN_XAEND


































