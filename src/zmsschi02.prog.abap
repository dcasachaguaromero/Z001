*----------------------------------------------------------------------*
***INCLUDE MSSCHI02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_2000 input.

  call method cl_gui_cfw=>dispatch.
  perform user_command_2000.

endmodule.                     " USER_COMMAND_2000  INPUT

form user_command_2000.
data: l_continue(1),
      l_change_screen(1).

  fcode_old = fcode.
  clear fcode.

  case fcode_old.
  when fcode_f12
  or   fcode_f3
  or   fcode_f15.
       perform save_on_request using    g_prefix " save possible changes
                               changing l_change_screen.
       check l_change_screen = true.
       perform destroy_controls.
       set screen 0.
       leave screen.
  when fcode_import.
       perform graphic_import.
  when fcode_delete.
       perform graphic_delete.
  when fcode_prop.
       case g_prefix.
       when prefix_bds_object
       or   prefix_bds_id.
            sub_areanr   = screen_sub_attr_bds.
       when prefix_tx_graphics
       or   prefix_standard_texts.
            sub_areanr   = screen_sub_attr_text.
       endcase.
  when fcode_copy.
*        perform graphic_copy.
  when fcode_find.
       perform graphic_find.
  when fcode_print.
       perform graphic_print using c_device_printer.
  when fcode_preview.
       perform save_on_request using    g_prefix " save possible changes
                               changing l_change_screen.
       check l_change_screen = true.
       sub_areanr   = screen_sub_preview.
       perform graphic_print using c_device_screen.
  when fcode_transport.
       perform graphic_transport.
  when fcode_rb_btype.
*       if rsscg-btype_bmon = true.
*         g_stxbitmaps-tdbtype = c_bmon.
*       elseif rsscg-btype_bcol = true.
*         g_stxbitmaps-tdbtype = c_bcol.
*       endif.
*       g_change_screen = true.
  when fcode_change_att.
       if g_modify_screen = fcode_change_att.
         perform change_subs_and_properties.
       else.
         perform check_authority changing l_continue.
         check l_continue = true.
         perform enqueue         changing l_continue.
         check l_continue = true.
         g_modify_screen = fcode_change_att.
       endif.
  when fcode_save_att.
       perform graphic_change_properties using g_prefix.
       perform dequeue using g_prefix.
       g_modify_screen = fcode_save_att.
  when 'SO10'.
       call transaction 'SO10'.
  when 'SE71'.
       call transaction 'SE71'.
  when 'SE72'.
       call transaction 'SE72'.
  when 'SE74'.
       call transaction 'SE74'.
  when 'SE73'.
       call transaction 'SE73'.
  when 'SE75'.
       call transaction 'SE75'.
  endcase.

endform.                   " USER_COMMAND_2000

*&---------------------------------------------------------------------*
*&      Module  STXBITMAPS_NAME  INPUT
*&---------------------------------------------------------------------*
module stxbitmaps_name input.

  if rsscg-btype_bmon = true.
    g_stxbitmaps-tdbtype = c_bmon.
  elseif rsscg-btype_bcol = true.
    g_stxbitmaps-tdbtype = c_bcol.
  endif.
  perform check_name using rstxt-tdname.
  g_stxbitmaps-tdname = rstxt-tdname.
  perform fill_bds_properties.
  g_change_screen = true.

endmodule.                 " STXBITMAPS_NAME  INPUT

*&---------------------------------------------------------------------*
*&      Module  STXBITMAPS_NAME_2004  INPUT
*&---------------------------------------------------------------------*
module stxbitmaps_name_2004 input.

  if rsscg-btype_bmon = true.
    g_stxbitmaps-tdbtype = c_bmon.
  elseif rsscg-btype_bcol = true.
    g_stxbitmaps-tdbtype = c_bcol.
  else.
    g_stxbitmaps-tdbtype = rsscg-btype.
  endif.
  perform check_name using rstxt-tdname.
  g_stxbitmaps-tdname = rstxt-tdname.
  perform fill_bds_properties.
  g_change_screen = true.

endmodule.                 " STXBITMAPS_NAME_2004  INPUT

*&---------------------------------------------------------------------*
*&      Module  STXH_NAME_SPRAS  INPUT
*&---------------------------------------------------------------------*
module stxh_name_spras input.

  perform check_name using rstxt-tdname.
  g_stxh-tdname = rstxt-tdname.
  g_stxh-tdspras = rstxt-tdspras.
  if not ( g_stxh-tdname is initial or g_stxh-tdspras is initial ).
    perform fill_textinfo.
  endif.

endmodule.                 " STXH_NAME_SPRAS  INPUT

*&---------------------------------------------------------------------*
*&      Form  check_name
*&---------------------------------------------------------------------*
form check_name using    p_name.

  if p_name ca '*,'.
     message e605 with p_name.
  endif.

endform.                    " check_name

*&---------------------------------------------------------------------*
*&      Module  STXH_TITLES  INPUT
*&---------------------------------------------------------------------*
module stxh_titles input.
  g_stxh-tdtitle    = rstxt-tdtitle.
  g_stxh-tdmacode1  = rstxt-tdmacode1.
  g_stxh-tdmacode2  = rstxt-tdmacode2.
  g_modified_administration = true.
endmodule.                 " STXH_TITLES  INPUT

*&---------------------------------------------------------------------*
*&      Module  STXH_RESOLUTION INPUT
*&---------------------------------------------------------------------*
module stxh_resolution.
  g_techinfo-resolution = rsscg-resolution.
  g_modified_properties = true.
  perform fill_sizeinfo.
endmodule.                 " STXH_RESOLUTION  INPUT

*&---------------------------------------------------------------------*
*&      Module  STXH_TECHINFO  INPUT
*&---------------------------------------------------------------------*
module stxh_techinfo input.
  g_techinfo-resident   = rsscg-resident.
  g_techinfo-autoheight = rsscg-autoheight.
  g_modified_properties = true.
endmodule.                 " STXH_TECHINFO  INPUT

*&---------------------------------------------------------------------*
*&      Module  BDS_TITLE  INPUT
*&---------------------------------------------------------------------*
module bds_title input.
  g_bds_properties-description = rsscg-bds_title.
  g_modified_administration = true.
endmodule.                 " BDS_TITLE  INPUT

*&---------------------------------------------------------------------*
*&      Module  BDS_TECHINFO  INPUT
*&---------------------------------------------------------------------*
module bds_techinfo input.
  g_stxbitmaps-resident   = rsscg-resident.
  g_stxbitmaps-autoheight = rsscg-autoheight.
  g_modified_properties = true.
endmodule.                 " BDS_TECHINFO  INPUT
