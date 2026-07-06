*&---------------------------------------------------------------------*
*&  Include           ZINTHELPF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.

  CLEAR ls_bdc.
  ls_bdc-program  = program.
  ls_bdc-dynpro   = dynpro.
  ls_bdc-dynbegin = 'X'.
  APPEND ls_bdc TO bdcdata.

ENDFORM.                    "BDC_DYNPRO


*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.

  CLEAR ls_bdc.
  ls_bdc-fnam = fnam.
  ls_bdc-fval = fval.
  APPEND ls_bdc TO bdcdata.

ENDFORM.                    "BDC_FIELD


*&---------------------------------------------------------------------*
*&      Form  ACTUALIZAR_TEXTOS
*&---------------------------------------------------------------------*
FORM actualizar_textos USING nrocliente iv_texto1 iv_texto2.

*  DATA LS_LOG LIKE LINE OF T_LOG.
  DATA gs_thead TYPE thead  .
  DATA t_lines TYPE STANDARD TABLE OF tline.
  DATA gs_lines LIKE LINE OF t_lines.

  CLEAR gs_thead.
  CLEAR gs_lines.
  REFRESH t_lines.

  gs_thead-tdobject = 'KNA1'.
  gs_thead-tdname   = nrocliente.
  gs_thead-tdid     =  'Z001'.
  gs_thead-tdspras  = sy-langu.
*
  gs_lines-tdformat = '*'.
  gs_lines-tdline   = iv_texto1.
  APPEND gs_lines TO t_lines.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = gs_thead
      savemode_direct = 'X'
    TABLES
      lines           = t_lines
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
*    PERFORM ADD_SY_MESS_TO_LOG.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
*    LS_LOG-MSGTYP = 'I'.
*    LS_LOG-MSGID = '00'.
*    LS_LOG-MSGNR = '398'.
*    LS_LOG-MSGV1 = G_REGINDEX .
*    LS_LOG-MSGV2 = 'Texto1 Cliente'.
*    LS_LOG-MSGV3 = WA_DATA-NROCLIENTE.
*    LS_LOG-MSGV4 = 'actualizado con exito'.
*    APPEND LS_LOG TO T_LOG.
  ENDIF.
*---------------------------------
  CLEAR gs_lines.
  REFRESH t_lines.
  gs_lines-tdformat = '*'.
  gs_lines-tdline = iv_texto2.
  APPEND gs_lines TO t_lines.
  gs_thead-tdid  =  'Z002'.
  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = gs_thead
      savemode_direct = 'X'
    TABLES
      lines           = t_lines
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
*    PERFORM ADD_SY_MESS_TO_LOG.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
*    LS_LOG-MSGTYP = 'I'.
*    LS_LOG-MSGID = '00'.
*    LS_LOG-MSGNR = '398'.
*    LS_LOG-MSGV1 = G_REGINDEX .
*    LS_LOG-MSGV2 = 'Texto2 Cliente'.
*    LS_LOG-MSGV3 = WA_DATA-NROCLIENTE.
*    LS_LOG-MSGV4 = 'actualizado con exito'.
*    APPEND LS_LOG TO T_LOG.
  ENDIF.

ENDFORM.                    " ACTUALIZAR_TEXTOS


*&---------------------------------------------------------------------*
*&      Form  MAKE_MESSAGE
*&---------------------------------------------------------------------*
FORM make_message  USING    mess_msg
                   CHANGING cv_message.

  DATA str_tmp TYPE string.

  CLEAR str_tmp.
  str_tmp = mess_msg.
  CONDENSE str_tmp NO-GAPS.
  REPLACE '&' INTO cv_message WITH str_tmp.

ENDFORM.                    " MAKE_MESSAGE
