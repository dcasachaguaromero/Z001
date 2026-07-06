*----------------------------------------------------------------------*
***INCLUDE LF064F01 .
*** Forms für externe Aufrufe aus REUSE_ALV_LIST_DISPLAY
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS_SET
*&---------------------------------------------------------------------*
form pf_status_set using rtr_exctab type slis_t_extab.      "#EC CALLED
  data: l_tcode like sy-tcode,                             "Note 323188
        l_subrc like sy-subrc.                             "Note 323188
  tables: qisrpcrtype_scen.            "posting correction request

  data: exc type slis_extab.
  data: l_exctab type table of excltab_line                "Note 361420
                 with header line.                         "Note 361420
  data: l_parked type xfeld.                               "Note 361420

*----------- Call from posting transaction ? ---------------------------
*----------- Regard item display in Fb05 ----------------- "Note 302995
* (del) if t020-aktyp = 'H'.                               "Note 302995
  if t020-aktyp = c_h and t020-dyncl ne c_z.               "Note 302995

*------- build up exctab to determine 'grey' menu options

*------- error messages ?

    describe table terrinf lines sy-tfill.
    if sy-tfill = 0.
      exc-fcode = 'LOG'.
      collect exc into rtr_exctab.
    else.
      message i047(f5a).
      loop at terrinf                                      "Note 328206
        where type cn 'IS'.                                "Note 328206
        exit.                                              "Note 328206
      endloop.                                             "Note 328206
      if sy-subrc is initial.                              "Note 328206
        exc-fcode = 'BU'.
        collect exc into rtr_exctab.
      endif.                                               "Note 328206
    endif.


*------- posting not allowed in workflow

    if x_posting_forbidden = c_x.                          "Note 308896
      exc-fcode = 'BU'.                                    "Note 308896
      collect exc into rtr_exctab.                         "Note 308896
    endif.                                                 "Note 308896

*------- Parking not allowed due to authorization --------- "Note449741
    if x_parking_forbidden = c_x.                           "Note449741
      exc-fcode = 'BP'.                                     "Note449741
      collect exc into rtr_exctab.                          "Note449741
      exc-fcode = 'PBBP'.                                   "Note449741
      collect exc into rtr_exctab.                          "Note449741
    else.                                                   "Note449741
      if rfopt2-xcmpl = c_x.                                "Note449741
        exc-fcode = 'BP'.                                   "Note449741
        collect exc into rtr_exctab.                        "Note449741
      endif.                                                "Note449741
    endif.                                                  "Note449741

*------- Open FI in enjoy transactions ------------------- "Note 361420
    if g_document_exists = c_x.                            "Note 361420
      l_parked = c_x.                                      "Note 361420
    endif.                                                 "Note 361420
    call function 'OPEN_FI_PERFORM_00001140_E'             "Note 361420
      exporting                                            "Note 361420
        i_parked = l_parked                                "Note 361420
      tables                                               "Note 361420
        t_bkpf   = xbkpf                                   "Note 361420
        t_bseg   = archbseg                                "Note 565919
        t_exctab = l_exctab.                               "Note 361420
    loop at l_exctab.                                      "Note 361420
      exc = l_exctab-okcod.                                "Note 361420
      collect exc into rtr_exctab.                         "Note 361420
    endloop.                                               "Note 361420

*------ 'save' (='park') in document parking

    if t020-dyncl = c_v.                                   "Note 335913
      set pf-status 'STD_SIMU_PP' excluding rtr_exctab.    "Note 335913
    else.                                                  "Note 335913
      set pf-status 'STD_SIMU' excluding rtr_exctab.
    endif.                                                 "Note 335913
    set titlebar 'H01'.
    exit.
  endif.

*------- check for transaction code authority ( Note 323188 )

  if t020-aktyp = c_v.
    l_tcode = 'FB02'.
  else.
    l_tcode = 'FB03'.
  endif.
  if bkpf-bstat ca 'DM'.
    l_tcode+2(1) = bkpf-bstat.
  endif.
  perform check_tcode_auth using l_tcode l_subrc.
  if l_subrc ne 0.
    exc-fcode = 'NB'.
    collect exc into rtr_exctab.
  endif.

*------- 'payment usage' for all kinds of clearing documents

  if  bkpf-tcode    ne 'F110'
  and bkpf-tcode    ne 'F111'
  and bkpf-tcode(3) ne 'FBZ'
  and bkpf-tcode    ne 'FB05'
  and bkpf-tcode    ne 'FB1K'
  and bkpf-tcode    ne 'FB1D'
  and bkpf-tcode    ne 'FB1S'
  and bkpf-tcode    ne 'FBW2'                              "Note 0409904
  and bkpf-tcode    ne 'FBW4'                              "Note 0409904
  AND bkpf-tcode    NE 'FBA3'                              "Note 1121799
  AND bkpf-tcode    NE 'FBA8'                              "Note 1121799
  and bkpf-bstat    ne  c_a
  or  bkpf-bstat    = c_b.
    exc-fcode = 'EPOS'.
    collect exc into rtr_exctab.
    exc-fcode = 'AU'.
    collect exc into rtr_exctab.
  endif.

*----------------------------------------------------------------------
* Cancellation of documents
*----------------------------------------------------------------------
*----------------------------------------------------------------------
* No Reversal for already deleted (parked) documents
*----------------------------------------------------------------------

  if bkpf-bstat ca 'WZ'.
    exc-fcode = 'REVS'.
    collect exc into rtr_exctab.
  endif.

  if bkpf-bstat is initial or bkpf-bstat = c_s.

*----------------------------------------------------------------------
* No reversal, if already reversed, archived, cross-company document
* or drill-down from line item list FBLxy.
*----------------------------------------------------------------------
    perform check_if_archived using bkpf-bukrs bkpf-belnr
                                    bkpf-gjahr rcode.
    if not bkpf-stblg is initial or
       not bkpf-bvorg is initial or
       x_nochange = c_x or
       epos = c_x or
       rcode ne 0.
      exc-fcode = 'REVS'.
      collect exc into rtr_exctab.
    else.
*----------------------------------------------------------------------
* No reversal if user lacks authorization for FB08.
*----------------------------------------------------------------------
      perform check_tcode_auth using 'FB08' l_subrc.
      if l_subrc ne 0.
        exc-fcode = 'REVS'.
        collect exc into rtr_exctab.
      else.
*----------------------------------------------------------------------
* No reversal if document stems from an application other
* than FI or if it is an ALE document (Note 454907).
*----------------------------------------------------------------------
        call function 'FI_REVERSE_POSTING_ALLOWED'
          exporting
            i_awtyp                 = bkpf-awtyp
            i_glvor                 = bkpf-glvor
            i_awkey                 = bkpf-awkey
            i_awsys                 = bkpf-awsys
*           I_LOGSYS                = T000-LOGSYS
            i_tcode                 = bkpf-tcode
*           I_REVDOC                = FIREVDOC-BELNR
          exceptions
            no_fi_reversal           = 4
            ale_reversal_prohibited  = 8
            add_component_prohibited = 16.

        if sy-subrc ne 0.
          exc-fcode = 'REVS'.
          collect exc into rtr_exctab.
        else.
* ---------------------------------------------------------------------
* No Reversal if document contains cleared items
* ---------------------------------------------------------------------
          loop at xbseg.
            if  xbseg-augbl    ne space
            and xbseg-augbl(4) ne 'ALE-'.
              exc-fcode = 'REVS'.
              collect exc into rtr_exctab.
              exit.
            endif.
          endloop.
        endif.
      endif.
    endif.

*----------------------------------------------------------------------
* No changes allowed
*----------------------------------------------------------------------

    if x_nochange = c_x or g_aktyp = c_v.                   "Note 568251
      exc-fcode = 'CHGL'.                                  "Note 302995
      collect exc into rtr_exctab.                         "Note 302995
    endif.                                                 "Note 302995

*----------------------------------------------------------------------
* Posting correction request
*----------------------------------------------------------------------

    select single * from qisrpcrtype_scen where doctype = 'FI-GL'.
    if qisrpcrtype_scen-active = space.
      exc-fcode = 'CORR'.
      collect exc into rtr_exctab.
    endif.
  endif.

*------- balance sheet adjustment                   begin of note 423937

  if bkpf-bstat is initial.
*   no bs adjustment infos available for archived documents
    perform check_if_archived using bkpf-bukrs bkpf-belnr
                                    bkpf-gjahr rcode.
    if not rcode is initial.
      exc-fcode = 'ZAUF'.          " why not as constant
      collect exc into rtr_exctab.
    endif.
  endif.
*                                                     end of note 423937

*----- Check information display for payments only --------------------*
  IF XZLBLG NE 'X'.                                         "Note1139298
    EXC-FCODE = 'ZBLG'.                                     "Note1139298
    COLLECT EXC INTO RTR_EXCTAB.                            "Note1139298
  ENDIF.                                                    "Note1139298

*-------- Other document....? (Note 560107)
  get parameter id 'NO_DOCU_EXCHANGE' field no_docu_exchange.
  if no_docu_exchange = 'X'.
    exc-fcode = 'NB'.
    collect exc into rtr_exctab.
  endif.

*--------- Menu: not all functionalities possible in case of
*          cross-company code (Note 618059)
if status = 'H'.
   exc-fcode = 'ZBLG'.
   collect exc into rtr_exctab.
   exc-fcode = 'ZBEL'.
   collect exc into rtr_exctab.
   exc-fcode = 'ZREC'.
   collect exc into rtr_exctab.
   exc-fcode = 'DRB'.
   collect exc into rtr_exctab.
   exc-fcode = 'KORR'.
   collect exc into rtr_exctab.
   exc-fcode = 'ZAUF'.
   collect exc into rtr_exctab.
   exc-fcode = 'OBAZ'.
   collect exc into rtr_exctab.
   exc-fcode = 'OBLE'.
   collect exc into rtr_exctab.
   exc-fcode = 'VK'.
   collect exc into rtr_exctab.
   exc-fcode = 'TEXT'.
   collect exc into rtr_exctab.
   exc-fcode = 'AU'.
   collect exc into rtr_exctab.
   exc-fcode = 'CORR'.
   collect exc into rtr_exctab.
endif.

*------- choose appropriate GUI status

  if bkpf-bstat is initial or bkpf-bstat = c_s
  or bkpf-bstat = c_l.                                   "ERP05
    set pf-status 'SPECIAL1' excluding rtr_exctab.
  elseif bkpf-bstat = c_d.
    set pf-status 'RECUR_ENTRY_DOC' excluding rtr_exctab.
  elseif bkpf-bstat = c_m.
    set pf-status 'SAMPLE' excluding rtr_exctab.
  elseif bkpf-bstat = c_a or bkpf-bstat = c_b.
    set pf-status 'CLEARING' excluding rtr_exctab.
  else.
    set pf-status 'STANDARD' excluding rtr_exctab.
  endif.

  if status eq 'H'.
    if g_aktyp = c_a.                                     "Note 568251
      set titlebar 'SP2'.
    else.
      set titlebar 'SP3'.
    endif.
  else.
    if g_aktyp = c_a.
      set titlebar 'SP1'.
    else.
      set titlebar 'SP4'.
    endif.
  endif.


endform.                               "PF_STATUS_SET
*&---------------------------------------------------------------------*
*&      Form  KOPF_ANZEIGE
*&---------------------------------------------------------------------*
form kopf_anzeige.
  data _text(80).
*---------------- Anzeige BKPF via Event TOP_OF_PAGE -------------------
  new-line no-scrolling.
  write at (85) sy-uline.
  write at  86  sy-vline.

*------------ header line----------------------------------------------*
  new-line no-scrolling.
  write sy-vline.
  select single * from  t003t
         where  spras       = sy-langu
         and    blart       = bkpf-blart.
  format color col_heading intensified on.
  clear anzst.
  domvalue = bkpf-bstat.
  clear ddtext.
  call function 'FI_CUST_READ_DOMVALUETEXT'
    exporting
      domname         = 'BSTAT'
      domvalue        = domvalue
      spras           = sy-langu
    importing
      ddtext          = ddtext
    exceptions
      text_not_found  = 01
      value_not_found = 02.
  if sy-subrc = 0.
    anzst = ddtext.
  endif.

  concatenate text-045 ':' bkpf-blart '(' t003t-ltext ')' anzst
  into _text separated by space.
  write at 3(83) _text.
  format reset.
  write at 86 sy-vline.
  format reset.

*------------ next line  ----------------------------------------------*
  if not bkpf-ppnam is initial.
    new-line no-scrolling.
    write sy-vline.
    format intensified.
    write at 3(15) 'parked by'(042).
    write at 18 bkpf-ppnam.                                 "Note 455452
    write at 35(15) 'posted by'(044).
    write at 51 bkpf-usnam.                                 "Note 455452
    format reset.
    write at 86 sy-vline.
  endif.

*------------ next line  ----------------------------------------------*
  new-line no-scrolling.
  write sy-vline.
  write at 3(15)  'Belegnummer'(001).
  write at 18(10) bkpf-belnr.
  write at 35(15) 'Buchungskreis'(002).
  write at 51(4)  bkpf-bukrs.
  write at 64(15) 'Geschäftsjahr'(003).
  write at 80(4)  bkpf-gjahr.
  write at 86 sy-vline.

*------------ next line  ----------------------------------------------*
  new-line no-scrolling.
  write sy-vline.
  write at 3(15)  'Belegdatum'(004).
  write at 18(10) bkpf-bldat.
  write at 35(15) 'Buchungsdatum'(005).
  write at 51(10) bkpf-budat.
  write at 64(15) 'Periode'(006).
  write at 80(2)  bkpf-monat.
  write at 86 sy-vline.

*------------ next line  --------------------------------------"705183
  new-line no-scrolling.                                       "705183
  write sy-vline.                                              "705183
  write at 3(15)  'Steuer rechnen'(010).                       "705183
  write at 18      bkpf-Xmwst as checkbox INPUT OFF.           "705183
  if not t001-xvatdate is initial                              "N1023317
  and not bkpf-vatdate is initial.                             "N1023317
    write at 35(15) 'Steuermeldedat.'(011).                    "N1023317
    write at 51(10)  bkpf-vatdate.                             "N1023317
  endif.                                                       "N1023317
  write at 86 sy-vline.                                        "705183

*------------ next line  ----------------------------------------------*
  if  not ( bkpf-bvorg is initial and bkpf-xblnr is initial ).
    new-line no-scrolling.
    write sy-vline.
    write at 3(15)  text-007.          "Reference
    write at 18(16) bkpf-xblnr.
    if not bkpf-bvorg is initial.
      write at 35(15) text-008.        "Cross-company code number
      write at 51(16) bkpf-bvorg hotspot.
    endif.
    write at 86 sy-vline.
  endif.
*------------ next line  ----------------------------------------------*
  new-line no-scrolling.
  write sy-vline.
  write at 3(15)  text-009.            "document currency
  write at 18(16) bkpf-waers.

  if bkpf-stblg ne space.
*------- Reversal document  -------------------------------------------*
    perform reversal_text.
    write at 35(15) rf05l-stotx.
    write at 51(10) bkpf-stblg hotspot.
    write at 62 '/'.
    write: at 64(04) bkpf-stjah hotspot.
  endif.
  write at 86 sy-vline.
*------ Simulation from fb50L show ledgergroup
  if not bkpf-ldgrp is initial.
    new-line no-scrolling.
    write sy-vline.
    write at 3(15)  text-ldr.
    write at 18 bkpf-ldgrp.
    write at 86 sy-vline.
  endif.
*------------ next line  ----------------------------------------------*
  if not bkpf-bktxt is initial.
    new-line no-scrolling.
    write sy-vline.
    if bkpf-tcode(3) ne 'F11'.
      write at 3(15)  text-bkt.        "document header text
      write at 18 bkpf-bktxt.                               "Note407907
    else.
      date = bkpf-bktxt(8).
      write at 3(22)  text-pay.        "payment run id
* Does 'date' really contain a date, or has it been altered by a
*  user exit / open fi ?   (Note 443989)
      if date co '1234567890'.                " seems to be a date....
        write: at 35 date, '-', bkpf-bktxt+9. " format text accordingly
      else.
        write: at 35 bkpf-bktxt.              " don't format the text
      endif.
    endif.
    write at 86 sy-vline.
  endif.
*--------------- end --------------------------------------------------*
* Mandtsanzeige, sofern WEG-AddON / Mandatsverwaltung aktiv
  if not bkpf-propmano is initial.
    new-line no-scrolling.
    write sy-vline.
    write at 3(09)  text-p01.
    write at 18 bkpf-propmano.
    write at 86 sy-vline.
  endif.
*----------------------------------------------------------------------
  new-line no-scrolling.
  write at (86) sy-uline.

  skip 1.

endform.                               "KOPF_ANZEIGE
