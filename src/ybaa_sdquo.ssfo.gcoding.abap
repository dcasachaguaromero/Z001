
**********************************************
* Delete duplicate items in IT_VBDPA
* Setup schedule line internal table
DATA ls_vbdpa TYPE vbdpa.
LOOP AT it_vbdpa INTO ls_vbdpa.
*LOOP AT <itab> INTO <wa>. IT_VBDPA is from Import table(Form Interface)
IF ls_vbdpa-posnr_neu IS INITIAL.
APPEND ls_vbdpa TO gt_sch_item.
* APPEND <line> TO <itab>.
DELETE it_vbdpa.
* Delete line of <itab>.
ENDIF.
ENDLOOP.

**********************************************
PERFORM     get_print_language
USING     control_parameters
is_nast
CHANGING  gv_language.
**********************************************
* Get customer VAT Number
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE stceg FROM kna1 INTO
*gv_cust_vat WHERE kunnr = is_vbdka-kunnr.
*
* NEW CODE
SELECT stceg
UP TO 1 ROWS  FROM kna1 INTO
gv_cust_vat WHERE kunnr = is_vbdka-kunnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

**********************************************
* When document Sold-to = Ship-to ,
* import paramenter IS_VBDKA-ADRNR_WE is empty.
* In this case, set IS_VBDKA-ADRNR_WE
IF is_vbdka-adrnr_we IS INITIAL.
MOVE is_vbdka-adrnr TO is_vbdka-adrnr_we.
ENDIF.

**********************************************
* Check if ship-to and delivery date in item
* level are the same as in header level
DATA lt_ztvbdpa TYPE t_vbdpa_tab.
lt_ztvbdpa[] = it_vbdpa[].
PERFORM compare_dlv_addr_sch
USING    is_vbdka
lt_ztvbdpa
CHANGING gv_dif_addr_flag
gv_dif_schdate_flag.

**********************************************
* delivery data :
* Import parameter IS_VBDKA-LFDAT contains
* delivery date of the document. If delivery date
* differs for different items, this varaiable is
* empty
* Since this is already done in the print program,
* there is no need to add program lines to process
* IS_VBDKA-LFDAT
**********************************************


**********************************************
* Get Price Print Mode
*   empty --- First access SD puffer tables,
*             then SD database tables
*   A     --- Only access SD database tables
*   B     --- Only access SD buffer tables
CALL FUNCTION 'RV_PRICE_PRINT_GET_MODE'
IMPORTING
e_print_mode = gv_price_print_mode.

* Determine Footer Text Modules
DATA: lv_txnam_adr TYPE txnam_adr,
lv_txnam_kop TYPE txnam_kop,
lv_txnam_fus TYPE txnam_fus,
lv_txnam_gru TYPE txnam_gru.

DATA: lv_formname TYPE tdsfname.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE txnam_adr txnam_kop txnam_fus txnam_gru
*FROM tvko INTO (lv_txnam_adr,
*lv_txnam_kop,
*lv_txnam_fus,
*lv_txnam_gru )
*WHERE vkorg = is_vbdka-vkorg.
*
* NEW CODE
SELECT txnam_adr txnam_kop txnam_fus txnam_gru
UP TO 1 ROWS 
FROM tvko INTO (lv_txnam_adr,
lv_txnam_kop,
lv_txnam_fus,
lv_txnam_gru )
WHERE vkorg = is_vbdka-vkorg ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc = '0'.

* Sender
gv_sender = lv_txnam_adr.

* Header
gv_header = lv_txnam_kop.

* Footer 1 - Prefix + No. + Sales Org.
CONCATENATE lv_txnam_fus '1_' is_vbdka-vkorg INTO gv_footer1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE formname FROM stxfadm INTO lv_formname
*WHERE formname = gv_footer1
*AND formtype = 'T'.
*
* NEW CODE
SELECT formname
UP TO 1 ROWS  FROM stxfadm INTO lv_formname
WHERE formname = gv_footer1
AND formtype = 'T' ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc <> '0'.
*   Footer 1 - Prefix + No.
CONCATENATE lv_txnam_fus '1' INTO gv_footer1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE formname FROM stxfadm INTO lv_formname
*WHERE formname = gv_footer1
*AND formtype = 'T'.
*
* NEW CODE
SELECT formname
UP TO 1 ROWS  FROM stxfadm INTO lv_formname
WHERE formname = gv_footer1
AND formtype = 'T' ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc <> '0'.
CLEAR: gv_footer1.
ENDIF.
ENDIF.

* Footer 2 - Prefix + No. + Sales Org.
CONCATENATE lv_txnam_fus '2_' is_vbdka-vkorg INTO gv_footer2.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE formname FROM stxfadm INTO lv_formname
*WHERE formname = gv_footer2
*AND formtype = 'T'.
*
* NEW CODE
SELECT formname
UP TO 1 ROWS  FROM stxfadm INTO lv_formname
WHERE formname = gv_footer2
AND formtype = 'T' ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc <> '0'.
*   Footer 2 - Prefix + No.
CONCATENATE lv_txnam_fus '2' INTO gv_footer2.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE formname FROM stxfadm INTO lv_formname
*WHERE formname = gv_footer2
*AND formtype = 'T'.
*
* NEW CODE
SELECT formname
UP TO 1 ROWS  FROM stxfadm INTO lv_formname
WHERE formname = gv_footer2
AND formtype = 'T' ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
IF sy-subrc <> '0'.
CLEAR: gv_footer2.
ENDIF.
ENDIF.

* Footer 3 - Prefix + No. + Sales Org.
CONCATENATE lv_txnam_fus '3_' is_vbdka-vkorg INTO gv_footer3.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE formname FROM stxfadm INTO lv_formname
*WHERE formname = gv_footer3
*AND formtype = 'T'.
*
* NEW CODE
SELECT formname
UP TO 1 ROWS  FROM stxfadm INTO lv_formname
WHERE formname = gv_footer3
AND formtype = 'T' ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc <> '0'.
*   Footer 3 - Prefix + No.
CONCATENATE lv_txnam_fus '3' INTO gv_footer3.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE formname FROM stxfadm INTO lv_formname
*WHERE formname = gv_footer3
*AND formtype = 'T'.
*
* NEW CODE
SELECT formname
UP TO 1 ROWS  FROM stxfadm INTO lv_formname
WHERE formname = gv_footer3
AND formtype = 'T' ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
IF sy-subrc <> '0'.
CLEAR: gv_footer3.
ENDIF.
ENDIF.

* Footer 4 - Prefix + No. + Sales Org.
CONCATENATE lv_txnam_fus '4_' is_vbdka-vkorg INTO gv_footer4.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE formname FROM stxfadm INTO lv_formname
*WHERE formname = gv_footer4
*AND formtype = 'T'.
*
* NEW CODE
SELECT formname
UP TO 1 ROWS  FROM stxfadm INTO lv_formname
WHERE formname = gv_footer4
AND formtype = 'T' ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc <> '0'.
*   Footer 4 - Prefix + No.
CONCATENATE lv_txnam_fus '4' INTO gv_footer4.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE formname FROM stxfadm INTO lv_formname
*WHERE formname = gv_footer4
*AND formtype = 'T'.
*
* NEW CODE
SELECT formname
UP TO 1 ROWS  FROM stxfadm INTO lv_formname
WHERE formname = gv_footer4
AND formtype = 'T' ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
IF sy-subrc <> '0'.
CLEAR: gv_footer4.
ENDIF.
ENDIF.

ENDIF.

*formatting settings of the langauge environment
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE land1 FROM kna1 INTO h_land
*WHERE kunnr = is_vbdka-kunnr.
*
* NEW CODE
SELECT land1
UP TO 1 ROWS  FROM kna1 INTO h_land
WHERE kunnr = is_vbdka-kunnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
SET COUNTRY h_land.


