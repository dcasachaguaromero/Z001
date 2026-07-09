*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_100
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
  ENDCASE.

  REFRESH tab.
  MOVE 'CANCL' TO tab-fcode.
  APPEND tab.
  MOVE 'ACTUAL' TO tab-fcode.
  APPEND tab.
  SET  PF-STATUS 'ZFITR011' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0100  OUTPUT

MODULE status_0150 OUTPUT.

  REFRESH tab.
  MOVE 'CANCL' TO tab-fcode.
  APPEND tab.
  MOVE 'ACTUAL' TO tab-fcode.
  APPEND tab.

  SET  PF-STATUS 'ZFITR011' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100_exit INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
  ENDCASE.
  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0100_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA : xlinea LIKE tabla-top_line.

  CASE sy-ucomm.

    WHEN 'CONT'.
      IF  totalbco  <> '0.00' OR  totaldep  <> '0.00'.
        PERFORM confirma_contabilizacion.
      ELSE.
        MESSAGE i004(zfi) WITH 'Debe seleccionar informacion para contabilizar'.
      ENDIF.

    WHEN 'VALIDA'.

      CLEAR: totalbco, totaldep.

      LOOP AT int_tabla.
        IF int_tabla-sel = 'X'.
          totalbco = totalbco + int_tabla-montodev.
          totaldep = totaldep + int_tabla-montopend.
        ENDIF.
      ENDLOOP.

    WHEN 'SEL'.
      GET CURSOR FIELD cursorfield.
      GET CURSOR LINE xlinea.
      IF xlinea > 0 AND xlinea <= tabla-lines .
        xlinea = xlinea + tabla-top_line - 1.
**Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
*        SORT INT_TABLA .
**End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
        READ TABLE int_tabla INDEX xlinea.
        CLEAR sy-ucomm.
        PERFORM detalle.
      ENDIF.

  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0150 INPUT.

  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
    WHEN 'SELECT'.
      PERFORM select_all_entries   CHANGING gt_outtab[].
    WHEN 'DESELECT'.
      PERFORM deselect_all_entries CHANGING gt_outtab[].
    WHEN 'CONT'.
      CLEAR: totalbco, totaldep.
      LOOP AT gt_outtab WHERE sel EQ 'X'.
        totalbco = totalbco + gt_outtab-montodev.
        totaldep = totaldep + gt_outtab-montopend.
      ENDLOOP.
*
      IF  totalbco  <> '0.00' OR  totaldep  <> '0.00'.
        PERFORM confirma_contabilizacion.
        SET SCREEN 0.   "salida a la pantalla de selección
      ELSE.
        MESSAGE i004(zfi) WITH 'Debe seleccionar informacion para contabilizar'.
      ENDIF.
  ENDCASE.
ENDMODULE.
**&---------------------------------------------------------------------
**&      Module  FILL_TABLE_CONTROL  OUTPUT
**&---------------------------------------------------------------------
MODULE fill_table_control_0100 OUTPUT.

*ReSQ: No Need Of Change Internal Table INT_TABLA Already Sorted
  READ TABLE int_tabla INTO zfitr011_est_001 INDEX tabla-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT


*----------------------------------------------------------------------*
*  MODULE valida-grilla_0100 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE valida-grilla_0100 INPUT.

  IF zfitr011_est_001-montodif <> '0.00' AND zfitr011_est_001-sel = 'X'.
    zfitr011_est_001-sel = ''.
    MESSAGE i004(zfi) WITH 'Existen diferencias en linea seleccionada'.
  ELSE.
    IF zfitr011_est_001-montodev = '0.00' AND zfitr011_est_001-montopend = '0.00' AND zfitr011_est_001-sel = 'X'.
      zfitr011_est_001-sel = ''.
      MESSAGE i004(zfi) WITH 'Valores en cero en linea seleccionada'.
    ELSE.
*ReSQ: No Need Of Change Internal Table INT_TABLA Already Sorted
      MODIFY int_tabla FROM zfitr011_est_001 INDEX tabla-current_line
       TRANSPORTING sel.
    ENDIF.
  ENDIF.

ENDMODULE.                 " VALIDA-GRILLA_0100  INPUT



*&---------------------------------------------------------------------*
*&      Form  DETALLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detalle .
  REFRESH int_tabla2.

  totalsel  = 0.

  IF  cursorfield = 'ZFITR011_EST_001-MONTODEV'.

    LOOP AT tdev WHERE estado_pago = int_tabla-estado_pago
                 AND   cuenta_cargo = int_tabla-ctactedev
                 AND   numero_lote = int_tabla-lotedev
                 AND   fecha_pago = int_tabla-fechadev
                   AND   correl     = int_tabla-correl.

      int_tabla2-sel          =      tdev-estado.
      int_tabla2-identif_pago =  tdev-codigo_identificacion.
      int_tabla2-rut          = tdev-rut_emisor.
      int_tabla2-nombre       = tdev-nombre_beneficiario.
      int_tabla2-estado_pago  = tdev-estado_pago.
      int_tabla2-cuentadep    = ''.
      int_tabla2-fechacon     = ''.
      int_tabla2-monto        =  tdev-monto / 10000.
      IF int_tabla2-sel = 'X'.
        totalsel  = totalsel  + int_tabla2-monto.
      ENDIF.
      int_tabla2-correl = tdev-correl.
      APPEND int_tabla2.
    ENDLOOP.

    DESCRIBE TABLE int_tabla2 LINES fill.
    tabla2-lines = fill.
    tabla2-top_line = 1.
    LOOP AT tabla2-cols INTO cols .
      IF sy-tabix = 4 OR
         sy-tabix = 5 OR
         sy-tabix = 6 OR
         sy-tabix = 7.
        cols-invisible = '1'.
      ELSE.
        cols-invisible = '0'.
      ENDIF.
      MODIFY tabla2-cols FROM cols INDEX sy-tabix.
    ENDLOOP.
    SORT int_tabla2 BY identif_pago.
    sw_dato = '1'.
    titulo = 'SELECCIONA PARTIDAS BANCO'.
    CALL SCREEN 200 STARTING AT 25 03 ENDING AT 130 25.
  ELSE.
    IF  cursorfield = 'ZFITR011_EST_001-MONTOPEND'.
      tdep-cuenta_cargo = int_tabla-ctactedev.
      tdep-secuencia = tdep-secuencia + 1.
      LOOP AT tdep  WHERE estado_pago = int_tabla-estado_pago
                    AND  cuenta_cargo = int_tabla-ctactedev
                    AND numero_lote = int_tabla-lotedev
                    AND fecha_recepcion = int_tabla-fechadev
                    AND correl      = int_tabla-correl.
        int_tabla2-sel          = ''. "tdep-estado.
        int_tabla2-identif_pago = ''.
        int_tabla2-rut          = ''.
        int_tabla2-nombre       = ''.
        int_tabla2-cuentadep    = tdep-hkont.
        int_tabla2-belnr        = tdep-belnr.
        int_tabla2-fechacon     = tdep-budat.
        int_tabla2-sec          = tdep-secuencia.
        int_tabla2-monto        =  tdep-wrbtr .
        int_tabla2-correl       = tdep-correl.
        IF int_tabla2-sel = 'X'.
          totalsel  = totalsel  + int_tabla2-monto.
        ENDIF.
        APPEND int_tabla2.
      ENDLOOP.

      DESCRIBE TABLE int_tabla2 LINES fill.
      tabla2-lines = fill.
      tabla2-top_line = 1.
      LOOP AT tabla2-cols INTO cols .
        IF sy-tabix = 1   OR
            sy-tabix = 2 OR
            sy-tabix = 3 .
          cols-invisible = '1'.
        ELSE.
          cols-invisible = '0'.
        ENDIF.
        MODIFY tabla2-cols FROM cols INDEX sy-tabix.
      ENDLOOP.


      SORT int_tabla2 BY cuentadep fechacon sec.
      sw_dato = '2'.
      titulo = 'SELECCIONA PARTIDAS DEPOSITO'.
      CALL SCREEN 200 STARTING AT 25 03 ENDING AT 130 25.
    ENDIF.
  ENDIF.

  REFRESH int_tabla.
  CLEAR int_tabla.

  totalbco = 0.
  totaldep = 0.

  SORT tdev BY estado_pago cuenta_cargo numero_lote fecha_pago correl.
  LOOP AT tdev.
    IF tdev-estado = 'X'.
      int_tabla-montodev = int_tabla-montodev + tdev-monto / 10000.
    ENDIF.
    AT END OF correl.
      MOVE tdev-estado_pago TO int_tabla-estado_pago.
      MOVE tdev-cuenta_cargo TO int_tabla-ctactedev.
      MOVE tdev-numero_lote TO int_tabla-lotedev.
      MOVE tdev-fecha_pago TO int_tabla-fechadev.
      MOVE tdev-correl     TO int_tabla-correl.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM zctarechazo WHERE bukrs = bukrs
*                                       AND   ctacte_bco = int_tabla-ctactedev.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM zctarechazo WHERE bukrs = bukrs
                                       AND   ctacte_bco = int_tabla-ctactedev ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        int_tabla-cuentadep = zctarechazo-hkont_dep.
        LOOP AT tdep     WHERE estado_pago = int_tabla-estado_pago
                         AND   cuenta_cargo = int_tabla-ctactedev
                         AND   numero_lote = int_tabla-lotedev
                         AND   fecha_recepcion = int_tabla-fechadev
                         AND   correl          = int_tabla-correl
                         AND   estado = 'X'.

          IF tdep-shkzg = 'H'.
            int_tabla-montopend = int_tabla-montopend + tdep-wrbtr.
          ELSE.
            int_tabla-montopend = int_tabla-montopend - tdep-wrbtr.
          ENDIF.
        ENDLOOP.
      ENDIF.
      int_tabla-montodif = int_tabla-montodev - int_tabla-montopend.
      APPEND int_tabla.
      CLEAR int_tabla.
    ENDAT.
  ENDLOOP.
  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY estado_pago ctactedev lotedev fechadev correl.
  tabla-lines = fill.
  tabla-top_line = 1.

ENDFORM.                    " DETALLE
*&---------------------------------------------------------------------*
*&      Module  PREPARA_REPORTE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE prepara_reporte OUTPUT.
*
  IF g_custom_container IS INITIAL.
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = g_container.
    CREATE OBJECT g_grid1
      EXPORTING
        i_parent = g_custom_container.
*
    PERFORM build_fieldcat       CHANGING gt_fieldcat.
*
    PERFORM exclude_tb_functions CHANGING gt_exclude.
*
    gs_layout-stylefname = 'CELLTAB'.
    gs_layout-ctab_fname = 'COLOR'.

    CALL METHOD g_grid1->set_table_for_first_display
      EXPORTING
        it_toolbar_excluding = gt_exclude
        is_layout            = gs_layout
      CHANGING
        it_fieldcatalog      = gt_fieldcat
        it_outtab            = gt_outtab[].
*
    CREATE OBJECT g_event_receiver.
    SET HANDLER g_event_receiver->catch_hotspot_click FOR g_grid1.
    SET HANDLER g_event_receiver->catch_doubleclick   FOR g_grid1.

* Set editable cells to ready for input initially
    CALL METHOD g_grid1->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM build_fieldcat CHANGING pt_fieldcat TYPE lvc_t_fcat.
  DATA : ls_fcat   TYPE lvc_s_fcat,
         l_col_pos TYPE lvc_s_fcat-col_pos.
*
  CLEAR pt_fieldcat[].
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZFITR011_EST_001'
    CHANGING
      ct_fieldcat      = pt_fieldcat.
*
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'MENSAJE'.
  ls_fcat-outputlen = 40.
  APPEND ls_fcat TO pt_fieldcat.
*
  CLEAR ls_fcat.
  ls_fcat-fieldname = 'LINSEL'.
  ls_fcat-outputlen = 5.
  APPEND ls_fcat TO pt_fieldcat.
*
  l_col_pos = 5.
  LOOP AT pt_fieldcat INTO ls_fcat.
    ADD 1 TO l_col_pos.
    ls_fcat-col_pos = l_col_pos.
    CASE ls_fcat-fieldname.
      WHEN 'ESTADO_PAGO'.
        ls_fcat-coltext   = 'Estado'.
      WHEN 'CTACTEDEV'.
        ls_fcat-coltext   = 'Cta.Cte.'.
        ls_fcat-outputlen = 10.
      WHEN 'LOTEDEV'.
        ls_fcat-coltext   = 'Lote'.
        ls_fcat-outputlen = 10.
      WHEN 'FECHADEV'.
        ls_fcat-coltext   = 'Fecha Recepción'.
        ls_fcat-outputlen = 15.
      WHEN 'MONTODEV'.
        ls_fcat-coltext    = 'Monto Envio'.
        ls_fcat-currency   = t001-waers.
        ls_fcat-outputlen  = 15.
      WHEN 'CUENTADEP'.
        ls_fcat-coltext   = 'Cta. Depósito'.
      WHEN 'MONTOPEND'.
        ls_fcat-coltext   = 'Monto Depósito'.
        ls_fcat-currency   = t001-waers.
        ls_fcat-outputlen = 15.
      WHEN 'MONTODIF'.
        ls_fcat-coltext   = 'Diferencia'.
        ls_fcat-currency   = t001-waers.
        ls_fcat-outputlen = 10.
      WHEN 'SEL'.
        ls_fcat-col_pos   = 0.
        ls_fcat-checkbox  = 'X'.
        ls_fcat-edit      = 'X'.
        ls_fcat-outputlen = 8.
        ls_fcat-hotspot   = 'X'.
        ls_fcat-coltext   = 'Selección'.
      WHEN 'MENSAJE'.
        ls_fcat-coltext   = 'Mensaje Error'.
      WHEN 'LINSEL'.
        ls_fcat-coltext   = 'Correl'.
        ls_fcat-col_pos   = 1.
      WHEN 'CORREL'.
        ls_fcat-no_out    = 'X'.
        ls_fcat-tech      = 'X'.
    ENDCASE.
    ls_fcat-tooltip    = ls_fcat-coltext.
    ls_fcat-reptext    = ls_fcat-coltext.
    ls_fcat-txt_field  = ls_fcat-coltext.
    ls_fcat-scrtext_l  = ls_fcat-coltext.
    ls_fcat-scrtext_m  = ls_fcat-coltext.
    ls_fcat-scrtext_s  = ls_fcat-coltext.
*
    MODIFY pt_fieldcat FROM ls_fcat.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
FORM exclude_tb_functions CHANGING pt_exclude TYPE ui_functions.
  DATA ls_exclude TYPE ui_func.
*
  CLEAR pt_exclude[].
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_ALL_ENTRIES
*&---------------------------------------------------------------------*
FORM select_all_entries CHANGING pt_outtab TYPE STANDARD TABLE.
  DATA: ls_outtab         TYPE ty_outtab,
        lt_filter_entries TYPE lvc_t_fidx.   " Filtered entries
  DATA: l_valid  TYPE c,
        l_locked TYPE c,
        l_linsel TYPE numc05,
        l_tabix  TYPE sy-tabix,                " Index
        lt_color TYPE lvc_t_scol,
        ls_color TYPE lvc_s_scol.
*
  CALL METHOD g_grid1->check_changed_data
    IMPORTING
      e_valid = l_valid.
  IF l_valid EQ 'X'.
*
    CALL METHOD g_grid1->get_filtered_entries
      IMPORTING
        et_filtered_entries = lt_filter_entries.
*
    l_linsel = 0.
    LOOP AT pt_outtab INTO ls_outtab.
      l_tabix = sy-tabix.
      IF ls_outtab-montodif <> '0.00'.
        ls_outtab-mensaje = 'Existen diferencias'.
      ELSE.
        IF ls_outtab-montodev = '0.00' AND ls_outtab-montopend = '0.00'.
          ls_outtab-mensaje = 'Valores en cero'.
        ELSE.
          READ TABLE lt_filter_entries FROM l_tabix TRANSPORTING NO FIELDS.
          IF sy-subrc IS NOT INITIAL.
            ADD 1 TO l_linsel.
            ls_outtab-linsel  = l_linsel.
            ls_outtab-mensaje = ''.
            ls_outtab-sel     = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
*
      IF ls_outtab-mensaje IS NOT INITIAL.
        ls_color-fname     = 'MENSAJE'.
        ls_color-color-col = cl_gui_resources=>list_col_negative.
        ls_color-color-int = 0.
        ls_color-color-inv = 0.
        ls_color-nokeycol  = 'X'.
        APPEND ls_color TO lt_color.
        ls_outtab-color[] = lt_color[].
      ENDIF.
*
      MODIFY pt_outtab FROM ls_outtab.
    ENDLOOP.
    CALL METHOD g_grid1->refresh_table_display.
  ENDIF.
*
  IF l_linsel GE 480.
    gv_error = TEXT-adv.
  ELSE.
    CLEAR gv_error.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL_ENTRIES
*&---------------------------------------------------------------------*
FORM deselect_all_entries  CHANGING pt_outtab TYPE STANDARD TABLE.
  DATA: ls_outtab         TYPE ty_outtab,
        lt_filter_entries TYPE lvc_t_fidx.   " Filtered entries
  DATA: l_valid  TYPE c,
        l_locked TYPE c,
        l_tabix  TYPE sy-tabix,                " Index
        lt_color TYPE lvc_t_scol,
        ls_color TYPE lvc_s_scol.
*
  CALL METHOD g_grid1->check_changed_data
    IMPORTING
      e_valid = l_valid.
  IF l_valid EQ 'X'.
*
    CALL METHOD g_grid1->get_filtered_entries
      IMPORTING
        et_filtered_entries = lt_filter_entries.
*
    LOOP AT pt_outtab INTO ls_outtab.
      l_tabix = sy-tabix.
      PERFORM check_lock USING    ls_outtab
                         CHANGING l_locked.
      IF l_locked IS INITIAL  AND NOT ls_outtab-sel EQ '-'.
        READ TABLE lt_filter_entries FROM l_tabix TRANSPORTING NO FIELDS.
        IF sy-subrc IS NOT INITIAL.
          ls_outtab-sel     = ' '.
          ls_outtab-mensaje = ' '.
          ls_outtab-linsel  = ' '.
          ls_color-fname     = 'MENSAJE'.
          APPEND ls_color TO lt_color.
          ls_outtab-color[] = lt_color[].
        ENDIF.
      ENDIF.
      MODIFY pt_outtab FROM ls_outtab.
    ENDLOOP.
    CLEAR gv_error.
    CALL METHOD g_grid1->refresh_table_display.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_LOCK
*&---------------------------------------------------------------------*
FORM check_lock  USING    ps_outtab TYPE ty_outtab
                 CHANGING p_locked.
  DATA ls_celltab TYPE lvc_s_styl.

  LOOP AT ps_outtab-celltab INTO ls_celltab.
    IF ls_celltab-fieldname = 'SEL'.
      IF ls_celltab-style EQ cl_gui_alv_grid=>mc_style_disabled.
        p_locked = 'X'.
      ELSE.
        p_locked = space.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
