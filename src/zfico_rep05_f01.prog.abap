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
*
CLASS lcl_report IMPLEMENTATION.

*
  METHOD lee_datos.
*
    cl_progress_indicator=>progress_indicate(
        i_text = | { TEXT-uno } |
        i_output_immediately = abap_true ).
*
* BUSCA LAS SOCIEDADES QUE SE AGRUPARAN EN EL REPORTE
    SELECT clave nombre bukrs INTO TABLE gt_rep05
           FROM zfico_rep05 WHERE bukrs NE space
                                 ORDER BY clave.
    CHECK sy-subrc EQ 0.
    LOOP AT gt_rep05 INTO DATA(lw_rep05).
      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
             ID 'BUKRS' FIELD lw_rep05-bukrs
             ID 'ACTVT' FIELD '03'.    "Visualizar
      CHECK sy-subrc NE 0.
      DELETE gt_rep05 INDEX sy-tabix.
    ENDLOOP.
    CHECK  gt_rep05[] IS NOT INITIAL.
    lr_bukrs = VALUE #( FOR lw_bukrs IN gt_rep05
                        ( sign = 'I'             option = 'EQ'
                          low  = lw_bukrs-bukrs ) ).
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
                   WHERE  bseg~bukrs      IN @lr_bukrs
                     AND  bkpf~budat      IN @s_budat
                     AND  bseg~gjahr      IN @s_gjahr
                     AND  bseg~hkont      IN @s_hkont
                     AND  bseg~kostl      IN @s_kostl
                     AND  bseg~zzrut_terc IN @s_stcd1
*                     AND  bseg~zzrut_terc NE @space
                     AND  bseg~kostl      NE @space
                     AND  bseg~xbilk      EQ @space.
    CHECK sy-subrc EQ 0.
    cl_progress_indicator=>progress_indicate(
        i_text = | { TEXT-dos } |
        i_output_immediately = abap_true ).

* TEXTO DEL CECO
    DATA(lt_tabla) = lt_bseg[].
    SORT lt_tabla BY kostl.
    DELETE ADJACENT DUPLICATES FROM lt_tabla COMPARING kostl.
    IF lt_tabla[] IS NOT INITIAL.
      SELECT DISTINCT kostl, ltext INTO TABLE @DATA(lt_kostl)
             FROM cskt FOR ALL ENTRIES IN @lt_tabla
                       WHERE spras EQ @sy-langu
                        AND  kokrs EQ @gc_kokrs
                        AND  kostl EQ @lt_tabla-kostl
                        AND  datbi GE @sy-datum.
    ENDIF.
* TEXTOS DE CUENTA
    lt_tabla[] = lt_bseg[].
    SORT lt_tabla BY hkont.
    DELETE lt_tabla WHERE hkont IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM lt_tabla COMPARING hkont.
    IF lt_tabla[] IS NOT INITIAL.
      SELECT DISTINCT saknr, txt50 INTO TABLE @DATA(lt_hkont)
             FROM skat FOR ALL ENTRIES IN @lt_tabla
                       WHERE spras EQ @sy-langu
                        AND  ktopl EQ @gc_ktopl
                        AND  saknr EQ @lt_tabla-hkont.
    ENDIF.
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
                                       zzrut_terc = |{ ls_datos-zzrut_terc ALPHA = IN }|
                                       waers      = ls_datos-waers
                                       waers_soc  = ls_datos-waers_soc
                                       budat      = ls_datos-budat
                                       hwae3      = ls_datos-hwae3
                                       blart      = ls_datos-blart
                                       shkzg      = ls_datos-shkzg
                                       sgtxt      = ls_datos-sgtxt ).
* TEXTO DEL CECO
      IF line_exists( lt_kostl[ kostl = ls_comm-kostl ] ).
        ls_comm-ltext = lt_kostl[ kostl = ls_comm-kostl ]-ltext.
      ENDIF.
* TEXTO DE LA CUENTA
      IF line_exists( lt_hkont[ saknr = ls_comm-hkont ] ).
        ls_comm-txt50 = lt_hkont[ saknr = ls_comm-hkont ]-txt50.
      ENDIF.

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
      APPEND ls_comm TO co_data_out.
      CLEAR  ls_comm.
    ENDLOOP.
    SORT co_data_out BY zzrut_terc.
**
  ENDMETHOD.

  METHOD lee_acreedor.
    TYPES: BEGIN OF ty_lfa1,
             lifnr TYPE lfa1-lifnr,
             stcd1 TYPE lfa1-stcd1,
           END OF ty_lfa1.
    DATA : lt_lfa1   TYPE TABLE OF ty_lfa1,
           lw_lfa1   TYPE ty_lfa1,
           lw_lfa1_s TYPE gty_lfa1.
*
    cl_progress_indicator=>progress_indicate(
        i_text = | { TEXT-pro } |
        i_output_immediately = abap_true ).
*
    DATA(lt_datos_p) = co_data_in[].
    SORT lt_datos_p BY zzrut_terc.
    DELETE ADJACENT DUPLICATES FROM lt_datos_p COMPARING zzrut_terc.
*
    IF lt_datos_p IS NOT INITIAL.
      LOOP AT lt_datos_p INTO DATA(lw_datos_p) WHERE zzrut_terc IS NOT INITIAL.
        lw_lfa1-lifnr = lw_datos_p-zzrut_terc.
        lw_lfa1-stcd1 = lw_datos_p-zzrut_terc.
        APPEND lw_lfa1 TO lt_lfa1.
      ENDLOOP.
*
      IF lt_lfa1[] IS NOT INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT stcd1 lifnr name1 stcd1  INTO TABLE co_lfa1_out
*              FROM lfa1 FOR ALL ENTRIES IN lt_lfa1
*                        WHERE stcd1 EQ lt_lfa1-stcd1.
*
* NEW CODE
        SELECT stcd1 lifnr name1 stcd1
  INTO TABLE co_lfa1_out
              FROM lfa1 FOR ALL ENTRIES IN lt_lfa1
                        WHERE stcd1 EQ lt_lfa1-stcd1 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT lifnr lifnr name1 stcd1  APPENDING TABLE co_lfa1_out
*             FROM lfa1 FOR ALL ENTRIES IN lt_lfa1
*                       WHERE lifnr EQ lt_lfa1-lifnr.
*
* NEW CODE
        SELECT lifnr lifnr name1 stcd1  APPENDING TABLE co_lfa1_out

             FROM lfa1 FOR ALL ENTRIES IN lt_lfa1
                       WHERE lifnr EQ lt_lfa1-lifnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      ENDIF.
*
      IF co_lfa1_out[] IS NOT INITIAL.
        SORT co_lfa1_out BY zzrut_terc.
        DELETE ADJACENT DUPLICATES FROM co_lfa1_out COMPARING zzrut_terc.
      ELSE.
        APPEND lw_lfa1_s TO co_lfa1_out.  " PARA QUE TENGA 1 REG. AL MENOS.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD acumula_datos.
    DATA : lv_index      TYPE syindex,
           lv_lines      TYPE sytabix,
           lv_lifnr      TYPE lifnr,
           lv_name1      TYPE name1,
           lv_stcd1      TYPE stcd1,
           lv_zzrut_terc TYPE zzrut_terc.
*
    cl_progress_indicator=>progress_indicate(
        i_text = | { TEXT-cua } |
        i_output_immediately = abap_true ).
*
    DESCRIBE TABLE co_lfa1_in LINES lv_lines.
    lv_index = 1.
    LOOP AT co_data_in ASSIGNING FIELD-SYMBOL(<ls_dato>)
                       GROUP BY ( bukrs      = <ls_dato>-bukrs
                                  gjahr      = <ls_dato>-gjahr
                                  hkont      = <ls_dato>-hkont
                                  txt50      = <ls_dato>-txt50
                                  kostl      = <ls_dato>-kostl
                                  ltext      = <ls_dato>-ltext
                                  zzrut_terc = <ls_dato>-zzrut_terc
                                  waers      = <ls_dato>-waers
                                  waers_soc  = <ls_dato>-waers_soc
                                  hwae3      = <ls_dato>-hwae3 )
                       INTO DATA(ls_datas).
      DATA(ls_comm2) = VALUE gty_datos_res( clave      = gt_rep05[ bukrs = ls_datas-bukrs ]-clave
                                            gjahr      = ls_datas-gjahr
                                            hkont      = ls_datas-hkont
                                            txt50      = ls_datas-txt50
                                            kostl      = ls_datas-kostl
                                            ltext      = ls_datas-ltext
                                            zzrut_terc = ls_datas-zzrut_terc ).
      CASE gc_x.
        WHEN p_local.
          ls_comm2-waers = ls_datas-hwae3.
        WHEN p_docum.
          ls_comm2-waers = ls_datas-waers.
        WHEN p_socie.
          ls_comm2-waers = ls_datas-waers_soc.
      ENDCASE.
*
      IF lv_zzrut_terc NE ls_comm2-zzrut_terc.
        lv_zzrut_terc = ls_comm2-zzrut_terc.
        CLEAR : lv_lifnr, lv_name1.
        IF co_lfa1_in[ lv_index ]-zzrut_terc = ls_comm2-zzrut_terc.
          lv_lifnr = ls_comm2-lifnr  = co_lfa1_in[ lv_index ]-lifnr.
          lv_name1 = ls_comm2-nombre = co_lfa1_in[ lv_index ]-name1.
          lv_stcd1 = ls_comm2-nombre = co_lfa1_in[ lv_index ]-stcd1.
*
          ls_comm2-lifnr  = lv_lifnr.
          ls_comm2-nombre = lv_name1.
          IF lv_stcd1 IS NOT INITIAL.
            ls_comm2-stcd1  = lv_stcd1 .
          ELSE.
            ls_comm2-nombre = 'Acreedor no Existe'.
          ENDIF.
*
          ADD 1 TO lv_index.
          IF lv_index GT lv_lines.
            lv_index = lv_lines.
          ENDIF.
        ELSE.
          ls_comm2-nombre     = |Acreedor no Existe : { ls_comm2-zzrut_terc } |.
        ENDIF.
      ELSEIF lv_lifnr IS NOT INITIAL.
        ls_comm2-lifnr  = lv_lifnr.
        ls_comm2-nombre = lv_name1.
        IF lv_stcd1 IS NOT INITIAL.
          ls_comm2-stcd1 = lv_stcd1 .
        ELSE.
          ls_comm2-nombre = 'Acreedor no Existe'.
        ENDIF.
      ELSE.
        ls_comm2-nombre     = 'Acreedor no Existe'.
      ENDIF.
*
      LOOP AT GROUP ls_datas INTO DATA(ls_datas_sum).
        DATA(lv_campo) = 'LS_COMM2-BUKRS_' && ls_comm2-clave.
        ASSIGN (lv_campo) TO FIELD-SYMBOL(<campo>).
        CASE gc_x.
          WHEN p_local.
            "ADD ls_datas_sum-dmbe3     TO  <campo>.
            ADD ls_datas_sum-pswbt     TO  <campo>.
          WHEN p_docum.
            ADD ls_datas_sum-wrbtr     TO  <campo>.
          WHEN p_socie.
            ADD ls_datas_sum-dmbtr     TO  <campo>.
        ENDCASE.
      ENDLOOP.
*
      COLLECT ls_comm2 INTO co_data_res.
      CLEAR  ls_comm2.
    ENDLOOP.
    DELETE co_data_res WHERE clave EQ 0.
  ENDMETHOD.

  METHOD genera_salida.
*
    cl_progress_indicator=>progress_indicate(
        i_text = | { TEXT-tre } |
        i_output_immediately = abap_true ).
*
    co_salida = VALUE #( FOR lw_bseg1 IN co_data_in
                         ( CORRESPONDING #( lw_bseg1  ) ) ).

*    co_salida = VALUE #( FOR lw_bseg1 IN co_data_in
*                           LET lv_terc = lw_bseg1-stcd1
*                           IN ( VALUE #( BASE CORRESPONDING #( lw_bseg1  )
*                                        zzrut_terc = lv_terc ) ) ).
*
  ENDMETHOD.
ENDCLASS.
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  DATA : lt_lfa1  TYPE gtt_lfa1,
         lt_datos TYPE gtt_datos_res,
         lt_kostl TYPE gtt_kostl,
         lt_hkont TYPE gtt_hkont.
*
  CLEAR : gt_salida[], gt_datos[], gt_rep05[].
*
  CREATE OBJECT lo_report.
  lo_report->lee_datos( CHANGING co_data_out  = gt_datos ).
  IF gt_datos[] IS NOT INITIAL.
    lo_report->lee_acreedor( EXPORTING co_data_in  = gt_datos
                             CHANGING  co_lfa1_out     = lt_lfa1 ).

    lo_report->acumula_datos( EXPORTING co_data_in   = gt_datos
                                        co_lfa1_in   = lt_lfa1
                              CHANGING  co_data_res  = lt_datos ).

    lo_report->genera_salida( EXPORTING co_data_in   = lt_datos
                              CHANGING  co_salida    = gt_salida ).

    ASSIGN TABLE FIELD gt_salida TO <tables>.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DETALLE
*&---------------------------------------------------------------------*
FORM muestra_detalle  USING    p_wa_salida TYPE zes_fico_rep05.
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
         lo_set_key       TYPE salv_s_layout_key,
         lo_set_lay       TYPE slis_vari,
         lx_msg           TYPE REF TO cx_salv_msg.
*
  CLEAR gt_salida_det[].
  gt_salida_det = VALUE #( FOR lw_datos IN gt_datos
                        WHERE ( hkont      EQ p_wa_salida-hkont AND
                                kostl      EQ p_wa_salida-kostl AND
                                zzrut_terc EQ p_wa_salida-zzrut_terc )
                              ( CORRESPONDING #( lw_datos ) ) ).
  CHECK gt_salida[] IS NOT INITIAL.
*
  TRY.
      cl_salv_table=>factory(
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
      lo_layout->set_save_restriction( value = if_salv_c_layout=>restrict_none ).
      lo_gr_alv->get_layout( )->set_default( if_salv_c_bool_sap=>true ). "Allow layout preset
      "lo_layout->set_initial_layout( value = lo_set_lay ).
* titulo
      DATA(lv_grupo) = gt_rep05[ bukrs = gt_salida_det[ 1 ]-bukrs ]-nombre.
      lo_display = lo_gr_alv->get_display_settings( ).
      lo_display->set_list_header( | Rut : { p_wa_salida-zzrut_terc } { p_wa_salida-nombre } ,Grupo : { lv_grupo } | ).
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

  CASE rs_selfield-fieldname.
    WHEN 'ZZRUT_TERC' OR 'STCD1'.
      READ TABLE gt_salida INTO DATA(wa_salida) INDEX rs_selfield-tabindex.
      PERFORM muestra_detalle USING wa_salida.
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
      WHEN 'STCD1'.
        <datos>-key       = gc_x.
        <datos>-hotspot   = gc_x.
        <datos>-scrtext_m = 'RUT de Terceros'.
      WHEN 'ZZRUT_TERC'.
        <datos>-tech = gc_x.
      WHEN 'NOMBRE'.
        <datos>-scrtext_m = 'Denominación Proveedor	'.
      WHEN 'CLAVE' OR 'DMBTR' OR 'WRBTR' OR 'WAERS_SOC'.
        <datos>-tech = gc_x.
      WHEN OTHERS.
        CASE <datos>-fieldname(6).
          WHEN 'BUKRS_'.
            <datos>-no_zero = gc_x.
            <datos>-do_sum  = gc_x.
            DATA(lv_index) = line_index( gt_rep05[ clave = <datos>-fieldname+6(2) ] ).
            IF lv_index GT 0.
              <datos>-scrtext_m = gt_rep05[ lv_index ]-nombre.
              <datos>-outputlen = 15.
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
  lw_sort-fieldname = 'STCD1'. "'ZZRUT_TERC'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.

  lw_sort-fieldname = 'LIFNR'.
  APPEND lw_sort TO p_lt_sort.

*  lw_sort-fieldname = 'NOMBRE'.
*  APPEND lw_sort TO p_lt_sort.

  lw_sort-fieldname = 'KOSTL'.
  APPEND lw_sort TO p_lt_sort.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TABLA_PARAM
*&---------------------------------------------------------------------*
FORM tabla_param .
  DATA: lv_viewname TYPE vim_name VALUE 'ZFICO_REP05',
        lv_action   TYPE char01   VALUE 'S'.
*
  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action         = lv_action
      view_name      = lv_viewname
    EXCEPTIONS
      foreign_lock   = 2
      no_tvdir_entry = 8.


ENDFORM.
