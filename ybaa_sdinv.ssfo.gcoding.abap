* set textnames for header, adress and footer
PERFORM get_textname USING    is_bil_invoice-hd_gen-bil_number
is_bil_invoice-hd_org-salesorg
CHANGING gf_txnam_adr
gf_txnam_kop
gf_txnam_fus
gf_txnam_gru
gf_txnam_sdb.

* object text name
*GF_TDNAME = IS_BIL_INVOICE-HD_GEN-BIL_NUMBER.

*--------------------------------------------------------
*    judge
*--------------------------------------------------------
PERFORM judge_diff USING     is_bil_invoice
CHANGING  gv_reford_diff
gv_refdlv_diff
gv_refpurord_diff.

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
*WHERE vkorg = is_bil_invoice-hd_org-salesorg.
*
* NEW CODE
SELECT txnam_adr txnam_kop txnam_fus txnam_gru
UP TO 1 ROWS 
FROM tvko INTO (lv_txnam_adr,
lv_txnam_kop,
lv_txnam_fus,
lv_txnam_gru )
WHERE vkorg = is_bil_invoice-hd_org-salesorg ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc = '0'.

* Sender
gv_sender = lv_txnam_adr.

* Header
gv_header = lv_txnam_kop.

* Footer 1 - Prefix + No. + Sales Org.
CONCATENATE lv_txnam_fus '1_' is_bil_invoice-hd_org-salesorg INTO gv_footer1.
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
CONCATENATE lv_txnam_fus '2_' is_bil_invoice-hd_org-salesorg INTO gv_footer2.
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
CONCATENATE lv_txnam_fus '3_' is_bil_invoice-hd_org-salesorg INTO gv_footer3.
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
CONCATENATE lv_txnam_fus '4_' is_bil_invoice-hd_org-salesorg INTO gv_footer4.
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
CLEAR: gs_hd_adr, h_kunnr.
*
READ TABLE is_bil_invoice-hd_adr INTO gs_hd_adr
WITH KEY bil_number = is_bil_invoice-hd_gen-bil_number
partn_role = 'RE'.
h_kunnr = gs_hd_adr-partn_numb.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE land1 FROM kna1 INTO h_land
*WHERE kunnr = h_kunnr.
*
* NEW CODE
SELECT land1
UP TO 1 ROWS  FROM kna1 INTO h_land
WHERE kunnr = h_kunnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
SET COUNTRY h_land.



