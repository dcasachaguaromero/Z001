DATA l_ekpo LIKE ekpo.
DATA ls_komk TYPE komk.
DATA ls_komp TYPE komp.
*  DATA lt_komv TYPE STANDARD TABLE OF komv.

REFRESH gt_komvd.

IF <fs>-uebpo NE space.
EXIT.
ENDIF.


REFRESH gt_komvd.
CHECK is_ekko-knumv NE space.
CHECK <fs>-netpr NE 0.
CHECK <fs>-prsdr NE space.
CLEAR ls_komp.

ls_komk-mandt = is_ekko-mandt.
IF is_ekko-kalsm NE space.
ls_komk-kalsm = is_ekko-kalsm.
ELSE.
ls_komk-kalsm = 'RM0000'.
ENDIF.
ls_komk-kappl = 'M'.
ls_komk-waerk = is_ekko-waers.
ls_komk-knumv = is_ekko-knumv.
ls_komk-lifnr = is_ekko-lifnr.       "WDUK

ls_komp-kposn = <fs>-ebelp.
ls_komp-matnr = <fs>-matnr.
ls_komp-werks = <fs>-werks.
ls_komp-matkl = <fs>-matkl.
ls_komp-infnr = <fs>-infnr.
ls_komp-evrtn = <fs>-konnr.
ls_komp-evrtp = <fs>-ktpnr.
ls_komp-mglme = <fs>-menge.

IF <fs>-meins NE <fs>-bprme.
IF <fs>-bpumn NE 0.
ls_komp-mgame = ls_komp-mglme * <fs>-bpumz / <fs>-bpumn.
ELSE.
ls_komp-mgame = ls_komp-mglme.
ENDIF.
ls_komp-umvkz = <fs>-bpumz.
ls_komp-umvkn = <fs>-bpumn.
ls_komp-vrkme = <fs>-bprme.
ELSE.
ls_komp-mgame = ls_komp-mglme.
ls_komp-vrkme = <fs>-bprme.
ENDIF.
ls_komp-meins = <fs>-lmein.
ls_komp-lgumz = <fs>-umrez.
ls_komp-lgumn = <fs>-umren.
ls_komp-lagme = <fs>-meins.
ls_komp-kursk = is_ekko-wkurs.
ls_komp-ix_komk = 1.

CALL FUNCTION 'RV_PRICE_PRINT_ITEM'
EXPORTING
comm_head_i = ls_komk
comm_item_i = ls_komp
language    = gv_language
IMPORTING
comm_head_e = ls_komk
comm_item_e = ls_komp
TABLES
tkomv       = gt_komv
tkomvd      = gt_komvd.


























