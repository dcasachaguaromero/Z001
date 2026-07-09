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
* Proceso: Consulta por suceso - licencias maternales
*--------------------------------------------------------------------*
REPORT  ZFITR0020_25.

TABLES: bsak, ZFITR020_T01, payr.
*--------------------------------------------------------------------*
* ALV de salida
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
         ,belnr_max        like ZFITR020_T01-BELNR
         ,GJAHR_max        like ZFITR020_T01-GJAHR
         ,BLART_max        like ZFITR020_T01-blart
         ,BLDAT_max        like ZFITR020_T01-bldat
         ,BUDAT_max        LIKE ZFITR020_T01-budat
         ,wrbtr_max        like ZFITR020_T01-WRBTR
         ,chect_max        LIKE ZFITR020_T01-chect
         ,hbkid_max        LIKE ZFITR020_T01-HBKID
         ,hktid_max        LIKE ZFITR020_T01-HKTID
         ,belnr_max2       like ZFITR020_T01-BELNR
         ,GJAHR_max2       like ZFITR020_T01-GJAHR
         ,BLART_max2       like ZFITR020_T01-blart
         ,BLDAT_max2       like ZFITR020_T01-bldat
         ,BUDAT_max2       LIKE ZFITR020_T01-budat
         ,wrbtr_max2       like ZFITR020_T01-WRBTR
         ,chect_max2       LIKE ZFITR020_T01-chect
         ,hbkid_max2       LIKE ZFITR020_T01-HBKID
         ,hktid_max2       LIKE ZFITR020_T01-HKTID
      ,END OF ty_salida.

DATA: ti_salida TYPE STANDARD TABLE OF ty_salida.
DATA: wa_salida LIKE LINE OF ti_salida.

DATA: t_itab  TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.
DATA: t_itab2 TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.
DATA: t_itab3 TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.

DATA: t_itab_min  TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.
DATA: t_itab_max  TYPE STANDARD TABLE OF ty_salida WITH HEADER LINE.


TYPES: BEGIN OF ty_bsak
         ,BUKRS like ZFITR020_T01-BUKRS
         ,BELNR like ZFITR020_T01-BELNR
         ,budat like bsak-budat
         ,bldat like bsak-bldat
         ,blart like bsak-blart
         ,augbl like bsak-augbl
         ,GJAHR like bsak-GJAHR
         ,augdt like bsak-augdt
         ,wrbtr like bsak-WRBTR
         ,LIFNR like ZFITR020_T01-LIFNR
         ,zuonr like bsak-zuonr,
      END OF ty_bsak.

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

data: tabname          type c length 4.
data: lv_estado_actual like ZFITR020_T01-PROCESO_COMPEN.

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

    ELSEIF column eq 'BELNR_MAX'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA Already Sorted
      READ TABLE ti_salida into wa_salida INDEX row.
      SET PARAMETER ID 'BLN' FIELD wa_salida-belnr_MAX.
      SET PARAMETER ID 'BUK' FIELD wa_salida-BUKRS.
      SET PARAMETER ID 'GJR' FIELD wa_salida-GJAHR_MAX.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

    ELSEIF column eq 'BELNR_MAX2'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA Already Sorted
      READ TABLE ti_salida into wa_salida INDEX row.
      SET PARAMETER ID 'BLN' FIELD wa_salida-belnr_MAX2.
      SET PARAMETER ID 'BUK' FIELD wa_salida-BUKRS.
      SET PARAMETER ID 'GJR' FIELD wa_salida-GJAHR_MAX2.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    endif.

  ENDMETHOD.                    "on_double_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION


*--------------------------------------------------------------------*
*   Primera pestaña:
*--------------------------------------------------------------------*
selection-screen begin of screen 101 as subscreen.
selection-screen begin of block b1 with frame title text-t00.
SELECT-OPTIONS   :   p_bukrs1   for ZFITR020_T01-BUKRS memory id buk no INTERVALS no-EXTENSION.
SELECT-OPTIONS   :   p_motem1   FOR ZFITR020_T01-MOTIVO_EMISION no INTERVALS.
SELECT-OPTIONS   :   p_rango    for ZFITR020_T01-blart no INTERVALS.
SELECT-OPTIONS   :   p_budat1   for ZFITR020_T01-budat DEFAULT sy-datum no-EXTENSION.
SELECT-OPTIONS   :   p_belnr1 for ZFITR020_T01-BELNR no INTERVALS.
SELECT-OPTIONS   :   p_gjahr1 for ZFITR020_T01-GJAHR no INTERVALS no-EXTENSION.
selection-screen end of block b1.
selection-screen end of screen 101.
*--------------------------------------------------------------------*
*   Segunda pestaña:
*--------------------------------------------------------------------*
selection-screen begin of screen 102 as subscreen.
selection-screen begin of block b2 with frame title text-t02.
SELECT-OPTIONS   :   p_bukrs2   for ZFITR020_T01-BUKRS memory id buk no INTERVALS no-EXTENSION.
SELECT-OPTIONS   :   p_motem2   FOR ZFITR020_T01-MOTIVO_EMISION no INTERVALS.
SELECT-OPTIONS   :   p_rango2    for ZFITR020_T01-blart no INTERVALS.
SELECT-OPTIONS   :   p_budat2   for ZFITR020_T01-budat DEFAULT sy-datum no-EXTENSION.
SELECT-OPTIONS   :   p_belnr2 for ZFITR020_T01-BELNR no INTERVALS.
SELECT-OPTIONS   :   p_gjahr2 for ZFITR020_T01-GJAHR no INTERVALS no-EXTENSION.
selection-screen end of block b2.
selection-screen end of screen 102.
*--------------------------------------------------------------------*
*   Tercera pestaña:
*--------------------------------------------------------------------*
selection-screen begin of screen 103 as subscreen.
selection-screen begin of block b3 with frame title text-t03.
SELECT-OPTIONS   :   p_bukrs3   for ZFITR020_T01-BUKRS memory id buk no INTERVALS no-EXTENSION.
SELECT-OPTIONS   :   p_motem3   FOR ZFITR020_T01-MOTIVO_EMISION no INTERVALS.
SELECT-OPTIONS   :   p_rango3    for ZFITR020_T01-blart no INTERVALS.
SELECT-OPTIONS   :   p_budat3   for ZFITR020_T01-budat DEFAULT sy-datum no-EXTENSION.
SELECT-OPTIONS   :   p_belnr3 for ZFITR020_T01-BELNR no INTERVALS.
SELECT-OPTIONS   :   p_gjahr3 for ZFITR020_T01-GJAHR no INTERVALS no-EXTENSION.
selection-screen end of block b3.
selection-screen end of screen 103.
*--------------------------------------------------------------------*

selection-screen begin of tabbed block t1 for 20 lines.
selection-screen tab (30) name1 user-command ucomm1 default screen 101.
selection-screen tab (30) name2 user-command ucomm2 default screen 102.
selection-screen tab (30) name3 user-command ucomm3 default screen 103.
selection-screen end of block t1.


AT SELECTION-SCREEN.
  "determino el tab que se ejecuto el programa y lo asigno a la variable
  "tabname para hacer procesos de busquedas distintos
  CASE sy-dynnr.
    WHEN 1000.
      CASE sy-ucomm.
        WHEN 'UCOMM1'.  tabname = 101.
        WHEN 'UCOMM2'.  tabname = 102.
        WHEN 'UCOMM3'.  tabname = 103.
      ENDCASE.
  ENDCASE.

INITIALIZATION.
  "nombre de las pestañas
  name1 = 'CHEQUES CADUCOS'.
  name2 = 'PAGOS REV. Y REE.'.
  name3 = 'PAGOS REALIZADOS'.

START-OF-SELECTION.

  if tabname eq '101' or tabname is INITIAL.
    PERFORM seleccion_datos1.
    PERFORM crea_alv_salida1.
  elseif tabname eq '102'.
    PERFORM seleccion_datos2.
    PERFORM crea_alv_salida2.
  elseif tabname eq '103'.
    PERFORM seleccion_datos3.
    PERFORM crea_alv_salida3.
  endif.

  PERFORM despliega_alv.


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
      gr_column ?= gr_columns->get_column( 'WRBTR_MAX' ).   gr_column->SET_CURRENCY_COLUMN( 'WAERS' ).
      gr_column ?= gr_columns->get_column( 'WRBTR_ORIG' ).  gr_column->SET_CURRENCY_COLUMN( 'WAERS' ).

    CATCH cx_salv_not_found.
  ENDTRY."SET_COLOR


  PERFORM cambia_headers.
  PERFORM colorea_columnas.
  perform oculta_columnas.

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

  "activa el layout del alv.
  gr_layout = gr_table->get_layout( ).
  key-report = sy-repid.
  gr_layout->set_key( key ).

  gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

  "despliega el alv
  gr_table->display( ).

ENDFORM.                    " DESPLIEGA_ALV
*&---------------------------------------------------------------------*
*&      Form  SELECCION_DATOS1
*&---------------------------------------------------------------------*
FORM SELECCION_DATOS1 .


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_itab
*    from ZFITR020_T01
*    where BUKRS in p_bukrs1
*      and budat in p_budat1
*      and blart in p_rango
*      and MOTIVO_EMISION in p_motem1
*      and BELNR in p_belnr1
*      and GJAHR in p_gjahr1.
*
* NEW CODE
  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_itab

    from ZFITR020_T01
    where BUKRS in p_bukrs1
      and budat in p_budat1
      and blart in p_rango
      and MOTIVO_EMISION in p_motem1
      and BELNR in p_belnr1
      and GJAHR in p_gjahr1 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


  if t_itab[] is INITIAL.
    MESSAGE 'No se encontraron datos' type 'E'.
  endif.

  sort t_itab by LLAVE LLAVE_POS DESCENDING.
  "rescata la posicion mas alta de esa llave
  LOOP AT t_itab.
    on CHANGE OF t_itab-llave.
      APPEND t_itab to t_itab_max.
    endon.
  endloop.

  "se busca la posicion inicial de esa llave
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * into CORRESPONDING FIELDS OF TABLE t_itab_min
*    from ZFITR020_T01 FOR ALL ENTRIES IN t_itab_max
*    where BUKRS = t_itab_max-bukrs
*      and llave = t_itab_max-LLAVE
*      and LLAVE_POS = '1'
*      and blart = 'ZP'.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE t_itab_min
    from ZFITR020_T01 FOR ALL ENTRIES IN t_itab_max
    where BUKRS = t_itab_max-bukrs
      and llave = t_itab_max-LLAVE
      and LLAVE_POS = '1'
      and blart = 'ZP' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  sort t_itab3 by BELNR GJAHR LLAVE LLAVE_POS.
*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES03 ECDK917080 *
SORT T_ITAB_MIN .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES03 ECDK917080 *
  delete ADJACENT DUPLICATES FROM t_itab_min.

  ranges: r_date for bsak-augdt .
  loop at t_itab_min.
    clear r_date[]. CLEAR r_date.

    r_date-sign   = 'I'."I, incluir, E excluir.
    r_date-option = 'BT'. "eq igual, bt between, NE no igual
    CONCATENATE t_itab_min-GJAHR '0101' into r_date-low    .
    CONCATENATE t_itab_min-GJAHR '1231' INTO r_date-high   .
    append r_date.

    "se buscan los datos adicionales correspondientes
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select * APPENDING CORRESPONDING FIELDS OF TABLE ti_bsak
*      from bsak "FOR ALL ENTRIES IN t_itab_min
*      where BUKRS =  t_itab_min-bukrs
*        and augbl =  t_itab_min-belnr
*        and augdt in r_date
*        and BELNR <> t_itab_min-belnr
**        and GJAHR =  t_itab_min-GJAHR
*        and LIFNR =  t_itab_min-LIFNR.
*
* NEW CODE
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ti_bsak

      from bsak "FOR ALL ENTRIES IN t_itab_min
      where BUKRS =  t_itab_min-bukrs
        and augbl =  t_itab_min-belnr
        and augdt in r_date
        and BELNR <> t_itab_min-belnr
*        and GJAHR =  t_itab_min-GJAHR
        and LIFNR =  t_itab_min-LIFNR ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  endloop.

ENDFORM.                    " SELECCION_DATOS1
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV_SALIDA1
*&---------------------------------------------------------------------*
FORM CREA_ALV_SALIDA1 .
  "esta tabla tiene las llave posiciones minimas
  loop at t_itab_min.
    "esta tabla tiene las llave posiciones maximas de cada caduco
    READ TABLE t_itab_max with key LLAVE = t_itab_min-LLAVE.

    loop at ti_bsak into wa_bsak where augbl = t_itab_min-BELNR
                                   and augdt = t_itab_min-budat
*                                   and GJAHR = t_itab_min-GJAHR
                                   and LIFNR = t_itab_min-LIFNR.

      t_itab_min-zuonr         = wa_bsak-zuonr.
      t_itab_min-belnr_orig    = wa_bsak-belnr.
      t_itab_min-budat_orig    = wa_bsak-budat.
      t_itab_min-bldat_orig    = wa_bsak-bldat.
      t_itab_min-blart_orig    = wa_bsak-blart.
      t_itab_min-GJAHR_orig    = wa_bsak-GJAHR.
      t_itab_min-wrbtr_orig    = wa_bsak-WRBTR.
      t_itab_min-estado_actual = t_itab_max-CAMBIO_ESTADO.

      t_itab_min-belnr_max     = t_itab_max-belnr.
      t_itab_min-GJAHR_max     = t_itab_max-GJAHR.
      t_itab_min-BLART_max     = t_itab_max-BLART.
      t_itab_min-BLDAT_max     = t_itab_max-BLDAT.
      t_itab_min-BUDAT_max     = t_itab_max-BUDAT.
      t_itab_min-wrbtr_max     = t_itab_max-wrbtr.
      t_itab_min-chect_max     = t_itab_max-chect.
      t_itab_min-hbkid_max     = t_itab_max-hbkid.
      t_itab_min-hktid_max     = t_itab_max-hktid.

      append t_itab_min to ti_salida.

    endloop.
    clear t_itab_min.
  endloop.

ENDFORM.                    " CREA_ALV_SALIDA1
*&---------------------------------------------------------------------*
*&      Form  SELECCION_DATOS2
*&---------------------------------------------------------------------*
FORM SELECCION_DATOS2 .

  "se rescatan las posciciones asociados al motivo de emision
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_itab
*    from ZFITR020_T01
*    where BUKRS in p_bukrs2
*      and budat in p_budat2
*      and blart in p_rango2
*      and MOTIVO_EMISION in p_motem2
*      and BELNR in p_belnr2
*      and GJAHR in p_gjahr2.
*
* NEW CODE
  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_itab

    from ZFITR020_T01
    where BUKRS in p_bukrs2
      and budat in p_budat2
      and blart in p_rango2
      and MOTIVO_EMISION in p_motem2
      and BELNR in p_belnr2
      and GJAHR in p_gjahr2 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


  if t_itab[] is INITIAL.
    MESSAGE 'No se encontraron datos' type 'E'.
  endif.

  sort t_itab by LLAVE LLAVE_POS DESCENDING.

  "se rescata solo el movimiento maximo de cada motivo
  LOOP AT t_itab.
    on CHANGE OF t_itab-llave.
      APPEND t_itab to t_itab_max.
    endon.
  endloop.

  "se rescata el primer movimiento de cada llave
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * into CORRESPONDING FIELDS OF TABLE t_itab_min
*    from ZFITR020_T01 FOR ALL ENTRIES IN t_itab_max
*    where BUKRS = t_itab_max-bukrs
*      and llave = t_itab_max-LLAVE
*      and LLAVE_POS = '1'
*      and blart = 'ZP'.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE t_itab_min
    from ZFITR020_T01 FOR ALL ENTRIES IN t_itab_max
    where BUKRS = t_itab_max-bukrs
      and llave = t_itab_max-LLAVE
      and LLAVE_POS = '1'
      and blart = 'ZP' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
**ins ini
    sort t_itab_min by bukrs blart belnr bldat budat gjahr.
**ins fin
  "se ordenan y borran los duplicados
  sort t_itab3 by belnr gjahr llave llave_pos.
*ReSQ: No Need Of Change Internal Table T_ITAB_MIN Already Sorted
  delete ADJACENT DUPLICATES FROM t_itab_min.

  ranges: r_date for bsak-augdt .
  loop at t_itab_min.
    clear r_date[]. CLEAR r_date.

    r_date-sign   = 'I'."I, incluir, E excluir.
    r_date-option = 'BT'. "eq igual, bt between, NE no igual
    CONCATENATE t_itab_min-GJAHR '0101' into r_date-low    .
    CONCATENATE t_itab_min-GJAHR '1231' INTO r_date-high   .
    append r_date.
    "se rescatan los folios asociados a los movimientos
    "minimos
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select * APPENDING CORRESPONDING FIELDS OF TABLE ti_bsak
*      from bsak "FOR ALL ENTRIES IN t_itab_min
*      where BUKRS =  t_itab_min-bukrs
*        and augbl =  t_itab_min-belnr
*        and augdt in r_date
*        and BELNR <> t_itab_min-belnr
**      and GJAHR =  t_itab_min-GJAHR
*        and LIFNR =  t_itab_min-LIFNR.
*
* NEW CODE
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ti_bsak

      from bsak "FOR ALL ENTRIES IN t_itab_min
      where BUKRS =  t_itab_min-bukrs
        and augbl =  t_itab_min-belnr
        and augdt in r_date
        and BELNR <> t_itab_min-belnr
*      and GJAHR =  t_itab_min-GJAHR
        and LIFNR =  t_itab_min-LIFNR ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  endloop.
  "
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * into CORRESPONDING FIELDS OF TABLE t_itab2
*   from ZFITR020_T01 FOR ALL ENTRIES IN t_itab
*   where BELNR = t_itab-VBLNR_PAGO
*     and GJAHR = t_itab-gjahr_pago
*     and BUKRS = t_itab-BUKRS.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE t_itab2
   from ZFITR020_T01 FOR ALL ENTRIES IN t_itab
   where BELNR = t_itab-VBLNR_PAGO
     and GJAHR = t_itab-gjahr_pago
     and BUKRS = t_itab-BUKRS ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


ENDFORM.                    " SELECCION_DATOS2
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV_SALIDA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREA_ALV_SALIDA2 .
  "esta tabla tiene las llave posiciones minimas
  loop at t_itab_min.
    "esta tabla tiene las llave posiciones maximas de cada caduco
    READ TABLE t_itab_max with key LLAVE = t_itab_min-LLAVE.

    READ TABLE t_itab2 with key LLAVE = t_itab_min-llave.

    loop at ti_bsak into wa_bsak where augbl = t_itab_min-BELNR
                                   and augdt = t_itab_min-budat
*                                   and GJAHR = t_itab_min-GJAHR
                                   and LIFNR = t_itab_min-LIFNR.

      t_itab_min-zuonr         = wa_bsak-zuonr.
      t_itab_min-belnr_orig    = wa_bsak-belnr.
      t_itab_min-budat_orig    = wa_bsak-budat.
      t_itab_min-bldat_orig    = wa_bsak-bldat.
      t_itab_min-blart_orig    = wa_bsak-blart.
      t_itab_min-GJAHR_orig    = wa_bsak-GJAHR.
      t_itab_min-wrbtr_orig    = wa_bsak-WRBTR.
      t_itab_min-estado_actual =  t_itab_max-CAMBIO_ESTADO.

      t_itab_min-belnr_max     = t_itab_max-belnr.
      t_itab_min-GJAHR_max     = t_itab_max-GJAHR.
      t_itab_min-BLART_max     = t_itab_max-BLART.
      t_itab_min-BLDAT_max     = t_itab_max-BLDAT.
      t_itab_min-BUDAT_max     = t_itab_max-BUDAT.
      t_itab_min-wrbtr_max     = t_itab_max-wrbtr.
      t_itab_min-chect_max     = t_itab_max-chect.
      t_itab_min-hbkid_max     = t_itab_max-hbkid.
      t_itab_min-hktid_max     = t_itab_max-hktid.

      t_itab_min-belnr_max2     = t_itab2-belnr.
      t_itab_min-GJAHR_max2     = t_itab2-GJAHR.
      t_itab_min-BLART_max2     = t_itab2-BLART.
      t_itab_min-BLDAT_max2     = t_itab2-BLDAT.
      t_itab_min-BUDAT_max2     = t_itab2-BUDAT.
      t_itab_min-wrbtr_max2     = t_itab2-wrbtr.
      t_itab_min-chect_max2     = t_itab2-chect.
      t_itab_min-hbkid_max2     = t_itab2-hbkid.
      t_itab_min-hktid_max2     = t_itab2-hktid.
      append t_itab_min to ti_salida.

    endloop.
    clear t_itab_min.
  endloop.
ENDFORM.                    " CREA_ALV_SALIDA2
*&---------------------------------------------------------------------*
*&      Form  SELECCION_DATOS3
*&---------------------------------------------------------------------*
FORM SELECCION_DATOS3 .

  "selecciona los datos minimos de manera directa
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_itab
*    from ZFITR020_T01
*    where BUKRS in p_bukrs3
*      and budat in p_budat3
*      and blart in p_rango3
*      and MOTIVO_EMISION in p_motem3
*      and LLAVE_POS eq '1'
*      and BELNR in p_belnr3
*      and GJAHR in p_gjahr3.
*
* NEW CODE
  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_itab

    from ZFITR020_T01
    where BUKRS in p_bukrs3
      and budat in p_budat3
      and blart in p_rango3
      and MOTIVO_EMISION in p_motem3
      and LLAVE_POS eq '1'
      and BELNR in p_belnr3
      and GJAHR in p_gjahr3 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  if t_itab[] is INITIAL.
    MESSAGE 'No se encontraron datos' type 'E'.
  endif.

  ranges: r_date for bsak-augdt .
  loop at t_itab.
    clear r_date[]. CLEAR r_date.

    r_date-sign   = 'I'."I, incluir, E excluir.
    r_date-option = 'BT'. "eq igual, bt between, NE no igual
    CONCATENATE t_itab-GJAHR '0101' into r_date-low    .
    CONCATENATE t_itab-GJAHR '1231' INTO r_date-high   .
    append r_date.

    "busca los folios respectivos
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select * APPENDING CORRESPONDING FIELDS OF TABLE ti_bsak
*      from bsak "FOR ALL ENTRIES IN t_itab
*      where BUKRS =  t_itab-bukrs
*        and augbl =  t_itab-belnr
*        and augdt in r_date
*        and BELNR <> t_itab-belnr
**        and GJAHR =  t_itab-GJAHR
*        and LIFNR =  t_itab-LIFNR.
*
* NEW CODE
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ti_bsak

      from bsak "FOR ALL ENTRIES IN t_itab
      where BUKRS =  t_itab-bukrs
        and augbl =  t_itab-belnr
        and augdt in r_date
        and BELNR <> t_itab-belnr
*        and GJAHR =  t_itab-GJAHR
        and LIFNR =  t_itab-LIFNR ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  endloop.
  "busca todos los movientos relacionados a la llave
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * into CORRESPONDING FIELDS OF TABLE t_itab2
*   from ZFITR020_T01 FOR ALL ENTRIES IN t_itab
*   where LLAVE = t_itab-LLAVE.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE t_itab2
   from ZFITR020_T01 FOR ALL ENTRIES IN t_itab
   where LLAVE = t_itab-LLAVE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  "ordena  y borra los duplicados
  sort t_itab2 by  LLAVE  DESCENDING LLAVE_POS DESCENDING.
  delete ADJACENT DUPLICATES FROM t_itab2.

  "rescata solo las posiciones maximas por llave de
  "cada caduco
  LOOP AT t_itab2.
    on CHANGE OF t_itab2-llave.
      APPEND t_itab2 to t_itab3.
    endon.
  endloop.

ENDFORM.                    " SELECCION_DATOS3
*&---------------------------------------------------------------------*
*&      Form  CREA_ALV_SALIDA3
*&---------------------------------------------------------------------*
FORM CREA_ALV_SALIDA3 .
  "esta tabla tiene las llave posiciones minimas
  loop at t_itab.

    "esta tabla tiene las llave posiciones maximas
    "de cada caduco
    READ TABLE t_itab3 with key LLAVE = t_itab-llave.

    "repetimos la informacion por cada folio encontrado
    loop at ti_bsak into wa_bsak where augbl = t_itab-BELNR
                                   and augdt = t_itab-budat
*                                   and GJAHR = t_itab-GJAHR
                                   and LIFNR = t_itab-LIFNR.

      t_itab-zuonr         = wa_bsak-zuonr.
      t_itab-belnr_orig    = wa_bsak-belnr.
      t_itab-budat_orig    = wa_bsak-budat.
      t_itab-bldat_orig    = wa_bsak-bldat.
      t_itab-blart_orig    = wa_bsak-blart.
      t_itab-GJAHR_orig    = wa_bsak-GJAHR.
      t_itab-wrbtr_orig    = wa_bsak-WRBTR.
      t_itab-estado_actual = t_itab3-CAMBIO_ESTADO.

      t_itab-belnr_max     = t_itab3-belnr.
      t_itab-GJAHR_max     = t_itab3-GJAHR.
      t_itab-BLART_max     = t_itab3-BLART.
      t_itab-BLDAT_max     = t_itab3-BLDAT.
      t_itab-BUDAT_max     = t_itab3-BUDAT.
      t_itab-wrbtr_max     = t_itab3-wrbtr.
      t_itab-chect_max     = t_itab3-chect.
      t_itab-hbkid_max     = t_itab3-hbkid.
      t_itab-hktid_max     = t_itab3-hktid.
      append t_itab to ti_salida.

    endloop.
    clear t_itab.
  endloop.
ENDFORM.                    " CREA_ALV_SALIDA3
*&---------------------------------------------------------------------*
*&      Form  COLOREA_COLUMNAS
*&---------------------------------------------------------------------*
FORM COLOREA_COLUMNAS .
  try.
      gr_columns = gr_table->get_columns( ).

      "celeste fuerte
      gr_column ?= gr_columns->get_column( 'BUKRS' ).      color-col = '1'.  color-int = '1'.  color-inv = '0'. gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'ZUONR' ).      color-col = '1'.  color-int = '1'.  color-inv = '0'. gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BELNR_ORIG' ). color-col = '1'.  color-int = '1'.  color-inv = '0'. gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BUDAT_ORIG' ). color-col = '1'.  color-int = '1'.  color-inv = '0'. gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BLDAT_ORIG' ). color-col = '1'.  color-int = '1'.  color-inv = '0'. gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BLART_ORIG' ). color-col = '1'.  color-int = '1'.  color-inv = '0'. gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'GJAHR_ORIG' ). color-col = '1'.  color-int = '1'.  color-inv = '0'. gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'WRBTR_ORIG' ). color-col = '1'.  color-int = '1'.  color-inv = '0'. gr_column->set_color( color ).
      "verde fuerte
      gr_column ?= gr_columns->get_column( 'ESTADO_ACTUAL' ). color-col = '5'.  color-int = '1'.  color-inv = '0'. gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'LLAVE' ).         color-col = '5'.  color-int = '1'.  color-inv = '0'. gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'LLAVE_POS' ).     color-col = '5'.  color-int = '1'.  color-inv = '0'. gr_column->set_color( color ).
      "naranjo suave
      gr_column ?= gr_columns->get_column( 'BELNR_MAX ' ).   color-col = '3'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'GJAHR_MAX ' ).   color-col = '3'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BLART_MAX ' ).   color-col = '3'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BLDAT_MAX ' ).   color-col = '3'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BUDAT_MAX ' ).   color-col = '3'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'WRBTR_MAX ' ).   color-col = '3'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'CHECT_MAX ' ).   color-col = '3'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'HBKID_MAX ' ).   color-col = '3'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'HKTID_MAX ' ).   color-col = '3'.    color-int = '0'.  gr_column->set_color( color ).
      "verde suave
      gr_column ?= gr_columns->get_column( 'BELNR_MAX2 ' ).  color-col = '5'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'GJAHR_MAX2 ' ).  color-col = '5'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BLART_MAX2 ' ).  color-col = '5'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BLDAT_MAX2 ' ).  color-col = '5'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'BUDAT_MAX2 ' ).  color-col = '5'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'WRBTR_MAX2 ' ).  color-col = '5'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'CHECT_MAX2 ' ).  color-col = '5'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'HBKID_MAX2 ' ).  color-col = '5'.    color-int = '0'.  gr_column->set_color( color ).
      gr_column ?= gr_columns->get_column( 'HKTID_MAX2 ' ).  color-col = '5'.    color-int = '0'.  gr_column->set_color( color ).

    CATCH cx_salv_not_found.
  ENDTRY.

ENDFORM.                    " COLOREA_COLUMNAS
*&---------------------------------------------------------------------*
*&      Form  OCULTA_COLUMNAS
*&---------------------------------------------------------------------*
FORM OCULTA_COLUMNAS .
  try.
      gr_columns = gr_table->get_columns( ).
      if tabname <> '102'.
        gr_column ?= gr_columns->get_column( 'BELNR_MAX2 ' ). gr_column->set_visible( abap_false ).
        gr_column ?= gr_columns->get_column( 'GJAHR_MAX2 ' ). gr_column->set_visible( abap_false ).
        gr_column ?= gr_columns->get_column( 'BLART_MAX2 ' ). gr_column->set_visible( abap_false ).
        gr_column ?= gr_columns->get_column( 'BLDAT_MAX2 ' ). gr_column->set_visible( abap_false ).
        gr_column ?= gr_columns->get_column( 'BUDAT_MAX2 ' ). gr_column->set_visible( abap_false ).
        gr_column ?= gr_columns->get_column( 'WRBTR_MAX2 ' ). gr_column->set_visible( abap_false ).
        gr_column ?= gr_columns->get_column( 'CHECT_MAX2 ' ). gr_column->set_visible( abap_false ).
        gr_column ?= gr_columns->get_column( 'HBKID_MAX2 ' ). gr_column->set_visible( abap_false ).
        gr_column ?= gr_columns->get_column( 'HKTID_MAX2 ' ). gr_column->set_visible( abap_false ).
      endif.

    CATCH cx_salv_not_found.
  ENDTRY.
ENDFORM.                    " OCULTA_COLUMNAS
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
      gr_column->set_long_text(   'C.P. Ejercicio' ).
      gr_column->set_medium_text( 'C.P. Ejercicio' ).
      gr_column->set_short_text(  'C.P.Ejer.' ).

      gr_column ?= gr_columns->get_column( 'WRBTR_ORIG' ).
      gr_column->set_long_text(   'C.P. Importe' ).
      gr_column->set_medium_text( 'C.P. Importe' ).
      gr_column->set_short_text(  'C.P.Imp.' ).

      gr_column ?= gr_columns->get_column( 'ESTADO_ACTUAL' ).
      gr_column->set_long_text(   'Estado actual' ).
      gr_column->set_medium_text( 'Estado actual' ).
      gr_column->set_short_text(  'Est. act.' ).

    CATCH cx_salv_not_found.
  ENDTRY."SET_COLOR
ENDFORM.                    " CAMBIA_HEADERS
