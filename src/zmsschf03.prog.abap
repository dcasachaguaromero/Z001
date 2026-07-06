*----------------------------------------------------------------------*
***INCLUDE MSSCHF03 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FILL_STXBITMAPS
*&---------------------------------------------------------------------*
form fill_stxbitmaps.
field-symbols <l_tabix>.
data: l_tabix like sy-tabix.

  assign g_selected_node+3(*) to <l_tabix>.
  l_tabix = <l_tabix>.
  check l_tabix > 0.                   "***************************
  read table g_ttxgr index l_tabix.
  check sy-subrc = 0.                  "***************************
  if g_ttxgr-object <> g_stxbitmaps-tdobject
  or g_ttxgr-id     <> g_stxbitmaps-tdid.
    g_stxbitmaps-tdobject = g_ttxgr-object.
    g_stxbitmaps-tdid     = g_ttxgr-id.
  endif.
  if rsscg-btype_bmon = true.
    g_stxbitmaps-tdbtype = c_bmon.
  elseif rsscg-btype_bcol = true.
    g_stxbitmaps-tdbtype = c_bcol.
  else.
    g_stxbitmaps-tdbtype = rsscg-btype.
  endif.

endform.                    " FILL_STXBITMAPS

*&---------------------------------------------------------------------*
*&      Form  FILL_BDS_PROPERTIES
*&---------------------------------------------------------------------*
form fill_bds_properties.

  call function 'SAPSCRIPT_ATTRIB_GRAPHIC_BDS'
       exporting
            i_object        = g_stxbitmaps-tdobject
            i_name          = g_stxbitmaps-tdname
            i_id            = g_stxbitmaps-tdid
            i_btype         = g_stxbitmaps-tdbtype
            read_only       = true
       importing
            e_fuser         = g_bds_properties-fuser
            e_fdate         = g_bds_properties-fdate
            e_ftime         = g_bds_properties-ftime
            e_luser         = g_bds_properties-luser
            e_ldate         = g_bds_properties-ldate
            e_ltime         = g_bds_properties-ltime
            e_description   = g_bds_properties-description
            e_resolution    = g_stxbitmaps-resolution
            e_resident      = g_stxbitmaps-resident
            e_autoheight    = g_stxbitmaps-autoheight
            e_widthtw       = g_stxbitmaps-widthtw
            e_heighttw      = g_stxbitmaps-heighttw
            e_widthpix      = g_stxbitmaps-widthpix
            e_heightpix     = g_stxbitmaps-heightpix
            e_compressed    = g_stxbitmaps-bmcomp
       exceptions
            bds_info_failed = 1
            not_found       = 2
            others          = 3.
  if sy-subrc = 0.
    perform set_sub_areanr using true true.
  else.
    perform set_sub_areanr using false true.
    if sy-subrc = 1.
      clear g_bds_properties.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    elseif sy-subrc = 2.
      clear: g_bds_properties,
             g_stxbitmaps-resolution,
             g_stxbitmaps-resident, g_stxbitmaps-autoheight,
             g_stxbitmaps-widthtw,  g_stxbitmaps-heighttw,
             g_stxbitmaps-widthpix, g_stxbitmaps-heightpix,
             g_stxbitmaps-bmcomp.
      message s287 with g_stxbitmaps-tdname.
    else.
      clear: g_bds_properties,
             g_stxbitmaps-resolution,
             g_stxbitmaps-resident, g_stxbitmaps-autoheight,
             g_stxbitmaps-widthtw,  g_stxbitmaps-heighttw,
             g_stxbitmaps-widthpix, g_stxbitmaps-heightpix,
             g_stxbitmaps-bmcomp.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

endform.                    " FILL_BDS_PROPERTIES

*&---------------------------------------------------------------------*
*&      Form  FILL_STXH
*&---------------------------------------------------------------------*
*      -->P_OBJECT    'GRAPHICS' or 'TEXT'
*----------------------------------------------------------------------*
form fill_stxh using    p_object type thead-tdobject.
field-symbols <l_tabix>.
data: l_tabix like sy-tabix.

  if p_object = c_graphics.
    assign g_selected_node+3(*) to <l_tabix>.
    if g_stxh-tdobject <> c_graphics
    or g_stxh-tdid <> c_graphics.
      g_stxh-tdobject = c_graphics.
      g_stxh-tdid     = <l_tabix>.
    endif.
  elseif p_object = c_stdtext.
    assign g_selected_node+3(*) to <l_tabix>.
    l_tabix = <l_tabix>.
    check l_tabix > 0.                   "***************************
    read table g_ttxid index l_tabix.
    check sy-subrc = 0.                  "***************************
    if g_ttxid-tdobject <> g_stxh-tdobject
    or g_ttxid-tdid     <> g_stxh-tdid.
      g_stxh-tdobject = g_ttxid-tdobject.
      g_stxh-tdid     = g_ttxid-tdid.
    endif.
  endif.

endform.                    " FILL_STXH

*&---------------------------------------------------------------------*
*&      Form  FILL_TEXTINFO
*&---------------------------------------------------------------------*
form fill_textinfo.
data: l_header     like thead,
      l_lines      like tline occurs 0 with header line,
      l_dpi        type i,
      l_width      type i,
      l_height     type i.

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
            not_found               = 1
            others                  = 2.
  if sy-subrc = 0.
    perform set_sub_areanr using true false.
  else.
    if sy-subrc = 1.
      clear g_techinfo.
      move-corresponding g_stxh to l_header.
      clear g_stxh.
      g_stxh-tdobject = l_header-tdobject.
      g_stxh-tdid     = l_header-tdid.
      g_stxh-tdname   = l_header-tdname.
      g_stxh-tdspras  = l_header-tdspras.
      perform set_sub_areanr using false false.
      message s624 with g_stxh-tdname   g_stxh-tdspras
                        g_stxh-tdobject g_stxh-tdid.
      exit.
    else.
      clear g_techinfo.
      move-corresponding g_stxh to l_header.
      clear g_stxh.
      g_stxh-tdobject = l_header-tdobject.
      g_stxh-tdid     = l_header-tdid.
      g_stxh-tdname   = l_header-tdname.
      g_stxh-tdspras  = l_header-tdspras.
      perform set_sub_areanr using true false.
      exit.
    endif.
  endif.

  move-corresponding l_header to g_stxh.

  call function 'SAPSCRIPT_CALC_BITMAP_SIZE'
       exporting
            header          = l_header
       importing
            width_twip      = l_width
            height_twip     = l_height
            dots_per_inch   = l_dpi
       tables
            lines           = l_lines
       exceptions
            no_bitmap_file  = 1
            bad_bitmap_type = 1
            others          = 3.
  if sy-subrc <> 0.
    clear g_techinfo.
    if sy-subrc = 1.
      message s877.
    endif.
    exit.
  endif.

  g_techinfo-resolution = l_dpi.
  g_techinfo-imagewidth = l_width.
  g_techinfo-imagehght  = l_height.
  g_techinfo-imageunit  = 'TW'.

  call function 'SAPSCRIPT_CHANGE_BITMAP_ATT'
       exporting
            dots_per_inch     = g_techinfo-resolution
            auto_height       = g_techinfo-autoheight
            resident          = g_techinfo-resident
            read_only         = true
            header            = l_header
       importing
            cur_dots_per_inch = g_techinfo-resolution
            cur_auto_height   = g_techinfo-autoheight
            cur_resident      = g_techinfo-resident
       tables
            lines             = l_lines
      exceptions
            no_bitmap_file    = 1
            bad_bitmap_type   = 1
            others            = 3.
  if sy-subrc <> 0.
    clear: g_techinfo-autoheight,
           g_techinfo-resident.
    if sy-subrc = 1.
     message s877.
    endif.
  endif.

endform.                    " FILL_TEXTINFO

*&---------------------------------------------------------------------*
*&      Form  FILL_SIZEINFO
*&---------------------------------------------------------------------*
form fill_sizeinfo.
data: l_header     like thead,
      l_lines      like tline occurs 0 with header line,
      l_dpi        type i,
      l_width      type i,
      l_height     type i.

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
            not_found               = 1
            others                  = 2.
  if sy-subrc <> 0.
    clear g_techinfo.
    move-corresponding g_stxh to l_header.
    clear g_stxh.
    g_stxh-tdobject = l_header-tdobject.
    g_stxh-tdid     = l_header-tdid.
    g_stxh-tdname   = l_header-tdname.
    g_stxh-tdspras  = l_header-tdspras.
    if sy-subrc = 1.
      message e624 with g_stxh-tdname   g_stxh-tdspras
                        g_stxh-tdobject g_stxh-tdid.
    else.
      exit.
    endif.
  endif.

  call function 'SAPSCRIPT_CHANGE_BITMAP_ATT'
       exporting
            dots_per_inch     = g_techinfo-resolution
            auto_height       = g_techinfo-autoheight
            resident          = g_techinfo-resident
            read_only         = false
            header            = l_header
       tables
            lines             = l_lines
       exceptions
            no_bitmap_file    = 1
            bad_bitmap_type   = 1
            others            = 3.
  if sy-subrc <> 0.
    clear: g_techinfo-imagewidth,
           g_techinfo-imagehght,
           g_techinfo-imageunit.
    if sy-subrc = 1.
     message s877.
    endif.
    exit.
  endif.
  call function 'SAPSCRIPT_CALC_BITMAP_SIZE'
       exporting
            header          = l_header
       importing
            width_twip      = l_width
            height_twip     = l_height
            dots_per_inch   = l_dpi
       tables
            lines           = l_lines
       exceptions
            no_bitmap_file  = 1
            bad_bitmap_type = 1
            others          = 3.
  if sy-subrc = 0.
    g_techinfo-imagewidth = l_width.
    g_techinfo-imagehght  = l_height.
    g_techinfo-imageunit  = 'TW'.
  else.
    clear: g_techinfo-imagewidth,
           g_techinfo-imagehght,
           g_techinfo-imageunit.
    if sy-subrc = 1.
      message s877.
    endif.
  endif.

endform.                    " FILL_SIZEINFO
