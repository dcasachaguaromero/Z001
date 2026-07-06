*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDPROCFAC_CLS
*&---------------------------------------------------------------------*

*local class to handle semantic checks
CLASS lcl_event_receiver DEFINITION DEFERRED.
DATA g_verifier TYPE REF TO lcl_event_receiver.

*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.

  PUBLIC SECTION.
    TYPES BEGIN OF sflight_key.
    TYPES: carrid TYPE s_carr_id,
           connid TYPE s_conn_id,
           fldate TYPE s_date.
    TYPES END OF sflight_key.
    TYPES: sflight_keys  TYPE STANDARD TABLE OF sflight_key,
           sflight_table TYPE STANDARD TABLE OF sflight.
*
    METHODS handle_data_changed
           FOR EVENT data_changed OF cl_gui_alv_grid
           IMPORTING er_data_changed.
    METHODS handle_toolbar
            FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object. "e_interactive.
    METHODS handle_double_click
            FOR EVENT double_click OF cl_gui_alv_grid
            IMPORTING e_row e_column.
    METHODS user_command
            FOR EVENT after_user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm.

    METHODS set_table_is_not_initial.

  PRIVATE SECTION.
* This flag is set if any error occured in one of the
* following methods:
    DATA error_in_data TYPE c.
ENDCLASS.                    "lcl_event_receiver DEFINITION
**---------------------------------------------------------
CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_data_changed.

    error_in_data = space.

    IF error_in_data = true.
      CALL METHOD er_data_changed->display_protocol.
    ENDIF.

  ENDMETHOD.                    "handle_data_changed
  METHOD user_command.

    CASE e_ucomm.
      WHEN 'GENFAC'.
        PERFORM genera_facturacion.
      WHEN 'GENIMP'.
        PERFORM genera_impresion.
      WHEN '&REFRESH'.
        FREE: gt_outtab, gt_cabpedext.
        PERFORM select_data TABLES gt_outtab
                            USING true.
    ENDCASE.

    l_stable-row = true.
    l_stable-col = true.

    CALL METHOD g_grid->set_frontend_layout
      EXPORTING
        is_layout = gs_layout.

    CALL METHOD g_grid->refresh_table_display
      EXPORTING
        is_stable = l_stable.

    CALL METHOD cl_gui_cfw=>dispatch.

  ENDMETHOD.                    "USER_COMMAND
  METHOD handle_toolbar.

    DATA lv_toolbar TYPE stb_button.
* Push Button
    CLEAR lv_toolbar.
    MOVE 'GENFAC'         TO lv_toolbar-function.
    MOVE '@39@'           TO lv_toolbar-icon.
    MOVE text-t14         TO lv_toolbar-text.
    MOVE text-t14         TO lv_toolbar-quickinfo.
    MOVE  space           TO lv_toolbar-disabled.
    APPEND lv_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.                    "handle_toolbar
  METHOD handle_double_click.
    DATA tmp_zcabpedext LIKE zcabpedext.
    TYPES: BEGIN OF t_bkpf,
         bukrs TYPE bkpf-bukrs,
         belnr TYPE bkpf-belnr,
         gjahr TYPE bkpf-gjahr,
       END OF t_bkpf.

    DATA: wa_bkpf TYPE t_bkpf.
    FREE t_log.
    CLEAR ls_log.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
*SORT GT_OUTTAB . "JOROZCO 20.01.2020
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
    READ TABLE gt_outtab INTO ls_outtab INDEX e_row.
    IF sy-subrc = 0.
      FREE t_fieldcat.

      CLEAR ls_fc.
      ls_fc-col_pos    = 1.
      ls_fc-tabname    = 'T_LOG'.
      ls_fc-fieldname  = 'STATUS'.
      ls_fc-seltext_l  = text-t15. "'Tipo'.
      ls_fc-outputlen  = 5.
      APPEND ls_fc TO t_fieldcat.
*
      CLEAR ls_fc.
      ls_fc-col_pos    = 2.
      ls_fc-tabname    = 'T_LOG'.
      ls_fc-fieldname  = 'TEXTO'.
      ls_fc-seltext_l  = text-t16."'Mensaje'.
      ls_fc-outputlen  = 70.
      APPEND ls_fc TO t_fieldcat.

      CASE e_column.
        WHEN 'FACTURA'.
          SET PARAMETER ID 'VF' FIELD ls_outtab-factura.
          CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
        WHEN 'PEDIDO'.
          SET PARAMETER ID 'AUN' FIELD ls_outtab-pedido.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
        WHEN 'STATUS'.
          FREE t_log.
          ls_log-status = 'E'.
          SELECT SINGLE * INTO tmp_zcabpedext
            FROM zcabpedext
            WHERE znum_doc_core = ls_outtab-znum_doc_core
              AND zblart        = ls_outtab-zblart.
          IF tmp_zcabpedext-log_error IS INITIAL AND tmp_zcabpedext-error NE space.
            IF ls_outtab-factura EQ space.
              ls_log-texto = text-t17. "'Error en la creación de la factura.'.
            ELSE.
              CLEAR str_awkey.
              SELECT SINGLE belnr INTO bkpf-belnr
                FROM bkpf
                WHERE awtyp EQ gv_vbrk
                  AND awkey EQ ls_outtab-factura.
              IF sy-subrc NE 0.
                CONCATENATE text-t18 "'El documento'
                            ls_outtab-znum_doc_core
                            text-t19 "'no pudo contabilizarse'
                       INTO ls_log-texto SEPARATED BY space.
              ENDIF.
            ENDIF.
          ELSE.
            ls_log-texto = tmp_zcabpedext-log_error.
          ENDIF.
          APPEND ls_log TO t_log.

          CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
            EXPORTING
              i_title                 = text-t07 "'Log Creación facturac SAP'
              i_selection             = ''
              i_allow_no_selection    = true
              i_screen_start_column   = 10
              i_screen_start_line     = 4
              i_screen_end_column     = 105
              i_screen_end_line       = 10
              i_scroll_to_sel_line    = ''
              i_tabname               = 'T_LOG'
              i_structure_name        = 'T_LOG'
              it_fieldcat             = t_fieldcat[]
              i_callback_program      = sy-repid
              i_callback_user_command = 'USER_COMMAND'
            TABLES
              t_outtab                = t_log[]
            EXCEPTIONS
              program_error           = 1
              OTHERS                  = 2.

          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        WHEN 'STATUS_ELEC'.
          FREE t_log.
          IF ls_outtab-status_elec(3) = '@5B'.
            CLEAR str_awkey.
            CLEAR wa_bkpf.
            SELECT SINGLE bukrs belnr gjahr
              INTO wa_bkpf
              FROM bkpf
              WHERE awtyp EQ gv_vbrk
                AND awkey EQ ls_outtab-factura.
            IF sy-subrc EQ 0.
              CLEAR tmp_url.
              SELECT SINGLE zurl
                INTO tmp_url
                FROM zfac_anex
                WHERE bukrs = wa_bkpf-bukrs
                  AND belnr = wa_bkpf-belnr
                  AND gjahr = wa_bkpf-gjahr.
              IF sy-subrc = 0 AND NOT tmp_url IS INITIAL.
                CLEAR l.
                l = STRLEN( tmp_url ) - 3.
                tmp_url = tmp_url(l).
                CALL FUNCTION 'ZHOW_PDF_URL'
                  EXPORTING
                    i_url = tmp_url.
              ENDIF.
            ENDIF.
          ELSE.
            FREE tmp_nast.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = ls_outtab-factura
              IMPORTING
                output = vbrk-vbeln.

            SELECT * FROM nast
              INTO CORRESPONDING FIELDS OF TABLE tmp_nast
              WHERE kappl EQ 'V3'
                AND objky EQ vbrk-vbeln.
            SORT tmp_nast BY erdat eruhr DESCENDING.
            READ TABLE tmp_nast INTO ls_tmp_nast INDEX 1.
            IF sy-subrc = 0.
              nast-cmfpnr = ls_tmp_nast-cmfpnr.
              SELECT msgv1 msgv2 msgv3 msgv4
                INTO (cmfp-msgv1, cmfp-msgv2, cmfp-msgv3, cmfp-msgv4)
                FROM cmfp WHERE aplid = 'WFMC'
                                   AND nr    = nast-cmfpnr
                                   AND msgty = 'E'.
                ls_log-status = 'E'.
                CONCATENATE cmfp-msgv1 cmfp-msgv2
                cmfp-msgv3 cmfp-msgv4 INTO ls_log-texto.
                APPEND ls_log TO t_log.
              ENDSELECT.
            ELSE.
              ls_log-status = 'E'.
              ls_log-texto  = ls_outtab-log_error              .
              APPEND ls_log TO t_log.
            ENDIF.
            CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
              EXPORTING
                i_title                 = text-t06 "'Log Envio facturas electrónicas a Acepta'
                i_selection             = ''
                i_allow_no_selection    = true
                i_screen_start_column   = 10
                i_screen_start_line     = 4
                i_screen_end_column     = 105
                i_screen_end_line       = 10
                i_scroll_to_sel_line    = ''
                i_tabname               = 'T_LOG'
                i_structure_name        = 'T_LOG'
                it_fieldcat             = t_fieldcat[]
                i_callback_program      = sy-repid
                i_callback_user_command = 'USER_COMMAND'
              TABLES
                t_outtab                = t_log[]
              EXCEPTIONS
                program_error           = 1
                OTHERS                  = 2.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          MESSAGE i000(0k) WITH 'log:' ls_outtab-log_error.
      ENDCASE.
    ENDIF.

  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
*---------------------------------------------------------
  "set_table_is_initial
*------------------------------------------------------
  METHOD set_table_is_not_initial.
*    initial_table = space.
  ENDMETHOD.                    "set_table_is_not_initial

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION
