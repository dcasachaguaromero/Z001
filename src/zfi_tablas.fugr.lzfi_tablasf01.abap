*----------------------------------------------------------------------*
***INCLUDE LZFI_TABLASF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DIRECTORIO
*&---------------------------------------------------------------------*
FORM directorio  CHANGING p_direc.
  DATA: l_folder TYPE string.
*
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Seleccione Directorio'
      initial_folder       = 'C:\'
    CHANGING
      selected_folder      = l_folder
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc = 0.
    p_direc = l_folder.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ARCHIVO_BAJADA
*&---------------------------------------------------------------------*
FORM archivo_bajada  TABLES   ti_extract
                     USING    p_vista
                              p_tabla_sal.
  DATA : generic_table TYPE REF TO data,
         lt_fieldcat   TYPE lvc_t_fcat.
  FIELD-SYMBOLS: <lt_table> TYPE STANDARD TABLE,
                 <lw_line>  TYPE any.
*
  PERFORM cabecera USING lt_fieldcat[]
                         g_table.
*
  CREATE DATA generic_table TYPE STANDARD TABLE OF (g_table).
  ASSIGN generic_table->* TO <ti_table>.
* CREA ESTRUCTURA
  CREATE DATA generic_table TYPE (g_table).
  ASSIGN generic_table->* TO <l_line>.

  LOOP AT ti_extract INTO p_vista.
    MOVE-CORRESPONDING p_vista TO <l_line>.
    APPEND <l_line> TO <ti_table>.
  ENDLOOP.

*
  IF p_tabla_sal IS NOT INITIAL.
*
    PERFORM cabecera USING lt_fieldcat[]
                           p_tabla_sal.
*
    CREATE DATA generic_table TYPE STANDARD TABLE OF (p_tabla_sal).
    ASSIGN generic_table->* TO <lt_table>.
    CREATE DATA generic_table TYPE (p_tabla_sal).
    ASSIGN generic_table->* TO <lw_line>.

    LOOP AT <ti_table> INTO <l_line>.
      MOVE-CORRESPONDING <l_line> TO <lw_line>.
      APPEND <lw_line> TO <lt_table>.
    ENDLOOP.

    UNASSIGN <ti_table>.
    ASSIGN TABLE FIELD <lt_table> TO <ti_table>.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD
*&---------------------------------------------------------------------*
FORM download USING p_file.
  DATA: l_filename   TYPE string,
        lt_salida    TYPE truxs_t_text_data,
        ti_csv_table TYPE truxs_t_text_data,
        lv_head      TYPE string.
*
  LOOP AT gt_cabeceras  INTO DATA(lw_fieldnames).
    CASE sy-tabix.
      WHEN 1.
        lv_head = lw_fieldnames-fieldname.
      WHEN OTHERS.
        lv_head = lv_head && ';' && lw_fieldnames-fieldname.
    ENDCASE.
  ENDLOOP.
  APPEND lv_head TO lt_salida.
*
  CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
    EXPORTING
      i_field_seperator    = ';'
    TABLES
      i_tab_sap_data       = <ti_table>
    CHANGING
      i_tab_converted_data = ti_csv_table
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
*
  APPEND LINES OF ti_csv_table TO lt_salida.
*
  l_filename = p_file.
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = l_filename
    CHANGING
      data_tab                = lt_salida
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
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc <> 0.
    MESSAGE e014(usmd6) WITH l_filename.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUSQUEDA_ARCHIVO
*&---------------------------------------------------------------------*
FORM busqueda_archivo  CHANGING p_filename.
  DATA: l_filename  TYPE string,
        o_filetable TYPE TABLE OF file_table,
        o_action    TYPE i,
        x_rc        TYPE i.
*
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
*     window_title            = i_title
      default_filename        = l_filename
      file_filter             = '*.*'
    CHANGING
      file_table              = o_filetable
      rc                      = x_rc
      user_action             = o_action
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    CLEAR p_filename.
  ELSE.
    IF o_action = 0.
      READ TABLE o_filetable INDEX 1 INTO p_filename.
    ELSE.
      CLEAR p_filename.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREPARA_ARCHIVO
*&---------------------------------------------------------------------*
FORM prepara_archivo USING    p_archivo
                     CHANGING gt_fieldcat TYPE slis_t_fieldcat_alv
                              it_fieldcat TYPE lvc_t_fcat
                              p_end.
  DATA: pv_tabla    TYPE dd02l-tabname,
        l_tabname   TYPE slis_tabname,
        l_tabix     TYPE sytabix,
        new_table   TYPE REF TO data,
        new_line    TYPE REF TO data,
        ls_fieldcat TYPE slis_fieldcat_alv,
        is_fieldcat TYPE lvc_s_fcat,
        l_pos       TYPE i.
  DATA : r_fieldname  TYPE RANGE OF slis_fieldcat_alv-fieldname,
         wa_fieldname LIKE LINE OF r_fieldname.
* CREACION DE CANMPOS DE LA TABLA PARA EL PROCESO DE EXCEL
  CLEAR : gt_fieldcat[], it_fieldcat[].
  l_tabname = p_archivo.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = l_tabname
    CHANGING
      ct_fieldcat      = gt_fieldcat[].
*
  p_end = 0.
  l_pos = 1.
  LOOP AT gt_fieldcat INTO ls_fieldcat WHERE fieldname NE 'MANDT'.
    MOVE sy-tabix TO l_tabix.
*
    IF ls_fieldcat-fieldname IN r_fieldname AND r_fieldname[] IS NOT INITIAL.
      ls_fieldcat-tech = c_x.
    ENDIF.
*
    IF ls_fieldcat-tech NE c_x.
      MOVE-CORRESPONDING ls_fieldcat TO is_fieldcat.
      is_fieldcat-col_pos   = l_pos.
      is_fieldcat-fieldname = ls_fieldcat-fieldname.
      is_fieldcat-ref_field = ls_fieldcat-fieldname.
      is_fieldcat-ref_table = ls_fieldcat-ref_tabname.
      APPEND is_fieldcat TO it_fieldcat.
      ADD 1 TO l_pos.
      ADD 1 TO p_end.
    ENDIF.
*
    ls_fieldcat-ddictxt  = 'L'.
    MODIFY gt_fieldcat FROM ls_fieldcat INDEX l_tabix.
  ENDLOOP.
* Create a new Table
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = it_fieldcat
    IMPORTING
      ep_table        = new_table.
* Create a new Line with the same structure of the table.
  ASSIGN new_table->* TO <ti_table>.
  CREATE DATA new_line LIKE LINE OF <ti_table>.
  ASSIGN new_line->* TO <l_line>.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CARGA_ARCHIVO
*&---------------------------------------------------------------------*
FORM carga_archivo  TABLES ti_table
                    USING  p_file
                           it_fieldcat TYPE lvc_t_fcat
                           p_end.
  DATA: it_excel    TYPE STANDARD TABLE OF alsmex_tabline,
        is_fieldcat TYPE lvc_s_fcat,
        l_campo     TYPE string,
        l_moneda    TYPE waers,
        l_fecha     TYPE char10,
        l_datum     TYPE datum,
        l_index     TYPE i.

  FIELD-SYMBOLS: <fs_excel> LIKE LINE OF it_excel,
                 <fs>       TYPE any.
*
  CLEAR ti_table[].
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_file
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = p_end
      i_end_row               = 65536
    TABLES
      intern                  = it_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE e010(ad) WITH 'error en el archivo, verifique datos'.
  ENDIF.
  CHECK NOT it_excel[] IS INITIAL.
  LOOP AT it_excel ASSIGNING <fs_excel>.
    MOVE <fs_excel>-col TO l_index.
    ASSIGN COMPONENT l_index OF STRUCTURE <l_line> TO <fs>.
*
    READ TABLE it_fieldcat INTO is_fieldcat WITH KEY col_pos = l_index.
    IF sy-subrc EQ 0.
      CASE is_fieldcat-datatype.
        WHEN 'CURR' OR 'DEC'.
          TRANSLATE <fs_excel>-value USING '. '.
          TRANSLATE <fs_excel>-value USING ',.'.
          CONDENSE  <fs_excel>-value NO-GAPS.
          MOVE <fs_excel>-value TO <fs>.
        WHEN 'CUKY'.
          MOVE <fs_excel>-value TO <fs>.
          l_moneda = <fs>.
        WHEN 'DATS'.
          TRANSLATE <fs_excel>-value USING '/.'.
          TRANSLATE <fs_excel>-value USING '-.'.
          CONDENSE  <fs_excel>-value NO-GAPS.
          CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
            EXPORTING
              date_external            = <fs_excel>-value
            IMPORTING
              date_internal            = <fs>
            EXCEPTIONS
              date_external_is_invalid = 1
              OTHERS                   = 2.
          IF sy-subrc <> 0.
            <fs> = <fs_excel>-value.
            CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
              EXPORTING
                date_internal            = <fs>
              IMPORTING
                date_external            = l_fecha
              EXCEPTIONS
                date_internal_is_invalid = 1
                OTHERS                   = 2.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          MOVE <fs_excel>-value TO <fs>.
      ENDCASE.
    ENDIF.
*
    AT END OF row.
      IF l_moneda EQ  'CLP'.
        LOOP AT it_fieldcat INTO is_fieldcat.
          IF  is_fieldcat-datatype EQ 'CURR'.
            CONCATENATE '<L_LINE>-' is_fieldcat-fieldname INTO l_campo.
            ASSIGN (l_campo) TO <fs>.
            <fs> = <fs> / 100.
          ENDIF.
          IF is_fieldcat-fieldname EQ 'OPT1' OR
             is_fieldcat-fieldname EQ 'OPT2' OR
             is_fieldcat-fieldname EQ 'OPT3'.
            CONCATENATE '<L_LINE>-' is_fieldcat-fieldname INTO l_campo.
            ASSIGN (l_campo) TO <fs>.
            <fs> = 'X'.
          ENDIF.
        ENDLOOP.
      ENDIF.
      APPEND <l_line> TO ti_table.
      CLEAR <l_line> .
    ENDAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos  TABLES ti_table
                    USING  gt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: wa_layout   TYPE slis_layout_alv,
        ti_fieldcat TYPE slis_t_fieldcat_alv.
*
  MOVE sy-repid           TO g_repid.
  PERFORM layout_init     USING wa_layout.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = wa_layout
      it_fieldcat              = gt_fieldcat[]
    TABLES
      t_outtab                 = ti_table
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CLEAR :  ti_table[].
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm    LIKE sy-ucomm            "#EC NEEDED
                        rs_selfield TYPE slis_selfield.     "#EC CALLED
*
  CASE r_ucomm.
    WHEN 'FC01'.
      PERFORM graba_datos.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
  rs_selfield-refresh = c_x.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE.
*
  IF <ti_table> IS NOT INITIAL.
    fcode_attrib_tab-text      = TEXT-001.
    fcode_attrib_tab-icon_id   = icon_import.
    fcode_attrib_tab-icon_text = TEXT-001.
    fcode_attrib_tab-quickinfo = space.
    fcode_attrib_tab-path      = space.
    APPEND fcode_attrib_tab.
  ENDIF.
*
  PERFORM dynamic_report_fcodes(rhteiln0) TABLES fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.
*
  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.
ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  layout_init
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.
  CLEAR rs_layout.
  rs_layout-f2code               = 'DISPLAY'.
  rs_layout-zebra                = c_x.
  rs_layout-detail_popup         = c_x.
  rs_layout-detail_initial_lines = c_x.
  rs_layout-colwidth_optimize    = c_x.
ENDFORM.                    " LAYOUT_INIT
*&---------------------------------------------------------------------*
*&      Form  GRABA_DATOS
*&---------------------------------------------------------------------*
FORM graba_datos .
  DATA : generic_table    TYPE REF TO data.
  FIELD-SYMBOLS: <table> TYPE STANDARD TABLE,
                 <line>  TYPE any.
* CREA TABLA
  CREATE DATA generic_table TYPE STANDARD TABLE OF (g_table).
  ASSIGN generic_table->* TO <table>.
* CREA ESTRUCTURA
  CREATE DATA generic_table TYPE (g_table).
  ASSIGN generic_table->* TO <line>.

  LOOP AT <ti_table> INTO <l_line>.
    MOVE-CORRESPONDING <l_line> TO <line>.
    APPEND <line> TO <table>.
  ENDLOOP.

  MODIFY (g_table) FROM TABLE <table> .
*
  g_graba = c_x.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CABECERA
*&---------------------------------------------------------------------*
FORM cabecera  USING p_gt_fieldcat TYPE lvc_t_fcat
                     p_g_table.
  DATA lv_tabla TYPE char30.
*
  CLEAR : gt_cabeceras[], p_gt_fieldcat[].
  lv_tabla = p_g_table.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = lv_tabla
    CHANGING
      ct_fieldcat            = p_gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT p_gt_fieldcat ASSIGNING FIELD-SYMBOL(<fieldcat>).
    <fieldcat>-colddictxt = 'L'.
    CASE <fieldcat>-colddictxt.
      WHEN 'S'.
        APPEND <fieldcat>-scrtext_s TO gt_cabeceras.
      WHEN 'M'.
        APPEND <fieldcat>-scrtext_m TO gt_cabeceras.
      WHEN 'L'.
        APPEND <fieldcat>-scrtext_l TO gt_cabeceras.
    ENDCASE.
  ENDLOOP.
ENDFORM.
