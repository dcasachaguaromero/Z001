function ZFI_DOCUMENT_CROSS_COMP_DISPLA.
*"--------------------------------------------------------------------
*"*"Interfase global
*"  IMPORTING
*"     VALUE(BVORG) LIKE  BVOR-BVORG
*"     VALUE(AKTYP) LIKE  T020-AKTYP DEFAULT 'A'
*"     VALUE(XEPOS) LIKE  BOOLE-BOOLE OPTIONAL
*"     VALUE(XPRNT) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(E_CMRQ) LIKE  BOOLE-BOOLE
*"     VALUE(E_CHNG) LIKE  BOOLE-BOOLE
*"  EXCEPTIONS
*"      DISPLAY_NOT_POSSIBLE
*"--------------------------------------------------------------------
  clear: e_cmrq, e_chng.
    if not xprnt is initial.
    MESSAGE S286(F5A).
*   Vorschau zum Drucken eines Buchhaltungsbelegs.
    endif.
perform init using aktyp xepos.
  status = 'H'.
  perform read_cross_company_documents using bvorg.
  perform define_structures_cc_display.
  perform feldkatalog_bseg.
  perform prepare_cross_company_display.
  perform cross_company_list_display.
  e_cmrq = comreq.
  e_chng = xchng.
* We don't provide an internal buffering of display variants for
* cross company display at the moment, therefore:
 clear variant_fix.                                          "Note448932
endfunction.
