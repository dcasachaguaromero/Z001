*&---------------------------------------------------------------------*
*&  Include           ZMM_CONTRATO_ME31K_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LEE_ARCHIVO
*&---------------------------------------------------------------------*
FORM lee_archivo .
  DATA : gt_raw   TYPE truxs_t_text_data,
         lv_meins TYPE meins.
*
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_field_seperator    = abap_true
      i_line_header        = abap_false
      i_tab_raw_data       = gt_raw
      i_filename           = p_file
    TABLES
      i_tab_converted_data = gt_table
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
*
  DELETE gt_table FROM 1 TO p_num.
*
  LOOP AT gt_table ASSIGNING FIELD-SYMBOL(<campos>).
    <campos>-lifnr = |{ <campos>-lifnr ALPHA = IN }|.
    <campos>-matnr = |{ <campos>-matnr ALPHA = IN }|.
*
    SELECT SINGLE lifnr INTO @DATA(lv_lifnr)
           FROM lfa1 WHERE lifnr EQ @<campos>-lifnr.
    IF sy-subrc NE 0.
      <campos>-mensaje = 'Proveedor no existe'.
      CONTINUE.
    ENDIF.
*
    SELECT SINGLE matnr INTO @DATA(lv_matnr)
           FROM mara WHERE matnr EQ @<campos>-matnr.
    IF sy-subrc NE 0.
      <campos>-mensaje = 'Material no existe'.
    ENDIF.
*
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = <campos>-kmein
      IMPORTING
        output         = lv_meins
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      <campos>-mensaje = 'Unidad de medida no existe'.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: lt_fieldcat TYPE lvc_t_fcat,
        lt_sort     TYPE lvc_t_sort,
        wa_layout   TYPE lvc_s_layo.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM sort_init       TABLES lt_sort.
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
      t_outtab                 = gt_table
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
  DATA : lv_getfeld  TYPE  t354s-initfield,
         lv_getvalue TYPE  t354s-initfield.
*
  CASE r_ucomm.
    WHEN 'FC01'.
      PERFORM crear_precios.
    WHEN OTHERS.
      CASE rs_selfield-fieldname.
        WHEN 'EBELN'.
          lv_getfeld  = 'VIQMEL-EBELN3'.
          lv_getvalue = rs_selfield-value.
          CALL FUNCTION 'MASTER_DATA'
            EXPORTING
              datenfeld  = lv_getfeld
              fieldvalue = lv_getvalue.
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
  IF gv_proc IS INITIAL.
    lw_fcode_attrib_tab-text      = TEXT-act.
    lw_fcode_attrib_tab-icon_id   = icon_budget_update.
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
*&      Form  SORT_INIT
*&---------------------------------------------------------------------*
FORM sort_init  TABLES   p_it_sort TYPE lvc_t_sort.
  DATA wa_sort TYPE lvc_s_sort.
*
  CLEAR p_it_sort[].
  wa_sort-fieldname = 'KSCHL'.
  wa_sort-up        = gc_x.
  APPEND wa_sort TO p_it_sort.

ENDFORM.                    " SORT_INIT
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
    CASE <fieldcat>-fieldname.
      WHEN 'KSCHL'.
        <fieldcat>-key       = gc_x.
      WHEN 'KBETR'.
        <fieldcat>-scrtext_m = 'Importe condición'.
      WHEN 'DATAB'.
        <fieldcat>-scrtext_m = 'Valido de'.
      WHEN 'DATBI'.
        <fieldcat>-scrtext_m = 'Fin de validez'.
      WHEN 'KMEIN'.
        <fieldcat>-scrtext_m = 'Unidad medida base'.
    ENDCASE.
**
    <fieldcat>-colddictxt = 'M'.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  crear_precios
*&---------------------------------------------------------------------*
FORM crear_precios .
  DATA : lt_itab     TYPE TABLE OF bdcmsgcoll,
         bdcdata_tab TYPE TABLE OF bdcdata,
         lw_opt      TYPE ctu_params,
         wa_campos   TYPE zes_mek1,
         lv_tabix    TYPE sytabix,
         lv_msg      TYPE bapi_msg.
*
  LOOP AT gt_table INTO wa_campos WHERE kschl IS NOT INITIAL.
    MOVE sy-tabix TO lv_tabix.
    CLEAR bdcdata_tab[].
    bdcdata_tab = VALUE #(
      ( program  = 'SAPMV13A' dynpro   = '0100' dynbegin = 'X' )
      ( fnam     = 'BDC_OKCODE'        fval = '/00'           )
      ( fnam     = 'RV13A-KSCHL'       fval = wa_campos-kschl )
*
      ( program  = 'SAPLV14A' dynpro   = '0100' dynbegin = 'X' )
      ( fnam     = 'BDC_OKCODE'        fval = '=WEIT'         )
      ( fnam     = 'RV130-SELKZ(01)'   fval = ''              )
      ( fnam     = 'RV130-SELKZ(07)'   fval = 'X'             )
*
      ( program  = 'SAPMV13A' dynpro   = '1018' dynbegin = 'X' )
      ( fnam     = 'BDC_OKCODE'        fval = '/00'           )
      ( fnam     = 'KOMG-LIFNR'        fval = wa_campos-lifnr )
      ( fnam     = 'KOMG-MATNR'        fval = wa_campos-matnr )
      ( fnam     = 'KOMG-EKORG'        fval = wa_campos-ekorg )
*
      ( program  = 'SAPMV13A' dynpro   = '1018' dynbegin = 'X' )
      ( fnam     = 'BDC_OKCODE'        fval = '/00'           )
      ( fnam     = 'KOMG-ESOKZ(01)'    fval = wa_campos-esokz )
      ( fnam     = 'KONP-KBETR(01)'    fval = wa_campos-kbetr )
      ( fnam     = 'KONP-KPEIN(01)'    fval = wa_campos-kpein )
      ( fnam     = 'KONP-KONWA(01)'    fval = wa_campos-waers )
      ( fnam     = 'KONP-KMEIN(01)'    fval = wa_campos-kmein )
      ( fnam     = 'RV13A-DATAB(01)'   fval = wa_campos-datab )
      ( fnam     = 'RV13A-DATBI(01)'   fval = wa_campos-datbi )
*
      ( program  = 'SAPMV13A' dynpro   = '1018' dynbegin = 'X' )
      ( fnam     = 'BDC_OKCODE'        fval = '=SICH'         )
       ).
*
    lw_opt-dismode = p_mode.
    lw_opt-defsize = 'X'.

    TRY.
        CLEAR lt_itab[].
        CALL TRANSACTION 'MEK1' WITH AUTHORITY-CHECK
                                USING bdcdata_tab OPTIONS FROM lw_opt
                                MESSAGES INTO lt_itab.

        READ TABLE lt_itab WITH KEY msgtyp = 'E' TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
          LOOP AT lt_itab INTO DATA(lw_itab) WHERE  msgtyp = 'E'.
            MESSAGE ID lw_itab-msgid TYPE lw_itab-msgtyp NUMBER lw_itab-msgnr
                    WITH lw_itab-msgv1 lw_itab-msgv2 lw_itab-msgv3 lw_itab-msgv4
                         INTO lv_msg.
          ENDLOOP.
          wa_campos-mensaje = lv_msg.
        ELSE.
          LOOP AT lt_itab INTO lw_itab WHERE msgtyp EQ 'S'
                                        AND  msgnr  EQ '023'.
            MESSAGE ID lw_itab-msgid TYPE lw_itab-msgtyp NUMBER lw_itab-msgnr
             WITH lw_itab-msgv1 lw_itab-msgv2 lw_itab-msgv3 lw_itab-msgv4
             INTO lv_msg.
          ENDLOOP.
          wa_campos-mensaje = lv_msg.
        ENDIF.

      CATCH cx_sy_authorization_error ##NO_HANDLER.
    ENDTRY.
    MODIFY gt_table FROM wa_campos INDEX lv_tabix.
  ENDLOOP.
*

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUSQUEDA_ARCHIVO
*&---------------------------------------------------------------------*
FORM busqueda_archivo CHANGING archivo TYPE localfile.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = ' '
      def_path         = 'c:\'
      mask             = ',*.XLS.'
      mode             = 'O'
      title            = 'Archivo a importar'
    IMPORTING
      filename         = archivo
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.
ENDFORM.
