*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFILB004_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  show_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_alv.
  DATA: l_msj TYPE string,
        l_num TYPE char13.


  WRITE g_num TO l_num .
  CONCATENATE 'Total de registros:' l_num
 INTO l_msj SEPARATED BY space.
  MESSAGE l_msj TYPE 'S'.
  gs_layout-window_titlebar = 'Libro Diario'.               "#EC NOTEXT

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active             = 'X'
      i_callback_program          = g_repid
*     i_structure_name            = 'ALV_T_T2'
      i_callback_user_command     = 'USER_COMMAND'
*     i_callback_top_of_page      = l_callback_top_of_page
      i_callback_html_top_of_page = l_callback_html_top_of_page
*     i_callback_html_end_of_list = l_callback_html_end_of_list
      i_callback_pf_status_set    = 'SET_STATUS'
      is_layout                   = gs_layout
      it_special_groups           = gt_slis_sp_group_alv[]
      it_sort                     = gt_sort[]
      it_excluding                = lt_extab
      it_events                   = gt_events[]
      it_fieldcat                 = gt_fieldcat[]
      is_variant                  = gs_variant
      i_html_height_top           = g_html_height_top
      i_html_height_end           = 10
    TABLES
      t_outtab                    = gt_outtab.


  IF sy-subrc = 0.                                          "#EC *

  ENDIF.
ENDFORM.                    "show_alv
*&---------------------------------------------------------------------*
*&      Form  eventtab_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EVENTS  text
*----------------------------------------------------------------------*
FORM eventtab_build USING rt_events TYPE slis_t_event.
  DATA: ls_event TYPE slis_alv_event.
*
  ls_event-name = 'TOP_OF_PAGE'.
  ls_event-form = 'HTML_EVENT_TOP_OF_PAGE'.
  APPEND ls_event TO rt_events.

*  ls_event-name = 'END_OF_LIST'.
*  ls_event-form = 'HTML_EVENT_END_OF_LIST'.
*  APPEND ls_event TO rt_events.

  ls_event-name = 'USER_COMNAND'.
  ls_event-form = 'USER_COMNAND'.
  APPEND ls_event TO rt_events.
ENDFORM.                    "EVENTTAB_BUILD
*&--------------------------------------------------------------------*
*&      Form  layout_init
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->RS_LAYOUT  text
*---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.
*"Build layout for list display
  rs_layout-detail_popup      = 'X'.
  rs_layout-subtotals_text    = 'ZW-SUMME:'.
  rs_layout-totals_text       = 'SUMME:'.
  rs_layout-zebra = 'X'.
ENDFORM.                    "layout_init
*&---------------------------------------------------------------------*
*&      Form  HTML_TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM html_top_of_page USING document
                            TYPE REF TO cl_dd_document.     "#EC CALLED

  DATA: l_title    TYPE sdydo_text_element,
        l_text     TYPE sdydo_text_element,
        l_font     TYPE sdydo_attribute VALUE '1',
        ls_zfigiro TYPE zfigiro,
        l_month    TYPE fcltx.

  CONCATENATE g_address_value-name1 g_address_value-city1
    INTO l_text SEPARATED BY space.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  l_text = 'Giro'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  LOOP AT gt_zfigiro INTO   ls_zfigiro.

    IF NOT ls_zfigiro-giro_1 IS INITIAL.
      ADD 2 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_1 TO l_text.
*      TRANSLATE L_TEXT TO LOWER CASE.
      CALL METHOD document->add_gap
        EXPORTING
          width = 10.
      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT  ls_zfigiro-giro_2 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_2 TO l_text.
*      TRANSLATE L_TEXT TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_3 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_3 TO l_text.
*      TRANSLATE L_TEXT TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_4 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_4 TO l_text.
*      TRANSLATE L_TEXT TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_5 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_5 TO l_text.
*      TRANSLATE L_TEXT TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_6 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_6 TO l_text.
*      TRANSLATE L_TEXT TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

  ENDLOOP.
***        RUT
  l_text = 'Rut'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  MOVE g_paval TO l_text.
  CALL METHOD document->add_gap
    EXPORTING
      width = 11.

  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

***      Direccion
  l_text = 'Dirección'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
  MOVE g_address_value-street TO l_text .
  CALL METHOD document->add_gap
    EXPORTING
      width = 0.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

  CALL METHOD document->new_line.
  l_title = 'Libro Diario'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 170.
  CALL METHOD document->add_text
    EXPORTING
      text          = l_title
      sap_style     = 'HEADING'
*     sap_fontsize  = l_font.
      sap_fontstyle = 'C'
      sap_emphasis  = 'C'.
  CALL METHOD document->new_line.
  PERFORM get_month
              USING
                 p_monat
              CHANGING
                 l_month.
  CONCATENATE l_month br_gjahr-low
    INTO l_text SEPARATED BY space.

  CALL METHOD document->add_gap
    EXPORTING
      width = 175.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
ENDFORM.                    "html_top_of_page
*&---------------------------------------------------------------------*
*&      Form  HTML_END_OF_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM html_end_of_list USING document
                            TYPE REF TO cl_dd_document..
  DATA: l_title TYPE sdydo_text_element,
        l_text  TYPE sdydo_text_element,
        l_num   TYPE char13.


  WRITE g_num TO l_num .
*  CALL METHOD document->new_line.
  CONCATENATE 'Total de registros:' l_num
 INTO l_text SEPARATED BY space.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
ENDFORM.                    " HTML_END_OF_LIST

*&---------------------------------------------------------------------*
*&      Form  fieldcat_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM fieldcat_init USING lt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUDAT'.
  ls_fieldcat-seltext_m = 'Fecha Documento'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 12.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BELNR'.
  ls_fieldcat-seltext_m = 'Número Documento'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BLART'.
  ls_fieldcat-seltext_m = 'Cl Doc.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 6.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUZEI'.
  ls_fieldcat-seltext_m = 'Linea'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 6.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'HKONT'.
  ls_fieldcat-seltext_m = 'Cuenta'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TXT20'.
  ls_fieldcat-seltext_m = 'Descripción'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 25.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SGTXT'.
  ls_fieldcat-seltext_m = 'Glosa Movimiento'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 30.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DMBTR_S'.
  ls_fieldcat-seltext_m = 'Debe'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DMBTR_H'.
  ls_fieldcat-seltext_m = 'Haber'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERS'.
  ls_fieldcat-seltext_m = 'Moneda'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 6.
  APPEND ls_fieldcat TO lt_fieldcat.

*
* INI WALDO ALARCON - VISIONONE - 10-10-2025
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname      = 'CPUDT'.
  ls_fieldcat-ref_fieldname  = 'CPUDT'.
  ls_fieldcat-ref_tabname    = 'BKPF'.
  ls_fieldcat-outputlen      = 10.
  ls_fieldcat-tech           = gv_tcode.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname      = 'CPUTM'.
  ls_fieldcat-ref_fieldname  = 'CPUTM'.
  ls_fieldcat-ref_tabname    = 'BKPF'.
  ls_fieldcat-outputlen      = 10.
  ls_fieldcat-tech           = gv_tcode.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname      = 'TCODE'.
  ls_fieldcat-ref_fieldname  = 'TCODE'.
  ls_fieldcat-ref_tabname    = 'BKPF'.
  ls_fieldcat-outputlen      = 20.
  ls_fieldcat-tech           = gv_tcode.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname      = 'KURSF'.
  ls_fieldcat-ref_fieldname  = 'KURSF'.
  ls_fieldcat-ref_tabname    = 'BKPF'.
  ls_fieldcat-outputlen      = 10.
  ls_fieldcat-tech           = gv_tcode.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname      = 'USNAM'.
  ls_fieldcat-ref_fieldname  = 'USNAM'.
  ls_fieldcat-ref_tabname    = 'BKPF'.
  ls_fieldcat-outputlen      = 12.
  ls_fieldcat-tech           = gv_tcode.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname      = 'KOSTL'.
  ls_fieldcat-ref_fieldname  = 'KOSTL'.
  ls_fieldcat-ref_tabname    = 'BSEG'.
  ls_fieldcat-outputlen      = 10.
  ls_fieldcat-tech           = gv_tcode.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname      = 'LTEXT'.
  ls_fieldcat-ref_fieldname  = 'LTEXT'.
  ls_fieldcat-ref_tabname    = 'T003T'.
  ls_fieldcat-outputlen      = 25.
  ls_fieldcat-tech           = gv_tcode.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname      = 'XREF2_HD'.
  ls_fieldcat-ref_fieldname  = 'XREF2_HD'.
  ls_fieldcat-ref_tabname    = 'BKPF'.
  ls_fieldcat-outputlen      = 25.
  ls_fieldcat-tech           = gv_tcode.
  APPEND ls_fieldcat TO lt_fieldcat.
* FIN WALDO ALARCON - VISIONONE - 10-10-2025
ENDFORM.                    "fieldcat_init
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.     "#EC *
  DATA ls_outtab TYPE ty_s_outtab.
  CASE r_ucomm.

    WHEN 'LINE'.
      CALL SCREEN 0100
        STARTING AT 20 1.

    WHEN '&IC1'.
      READ TABLE gt_outtab
        INTO ls_outtab
        INDEX rs_selfield-tabindex .
      CASE rs_selfield-fieldname.

        WHEN 'BELNR'.
          SET PARAMETER ID: 'BLN' FIELD ls_outtab-belnr,
                            'BUK' FIELD ls_outtab-bukrs,
                            'GJR' FIELD ls_outtab-gjahr.

          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        WHEN OTHERS.
          SET PARAMETER ID: 'BLN' FIELD ls_outtab-belnr,
                            'BUK' FIELD ls_outtab-bukrs,
                            'GJR' FIELD ls_outtab-gjahr,
                            'BUZ' FIELD ls_outtab-buzei.
          CALL TRANSACTION 'FB09D' AND SKIP FIRST SCREEN.

      ENDCASE.
    WHEN 'DOWN'.
      IF p_path IS INITIAL.
        MESSAGE 'Debe Ingresar La Ruta del Archivo' TYPE 'E'.
      ENDIF.
      PERFORM fill_file
                  USING
                     gt_outtab
                  CHANGING
                     gt_download.

      PERFORM fill_total
                  USING
                     gt_tabtot
                  CHANGING
                     gt_download.
      PERFORM download_txt
                  USING
                     gt_download.
*      CLEAR P_PATH.
*      CALL SCREEN 0100
*        STARTING AT 20 1
*        ENDING   AT 73 6.
    WHEN '&TXT'.
      CALL FUNCTION 'GUI_EXEC'
        EXPORTING
          command   = 'NOTEPAD.EXE'
          parameter = g_path
*       IMPORTING
*         RETURNCODE       =
        .

  ENDCASE.
*break-point.
ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
*&---------------------------------------------------------------------*
FORM set_status USING rt_extab TYPE slis_t_extab .          "#EC *
  SET PF-STATUS 'STANDARD'.
ENDFORM.                    "set_status

*&---------------------------------------------------------------------*
*&      Form  get_description_hkont
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_description_hkont USING    p_saknr TYPE hkont
                           CHANGING p_txt20 TYPE txt20_skat.

  SELECT SINGLE txt20
    FROM skat
    INTO p_txt20
    WHERE spras EQ sy-langu
    AND saknr EQ p_saknr.
ENDFORM.                    " get_description_hkont

*&---------------------------------------------------------------------*
*&      Form  value_request_path_down
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PATH     text
*----------------------------------------------------------------------*
FORM value_request_path_down  CHANGING p_path.

  DATA: l_path TYPE string.

  MOVE p_path TO l_path.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    CHANGING
      selected_folder      = l_path
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  MOVE l_path TO p_path.

ENDFORM.                    "value_request_path_up

*&---------------------------------------------------------------------*
*&      Form  download_local
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_DOWNLOAD  text
*----------------------------------------------------------------------*
FORM download_txt USING lt_download TYPE ty_t_download.

  DATA: l_path TYPE string.

  CONCATENATE p_path '/libro_diario_' br_bukrs-low
              '_' sy-datum '_'
              sy-uzeit '.TXT' INTO l_path.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*     WRITE_FIELD_SEPARATOR   = '  '
      filename                = l_path
      filetype                = 'ASC'
    TABLES
      data_tab                = lt_download
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc NE 0.
    MESSAGE 'Error al descargar  archivo.' TYPE 'S'.
  ELSE.
    MOVE l_path TO g_path.
  ENDIF.


ENDFORM.                    " download_servidor
*&---------------------------------------------------------------------*
*&      Form  download_XLS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_OUTTAB   text
*----------------------------------------------------------------------*
FORM download_xls USING t_outtab TYPE ty_t_outtab.

  DATA: l_path TYPE string.

  CONCATENATE p_path '/libro_diario_' br_bukrs-low
              '_' sy-datum '_'
              sy-uzeit '.XLS' INTO l_path.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*     WRITE_FIELD_SEPARATOR   = '  '
      filename                = l_path
      filetype                = 'DAT'
    TABLES
      data_tab                = t_outtab
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc NE 0.
    MESSAGE 'Error al descargar  archivo.' TYPE 'S'.
  ELSE.
    MOVE l_path TO g_path.
  ENDIF.


ENDFORM.                    " d
*&---------------------------------------------------------------------*
*&      Form  fill_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_header  CHANGING t_download TYPE ty_t_download.
  DATA: ls_download TYPE ty_s_download,
        l_date      TYPE char20,
        l_month     TYPE fcltx.
  PERFORM get_month
              USING
                 p_monat
              CHANGING
                 l_month.

  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+3(20) = g_butxt.
  ls_download-data+66(20) = 'Libro Diario'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  CONCATENATE l_month br_gjahr-low
    INTO ls_download-data+67(20) SEPARATED BY space.
  APPEND ls_download TO t_download .
  CLEAR ls_download.


  ls_download-data = c_line.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data(15)     = 'Fecha Documento'.
  ls_download-data+16(14)  = 'Núm. Documento'.
  ls_download-data+31(6)   = 'Cl.Doc'.
  ls_download-data+38(5)   = 'Línea'.
  ls_download-data+46(10)  = 'Cuenta'.
  ls_download-data+60(20)  = 'Nombre Cuenta'.
  ls_download-data+84(30)  = 'Glosa Movimiento'.
  ls_download-data+114(13) = 'Debe'.
  ls_download-data+131(13) = 'Haber'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = c_line.
  APPEND ls_download TO t_download .CLEAR ls_download.
ENDFORM.                    " fill_header
*&---------------------------------------------------------------------*
*&      Form  fill_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_file USING t_outtab       TYPE  ty_t_outtab
               CHANGING t_download TYPE ty_t_download.
  DATA: ls_outtab   TYPE ty_s_outtab,
        ls_download TYPE ty_s_download,
        l_num       TYPE i,
        l_mod       TYPE i.
  CLEAR: g_num.
  CLEAR t_download.
  PERFORM fill_header
              CHANGING
                 gt_download.
  LOOP AT t_outtab  INTO ls_outtab .
    ADD 1 TO g_num.
    .

    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = ls_outtab-budat
      IMPORTING
        date_external            = ls_download-data+3(12)
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.

*  ls_download-data+3(10)   = w_outtab-budat.
    ls_download-data+19(10)  = ls_outtab-belnr.
    ls_download-data+33(2)   = ls_outtab-blart.
    ls_download-data+39(3)   = ls_outtab-buzei.
    ls_download-data+46(10)  = ls_outtab-hkont.
    ls_download-data+60(20)  = ls_outtab-txt20.
    ls_download-data+84(21)  = ls_outtab-sgtxt.
    WRITE ls_outtab-dmbtr_s TO ls_download-data+109(13) CURRENCY ls_outtab-waers.
    WRITE ls_outtab-dmbtr_h TO ls_download-data+126(13) CURRENCY ls_outtab-waers.
    APPEND ls_download TO t_download .
    CLEAR ls_download.

    l_mod =  g_num MOD g_line.
*    AT LAST.
*      l_mod =  g_num MOD 42.
*    ENDAT.
    IF l_mod EQ 0.

      PERFORM fill_foot
                  CHANGING
                     gt_download.

      PERFORM fill_header
                  CHANGING
                     gt_download.

    ENDIF.
  ENDLOOP.
ENDFORM.                    " fill_file
*&---------------------------------------------------------------------*
*&      Form  fill_foot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_foot  CHANGING t_download TYPE ty_t_download.
  DATA: ls_download TYPE ty_s_download.

  ls_download-data = space.
  APPEND ls_download TO t_download .
  ls_download-data = space.
  APPEND ls_download TO t_download .


ENDFORM.                    " fill_foot
*&---------------------------------------------------------------------*
*&      Form  get_month
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_month USING p_monat TYPE monat
               CHANGING p_month     TYPE fcltx.

  DATA: lt_month_names TYPE TABLE OF t247,
        ls_month_names TYPE  t247,
        l_subrc        TYPE sy-subrc.
  CALL FUNCTION 'MONTH_NAMES_GET'
    EXPORTING
      language              = sy-langu
    IMPORTING
      return_code           = l_subrc
    TABLES
      month_names           = lt_month_names
    EXCEPTIONS
      month_names_not_found = 1
      OTHERS                = 2.
  IF l_subrc EQ 0.
    READ TABLE lt_month_names
     INTO ls_month_names
     WITH KEY mnr = p_monat.
    IF sy-subrc EQ 0.
      MOVE ls_month_names-ltx TO p_month .
    ENDIF.
  ENDIF.

ENDFORM.                    " get_month
*&---------------------------------------------------------------------*
*&      Form  fill_total
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_total USING t_tabtot TYPE ty_t_tabtot
                CHANGING t_download TYPE ty_t_download.
  DATA: ls_download TYPE ty_s_download,
        ls_tabtot   TYPE ty_s_tabtot.

  ls_download-data = space.
  APPEND ls_download TO t_download .
  ls_download-data+95(44) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+95(06) = 'Cl Doc'.
  ls_download-data+103(18) = '    Debe'.
  ls_download-data+122(18) = '    Haber'.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data+95(44) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.

  LOOP AT t_tabtot INTO ls_tabtot.
    ls_download-data+99(2)  = ls_tabtot-blart.
    WRITE ls_tabtot-dmbtr_s TO ls_download-data+103(18) CURRENCY 'CLP'.
    WRITE ls_tabtot-dmbtr_h TO ls_download-data+122(18) CURRENCY 'CLP'.
    APPEND ls_download TO t_download .CLEAR ls_download.
  ENDLOOP.

  ls_download-data+95(44) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data+95(06) = 'Total'.
  WRITE dmbtr_s TO ls_download-data+103(18) CURRENCY 'CLP'.
  WRITE  dmbtr_h TO ls_download-data+122(18) CURRENCY 'CLP'.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data+95(44) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.
ENDFORM.                    " fill_total
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM modify_screen .
  LOOP AT SCREEN.
    CASE  screen-name..
      WHEN 'BR_BUKRS-HIGH' OR '%_BR_BUKRS_%_APP_%-VALU_PUSH'." OR  '%_BR_BUKRS_%_APP_%-TEXT'.
        screen-active = 0.
      WHEN 'BR_GJAHR-HIGH' OR '%_BR_GJAHR_%_APP_%-VALU_PUSH'.
        screen-active = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                    " MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  get_description_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_description_bukrs USING p_bukrs TYPE bukrs
                           CHANGING p_butxt TYPE butxt.
  DATA : l_adrnr             TYPE adrnr,
         l_address_selection TYPE addr1_sel.

  SELECT SINGLE butxt adrnr
    FROM t001
    INTO (p_butxt, l_adrnr)
    WHERE bukrs EQ p_bukrs
    AND spras EQ sy-langu.

  MOVE l_adrnr TO  l_address_selection-addrnumber.

  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = l_address_selection
    IMPORTING
      address_value     = g_address_value
    EXCEPTIONS
      parameter_error   = 1
      address_not_exist = 2
      version_not_exist = 3
      internal_error    = 4
      OTHERS            = 5.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
  SELECT SINGLE paval
    FROM t001z
    INTO g_paval
    WHERE bukrs EQ p_bukrs
    AND party EQ 'TAXNR' .

  SELECT * FROM zfigiro
    INTO TABLE gt_zfigiro
    WHERE bukrs = p_bukrs.
ENDFORM.                    " get_description_bukrs

*&---------------------------------------------------------------------*
*&      Form  get_saknr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_saldo .
  DATA: gt_glt0     TYPE fagl_t_glt0,
        gs_glt0     TYPE glt0,
        range_racct TYPE fagl_range_t_racct.
  DATA: ls_range_racct TYPE fagl_range_racct,
        saldo          LIKE  gs_glt0-hslvt.

  SELECT saknr
    FROM skb1
    INTO ls_range_racct-low
    WHERE bukrs EQ br_bukrs-low.

    MOVE 'I'              TO ls_range_racct-sign.
    MOVE 'EQ'             TO ls_range_racct-option.
    APPEND ls_range_racct TO range_racct.
    CLEAR ls_range_racct.

  ENDSELECT.

  CALL FUNCTION 'FAGL_GET_GLT0'
    EXPORTING
      i_glt0_rldnr      = br_rldnr-low
      i_rvers           = '001'
      i_bukrs           = br_bukrs-low
      i_ryear           = br_gjahr-low
      i_rpmax           = '016'
      i_range_racct     = range_racct
    IMPORTING
      et_glt0           = gt_glt0
    EXCEPTIONS
      invalid_selection = 1
      OTHERS            = 2.


  CLEAR gs_outtab.
  SORT gt_glt0 BY racct.

  LOOP AT gt_glt0 INTO gs_glt0.

    CASE p_monat.
      WHEN 1.
        saldo = saldo + gs_glt0-hslvt .
    ENDCASE.

    AT END OF racct.
      IF saldo < '0.00'.
        gs_outtab-dmbtr_h = gs_outtab-dmbtr_h + ( saldo * -1 ).
      ELSE.
        gs_outtab-dmbtr_s = gs_outtab-dmbtr_s + saldo.
      ENDIF.
      CLEAR saldo.
    ENDAT.


  ENDLOOP.

  gs_outtab-bukrs = br_bukrs-low.
  gs_outtab-gjahr = br_gjahr-low.
  gs_outtab-txt20  = 'Saldo Total Apertura'.
  "          sgtxt   TYPE sgtxt,
  gs_outtab-waers = 'CLP'.

  APPEND gs_outtab TO gt_outtab.

  MOVE 'AA'    TO gs_tabtot-blart.
  MOVE 'CLP'   TO gs_tabtot-waers.
  MOVE gs_outtab-dmbtr_h TO gs_tabtot-dmbtr_h.
  MOVE gs_outtab-dmbtr_s TO gs_tabtot-dmbtr_s.
  COLLECT gs_tabtot INTO gt_tabtot.
  dmbtr_h = dmbtr_h + gs_outtab-dmbtr_h.
  dmbtr_s = dmbtr_s + gs_outtab-dmbtr_s.

  CLEAR gs_outtab.

ENDFORM.                    " get_SAKNR
