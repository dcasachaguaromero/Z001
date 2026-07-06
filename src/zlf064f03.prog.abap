*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   INCLUDE LF064F03                                                   *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM READ_CROSS_COMPANY_DOCUMENTS                             *
*---------------------------------------------------------------------*
*    read all documents and line items of a cross-company code        *
*    transaction                                                      *
*---------------------------------------------------------------------*
form read_cross_company_documents using p_bvorg like bkpf-bvorg.
  data: abkpf type table of abkpf.     " Note 0424402
  data: l_gjahr like bkpf-gjahr.       " Note 0424402
*  data: l_farc_xread like  farc_xread. " Note 0424402

  refresh xbkpf.
  refresh xbseg.
  refresh gt_missing_auth.
  select * from bvor into table ybvor where bvorg = p_bvorg.

* ---- Read  completely archived cross company documents  (Note 0424402)
  if sy-dbcnt eq 0.

* Determine fiscal year from two-digit year in BVOR-BVORG
    if p_bvorg+14(2) co '1234567890'.
      concatenate sy-datum(2) '00' into l_gjahr.
      if p_bvorg+14(2) gt sy-datum+2(2).
        l_gjahr = l_gjahr - 100 + p_bvorg+14(2).
      else.
        l_gjahr = l_gjahr + p_bvorg+14(2).
      endif.
    else.
* Right now, we cannot retrieve documents with alphanumerical external
* document number assignment.
      message e422(f5) with p_bvorg raising display_not_possible.
    endif.
* ERP05 replace obsolet functions
*    l_farc_xread-xbvor = c_x.
*    call function 'FI_DOCUMENT_ARCH_READ_SINGLE'
*      exporting
*        i_bukrs       = p_bvorg+10(4)
*        i_belnr       = p_bvorg(10)
*        i_gjahr       = l_gjahr
*        i_group_xread = l_farc_xread
*      tables
*        c_abkpf       = abkpf
*        c_bvor        = ybvor
*      exceptions
*        others        = 7.
    CALL FUNCTION 'FAGL_GET_ARCH_FI_DOCUMENT'
      EXPORTING
        i_bukrs                  = p_bvorg+10(4)
        i_belnr                  = p_bvorg(10)
        i_gjahr                  = l_gjahr
      TABLES
        T_BKPF                   = abkpf
        T_BVOR                   = ybvor
       EXCEPTIONS
       OTHERS                   = 3.

    if sy-subrc <> 0.
      message e422(f5) with p_bvorg raising display_not_possible.
*      MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    else.
      ybvor-xarch = c_x.
      modify ybvor transporting xarch where xarch ne c_x.
    endif.
  endif.
* ---- End of note Note 0424402

  loop at ybvor.                       " Note 390061
    perform beleg_lesen_cc using ybvor-belnr ybvor-bukrs ybvor-gjahr
                                 ybvor-xarch.
  endloop.

  if sy-subrc ne 0.
    message e422(f5) with p_bvorg raising display_not_possible.
  endif.

* ----- check authorizations on line item level ----------(Note 0411411)

  loop at xbseg.
* (del) perform berechtigungen changing rcode.              "Note449741
    perform berechtigungen                                  "Note449741
            using space                                     "Note449741
                  g_aktyp                                   "Note449741
            changing rcode.                                 "Note449741
    if rcode = 0.
      if xbseg-shkzg = 'H'.
        perform change_sign.
        modify xbseg.
      endif.
    else.
      move-corresponding xbseg to gt_missing_auth.
      gt_missing_auth-dash = c_dash.
      gt_missing_auth-semicolon = c_semicolon.
      append gt_missing_auth.
      delete xbseg.                                         "Note407495
      rcode = 0.
    endif.
  endloop.

* -------------- get account texts ------------------------------------

  loop at xbseg.
    perform fill_ktext_konto_faedt.
    modify xbseg.
  endloop.

endform.                               "read_cross_company_documents



*---------------------------------------------------------------------*
*       FORM CROSS_COMPANY_LIST_DISPLAY                               *
*---------------------------------------------------------------------*
*   display cross-company code transaction                            *
*---------------------------------------------------------------------*
form cross_company_list_display.

  data: l_lines_missing_auth type i,
        l_missing_lines(70),
        l_perform.
  data: l_save(1) type c value c_a.    "Authority to save?  Note 319936


  l_perform = c_yes.

  describe table gt_missing_auth lines l_lines_missing_auth.

  if l_lines_missing_auth > 0.
    loop at gt_missing_auth.
      concatenate l_missing_lines gt_missing_auth
                  into l_missing_lines
                  separated by space.
    endloop.

    call function 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         exporting
*         DEFAULTOPTION  = 'Y'
              diagnosetext1  = text-030
              diagnosetext2  = l_missing_lines
*         DIAGNOSETEXT3  = ' '
              textline1      = text-031
*         TEXTLINE2      = ' '
              titel          = text-032
*         START_COLUMN   = 25
*         START_ROW      = 6
              cancel_display = ' '
         importing
              answer         = l_perform
              .
  endif.

  if l_perform = c_yes.
    perform check_layout_auth using l_save l_save.         "Note 319936
    set parameter id 'VRG' field bvorg.
    call function 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
         exporting
*         I_INTERFACE_CHECK        = ' '
              i_callback_program       = 'SAPLF064'
              i_callback_pf_status_set = 'PF_STATUS_SET'
              i_callback_user_command  = 'HANDLE_USER_COMMAND'
              is_layout                = layout
              it_fieldcat              = fieldcat
              i_default                = 'X'
* (del)       i_save                   = 'A'               "Note 319936
              i_save                   = l_save            "Note 319936
              is_variant               = variant
              it_events                = events
*         IT_EVENT_EXIT            =
              i_tabname_header         = 'XBKPF'
              i_tabname_item           = 'XBSEG'
*         I_STRUCTURE_NAME_HEADER  =
*         I_STRUCTURE_NAME_ITEM    =
              is_keyinfo               = gs_keyinfo
              is_print                 = gs_print
*         IS_REPREP_ID             =
         tables
              t_outtab_header          = xbkpf
              t_outtab_item            = xbseg
         exceptions
              program_error            = 1
              others                   = 2
              .
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

endform.                               "cross_company_list_display
*&---------------------------------------------------------------------*
*&      Form  PREPARE_CROSS_COMPANY_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form prepare_cross_company_display.

  clear gs_keyinfo.
  gs_keyinfo-header01 = 'BUKRS'.
  gs_keyinfo-item01   = 'BUKRS'.
  gs_keyinfo-header02 = 'BELNR'.
  gs_keyinfo-item02   = 'BELNR'.
  gs_keyinfo-header03 = 'GJAHR'.
  gs_keyinfo-item03   = 'GJAHR'.
  gs_keyinfo-item04   = 'BUZEI'.

endform.                               " PREPARE_CROSS_COMPANY_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  DEFINE_STRUCTURES_CC_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form define_structures_cc_display.

*------------- Vorbereitungen für ALV ----------------------------------
*------------------ Anzeigevarianten -----------------------------------
  variant-report         = 'SAPLF064'.
  variant-username       = sy-uname.

*-------------- Verschiedene Keys für die Aufrufe ----------------------
  variant-handle = 'BKPF'.
  clear variant-variant.                                    "Note 443989

*----------------- Einstiegsvariante ermitteln -------------------------
  call function 'REUSE_ALV_VARIANT_DEFAULT_GET'
    exporting
*     I_SAVE        = 'X'
      i_save        = 'A'
    changing
      cs_variant    = variant
    exceptions
      wrong_input   = 1
      not_found     = 2
      program_error = 3
      others        = 4.
  if sy-subrc ne 0.
    variant-variant = '0SAP'.          "Diese Variante ist ausgeliefert
  endif.

*------------------- Layout --------------------------------------------
  clear layout.                                             "Note 443989
  layout-zebra           = 'X'.
  clear layout-no_min_linesize.
  layout-min_linesize    = '100'.
  layout-f2code          = 'DETA'.
  layout-key_hotspot     = 'X'.
  layout-info_fieldname  = 'COLOR'.
  layout-coltab_fieldname = 'COLFW'.
  layout-expand_fieldname = 'EXPAND'.

*------------------ Kopfanzeige und Fußzeile via Eventsteuerung --------
  refresh events.
  clear events_wa.
  events_wa-name = 'TOP_OF_PAGE'.
  events_wa-form = 'DISPLAY_CC_HEADER'.
  append events_wa to events.
  events_wa-name = 'END_OF_LIST'.
  events_wa-form = 'BELEGSALDO'.
  append events_wa to events.
endform.                               " DEFINE_STRUCTURES_CC_DISPLAY


*---------------------------------------------------------------------*
*       FORM DISPLAY_CC_HEADER                                        *
*---------------------------------------------------------------------*
*  Display header via event TOP_OF_PAGE                               *
*---------------------------------------------------------------------*
form display_cc_header.
  new-line no-scrolling.
  write at (85) sy-uline.
  write at  86  sy-vline.

*---------- Allgemeine Infos -------------------------------------------
  new-line no-scrolling.
  write sy-vline.
  select single * from  t003t
         where  spras       = sy-langu
         and    blart       = bkpf-blart     .
  format color col_heading intensified on.
  write at 3(80)  t003t-ltext.
  write at 86 sy-vline.

  format reset.
  if bkpf-bstat ne space.
    new-line no-scrolling.
    write sy-vline.
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
    write at 3(40) anzst.
    write at 86 sy-vline.
  endif.

*------------ second line ----------------------------------------------
  new-line no-scrolling.
  write sy-vline.
  write at 3(15) text-008.
  write at 19(16) bkpf-bvorg.
  write at 38(15) text-009.
  write at 53(16) bkpf-waers.
  write at 86 sy-vline.

*--------------- Abschluß ----------------------------------------------
  new-line no-scrolling.
  write at (86) sy-uline.
  skip 1.

endform.                    "display_cc_header

*---------------------------------------------------------------------*
*       FORM BELEG_LESEN_CC                                           *
*---------------------------------------------------------------------*
*   read all documents involved in cross-company code transaction     *
*---------------------------------------------------------------------*

form beleg_lesen_cc using p_belnr like bkpf-belnr
                          p_bukrs like bkpf-bukrs
                          p_gjahr like bkpf-gjahr
                          p_xarch like bvor-xarch.

* form recently changed by note 390061

* ----- data declarations

*  data: l_group_xreadall like farc_xread
*        value 'XXXXXXXXXXXXXXXXXXXXXX'.                    "ERP05
  data: l_archbkpf type abkpf occurs 0 with header line. " dummy

* ------ delete internal tables xbkpf (header) and xbseg (line items)

  delete xbkpf where belnr = p_belnr and bukrs = p_bukrs
                 and gjahr = p_gjahr.
  delete xbseg where belnr = p_belnr and bukrs = p_bukrs
                 and gjahr = p_gjahr.

* ------- get header information first from database or archive

  call function 'READ_DOCUMENT_HEADER'
       exporting
            belnr          = p_belnr
            bukrs          = p_bukrs
            gjahr          = p_gjahr
            xbstv          = 'X'
            xbstd          = 'X'
            xbstm          = 'X'
            xarch          = p_xarch
       importing
            e_bkpf         = bkpf
*           e_archived     = l_archived
       tables
            t_accdn        = taccdn
       exceptions
            exit           = 4
            not_found      = 8
            archive_cancel = 12
            others         = 16.

* -------- document header found / not found ?

  case sy-subrc.
    when 0.
    when 4.
      message e429 with p_belnr p_bukrs raising display_not_possible.
    when 8.
      message e429 with p_belnr p_bukrs raising display_not_possible.
    when 12.
      message e881 with p_belnr p_bukrs raising display_not_possible.
    when others.
      message a370 with 'READ_DOCUMENT_HEADER'
                   raising display_not_possible.
  endcase.

* ------ fill internal table xbkpf with header information

  clear:   xbkpf.
  clear:   xbseg.
  move-corresponding bkpf to xbkpf.
  xbkpf-expand = 'X'.
  append xbkpf.
  rcode = 0.

* ------ get line items: document in database?

  if p_xarch is initial.
select * from bseg
where bukrs = bkpf-bukrs
and belnr = bkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES01 ECDK917080 *
*and gjahr = bkpf-gjahr .
AND GJAHR = BKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES01 ECDK917080 *
      move-corresponding bseg to xbseg.
      append xbseg.
    endselect.

  else.

* ----- get line item : document in archive ?
* ERP05 replace old access to archive
*    call function 'FI_DOCUMENT_READ_SINGLE'
*      exporting
*        i_bukrs           = bkpf-bukrs
*        i_belnr           = bkpf-belnr
*        i_gjahr           = bkpf-gjahr
*        i_group_xread     = l_group_xreadall
*        i_xuse_database   = space
*        i_xsuppressdialog = c_x
*      tables
*        c_bseg            = archbseg
*        c_abkpf           = l_archbkpf
*      exceptions
*        others            = 99.

      CALL FUNCTION 'FAGL_GET_ARCH_FI_DOCUMENT'
        EXPORTING
          i_bukrs            = bkpf-bukrs
          i_belnr            = bkpf-belnr
          i_gjahr            = bkpf-gjahr
        TABLES
          t_bkpf             = l_archbkpf
          t_bseg             = archbseg
        EXCEPTIONS
          error_message      = 01
          document_not_found = 02.
* ----- check for exceptions

    if sy-subrc ne 0.
        MESSAGE s397(f5a) WITH bkpf-belnr bkpf-bukrs bkpf-gjahr.
    endif.

* ----- fill internal table xbseg with line item information

    loop at archbseg.
      move-corresponding archbseg to xbseg.
      append xbseg.
    endloop.
  endif.

endform.                               " BELEG_LESEN_CC
