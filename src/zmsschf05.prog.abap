*----------------------------------------------------------------------*
***INCLUDE MSSCHF05 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ENQUEUE
*&---------------------------------------------------------------------*
form enqueue changing p_continue.
data: l_return type i.

  case g_prefix.
  when prefix_bds_object
  or   prefix_bds_id.
       perform enqueue_graphic using    g_stxbitmaps-tdobject
                                        g_stxbitmaps-tdname
                                        g_stxbitmaps-tdid
                                        g_stxbitmaps-tdbtype
                               changing l_return.
       if l_return = 0.
         p_continue = true.
       else.
         p_continue = true.
       endif.
  when prefix_tx_graphics
  or   prefix_standard_texts.
       perform enqueue_text using    g_stxh-tdobject
                                     g_stxh-tdname
                                     g_stxh-tdid
                                     g_stxh-tdspras
                            changing l_return.
       if l_return = 0.
         p_continue = true.
       else.
         p_continue = true.
       endif.
  when others.
       p_continue = false.
  endcase.

endform.                      " ENQUEUE

*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_TEXT
*&---------------------------------------------------------------------*
form enqueue_text using    p_object  like stxh-tdobject
                           p_name    like stxh-tdname
                           p_id      like stxh-tdid
                           p_spras   like stxh-tdspras
                  changing p_return type i.

  call function 'ENQUEUE_ESSSTXT'
       exporting
            tdobject       = p_object
            tdname         = p_name
            tdid           = p_id
            tdspras        = p_spras
       exceptions
            others         = 1.
  p_return = sy-subrc.
  if p_return <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " ENQUEUE_TEXT

*&---------------------------------------------------------------------*
*&      Form  ENQUEUE_GRAPHIC
*&---------------------------------------------------------------------*
form enqueue_graphic using    p_object  like stxbitmaps-tdobject
                              p_name    like stxbitmaps-tdname
                              p_id      like stxbitmaps-tdid
                              p_btype   like stxbitmaps-tdbtype
                     changing p_return  type i.

  call function 'ENQUEUE_ESSGRABDS'
       exporting
            tdobject        = p_object
            tdname          = p_name
            tdid            = p_id
            tdbtype         = p_btype
       exceptions
            others          = 1.
  p_return = sy-subrc.
  if p_return <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " ENQUEUE_GRAPHIC

*&---------------------------------------------------------------------*
*&      Form  DEQUEUE
*&---------------------------------------------------------------------*
form dequeue using p_prefix like g_prefix.

  case p_prefix.
  when prefix_bds_object
  or   prefix_bds_id.
       perform dequeue_graphic using    g_stxbitmaps-tdobject
                                        g_stxbitmaps-tdname
                                        g_stxbitmaps-tdid
                                        g_stxbitmaps-tdbtype.
  when prefix_tx_graphics
  or   prefix_standard_texts.
       perform dequeue_text using    g_stxh-tdobject
                                     g_stxh-tdname
                                     g_stxh-tdid
                                     g_stxh-tdspras.
  endcase.

endform.                      " DEQUEUE

*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_TEXT
*&---------------------------------------------------------------------*
form dequeue_text using    p_object  like stxh-tdobject
                           p_name    like stxh-tdname
                           p_id      like stxh-tdid
                           p_spras   like stxh-tdspras.

  call function 'DEQUEUE_ESSSTXT'
       exporting
            tdobject       = p_object
            tdname         = p_name
            tdid           = p_id
            tdspras        = p_spras.

endform.                    " DEQUEUE_TEXT



*&---------------------------------------------------------------------*
*&      Form  DEQUEUE_GRAPHIC
*&---------------------------------------------------------------------*
form dequeue_graphic using p_object like stxbitmaps-tdobject
                           p_name   like stxbitmaps-tdname
                           p_id     like stxbitmaps-tdid
                           p_btype  like stxbitmaps-tdbtype.

  call function 'DEQUEUE_ESSGRABDS'
       exporting
            tdobject        = p_object
            tdname          = p_name
            tdid            = p_id
            tdbtype         = p_btype.

endform.                    " DEQUEUE_GRAPHIC

*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHORITY
*&---------------------------------------------------------------------*
form check_authority changing p_continue.
data: l_return type i.

  case g_prefix.
  when prefix_bds_object
  or   prefix_bds_id.
* No authority check for BDS graphics in graphics administration
       p_continue = true.
  when prefix_tx_graphics.
       perform check_authority_graphics using    g_stxh-tdname
                                                 g_stxh-tdspras
                                                 g_stxh-tdid
                                                 'EDIT'
                                        changing l_return.
       if l_return = 0.
         p_continue = true.
       else.
         p_continue = false.
       endif.
  when prefix_standard_texts.
       perform check_authority_text using    g_stxh-tdname
                                             g_stxh-tdspras
                                             g_stxh-tdid
                                             'EDIT'
                                    changing l_return.
       if l_return = 0.
         p_continue = true.
       else.
         p_continue = false.
       endif.
  when others.
       p_continue = false.
  endcase.

endform.                    " CHECK_AUTHORITY

*&---------------------------------------------------------------------*
form check_authority_graphics
          using    ca_name      like stxh-tdname
                   ca_language  like stxh-tdspras
                   ca_id        like stxh-tdid
                   ca_activity  type c
          changing ca_return    type i.
field-symbols <ca>.
data: ca_langu(4),
      ca_question(400),
      ca_text(100),
      ca_len     type i.

 call function 'CHECK_TEXT_AUTHORITY'
      exporting
           activity     = ca_activity
           id           = ca_id
           language     = ca_language
           name         = ca_name
           object       = c_graphics
      exceptions
           no_authority = 1
           others       = 2.
 if sy-subrc <> 0.
   ca_return = 4.
   ca_question = text-m03.
   ca_len = strlen( ca_name ).
   assign ca_name(ca_len) to <ca>.
   replace '&1' with <ca> into ca_question.
   write ca_language to ca_langu.
   ca_len = strlen( ca_langu ).
   assign ca_langu(ca_len) to <ca>.
   replace '&2' with <ca> into ca_question.
   if ca_id = c_bmon.
      ca_text = text-q05.
   elseif ca_id = c_bcol.
      ca_text = text-q06.
   endif.
   ca_len = strlen( ca_text ).
   assign ca_text(ca_len) to <ca>.
   replace '&3' with <ca> into ca_question.
   message s252 with ca_question.
 else.
   ca_return = 0.
 endif.

endform.

*&---------------------------------------------------------------------*
form check_authority_text
          using    ca_name      like stxh-tdname
                   ca_language  like stxh-tdspras
                   ca_id        like stxh-tdid
                   ca_activity  type c
          changing ca_return    type i.

 call function 'CHECK_TEXT_AUTHORITY'
      exporting
           activity     = ca_activity
           id           = ca_id
           language     = ca_language
           name         = ca_name
           object       = c_graphics
      exceptions
           others       = 1.
 if sy-subrc <> 0.
   ca_return = 4.
 else.
   ca_return = 0.
 endif.

endform.
