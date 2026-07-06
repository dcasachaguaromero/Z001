*----------------------------------------------------------------------*
***INCLUDE ZFIMRP001_INC .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REPORTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reporte .
*LEAVE TO LIST-PROCESSING. "AND RETURN TO SCREEN 0.
* LEAVE TO LIST-PROCESSING. NEW-PAGE NO-HEADING NO-TITLE.



  REFRESH: gt_fieldcat.
  CLEAR: gt_events, gt_list_top_of_page, ls_toolbar.
  PERFORM build.
*  PERFORM BUILD2.
  PERFORM eventtab_build CHANGING gt_events.
  PERFORM layout_init USING gs_layout.
  PERFORM comment_build  CHANGING gt_list_top_of_page.
  PERFORM call_alv.
ENDFORM.                    " REPORTE


*&---------------------------------------------------------------------*
*&      Form  BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build.
* DATA FIELD CATALOG
* Explain Field Description to ALV
  DATA: fieldcat_in TYPE slis_fieldcat_alv.

  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname = 'BUKRS'.
  fieldcat_ln-key       = ' '.   "SUBTOTAL KEY
  fieldcat_ln-checkbox   = ' '.
  fieldcat_ln-edit    = ' '.
  fieldcat_ln-seltext_l = 'Sociedad FI'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-fix_column = 'X'.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname  = 'ESTADO'.
  fieldcat_ln-seltext_l = 'Estado Origen'.
  fieldcat_ln-icon      = ' '.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-sp_group = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname = 'BELNR'.
  fieldcat_ln-key       = ' '.   "SUBTOTAL KEY
  fieldcat_ln-checkbox   = ' '.
  fieldcat_ln-edit    = ' '.
  fieldcat_ln-seltext_l = 'Numero de Doc.'.
* FCV - 21.04.2010
*  FIELDCAT_LN-HOTSPOT = ' '.
  fieldcat_ln-hotspot = 'X'.
* fin FCV - 21.04.2010
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname  = 'ESTADOC'.
  fieldcat_ln-seltext_l = 'Estado Cambio'.
  fieldcat_ln-icon      = ' '.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-sp_group = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname = 'BELNRACT'.
  fieldcat_ln-key       = ' '.   "SUBTOTAL KEY
  fieldcat_ln-checkbox   = ' '.
  fieldcat_ln-edit    = ' '.
  fieldcat_ln-seltext_l = 'Numero de Cambio.'.
  fieldcat_ln-hotspot = 'X'.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname  = 'ESTREVER'.
  fieldcat_ln-seltext_l = 'Reversado'.
  fieldcat_ln-icon      = ' '.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-sp_group = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.




  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname = 'ZDOCREV'.
  fieldcat_ln-key       = ' '.
  fieldcat_ln-checkbox   = ' '.
  fieldcat_ln-edit    = ' '.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-seltext_l = 'Doc. Reversa'.
  APPEND fieldcat_ln TO gt_fieldcat.

*CLEAR: FIELDCAT_IN.
*  FIELDCAT_LN-FIELDNAME = 'ZALDT'.
*  FIELDCAT_LN-KEY       = ' '.   "SUBTOTAL KEY
*  FIELDCAT_LN-CHECKBOX   = ' '.
*  FIELDCAT_LN-EDIT    = ' '.
*  FIELDCAT_LN-HOTSPOT = ' '.
*  FIELDCAT_LN-SELTEXT_L = 'Fecha Doc. Orig'.
*  FIELDCAT_LN-JUST = ' '.
*  APPEND FIELDCAT_LN TO GT_FIELDCAT.


  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname = 'BUDAT'.
  fieldcat_ln-seltext_l = 'Fecha Contab.'.
  fieldcat_ln-hotspot = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.




*CLEAR: FIELDCAT_IN.
*  FIELDCAT_LN-FIELDNAME = 'BUZEI'.
*  FIELDCAT_LN-SELTEXT_L = 'Posición'.
*  FIELDCAT_LN-HOTSPOT = ' '.
*  APPEND FIELDCAT_LN TO GT_FIELDCAT.

*CLEAR: FIELDCAT_IN.
*  FIELDCAT_LN-FIELDNAME = 'CHECT'.
*  FIELDCAT_LN-SELTEXT_L = 'Numero de Cheque'.
*  FIELDCAT_LN-HOTSPOT = ' '.
*  FIELDCAT_LN-DO_SUM  = ' '.
*  FIELDCAT_LN-JUST = 'R'.
*  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname = 'WRBTR'.
  fieldcat_ln-currency  = 'CLP'.
  fieldcat_ln-seltext_l = 'Monto Cheque'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-do_sum  = ' '.
  fieldcat_ln-just = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

*CLEAR: FIELDCAT_IN.
*  FIELDCAT_LN-CURRENCY  = '   '.
*  FIELDCAT_LN-FIELDNAME = 'ZMOTE'.
*  FIELDCAT_LN-SELTEXT_L = 'Motivo Emisión'.
*  FIELDCAT_LN-HOTSPOT = ' '.
*  FIELDCAT_LN-DO_SUM  = ' '.
*  APPEND FIELDCAT_LN TO GT_FIELDCAT.
*
  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname = 'FECPROCESO'.
  fieldcat_ln-currency  = '  '.
  fieldcat_ln-seltext_l = 'Fec. Cambio Estado'.
  fieldcat_ln-hotspot = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname  = 'HORAPROCESO'.
  fieldcat_ln-seltext_l = 'H. Cambio Estado'.
  fieldcat_ln-icon      = ' '.
  fieldcat_ln-hotspot = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname  = 'CODUSUARIO'.
  fieldcat_ln-seltext_l = 'Usuario'.
  fieldcat_ln-icon      = 'X'.
  fieldcat_ln-hotspot = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.




* DATA SORTING AND SUBTOTAL
  DATA: gs_sort TYPE slis_sortinfo_alv.
ENDFORM.                    "BUILD
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*

FORM layout_init USING rs_layout TYPE slis_layout_alv.
  rs_layout-group_change_edit = 'X'.
  rs_layout-detail_popup      = 'X'.
  rs_layout-info_fieldname    = 'X'.
  rs_layout-colwidth_optimize = 'X'.
  rs_layout-zebra             = 'X'.
ENDFORM.                    "LAYOUT_INIT

*&---------------------------------------------------------------------*
*&      Form  CALL_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_alv.
  g_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
*      I_CALLBACK_PF_STATUS_SET = 'ZFULLSCREEN'
      i_callback_user_command  = 'USER_COMMAND_DET'
      i_background_id          = 'LOGOISAPBAN002'
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat[]
      it_events                = gt_events
    TABLES
      t_outtab                 = t_ok
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.

  ENDIF.
ENDFORM.                    "CALL_ALV

* HEADER FORM
FORM eventtab_build CHANGING lt_events TYPE slis_t_event.
  CONSTANTS:
  gc_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE'.
  DATA: ls_event TYPE slis_alv_event.

  ls_event-name = slis_ev_user_command.
  ls_event-form = 'USER_COMMAND_DET'.
  APPEND ls_event TO gt_events.

  ls_event-name = slis_ev_pf_status_set.
  ls_event-form = 'ZFULLSCREEN'.
  APPEND ls_event TO gt_events.


  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = lt_events.
  READ TABLE lt_events WITH KEY name =  slis_ev_top_of_page   INTO ls_event.
  IF sy-subrc = 0.
    MOVE gc_formname_top_of_page TO ls_event-form.
    APPEND ls_event TO lt_events.
  ENDIF.
ENDFORM.                    "EVENTTAB_BUILD


*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->GT_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
FORM comment_build CHANGING gt_top_of_page TYPE slis_t_listheader.
  DATA: gs_line TYPE slis_listheader.
  CLEAR gs_line.
  DATA stext(30) TYPE c.

  gs_line-typ  = 'H'.

  CONCATENATE   'Estado Cheque' ' : 'schect-low INTO stext.

  gs_line-info = stext.

  APPEND gs_line TO gt_top_of_page.

  CLEAR gs_line.
  gs_line-typ  = 'S'.
  gs_line-key  = 'Sociedad'.
  gs_line-info = sbukrs-low.
  APPEND gs_line TO gt_top_of_page.

  gs_line-key  = 'Banco'.
  gs_line-info = shbkid-low.
  APPEND gs_line TO gt_top_of_page.

  gs_line-key  = 'ID Cuenta'.
  gs_line-info = shktid-low.
  APPEND gs_line TO gt_top_of_page.

  gs_line-key  = 'Usuario'.
  gs_line-info = sy-uname.
  APPEND gs_line TO gt_top_of_page.


ENDFORM.                    "COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_list_top_of_page.
  WRITE: sy-datum, 'Page No', sy-pagno LEFT-JUSTIFIED.
ENDFORM.                    "TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  END_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM end_of_page.
  WRITE AT (sy-linsz) sy-pagno CENTERED.
ENDFORM.                    "END_OF_PAGE

* FCV - 21.04.2010
* Se controlan los eventos de la grila
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_DET
*&---------------------------------------------------------------------*
FORM user_command_det USING f_ucomm LIKE sy-ucomm
    i_selfield TYPE slis_selfield.
  DATA: an1 TYPE payr-vblnr.

  CASE f_ucomm.
    WHEN '&IC1'. "Doble Click
      CASE i_selfield-fieldname.
        WHEN 'BELNR' OR 'BELNRACT'.
          DATA: len TYPE p.
          DESCRIBE FIELD i_selfield-value.

          an1 = i_selfield-value.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = an1
            IMPORTING
              output = an1.

          READ TABLE  t_ok INDEX i_selfield-tabindex.

          IF sy-subrc EQ 0.
            SET PARAMETER ID 'BLN' FIELD an1.
            SET PARAMETER ID 'BUK' FIELD t_ok-bukrs.
            SET PARAMETER ID 'GJR' FIELD t_ok-gjahr.
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          ENDIF.

      ENDCASE.
  ENDCASE.
ENDFORM.                    "USER_COMMAND_DET
* fin FCV - 21.04.2010
