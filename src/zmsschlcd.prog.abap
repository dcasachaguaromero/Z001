*----------------------------------------------------------------------*
*   INCLUDE MSSCHLCD                                                   *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*     LOCAL CLASS LCL_APPLICATION                                      *
*----------------------------------------------------------------------*
class lcl_application definition.
  public section.
   methods:
     handle_node_double_click
       for event node_double_click
       of cl_gui_list_tree
       importing node_key,
     handle_item_double_click
       for event item_double_click
       of cl_gui_list_tree
       importing node_key item_name.
endclass.
