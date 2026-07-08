*flagged out because not used


*DATA ls_komk TYPE komk.

CLEAR gs_komk.
CLEAR gt_komvd[].
*GV_tax = 0.

*IF is_pekko-prsdr EQ space.
*  EXIT.
*ENDIF.


*ls_komk-mandt = is_ekko-mandt.
*IF is_ekko-kalsm NE space.
*  ls_komk-kalsm = is_ekko-kalsm.
*ELSE.
*  ls_komk-kalsm = 'RM0000'.
*ENDIF.
*ls_komk-kappl = 'M'.
*ls_komk-waerk = is_ekko-waers.
*ls_komk-knumv = is_ekko-knumv.
*ls_komk-bukrs = is_ekko-bukrs.
*ls_komk-lifnr = is_ekko-lifnr.
*CALL FUNCTION 'RV_PRICE_PRINT_HEAD'
*  EXPORTING
*    comm_head_i = ls_komk
*    language    = gv_language
*  IMPORTING
*    comm_head_e = gs_komk
*  TABLES
*    tkomv       = gt_komv
*    tkomvd      = gt_komvd.


