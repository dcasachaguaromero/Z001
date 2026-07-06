*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report J_1AAINFL_REVERSE with ALV
*& Mass Reversal of data.
*&---------------------------------------------------------------------*

REPORT  z_1aainfl_reverse NO STANDARD PAGE HEADING MESSAGE-ID 8z.

NODES:  anla0,
        anlav,             " Asset Master rec.: ANLA-Felder + Kst...
        anlb,              " Depreciation terms
        anek,              " Document Header Asset Posting
        anepv.             " Asset Line Items
TABLES: tabw,              " Asset transaction types
        tabwg,             " Transaction type groups
        j_1aat089.         " Inflation areas

* Global structure of list for ALV ==================================
TYPE-POOLS: slis.

* Global data declaration ============================================

* Internal tables  --------------
DATA:   BEGIN OF gt_outtab OCCURS 0.    " Internal table
        INCLUDE STRUCTURE anek.
DATA:   anbtr LIKE anepv-anbtr.         " amount posted
DATA:   afabe LIKE anepv-afabe.
DATA:   mark(1),                        " Additional field for selection
        lights,                         " Traffic light
        revyes TYPE i.                  " indicator for reversal.
DATA:   END OF gt_outtab.               " end of Internal table

DATA: wa_anek  LIKE gt_outtab OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF r_ttype OCCURS 10.        " table for trans.type
DATA:      bwasl LIKE tabw-bwasl,
           bwatyp LIKE tabwg-bwatyp.
DATA: END   OF r_ttype.

* global variables  -------------
DATA:   gt_fieldcat TYPE slis_t_fieldcat_alv,
        g_repid LIKE sy-repid,
        g_status TYPE slis_formname VALUE 'SEL_ST_ALV',
        gs_layout TYPE slis_layout_alv,
        g_user_command TYPE slis_formname VALUE 'USER_COMMAND',
        g_save(1) TYPE c,
        g_variant LIKE disvariant.

DATA: tindex TYPE i, selind TYPE c.
DATA: lt_acchd     LIKE acchd     OCCURS 0 WITH HEADER LINE,
      lt_accit     LIKE accit     OCCURS 0 WITH HEADER LINE,
      lt_acccr     LIKE acccr     OCCURS 0 WITH HEADER LINE,
      lt_accda     LIKE accda     OCCURS 0 WITH HEADER LINE,
      lt_bapiret2  LIKE bapiret2  OCCURS 0 WITH HEADER LINE,
      lf_belnr     LIKE bkpf-belnr,      " Doc. nummer from BKPF
      in_awk       LIKE bkpf-awkey.

DATA:  f_date  LIKE sy-datum,
       f_last_day LIKE sy-datum,
       f_periv LIKE t001-periv,
       f_perid LIKE t009-anzbp,
       f_gjahr LIKE anbz-gjahr,
       f_gjahr1 LIKE anbz-gjahr,
       f_diff  LIKE anbz-gjahr.
DATA:  counter TYPE i,
       in_revyes TYPE i.                  " indicator for reversal.

DATA:  l_abgja LIKE t093b-abgja.
DATA:  l_afapl LIKE t093c-afapl.
DATA:  L_ANLN1_INIT LIKE ANLA-ANLN1,                        "Note 777092
       L_ANLN2_INIT LIKE ANLA-ANLN2.                        "Note 777092

CONSTANTS:
       l_tcode TYPE anek-tcode VALUE 'AB08',   " assign name to trans.
       l_bwatyp TYPE tabwg-bwatyp VALUE '6'.   " Set T.Type

*   Data definition for authority-check
INCLUDE lafarcon.

* ================= select parameters via Sel.Screen =============

SELECTION-SCREEN BEGIN OF BLOCK b_001 WITH FRAME TITLE text-001.
SELECT-OPTIONS  so_budat FOR  wa_anek-budat
                      OBLIGATORY.
SELECT-OPTIONS  so_bwatp FOR tabwg-bwatyp no-display.
SELECTION-SCREEN END OF BLOCK b_001.

*-----------------------------------------------------------------
* Initialization fieldcatalog
INITIALIZATION.

  g_repid = sy-repid.                " current main program
* Fill field catalog.
  PERFORM fieldcat_init USING gt_fieldcat[].
* Build layout.
  gs_layout-box_fieldname = 'MARK'.  " int.table field 4 chkbx
  gs_layout-zebra    = 'X'.
  bereich1 = '*'. " Default value
  so_bwatp-low    = l_bwatyp.
  so_bwatp-sign   = 'I'.
  so_bwatp-option = 'EQ'.
  APPEND so_bwatp.

* Hide fields in ADA selection screen.
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = 'BUKRS-HIGH'               OR
       screen-name ='%_BUKRS_%_APP_%-VALU_PUSH' OR
       screen-name CS 'SRTVR'                   OR
       screen-name = '%F303079_1000'            OR
       screen-name CS 'XEINZEL'                 OR
       screen-name CS 'UMVAR'                   OR
       screen-name = '%F304084_1000'            OR
       screen-name CS 'XUNTNR'                  OR
       screen-name CS 'SUMMB'                   OR
       screen-name CS '%BBL2064_BLOCK_1000'     OR
       screen-name CS 'BER'                     OR
       screen-name CS '%F020070_1000'           OR
       screen-name CS 'SRT_TXT'                 OR
       screen-name CS 'UMV_TXT'.
      screen-input = '0'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

*******************************************************************
*** Check input data fields and authority *************************
* Make sure that the other's CC will not be modified.

AT SELECTION-SCREEN ON bukrs.

* Check if selected company code exist
  CALL FUNCTION 'FI_COMPANY_CODE_CHECK'
    EXPORTING
      i_bukrs      = bukrs-low
    EXCEPTIONS
      company_code = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    MESSAGE e165(f5) WITH bukrs-low RAISING system_error.
  ENDIF.

* Authority check for company code
  AUTHORITY-CHECK   OBJECT 'A_PERI_BUK'
                    ID     'AM_ACT_PER'  FIELD '41'
                    ID     'BUKRS'       FIELD bukrs-low.      "n.846432
  IF sy-subrc <> 0.
    MESSAGE e074(aa) WITH bukrs-low.
  ENDIF.

* Check if date is not in closed fisc. year.

AT SELECTION-SCREEN ON so_budat.

* Check if reversal is required for only one day.
  IF so_budat-high IS INITIAL.
    so_budat-high = so_budat-low.
  ENDIF.

* Closed fiscal year.
  SELECT SINGLE periv FROM t001 INTO f_periv
                WHERE bukrs EQ bukrs-low.         " get period variant
  SELECT SINGLE abgja FROM t093b INTO l_abgja
                WHERE bukrs EQ bukrs-low
                  AND afabe EQ bereich1.          " get closed f.yr.

* Get revaluation (depreciation) area from table j_1aat089.
  SELECT SINGLE afapl FROM t093c INTO l_afapl
                WHERE bukrs EQ bukrs-low.        " get chart of acc.

* Check lower Posting Date.
  f_date = so_budat-low.
  CALL FUNCTION 'DATE_TO_PERIOD_CONVERT'
    EXPORTING
      i_date  = f_date
      i_periv = f_periv
    IMPORTING
      e_buper = f_perid
      e_gjahr = f_gjahr.
  IF f_gjahr LT l_abgja.
    MESSAGE e745 WITH f_gjahr.
  ENDIF.

* Check upper Posting Date
  f_date = so_budat-high.
  CALL FUNCTION 'DATE_TO_PERIOD_CONVERT'
    EXPORTING
      i_date  = f_date
      i_periv = f_periv
    IMPORTING
      e_buper = f_perid
      e_gjahr = f_gjahr1.
* Make sure that the selected posting date are within the same f.year.
  f_diff = f_gjahr1 - f_gjahr .
  IF f_diff NE 0.
    MESSAGE e742.
  ENDIF.

* Get Reporting date as last day of the opened fiscal year.
  CALL FUNCTION 'FIRST_AND_LAST_DAY_IN_YEAR_GET'
    EXPORTING
      i_gjahr    = f_gjahr
      i_periv    = f_periv
    IMPORTING
      e_last_day = f_last_day.
* Assign Reporting Date.
  berdatum     = f_last_day.
* Assighn Trans.Type.

*** Check input data fields and authority - END *******************
*******************************************************************

* Data selection =============================================

START-OF-SELECTION.

** Create table r_ttype containing (bwasl) vs (bwatyp),
** (asset transaction type) vs (transaction type category)

  SELECT bwasl bwatyp INTO TABLE r_ttype
    FROM tabw INNER JOIN tabwg
    ON  tabw~bwagrp = tabwg~bwagrp.               "#EC CI_BUFFJOIN

  anla0-xepos = 'x'.   " note 502916, indicator for ADA

GET anla0.

GET anlav.

GET anlb.

GET anek.

  CHECK anek-budat IN so_budat.

GET anepv.

  CHECK anepv-anbtr IS NOT INITIAL.

* Check if data not yet reversed
  IF anepv-lnsan EQ 0.            " Append only not reversed docs

    MOVE-CORRESPONDING anepv TO gt_outtab.
    MOVE-CORRESPONDING anek TO gt_outtab. " must be last (belnr ovr.)

    in_revyes = 0 . " flag
    READ TABLE r_ttype WITH KEY bwasl = anepv-bwasl.
    IF r_ttype-bwatyp IN so_bwatp.
* Set indicator to 0 if reversal is allowed for this Trans.Type.
      gt_outtab-revyes = 0.
      in_revyes = 1 .
    ELSE.
      gt_outtab-revyes = 1.
    ENDIF.

* Append only data for selected transaction type
    IF in_revyes EQ 1.
      READ TABLE gt_outtab WITH KEY bukrs = anepv-bukrs
                                    anln1 = anepv-anln1
                                    anln2 = anepv-anln2
                                    gjahr = anepv-gjahr
                                    lnran = anepv-lnran.
      IF sy-subrc IS NOT INITIAL.
        APPEND gt_outtab.
      ENDIF.
    ENDIF.
  ENDIF. " IF anepv-lnsan EQ 0.

END-OF-SELECTION.
* End Data selection =============================================

** Set checkbox as selected
  LOOP AT gt_outtab.
    IF gt_outtab-revyes EQ 0.
      gt_outtab-mark = 'X'.
      MODIFY gt_outtab.
    ENDIF.
  ENDLOOP.

* ================================================================
  IF not gt_outtab[] IS initial.                         "Note 777092(b)
     CALL FUNCTION 'RA_ASSET_ENQUEUE'
           EXPORTING
                BUKRS   = BUKRS-LOW
                ANLN1   = L_ANLN1_INIT
                ANLN2   = L_ANLN2_INIT
                I_SCOPE = '2'.
  ENDIF.                                                 "Note 777092(e)
* ================================================================
* This part is For background processing only.

  IF sy-batch EQ 'X'.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT GT_OUTTAB .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
    DO.
      tindex = sy-index.
      READ TABLE gt_outtab INDEX tindex.
      MOVE-CORRESPONDING gt_outtab TO wa_anek.
* Check if line is marked and if the reversal is allowed.
* End of reversal.
      IF sy-tabix = 0.
        COMMIT WORK.
        CALL FUNCTION 'RA_ASSET_DEQUEUE'                 "Note 777092(b)
                EXPORTING
                     BUKRS = BUKRS-LOW
                     ANLN1 = L_ANLN1_INIT
                     ANLN2 = L_ANLN2_INIT.               "Note 777092(e)
        MESSAGE i744 WITH counter.
* Send Message in Spool  ****************
        CALL FUNCTION 'AMDP_MESSAGE_SEND' " message ab.reversed doc.
         TABLES t_return = lt_bapiret2
         EXCEPTIONS OTHERS   = 4.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
*****************************************
        LEAVE PROGRAM.
      ENDIF.
* check if reversal is possible.
      IF wa_anek-revyes EQ 0 .
* Reverse the document if yes.
        PERFORM reverse_and_post.
      ENDIF.
    ENDDO.
  ENDIF. " if sy-batch ne 'X'.
* ================================================================
* ================================================================

  SORT gt_outtab BY bukrs anln1 anln2 lnran.

  g_save = 'A'.
  PERFORM variant_init.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
      i_callback_pf_status_set = g_status
      i_callback_user_command  = g_user_command
      i_save                   = g_save
      is_variant               = g_variant
      it_fieldcat              = gt_fieldcat[]
      is_layout                = gs_layout
    TABLES
      t_outtab                 = gt_outtab.

*-----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*-----------------------------------------------------------------------
FORM sel_st_alv USING  extab TYPE slis_t_extab.
  SET PF-STATUS 'SEL_ST_ALV' EXCLUDING extab.
ENDFORM.                    "sel_st_alv
*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.
  DATA: l_lines TYPE i,
        l_outtab LIKE gt_outtab OCCURS 0.

  CASE r_ucomm.

    WHEN  'WAHL'.                            "menubutton
      READ TABLE gt_outtab INDEX rs_selfield-tabindex. "cursorposit.
      CLEAR r_ucomm.

    WHEN '&IC1'.                             "doubleclick
      READ TABLE gt_outtab INTO wa_anek INDEX rs_selfield-tabindex.
      PERFORM review_asset.
      CLEAR r_ucomm.

    WHEN 'REVERSE'.
      l_outtab[] = gt_outtab[].
      DELETE l_outtab WHERE mark IS initial.
      DESCRIBE TABLE l_outtab LINES l_lines.
      IF l_lines > 1000.
        MESSAGE i743 WITH '1000'.
      ELSE.
        PERFORM reverse_selected.
        CLEAR r_ucomm.
        IF NOT sy-batch IS INITIAL.
          MESSAGE i744 WITH counter.
        ENDIF.
        LEAVE SCREEN.
      ENDIF.
      FREE l_outtab.
  ENDCASE.
ENDFORM.                    "user_command

*---------------------------------------------------------------------*
*  FORM review_asset
*---------------------------------------------------------------------*
FORM review_asset.
* get Doc.number BELNR from table BKPF.
  CONCATENATE wa_anek-belnr wa_anek-aworg INTO in_awk.

  SELECT SINGLE belnr FROM bkpf INTO lf_belnr
          WHERE awkey EQ in_awk
            AND awtyp EQ gt_outtab-awtyp.
  SET PARAMETER ID 'BLN' FIELD  lf_belnr.
  SET PARAMETER ID 'BUK' FIELD  gt_outtab-bukrs.
  SET PARAMETER ID 'GJR' FIELD  gt_outtab-gjahr.
  CALL TRANSACTION 'FB03'  AND SKIP FIRST SCREEN.
ENDFORM.                                "review_asset

*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
FORM variant_init.
  CLEAR g_variant.
  g_variant-report = g_repid.
ENDFORM.                               " VARIANT_INIT

*---------------------------------------------------------------------*
*       FORM FIELDCAT_INIT                                            *
*---------------------------------------------------------------------*
FORM fieldcat_init
      USING rt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

* Add fields from ANEK
  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'BUKRS'.
  ls_fieldcat-col_pos      = 1.
  ls_fieldcat-key          = 'X'.
  ls_fieldcat-key_sel      = 'X'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'ANLN1'.
  ls_fieldcat-col_pos      = 2.
  ls_fieldcat-key          = 'X'.
  ls_fieldcat-key_sel      = 'X'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'ANLN2'.
  ls_fieldcat-col_pos      = 3.
  ls_fieldcat-key          = 'X'.
  ls_fieldcat-key_sel      = 'X'.
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'BELNR'.
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'GJAHR'.
  ls_fieldcat-no_out       = 'X'.     " not display in current list
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'LNRAN'.
  ls_fieldcat-no_out       = 'X'.
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'BLDAT'.
  ls_fieldcat-no_out       = 'X'.     " not display in current list
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'CPUDT'.
  ls_fieldcat-no_out       = 'X'.     " not display in current list
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'CPUTM'.
  ls_fieldcat-no_out       = 'X'.     " not display in current list
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'USNAM'.
  ls_fieldcat-no_out       = 'X'.
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'TCODE'.
  ls_fieldcat-emphasize    = 'C310'.  " highlight column
  ls_fieldcat-no_out       = 'X'.     " not display in current list
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'GLVOR'.
  ls_fieldcat-no_out       = 'X'.     " not display in current list
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'AWTYP'.
  ls_fieldcat-no_out       = 'X'.     " not display in current list
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'AWORG'.
  ls_fieldcat-no_out       = 'X'.     " not display in current list
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEK'.
  ls_fieldcat-fieldname    = 'BUDAT'.
  APPEND ls_fieldcat TO rt_fieldcat.

* Add fields from table ANEP(v)
  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEPV'.
  ls_fieldcat-fieldname    = 'ANBTR'.
  APPEND ls_fieldcat TO  rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-ref_tabname  = 'ANEPV'.
  ls_fieldcat-fieldname    = 'AFABE'.
  APPEND ls_fieldcat TO  rt_fieldcat.

ENDFORM.                               "fieldcat_init

*---------------------------------------------------------------------*
*       FORM REVERSE_SELECTED                                         *
*---------------------------------------------------------------------*
FORM reverse_selected.
  selind = 0.
  LOOP AT gt_outtab.
    READ TABLE gt_outtab INTO gt_outtab INDEX sy-tabix.
* Check if line is marked and if the reversal is allowed.
    IF gt_outtab-mark EQ 'X' AND gt_outtab-revyes EQ 0.
      selind = 1.
      MOVE-CORRESPONDING gt_outtab TO wa_anek.
      PERFORM reverse_and_post.      " reverse this document
    ENDIF.
  ENDLOOP.

* Ending of reversal.
  IF selind NE 0.
    COMMIT WORK.
         CALL FUNCTION 'RA_ASSET_DEQUEUE'                "Note 777092(b)
                EXPORTING
                     BUKRS = BUKRS-LOW
                     ANLN1 = L_ANLN1_INIT
                     ANLN2 = L_ANLN2_INIT.               "Note 777092(e)
    CALL FUNCTION 'AMDP_MESSAGE_SEND' " send message ab.reversed
         TABLES t_return = lt_bapiret2
         EXCEPTIONS OTHERS   = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSE.                               " no data selected
    MESSAGE w741(8z).
  ENDIF. " selind NE 0.

ENDFORM.                    "reverse_selected


*---------------------------------------------------------------------*
*       FORM reverse_and_post                                         *
*---------------------------------------------------------------------*
FORM reverse_and_post.

* Reverse selected document.
  CALL FUNCTION 'AMSS_DOCUMENT_REVERSE'
    EXPORTING
      i_awtyp = wa_anek-awtyp
      i_awref = wa_anek-belnr
      i_aworg = wa_anek-aworg
      i_awsys = wa_anek-awsys
      i_gjahr = wa_anek-gjahr
      i_belnr = wa_anek-belnr
      i_budat = wa_anek-budat
      i_monat = wa_anek-monat
      i_stgrd = '01'  " reason for reversal.
    EXCEPTIONS
      OTHERS  = 01.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  Read RW-document from AMBU-buffer
  CALL FUNCTION 'AMBU_AC_TABLES_GET_FROM_BUFFER'
    TABLES
      t_acchd = lt_acchd
      t_accit = lt_accit
      t_accda = lt_accda
      t_acccr = lt_acccr.


  IF sy-tcode IS INITIAL.
    sy-tcode = l_tcode.
  ENDIF.

* Post the reversed data.

  CALL FUNCTION 'AMBU_CALL_AC_DOCUMENT_POST'
    IMPORTING
      e_awref       = wa_anek-belnr
      e_aworg       = wa_anek-aworg
      e_awtyp       = wa_anek-awtyp
      e_awsys       = wa_anek-awsys
    TABLES
      t_accit       = lt_accit
      t_acchd       = lt_acchd
      t_acccr       = lt_acccr
      t_accda       = lt_accda
      t_return      = lt_bapiret2
    EXCEPTIONS
      error_message = 01.

  IF NOT sy-subrc IS INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    ADD 1 TO counter.
  ENDIF.

ENDFORM.                    "reverse_and_post
