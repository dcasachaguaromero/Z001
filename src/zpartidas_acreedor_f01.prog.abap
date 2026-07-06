*&---------------------------------------------------------------------*
*&  Include           ZPARTIDAS_ACREEDOR_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  select_data
*&---------------------------------------------------------------------*
* §1 to display the data, you first have to select it in some table
*----------------------------------------------------------------------*
FORM select_data.
* ini Waldo Alarcón - Visionone - 20-12-2024
  TYPES : BEGIN OF ty_lifnr,
            lifnr TYPE lifnr,
            bvtyp TYPE bvtyp,
          END OF ty_lifnr.
  DATA: lt_lifnr TYPE TABLE OF ty_lifnr.
* fin Waldo Alarcón - Visionone - 20-12-2024

*  Validacion de fecha de contabilizacion y periodo.
  IF s_monat IS NOT INITIAL.
    LOOP AT s_monat.
      IF s_augdt IS NOT INITIAL.
        LOOP AT s_augdt.
          IF s_augdt-low IS NOT INITIAL AND s_augdt-low+4(2) <> s_monat-low.
            MESSAGE 'El periodo contable es diferente a la fecha de compensación' TYPE 'E'.
          ENDIF.
          IF s_augdt-high IS NOT INITIAL AND s_augdt-high+4(2) <> s_monat-high.
            MESSAGE 'El periodo contable es diferente a la fecha de compensación' TYPE 'E'.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF s_budat IS NOT INITIAL.
        LOOP AT s_budat.
          IF s_budat-low IS NOT INITIAL AND s_budat-low+4(2) <> s_monat-low.
            MESSAGE 'El periodo contable es diferente a la fecha de contabilización' TYPE 'E'.
          ENDIF.
          IF s_budat-high IS NOT INITIAL AND s_budat-high+4(2) <> s_monat-high.
            MESSAGE 'El periodo contable es diferente a la fecha de contabilización' TYPE 'E'.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.


  IF p_op1 = 'X'. " Partidas Compensadas
*PYV 02/01/2011 Se ordena Select segun indices existentes
*    REFRESH gt_bsak.
*    SELECT * FROM bsak
*      INTO CORRESPONDING FIELDS OF TABLE gt_bsak
*      WHERE bukrs  = p_bukrs AND
*            lifnr IN s_lifnr AND
*            augdt IN s_augdt AND
*            augbl IN s_augbl AND
*            zuonr IN s_zuonr AND
*            gjahr IN s_gjahr AND
*            belnr IN s_belnr AND
*            budat IN s_budat AND
*            waers IN s_waers AND
*            xblnr IN s_xblnr AND
*            blart IN s_blart AND
*            monat IN s_monat ORDER BY lifnr.

    REFRESH gt_bsak.
    SELECT * FROM bsak
      INTO CORRESPONDING FIELDS OF TABLE gt_bsak
      WHERE lifnr IN s_lifnr AND
            bukrs  = p_bukrs AND
            augdt IN s_augdt AND
            augbl IN s_augbl AND
            gjahr IN s_gjahr AND
            belnr IN s_belnr AND
            zuonr IN s_zuonr AND
            budat IN s_budat AND
            waers IN s_waers AND
            xblnr IN s_xblnr AND
            blart IN s_blart AND
            monat IN s_monat AND
            hkont IN s_hkont ORDER BY lifnr.
*PYV 02/01/2011 Se ordena Select segun indices existentes

  ELSEIF p_op2 = 'X'. " Partidas Pendientes
*PYV 02/01/2011 Se ordena Select segun indices existentes
*    REFRESH gt_bsak.
*    SELECT * FROM bsik INTO CORRESPONDING FIELDS OF TABLE gt_bsak
*      WHERE bukrs  = p_bukrs AND
*            lifnr IN s_lifnr AND
*            augdt IN s_augdt AND
*            augbl IN s_augbl AND
*            zuonr IN s_zuonr AND
*            gjahr IN s_gjahr AND
*            belnr IN s_belnr AND
*            budat IN s_budat AND
*            waers IN s_waers AND
*            xblnr IN s_xblnr AND
*            blart IN s_blart AND
*            monat IN s_monat and
*            hkont in s_hkont ORDER BY lifnr.

    REFRESH gt_bsak.
    SELECT * FROM bsik INTO CORRESPONDING FIELDS OF TABLE gt_bsak
      WHERE lifnr IN s_lifnr AND
            bukrs  = p_bukrs AND
            gjahr IN s_gjahr AND
            belnr IN s_belnr AND
            augdt IN s_augdt AND
            augbl IN s_augbl AND
            zuonr IN s_zuonr AND
            budat IN s_budat AND
            waers IN s_waers AND
            xblnr IN s_xblnr AND
            blart IN s_blart AND
            monat IN s_monat AND
            hkont IN s_hkont ORDER BY lifnr.
*PYV 02/01/2011 Se ordena Select segun indices existentes

  ELSEIF p_op3 = 'X'. " Todas las partidas
*PYV 02/01/2011 Se ordena Select segun indices existentes

*    REFRESH gt_bsak.
*    SELECT * FROM bsak
*      INTO CORRESPONDING FIELDS OF TABLE gt_bsak
*      WHERE bukrs  = p_bukrs AND
*            lifnr IN s_lifnr AND
*            augdt IN s_augdt AND
*            augbl IN s_augbl AND
*            zuonr IN s_zuonr AND
*            gjahr IN s_gjahr AND
*            belnr IN s_belnr AND
*            budat IN s_budat AND
*            waers IN s_waers AND
*            xblnr IN s_xblnr AND
*            blart IN s_blart AND
*            monat IN s_monat and
*            hkont in s_hkont ORDER BY lifnr.
*
*    SELECT * FROM bsik APPENDING TABLE gt_bsak
*    WHERE bukrs  = p_bukrs AND
*          lifnr IN s_lifnr AND
*          augdt IN s_augdt AND
*          augbl IN s_augbl AND
*          zuonr IN s_zuonr AND
*          gjahr IN s_gjahr AND
*          belnr IN s_belnr AND
*          budat IN s_budat AND
*          waers IN s_waers AND
*          xblnr IN s_xblnr AND
*          blart IN s_blart AND
*          monat IN s_monat and
*          hkont in s_hkont ORDER BY lifnr.

    REFRESH gt_bsak.
    SELECT * FROM bsak
      INTO CORRESPONDING FIELDS OF TABLE gt_bsak
      WHERE lifnr IN s_lifnr AND
            bukrs  = p_bukrs AND
            augdt IN s_augdt AND
            augbl IN s_augbl AND
            gjahr IN s_gjahr AND
            belnr IN s_belnr AND
            zuonr IN s_zuonr AND
            budat IN s_budat AND
            waers IN s_waers AND
            xblnr IN s_xblnr AND
            blart IN s_blart AND
            monat IN s_monat AND
            hkont IN s_hkont ORDER BY lifnr.

    SELECT * FROM bsik APPENDING TABLE gt_bsak
    WHERE lifnr IN s_lifnr AND
          bukrs  = p_bukrs AND
          gjahr IN s_gjahr AND
          belnr IN s_belnr AND
          augdt IN s_augdt AND
          augbl IN s_augbl AND
          zuonr IN s_zuonr AND
          budat IN s_budat AND
          waers IN s_waers AND
          xblnr IN s_xblnr AND
          blart IN s_blart AND
          monat IN s_monat AND
          hkont IN s_hkont ORDER BY lifnr.

*PYV 02/01/2011 Se ordena Select segun indices existentes
  ENDIF.

* ini Waldo Alarcón - Visionone - 20-12-2024
  lt_lifnr = VALUE #( FOR ly_detalle IN gt_bsak
                                        WHERE ( lifnr NE space )
                                        ( CORRESPONDING #( ly_detalle ) ) ).
  SORT lt_lifnr BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_lifnr COMPARING ALL FIELDS.
  IF lt_lifnr[] IS NOT INITIAL.
    SELECT lifnr, banks, bankl, bankn, bvtyp INTO TABLE @DATA(lt_lfbk)
           FROM lfbk FOR ALL ENTRIES IN @lt_lifnr
                      WHERE lifnr EQ @lt_lifnr-lifnr
                       AND  bvtyp EQ @lt_lifnr-bvtyp.
  ENDIF.
* fin Waldo Alarcón - Visionone - 20-12-2024

  REFRESH gt_outtab.

  LOOP AT gt_bsak.
    CLEAR gr_outtab.
    MOVE-CORRESPONDING gt_bsak TO gr_outtab.
    gr_outtab-monto1 = gr_outtab-dmbtr.
*V1 INI 25-10-2024
    IF gr_outtab-qsskz = 'XX'.
      gr_outtab-qbshb  = gr_outtab-qsshb - gr_outtab-wrbtr.
    ENDIF.
*V1 FIN 25-10-2024
    IF gr_outtab-shkzg = 'H'.
      MULTIPLY gr_outtab-dmbtr BY -1.
      MULTIPLY gr_outtab-monto1 BY -1.
    ENDIF.

    SELECT SINGLE  name1 stcd1 FROM lfa1 INTO (gr_outtab-name1, gr_outtab-stcd1)
      WHERE lifnr EQ gt_bsak-lifnr.

    IF gr_outtab-augbl IS NOT INITIAL.
*PYV 02/01/2011 Se ordena Select segun indices existentes
*      SELECT SINGLE znme1 rwbtr checf FROM payr INTO (gr_outtab-znme1, gr_outtab-rwbtr, gr_outtab-checf)
*        WHERE hbkid EQ gt_bsak-hbkid AND
*              hktid EQ gt_bsak-hktid AND
*              zbukr EQ gt_bsak-bukrs AND
*              vblnr EQ gt_bsak-augbl AND
*              voidr EQ ''.
*PYV 02/01/2011 Se ordena Select segun indices existentes
*** INI V1 RVY 19-022024
      IF gr_outtab-zlsch = 'C'.
        SELECT SINGLE znme1 rwbtr checf FROM payr INTO
                     (gr_outtab-znme1, gr_outtab-rwbtr, gr_outtab-checf)
          WHERE zbukr EQ gt_bsak-bukrs AND
                hbkid EQ gt_bsak-hbkid AND
                hktid EQ gt_bsak-hktid AND
                vblnr EQ gt_bsak-augbl AND
                voidr EQ ''.
      ELSE.
        SELECT SINGLE znme1 rwbtr FROM reguh INTO
                    (gr_outtab-znme1, gr_outtab-rwbtr)
           WHERE zbukr EQ gt_bsak-bukrs AND
                 vblnr EQ gt_bsak-augbl AND
                 zaldt EQ gt_bsak-augdt.
      ENDIF.
*** FIN V1 RVY 19-022024
    ENDIF.

    IF NOT  gt_bsak-xref2 IS INITIAL.
      SELECT MAX( identif_pago )  INTO gr_outtab-identif_pago
                                FROM reguh
                                WHERE zbukr = gt_bsak-bukrs
                                AND   vblnr = gt_bsak-xref2
                                AND   zaldt <= gt_bsak-budat
                                AND   lifnr  = gt_bsak-lifnr.

    ENDIF.

* ini Waldo Alarcón - Visionone - 20-12-2024
    DATA(lv_index) = line_index( lt_lfbk[ lifnr = gt_bsak-lifnr
                                          bvtyp = gt_bsak-bvtyp ] ).
    IF lv_index GT 0.
      gr_outtab-bankl = lt_lfbk[ lv_index ]-bankl.
      gr_outtab-bankn = lt_lfbk[ lv_index ]-bankn.
    ENDIF.
* fin Waldo Alarcón - Visionone - 20-12-2024

    APPEND gr_outtab TO gt_outtab.
  ENDLOOP.


ENDFORM.                    " select_data
*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column,

      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.                    "lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_double_click.

*    DATA: bdcdata_wa  TYPE bdcdata,
*          bdcdata_tab TYPE TABLE OF bdcdata.
*
*    DATA opt TYPE ctu_params.
*
*    READ TABLE gt_outtab INTO gs_outtab INDEX row.

  ENDMETHOD.                    "on_double_click

  METHOD on_user_command.

* Get the selection rows
*    DATA: lr_selections TYPE REF TO cl_salv_selections.
*    DATA: lt_rows   TYPE salv_t_row.
*    DATA: ls_rows   TYPE i.
*    DATA: message TYPE string.
*
*    CASE e_salv_function.
*      WHEN 'MYFUNCTION'.
*
*        lr_selections = gr_table->get_selections( ).
*        lt_rows = lr_selections->get_selected_rows( ).
*    ENDCASE.

  ENDMETHOD.                    "on_user_command

  METHOD on_link_click.

    DATA: bdcdata_wa  TYPE bdcdata,
          bdcdata_tab TYPE TABLE OF bdcdata.

    DATA opt TYPE ctu_params.

    READ TABLE gt_outtab INTO gr_outtab INDEX row.

    SET PARAMETER ID: 'BLN' FIELD gr_outtab-belnr,
                      'BUK' FIELD gr_outtab-bukrs,
                      'GJR' FIELD gr_outtab-gjahr.

    IF column NE 'CHECF'.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    ELSE.
      CLEAR bdcdata_wa.
      bdcdata_wa-program  = 'SAPMFCHK'.
      bdcdata_wa-dynpro   = '100'.
      bdcdata_wa-dynbegin = 'X'.
      APPEND bdcdata_wa TO bdcdata_tab.

      CLEAR bdcdata_wa.
      bdcdata_wa-fnam = 'PAYR-ZBUKR'.
      bdcdata_wa-fval = gr_outtab-bukrs.
      APPEND bdcdata_wa TO bdcdata_tab.
      CLEAR bdcdata_wa.
      bdcdata_wa-fnam = 'PAYR-HBKID'.
      bdcdata_wa-fval = gr_outtab-hbkid.
      APPEND bdcdata_wa TO bdcdata_tab.
      CLEAR bdcdata_wa.
      bdcdata_wa-fnam = 'PAYR-HKTID'.
      bdcdata_wa-fval = gr_outtab-hktid.
      APPEND bdcdata_wa TO bdcdata_tab.
      CLEAR bdcdata_wa.
      bdcdata_wa-fnam = 'PAYR-CHECT'.
      bdcdata_wa-fval = gr_outtab-checf.
      APPEND bdcdata_wa TO bdcdata_tab.

      opt-dismode = 'E'.
      opt-defsize = 'X'.

      CALL TRANSACTION 'FCH1' USING bdcdata_tab OPTIONS FROM opt.
    ENDIF.
  ENDMETHOD. "on_link_click

  "on_double_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION
*&---------------------------------------------------------------------*
*&      Form  display_fullscreen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_fullscreen .


*... §2 create an ALV table
*    §2.2 just create an instance and do not set LIST_DISPLAY for
*         displaying the data as a Fullscreen Grid
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = gr_table
        CHANGING
          t_table      = gt_outtab ).
    CATCH cx_salv_msg.                                  "#EC NO_HANDLER
  ENDTRY.

*... §3 Functions
*... §3.1 activate ALV generic Functions
  DATA: lr_functions TYPE REF TO cl_salv_functions_list.

  DATA: lo_header  TYPE REF TO cl_salv_form_layout_grid,
        lo_h_label TYPE REF TO cl_salv_form_label,
        lo_h_flow  TYPE REF TO cl_salv_form_layout_flow,
        gr_layout  TYPE REF TO cl_salv_layout,
        lr_events  TYPE REF TO cl_salv_events_table,
        key        TYPE salv_s_layout_key,
        l_text     TYPE string,
        lr_columns TYPE REF TO cl_salv_columns,
        lr_column  TYPE REF TO cl_salv_column_table.

*   To create a Lable or Flow we have to specify the target
*     row and column number where we need to set up the output
*     text.
*   header object
  CREATE OBJECT lo_header.
*   information in Bold
  CONCATENATE g_address_value-name1 ''
    INTO l_text SEPARATED BY space.
  lo_h_label = lo_header->create_label( row = 1 column = 1 ).
  lo_h_label->set_text( l_text ).

*   information in tabular format
  lo_h_flow = lo_header->create_flow( row = 3  column = 1 ).
  lo_h_flow->create_text( text = 'Fecha:' ).

  CONCATENATE sy-datum+6 sy-datum+4(2) sy-datum(4) INTO l_text SEPARATED BY '/'.
  CONDENSE l_text.
  lo_h_flow = lo_header->create_flow( row = 3  column = 2 ).
  lo_h_flow->create_text( text = l_text ).

  lo_h_flow = lo_header->create_flow( row = 4  column = 1 ).
  lo_h_flow->create_text( text = 'Hora:' ).

  CONCATENATE sy-timlo(2) sy-timlo+2(2) sy-timlo+4(2) INTO l_text SEPARATED BY ':'.
  CONDENSE l_text.
  lo_h_flow = lo_header->create_flow( row = 4  column = 2 ).
  lo_h_flow->create_text( text = l_text ).

  lo_h_flow = lo_header->create_flow( row = 5  column = 1 ).
  lo_h_flow->create_text( text = 'Registros:' ).

  DESCRIBE TABLE gt_outtab LINES l_text.
  CONDENSE l_text.
  lo_h_flow = lo_header->create_flow( row = 5  column = 2 ).
  lo_h_flow->create_text( text = l_text ).

  gr_table->set_top_of_list( lo_header ).

  lr_functions = gr_table->get_functions( ).
  lr_functions->set_all( abap_true ).
  gr_layout = gr_table->get_layout( ).
  key-report = sy-repid.
  gr_layout->set_key( key ).

  gr_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).

  lr_events = gr_table->get_event( ).
  CREATE OBJECT gr_handle_events.
  SET HANDLER gr_handle_events->on_double_click FOR lr_events.
  SET HANDLER gr_handle_events->on_user_command FOR lr_events.
  SET HANDLER gr_handle_events->on_link_click FOR lr_events.

*... set the columns technical

  lr_columns = gr_table->get_columns( ).
  lr_columns->set_optimize( abap_true ).

  TRY.
      lr_column ?= lr_columns->get_column( 'BELNR' ). "<- columna objetivo
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
      lr_column ?= lr_columns->get_column( 'AUGBL' ). "<- columna objetivo
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
      lr_column ?= lr_columns->get_column( 'CHECF' ). "<- columna objetivo
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  PERFORM set_columns_technical USING lr_columns.

*... §4 display the table
  gr_table->display( ).

ENDFORM.                    " display_fullscreen


*&---------------------------------------------------------------------*
*&      Form  set_columns_technical
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_columns_technical USING ir_columns TYPE REF TO cl_salv_columns.

  DATA: lr_column TYPE REF TO cl_salv_column.

  TRY.
      lr_column = ir_columns->get_column( 'MANDT' ).
      lr_column->set_technical( if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'NAME1' ).
      lr_column->set_short_text( 'N. Acree.' ).
      lr_column->set_medium_text( 'Nombre Acreedor' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'MONTO1' ).
      lr_column->set_short_text( 'Importe ML' ).
      lr_column->set_medium_text( 'Importe ML' ).
      lr_column->set_currency( 'CLP' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'RWBTR' ).
      lr_column->set_currency( 'CLP' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'DMBTR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'UMSKS' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'CPUDT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ZUMSK' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'GSBER' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'WRBTR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'MWSTS' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'WMWST' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'BDIFF' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'BDIF2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PROJN' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'AUFNR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ANLN1' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ANLN2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'EBELN' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'EBELP' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'FKONT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'FILKD' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ZBD2T' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ZBD3T' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ZBD1P' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ZBD2P' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'SKFBT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'SKNTO' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'WSKTO' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ZBFIX' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'BVTYP' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'REBZJ' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'REBZZ' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ZOLLT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ZOLLD' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'LZBKZ' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'LANDL' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DIEKZ' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'MANSP' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'MSCHL' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'MADAT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'MANST' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'MABER' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XNETB' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XANET' ).
      lr_column->set_short_text( 'Indicador' ).
      lr_column->set_medium_text( 'Ind. Anticipo' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XCPDD' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XESRD' ).
      lr_column->set_short_text( 'Indicador' ).
      lr_column->set_medium_text( 'Ind. ESR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XZAHL' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'MWSK1' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DMBT1' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'WRBT1' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'MWSK2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DMBT2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'WRBT2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'MWSK3' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DMBT3' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'WRBT3' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'QSSKZ' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'QSSHB' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'QBSHB' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'BSTAT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ANFBN' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ANFBJ' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ANFBU' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'VBUND' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'REBZT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'STCEG' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'EGBLD' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'EGLLD' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'QSZNR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'QSFBT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XINVE' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PROJK' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'FIPOS' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'NPLNR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'NPLNR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'AUFPL' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'APLZL' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XEGDR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DMBE2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DMBE3' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DMB21' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DMB22' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DMB23' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DMB31' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DMB32' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DMB33' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'MWST2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'MWST3' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'SKNT2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'SKNT3' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'BDIF3' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'RSTGR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'UZAWE' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'LNRAN' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XSTOV' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'KZBTR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XREF1' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XREF2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XARCH' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PSWSL' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PSWBT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'IMKEY' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ZEKKN' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'FISTL' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'GEBER' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DABRZ' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XNEGP' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PRCTR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XREF3' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DTWS1' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DTWS2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DTWS3' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'DTWS4' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'XPYPR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'KIDNO' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PYCUR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PYAMT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'BUPLA' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'SECCO' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PPDIFF' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PPDIF2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PPDIF3' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PENLC1' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PENLC2' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PENLC3' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PENFC' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PENDAYS' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PENRC' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'VERTT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'VERTN' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'VBEWA' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'KBLNR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'KBLPOS' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'GRANT_NBR' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'GMVKZ' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'SRTYPE' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'LOTKZ' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'ZINKZ' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'FKBER' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'INTRENO' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'PPRCT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'BUZID' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'AUGGJ' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'HKTID' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'KONTT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'KONTL' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'UEBGDAT' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'VNAME' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'EGRUP' ).
      lr_column->set_visible( '' ).
      lr_column = ir_columns->get_column( 'BTYPE' ).
      lr_column->set_visible( '' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'IDENTIF_PAGO' ).
      lr_column->set_short_text( 'ID Pago' ).
      lr_column->set_medium_text( 'ID Pago Banco' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.


ENDFORM.                    " set_columns_technical(

*&---------------------------------------------------------------------*
*&      Form  get_description_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS    text
*      -->P_BUTXT    text
*----------------------------------------------------------------------*
FORM get_description_bukrs USING p_bukrs TYPE bukrs
                           CHANGING p_butxt TYPE butxt.
  DATA : l_adrnr             TYPE adrnr,
         l_address_selection TYPE addr1_sel,
         l_zgiro             TYPE zfigiro.

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

ENDFORM.                    "get_description_bu
