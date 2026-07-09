*----------------------------------------------------------------------*
*   INCLUDE MSSCHF06                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
form save_on_request using    p_prefix like g_prefix
                     changing p_change_screen type c.
data: l_answer(1).

  p_change_screen = true.
  if g_modified_administration = true
  or g_modified_properties = true.
    call function 'POPUP_TO_CONFIRM'
         exporting
              titlebar              = text-t20
              text_question         = text-q20
              text_button_1         = 'Ja'(001)
              text_button_2         = 'Nein'(002)
              default_button        = '1'
              display_cancel_button = true
*             USERDEFINED_F1_HELP   = ' '
*             START_COLUMN          = 25
*             START_ROW             = 6
*             POPUP_TYPE            =
         importing
              answer                = l_answer
         exceptions
              others                = 1.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    if l_answer = '1'.
      perform graphic_change_properties using p_prefix.
      perform dequeue using p_prefix.
      g_modified_administration = false.
      g_modified_properties = false.
    elseif l_answer = 'A'.
      if g_last_node is initial.  " First selection after adm. call
        g_last_node  = g_selected_node.
        g_prefix_old = g_prefix.
      endif.
      if not g_prefix_old is initial.
        g_prefix = g_prefix_old.
      endif.
      perform select_node using g_last_node.
      p_change_screen = false.
    else.
      perform dequeue using p_prefix.
      g_modified_administration = false.
      g_modified_properties = false.
      message i290.
    endif.
  else.
    perform dequeue using p_prefix.
  endif.

endform.

*&---------------------------------------------------------------------*
form save_stxh_titles.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single * from stxh where tdobject = g_stxh-tdobject
*                            and   tdname   = g_stxh-tdname
*                            and   tdid     = g_stxh-tdid
*                            and   tdspras  = g_stxh-tdspras.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  from stxh where tdobject = g_stxh-tdobject
                            and   tdname   = g_stxh-tdname
                            and   tdid     = g_stxh-tdid
                            and   tdspras  = g_stxh-tdspras ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  if sy-subrc = 0.
    g_stxh-tdluser   = sy-uname.
    g_stxh-tdldate   = sy-datum.
    g_stxh-tdltime   = sy-uzeit.
    g_stxh-tdlreles  = sy-saprl.
    move-corresponding g_stxh to stxh.
    update stxh.
    if sy-subrc = 0.
      g_modified_administration = false.
      message s674.
    else.
      message e607 with g_stxh-tdobject g_stxh-tdname
                        g_stxh-tdid     g_stxh-tdspras.
    endif.
  else.
    message e624 with g_stxh-tdname   g_stxh-tdspras
                      g_stxh-tdobject g_stxh-tdid.
  endif.

endform.

*&---------------------------------------------------------------------*
form save_stxh_techinfo.
data: l_header     like thead,
      l_lines      like tline occurs 0 with header line.

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
  if sy-subrc = 4.
    message e624 with g_stxh-tdname   g_stxh-tdspras
                      g_stxh-tdobject g_stxh-tdid.
  elseif sy-subrc <> 0.
     message e001 with 'SAVE_STXH_TECHINFO' sy-repid.
  endif.

  call function 'SAPSCRIPT_CHANGE_BITMAP_ATT'
       exporting
            dots_per_inch     = g_techinfo-resolution
            auto_height       = g_techinfo-autoheight
            resident          = g_techinfo-resident
            read_only         = false
            header            = l_header
       importing
            cur_dots_per_inch = g_techinfo-resolution
            cur_auto_height   = g_techinfo-autoheight
            cur_resident      = g_techinfo-resident
       tables
            lines             = l_lines
      exceptions
            others            = 1.
  if sy-subrc = 0.
    call function 'SAVE_TEXT'
         exporting
              header          = l_header
         tables
              lines           = l_lines
         exceptions
              id              = 1
              language        = 1
              name            = 1
              object          = 1
              others          = 2.
      if sy-subrc = 0.
        g_modified_properties = false.
        message s674.
      elseif sy-subrc = 1.
        message e001 with 'SAVE_STXH_TECHINFO' sy-repid.
      else.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
  else.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.

*&---------------------------------------------------------------------*
form save_bds_attributes.

  call function 'SAPSCRIPT_ATTRIB_GRAPHIC_BDS'
       exporting
            i_object        = g_stxbitmaps-tdobject
            i_name          = g_stxbitmaps-tdname
            i_id            = g_stxbitmaps-tdid
            i_btype         = g_stxbitmaps-tdbtype
            read_only       = false
            i_description   = g_bds_properties-description
            i_resident      = g_stxbitmaps-resident
            i_autoheight    = g_stxbitmaps-autoheight
       exceptions
            enqueue_failed  = 1
            bds_info_failed = 2
            update_failed   = 3
            not_found       = 4
            others          = 5.
  if sy-subrc = 0.
    g_modified_administration = false.
    g_modified_properties     = false.
    message s674.
  else.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.
