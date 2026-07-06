*&---------------------------------------------------------------------*
*&  Include          ZFITR060_F02
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  SET PF-STATUS 'ZFITR060' EXCLUDING gt_itab.

*
  CHECK gv_mod EQ 'X'.
  LOOP AT SCREEN.
    CHECK screen-group1 EQ 'MOD'.
    screen-input = 1.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.                             " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_exit_0200 INPUT.
  CASE sy-ucomm.
    WHEN 'CANCL'.

      LEAVE  TO SCREEN 0.
  ENDCASE.

ENDMODULE.                    "user_command_EXIT_0200 INPUT
*----------------------------------------------------------------------*
*  MODULE user_command_0200 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'GRABAR'.
      PERFORM ingreso_base.
      SET SCREEN 0. "LEAVE  TO SCREEN 0.
* ini - Waldo Alarcón - Visionone - 17-11-2020
    WHEN 'MODIFICAR'.
      PERFORM modifica_base.
      SET SCREEN 0.
    WHEN 'BORRAR'.
      PERFORM borra_base.
      SET SCREEN 0.
* fin - Waldo Alarcón - Visionone - 17-11-2020
  ENDCASE.

ENDMODULE.                             " USER_COMMAND_0200  INPUT



*---------------------------------------------------------------------*
*       FORM INGRESO_bASE                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM ingreso_base.
  DATA : lv_rut_aux   TYPE char16,
         lv_largo_rut TYPE i.
*  MOVE   p_bukrs                  TO ZFIMOTEMISAN-bukrs.
  znovedadbanco_est-ingres   = 'MANUAL'.
  MOVE-CORRESPONDING znovedadbanco_est TO znovedadbanco.
  INSERT znovedadbanco.

* ini - Waldo Alarcón - Visionone - 17-11-2020
  IF gt_log_noved[] IS NOT INITIAL.
    MODIFY zlog_novedades FROM TABLE gt_log_noved.
*  ELSE.
*    MOVE-CORRESPONDING znovedadbanco_est TO wa_log_noved.
*    MOVE: sy-datum                       TO wa_log_noved-fecha_mod,
*          sy-uzeit                       TO wa_log_noved-hora_mod,
*          sy-uname                       TO wa_log_noved-usuario_mod,
*          'I'                            TO wa_log_noved-clase_mod.
*    MODIFY  zlog_novedades FROM wa_log_noved.
  ENDIF.
* actualia el estado de la tabla ZNOVEDADBANCO y REGUH
  IF gt_znovedad[] IS NOT INITIAL.
    MODIFY znovedadbanco FROM TABLE gt_znovedad.
* actualiza el estado de la tabla REGUH
    LOOP AT gt_znovedad INTO DATA(lw_znovedad).
      lv_largo_rut  = strlen( lw_znovedad-rutben ) - 1.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = lw_znovedad-rutben+0(lv_largo_rut)
        IMPORTING
          output = lv_rut_aux.
      lv_rut_aux = lv_rut_aux && '-' &&  lw_znovedad-rutben+lv_largo_rut(1).
*
      UPDATE reguh SET : ind_pago      = ''
                         ind_rescatado = ''
                         fecha_pago    = '00000000'
                   WHERE identif_pago = lw_znovedad-identif
                   AND   zstc1        = lv_rut_aux.
    ENDLOOP.
  ENDIF.
  COMMIT WORK AND WAIT.
  MESSAGE i899(fi) WITH 'Dato Grabado'.
* fin - Waldo Alarcón - Visionone - 17-11-2020
ENDFORM.                    "ingreso_base
*&---------------------------------------------------------------------*
*&      Form  MODIFICA_BASE
*&---------------------------------------------------------------------*
FORM modifica_base .

  znovedadbanco_est-ingres   = 'MANUAL'.
  MOVE-CORRESPONDING znovedadbanco_est TO znovedadbanco.
  MODIFY znovedadbanco.
*
  IF gt_log_noved[] IS NOT INITIAL.
    MODIFY zlog_novedades FROM TABLE gt_log_noved.
  ELSEIF wa_znovedad_old NE znovedadbanco_est.
    MOVE-CORRESPONDING wa_znovedad_old   TO wa_log_noved.
    MOVE: sy-datum                       TO wa_log_noved-fecha_mod,
          sy-uzeit                       TO wa_log_noved-hora_mod,
          sy-uname                       TO wa_log_noved-usuario_mod,
          'I'                            TO wa_log_noved-clase_mod.
    MODIFY  zlog_novedades FROM wa_log_noved.
*
    WAIT UP TO 1 SECONDS.
    MOVE-CORRESPONDING znovedadbanco_est TO wa_log_noved.
    MOVE: sy-datum                       TO wa_log_noved-fecha_mod,
          sy-uzeit                       TO wa_log_noved-hora_mod,
          sy-uname                       TO wa_log_noved-usuario_mod,
          'U'                            TO wa_log_noved-clase_mod.
    MODIFY  zlog_novedades FROM wa_log_noved.
  ENDIF.
  IF gt_znovedad[] IS NOT INITIAL.
    MODIFY znovedadbanco FROM TABLE gt_log_noved.
  ENDIF.
  COMMIT WORK AND WAIT.
  MESSAGE i899(fi) WITH 'Dato Modificado'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BORRA_BASE
*&---------------------------------------------------------------------*
FORM borra_base .

  DELETE znovedadbanco FROM znovedadbanco_est.
* REGISTRA EL BORRADO EN TABLA DE LOGS.
  MOVE-CORRESPONDING znovedadbanco_est TO wa_log_noved.
  MOVE: sy-datum                       TO wa_log_noved-fecha_mod,
        sy-uzeit                       TO wa_log_noved-hora_mod,
        sy-uname                       TO wa_log_noved-usuario_mod,
        'D'                            TO wa_log_noved-clase_mod.
  MODIFY  zlog_novedades FROM wa_log_noved.
  COMMIT WORK AND WAIT.
  MESSAGE i899(fi) WITH 'Dato Eliminado'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: lt_sort     TYPE lvc_t_sort,
        lt_fieldcat TYPE lvc_t_fcat,
        wa_layout   TYPE lvc_s_layo.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM fieldcat_init   USING lt_fieldcat[].
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_znovedad
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
*
  CASE rs_selfield-fieldname.
    WHEN 'IDENTIF'.
      wa_znovedad_old = znovedadbanco_est = gt_znovedad[ rs_selfield-tabindex ].
      CALL SCREEN 200 STARTING AT 20 05 ENDING AT 130 25.

      MODIFY gt_znovedad FROM znovedadbanco_est INDEX rs_selfield-tabindex.
      rs_selfield-refresh = 'X'.
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
  rs_layout-zebra                = 'X'.
  rs_layout-detailinit           = 'X'.
  rs_layout-cwidth_opt           = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
  DATA : gs_fieldcat TYPE  lvc_s_fcat.
*
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZNOVEDADBANCO'
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
**
  LOOP AT p_gt_fieldcat INTO gs_fieldcat .
    CASE gs_fieldcat-fieldname.
      WHEN 'IDENTIF'.
        gs_fieldcat-scrtext_m  = 'ID Pago'.
        gs_fieldcat-hotspot    = 'X'.
      WHEN 'FECHA'.
        gs_fieldcat-scrtext_m  = 'Fecha Reintegro'.
      WHEN 'RUTBEN'.
        gs_fieldcat-scrtext_m  = 'RUT beneficiario'.
      WHEN 'NOMBEN'.
        gs_fieldcat-scrtext_m  = 'Nombre beneficiario'.
      WHEN 'MONTOW'.
        gs_fieldcat-scrtext_m  = 'Monto Novedad'.
      WHEN 'FECPAG'.
        gs_fieldcat-scrtext_m  = 'fecha Pago'.
      WHEN 'NUMLOT'.
        gs_fieldcat-scrtext_m  = 'Lote'.
      WHEN OTHERS.
        gs_fieldcat-no_out    = 'X'.
    ENDCASE.
**
    gs_fieldcat-colddictxt = 'M'.
    MODIFY p_gt_fieldcat FROM gs_fieldcat.
  ENDLOOP.
ENDFORM.
