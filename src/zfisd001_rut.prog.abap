*&---------------------------------------------------------------------*
*&  Include           ZFISD001_RUT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SUBIR_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM subir_archivo .
  DATA: strarq       TYPE string.
  IF NOT p_local IS INITIAL.
    strarq = fichero.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = strarq
        filetype                = 'ASC'
        has_field_separator     = 'X'
      TABLES
        data_tab                = ti_entrada
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17.

  ELSE.
    strarq = servidor.
    DATA: tab TYPE c,
          gato TYPE fist-searchw.
    DATA: cadena TYPE string.
    tab = cl_abap_char_utilities=>horizontal_tab.
    OPEN DATASET strarq FOR INPUT IN TEXT MODE ENCODING NON-UNICODE.
    IF sy-subrc EQ 0.
      DO.
        READ DATASET strarq INTO cadena.
        IF sy-subrc EQ 0.
          CLEAR ti_entrada.
          SPLIT cadena AT tab INTO ti_entrada-nrocore
                                   ti_entrada-nrocore
                                   ti_entrada-belnr.
          APPEND ti_entrada.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDIF.

*  SORT ti_entrada BY vbeln znum_doc_core.
ENDFORM.                    " SUBIR_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  PROCESAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM procesar .
*  SELECT *
*    INTO TABLE ti_vbrk
*    FROM vbrk
*    FOR ALL ENTRIES IN ti_entrada
*    WHERE vbeln EQ ti_vbeln.


  LOOP AT ti_entrada.
*
    IF p_test IS INITIAL.
*
     UPDATE vbrk SET znum_doc_core = ti_entrada-nrocore
                   WHERE vbeln = ti_entrada-vbeln.

      IF sy-subrc EQ 0.
        WRITE /: 'SE MODIFICO TABLA VBRK'.
        COMMIT WORK.
      ELSE.
        WRITE /: 'ERROR : NO SE MODIFICO TABLA VBRK'.
      ENDIF.

    ENDIF.
  ENDLOOP.

ENDFORM.                    " PROCESAR
*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mostrar_alv .
  PERFORM init_fieldcat.
  PERFORM layout.
  PERFORM eventos CHANGING gt_events[].
  PERFORM comment_build_01 USING gt_list_top_of_page.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
*      i_callback_pf_status_set = 'PF_STATUS'
*      i_callback_user_command = 'USER_COMMAND'
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat[]
      i_default               = 'X'
      i_save                  = 'A'
      it_events               = gt_events[]
    TABLES
      t_outtab                = ti_VBRK[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
ENDFORM.                    " MOSTRAR_ALV


*----------------------------------------------------------------------*
FORM layout .
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra             = 'X'.
ENDFORM.                    " LAYOUT
*&---------------------------------------------------------------------*
*&      Form  EVENTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventos  CHANGING pgt_events TYPE slis_t_event.
  CONSTANTS:
    gc_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE_01'.

  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = pgt_events.

  READ TABLE pgt_events WITH KEY name = slis_ev_top_of_page
             INTO ls_event.

  IF sy-subrc = 0.
    MOVE gc_formname_top_of_page TO ls_event-form.
    APPEND ls_event TO pgt_events.
  ENDIF.
ENDFORM.                    " EVENTOS
*&---------------------------------------------------------------------*
*&      Form  comment_build_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
FORM comment_build_01 USING lt_top_of_page TYPE slis_t_listheader.

  DATA: ls_line TYPE slis_listheader,
        fecha(10) TYPE c.

  REFRESH: lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key  = 'Título :'.
  ls_line-info = sy-title.
  APPEND ls_line TO lt_top_of_page.

  IF p_test IS INITIAL.
    CLEAR ls_line.
    ls_line-typ  = 'S'.
    ls_line-key  = 'Modo :'.
    ls_line-info = 'Real'.
    APPEND ls_line TO lt_top_of_page.
  ELSE.
    CLEAR ls_line.
    ls_line-typ  = 'S'.
    ls_line-key  = 'Modo :'.
    ls_line-info = 'Test'.
    APPEND ls_line TO lt_top_of_page.
  ENDIF.
ENDFORM.                    "comment_build_01
*&---------------------------------------------------------------------*
*&      Form  top_of_page_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page_01.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_list_top_of_page.
ENDFORM.                    "TOP_OF_PAGE_01
*&---------------------------------------------------------------------*
*&      Form  INIT_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_fieldcat .
  REFRESH gt_fieldcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_repid
      i_structure_name       = 'VBRK'
      i_inclname             = g_repid
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
ENDFORM.                    "init_fieldcat
