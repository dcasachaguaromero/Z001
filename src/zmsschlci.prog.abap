*----------------------------------------------------------------------*
*   INCLUDE MSSCHLCI                                                   *
*----------------------------------------------------------------------*

class lcl_application implementation.

  method  handle_node_double_click.
    " this method handles the node double click event of the tree
    " control instance

    " show the key of the double clicked node in a dynpro field
**  g_event = 'NODE_DOUBLE_CLICK'.
    g_new_node = node_key.
    if g_new_node <> g_selected_node.
*   change screen
      g_last_node = g_selected_node.
      g_selected_node = g_new_node.
      g_prefix_old = g_prefix.
      g_prefix = g_selected_node.
      g_change_screen = 'X'.
    endif.
    clear g_selected_item.
  endmethod.

  method  handle_item_double_click.
    " this method handles the item double click event of the tree
    " control instance

    " show the key of the node and the name of the item
    " of the double clicked item in a dynpro field
**  g_event = 'ITEM_DOUBLE_CLICK'.
    g_new_node = node_key.
    if g_new_node <> g_selected_node.
*   change screen
      g_last_node = g_selected_node.
      g_selected_node = g_new_node.
      g_prefix_old = g_prefix.
      g_prefix = g_selected_node.
      g_change_screen = 'X'.
    endif.
    g_selected_item = item_name.
  endmethod.

endclass.
