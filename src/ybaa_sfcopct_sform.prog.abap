*&---------------------------------------------------------------------*
*& Report  AA_SFCOPCT_SFORM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  YBAA_SFCOPCT_SFORM MESSAGE-ID CO.
*---------------------------------------------------------------------*
*                                                                     *
* PPS-Print: Control-Ticket (Steuerkarte)                             *
*                                                                     *
*---------------------------------------------------------------------*

*********************************************************************
* hard code form name since PP config does not support SMARTFORMS
*********************************************************************
*!!!!! Hier YB_xxx Formularnamen fest hinterlegen
*DATA: lf_formname           TYPE tdsfname value '/SMB15/AA_PROD_ORD'.
DATA: lf_formname           TYPE tdsfname value 'YBAA_PROD_ORD'.
*********************************************************************
*********************************************************************
*********************************************************************

* DATA-Statements general
INCLUDE PPCOINCL.
* DATA-Statements specific for production orders
INCLUDE CODRGT10.



TABLES: nast,                          "Messages
        *nast,                         "Messages
        tnapr,                         "Programs & Forms
        itcpo,                         "Communicationarea for Spool
        arc_params,                    "Archive parameters
        toa_dara,                      "Archive parameters
        addr_key.                      "Adressnumber for ADDRESS
TABLES: MARA.
*  Material Master Info for every PO
DATA WA_MARA LIKE MARA.
*  help stucture for operation Short text
DATA WA_LTXA1A TYPE C LENGTH 20.
DATA WA_LTXA1B TYPE C LENGTH 20.
*  Ranger of Serail Number
DATA WA_SERNR_HI TYPE C LENGTH 18.  "The largest Serial Number
DATA WA_SERNR_LO TYPE C LENGTH 18.  "The smallest Serial Number
DATA WA_TABIX LIKE SY-TABIX.
*  Processing Time
DATA WA_AUFZT LIKE AFVGD-VGW03.

DATA: retcode   LIKE sy-subrc.         "Returncode
DATA: xscreen(1) TYPE c.               "Output on printer or screen
data: is_afpod type afpod,                                  "position 1
      it_afpod like afpod occurs 10, "positions
      it_afvgd like afvgd occurs 50, "OPS
      IT_AFFLD LIKE AFFLD OCCURS 50, "SEQUENCES
      IT_RESBD LIKE RESBD OCCURS 50, "components
      IT_AFFHD LIKE AFFHD OCCURS 50, "PRT
      IT_CHARAC LIKE SFC_CONF OCCURS 50,"configuration
      IT_COLORD LIKE PPPRCOLORD OCCURS 50,"coll orde
      IT_SEROB LIKE RSEROB OCCURS 50,"serialnumbers
      IT_AFDLD LIKE AFDLD occurs 50, "DOCS
      it_rcr01 like rcr01 occurs 50. "work centers



* entry to print
PERFORM PRINT_SUB.

*---------------------------------------------------------------------*
*       FORM PRINT_SUB                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM PRINT_SUB.
* Document-tables
  INCLUDE LCODRINC.

  LOOP AT ITAB_TDR WHERE OBJECT = OBJ-POS
                   OR    OBJECT = OBJ-SOP
                   OR    OBJECT = OBJ-FHM
                   AND   AUFNR  = PRINT_CO-AUFNR.           "New 3.0
    EXIT.
  ENDLOOP.

  CHECK SY-SUBRC IS INITIAL.

  CLEAR:it_afpod,  "positions
        it_afvgd,
        IT_RESBD,  "comps
        it_afvgd, "OPS
        IT_AFFLD, "SEQUENCES
        IT_RESBD, "components
        IT_AFFHD, "PRT
        IT_CHARAC,"configuration
        IT_COLORD,"coll orde
        IT_SEROB,"serialnumbers
        it_rcr01,"workcenter
        IT_AFDLD. "DOCS

* fill workarea of header (probably more than 1 order is to be printed)
  LOOP AT ITAB_TDR WHERE OBJECT = OBJ-ALT
                   AND   AUFNR  = PRINT_CO-AUFNR.           "New 3.0
* Save Indextable of header
    ITAB_ORD = ITAB_TDR.

    LOOP AT CAUFVD_TAB WHERE AUFNR = ITAB_TDR-AUFNR.
      PERFORM PPPR_STD_INIT_ORDER USING CAUFVD_TAB.

* Get position
      loop at AFPOD_TAB where AUFNR = CAUFVD-AUFNR.
        if afpod_tab-POSNR = '0001'.
          is_AFPOD = AFPOD_TAB.
        endif.
        append afpod_tab to it_afpod.
      endloop.

* GET SEQUENCES
      loop at affld_tab where  AUFPL = caufvd-AUFPL.
        append affld_tab to it_affld.
      endloop.

* get ops
      loop at afvgd_tab where   AUFPL = caufvd-AUFPL.
        append afvgd_tab to it_afvgd.

* get work center
        loop at work_tab where arbid = afvgd_tab-arbid.
          append work_tab to it_rcr01.
        endloop.
      endloop.

* GET COMPONENT DATA
      LOOP AT RESBD_TAB WHERE RSNUM = CAUFVD-RSNUM.
        APPEND RESBD_TAB TO IT_RESBD.

      ENDLOOP.

* get docs
      LOOP AT afdld_TAB WHERE aufnr = CAUFVD-aufnr.
        APPEND afdld_TAB TO IT_afdld.
      ENDLOOP.

* get prts
      loop at affhd_tab where  AUFPL = caufvd-AUFPL.
        append affhd_tab to it_affhd.
      endloop.

* get configuration
      loop at charac_tab where cuobj = afpod-CUOBJ.
        append charac_tab to it_charac .
      endloop.


*  Get MATERIAL Data
      CLEAR WA_MARA.
      SELECT SINGLE *
        FROM MARA INTO CORRESPONDING FIELDS OF WA_MARA
        WHERE MATNR = CAUFVD-MATNR.

* GET SERIAL NUMBER DATA
      CLEAR WA_SERNR_HI.
      CLEAR WA_SERNR_LO.
      CLEAR WA_TABIX.
      LOOP AT SEROB_TAB WHERE PPAUFNR EQ CAUFVD_TAB-AUFNR.
        IF SY-TABIX = 1.
          WA_SERNR_LO = SEROB_TAB-SERNR.
        ENDIF.
        WA_TABIX = SY-TABIX.
      ENDLOOP.
      IF WA_TABIX NE 1.
        WA_SERNR_HI = SEROB_TAB-SERNR.
      ENDIF.

* Do Printing
      DO PRINT_CO-COPYS TIMES.
        IF SY-INDEX GT 1.
          MOVE TEXT-DUP TO PRINT_CO-DRTXT.
        ENDIF.


* get doc links
*      PERFORM get_doclinks.


* print Operations
        PERFORM PRINT_smartform.



      ENDDO.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    "PRINT_SUB
********************************************************
*****************************
INCLUDE CODRGETT.         "PPPR-Form-Routinen: pppr_get_tables
INCLUDE CODRIF01.         "PPPR-Form-Routinen: Druck-Parts lesen
INCLUDE CODRIF04.         "PPPR-Form-Routinen: read_mat
*INCLUDE CODRIF09.         "PPPR-Form-Routinen: print_prt_to_opr
INCLUDE CODRIF17.         "PSFC-Form-Routinen: std_init_operation



*&--------------------------------------------------------------------*
*&      Form  PRINT_SMARTFORM
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM PRINT_SMARTFORM.
  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_control_param      TYPE ssfctrlop.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: ls_recipient          TYPE swotobjid.
  DATA: ls_sender             TYPE swotobjid.
* DATA: lf_formname           TYPE tdsfname.
  DATA: ls_addr_key           LIKE addr_key.
  data: ls_job_info           type ssfcrescl.
  data: l_spoolid             type rspoid.

  CHECK retcode = 0.
  PERFORM set_print_param USING      ls_addr_key
                            CHANGING ls_control_param
                                     ls_composer_param
                                     ls_recipient
                                     ls_sender
                                     retcode.

* PP does not support smartforms in the config table
* smartform is hardcoded in program

**Get the Smart Form name.
*  IF NOT tnapr-sform IS INITIAL.
*    lf_formname = tnapr-sform.
*  ELSE.
*    MESSAGE e001(ssfcomposer).
*  ENDIF.

* determine smartform function module
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
       EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
       IMPORTING  fm_name            = lf_fm_name
       EXCEPTIONS no_form            = 1
                  no_function_module = 2
                  OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    retcode = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(ssfcomposer).
    ENDIF.
    PERFORM protocol_update.
  ENDIF.


  CALL FUNCTION lf_fm_name
    EXPORTING
       archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
       archive_parameters         = arc_params
       control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
       mail_recipient             = ls_recipient
       mail_sender                = ls_sender
       output_options             = ls_composer_param
       user_settings              = ' '
       it_caufvd                  = caufvd_tab    "header
       is_AFPOD                   = is_AFPOD       "item
       it_PSFC_HEAD               = PSFC_HEAD   "header text
       is_sernr_hi                = WA_SERNR_HI
       is_sernr_lo                = WA_SERNR_lo
*         IT_AFDLD                   = AFDLD_p_tab[]
*         is_mseg                       = mseg
*         is_ekpo                       = ekpo
*         is_t157e                      = t157e
*         is_am07m                      = am07m
*         is_mkpf                       = mkpf
*         is_nast                       = nast
*         is_t159p                      =  t159p
*         is_t001w                      = t001w
*         is_ekko                       = ekko
*         is_t024                       = t024
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
tables
  it_afpod                   = it_afpod         "positions
  it_afvgd                   = it_afvgd         "ops
  IT_AFDLD                   = it_afdld         "docs
  IT_AFFLD                   = IT_AFFLD "SEQ
  IT_RESBD                   = IT_RESBD "components
  IT_AFFHD                   = IT_AFFHD "PRT
  IT_CHARAC                  = IT_CHARAC "configuration
  IT_COLORD                  = IT_COLORD "coll orde
  IT_SEROB                   = IT_SEROB "serialnumbers
  it_rcr01                   = it_rcr01 " work centers
EXCEPTIONS
 formatting_error           = 1
 internal_error             = 2
 send_error                 = 3
 user_canceled              = 4
 OTHERS                     = 5
            .
  IF sy-subrc <> 0.
    retcode = sy-subrc.
    PERFORM protocol_update.
* get SmartForm protocoll and store it in the NAST protocoll
    PERFORM add_smfrm_prot.
  else.
    read table ls_job_info-spoolids into l_spoolid index 1.
    if sy-subrc is initial.
      export spoolid = l_spoolid to memory id 'KYK_SPOOLID'.
    endif.

  ENDIF.

ENDFORM.                    "PRINT SMARTFORM






************************************
* STANDARD SMARTFORM FORM ROUTINES *
************************************

*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

FORM protocol_update.

  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                    "protocol_update


*&---------------------------------------------------------------------*
*&      Form  set_print_param
*&---------------------------------------------------------------------*
FORM set_print_param USING    is_addr_key LIKE addr_key
                     CHANGING cs_control_param TYPE ssfctrlop
                              cs_composer_param TYPE ssfcompop
                              cs_recipient TYPE  swotobjid
                              cs_sender TYPE  swotobjid
                              cf_retcode TYPE sy-subrc.

  DATA: ls_itcpo     TYPE itcpo.
  DATA: lf_repid     TYPE sy-repid.
  DATA: lf_device    TYPE tddevice.
  DATA: ls_recipient TYPE swotobjid.
  DATA: ls_sender    TYPE swotobjid.

  lf_repid = sy-repid.

  CALL FUNCTION 'WFMC_PREPARE_SMART_FORM'
    EXPORTING
      pi_nast       = nast
      pi_addr_key   = is_addr_key
      pi_repid      = lf_repid
    IMPORTING
      pe_returncode = cf_retcode
      pe_itcpo      = ls_itcpo
      pe_device     = lf_device
      pe_recipient  = cs_recipient
      pe_sender     = cs_sender.

  IF cf_retcode = 0.
    MOVE-CORRESPONDING ls_itcpo TO cs_composer_param.
*    cs_composer_param-tdnoprint = 'X'.                     "Note 591576
    cs_control_param-device      = lf_device.
    cs_control_param-no_dialog   = 'X'.
    cs_control_param-preview     = xscreen.
    cs_control_param-getotf      = ls_itcpo-tdgetotf.
    cs_control_param-langu       = nast-spras.
  ENDIF.
ENDFORM.                    "set_print_param

*&---------------------------------------------------------------------*
*&      Form  add_smfrm_prot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_smfrm_prot.
  DATA: lt_errortab             TYPE tsferror.
  DATA: lf_msgnr                TYPE sy-msgno.
  DATA:  l_s_log                TYPE bal_s_log,
         p_loghandle            TYPE balloghndl,
         l_s_msg                TYPE bal_s_msg.
  FIELD-SYMBOLS: <fs_errortab>  TYPE LINE OF tsferror.

* get smart form protocoll
  CALL FUNCTION 'SSF_READ_ERRORS'
    IMPORTING
      errortab = lt_errortab.

* add smartform protocoll to nast protocoll
  LOOP AT lt_errortab ASSIGNING <fs_errortab>.
    CLEAR lf_msgnr.
    lf_msgnr = <fs_errortab>-errnumber.
    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
      EXPORTING
        msg_arbgb = <fs_errortab>-msgid
        msg_nr    = lf_msgnr
        msg_ty    = <fs_errortab>-msgty
        msg_v1    = <fs_errortab>-msgv1
        msg_v2    = <fs_errortab>-msgv2
        msg_v3    = <fs_errortab>-msgv3
        msg_v4    = <fs_errortab>-msgv4
      EXCEPTIONS
        OTHERS    = 1.
  ENDLOOP.
* open the application log
  l_s_log-extnumber    = sy-uname.
  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log      = l_s_log
    IMPORTING
      e_log_handle = p_loghandle
    EXCEPTIONS
      OTHERS       = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT lt_errortab ASSIGNING <fs_errortab>.
    MOVE-CORRESPONDING <fs_errortab> TO l_s_msg.
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle = p_loghandle
        i_s_msg      = l_s_msg
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDLOOP.

** Function module to display error logs during
** smart form processing
** Notice , the function 'BAL_DSP_LOG_DISPLAY' can
** not be used when you using output dispatch time
** 4 (Send immediately), so the statement is comment
** out by default.

** You can enable the function call statement
** if your form can not be output and you want to
** see the error log. Set output dispatch time to 3
** before save your order, then print or preview the
** output.

  DATA lv_debug.
  IF NOT lv_debug IS INITIAL.
    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
  ENDIF.

ENDFORM.                               " add_smfrm_prot
