*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFILB005_F01_2_V1
*&---------------------------------------------------------------------*
FORM create_hierarchy.

  DATA: ls_outtab   TYPE ty_s_outtab,
        l_top_key   TYPE lvc_nkey,
        l_node_key  TYPE lvc_nkey,
        l_node_text TYPE lvc_value.

  CALL METHOD g_alv_tree->add_node
    EXPORTING
      i_relat_node_key = ''
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = text-050
    IMPORTING
      e_new_node_key   = l_top_key.

*  gt_outtab_tree[] = gt_outtab[].
  LOOP AT gt_outtab INTO ls_outtab.
    MOVE ls_outtab-hkont TO l_node_text.
    CALL METHOD g_alv_tree->add_node
      EXPORTING
        i_relat_node_key = l_top_key
        i_relationship   = cl_gui_column_tree=>relat_last_child
        i_node_text      = l_node_text
        is_outtab_line   = ls_outtab
      IMPORTING
        e_new_node_key   = l_node_key.
  ENDLOOP.

ENDFORM.                    "create_hierarchy
*&---------------------------------------------------------------------*
*&      Form  register_events
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM register_events.
*§4. Event registration: tell ALV Tree which events shall be passed
*    from frontend to backend.
  DATA: lt_events TYPE cntl_simple_events,
        l_event TYPE cntl_simple_event,
        l_event_receiver TYPE REF TO lcl_tree_event_receiver.

*§4a. Frontend registration(i):  get already registered tree events.
*................................................................
* The following four tree events registers ALV Tree in the constructor
* method itself.
*    - cl_gui_column_tree=>eventid_expand_no_children
* (needed to load data to frontend when a user expands a node)
*    - cl_gui_column_tree=>eventid_header_context_men_req
* (needed for header context menu)
*    - cl_gui_column_tree=>eventid_header_click
* (allows selection of columns (only when item selection activated))
*   - cl_gui_column_tree=>eventid_item_keypress
* (needed for F1-Help (only when item selection activated))
*
* Nevertheless you have to provide their IDs again if you register
* additional events with SET_REGISTERED_EVENTS (see below).
* To do so, call first method  GET_REGISTERED_EVENTS (this way,
* all already registered events remain registered, even your own):
  CALL METHOD g_alv_tree->get_registered_events
    IMPORTING
      events = lt_events.
* (If you do not these events will be deregistered!!!).
* You do not have to register events of the toolbar again.

*§4b. Frontend registration(ii): add additional event ids
  l_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
  APPEND l_event TO lt_events.

*§4c. Frontend registration(iii):provide new event table to alv tree
  CALL METHOD g_alv_tree->set_registered_events
    EXPORTING
      events                    = lt_events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.
*--------------------
*§4d. Register events on backend (ABAP Objects event handling)
  CREATE OBJECT l_event_receiver.
  SET HANDLER l_event_receiver->handle_node_double_click FOR g_alv_tree.

ENDFORM.                    "register_events
*&---------------------------------------------------------------------*
*&      Form  init_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM init_tree.
* create container for alv-tree
  DATA: l_tree_container_name(30) TYPE c.

  l_tree_container_name = 'CCONTAINER1'.

  CREATE OBJECT g_custom_container
    EXPORTING
      container_name              = l_tree_container_name
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'(100).
  ENDIF.

* create tree control
  CREATE OBJECT g_alv_tree
    EXPORTING
      parent                      = g_custom_container
      node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
      item_selection              = 'X'
      no_html_header              = 'X'
      no_toolbar                  = ''
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      illegal_node_selection_mode = 5
      failed                      = 6
      illegal_column_name         = 7.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.

  DATA l_hierarchy_header TYPE treev_hhdr.
  PERFORM build_hierarchy_header CHANGING l_hierarchy_header.

* Hide columns and sum up values initially using the fieldcatalog
  PERFORM build_fieldcatalog.

* IMPORTANT: Table 'gt_sflight' must be empty. Do not change this table
* (even after this method call). You can change data of your table
* by calling methods of CL_GUI_ALV_TREE.
* Furthermore, the output table 'gt_outtab' must be global and can
* only be used for one ALV Tree Control.
  CALL METHOD g_alv_tree->set_table_for_first_display
    EXPORTING
      is_hierarchy_header = l_hierarchy_header
    CHANGING
      it_fieldcatalog     = gt_fieldcatalog
      it_outtab           = gt_outtab_tree. "table must be empty !

  PERFORM create_hierarchy.

  PERFORM register_events.
* Update calculations which were initially defined by field DO_SUM
* of the fieldcatalog. (see build_fieldcatalog).
  CALL METHOD g_alv_tree->update_calculations.

* Send data to frontend.
  CALL METHOD g_alv_tree->frontend_update.

ENDFORM.                    "init_tree
*&---------------------------------------------------------------------*
*&      Form  build_hierarchy_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_HIERARCHY_HEADER  text
*----------------------------------------------------------------------*
FORM build_hierarchy_header CHANGING
                            p_hierarchy_header TYPE treev_hhdr.

  p_hierarchy_header-heading = 'Totals/Month/Carrier/Date'(300).
  p_hierarchy_header-tooltip = 'Flights in a month'(400).
  p_hierarchy_header-width = 35.
  p_hierarchy_header-width_pix = ''.

ENDFORM.                    "build_hierarchy_header
*&---------------------------------------------------------------------*
*&      Form  build_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_fieldcatalog.

  DATA: ls_fieldcatalog TYPE lvc_s_fcat.

  ls_fieldcatalog-fieldname = 'HKONT'.
  ls_fieldcatalog-seltext  = 'Cuenta'.
  APPEND ls_fieldcatalog TO  gt_fieldcatalog.
  CLEAR ls_fieldcatalog.

  ls_fieldcatalog-fieldname = 'BUDAT'.
  ls_fieldcatalog-seltext  = 'Fecha Documento'.
  APPEND ls_fieldcatalog TO  gt_fieldcatalog.
  CLEAR ls_fieldcatalog.

  ls_fieldcatalog-fieldname = 'BELNR'.
  ls_fieldcatalog-seltext  = 'Documento'.
  APPEND ls_fieldcatalog TO  gt_fieldcatalog.
  CLEAR ls_fieldcatalog.

ENDFORM.                    "build_fieldcatalog
*&---------------------------------------------------------------------*
*&      Form  fieldcat_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM fieldcat_init USING lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'SGTXT2'.
*  ls_fieldcat-seltext_m = 'Cuenta'.
*  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
*  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-hotspot = ' '.
*  ls_fieldcat-outputlen = 20.
*  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'HKONT'.
  ls_fieldcat-seltext_m = 'Cod Cuenta'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 40.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUDAT'.
  ls_fieldcat-seltext_m = 'Fecha Documento'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 12.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BELNR'.
  ls_fieldcat-seltext_m = 'Número Documento'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BLART'.
  ls_fieldcat-seltext_m = 'Cl Doc.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 6.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUZEI'.
  ls_fieldcat-seltext_m = 'Linea'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 6.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SGTXT'.
  ls_fieldcat-seltext_m = 'Glosa Movimiento'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 30.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DMBTR_S'.
  ls_fieldcat-seltext_m = 'Debe'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 15.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DMBTR_H'.
  ls_fieldcat-seltext_m = 'Haber'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 15.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SALDO_START'.
  ls_fieldcat-seltext_m = 'Saldo'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = ' '.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 15.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SALDO_END'.
  ls_fieldcat-seltext_m = 'Saldo Acumulado'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = ' '.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 15.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERS'.
  ls_fieldcat-seltext_m = 'Moneda'.
  ls_fieldcat-do_sum    = ' '.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 6.
  APPEND ls_fieldcat TO lt_fieldcat.

ENDFORM.                    "fieldcat_init
*&---------------------------------------------------------------------*
*&      Form  set_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM set_status USING rt_extab TYPE slis_t_extab .          "#EC *

  SET PF-STATUS 'STATUS' EXCLUDING rt_extab.

ENDFORM.                    "set_status

*&---------------------------------------------------------------------*
*&      Form  fill_bstat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_bstat .

*  ADMSVWZ
  r_bstat-sign   = 'I'.
  r_bstat-option = 'NE'.
  r_bstat-low    = 'A'.
  APPEND r_bstat.

  r_bstat-sign   = 'I'.
  r_bstat-option = 'NE'.
  r_bstat-low    = 'D'.
  APPEND r_bstat.

  r_bstat-sign   = 'I'.
  r_bstat-option = 'NE'.
  r_bstat-low    = 'A'.
  APPEND r_bstat.

  r_bstat-sign   = 'I'.
  r_bstat-option = 'NE'.
  r_bstat-low    = 'M'.
  APPEND r_bstat.

  r_bstat-sign   = 'I'.
  r_bstat-option = 'NE'.
  r_bstat-low    = 'S'.
  APPEND r_bstat.

  r_bstat-sign   = 'I'.
  r_bstat-option = 'NE'.
  r_bstat-low    = 'V'.
  APPEND r_bstat.

  r_bstat-sign   = 'I'.
  r_bstat-option = 'NE'.
  r_bstat-low    = 'W'.
  APPEND r_bstat.

  r_bstat-sign   = 'I'.
  r_bstat-option = 'NE'.
  r_bstat-low    = 'Z'.
  APPEND r_bstat.

ENDFORM.                    " fill_bstat
*&---------------------------------------------------------------------*
*&      Form  value_request_path_down
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PATH     text
*----------------------------------------------------------------------*
FORM value_request_path_down  CHANGING p_path.

  DATA: l_path TYPE string.

  MOVE p_path TO l_path.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    CHANGING
      selected_folder      = l_path
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  MOVE l_path TO p_path.

ENDFORM.                    "value_request_pat
*&---------------------------------------------------------------------*
*&      Form  html_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DOCUMENT   text
*----------------------------------------------------------------------*
FORM html_top_of_page USING document
                      TYPE REF TO cl_dd_document.           "#EC CALLED

  DATA: l_title      TYPE sdydo_text_element,
        l_text       TYPE sdydo_text_element,
        l_font       TYPE sdydo_attribute VALUE '1',
        ls_zfigiro   TYPE zfigiro,
        l_month      TYPE fcltx.

  MOVE 30 TO g_html_height_top.
  CONCATENATE g_address_value-name1 ''
    INTO l_text SEPARATED BY space.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  l_text = 'Giro'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  LOOP AT gt_zfigiro INTO   ls_zfigiro.

    IF NOT ls_zfigiro-giro_1 IS INITIAL.
      ADD 2 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_1 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->add_gap
        EXPORTING
          width = 10.
      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT  ls_zfigiro-giro_2 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_2 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_3 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_3 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_4 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_4 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_5 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_5 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_6 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_6 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

  ENDLOOP.
***        RUT
  l_text = 'Rut'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  MOVE g_paval TO l_text.
  CALL METHOD document->add_gap
    EXPORTING
      width = 11.

  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

***      Direccion
  l_text = 'Dirección'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
  CONCATENATE g_address_value-street g_address_value-city1
      INTO l_text
      SEPARATED BY space .
  CALL METHOD document->add_gap
    EXPORTING
      width = 0.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

  CALL METHOD document->new_line.
  l_title = 'Libro Mayor'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 170.
  CALL METHOD document->add_text
    EXPORTING
      text          = l_title
      sap_style     = 'HEADING'
*      sap_fontsize  = l_font.
      sap_fontstyle = 'C'
      sap_emphasis  = 'C'.
  CALL METHOD document->new_line.
  PERFORM get_month
              USING
                 p_monat
              CHANGING
                 l_month.
  CONCATENATE l_month p_gjahr
    INTO l_text SEPARATED BY space.

  CALL METHOD document->add_gap
    EXPORTING
      width = 180.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

ENDFORM.                    "html_top_of_page
*&---------------------------------------------------------------------*
*&      Form  HTML_END_OF_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM html_end_of_list USING document
                      TYPE REF TO cl_dd_document.

  DATA: l_title   TYPE sdydo_text_element,
        l_text    TYPE sdydo_text_element,
        l_num     TYPE char13.

  WRITE g_num TO l_num .
*  CALL METHOD document->new_line.
  CONCATENATE 'Total de registros:' l_num
 INTO l_text SEPARATED BY space.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

ENDFORM.                    "html_end_of_list
*&---------------------------------------------------------------------*
*&      Form  get_month
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MONAT    text
*      -->P_MONTH    text
*----------------------------------------------------------------------*
FORM get_month USING p_monat TYPE monat
               CHANGING p_month TYPE fcltx.

  DATA: lt_month_names TYPE TABLE OF t247,
        ls_month_names TYPE  t247,
        l_subrc        TYPE sy-subrc.

  CALL FUNCTION 'MONTH_NAMES_GET'
    EXPORTING
      language              = sy-langu
    IMPORTING
      return_code           = l_subrc
    TABLES
      month_names           = lt_month_names
    EXCEPTIONS
      month_names_not_found = 1
      OTHERS                = 2.

  IF l_subrc EQ 0.
    READ TABLE lt_month_names
     INTO ls_month_names
     WITH KEY mnr = p_monat.
    IF sy-subrc EQ 0.
      MOVE ls_month_names-ltx TO p_month .
    ENDIF.
  ENDIF.

ENDFORM.                    "get_month
*&---------------------------------------------------------------------*
*&      Form  show_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_alv.

  gs_layout-window_titlebar = 'Libro Mayor'.                "#EC NOTEXT

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active             = 'X'
      i_callback_program          = g_repid
*      i_structure_name            = 'ALV_T_T2'
      i_callback_user_command     = 'USER_COMMAND'
*      i_callback_top_of_page      = l_callback_top_of_page
      i_callback_html_top_of_page = l_callback_html_top_of_page
*      i_callback_html_end_of_list = l_callback_html_end_of_list
      i_callback_pf_status_set    = 'SET_STATUS'
      is_layout                   = gs_layout
      it_special_groups           = gt_slis_sp_group_alv[]
      it_sort                     = gt_sort[]
      it_excluding                = lt_extab
*      it_events                   = gt_events[]
      it_fieldcat                 = gt_fieldcat[]
      is_variant                  = gs_variant
      i_html_height_top           = g_html_height_top
      i_html_height_end           = 10
    TABLES
      t_outtab                    = gt_outtab.

ENDFORM.            "get_month
" SORT_INIT
*&---------------------------------------------------------------------*
*&      Form  get_SAKNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_saknr .

  DATA: ls_saknr        TYPE ty_s_saknr,
        ls_outtab       TYPE ty_s_outtab,
        ls_range_racct  TYPE fagl_range_racct.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT saknr
*    FROM skb1
*    INTO CORRESPONDING FIELDS OF TABLE gt_saknr
*    WHERE bukrs EQ p_bukrs.
*
* NEW CODE
  SELECT saknr

    FROM skb1
    INTO CORRESPONDING FIELDS OF TABLE gt_saknr
    WHERE bukrs EQ p_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  LOOP AT gt_saknr INTO ls_saknr.
*    CHECK  ls_saknr-saknr(1) NE '9'.
    IF p_mov EQ 'X'.
      PERFORM get_description_hkont
            USING
               ls_saknr-saknr
            CHANGING
               g_txt20.

      CONCATENATE ls_saknr-saknr '-' g_txt20 INTO ls_outtab-hkont.
*      MOVE ls_saknr-saknr TO ls_outtab-hkont.
      MOVE 'CLP'       TO ls_outtab-waers.
      APPEND ls_outtab TO gt_outtab.
      CLEAR ls_outtab.
    ENDIF.

    IF s_saknr[] IS  INITIAL.
      MOVE 'I'              TO ls_range_racct-sign.
      MOVE 'EQ'             TO ls_range_racct-option.
      MOVE ls_saknr-saknr   TO ls_range_racct-low.
      APPEND ls_range_racct TO range_racct.
      CLEAR ls_range_racct.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'FAGL_GET_GLT0'
    EXPORTING
      i_glt0_rldnr      = p_rldnr
      I_RLDNR           = p_rldnr
      i_rvers           = '001'
      i_bukrs           = p_bukrs
      i_ryear           = p_gjahr
      i_rpmax           = '016'
      i_range_racct     = range_racct
    IMPORTING
      et_glt0           = gt_glt0
    EXCEPTIONS
      invalid_selection = 1
      OTHERS            = 2.
  SORT gt_glt0 BY racct.

  LOOP AT gt_glt0 INTO gs_glt0.
    PERFORM get_description_hkont
           USING       gs_glt0-racct
           CHANGING    g_txt20.

    CONCATENATE gs_glt0-racct '-' g_txt20 INTO ls_outtab-hkont.

*    MOVE gs_glt0-racct TO ls_outtab-hkont.

    MOVE 'CLP'  TO ls_outtab-waers.
    CASE p_monat.
      WHEN 1.
        ls_outtab-saldo_end = gs_glt0-hslvt .
      WHEN 2.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 .
      WHEN 3.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02.
      WHEN 4.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 .
      WHEN 5.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04.
      WHEN 6.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04 + gs_glt0-hsl05.
      WHEN 7.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04 + gs_glt0-hsl05 +
                              gs_glt0-hsl06.
      WHEN 8.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04 + gs_glt0-hsl05 +
                              gs_glt0-hsl06 + gs_glt0-hsl07 .
      WHEN 9.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04 + gs_glt0-hsl05 +
                              gs_glt0-hsl06 + gs_glt0-hsl07 +
                              gs_glt0-hsl08.
      WHEN 10.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04 + gs_glt0-hsl05 +
                              gs_glt0-hsl06 + gs_glt0-hsl07 +
                              gs_glt0-hsl08 + gs_glt0-hsl09 .
      WHEN 11.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04 + gs_glt0-hsl05 +
                              gs_glt0-hsl06 + gs_glt0-hsl07 +
                              gs_glt0-hsl08 + gs_glt0-hsl09 +
                              gs_glt0-hsl10 .
      WHEN 12.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04 + gs_glt0-hsl05 +
                              gs_glt0-hsl06 + gs_glt0-hsl07 +
                              gs_glt0-hsl08 + gs_glt0-hsl09 +
                              gs_glt0-hsl10 + gs_glt0-hsl11 .

      WHEN 13.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04 + gs_glt0-hsl05 +
                              gs_glt0-hsl06 + gs_glt0-hsl07 +
                              gs_glt0-hsl08 + gs_glt0-hsl09 +
                              gs_glt0-hsl10 + gs_glt0-hsl11 +
                              gs_glt0-hsl12.
      WHEN 14.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04 + gs_glt0-hsl05 +
                              gs_glt0-hsl06 + gs_glt0-hsl07 +
                              gs_glt0-hsl08 + gs_glt0-hsl09 +
                              gs_glt0-hsl10 + gs_glt0-hsl11 +
                              gs_glt0-hsl12 + gs_glt0-hsl13 .
      WHEN 15.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04 + gs_glt0-hsl05 +
                              gs_glt0-hsl06 + gs_glt0-hsl07 +
                              gs_glt0-hsl08 + gs_glt0-hsl09 +
                              gs_glt0-hsl10 + gs_glt0-hsl11 +
                              gs_glt0-hsl12 + gs_glt0-hsl13 +
                              gs_glt0-hsl14.
      WHEN 16.
        ls_outtab-saldo_end = gs_glt0-hslvt + gs_glt0-hsl01 +
                              gs_glt0-hsl02 + gs_glt0-hsl03 +
                              gs_glt0-hsl04 + gs_glt0-hsl05 +
                              gs_glt0-hsl06 + gs_glt0-hsl07 +
                              gs_glt0-hsl08 + gs_glt0-hsl09 +
                              gs_glt0-hsl10 + gs_glt0-hsl11 +
                              gs_glt0-hsl12 + gs_glt0-hsl13 +
                              gs_glt0-hsl14 + gs_glt0-hsl15.



      WHEN OTHERS.
    ENDCASE.




    COLLECT ls_outtab INTO gt_outtab.
    CLEAR ls_outtab.

  ENDLOOP.

  IF p_monat = 1.
    LOOP AT gt_outtab INTO ls_outtab.
      IF ls_outtab-saldo_end < '0.00'.
        ls_outtab-dmbtr_h = ls_outtab-saldo_end * -1.
      ELSE.
        ls_outtab-dmbtr_s = ls_outtab-saldo_end.
      ENDIF.
      MODIFY gt_outtab FROM ls_outtab.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " get_SAKNR
" SORT_INIT
*&---------------------------------------------------------------------*
*&      Form  SORT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_SORT  text
*----------------------------------------------------------------------*
FORM sort_init  USING expa TYPE c
                CHANGING t_sort TYPE slis_t_sortinfo_alv.

  DATA: ls_sort TYPE slis_sortinfo_alv,
        l_expa.

  REFRESH  t_sort.
*  MOVE expa TO l_expa.

*  MOVE expa TO l_expa.
*  ls_sort-fieldname = 'SGTXT2'.
*  ls_sort-subtot = 'X'.
*  ls_sort-expa = l_expa.
*  APPEND ls_sort TO t_sort.CLEAR ls_sort.

  MOVE expa TO l_expa.
  ls_sort-fieldname = 'HKONT'.
  ls_sort-subtot = 'X'.
  ls_sort-expa = l_expa.
  APPEND ls_sort TO t_sort.CLEAR ls_sort.

  MOVE expa TO l_expa.
  ls_sort-fieldname = 'BUDAT'.
  ls_sort-expa = l_expa.
  APPEND ls_sort TO t_sort.CLEAR ls_sort.

  MOVE expa TO l_expa.
  ls_sort-fieldname = 'BELNR'.
  ls_sort-expa = l_expa.
  APPEND ls_sort TO t_sort.CLEAR ls_sort.

ENDFORM.                    " SORT_INIT
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.     "#EC *

  DATA ls_outtab TYPE ty_s_outtab.

  CASE r_ucomm.

    WHEN 'LINE'.
      CALL SCREEN 0100
        STARTING AT 20 1.

    WHEN 'DOWN'.

      PERFORM fill_file USING gt_outtab
                        CHANGING gt_download.

      PERFORM fill_total2 USING gt_tabtot
                          CHANGING gt_download.

      PERFORM download_txt USING gt_download.

*        ENDING   AT 73 6.

    WHEN '&BACK'.
      LEAVE TO SCREEN 0.
*      IF s_saknr[] IS NOT INITIAL.
*
*        SUBMIT zfilb005_2
*                WITH p_bukrs EQ p_bukrs
*                WITH p_gjahr EQ p_gjahr
*                WITH p_monat EQ p_monat
*                WITH p_mov   EQ p_mov
*                WITH p_path  EQ p_path
*                WITH p_rldnr EQ p_rldnr
*                WITH s_saknr IN s_saknr VIA SELECTION-SCREEN.
*      ELSE.
*        SUBMIT zfilb005_2
*        WITH p_bukrs EQ p_bukrs
*        WITH p_gjahr EQ p_gjahr
*        WITH p_monat EQ p_monat
*        WITH p_mov   EQ p_mov
*        WITH p_path  EQ p_path
*        WITH p_rldnr EQ p_rldnr
**              WITH s_saknr EQ s_saknr
*        VIA SELECTION-SCREEN.
*      ENDIF.

    WHEN '&OMP'.
      MOVE 'X' TO g_expa.
      PERFORM sort_init USING  g_expa
                        CHANGING gt_sort.
      PERFORM show_alv.

    WHEN '&XPA'.
      CLEAR g_expa.
      PERFORM sort_init USING  g_expa
                        CHANGING gt_sort.
      PERFORM show_alv.

    WHEN '&IC1'.
      READ TABLE gt_outtab
        INTO ls_outtab
        INDEX rs_selfield-tabindex .

      CASE rs_selfield-fieldname.

        WHEN 'BELNR'.
          CHECK   rs_selfield-value IS NOT INITIAL.
          SET PARAMETER ID: 'BLN' FIELD ls_outtab-belnr,
                            'BUK' FIELD ls_outtab-bukrs,
                            'GJR' FIELD ls_outtab-gjahr.

          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

        WHEN 'BUZEI'.
          CHECK   rs_selfield-value IS NOT INITIAL.
          SET PARAMETER ID: 'BLN' FIELD ls_outtab-belnr,
                            'BUK' FIELD ls_outtab-bukrs,
                            'GJR' FIELD ls_outtab-gjahr,
                            'BUZ' FIELD ls_outtab-buzei.
          CALL TRANSACTION 'FB09D' AND SKIP FIRST SCREEN.

        WHEN 'HKONT'.
*          SET PARAMETER ID:'ACC' FIELD  rs_selfield-value,
*         'BUK' FIELD p_bukrs,
*         'GJR' FIELD p_gjahr,
*         'GLN_FLEX' FIELD p_rldnr.
*          CALL TRANSACTION 'FAGLB03'.

          SUBMIT zfagl_account_balance
                  WITH racct EQ rs_selfield-value
                  WITH rbukrs EQ p_bukrs
                  WITH rldnr EQ p_rldnr
                  WITH ryear EQ p_gjahr
                  AND RETURN.

      ENDCASE.

  ENDCASE.

ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  layout_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.

*"Build layout for list display
  rs_layout-detail_popup      = 'X'.
*  rs_layout-subtotals_text    = 'ZW-SUMME:'.
*  rs_layout-totals_text       = 'SUMME:'.
  rs_layout-zebra = 'X'.
  rs_layout-expand_all = p_extend.

ENDFORM.                    "layout_init

*&---------------------------------------------------------------------*
*&      Form  download_txt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_DOWNLOAD  text
*----------------------------------------------------------------------*
FORM download_txt USING lt_download TYPE ty_t_download.

  DATA: l_path TYPE string.

  CONCATENATE p_path '/libro_mayor_' p_bukrs
              '_' sy-datum '_'
              sy-uzeit '.TXT' INTO l_path.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*      WRITE_FIELD_SEPARATOR  = '  '
      filename                = l_path
      filetype                = 'ASC'
    TABLES
      data_tab                = lt_download
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.

  IF sy-subrc NE 0.
    MESSAGE 'Error al descargar  archivo.' TYPE 'S'.
  ELSE.
    MOVE l_path TO g_path.
  ENDIF.

ENDFORM.                    " download_servidor
*&---------------------------------------------------------------------*
*&      Form  fill_foot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_foot  CHANGING t_download TYPE ty_t_download.

  DATA: ls_download TYPE ty_s_download.

  ls_download-data = space.
  APPEND ls_download TO t_download .

  ls_download-data = space.
  APPEND ls_download TO t_download .

ENDFORM.                    "fill_foot
*&---------------------------------------------------------------------*
*&      Form  fill_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_header  CHANGING t_download TYPE ty_t_download.

  DATA: ls_download TYPE ty_s_download,
        l_date      TYPE char20,
        l_month     TYPE fcltx .

  PERFORM get_month USING p_monat
                    CHANGING l_month.

  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+3(20) = g_butxt.
  ls_download-data+69(20) = 'Libro Mayor'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  CONCATENATE l_month p_gjahr
    INTO ls_download-data+67(20) SEPARATED BY space.
  APPEND ls_download TO t_download .
  CLEAR ls_download.

  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = c_line.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data(10)     = 'Cuenta'.
  ls_download-data+14(15)  = 'Fecha Documento'.
  ls_download-data+30(14)  = 'Núm. Documento'.
  ls_download-data+45(6)   = 'Cl.Doc'.
  ls_download-data+52(5)   = 'Línea'.
  ls_download-data+60(30)  = 'Glosa Movimiento'.
  ls_download-data+91(13)  = 'Debe'.
  ls_download-data+108(13) = 'Haber'.
  ls_download-data+125(13) = 'Saldo'.
  ls_download-data+137(16) = 'Saldo Acum.'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = c_line.
  APPEND ls_download TO t_download .CLEAR ls_download.

ENDFORM.                    " fill_header
*&---------------------------------------------------------------------*
*&      Form  fill_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_OUTTAB   text
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_file USING t_outtab      TYPE  ty_t_outtab
               CHANGING t_download TYPE ty_t_download.

  DATA: ls_outtab TYPE ty_s_outtab,
        ls_download TYPE ty_s_download,
        l_hkont TYPE hkont,
        l_saldo_s TYPE dmbtr_x8, " dmbtr, Modificado TIPO HCD 23-10-2012
        l_saldo_e TYPE dmbtr_x8, " dmbtr, Modificado TIPO HCD 23-10-2012
        l_debe  TYPE dmbtr_x8, " dmbtr, Modificado TIPO HCD 23-10-2012
        l_haber TYPE dmbtr_x8, " dmbtr, Modificado TIPO HCD 23-10-2012
        l_num TYPE i,
        l_mod TYPE i,
        l_linea TYPE i,
        l_total_lineas TYPE i,
        l_total_lineas4 TYPE i.

  CLEAR: g_num.
  CLEAR: l_linea.
  CLEAR: l_saldo_s,l_saldo_e,l_debe,l_haber.
  REFRESH gt_download.
  PERFORM fill_header CHANGING gt_download.

  MOVE g_line TO l_total_lineas.
  MOVE g_line TO l_total_lineas4.
  SUBTRACT 2 FROM l_total_lineas.
  SUBTRACT 4 FROM l_total_lineas4.
  ADD 10 TO l_linea.

  LOOP AT t_outtab  INTO ls_outtab .

    IF l_linea GE l_total_lineas.
      PERFORM fill_foot CHANGING gt_download.
      PERFORM fill_header CHANGING gt_download.
      MOVE 10 TO l_linea.
    ENDIF.

    ADD 1 TO g_num.

    IF l_hkont NE ls_outtab-hkont(10).

      MOVE ls_outtab-hkont TO l_hkont.

      IF g_num GT 1.

        IF l_linea GE l_total_lineas4 AND l_linea LE l_total_lineas.
          PERFORM fill_foot CHANGING gt_download.
          PERFORM fill_header CHANGING gt_download.
          MOVE 10 TO l_linea.
        ENDIF.

        ADD 1 TO g_num.
        ls_download-data = c_line.
        APPEND ls_download TO t_download .CLEAR ls_download.

        ls_download-data+60(21)  = 'Totales'.
        WRITE l_saldo_s    TO ls_download-data+116(16) CURRENCY 'CLP'.
        WRITE l_saldo_e    TO ls_download-data+133(16) CURRENCY 'CLP'.

        WRITE l_debe       TO ls_download-data+82(16) CURRENCY 'CLP'.
        WRITE l_haber      TO ls_download-data+99(16) CURRENCY 'CLP'.
        APPEND ls_download TO t_download .CLEAR ls_download.

        ls_download-data = c_line.
        APPEND ls_download TO t_download .CLEAR ls_download.

        ADD 3 TO l_linea.
        CLEAR: l_debe, l_haber.
        CLEAR: l_saldo_s,l_saldo_e.

      ENDIF.

      IF l_linea GE l_total_lineas4 AND l_linea LE l_total_lineas.
        PERFORM fill_foot CHANGING gt_download.
        PERFORM fill_header CHANGING gt_download.
        MOVE 10 TO l_linea.
      ENDIF.

      PERFORM get_description_hkont2 USING ls_outtab-hkont
                                     CHANGING ls_download-data+17(20).

      ls_download-data+3(10)  = ls_outtab-hkont.

      WRITE ls_outtab-dmbtr_s      TO ls_download-data+82(16) CURRENCY 'CLP'.
      WRITE ls_outtab-dmbtr_h      TO ls_download-data+99(16) CURRENCY 'CLP'.
      WRITE ls_outtab-saldo_end    TO ls_download-data+133(16) CURRENCY 'CLP'.
      APPEND ls_download TO t_download .CLEAR ls_download.

      ls_download-data = c_line.
      APPEND ls_download TO t_download .CLEAR ls_download.

      l_saldo_s = ls_outtab-saldo_start.
      l_saldo_e = ls_outtab-saldo_end.

      l_haber =  ls_outtab-dmbtr_h.
      l_debe  =  ls_outtab-dmbtr_s.
      ADD 2 TO l_linea.

    ELSE.

      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          date_internal            = ls_outtab-budat
        IMPORTING
          date_external            = ls_download-data+17(12)
        EXCEPTIONS
          date_internal_is_invalid = 1
          OTHERS                   = 2.

      ls_download-data+33(10)  = ls_outtab-belnr.
      ls_download-data+47(2)   = ls_outtab-blart.
      ls_download-data+53(3)   = ls_outtab-buzei.
      ls_download-data+60(21)  = ls_outtab-sgtxt.
      l_saldo_s =  ls_outtab-saldo_start.
      l_saldo_e =  ls_outtab-saldo_end.
      WRITE ls_outtab-dmbtr_s     TO ls_download-data+82(16)  CURRENCY 'CLP'.
      WRITE ls_outtab-dmbtr_h     TO ls_download-data+99(16)  CURRENCY 'CLP'.
      WRITE ls_outtab-saldo_start TO ls_download-data+116(16) CURRENCY 'CLP'.
      WRITE ls_outtab-saldo_end   TO ls_download-data+133(16) CURRENCY 'CLP'.
      APPEND ls_download TO t_download .
      CLEAR ls_download.
      l_haber = l_haber + ls_outtab-dmbtr_h.
      l_debe  = l_debe  + ls_outtab-dmbtr_s.

      ADD 1 TO l_linea.

    ENDIF.

  ENDLOOP.

  IF l_linea GE l_total_lineas.

    PERFORM fill_foot CHANGING gt_download.
    PERFORM fill_header CHANGING gt_download.
  ENDIF.

  ls_download-data = c_line.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+60(21)  = 'Totales'.
  WRITE l_saldo_s    TO ls_download-data+116(16) CURRENCY 'CLP'.
  WRITE l_saldo_e    TO ls_download-data+133(16) CURRENCY 'CLP'.
  WRITE l_debe       TO ls_download-data+82(16)  CURRENCY 'CLP'.
  WRITE l_haber      TO ls_download-data+99(16)  CURRENCY 'CLP'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = c_line.
  APPEND ls_download TO t_download .CLEAR ls_download.

ENDFORM.                    " fill_file
*&---------------------------------------------------------------------*
*&      Form  fill_total
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_TABTOT   text
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_total USING t_tabtot TYPE ty_t_tabtot
                CHANGING t_download TYPE ty_t_download.

  DATA: ls_download TYPE ty_s_download,
        ls_tabtot   TYPE ty_s_tabtot.

  ls_download-data = space.
  APPEND ls_download TO t_download .

  ls_download-data+106(41) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+107(10) = 'Cl Doc'.
  ls_download-data+122(13) = 'Debe'.
  ls_download-data+139(13) = 'Haber'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+106(41) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.

  LOOP AT t_tabtot INTO ls_tabtot.
    ls_download-data+109(2)  = ls_tabtot-blart.
    WRITE ls_tabtot-dmbtr_s TO ls_download-data+127(13) CURRENCY 'CLP'.
    WRITE ls_tabtot-dmbtr_h TO ls_download-data+144(13) CURRENCY 'CLP'.
    APPEND ls_download TO t_download .CLEAR ls_download.
  ENDLOOP.

  ls_download-data+106(41) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+107(10) = 'Total'.
  WRITE dmbtr_s TO ls_download-data+127(15) CURRENCY 'CLP'.
  WRITE  dmbtr_h TO ls_download-data+144(15) CURRENCY 'CLP'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+106(41) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.

ENDFORM.                    " fill_total

*&---------------------------------------------------------------------*
*&      Form  fill_total
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_TABTOT   text
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_total2 USING t_tabtot TYPE ty_t_tabtot
                 CHANGING t_download TYPE ty_t_download.

  DATA: ls_download TYPE ty_s_download,
        ls_tabtot   TYPE ty_s_tabtot.
  DATA: l_dmbtr_s TYPE dmbtr_x8. " dmbtr, Modificado TIPO HCD 23-10-2012dmbtr.
  DATA: l_dmbtr_h TYPE dmbtr_x8. " dmbtr, Modificado TIPO HCD 23-10-2012dmbtr.

  LOOP AT t_tabtot INTO ls_tabtot.

*    ls_download-data+109(2)  = ls_tabtot-blart.
    l_dmbtr_s = l_dmbtr_s + ls_tabtot-dmbtr_s.
    l_dmbtr_h = l_dmbtr_h + ls_tabtot-dmbtr_h.

  ENDLOOP.

  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+64(10) = 'Total'.
  WRITE g_dmbtr_s TO ls_download-data+79(18)   CURRENCY 'CLP'.
  WRITE g_dmbtr_h TO ls_download-data+98(18)   CURRENCY 'CLP'.
  WRITE g_saldo_s1 TO ls_download-data+115(17) CURRENCY 'CLP'.
  WRITE g_saldo_e1 TO ls_download-data+132(17) CURRENCY 'CLP'.
  APPEND ls_download TO t_download .CLEAR ls_download.

ENDFORM.                    " fill_total

*&---------------------------------------------------------------------*
*&      Form  get_description_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS    text
*      -->P_BUTXT    text
*----------------------------------------------------------------------*
FORM get_description_bukrs USING p_bukrs TYPE bukrs
                           CHANGING p_butxt TYPE butxt.

  DATA : l_adrnr TYPE adrnr,
        l_zgiro TYPE zfigiro,
        l_address_selection TYPE addr1_sel.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE butxt adrnr
*    FROM t001
*    INTO (p_butxt, l_adrnr)
*    WHERE bukrs EQ p_bukrs
*    AND spras EQ sy-langu.
*
* NEW CODE
  SELECT butxt adrnr
  UP TO 1 ROWS 
    FROM t001
    INTO (p_butxt, l_adrnr)
    WHERE bukrs EQ p_bukrs
    AND spras EQ sy-langu ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  MOVE l_adrnr TO  l_address_selection-addrnumber.

  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = l_address_selection
    IMPORTING
      address_value     = g_address_value
    EXCEPTIONS
      parameter_error   = 1
      address_not_exist = 2
      version_not_exist = 3
      internal_error    = 4
      OTHERS            = 5.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE paval
*    FROM t001z
*    INTO g_paval
*    WHERE bukrs EQ p_bukrs
*    AND party EQ 'TAXNR' .
*
* NEW CODE
  SELECT paval
  UP TO 1 ROWS 
    FROM t001z
    INTO g_paval
    WHERE bukrs EQ p_bukrs
    AND party EQ 'TAXNR'  ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM zfigiro
*    INTO TABLE gt_zfigiro
*    WHERE bukrs = p_bukrs.
*
* NEW CODE
  SELECT *
 FROM zfigiro
    INTO TABLE gt_zfigiro
    WHERE bukrs = p_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  IF sy-subrc EQ 0.
    READ TABLE gt_zfigiro INTO l_zgiro INDEX 1.
    IF sy-subrc EQ 0.
      IF l_zgiro-giro_1 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_2 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_3 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_4 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_5 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_6 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_7 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.                    "get_description_bukrs
*&---------------------------------------------------------------------*
*&      Form  GET_SALDOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_saldos.

  DATA: ls_outtab TYPE ty_s_outtab,
        l_hkont   TYPE hkont,
        l_index   TYPE i.

*PYV 12/11/2012
  DATA: saldo_s1 LIKE ls_outtab-saldo_start,
        saldo_e1 LIKE ls_outtab-saldo_end.
  CLEAR saldo_s1.
  CLEAR saldo_e1.
*PYV 12/11/2012

  FIELD-SYMBOLS <ls_outtab> TYPE ty_s_outtab.

  CLEAR: g_saldo_s1, g_dmbtr_s, g_dmbtr_h.
  CLEAR g_saldo_e1.

  LOOP AT gt_outtab INTO ls_outtab.
    g_dmbtr_s   = g_dmbtr_s + ls_outtab-dmbtr_s.
    g_dmbtr_h   = g_dmbtr_h + ls_outtab-dmbtr_h.

    IF sy-tabix NE 1 AND l_hkont EQ ls_outtab-hkont(10).
      g_saldo_s = g_saldo_s + ls_outtab-dmbtr_s - ls_outtab-dmbtr_h.
      ls_outtab-saldo_start = g_saldo_s.
      l_index = sy-tabix - 1.
      READ TABLE  gt_outtab ASSIGNING <ls_outtab>
                           INDEX l_index.
      ls_outtab-saldo_end = ls_outtab-dmbtr_s - ls_outtab-dmbtr_h + <ls_outtab>-saldo_end.
*PYV 12/11/2012
      saldo_s1 = ls_outtab-saldo_start.
      saldo_e1 = ls_outtab-saldo_end.
*PYV 12/11/2012
    ENDIF.

    MODIFY gt_outtab FROM ls_outtab.

    IF l_hkont NE ls_outtab-hkont(10).
      MOVE ls_outtab-hkont(10) TO l_hkont.
      g_saldo_s1 = g_saldo_s1 + saldo_s1.
      g_saldo_e1 = g_saldo_e1 + saldo_e1.
      CLEAR: saldo_s1, saldo_e1, g_saldo_s.
      saldo_e1 = ls_outtab-saldo_end.
    ENDIF.

  ENDLOOP.

  g_saldo_s1 = g_saldo_s1 + saldo_s1.
  g_saldo_e1 = g_saldo_e1 + saldo_e1.



ENDFORM.                    " GET_SALDOS

*&---------------------------------------------------------------------*
*&      Form  get_description_hkont
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SAKNR    text
*      -->P_TXT20    text
*----------------------------------------------------------------------*
FORM get_description_hkont USING    p_saknr TYPE hkont
                           CHANGING p_txt20 TYPE txt20_skat.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE txt20
*    FROM skat
*    INTO p_txt20
*    WHERE spras EQ sy-langu
*    AND saknr EQ p_saknr.
*
* NEW CODE
  SELECT txt20
  UP TO 1 ROWS 
    FROM skat
    INTO p_txt20
    WHERE spras EQ sy-langu
    AND saknr EQ p_saknr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

ENDFORM.                    "get_description_hkont


*&---------------------------------------------------------------------*
*&      Form  get_description_hkont
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SAKNR    text
*      -->P_TXT20    text
*----------------------------------------------------------------------*
FORM get_description_hkont2 USING    p_saknr
                            CHANGING p_txt20 TYPE txt20_skat.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE txt20
*    FROM skat
*    INTO p_txt20
*    WHERE spras EQ sy-langu
*    AND saknr EQ p_saknr.
*
* NEW CODE
  SELECT txt20
  UP TO 1 ROWS 
    FROM skat
    INTO p_txt20
    WHERE spras EQ sy-langu
    AND saknr EQ p_saknr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

ENDFORM.                    "get_description_hkont
*&---------------------------------------------------------------------*
*&      Form  DELE_DH_CEROS
*&---------------------------------------------------------------------*
*       SE REVISARAN LOS TOTALES CUYA  CUENTA ( DEBE Y HABER )SEA CERO
*       OBJETIVO : SACAR EL REGISTRO DE TOTAL ACUMULADO
*----------------------------------------------------------------------*
*      -->P_GT_OUTTAB  text
*----------------------------------------------------------------------*
FORM dele_dh_ceros .

  DATA: ls_outtab TYPE ty_s_outtab.

  LOOP AT gt_outtab INTO ls_outtab.

    MOVE ls_outtab-hkont   TO gs_grptab-hkont.
    MOVE ls_outtab-dmbtr_s TO gs_grptab-dmbtr_s.
    MOVE ls_outtab-dmbtr_h TO gs_grptab-dmbtr_h.

    COLLECT gs_grptab INTO gt_grptab.
    CLEAR gs_grptab.

  ENDLOOP.

*ES GT_GRPTAB  SE BUSCARAN TODOS LOS DEBE Y HABER EN CERO PARA BORRARLOS EN gt_outtab
  DATA : ls_grptab TYPE ty_s_grptab.

  LOOP AT gt_grptab INTO ls_grptab.
    IF ls_grptab-dmbtr_s  EQ 0 AND ls_grptab-dmbtr_h EQ 0.
      DELETE gt_outtab
       WHERE hkont EQ ls_grptab-hkont.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " DELE_DH_CEROS
