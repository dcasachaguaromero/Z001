*&---------------------------------------------------------------------*
*& Report ZFITR040_038
*&---------------------------------------------------------------------*
*& Versión 2 del reporte ZFITR040_037
*& V1 - Carlos Nievas 30.01.2023
*& Baja retorno de archivo de Novedades de Banco Santander segun se
*& indique en  parámetros ingresados
*& Invoca funcion de formateo de datos propia de Santander
*& Transacción: ZFITR040_037
*&---------------------------------------------------------------------*
REPORT zfitr040_038.

INCLUDE zfitr040_038_top.   "Declaracions globales
INCLUDE zfitr040_038_sel.   "Inicio de programa
INCLUDE zfitr040_038_cld.   "Definciones de clases
INCLUDE zfitr040_038_cli.   "Implementaciones de clases
INCLUDE zfitr040_038_f01.   "Rutinas locales


*----------------------------------------------------------------------
*                     START-OF-SELECTION
*----------------------------------------------------------------------
START-OF-SELECTION.

  DATA(lo_director) = NEW lcl_director( ).

  CLEAR: gt_tabla, gv_rc, gv_message.

  lo_director->get_filenames( EXPORTING iv_bukrs   = p_bukrs
                                        iv_path    = gs_ztparamftp-zruta
                              IMPORTING et_tabla   = gt_tabla
                                        ev_rc      = gv_rc
                                        ev_message = gv_message
                            ).

  IF NOT gv_rc IS INITIAL.
    WRITE: / gv_message.
    RETURN.
  ENDIF.

  gv_repid = sy-repid.
  lo_director->show_alv( CHANGING ct_tabla = gt_tabla ).


*--------------------------------------------------------------------*
*&   Form  USER_COMMAND
*--------------------------------------------------------------------*
FORM user_command USING i_ucomm     LIKE sy-ucomm
                        is_selfield TYPE slis_selfield.

  DATA: lv_ucomm TYPE syucomm.

  lv_ucomm = i_ucomm.
  CLEAR: i_ucomm.

  CASE lv_ucomm.
    WHEN '&FC01'.
      lo_director->process_documents( EXPORTING it_tabla = gt_tabla
                                                iv_block = p_block
                                                is_direc = gs_ztparamftp
                                      IMPORTING et_log   = gt_log
                                     ).
      IF NOT gt_log IS INITIAL.
*       Mostrar log
        IF p_show = abap_true.
          lo_director->show_log( EXPORTING it_log = gt_log ).
        ELSE.
          lo_director->down_log( EXPORTING it_log = gt_log ).
        ENDIF.
      ENDIF.

      is_selfield-exit ='X'.

  ENDCASE.

ENDFORM.
