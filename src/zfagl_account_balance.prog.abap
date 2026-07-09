*&---------------------------------------------------------------------*
*& Report  ZFAGL_ACCOUNT_BALANCE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfagl_account_balance MESSAGE-ID fagl_account_balance.

TABLES: faglflext,
        skc1a,
        rf42b,
        sscrfields,
        bkpf.

TYPE-POOLS: gusl, rsds, icon, abap.

TYPES tt_saknr TYPE RANGE OF saknr.
TYPES tt_bukrs TYPE RANGE OF bukrs.

CONSTANTS: gc_owner TYPE gl_owner VALUE 'FAGL_BALANCE_DISPLAY',
           gc_parameter_id TYPE memoryid VALUE 'GLN_FLEX'.

DATA: BEGIN OF gt_range OCCURS 0,
        sign(1)   TYPE c,
        option(2) TYPE c,
        low(10)   TYPE c,
        high(10)  TYPE c,
      END OF gt_range.

DATA mem_id(2) TYPE c.

DATA gt_parameter_modif_id TYPE fagl_tt_parameter_modif_id.
DATA gv_relevant_ledger TYPE rldnr_flex.
DATA gt_cosel TYPE tcosel.
DATA currtype_cosel TYPE cosel.                             "991987
DATA gd_newgl_active TYPE boole_d.

DATA: gd_tpc_check TYPE char1.                              "1061175

DATA: fs_f1_icon LIKE smp_dyntxt.                           "f1 taste
DATA: gs_tablenames  TYPE fagl_tabnames.

* data references for the relevant sum table.
DATA gr_tot_table TYPE REF TO data.

DATA ld_curtp           LIKE rfpdo2-allgcrtp.               "991987
DATA ld_auth_perid      LIKE sy-subrc.                      "1062329
DATA gs_dyns            TYPE rsds_type.                     "1095555
DATA gd_rri_acct_bukrs_set TYPE boolean.                    "1139010

* field symbol for the relevant sum table.
FIELD-SYMBOLS <tot_table> TYPE STANDARD TABLE.

* select-options and parameters
SELECT-OPTIONS:
     racct FOR faglflext-racct MODIF ID 001 MEMORY ID acc,
     rbukrs FOR bkpf-bukrs MODIF ID 002 MEMORY ID buk.
PARAMETERS
     ryear TYPE faglflext-ryear MODIF ID 019 MEMORY ID gjr.
PARAMETERS
       rldnr TYPE faglflext-rldnr MODIF ID rld MEMORY ID gln_flex.
PARAMETERS:     gp_curtp LIKE rfpdo2-allgcrtp.              "991987
*...declaration of function keys.......................................*
SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.
SELECTION-SCREEN FUNCTION KEY 4.

*...selection screen for processing of worklists.......................*
SELECTION-SCREEN BEGIN OF SCREEN 2000.
PARAMETER:
           fs_dyns TYPE rsds_type NO-DISPLAY,
           fs_num LIKE sy-tfill   NO-DISPLAY,
           fs_field TYPE rsdsfields_t NO-DISPLAY.
SELECTION-SCREEN BEGIN OF BLOCK account WITH FRAME TITLE text-005.
PARAMETERS: pc_wlsak LIKE rf42b-idnts MODIF ID 101.
SELECT-OPTIONS: sc_wlsak FOR skc1a-saknr MEMORY ID sak MODIF ID 102 .
SELECTION-SCREEN END OF BLOCK account.
SELECTION-SCREEN BEGIN OF BLOCK company WITH FRAME TITLE text-006.
PARAMETERS: pc_wlbuk LIKE rf42b-idntb  MODIF ID 103.
SELECT-OPTIONS: sc_wlbuk FOR skc1a-bukrs MEMORY ID buk  MODIF ID 104.
SELECTION-SCREEN END OF BLOCK company.
PARAMETERS: gc_gjhr2 TYPE gjahr MEMORY ID gjr MODIF ID 105.
PARAMETERS
       gc_rldnr TYPE faglflext-rldnr MODIF ID rld MEMORY ID gln_flex.
PARAMETERS:     gp_crtp2 LIKE rfpdo2-allgcrtp NO-DISPLAY .
            "991987
SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 3.
SELECTION-SCREEN FUNCTION KEY 4.
SELECTION-SCREEN END OF SCREEN 2000.

INITIALIZATION.

  mem_id = 'FAGLB03'.

  IMPORT
  table1 = fs_dyns
  table2 = fs_num
  table3 = fs_field
  table4 = rldnr
  FROM DATABASE indx(ab)
  ID mem_id.

* fill gv_relevant_ledger from rldnr screen 2000
  gv_relevant_ledger = rldnr.
  gc_rldnr = rldnr.

  CLEAR gd_rri_acct_bukrs_set.                              "1139010

* check, if new G/L is active for the client
  DELETE FROM DATABASE indx(ab) ID mem_id.

  CALL FUNCTION 'FAGL_CHECK_GLFLEX_ACTIVE'
    IMPORTING
      e_glflex_active = gd_newgl_active.

* if not check, if new G/L is active at least in one
* company code
  IF gd_newgl_active NE 'X'.
    CALL FUNCTION 'FAGL_BUKRS_ACTIVE_IN_CLIENT'
      IMPORTING
        e_glflex_active = gd_newgl_active.
  ENDIF.

  DATA ld_active_mgpln_exist TYPE abap_bool.
  CLEAR ld_active_mgpln_exist.

  CALL FUNCTION 'FAGL_ACTIVE_MGPLN_EXIST'
    IMPORTING
      ed_active_mgpln_exist   = ld_active_mgpln_exist
    EXCEPTIONS
      no_migration_data_found = 1
      internal_error          = 2
      OTHERS                  = 3.

  IF gd_newgl_active NE 'X'.
    IF ld_active_mgpln_exist EQ space.
      MESSAGE w024(fagl_account_balance).
      LEAVE TO TRANSACTION 'FS10N'.
    ENDIF.
  ENDIF.

* mapping table for select options and parameters:


  PERFORM fill_gt_parameter_modif_id
              CHANGING gt_parameter_modif_id.

  DATA: fs_f3_icon           LIKE smp_dyntxt.
  PERFORM fs_set_sscrtexts_dynsel3 CHANGING fs_f3_icon.
* worklist
  sscrfields-functxt_02 = text-003.
  sscrfields-functxt_03 = text-004.
  sscrfields-functxt_04 = fs_f3_icon.

  DATA l_text LIKE smp_dyntxt.

  CLEAR fs_f1_icon.
  CLEAR l_text.
  MOVE: icon_fencing TO l_text-icon_id,
        'Free selections'(270) TO l_text-text.              "#EC *

  IF fs_num > 0.
    WRITE fs_num TO l_text-icon_text(2).
    MOVE 'active'(271) TO l_text-icon_text+3.               "#EC *
  ENDIF.
  fs_f1_icon = l_text.

  sscrfields-functxt_01 = fs_f1_icon.

*  IF sy-slset EQ space.                                     "796813
  IF rldnr EQ space.
    PERFORM find_relevant_ledger
            CHANGING gv_relevant_ledger.
    rldnr = gv_relevant_ledger.
  ENDIF.

  CLEAR gs_dyns.                                            "1095555
* rri
  PERFORM init_rri_data.

*  ELSE.                                                     "796813
*    gv_relevant_ledger = rldnr.                             "796813
*  ENDIF.                                                    "796813

* find balance tablename
  CALL FUNCTION 'FAGL_GET_TABLENAMES'
    EXPORTING
      i_ledger    = rldnr
    IMPORTING
      es_tabnames = gs_tablenames.

* fill table gt_reporting_fields.
  DATA gt_reporting_fields TYPE ttfieldname.
  DATA gs_reporting_fields TYPE fieldname.
  DATA gt_dfies_reporting_fields TYPE dfies_table.

  CALL FUNCTION 'FAGL_GET_REPORTING_FIELDS'
    EXPORTING
      i_rldnr   = gv_relevant_ledger
    IMPORTING
      et_fields = gt_reporting_fields
      et_dfies  = gt_dfies_reporting_fields.

  PERFORM update_gt_parameter_modif_id
              CHANGING gt_parameter_modif_id.

*...check for the GDPDU authority.............................."1061175*
  DATA ld_return TYPE char1.

  CALL FUNCTION 'FI_CHECK_DATE'
    EXPORTING
      i_bukrs           = space
      i_user            = sy-uname
      i_program         = 'SAPDBSDF'
    IMPORTING
      e_return          = ld_return
    EXCEPTIONS
      no_authority_prog = 1
      no_authority_date = 2
      wrong_parameter   = 3
      OTHERS            = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF ld_return = 1.
    gd_tpc_check = 'X'.
  ELSE.
    gd_tpc_check = space.
  ENDIF.
*...check for the GDPDU authority.............................."1061175*

* check selections
AT SELECTION-SCREEN.

  DATA lt_t001 TYPE TABLE OF t001.
  DATA ls_t001 TYPE t001.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM t001 INTO TABLE lt_t001 WHERE bukrs IN rbukrs.
*
* NEW CODE
  SELECT *
 FROM t001 INTO TABLE lt_t001 WHERE bukrs IN rbukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  LOOP AT lt_t001 INTO ls_t001.
* check at PAI, if NewGL is active for the selected company codes.
    CALL FUNCTION 'FAGL_CHECK_GLFLEX_ACTIVE'
      EXPORTING
        id_bukrs        = ls_t001-bukrs
      IMPORTING
        e_glflex_active = gd_newgl_active.
    IF gd_newgl_active NE 'X'.
      MESSAGE w026(fagl_account_balance) WITH ls_t001-bukrs.
      LEAVE TO TRANSACTION 'FS10N'.
    ENDIF.
  ENDLOOP.

  CASE sscrfields-ucomm.
    WHEN 'FC01'.
      PERFORM free_selections.

    WHEN 'ONLI'.

      PERFORM fill_selopt_fr_worklist.

* switch on worklists
    WHEN 'FC02'.

* export to memory of free selection parameters
      EXPORT
       table1 = fs_dyns
       table2 = fs_num
       table3 = fs_field
       table4 = rldnr
      TO DATABASE indx(ab)
      ID mem_id.

      LEAVE TO TRANSACTION 'FAGLB03A'.

* switch off worklists
    WHEN 'FC03'.
* export to memory of free selection parameters
      EXPORT
       table1 = fs_dyns
       table2 = fs_num
       table3 = fs_field
       table4 = rldnr
      TO DATABASE indx(ab)
      ID mem_id.

      LEAVE TO TRANSACTION 'FAGLB03'.

* choose ledger
    WHEN 'FC04'.

      DATA: BEGIN OF gt_chosen_values OCCURS 0.
              INCLUDE STRUCTURE sval.
      DATA: END OF gt_chosen_values.
      DATA lv_new_ledger TYPE rldnr_flex.
      CLEAR lv_new_ledger.

      PERFORM choose_ledger
                   TABLES gt_chosen_values
                   USING gv_relevant_ledger
                   CHANGING lv_new_ledger.

      IF lv_new_ledger NE gv_relevant_ledger.
*        REFRESH lt_modif_id.

        gv_relevant_ledger = lv_new_ledger.
        rldnr = lv_new_ledger.                              "796813

* mapping table for select options and parameters:
        PERFORM fill_gt_parameter_modif_id
                    CHANGING gt_parameter_modif_id.

* fill table gt_reporting_fields.
        CALL FUNCTION 'FAGL_GET_REPORTING_FIELDS'
          EXPORTING
            i_rldnr   = gv_relevant_ledger
          IMPORTING
            et_fields = gt_reporting_fields
            et_dfies  = gt_dfies_reporting_fields.

* find balance tablename
        CALL FUNCTION 'FAGL_GET_TABLENAMES'
          EXPORTING
            i_ledger    = gv_relevant_ledger
          IMPORTING
            es_tabnames = gs_tablenames.

        PERFORM update_gt_parameter_modif_id
                    CHANGING gt_parameter_modif_id.

        PERFORM upd_fs_params.

      ENDIF.
  ENDCASE.

* ledger chosen in the selection screen.
AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF screen-group1 = 'RLD'.
*      screen-input    = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
  IF rldnr IS INITIAL.                                      "1057371
    rldnr = gv_relevant_ledger.                             "1057371
  ENDIF.                                                    "1057371
  gc_rldnr = rldnr.

* check Ledger for newGL
  IF NOT gv_relevant_ledger IS INITIAL.
    CALL FUNCTION 'FAGL_CHECK_IF_LEDGER_IS_GLFLEX'
      EXPORTING
        i_rldnr                       = gv_relevant_ledger
      EXCEPTIONS
*       NOT_FOUND                     = 1
        no_glflex_ledger              = 2
*       GLFLEX_ROLLUP_LEDGER          = 3
*       WRONG_APPLICATION             = 4
*       GLFLEX_DEPENDENT_LEDGER       = 5
*       OTHERS                        = 6
              .
    IF sy-subrc <> 0.
      MESSAGE e108(msitem) WITH gv_relevant_ledger.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  CLEAR fs_f1_icon.
  CLEAR l_text.

  MOVE: icon_fencing TO l_text-icon_id,
        'Free selections'(270) TO l_text-text.              "#EC *

  IF fs_num > 0.
    WRITE fs_num TO l_text-icon_text(2).
    MOVE 'active'(271) TO l_text-icon_text+3.               "#EC *
  ELSE.
    CLEAR l_text-icon_text(2).
  ENDIF.
  fs_f1_icon = l_text.

  sscrfields-functxt_01 = fs_f1_icon.

  IF rldnr NE gv_relevant_ledger.
    gv_relevant_ledger = rldnr.

*    REFRESH lt_modif_id.
* mapping table for select options and parameters:
    PERFORM fill_gt_parameter_modif_id
                CHANGING gt_parameter_modif_id.

* fill table gt_reporting_fields.
    CALL FUNCTION 'FAGL_GET_REPORTING_FIELDS'
      EXPORTING
        i_rldnr   = gv_relevant_ledger
      IMPORTING
        et_fields = gt_reporting_fields
        et_dfies  = gt_dfies_reporting_fields.

    PERFORM update_gt_parameter_modif_id
                CHANGING gt_parameter_modif_id.

* delete all entries from fs_dyns-trange, which are not in
* gt_reporting_fields

    PERFORM upd_fs_params.

  ENDIF.

START-OF-SELECTION.
*...get valid currency type............................................*

  IF gp_crtp2 IS INITIAL.                                   "991987
    ld_curtp = gp_curtp.                                    "991987
  ELSE.                                                     "991987
    ld_curtp = gp_crtp2.                                    "991987
  ENDIF.                                                    "991987

  DATA gt_bukrs_hwaer TYPE fagl_t_bukrs_hwaer.

  IF gd_rri_acct_bukrs_set = 'X'.                           "1139010
    IMPORT racct  FROM MEMORY ID 'FAGLB03_RRI_RACCT'.       "1139010
    IMPORT rbukrs FROM MEMORY ID 'FAGLB03_RRI_RBUKRS'.      "1139010
    CLEAR gd_rri_acct_bukrs_set.                            "1139010
  ENDIF.

* read all company code currencies and fill table gt_bukrs_hwaer
  PERFORM fill_gt_bukrs_hwaer
                  USING gv_relevant_ledger
                        rbukrs[]
                  CHANGING gt_bukrs_hwaer
                           ld_auth_perid.                   "1062329
  IF ld_auth_perid = 4.                                     "1062329
    RETURN.                                                 "1062329
  ENDIF.                                                    "1062329

* check, that for all selected companies each currency type has the same currency.
  PERFORM check_currs_of_companies
           TABLES gt_bukrs_hwaer
           USING ld_curtp.                                  "991987

  DATA gs_fagl_tabnames TYPE fagl_tabnames.

*...call FAGL_GET_TABLENAMES in order to fill
*...gs_fagl_tablename
*...gs_fagl_tablename is an import parameter of function modul
*...G_TABLE_SELECT_WITH_CURSOR
  CALL FUNCTION 'FAGL_GET_TABLENAMES'
    EXPORTING
      i_ledger            = gv_relevant_ledger
    IMPORTING
      es_tabnames         = gs_fagl_tabnames
    EXCEPTIONS
      not_found           = 1
      configuration_error = 2
      OTHERS              = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  DATA gt_selection TYPE gusl_t_selection.
  DATA ls_rsds_range_temp TYPE rsds_range.
  DATA ls_rsds_frange_temp TYPE rsds_frange.

  REFRESH gt_selection.

* fill gt_selection with free selection parameters
* gt_selection
  DATA ls_selection TYPE gusl_s_selection.

  IF fs_dyns-trange IS INITIAL.                             "1095555
    fs_dyns-trange = gs_dyns-trange.                        "1095555
    CLEAR gs_dyns.                                          "1095555
  ENDIF.                                                    "1095555

  LOOP AT fs_dyns-trange INTO ls_rsds_range_temp.
    LOOP AT ls_rsds_range_temp-frange_t INTO ls_rsds_frange_temp.

      ls_selection-fieldname = ls_rsds_frange_temp-fieldname.
      ls_selection-t_range[] = ls_rsds_frange_temp-selopt_t[].
      APPEND ls_selection TO gt_selection.

    ENDLOOP.
  ENDLOOP.

*...fill gt_selection
*...gt_selection is an import parameter of function modul
*...G_TABLE_SELECT_WITH_CURSOR

  PERFORM fill_gt_selections
            TABLES  racct
                   rbukrs
            USING gv_relevant_ledger
            CHANGING
                gt_selection.

  DATA lt_selection TYPE fagl_t_selection.
  DATA lt_bukrs TYPE fagl_range_t_bukrs.
  DATA ld_tabname TYPE tabname.
  lt_selection[] = gt_selection[].
  lt_bukrs[] = rbukrs[].
  ld_tabname = gs_fagl_tabnames-tot_table.

*...authority check of the selection screen.....................*
  DATA ld_label TYPE string.
  DATA ld_fieldvalue TYPE string.

  CALL FUNCTION 'FAGL_CHECK_AUTHORITY_SELECTION'
    EXPORTING
      it_selections = lt_selection
      id_table      = ld_tabname
      it_bukrs      = lt_bukrs
      id_actvt      = '27'           "sum data set
    IMPORTING
      ed_label      = ld_label
      ed_field      = ld_fieldvalue
    EXCEPTIONS
      no_authority  = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE e030(fagl_post_service) WITH ld_label ld_fieldvalue.
  ENDIF.

*...fill gt_fieldlist with fields, which have to be ignored by
*...function modul G_TABLE_SELECT_WITH_CURSOR during aggregation.
  DATA gt_fieldlist TYPE gusl_t_fields.
  DATA ld_fieldlist TYPE dfies-fieldname.

  PERFORM fill_fieldlist
                 CHANGING gt_fieldlist.

  CREATE DATA gr_tot_table TYPE TABLE OF (gs_fagl_tabnames-tot_table).
  ASSIGN gr_tot_table->* TO <tot_table>.

  CALL FUNCTION 'G_TABLE_SELECT_WITH_CURSOR'
    EXPORTING
      i_tabname         = gs_fagl_tabnames-tot_table
      i_selection       = gt_selection
      i_fieldlist       = gt_fieldlist
      i_aggregation     = 'X'
      i_zero_records    = 'X'                               "865353
    CHANGING
      c_t_data          = <tot_table>
    EXCEPTIONS
      invalid_selection = 1
      invalid_table     = 2
      internal_error    = 3
      foreign_lock      = 4
      OTHERS            = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  DATA lt_fields TYPE fieldname_tab.
  DATA ld_field TYPE fieldname.
  lt_fields[] = gt_fieldlist[].

  LOOP AT lt_fields INTO ld_field.
    IF ld_field = 'RTCUR'
    OR ld_field = 'DRCRK'
    OR ld_field = 'RYEAR'
    OR ld_field = 'TSL'
    OR ld_field = 'HSL'
    OR ld_field = 'KSL'
    OR ld_field = 'OSL'.
      DELETE lt_fields.
    ENDIF.
  ENDLOOP.

*...authority check of the selected data.............................*
  CALL FUNCTION 'FAGL_CHECK_AUTHORITY_SUM_TABLE'
    EXPORTING
      it_fields    = lt_fields
      id_actvt     = '27'           "sum data set
    CHANGING
      it_data      = <tot_table>
    EXCEPTIONS
      no_authority = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*...check for the GDPDU authority per balance line............."1061175*
  IF gd_tpc_check = 'X'.
    FIELD-SYMBOLS <tot_tpc_structure> TYPE ANY.
    FIELD-SYMBOLS <target_bukrs>.
    FIELD-SYMBOLS <target_gjahr>.

    LOOP AT <tot_table> ASSIGNING <tot_tpc_structure>.
      ASSIGN COMPONENT 'RBUKRS'
        OF STRUCTURE <tot_tpc_structure> TO <target_bukrs>.
      ASSIGN COMPONENT 'RYEAR'
        OF STRUCTURE <tot_tpc_structure> TO <target_gjahr>.

      CALL FUNCTION 'FI_CHECK_DATE'
        EXPORTING
          i_bukrs           = <target_bukrs>
          i_user            = sy-uname
          i_program         = 'SAPDBSDF'
          i_from_year       = <target_gjahr>
        EXCEPTIONS
          no_authority_prog = 1
          no_authority_date = 2
          wrong_parameter   = 3
          OTHERS            = 4.

      CASE sy-subrc.
        WHEN 0.
        WHEN 2.
          DELETE <tot_table>.
        WHEN OTHERS.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDCASE.
    ENDLOOP.
  ENDIF.
*...check for the GDPDU authority per balance line............."1061175*



*...change sign for all <tot_table> entries, if debvit credit indicator
*...has value credit.

  FIELD-SYMBOLS <tot_table_structure> TYPE ANY.
  FIELD-SYMBOLS <target_field_value>.

  DATA lt_dfies TYPE TABLE OF dfies.
  DATA ls_dfies TYPE dfies.

  DATA ls_period_block TYPE fagl_s_period_block.
  FIELD-SYMBOLS <table> TYPE ANY.

  LOOP AT <tot_table> ASSIGNING <tot_table_structure>.

    ASSIGN COMPONENT 'DRCRK'
    OF STRUCTURE <tot_table_structure> TO <target_field_value>.
    IF <target_field_value> EQ 'H'.

      MOVE-CORRESPONDING <tot_table_structure> TO ls_period_block.

      CALL FUNCTION 'DDIF_NAMETAB_GET'
        EXPORTING
          tabname   = 'FAGL_S_PERIOD_BLOCK'
        TABLES
          dfies_tab = lt_dfies
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.

      LOOP AT lt_dfies INTO ls_dfies.
        CHECK ls_dfies-fieldname NE 'DRCRK'
        AND ls_dfies-fieldname NE 'HSLVT'
        AND ls_dfies-fieldname NE 'TSLVT'
        AND ls_dfies-fieldname NE 'KSLVT'
        AND ls_dfies-fieldname NE 'OSLVT'
        AND ls_dfies-fieldname NE 'MSLVT'.
        ASSIGN COMPONENT ls_dfies-fieldname
      OF STRUCTURE <tot_table_structure> TO <target_field_value>.
        <target_field_value> = 0 - <target_field_value>.
      ENDLOOP.

    ENDIF.
  ENDLOOP.


*...fill 'empty' in all fields, which have no account assignment......*

  LOOP AT <tot_table> ASSIGNING <tot_table_structure>.
    LOOP AT gt_fieldlist INTO ld_fieldlist.
      CHECK ld_fieldlist NE 'TSL' AND
            ld_fieldlist NE 'HSL' AND
            ld_fieldlist NE 'KSL' AND
            ld_fieldlist NE 'OSL'   AND
            ld_fieldlist NE 'ACTIV' AND                     "1129308
            ld_fieldlist NE 'RMVCT' AND                     "1129308
            ld_fieldlist NE 'RTCUR' AND                     "1129308
            ld_fieldlist NE 'RUNIT' AND                     "1129308
            ld_fieldlist NE 'AWTYP'.                        "1129308

      ASSIGN COMPONENT ld_fieldlist
      OF STRUCTURE <tot_table_structure> TO <target_field_value>.

      IF <target_field_value> EQ space.
        <target_field_value> = text-010.
      ENDIF.

    ENDLOOP.
  ENDLOOP.


END-OF-SELECTION.

*...check, if data has been found at all.............................*
  IF <tot_table> IS INITIAL.
    MESSAGE i020 WITH ryear.
    RETURN.
  ENDIF.

* transform gt_namerange into gt_cosel.
  PERFORM fill_gt_cosel
                 USING gt_selection
                       gt_reporting_fields
                 CHANGING gt_cosel.

* fill ld_curtp.
  IF ld_curtp IS NOT INITIAL.                               "991987
    currtype_cosel-field = 'CURRTYPE'.                      "991987
    currtype_cosel-low = ld_curtp.                          "991987
    APPEND currtype_cosel TO gt_cosel.                      "991987
  ENDIF.                                                    "991987

* ALV Grid Ausgabe
  CALL FUNCTION 'FAGL_AB_BALANCES_DISPLAY'
    EXPORTING
      pt_cosel               = gt_cosel
      it_active_par_modif_id = gt_parameter_modif_id
      ic_rldnr_flex          = gv_relevant_ledger
      it_bukrs_hwaer         = gt_bukrs_hwaer
      it_fieldlist           = gt_fieldlist
    CHANGING
      pt_balance_data        = <tot_table>
    EXCEPTIONS
      OTHERS                 = 1.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  INCLUDE fill_active_ledger_parameters.

  INCLUDE find_relevant_ledger.

  INCLUDE fill_gt_namerange.

  INCLUDE fill_ct_namerange_one_field.

  INCLUDE fill_alv_structure.

  INCLUDE fagl_fill_selopt_fr_worklist.

  INCLUDE fagl_check_authority_groups.

  INCLUDE fagl_get_range_from_worklist.

  INCLUDE fagl_choose_ledger.

  INCLUDE fagl_choose_fields.

  INCLUDE fagl_save_ledger.

  INCLUDE fagl_hr_only_check.

  INCLUDE fagl_fill_gt_bukrs_hwaer.

  INCLUDE fagl_fill_gt_selections.

  INCLUDE fagl_fill_gt_para_modif_id.

  INCLUDE fagl_fill_fieldlist.

  INCLUDE fagl_fill_gt_cosel.

  INCLUDE fagl_free_selections.

  INCLUDE fagl_mod_gt_para_modif_id.

  INCLUDE fagl_upd_fs_params.

  INCLUDE fagl_init_rri.

  INCLUDE fagl_check_curtp_authority.

  INCLUDE fagl_set_sscrtexts_dynsel.

  INCLUDE fagl_check_currs_of_comps.
