*----------------------------------------------------------------------*
*   INCLUDE MSSCHF01                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
form graphic_import.

 case g_prefix.
 when prefix_bds_object
 or   prefix_bds_id.
      perform graphic_import_bds.
 when prefix_tx_graphics
 or   prefix_standard_texts.
      perform graphic_import_text.
 endcase.

endform.

*&---------------------------------------------------------------------*
form graphic_change_properties using p_prefix like g_prefix.
  case p_prefix.
  when prefix_bds_object
  or   prefix_bds_id.
       if g_modified_administration = true
       or g_modified_properties = true.
         perform save_bds_attributes.
       endif.
  when prefix_tx_graphics
  or   prefix_standard_texts.
       if g_modified_administration = true.
         perform save_stxh_titles.
       endif.
       if g_modified_properties = true.
         perform save_stxh_techinfo.
       endif.
  endcase.
endform.

*&---------------------------------------------------------------------*
form graphic_delete.

  case g_prefix.
  when prefix_bds_object
  or   prefix_bds_id.
       if rstxt-tdname is initial.
         message e830.
       endif.
       perform graphic_delete_bds.
  when prefix_tx_graphics
  or   prefix_standard_texts.
       if rstxt-tdname is initial or rstxt-tdspras is initial.
          message e629.
       endif.
       perform graphic_delete_text.
  endcase.

endform.

*&---------------------------------------------------------------------*
form graphic_print using p_device type c.

  case g_prefix.
  when prefix_bds_object
  or   prefix_bds_id.
       if rstxt-tdname is initial.
         message e830.
       endif.
       perform graphic_print_bds using p_device.
  when prefix_tx_graphics
  or   prefix_standard_texts.
       if rstxt-tdname is initial or rstxt-tdspras is initial.
          message e629.
       endif.
       perform graphic_print_text using p_device.
  endcase.

endform.

*&---------------------------------------------------------------------*
form graphic_refresh_preview.

  case g_prefix.
  when prefix_bds_object
  or   prefix_bds_id.
       if rstxt-tdname is initial.
         sub_areanr = screen_sub_empty.
         message e830.
       endif.
       perform graphic_print_bds using c_device_screen.
  when prefix_tx_graphics
  or   prefix_standard_texts.
       if rstxt-tdname is initial or rstxt-tdspras is initial.
          sub_areanr = screen_sub_empty.
          message e629.
       endif.
       perform graphic_print_text using c_device_screen.
  endcase.

endform.

*&---------------------------------------------------------------------*
form graphic_transport.
data l_task like e070-trkorr.

 case g_prefix.
 when prefix_bds_object
 or   prefix_bds_id.
      if rstxt-tdname is initial.
        message e830.
      endif.
      call function 'SAPSCRIPT_TRANSPORT_OBJECTS'
           exporting
                objecttype               = 'BDS'
                grobject                 = g_stxbitmaps-tdobject
                grname                   = g_stxbitmaps-tdname
                grid                     = g_stxbitmaps-tdid
                grtype                   = g_stxbitmaps-tdbtype
           importing
                e_task                   = l_task
           exceptions
                transport_impossible     = 1
                nothing_found            = 2
                others                   = 3.
      case sy-subrc.
      when 0.
           message s292 with g_stxbitmaps-tdname l_task.
      when 1.
           message e291 with g_stxbitmaps-tdname.
      when 2.
           message e287 with g_stxbitmaps-tdname.
      when others.
           message e001 with 'GRAPHIC_TRANSPORT' sy-repid.
      endcase.

 when prefix_tx_graphics
 or   prefix_standard_texts.
      if rstxt-tdname is initial or rstxt-tdspras is initial.
         message e629.
      endif.
      call function 'SAPSCRIPT_TRANSPORT_OBJECTS'
           exporting
                objecttype               = 'TEXT'
                textobject               = g_stxh-tdobject
                textname                 = g_stxh-tdname
                textid                   = g_stxh-tdid
                textspras                = g_stxh-tdspras
           importing
                e_task                   = l_task
           exceptions
                transport_impossible     = 1
                nothing_found            = 2
                others                   = 3.
      case sy-subrc.
      when 0.
           message s292 with g_stxh l_task.
      when 1.
          message e291 with g_stxh-tdname.
      when 2.
          message e624 with g_stxh-tdname   g_stxh-tdspras
                            g_stxh-tdobject g_stxh-tdid.
      when others.
          message e001 with 'GRAPHIC_TRANSPORT' sy-repid.
      endcase.

 endcase.

endform.
