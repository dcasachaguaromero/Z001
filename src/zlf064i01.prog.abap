*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LF064I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  DAUERBUCHUNG_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module dauerbuchung_pruefen input.
  if bkdf-dbakz ne space
  and ( rf05l-dbtag ne space
        or bkdf-dbmon ne space ).
    message e447(f5).
  endif.
  if bkdf-dbakz = space
  and rf05l-dbtag = space
  and bkdf-dbmon = space.
    message e447(f5).
  endif.
  if bkdf-dbmon ne space
  and rf05l-dbtag = space.
    message e448(f5).
  endif.
  if bkdf-dbmon = space
  and rf05l-dbtag ne space.
    message e449(f5).
  endif.

*------- Abrechnungstermin geaendert ? ---------------------------------
  if rf05l-dbatr ne bkdf-dbatr.
    if bkdf-dbatr(6) > rf05l-dbatr(6).
      message w330(f5).
    endif.
  else.

*------- Tag geaendert ? -----------------------------------------------
    if rf05l-dbtag ne bkdf-dbtag
    and rf05l-dbtag ne space
    and rf05l-dbatr = bkdf-dbatr.
*     RF05L-DBATR+6(2) = RF05L-DBTAG.
      message w331(f5).
    endif.
  endif.
  if rf05l-dbatr > bkdf-dbedt and bkdf-xdelt ne c_x.
    message e317(f5).
  endif.
  if rf05l-dbatr < bkdf-dbbdt.
    message e434(f5).
  endif.
  if rf05l-dbatr(6) < sy-datlo(6) and bkdf-xdelt ne c_x.
    call function 'FI_PERIOD_DETERMINE'
      exporting
        i_budat = rf05l-dbatr
        i_bukrs = t001-bukrs
      importing
        e_gjahr = xbkpf-gjahr
        e_monat = xbkpf-monat.
    frpe1 = xbkpf-monat.
    call function 'FI_PERIOD_CHECK'
      exporting
        i_bukrs = t001-bukrs
        i_koart = '+'
        i_gjahr = xbkpf-gjahr
        i_monat = frpe1
      exceptions
        others  = 4.
    if sy-subrc ne 0.
      message e454(f5).                "Buper f. Beg.Dat nicht erlaubt
    endif.
    message w318(f5).
  endif.
  bkdf-dbtag = rf05l-dbtag.
  bkdf-dbatr = rf05l-dbatr.

endmodule.                             " DAUERBUCHUNG_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  D0101_OKCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d0101_okcode input.
  if ok-code = 'ENTR'.
    ok-code = space.
  endif.
  if ok-code ne 'AE'
  and g_aktyp = c_aktyp_change.
    if bkdf-xdelt = c_x.
      message w433(f5).
    endif.
  endif.

*------- OK-Code Verarbeitung ----------------------------------------*
  case ok-code.

*------- Keine Eingabe -----------------------------------------------*
    when space.
*     if g_aktyp = c_aktyp_change.
*      and status-anzeige = space.
*       select single * from bkdf into *bkdf
*         where bukrs = bkdf-bukrs
*         and   belnr = bkdf-belnr
*         and   gjahr = bkdf-gjahr.
*       if bkdf ne *bkdf.
*         call function 'POPUP_TO_CONFIRM_STEP'
*              exporting
*                   titel         = 'Beleg ändern'(021)
*                   textline1     = 'Sollen die Änderungen'(022)
*                   textline2     = 'gesichert werden ?'(023)
*                   defaultoption = c_yes
*              importing
*                   answer        = char(1).
*         if char(1) = c_a.
*           set screen sy-dynnr.
*           leave screen.
*         elseif char(1) = c_yes.
*           ok-code = 'AE'.
*           perform update_bkdf.
*           comreq = c_x.
*           xchng = c_x.
*           message s300(f5).
*         else.
*           ok-code = space.
*         endif.
*       endif.
*     endif.
      set screen 0.
      leave screen.

*-- change of recurring document data not possible yet:
    when 'AE'.
*     if g_aktyp ne c_aktyp_change.
      message e222 with ok-code.
*     endif.
*     perform update_bkdf.
*     comreq = c_x.
*     xchng = c_x.
*     message s300(f5).
*     set screen 0.
*     leave screen.

  endcase.
  ok-code = space.

endmodule.                             " D0101_OKCODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  D0101_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d0101_exit input.
  clear ok-code.
  set screen 0.
  leave screen.
endmodule.                             " D0101_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  XBLNR_MUSSFELD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module xblnr_mussfeld input.
  check g_aktyp = 'V'.

*-------------- XBLNR = Mußfeld ? --------------------------------------
  check t003-xmref ne space
    and bkpf-xblnr eq space.
  bkpf-xblnr = old_xblnr.
  message e480(f5) with bkpf-blart text-xbl.
endmodule.                             " XBLNR_MUSSFELD  INPUT
*&---------------------------------------------------------------------*
*&      Module  BKTXT_MUSSFELD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module bktxt_mussfeld input.
  check g_aktyp = 'V'.
  check t003-xmtxt ne space
    and bkpf-bktxt eq space.
  bkpf-bktxt = old_bktxt.
  message e480(f5) with bkpf-blart text-bkt.
endmodule.                             " BKTXT_MUSSFELD  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_STODT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module check_stodt input.
  if bkpf-budat > bkpf-stodt
  and not bkpf-stodt is initial.
    message e601(f5).
  endif.
  if bkpf-stodt is initial.
    clear bkpf-xstov.
    message w602(f5).
  else.
    bkpf-xstov = 'X'.
  endif.
endmodule.                             " CHECK_STODT  INPUT
*&---------------------------------------------------------------------*
*&      Module  KOPF_AENDERN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module kopf_aendern input.
  if g_aktyp = 'V'.
    perform substitution_kopf(sapff011) using bkpf.
    perform validation_kopf(sapff011) using bkpf.
  endif.
endmodule.                             " KOPF_AENDERN  INPUT
*&---------------------------------------------------------------------*
*&      Module  REFERENZ_AENDERUNG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module referenz_aenderung input.
  check g_aktyp = 'V'.
  check bkpf-awtyp = 'VBRK '.
  call function 'CUSTOMIZED_MESSAGE'
    exporting
      i_arbgb = 'F5'
      i_dtype = 'W'
      i_msgnr = '872'
    exceptions
      others  = 1.
endmodule.                             " REFERENZ_AENDERUNG  INPUT
*&---------------------------------------------------------------------*
*&      Module  KOPF_OKCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module kopf_okcode input.
  if ok-code = space or ok-code = 'ENTR'.
    ok-code = space.
  endif.

  case ok-code.
    when space.
*     if g_aktyp = c_aktyp_change.
*       select single * from bkpf into *bkpf where bukrs = bkpf-bukrs
*              and belnr = bkpf-belnr and gjahr = bkpf-gjahr.
*       if bkpf ne *bkpf.
*         call function 'POPUP_TO_CONFIRM_STEP'
*              exporting
*                   titel         = 'Beleg ändern'(021)
*                   textline1     = 'Sollen die Änderungen'(022)
*                   textline2     = 'gesichert werden ?'(023)
*                   defaultoption = c_yes
*              importing
*                   answer        = char(1).
*         if char(1) = c_a.
*           set screen sy-dynnr.
*           leave screen.
*         elseif char(1) = c_yes.
*           ok-code = 'AE'.
*           perform update_bkpf.
*           comreq = c_x.
*           xchng = c_x.
*           message s300(f5).
*         else.
*          ok-code = space.
*         endif.
*       endif.
*     endif.
      set screen 0.
      leave screen.

*-- Beleg Aendern -----------------------------------------------------
    when 'AE'.
* change of document header data not yet possible:
*     if g_aktyp ne c_aktyp_change.
      message e222 with ok-code.
*     endif.
*     perform update_bkpf.
*     comreq = c_x.
*     xchng = c_x.
*     message s300(f5).
      set screen 0.
      leave screen.

    when 'DETA'.                                           "Note 369284
      get cursor field csline.                             "Note 369284
      if csline = 'BKPF-STBLG'                             "Note 369284
      or csline = 'BKPF-STJAH'.                            "Note 369284
        set parameter: id 'BUK' field bkpf-bukrs,          "Note 369284
                       id 'BLN' field bkpf-stblg,          "Note 369284
                       id 'GJR' field bkpf-stjah.          "Note 369284
        call transaction 'FB03' and skip first screen.     "Note 369284
        set parameter: id 'BUK' field bkpf-bukrs,          "Note 369284
                       id 'BLN' field bkpf-belnr,          "Note 369284
                       id 'GJR' field bkpf-gjahr.          "Note 369284
        endif.
      if csline = 'BKPF-AWKEY'.                        "Note 505521
        perform record_sender.
      else.
        message s315(f4).                                  "Note 369284
      endif.                                               "Note 369284
  endcase.
  ok-code = space.
endmodule.                             " KOPF_OKCODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module exit input.
  set screen 0.
  leave screen.
endmodule.                             " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  BUKRS_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module bukrs_pruefen input.
  perform buchungskreis_lesen(sapff001) using rf05l-bukrs.
endmodule.                             " BUKRS_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  BELEG_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module beleg_pruefen input.
  data: ibkpf type bkpf.
  perform alphaformat(sapfs000) using rf05l-belnr rf05l-belnr.

  if rf05l-belnr = space.
    message e279.
  endif.
*
* Note 486975
*  if rf05l-gjahr is initial.
*    get parameter id 'GJR' field rf05l-gjahr.
*  endif.

  perform beleg_lesen using rf05l-belnr rf05l-bukrs rf05l-gjahr.

  if sy-tcode(3) = 'FBD'.
    perform read_*bkdf(sapff011) using rcode
    rf05l-bukrs rf05l-belnr rf05l-gjahr.
    if rcode ne 0.
      message e432 with rf05l-bukrs rf05l-belnr rf05l-gjahr.
    endif.
  endif.

*-------- Initialize object services --------------------- "Note 306170
  call function 'SWU_OBJECT_REFRESH'.

*-------- Generischer Objektservice für ges. Beleg ---------------------
  perform gen_obj_serv(sapmf05l) using 'P' 'BKPF' bkpf-awkey
                                                  bkpf-awsys bkpf-awtyp.
  if not bkpf-ppnam is initial.                            "Note 217657
    perform gen_obj_serv(sapmf05l) using 'P' 'FIPP'        "Note 217657
                                         bkpf-awkey        "Note 217657
                                         bkpf-awsys        "Note 217657
                                         bkpf-awtyp.       "Note 217657
  endif.                                                   "Note 217657

* Objektservices für Ursprungsbeleg ermöglichen
  perform gen_obj_serv(sapmf05l) using 'P' bkpf-awtyp bkpf-awkey
                                           bkpf-awsys bkpf-awtyp.
  perform gen_obj_serv(sapmf05l) using 'P' 'ACCTGDOCMT' bkpf-awkey
                                           bkpf-awsys bkpf-awtyp.
endmodule.                             " BELEG_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  D1110_OKCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d1110_okcode input.
  set screen 0.
  leave screen.
endmodule.                             " D1110_OKCODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  D1110_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d1110_exit input.
  g_exit = c_x.
  set screen 0.
  leave screen.
endmodule.                             " D1110_EXIT  INPUT
* Begin of ALRK225335
*&---------------------------------------------------------------------*
*&      Module  D1120_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d1120_exit input.
  set screen 0.
  leave screen.
endmodule.                             " D1120_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  D1120_OKCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d1120_okcode input.
  d1120_okcode = ok-code.
  clear: ok-code.
  case d1120_okcode.
    when 'ENTR'.
    when 'REVS'.
      xrevs = 'X'.
      set screen 0.
      leave screen.
    when others.
  endcase.
endmodule.                             " D1120_OKCODE  INPUT
*&---------------------------------------------------------------------*
*&      Module  PROCESS_STGRD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module d1120_read_text output.
  if uf05a-stgrd is initial.
    get parameter id 'FSG' field uf05a-stgrd.
  endif.
  if bsis-budat is initial.
    get parameter id 'DTS' field bsis-budat.
  endif.
  if not uf05a-stgrd is initial and
    uf05a-stgrd ne t041ct-stgrd.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single * from t041ct
*      where spras = sy-langu
*        and stgrd = uf05a-stgrd.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  from t041ct
      where spras = sy-langu
        and stgrd = uf05a-stgrd ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    if sy-subrc ne 0.
      clear t041ct.
    endif.
  endif.
  if not rf05a-voidr is initial and
  rf05a-voidr ne tvoit-voidr.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single * from tvoit
*      where langu = sy-langu
*        and voidr = rf05a-voidr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  from tvoit
      where langu = sy-langu
        and voidr = rf05a-voidr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    if sy-subrc ne 0.
      clear tvoit.
    endif.
  endif.
endmodule.                             " PROCESS_STGRD  INPUT
* End of ALRK225335
