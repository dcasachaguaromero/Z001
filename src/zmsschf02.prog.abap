*----------------------------------------------------------------------*
***INCLUDE MSSCHF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_TREE
*&---------------------------------------------------------------------*
form create_and_init_tree.
data:
   node_table     type treev_ntab,
   item_table     type item_table_type,
   wa_node        type treev_node,
   wa_item        type ssftreeit,
   wa_tabix(8)    type c,
   events         type cntl_simple_events,
   event          type cntl_simple_event,
   nodekey_table  type treev_nks,
   wa_nodekey     like line of nodekey_table.
data:
   l_ttxgrt  type standard table of ttxgrt with header line,
   l_ttxit   type standard table of ttxit  with header line,
   l_key     type treev_node-node_key,
   l_prev_ob_key type treev_node-node_key,
   l_prev_id_key type treev_node-node_key,
   l_prev_object type ttxgr-object.

  create object h_tree
      exporting
         parent              = h_docking
         node_selection_mode = cl_gui_list_tree=>node_sel_mode_single
         item_selection      = 'X'
         with_headers        = ' '.

* define the events which will be passed to the backend
  " node double click
  event-eventid = cl_gui_list_tree=>eventid_node_double_click.
  event-appl_event = 'X'. "
  append event to events.

  " item double click
  event-eventid = cl_gui_list_tree=>eventid_item_double_click.
  event-appl_event = 'X'.
  append event to events.

  call method h_tree->set_registered_events
      exporting
         events = events
      exceptions
         cntl_error                = 1
         cntl_system_error         = 2
         illegal_event_combination = 3.
  if sy-subrc = 0.
* assign event handlers in the application class to each desired event
    set handler h_application->handle_node_double_click for h_tree.
    set handler h_application->handle_item_double_click for h_tree.
  endif.

* Add nodes and items

* SAPscript-Grafiken
  new_node_folder c_key_root space relat_first_sibling.
  new_item        c_key_root 1 text-g10 ' '.
* Grafikablage BDS
  new_node_folder c_key_bds c_key_root relat_first_child.
  new_item        c_key_bds 1 text-g11 ' '.

* Collect header nodes for later expansion
  loop at node_table into wa_node.
    wa_nodekey = wa_node.
    append wa_nodekey to nodekey_table.
  endloop.

* Grafikablage über Texte
  new_node_folder c_key_stxl c_key_bds relat_next_sibling.
  new_item        c_key_stxl 1 text-g12 ' '.
* Rasterbilder
  new_node_folder c_key_stxl_graphics c_key_stxl relat_first_child.
  new_item        c_key_stxl_graphics 1 text-g13 ' '.
* Standardtexte
  new_node_folder c_key_stxl_text c_key_stxl_graphics
                                                 relat_next_sibling.
  new_item        c_key_stxl_text 1 text-g14 ' '.

* Generate graphic object and ID nodes
  select * from ttxgr into table g_ttxgr.
  sort g_ttxgr by object id.
  select * from ttxgrt into table l_ttxgrt.

  loop at g_ttxgr.
    wa_tabix = sy-tabix.
    build_nodekey prefix_bds_object.        " changes l_key
*   Object node
    if g_ttxgr-object <> l_prev_object.
      if l_prev_ob_key is initial.
        new_node_folder l_key c_key_bds relat_first_child.
      else.
        new_node_folder l_key l_prev_ob_key relat_next_sibling.
      endif.
      new_item l_key 1 g_ttxgr-object 'X'.
      read table l_ttxgrt with key spras  = sy-langu
                                   object = g_ttxgr-object
                                   id     = space.
      if sy-subrc = 0 and not l_ttxgrt-text is initial.
        new_item l_key 2 l_ttxgrt-text ' '.
      endif.
      l_prev_object = g_ttxgr-object.
      l_prev_ob_key = l_key.
      clear l_prev_id_key.
    endif.
*   ID node
    build_nodekey prefix_bds_id.          " changes l_key
    if l_prev_id_key is initial.
      new_node_object l_key l_prev_ob_key relat_first_child.
    else.
      new_node_object l_key l_prev_id_key relat_next_sibling.
    endif.
    new_item l_key 1 g_ttxgr-id 'X'.
    read table l_ttxgrt with key spras  = sy-langu
                                 object = g_ttxgr-object
                                 id     = g_ttxgr-id.
    if sy-subrc = 0 and not l_ttxgrt-text is initial.
      new_item l_key 2 l_ttxgrt-text ' '.
    endif.
    l_prev_id_key = l_key.
  endloop.

  concatenate prefix_tx_graphics c_bmon into l_prev_id_key.
  new_node_object   l_prev_id_key c_key_stxl_graphics relat_first_child.
  new_item          l_prev_id_key 1 text-g03 ' '.

  concatenate prefix_tx_graphics c_bcol into l_key.
  new_node_object   l_key l_prev_id_key relat_next_sibling.
  new_item          l_key 1 text-g04 ' '.

* Generate standard text ID nodes
  select * from ttxid into table g_ttxid where tdobject = 'TEXT'.
  select * from ttxit into table l_ttxit where tdobject = 'TEXT'.

  clear l_prev_id_key.
  loop at g_ttxid.
    wa_tabix = sy-tabix.
    build_nodekey prefix_standard_texts.        " changes l_key
    if l_prev_id_key is initial.
      new_node_object l_key c_key_stxl_text relat_first_child.
    else.
      new_node_object l_key l_prev_id_key relat_next_sibling.
    endif.
    new_item l_key 1 g_ttxid-tdid 'X'.
    read table l_ttxit with key tdspras  = sy-langu
                                tdid     = g_ttxid-tdid.
    if sy-subrc = 0 and not l_ttxit-tdtext is initial.
      new_item l_key 2 l_ttxit-tdtext ' '.
    endif.
    l_prev_id_key = l_key.
  endloop.

  call method h_tree->add_nodes_and_items
      exporting
         node_table = node_table
         item_table = item_table
         item_table_structure_name = 'SSFTREEIT'
      exceptions
         others                    = 1.


* Expand header nodes
  call method h_tree->expand_nodes
      exporting
         node_key_table = nodekey_table
      exceptions
         failed                    = 1
         cntl_system_error         = 2
         error_in_node_key_table   = 3
         dp_error                  = 4.

endform.                    " CREATE_AND_INIT_TREE

*&---------------------------------------------------------------------*
*&      Form  SELECT_NODE
*&---------------------------------------------------------------------*
form select_node using p_nodekey type tv_nodekey.

  check not p_nodekey is initial.
  call method h_tree->set_selected_node
      exporting
         node_key   = p_nodekey
      exceptions
         others     = 1.
  if sy-subrc = 0.
    g_last_node     = g_selected_node.
    g_selected_node = p_nodekey.
  else.
    message s001 with 'SELECT_NODE' sy-repid.
  endif.

endform.

*&---------------------------------------------------------------------*
*&      Form  SELECT_NODE_BDS
*&---------------------------------------------------------------------*
form select_node_bds using p_object like stxbitmaps-tdobject
                           p_id     like stxbitmaps-tdid
                           p_flush  type c.
data: wa_tabix(8)    type c,
      l_key          type treev_node-node_key.

  check not ( p_object is initial or p_id is initial ).
  read table g_ttxgr with key object = p_object
                              id     = p_id.
  check sy-subrc = 0.
  wa_tabix = sy-tabix.
  build_nodekey prefix_bds_id.
  perform select_node using l_key.

  if p_flush = true.
    call method cl_gui_cfw=>flush.
  endif.

endform.

*&---------------------------------------------------------------------*
*&      Form  SELECT_NODE_TEXT
*&---------------------------------------------------------------------*
form select_node_text using p_object like stxh-tdobject
                            p_id     like stxh-tdid
                            p_flush  type c.
data: wa_tabix(8)    type c,
      l_key          type treev_node-node_key.

  check not p_id is initial.

  if p_object = c_graphics.
    if p_id = c_bmon.
      concatenate prefix_tx_graphics c_bmon into l_key.
    elseif p_id = c_bcol.
      concatenate prefix_tx_graphics c_bcol into l_key.
    else.
      exit.
    endif.
  elseif p_object = c_stdtext.
    read table g_ttxid with key tdobject = p_object
                                tdid     = p_id.
    check sy-subrc = 0.
    wa_tabix = sy-tabix.
    build_nodekey prefix_standard_texts.
  else.
    exit.
  endif.

  perform select_node using l_key.

  if p_flush = true.
    call method cl_gui_cfw=>flush.
  endif.

endform.

*&---------------------------------------------------------------------*
*&      Form  DESTROY_CONTROLS
*&---------------------------------------------------------------------*
form destroy_controls.

* Destroy event handler
  clear h_application.

* Destroy tree control and initialize global variables
  if not h_tree is initial.
    call method h_tree->free
         exceptions others = 1.
    if sy-subrc = 0.
      clear h_tree.
    endif.
  endif.

* Destroy image control and container
  if not h_pic_container is initial.
    call method h_pic_container->free
         exceptions others = 1.
    if sy-subrc = 0.
      clear h_pic_container.
      clear h_picture.
    endif.
  endif.

* Destroy docking container
  if not h_docking is initial.
    call method h_docking->free
         exceptions others = 1.
    if sy-subrc = 0.
      clear h_docking.
    endif.
  endif.

endform.                    " DESTROY_CONTROLS
