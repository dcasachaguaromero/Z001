*----------------------------------------------------------------------*
*   INCLUDE MSSCHDEF                                                   *
*----------------------------------------------------------------------*

define new_node_folder.
  clear wa_node.
  wa_node-node_key = &1.
  wa_node-relatkey = &2.
  wa_node-relatship = cl_gui_list_tree=>&3.
  wa_node-isfolder  = 'X'.
  wa_node-expander  = 'X'.
  wa_node-disabled  = 'X'.
  append wa_node to node_table.
end-of-definition.

define new_node_object.
  clear wa_node.
  wa_node-node_key = &1.
  wa_node-relatkey = &2.
  wa_node-relatship = cl_gui_list_tree=>&3.
  wa_node-isfolder  = 'X'.
  append wa_node to node_table.
end-of-definition.

define new_item.
  clear wa_item.
  wa_item-node_key   = &1.
  wa_item-item_name  = &2.
  wa_item-class      = cl_gui_list_tree=>item_class_text.
  wa_item-alignment  = cl_gui_list_tree=>align_auto.
  wa_item-font       = cl_gui_list_tree=>item_font_prop.
  wa_item-text       = &3.
  wa_item-usebgcolor = &4.
  append wa_item to item_table.
end-of-definition.

define build_nodekey.
  concatenate &1 wa_tabix into l_key.
  condense l_key no-gaps.
end-of-definition.

define screen_active.
  screen-input     = c_screen_on.
  screen-output    = c_screen_on.
  screen-invisible = c_screen_off.
  modify screen.
end-of-definition.

define screen_inactive.
  screen-input     = c_screen_off.
  screen-output    = c_screen_on.
  screen-invisible = c_screen_off.
  modify screen.
end-of-definition.

define screen_invisible.
  screen-input     = c_screen_off.
  screen-output    = c_screen_off.
  screen-invisible = c_screen_on.
  modify screen.
end-of-definition.
