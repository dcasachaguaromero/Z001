*&---------------------------------------------------------------------*
*&  Include           ZFI_COMPENSA_INTERCOMPANY_F01
*&---------------------------------------------------------------------*

CLASS lcl_report IMPLEMENTATION.
  METHOD get_data.
    CONSTANTS: c_h TYPE c VALUE 'H'.
***Buscamos las partidas en ambas sociedades y verificamos
    SELECT bukrs, belnr, gjahr, buzei, kunnr, umskz,
           zuonr, budat, bldat, wrbtr, waers, shkzg
      INTO TABLE @DATA(ti_bsid)
      FROM bsid
      WHERE ( bukrs = @p_soc1 OR bukrs = @p_soc2 )
        AND kunnr IN @s_kunnr
        AND umskz IN @s_umskz
        AND zuonr IN @s_zuonr.
    IF sy-subrc <> 0.
      MESSAGE i398(00) WITH TEXT-e01 space space space.
    ELSE.
      READ TABLE ti_bsid INTO DATA(wa_bsid) WITH KEY bukrs = p_soc1.
      IF sy-subrc <> 0.
        MESSAGE i398(00) WITH TEXT-e02 p_soc1 space space.
        REFRESH ti_data.
      ELSE.
        READ TABLE ti_bsid INTO wa_bsid WITH KEY bukrs = p_soc2.
        IF sy-subrc <> 0.
          MESSAGE i398(00) WITH TEXT-e02 p_soc2 space space.
          REFRESH ti_data.
        ELSE.
          LOOP AT ti_bsid ASSIGNING FIELD-SYMBOL(<fs>).
            CLEAR wa_data.
            MOVE-CORRESPONDING <fs> TO wa_data.
            CONCATENATE <fs>-kunnr
                        <fs>-umskz
                        <fs>-zuonr
                        INTO wa_data-llave SEPARATED BY '-'.
            IF <fs>-shkzg = c_h.
              wa_data-wrbtr = <fs>-wrbtr * -1.
            ENDIF.
            APPEND wa_data TO ti_data.

**Agrupamos en esta tabla auxiliar para ver si el saldo es 0.
            MOVE-CORRESPONDING wa_data TO wa_aux.
            COLLECT wa_aux INTO ti_aux.
          ENDLOOP.

          SORT ti_data BY llave.
          SORT ti_aux BY llave.
          me->compensar( ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD compensar.
    CONSTANTS: c_c     TYPE c VALUE 'C',
               c_d     TYPE c VALUE 'D',
               c_s     TYPE c VALUE 'S',
               c_e     TYPE c VALUE 'E',
               c_k     TYPE c VALUE 'K',
               c_1     TYPE c VALUE '1',
               c_zv    TYPE blart VALUE 'ZV',
               c_texto TYPE bktxt VALUE 'Compensación Intercompany'.

    DATA: lv_mode  TYPE c VALUE 'N',
          lv_fecha TYPE char10,
          lv_flag  TYPE c,
          lv_subrc TYPE sy-subrc.

    DATA: ti_blntab   TYPE TABLE OF blntab,
          wa_blntab   TYPE blntab,
          ti_ftclear  TYPE TABLE OF ftclear,
          wa_ftclear  TYPE ftclear,
          ti_ftpost   TYPE TABLE OF ftpost,
          ti_fttax    TYPE TABLE OF fttax,
          wa_data_aux TYPE ty_data,
          wa_msg      TYPE bapiret2.

    FIELD-SYMBOLS: <fs_data> TYPE ty_data.

    CONCATENATE p_augdt+6(2) p_augdt+4(2) p_augdt(4)
    INTO lv_fecha.

    LOOP AT ti_data ASSIGNING <fs_data> WHERE augbl IS INITIAL
                                          AND message IS INITIAL.
**Verificamos que el saldo sea 0
      READ TABLE ti_aux INTO wa_aux WITH KEY llave = <fs_data>-llave
      BINARY SEARCH.
      IF sy-subrc = 0 AND NOT wa_aux-wrbtr IS INITIAL.
        <fs_data>-message = TEXT-e03. "Saldo distinto de cero
        MODIFY ti_data FROM <fs_data> TRANSPORTING message
        WHERE llave = wa_aux-llave.
      ELSE.
        MOVE-CORRESPONDING <fs_data> TO wa_data_aux.
        AT NEW llave.
          REFRESH: ti_blntab, ti_ftclear, ti_ftpost, ti_fttax.
          CALL FUNCTION 'POSTING_INTERFACE_START'
            EXPORTING
              i_client           = sy-mandt
              i_function         = c_c
              i_mode             = lv_mode
              i_update           = c_s
              i_user             = sy-uname
            EXCEPTIONS
              client_incorrect   = 1
              function_invalid   = 2
              group_name_missing = 3
              mode_invalid       = 4
              update_invalid     = 5
              OTHERS             = 6.

          PERFORM  fill_ftpost TABLES ti_ftpost
                             USING: c_k c_1 'BKPF-BUKRS'  wa_data_aux-bukrs,       " Sociedad
                                    c_k c_1 'BKPF-BLDAT'  lv_fecha,      " Fecha doc.,
                                    c_k c_1 'BKPF-BUDAT'  lv_fecha,      " Fecha Contab.
                                    c_k c_1 'BKPF-MONAT'  p_augdt+4(2),  " Mes
                                    c_k c_1 'BKPF-XBLNR'  wa_data_aux-zuonr,  " Doc. Ref.
                                    c_k c_1 'BKPF-BLART'  c_zv,          " Clase Doc.
                                    c_k c_1 'BKPF-BKTXT'  c_texto,       " Texto cabecera
                                    c_k c_1 'RF05A-AUGTX' c_texto,       " TExto compensación
                                    c_k c_1 'BKPF-WAERS'  wa_data_aux-waers.  " Moneda
        ENDAT.

***Criterio de partida abierta
        wa_ftclear-agbuk = <fs_data>-bukrs.   "Sociedad
        wa_ftclear-agkoa = c_d.               "D = Deudor
        wa_ftclear-agkon = <fs_data>-kunnr.   "Cliente
        wa_ftclear-xnops = c_x.               "¿Sel.sólo PAs no oper.CME?
        wa_ftclear-xfifo = space.             "Reparto automático vencim.
        wa_ftclear-agums = <fs_data>-umskz.   "Oper. CME a sel.
        wa_ftclear-avsid = space.             "Nº aviso
        wa_ftclear-selfd = 'BELNR'.           "Documento 'BELNR'
        CONCATENATE <fs_data>-belnr <fs_data>-gjahr <fs_data>-buzei
        INTO wa_ftclear-selvon.   "Documento
        APPEND  wa_ftclear TO ti_ftclear.

        AT END OF llave.
          CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
            EXPORTING
              i_auglv                    = 'UMBUCHNG'
              i_tcode                    = 'FB05'
              i_sgfunct                  = ' '
              i_no_auth                  = c_x
            IMPORTING
              e_msgid                    = wa_msg-id
              e_msgno                    = wa_msg-number
              e_msgty                    = wa_msg-type
              e_msgv1                    = wa_msg-message_v1
              e_msgv2                    = wa_msg-message_v2
              e_msgv3                    = wa_msg-message_v3
              e_msgv4                    = wa_msg-message_v4
              e_subrc                    = lv_subrc
            TABLES
              t_blntab                   = ti_blntab    " N° documento Contabil.
              t_ftclear                  = ti_ftclear   " Criterio de Sel. de PAs
              t_ftpost                   = ti_ftpost    " Cabecera y Pos. de Comp
              t_fttax                    = ti_fttax     " Pos. de Impuestos
            EXCEPTIONS
              clearing_procedure_invalid = 1
              clearing_procedure_missing = 2
              table_t041a_empty          = 3
              transaction_code_invalid   = 4
              amount_format_error        = 5
              too_many_line_items        = 6
              company_code_invalid       = 7
              screen_not_found           = 8
              no_authorization           = 9
              OTHERS                     = 10.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            INTO <fs_data>-message.

            MODIFY ti_data FROM <fs_data> TRANSPORTING message
            WHERE llave = wa_aux-llave.
          ELSE.
            IF NOT ti_blntab[] IS INITIAL.
              LOOP AT ti_blntab INTO wa_blntab WHERE NOT belnr IS INITIAL.
                <fs_data>-augbl = wa_blntab-belnr.
                <fs_data>-augdt = p_augdt.
                MODIFY ti_data FROM <fs_data> TRANSPORTING augbl augdt
                WHERE llave = <fs_data>-llave.
                EXIT.
              ENDLOOP.
            ELSE.
              MESSAGE ID wa_msg-id TYPE wa_msg-type NUMBER wa_msg-number
              WITH wa_msg-message_v1 wa_msg-message_v2 wa_msg-message_v3 wa_msg-message_v4
              INTO <fs_data>-message.

              MODIFY ti_data FROM <fs_data> TRANSPORTING message
              WHERE llave = wa_aux-llave.
            ENDIF.
          ENDIF.

          CALL FUNCTION 'POSTING_INTERFACE_END'
            EXPORTING
              i_bdcimmed = c_x.
        ENDAT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD generate_out.
    DATA: lx_msg   TYPE REF TO cx_salv_msg,
          lv_lines TYPE i,
          lv_cant  TYPE char10.

    IF NOT ti_data[] IS INITIAL.
      DESCRIBE TABLE ti_data LINES lv_lines.
      WRITE lv_lines TO lv_cant.
      CONDENSE lv_cant.
      MESSAGE s398(00) WITH 'Se visualizan' lv_cant 'partidas' space.
      TRY.
          cl_salv_table=>factory(
            IMPORTING
              r_salv_table = o_alv_r
            CHANGING
              t_table      = ti_data  ).
        CATCH cx_salv_msg INTO lx_msg.
      ENDTRY.

      CALL METHOD set_pf_status
        CHANGING
          co_alv = o_alv_r.

      CALL METHOD me->set_columns
        CHANGING
          co_alv = o_alv_r.

      CALL METHOD set_aggregations
        CHANGING
          co_alv = o_alv_r.

      CALL METHOD set_display_setting
        CHANGING
          co_alv = o_alv_r.

      o_alv_r->display( ).

    ENDIF.
  ENDMETHOD.                    "GET_dATA

  METHOD set_aggregations.

    DATA: lo_aggrs TYPE REF TO cl_salv_aggregations,
          lo_sort  TYPE REF TO cl_salv_sorts.
*
    lo_sort = co_alv->get_sorts( ).
    lo_aggrs = co_alv->get_aggregations( ).

*    TRY.
*        CALL METHOD lo_sort->add_sort
*          EXPORTING
*            columnname = 'BUKRS'
*            sequence   = if_salv_c_sort=>sort_up
*            position   = 1
*            subtotal   = if_salv_c_bool_sap=>true.
*
*      CATCH cx_salv_not_found .                         "#EC NO_HANDLER
*      CATCH cx_salv_existing .                          "#EC NO_HANDLER
*      CATCH cx_salv_data_error .                        "#EC NO_HANDLER
*    ENDTRY.

    TRY.
        CALL METHOD lo_sort->add_sort
          EXPORTING
            columnname = 'KUNNR'
            sequence   = if_salv_c_sort=>sort_up
            position   = 1
            subtotal   = if_salv_c_bool_sap=>true.

      CATCH cx_salv_not_found .                         "#EC NO_HANDLER
      CATCH cx_salv_existing .                          "#EC NO_HANDLER
      CATCH cx_salv_data_error .                        "#EC NO_HANDLER
    ENDTRY.

    TRY.
        CALL METHOD lo_sort->add_sort
          EXPORTING
            columnname = 'UMSKZ'
            sequence   = if_salv_c_sort=>sort_up
            position   = 2
            subtotal   = if_salv_c_bool_sap=>true.

      CATCH cx_salv_not_found .                         "#EC NO_HANDLER
      CATCH cx_salv_existing .                          "#EC NO_HANDLER
      CATCH cx_salv_data_error .                        "#EC NO_HANDLER
    ENDTRY.

    TRY.
        CALL METHOD lo_sort->add_sort
          EXPORTING
            columnname = 'ZUONR'
            sequence   = if_salv_c_sort=>sort_up
            position   = 3
            subtotal   = if_salv_c_bool_sap=>true.

      CATCH cx_salv_not_found .                         "#EC NO_HANDLER
      CATCH cx_salv_existing .                          "#EC NO_HANDLER
      CATCH cx_salv_data_error .                        "#EC NO_HANDLER
    ENDTRY.

    TRY.
        CALL METHOD lo_aggrs->add_aggregation
          EXPORTING
            columnname  = 'WRBTR'
            aggregation = if_salv_c_aggregation=>total.

      CATCH cx_salv_data_error .                        "#EC NO_HANDLER
      CATCH cx_salv_not_found .                         "#EC NO_HANDLER
      CATCH cx_salv_existing .                          "#EC NO_HANDLER
    ENDTRY.

  ENDMETHOD.

  METHOD on_link_click.
    READ TABLE ti_data INTO DATA(wa_data) INDEX row.
    IF column = 'BELNR' AND NOT wa_data-belnr IS INITIAL.
** Call Transaction
      SET PARAMETER ID 'BLN' FIELD wa_data-belnr.
      SET PARAMETER ID 'BUK' FIELD wa_data-bukrs .
      SET PARAMETER ID 'GJR' FIELD wa_data-gjahr .
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN .
    ELSEIF column = 'AUGBL' AND NOT wa_data-augbl IS INITIAL.
      SET PARAMETER ID 'BLN' FIELD wa_data-augbl.
      SET PARAMETER ID 'BUK' FIELD wa_data-bukrs .
      SET PARAMETER ID 'GJR' FIELD wa_data-augdt(4).
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN .
    ENDIF.
  ENDMETHOD.

  METHOD set_pf_status.
*
    DATA: lo_functions TYPE REF TO cl_salv_functions_list.
    DATA: lt_func_list TYPE salv_t_ui_func,
          la_func_list LIKE LINE OF lt_func_list.

    co_alv->set_screen_status(
      pfstatus      =  'STANDARD'
      report        =  'SAPLSALV'
      set_functions = co_alv->c_functions_all ).

  ENDMETHOD.                    "set_pf_status

  METHOD set_columns.
    DATA : lo_layout TYPE REF TO cl_salv_layout,
           ls_key    TYPE salv_s_layout_key.
    DATA : lr_columns TYPE REF TO cl_salv_columns_table. "columns instance
    DATA : lr_column TYPE REF TO cl_salv_column_table. "column instance


    DATA:
      lv_text_l TYPE scrtext_l,
      lv_text_m TYPE scrtext_m,
      lv_text_s TYPE scrtext_s.

    lr_columns = co_alv->get_columns( ).
    lr_columns->set_optimize( c_x ).

    lo_layout = co_alv->get_layout( ).
    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
    ls_key-report = sy-repid.
    lo_layout->set_key( ls_key ).

    TRY.
        lr_column ?= lr_columns->get_column( 'LLAVE' ).
        lr_column->set_visible( space ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_column ?= lr_columns->get_column( 'BELNR' ).
        lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
        lr_column->set_zero( if_salv_c_bool_sap=>false ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_column ?= lr_columns->get_column( 'AUGBL' ).
        lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
        lr_column->set_zero( if_salv_c_bool_sap=>false ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_column ?= lr_columns->get_column( 'WRBTR' ).
        lr_column->set_currency_column( 'WAERS' ).
        lr_column->set_zero( if_salv_c_bool_sap=>false ).
      CATCH cx_salv_data_error.
      CATCH cx_salv_not_found.
    ENDTRY.

*...Events
    DATA: lo_events     TYPE REF TO cl_salv_events_table.
*   All events
    lo_events = co_alv->get_event( ).

*   Event handler
    SET HANDLER me->on_link_click FOR lo_events.
*    SET HANDLER on_user_command FOR lo_events.

  ENDMETHOD.

  METHOD set_display_setting.
    DATA: lo_display TYPE REF TO cl_salv_display_settings.
    lo_display = co_alv->get_display_settings( ).
    lo_display->set_striped_pattern( c_x ).
    lo_display->set_list_header( sy-title ).
  ENDMETHOD.                    "SET_DISPLAY_SETTING

ENDCLASS.

FORM fill_ftpost TABLES ti_ftpost STRUCTURE ftpost
                 USING p_stype
                       p_count
                       p_fnam
                       p_fval.

  DATA: wa_ftpost  TYPE ftpost.
  CHECK p_fval IS NOT INITIAL.
  CLEAR: wa_ftpost.
  wa_ftpost-stype = p_stype.
  wa_ftpost-count = p_count.
  wa_ftpost-fnam  = p_fnam.
  wa_ftpost-fval  = p_fval.
  APPEND wa_ftpost TO ti_ftpost.
ENDFORM. "fill_FTPOST
