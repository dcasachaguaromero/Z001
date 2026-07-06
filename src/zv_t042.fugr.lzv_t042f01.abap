*----------------------------------------------------------------------*
***INCLUDE LZV_T042F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  T001_LESEN
*&---------------------------------------------------------------------*
FORM t001_lesen USING    bukrs  LIKE t042-absbu.

  SELECT SINGLE * FROM  t001 INTO *t001 WHERE bukrs = bukrs.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CARGAR_DATOS
*&---------------------------------------------------------------------*
FORM cargar_datos.
  DATA : lr_absbu TYPE RANGE OF absbu.
*
  PERFORM vim_fill_wheretab.
  REFRESH total.
  CLEAR   total.
*
  SELECT username, absbu INTO TABLE @DATA(lt_absbu)
         FROM zt042_user WHERE username EQ @sy-uname
                           AND absbu    NE @space.
  IF sy-subrc EQ 0.
    lr_absbu = VALUE #( FOR lw_data IN lt_absbu
                        sign = 'I' option = 'EQ'
                         ( low = lw_data-absbu ) ).

* SOLO SOCIEDADES QUE TENGAN EMISORA
    APPEND |ABSBU IN LR_ABSBU| TO vim_wheretab.
*
    SELECT * FROM t042 WHERE (vim_wheretab) .
      CLEAR zv_t042 .
      zv_t042-mandt =
      t042-mandt .
      zv_t042-bukrs =
      t042-bukrs .
      zv_t042-zbukr =
      t042-zbukr .
      zv_t042-ulsk1 =
      t042-ulsk1 .
      zv_t042-ulsk2 =
      t042-ulsk2 .
      zv_t042-ulsd1 =
      t042-ulsd1 .
      zv_t042-ulsd2 =
      t042-ulsd2 .
      zv_t042-xkdfb =
      t042-xkdfb .
      zv_t042-xgbtr =
      t042-xgbtr .
      zv_t042-toltg =
      t042-toltg .
      zv_t042-sktug =
      t042-sktug .
      zv_t042-xskr1 =
      t042-xskr1 .
      zv_t042-absbu =
      t042-absbu .
      zv_t042-xuzaw =
      t042-xuzaw .
      zv_t042-xbptr =
      t042-xbptr .
      SELECT SINGLE * FROM t001 WHERE bukrs = t042-zbukr .
      IF sy-subrc EQ 0.
        zv_t042-butxt =
        t001-butxt .
      ENDIF.
      <vim_total_struc> = zv_t042.
      APPEND total.
    ENDSELECT.
    SORT total BY <vim_xtotal_key>.
    <status>-alr_sorted = 'R'.

*.check dynamic selectoptions (not in DDIC)...........................*
    IF x_header-selection NE space.
      PERFORM check_dynamic_select_options.
    ELSEIF x_header-delmdtflag NE space.
      PERFORM build_mainkey_tab.
    ENDIF.
    REFRESH extract.
  ELSE.
    MESSAGE 'Usuario sin Sociedades asignadas' TYPE 'I' DISPLAY LIKE 'I'.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALMACENA_TABLA_ORIG
*&---------------------------------------------------------------------*
FORM almacena_tabla_orig.

  zv_t042_total_resp[] = zv_t042_total[].
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GENERAR_LOG
*&---------------------------------------------------------------------*
FORM generar_log.
  DATA : lw_zt042_log TYPE zt042_log.
*
  LOOP AT zv_t042_total ASSIGNING FIELD-SYMBOL(<lw_datos>)
                                WHERE action IS NOT INITIAL.

    DATA(lv_index) = line_index( zv_t042_total_resp[ bukrs = <lw_datos>-bukrs ] ).
    CHECK lv_index GT 0.
    DATA(lw_datos) = zv_t042_total_resp[ lv_index ].
    IF lw_datos-absbu NE <lw_datos>-absbu OR
       lw_datos-zbukr NE <lw_datos>-zbukr.

      lw_zt042_log-bukrs     = <lw_datos>-bukrs.
      lw_zt042_log-datum     = sy-datum.
      lw_zt042_log-uzeit     = sy-uzeit.
      lw_zt042_log-uname     = sy-uname.
      lw_zt042_log-absbu     = <lw_datos>-absbu.
      lw_zt042_log-zbukr     = lw_datos-zbukr.
      lw_zt042_log-zbukr_act = <lw_datos>-zbukr.

      MODIFY zt042_log FROM lw_zt042_log.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_LOG
*&---------------------------------------------------------------------*
FORM muestra_log  USING    p_lv_bukrs
                           p_lv_absbu.
  DATA : lo_gr_alv  TYPE REF TO cl_salv_table,
         lo_columns TYPE REF TO cl_salv_columns,
         lo_column  TYPE REF TO cl_salv_column_table,
         lx_msg     TYPE REF TO cx_salv_msg.

  SELECT * INTO TABLE @DATA(lt_logs)
         FROM zt042_log WHERE bukrs EQ @p_lv_bukrs
                          AND absbu EQ @p_lv_absbu.
  SORT lt_logs BY datum DESCENDING uzeit DESCENDING.

  TRY.
      cl_salv_table=>factory(
      EXPORTING
          list_display = if_salv_c_bool_sap=>false
        IMPORTING
          r_salv_table = lo_gr_alv
        CHANGING
          t_table      = lt_logs  ).
* Default functions
      lo_gr_alv->get_functions( )->set_all( if_salv_c_bool_sap=>true ).
      lo_gr_alv->get_functions( )->set_view_excel( value = if_salv_c_bool_sap=>false ).
      lo_gr_alv->get_functions( )->set_graphics( value = if_salv_c_bool_sap=>false ).
      lo_gr_alv->get_functions( )->set_export_mail( value = if_salv_c_bool_sap=>false ).
*
      TRY.
* Fit the columns
          lo_columns = lo_gr_alv->get_columns( ).
          lo_columns->set_optimize( abap_true ).

          lo_column ?= lo_columns->get_column( 'BUKRS' ).
          lo_column->set_long_text( 'Sociedad' ).

          lo_column ?= lo_columns->get_column( 'ABSBU' ).
          lo_column->set_fixed_header_text( 'L' ).
          lo_column->set_long_text( 'Sociedad Emisora' ).

          lo_column ?= lo_columns->get_column( 'ZBUKR' ).
          lo_column->set_fixed_header_text( 'L' ).
          lo_column->set_long_text( 'Sociedad Pagadora Anterior' ).

          lo_column ?= lo_columns->get_column( 'ZBUKR_ACT' ).
          lo_column->set_fixed_header_text( 'L' ).
          lo_column->set_long_text( 'Sociedad Pagadora Actual' ).


        CATCH cx_salv_data_error .
      ENDTRY.

      lo_gr_alv->display( ).
*
    CATCH cx_salv_msg INTO lx_msg.
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  HELP_ZBUKR
*&---------------------------------------------------------------------*
FORM help_zbukr  CHANGING p_zv_t042_zbukr.
  DATA: f4_display     TYPE t_bool,
        lt_returnvalue TYPE TABLE OF ddshretval.
*
  SELECT absbu,butxt INTO TABLE @DATA(lt_zbukr)
       FROM zt042_user INNER JOIN t001
             ON zt042_user~absbu EQ t001~bukrs
                     WHERE username EQ @sy-uname.
*
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      window_title    = 'Sociedad Pagadora'
      retfield        = 'ABSBU'
      value_org       = 'S'
      display         = f4_display
    TABLES
      value_tab       = lt_zbukr
      return_tab      = lt_returnvalue
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc = 0.
    LOOP AT lt_returnvalue INTO DATA(ls_return).
      p_zv_t042_zbukr =  ls_return-fieldval.
      EXIT.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDA_ZBUKR
*&---------------------------------------------------------------------*
FORM valida_zbukr  USING    p_zv_t042_zbukr.

  CHECK p_zv_t042_zbukr IS NOT INITIAL.
  SELECT SINGLE absbu INTO @DATA(lv_absu)
       FROM zt042_user WHERE username EQ @sy-uname
                         AND absbu    EQ @p_zv_t042_zbukr.
  IF sy-subrc NE 0.
    MESSAGE e899(fi) WITH 'Sociedad Pagadora no asignada a usuario'.
  ENDIF.
ENDFORM.
