*&---------------------------------------------------------------------*
*&  Include           ZFITR060_V2_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_RUT_SOC
*&---------------------------------------------------------------------*
FORM get_rut_soc USING iv_bukrs TYPE bukrs
                       ev_rut   TYPE gty_rut.

  DATA: ls_adrc TYPE adrc.

  DATA: lv_rut    TYPE ad_sort1,
        lv_num    TYPE c LENGTH 8,
        lv_dv     TYPE c LENGTH 1,
        lv_numero TYPE n LENGTH 9.


  SELECT SINGLE FROM t001 FIELDS adrnr
    WHERE bukrs = @iv_bukrs INTO @DATA(lv_adrnr).

  IF NOT lv_adrnr IS INITIAL.
    CALL FUNCTION 'RTP_US_DB_ADRC_READ'
      EXPORTING
        i_address_number = lv_adrnr
      IMPORTING
        e_adrc           = ls_adrc
      EXCEPTIONS
        not_found        = 1
        OTHERS           = 2.

    lv_rut = ls_adrc-sort1.
  ENDIF.

  IF NOT lv_rut IS INITIAL.
    SPLIT lv_rut AT '-' INTO lv_num lv_dv.
    lv_numero = lv_num.
    CONCATENATE lv_numero lv_dv INTO ev_rut.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  GET_REGUH
*&---------------------------------------------------------------------*
FORM get_reguh  TABLES et_reguh TYPE gtt_reguh.

  SELECT FROM reguh
    FIELDS identif_pago, laufd, laufi, zbukr, name1, rbetr, waers,
           glosa_redepo, ind_custodia, ind_pago, belnr_dev, stcd1
    WHERE identif_pago IN @s_idpago
*INI V1 RVY 12-05-2025
*      AND glosa_redepo  = 'RETIRO POR UN 3ERO'
*      AND ind_custodia  = 'X'
*      AND ind_pago      = ' '
      AND glosa_redepo  = 'RETIRO POR UN 3ERO'
      AND ind_pago      = ' '
      AND ( ind_custodia  = 'X' OR IND_ENTREGADO = 'X')
*FIN V1 RVY 12-05-2025
      AND belnr_dev     = '          '
    INTO TABLE @et_reguh.

ENDFORM.


*&---------------------------------------------------------------------*
*&  Include          zfitr060_f02
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  SET PF-STATUS 'ZFITR060' EXCLUDING gt_itab.

  CHECK gv_mod EQ 'X'.
  LOOP AT SCREEN.
    CHECK screen-group1 EQ 'MOD'.
    screen-input = 1.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                             " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_EXIT_0200  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_exit_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'CANCL'.
      LEAVE  TO SCREEN 0.
  ENDCASE.

ENDMODULE.                    "user_command_EXIT_0200 INPUT


*----------------------------------------------------------------------*
*  Module USER_COMMAND_0200 INPUT
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
*       Form INGRESO_BASE
*---------------------------------------------------------------------*
FORM ingreso_base.

  DATA : lv_rut_aux   TYPE char16,
         lv_largo_rut TYPE i.

  DATA: lv_lines  TYPE sytabix,
        lv_montow TYPE rbetr,
        lv_tot    TYPE rbetr.

  gs_znovedadbanco_est-ingres   = 'MANUAL'.
  MOVE-CORRESPONDING gs_znovedadbanco_est TO znovedadbanco.
  INSERT znovedadbanco.

  IF gt_log_noved[] IS NOT INITIAL.
    MODIFY zlog_novedades FROM TABLE gt_log_noved.
  ENDIF.

* Actualia el estado de la tabla ZNOVEDADBANCO y REGUH
  IF gt_znovedad[] IS NOT INITIAL.
    MODIFY znovedadbanco FROM TABLE gt_znovedad.
    lv_lines = lines( gt_znovedad ).   "V1-CNN 11.03.2025

*   Actualiza el estado de la tabla REGUH
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

      lv_montow = lw_znovedad-montow.
      lv_tot = lv_tot + lv_montow.
    ENDLOOP.
  ENDIF.

  gv_lines = gv_lines + lv_lines.
  gv_tot   = gv_tot + lv_tot.

  COMMIT WORK AND WAIT.
  MESSAGE i899(fi) WITH 'Dato Grabado'.

ENDFORM.                    "ingreso_base


*&---------------------------------------------------------------------*
*&      Form  MODIFICA_BASE
*&---------------------------------------------------------------------*
FORM modifica_base .

  DATA: lv_lines  TYPE sytabix,
        lv_montow TYPE rbetr,
        lv_tot    TYPE rbetr.

  gs_znovedadbanco_est-ingres   = 'MANUAL'.
  MOVE-CORRESPONDING gs_znovedadbanco_est TO znovedadbanco.
  MODIFY znovedadbanco.
*
  IF gt_log_noved[] IS NOT INITIAL.
    MODIFY zlog_novedades FROM TABLE gt_log_noved.
  ELSEIF gs_znovedad_old NE gs_znovedadbanco_est.
    MOVE-CORRESPONDING gs_znovedad_old   TO gs_log_noved.
    MOVE: sy-datum                       TO gs_log_noved-fecha_mod,
          sy-uzeit                       TO gs_log_noved-hora_mod,
          sy-uname                       TO gs_log_noved-usuario_mod,
          'I'                            TO gs_log_noved-clase_mod.
    MODIFY  zlog_novedades FROM gs_log_noved.
*
    WAIT UP TO 1 SECONDS.
    MOVE-CORRESPONDING gs_znovedadbanco_est TO gs_log_noved.
    MOVE: sy-datum                       TO gs_log_noved-fecha_mod,
          sy-uzeit                       TO gs_log_noved-hora_mod,
          sy-uname                       TO gs_log_noved-usuario_mod,
          'U'                            TO gs_log_noved-clase_mod.
    MODIFY  zlog_novedades FROM gs_log_noved.
  ENDIF.

  IF gt_znovedad[] IS NOT INITIAL.
    MODIFY znovedadbanco FROM TABLE gt_log_noved.
    lv_lines = lines( gt_znovedad ).

    LOOP AT gt_znovedad ASSIGNING FIELD-SYMBOL(<ls_znoved>).
      lv_montow = <ls_znoved>-montow.
      lv_tot = lv_tot + lv_montow.
    ENDLOOP.
  ENDIF.

  gv_lines = gv_lines + lv_lines.
  gv_tot   = gv_tot + lv_tot.

  MESSAGE i899(fi) WITH 'Dato Modificado'.

  COMMIT WORK AND WAIT.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  BORRA_BASE
*&---------------------------------------------------------------------*
FORM borra_base .

  DELETE znovedadbanco FROM gs_znovedadbanco_est.

* REGISTRA EL BORRADO EN TABLA DE LOGS.
  MOVE-CORRESPONDING gs_znovedadbanco_est TO gs_log_noved.
  MOVE: sy-datum                       TO gs_log_noved-fecha_mod,
        sy-uzeit                       TO gs_log_noved-hora_mod,
        sy-uname                       TO gs_log_noved-usuario_mod,
        'D'                            TO gs_log_noved-clase_mod.
  MODIFY  zlog_novedades FROM gs_log_noved.
  COMMIT WORK AND WAIT.
  MESSAGE i899(fi) WITH 'Dato Eliminado'.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos.

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
      gs_znovedad_old = gs_znovedadbanco_est = gt_znovedad[ rs_selfield-tabindex ].
      CALL SCREEN 200 STARTING AT 20 05 ENDING AT 130 25.

      MODIFY gt_znovedad FROM gs_znovedadbanco_est INDEX rs_selfield-tabindex.
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
