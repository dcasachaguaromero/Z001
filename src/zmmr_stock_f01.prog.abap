*&---------------------------------------------------------------------*
*&  Include           ZMMR_STOCK_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  DATA : lt_alv_list TYPE TABLE OF ty_bestand,
         lr_atnam    TYPE RANGE OF cabn-atnam.
*
  PERFORM lee_mb52 TABLES lt_alv_list.
  CHECK lt_alv_list[] IS NOT INITIAL.
* LEE LAS CARACTERISTICAS
  lr_atnam = VALUE #( sign = 'I' option = 'EQ'
                      ( low = 'LOTE_MARCA' )
                      ( low = 'LOTE_FABRICANTE' )
                      ( low = 'LOTE_NUMERO_SERIE' ) ).

  SELECT atinn, adzhl, atnam INTO TABLE @gt_cabn
         FROM cabn WHERE atnam IN @lr_atnam.
  IF sy-subrc EQ 0.
    gr_atinn = VALUE #( FOR lw_cabn IN gt_cabn
                           ( sign = 'I' option = 'EQ'
                             low  = lw_cabn-atinn ) ).
  ENDIF.
*
  LOOP AT lt_alv_list INTO DATA(lw_alv_list).
    CLEAR wa_salida.
    MOVE: lw_alv_list-matnr TO wa_salida-matnr,
          lw_alv_list-maktx TO wa_salida-maktx,
          lw_alv_list-werks TO wa_salida-werks,
          lw_alv_list-lgort TO wa_salida-lgort,
          lw_alv_list-charg TO wa_salida-charg,
          lw_alv_list-labst TO wa_salida-labst,
          lw_alv_list-meins TO wa_salida-meins,
          lw_alv_list-wlabs TO wa_salida-salk3,
          lw_alv_list-waers TO wa_salida-waers.
*
    PERFORM datos_comerciales CHANGING wa_salida.
*
    PERFORM lee_clasificacion CHANGING wa_salida.
*
    CHECK wa_salida-licha      IN s_licha AND
          wa_salida-marca      IN s_marca AND
          wa_salida-fabricante IN s_fabri AND
          wa_salida-serie      IN s_serie.
*
    APPEND wa_salida TO gt_salida.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: lt_sort       TYPE lvc_t_sort,
        lt_fieldcat   TYPE lvc_t_fcat,
        wa_layout     TYPE lvc_s_layo,
        wa_variant    TYPE disvariant,
        lv_grid_title TYPE  lvc_title.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM fieldcat_init   USING lt_fieldcat[].
  PERFORM sort            USING lt_sort[].
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_grid_title             = lv_grid_title
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
      is_variant               = wa_variant
*     it_sort_lvc              = lt_sort
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

  CASE rs_selfield-fieldname.
    WHEN 'SEMAFORO'.
      CHECK sy-tcode EQ 'Z_A_OB52'.
      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA: fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE,
        l_procesado      TYPE char50.
*
  CLEAR: fcode_attrib_tab, fcode_attrib_tab[].
*
  PERFORM dynamic_report_fcodes(rhteiln0) TABLES fcode_attrib_tab
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
*
  rs_layout-zebra                = gc_x.
  rs_layout-detailinit           = gc_x.
  rs_layout-cwidth_opt           = gc_x.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
  DATA : lv_tabla TYPE char30.
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
  LOOP AT p_gt_fieldcat ASSIGNING FIELD-SYMBOL(<datos>).
*
    CASE <datos>-fieldname.
      WHEN 'MARCA'.
        <datos>-scrtext_m = 'Marca'.
      WHEN 'FABRICANTE' .
        <datos>-scrtext_m = 'Fabricante'.
      WHEN 'SERIE'.
        <datos>-scrtext_m = 'Serie'.
      WHEN 'LWEDT'.
        <datos>-scrtext_m = 'Fecha Vencimeinto'.
      WHEN 'SALK3'.
        <datos>-scrtext_m = 'Valor libre util.'.
    ENDCASE.
    <datos>-colddictxt = 'M'.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SORT
*&---------------------------------------------------------------------*
FORM sort  USING    p_lt_sort TYPE lvc_t_sort.
  DATA lw_sort TYPE lvc_s_sort.
*
  CLEAR p_lt_sort[].
  lw_sort-fieldname = 'MATNR'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.

  lw_sort-fieldname = 'WERKS'.
  APPEND lw_sort TO p_lt_sort.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_MB52
*&---------------------------------------------------------------------*
FORM lee_mb52  TABLES ti_alv_list TYPE ty_t_bestand.
  DATA : lt_s_type_metadata TYPE ty_type_metadata,
         lt_pay_data        TYPE REF TO data,
         lw_alv_list        TYPE ty_bestand.
  FIELD-SYMBOLS : <fs_pay_t_data> TYPE ANY TABLE,
                  <fs_pay_data>   TYPE any.
*
  CLEAR ti_alv_list[].
* prepara el ambiente para la rececpcion de datos
  cl_salv_bs_runtime_info=>set( EXPORTING display  = abap_false
                                          metadata = abap_true
                                          data     = abap_true ).
* REALIZADA LA LLAMADA AL REPORTE
  SUBMIT rm07mlbs
           WITH matnr    IN s_matnr
           WITH werks    IN s_werks
           WITH lgort    IN s_lgort
           WITH charg    IN s_charg
           WITH matart   IN s_mtart
           WITH pa_sond  EQ 'X'
           WITH seneg    EQ pt_seneg
           WITH xmchb    EQ pt_xmchb
           WITH nozero   EQ pt_noze
           WITH novalues EQ pt_noval
           AND RETURN.
* revisa el resultado del proceso
  TRY.
* OBTIENE LAYOUT Y CATALOGO
      CALL METHOD cl_salv_bs_runtime_info=>get_metadata
        RECEIVING
          value = lt_s_type_metadata.
* OBTIENE LAYOUT Y CATALOGO
      CALL METHOD cl_salv_bs_runtime_info=>get_metadata
        RECEIVING
          value = lt_s_type_metadata.
* OBTIENE LOS DATOS DEL REPORTE
      cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = lt_pay_data ).
      IF lt_pay_data IS NOT INITIAL.
        ASSIGN lt_pay_data->* TO <fs_pay_t_data>.
        IF <fs_pay_t_data> IS ASSIGNED.
          LOOP AT <fs_pay_t_data> ASSIGNING <fs_pay_data>.
            MOVE-CORRESPONDING <fs_pay_data> TO lw_alv_list.
            APPEND lw_alv_list TO ti_alv_list.
          ENDLOOP.
        ENDIF.
      ENDIF.
    CATCH cx_salv_bs_sc_runtime_info.
      MESSAGE TEXT-e02 TYPE 'E'.
  ENDTRY.
  cl_salv_bs_runtime_info=>clear_all( ).
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_CLASIFICACION
*&---------------------------------------------------------------------*
FORM lee_clasificacion  CHANGING p_wa_salida  TYPE zes_stock_lote.
  DATA : lv_class_type    TYPE tcla-klart VALUE '023',
         lv_table         TYPE tcla-obtab VALUE 'MCH1',
         lv_mafid         TYPE ausp-mafid VALUE 'O',
         lv_object_id     TYPE kssk-objek,
         lv_object_number TYPE inob-cuobj.
*
  CHECK p_wa_salida-matnr IS NOT INITIAL AND p_wa_salida-charg IS NOT INITIAL.

  CONCATENATE p_wa_salida-matnr p_wa_salida-charg INTO lv_object_id.
  CALL FUNCTION 'CUOB_GET_NUMBER'
    EXPORTING
      class_type       = lv_class_type
      object_id        = lv_object_id
      table            = lv_table
    IMPORTING
      object_number    = lv_object_number
    EXCEPTIONS
      lock_problem     = 1
      object_not_found = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  SELECT objek, atinn, atzhl, mafid, klart, adzhl, atwrt
        INTO TABLE @DATA(lt_ausp)
        FROM ausp WHERE objek EQ @lv_object_number
                   AND  atinn IN @gr_atinn
                   AND  mafid EQ @lv_mafid
                   AND  klart EQ @lv_class_type.
  LOOP AT lt_ausp INTO DATA(lw_ausp).
    DATA(lv_index) = line_index( gt_cabn[ atinn = lw_ausp-atinn ] ).
    CHECK lv_index GT 0.
    DATA(lw_cabn) = gt_cabn[ lv_index ].
    CASE lw_cabn-atnam.
      WHEN 'LOTE_MARCA'.        p_wa_salida-marca       = lw_ausp-atwrt.
      WHEN 'LOTE_FABRICANTE' .  p_wa_salida-fabricante  = lw_ausp-atwrt.
      WHEN 'LOTE_NUMERO_SERIE'. p_wa_salida-serie       = lw_ausp-atwrt.
    ENDCASE.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DATOS_COMERCIALES
*&---------------------------------------------------------------------*
FORM datos_comerciales  CHANGING p_wa_salida  TYPE zes_stock_lote.

  CLEAR : p_wa_salida-licha, p_wa_salida-lwedt.
  SELECT SINGLE licha, lwedt INTO @DATA(lw_mch1)
         FROM mch1 WHERE matnr EQ @p_wa_salida-matnr
                    AND  charg EQ @p_wa_salida-charg.
  CHECK sy-subrc EQ 0.
  p_wa_salida-licha = lw_mch1-licha.
  p_wa_salida-lwedt = lw_mch1-lwedt.

ENDFORM.
