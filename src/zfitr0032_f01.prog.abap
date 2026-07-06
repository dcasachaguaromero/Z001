*&---------------------------------------------------------------------*
*&  Include           ZFITR0032_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INICIALIZA_VAR
*&---------------------------------------------------------------------*
FORM inicializa_var .
  gv_column = 0.
  CLEAR : gt_hist[].
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS_FECHA
*&---------------------------------------------------------------------*
FORM lee_datos_fecha .
  DATA : ti_bkpf   TYPE TABLE OF ty_bkpf,
         wa_bkpf   TYPE ty_bkpf,
         lv_column TYPE i.
*
  SELECT bukrs belnr gjahr blart budat waers INTO TABLE ti_bkpf
         FROM bkpf WHERE bukrs IN s_bukrs AND
                         belnr IN s_belnr AND
                         cpudt IN s_cpudt AND
                         blart IN s_blart.
  gv_column = 1.
  LOOP AT ti_bkpf INTO wa_bkpf.
    gv_belnr  = wa_bkpf-belnr.
    gv_corr   = 0.
    CLEAR wa_hist_bkpf.
*
    MOVE-CORRESPONDING wa_bkpf TO wa_hist_bkpf.
    MOVE : wa_bkpf-bukrs TO wa_hist_bkpf-bukrs_clr,
           wa_bkpf-belnr TO wa_hist_bkpf-belnr_clr,
           wa_bkpf-gjahr TO wa_hist_bkpf-gjahr_clr,
           wa_bkpf-blart TO wa_hist_bkpf-blart,
*
           wa_bkpf-budat TO wa_hist_bkpf-budat,
           wa_bkpf-waers TO wa_hist_bkpf-waers.
**
    PERFORM lee_flujo USING wa_bkpf
                      CHANGING lv_column.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS_Z6
*&---------------------------------------------------------------------*
FORM lee_datos_z6 .
  DATA : ti_bkpf   TYPE TABLE OF ty_bkpf,
         wa_bkpf   TYPE ty_bkpf,
         lv_column TYPE i.
*
  SELECT bukrs belnr gjahr blart budat waers INTO TABLE ti_bkpf
         FROM bkpf WHERE bukrs IN s_bukrs AND
                         belnr IN s_belnr AND
                         cpudt IN s_cpudt AND
                         blart IN s_blaz6 ORDER BY PRIMARY KEY.
*
  gv_column = 1.
  LOOP AT ti_bkpf INTO wa_bkpf.
    gv_belnr  = wa_bkpf-belnr.
    gv_corr   = 0.
    CLEAR wa_hist_bkpf.
*
    MOVE-CORRESPONDING wa_bkpf TO wa_hist_bkpf.
    MOVE : wa_bkpf-bukrs TO wa_hist_bkpf-bukrs_clr,
           wa_bkpf-belnr TO wa_hist_bkpf-belnr_clr,
           wa_bkpf-gjahr TO wa_hist_bkpf-gjahr_clr,
           wa_bkpf-blart TO wa_hist_bkpf-blart,
*
           wa_bkpf-budat TO wa_hist_bkpf-budat,
           wa_bkpf-waers TO wa_hist_bkpf-waers.
**
    PERFORM lee_flujo USING wa_bkpf
                      CHANGING lv_column.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_FLUJO
*&---------------------------------------------------------------------*
FORM lee_flujo USING p_wa_bkpf TYPE ty_bkpf
                     p_column.
  TYPES : BEGIN OF ty_base_clr ,
            bukrs_clr	TYPE bkpf-bukrs,
            belnr_clr TYPE bse_clr-belnr,
            gjahr_clr TYPE bse_clr-gjahr,
            bukrs     TYPE bse_clr-bukrs,
            belnr     TYPE bse_clr-belnr,
            gjahr     TYPE bse_clr-gjahr,
            buzei     TYPE bse_clr-buzei,
            index_clr TYPE bse_clr-index_clr,
          END OF ty_base_clr .
*
  DATA : ti_base_clr   TYPE TABLE OF ty_base_clr,
         wa_bkpf       TYPE ty_bkpf,
         wa_base_clr   TYPE ty_base_clr,
         lw_hist_bkpf  TYPE ty_hist,
         lv_zzmot_emis TYPE zzmot_emis,
         lv_buzei      TYPE buzei,
         lv_blart      TYPE blart,
         lv_budat      TYPE budat,
         lv_waers      TYPE waers,
         lv_lifnr      TYPE lifnr,
         lv_wrbtr      TYPE wrbtr,
         lv_sgtxt      TYPE sgtxt,
         lv_stblg      TYPE stblg,
         lv_stjah      TYPE stjah,
         lv_corr       TYPE numc06,
         lv_lines      TYPE sytabix.
*
  CASE gc_x.
    WHEN p_codz6.
      SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei
           INTO CORRESPONDING FIELDS OF TABLE ti_base_clr
           FROM bse_clr  WHERE bukrs  EQ p_wa_bkpf-bukrs AND
                               belnr  EQ p_wa_bkpf-belnr AND
                               gjahr  EQ p_wa_bkpf-gjahr AND
                               buzei  IN s_buzei
                               ORDER BY PRIMARY KEY.
      IF sy-subrc EQ 0.
        DELETE ADJACENT DUPLICATES FROM ti_base_clr
           COMPARING bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr.
*
        CLEAR s_buzei. REFRESH s_buzei.
        SORT ti_base_clr BY belnr gjahr buzei.
        LOOP AT ti_base_clr INTO wa_base_clr.
          IF gv_belnr NE wa_base_clr-belnr.
            ADD 1 TO p_column.
            IF p_column GT gv_column.
              gv_column = p_column.
            ENDIF.
          ELSE.
            ADD 1 TO gv_corr.
            CONCATENATE wa_hist_bkpf-bukrs wa_hist_bkpf-gjahr
                        wa_hist_bkpf-belnr gv_corr        INTO gv_clave.
            PERFORM lee_motiv_emis USING wa_base_clr-bukrs
                                         wa_base_clr-belnr
                                         wa_base_clr-gjahr
                                         wa_base_clr-buzei
                                         ''
                                   CHANGING gv_zzmot_emis
                                            lv_buzei
                                            lv_lifnr
                                            lv_wrbtr
                                            lv_sgtxt.
            MOVE : gv_zzmot_emis   TO wa_hist_bkpf-zzmot_emis,
                   gv_zzmot_emis   TO wa_hist_bkpf-zzmot_emis_or,
                   gv_clave        TO wa_hist_bkpf-clave,
                   lv_buzei        TO wa_hist_bkpf-buzei,
*
                   lv_lifnr        TO wa_hist_bkpf-lifnr,
                   lv_wrbtr        TO wa_hist_bkpf-wrbtr,
                   lv_sgtxt        TO wa_hist_bkpf-sgtxt.
*
            IF gv_zzmot_emis IS INITIAL.
              wa_hist_bkpf-error      = gc_x.
            ENDIF.
*
            APPEND wa_hist_bkpf TO gt_hist.
            p_column = 1.
          ENDIF.
*
          PERFORM lee_motiv_emis USING wa_base_clr-bukrs_clr
                                       wa_base_clr-belnr_clr
                                       wa_base_clr-gjahr_clr
                                       wa_base_clr-buzei
                                       gc_x
                                 CHANGING lv_zzmot_emis
                                          lv_buzei
                                          lv_lifnr
                                          lv_wrbtr
                                          lv_sgtxt.
*
          SELECT SINGLE blart budat waers stblg stjah
                 INTO (lv_blart, lv_budat, lv_waers, lv_stblg,lv_stjah )
                 FROM bkpf WHERE bukrs  EQ wa_base_clr-bukrs_clr AND
                                 belnr  EQ wa_base_clr-belnr_clr AND
                                 gjahr  EQ wa_base_clr-gjahr_clr AND
                                 blart  IN s_blart."               AND
*                                 stblg  EQ space.
          IF sy-subrc EQ 0.
            IF lv_blart IN s_blaz6.
              CONTINUE.
            ENDIF.
*
            MOVE-CORRESPONDING wa_base_clr TO wa_hist.
            wa_hist-clave         = gv_clave.
            wa_hist-zzmot_emis    = lv_zzmot_emis.
            wa_hist-zzmot_emis_or = gv_zzmot_emis.
            wa_hist-blart         = lv_blart.
            wa_hist-buzei         = lv_buzei.
            wa_hist-error         = ''.
*
            wa_hist-lifnr         = lv_lifnr.
            wa_hist-wrbtr         = lv_wrbtr.
            wa_hist-sgtxt         = lv_sgtxt.
            wa_hist-budat         = lv_budat.
            wa_hist-waers         = lv_waers.
*
*            IF lv_blart IN s_blaz6.
*              MOVE: lv_lifnr        TO wa_hist_bkpf-lifnr,
*                    lv_wrbtr        TO wa_hist_bkpf-wrbtr,
*                    lv_budat        TO wa_hist_bkpf-budat,
*                    lv_waers        TO wa_hist_bkpf-waers,
*                    lv_sgtxt        TO wa_hist_bkpf-sgtxt.
*            ENDIF.
*
            IF lv_zzmot_emis NE gv_zzmot_emis OR lv_zzmot_emis IS INITIAL.
              wa_hist-error      = gc_x.
            ENDIF.
            APPEND wa_hist TO gt_hist.
          ENDIF.
*
          MOVE : wa_base_clr-bukrs_clr TO wa_bkpf-bukrs,
                 wa_base_clr-belnr_clr TO wa_bkpf-belnr,
                 wa_base_clr-gjahr_clr TO wa_bkpf-gjahr,
                 lv_blart              TO wa_bkpf-blart,
*
                 lv_budat              TO wa_bkpf-budat,
                 lv_waers              TO wa_bkpf-waers.
*
          PERFORM lee_flujo USING wa_bkpf
                            CHANGING p_column.
        ENDLOOP.
      ENDIF.
    WHEN OTHERS.
      SELECT bukrs_clr belnr_clr gjahr_clr bukrs belnr gjahr buzei
           INTO CORRESPONDING FIELDS OF TABLE ti_base_clr
           FROM bse_clr  WHERE bukrs_clr  EQ p_wa_bkpf-bukrs AND
                               belnr_clr  EQ p_wa_bkpf-belnr AND
                               gjahr_clr  EQ p_wa_bkpf-gjahr
                               ORDER BY PRIMARY KEY.
      IF sy-subrc EQ 0.
        lv_lines = 0.
        LOOP AT ti_base_clr INTO wa_base_clr.
          IF gv_belnr NE wa_base_clr-belnr_clr.
            ADD 1 TO lv_lines.
            IF lv_lines GT 1.
              ADD 1 TO gv_corr.
              CONCATENATE wa_hist_bkpf-bukrs wa_hist_bkpf-gjahr
                          wa_hist_bkpf-belnr gv_corr        INTO gv_clave.

              SELECT SINGLE blart budat waers
                     INTO (lv_blart, lv_budat, lv_waers )
                     FROM bkpf WHERE bukrs  EQ wa_base_clr-bukrs_clr AND
                                     belnr  EQ wa_base_clr-belnr_clr AND
                                     gjahr  EQ wa_base_clr-gjahr_clr AND
                                     blart  IN s_blart.

              PERFORM lee_motiv_emis USING wa_base_clr-bukrs_clr
                                           wa_base_clr-belnr_clr
                                           wa_base_clr-gjahr_clr
                                           '001'
                                           gc_x
                                     CHANGING gv_zzmot_emis
                                              lv_buzei
                                              lv_lifnr
                                              lv_wrbtr
                                              lv_sgtxt.

              lw_hist_bkpf-bukrs_clr     = wa_base_clr-bukrs_clr.
              lw_hist_bkpf-belnr_clr     = wa_base_clr-belnr_clr.
              lw_hist_bkpf-gjahr_clr     = wa_base_clr-gjahr_clr.
              lw_hist_bkpf-bukrs         = wa_base_clr-bukrs_clr.
              lw_hist_bkpf-belnr         = wa_base_clr-belnr_clr.
              lw_hist_bkpf-gjahr         = wa_base_clr-gjahr_clr.
              lw_hist_bkpf-clave         = gv_clave.
              lw_hist_bkpf-buzei         = lv_buzei.
              lw_hist_bkpf-zzmot_emis    = lv_zzmot_emis.
              lw_hist_bkpf-blart         = lv_blart.
              lw_hist_bkpf-lifnr         = lv_lifnr.
              lw_hist_bkpf-wrbtr         = lv_wrbtr.
              lw_hist_bkpf-sgtxt         = lv_sgtxt.
              lw_hist_bkpf-budat         = lv_budat.
              lw_hist_bkpf-waers         = lv_waers.
*
              APPEND lw_hist_bkpf TO gt_hist.
              p_column = 1.
            ELSE.
              ADD 1 TO p_column.
              IF p_column GT gv_column.
                gv_column = p_column.
              ENDIF.
            ENDIF.
          ELSE.
            ADD 1 TO gv_corr.
            CONCATENATE wa_hist_bkpf-bukrs wa_hist_bkpf-gjahr
                        wa_hist_bkpf-belnr gv_corr        INTO gv_clave.

            SELECT SINGLE blart budat waers
                   INTO (lv_blart, lv_budat, lv_waers )
                   FROM bkpf WHERE bukrs  EQ wa_base_clr-bukrs_clr AND
                                   belnr  EQ wa_base_clr-belnr_clr AND
                                   gjahr  EQ wa_base_clr-gjahr_clr AND
                                   blart  IN s_blart.

            PERFORM lee_motiv_emis USING wa_base_clr-bukrs_clr
                                         wa_base_clr-belnr_clr
                                         wa_base_clr-gjahr_clr
                                         '001'
                                         gc_x
                                   CHANGING gv_zzmot_emis
                                            lv_buzei
                                            lv_lifnr
                                            lv_wrbtr
                                            lv_sgtxt.
            MOVE : gv_zzmot_emis   TO wa_hist_bkpf-zzmot_emis,
                   gv_clave        TO wa_hist_bkpf-clave,
                   lv_buzei        TO wa_hist_bkpf-buzei,
                   lv_blart        TO wa_hist_bkpf-blart,
                   lv_budat        TO wa_hist_bkpf-budat,
                   lv_waers        TO wa_hist_bkpf-waers.
*
            IF gv_zzmot_emis IS INITIAL.
              wa_hist_bkpf-error      = gc_x.
            ENDIF.
*
            IF  wa_hist_bkpf-blart IN s_blaz6.
              MOVE : gv_zzmot_emis   TO wa_hist_bkpf-zzmot_emis_or,
                     lv_lifnr        TO wa_hist_bkpf-lifnr,
                     lv_wrbtr        TO wa_hist_bkpf-wrbtr,
                     lv_sgtxt        TO wa_hist_bkpf-sgtxt,
                     lv_budat        TO wa_hist_bkpf-budat,
                     lv_waers        TO wa_hist_bkpf-waers.
            ENDIF.
*
            APPEND wa_hist_bkpf TO gt_hist.
            p_column = 1.
          ENDIF.
*
          PERFORM lee_motiv_emis USING wa_base_clr-bukrs
                                       wa_base_clr-belnr
                                       wa_base_clr-gjahr
                                       wa_base_clr-buzei
                                       ''
                                 CHANGING lv_zzmot_emis
                                          lv_buzei
                                          lv_lifnr
                                          lv_wrbtr
                                          lv_sgtxt.
*
          SELECT SINGLE blart budat waers
                 INTO (lv_blart, lv_budat, lv_waers )
                 FROM bkpf WHERE bukrs  EQ wa_base_clr-bukrs AND
                                 belnr  EQ wa_base_clr-belnr AND
                                 gjahr  EQ wa_base_clr-gjahr AND
                                 blart  IN s_blart           AND
                                 stblg  EQ space.
          IF sy-subrc EQ 0.
            wa_hist-bukrs_clr     = wa_base_clr-bukrs.
            wa_hist-belnr_clr     = wa_base_clr-belnr.
            wa_hist-gjahr_clr     = wa_base_clr-gjahr.
            wa_hist-bukrs         = wa_base_clr-bukrs_clr.
            wa_hist-belnr         = wa_base_clr-belnr_clr.
            wa_hist-gjahr         = wa_base_clr-gjahr_clr.
            wa_hist-clave         = gv_clave.
            wa_hist-buzei         = lv_buzei.
            wa_hist-zzmot_emis    = lv_zzmot_emis.
            wa_hist-blart         = lv_blart.
*
            wa_hist-lifnr         = lv_lifnr.
            wa_hist-wrbtr         = lv_wrbtr.
            wa_hist-sgtxt         = lv_sgtxt.
            wa_hist-budat         = lv_budat.
            wa_hist-waers         = lv_waers.
*
            wa_hist-error         = ''.

            IF  wa_hist-blart IN s_blaz6. "EQ 'Z6'.
              MOVE : lv_zzmot_emis   TO wa_hist-zzmot_emis_or,
                     lv_lifnr        TO wa_hist_bkpf-lifnr,
                     lv_wrbtr        TO wa_hist_bkpf-wrbtr,
                     lv_sgtxt        TO wa_hist_bkpf-sgtxt,
                     lv_budat        TO wa_hist_bkpf-budat,
                     lv_waers        TO wa_hist_bkpf-waers.
            ENDIF.
*
            IF lv_zzmot_emis NE gv_zzmot_emis OR lv_zzmot_emis IS INITIAL.
              wa_hist-error      = gc_x.
            ENDIF.
            APPEND wa_hist TO gt_hist.
*
            IF  wa_hist-blart IN s_blaz6.
              CONTINUE.
            ENDIF.
          ENDIF.
*
          MOVE : wa_base_clr-bukrs TO wa_bkpf-bukrs,
                 wa_base_clr-belnr TO wa_bkpf-belnr,
                 wa_base_clr-gjahr TO wa_bkpf-gjahr,
                 lv_blart          TO wa_bkpf-blart,
*
                 lv_budat          TO wa_bkpf-budat,
                 lv_waers          TO wa_bkpf-waers.
*
          PERFORM lee_flujo USING wa_bkpf
                            CHANGING p_column.
        ENDLOOP.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: wa_hist    TYPE ty_hist,
        wa_display TYPE REF TO cl_salv_display_settings,
        lr_events  TYPE REF TO cl_salv_events_table.
*
  MOVE sy-repid           TO gv_repid.
*
  IF <table> IS ASSIGNED.
* Preparar tabla interna para mostrar
    cl_salv_table=>factory( "EXPORTING list_display = 'X'
                            IMPORTING r_salv_table = gv_table
                            CHANGING  t_table      = <table> ).
* Mandar titulo del reporte
* Set the Screen status (This precedes all other methods)
    PERFORM pf_status USING gv_table.
* Asignando nombre a las columnas
    PERFORM nombre_columnas.
*
    lr_events = gv_table->get_event( ).
    CREATE OBJECT gr_events.
    SET HANDLER gr_events->on_user_command FOR lr_events.
    SET HANDLER gr_events->on_double_click FOR lr_events.
    SET HANDLER gr_events->on_single_click FOR lr_events.
* Mostrar el reporte
    gv_table->display( ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREAR_TABLA
*&---------------------------------------------------------------------*
FORM crear_tabla.
  DATA: lt_comptab     TYPE abap_component_tab,
        wa_compline    TYPE abap_componentdescr,
        wa_structdescr TYPE REF TO cl_abap_structdescr,
        wa_tabledescr  TYPE REF TO cl_abap_tabledescr,
        wa_tabref      TYPE REF TO data,
        wa_data        TYPE REF TO data,
        wa_fieldcat    TYPE lvc_s_fcat,
        lv_name        TYPE string,
        lt_color       TYPE lvc_t_scol,
        lv_num         TYPE numc2.
*
  wa_compline-name        = 'BUKRS'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'BUKRS' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*
  wa_compline-name        = 'GJAHR'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'GJAHR' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*
  wa_compline-name        = 'BELNR'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'BELNR_D' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*
  wa_compline-name        = 'BUZEI'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'BUZEI' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*
  wa_compline-name        = 'ZZMOT_EMIS'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'ZZMOT_EMIS' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*
  wa_compline-name        = 'ZZMOT_EMIS_OR'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'ZZMOT_EMIS' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*
  wa_compline-name        = 'BLART'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'BLART' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*********************************************************
  wa_compline-name        = 'BUDAT'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'BUDAT' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*
  wa_compline-name        = 'WRBTR'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'WRBTR' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*
  wa_compline-name        = 'WAERS'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'WAERS' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*
  wa_compline-name        = 'LIFNR'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'LIFNR' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*
  wa_compline-name        = 'SGTXT'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'SGTXT' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*********************************************************
  DO gv_column TIMES.
    ADD 1 TO lv_num.
*
    CONCATENATE 'GJAHR' lv_num INTO lv_name.
    wa_compline-name        = lv_name.
    wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'GJAHR' ).
    wa_compline-as_include  = abap_false.
    wa_compline-suffix      = space.
    APPEND wa_compline TO lt_comptab.
*
    CONCATENATE 'BELNR' lv_num INTO lv_name.
    wa_compline-name        = lv_name.
    wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'BELNR_D' ).
    wa_compline-as_include  = abap_false.
    wa_compline-suffix      = space.
    APPEND wa_compline TO lt_comptab.
*
    CONCATENATE 'BUZEI' lv_num INTO lv_name.
    wa_compline-name        = lv_name.
    wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'BUZEI' ).
    wa_compline-as_include  = abap_false.
    wa_compline-suffix      = space.
    APPEND wa_compline TO lt_comptab.
*
    CONCATENATE 'ZZMOT_EMIS' lv_num INTO lv_name.
    wa_compline-name        = lv_name.
    wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'ZZMOT_EMIS' ).
    wa_compline-as_include  = abap_false.
    wa_compline-suffix      = space.
    APPEND wa_compline TO lt_comptab.
*
    CONCATENATE 'BLART' lv_num INTO lv_name.
    wa_compline-name        = lv_name.
    wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'BLART' ).
    wa_compline-as_include  = abap_false.
    wa_compline-suffix      = space.
    APPEND wa_compline TO lt_comptab.
*
    CONCATENATE 'BUDAT' lv_num INTO lv_name.
    wa_compline-name        = lv_name.
    wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'BUDAT' ).
    wa_compline-as_include  = abap_false.
    wa_compline-suffix      = space.
    APPEND wa_compline TO lt_comptab.
*
  ENDDO.
*
  wa_compline-name        = 'COLOR'.
  wa_compline-type        ?= cl_abap_datadescr=>describe_by_data( lt_color ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
*
  wa_compline-name        = 'ERROR'.
  wa_compline-type       ?= cl_abap_typedescr=>describe_by_name( 'XFLAG' ).
  wa_compline-as_include  = abap_false.
  wa_compline-suffix      = space.
  APPEND wa_compline TO lt_comptab.
* // Create a structure
  wa_structdescr = cl_abap_structdescr=>create( lt_comptab ).
  CREATE DATA wa_data TYPE HANDLE wa_structdescr.
  ASSIGN wa_data->* TO <lines>.
* // Then create a table
  wa_tabledescr = cl_abap_tabledescr=>create( wa_structdescr ).
  CREATE DATA wa_tabref TYPE HANDLE wa_tabledescr.
  ASSIGN wa_tabref->* TO <table>.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  NOMBRE_COLUMNAS
*&---------------------------------------------------------------------*
FORM nombre_columnas .
  DATA: lv_idx     TYPE numc2,
        lv_text(4) TYPE c,
        lv_colname TYPE lvc_fname,
        lv_outps   TYPE scrtext_s,
        lv_outpm   TYPE scrtext_m,
        lv_outpl   TYPE scrtext_l,
        lt_color   TYPE lvc_t_scol.
*
  gv_columns_table = gv_table->get_columns( ).
*
  lv_colname = 'BUKRS'.
  gv_column_table ?= gv_columns_table->get_column( lv_colname ).
  gv_column_table->set_optimized( value  = abap_true ).
*
  lv_colname = 'BELNR'.
  gv_column_table ?= gv_columns_table->get_column( lv_colname ).
  gv_column_table->set_cell_type( if_salv_c_cell_type=>hotspot ).
  gv_column_table->set_optimized( value  = abap_true ).
*
  lv_colname = 'ZZMOT_EMIS_OR'.
  MOVE 'Em.Inicial' TO lv_outps.
  lv_outpm = 'Emisión Inicial'.
  lv_outpl = 'Emisión Inicial'.
  gv_column_table ?= gv_columns_table->get_column( lv_colname ).
  gv_column_table->set_optimized( value  = abap_true ).
  gv_column_table->set_short_text( lv_outps ).
  gv_column_table->set_medium_text( lv_outpm ).
  gv_column_table->set_long_text( lv_outpl ).
  gv_column_table->set_visible( value  = if_salv_c_bool_sap=>false ).
******************************************************
  lv_colname = 'LIFNR'.
  MOVE 'Cuenta' TO lv_outps.
  lv_outpm = 'Cuenta'.
  lv_outpl = 'Cuenta'.
  gv_column_table ?= gv_columns_table->get_column( lv_colname ).
  gv_column_table->set_optimized( value  = abap_true ).
  gv_column_table->set_short_text( lv_outps ).
  gv_column_table->set_medium_text( lv_outpm ).
  gv_column_table->set_long_text( lv_outpl ).
*
  lv_colname = 'SGTXT'.
  MOVE 'Denominación' TO lv_outps.
  lv_outpm = 'Denominación'.
  lv_outpl = 'Denominación'.
  gv_column_table ?= gv_columns_table->get_column( lv_colname ).
  gv_column_table->set_optimized( value  = abap_true ).
  gv_column_table->set_short_text( lv_outps ).
  gv_column_table->set_medium_text( lv_outpm ).
  gv_column_table->set_long_text( lv_outpl ).
*
  lv_colname = 'WRBTR'.
  gv_column_table ?= gv_columns_table->get_column( lv_colname ).
  gv_column_table->set_currency_column( 'WAERS' ). "Currency Key
*
  lv_colname = 'WAERS'.
  gv_column_table ?= gv_columns_table->get_column( lv_colname ).
  gv_column_table->set_visible( value  = if_salv_c_bool_sap=>false ).
******************************************************
  lv_colname = 'ERROR'.
  MOVE 'Error' TO lv_outps.
  lv_outpm = lv_outps.
  lv_outpl = lv_outps.
  gv_column_table ?= gv_columns_table->get_column( lv_colname ).
  gv_column_table->set_optimized( value  = abap_true ).
  gv_column_table->set_short_text( lv_outps ).
  gv_column_table->set_medium_text( lv_outpm ).
  gv_column_table->set_long_text( lv_outpl ).
*
  gv_columns_table->set_color_column( 'COLOR' ).
*
  DO gv_column TIMES.
    ADD 1 TO lv_idx.
    CONCATENATE 'BELNR' lv_idx INTO lv_colname.
    CONCATENATE 'Docum.' lv_idx INTO lv_outps.
    lv_outpm = lv_outps.
    lv_outpl = lv_outps.
    gv_column_table ?= gv_columns_table->get_column( lv_colname ).
    gv_column_table->set_cell_type( if_salv_c_cell_type=>hotspot ).
    gv_column_table->set_optimized( value  = abap_true ).
    gv_column_table->set_alignment( value  = 1 ).
    gv_column_table->set_zero( value  = space ).
    gv_column_table->set_short_text( lv_outps ).
    gv_column_table->set_medium_text( lv_outpm ).
    gv_column_table->set_long_text( lv_outpl ).
*
    CONCATENATE 'GJAHR' lv_idx INTO lv_colname.
    lv_outps = 'Año'.
    lv_outpm = 'Año'.
    lv_outpl = 'Año'.
    gv_column_table ?= gv_columns_table->get_column( lv_colname ).
    gv_column_table->set_optimized( value  = abap_true ).
    gv_column_table->set_alignment( value  = 1 ).
    gv_column_table->set_zero( value  = space ).
    gv_column_table->set_short_text( lv_outps ).
    gv_column_table->set_medium_text( lv_outpm ).
    gv_column_table->set_long_text( lv_outpl ).
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECCIONA_BLART
*&---------------------------------------------------------------------*
FORM selecciona_blart .

  SELECT sign opti low high INTO TABLE s_blart
    FROM tvarvc WHERE name EQ 'ZFI_MOTIVEMIS_BLART'.
*
  CLEAR s_blaz6[].
  s_blaz6-sign = 'I'.     s_blaz6-option = 'EQ'.
  s_blaz6-low  = 'Z6'.    APPEND s_blaz6.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUEVE_DATOS
*&---------------------------------------------------------------------*
FORM mueve_datos .
  DATA : wa_hist_paso     TYPE ty_hist,
         wa_hist          TYPE ty_hist,
         lv_campo         TYPE char50,
         lv_belnr         TYPE belnr_d,
         lt_color         TYPE lvc_t_scol,
         ls_color         LIKE LINE OF lt_color,
         lv_error         TYPE char01,
         lv_blart         TYPE char01,
         lv_zzmot_emis_or TYPE zzmot_emis,
         lv_num           TYPE numc2,
         lt_sort_tab      TYPE abap_sortorder_tab,
         lw_sort_tab      TYPE abap_sortorder.
  FIELD-SYMBOLS : <valor> TYPE any.
*
  CHECK <table> IS ASSIGNED.
* sí se seleccionan por fecha ordena el proceso desde el
* documento más antiguo.
  IF p_codz6 IS INITIAL.
    SORT gt_hist BY clave bukrs_clr gjahr_clr budat belnr_clr.
  ENDIF.
*
  LOOP AT gt_hist INTO wa_hist_paso.
    MOVE-CORRESPONDING wa_hist_paso TO wa_hist.
    AT NEW clave.
      CLEAR : <lines>, lt_color, lv_error, lv_blart, lv_zzmot_emis_or.
      IF p_codz6 IS INITIAL AND wa_hist-blart IN s_blaz6. "EQ 'Z6'.
        MOVE : wa_hist-bukrs_clr TO wa_hist-bukrs,
               wa_hist-belnr_clr TO wa_hist-belnr,
               wa_hist-gjahr_clr TO wa_hist-gjahr.
      ENDIF.
      MOVE-CORRESPONDING wa_hist TO <lines>.
      lv_num = 0.
    ENDAT.
*
    IF lv_num GT 0.
      CONCATENATE '<LINES>-BELNR'      lv_num INTO lv_campo.
      ASSIGN (lv_campo) TO <valor>.
      <valor> = wa_hist-belnr_clr.
**
      ls_color-fname     = lv_campo+8().
      IF p_codz6 IS INITIAL AND lv_blart EQ gc_x.
        IF wa_hist-zzmot_emis NE lv_zzmot_emis_or.
          wa_hist-error = gc_x.
        ELSE.
          wa_hist-error = ''.
        ENDIF.
      ENDIF.
      IF wa_hist-error EQ gc_x.
        lv_error = gc_x.
        ls_color-color-col = '6'.
      ELSE.
        ls_color-color-col = '1'.
      ENDIF.
      ls_color-color-int = '0'.
      APPEND ls_color TO lt_color.
*
      CONCATENATE '<LINES>-GJAHR'      lv_num INTO lv_campo.
      ASSIGN (lv_campo) TO <valor>.
      <valor> = wa_hist-gjahr_clr.

      ls_color-fname     = lv_campo+8().
      ls_color-color-col = '1'.
      ls_color-color-int = '1'.
      APPEND ls_color TO lt_color.
*
      CONCATENATE '<LINES>-BUZEI'      lv_num INTO lv_campo.
      ASSIGN (lv_campo) TO <valor>.
      <valor> = wa_hist-buzei.
*
      CONCATENATE '<LINES>-ZZMOT_EMIS' lv_num INTO lv_campo.
      ASSIGN (lv_campo) TO <valor>.
      <valor> = wa_hist-zzmot_emis.
*
      CONCATENATE '<LINES>-BLART' lv_num INTO lv_campo.
      ASSIGN (lv_campo) TO <valor>.
      <valor> = wa_hist-blart.
*
      CONCATENATE '<LINES>-BUDAT' lv_num INTO lv_campo.
      ASSIGN (lv_campo) TO <valor>.
      <valor> = wa_hist-budat.
    ENDIF.
    ADD 1 TO lv_num.
*
    IF wa_hist-blart IN s_blaz6. "EQ 'Z6'.
      MOVE '<LINES>-ZZMOT_EMIS_OR' TO lv_campo.
      ASSIGN (lv_campo) TO <valor>.
      <valor>          = wa_hist-zzmot_emis_or.
      lv_zzmot_emis_or = wa_hist-zzmot_emis_or.
      lv_blart         = gc_x.
    ENDIF.
*
    AT END OF clave.
      IF lv_blart EQ gc_x AND lv_num GT 1.
        IF ( p_error EQ gc_x AND lv_error EQ gc_x ) OR
             p_error IS INITIAL.
          MOVE '<LINES>-COLOR' TO lv_campo.
          ASSIGN (lv_campo) TO <valor>.
          <valor> = lt_color[].
*
          IF lv_error EQ gc_x.
            MOVE '<LINES>-ERROR' TO lv_campo.
            ASSIGN (lv_campo) TO <valor>.
            <valor> = gc_x.
          ENDIF.
*
          APPEND <lines> TO <table>.
        ENDIF.
      ENDIF.
      lv_num = 0.
      CLEAR : <lines>, lt_color, lv_error, lv_blart, lv_zzmot_emis_or.
    ENDAT.
  ENDLOOP.

*
  lw_sort_tab-name = 'BUKRS'.
  APPEND lw_sort_tab TO lt_sort_tab.
  lw_sort_tab-name = 'GJAHR'.
  APPEND lw_sort_tab TO lt_sort_tab.
  lw_sort_tab-name = 'BELNR'.
  APPEND lw_sort_tab TO lt_sort_tab.
  lw_sort_tab-name = 'BUZEI'.
  APPEND lw_sort_tab TO lt_sort_tab.
*
  SORT <table> BY (lt_sort_tab).
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_MOTIV_EMIS
*&---------------------------------------------------------------------*
FORM lee_motiv_emis  USING    p_bukrs
                              p_belnr
                              p_gjahr
                              p_buzei
                              p_sem
                     CHANGING p_lv_zzmot_emis
                              p_buzei_sal
                              p_lifnr
                              p_wrbtr
                              p_sgtxt.
*
  DATA : lv_buzei TYPE buzei.
* Busca la posicon del documento buscado.
  IF p_sem EQ gc_x.
    SELECT SINGLE buzei INTO lv_buzei
         FROM bse_clr  WHERE bukrs  EQ p_bukrs AND
                             belnr  EQ p_belnr AND
                             gjahr  EQ p_gjahr.
    IF sy-subrc NE 0.
      lv_buzei = p_buzei.
    ENDIF.
  ELSE.
    lv_buzei = p_buzei.
  ENDIF.
*
*
  CLEAR : p_lv_zzmot_emis, p_buzei_sal, p_lifnr, p_wrbtr.
  SELECT SINGLE zzmot_emis buzei lifnr wrbtr sgtxt
         INTO (p_lv_zzmot_emis, p_buzei_sal, p_lifnr, p_wrbtr, p_sgtxt )
         FROM bseg WHERE bukrs  EQ p_bukrs AND
                         belnr  EQ p_belnr AND
                         gjahr  EQ p_gjahr AND
                         buzei  EQ lv_buzei.
  CHECK p_lv_zzmot_emis IS INITIAL.
  SELECT SINGLE zzmot_emis buzei lifnr wrbtr sgtxt
         INTO (p_lv_zzmot_emis, p_buzei_sal, p_lifnr, p_wrbtr, p_sgtxt )
         FROM bseg WHERE bukrs      EQ p_bukrs AND
                         belnr      EQ p_belnr AND
                         gjahr      EQ p_gjahr AND
                         zzmot_emis NE space AND
                         koart      IN ('K','D').
  CHECK p_lv_zzmot_emis IS INITIAL.
  SELECT SINGLE zzmot_emis buzei lifnr wrbtr sgtxt
         INTO (p_lv_zzmot_emis, p_buzei_sal, p_lifnr, p_wrbtr, p_sgtxt )
         FROM bseg WHERE bukrs      EQ p_bukrs AND
                         belnr      EQ p_belnr AND
                         gjahr      EQ p_gjahr AND
                         zzmot_emis EQ space AND
                         koart      IN ('K','D').
*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_DOCUMENTO_FI
*&---------------------------------------------------------------------*
FORM lee_documento_fi  USING    p_row
                                p_column.
  DATA : lv_campo   TYPE char50,
         lv_valores TYPE ty_bkpf.
  FIELD-SYMBOLS : <bukrs> TYPE any,
                  <belnr> TYPE any,
                  <gjahr> TYPE any.
*
  READ TABLE <table> INTO <lines> INDEX p_row.
  CONCATENATE '<lines>-' p_column INTO lv_campo.
  ASSIGN (lv_campo) TO <belnr>.
  IF <belnr> IS ASSIGNED .
    CONCATENATE '<lines>-GJAHR' p_column+5(2) INTO lv_campo.
    ASSIGN (lv_campo) TO <gjahr>.
    MOVE-CORRESPONDING <lines> TO lv_valores.
    SET PARAMETER ID : 'BLN' FIELD <belnr>,
                       'BUK' FIELD lv_valores-bukrs,
                       'GJR' FIELD <gjahr>.
    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status  USING gv_table TYPE REF TO cl_salv_table.
  DATA : fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE,
         ce_func_exclude  TYPE slis_t_extab,
         lo_functions     TYPE REF TO cl_salv_functions,
         lt_func_list     TYPE salv_t_ui_func,
         la_func_list     LIKE LINE OF lt_func_list.
*
* function: participation-list
  fcode_attrib_tab-text      = 'ACTUAL'.
  fcode_attrib_tab-icon_id   = '@01@'.
  fcode_attrib_tab-icon_text = 'ACTUAL'.
  fcode_attrib_tab-quickinfo = space.
  fcode_attrib_tab-path      = space.
  APPEND fcode_attrib_tab.
*
  PERFORM dynamic_report_fcodes(rhteiln0) TABLES fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.
*
  gv_table->set_screen_status(
    pfstatus      =  'ALVLIST'
    report        =  'RHTEILN0'
    set_functions = gv_table->c_functions_all ).
* Get all functions
  lo_functions =   gv_table->get_functions( ).
  lt_func_list = lo_functions->get_functions( ).

* Now hide the ICONS
  LOOP AT lt_func_list INTO la_func_list.
    CASE la_func_list-r_function->get_name( ).
      WHEN 'CNOT'OR 'DNOT'.
        la_func_list-r_function->set_visible( ' ' ).
      WHEN 'FC01'.
    ENDCASE.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command USING i_ucomm TYPE salv_de_function.
*
  CASE i_ucomm.
    WHEN 'FC01'.
      PERFORM ajusta_motivo.
      gv_table->refresh( refresh_mode = if_salv_c_refresh=>full ).
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AJUSTA_MOTIVO
*&---------------------------------------------------------------------*
FORM ajusta_motivo .
  TYPES : BEGIN OF ty_error,
            bukrs         TYPE bkpf-bukrs,
            belnr         TYPE bkpf-belnr,
            gjahr         TYPE bkpf-gjahr,
            blart         TYPE bkpf-blart,
            zzmot_emis    TYPE zzmot_emis,
            zzmot_emis_or TYPE zzmot_emis,
            error         TYPE char01,
          END OF ty_error.
  DATA : wa_error  TYPE  ty_error,
         lv_campo  TYPE char50,
         lv_tabix  TYPE sytabix,
         lv_num    TYPE numc2,
         lv_commit TYPE i,
         lt_color  TYPE lvc_t_scol,
         ls_color  LIKE LINE OF lt_color.
  FIELD-SYMBOLS : <belnr>    TYPE any,
                  <gjahr>    TYPE any,
                  <buzei>    TYPE any,
                  <blart>    TYPE any,
                  <valor>    TYPE any,
                  <mot_emis> TYPE any.
*
  LOOP AT <table> INTO <lines>.
    MOVE sy-tabix TO lv_tabix.
*
    ADD 1 TO lv_commit.
    MOVE-CORRESPONDING <lines> TO wa_error.
    CHECK wa_error-error EQ gc_x AND
          wa_error-zzmot_emis_or IS NOT INITIAL.
    lv_num = 0.
    CLEAR lt_color[].
*
    IF  wa_error-zzmot_emis NE wa_error-zzmot_emis_or AND
        wa_error-blart NE 'Z6'.
      MOVE '<LINES>-ZZMOT_EMIS' TO lv_campo.
      ASSIGN (lv_campo)         TO <mot_emis>.
      <mot_emis> = wa_error-zzmot_emis_or.
    ENDIF.
*
    DO gv_column TIMES.
      ADD 1 TO lv_num.
      CONCATENATE '<LINES>-BELNR' lv_num        INTO lv_campo.
      ASSIGN (lv_campo) TO <belnr> .
      IF <belnr> IS NOT INITIAL.
        CONCATENATE '<LINES>-ZZMOT_EMIS' lv_num INTO lv_campo.
        ASSIGN (lv_campo) TO <mot_emis>.
        CHECK <mot_emis> NE wa_error-zzmot_emis_or.

        CONCATENATE '<LINES>-BLART' lv_num      INTO lv_campo.
        ASSIGN (lv_campo) TO <blart>.
        CHECK <blart> NE 'Z6'."SOLO MODIFICAR DOCUMENTO DISTINTOS DE Z6
*
        CONCATENATE '<LINES>-GJAHR' lv_num      INTO lv_campo.
        ASSIGN (lv_campo) TO <gjahr> .
        CONCATENATE '<LINES>-BUZEI' lv_num      INTO lv_campo.
        ASSIGN (lv_campo) TO <buzei> .
*
        IF <blart> EQ 'ZP'."actualiza todas las posiciones del documento
          UPDATE bseg SET zzmot_emis = wa_error-zzmot_emis_or
                      WHERE bukrs EQ wa_error-bukrs AND
                            belnr EQ <belnr>        AND
                            gjahr EQ <gjahr>.
        ELSE.
          UPDATE bseg SET zzmot_emis = wa_error-zzmot_emis_or
                      WHERE bukrs EQ wa_error-bukrs AND
                            belnr EQ <belnr>        AND
                            gjahr EQ <gjahr>        AND
                            buzei EQ <buzei>.
        ENDIF.
*
        <mot_emis> =  wa_error-zzmot_emis_or.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
*
    MOVE '<LINES>-ERROR' TO lv_campo.
    ASSIGN (lv_campo) TO <valor>.
    <valor> = ''.
*
    APPEND ls_color TO lt_color.
    MOVE '<LINES>-COLOR' TO lv_campo.
    ASSIGN (lv_campo) TO <valor>.
    <valor> = lt_color[].
*
    MODIFY  <table> FROM <lines> INDEX lv_tabix.
*
    CHECK lv_commit GT 10000.
    COMMIT WORK AND WAIT.
    lv_commit = 0.
  ENDLOOP.
*
  COMMIT WORK AND WAIT.
ENDFORM.
