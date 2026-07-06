*&---------------------------------------------------------------------*
*&  Include           ZFILB006_FORM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  VALUE_REQUEST_PATH_DOWN
*&---------------------------------------------------------------------*
FORM value_request_path_down  CHANGING p_path.

  DATA: l_path TYPE string.

  MOVE p_path TO l_path.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    CHANGING
      selected_folder      = l_path
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  MOVE l_path TO p_path.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FI_IMPORT_BALANCE
*&---------------------------------------------------------------------*
FORM fi_import_balance USING sbalan.

  CALL FUNCTION 'FI_IMPORT_BALANCE_SHEET_POS'
    EXPORTING
      version           = sbalan " T011-VERSN " B100
    TABLES
      x011p             = x011p
      x011v             = x011v
      i011z             = x011z
    EXCEPTIONS
      new_balance_sheet = 04.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ONLY_ESTRUCT
*&---------------------------------------------------------------------*
FORM only_estruct .
  DATA : ls_output LIKE LINE OF gt_output OCCURS 0 WITH HEADER LINE.
  DATA : ls_output2 LIKE LINE OF gt_output OCCURS 0 WITH HEADER LINE.
  DATA : l_comp TYPE numc10.
  DATA : l_cuenta TYPE ktopl.
  DATA : l_id TYPE i.
  DATA : ident TYPE i.
  DATA : BEGIN OF lsz OCCURS 0,
           ktopl  TYPE ktopl, "Plan de cuentas
           nbilkt TYPE numc10, "Límite superior del intervalo de cuentas
           nvonkt TYPE numc10, "Límite inferior del intervalo de cuentas
         END OF lsz.
*
  IF gt_output[] IS INITIAL OR x011z[] IS INITIAL.
    EXIT.
  ENDIF.

  LOOP AT x011z.
    MOVE x011z-ktopl TO lsz-ktopl.
    MOVE x011z-bilkt TO lsz-nbilkt.
    MOVE x011z-vonkt TO lsz-nvonkt.
    APPEND lsz.
  ENDLOOP.

* SE VERIFICA QUE EXISTA LA CUENTA EN TABLA ZEST_BALANC
  LOOP AT gt_output INTO ls_output.
    ident = 1. " SE SETEA PARA QUE SE BORRE LA CUENTA A BUSCAR
    l_comp = ls_output-saknr.
    LOOP AT lsz.
      IF ( lsz-nbilkt >= l_comp ) AND ( lsz-nvonkt <= l_comp ).
        ident = 0. " SI ENCONTRO LA CUENTA NO SE BORRA
        EXIT.
      ENDIF.

    ENDLOOP.
    IF ident = 1.
      MOVE ls_output-saknr TO ls_output2-saknr.
      APPEND ls_output2. " las cuentas que se encuentran en esta tabla se deben sacar de GT_OUTPUT
    ENDIF.

  ENDLOOP.

  LOOP AT gt_output INTO ls_output.
    l_id = sy-tabix.

    READ TABLE ls_output2 WITH KEY saknr = ls_output-saknr.

    IF sy-subrc EQ 0.
      DELETE gt_output WHERE saknr = ls_output-saknr.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN_NEW
*&---------------------------------------------------------------------*
FORM modify_screen_new .

* Eliminate unused screen selections
  LOOP AT SCREEN.
    CHECK screen-group1 EQ 'V1'.
    screen-active = 0.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_LIST_OUTPUT_NEW
*&---------------------------------------------------------------------*
FORM alv_list_output_new .
  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        lt_events   TYPE slis_t_event,
        ls_layout   TYPE slis_layout_alv,
        ls_sett     TYPE lvc_s_glay,
        ls_prnt     TYPE slis_print_alv.

*Begin of Note 1018053
  DATA: ls_fieldcat TYPE slis_fieldcat_main0,
        lv_waers    TYPE t001-waers.
*End of Note 1018053

* Build item fieldcatalog table
*  PERFORM fieldcat_init CHANGING lt_fieldcat.
  PERFORM fieldcat_init_new CHANGING lt_fieldcat.
* Build Print Information.
  PERFORM set_prnt CHANGING ls_prnt.
* Build Grid Settings.
  PERFORM set_grid_sett CHANGING ls_sett.
* Build event table
  PERFORM lt_events_build CHANGING lt_events.

* INI - WALDO ALARCON - VISIONONE - 01-05-2020
* Build Layout.
*  PERFORM layout_init CHANGING ls_layout.
  PERFORM layout_init_new CHANGING ls_layout.

* Build comments for page header.
*  PERFORM lt_comment_build USING gs_list_top_of_page[].
  PERFORM lt_comment_build_new USING gs_list_top_of_page[].
* FIN - WALDO ALARCON - VISIONONE - 01-05-2020

* Build the layout with row colors for totals.
  PERFORM set_row_color CHANGING ls_layout.

*Begin of Note 1018053
  SELECT waers INTO lv_waers FROM t001 WHERE bukrs = sd_bukrs-low.
  ENDSELECT.

  LOOP AT lt_fieldcat INTO ls_fieldcat.
    IF ls_fieldcat-currency IS INITIAL.
      ls_fieldcat-currency = lv_waers.
      MODIFY lt_fieldcat FROM ls_fieldcat.
    ENDIF.
  ENDLOOP.
*End of Note 1018053

*Call Function Module 'REUSE_ALV_GRID_DISPLAY' for ALV grid display.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'STANDAR_DET'
      i_callback_user_command  = 'USER_COMMAND_DET'
*     i_callback_html_top_of_page = l_callback_html_top_of_page
      i_background_id          = 'LOGOISAPBAN002'
      i_grid_settings          = ls_sett
      is_layout                = ls_layout
      it_fieldcat              = lt_fieldcat
      i_save                   = gc_save
      is_variant               = gs_variant
      it_events                = lt_events
      is_print                 = ls_prnt
      i_html_height_top        = 32
    TABLES
      t_outtab                 = gt_output
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_DET
*&---------------------------------------------------------------------*
FORM user_command_det USING f_ucomm    LIKE sy-ucomm
                            i_selfield TYPE slis_selfield.
  DATA : ls_output LIKE LINE OF gt_output.
  DATA: rs_selfield TYPE slis_selfield.
*
  i_selfield-refresh  = 'X'.
  rs_selfield-refresh = 'X'.
*
  CASE sy-ucomm.
    WHEN '&FILE'. "GENERA ARCHIVO
      IF zfile IS NOT INITIAL.
        PERFORM get_file USING zfile.
      ELSE.
        MESSAGE 'Debe Indicar la Ruta del Archivo de Texto' TYPE  'E'.
      ENDIF.
    WHEN 'LINE'.
      CALL SCREEN 0100
       STARTING AT 20 1.
  ENDCASE.
*
  CASE f_ucomm.
    WHEN '&IC1'. "Doble Click
      READ TABLE  gt_output INTO ls_output INDEX i_selfield-tabindex.
      IF sy-subrc EQ 0.
        PERFORM call_faglb03 USING ls_output-saknr sd_bukrs-low sd_gjahr-low.
      ENDIF.
  ENDCASE.

ENDFORM.                    "USER_COMMAND_DET
*---------------------------------------------------------------------*
*       FORM standard                                                 *
*---------------------------------------------------------------------*
* FORM routine for PF Status.
*---------------------------------------------------------------------*
FORM standar_det                                            "#EC CALLED
            USING extab TYPE slis_t_extab.                  "#EC NEEDED

  SET PF-STATUS 'STANDARD' .
  SET TITLEBAR 'TITULO'.

ENDFORM.                                                    "standard01
*&---------------------------------------------------------------------*
*&      Form  GET_FILE
*&---------------------------------------------------------------------*
FORM get_file USING spath_file.
*data SPATH_FILE type rlgrap-filename.

  path_file = spath_file.
  CONCATENATE path_file '\BALANCE' '_' sy-datum '_' sy-uzeit '.txt' INTO path_file.
  PERFORM crea_directorio USING spath_file.
  PERFORM prepara_file USING path_file.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREA_DIRECTORIO
*&---------------------------------------------------------------------*
FORM crea_directorio USING ppath_file.
  DATA: p_dir TYPE rlgrap-filename.
  p_dir = ppath_file.

  CALL FUNCTION 'GUI_CREATE_DIRECTORY'
    EXPORTING
      dirname = p_dir
    EXCEPTIONS
      failed  = 1
      OTHERS  = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREPARA_FILE
*&---------------------------------------------------------------------*
FORM prepara_file  USING    p_path_file.
  DATA : ls_output LIKE LINE OF gt_output,
         v_long    TYPE i,
         v_len     TYPE i.
*
  v_horiz_tab = cl_abap_char_utilities=>horizontal_tab.
  v_newline   = cl_abap_char_utilities=>newline.
  g_lineas    = 1.
  g_primero   = 0.
  CLEAR gt_data.

  LOOP AT gt_output INTO ls_output.


    IF g_lineas LE g_line.
      IF g_primero = 0.
        PERFORM cabecera.
        PERFORM new_page.
        CLEAR g_totlaufd.
        g_primero = 1.
        txt1 = ls_output-saknr. " cuenta
        txt2 = ls_output-txt50. " descripcion
        WRITE : ls_output-summe_soll TO txt3 CURRENCY ls_output-hwaer. " DEBE
        WRITE : ls_output-summe_haben TO txt4 CURRENCY ls_output-hwaer. " HABER
        WRITE : ls_output-saldo_ende_soll TO txt5 CURRENCY ls_output-hwaer. " Saldo deudor
        WRITE : ls_output-saldo_ende_haben TO txt6 CURRENCY ls_output-hwaer. " Saldo Acreedor
        WRITE : ls_output-bestandkonto TO txt7 CURRENCY ls_output-hwaer. " activo
        WRITE : ls_output-bestandkonto_passiv TO txt8 CURRENCY ls_output-hwaer. " pasivo
        WRITE : ls_output-erfolg_aufwand TO txt9 CURRENCY ls_output-hwaer. " perdida
        WRITE : ls_output-erfolg_ertrag TO txt10 CURRENCY ls_output-hwaer. " ganancia

        g_totlaufd = 1.
      ELSE.
        txt1 = ls_output-saknr. " cuenta
        txt2 = ls_output-txt50. " descripcion
        WRITE : ls_output-summe_soll TO txt3 CURRENCY ls_output-hwaer. " DEBE
        WRITE : ls_output-summe_haben TO txt4 CURRENCY ls_output-hwaer. " HABER
        WRITE : ls_output-saldo_ende_soll TO txt5 CURRENCY ls_output-hwaer. " Saldo deudor
        WRITE : ls_output-saldo_ende_haben TO txt6 CURRENCY ls_output-hwaer. " Saldo Acreedor
        WRITE : ls_output-bestandkonto TO txt7 CURRENCY ls_output-hwaer. " activo
        WRITE : ls_output-bestandkonto_passiv TO txt8 CURRENCY ls_output-hwaer. " pasivo
        WRITE : ls_output-erfolg_aufwand TO txt9 CURRENCY ls_output-hwaer. " perdida
        WRITE : ls_output-erfolg_ertrag TO txt10 CURRENCY ls_output-hwaer. " ganancia
        g_totlaufd =  g_totlaufd + 1.
      ENDIF.

      IF  txt5 IS INITIAL.
        CONCATENATE '-' txt5 INTO txt5.
      ENDIF.

      IF  txt7 IS INITIAL.
        CONCATENATE '-' txt7 INTO txt7.
      ENDIF.

    ELSE.  " titulo
*         PERFORM Subtotal.
      PERFORM cabecera.
      PERFORM new_page.
      g_lineas = 1.
      CLEAR g_totlaufd.
      g_totlaufd =  1.
      txt1 = ls_output-saknr. " cuenta
      txt2 = ls_output-txt50. " descripcion
      WRITE : ls_output-summe_soll TO txt3 CURRENCY ls_output-hwaer. " DEBE
      WRITE : ls_output-summe_haben TO txt4 CURRENCY ls_output-hwaer. " HABER
      WRITE : ls_output-saldo_ende_soll TO txt5 CURRENCY ls_output-hwaer. " Saldo deudor
      WRITE : ls_output-saldo_ende_haben TO txt6 CURRENCY ls_output-hwaer. " Saldo Acreedor
      WRITE : ls_output-bestandkonto TO txt7 CURRENCY ls_output-hwaer. " activo
      WRITE : ls_output-bestandkonto_passiv TO txt8 CURRENCY ls_output-hwaer. " pasivo
      WRITE : ls_output-erfolg_aufwand TO txt9 CURRENCY ls_output-hwaer. " perdida
      WRITE : ls_output-erfolg_ertrag TO txt10 CURRENCY ls_output-hwaer. " ganancia
    ENDIF.

*    SHIFT TXT1 RIGHT DELETING TRAILING SPACE.
*    SHIFT txt2 RIGHT DELETING TRAILING SPACE.
*    SHIFT txt2 LEFT DELETING LEADING ' '.
    v_len = strlen( txt2 ).
    DESCRIBE FIELD txt2 LENGTH v_long IN CHARACTER MODE.
    v_len = v_long - v_len.
    DO v_len TIMES.
      CONCATENATE txt2 space INTO txt2.
    ENDDO.

    SHIFT txt3 RIGHT DELETING TRAILING space.
    SHIFT txt4 RIGHT DELETING TRAILING space.
    SHIFT txt5 RIGHT DELETING TRAILING space.
    SHIFT txt6 RIGHT DELETING TRAILING space.
    SHIFT txt7 RIGHT DELETING TRAILING space.
    SHIFT txt8 RIGHT DELETING TRAILING space.
    SHIFT txt9 RIGHT DELETING TRAILING space.
    SHIFT txt10 RIGHT DELETING TRAILING space.

    CLEAR s_texto.
*    CONCATENATE TXT1 V_HORIZ_TAB
*                TXT2 V_HORIZ_TAB
*                TXT3 V_HORIZ_TAB
*                TXT4 V_HORIZ_TAB
*                TXT5 V_HORIZ_TAB
*                TXT6 V_HORIZ_TAB
*                TXT7 V_HORIZ_TAB
*                TXT8  INTO S_TEXTO.
** v_NEWLINE
* se arma texto patra colocar en Tabla interna
    CLEAR s_texto.
    s_texto+0(20)  = txt1.
    s_texto+20(60) = txt2.
    s_texto+80(20)  = txt3.
    s_texto+100(20)  = txt4.
    s_texto+120(20)  = txt5.
    s_texto+140(20)  = txt6.
    s_texto+160(20)  = txt7.
    s_texto+180(20)  = txt8.
    s_texto+200(20)  = txt9.
    s_texto+220(20)  = txt10.

    APPEND s_texto TO gt_data.
    g_lineas = g_lineas + 1.

  ENDLOOP.

  PERFORM  gui_download_f USING p_path_file.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CABECERA
*&---------------------------------------------------------------------*
FORM cabecera .
  DATA :  p_linea(240) TYPE c.
  DATA :  p_butxt LIKE t001-butxt.
***** se extrae la descripcion de la sociedad

  SELECT SINGLE butxt
    INTO p_butxt
    FROM t001
    WHERE bukrs EQ sd_bukrs-low.
  s_texto = '     '.
  CONCATENATE s_texto v_newline  INTO s_texto.
  SHIFT s_texto RIGHT DELETING TRAILING space.
  APPEND s_texto TO gt_data.
  APPEND s_texto TO gt_data.
  APPEND s_texto TO gt_data.
  APPEND s_texto TO gt_data.
  APPEND s_texto TO gt_data.
  APPEND s_texto TO gt_data.

  txt1 = 'Sociedad : '.
  txt2 = p_butxt.
  s_texto+0(20)  = txt1.
  s_texto+20(30) = txt2.
  APPEND s_texto TO gt_data.

  s_texto = '     '.
  txt3 = 'Balance General     (Mensual)'.
  s_texto+120(20)  = txt3.
  txt4 = 'Fecha Emision :'.

  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal = sy-datum
    IMPORTING
      date_external = txt5
*   EXCEPTIONS
*     DATE_INTERNAL_IS_INVALID       = 1
*     OTHERS        = 2
    .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*   TXT5 = sy-datum.

  s_texto+200(20)  = txt4.
  s_texto+220(20)  = txt5.
  APPEND s_texto TO gt_data.


  s_texto = '     '.
  txt6 = gv_lowdate.
  txt7 = 'A'.
  txt8 = gv_highdate.
  s_texto+110(20)  = txt6.
  s_texto+130(5)  = txt7.
  s_texto+135(20)  = txt8.
  APPEND s_texto TO gt_data.

ENDFORM.                    " CABECERA
*&---------------------------------------------------------------------*
*&      Form  NEW_PAGE
*&---------------------------------------------------------------------*
FORM new_page.
  DATA :  p_linea(240) TYPE c.
  DO 240 TIMES.
    CONCATENATE p_linea '-' INTO p_linea.
  ENDDO.

  s_texto = '     '.
  CONCATENATE s_texto v_newline  INTO s_texto.
  SHIFT s_texto RIGHT DELETING TRAILING space.
  APPEND s_texto TO gt_data.
  APPEND s_texto TO gt_data.
  APPEND s_texto TO gt_data.
  APPEND s_texto TO gt_data.
  txt1 = 'Cuenta'.
  txt2 = 'Descripcion'.
  txt3 = 'Débitos'.
  txt4 = 'Creditos'.
  txt5 = 'Saldo Deudor'.
  txt6 = 'Saldo Acreedor'.
  txt7 = 'Activos'.
  txt8 = 'Pasivos'.
  txt9 = 'Perdida'.
  txt10 = 'Ganancia'.

*  SHIFT TXT1 RIGHT DELETING TRAILING SPACE.
*  SHIFT TXT2 RIGHT DELETING TRAILING SPACE.
  SHIFT txt3 RIGHT DELETING TRAILING space.
  SHIFT txt4 RIGHT DELETING TRAILING space.
  SHIFT txt5 RIGHT DELETING TRAILING space.
  SHIFT txt6 RIGHT DELETING TRAILING space.
  SHIFT txt7 RIGHT DELETING TRAILING space.
  SHIFT txt8 RIGHT DELETING TRAILING space.
  SHIFT txt9 RIGHT DELETING TRAILING space.
  SHIFT txt10 RIGHT DELETING TRAILING space.

*  CONCATENATE TXT1 V_HORIZ_TAB
*         TXT2 V_HORIZ_TAB
*         TXT3 V_HORIZ_TAB
*         TXT4 V_HORIZ_TAB
*         TXT5 V_HORIZ_TAB
*         TXT6 V_HORIZ_TAB
*         TXT7 V_HORIZ_TAB
*         TXT8 V_NEWLINE  INTO S_TEXTO.

  APPEND p_linea TO gt_data.

  CLEAR s_texto.
  s_texto+0(20)  = txt1.
  s_texto+20(60) = txt2.
  s_texto+80(20)  = txt3.
  s_texto+100(20)  = txt4.
  s_texto+120(20)  = txt5.
  s_texto+140(20)  = txt6.
  s_texto+160(20)  = txt7.
  s_texto+180(20)  = txt8.
  s_texto+200(20)  = txt9.
  s_texto+220(20)  = txt10.
  APPEND s_texto TO gt_data.

  APPEND p_linea TO gt_data.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALL_FAGLB03
*&---------------------------------------------------------------------*
FORM call_faglb03  USING    p_cuenta
                            p_bukrs
                            p_gjahr.

  DATA p_rldnr TYPE fagl_rldnr.
  p_rldnr = sd_rldnr-low.

  SET PARAMETER ID :'ACC' FIELD  p_cuenta,
                    'BUK' FIELD  p_bukrs,
                    'GJR' FIELD  p_gjahr,
                    'GLN_FLEX' FIELD p_rldnr.


  CALL TRANSACTION 'FAGLB03' AND SKIP FIRST SCREEN.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GUI_DOWNLOAD_F
*&---------------------------------------------------------------------*
FORM gui_download_f USING path_file.
  DATA: xtextm(100) TYPE c.

  DATA : nombre_a  TYPE string.
  nombre_a = path_file.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = nombre_a
      filetype                = 'ASC'
      append                  = ' '
      confirm_overwrite       = ' '
    TABLES
*     data_tab                = reg_stder
      data_tab                = gt_data
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.

  IF sy-subrc <> 0.
    WRITE :/ 'error!!!!'  ,
           /  sy-msgv1 ,
           /  sy-msgv2 ,
           /  sy-msgv3 ,
           /  sy-msgv4 .
  ELSE.
    SKIP 2 .
*    FORMAT COLOR 3 ON.
    CONCATENATE 'Se genero archivo :' path_file INTO xtextm.
    MESSAGE  xtextm TYPE 'S'.
*     WRITE : / 'Se genero archivo :', PATH_FILE.
*    FORMAT COLOR 3 OFF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LT_COMMENT_BUILD_NEW
*&---------------------------------------------------------------------*
FORM lt_comment_build_new USING xt_top_of_page TYPE
                                slis_t_listheader.

  DATA: ls_line     TYPE slis_listheader,
        lv_date(10) TYPE c.
  DATA: ti_zfigiro LIKE zfigiro OCCURS 0 WITH HEADER LINE.
*
  IF gs_t001-adrnr NE space.
* Company name and address details for header.
    PERFORM get_comp_address.
  ENDIF.

  CLEAR: gs_t001z.
* R.U.T Tax Number.
  SELECT SINGLE paval FROM t001z INTO gs_t001z-paval
                     WHERE bukrs = gs_t001-bukrs
                     AND party = 'TAXNR'.
  CHECK sy-subrc = 0.

* SE EXTRAE GIRO
  SELECT * FROM zfigiro INTO TABLE ti_zfigiro
           WHERE bukrs = gs_t001-bukrs.

* Listheader
  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = 'Balance'.
  APPEND ls_line TO xt_top_of_page.

* Listheader: show company code name
  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key =  TEXT-005 .
  ls_line-info = gs_t001-butxt .
  APPEND ls_line TO xt_top_of_page.

* Listheader: show company address
  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key =  TEXT-006 .
  ls_line-info = gs_addr_comp-street .
  APPEND ls_line TO xt_top_of_page.

* Listheader: show city
  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key =  TEXT-007 .
  ls_line-info = gs_addr_comp-city1 .
  APPEND ls_line TO xt_top_of_page.
  CLEAR: gs_addr_comp, gs_addr_sel.

* Listheader: show R.U.T.
  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key =  TEXT-008 .
  ls_line-info = gs_t001z-paval .
  APPEND ls_line TO xt_top_of_page.

* Listheader: show Fiscal Period
  CLEAR : gv_lowdate, gv_highdate, gv_date.

  CONCATENATE gc_01 '.' gc_01 '.' sd_gjahr-low INTO gv_lowdate.
  CONCATENATE p_date+6(2) '.' p_date+4(2) '.' p_date+0(4) INTO
  gv_highdate.
  CONCATENATE gv_lowdate 'TO' gv_highdate INTO gv_date
              SEPARATED BY space.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key =  TEXT-009 .
  ls_line-info = gv_date.
  APPEND ls_line TO xt_top_of_page.

* Listheader: show Date
  CLEAR lv_date.
  WRITE sy-datum TO lv_date.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-key =  TEXT-010 .
  ls_line-info = lv_date .
  APPEND ls_line TO xt_top_of_page.

******** Giro **************************+
  LOOP AT ti_zfigiro.
    IF ti_zfigiro-giro_1 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR ls_line.
      ls_line-typ  = 'S'.
      ls_line-key =  TEXT-016 .
      ls_line-info = ti_zfigiro-giro_1 .
      APPEND ls_line TO xt_top_of_page.
    ENDIF.

    IF ti_zfigiro-giro_2 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR ls_line.
      ls_line-typ  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      ls_line-info = ti_zfigiro-giro_2.
      APPEND ls_line TO xt_top_of_page.
    ENDIF.

    IF ti_zfigiro-giro_3 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR ls_line.
      ls_line-typ  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      ls_line-info = ti_zfigiro-giro_3.
      APPEND ls_line TO xt_top_of_page.
    ENDIF.

    IF ti_zfigiro-giro_4 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR ls_line.
      ls_line-typ  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      ls_line-info = ti_zfigiro-giro_4.
      APPEND ls_line TO xt_top_of_page.
    ENDIF.

    IF ti_zfigiro-giro_5 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR ls_line.
      ls_line-typ  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      ls_line-info = ti_zfigiro-giro_5.
      APPEND ls_line TO xt_top_of_page.
    ENDIF.

    IF ti_zfigiro-giro_6 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR ls_line.
      ls_line-typ  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      ls_line-info = ti_zfigiro-giro_6.
      APPEND ls_line TO xt_top_of_page.
    ENDIF.

    IF ti_zfigiro-giro_7 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR ls_line.
      ls_line-typ  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      ls_line-info = ti_zfigiro-giro_7.
      APPEND ls_line TO xt_top_of_page.
    ENDIF.

    IF ti_zfigiro-giro_8 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR ls_line.
      ls_line-typ  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      ls_line-info = ti_zfigiro-giro_8.
      APPEND ls_line TO xt_top_of_page.
    ENDIF.

  ENDLOOP.

ENDFORM.                               " LT_COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT_NEW
*&---------------------------------------------------------------------*
FORM layout_init_new CHANGING rs_layout TYPE slis_layout_alv.

*columns separated by space
*  RS_LAYOUT-NO_VLINE      = 'X'.
*Build layout for list display
  rs_layout-detail_popup      = 'X'.
*Optimize column width
  rs_layout-colwidth_optimize  = 'X'.
*no choice for summing up
  rs_layout-no_sumchoice  = 'X'.

  rs_layout-zebra = 'X'.
  rs_layout-info_fieldname    = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_100'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN'OK'.
      SET SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT_NEW
*&---------------------------------------------------------------------*
FORM FIELDCAT_INIT_NEW CHANGING RT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.
  FIELD-SYMBOLS <ls_fcat> type slis_fieldcat_alv.
* User definded additional field(s) not included in structure
* but with ddic reference structure
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = GC_STRUCTURE_NEW
    CHANGING
      CT_FIELDCAT            = RT_FIELDCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

  DELETE RT_FIELDCAT WHERE FIELDNAME = GC_HWAER.

ENDFORM.                               " FIELDCAT_INIT_NEW
