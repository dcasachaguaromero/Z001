FUNCTION ZFIRFC_B005.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(TI_IN) TYPE  ZICOMPET
*"  EXPORTING
*"     VALUE(TI_OUT) TYPE  ZOCOMPET
*"----------------------------------------------------------------------
data fecha_doc TYPE d.
data fecha_c(8) TYPE c.
data wa_out LIKE LINE OF ti_out.
data wa_in LIKE LINE OF ti_in.
LOOP AT ti_in into wa_in.
  fecha_c = wa_in-lifnr+2(8)  .


  condense fecha_c  NO-GAPS.
  fecha_doc = fecha_c .

  IF wa_in-GKOAR_I eq 'K' .
    SELECT single * from bsik INTO CORRESPONDING FIELDS OF wa_out
      where bukrs = wa_in-bukrs
            and lifnr = wa_in-lifnr
            and blart = wa_in-blart
            and gjahr = wa_in-gjahr
            and xblnr = wa_in-xblnr.
    wa_out-estado = 'P'.
    APPEND wa_out to ti_out.
  ENDIF.
  IF wa_in-GKOAR_I eq 'C' .
       SELECT single * from bkpf INTO CORRESPONDING FIELDS OF wa_out
       where    bukrs     = wa_in-bukrs
            and BLDAT     = fecha_doc
            and blart     = wa_in-blart
            and gjahr     = wa_in-gjahr
            and xblnr     = wa_in-xblnr.
    wa_out-estado = 'P'.
    APPEND wa_out to ti_out.
  ENDIF.
ENDLOOP.

ENDFUNCTION.
