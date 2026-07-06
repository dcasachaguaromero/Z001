
*****************************************************
PERFORM     get_print_language
USING     control_parameters
CHANGING  gv_language.
*****************************************************
PERFORM     get_cur_decimal_flag
USING     is_ekko-waers
CHANGING  gv_spec_cur_decimal.
*****************************************************
PERFORM     get_vender_land
USING     is_ekko
is_nast
CHANGING
gv_vender_land.
*****************************************************
PERFORM get_sto_flag
USING     is_ekko
CHANGING  gv_sto_flag.
*****************************************************


*****************************************************
******* Get the change information ******************
DATA:
lt_xaend     TYPE STANDARD TABLE OF ty_meein_xaend,
ls_xaend     TYPE ty_meein_xaend,
ls_chg_texts TYPE ty_chg_texts.

IF is_nast-aende NE space.
CALL FUNCTION 'ME_READ_CHANGES_EINKBELEG'
EXPORTING
document        = is_ekko
date_of_change  = is_nast-datvr
time_of_change  = is_nast-uhrvr
print_operation = '2'
TABLES
xekpo           = it_ekpo
xaend           = lt_xaend.

DATA ls_ekpo TYPE ekpo.
LOOP AT it_ekpo INTO ls_ekpo.
DATA ls_pekpo TYPE pekpo.
READ TABLE it_pekpo
INTO       ls_pekpo
WITH  KEY  ebelp = ls_ekpo-ebelp.

PERFORM  ergaenzen_xaend
USING    ls_ekpo
ls_pekpo
is_ekko
CHANGING lt_xaend.
ENDLOOP.

ls_chg_texts-ebeln = is_ekko-ebeln.
LOOP AT lt_xaend INTO ls_xaend
WHERE ctxnr <> ' '.
ls_chg_texts-ebelp = ls_xaend-ebelp.
ls_chg_texts-ctxnr = ls_xaend-ctxnr.
ls_chg_texts-f_old = ls_xaend-f_old.
ls_chg_texts-f_new = ls_xaend-f_new.
SELECT SINGLE chtxt FROM t166t INTO ls_chg_texts-chtxt
WHERE spras = sy-langu AND ctxnr = ls_xaend-ctxnr.
APPEND ls_chg_texts TO gt_chg_texts.
ENDLOOP.

SORT gt_chg_texts BY ebeln ebelp chtxt.
DELETE ADJACENT DUPLICATES FROM gt_chg_texts
COMPARING ebeln ebelp chtxt.
SORT gt_chg_texts BY ebeln ebelp ctxnr.
ENDIF.


*******************************
**  PREPARE_CONDITION

*******************************
FIELD-SYMBOLS: <fs_komv>  TYPE komv.
LOOP AT it_tkomv ASSIGNING <fs_komv>.
SELECT SINGLE drukz
FROM t683s
INTO <fs_komv>-drukz
WHERE kalsm = is_ekko-kalsm
AND kschl = <fs_komv>-kschl.
ENDLOOP.
********************************

* Determine Footer Text Modules
DATA: lv_txadr TYPE txadr,
lv_txkop TYPE txkop,
lv_txfus TYPE txfus,
lv_txgru TYPE txgru.

DATA: lv_formname TYPE tdsfname.

SELECT SINGLE txadr txkop txfus txgru
FROM t024e INTO (lv_txadr, lv_txkop, lv_txfus, lv_txgru )
WHERE ekorg = is_ekko-ekorg.

IF sy-subrc = '0'.

* Sender
gv_sender = lv_txadr.

* Header
gv_header = lv_txkop.

* Footer 1 - Prefix + No. + Purchasing Org.
CONCATENATE lv_txfus '1_' is_ekko-ekorg INTO gv_footer1.
SELECT SINGLE formname FROM stxfadm INTO lv_formname
WHERE formname = gv_footer1
AND formtype = 'T'.

IF sy-subrc <> '0'.
*   Footer 1 - Prefix + No.
CONCATENATE lv_txfus '1' INTO gv_footer1.
SELECT SINGLE formname FROM stxfadm INTO lv_formname
WHERE formname = gv_footer1
AND formtype = 'T'.

IF sy-subrc <> '0'.
CLEAR: gv_footer1.
ENDIF.
ENDIF.

* Footer 2 - Prefix + No. + Purchasing Org.
CONCATENATE lv_txfus '2_' is_ekko-ekorg INTO gv_footer2.
SELECT SINGLE formname FROM stxfadm INTO lv_formname
WHERE formname = gv_footer2
AND formtype = 'T'.

IF sy-subrc <> '0'.
*   Footer 2 - Prefix + No.
CONCATENATE lv_txfus '2' INTO gv_footer2.
SELECT SINGLE formname FROM stxfadm INTO lv_formname
WHERE formname = gv_footer2
AND formtype = 'T'.
IF sy-subrc <> '0'.
CLEAR: gv_footer2.
ENDIF.
ENDIF.

* Footer 3 - Prefix + No. + Purchasing Org.
CONCATENATE lv_txfus '3_' is_ekko-ekorg INTO gv_footer3.
SELECT SINGLE formname FROM stxfadm INTO lv_formname
WHERE formname = gv_footer3
AND formtype = 'T'.

IF sy-subrc <> '0'.
*   Footer 3 - Prefix + No.
CONCATENATE lv_txfus '3' INTO gv_footer3.
SELECT SINGLE formname FROM stxfadm INTO lv_formname
WHERE formname = gv_footer3
AND formtype = 'T'.
IF sy-subrc <> '0'.
CLEAR: gv_footer3.
ENDIF.
ENDIF.

* Footer 4 - Prefix + No. + Purchasing Org.
CONCATENATE lv_txfus '4_' is_ekko-ekorg INTO gv_footer4.
SELECT SINGLE formname FROM stxfadm INTO lv_formname
WHERE formname = gv_footer4
AND formtype = 'T'.

IF sy-subrc <> '0'.
*   Footer 4 - Prefix + No.
CONCATENATE lv_txfus '4' INTO gv_footer4.
SELECT SINGLE formname FROM stxfadm INTO lv_formname
WHERE formname = gv_footer4
AND formtype = 'T'.
IF sy-subrc <> '0'.
CLEAR: gv_footer4.
ENDIF.
ENDIF.

ENDIF.

*formatting settings of the langauge environment
SELECT SINGLE land1 FROM lfa1 INTO h_land
WHERE lifnr = is_ekko-lifnr.
*
SET COUNTRY h_land.

