*----------------------------------------------------------------------*
***INCLUDE LF064F04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*  react on various possible user commands
*----------------------------------------------------------------------*
*  Caution: Do not insert a SET SCREEN SY-DYNNR etc. command in here,
*  as this will destroy the ALV stack (DYNPRO_NOT_FOUND shortdump
*  will occur). Also refer to Note 456016.
*----------------------------------------------------------------------*
form handle_user_command using r_ucomm     like sy-ucomm
                        rs_selfield type slis_selfield.     "#EC CALLED

  data: exit_from_form,
        l_dyncl,
        ls_rfopt2 like rfopt2.

  if bkpf-bstat = 'M' or bkpf-bstat = c_d.
    l_dyncl = xbkpf-bstat.
  else.
    clear l_dyncl.
  endif.

*--------- Part for document simulation during posting -----------------
*--------- Regard item display in FB05 ------------------- "Note 302995
* (del) if t020-aktyp = 'H'.                               "Note 302995
  if t020-aktyp = c_h and t020-dyncl ne c_z.               "Note 302995
    clear exit_from_form.
    perform okcode_during_simulation using    r_ucomm
                                     changing exit_from_form
                                              rs_selfield.
    if exit_from_form = 'X'.
      exit.
    endif.
  endif.

*------- preliminary checks before user commands will be processed:
*------- Is cursor positioned on a valid line ?

  if r_ucomm eq 'DETA' or r_ucomm eq 'CHGL' or
  ( status eq c_stat_hierseq and                            "ALRK225335
    r_ucomm <> 'NB' and r_ucomm <> 'REVS' ).                "ALRK225335
    if rs_selfield-tabindex = 0
    or ( rs_selfield-tabname ne 'XBSEG'
    and  rs_selfield-tabname ne 'XBKPF' ).
* Note 369284: Begin of insertion
      if not   ( rs_selfield-sel_tab_field = 'BKPF-STBLG' or
                 rs_selfield-sel_tab_field = 'RF05L-STOTX' or
                 rs_selfield-sel_tab_field = 'BKPF-STJAH' or
                 rs_selfield-sel_tab_field = 'BKPF-BVORG' ).

* Note 369284: End of insertion
        message s314(f5).
        exit.
      endif.                                               "Note 369284
    endif.
  endif.

*
*------ process user commands from here on
*

  case r_ucomm.

    when 'DETA'.

      if xbkpf-bstat = c_bel_vorerf.
        message s358(f5a) with xbkpf-belnr.                "Note 496832
        exit.
      endif.
      if rs_selfield-tabname = 'XBSEG'.
* document line item detail
        perform zeilen_bearbeitung using rs_selfield-tabindex g_aktyp
                                         changing rs_selfield-refresh.

      elseif rs_selfield-sel_tab_field = 'BKPF-STBLG'      "Note 369284
          or rs_selfield-sel_tab_field = 'RF05L-STOTX'     "Note 369284
          or rs_selfield-sel_tab_field = 'BKPF-STJAH'.     "Note 369284
        set parameter: id 'BUK' field bkpf-bukrs,          "Note 369284
                       id 'BLN' field bkpf-stblg,          "Note 369284
                       id 'GJR' field bkpf-stjah.          "Note 369284
        call transaction 'FB03' and skip first screen.     "Note 369284

        set parameter: id 'BUK' field bkpf-bukrs,          "Note 369284
                       id 'BLN' field bkpf-belnr,          "Note 369284
                       id 'GJR' field bkpf-gjahr.          "Note 369284

      elseif rs_selfield-sel_tab_field = 'BKPF-BVORG'.     "Note 388044
        set parameter id 'VRG' field  bkpf-bvorg.          "Note 388044
        call transaction 'FBU3' and skip first screen.     "Note 388044

      else.
        read table xbkpf index rs_selfield-tabindex.
        move-corresponding xbkpf to bkpf.
        call screen '1710' starting at 14 4
                             ending at 78 21.
      endif.

    when 'CHGL'.

      if rs_selfield-tabname = 'XBSEG'.
        perform set_cc_doc_key using rs_selfield.          "Note 389794
        perform check_if_archived using xbkpf-bukrs xbkpf-belnr
                                       xbkpf-gjahr rcode.  "Note 389794
        "Note 389794
        if rcode ne 0.                                      "Note 389794
         message s720(f5).                                  "Note 389794
         exit.                                              "Note 389794
        endif.                                              "Note 389794

        perform zeilen_bearbeitung using rs_selfield-tabindex 'V'
                                   changing rs_selfield-refresh.
      else.
        message s314(f5).
        exit.
      endif.

*---------- show document changes   -----------------------------------*
    when 'AH'.

      if bkpf-bstat = c_a or bkpf-bstat = c_b.
        call dialog 'AENDERUNGSBELEGE_RF_BELEG'
          exporting
            rf01a-belnr from bkpf-belnr
            rf01a-bukrs from bkpf-bukrs
            rf01a-gjahr from bkpf-gjahr
            dyncl       from l_dyncl.
      elseif rs_selfield-tabname = 'XBSEG'.
        read table xbseg index rs_selfield-tabindex.
        call dialog 'AENDERUNGSBELEGE_RF_BELEG'
          exporting
            rf01a-belnr from xbseg-belnr
            rf01a-bukrs from xbseg-bukrs
            rf01a-gjahr from xbseg-gjahr
            dyncl       from l_dyncl.
      else.
        read table xbkpf index rs_selfield-tabindex.
        call dialog 'AENDERUNGSBELEGE_RF_BELEG'
          exporting
            rf01a-belnr from xbkpf-belnr
            rf01a-bukrs from xbkpf-bukrs
            rf01a-gjahr from xbkpf-gjahr
            dyncl       from l_dyncl.
      endif.

*---------- show clearing info ----------------------------------------*
    when 'AU'.

      if bkpf-bstat = c_a.
        move-corresponding bkpf to xbkpf.
      else.
        perform set_cc_doc_key using rs_selfield.
      endif.

      if status = 'H'.                 " cross-company code transaction
        call function 'FI_CLEARED_ACCOUNTS_READ'
          exporting
            i_bukrs         = xbkpf-bukrs
            i_belnr         = xbkpf-belnr
            i_gjahr         = xbkpf-gjahr
            i_cross_company = 'X'
            i_display       = 'X'.
      else.
        call function 'FI_CLEARED_ACCOUNTS_READ'
          exporting
            i_bukrs   = xbkpf-bukrs
            i_belnr   = xbkpf-belnr
            i_gjahr   = xbkpf-gjahr
            i_display = 'X'.
      endif.

*---------- show data for recurring documents -------------------------*
    when 'DBDA'.

      if xbkpf-bstat ne c_d.
        message e324(f5).
      endif.

      if g_aktyp eq c_aktyp_display.
        call screen '0101' starting at 20 5
                           ending at 78 21.
      else.
        set parameter id 'BUK' field xbkpf-bukrs.
        set parameter id 'BLN' field xbkpf-belnr.
        set parameter id 'BLD' field xbkpf-belnr.
        set parameter id 'GJR' field xbkpf-gjahr.
        clear xfeld.
        export xfeld to memory id 'FB02ALV'.
        call function 'DEQUEUE_EFBKPF'
          exporting
            belnr = xbkpf-belnr
            bukrs = xbkpf-bukrs
            gjahr = xbkpf-gjahr.
        call transaction 'FBD2' and skip first screen.
      endif.

*------------- Call document relation browser --------------------------
    when 'DRB'.
      perform set_cc_doc_key using rs_selfield.
      data: ld_objtype(10) type c.
      ld_objtype = xbkpf-awtyp.
* Remove GOS icon when calling DRB (not in own session)
      if not rfopt2-xdrb = 'X'.
        perform unpublish_icon.
      endif.
      call function 'FI_DOCUMENT_RELATION_BROWSER'
        exporting
*         I_OBJTYPE       = 'BKPF'
          I_OBJTYPE       = ld_objtype
          i_bukrs         = xbkpf-bukrs
          i_belnr         = xbkpf-belnr
          i_gjahr         = xbkpf-gjahr.
* Create GOS icon anew in case we display a non cross company code doc.
      if status ne c_stat_hierseq and gos_icon is initial.
        perform publish_doc_icon
              using 'BKPF' xbkpf-bukrs xbkpf-belnr
                    xbkpf-gjahr '000' space rcode.
      endif.

*---------- show cleared items for all kinds of clearing documents ----*
    when 'EPOS'.

      perform set_cc_doc_key using rs_selfield.

      perform check_if_archived using xbkpf-bukrs xbkpf-belnr
                                      xbkpf-gjahr rcode.   "Note 389794
      "Note 389794
      if rcode ne 0.                                       "Note 389794
        message s256(f5a).                                 "Note 389794
        exit.                                              "Note 389794
      endif.                                               "Note 389794

      call function 'SHOW_PAID_INVOICES'
        exporting
          bukrs = xbkpf-bukrs
          belnr = xbkpf-belnr
          gjahr = xbkpf-gjahr
          bvorg = xbkpf-bvorg.

*---------- correspondence request ------------------------------------*
    when 'KORR'.

      if bkpf-bstat = c_a or bkpf-bstat = c_b.
        move-corresponding bkpf to xbkpf.
      else.
        perform set_cc_doc_key using rs_selfield.
      endif.

      call function 'CORRESPONDENCE_REQUEST'
        exporting
          i_company_code    = xbkpf-bukrs
          i_dbupdate        = 'X'
          i_document        = xbkpf-belnr
          i_message         = 'X'
          i_overwrite_acc   = 'X'
          i_overwrite_doc   = 'X'
          i_process         = 'BAN'
          i_year            = xbkpf-gjahr
        exceptions
          no_event_found    = 01
          no_event_selected = 02.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

*---------- show another document -------------------------------------*
    when 'NB'.

      perform neuer_beleg.

*---------- new process -----------------------------------------------*
    when 'NV'.

      perform neuer_beleg.

*-- object links  -----------------------------------------------------*
    when 'OBAZ'.
*-- check authority for each line item first before displaying links
*-- Note 388044

      perform set_cc_doc_key using rs_selfield.

      clear gt_missing_auth.
      loop at gt_missing_auth where bukrs eq xbkpf-bukrs and
                                    belnr eq xbkpf-belnr and
                                    dash = c_dash.
        message i882.
        exit.
      endloop.

      if gt_missing_auth-dash ne c_dash.
        wflkey-bukrs = xbkpf-bukrs.
        wflkey-belnr = xbkpf-belnr.
        wflkey-gjahr = xbkpf-gjahr.
        clear wflpos.
        perform org_beleg_zeigen(sapfs006) using wflkey wflpos.
      endif.

*-------- assign recently displayed original document -----------------*
    when 'OBLE'.

      perform set_cc_doc_key using rs_selfield.

      xopar = space.
      perform obeleg_ablage_pruefen(sapfs006) using xopar.
      if xopar = 'X'.
        wflkey-bukrs = xbkpf-bukrs.
        wflkey-belnr = xbkpf-belnr.
        wflkey-gjahr = xbkpf-gjahr.
        perform org_beleg_ablegen(sapfs006)
          using wflkey xwfla.
        if xwfla = 'X'.
          leave.
        endif.
      endif.

*-------- reverse document --------------------------------------------*
    when 'REVS'.

      perform reverse_document                             "Note 323188
        changing rs_selfield-refresh.                      "Note 323188
    when 'ST'.                         " tax data

      if rs_selfield-tabname = 'XBSEG' or
      rs_selfield-tabname = 'XBKPF'.
        perform set_cc_doc_key using rs_selfield.
      else.

*---------- Determine tax company code ---------------------------------
        loop at xbseg.
          check xbseg-stbuk = xbseg-bukrs.
          exit.
        endloop.
        if sy-subrc = 0.
          read table xbkpf with key bukrs = xbseg-bukrs
                belnr = xbseg-belnr gjahr = xbseg-gjahr.
        endif.
      endif.
      move-corresponding xbkpf to bkpf.
      call function 'FI_TAX_SHOW_BSET'
        exporting
          i_bukrs               = bkpf-bukrs
          i_belnr               = bkpf-belnr
          i_gjahr               = bkpf-gjahr
          i_waers               = bkpf-waers
          i_screen_start_column = 10
          i_screen_start_line   = 10
          i_screen_end_column   = 70
          i_screen_end_line     = 21
        tables
          t_bset                = xbset                    "Note 490520
        exceptions
          parameter_error       = 1
          alv_problem           = 2
          others                = 3.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

*---------- show long texts -------------------------------------------*
    when 'TEXT'.

      if bkpf-bstat = c_a or bkpf-bstat = c_b.
        move-corresponding bkpf to xbkpf.
      else.
        perform set_cc_doc_key using rs_selfield.
      endif.

      if g_aktyp = c_aktyp_display.
        call function 'FI_TEXTS_DOCUMENT'
          exporting
            i_object       = 'BELEG'
            i_aktyp        = c_aktyp_display
            i_bukrs        = xbkpf-bukrs
            i_gjahr        = xbkpf-gjahr
            i_belnr        = xbkpf-belnr
            i_blart        = xbkpf-blart
          importing
            e_update       = xchng
          tables                                        "Note 319123
            t_accdn        = taccdn                  "Note 319123
          exceptions
            no_texts_found = 1
            others         = 2.
      else.
        set parameter id 'BUK' field xbkpf-bukrs.
        set parameter id 'BLN' field xbkpf-belnr.
        set parameter id 'GJR' field xbkpf-gjahr.
        call function 'DEQUEUE_EFBKPF'
          exporting
            belnr = xbkpf-belnr
            bukrs = xbkpf-bukrs
            gjahr = xbkpf-gjahr.
        clear xfeld.
        export xfeld to memory id 'FB02ALV'.
        if  xbkpf-bstat = c_d.
          set parameter id 'BLD' field xbkpf-belnr.
          call transaction 'FBD2' and skip first screen.
        elseif  xbkpf-bstat = c_m.
          set parameter id 'BLM' field xbkpf-belnr.
          call transaction 'FBM2' and skip first screen.
        else.
          call transaction 'FB02' and skip first screen.
        endif.
      endif.

*---------- document header data --------------------------------------*
    when 'VK'.

      if bkpf-bstat = c_a or bkpf-bstat = c_b.
* do nothing.
      else.
        perform set_cc_doc_key using rs_selfield.
        move-corresponding xbkpf to bkpf.
      endif.

      perform document_header changing rs_selfield-refresh.

*--------- balance sheet readjustment ---------------------------------*
    when 'ZAUF'.

      perform set_cc_doc_key using rs_selfield.

* leave to list-processing.  ??
* set pf-status 'BACK'.      ??
      call function 'BREAKDOWN_SHOW_DOCUMENT'
        exporting
          i_bukrs = xbkpf-bukrs
          i_belnr = xbkpf-belnr
          i_gjahr = xbkpf-gjahr
          i_waenr = s_status-waehr
          i_lmode = '2'.

*--------- show original document -------------------------------------*
    when 'ZBEL'.

      perform set_cc_doc_key using rs_selfield.

      call function 'AC_DOCUMENT_SENDER'
           exporting
                i_awsys                      = xbkpf-awsys
                i_awtyp                      = xbkpf-awtyp
                i_awref                      = xbkpf-awkey+00(10)
                i_aworg                      = xbkpf-awkey+10(10)
* (del)         i_bukrs                      = xbkpf-bukrs "Note 212977
           exceptions
                awtyp_not_found              = 1
                no_document_display_function = 2
                others                       = 3.
      if sy-subrc ne 0.
        message i654(c+).
      endif.

*--------- payment document -------------------------------------------*
    when 'ZBLG'.

      perform set_cc_doc_key using rs_selfield.

      loop at xbseg where ( koart = 'D' or koart = 'K' ) and
                          augbl = xbkpf-belnr and augdt = xbkpf-budat.
      endloop.
      if sy-subrc eq 0.
        call function 'GET_CHECK_INFORMATION'
          exporting
            i_augbl   = xbkpf-belnr
            i_augdt   = xbkpf-budat
            i_belnr   = xbkpf-belnr
            i_bukrs   = xbkpf-bukrs
            i_bvorg   = xbkpf-bvorg
            i_gjahr   = xbkpf-gjahr
          exceptions
            not_found = 04.
      else.                            " payment on account
        clear: xbseg-augbl, xbseg-augdt.
        call function 'GET_CHECK_INFORMATION'
          exporting
            i_augbl   = xbseg-augbl
            i_augdt   = xbseg-augdt
            i_belnr   = xbkpf-belnr
            i_bukrs   = xbkpf-bukrs
            i_bvorg   = xbkpf-bvorg
            i_gjahr   = xbkpf-gjahr
          exceptions
            not_found = 04.
      endif.
      if sy-subrc ne 0.
        message s241(f5).
      endif.

*--------- accounting documents ---------------------------------------*
    when 'ZREC'.

      perform set_cc_doc_key using rs_selfield.

      perform record_receiver.

*----------- Posting Correction Request -------------------------------*
    when 'CORR'.

      data: id_doctype type  doctype_pcr,
            is_key type  acc_pcr_key.

      is_key-ac_doc_no = bkpf-belnr.
      is_key-comp_code = bkpf-bukrs.
      is_key-fisc_year = bkpf-gjahr.
      if rs_selfield-tabindex eq space.
        message e002(qisr_pcr).
      else.
        is_key-item_num = rs_selfield-tabindex.
      endif.
      id_doctype = 'FI-GL'.

      call function 'PCR_CALL_REQUEST'
        exporting
          id_doctype = id_doctype
          is_key     = is_key
        exceptions
          not_active = 1
          others     = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
  endcase.

  perform variant_hold.

endform.                               " handle_user_command


*---------------------------------------------------------------------*
*       FORM RECORD_RECEIVER                                          *
*---------------------------------------------------------------------*
*   show all accounting documents                                     *
*---------------------------------------------------------------------*
form record_receiver.

  data: ls_dialog type boole.

  data: begin of t_documents occurs 10.
          include structure acc_doc.
  data: end of t_documents.
*
* collect all documents that have not been displayed
*
  clear ls_dialog.
  call function 'AC_DOCUMENT_RECORD'
       exporting
            i_awtyp     = xbkpf-awtyp
            i_awref     = xbkpf-awkey+00(10)
            i_aworg     = xbkpf-awkey+10(10)
            i_awsys     = xbkpf-awsys
            x_dialog    = ls_dialog
* detect cross-company code documents
            i_bukrs     = xbkpf-bukrs
       tables
            t_documents = t_documents.
*
* delete current FI document from the list
*
* loop at t_documents
*   where docnr eq xbkpf-belnr
*   and   awtyp = xbkpf-awtyp.
*   delete t_documents.
* endloop.
*
*
* display remaining list of documents
*
    ls_dialog-boole = c_x.
  call function 'AC_DOCUMENT_RECORD'
    exporting
      i_awtyp     = xbkpf-awtyp
      i_awref     = xbkpf-awkey+00(10)
      i_aworg     = xbkpf-awkey+10(10)
      i_awsys     = xbkpf-awsys
      x_dialog    = ls_dialog
    tables
      t_documents = t_documents.
endform.                    "record_receiver

*---------------------------------------------------------------------*
*       FORM DOCUMENT_HEADER                                          *
*---------------------------------------------------------------------*
*   display document header or - in change mode - call                *
*   conventional FB02 transaction to perform changes of header data   *
*---------------------------------------------------------------------*
form document_header changing refresh type c.

  data: ls_rfopt2 like rfopt2.

  if g_aktyp = c_aktyp_display.
    call screen '1710' starting at 14 4
                         ending at 78 21.
  else.
    call function 'DEQUEUE_EFBKPF'
      exporting
        belnr = xbkpf-belnr
        bukrs = xbkpf-bukrs
        gjahr = xbkpf-gjahr.
    set parameter id 'BUK' field xbkpf-bukrs.
    set parameter id 'BLN' field xbkpf-belnr.
    set parameter id 'GJR' field xbkpf-gjahr.
*----- xfeld = 'U': supress ALV + commit work and wait (Note 400568)
    xfeld = 'U'.
    export xfeld to memory id 'FB02ALV'.
    message i092(f5a).
    if xbkpf-bstat = c_d.
      set parameter id 'BLD' field xbkpf-belnr.
      call transaction 'FBD2' and skip first screen.
    elseif xbkpf-bstat = c_m.
      set parameter id 'BLM' field xbkpf-belnr.
      call transaction 'FBM2' and skip first screen.
    else.
      call transaction 'FB02' and skip first screen.
    endif.

* ------- Refresh document header changes (Note 400568)----------------

    refresh = c_x.
    if  status eq c_stat_list.
      perform beleg_lesen using xbkpf-belnr xbkpf-bukrs xbkpf-gjahr.
    else.
      perform read_cross_company_documents using xbkpf-bvorg.
    endif.
  endif.

endform.                               " document_header
*&---------------------------------------------------------------------*
*&      Form  okcode_during_simulation
*&---------------------------------------------------------------------*
*       OKCODE Handling in simulation mode of new enjoy transaction
*----------------------------------------------------------------------*
form okcode_during_simulation using    p_ucomm like sy-ucomm
                              changing exit    type c
                                       rs_sel  type slis_selfield.
  okcode = p_ucomm.

*-------------- Standard F2 Code ? -------------------------------------
  if p_ucomm = 'DETA'.
    okcode = 'PI'.
  endif.

*-------- Back, Cancel or End was pressed ------------------------------
  if p_ucomm = 'F03' or p_ucomm = 'F12'.
    okcode = 'LA'.
  elseif p_ucomm = 'F15'.
    okcode = 'END'.
  endif.

*------------ Initialize selected line item no. ------------------------
  index = 0.

*-------- Quit ALV -----------------------------------------------------
  rs_sel-exit = 'X'.

*------------- Line was chosen for detailed display --------------------
  case okcode.
    when 'PI'.
      if rs_sel-tabindex = 0.
        if rs_sel-fieldname is initial.
          clear rs_sel-exit.
          index = 0.
          message s314(f5).
        else.

*------------- Don't exit ----------------------------------------------
          clear rs_sel-exit.
        endif.
      else.
        index = rs_sel-tabindex.

* Free Error Log from this line item: BUZEI = first parameter in msg. --
        read table xbseg index index.
        if sy-subrc = 0.
          delete terrinf where message_v1 = xbseg-buzei.
* Note 329716: begin of insertion
* Ensure that drill-down on sorted items in ALV brings up
* correct line item in detail display; xbseg is sorted according
* to sorting criteria in ALV
          index = xbseg-buzei.
* Note 329716: end of insertion
        endif.
      endif.
      exit = 'X'.

*------------ Ausgabe Info über noch nachzukontierende Zeilen ----------
    when 'LOG '.
      call function 'REUSE_ALV_LIST_DISPLAY'
        exporting
          i_structure_name      = 'ACERRLOG'
          i_save                = 'X'
          i_screen_start_column = 10
          i_screen_start_line   = 10
          i_screen_end_column   = 90
          i_screen_end_line     = 20
        tables
          t_outtab              = terrinf
        exceptions
          others                = 4.
      clear rs_sel-exit.
    when 'STIB'.
      clear rs_sel-exit.
      call function 'FI_TAX_SHOW_BSET'
        exporting
          i_waers               = bkpf-waers
          i_screen_start_column = 10
          i_screen_start_line   = 10
          i_screen_end_column   = 90
          i_screen_end_line     = 21
        tables
          t_bset                = xbset
        exceptions
          others                = 4.
    when 'LA'.
      IF sy-tcode EQ 'ZFITR006B'.
      ELSE.
        message i257.                                         "P00K027809
      ENDIF.

    when 'BP'.                                              "Note449741
    when 'BU'.
    when 'END'.
      message i257.                                         "P00K027809
    when 'PBBP'.                                            "Note449741
    when others.
      clear rs_sel-exit.
  endcase.
  if rs_sel-exit = 'X'.
    perform variant_hold.
  endif.
endform.                               " okcode_during_simulation
*&---------------------------------------------------------------------*
*&      Form  NEUER_BELEG
*&---------------------------------------------------------------------*
*       Aufrufen Call-Bild fuer neuen Beleg / neuen Vorgang           *
*       Falls der Beleg gefunden wurde alte Belege evtl entsperren    *
*       und neuen anzeigen.                                           *
*----------------------------------------------------------------------*
form neuer_beleg.
  data:  l_tcode like sy-tcode.

* We may have been called by FBL3N etc.                    "Note 313252
* (del) l_tcode = sy-tcode.                                "Note 313252
  if t020-tcode ne sy-tcode.                               "Note 313252
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single * from t020 where tcode = sy-tcode.      
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  from t020 where tcode = sy-tcode ORDER BY PRIMARY KEY.      

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"Note 313252
  endif.                                                   "Note 313252
  if t020-aktyp = c_v.                                     "Note 313252
    l_tcode = 'FB02'.                                      "Note 313252
  else.                                                    "Note 313252
    l_tcode = 'FB03'.                                      "Note 313252
  endif.                                                   "Note 313252

  g_ucomm = 'NB'.

  call screen '1110' starting at 27 15
                     ending at   58 18.

  if g_exit eq c_x.
    clear g_exit.
    exit.
  endif.

* clear parameter R/R in order to make fb03 search           note 30700
* the document by document number and not by xblnr           note 30700
  rf05l-xblnr = ' '.                                        "note 30700
  set parameter id 'R/R' field rf05l-xblnr.                 "note 30700

  set parameter id 'BUK' field rf05l-bukrs.
  set parameter id 'BLN' field rf05l-belnr.
  set parameter id 'GJR' field rf05l-gjahr.
  if bkpf-bstat = c_m.
    l_tcode+2(1) = c_m.
    set parameter id 'BLM' field rf05l-belnr.
  elseif bkpf-bstat = c_d.
    l_tcode+2(1) = c_d.
    set parameter id 'BLD' field rf05l-belnr.
  else.
    l_tcode+2(1) = '0'.
  endif.

  leave to transaction l_tcode and skip first screen.

endform.                               " NEUER_BELEG
* Begin of ALRK225335
*&---------------------------------------------------------------------*
*&      Form  REVERSE_DOCUMENT
*&---------------------------------------------------------------------*
*       Call FB08 to reverse document. Call new transaction after
*       return to update information displayed.
*----------------------------------------------------------------------*
form reverse_document changing refresh type c.

* ----- data declarations

  data:    docid          like toadv-ar_object,           "Note 0390492
           barcode_id     like toav0-arc_doc_id.          "Note 0390492
  data: pj_par(1) type c,                                 "493283
        opt       type ctu_params.                        "493283
  data:    ld_stbla type stbla_003,
           ld_xsybl type xsybl,
           ld_bor_flag type xfeld,
           fb09_rcode type sysubrc.

* Authority check for FB08 at PBO to deactivate function   "Note 323188
* (del) data l_tcode like sy-tcode.             "ALRK241034 Note 323188
* (del) l_tcode = sy-tcode.                     "ALRK241034 Note 323188
* (del) call function 'AUTHORITY_CHECK_TCODE'   "ALRK241034 Note 323188
* (del)   exporting                             "ALRK241034 Note 323188
* (del)     tcode   = l_tcode                   "ALRK241034 Note 323188
* (del)   exceptions                            "ALRK241034 Note 323188
* (del)     ok      = 0                         "ALRK241034 Note 323188
* (del)   others  = 4.                          "ALRK241034 Note 323188
* (del) if sy-subrc ne 0.                       "ALRK241034 Note 323188
* (del)   message e172(00) with l_tcode.        "ALRK241034 Note 323188
* (del) endif.                                  "ALRK241034 Note 323188

  clear xrevs.
  read table xbkpf index 1.

* ------ No reversal for cross-company documents

  check xbkpf-bvorg is initial.

  rf05a-belnr = xbkpf-belnr.
  rf05a-bukrs = xbkpf-bukrs.
  rf05a-gjahr = xbkpf-gjahr.

* ------ Determine document type for reversal document
*        Notes (0390492 + 480960)
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single stbla into ld_stbla
*              from t003 where blart = xbkpf-blart.
*
* NEW CODE
  SELECT stbla
  UP TO 1 ROWS  into ld_stbla
              from t003 where blart = xbkpf-blart ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  if sy-subrc = 0.
    if ld_stbla ne space.
      bkpf-blart = ld_stbla.
    else.
      bkpf-blart = xbkpf-blart.
    endif.
  else.
    message e067 with xbkpf-blart.
  endif.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single xsybl into ld_xsybl from t003 where blart = bkpf-blart.
*
* NEW CODE
  SELECT xsybl
  UP TO 1 ROWS  into ld_xsybl from t003 where blart = bkpf-blart ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  if ld_xsybl = c_x.
    message i310(f5) with bkpf-blart.
    exit.
  endif.

* ------ Call popup for reversal parameters

  call screen '1120' starting at 27 25.

* ------ Reversal requested ?

  check xrevs = 'X'.

* ------ check barcode customizing and call
* ------ popup for barcode input if necessary (Note 0390492)
  clear rcode.                                            "Note 0403778
  perform barcode_eingabe(sapfs006) using rcode.
  if rcode eq 0.
    perform get_barcode(sapfs006) using docid barcode_id.
  endif.

* ------ prepare batch-input

  bdcmode = 'N'.
  refresh bdctab.
  clear bdctab.
  bdctab-program  = 'SAPMF05A'.
  bdctab-dynpro   = '0105'.
  bdctab-dynbegin = 'X'.
  append bdctab.
  perform fill_bdctab using 'RF05A-BELNS' xbkpf-belnr.
  perform fill_bdctab using 'BKPF-BUKRS' xbkpf-bukrs.
  perform fill_bdctab using 'RF05A-GJAHS' xbkpf-gjahr.
  perform fill_bdctab using 'UF05A-STGRD' uf05a-stgrd.
  perform fill_bdctab using 'BSIS-BUDAT' bsis-budat.
  perform fill_bdctab using 'BSIS-MONAT' bsis-monat.
  perform fill_bdctab using 'FS006-DOCID' docid.
  perform fill_bdctab using 'FS006-BARCD' barcode_id.
  perform fill_bdctab using 'BDC_OKCODE' 'BU'.
* Check if JVA test popup should be sent
  get parameter id 'GJ_JVA_TEST' field pj_par.         "493283
  if pj_par = 'X'.                                     "493283
    opt-nobinpt = 'X'.                                 "493283
    opt-updmode = 'S'.                                 "493283
    call transaction 'FB08' using bdctab               "493283
                            options from opt.          "493283
  else.                                                "493283

* ------- Call reversing transaction in synchronous update mode

  call transaction 'FB08' using bdctab
                          mode bdcmode
                          update 'S'.
  endif.                                               "493283

* All checks if document is really reversable will be done
* in transaction FB08, and NOT before. (This is a little drawback: user
* types in data, and system tells him afterwards that document
* cannot be reversed).

* ------- Issue error message, if error occurred

  if sy-subrc ne 0.
    message id sy-msgid
            type sy-msgty
            number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.

* Reversal succesful:
* In case list display was called from workflow method BSEG.CHANGE
* and document was reversed, we need to set the export code
* for the BSEG.CHANGE method (s. TA SWO1, Note 544581)

    fb09_rcode = 1.
    export fb09_rcode to memory id 'SAPMF05L_FRRTC'.

* ------ Read document anew to obtain reversal information
    refresh = c_x.
    perform beleg_lesen using xbkpf-belnr xbkpf-bukrs xbkpf-gjahr.
  endif.

endform.                               " REVERSE_DOCUMENT

*---------------------------------------------------------------------*
*       FORM fill_bdctab                                              *
*---------------------------------------------------------------------*
*       Create line in batch input table                              *
*---------------------------------------------------------------------*
*  -->  value(p_fname)    Name of field to be filled                  *
*  -->  value(p_fvalue)   Value of field                              *
*---------------------------------------------------------------------*
form fill_bdctab using value(p_fnam) type clike
                       value(p_fval) type clike.
  if not p_fval is initial.
    clear bdctab.
    bdctab-fnam = p_fnam.
* Use write because to edit dates correctly
    write p_fval to bdctab-fval.
    append bdctab.
  endif.
endform.                    "fill_bdctab
* End of ALRK225335
*&---------------------------------------------------------------------*
*&      Form  reversal_text
*&---------------------------------------------------------------------*
*  Correct text element for reversals / reversed documents
*----------------------------------------------------------------------*

form reversal_text.
* Recently changed by notes 354186 + 432389

  data: t_reversal type t_time,
        t_reversed type t_time.
  data: t_sfakn like vbrk-sfakn.                          "Note 614057
* ---------------------------------------------------------------------
* Try to find out if a document is a reversal or a reversed document.
* That's not that easy, as in releases < 4.70 an unequivocal indicator
* for reversal or reversed documents is missing. We cannot use
* BKPF-STGRD as an indicator, as it's sometimes missing or filled the
* other way round than in FB08. From 4.70 on, there's BKPF-XREVERSAL.
* ---------------------------------------------------------------------

  check bkpf-stblg ne space.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
* select single cpudt cputm into (t_reversed-date, t_reversed-time) from
*        bkpf where bukrs eq bkpf-bukrs and
*                   belnr eq bkpf-stblg and
*                   gjahr eq bkpf-gjahr and
*                   stblg eq bkpf-belnr.                    
*
* NEW CODE
 SELECT cpudt cputm
 UP TO 1 ROWS  into (t_reversed-date, t_reversed-time) from
        bkpf where bukrs eq bkpf-bukrs and
                   belnr eq bkpf-stblg and
                   gjahr eq bkpf-gjahr and
                   stblg eq bkpf-belnr ORDER BY PRIMARY KEY.                    

 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"Note590739

* Document might have been archived.....
  if sy-subrc eq 0.
    t_reversal-date = bkpf-cpudt.
    t_reversal-time = bkpf-cputm.
  endif.

  if  bkpf-xreversal = '2'     " most definite indicator for a reversal
* Compare time stamps, might not always be true in distributed systems
   or t_reversal gt t_reversed
* Here, we cannot do anything else than checking for transaction
* codes....
* ---- FI
   or bkpf-tcode eq 'FB08'
*  --- MM Invoice Verifcation
   or ( bkpf-tcode eq 'MR01' and not bkpf-stgrd is initial )
   or bkpf-tcode eq 'MR8M'
* ---- Treasury, Financial Services....
   or bkpf-tcode eq 'TBB2'
   or bkpf-tcode eq 'TBB5'
   or bkpf-tcode eq 'TBB8'
   or bkpf-tcode eq 'FWACR'
   or bkpf-tcode eq 'FWAS'
   or bkpf-tcode eq 'FWPR'
   or bkpf-tcode eq 'FWER_STORNO'
   or bkpf-tcode eq 'FWKS'
   or bkpf-tcode eq 'FWOE'
   or bkpf-tcode eq 'FWOS'
   or bkpf-tcode eq 'FWSS'
   or bkpf-tcode eq 'FWSU'
   or bkpf-tcode eq 'FWDS'
   or bkpf-tcode eq 'TS07'
   or bkpf-tcode eq 'TPM29'
   or bkpf-tcode eq 'TPM16'
   or bkpf-tcode eq 'TPM2'
* ---- Billing (SD)
   or bkpf-tcode eq 'VF11'
   or bkpf-tcode eq 'VF26'.
* To be continued in case something still doesn't work.....
*  OR BKPF-TCODE EQ '0815'.
    rf05l-stotx = text-038.    " Reversal for ......
  else.
    rf05l-stotx = text-039.    " Reversed by ....
  endif.

* -----Billing (SD): documents subsequently forwarded to FI----
* document can either be a reversal document or a reversed one;
* tcode is not like VF11, VF26 or VF01 (Note 614057)
if bkpf-tcode(2) = 'VF' and
   bkpf-tcode <> 'VF01' and
   bkpf-tcode <> 'VF11' and
   bkpf-tcode <> 'VF26'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
* select single sfakn into t_sfakn
*        from vbrk
*        where vbeln = bkpf-awkey(10).
*
* NEW CODE
 SELECT sfakn
 UP TO 1 ROWS  into t_sfakn
        from vbrk
        where vbeln = bkpf-awkey(10) ORDER BY PRIMARY KEY.

 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    if not t_sfakn is initial.
      rf05l-stotx = text-038.    " Reversal for ......
    else.
      rf05l-stotx = text-039.    " Reversed by ....
    endif.
endif.

endform.                    " reversal_text
*&---------------------------------------------------------------------*
*&      Form  PUBLISH_DOC_ICON
*&---------------------------------------------------------------------*
* Created by note 402273
*----------------------------------------------------------------------*
form publish_doc_icon using
                          value(p_object) type saeanwdid
                          value(p_bukrs)  type bukrs
                          value(p_belnr)  type belnr_d
                          value(p_gjahr) type gjahr
                          value(p_item) type buzei
                          p_test        type xfeld
                          p_rcode type sysubrc.

* ----------------------- data declarations

  data: objectident type borident.
  data: lt_services type tgos_sels.    " table typ
  data: ls_service type sgos_sels.     " structure type
  data: rc type sysubrc.
  data: indxkey like rfdt-srtfd.
  DATA: indarl LIKE rfdt-srtfd.                       "Note906198
  DATA: l_ip_no_commit TYPE sgs_cmode.                      "Note1033419


  data: begin of keydata,
          bukrs like bkpf-bukrs,
          belnr like bkpf-belnr,
          gjahr like bkpf-gjahr,
        end of keydata.

* -------- P_RCODE: 0 = publishing worked   1 = didn't work

  p_rcode = '1'.
*
* -------- suppress publishing in batch-input mode (Note 430030)
*
  check sy-binpt = ' '.

* -------- check for existence of appropriate basis package

*  CALL FUNCTION 'OCS_GET_COMPONENT_STATE'
*       EXPORTING
*            IV_COMPONENT  = 'SAP_BASIS'
*       IMPORTING
*            EV_COMP_LEVEL = P_LEVEL
*       EXCEPTIONS
*            OTHERS        = 1.
*
*  IF SY-SUBRC <> 0 or p_level le '0815'.
*    EXIT.
*   ENDIF.

* If interface IFGOSXSERV exists, basis hotpackage is available ....

*  call function 'SWO_OBJTYPE_EXIST'
*    exporting
*      objtype           = 'IFGOSXSERV'
*    exceptions
*      objtype_not_found = 1.

*  if sy-subrc <> 0.
*    exit.
*  endif.

* ------- in test mode, return code = 0 when new func. could be used..

*  if p_test eq 'X'.
*    clear p_rcode.
*    exit.                              " do nothing else.
*  endif.

*--------------------------------------------------------------------
*
* Publishing of object: Publish always BKPF in Display
* Transactions when posted (not parked) documents are displayed.
*
* Consequence: Private Notes, attachements will always be linked to this
* object type for simplicity. Nevertheless, if wanted, other
* types (BSEG) etc. could be published here. This would allow for the
* creation of attachments that are linked to this other object type.
*
* Right now, only objects BKPF+FIPP support the publishing of
* related objects via method GOSADDOBJECTS called by the generic object
* services. To provide for a full functionality for other objects,
* this objects have to implement interface IFGOSASERV (s. Type BKPF).
*
*----------------------------------------------------------------------

  keydata-bukrs = p_bukrs.
  keydata-belnr = p_belnr.
  keydata-gjahr = p_gjahr.

  objectident-objkey  = keydata.
  objectident-objtype = p_object.
  objectident-logsys  = bkpf-awsys.                        "Note753505

*----------------------------------------------------------------------
* Line item Display: 'BSEG' has to be published to support workflow,
* publishing of additional objects will be carried out in method
* GOSADDOBJECTS (RFBKPF00). For BSEG, we need the line item number
* P_ITEM (not relevant for ALV document overview !)
* For other purposes, we also need BKPF-AWKEY etc.
* Data has to be transferred to method GOSADDOBJECTS via a
* EXPORT TO SHARED BUFFER statement, as all other methods (export
* to memory, set/get parameter id) will NOT work. Reason:
* Object GOS_ICON is created with parameter IP_NO_COMMIT = 'R',
* which employs a RFC(!) call (destination NONE) to allow for a COMMIT
* WORK in its own process.
*----------------------------------------------------------------------

  concatenate objectident-objkey sy-uname(6) into
  indxkey.                    .        " use specifc index to avoid
  " problems with parallel display

  export bkpf-awkey bkpf-awtyp bkpf-awsys bkpf-xblnr bkpf-bstat
         bkpf-bvorg bkpf-ppnam p_item
         to shared buffer rfdt(cb) id indxkey.

  indarl+00(04) = bkpf-bukrs.                                  "1090416
  indarl+04(10) = bkpf-belnr.                                  "1090416
  indarl+14(04) = bkpf-gjahr.                                  "1090416

  EXPORT taccdn-archiv_key taccdn-offst                        "1090416
         TO SHARED BUFFER rfdt(cb) ID indarl.                  "1090416


*--------------------------------------------------------------------
* Method GOSADDOBJECTS in RFBKPF00 will publish object BSEG
* only if a workflow menu option is picked in the generic object icon.
* This is the only context in which object BSEG is used,
* it is not used for any other purposes (and not intended to be used
* anywhere else). Method GOSADDOBJECTS also takes care of publishing
* objects like FIPP (workflow) and the appropriate object-IDs.
* If an object link is not visible in GOS icon, check with RFBKPF00 !
*--------------------------------------------------------------------

*--------------------------------------------------------------------
* Authorization check: If user lacks authorization for a SINGLE line
* item, no access to attachment list will be granted.
*-------------------------------------------------------------------

  refresh lt_services.
  clear ls_service.
  clear rc.

* --Table GT_MISSING_AUTH is already known at this point.

  loop at gt_missing_auth where bukrs eq p_bukrs and
                                belnr eq p_belnr and
                                dash = c_dash.
    exit.
  endloop.

* ------ authority missing for a single line item ?

  if gt_missing_auth-dash eq c_dash.
    ls_service-sign = 'E'.
    ls_service-option = 'EQ'.
    ls_service-low = 'VIEW_ATTA'.
* Service names (table SGOSATTR): WF_OVERVIEW, SRELATIONS etc.
    append ls_service to lt_services.
    clear rc.
  endif.

* -------- refresh icon

  perform unpublish_icon.

* -------- Define IP_NO_COMMIT (Note 1033419) --------------------------
* If a document is called by a CALL DIALOG (eg. line items display),
* the COMMIT WORK within GOS is effectless. In such cases the reference
* has to be created with P_NO_COMMIT equal 'R'.

*(del)  IF sy-tcode(3) = 'FBL'.                           "Note1123903
  IF sy-oncom EQ 'N'.        "('N' = CALL DIALOG)         "Note1123903
    l_ip_no_commit = 'R'.
  ELSE.
    CLEAR l_ip_no_commit.
  ENDIF.

* -------- publish new icon

  create object gos_icon
    exporting
      is_object            = objectident
      it_service_selection = lt_services
*(del)      ip_no_commit         = 'R'       " allows for a db commit in
*(del)                                       " own roll area (RFC!)
*(del)     IP_NO_COMMIT         = ' '        "Note 979455/Note 1033419
      ip_no_commit         = l_ip_no_commit  "Note 1033419
  exceptions
     others = 1.

* -------- catch exceptions

  if sy-subrc ne 0.
* do nothing
  else.
    clear p_rcode.
  endif.

endform.                               " publish_doc_icon
*&---------------------------------------------------------------------*
*&      Form  unpublish_icon
*&---------------------------------------------------------------------*
*     Created by note 402273
*----------------------------------------------------------------------*
form unpublish_icon.

* Unpublish to avoid duplicate icons or icons on screens where they
* don't belong....

  if not gos_icon is initial.
* flush here to avoid duplicate icons in case object gets published
*    CALL METHOD CL_GUI_CFW=>FLUSH.
    call method gos_icon->unpublish.
    clear gos_icon.
  endif.

endform.                               " unpublish_icon
*&---------------------------------------------------------------------*
*&      Form  record_sender
*&---------------------------------------------------------------------*
*  <--  p2        text
*----------------------------------------------------------------------*
form record_sender .
        call function 'AC_DOCUMENT_SENDER'
          exporting
            i_awsys                      = xbkpf-awsys
            i_awtyp                      = xbkpf-awtyp
            i_awref                      = xbkpf-awkey+00(10)
            i_aworg                      = xbkpf-awkey+10(10)
          exceptions
            awtyp_not_found              = 1
            no_document_display_function = 2.
        if sy-subrc ne 0.
          message i654(c+).
        endif.

endform.                    " record_sender
