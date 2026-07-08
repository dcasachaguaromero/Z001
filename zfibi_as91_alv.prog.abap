*&---------------------------------------------------------------------*
*&  Include           ZFIBI_AS91_ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_ALV_MSJ
*&---------------------------------------------------------------------*
FORM mostrar_alv_msj .
  DATA: l_status TYPE slis_formname VALUE 'F_STATUS_ALV'.
  "Variable con el nombre del form que define el STATUS
  DATA: l_comm   TYPE slis_formname VALUE 'F_USER_COMMAND'.
  "Variable con el nombre del form que define USER COMMAND
  DATA: l_repid  TYPE sy-repid.
  "Variable para guardar el nombre del programa
  DATA: l_layout TYPE slis_layout_alv.
  "Variable con el layout del ALV
  DATA: i_catalogo TYPE slis_t_fieldcat_alv.
  "Tabla con el catalogo del ALV
  DATA: i_orden    TYPE slis_t_sortinfo_alv.
  "Tabla con el orden del ALV

  PERFORM f_cargar_layout CHANGING l_layout.
  PERFORM f_cargar_catalogo TABLES i_catalogo.
*  PERFORM f_cargar_orden        TABLES i_orden.

  l_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_bypassing_buffer       = 'X'
      i_callback_program       = l_repid
*      i_callback_pf_status_set = l_status
      i_callback_user_command  = l_comm
*      i_grid_title             = ''
      is_layout                = l_layout
      it_fieldcat              = i_catalogo
*      it_sort                  = i_orden
      i_save                   = 'X'
    TABLES
      t_outtab                 = gt_alv
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " mostrar_alv_msj

*&---------------------------------------------------------------------*
*&      Form  f_cargar_layout
*&---------------------------------------------------------------------*
FORM f_cargar_layout  CHANGING ps_l_layout TYPE slis_layout_alv.
  ps_l_layout-zebra             = c_x.
  ps_l_layout-colwidth_optimize = c_x.
  ps_l_layout-lights_condense   = c_x.
  ps_l_layout-info_fieldname    = 'COLOR_L'.
*  ps_l_layout-coltab_fieldname  = 'COLOR_C' .

ENDFORM.                    " F_CARGAR_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_CARGAR_CATALOGO
*&---------------------------------------------------------------------*
*   Rutina para crear el catalogo del alv de selección y el de resultado
*----------------------------------------------------------------------*
FORM f_cargar_catalogo  TABLES   ps_i_catalogo TYPE slis_t_fieldcat_alv.

  DATA: r_catalogo TYPE slis_fieldcat_alv.
  DATA: l_campo  TYPE slis_fieldname,
        l_textos  LIKE dd03p-scrtext_s,
        l_textom  LIKE dd03p-scrtext_m,
        l_descr  LIKE dd03p-scrtext_l.
  DATA: l_pos TYPE i.
  CONSTANTS: lc_nombre TYPE char16 VALUE 'GT_ALV'.

  DEFINE fc.

    clear r_catalogo.
    add 1 to l_pos.
    r_catalogo-col_pos       = l_pos.
    r_catalogo-fieldname     = &1.
    r_catalogo-seltext_l     = &2.
    r_catalogo-seltext_s     = &3.
    r_catalogo-seltext_m     = &4.
    r_catalogo-tabname       = &5.
    r_catalogo-no_out        = &6.
    r_catalogo-key           = &7.
    r_catalogo-outputlen    = &8.

    append r_catalogo to ps_i_catalogo.

  END-OF-DEFINITION.

  REFRESH ps_i_catalogo.

  l_campo  = 'POS'.
  l_textom = 'Linea'.
  l_textos = 'LineaExcel'.
  l_descr  = 'Linea Excel'.
  fc l_campo l_descr l_textos l_textom lc_nombre space c_x 10.

  l_campo  = 'ACTIVO'.
  l_textom = 'AF'.
  l_textos = 'Activo Fijo'.
  l_descr  = 'Num Activo Fijo'.
  fc l_campo l_descr l_textos l_textom lc_nombre space c_x 18.

  l_campo  = 'MENSAJE'.
  l_textom = 'Mensaje'.
  l_textos = 'Mensaje'.
  l_descr  = 'Mensaje'.
  fc l_campo l_descr l_textos l_textom lc_nombre space c_x 300.

  LOOP AT ps_i_catalogo INTO r_catalogo.
    IF r_catalogo-fieldname EQ 'ACTIVO'.
      r_catalogo-hotspot = c_x.
      MODIFY ps_i_catalogo FROM r_catalogo.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CARGAR_CATALOGO

*&---------------------------------------------------------------------*
*&      Form  f_user_command
*&---------------------------------------------------------------------*
FORM f_user_command USING pe_ucomm     LIKE sy-ucomm
                          pe_selfield  TYPE slis_selfield.
  DATA: w_datos TYPE t_alv.
  CASE pe_ucomm.
    WHEN '&IC1'."Hotpost
      READ TABLE gt_alv INTO w_datos INDEX pe_selfield-tabindex.
      IF pe_selfield-fieldname EQ 'ACTIVO' AND w_datos-activo IS NOT INITIAL.
        SET PARAMETER ID 'AN1' FIELD w_datos-activo.
        SET PARAMETER ID 'BUK' FIELD w_datos-bukrs.
        CALL TRANSACTION 'AS93' ."AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.
ENDFORM.  " F_USER_COMMAND
