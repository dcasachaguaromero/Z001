*----------------------------------------------------------------------*
*   INCLUDE MSSCHF04                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
form graphic_import_text.
data: l_tdname      like stxh-tdname,
      l_tdid        like stxh-tdid,
      l_language    like thead-tdspras.

  case g_stxh-tdobject.
  when c_graphics.
* authority check included in report RSTXLDMC
      call function 'SAPSCRIPT_IMPORT_GRAPHIC'
           exporting
                i_object   = c_graphics
                i_name     = g_stxh-tdname
                i_id       = g_stxh-tdid
                i_language = g_stxh-tdspras
           importing
                e_name     = l_tdname
                e_id       = l_tdid
           exceptions
                canceled          = 1
                others            = 2.
      if sy-subrc = 0.
        g_stxh-tdname = l_tdname.
        g_stxh-tdid   = l_tdid.
        message s288 with g_stxh-tdname.
        perform fill_textinfo.
      elseif sy-subrc = 1.    " Import canceled
        message s178.
      else.
        message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

  when c_stdtext.
       if g_stxh-tdspras is initial.
         l_language = sy-langu.
       else.
         l_language = g_stxh-tdspras.
       endif.
       if g_stxh-tdname is initial.
         submit rstxldmc via selection-screen and return
                 with txobject = c_stdtext
                 with txid     = g_stxh-tdid
                 with txlang   = l_language
                 with auto_hgt = 'X'.
       else.
         submit rstxldmc via selection-screen and return
                 with txname   = g_stxh-tdname
                 with txobject = c_stdtext
                 with txid     = g_stxh-tdid
                 with txlang   = l_language
                 with auto_hgt = 'X'.
       endif.
       perform fill_textinfo.

  endcase.

endform.

*&---------------------------------------------------------------------*
form graphic_import_bds.
data: l_tdname      like stxbitmaps-tdname,
      l_tdbtype     like stxbitmaps-tdbtype,
      l_resolution  like stxbitmaps-resolution,
      l_resident    like stxbitmaps-resident,
      l_autoheight  like stxbitmaps-autoheight.

* authority check für OBJECT GRAPHICS?
* ...

  call function 'SAPSCRIPT_IMPORT_GRAPHIC_BDS'
       exporting
            i_object       = g_stxbitmaps-tdobject
            i_name         = g_stxbitmaps-tdname
            i_id           = g_stxbitmaps-tdid
            i_btype        = g_stxbitmaps-tdbtype
*           i_resident     = g_stxbitmaps-resident
*           i_autoheight   = g_stxbitmaps-autoheight
       importing
            e_name         = l_tdname
            e_btype        = l_tdbtype
            e_resolution   = l_resolution
            e_resident     = l_resident
            e_autoheight   = l_autoheight
       exceptions
            enqueue_failed    = 1
            conversion_failed = 1
            canceled          = 2
            others            = 3.
  if sy-subrc = 0.
    g_stxbitmaps-tdname      = l_tdname.
    g_stxbitmaps-tdbtype     = l_tdbtype.
    g_stxbitmaps-resolution  = l_resolution.
    g_stxbitmaps-resident    = l_resident.
    g_stxbitmaps-autoheight  = l_autoheight.
    message s288 with g_stxbitmaps-tdname.
    perform fill_bds_properties.
  else.
    if sy-subrc = 1.
      message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    elseif sy-subrc = 2.       " Import canceled
      message s178.
    else.
      message e001 with 'GRAPHIC_IMPORT_BDS' sy-repid.
    endif.
  endif.

endform.

*&---------------------------------------------------------------------*
form graphic_delete_text.
field-symbols <l>.
data: l_entries like sy-tfill,
      l_len     type i,
      l_language(4),
      l_question(400),
      l_text(100),
      l_title(40),
      l_answer(1),
      l_return  type i.

  check g_stxh-tdobject =  c_graphics or g_stxh-tdobject =  c_stdtext.

  case g_stxh-tdobject.
  when c_graphics.
       perform check_authority_graphics using    g_stxh-tdname
                                                 g_stxh-tdspras
                                                 g_stxh-tdid
                                                 'EDIT'
                                        changing l_return.
       check l_return = 0.
  when c_stdtext.
       call function 'CHECK_TEXT_AUTHORITY'
            exporting
                 activity     = 'EDIT'
                 id           = g_stxh-tdid
                 language     = g_stxh-tdspras
                 name         = g_stxh-tdname
                 object       = c_stdtext
            exceptions
                 others       = 1.
       if sy-subrc <> 0.
         message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
       endif.
  endcase.

  call function 'SELECT_TEXT'
       exporting
            id                      = g_stxh-tdid
            language                = g_stxh-tdspras
            name                    = g_stxh-tdname
            object                  = g_stxh-tdobject
       importing
            entries                 = l_entries
       exceptions
            wrong_access_to_archive = 1
            others                  = 2.
  check sy-subrc = 0.

  if l_entries = 0.
     message e624 with g_stxh-tdname   g_stxh-tdspras
                       g_stxh-tdobject g_stxh-tdid.
  endif.

  case g_stxh-tdobject.
  when c_graphics.
       l_question = text-q01.
       l_len = strlen( g_stxh-tdname ).
       assign g_stxh-tdname(l_len) to <l>.
       replace '&1' with <l> into l_question.
       write g_stxh-tdspras to l_language.
       l_len = strlen( l_language ).
       assign l_language(l_len) to <l>.
       replace '&2' with <l> into l_question.
       if g_stxh-tdid = c_bmon.
          l_text = text-q05.
       elseif g_stxh-tdid = c_bcol.
          l_text = text-q06.
       endif.
       l_len = strlen( l_text ).
       assign l_text(l_len) to <l>.
       replace '&3' with <l> into l_question.
       l_title = text-t01.
  when c_stdtext.
       l_question = text-q10.
       l_len = strlen( g_stxh-tdname ).
       assign g_stxh-tdname(l_len) to <l>.
       replace '&1' with <l> into l_question.
       write g_stxh-tdspras to l_language.
       l_len = strlen( l_language ).
       assign l_language(l_len) to <l>.
       replace '&2' with <l> into l_question.
       l_title = text-t10.
  endcase.

  call function 'POPUP_TO_CONFIRM'
       exporting
            titlebar              = l_title
            text_question         = l_question
            text_button_1         = 'Ja'(001)
            icon_button_1         = ' '
            text_button_2         = 'Nein'(002)
            icon_button_2         = ' '
*           DEFAULT_BUTTON        = '1'
*           DISPLAY_CANCEL_BUTTON = 'X'
*           USERDEFINED_F1_HELP   = ' '
*           START_COLUMN          = 25
*           START_ROW             = 6
*           POPUP_TYPE            =
       importing
            answer                = l_answer
       exceptions
            others                = 1.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  if l_answer = '1'.
    call function 'DELETE_TEXT'
         exporting
              id              = g_stxh-tdid
              language        = g_stxh-tdspras
              name            = g_stxh-tdname
              object          = g_stxh-tdobject
         exceptions
              not_found       = 1
              others          = 2.
    if sy-subrc = 0.
      case g_stxh-tdobject.
      when c_graphics.
           l_question = text-m01.
      when c_stdtext.
           l_question = text-m10.
      endcase.
      l_len = strlen( g_stxh-tdname ).
      assign g_stxh-tdname(l_len) to <l>.
      replace '&' with <l> into l_question length l_len.
      message s252 with l_question.
    endif.
  endif.


endform.

*&---------------------------------------------------------------------*
form graphic_delete_bds.
data l_text(100).

  call function 'SAPSCRIPT_DELETE_GRAPHIC_BDS'
       exporting
            i_object       = g_stxbitmaps-tdobject
            i_name         = g_stxbitmaps-tdname
            i_id           = g_stxbitmaps-tdid
            i_btype        = g_stxbitmaps-tdbtype
            dialog         = 'X'
       exceptions
            delete_failed  = 1
            not_found      = 2
            canceled       = 3
            others         = 4 .
  if sy-subrc = 0.
    l_text = text-m01.
    replace '&' with g_stxbitmaps-tdname into l_text.
    condense l_text.
    message s252 with l_text.
  else.
    case sy-subrc.
    when 1.
         message s286 with g_stxbitmaps-tdname.
    when 2.
         message s287 with g_stxbitmaps-tdname.
    when 3.
      message s178.
    when others.
         message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endcase.
  endif.


endform.

*&---------------------------------------------------------------------*
form graphic_print_text using p_device type c.
data: l_header     like thead,
      l_lines      like tline occurs 0 with header line,
      l_options    like itcpo,
      l_result     like itcpp,
      l_return1    type i,
      l_dest_long_name like tsp03l-lname.

  if g_stxh-tdobject = c_graphics.
    perform check_authority_graphics using    g_stxh-tdname
                                              g_stxh-tdspras
                                              g_stxh-tdid
                                              'SHOW'
                                     changing l_return1.
     check l_return1 = 0.
  elseif g_stxh-tdobject = c_stdtext.
    perform check_authority_text using    g_stxh-tdname
                                          g_stxh-tdspras
                                          g_stxh-tdid
                                          'SHOW'
                                 changing l_return1.
     check l_return1 = 0.
  endif.

  call function 'READ_TEXT'
       exporting
            id                      = g_stxh-tdid
            language                = g_stxh-tdspras
            name                    = g_stxh-tdname
            object                  = g_stxh-tdobject
       importing
            header                  = l_header
       tables
            lines                   = l_lines
       exceptions
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            others                  = 8.
  if sy-subrc = 1.
    message e624 with g_stxh-tdname   g_stxh-tdspras
                      g_stxh-tdobject g_stxh-tdid.
  elseif sy-subrc <> 0.
    call function 'SAPSCRIPT_MESSAGE'.
    exit.
  endif.

  if p_device = c_device_printer.

    clear l_options.
    l_options-tdnoprev  = true.
    l_options-tdnoarmch = true.
    l_options-tdnewid   = true.
    l_options-tdtitle   = text-t02.
    l_options-tddest    = '*'.
    l_options-tdimmed   = '*'.
    l_options-tddelete  = '*'.

    call function 'PRINT_TEXT'
         exporting
              dialog                   = true
              header                   = l_header
              options                  = l_options
         importing
              result                   = l_result
         tables
              lines                    = l_lines
         exceptions
              others                   = 1.
    if sy-subrc = 0.
      write l_result-tddest to l_dest_long_name.
      message s433 with l_result-tdspoolid l_dest_long_name.
    else.
      message id sy-msgid type 'S' number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

  elseif p_device = c_device_screen.

    call function 'SAPSCRIPT_CONVERT_BITMAP'
         exporting
              itf_header             = l_header
              old_format             = 'ITF'
              new_format             = 'BMP'
         importing
              bitmap_file_bytecount  = graphic_size
         tables
              itf_lines              = l_lines
              bitmap_file            = graphic_table
         exceptions
              no_bitmap_file         = 1
              format_not_supported   = 2
              bitmap_file_not_type_x = 3
              others                 = 4 .
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      exit.
    endif.
    check graphic_size > 0.
    call function 'DP_CREATE_URL'
         exporting
            type                 = 'image'            "#EC NOTEXT
            subtype              = cndp_sap_tab_unknown
            size                 = graphic_size
            lifetime             = cndp_lifetime_transaction
         tables
            data                 = graphic_table
         changing
            url                  = graphic_url
         exceptions
*           DP_INVALID_PARAMETER = 1
*           DP_ERROR_PUT_TABLE   = 2
*           DP_ERROR_GENERAL     = 3
            others               = 4 .
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      exit.
    endif.

    graphic_refresh = true.

  endif.

endform.

*&---------------------------------------------------------------------*
form graphic_print_bds using p_device type c.
data: l_lines      like tline occurs 0 with header line,
      l_header     like thead,
      l_options    like itcpo,
      l_result     like itcpp,
      l_content    type sbdst_content,
      l_wa_content type line of sbdst_content,
      l_bdslen     type i,
      l_size       type i,
      l_dest_long_name like tsp03l-lname.

data: l_graphic_xstr type xstring,
      l_graphic_conv type i,
      l_graphic_offs type i.

*perform check_authority_graphics using    rstxt-tdname
*                                 rstxt-tdspras
*                                 l_id
*                                 'SHOW'
*                        changing l_return1.
*check l_return1 = 0.


 if p_device = c_device_printer.

   if  g_stxbitmaps-tdbtype <> c_bmon
   and g_stxbitmaps-tdbtype <> c_bcol.
     message e296 with g_stxbitmaps-tdbtype.
   endif.

   call function 'SAPSCRIPT_GENERATE_BMP_COMMAND'
        exporting
             bm_name      = g_stxbitmaps-tdname
             bm_object    = g_stxbitmaps-tdobject
             bm_id        = g_stxbitmaps-tdid
             bm_type      = g_stxbitmaps-tdbtype
*            BM_XPOS      =
*            BM_XPOS_UNIT = 'MM'
             bm_dpi       = g_stxbitmaps-resolution
        importing
             bm_command   = l_lines.
   append l_lines.

   clear l_options.
   l_options-tdnoprev  = true.
   l_options-tdnoarmch = true.
   l_options-tdnewid   = true.
   l_options-tdtitle   = text-t02.
   l_options-tddest    = '*'.
   l_options-tdimmed   = '*'.
   l_options-tddelete  = '*'.

   l_header-tdform  = 'SYSTEM'.
   l_header-tdspras = sy-langu.

   call function 'PRINT_TEXT'
        exporting
             device                   = 'PRINTER'
             dialog                   = 'X'
             header                   = l_header
             options                  = l_options
        importing
             result                   = l_result
        tables
             lines                    = l_lines
        exceptions
             others                   = 1.
   if sy-subrc = 0.
     write l_result-tddest to l_dest_long_name.
     message s433 with l_result-tdspoolid l_dest_long_name.
   else.
     message id sy-msgid type 'S' number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
   endif.

 elseif p_device = c_device_screen.

   if  g_stxbitmaps-tdbtype <> c_bmon
   and g_stxbitmaps-tdbtype <> c_bcol.
     message e297 with g_stxbitmaps-tdbtype.
   endif.

   clear: graphic_url,
          graphic_table[].
   call method cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
        exporting  p_object  = g_stxbitmaps-tdobject
                   p_name    = g_stxbitmaps-tdname
                   p_id      = g_stxbitmaps-tdid
                   p_btype   = g_stxbitmaps-tdbtype
        receiving  p_bmp     = l_graphic_xstr
        exceptions not_found = 1
                   others    = 2.
   if sy-subrc = 1.
     message e287 with g_stxbitmaps-tdname.
   elseif sy-subrc <> 0.
     message id sy-msgid type sy-msgty number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
     exit.
   endif.

   graphic_size = xstrlen( l_graphic_xstr ).
   check graphic_size > 0.

   l_graphic_conv = graphic_size.
   l_graphic_offs = 0.

   while l_graphic_conv > 255.
     graphic_table-line = l_graphic_xstr+l_graphic_offs(255).
     append graphic_table.
     l_graphic_offs = l_graphic_offs + 255.
     l_graphic_conv = l_graphic_conv - 255.
   endwhile.

   graphic_table-line = l_graphic_xstr+l_graphic_offs(l_graphic_conv).
   append graphic_table.

   call function 'DP_CREATE_URL'
        exporting
           type                 = 'image'                "#EC NOTEXT
           subtype              = cndp_sap_tab_unknown " 'X-UNKNOWN'
           size                 = graphic_size
           lifetime             = cndp_lifetime_transaction  " 'T'
        tables
           data                 = graphic_table
        changing
           url                  = graphic_url
        exceptions
*           DP_INVALID_PARAMETER = 1
*           DP_ERROR_PUT_TABLE   = 2
*           DP_ERROR_GENERAL     = 3
           others               = 4 .
   if sy-subrc <> 0.
     message id sy-msgid type sy-msgty number sy-msgno
             with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
     exit.
   endif.

   graphic_refresh = true.

 endif.

endform.
