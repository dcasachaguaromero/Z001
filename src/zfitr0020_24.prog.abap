*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES03 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFITR0020_24
*&---------------------------------------------------------------------
*&  Compañía   : Banmedica
*&  Autor      : Crystalis Consulting Chile - Pablo Cabezas Melendez
*&  Funcional  : Crystalis Consulting Chile - Oscar Agudelo Prado
*&  Fecha      : 30.08.2013
*&  Objetivo   : Solución integral de pagos
*&--------------------------------------------------------------------
* Proceso: Consulta por comprobante de pago masivo
*--------------------------------------------------------------------*
REPORT  ZFITR0020_24.

TABLES: bsak, ZFITR020_T01, payr.

*--------------------------------------------------------------------*
*   ALV de salida
*--------------------------------------------------------------------*
TYPES: BEGIN OF ty_salida
         ,BUKRS            like ZFITR020_T01-BUKRS
         ,LLAVE            like ZFITR020_T01-LLAVE
         ,LLAVE_POS        like ZFITR020_T01-LLAVE_POS
         ,zuonr            like bsak-zuonr
         ,belnr_orig       like bsak-BELNR
         ,budat_orig       like bsak-budat
         ,bldat_orig       like bsak-bldat
         ,blart_orig       like bsak-blart
         ,gjahr_orig       like bsak-GJAHR
         ,wrbtr_orig       like bsak-WRBTR
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
         ,FECHA_INGRESO    like ZFITR020_T01-FECHA_INGRESO
         ,FECHA_ACTUAL     like ZFITR020_T01-FECHA_ACTUAL
      ,END OF ty_salida.

DATA: ti_salida TYPE STANDARD TABLE OF ty_salida.
DATA: wa_salida LIKE LINE OF ti_salida.
DATA: t_itab  TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.
DATA: t_itab2 TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.
DATA: t_itab3 TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.
DATA: t_itab4 TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.

TYPES: BEGIN OF ty_bsak
         ,BUKRS           like ZFITR020_T01-BUKRS
         ,BELNR           like ZFITR020_T01-BELNR
         ,budat           like bsak-budat
         ,bldat           like bsak-bldat
         ,blart           like bsak-blart
         ,augbl           like bsak-augbl
         ,GJAHR           like bsak-GJAHR
         ,augdt           like bsak-augdt
         ,LIFNR           like ZFITR020_T01-LIFNR
         ,zuonr           like bsak-zuonr
         ,wrbtr           like bsak-wrbtr
        ,END OF ty_bsak.

DATA: ti_bsak TYPE STANDARD TABLE OF ty_bsak.
DATA: wa_bsak LIKE LINE OF ti_bsak.

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

data: lv_estado_actual like ZFITR020_T01-PROCESO_COMPEN.
*--------------------------------------------------------------------*
*   Variables para el matchcode
*--------------------------------------------------------------------*
DATA: input_output(20) TYPE c,
      fld(20) TYPE c, "nombre del campo
      off     TYPE i,
      val(20) TYPE c, "valor en el campo
      len     TYPE i. "largo del valor

FIELD-SYMBOLS: <campo> TYPE ANY.

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
      READ TABLE ti_salida into wa_salida INDEX row.
      SET PARAMETER ID 'BLN' FIELD wa_salida-belnr_orig.
      SET PARAMETER ID 'BUK' FIELD wa_salida-BUKRS.
      SET PARAMETER ID 'GJR' FIELD wa_salida-GJAHR_orig.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

    ELSEIF column eq 'BELNR'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA Already Sorted
      READ TABLE ti_salida into wa_salida INDEX row.
      SET PARAMETER ID 'BLN' FIELD wa_salida-belnr.
      SET PARAMETER ID 'BUK' FIELD wa_salida-BUKRS.
      SET PARAMETER ID 'GJR' FIELD wa_salida-GJAHR.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

    endif.

  ENDMETHOD.                    "on_double_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION


SELECTION-SCREEN BEGIN OF BLOCK uno WITH FRAME TITLE text-001.
SELECT-OPTIONS    : p_bukrs1 for payr-zbukr no INTERVALS no-EXTENSION MEMORY ID buk.
SELECT-OPTIONS    : p_belnr1 for ZFITR020_T01-BELNR no INTERVALS.
SELECT-OPTIONS    : p_gjahr1 for ZFITR020_T01-GJAHR no INTERVALS no-EXTENSION.
SELECT-OPTIONS    : p_budat1 for ZFITR020_T01-BUDAT no-EXTENSION.
SELECT-OPTIONS    : p_lifnr1 for ZFITR020_T01-LIFNR no INTERVALS.
SELECT-OPTIONS    : p_motemi for ZFITR020_T01-MOTIVO_EMISION no INTERVALS.
SELECTION-SCREEN END OF BLOCK uno.

AT SELECTION-SCREEN on VALUE-REQUEST FOR p_motemi-low.
  DATA : indice    LIKE sy-tabix.
  DATA: return_tab TYPE TABLE OF ddshretval WITH HEADER LINE.

  DATA: BEGIN OF it_mov OCCURS 0
          ,BUKRS       TYPE T012-BUKRS
          ,ZZDESCR     like ZMOT_EMIS-ZZDESCR
          ,ZZMOT_EMIS  like ZMOT_EMIS-ZZMOT_EMIS
        ,END OF it_mov.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE it_mov
    FROM ZMOT_EMIS..

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'P_MOTEMI'
      dynpprog        = sy-cprog
      dynpnr          = sy-dynnr
      dynprofield     = space
      window_title    = 'Motivo'
      value_org       = 'S'
    TABLES
      value_tab       = it_mov
      return_tab      = return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES03 ECDK917080 *
SORT RETURN_TAB .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES03 ECDK917080 *
  READ TABLE return_tab INDEX 1.

  "obtengo el fieldtext donde esta el cursor
  GET CURSOR FIELD fld OFFSET off VALUE val LENGTH len.
  ASSIGN (fld) TO <campo>.
  MOVE return_tab-fieldval TO <campo>.

START-OF-SELECTION.

  PERFORM seleccion_datos.
  PERFORM crea_alv_salida.
  PERFORM despliega_alv.


*&---------------------------------------------------------------------*
*&      Form  SELECCION_DATOS
*&---------------------------------------------------------------------*
FORM seleccion_datos .


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_itab
*    from ZFITR020_T01
*    where BUKRS in p_bukrs1
*      and BELNR in p_belnr1
*      and GJAHR in p_gjahr1
*      and BLDAT in p_budat1
*      and lifnr in p_lifnr1
*      and blart = 'ZP'
*      and MOTIVO_EMISION in p_motemi.
*
* NEW CODE
  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_itab

    from ZFITR020_T01
    where BUKRS in p_bukrs1
      and BELNR in p_belnr1
      and GJAHR in p_gjahr1
      and BLDAT in p_budat1
      and lifnr in p_lifnr1
      and blart = 'ZP'
      and MOTIVO_EMISION in p_motemi ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  if t_itab[] is INITIAL.
    MESSAGE 'No se encontraron registros para la consultas' type 'E'.
  endif.
  "se rescata la posicion inicial de cada llave
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * into CORRESPONDING FIELDS OF TABLE t_itab2
*    from ZFITR020_T01 FOR ALL ENTRIES IN t_itab
*    where BUKRS = t_itab-bukrs
*      and llave = t_itab-LLAVE
*      and LLAVE_POS = '1'.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE t_itab2
    from ZFITR020_T01 FOR ALL ENTRIES IN t_itab
    where BUKRS = t_itab-bukrs
      and llave = t_itab-LLAVE
      and LLAVE_POS = '1' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  sort t_itab2 by BELNR GJAHR LLAVE LLAVE_POS.
  delete ADJACENT DUPLICATES FROM t_itab2.

*  "rescate de datos adicionales
*  select * into CORRESPONDING FIELDS OF TABLE ti_bsak
*    from bsak FOR ALL ENTRIES IN t_itab2
*    where BUKRS = t_itab2-bukrs
*      and augbl = t_itab2-belnr
*      and BELNR <> t_itab2-belnr
*      and GJAHR = t_itab2-GJAHR
*      and LIFNR = t_itab2-LIFNR.
  ranges: r_date for bsak-augdt .
  LOOP AT t_itab2.
    clear r_date[]. CLEAR r_date.

    r_date-sign   = 'I'."I, incluir, E excluir.
    r_date-option = 'BT'. "eq igual, bt between, NE no igual
    CONCATENATE t_itab2-GJAHR '0101' into r_date-low    .
    CONCATENATE t_itab2-GJAHR '1231' INTO r_date-high   .
    append r_date.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select * APPENDING CORRESPONDING FIELDS OF TABLE ti_bsak
*      from bsak "FOR ALL ENTRIES IN t_itab2
*      where BUKRS = t_itab2-bukrs
*        and augbl = t_itab2-belnr
*        and augdt in r_date
*        and BELNR <> t_itab2-belnr
**      and GJAHR = t_itab2-GJAHR
*        and LIFNR = t_itab2-LIFNR.
*
* NEW CODE
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ti_bsak

      from bsak "FOR ALL ENTRIES IN t_itab2
      where BUKRS = t_itab2-bukrs
        and augbl = t_itab2-belnr
        and augdt in r_date
        and BELNR <> t_itab2-belnr
*      and GJAHR = t_itab2-GJAHR
        and LIFNR = t_itab2-LIFNR ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDLOOP.

  sort ti_bsak by BELNR budat bldat GJAHR LIFNR.
  delete ADJACENT DUPLICATES FROM ti_bsak.

  "se rescatan todas las posiciones de cada llave
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * into CORRESPONDING FIELDS OF TABLE t_itab3
*    from ZFITR020_T01 FOR ALL ENTRIES IN t_itab2
*    where BUKRS = t_itab2-bukrs
*      and llave = t_itab2-LLAVE.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE t_itab3
    from ZFITR020_T01 FOR ALL ENTRIES IN t_itab2
    where BUKRS = t_itab2-bukrs
      and llave = t_itab2-LLAVE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  sort t_itab3 by  LLAVE  LLAVE_POS DESCENDING.
  DELETE ADJACENT DUPLICATES FROM t_itab3.

ENDFORM.                    " SELECCION_DATOS
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV_SALIDA
*&---------------------------------------------------------------------*
FORM crea_alv_salida .
  "tabla con las posiciones iniciales de cada llave
  loop at t_itab2.
    "posicion con todas las posiciones de cada llave
    loop at t_itab3 where llave = t_itab2-LLAVE.
      "solo interesa el movimiento de la ultima posicion de la
      "llave
      on CHANGE OF t_itab3-llave.
        clear t_itab4.
        READ TABLE t_itab3 into t_itab4
                      with key VBLNR_PAGO = t_itab3-BELNR.
        if sy-subrc = 0.
          lv_estado_actual = t_itab4-PROCESO_COMPEN.
        else.
          if t_itab2-llave_pos eq '1'.
            if t_itab2-PROCESO_COMPEN is not INITIAL.
              lv_estado_actual = t_itab3-PROCESO_COMPEN.
            else.
              lv_estado_actual = t_itab3-CAMBIO_ESTADO.
            endif.
          endif.
        endif.
      endon.

      loop at ti_bsak into wa_bsak where augbl = t_itab2-BELNR
*                                     and GJAHR = t_itab2-GJAHR
                                     and augdt = t_itab2-budat
                                     and LIFNR = t_itab2-LIFNR.

        t_itab3-zuonr         = wa_bsak-zuonr.
        t_itab3-belnr_orig    = wa_bsak-belnr.
        t_itab3-budat_orig    = wa_bsak-budat.
        t_itab3-bldat_orig    = wa_bsak-bldat.
        t_itab3-blart_orig    = wa_bsak-blart.
        t_itab3-GJAHR_orig    = wa_bsak-GJAHR.
        t_itab3-wrbtr_orig    = wa_bsak-WRBTR.
        t_itab3-estado_actual = lv_estado_actual.

        append t_itab3 to ti_salida.
        clear wa_bsak.

      endloop.
      clear t_itab3.
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
  gr_display->set_list_header( 'Consulta por comprobante masiva ' ).

  TRY.
      gr_columns = gr_table->get_columns( ).
      gr_column ?= gr_columns->get_column( 'WRBTR' ).       gr_column->SET_CURRENCY_COLUMN( 'WAERS' ).
      gr_column ?= gr_columns->get_column( 'WRBTR_ORIG' ).  gr_column->SET_CURRENCY_COLUMN( 'WAERS' ).
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
  "despliega el alv
  gr_table->display( ).

ENDFORM.                    " DESPLIEGA_ALV
*&---------------------------------------------------------------------*
*&      Form  COLOREA_COLUMNAS
*&---------------------------------------------------------------------*
FORM COLOREA_COLUMNAS .
  try.
      gr_columns = gr_table->get_columns( ).
      "azul intenso
      gr_column ?= gr_columns->get_column( 'BUKRS' ).     color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'ZUONR' ).     color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BELNR_ORIG' ).color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BUDAT_ORIG' ).color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BLDAT_ORIG' ).color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BLART_ORIG' ).color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'GJAHR_ORIG' ).color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'WRBTR_ORIG' ).color-col = '1'.  color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      "verde intenso
      gr_column ?= gr_columns->get_column( 'ESTADO_ACTUAL' ).color-col = '5'.   color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'LLAVE' ).        color-col = '5'.   color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'LLAVE_POS' ).    color-col = '5'.   color-int = '1'.  color-inv = '0'.  gr_column->set_color( color ).

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
      gr_column->set_long_text( 'C.P. Sociedad' ).
      gr_column->set_medium_text( 'C.P. Sociedad' ).
      gr_column->set_short_text( 'C.P. Soc.' ).

      gr_column ?= gr_columns->get_column( 'ZUONR' ).
      gr_column->set_long_text( 'C.P. Folio doc. pago' ).
      gr_column->set_medium_text( 'C.P.Folio doc. pago' ).
      gr_column->set_short_text( 'C.P.dc.pag' ).

      gr_column ?= gr_columns->get_column( 'BELNR_ORIG' ).
      gr_column->set_long_text(   'C.P. Comprobante' ).
      gr_column->set_medium_text( 'C.P. Comprobante' ).
      gr_column->set_short_text(  'C.P. Comp.' ).

      gr_column ?= gr_columns->get_column( 'BUDAT_ORIG' ).
      gr_column->set_long_text(   'C.P. Fe.contab.' ).
      gr_column->set_medium_text( 'C.P. Fe.contab.' ).
      gr_column->set_short_text(  'C.P.F.con.' ).

      gr_column ?= gr_columns->get_column( 'BLDAT_ORIG' ).
      gr_column->set_long_text(   'C.P. Fecha doc.' ).
      gr_column->set_medium_text( 'C.P. Fecha doc.' ).
      gr_column->set_short_text(  'C.P.F.doc.' ).

      gr_column ?= gr_columns->get_column( 'BLART_ORIG' ).
      gr_column->set_long_text(   'C.P. Clase doc.' ).
      gr_column->set_medium_text( 'C.P. Clase doc.' ).
      gr_column->set_short_text(  'C.P.Cl.doc' ).

      gr_column ?= gr_columns->get_column( 'GJAHR_ORIG' ).
      gr_column->set_long_text(   'F.P. Ejercicio' ).
      gr_column->set_medium_text( 'F.P. Ejercicio' ).
      gr_column->set_short_text(  'F.P.Ejer.' ).

      gr_column ?= gr_columns->get_column( 'WRBTR_ORIG' ).
      gr_column->set_long_text(   'F.P. Importe' ).
      gr_column->set_medium_text( 'F.P. Importe' ).
      gr_column->set_short_text(  'F.P.Imp.' ).

      gr_column ?= gr_columns->get_column( 'ESTADO_ACTUAL' ).
      gr_column->set_long_text(   'Estado actual' ).
      gr_column->set_medium_text( 'Estado actual' ).
      gr_column->set_short_text(  'Est. act.' ).
    CATCH cx_salv_not_found.
  ENDTRY."SET_COLOR

ENDFORM.                    " CAMBIA_HEADERS
