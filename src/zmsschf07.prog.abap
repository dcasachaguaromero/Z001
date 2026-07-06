*----------------------------------------------------------------------*
*   INCLUDE MSSCHF07                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&    PROCESS ON VALUE-REQUEST                                         *
*&---------------------------------------------------------------------*
form textname_get.
data: l_name     like stxh-tdname,
      l_language like stxh-tdspras,
      l_object   like stxh-tdobject,
      l_id       like stxh-tdid,
      l_return   type i.
data: begin of d_tab occurs 3.
        include structure dynpread.
data: end of d_tab.
data: l_repid like d020s-prog,
      l_dynnr like d020s-dnum.

  if g_modified_administration = true
  or g_modified_properties = true.
    message i293.
    exit.
  endif.

* Determine text id
 l_repid = sy-repid.
 l_dynnr = sy-dynnr.
 refresh d_tab.
 d_tab-fieldname = 'RSTXT-TDNAME'.
 append d_tab.
 d_tab-fieldname = 'RSTXT-TDSPRAS'.
 append d_tab.
 call function 'DYNP_VALUES_READ'
      exporting
           dyname                   = l_repid
           dynumb                   = l_dynnr
      tables
           dynpfields               = d_tab
      exceptions
           invalid_abapworkarea     = 1
           invalid_dynprofield      = 2
           invalid_dynproname       = 3
           invalid_dynpronummer     = 4
           invalid_request          = 5
           no_fielddescription      = 6
           invalid_parameter        = 7
           undefind_error           = 8
           double_conversion        = 9
           others                   = 10.
 if sy-subrc <> 0.
   exit.
 else.
   read table d_tab index 1.             " RSTXT-TDNAME
   l_name = d_tab-fieldvalue.

   read table d_tab index 2.             " RSTXT-TDSPRAS
   if d_tab-fieldvalue is initial.
      l_language = '*'.
   elseif d_tab-fieldvalue cs '*'.
      l_language = '*'.
   else.
      call function 'CONVERSION_EXIT_ISOLA_INPUT'
           exporting
                input            = d_tab-fieldvalue
           importing
                output           = l_language
           exceptions
                unknown_language = 1
                others           = 2.
      if sy-subrc <> 0.       "propose all languages
         l_language = '*'.
      endif.
   endif.
 endif.

 l_object = g_stxh-tdobject.
 l_id     = g_stxh-tdid.

* Retrieval
 if l_object = c_graphics.
   perform graphic_search_old using
                                 l_object
                                 l_id
                              changing
                                 l_name
                                 l_language
                                 l_return.
 else.
   perform text_search changing l_object
                                l_id
                                l_name
                                l_language
                                l_return.
 endif.
 if l_return = 0.
   rstxt-tdname  = l_name.
* Update dynpro value for text language
   refresh d_tab.
   d_tab-fieldname  = 'RSTXT-TDSPRAS'.
   write l_language to d_tab-fieldvalue.
   append d_tab.
   call function 'DYNP_VALUES_UPDATE'
        exporting
             dyname               = l_repid
             dynumb               = l_dynnr
        tables
             dynpfields           = d_tab
        exceptions
             invalid_abapworkarea = 1
             invalid_dynprofield  = 2
             invalid_dynproname   = 3
             invalid_dynpronummer = 4
             invalid_request      = 5
             no_fielddescription  = 6
             undefind_error       = 7
             others               = 8.
   clear g_stxh.
   g_stxh-tdobject = l_object.
   g_stxh-tdid     = l_id.
   g_stxh-tdname   = l_name.
   g_stxh-tdspras  = l_language.
   perform select_node_text using l_object
                                  l_id
                                  true.

 endif.

endform.

*&---------------------------------------------------------------------*
form graphicname_get.
data: l_name     like stxbitmaps-tdname,
      l_return   type i.
data: begin of d_tab occurs 3.
        include structure dynpread.
data: end of d_tab.
data: l_repid like d020s-prog,
      l_dynnr like d020s-dnum.

  if g_modified_administration = true
  or g_modified_properties = true.
    message i293.
    exit.
  endif.

* Determine text id
  l_repid = sy-repid.
  l_dynnr = sy-dynnr.
  refresh d_tab.
  d_tab-fieldname = 'RSTXT-TDNAME'.
  append d_tab.
  call function 'DYNP_VALUES_READ'
       exporting
            dyname                   = l_repid
            dynumb                   = l_dynnr
       tables
            dynpfields               = d_tab
       exceptions
            invalid_abapworkarea     = 1
            invalid_dynprofield      = 2
            invalid_dynproname       = 3
            invalid_dynpronummer     = 4
            invalid_request          = 5
            no_fielddescription      = 6
            invalid_parameter        = 7
            undefind_error           = 8
            double_conversion        = 9
            others                   = 10.
  if sy-subrc <> 0.
    exit.
  else.
    read table d_tab index 1.             " RSTXT-TDNAME
    l_name = d_tab-fieldvalue.
  endif.

  perform graphic_search_bds using    l_name
                             changing g_stxbitmaps-tdobject
                                      g_stxbitmaps-tdid
                                      g_stxbitmaps-tdname
                                      g_stxbitmaps-tdbtype
                                      l_return.
  if l_return = 0.
* Update dynpro values
    rstxt-tdname  = g_stxbitmaps-tdname.
    refresh d_tab.
    if g_stxbitmaps-tdbtype = c_bmon.
      d_tab-fieldname = 'RSSCG-BTYPE_BMON'.
      d_tab-fieldvalue = 'X'.
      append d_tab.
      d_tab-fieldname = 'RSSCG-BTYPE_BCOL'.
      clear d_tab-fieldvalue.
      append d_tab.
      d_tab-fieldname = 'RSSCG-BTYPE_STD'.
      clear d_tab-fieldvalue.
      append d_tab.
    elseif g_stxbitmaps-tdbtype = c_bcol.
      d_tab-fieldname = 'RSSCG-BTYPE_BCOL'.
      d_tab-fieldvalue = 'X'.
      append d_tab.
      d_tab-fieldname = 'RSSCG-BTYPE_BMON'.
      clear d_tab-fieldvalue.
      append d_tab.
      d_tab-fieldname = 'RSSCG-BTYPE_STD'.
      clear d_tab-fieldvalue.
      append d_tab.
    else.
      d_tab-fieldname = 'RSSCG-BTYPE_STD'.
      d_tab-fieldvalue = 'X'.
      append d_tab.
      d_tab-fieldname = 'RSSCG-BTYPE'.
      d_tab-fieldvalue = g_stxbitmaps-tdbtype.
      append d_tab.
      d_tab-fieldname = 'RSSCG-BTYPE_BMON'.
      clear d_tab-fieldvalue.
      append d_tab.
      d_tab-fieldname = 'RSSCG-BTYPE_BCOL'.
      clear d_tab-fieldvalue.
      append d_tab.
    endif.
    call function 'DYNP_VALUES_UPDATE'
          exporting
               dyname               = l_repid
               dynumb               = l_dynnr
          tables
               dynpfields           = d_tab
          exceptions
               invalid_abapworkarea = 1
               invalid_dynprofield  = 2
               invalid_dynproname   = 3
               invalid_dynpronummer = 4
               invalid_request      = 5
               no_fielddescription  = 6
               undefind_error       = 7
               others               = 8.
    perform select_node_bds using g_stxbitmaps-tdobject
                                  g_stxbitmaps-tdid
                                  true.
  endif.


endform.

*&---------------------------------------------------------------------*
*&  Normal search                                                      *
*&---------------------------------------------------------------------*
form graphic_find.
data l_return type i.

  case g_prefix.
  when prefix_bds_object
  or   prefix_bds_id.
       perform graphic_search_bds using    g_stxbitmaps-tdname
                                  changing g_stxbitmaps-tdobject
                                           g_stxbitmaps-tdid
                                           g_stxbitmaps-tdname
                                           g_stxbitmaps-tdbtype
                                           l_return.
       if l_return = 0.
         g_change_screen = true.
         perform select_node_bds  using g_stxbitmaps-tdobject
                                        g_stxbitmaps-tdid
                                        false.
       endif.
  when prefix_tx_graphics.
       perform graphic_search_old using    g_stxh-tdobject
                                           g_stxh-tdid
                                  changing g_stxh-tdname
                                           g_stxh-tdspras
                                           l_return.
       if l_return = 0.
         g_change_screen = true.
       endif.
  when prefix_standard_texts.
       perform text_search changing g_stxh-tdobject
                                    g_stxh-tdid
                                    g_stxh-tdname
                                    g_stxh-tdspras
                                    l_return.
       if l_return = 0.
         g_change_screen = true.
         perform select_node_text using g_stxh-tdobject
                                        g_stxh-tdid
                                        false.
       endif.
  endcase.

endform.

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
form text_search changing p_object   like stxh-tdobject
                          p_id       like stxh-tdid
                          p_name     like stxh-tdname
                          p_language like stxh-tdspras
                          p_return   type i.
data: l_type(10).

  l_type = 'TEXT'.
  call function 'SAPSCRIPT_SEARCH_GRAPHIC'
       changing
            objecttype         = l_type
            textobject         = p_object
            textname           = p_name
            textid             = p_id
            textspras          = p_language
       exceptions
            canceled           = 1
            others             = 2.
  p_return = sy-subrc.

endform.

*&---------------------------------------------------------------------*
form graphic_search_bds using    p_sname    like stxbitmaps-tdname
                        changing p_object   like stxbitmaps-tdobject
                                 p_id       like stxbitmaps-tdid
                                 p_name     like stxbitmaps-tdname
                                 p_btype    like stxbitmaps-tdbtype
                                 p_return   type i.

  clear:   s_object, s_id, s_name, r_btype.
  refresh: s_object, s_id, s_name, r_btype.

  if p_sname = '*' or p_name is initial.
* empty select option
  elseif p_sname cs '*'.
     s_name-sign   = 'I'.
     s_name-option = 'CP'.
     s_name-low    = p_sname.
     s_name-high   = space.
     append s_name.
  else.
     s_name-sign   = 'I'.
     s_name-option = 'EQ'.
     s_name-low    = p_sname.
     s_name-high   = space.
     append s_name.
  endif.

  s_object-sign   = 'I'.
  s_object-option = 'EQ'.
  s_object-low    = p_object.
  clear s_object-high.
  append s_object.

  s_id-sign   = 'I'.
  s_id-option = 'EQ'.
  s_id-low    = p_id.
  clear s_id-high.
  append s_id.

  if p_btype = c_bmon.
    cb_bmon = true.
    cb_bcol = false.
  else.
    cb_bmon = false.
    cb_bcol = true.
  endif.

  call selection-screen 0100 starting at 1 1.
  check sy-subrc = 0.            " sy-subrc <> 0 => selection canceled
  clear r_btype.
  refresh r_btype.
  r_btype-sign   = 'I'.
  r_btype-option = 'EQ'.
  r_btype-high   = space.
  if cb_bmon = true.
    r_btype-low = c_bmon.
    append r_btype.
  endif.
  if cb_bcol = true.
    r_btype-low = c_bcol.
    append r_btype.
  endif.

* Retrieval
  call function 'SAPSCRIPT_SEARCH_GRAPHIC_BDS'
       exporting
            selection_screen   = false
            select_entry       = true
            selection_show     = true
       importing
            e_object           = p_object
            e_id               = p_id
            e_name             = p_name
            e_btype            = p_btype
       tables
            t_objects          = s_object
            t_ids              = s_id
            t_names            = s_name
            t_btypes           = r_btype
*           T_SELECTIONS       =
       exceptions
            nothing_found      = 1
            selection_canceled = 2
            internal_error     = 3
            others             = 4.
  p_return = sy-subrc.
  if p_return <> 0 and p_return <> 2.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.

*&---------------------------------------------------------------------*
form graphic_search_old using    gs_object   like stxh-tdobject
                             gs_id       like stxh-tdid
                    changing gs_name     like stxh-tdname
                             gs_language like stxh-tdspras
                             gs_return   type i.
data: l_name     like stxh-tdname,
      l_language like stxh-tdspras.

 gs_return = 4.
* Determine text id
 if gs_name is initial.
   l_name = '*'.
 else.
   l_name = gs_name.
 endif.

 if gs_language is initial.
   l_language = '*'.
 elseif gs_language cs '*'.
   l_language = '*'.
 else.
   l_language = gs_language.
 endif.

* Retrieval
 call function 'SEARCH_TEXT'
      exporting
           i_object         = gs_object
           i_name           = l_name
           i_id             = gs_id
           i_language       = l_language
           selection_screen = 'X'
      importing
           e_name           = l_name
           e_language       = l_language
      exceptions
           canceled         = 1
           retrieval_error  = 2
           invalid_object   = 3
           invalid_id       = 4
           invalid_language = 5
           invalid_savemode = 6
           others           = 7.
 if sy-subrc = 0.
   gs_name     = l_name.
   gs_language = l_language.
   gs_return = 0.
*elseif sy-subrc = 1.
*   message e178.
 elseif sy-subrc = 2.
    message s615.
 endif.

endform.
