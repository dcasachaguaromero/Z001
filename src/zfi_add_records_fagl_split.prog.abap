*&---------------------------------------------------------------------*
*& Report ZFI_ADD_RECORDS_FAGL_SPLIT
*&---------------------------------------------------------------------*
*& Compañía   : Banmédica
*& Autor      : Vision One # CNN
*& Fecha      : 29.01.2025
*& Objetivo   : Agrega registros faltantes a las tablas
*&              FAGL_SPLINFO_VAL y FAGL_SPLINFO
*&---------------------------------------------------------------------
*&                       MODIFICACIONES
*&---------------------------------------------------------------------
*& Modificó   :
*& Fecha      :
*& Solicitó   :
*& Transporte :
*& Objetivo   :
*&---------------------------------------------------------------------
REPORT zfi_add_records_fagl_split MESSAGE-ID zfi NO STANDARD PAGE HEADING.

INCLUDE zfi_add_records_fagl_split_top.  "Objetos de datos globales
INCLUDE zfi_add_records_fagl_split_sel.  "Pantalla de selección
INCLUDE zfi_add_records_fagl_split_cls.  "Clases

*--------------------------------------------------------------------*
*                     BEGIN
*--------------------------------------------------------------------*
START-OF-SELECTION.

  DATA(go_app) = NEW lcl_app( ).

  gr_belnr[] = s_belnr[].

  IF p_ins = abap_true.
    go_app->get_db_tables( EXPORTING iv_bukrs = p_bukrs
                                     iv_gjahr = p_gjahr
                                     ir_belnr = gr_belnr
    ).

*    IF go_app->gt_fagl_splinfo IS INITIAL.
     IF gv_reg3 = '1'.
*     No se encontraron documentos para la selección
      MESSAGE i029.
      RETURN.
    ENDIF.

    go_app->manage_updates( ).

  ELSE.
    go_app->del_db_table( EXPORTING iv_bukrs = p_bukrs
                                    iv_belnr = gv_belnr_del
                                    iv_gjahr = p_gjahr
                                    iv_buzei = p_buzei
    ).
  ENDIF.

* Log de ejecución
  go_app->show_log( ).
