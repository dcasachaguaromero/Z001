*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES03 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFITR0020_22
*&---------------------------------------------------------------------
*&  Compañía   : Banmedica
*&  Autor      : Crystalis Consulting Chile - Pablo Cabezas Melendez
*&  Funcional  : Crystalis Consulting Chile - Oscar Agudelo Prado
*&  Fecha      : 30.08.2013
*&  Objetivo   : Solución integral de pagos
*&--------------------------------------------------------------------
* Proceso: Consulta por comprobante de pago
*--------------------------------------------------------------------*
REPORT  ZFITR0020_23.

TABLES: bsak, ZFITR020_T01, payr.

*--------------------------------------------------------------------*
*   ALV de saliad
*--------------------------------------------------------------------*
TYPES: BEGIN OF ty_salida
         ,BUKRS            like ZFITR020_T01-BUKRS
         ,belnr_orig       like bsak-BELNR
         ,gjahr_orig       like bsak-GJAHR
         ,estado_actual    like ZFITR020_T01-PROCESO_COMPEN
         ,BLART            like ZFITR020_T01-BLART
         ,BELNR            like ZFITR020_T01-BELNR
         ,BLDAT            like ZFITR020_T01-BLDAT
         ,BUDAT            like ZFITR020_T01-BUDAT
         ,GJAHR            like ZFITR020_T01-GJAHR
         ,WRBTR            like ZFITR020_T01-WRBTR
         ,WAERS            like ZFITR020_T01-WAERS
         ,BKTXT            like ZFITR020_T01-BKTXT
         ,XBLNR            like ZFITR020_T01-XBLNR
         ,USNAM            like ZFITR020_T01-USNAM
         ,LIFNR            like ZFITR020_T01-LIFNR
         ,EMPFB            like ZFITR020_T01-EMPFB
         ,HKONTD           like ZFITR020_T01-HKONTD
         ,HKONTH           like ZFITR020_T01-HKONTH
         ,CAMBIO_ESTADO    like ZFITR020_T01-CAMBIO_ESTADO
         ,MODALIDAD_PAGO   like ZFITR020_T01-MODALIDAD_PAGO
         ,CHECT            like ZFITR020_T01-CHECT
         ,HBKID            like ZFITR020_T01-HBKID
         ,HKTID            like ZFITR020_T01-HKTID
         ,STCD1            like ZFITR020_T01-STCD1
         ,MOTIVO_EMISION   like ZFITR020_T01-MOTIVO_EMISION
         ,NAME1            like ZFITR020_T01-NAME1
         ,ZALDT            like ZFITR020_T01-ZALDT
         ,ID_PROP_PAGO     like ZFITR020_T01-ID_PROP_PAGO
         ,PROCESO_COMPEN   like ZFITR020_T01-PROCESO_COMPEN
         ,NUM_AGENCIA      like ZFITR020_T01-NUM_AGENCIA
         ,ESTAD_PAGO_ORIG  like ZFITR020_T01-ESTAD_PAGO_ORIG
         ,VBLNR_PAGO       like ZFITR020_T01-VBLNR_PAGO
         ,GJAHR_PAGO       like ZFITR020_T01-GJAHR_PAGO
         ,BLART_PAGO       like ZFITR020_T01-BLART_PAGO
         ,BLDAT_PAGO       like ZFITR020_T01-BLDAT_PAGO
         ,BUDAT_PAGO       like ZFITR020_T01-BUDAT_PAGO
         ,AZDAT            like ZFITR020_T01-AZDAT
         ,AZNUM            like ZFITR020_T01-AZNUM
         ,LLAVE            like ZFITR020_T01-LLAVE
         ,LLAVE_POS        like ZFITR020_T01-LLAVE_POS,
      END OF ty_salida.

DATA: ti_salida TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.
DATA: wa_salida LIKE LINE OF ti_salida.

DATA: t_itab  TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.
DATA: t_itab2 TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.
DATA: t_itab3 TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.

TYPES: BEGIN OF ty_error,
          BUKRS            like ZFITR020_T01-BUKRS
         ,BELNR            like ZFITR020_T01-BELNR
         ,GJAHR            like ZFITR020_T01-GJAHR,
  end of ty_error.

data: ti_error TYPE STANDARD TABLE OF ty_error WITH HEADER LINE.

DATA: gr_table      TYPE REF TO cl_salv_table.
DATA: gr_events     TYPE REF TO cl_salv_events_table.
DATA: gr_functions  TYPE REF TO cl_salv_functions.
DATA: gr_selections TYPE REF TO cl_salv_selections.
DATA: gr_display    TYPE REF TO cl_salv_display_settings.
DATA: gr_columns    TYPE REF TO cl_salv_columns_table.
DATA: gr_column     TYPE REF TO cl_salv_column_table.
DATA: gr_sorts      TYPE REF TO cl_salv_sorts.
DATA: gr_agg        TYPE REF TO cl_salv_aggregations.
DATA: gr_filter     TYPE REF TO cl_salv_filters.
DATA: gr_layout     TYPE REF TO cl_salv_layout.

DATA: color TYPE lvc_s_colo.
DATA: key   TYPE salv_s_layout_key.

DATA: lr_column  TYPE REF TO cl_salv_column_table,
      lr_columns TYPE REF TO cl_salv_columns.

FIELD-SYMBOLS <tabla> TYPE ANY TABLE.

*----------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
    METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column.

ENDCLASS.     "lcl_handle_events DEFINITION
DATA: event_handler TYPE REF TO lcl_handle_events.
*----------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
    DATA: lr_selections TYPE REF TO cl_salv_selections.
    DATA: lt_rows TYPE salv_t_row.
    DATA: ls_rows TYPE i.
    DATA: message TYPE string.

    CASE e_salv_function.
      WHEN 'MYFUNCTION'.
*        lr_selections = gr_table->get_selections( ).
*        lt_rows = lr_selections->get_selected_rows( ).
*        READ TABLE lt_rows INTO ls_rows INDEX 1.
*        READ TABLE ti_salida INTO wa_salida INDEX ls_rows.
**        CONCATENATE xspfli-carrid xspfli-connid
**           xspfli-cityfrom xspfli-cityto
**             INTO message SEPARATED BY space.
*
*        MESSAGE i001(00) WITH 'You pushed the button!' message.
    ENDCASE.
  ENDMETHOD. "on_user_command endclass.
  METHOD on_double_click.

    if column eq 'BELNR_ORIG'.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES03 ECDK917080 *
SORT TI_SALIDA .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES03 ECDK917080 *
      READ TABLE ti_salida into ti_salida INDEX row.
      SET PARAMETER ID 'BLN' FIELD ti_salida-belnr_orig.
      SET PARAMETER ID 'BUK' FIELD ti_salida-BUKRS.
      SET PARAMETER ID 'GJR' FIELD ti_salida-GJAHR_orig.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

    ELSEIF column eq 'BELNR'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA Already Sorted
      READ TABLE ti_salida into ti_salida INDEX row.
      SET PARAMETER ID 'BLN' FIELD ti_salida-belnr.
      SET PARAMETER ID 'BUK' FIELD ti_salida-BUKRS.
      SET PARAMETER ID 'GJR' FIELD ti_salida-GJAHR.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

    endif.


*    CONCATENATE 'Row' row_c 'Column' column
*        INTO message SEPARATED BY space.
*    MESSAGE i001(00) WITH 'You double-clicked on ' message.
  ENDMETHOD.                    "on_double_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION


SELECTION-SCREEN BEGIN OF BLOCK uno WITH FRAME TITLE text-001.
SELECT-OPTIONS    : p_bukrs1 for payr-zbukr OBLIGATORY no INTERVALS no-EXTENSION.
SELECT-OPTIONS    : p_hbkid1 for payr-hbkid OBLIGATORY no INTERVALS no-EXTENSION.
SELECT-OPTIONS    : p_hktid1 for payr-hktid OBLIGATORY no INTERVALS no-EXTENSION.
SELECT-OPTIONS    : p_belnr1 for ZFITR020_T01-BELNR no INTERVALS OBLIGATORY.
select-OPTIONS    : p_budat1 for ZFITR020_T01-budat no-EXTENSION OBLIGATORY.
SELECTION-SCREEN END OF BLOCK uno.


START-OF-SELECTION.

  PERFORM seleccion_datos.
  PERFORM crea_alv_salida.
  PERFORM despliega_alv.


*&---------------------------------------------------------------------*
*&      Form  SELECCION_DATOS
*&---------------------------------------------------------------------*
FORM seleccion_datos .

  loop at p_belnr1.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_itab
*      from ZFITR020_T01
*      where BUKRS in p_bukrs1
*        and hbkid in p_hbkid1
*        and hktid in p_hktid1
*        and BELNR eq p_belnr1-low
**        and GJAHR in p_gjahr1
*        and budat in p_budat1
*        .
*
* NEW CODE
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_itab

      from ZFITR020_T01
      where BUKRS in p_bukrs1
        and hbkid in p_hbkid1
        and hktid in p_hktid1
        and BELNR eq p_belnr1-low
*        and GJAHR in p_gjahr1
        and budat in p_budat1
         ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    if sy-subrc <> 0.
      clear ti_error.
      ti_error-BELNR = p_bukrs1.
      ti_error-BUKRS = p_belnr1-low.
*      ti_error-GJAHR = p_gjahr1.
      APPEND ti_error.
    endif.
  endloop.

  "se rescatan todas las posiciones de cada llave
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * into CORRESPONDING FIELDS OF TABLE t_itab2
*    from ZFITR020_T01 FOR ALL ENTRIES IN t_itab
*    where BUKRS = t_itab-bukrs
*      and llave = t_itab-LLAVE.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE t_itab2
    from ZFITR020_T01 FOR ALL ENTRIES IN t_itab
    where BUKRS = t_itab-bukrs
      and llave = t_itab-LLAVE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  sort t_itab2 by  LLAVE  LLAVE_POS DESCENDING.

ENDFORM.                    " SELECCION_DATOS
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV_SALIDA
*&---------------------------------------------------------------------*
FORM crea_alv_salida .

  "agregamos los comprobantes que dan error
  loop at ti_error.
    t_itab2-BUKRS      = ti_error-BUKRS.
    t_itab2-belnr_orig = ti_error-belnr.
    t_itab2-GJAHR_orig = ti_error-GJAHR.
    t_itab2-estado_actual = 'SIN DATOS'.
    append  t_itab2 to ti_salida.
    clear t_itab2.
  endloop.

  "esta tabla contiene las posiciones inicales
  loop at t_itab.
    "esta tabla tiene todas las posiciones de cada llave
    loop at t_itab2 where llave = t_itab-LLAVE.
      "solo interesa el movimiento de la ultima posicion de la
      "llave
      on CHANGE OF t_itab2-llave.
        data: lv_estado_actual like ZFITR020_T01-PROCESO_COMPEN.
        clear t_itab3.
        READ TABLE t_itab2 into t_itab3
                        with key VBLNR_PAGO = t_itab2-BELNR.
        if sy-subrc = 0.
          lv_estado_actual = t_itab3-PROCESO_COMPEN.
        else.
          if t_itab-llave_pos eq '1'.
            if t_itab2-PROCESO_COMPEN is not INITIAL.
              lv_estado_actual = t_itab2-PROCESO_COMPEN.
            else.
              lv_estado_actual = t_itab2-CAMBIO_ESTADO.
            endif.
          endif.
        endif.
      endon.

      t_itab2-belnr_orig    = t_itab-BELNR.
      t_itab2-GJAHR_orig    = t_itab-GJAHR.
      t_itab2-estado_actual = lv_estado_actual.

      append t_itab2 to ti_salida.
      clear t_itab2.
    endloop.
  endloop.

  SORT ti_salida by belnr_orig llave LLAVE_POS.
  delete ADJACENT DUPLICATES FROM ti_salida.

ENDFORM.                    " CREA_ALV_SALIDA
*&---------------------------------------------------------------------*
*&      Form  DESPLIEGA_ALV
*&---------------------------------------------------------------------*
FORM despliega_alv .
  "no necesita structura de datos si se asigna el field symbol
  ASSIGN ti_salida[] TO <tabla>[].
  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = gr_table
        CHANGING  t_table      = <tabla>[] ).
    CATCH cx_salv_msg.                                  "#EC NO_HANDLER
  ENDTRY.
  "copiar status gui de function group SALV_METADATA_STATUS
  "and copy the gui status SALV_TABLE_STANDARD into the program.
  "se80 -> grupo de funciones -> status gui ->boton derecho copiar
*{   DELETE         ECDK910635                                        1
*\  gr_table->set_screen_status(
*\    pfstatus      = 'SALV_TABLE_STANDARD'
*\    report        = sy-repid
*\    set_functions = gr_table->c_functions_all ).
*}   DELETE

**... optimize the column widths
  TRY.
      lr_columns = gr_table->get_columns( ).
      lr_columns->set_optimize( 'X' ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  gr_events = gr_table->get_event( ).

  CREATE OBJECT event_handler.
  SET HANDLER event_handler->on_user_command FOR gr_events.
  SET HANDLER event_handler->on_double_click FOR gr_events.

*  * Set up selections.
  gr_selections = gr_table->get_selections( ).
  "none(0) Single(1) multiple (2) cell selection(3) row_column(4)
  gr_selections->set_selection_mode( 2 ).

* Habilita las funciones del alv
  gr_functions = gr_table->get_functions( ).
  gr_functions->set_all( abap_true ).

  gr_display = gr_table->get_display_settings( ).
  gr_display->set_striped_pattern( cl_salv_display_settings=>true ).
  gr_display->set_list_header( 'Consulta por comprobante ' ).

  TRY.
      gr_columns = gr_table->get_columns( ).
      gr_column ?= gr_columns->get_column( 'WRBTR' ).   gr_column->SET_CURRENCY_COLUMN( 'WAERS' ).
    CATCH cx_salv_not_found.
  ENDTRY."SET_COLOR

  PERFORM colorea_columnas.
  PERFORM cambia_headers.

  gr_agg = gr_table->get_aggregations( ).
  gr_agg->clear( ).

  try.
      gr_agg->add_aggregation( columnname = 'WRBTR' ).
    CATCH cx_salv_not_found.
  ENDTRY.

  DATA: nfilas(5) TYPE c.
  DATA: nfilas1 TYPE i.
  DESCRIBE TABLE ti_salida LINES  nfilas1.
  MOVE nfilas1 TO nfilas.
  DATA: vl_texto(25) TYPE c.
  CONCATENATE 'Número de filas' nfilas INTO vl_texto SEPARATED BY space.
  MESSAGE vl_texto TYPE 'S'.

**  oculta columnas
*  TRY.
*      gr_column ?= gr_columns->get_column( 'CAMPO20' ).
*      gr_column->set_visible(abap_false).
*    CATCH cx_salv_not_found .
*  ENDTRY.
*
*  "pinta la columna
*  gr_column ?= gr_columns->get_column( 'CITYFROM' ).
*  color-col = '6'.
*  color-int = '1'.
*  color-inv = '0'.
*  gr_column->set_color( color ).
*  try.
*  gr_sorts = gr_table->get_sorts( ).
*  gr_sorts->add_sort( columnname = 'CITYTO' subtotal = abap_true ).
*  gr_agg = gr_table->get_aggregations( ).
*
*  gr_agg->add_aggregation( 'DISTANCE' ).
*  catch cx_salv_not_found cx_salv_existing cx_salv_data_error.
*  endtry.

*  gr_filter = gr_table->get_filters( ).
*  gr_filter->add_filter( columnname = 'CARRID' low = 'LH' ).
*
  gr_layout = gr_table->get_layout( ).
  key-report = sy-repid.
  gr_layout->set_key( key ).

  gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
*  despliega el alv
  gr_table->display( ).

ENDFORM.                    " DESPLIEGA_ALV
*&---------------------------------------------------------------------*
*&      Form  COLOREA_COLUMNAS
*&---------------------------------------------------------------------*
FORM COLOREA_COLUMNAS .
  try.
      gr_columns = gr_table->get_columns( ).
      gr_column ?= gr_columns->get_column( 'BUKRS' ).        color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
*      gr_column ?= gr_columns->get_column( 'ZUONR' ).        color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BELNR_ORIG' ).   color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'GJAHR_ORIG' ).   color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'ESTADO_ACTUAL' ).color-col = '5'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      CATCH cx_salv_not_found.

  ENDTRY."SET_COLOR
ENDFORM.                    " COLOREA_COLUMNAS
*&---------------------------------------------------------------------*
*&      Form  CAMBIA_HEADERS
*&---------------------------------------------------------------------*
FORM CAMBIA_HEADERS .
  try.
      gr_columns = gr_table->get_columns( ).
      gr_column ?= gr_columns->get_column( 'BUKRS' ).
      gr_column->set_long_text(   'F.P. Sociedad' ).
      gr_column->set_medium_text( 'F.P. Sociedad' ).
      gr_column->set_short_text(  'F.P. Soc.' ).
*
*      gr_column ?= gr_columns->get_column( 'ZUONR' ).
*      gr_column->set_long_text(   'F.P. Folio doc. pago' ).
*      gr_column->set_medium_text( 'F.P.Folio doc. pago' ).
*      gr_column->set_short_text(  'F.P.dc.pag' ).

      gr_column ?= gr_columns->get_column( 'BELNR_ORIG' ).
      gr_column->set_long_text(   'F.P. Comprobante' ).
      gr_column->set_medium_text( 'F.P. Comprobante' ).
      gr_column->set_short_text(  'F.P. Comp.' ).

      gr_column ?= gr_columns->get_column( 'GJAHR_ORIG' ).
      gr_column->set_long_text(   'F.P. Ejercicio' ).
      gr_column->set_medium_text( 'F.P. Ejercicio' ).
      gr_column->set_short_text(  'F.P.Ejer.' ).

      gr_column ?= gr_columns->get_column( 'ESTADO_ACTUAL' ).
      gr_column->set_long_text(   'Estado actual' ).
      gr_column->set_medium_text( 'Estado actual' ).
      gr_column->set_short_text(  'Est. act.' ).

    CATCH cx_salv_not_found.
  ENDTRY."SET_COLOR
ENDFORM.                    " CAMBIA_HEADERS
