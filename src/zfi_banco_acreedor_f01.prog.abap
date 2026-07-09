*&---------------------------------------------------------------------*
*&  Include           ZFI_BANCO_ACREEDOR_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  AUTORIZACION
*&---------------------------------------------------------------------*
FORM autorizacion .

  AUTHORITY-CHECK OBJECT 'S_TCODE'
                      ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e899(mm) WITH TEXT-e01 sy-tcode.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_ARCHIVO
*&---------------------------------------------------------------------*
FORM lee_archivo  CHANGING p_file.
  DATA: lt_tab   TYPE filetable,
        ld_subrc TYPE i,
        ls_tab   LIKE LINE OF lt_tab.
*
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title     = 'Seleccionar Archivo'
      default_filename = '*.xlsx'
      file_filter      = ',*.XLS,*.xls,*.XLSX,*.xlsx'
      multiselection   = ' '
    CHANGING
      file_table       = lt_tab
      rc               = ld_subrc.
  READ TABLE lt_tab INDEX 1 INTO ls_tab.
  IF sy-subrc EQ 0.
    MOVE ls_tab TO p_file.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEER_ARCHIVO_EXCEL
*&---------------------------------------------------------------------*
FORM leer_archivo_excel .
  TYPES: BEGIN OF ty_datatab,
           col1(40)  TYPE c,
           col2(10)  TYPE c,
           col3(05)  TYPE c,
           col4(16)  TYPE c,
           col5(10)  TYPE c,
           col6(16)  TYPE c,
           col7(10)  TYPE c,
           col8(60)  TYPE c,
           col9(241) TYPE c,
         END OF ty_datatab.
  DATA : lt_datos     TYPE TABLE OF ty_datatab,
         it_raw       TYPE truxs_t_text_data,
         lv_bankl(03) TYPE c.
*
  CLEAR gt_salida[].
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header        = 'X'
      i_tab_raw_data       = it_raw
      i_filename           = p_file
    TABLES
      i_tab_converted_data = lt_datos
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*
  LOOP AT lt_datos ASSIGNING FIELD-SYMBOL(<datos>).
    CLEAR wa_salida.
    SELECT SINGLE lifnr, name1, name2, land1 INTO @DATA(lv_lfa1)
           FROM lfa1 WHERE stcd1 =  @<datos>-col2.
    IF sy-subrc NE 0.
      wa_salida-mensaje = 'Acreedor NO Existe, para el RUT indicado'.
    ENDIF.
    wa_salida-lifnr = lv_lfa1-lifnr.
    wa_salida-name1 = lv_lfa1-name1.
    wa_salida-name2 = lv_lfa1-name2.
    wa_salida-land1 = lv_lfa1-land1.
    wa_salida-stcd1 = <datos>-col2.
    wa_salida-banks = 'CL'.
    lv_bankl        = |{ <datos>-col5 ALPHA = IN }|.
    wa_salida-bankl = lv_bankl.
    wa_salida-bankn = <datos>-col6.
    CONDENSE wa_salida-bankn NO-GAPS.
* verifica la cuenta contable a eliminar
    IF wa_salida-lifnr IS NOT INITIAL.
      SELECT SINGLE lifnr INTO @DATA(lv_lifnr)
         FROM lfbk WHERE lifnr EQ @wa_salida-lifnr
                    AND  banks EQ @wa_salida-banks
                    AND  bankl EQ @wa_salida-bankl
                    AND  bankn EQ @wa_salida-bankn.
      IF sy-subrc NE 0.
        wa_salida-mensaje = 'Cuenta NO Existe, para el cliente indicado'.
      ELSE.
        gv_procesa = gc_x.
      ENDIF.
    ENDIF.

    APPEND wa_salida TO gt_salida.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: lt_sort     TYPE lvc_t_sort,
        lt_fieldcat TYPE lvc_t_fcat,
        wa_layout   TYPE lvc_s_layo,
        wa_variant  TYPE disvariant.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM sort            TABLES lt_sort.
  PERFORM fieldcat_init   USING lt_fieldcat[].
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
      it_sort_lvc              = lt_sort
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_salida
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm    LIKE sy-ucomm            "#EC NEEDED
                        rs_selfield TYPE slis_selfield.     "#EC CALLED
  DATA : lt_bdcdata_tab TYPE bdcdata_tab,
         opt            TYPE ctu_params.
*
  CASE r_ucomm.
    WHEN 'FC01'.
      PERFORM eliminar_cta_banco.
    WHEN OTHERS.
      CASE rs_selfield-fieldname.
        WHEN 'LIFNR'.
          lt_bdcdata_tab = VALUE #(
            ( program  = 'SAPMF02K'          dynpro   = '0101' dynbegin = 'X' )
            ( fnam     = 'BDC_OKCODE'        fval     = '/00'             )
            ( fnam     = 'RF02K-LIFNR'       fval     = rs_selfield-value )
            ( fnam     = 'RF02K-D0130'       fval     = 'X'               ) ).

          opt-dismode = 'E'.
          opt-defsize = 'X'.

          TRY.
              CALL TRANSACTION 'XK03' WITH AUTHORITY-CHECK
                                      USING lt_bdcdata_tab OPTIONS FROM opt.
            CATCH cx_sy_authorization_error ##NO_HANDLER.
          ENDTRY.
      ENDCASE.
  ENDCASE.
  rs_selfield-refresh = gc_x.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA: lt_fcode_attrib_tab TYPE TABLE OF smp_dyntxt,
        lw_fcode_attrib_tab TYPE smp_dyntxt.
*
  CLEAR: lt_fcode_attrib_tab[].
*
  IF gv_procesa EQ gc_x.
    lw_fcode_attrib_tab-text      = TEXT-act.
    lw_fcode_attrib_tab-icon_id   = icon_delete.
    lw_fcode_attrib_tab-icon_text = TEXT-act.
    lw_fcode_attrib_tab-quickinfo = space.
    lw_fcode_attrib_tab-path      = space.
    APPEND lw_fcode_attrib_tab TO lt_fcode_attrib_tab.
  ENDIF.
*
  PERFORM dynamic_report_fcodes IN PROGRAM rhteiln0
                                          TABLES lt_fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.

  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.
ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE lvc_s_layo.
  CLEAR rs_layout.
*  rs_layout-f2code               = 'DISPLAY'.
  rs_layout-zebra                = gc_x.
  rs_layout-detailinit           = gc_x.
  rs_layout-cwidth_opt           = gc_x.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SORT
*&---------------------------------------------------------------------*
FORM sort  TABLES   p_it_sort TYPE lvc_t_sort.
  DATA wa_sort TYPE lvc_s_sort.
*
  CLEAR p_it_sort[].
*  ADD 1 TO wa_sort-spos.
*  wa_sort-fieldname = 'KSCHL'.
*  wa_sort-up        = gc_x.
*  APPEND wa_sort TO p_it_sort.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
*
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gc_tabla
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
*
  LOOP AT p_gt_fieldcat ASSIGNING FIELD-SYMBOL(<fieldcat>).
    <fieldcat>-colddictxt     = 'M'.
    CASE <fieldcat>-fieldname.
      WHEN 'LIFNR'.
        <fieldcat>-key        = gc_x.
        <fieldcat>-hotspot    = gc_x.
      WHEN 'NAME1'.
        <fieldcat>-key        = gc_x.
      WHEN 'MENSAJE'.
        <fieldcat>-colddictxt     = 'L'.
    ENDCASE.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ELIMINAR_CTA_BANCO
*&---------------------------------------------------------------------*
FORM eliminar_cta_banco .
  DATA: lw_lfa1  TYPE lfa1,
        lw_lfb1  TYPE lfb1,
        lw_lfm1  TYPE lfm1,
        lw_ylfa1 TYPE lfa1,
        lw_ylfb1 TYPE lfb1,
        lw_ylfm1 TYPE lfm1,
*
        lt_xlfas TYPE TABLE OF flfas,
        lt_xlfb5 TYPE TABLE OF flfb5,
        lt_xlfbk TYPE TABLE OF flfbk,
        lt_xlfza TYPE TABLE OF flfza,
        lt_ylfas TYPE TABLE OF flfas,
        lt_ylfb5 TYPE TABLE OF flfb5,
        lt_ylfbk TYPE TABLE OF flfbk,
        lt_ylfza TYPE TABLE OF flfza,
*
        wa_ylfbk TYPE flfbk,
        lv_tabix TYPE sytabix.

  LOOP AT gt_salida INTO wa_salida WHERE mensaje IS INITIAL.
    MOVE sy-tabix TO lv_tabix.

    CLEAR : wa_ylfbk, lt_ylfbk[].
    wa_ylfbk-lifnr = wa_salida-lifnr.
    wa_ylfbk-banks = wa_salida-banks.
    wa_ylfbk-bankl = wa_salida-bankl.
    wa_ylfbk-bankn = wa_salida-bankn.
    wa_ylfbk-kz    = ' '.  "E
    APPEND wa_ylfbk TO lt_ylfbk.
*
    CALL FUNCTION 'VENDOR_UPDATE'
      EXPORTING
        i_lfa1  = lw_lfa1
        i_lfb1  = lw_lfb1
        i_lfm1  = lw_lfm1
        i_ylfa1 = lw_ylfa1
        i_ylfb1 = lw_ylfb1
        i_ylfm1 = lw_ylfm1
      TABLES
        t_xlfas = lt_xlfas
        t_xlfb5 = lt_xlfb5
        t_xlfbk = lt_xlfbk
        t_xlfza = lt_xlfza
        t_ylfas = lt_ylfas
        t_ylfb5 = lt_ylfb5
        t_ylfbk = lt_ylfbk
        t_ylfza = lt_ylfza.

    IF sy-subrc EQ 0.
      wa_salida-mensaje = 'Cuenta del Acreedor Eliminada'.
      COMMIT WORK AND WAIT.
    ELSE.
      MESSAGE a801(f2) WITH 'LFBK' wa_salida-lifnr INTO wa_salida-mensaje.
    ENDIF.

    MODIFY gt_salida FROM wa_salida INDEX lv_tabix.
  ENDLOOP.
  CLEAR gv_procesa.
ENDFORM.
