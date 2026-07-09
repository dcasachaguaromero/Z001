FUNCTION ZFI_F4_FPFORM_ASLM.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"--------------------------------------------------------------------

* Search help exit function module for search help HFPFORM_ASLM
* Display the name of the tax group in the list.

  DATA:
    wa_fielddescr TYPE dfies,
    wa_selopt TYPE ddshselopt,
    ld_name TYPE fpname,
    ld_description TYPE fptext,
    ld_state TYPE fpstate,
    ld_name_off TYPE doffset,
    ld_name_len TYPE ddleng,
    ld_description_off TYPE doffset,
    ld_description_len TYPE ddleng,
    ld_state_off TYPE doffset,
    ld_state_len TYPE ddleng.

  CONSTANTS:
    lc_interface TYPE fpname VALUE 'FI_F_ASL_DE'.

  IF callcontrol-step = 'SELECT'.
    wa_selopt-shlpname  = 'FPCONTEXT'.
    wa_selopt-shlpfield = 'INTERFACE'.
    wa_selopt-sign      = 'I'.
    wa_selopt-option    = 'EQ'.
    wa_selopt-low       = lc_interface.
    wa_selopt-high      = space.
    APPEND wa_selopt TO shlp-selopt.
  ENDIF.

  CHECK callcontrol-step = 'DISP'.

* Get positions and length of fields used in record_tab
  LOOP AT shlp-fielddescr INTO wa_fielddescr
       WHERE fieldname = 'NAME '
          OR fieldname = 'DESCRIPTION '
          OR fieldname = 'STATE '.
    CASE wa_fielddescr-fieldname.
      WHEN 'NAME '.
        ld_name_off = wa_fielddescr-offset.
        ld_name_len = wa_fielddescr-leng.
      WHEN 'DESCRIPTION '.
        ld_description_off = wa_fielddescr-offset.
        ld_description_len = wa_fielddescr-leng.
      WHEN 'STATE '.
        ld_state_off = wa_fielddescr-offset.
        ld_state_len = wa_fielddescr-leng.
    ENDCASE.
  ENDLOOP.

  CHECK:
    NOT ld_name_len IS INITIAL,
    NOT ld_description_len IS INITIAL,
    NOT ld_state_len IS INITIAL.


* Get address data of tax group and put it into record_tab
  LOOP AT record_tab.

    ld_name  = record_tab-string+ld_name_off(ld_name_len).
    ld_state = record_tab-string+ld_state_off(ld_state_len).

    IF ld_name IS INITIAL  OR
       NOT ld_state = 'A'.
      DELETE record_tab.
      CONTINUE.
    ENDIF.

    TRY.
        ld_description
           = cl_fp_wb_helper=>form_description( ld_name ).
      CATCH cx_fp_api.
        CLEAR ld_description.
    ENDTRY.
    record_tab-string+ld_description_off(ld_description_len)
      = ld_description.
    MODIFY record_tab.

  ENDLOOP.


ENDFUNCTION.
