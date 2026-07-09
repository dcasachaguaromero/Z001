*&---------------------------------------------------------------------*
*&  Include           ZFICO_REP04_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  AUTORIZACION
*&---------------------------------------------------------------------*
FORM autorizacion .
  AUTHORITY-CHECK OBJECT 'S_TCODE'
    ID 'TCD' FIELD sy-tcode.
  IF sy-subrc <> 0.
    MESSAGE e899(fi) WITH TEXT-e01 sy-tcode.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
CLASS cl_handler IMPLEMENTATION.
  METHOD on_double_click.
    IF column EQ 'BELNR'.
      READ TABLE gt_salida_det INTO DATA(lw_salida) INDEX row.
      SET PARAMETER ID 'BLN' FIELD lw_salida-belnr.
      SET PARAMETER ID 'BUK' FIELD lw_salida-bukrs.
      SET PARAMETER ID 'GJR' FIELD lw_salida-gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  TYPES: BEGIN OF ty_lfa1,
           lifnr TYPE lfa1-lifnr,
           stcd1 TYPE lfa1-stcd1,
         END OF ty_lfa1.
*
  DATA : lt_lfa1   TYPE TABLE OF ty_lfa1,
         lt_meses  TYPE gtt_meses,
         lw_salida TYPE zes_fico_rep04,
         lw_lfa1   TYPE ty_lfa1,
         lw_bseg   TYPE gty_datos,
         lw_meses  TYPE gty_meses,
         lv_lines  TYPE sytabix,
         lv_tabix  TYPE sytabix,
         lv_flag   TYPE char01,
         lv_gjahr  TYPE gjahr,
         lv_monat  TYPE monat,
         lv_mes    TYPE numc2.
*
  CLEAR : gt_salida[], gt_datos[], gt_meses[].
*
  cl_progress_indicator=>progress_indicate(
      i_text = | { TEXT-uno } |
      i_output_immediately = abap_true ).
*
  SELECT bseg~bukrs, bseg~belnr, bseg~gjahr, bseg~buzei, bseg~hkont,
         bseg~wrbtr, bseg~dmbtr, bseg~dmbe3, bseg~kostl, bseg~zzrut_terc,
         bseg~shkzg, bseg~sgtxt, bseg~pswbt,
         bkpf~waers, bkpf~budat, bkpf~hwae3, bkpf~blart,
         t001~waers AS waers_soc
        INTO TABLE @DATA(lt_bseg)
        FROM bseg INNER JOIN bkpf
                 ON bseg~bukrs EQ bkpf~bukrs AND
                    bseg~belnr EQ bkpf~belnr AND
                    bseg~gjahr EQ bkpf~gjahr
                  INNER JOIN t001
                 ON bseg~bukrs EQ t001~bukrs
                 WHERE  bseg~bukrs      IN @s_bukrs
                   AND  bkpf~budat      IN @s_budat
                   AND  bseg~gjahr      IN @s_gjahr
                   AND  bseg~hkont      IN @s_hkont
                   AND  bseg~kostl      IN @s_kostl
                   AND  bseg~zzrut_terc IN @s_stcd1
                   AND  bseg~xbilk      EQ @space.
  CHECK sy-subrc EQ 0.
  DELETE lt_bseg WHERE kostl      IS INITIAL.
*  DELETE lt_bseg WHERE zzrut_terc IS INITIAL.
*
  cl_progress_indicator=>progress_indicate(
      i_text = | { TEXT-dos } |
      i_output_immediately = abap_true ).
*
  LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<ls_data>)
                     GROUP BY ( bukrs      = <ls_data>-bukrs
                                belnr      = <ls_data>-belnr
                                gjahr      = <ls_data>-gjahr
                                kostl      = <ls_data>-kostl
                                hkont      = <ls_data>-hkont
                                zzrut_terc = <ls_data>-zzrut_terc
                                waers      = <ls_data>-waers
                                waers_soc  = <ls_data>-waers_soc
                                budat      = <ls_data>-budat
                                hwae3      = <ls_data>-hwae3
                                blart      = <ls_data>-blart
                                shkzg      = <ls_data>-shkzg
                                sgtxt      = <ls_data>-sgtxt )
                     INTO DATA(ls_datos).
    DATA(ls_comm) = VALUE gty_datos( bukrs      = ls_datos-bukrs
                                     belnr      = ls_datos-belnr
                                     gjahr      = ls_datos-gjahr
                                     kostl      = ls_datos-kostl
                                     hkont      = ls_datos-hkont
                                     zzrut_terc = ls_datos-zzrut_terc
                                     waers      = ls_datos-waers
                                     waers_soc  = ls_datos-waers_soc
                                     budat      = ls_datos-budat
                                     hwae3      = ls_datos-hwae3
                                     blart      = ls_datos-blart
                                     shkzg      = ls_datos-shkzg
                                     sgtxt      = ls_datos-sgtxt
                                     monat      = ls_datos-budat+4(2) ).
    LOOP AT GROUP ls_datos INTO DATA(ls_datos_sum).
      IF ls_datos_sum-shkzg EQ 'H'.
        MULTIPLY ls_datos_sum-wrbtr BY -1.
        MULTIPLY ls_datos_sum-dmbtr BY -1.
        MULTIPLY ls_datos_sum-dmbe3 BY -1.
        MULTIPLY ls_datos_sum-pswbt BY -1.
      ENDIF.
      ADD ls_datos_sum-wrbtr       TO ls_comm-wrbtr.
      ADD ls_datos_sum-dmbtr       TO ls_comm-dmbtr.
      ADD ls_datos_sum-dmbe3       TO ls_comm-dmbe3.
      ADD ls_datos_sum-pswbt       TO ls_comm-pswbt.
    ENDLOOP.
*
    APPEND ls_comm TO gt_datos.
    CLEAR  ls_comm.
  ENDLOOP.
* TEXTOS DE CENTRO DE COSTO
  SELECT DISTINCT kostl, ltext INTO TABLE @DATA(lt_kostl)
         FROM cskt FOR ALL ENTRIES IN @gt_datos
                   WHERE spras EQ @sy-langu
                    AND  kokrs EQ @gc_kokrs
                    AND  kostl EQ @gt_datos-kostl
                    AND  datbi GE @sy-datum.
* TEXTOS DE CUENTA
  SELECT DISTINCT saknr, txt50 INTO TABLE @DATA(lt_hkont)
         FROM skat FOR ALL ENTRIES IN @gt_datos
                   WHERE spras EQ @sy-langu
                    AND  ktopl EQ @gc_ktopl
                    AND  saknr EQ @gt_datos-hkont.
*
  cl_progress_indicator=>progress_indicate(
      i_text = | { TEXT-tre } |
      i_output_immediately = abap_true ).
*
  DATA(lt_datos_p) = gt_datos[].
  SORT lt_datos_p BY zzrut_terc.
  DELETE ADJACENT DUPLICATES FROM lt_datos_p COMPARING zzrut_terc.
*
  IF lt_datos_p IS NOT INITIAL.
    LOOP AT lt_datos_p INTO DATA(lw_datos_p) WHERE zzrut_terc IS NOT INITIAL.
      lw_lfa1-lifnr = |{ lw_datos_p-zzrut_terc ALPHA = IN }|.
      lw_lfa1-stcd1 = lw_datos_p-zzrut_terc.
      APPEND lw_lfa1 TO lt_lfa1.
    ENDLOOP.
*
    IF  lt_lfa1[] IS NOT INITIAL.
      SELECT lifnr, name1, stcd1 INTO TABLE @DATA(lt_lfa1_s)
            FROM lfa1 FOR ALL ENTRIES IN @lt_lfa1
                      WHERE lifnr EQ @lt_lfa1-lifnr OR
                            stcd1 EQ @lt_lfa1-stcd1.
    ENDIF.
  ENDIF.
*
  CHECK gt_datos[] IS NOT INITIAL.
  SORT gt_datos BY gjahr monat.
*
  lw_bseg = gt_datos[ 1 ].
  MOVE-CORRESPONDING lw_bseg TO lw_meses.
  lv_monat = lw_meses-monat.
  lv_gjahr = lw_meses-gjahr.
  DO 24 TIMES.
    ADD 1 TO lv_mes.
    IF lv_monat EQ 13 OR lw_meses-gjahr NE lv_gjahr.
      lw_meses-gjahr = lw_meses-gjahr + 1.
      lv_gjahr       = lw_meses-gjahr.
      lv_monat       = 1.
    ENDIF.
    lw_meses-monat = lv_monat.
    lw_meses-mes   = lv_mes.
    APPEND lw_meses TO gt_meses.
    lv_monat = lv_monat + 1.
  ENDDO.
*
  SORT gt_datos BY bukrs gjahr monat.
  DESCRIBE TABLE gt_datos LINES lv_tabix.
  LOOP AT gt_datos ASSIGNING FIELD-SYMBOL(<campos>).
    DATA(lv_regist) = sy-tabix.
    MOVE-CORRESPONDING <campos> TO lw_bseg.

    AT NEW gjahr.
      MOVE-CORRESPONDING lw_bseg TO lw_meses.
      DATA(lv_index_mes) = line_index( gt_meses[ gjahr = lw_meses-gjahr
                                                 monat = lw_meses-monat ] ).
      IF lv_index_mes GT 0.
        lw_meses = gt_meses[ lv_index_mes ].
      ENDIF.
      COLLECT lw_meses INTO lt_meses.
      lv_flag = gc_x.
    ENDAT.

    AT NEW monat.
      IF lv_flag IS INITIAL.
        MOVE-CORRESPONDING lw_bseg TO lw_meses.
        lv_index_mes = line_index( gt_meses[ gjahr = lw_meses-gjahr
                                             monat = lw_meses-monat ] ).
        IF lv_index_mes GT 0.
          lw_meses = gt_meses[ lv_index_mes ].
        ENDIF.
        COLLECT lw_meses INTO lt_meses.
      ENDIF.
      CLEAR lv_flag.
    ENDAT.
*
    ADD 1 TO lv_lines.
    IF lv_lines EQ 10000.
      cl_progress_indicator=>progress_indicate(
          i_text = |Procesando : { sy-tabix } / { lv_tabix } |
          i_output_immediately = abap_true ).
      lv_lines = 0.
    ENDIF.
*
    CLEAR : lw_salida.
    MOVE : lw_bseg-bukrs      TO lw_salida-bukrs,
           lw_bseg-kostl      TO lw_salida-kostl,
           lw_bseg-hkont      TO lw_salida-hkont.
    " lw_bseg-zzrut_terc TO lw_salida-zzrut_terc.
* TEXTO DEL CECO
    DATA(lv_index) = line_index( lt_kostl[ kostl = lw_bseg-kostl ] ).
    IF lv_index GT 0.
      lw_salida-ltext = lt_kostl[ lv_index ]-ltext.
    ENDIF.
* TEXTO DE LA CUENTA
    lv_index = line_index( lt_hkont[ saknr = lw_bseg-hkont ] ).
    IF lv_index GT 0.
      lw_salida-txt50 = lt_hkont[ lv_index ]-txt50.
    ENDIF.
*
    DATA(lv_campo) = 'LW_SALIDA-MES_' && lw_meses-mes. "lw_bseg-budat+4(2).
    ASSIGN (lv_campo) TO FIELD-SYMBOL(<campo>).
    CASE gc_x.
      WHEN p_docum.
        <campo>         = lw_bseg-wrbtr.
        lw_salida-waers = lw_bseg-waers.
      WHEN p_socie.
        <campo>         = lw_bseg-dmbtr.
        lw_salida-waers = lw_bseg-waers_soc.
      WHEN p_local.
*        <campo>         = lw_bseg-dmbe3.
        <campo>         = lw_bseg-pswbt.
        lw_salida-waers = lw_bseg-hwae3.
    ENDCASE.
*
    lv_index = 0.
    IF lw_bseg-zzrut_terc IS NOT INITIAL.
      lv_index = line_index( lt_lfa1_s[ stcd1 = lw_bseg-zzrut_terc ] ).
      IF lv_index EQ 0.
        lv_index = line_index( lt_lfa1_s[ lifnr = |{ lw_bseg-zzrut_terc ALPHA = IN }| ] ).
      ENDIF.
    ENDIF.
    IF lv_index GT 0.
      DATA(lw_lfa1_s)  = lt_lfa1_s[ lv_index ].
      lw_salida-nombre = lw_lfa1_s-name1.
      lw_salida-lifnr  = lw_lfa1_s-lifnr.
      lw_salida-stcd1  = lw_lfa1_s-stcd1.
    ELSE.
      CLEAR lw_lfa1_s.
      lw_salida-nombre = 'RUT de terceros no encontrado'.
      lw_salida-lifnr  = '9999999999'.
      lw_salida-stcd1  = ''.
    ENDIF.

    COLLECT lw_salida INTO gt_salida.
*
    lw_bseg-lifnr = lw_salida-lifnr.
    lw_bseg-ltext = lw_salida-ltext.
    lw_bseg-txt50 = lw_salida-txt50.
*    lw_bseg-monat = lw_bseg-budat+4(2).
    IF lw_lfa1_s-stcd1 IS NOT INITIAL.
      lw_bseg-stcd1 = lw_lfa1_s-stcd1.
    ELSE.
      lw_bseg-stcd1 = 'Acreedor no Existe'.
    ENDIF.
    MODIFY gt_datos FROM lw_bseg INDEX lv_regist.

  ENDLOOP.
  ASSIGN TABLE FIELD gt_salida TO <tables>.
*
  SORT lt_meses BY gjahr monat.
  DESCRIBE TABLE lt_meses LINES lv_lines.
  lw_meses = lt_meses[ lv_lines ].
  lv_index = line_index( gt_meses[ gjahr = lw_meses-gjahr
                                   monat = lw_meses-monat ] ).
  DELETE gt_meses FROM lv_index + 1.

  cl_progress_indicator=>progress_indicate(
      i_text = | { TEXT-cua } |
      i_output_immediately = abap_true ).
*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DETALLE
*&---------------------------------------------------------------------*
FORM muestra_detalle  USING p_wa_salida TYPE zes_fico_rep04
                            p_year p_mes.
  DATA : lo_gr_alv        TYPE REF TO cl_salv_table,
         lo_columns       TYPE REF TO cl_salv_columns,
         lo_column        TYPE REF TO cl_salv_column_table,
         lo_selections    TYPE REF TO cl_salv_selections,
         lo_event_handler TYPE REF TO cl_handler, " Variables for events
         lo_display       TYPE REF TO cl_salv_display_settings,
         lo_events        TYPE REF TO cl_salv_events_table,
         lo_groups        TYPE REF TO cl_salv_sorts,
         lo_aggregations  TYPE REF TO cl_salv_aggregations,
         lo_layout        TYPE REF TO cl_salv_layout,
         lo_functions     TYPE REF TO cl_salv_functions_list,
         lf_variant       TYPE slis_vari,
         lo_set_key       TYPE salv_s_layout_key,
         lo_set_lay       TYPE slis_vari,
         lr_year          TYPE RANGE OF gjahr,
         lr_monat         TYPE RANGE OF monat,
         lx_msg           TYPE REF TO cx_salv_msg.
*
  CLEAR gt_salida_det[].
*
  IF p_year IS NOT INITIAL.
    lr_year  = VALUE #( sign = 'I' option = 'EQ'
                        ( low  = p_year ) ).
  ENDIF.
  IF p_mes IS NOT INITIAL.
    lr_monat = VALUE #( sign = 'I' option = 'EQ'
                        ( low  = p_mes ) ).
  ENDIF.
*
  gt_salida_det = VALUE #( FOR lw_datos IN gt_datos
                        WHERE ( bukrs      EQ p_wa_salida-bukrs      AND
                                hkont      EQ p_wa_salida-hkont      AND
                                kostl      EQ p_wa_salida-kostl      AND
                                lifnr      EQ p_wa_salida-lifnr      AND
                                "zzrut_terc EQ p_wa_salida-zzrut_terc AND
                                gjahr      IN lr_year                AND
                                monat      IN lr_monat )
                              ( CORRESPONDING #( lw_datos ) ) ).
*
  TRY.
      cl_salv_table=>factory(
      EXPORTING
          list_display = if_salv_c_bool_sap=>false
        IMPORTING
          r_salv_table = lo_gr_alv
        CHANGING
          t_table      = gt_salida_det  ).
* Default functions
      lo_gr_alv->get_functions( )->set_all( if_salv_c_bool_sap=>true ).
      "lo_gr_alv->get_functions( )->set_default( if_salv_c_bool_sap=>true ). "Solamente algunos puls estandard
      lo_gr_alv->get_functions( )->set_view_excel( value = if_salv_c_bool_sap=>false ).
* LAYOUT
      lo_set_key-report = sy-repid.
      lo_set_key-handle = 'DETA'.
      lo_layout         = lo_gr_alv->get_layout( ).
      lo_layout->set_key( value = lo_set_key ).
      lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
      lo_gr_alv->get_layout( )->set_default( if_salv_c_bool_sap=>true ). "Allow layout preset
      "      lo_layout->set_save_restriction( value = if_salv_c_layout=>restrict_none ).
      "lo_layout->set_initial_layout( value = lo_set_lay ).
*   set initial Layout
      lf_variant = 'DEFAULT'.
      lo_layout->set_initial_layout( lf_variant ).
* titulo
      lo_display = lo_gr_alv->get_display_settings( ).
      lo_display->set_list_header( | Acreedor :  { p_wa_salida-lifnr ALPHA = OUT } { p_wa_salida-nombre }  { p_wa_salida-stcd1 }| ).
* Fit the columns
      lo_columns = lo_gr_alv->get_columns( ).
      lo_columns->set_optimize( 'X' ).
* Register events
      lo_events = lo_gr_alv->get_event( ).
      CREATE OBJECT lo_event_handler.
      SET HANDLER lo_event_handler->on_double_click FOR lo_events.
* Enable cell selection mode
      lo_selections = lo_gr_alv->get_selections( ).
      lo_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).
*   Set the HotSpot for BELNR Column
      TRY.
          lo_column ?= lo_columns->get_column( 'BELNR' ).
        CATCH cx_salv_not_found.
      ENDTRY.
*
      TRY.
          CALL METHOD lo_column->set_cell_type
            EXPORTING
              value = if_salv_c_cell_type=>hotspot.
          .
        CATCH cx_salv_data_error .
      ENDTRY.
*
      TRY.
          lo_column ?= lo_columns->get_column( 'WAERS_SOC' ).
          lo_column->set_visible( if_salv_c_bool_sap=>true ).
          lo_column->set_long_text( 'Moneda ML' ).
          lo_column->set_medium_text( 'Moneda ML' ).
          lo_column->set_short_text( 'Moneda ML' ).
*
          lo_column ?= lo_columns->get_column( 'WRBTR' ). "Currency Value
          lo_column->set_currency_column( 'WAERS' ). "Currency Key
          lo_column->set_sign( 'X' ).
*
          lo_column ?= lo_columns->get_column( 'DMBTR' ). "Currency Value
          lo_column->set_currency_column( 'WAERS_SOC' ). "Currency Key
          lo_column->set_sign( 'X' ).
*
          lo_column ?= lo_columns->get_column( 'DMBE3' ). "Currency Value
          lo_column->set_currency_column( 'HWAE3' ). "Currency Key
          lo_column->set_sign( 'X' ).
*
          lo_column ?= lo_columns->get_column( 'PSWBT' ). "Currency Value
          lo_column->set_currency_column( 'HWAE3' ). "Currency Key
          lo_column->set_sign( 'X' ).
**
          lo_column ?= lo_columns->get_column( 'ZZRUT_TERC' ).
          lo_column->set_long_text( 'RUT Terceros' ).
          lo_column->set_medium_text( 'RUT Terceros' ).
          lo_column->set_short_text( 'RUT Terc.' ).
          lo_column->set_visible( if_salv_c_bool_sap=>false ).

          lo_column ?= lo_columns->get_column( 'STCD1' ).
          lo_column->set_long_text( 'RUT Terceros' ).
          lo_column->set_medium_text( 'RUT Terceros' ).
          lo_column->set_short_text( 'RUT Terc.' ).
**
          lo_column ?= lo_columns->get_column( 'SHKZG' ).
          lo_column->set_visible( if_salv_c_bool_sap=>false ).

        CATCH cx_salv_not_found.
        CATCH cx_salv_existing.
        CATCH cx_salv_data_error.
      ENDTRY.
* sort
      lo_groups = lo_gr_alv->get_sorts( ) .
      lo_groups->clear( ).
      TRY.
          lo_groups->add_sort( columnname = 'BUKRS'
                               position   = 1
                               subtotal   = abap_false
                               sequence   = if_salv_c_sort=>sort_up ).

          lo_groups->add_sort( columnname = 'GJAHR'
                               position   = 2
                               subtotal   = abap_false
                               sequence   = if_salv_c_sort=>sort_up ).

          lo_groups->add_sort( columnname = 'KOSTL'
                               position   = 3
                               subtotal   = abap_false
                               sequence   = if_salv_c_sort=>sort_up ).

          lo_groups->add_sort( columnname = 'BUDAT'
                               position   = 4
                               subtotal   = abap_false
                               sequence   = if_salv_c_sort=>sort_up ).

        CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
      ENDTRY.
*
      lo_aggregations = lo_gr_alv->get_aggregations( ).
      TRY.
          lo_aggregations->add_aggregation( columnname = 'WRBTR' ).
          lo_aggregations->add_aggregation( columnname = 'DMBTR' ).
          lo_aggregations->add_aggregation( columnname = 'DMBE3' ).

        CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
      ENDTRY.
*
      lo_gr_alv->display( ).

    CATCH cx_salv_msg INTO lx_msg.
  ENDTRY.

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
  PERFORM fieldcat_init   USING lt_fieldcat[].
  PERFORM sort            USING lt_sort[].
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
      is_variant               = wa_variant
      it_sort_lvc              = lt_sort
      i_save                   = 'A'
    TABLES
      t_outtab                 = <tables>
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
  DATA lw_meses TYPE gty_meses.
*
  CASE rs_selfield-fieldname.
    WHEN 'LIFNR'.
      READ TABLE gt_salida INTO DATA(wa_salida) INDEX rs_selfield-tabindex.
      PERFORM muestra_detalle USING wa_salida '' ''.
    WHEN OTHERS.
      IF rs_selfield-fieldname(4) EQ 'MES_'.
        READ TABLE gt_meses INTO lw_meses WITH KEY mes = rs_selfield-fieldname+4(2).
        READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
        PERFORM muestra_detalle USING wa_salida lw_meses-gjahr lw_meses-monat.
      ENDIF.
*      rs_selfield-refresh = gc_x.
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
*  rs_layout-f2code               = 'DISPLAY'.
  rs_layout-zebra                = gc_x.
  rs_layout-detailinit           = gc_x.
  rs_layout-cwidth_opt           = gc_x.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
  DATA : lw_meses TYPE gty_meses.
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
      WHEN 'BUKRS'.
        <datos>-key       = gc_x.
      WHEN 'HKONT'.
        <datos>-key       = gc_x.
      WHEN 'KOSTL'.
        <datos>-key       = gc_x.
      WHEN 'LIFNR'.
        <datos>-key       = gc_x.
        <datos>-hotspot   = gc_x.
      WHEN 'STCD1'.
        <datos>-scrtext_m = 'RUT Acreedor'.
      WHEN 'NOMBRE'.
        <datos>-scrtext_m = 'Denominación Proveedor	'.
      WHEN 'LTEXT'.
        <datos>-scrtext_m = 'Descripción CeCo'.
      WHEN 'TXT50'.
        <datos>-scrtext_m = 'Descripción Cta.Ctbl.'.
      WHEN 'ZZRUT_TERC' OR 'MONAT'.
        <datos>-tech      = gc_x.
      WHEN OTHERS.
        CASE <datos>-fieldname(4).
          WHEN 'MES_'.
            <datos>-no_zero = gc_x.
            <datos>-do_sum  = gc_x.
            <datos>-hotspot = gc_x.
            DATA(lv_index) = line_index( gt_meses[ mes = <datos>-fieldname+4(2) ] ).
            IF lv_index GT 0.
              lw_meses = gt_meses[ lv_index ].
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE ltx INTO <datos>-scrtext_m
*                FROM t247 WHERE spras EQ sy-langu
*                           AND  mnr   EQ lw_meses-monat.
*
* NEW CODE
              SELECT ltx
              UP TO 1 ROWS  INTO <datos>-scrtext_m
                FROM t247 WHERE spras EQ sy-langu
                           AND  mnr   EQ lw_meses-monat ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              <datos>-scrtext_m = |{ <datos>-scrtext_m }  { lw_meses-gjahr }|.
            ELSE.
              <datos>-tech = gc_x.
            ENDIF.
        ENDCASE.
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
  lw_sort-fieldname = 'BUKRS'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.

  lw_sort-fieldname = 'KOSTL'.
  APPEND lw_sort TO p_lt_sort.

*  lw_sort-fieldname = 'ZZRUT_TERC'.
*  APPEND lw_sort TO p_lt_sort.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDA_FECHAS
*&---------------------------------------------------------------------*
FORM valida_fechas .
  DATA : lv_year  TYPE i,
         lv_month TYPE i.
*
  IF s_budat-high IS INITIAL.
    s_budat-high = s_budat-low.
  ENDIF.
*
  CALL FUNCTION 'HR_SGPBS_YRS_MTHS_DAYS'
    EXPORTING
      beg_da        = s_budat-low
      end_da        = s_budat-high
    IMPORTING
      no_month      = lv_month
      no_year       = lv_year
    EXCEPTIONS
      dateint_error = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE e999(f5) WITH 'Error en rango de Fechas'.
  ELSEIF lv_year EQ 2 AND lv_month GT 0.
    MESSAGE e999(f5) WITH 'Rango de Fecha excede los 24 meses'.
  ENDIF.

ENDFORM.
