*&---------------------------------------------------------------------*
*&  Include           ZFI_CARGA_MASIVA_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LEER_PC
*&---------------------------------------------------------------------*
FORM leer_pc  CHANGING p_filepc.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = p_filepc
      def_path         = 'c:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Directorio de Datos'
    IMPORTING
      filename         = p_filepc
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEER_SERVER
*&---------------------------------------------------------------------*
FORM leer_server  CHANGING p_p_filepc.
  DATA: lt_dir1        TYPE TABLE OF eps2fili,
        wa_dir1        LIKE LINE OF lt_dir1,
        lv_iv_dir_name TYPE  eps2filnam.
*
  lv_iv_dir_name = p_p_filepc.
  CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
    EXPORTING
      iv_dir_name = lv_iv_dir_name
    TABLES
      dir_list    = lt_dir1.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_ARCHIVO_CSV
*&---------------------------------------------------------------------*
FORM lee_archivo_csv.
  DATA: lt_aux      TYPE truxs_t_text_data,
        lt_datos    TYPE TABLE OF zes_fi_carga_masiva_csv,
        lv_filename TYPE string.
*
  lv_filename = p_filepc.
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = 'DAT'
    CHANGING
      data_tab                = lt_aux
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
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

  DELETE lt_aux INDEX 1. "Borramos la fila de los titulos cabecera
  CALL FUNCTION 'TEXT_CONVERT_CSV_TO_SAP'
    EXPORTING
      i_field_seperator    = ';'
      i_tab_raw_data       = lt_aux
    TABLES
      i_tab_converted_data = lt_datos.
*
  LOOP AT lt_datos INTO DATA(lw_datos).
    CLEAR wa_excel.
*
    PERFORM fromatea_valor USING lw_datos-amt_doccur
                           CHANGING lw_datos-amt_doccur.
    PERFORM fromatea_valor USING lw_datos-amt_base
                           CHANGING lw_datos-amt_base.
*
    MOVE-CORRESPONDING lw_datos TO wa_excel.
    wa_excel-key    = wa_excel-zkey.
    wa_excel-correl = wa_excel-itemno_acc.
    APPEND wa_excel TO gt_excel.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_ARCHIVO_EXCEL
*&---------------------------------------------------------------------*
FORM lee_archivo_excel .
  DATA: lt_excel     TYPE TABLE OF alsmex_tabline,
        ls_tabla     TYPE zes_fi_carga_masiva,
        lv_start_col TYPE i VALUE 1,
        lv_start_row TYPE i VALUE 2,
        lv_end_col   TYPE i VALUE 46,
        lv_end_row   TYPE i VALUE 65536,
        lv_index     TYPE i.
  FIELD-SYMBOLS: <fs_excel> LIKE LINE OF lt_excel,
                 <fs>.
*
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_filepc
      i_begin_col             = lv_start_col
      i_begin_row             = lv_start_row
      i_end_col               = lv_end_col
      i_end_row               = lv_end_row
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CHECK NOT lt_excel[] IS INITIAL.

  LOOP AT lt_excel ASSIGNING <fs_excel>.
    MOVE <fs_excel>-col TO lv_index.
    ASSIGN COMPONENT lv_index OF STRUCTURE ls_tabla TO <fs>.
*          AMT_DOCCUR
*AMT_BASE
    CASE lv_index.
      WHEN 31.
        PERFORM fromatea_valor USING <fs_excel>-value
                               CHANGING <fs>.
      WHEN 32.
        PERFORM fromatea_valor USING <fs_excel>-value
                               CHANGING <fs>.
      WHEN OTHERS.
        MOVE <fs_excel>-value TO <fs>.
    ENDCASE.
    AT END OF row.
      CLEAR wa_excel.
      MOVE-CORRESPONDING ls_tabla TO wa_excel.
      wa_excel-key    = wa_excel-zkey.
      wa_excel-correl = wa_excel-itemno_acc.
      APPEND wa_excel TO gt_excel.

      CLEAR ls_tabla.
    ENDAT.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREPARA_DATOS
*&---------------------------------------------------------------------*
FORM prepara_datos .
  DATA lv_key TYPE zkey1.
*
  CLEAR :  gt_header[], gt_detalle[] .
  SORT gt_excel BY key correl.
  lv_key = |_{ sy-datum }_{ sy-uzeit }|.
  LOOP AT gt_excel ASSIGNING FIELD-SYMBOL(<campos>).
    CLEAR wa_excel.
    MOVE-CORRESPONDING <campos> TO wa_excel.
    AT NEW key.
      MOVE-CORRESPONDING wa_excel TO wa_cabecera.
      MOVE  wa_excel-zkey         TO wa_cabecera-key.
      CONDENSE wa_cabecera-key NO-GAPS.
      wa_cabecera-key+4(16)  =   lv_key.
      CONDENSE wa_cabecera-key NO-GAPS.
      MOVE : wa_excel-ledger      TO wa_cabecera-acc_principle,
             'CARGAMASIVA'        TO wa_cabecera-grupo,
             sy-uname             TO wa_cabecera-username.

      APPEND wa_cabecera TO gt_header.
    ENDAT.
*
    MOVE-CORRESPONDING wa_excel TO wa_detalle.
    MOVE wa_excel-xinfiva       TO wa_detalle-iva.
    IF wa_excel-vendor_no IS NOT INITIAL.
      wa_detalle-ktok      = 'ZB01'.
      wa_detalle-land1     = 'CL'.
      wa_detalle-regio     = '13'.
      wa_detalle-fdgrv     = 'A4' .
      wa_detalle-zterm1    = 'ZC01'.
*      wa_detalle-zgrup     = 'Z1'.
*
      PERFORM lee_proveedor USING    wa_excel-vendor_no
                            CHANGING wa_detalle-vendor_no
                                     wa_detalle-message.
    ELSEIF wa_excel-customer IS NOT INITIAL.
      wa_detalle-ktok      = 'Z001'.
      wa_detalle-land1     = 'CL'.
      wa_detalle-regio     = '13'.
      wa_detalle-fdgrv     = 'A4' .
      wa_detalle-zterm1    = 'ZD01'.
*      wa_detalle-zgrup     = 'Z1'.
*
      PERFORM lee_cliente   USING    wa_excel-customer
                            CHANGING wa_detalle-customer
                                     wa_detalle-message.
    ENDIF.
    MOVE : wa_cabecera-key      TO wa_detalle-key,
           wa_excel-cme         TO wa_detalle-zumsk.
    PERFORM ajusta_texto CHANGING wa_detalle-sgtxt.
*
    APPEND wa_detalle  TO gt_detalle.
  ENDLOOP.
*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: lt_sort     TYPE slis_t_sortinfo_alv,
        lt_fieldcat TYPE slis_t_fieldcat_alv,
        lw_layout   TYPE slis_layout_alv,
        lw_keyinfo  TYPE slis_keyinfo_alv,
        lv_sem      TYPE xflag,
        wa_variant  TYPE disvariant.
*
  IF gt_return[] IS NOT INITIAL.
    lv_sem = gc_x.
  ELSE.
    CLEAR lv_sem.
  ENDIF.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING    lv_sem
                          CHANGING lw_layout.
  PERFORM fieldcat_init   USING    lv_sem
                          CHANGING lt_fieldcat[].
*
  CASE lv_sem.
    WHEN gc_x.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program = gv_repid
          is_layout          = lw_layout
          it_fieldcat        = lt_fieldcat[]
          i_save             = 'A'
        TABLES
          t_outtab           = gt_return
        EXCEPTIONS
          program_error      = 1
          OTHERS             = 2.
    WHEN OTHERS.
      PERFORM sort            TABLES   lt_sort.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program       = gv_repid
          i_callback_pf_status_set = 'PF_STATUS'
          i_callback_user_command  = 'USER_COMMAND'
          is_layout                = lw_layout
          it_fieldcat              = lt_fieldcat[]
          i_save                   = 'A'
          it_sort                  = lt_sort
        TABLES
          t_outtab                 = gt_header[]
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.

*      PERFORM key_info        CHANGING lw_keyinfo.
*      CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
*        EXPORTING
*          i_callback_program       = gv_repid
*          i_callback_pf_status_set = 'PF_STATUS'
*          i_callback_user_command  = 'USER_COMMAND'
*          it_fieldcat              = lt_fieldcat
*          it_sort                  = lt_sort
*          is_layout                = lw_layout
*          i_save                   = 'A'
*          i_tabname_header         = 'GT_HEADER'
*          i_tabname_item           = 'GT_DETALLE'
*          is_keyinfo               = lw_keyinfo
*        TABLES
*          t_outtab_header          = gt_header[]
*          t_outtab_item            = gt_detalle[]
*        EXCEPTIONS
*          program_error            = 1
*          OTHERS                   = 2.
  ENDCASE.
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

  CASE r_ucomm.
    WHEN 'FC01'.
      PERFORM asiento_contable.
      gv_proc = gc_x.
      rs_selfield-refresh      = gc_x.
    WHEN OTHERS.
      CASE rs_selfield-fieldname(5).
        WHEN 'BELNR'.
          IF rs_selfield-value IS NOT INITIAL.
            READ TABLE gt_header INTO DATA(lw_salida) INDEX rs_selfield-tabindex.
            SET PARAMETER ID 'BLN' FIELD rs_selfield-value.
            SET PARAMETER ID 'BUK' FIELD lw_salida-bukrs.
            SET PARAMETER ID 'GJR' FIELD lw_salida-gjahr.
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN .
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA: lt_fcode_attrib_tab TYPE TABLE OF smp_dyntxt,
        lw_fcode_attrib_tab TYPE smp_dyntxt.
*
  IF gv_proc IS INITIAL.
    CLEAR lw_fcode_attrib_tab.
    lw_fcode_attrib_tab-text      = TEXT-ctb.
    lw_fcode_attrib_tab-icon_id   = icon_create.
    lw_fcode_attrib_tab-icon_text = TEXT-ctb.
    lw_fcode_attrib_tab-quickinfo = space.
    lw_fcode_attrib_tab-path      = space.
    APPEND lw_fcode_attrib_tab TO lt_fcode_attrib_tab.
  ENDIF.
**
  PERFORM dynamic_report_fcodes IN PROGRAM rhteiln0
                                          TABLES lt_fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.
*
  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.
ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING p_sem
                 CHANGING p_wa_layout TYPE  slis_layout_alv.
  CLEAR p_wa_layout.
  p_wa_layout-zebra                = gc_x.
  p_wa_layout-colwidth_optimize    = gc_x.
  CHECK p_sem IS INITIAL.
  p_wa_layout-key_hotspot          = gc_x.
  p_wa_layout-expand_fieldname     = 'EXPAND'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SORT
*&---------------------------------------------------------------------*
FORM sort  TABLES   p_lt_sort TYPE slis_t_sortinfo_alv.
  DATA: lw_sort TYPE slis_sortinfo_alv.
*
  CLEAR p_lt_sort[].
  lw_sort-spos       = 1.
  lw_sort-fieldname  = 'KEY'.
  lw_sort-tabname    = 'GT_CABECERA'.
  lw_sort-up         = 'X'.
  APPEND lw_sort TO p_lt_sort.
*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init USING    p_sem
                   CHANGING p_lt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA : lt_fieldcat TYPE slis_t_fieldcat_alv,
         lw_fieldcat TYPE slis_fieldcat_alv,
         lv_num      TYPE numc2.
*
  CASE p_sem.
    WHEN gc_x.
      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = gc_tabla3
        CHANGING
          ct_fieldcat            = p_lt_fieldcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    WHEN OTHERS.
      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = gc_tabla1
        CHANGING
          ct_fieldcat            = lt_fieldcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
*
      CLEAR lw_fieldcat.
      DESCRIBE TABLE lt_fieldcat LINES DATA(lv_lin).
      lv_lin                     = lv_lin + 1.
      lw_fieldcat-col_pos        = lv_lin.
      lw_fieldcat-fieldname      = 'BUKRS'.
      lw_fieldcat-tabname        = 'GT_HEADER'.
      lw_fieldcat-ref_tabname    = 'BKPF'.
      lw_fieldcat-ref_fieldname  = 'BUKRS'.
      APPEND lw_fieldcat TO lt_fieldcat.
*
      lv_lin                     = lv_lin + 1.
      lw_fieldcat-col_pos        = lv_lin.
      lw_fieldcat-fieldname      = 'GJAHR'.
      lw_fieldcat-tabname        = 'GT_HEADER'.
      lw_fieldcat-ref_tabname    = 'BKPF'.
      lw_fieldcat-ref_fieldname  = 'GJAHR'.
      APPEND lw_fieldcat TO lt_fieldcat.

      DO gv_num_docum TIMES.
        ADD 1 TO lv_num.
        lv_lin                     = lv_lin + 1.
        lw_fieldcat-col_pos        = lv_lin.
        lw_fieldcat-fieldname      = 'BELNR' && lv_num.
        lw_fieldcat-tabname        = 'GT_HEADER'.
        lw_fieldcat-ref_tabname    = 'BKPF'.
        lw_fieldcat-ref_fieldname  = 'BELNR'.
        lw_fieldcat-hotspot        = gc_x.
        APPEND lw_fieldcat TO lt_fieldcat.
      ENDDO.
*
      lv_lin                     = lv_lin + 1.
      lw_fieldcat-col_pos        = lv_lin.
      lw_fieldcat-hotspot        = ' '.
      lw_fieldcat-fieldname      = 'MESSAGE'.
      lw_fieldcat-ref_fieldname  = 'MESSAGE'.
      lw_fieldcat-ref_tabname    = 'BAPIRET2'.
      APPEND lw_fieldcat TO lt_fieldcat.
*
      LOOP AT lt_fieldcat INTO lw_fieldcat.
        lw_fieldcat-tabname = 'GT_HEADER'.
        lw_fieldcat-ddictxt = 'M'.
        CASE lw_fieldcat-fieldname.
          WHEN 'OBJ_TYPE'         OR 'OBJ_KEY'    OR 'OBJ_SYS'     OR 'BUS_ACT'     OR 'TRANS_DATE' OR
               'INVOICE_REC_DATE' OR'FISC_YEAR'   OR 'FIS_PERIOD'  OR 'AC_DOC_NO'   OR 'OBJ_KEY_R'  OR
               'REF_DOC_NO_LONG'  OR'COMPO_ACC'   OR  'NEG_POSTNG' OR 'OBJ_KEY_INV' OR
               'BILL_CATEGORY'    OR 'VATDATE'    OR  'ECS_ENV'    OR
               'PARTIAL_REV'      OR 'DOC_STATUS' OR 'REASON_REV'.
            lw_fieldcat-no_out = gc_x.
          WHEN 'GRUPO'.
            lw_fieldcat-seltext_m = 'Grupo'.
          WHEN 'RECARGA'.
            lw_fieldcat-seltext_m = 'Recarga'.
            lw_fieldcat-no_out    = gc_x.
          WHEN 'AREA_CONTAB'.
            lw_fieldcat-seltext_m = 'Area Contable'.
          WHEN 'BELNR1' OR 'BELNR2' OR 'BELNR3' OR 'BELNR4'.
            lw_fieldcat-hotspot   = gc_x.
        ENDCASE.
        APPEND lw_fieldcat TO p_lt_fieldcat.
      ENDLOOP.
**
*      CLEAR lt_fieldcat[].
*      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*        EXPORTING
*          i_structure_name       = gc_tabla2
*        CHANGING
*          ct_fieldcat            = lt_fieldcat
*        EXCEPTIONS
*          inconsistent_interface = 1
*          program_error          = 2
*          OTHERS                 = 3.
*      LOOP AT lt_fieldcat INTO lw_fieldcat.
*        lw_fieldcat-tabname = 'GT_DETALLE'.
*        lw_fieldcat-ddictxt = 'M'.
*        CASE lw_fieldcat-fieldname.
*          WHEN 'FDLEV'      OR 'ALT_PAYEE'  OR 'IVA'    OR 'HKTID' OR 'AUFNR'     OR 'BUKRS'  OR
*               'STCD1_D'    OR 'STCD1_K'    OR 'TITLE'  OR 'SORT1' OR 'SORT2'     OR 'STREET' OR
*               'HOUSE_NUM1' OR 'HOUSE_NUM2' OR 'PSTLZ'  OR 'ORT01' OR 'ORT02'     OR 'LAND1'  OR
*               'REGIO'      OR 'FDGRV'      OR 'ZTERM1' OR 'WITHT' OR 'WT_WITHCD' OR 'BANKS'  OR
*               'BANKL'      OR 'BANKN'      OR 'KOINH'  OR 'ZGRUP'.
*            lw_fieldcat-no_out = gc_x.
*          WHEN 'KEY'.
*            lw_fieldcat-no_out = gc_x.
*          WHEN 'ITEMNO_ACC'.
*            lw_fieldcat-seltext_m = 'Correlativo'.
*        ENDCASE.
*        APPEND lw_fieldcat TO p_lt_fieldcat.
*      ENDLOOP.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  KEY_INFO
*&---------------------------------------------------------------------*
FORM key_info  CHANGING p_lw_keyinfo TYPE slis_keyinfo_alv.


  CLEAR p_lw_keyinfo.
  p_lw_keyinfo-header01 = 'KEY'.
  p_lw_keyinfo-item01   = 'KEY'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ASIENTO_CONTABLE
*&---------------------------------------------------------------------*
FORM asiento_contable .
  DATA : ti_tlogcaberr TYPE TABLE OF ztlogcaberrv3,
         ti_tlogdeterr TYPE TABLE OF ztlogdeterrv3,
         ti_resumen    TYPE TABLE OF zresumenv3,
         ti_cabecera   TYPE TABLE OF zcabecerav3,
         ti_detalle    TYPE TABLE OF zdetallev3,
         ti_return     TYPE TABLE OF bapiret2,
         wa_carga_file TYPE zfi_carga_file,
         lv_num        TYPE numc2,
         lv_campo      TYPE char30,
         lw_return     TYPE bapiret2.
*
  CLEAR gt_return[].
  LOOP AT gt_header INTO wa_cabecera.
    DATA(lv_tabix) = sy-tabix.
    CLEAR : ti_cabecera[], ti_detalle[], ti_tlogcaberr[], ti_tlogdeterr[],
            ti_resumen[], ti_return[].
*
    ti_cabecera[] = VALUE #( FOR ly_detalle IN gt_header
                                  WHERE ( key = wa_cabecera-key )
                                 ( CORRESPONDING #( ly_detalle ) ) ).
    ti_detalle[]  = VALUE #( FOR ly_detalle_pos IN gt_detalle
                                  WHERE ( key = wa_cabecera-key )
                                 ( CORRESPONDING #( ly_detalle_pos ) ) ).
*
    DATA(lv_text) = '(SAPLZFIRFC001_V3)t_error'.
    ASSIGN (lv_text) TO FIELD-SYMBOL(<lv_error>).
    IF sy-subrc EQ 0.
      <lv_error> = 0.
    ENDIF.
*
    CALL FUNCTION 'ZFIRFC001_V3'
      EXPORTING
        i_carga_masiva = gc_x
      TABLES
        ti_cabecera    = ti_cabecera
        ti_detalle     = ti_detalle
        ti_tlogcaberr  = ti_tlogcaberr
        ti_tlogdeterr  = ti_tlogdeterr
        ti_resumen     = ti_resumen
        return         = ti_return.
*
    IF ti_return[] IS NOT INITIAL AND ti_resumen[] IS INITIAL.
      LOOP AT ti_return INTO DATA(lw_reurn) WHERE type EQ 'E'.
        wa_cabecera-message   = |{ lw_reurn-type }-{ lw_reurn-id }-{ lw_reurn-number }-{ lw_reurn-message }|.
        MODIFY gt_header FROM wa_cabecera INDEX lv_tabix.
        EXIT.
      ENDLOOP.
    ELSE.
      LOOP AT ti_tlogcaberr INTO DATA(lw_tlogcaberr).
        wa_cabecera-message   = |{ lw_tlogcaberr-cod_err }-{ lw_tlogcaberr-descripcion }|.
        MODIFY gt_header FROM wa_cabecera INDEX lv_tabix.
        EXIT.
      ENDLOOP.
*
      LOOP AT ti_tlogdeterr INTO DATA(lw_tlogdeterr).
        DATA(lv_index1) = line_index( gt_detalle[ key        = lw_tlogdeterr-key
                                                  itemno_acc = lw_tlogdeterr-posic ] ).
        IF lv_index1 GT 0.
          wa_detalle          = gt_detalle[ lv_index1 ].
          wa_detalle-message  = |{ lw_tlogdeterr-cod_err }-{ lw_tlogdeterr-descripcion }|.
          MODIFY gt_detalle FROM wa_detalle INDEX lv_index1.

          wa_cabecera-message   = wa_detalle-message.
          MODIFY gt_header FROM wa_cabecera INDEX lv_tabix.
        ENDIF.
      ENDLOOP.

      LOOP AT ti_resumen INTO DATA(lw_resumen).
        IF wa_cabecera-belnr01 IS INITIAL.
          wa_cabecera-belnr01 = lw_resumen-n_sap.
          wa_cabecera-gjahr  = wa_cabecera-pstng_date+0(4).
          wa_cabecera-bukrs  = wa_cabecera-comp_code.
        ELSE.
          lv_num = 1.
          DO 10 TIMES.
            ADD 1 TO lv_num.
            lv_campo = 'WA_CABECERA-BELNR' && lv_num.
            ASSIGN (lv_campo) TO FIELD-SYMBOL(<valor>).
            CHECK <valor> IS INITIAL.
            <valor> = lw_resumen-n_sap.
            IF gv_num_docum LT lv_num.
              gv_num_docum = lv_num.
            ENDIF.
            EXIT.
          ENDDO.
        ENDIF.
*
        IF wa_cabecera-message IS INITIAL AND ti_return[] IS NOT INITIAL.
          LOOP AT ti_return INTO lw_reurn WHERE type EQ 'E'.
            wa_cabecera-message   = |{ lw_reurn-type }-{ lw_reurn-id }-{ lw_reurn-number }-{ lw_reurn-message }|.
            EXIT.
          ENDLOOP.
        ENDIF.
*
        MODIFY gt_header FROM wa_cabecera INDEX lv_tabix.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
* si al menos creo un asiento contable graba el archivo.
  LOOP AT gt_header INTO wa_cabecera WHERE belnr01 IS NOT INITIAL.
    wa_carga_file-localfile = gv_file.
    wa_carga_file-uname     = sy-uname.
    wa_carga_file-datum     = sy-datum.
    wa_carga_file-uzeit     = sy-uzeit.
    MODIFY zfi_carga_file FROM wa_carga_file.
    COMMIT WORK AND WAIT.
    gv_proc = gc_x.
    EXIT.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_EXCEPTIONS_MODIFY
*&---------------------------------------------------------------------*
FORM layout_exceptions_modify .
  DATA: ls_layout TYPE slis_layout_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
    IMPORTING
      es_layout     = ls_layout
    EXCEPTIONS
      no_infos      = 1
      program_error = 2
      OTHERS        = 3.

  CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_SET'
    EXPORTING
      is_layout = ls_layout
    EXCEPTIONS
      OTHERS    = 1.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VERIFICA_ARCHIVO
*&---------------------------------------------------------------------*
FORM verifica_archivo  USING  p_p_filepc.
  DATA : lw_carga_file TYPE zfi_carga_file,
         vl_resp       TYPE xflag,
         lv_text       TYPE string,
         lv_name       TYPE string,
         lv_path       TYPE string.
*
  CLEAR gv_ok.
  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = p_p_filepc
    IMPORTING
      stripped_name = lv_name
      file_path     = lv_path
    EXCEPTIONS
      x_error       = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  gv_file = lv_name.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE localfile uname datum uzeit
*         INTO CORRESPONDING FIELDS OF lw_carga_file
*         FROM zfi_carga_file WHERE localfile EQ lv_name.
*
* NEW CODE
  SELECT localfile uname datum uzeit
  UP TO 1 ROWS 
         INTO CORRESPONDING FIELDS OF lw_carga_file
         FROM zfi_carga_file WHERE localfile EQ lv_name ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc EQ 0.
    lv_text = |Procesado por el usuario { lw_carga_file-uname } el día { lw_carga_file-datum DATE = USER }, desea continuar?|.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'ARCHIVO YA PROCESADO'
        text_question         = lv_text
        text_button_1         = 'SI'                      "(001)
        icon_button_1         = 'ICON_CHECKED'
        text_button_2         = 'NO'                      "(002)
        icon_button_2         = 'ICON_INCOMPLETE'
        default_button        = '2'
        display_cancel_button = ''
      IMPORTING
        answer                = vl_resp.
    IF vl_resp = 1.
      gv_ok = gc_x.
    ENDIF.
  ELSE.
    gv_ok = gc_x.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_PROVEEDOR
*&---------------------------------------------------------------------*
FORM lee_proveedor  USING    p_wa_vendor_no
                    CHANGING p_vendor_no
                             p_mensaje.

  CLEAR p_vendor_no.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT  SINGLE lifnr INTO p_vendor_no
*          FROM lfa1 WHERE stcd1 EQ p_wa_vendor_no.
*
* NEW CODE
  SELECT lifnr
  UP TO 1 ROWS  INTO p_vendor_no
          FROM lfa1 WHERE stcd1 EQ p_wa_vendor_no ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CHECK sy-subrc NE 0.
  p_mensaje = |El RUT { p_wa_vendor_no } no encontrado como Acredor|.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_CLIENTE
*&---------------------------------------------------------------------*
FORM lee_cliente  USING    p_wa_customer
                  CHANGING p_customer
                           p_mensaje.
  CLEAR p_customer.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT  SINGLE kunnr INTO p_customer
*          FROM kna1 WHERE stcd1 EQ p_wa_customer.
*
* NEW CODE
  SELECT kunnr
  UP TO 1 ROWS  INTO p_customer
          FROM kna1 WHERE stcd1 EQ p_wa_customer ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CHECK sy-subrc NE 0.
  p_mensaje = |El RUT { p_wa_customer } no encontrado como Cliente|.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FROMATEA_VALOR
*&---------------------------------------------------------------------*
FORM fromatea_valor  USING    p_valor
                     CHANGING p_salida.

  TRANSLATE p_valor USING '. '.
  TRANSLATE p_valor USING ', '.
  CONDENSE  p_valor NO-GAPS.

  p_salida = p_valor.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AJUSTA_TEXTO
*&---------------------------------------------------------------------*
FORM ajusta_texto  CHANGING p_wa_salida_linea.

  CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
    EXPORTING
      intext            = p_wa_salida_linea
    IMPORTING
      outtext           = p_wa_salida_linea
    EXCEPTIONS
      invalid_codepage  = 1
      codepage_mismatch = 2
      internal_error    = 3
      cannot_convert    = 4
      fields_not_type_c = 5
      OTHERS            = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
