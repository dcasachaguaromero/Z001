*----------------------------------------------------------------------*
***INCLUDE MSSCHO02 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
module status_2000 output.
  data: l_change_screen(1).
  set pf-status 'INIT'.
  set titlebar '001'.

  if h_application is initial.
    create object h_application.
  endif.

  if h_docking is initial.
    create object h_docking
           exporting repid     = g_repid
                     dynnr     = g_dynnr
                     side      = cl_gui_docking_container=>dock_at_left
                     extension = 300.
  endif.

  if h_tree is initial.
    perform create_and_init_tree.
    rsscg-btype_bmon = true.
    rsscg-btype_bcol = false.
    sub_headernr    = screen_sub_empty.
    sub_areanr      = screen_sub_empty.
    g_modified_administration = false.
    g_modified_properties     = false.
  endif.

  if g_change_screen = true.
    g_change_screen = false.
    perform change_subs_and_properties.
  endif.
* * ****************************************************
 IF fcode_old eq ''.
  perform fill_stxbitmaps.
  perform save_on_request using    g_prefix_old  " save possible changes
                          changing l_change_screen.
  if l_change_screen = false.    " save procedure canceled
    exit.
  else.
    g_modify_screen = fcode_save_att.
  endif.
*   if g_prefix = prefix_bds_id.
         perform fill_stxbitmaps.
*       endif.
       sub_headernr = screen_sub_header_bds.
       if not g_stxbitmaps-tdname is initial.
         perform fill_bds_properties.          " => changes sub_areanr
       else.
         sub_areanr = screen_sub_empty.
       endif.
 g_stxbitmaps-tdobject = 'GRAPHICS'.
 g_stxbitmaps-tdid     = 'BMAP'.
 g_prefix = 'GRI'.
 ENDIF.
************************************************+
endmodule.                 " STATUS_2000  OUTPUT

*----------------------------------------------------------------------*
form change_subs_and_properties.
data: l_change_screen(1).

  perform save_on_request using    g_prefix_old  " save possible changes
                          changing l_change_screen.
  if l_change_screen = false.    " save procedure canceled
    exit.
  else.
    g_modify_screen = fcode_save_att.
  endif.
  case g_prefix.
  when prefix_bds_object
  or   prefix_bds_id.
       if g_prefix = prefix_bds_id.
         perform fill_stxbitmaps.
       endif.
       sub_headernr = screen_sub_header_bds.
       if not g_stxbitmaps-tdname is initial.
         perform fill_bds_properties.          " => changes sub_areanr
       else.
         sub_areanr = screen_sub_empty.
       endif.
  when prefix_tx_graphics.
       sub_headernr = screen_sub_header_graphics.
       perform fill_stxh using c_graphics.
       if not ( g_stxh-tdname  is initial or
                g_stxh-tdspras is initial    ).
         perform fill_textinfo.                " => changes sub_areanr
       else.
         sub_areanr = screen_sub_empty.
       endif.
  when prefix_standard_texts.
       sub_headernr = screen_sub_header_text.
       perform fill_stxh using c_stdtext.
       if not ( g_stxh-tdname  is initial or
                g_stxh-tdspras is initial    ).
         perform fill_textinfo.                " => changes sub_areanr
       else.
         sub_areanr = screen_sub_empty.
       endif.
  when others.
       sub_headernr = screen_sub_empty.
       sub_areanr   = screen_sub_empty.
  endcase.

endform.

*----------------------------------------------------------------------*
form set_sub_areanr using p_exists  type c
                          p_bds     type c.

  if p_exists = false.
    sub_areanr = screen_sub_empty.
  else.
    case sub_areanr.
    when screen_sub_empty
    or   screen_sub_attr_bds
    or   screen_sub_attr_text.
         if p_bds = true.
           sub_areanr = screen_sub_attr_bds.
         else.
           sub_areanr = screen_sub_attr_text.
         endif.
    when screen_sub_preview.
         perform graphic_refresh_preview.
    endcase.
  endif.

endform.

*&---------------------------------------------------------------------*
*&      Module  STATUS_2005  OUTPUT
*&---------------------------------------------------------------------*
module status_2005 output.

  if h_picture is initial.
    create object h_pic_container
           exporting container_name =  'CONTAINER_PICTURE'.
    create object h_picture exporting parent = h_pic_container.

    call method h_picture->set_display_mode
         exporting
              display_mode = cl_gui_picture=>display_mode_normal.
***          display_mode = cl_gui_picture=>display_mode_normal_center.
  endif.

  if graphic_refresh = true.
* Grafik gelesen in graphic_print_...
* URL für interne Tabelle erzeugt in graphic_print_...
    call method h_picture->load_picture_from_url
         exporting url    = graphic_url
         importing result = g_result.
    if g_result = cntl_false.
*    message e...
      exit.
    endif.
    graphic_refresh = false.
  endif.

endmodule.                 " STATUS_2005  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_201X  OUTPUT
*&---------------------------------------------------------------------*
*  Subscreens 2011 and 2012                                           -*
*----------------------------------------------------------------------*
module modify_201x output.

  case g_modify_screen.
  when fcode_change_att.
       loop at screen.
         if screen-group1 = 'CH1'.
           screen_active.
         elseif screen-group1 = 'SV1'.
           screen_inactive.
         endif.
       endloop.
  when fcode_save_att
  or   space.
       loop at screen.
         if screen-group1 = 'SV1'.
           screen_active.
         elseif screen-group1 = 'CH1'.
           screen_inactive.
         endif.
       endloop.
  endcase.

endmodule.                 " MODIFY_201X  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_FIELDS_2001  OUTPUT
*&---------------------------------------------------------------------*
module set_fields_2001 output.

  rstxt-tdname = g_stxbitmaps-tdname.
  if g_stxbitmaps-tdbtype = c_bmon.
    rsscg-btype_bmon = true.
    rsscg-btype_bcol = false.
  elseif g_stxbitmaps-tdbtype = c_bcol.
    rsscg-btype_bcol = true.
    rsscg-btype_bmon = false.
  endif.

endmodule.                 " SET_FIELDS_2001  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_FIELDS_200X  OUTPUT
*&---------------------------------------------------------------------*
*  Subscreens 2002 and 2003                                           -*
*----------------------------------------------------------------------*
module set_fields_200x output.

  rstxt-tdname  = g_stxh-tdname.
  rstxt-tdspras = g_stxh-tdspras.

endmodule.                 " SET_FIELDS_200X  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_FIELDS_2010  OUTPUT        text header info
*&---------------------------------------------------------------------*
module set_fields_2011 output.

  rsscg-bds_fuser   = g_bds_properties-fuser.
  rsscg-fdate       = g_bds_properties-fdate.
  rsscg-ftime       = g_bds_properties-ftime.
  rsscg-bds_luser   = g_bds_properties-luser.
  rsscg-ldate       = g_bds_properties-ldate.
  rsscg-ltime       = g_bds_properties-ltime.
  rsscg-bds_title   = g_bds_properties-description.
  rsscg-resolution   = g_stxbitmaps-resolution.
  rsscg-resident     = g_stxbitmaps-resident.
  rsscg-autoheight   = g_stxbitmaps-autoheight.
  rsscg-compressed   = g_stxbitmaps-bmcomp.
  perform concatenate_size using    g_stxbitmaps-widthtw
                                    g_stxbitmaps-heighttw
                                    'TW'
                                    'CM'
                           changing t_size.

* g_bds_properties - dates/times have UTC format
* we need the local time zone format
  perform calc_date_time changing rsscg-fdate rsscg-ftime.
  perform calc_date_time changing rsscg-ldate rsscg-ltime.

endmodule.                 " SET_FIELDS_2011  OUTPUT
*----------------------------------------------------------------------*
form calc_date_time changing pdate type rsscg-fdate
                             ptime type rsscg-ftime.
  data: ts type timestamp.
  convert date pdate time ptime into time stamp ts time zone '      '.
  convert time stamp ts time zone sy-zonlo into date pdate time ptime.
endform.
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  SET_FIELDS_2012  OUTPUT        text header info
*&---------------------------------------------------------------------*
module set_fields_2012 output.

  rstxt-tdfuser   = g_stxh-tdfuser.
  rstxt-tdfdate   = g_stxh-tdfdate.
  rstxt-tdftime   = g_stxh-tdftime.
  rstxt-tdfreles  = g_stxh-tdfreles.
  rstxt-tdluser   = g_stxh-tdluser.
  rstxt-tdldate   = g_stxh-tdldate.
  rstxt-tdltime   = g_stxh-tdltime.
  rstxt-tdlreles  = g_stxh-tdlreles.
  rstxt-tdtitle   = g_stxh-tdtitle.
  rstxt-tdmacode1 = g_stxh-tdmacode1.
  rstxt-tdmacode2 = g_stxh-tdmacode2.
  move-corresponding g_techinfo to rsscg.
  perform concatenate_size using    g_techinfo-imagewidth
                                    g_techinfo-imagehght
                                    g_techinfo-imageunit
                                    'CM'
                           changing t_size.

endmodule.                 " SET_FIELDS_2012  OUTPUT

*----------------------------------------------------------------------*
form concatenate_size using    p_width       type any
                               p_height      type any
                               p_unit_from   type c
                               p_unit_to     type c
                      changing p_size_string type c.
data: l_heightc(9),
      l_widthc(9),
      l_height   type rsscg-imagehght,
      l_width    type rsscg-imagewidth,
      l_unit(10).

  if p_unit_from <> 'TW'.
    clear p_size_string.
    exit.
  endif.

  case p_unit_to.
     when 'TW'.
       l_unit = text-utw.
       l_height = p_height.
       l_width  = p_width.
     when 'PT'.
       l_unit = text-upt.
       l_height = p_height / 20.
       l_width  = p_width  / 20.
     when 'IN'.
       l_unit = text-uin.
       l_height = p_height / 1440.
       l_width  = p_width  / 1440.
     when 'CM'.
       l_unit = text-ucm.
       l_height = p_height * 254 / 144000.
       l_width  = p_width  * 254 / 144000.
     when 'MM'.
       l_unit = text-umm.
       l_height = p_height * 254 / 14400.
       l_width  = p_width  * 254 / 14400.
     when others.
       clear p_size_string.
       exit.
  endcase.

  write l_width to l_widthc.
  condense l_widthc.
  write l_height to l_heightc.
  condense l_heightc.

  concatenate l_widthc 'x' l_heightc l_unit into p_size_string
  separated by space.

endform.
