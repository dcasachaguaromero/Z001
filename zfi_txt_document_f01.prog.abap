*&---------------------------------------------------------------------*
*&  Include           ZFI_TXT_DOCUMENT_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZA_TEXTO.
*&---------------------------------------------------------------------*
FORM actualiza_texto .
  DATA : lt_buztab TYPE tpit_t_buztab,
         lw_buztab TYPE tpit_buztab,
         lv_fin    TYPE xflag.
  DATA: go_functions TYPE REF TO cl_salv_functions,
        go_display   TYPE REF TO cl_salv_display_settings,
        go_columns   TYPE REF TO cl_salv_columns_table,
        go_column    TYPE REF TO cl_salv_column,
        gx_salv_msg  TYPE REF TO  cx_salv_msg.
*
  SELECT bukrs, belnr, gjahr, bktxt
        INTO TABLE @DATA(lt_bkpf)
*Begin V1 - MJD nuevos 04/04/2023 parametros de selección
*       FROM bkpf WHERE cpudt IN @s_cpudt
        FROM bkpf WHERE bukrs in @s_bukrp
                    AND belnr IN @s_belnr
                    AND gjahr IN @s_gjahr
                    AND blart IN @s_blart
                    AND cpudt IN @s_cpudt.
*End V1 - MJD nuevos 04/04/2023 parametros de selección
  CHECK sy-subrc EQ 0.

  SELECT bukrs, belnr, gjahr, sgtxt, buzei, koart, bschl, kunnr, lifnr, hkont, kontl
        INTO TABLE @DATA(lt_bseg)
        FROM bseg FOR ALL ENTRIES IN @lt_bkpf
             WHERE bukrs EQ @lt_bkpf-bukrs
               AND gjahr EQ @lt_bkpf-gjahr
               AND belnr EQ @lt_bkpf-belnr
               AND sgtxt EQ @space.
  CHECK sy-subrc EQ 0.
*
  SORT lt_bseg BY bukrs belnr gjahr buzei.
  LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<lw_bseg>).
*
    CLEAR <lw_bseg>-kontl.
    CASE <lw_bseg>-koart.
      WHEN 'D'.
* nombre del solicitante
        IF NOT line_exists( gt_kunnr[ kunnr = <lw_bseg>-kunnr ] ).
          lcl_report=>read_kunnr( EXPORTING iv_kunnr = <lw_bseg>-kunnr
                                  IMPORTING lw_kunnr = DATA(lw_kunnr)
                                  CHANGING  ct_kunnr = gt_kunnr  ).
        ELSE.
          lw_kunnr = gt_kunnr[ kunnr = <lw_bseg>-kunnr ].
          IF lw_kunnr-name1 IS INITIAL.
            lw_kunnr-name1 = <lw_bseg>-kunnr.
          ENDIF.
        ENDIF.
        <lw_bseg>-sgtxt = lw_kunnr-name1.
      WHEN 'K'.
* nombre del Acreedor
        IF NOT line_exists( gt_lifnr[ lifnr = <lw_bseg>-lifnr ] ).
          lcl_report=>read_lifnr( EXPORTING iv_lifnr = <lw_bseg>-lifnr
                                  IMPORTING lw_lifnr = DATA(lw_lifnr)
                                  CHANGING  ct_lifnr = gt_lifnr  ).
        ELSE.
          lw_lifnr = gt_lifnr[ lifnr = <lw_bseg>-lifnr ].
          IF lw_lifnr-name1 IS INITIAL.
            lw_lifnr-name1 = <lw_bseg>-lifnr.
          ENDIF.
        ENDIF.
        <lw_bseg>-sgtxt = lw_lifnr-name1.
      WHEN OTHERS.
* LEE LOS DATSO DE CABECERA
        DATA(lw_bkpf) = lt_bkpf[ bukrs = <lw_bseg>-bukrs
                                 belnr = <lw_bseg>-belnr
                                 gjahr = <lw_bseg>-gjahr ].

        IF lw_bkpf-bktxt IS NOT INITIAL.
          <lw_bseg>-sgtxt = lw_bkpf-bktxt.
        ELSE.
* nombre del Acreedor
          IF NOT line_exists( gt_hkont[ hkont = <lw_bseg>-hkont ] ).
            lcl_report=>read_hkont( EXPORTING iv_hkont = <lw_bseg>-hkont
                                    IMPORTING lw_hkont = DATA(lw_hkont)
                                    CHANGING  ct_hkont = gt_hkont  ).
          ELSE.
            lw_hkont = gt_hkont[ hkont = <lw_bseg>-hkont ].
            IF lw_hkont-txt20 IS INITIAL.
              lw_hkont-txt20 =  <lw_bseg>-hkont.
            ENDIF.
          ENDIF.

          <lw_bseg>-sgtxt = lw_hkont-txt20.
        ENDIF.
    ENDCASE.

    MODIFY lt_bseg FROM <lw_bseg> TRANSPORTING sgtxt.
  ENDLOOP.
*
  SORT lt_bseg BY bukrs  belnr gjahr sgtxt buzei.
  LOOP AT lt_bseg ASSIGNING <lw_bseg>.
*
    MOVE-CORRESPONDING <lw_bseg> TO lw_buztab.
    APPEND lw_buztab TO lt_buztab.
**
    AT END OF sgtxt.
      lv_fin = gc_x.
    ENDAT.

    AT END OF belnr.
      lv_fin = 'F'.
    ENDAT.

    IF lv_fin IS NOT INITIAL..
      PERFORM actualiza_sgtxt TABLES lt_buztab
                              CHANGING <lw_bseg>-sgtxt
                                       <lw_bseg>-kontl.
      COMMIT WORK AND WAIT.
      CLEAR : lv_fin, lt_buztab[].
      WAIT UP TO 1 SECONDS.
    ENDIF.
  ENDLOOP.
* prepara los datos para el reporte de salida
  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          list_display = if_salv_c_bool_sap=>false
        IMPORTING
          r_salv_table = gt_table
        CHANGING
          t_table      = lt_bseg.

      go_functions = gt_table->get_functions( ).
      go_functions->set_all( abap_true ).

      go_display = gt_table->get_display_settings( ).
      go_display->set_striped_pattern( abap_true ).
      go_columns = gt_table->get_columns( ).
      go_columns->set_optimize( abap_true ).

      go_column = go_columns->get_column( 'KONTL' ).
      go_column->set_short_text( 'MENSAJE' ).
      go_column->set_medium_text( 'MENSAJE ERROR' ).
      go_column->set_long_text( 'MENSAJE ERROR' ).

    CATCH cx_salv_msg INTO gx_salv_msg.
      MESSAGE 'error' TYPE 'E'.
  ENDTRY.

  gt_table->display( ).

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ACTUALIZA_TEXTO_HIST
*&---------------------------------------------------------------------*
FORM actualiza_texto_hist .
  DATA : lt_buztab TYPE tpit_t_buztab,
         lv_fin    TYPE xflag,
         lw_buztab TYPE tpit_buztab,
         lv_table  TYPE tabname,
         lv_count  TYPE i,
         lv_tabix  TYPE sytabix.
  DATA: go_functions TYPE REF TO cl_salv_functions,
        go_display   TYPE REF TO cl_salv_display_settings,
        go_columns   TYPE REF TO cl_salv_columns_table,
        go_column    TYPE REF TO cl_salv_column,
        gx_salv_msg  TYPE REF TO  cx_salv_msg.
*
  SELECT bukrs, belnr, gjahr, sgtxt
         INTO TABLE @DATA(lt_histo) UP TO @p_lineas ROWS
         FROM zlogtxt WHERE bukrs     IN @s_bukrs
                        AND gjahr     IN @s_gjahr
                        AND procesado EQ @space
                        ORDER BY PRIMARY KEY.
  CHECK sy-subrc EQ 0.
  DELETE ADJACENT DUPLICATES FROM lt_histo COMPARING bukrs belnr gjahr.
*
  SELECT bukrs, belnr, gjahr, bktxt
        INTO TABLE @DATA(lt_bkpf)
        FROM bkpf FOR ALL ENTRIES IN @lt_histo
             WHERE bukrs EQ @lt_histo-bukrs
               AND gjahr EQ @lt_histo-gjahr
               AND belnr EQ @lt_histo-belnr.
  CHECK sy-subrc EQ 0.

  SELECT bukrs, belnr, gjahr, buzei, koart, bschl, kunnr, lifnr, hkont, sgtxt, kontl
        INTO TABLE @DATA(lt_bseg)
        FROM bseg FOR ALL ENTRIES IN @lt_bkpf
             WHERE bukrs EQ @lt_bkpf-bukrs
               AND gjahr EQ @lt_bkpf-gjahr
               AND belnr EQ @lt_bkpf-belnr.


  SORT lt_bseg BY bukrs belnr gjahr buzei.
  LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<lw_bseg>).
    MOVE sy-tabix TO lv_tabix.
*
    CLEAR <lw_bseg>-kontl.
    IF <lw_bseg>-sgtxt IS INITIAL.
      CASE <lw_bseg>-koart.
        WHEN 'D'.
* nombre del solicitante
          IF NOT line_exists( gt_kunnr[ kunnr = <lw_bseg>-kunnr ] ).
            lcl_report=>read_kunnr( EXPORTING iv_kunnr = <lw_bseg>-kunnr
                                    IMPORTING lw_kunnr = DATA(lw_kunnr)
                                    CHANGING  ct_kunnr = gt_kunnr  ).
          ELSE.
            lw_kunnr = gt_kunnr[ kunnr = <lw_bseg>-kunnr ].
            IF lw_kunnr-name1 IS INITIAL.
              lw_kunnr-name1 = <lw_bseg>-kunnr.
            ENDIF.
          ENDIF.
          <lw_bseg>-sgtxt = lw_kunnr-name1.
        WHEN 'K'.
* nombre del Acreedor
          IF NOT line_exists( gt_lifnr[ lifnr = <lw_bseg>-lifnr ] ).
            lcl_report=>read_lifnr( EXPORTING iv_lifnr = <lw_bseg>-lifnr
                                    IMPORTING lw_lifnr = DATA(lw_lifnr)
                                    CHANGING  ct_lifnr = gt_lifnr  ).
          ELSE.
            lw_lifnr = gt_lifnr[ lifnr = <lw_bseg>-lifnr ].
            IF lw_lifnr-name1 IS INITIAL.
              lw_lifnr-name1 = <lw_bseg>-lifnr.
            ENDIF.
          ENDIF.
          <lw_bseg>-sgtxt = lw_lifnr-name1.
        WHEN OTHERS.
* LEE LOS DATSO DE CABECERA
          DATA(lw_bkpf) = lt_bkpf[ bukrs = <lw_bseg>-bukrs
                                   belnr = <lw_bseg>-belnr
                                   gjahr = <lw_bseg>-gjahr ].

          IF lw_bkpf-bktxt IS NOT INITIAL.
            <lw_bseg>-sgtxt = lw_bkpf-bktxt.
          ELSE.
* nombre del Acreedor
            IF NOT line_exists( gt_hkont[ hkont = <lw_bseg>-hkont ] ).
              lcl_report=>read_hkont( EXPORTING iv_hkont = <lw_bseg>-hkont
                                      IMPORTING lw_hkont = DATA(lw_hkont)
                                      CHANGING  ct_hkont = gt_hkont  ).
            ELSE.
              lw_hkont = gt_hkont[ hkont = <lw_bseg>-hkont ].
              IF lw_hkont-txt20 IS INITIAL.
                lw_hkont-txt20 =  <lw_bseg>-hkont.
              ENDIF.
            ENDIF.
            <lw_bseg>-sgtxt = lw_hkont-txt20.
          ENDIF.
      ENDCASE.
    ELSE.
* verifica que las otras tablas tengan un valor distinto en el texto
* para ajustar el documento.
      CASE <lw_bseg>-koart.
        WHEN 'D'.    MOVE 'BSID' TO lv_table.
        WHEN 'K'.    MOVE 'BSIK' TO lv_table.
        WHEN OTHERS. MOVE 'BSIS' TO lv_table.
      ENDCASE.

      DO 2 TIMES.
        SELECT COUNT( * ) INTO lv_count
               FROM (lv_table) WHERE bukrs EQ <lw_bseg>-bukrs
                                 AND gjahr EQ <lw_bseg>-gjahr
                                 AND belnr EQ <lw_bseg>-belnr
                                 AND sgtxt NE <lw_bseg>-sgtxt.
        IF lv_count GT 0.
          EXIT.
        ELSE.
          CASE <lw_bseg>-koart.
            WHEN 'D'.    MOVE 'BSAD' TO lv_table.
            WHEN 'K'.    MOVE 'BSAK' TO lv_table.
            WHEN OTHERS. MOVE 'BSAS' TO lv_table.
          ENDCASE.
        ENDIF.
      ENDDO.
*
      IF lv_count EQ 0.
        <lw_bseg>-kontl = 'Documento ya ajustado, no se trata'.
* actualiza tabla de log como procesado.
        UPDATE zlogtxt SET procesado = gc_x
                      WHERE bukrs EQ <lw_bseg>-bukrs
                        AND gjahr EQ <lw_bseg>-gjahr
                        AND belnr EQ <lw_bseg>-belnr.
        COMMIT WORK AND WAIT.
      ELSE.
        DATA(lv_len) = strlen( <lw_bseg>-sgtxt ).
        IF lv_len LT 50.
          <lw_bseg>-sgtxt = <lw_bseg>-sgtxt && '&'.
        ENDIF.
      ENDIF.
    ENDIF.
*
  ENDLOOP.
*
  SORT lt_bseg BY bukrs  belnr gjahr sgtxt buzei.
  LOOP AT lt_bseg ASSIGNING <lw_bseg> WHERE kontl IS INITIAL.
*
    MOVE-CORRESPONDING <lw_bseg> TO lw_buztab.
    APPEND lw_buztab TO lt_buztab.
**
    AT END OF sgtxt.
      lv_fin = gc_x.
    ENDAT.

    AT END OF belnr.
      lv_fin = 'F'.
    ENDAT.

    IF lv_fin IS NOT INITIAL.
*
      PERFORM actualiza_sgtxt TABLES lt_buztab
                              CHANGING <lw_bseg>-sgtxt
                                        <lw_bseg>-kontl.
* actualiza tabla de log como procesado.
      UPDATE zlogtxt SET procesado = gc_x
                    WHERE bukrs EQ <lw_bseg>-bukrs
                      AND gjahr EQ <lw_bseg>-gjahr
                      AND belnr EQ <lw_bseg>-belnr.
*
      COMMIT WORK AND WAIT.
      CLEAR : lv_fin, lt_buztab[].
      WAIT UP TO 1 SECONDS.

    ENDIF.
  ENDLOOP.
* prepara los datos para el reporte de salida
  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          list_display = if_salv_c_bool_sap=>false
        IMPORTING
          r_salv_table = gt_table
        CHANGING
          t_table      = lt_bseg.

      go_functions = gt_table->get_functions( ).
      go_functions->set_all( abap_true ).

      go_display = gt_table->get_display_settings( ).
      go_display->set_striped_pattern( abap_true ).

      go_columns = gt_table->get_columns( ).
      go_columns->set_optimize( abap_true ).

      go_column = go_columns->get_column( 'KONTL' ).
      go_column->set_short_text( 'MENSAJE' ).
      go_column->set_medium_text( 'MENSAJE ERROR' ).
      go_column->set_long_text( 'MENSAJE ERROR' ).

    CATCH cx_salv_msg INTO gx_salv_msg.
      MESSAGE 'error' TYPE 'E'.
  ENDTRY.

  gt_table->display( ).
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZA_SGTXT
*&---------------------------------------------------------------------*
FORM actualiza_sgtxt  TABLES lt_buztab TYPE tpit_t_buztab
                      CHANGING p_sgtxt
                               p_error.
  DATA : lt_fldtab TYPE tpit_t_fname,
         lt_errtab TYPE tpit_t_errdoc,
         ls_errtab TYPE tpit_errdoc,
         ls_msg    TYPE bdcmsgcoll,
         ls_fldtab TYPE tpit_fname,
         lv_len    TYPE i,
         es_bseg   TYPE bseg.
*
  CLEAR p_error.
  ls_fldtab-aenkz = abap_true.
  ls_fldtab-fname = 'SGTXT'.
  APPEND ls_fldtab TO lt_fldtab.
*
  es_bseg-sgtxt = p_sgtxt.
*
  CALL FUNCTION 'FI_ITEMS_MASS_CHANGE'
    EXPORTING
      s_bseg     = es_bseg
    IMPORTING
      errtab     = lt_errtab
    TABLES
      it_buztab  = lt_buztab
      it_fldtab  = lt_fldtab
    EXCEPTIONS
      bdc_errors = 1
      OTHERS     = 2.
  IF sy-subrc <> 0 OR lt_errtab[] IS NOT INITIAL.
    READ TABLE lt_errtab INTO ls_errtab INDEX 1.
    MOVE ls_errtab-err TO ls_msg.
    MESSAGE ID ls_msg-msgid TYPE ls_msg-msgtyp NUMBER ls_msg-msgnr
            INTO DATA(lv_mtext)
            WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4.

    p_error = 'ERROR:' && | | && lv_mtext.
  ELSE.
    p_error = 'Documento ajustado'.
* si el texto se forzo para producir el ajuste, se elimina y se actualiza nuevamente
    IF p_sgtxt IS NOT INITIAL.
      lv_len = strlen( p_sgtxt ) - 1.
      CHECK lv_len GT 0.
      IF p_sgtxt+lv_len(1) EQ '&'.
        p_sgtxt+lv_len(1) = ' '.
*
        es_bseg-sgtxt = p_sgtxt.
        CALL FUNCTION 'FI_ITEMS_MASS_CHANGE'
          EXPORTING
            s_bseg     = es_bseg
          IMPORTING
            errtab     = lt_errtab
          TABLES
            it_buztab  = lt_buztab
            it_fldtab  = lt_fldtab
          EXCEPTIONS
            bdc_errors = 1
            OTHERS     = 2.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
