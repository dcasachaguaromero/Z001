REFRESH gt_fpltdr.
CALL FUNCTION 'BILLING_SCHED_PRINTVIEW_READ'
EXPORTING
i_fplnr    = <fs>-fplnr
i_language = gv_language
i_vbeln    = is_vbdka-vbeln
TABLES
zfpltdr    = gt_fpltdr.

























