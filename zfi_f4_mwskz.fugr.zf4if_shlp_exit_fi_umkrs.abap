FUNCTION ZF4IF_SHLP_EXIT_FI_UMKRS.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"--------------------------------------------------------------------

* Search help exit function module for search help FI_UMKRS
* Display the name of the tax group in the list.

  DATA:
    wa_fielddescr TYPE dfies,
    wa_fieldprop TYPE ddshfprop,
    ls_addr1_sel TYPE addr1_sel,
    ls_addr1_val TYPE addr1_val,
    ld_adrnr TYPE adrnr,
    ld_name1 TYPE ad_name1,
    ld_tbukrs TYPE fot_tbukrs,
    ld_adrnr_off TYPE doffset,
    ld_adrnr_len TYPE ddleng,
    ld_name1_off TYPE doffset,
    ld_name1_len TYPE ddleng,
    ld_tbukrs_off TYPE doffset,
    ld_tbukrs_len TYPE ddleng,
    ld_have_tbukrs TYPE xfeld.


  CHECK callcontrol-step = 'DISP'.

* Get positions and length of fields used in record_tab
  LOOP AT shlp-fielddescr INTO wa_fielddescr
       WHERE fieldname = 'ADRNR '
          OR fieldname = 'NAME1 '
          OR fieldname = 'TBUKRS '.
    CASE wa_fielddescr-fieldname.
      WHEN 'ADRNR '.
        ld_adrnr_off = wa_fielddescr-offset.
        ld_adrnr_len = wa_fielddescr-leng.
      WHEN 'NAME1 '.
        ld_name1_off = wa_fielddescr-offset.
        ld_name1_len = wa_fielddescr-leng.
      WHEN 'TBUKRS '.
        ld_tbukrs_off = wa_fielddescr-offset.
        ld_tbukrs_len = wa_fielddescr-leng.
    ENDCASE.
  ENDLOOP.

  CHECK:
    NOT ld_adrnr_off IS INITIAL,
    NOT ld_adrnr_len IS INITIAL,
    NOT ld_name1_off IS INITIAL,
    NOT ld_name1_len IS INITIAL.


* Get address data of tax group and put it into record_tab
  LOOP AT record_tab.

    ld_adrnr = record_tab-string+ld_adrnr_off(ld_adrnr_len).
    IF NOT ld_adrnr IS INITIAL.
      CLEAR ls_addr1_sel.
      ls_addr1_sel-addrnumber = ld_adrnr.

      CALL FUNCTION 'ADDR_GET'
        EXPORTING
          address_selection = ls_addr1_sel
          address_group     = 'CA01'
        IMPORTING
          address_value     = ls_addr1_val
        EXCEPTIONS
          address_not_exist = 1
          OTHERS            = 2.
      IF sy-subrc = 0.

        ld_name1 = ls_addr1_val-name1.
        record_tab-string+ld_name1_off(ld_name1_len) = ld_name1.
        MODIFY record_tab.

      ENDIF.
    ENDIF.

    IF NOT ld_tbukrs_off IS INITIAL
       AND NOT ld_tbukrs_len IS INITIAL.
      ld_tbukrs = record_tab-string+ld_tbukrs_off(ld_tbukrs_len).
      IF NOT ld_tbukrs IS INITIAL.
        ld_have_tbukrs = 'X'.
      ENDIF.
    ENDIF.

  ENDLOOP.

* Eliminate column TBUKRS if empty
  IF ld_have_tbukrs IS INITIAL.
    LOOP AT shlp-fieldprop INTO wa_fieldprop
         WHERE fieldname = 'TBUKRS '.
      wa_fieldprop-shlplispos = 0.
      MODIFY shlp-fieldprop FROM wa_fieldprop
             TRANSPORTING shlplispos.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
