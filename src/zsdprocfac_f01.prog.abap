*&---------------------------------------------------------------------*
*&  Include           ZSDPROCFAC_F01
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM EXIT_PROGRAM                                             *
*---------------------------------------------------------------------*
FORM exit_program.

  LEAVE PROGRAM.

ENDFORM.                    "exit_program
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM build_fieldcat CHANGING pt_fieldcat TYPE lvc_t_fcat.

  DATA ls_fcat TYPE lvc_s_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZSTR_MON_FAC'
    CHANGING
      ct_fieldcat      = pt_fieldcat.

  LOOP AT pt_fieldcat INTO ls_fcat.
    CASE ls_fcat-fieldname.
      WHEN 'ZRUT_CLI_FACT'.
        ls_fcat-no_out = true.
      WHEN 'DESCRIP'.
        ls_fcat-key       = true.
        ls_fcat-reptext   = TEXT-t01."'Descripción'.
        ls_fcat-scrtext_l = TEXT-t01."'Descripción'.
        ls_fcat-scrtext_m = TEXT-t01."'Descripción'.
        ls_fcat-scrtext_s = TEXT-t01."'Descripción'.
      WHEN 'STATUS'.
        ls_fcat-just      = 'C'.
        ls_fcat-outputlen = '5'.
        ls_fcat-key       = true.
        ls_fcat-reptext   = TEXT-t02. "'Estado'.
        ls_fcat-scrtext_l = TEXT-t02. "'Estado'.
        ls_fcat-scrtext_m = TEXT-t02. "'Estado'.
        ls_fcat-scrtext_s = TEXT-t02. "'Estado'.
      WHEN 'STATUS_ELEC'.
        ls_fcat-just      = 'C'.
        ls_fcat-outputlen = '5'.
        ls_fcat-key       = true.
        ls_fcat-reptext   = TEXT-t03. "'E°Elec'.
        ls_fcat-scrtext_l = TEXT-t03. "'E°Elec'.
        ls_fcat-scrtext_m = TEXT-t03. "'E°Elec'.
        ls_fcat-scrtext_s = TEXT-t03. "'E°Elec'.
      WHEN 'FOLIO'.
        ls_fcat-col_opt   = true.
      WHEN 'ZBLART'.
        ls_fcat-outputlen = '5'.
        ls_fcat-just      = 'C'.
        ls_fcat-key       = true.
      WHEN 'ZNUM_DOC_CORE'.
        ls_fcat-key       = true.
        ls_fcat-just      = 'R'.
        ls_fcat-reptext   = TEXT-t04. "'Doc.Core'.
        ls_fcat-scrtext_l = TEXT-t04. "'Doc.Core'.
        ls_fcat-scrtext_m = TEXT-t04. "'Doc.Core'.
        ls_fcat-scrtext_s = TEXT-t04. "'Doc.Core'.
      WHEN 'FACTURA'.
        ls_fcat-just = 'R'.
      WHEN 'PEDIDO'.
        ls_fcat-just = 'R'.
        ls_fcat-reptext   = TEXT-t05. "'Pedido'.
        ls_fcat-scrtext_l = TEXT-t05. "'Pedido'.
        ls_fcat-scrtext_m = TEXT-t05. "'Pedido'.
        ls_fcat-scrtext_s = TEXT-t05. "'Pedido'.
      WHEN 'ZMONTO_TOTAL' OR 'ZTIP_CAMBIO_REF'.
        ls_fcat-cfieldname = space.
    ENDCASE.
    MODIFY pt_fieldcat FROM ls_fcat.
  ENDLOOP.

ENDFORM.                    "build_fieldcat
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_OUTTAB  text
*      <--P_GT_FIELDCAT  text
*      <--P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM create_and_init_alv CHANGING gt_outtab LIKE gt_outtab[]
                                  pt_fieldcat TYPE lvc_t_fcat.
*
  DATA gv_event_receiver TYPE REF TO lcl_event_receiver.
*
  CREATE OBJECT g_custom_container
    EXPORTING
      container_name = g_container.
*
  CREATE OBJECT g_grid
    EXPORTING
      i_parent = g_custom_container.
*
  CREATE OBJECT g_verifier.
*
  SET HANDLER g_verifier->handle_data_changed FOR g_grid.
*
  PERFORM select_data TABLES gt_cabpedext USING space.
*
  CALL METHOD g_verifier->set_table_is_not_initial.
  SORT gt_cabpedext BY zblart ASCENDING.
*
  LOOP AT gt_cabpedext INTO ls_cabpedext.
    MOVE-CORRESPONDING ls_cabpedext TO ls_outtab.
    APPEND ls_outtab TO gt_outtab.
  ENDLOOP.

* §3.Set all cells of the table non-editable by using the style table.
  LOOP AT gt_outtab INTO ls_outtab.
    l_index = sy-tabix.
    REFRESH lt_celltab.
    PERFORM fill_celltab USING 'RO' CHANGING lt_celltab.
* Copy your celltab to the celltab of the current row of gt_outtab.
    INSERT LINES OF lt_celltab INTO TABLE ls_outtab-celltab.
    MODIFY gt_outtab FROM ls_outtab INDEX l_index.
  ENDLOOP.

  PERFORM build_fieldcat       CHANGING pt_fieldcat.
  PERFORM exclude_tb_functions CHANGING lt_exclude.
*
  CREATE OBJECT gv_event_receiver.
  SET HANDLER gv_event_receiver->handle_toolbar      FOR g_grid.
  SET HANDLER gv_event_receiver->handle_double_click FOR g_grid.
  SET HANDLER gv_event_receiver->user_command        FOR g_grid.
*
  gs_layout-stylefname = 'CELLTAB'.
  gs_layout-zebra      = true.
*
  lay_var-report = sy-repid.
*
  CALL METHOD g_grid->set_table_for_first_display
    EXPORTING
      i_save               = 'A'
      is_layout            = gs_layout
      is_variant           = lay_var
      it_toolbar_excluding = lt_exclude
    CHANGING
      it_fieldcatalog      = pt_fieldcat
      it_outtab            = gt_outtab[].

* Set editable cells to ready for input initially
  CALL METHOD g_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.
*
ENDFORM.                               "CREATE_AND_INIT_ALV

*&---------------------------------------------------------------------*
*&      Form  select_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_OUTTAB  text
*----------------------------------------------------------------------*
FORM select_data TABLES gt_cabpedext LIKE gt_cabpedext
                 USING flag.

  PERFORM det_fecfaccon.

  PERFORM gen_ran_error.
  PERFORM gen_ran_error_e.

  CLEAR doctoproc.
  PERFORM obt_data TABLES   gt_cabpedext
                   USING flag
                   CHANGING doctoproc.

  IF doctoproc > 10.
    DATA answer.
    CLEAR answer.
    CALL FUNCTION 'POPUP_WITH_2_BUTTONS_TO_CHOOSE'
      EXPORTING
        defaultoption = '2'
        diagnosetext1 = TEXT-t09
        diagnosetext2 = TEXT-t10
        textline1     = TEXT-t11
        textline2     = TEXT-t12
        "'La cantidad de documentos seleccionados, al ser procesados'
        textline3     = ''
        "'en forma masiva podrían causar problemas de actualización.'
        text_option1  = 'Si'
        "'Por esto se recomienda utilizar el proceso de fondo.'
        text_option2  = 'No'
        "'¿Desea continuar considerando estos posibles problemas?'
        titel         = TEXT-t13 "'Advertencia'
      IMPORTING
        answer        = answer.
    IF answer EQ 2.
      FREE gt_cabpedext.
      ok_code = 'BACK'.
    ENDIF.
  ENDIF.

ENDFORM.                               " select_data
*----------------------------------------------------------------
FORM fill_celltab USING VALUE(p_mode)
                  CHANGING pt_celltab TYPE lvc_t_styl.
  DATA l_mode TYPE raw4.
* This forms sets the style of columns 'PRICE', FLDATE and PLANETYPE
* editable

  IF p_mode EQ 'RW'.
    l_mode = cl_gui_alv_grid=>mc_style_enabled.
  ELSE.                                "p_mode eq 'RO'
    l_mode = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  PERFORM changing_cell USING 'ZNUM_DOC_CORE'    l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZBLART'           l_mode  CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'STATUS'           l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZELECTRONICO'     l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'VKORG'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'VTWEG'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'SPART'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'VKBUR'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'VKGRP'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'KUNNR_CLI_FACT'   l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZNOM_CLI_FACT'    l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZRUT_CLI_PAGADOR' l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZGIRO_CLI_FACT'   l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZDIR_FACT'        l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZCOMUNA_FACT'     l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZCIUDAD_FACT'     l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'VERTN'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZFEC_CONT'        l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZUONR'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZTERM'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZIND_TRASPASO'    l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'XREF3'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'HBKID'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'VERTT'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'XREF1'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'WAERS'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZPLAN'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZLSCH'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZTIP_CAMBIO_REF'  l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZCENTRO'          l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZNUM_MANDATO'     l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZNUM_ENDOSO'      l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZIND_AFECTO'      l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZKVGR3'           l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZKVGR4'           l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZCOPAGO_PLAN'     l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZMONTO_TOTAL'     l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ZBLOQ_PAGO'       l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'PEDIDO'           l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'FACTURA'          l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'FEC_CAR'          l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'HOR_CAR'          l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'ERROR'            l_mode CHANGING
  pt_celltab.
  PERFORM changing_cell USING 'LOG_ERROR'        l_mode CHANGING
  pt_celltab.

ENDFORM.                               " FILL_CELLTAB

*---------------------------------------------
FORM exclude_tb_functions CHANGING pt_exclude TYPE ui_functions.
*
  DATA ls_exclude TYPE ui_func.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_maximum .
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_minimum .
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_subtot .
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_sum .
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_fc_average .
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_mb_sum .
  APPEND ls_exclude TO pt_exclude.
*
  ls_exclude = cl_gui_alv_grid=>mc_mb_subtot .
  APPEND ls_exclude TO pt_exclude.
*
ENDFORM.                               " EXCLUDE_TB_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM save_data.
  DATA: l_valid TYPE c.
* §7.Check if any errors exist in protocol by using method
*    CHECK_CHANGED_DATA of your ALV Grid instance.

* The method CHECK_CHANGED_DATA checks all new cells syntactically,
* raises event DATA_CHANGED and looks then for any entries
* in the error protocol. If any exist the parameter e_valid
* is initial (true in the other case).
*
  CALL METHOD g_grid->check_changed_data
    IMPORTING
      e_valid = l_valid.

  IF l_valid IS INITIAL.
    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        titel = TEXT-i06
        txt1  = TEXT-i07
        txt2  = TEXT-i08
        txt3  = TEXT-i09.

  ELSE.
*    PERFORM update_database.
    MESSAGE s000(0k) WITH TEXT-s01.
  ENDIF.
ENDFORM.                    "save_data
*&---------------------------------------------------------------------*
*&      Form  CHANGING_CELL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PT_CELLTAB  text
*----------------------------------------------------------------------*
FORM changing_cell USING tmp_fieldname l_mode CHANGING pt_celltab TYPE
lvc_t_styl.

  DATA ls_celltab TYPE lvc_s_styl.

  ls_celltab-fieldname = tmp_fieldname.
  ls_celltab-style = l_mode.
  INSERT ls_celltab INTO TABLE pt_celltab.

ENDFORM.                    " CHANGING_CELL
*&---------------------------------------------------------------------*
*&      Form  GENERA_FACTURACION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM genera_facturacion .

  FREE: order_items_in, order_items_inx, order_partners,
  order_schedules_in, order_schedules_inx, bill_data, return.
  CLEAR: order_items_in, order_items_inx, order_partners,
  order_schedules_in, order_schedules_inx,
         gt_cabpedext, order_head, order_headx, bill_data.

  IF gt_cabpedext[] IS INITIAL.
    gt_cabpedext[] = gt_outtab[].
  ENDIF.

  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_selected_rows.

  CLEAR: tmp_index, ls_ind_out.
  READ TABLE lt_selected_rows INTO ls_selected_row INDEX 1.
  CHECK ls_selected_row-row_id > 0.
  LOOP AT lt_selected_rows INTO ls_selected_row.
    PERFORM facturacion TABLES gt_outtab
                        USING ls_selected_row-row_id.
  ENDLOOP.
  PERFORM final_check.

ENDFORM.                    " GENERA_FACTURACION
*&---------------------------------------------------------------------*
*&      Form  COMPLETA_CABECERA_ORDEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_CABPEDEXT_VKORG  text
*      -->P_GT_CABPEDEXT_VTWEG  text
*      -->P_GT_CABPEDEXT_SPART  text
*      -->P_SY_DATUM  text
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_GT_CABPEDEXT_ZBLART  text
*      -->P_GT_CABPEDEXT_VKBUR  text
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_GT_CABPEDEXT_ZELECTRONICO  text
*      <--P_ORDER_HEAD  text
*      <--P_ORDER_HEADX  text
*----------------------------------------------------------------------*
FORM completa_cabecera_orden  USING    p_vkorg
                                       p_vtweg
                                       p_spart
                                       p_bstdk
                                       p_auart
                                       p_ind_e
                                       p_vertn
                                       p_zkvgr3
                                       p_zkvgr4
*                                       p_znum_doc_core
                                       p_zuonr
                                       p_zlsch
                                       p_fecventes
                         CHANGING p_order_header_in  TYPE bapisdhd1
                                  p_order_header_inx TYPE
                                  bapisdhd1x.
*
  CASE p_auart.
    WHEN 'G1' OR 'G2' OR 'G3' OR 'G4'. "Factura
      p_order_header_in-doc_type = 'ZFAC'.
    WHEN 'J1' OR 'J2' OR 'J3' OR 'J4'. "NC
      p_order_header_in-doc_type = 'ZNC'.
    WHEN 'L1' OR 'L2' OR 'L3' OR 'L4'. "ND
      p_order_header_in-doc_type = 'ZND'.
    WHEN 'O1' OR 'O2' OR 'O3' OR 'O4'. "BO
      p_order_header_in-doc_type = 'ZBOL'.
  ENDCASE.
  p_order_header_inx-doc_type = true.
  p_order_header_in-cust_grp1 = p_ind_e.
  p_order_header_inx-cust_grp1 = true.
  CASE p_auart.
    WHEN 'G1' OR 'G3' OR 'J1' OR 'J3' OR 'L1' OR 'L3' OR 'O1' OR 'O3'.
      p_order_header_in-cust_grp2 = '01'.
    WHEN OTHERS.
      p_order_header_in-cust_grp2 = '02'.
  ENDCASE.
  p_order_header_inx-cust_grp2 = true.

  p_order_header_in-cust_grp3  = p_zkvgr3.
  p_order_header_inx-cust_grp3 = true.
  p_order_header_in-cust_grp4  = p_zkvgr4.
  p_order_header_inx-cust_grp4 = true.
*
  p_order_header_in-sales_org   = p_vkorg.  " Organizacion de venta
  p_order_header_inx-sales_org  = true.
  p_order_header_in-distr_chan  = p_vtweg.  " Canal de ditribucucion
  p_order_header_inx-distr_chan = true.
  p_order_header_in-division    = p_spart.  " Sector
  p_order_header_inx-division   = true.
  p_order_header_in-fix_val_dy  = p_fecventes.  " Fecha vencimiento
  p_order_header_inx-fix_val_dy = true.
*
  CLEAR tmp_vertn.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_vertn
    IMPORTING
      output = tmp_vertn.

  p_order_header_in-purch_no_c  = tmp_vertn.  "n° de check
  p_order_header_inx-purch_no_c = true.
*  P_ORDER_HEADER_IN-ALTTAX_CLS  = P_TAXK1.  "Clasificación fiscal
  p_order_header_in-pmnttrms    = 'ZD00'.   "Condicion de pago.
  p_order_header_inx-pmnttrms   = true.
*  P_ORDER_HEADER_IN-VERSION     = P_VERSION."FORMA DE PAGO
*  P_ORDER_HEADER_IN-PRICE_GRP   = P_KONDA.  "Grupo de precios - Cliente
*  P_ORDER_HEADER_IN-SALES_OFF   = P_VKBUR.  "Oficina de Ventas
*  P_ORDER_HEADER_IN-REF_DOC_L   = P_XBLNR.  "Referencia
*  P_ORDER_HEADER_IN-PRICE_DATE  = P_BSTDK.  "Fecha det. precios
*
  p_order_header_in-req_date_h  = p_bstdk.  "Fecha preferente entrega
  p_order_header_inx-req_date_h = true.
  p_order_header_in-purch_date  = p_bstdk.  "Fecha del pedido
  p_order_header_inx-purch_date = true.
  p_order_header_in-price_date  = p_bstdk.  "Fecha pedido del destinat.
  p_order_header_inx-price_date = true.
  p_order_header_in-po_dat_s    = p_bstdk.
  p_order_header_inx-po_dat_s   = true.
  p_order_header_in-ass_number  = p_zuonr. "ZNUM_DOC_CORE.
  p_order_header_inx-ass_number = true.
  p_order_header_in-pymt_meth   = p_zlsch.
  p_order_header_inx-pymt_meth  = true.

ENDFORM.                    " COMPLETA_CABECERA_ORDEN
*&---------------------------------------------------------------------*
*&      Form  COMPLETA_PARTNER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ORDER_PARTNERS  text
*      -->P_BILL_DATA  text
*      -->P_GT_CABPEDEXT_ZRUT_CLI_PAGADOR  text
*      -->P_GT_CABPEDEXT_ZRUT_CLI_FACT  text
*----------------------------------------------------------------------*
FORM completa_partner TABLES ti_partner     LIKE order_partners
                       USING bill_data      TYPE  bapivbrk
                             tmp_pagador
                             tmp_cli_fact
                             lp_zuonr
                             lp_znum_doc_core
                       CHANGING msj.

  DATA: wa_partners  TYPE bapiparnr.
  DATA pagador  TYPE kunnr.
  DATA cli_fact TYPE kunnr.
  DATA l_zrut_beneficiari TYPE stcd1.
*
  CLEAR pagador.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE kunnr INTO pagador
*    FROM kna1  WHERE stcd1 EQ tmp_pagador.
*
* NEW CODE
  SELECT kunnr
  UP TO 1 ROWS  INTO pagador
    FROM kna1  WHERE stcd1 EQ tmp_pagador ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc NE 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE kunnr INTO pagador
*      FROM kna1  WHERE kunnr EQ tmp_pagador.
*
* NEW CODE
    SELECT kunnr
    UP TO 1 ROWS  INTO pagador
      FROM kna1  WHERE kunnr EQ tmp_pagador ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      pagador = tmp_pagador.
    ENDIF.
  ENDIF.
*
  CLEAR cli_fact.
  CONDENSE lp_zuonr NO-GAPS.
  IF lp_zuonr IS NOT INITIAL AND lp_zuonr NE '0'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zrut_beneficiari  INTO l_zrut_beneficiari
*      FROM zdetpedext WHERE znum_doc_core EQ lp_znum_doc_core.
*
* NEW CODE
    SELECT zrut_beneficiari
    UP TO 1 ROWS   INTO l_zrut_beneficiari
      FROM zdetpedext WHERE znum_doc_core EQ lp_znum_doc_core ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE kunnr INTO cli_fact
*           FROM kna1 WHERE stcd1 EQ l_zrut_beneficiari.
*
* NEW CODE
      SELECT kunnr
      UP TO 1 ROWS  INTO cli_fact
           FROM kna1 WHERE stcd1 EQ l_zrut_beneficiari ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE kunnr INTO cli_fact
*         FROM kna1 WHERE stcd1 EQ tmp_cli_fact.
*
* NEW CODE
    SELECT kunnr
    UP TO 1 ROWS  INTO cli_fact
         FROM kna1 WHERE stcd1 EQ tmp_cli_fact ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc NE 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE kunnr INTO cli_fact
*          FROM kna1 WHERE kunnr EQ  tmp_cli_fact.
*
* NEW CODE
      SELECT kunnr
      UP TO 1 ROWS  INTO cli_fact
          FROM kna1 WHERE kunnr EQ  tmp_cli_fact ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        cli_fact = tmp_cli_fact.
      ENDIF.
    ENDIF.
  ENDIF.

  wa_partners-partn_role = 'AG'.
  bill_data-bill_to      = wa_partners-partn_numb = pagador.
  APPEND wa_partners TO ti_partner.
  CLEAR wa_partners.

  wa_partners-partn_role = 'RG'.
  wa_partners-partn_numb = pagador.
  APPEND wa_partners TO ti_partner.
  CLEAR wa_partners.

  IF  NOT l_zrut_beneficiari IS INITIAL
      AND cli_fact IS INITIAL.
    CONCATENATE TEXT-t22 l_zrut_beneficiari
                               INTO msj SEPARATED BY space.
  ELSE.
    wa_partners-partn_role = 'RE'.
    bill_data-ship_to      = wa_partners-partn_numb = cli_fact.
    APPEND wa_partners TO ti_partner.
    CLEAR wa_partners.
  ENDIF.

  wa_partners-partn_role = 'WE'.
  bill_data-payer        = wa_partners-partn_numb = pagador.
  APPEND wa_partners TO ti_partner.
  CLEAR wa_partners.
ENDFORM.                    " COMPLETA_PARTNER
*&---------------------------------------------------------------------*
*&      Form  COMPLETA_POSICION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ORDER_ITEMS_IN  text
*      -->P_ORDER_ITEMS_INX  text
*      -->P_ORDER_PARTNERS  text
*      -->P_ORDER_SCHEDULES_IN  text
*      -->P_ORDER_SCHEDULES_INX  text
*      -->P_ORDER_CONDITIONS_IN  text
*      -->P_ORDER_CONDITIONS_INX  text
*      -->P_GT_CABPEDEXT  text
*      -->P_LS_DETPEDEXT  text
*      -->P_POS  text
*----------------------------------------------------------------------*
FORM completa_posicion TABLES ti_items_in       LIKE order_items_in
                              ti_items_inx      LIKE order_items_inx
                              ti_partners       LIKE order_partners
                              ti_schedules_in   LIKE order_schedules_in
                              ti_schedules_inx  LIKE order_schedules_inx
                              ti_cond_in  LIKE order_conditions_in
                              ti_cond_inx LIKE order_conditions_inx
                        USING gt_cabpedext         STRUCTURE
                              zstr_mon_fac
                              ls_detpedext         STRUCTURE zdetpedext
                              tabix.

  CLEAR:  wa_items_in, wa_items_inx, wa_partners,
  wa_schedules_in, wa_schedules_inx,  wa_items_in,  wa_items_inx,
  wa_cond_in, wa_cond_inx.

  wa_items_in-itm_number  = tabix * 10.
  wa_items_inx-itm_number = wa_items_in-itm_number.
  wa_cond_in-itm_number   = wa_items_in-itm_number.
  wa_cond_inx-itm_number  = wa_items_in-itm_number.

  wa_items_inx-updateflag     = true.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE matnr INTO mara-matnr
*    FROM mara WHERE bismt EQ ls_detpedext-matnr.
*
* NEW CODE
  SELECT matnr
  UP TO 1 ROWS  INTO mara-matnr
    FROM mara WHERE bismt EQ ls_detpedext-matnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    wa_items_in-material        = mara-matnr.
  ELSE.
    IF ls_detpedext-matnr NE '000000000000000000' OR
      NOT ls_detpedext-matnr IS INITIAL.
      WHILE ls_detpedext-matnr(1) EQ '0'.
        SHIFT ls_detpedext-matnr LEFT.
      ENDWHILE.
    ENDIF.
    CONCATENATE TEXT-t20 "'Core-'
                ls_detpedext-matnr INTO wa_items_in-material.
    CONDENSE ls_detpedext-matnr NO-GAPS.
  ENDIF.

  wa_items_inx-material       = true.

  wa_items_in-plant           = gt_cabpedext-zcentro.
  wa_items_inx-plant          = true.

  wa_items_in-target_qty      = ls_detpedext-menge.
  wa_items_inx-target_qty     = true.

  wa_schedules_in-itm_number  = wa_items_in-itm_number.
  wa_schedules_inx-itm_number = true.

  wa_schedules_in-req_qty     = ls_detpedext-menge.
  wa_schedules_inx-req_qty    = true.

  wa_items_in-purch_date      = gt_cabpedext-zfec_cont.
  wa_items_inx-purch_date     = true.

  wa_items_in-po_dat_s        = sy-datum.
  wa_items_inx-po_dat_s       = true.

  wa_items_in-pymt_meth       = gt_cabpedext-zlsch.
  wa_items_inx-pymt_meth      = true.

  wa_partners-partn_role      = 'ZB'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE kunnr  INTO wa_partners-partn_numb
*    FROM kna1 WHERE stcd1 EQ ls_detpedext-zrut_beneficiari.
*
* NEW CODE
  SELECT kunnr
  UP TO 1 ROWS   INTO wa_partners-partn_numb
    FROM kna1 WHERE stcd1 EQ ls_detpedext-zrut_beneficiari ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc NE 0.
    wa_partners-partn_numb = ls_detpedext-zrut_beneficiari.
  ENDIF.

  wa_partners-itm_number = wa_items_in-itm_number.
********************************************************
  DATA tip_cond      TYPE c LENGTH 4.
  DATA tmp_divisor   TYPE i.
  DATA tmp_prec      LIKE ls_detpedext-zprec.
  DATA tmp_val_cuota LIKE ls_detpedext-zprec.

  CLEAR tip_cond.

  tmp_divisor = '1'.
  IF gt_cabpedext-zkvgr4 IS INITIAL.
    IF gt_cabpedext-zuonr IS INITIAL.
      tip_cond = 'ZPR0'.
    ELSE.
      CASE gt_cabpedext-zkvgr3.
        WHEN '01'.
          tip_cond = 'ZPR3'.
        WHEN '02'.
          tip_cond = 'ZPR4'.
        WHEN '03'.
          tip_cond = 'ZPR9'.
        WHEN OTHERS.
          tip_cond = 'ZPR0'.
      ENDCASE.
    ENDIF.
  ELSE.
    tip_cond = 'ZPR5'.
    CLEAR tmp_divisor.
    CASE gt_cabpedext-zkvgr4.
      WHEN '01'.
        tmp_divisor = '1'.
      WHEN '02'.
        tmp_divisor = '3'.
      WHEN '03'.
        tmp_divisor = '6'.
      WHEN '04'.
        tmp_divisor = '12'.
    ENDCASE.
    CLEAR tmp_prec.
    tmp_prec = ls_detpedext-zprec     + ls_detpedext-zrec_ad    +
               ls_detpedext-zdes_ad   + ls_detpedext-zdcto_conv +
               ls_detpedext-zdcto_esp + ls_detpedext-zdcto_prom +
               ls_detpedext-zdcto_esp_t.
  ENDIF.

  IF tip_cond = 'ZPR5'.
    wa_cond_in-cond_type   = 'ZCUO'.
    wa_cond_inx-cond_type  = true.

    wa_cond_in-cond_value  = ls_detpedext-zprec / tmp_divisor.
    wa_cond_inx-cond_value = true.

    wa_cond_in-currency   = 'CLP'.
    wa_cond_inx-currency  = true.
  ELSE.
    wa_cond_in-cond_type   = tip_cond.
    wa_cond_inx-cond_type  = true.

    wa_cond_in-cond_value  = ls_detpedext-zprec. "valor
    wa_cond_inx-cond_value = true.

    wa_cond_in-currency   = 'CLP'.
    wa_cond_inx-currency  = true.
  ENDIF.

  APPEND: wa_cond_in  TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.

  wa_cond_in-cond_type   = 'ZRE1'.
  wa_cond_inx-cond_type  = true.

  wa_cond_in-cond_value  = ls_detpedext-zrec_ad / tmp_divisor.
  wa_cond_inx-cond_value = true.

  wa_cond_in-currency   = 'CLP'.
  wa_cond_inx-currency  = true.

  APPEND: wa_cond_in  TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.

  wa_cond_in-cond_type   = 'ZDC2'.
  wa_cond_inx-cond_type  = true.

  wa_cond_in-cond_value  = ls_detpedext-zdes_ad / tmp_divisor.
  wa_cond_inx-cond_value = true.

  wa_cond_in-currency   = 'CLP'.
  wa_cond_inx-currency  = true.

  APPEND: wa_cond_in  TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.

  wa_cond_in-cond_type   = 'ZDC1'.
  wa_cond_inx-cond_type  = true.

  wa_cond_in-cond_value  = ls_detpedext-zdcto_conv /
                           tmp_divisor.
  wa_cond_inx-cond_value = true.

  wa_cond_in-currency   = 'CLP'.
  wa_cond_inx-currency  = true.

  APPEND: wa_cond_in  TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.

  wa_cond_in-cond_type   = 'ZDC3'.
  wa_cond_inx-cond_type  = true.

  wa_cond_in-cond_value  = ls_detpedext-zdcto_esp / tmp_divisor.
  wa_cond_inx-cond_value = true.

  wa_cond_in-currency   = 'CLP'.
  wa_cond_inx-currency  = true.

  APPEND: wa_cond_in  TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.

  wa_cond_in-cond_type   = 'ZDC4'.
  wa_cond_inx-cond_type  = true.

  wa_cond_in-cond_value  = ls_detpedext-zdcto_prom / tmp_divisor.
  wa_cond_inx-cond_value = true.

  wa_cond_in-currency   = 'CLP'.
  wa_cond_inx-currency  = true.

  APPEND: wa_cond_in  TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.

  wa_cond_in-cond_type   = 'ZDC5'.
  wa_cond_inx-cond_type  = true.

  wa_cond_in-cond_value  = ls_detpedext-zdcto_esp_t / tmp_divisor.
  wa_cond_inx-cond_value = true.

  wa_cond_in-currency   = 'CLP'.
  wa_cond_inx-currency  = true.

  APPEND: wa_cond_in  TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.

  wa_cond_in-cond_type   = 'ZPR1'.
  wa_cond_inx-cond_type  = true.

  wa_cond_in-cond_value  = ls_detpedext-zing_b_h.
  wa_cond_inx-cond_value = true.

  wa_cond_in-currency   = 'CLP'.
  wa_cond_inx-currency  = true.

  APPEND: wa_cond_in  TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.

  wa_cond_in-cond_type   = 'ZPR2'.
  wa_cond_inx-cond_type  = true.

  wa_cond_in-cond_value  = ls_detpedext-zotro_ing.
  wa_cond_inx-cond_value = true.

  wa_cond_in-currency   = 'CLP'.
  wa_cond_inx-currency  = true.

  APPEND: wa_cond_in  TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.

  IF tip_cond = 'ZPR5'.
    CLEAR tmp_val_cuota.
    LOOP AT ti_cond_in INTO wa_cond_in
         WHERE itm_number EQ wa_items_in-itm_number.
      ADD wa_cond_in-cond_value TO tmp_val_cuota.
    ENDLOOP.

    wa_cond_in-cond_type   = tip_cond.
    wa_cond_inx-cond_type  = true.

    wa_cond_in-cond_value  = tmp_prec - tmp_val_cuota.
    wa_cond_inx-cond_value = true.

    wa_cond_in-currency   = 'CLP'.
    wa_cond_inx-currency  = true.

    APPEND: wa_cond_in  TO ti_cond_in,
            wa_cond_inx TO ti_cond_inx.
  ENDIF.

  APPEND: wa_items_in      TO ti_items_in,
          wa_items_inx     TO ti_items_inx,
          wa_schedules_in  TO ti_schedules_in,
          wa_schedules_inx TO ti_schedules_inx,
          wa_partners      TO ti_partners.
ENDFORM.                    " COMPLETA_POSICION
*&---------------------------------------------------------------------*
*&      Form  FACTURACION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_SELECTED_ROW_ROW_ID  text
*----------------------------------------------------------------------*
FORM facturacion TABLES gt_outtab LIKE gt_outtab
                  USING ls_selected_row_row_id.
  DATA: c_mensaje TYPE char100.
  DATA: c_rfbsk TYPE vbrk-rfbsk.
  DATA: vl_soc TYPE bkpf-bukrs.
  DATA: tmp_url TYPE  zfac_anex-zurl.
  DATA: lv_dea TYPE ztdea-dea.
  CLEAR : st_bkpf,  ls_cabpedext.

  READ TABLE gt_outtab INTO wa_outtab INDEX ls_selected_row_row_id.
  READ TABLE gt_cabpedext INTO ls_cabpedext
  WITH KEY znum_doc_core = wa_outtab-znum_doc_core.

  IF ls_cabpedext-factura NE space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE bukrs belnr gjahr
*       INTO st_bkpf
*       FROM bkpf
*         WHERE awtyp EQ gv_vbrk
*           AND awkey EQ ls_cabpedext-factura.
*
* NEW CODE
    SELECT bukrs belnr gjahr
    UP TO 1 ROWS 
       INTO st_bkpf
       FROM bkpf
         WHERE awtyp EQ gv_vbrk
           AND awkey EQ ls_cabpedext-factura ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
      CLEAR tmp_url.
      SELECT zurl INTO tmp_url UP TO 1 ROWS
        FROM zfac_anex
        WHERE bukrs = st_bkpf-bukrs
          AND belnr = st_bkpf-belnr
          AND gjahr = st_bkpf-gjahr
          ORDER BY bukrs belnr gjahr buzei.
      ENDSELECT.
      IF NOT tmp_url IS INITIAL.
        MESSAGE i899(mm) WITH TEXT-t18 "'El documento'
                               ls_cabpedext-znum_doc_core
                              TEXT-t21.
        "'fue procesado/normado completamente'.
        CHECK 1 = 2.
      ELSE.
        CLEAR vl_soc.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE bukrs
*          INTO vl_soc
*          FROM vbrk
*          WHERE vbeln EQ ls_cabpedext-factura.
*
* NEW CODE
        SELECT bukrs
        UP TO 1 ROWS 
          INTO vl_soc
          FROM vbrk
          WHERE vbeln EQ ls_cabpedext-factura ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        CLEAR lv_dea.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE dea
*          INTO lv_dea
*          FROM ztdea
*          WHERE blart = ls_cabpedext-zblart.
*
* NEW CODE
        SELECT dea
        UP TO 1 ROWS 
          INTO lv_dea
          FROM ztdea
          WHERE blart = ls_cabpedext-zblart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF NOT lv_dea IS INITIAL.
***Repetimos clase de mensaje ZFAE
          SUBMIT zsdrepmsg WITH p_vbeln EQ ls_cabpedext-factura
                           AND RETURN.

          PERFORM idcp IN PROGRAM zsdcreafac
                                   USING ls_cabpedext-znum_doc_core
                                         vl_soc
                                         ls_cabpedext-vkorg
                                         ls_cabpedext-factura.
        ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE *  INTO wa_zcabpedext
*           FROM zcabpedext
*                  WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
*                    AND zblart        EQ ls_cabpedext-zblart.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS   INTO wa_zcabpedext
           FROM zcabpedext
                  WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
                    AND zblart        EQ ls_cabpedext-zblart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc EQ 0.
          IF lv_dea IS INITIAL.
            wa_zcabpedext-error_e   = space.
            wa_zcabpedext-log_error = TEXT-062.
          ENDIF.

          PERFORM update_ti_grid USING ls_cabpedext-znum_doc_core.
        ENDIF.
        CHECK 1 = 2.
      ENDIF.
    ELSE.
***Contabilizar factura desde la VF02
      CLEAR: c_rfbsk, c_mensaje.
      PERFORM contab_vf02 USING ls_cabpedext-factura
                          CHANGING c_rfbsk
                                   c_mensaje.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM zcabpedext  INTO wa_zcabpedext
*                WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
*                  AND zblart        EQ ls_cabpedext-zblart.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM zcabpedext  INTO wa_zcabpedext
                WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
                  AND zblart        EQ ls_cabpedext-zblart ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF  c_rfbsk EQ 'C'.
        CLEAR : wa_zcabpedext-error, wa_zcabpedext-error_e .
        PERFORM act_tablas IN PROGRAM zsdprocfac
                        USING wa_zcabpedext
                              wa_zcabpedext-factura
                              wa_zcabpedext-pedido
                              space
                              space
                              space.

***Verificamos que este en la ZTDEA marcado la clase doc.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE dea INTO lv_dea
*          FROM ztdea  WHERE blart = ls_cabpedext-zblart.
*
* NEW CODE
        SELECT dea
        UP TO 1 ROWS  INTO lv_dea
          FROM ztdea  WHERE blart = ls_cabpedext-zblart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF NOT lv_dea IS INITIAL.
***Repetimos clase de mensaje ZFAE
          SUBMIT zsdrepmsg WITH p_vbeln EQ ls_cabpedext-factura
                           AND RETURN.

          CLEAR vl_soc.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE bukrs  INTO vl_soc
*            FROM vbrk WHERE vbeln EQ wa_outtab-factura.
*
* NEW CODE
          SELECT bukrs
          UP TO 1 ROWS   INTO vl_soc
            FROM vbrk WHERE vbeln EQ wa_outtab-factura ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
          PERFORM idcp IN PROGRAM zsdcreafac
                                   USING ls_cabpedext-znum_doc_core
                                         vl_soc
                                         ls_cabpedext-vkorg
                                         ls_cabpedext-factura.
        ENDIF.

        CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM zcabpedext  INTO wa_zcabpedext
*          WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
*            AND zblart        EQ ls_cabpedext-zblart.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM zcabpedext  INTO wa_zcabpedext
          WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
            AND zblart        EQ ls_cabpedext-zblart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc EQ 0.
          IF lv_dea IS INITIAL.
            wa_zcabpedext-error_e   = space.
            wa_zcabpedext-log_error = TEXT-062.
          ENDIF.

          PERFORM update_ti_grid USING ls_cabpedext-znum_doc_core.
        ENDIF.
        CHECK 1 = 2.

      ELSE.
        wa_zcabpedext-error     = true.
        wa_zcabpedext-error_e   = space.
        wa_zcabpedext-fec_car   = sy-datlo.
        wa_zcabpedext-hor_car   = sy-timlo.
        IF NOT c_mensaje IS INITIAL.
          wa_zcabpedext-log_error = c_mensaje.
        ELSE.
          CONCATENATE TEXT-t18 "'El documento'
              ls_cabpedext-znum_doc_core
              TEXT-t19 "'no pudo contabilizarse'
              INTO wa_zcabpedext-log_error SEPARATED BY space.
        ENDIF.
        UPDATE zcabpedext FROM wa_zcabpedext.
        CHECK wa_zcabpedext-error NE true.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ls_cabpedext-pedido EQ space AND ls_cabpedext-factura EQ space.
    PERFORM proc_fact USING ls_cabpedext. "ls_selected_row_row_id.
  ELSE.
    IF ls_cabpedext-factura EQ space.
      SUBMIT zsdcreafac WITH p_vkorg  EQ ls_cabpedext-vkorg
                        WITH p_vtweg  EQ ls_cabpedext-vtweg
                        WITH p_spart  EQ ls_cabpedext-spart
                        WITH p_doctyp EQ order_head-doc_type
                        WITH p_fecfac EQ ls_cabpedext-fecfaccon
                        WITH p_saldoc EQ ls_cabpedext-pedido
                        WITH p_numdoc EQ ls_cabpedext-znum_doc_core
                         AND RETURN.
      COMMIT WORK.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE *  INTO wa_zcabpedext
*        FROM zcabpedext
*        WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
*          AND zblart        EQ ls_cabpedext-zblart.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS   INTO wa_zcabpedext
        FROM zcabpedext
        WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
          AND zblart        EQ ls_cabpedext-zblart ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc EQ 0.
        PERFORM update_ti_grid USING ls_cabpedext-znum_doc_core.
      ENDIF.
    ELSE.
    ENDIF.
  ENDIF.
ENDFORM.                    " FACTURACION
*&---------------------------------------------------------------------*
*&      Form  GENERA_IMPRESION
*&---------------------------------------------------------------------*
FORM genera_impresion.

  CALL METHOD g_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_selected_rows.
  READ TABLE lt_selected_rows INTO ls_selected_row INDEX 1.
  CHECK ls_selected_row-row_id > 0.
  LOOP AT lt_selected_rows INTO ls_selected_row.
    PERFORM impresion USING ls_selected_row-row_id.
  ENDLOOP.

ENDFORM.                    " GENERA_IMPRESION
*&---------------------------------------------------------------------*
*&      Form  IMPRESION
*&---------------------------------------------------------------------*
FORM impresion USING ls_selected_row_row_id.
  DATA: indice     TYPE sy-tabix,
        factura    TYPE vbrk-vbeln,
        referencia TYPE vbrk-xblnr.
  CLEAR indice.
  indice = ls_selected_row_row_id.

  READ TABLE gt_cabpedext INTO ls_cabpedext INDEX indice.
  CHECK ls_cabpedext-zelectronico EQ '01'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE vbeln xblnr INTO (factura, referencia)
*    FROM vbrk  WHERE vbeln EQ ls_cabpedext-factura.
*
* NEW CODE
  SELECT vbeln xblnr
  UP TO 1 ROWS  INTO (factura, referencia)
    FROM vbrk  WHERE vbeln EQ ls_cabpedext-factura ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    PERFORM send_print_doc USING factura referencia.
  ENDIF.

ENDFORM.                    " IMPRESION
*&---------------------------------------------------------------------*
*&      Form  SEND_PRINT_DOC
*&---------------------------------------------------------------------*
FORM send_print_doc USING p_doc p_xblnr.

  DATA t_lines  TYPE STANDARD TABLE OF tline.
  DATA gs_lines TYPE tline.
  DATA mensaje  TYPE string.
  DATA t_name   TYPE thead-tdname.
  DATA com_acc  TYPE string.
  DATA str_dat  TYPE string.
  DATA: client    TYPE REF TO if_http_client,
        path      TYPE string,
        scheme    TYPE i,
        off       TYPE i,
        host      TYPE string,
        port      TYPE string,
        content   TYPE string,
        http_rc   TYPE sysubrc,
        timeout   TYPE i,
        errortext TYPE string,
        subrc     TYPE i.

  com_acc = TEXT-000.
  t_name = p_doc.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = 'ZXML'
      language                = sy-langu
      name                    = t_name
      object                  = 'VBBK'
    TABLES
      lines                   = t_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
    MESSAGE i899(mm) WITH TEXT-t18 "'El documento'
                         p_doc
                         TEXT-t25. "'no ha sido tratado por Acepta'.
  ELSE.
    LOOP AT t_lines INTO gs_lines.
      CONCATENATE str_dat gs_lines-tdline INTO str_dat.
      CONDENSE str_dat NO-GAPS.
    ENDLOOP.

    CONCATENATE 'http://10.0.0.70:5001/ca4xml?docid='
                p_xblnr
                '&comando=' com_acc '&parametros=' 'siibo,1' '&datos='
                str_dat
    INTO path.

* Checking if Path is SSL or not
    IF path(8) = 'https://' OR path(8) = 'HTTPS://'.
      scheme = 2.
      path = path+8(*).
    ELSEIF path(7) = 'http://' OR path(7) = 'HTTP://'.
      scheme = 1.
      path = path+7(*).
    ELSE.
      scheme = 1.
    ENDIF.

    IF path(30) CA ':'.
      off  = sy-fdpos.
      host = path+0(off).
      ADD 1 TO off.
      path  = path+off(*).
      IF path CA '/'.
        off  = sy-fdpos.
        port = path+0(off).
        "add 1 to off.
        path  = path+off(*).
      ENDIF.
    ELSE.
      IF path CA '/'.
        off  = sy-fdpos.
        host = path+0(off).
        "add 1 to off.
        path  = path+off(*).
      ELSE.
        host = path.
        path = '/'.
      ENDIF.
    ENDIF.

* Setting the port, 80 or 443 for SSL
    IF port IS INITIAL.
      IF scheme = 1.
        port = '80'.
      ELSE.
        port = '443'.
      ENDIF.
    ENDIF.

    IF path IS INITIAL.
      path = '/'.
    ENDIF.

*create client object
    CALL METHOD cl_http_client=>create
      EXPORTING
        host    = host
        service = port
        scheme  = scheme
      IMPORTING
        client  = client.

* set http method GET

    CALL METHOD client->request->set_method(
      if_http_request=>co_request_method_get ).

    client->request->set_version(
    if_http_request=>co_protocol_version_1_1 ).

* Set request uri (/<path>[?<querystring>])
    cl_http_utility=>set_request_uri( request = client->request
                                      uri     = path ).
* Send and receive
    CALL METHOD client->send
      EXPORTING
        timeout                    = timeout
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4.
    IF sy-subrc <> 0.
      CALL METHOD client->get_last_error
        IMPORTING
          code    = subrc
          message = errortext.
      WRITE: / TEXT-t26, "'Error de comunicasion en el envío',
             / TEXT-t27 , "'Código: ',
               subrc,
               TEXT-t28, "'Mensage: ',
               errortext.
      EXIT.
    ENDIF.

    CALL METHOD client->receive
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4.
    IF sy-subrc <> 0.
      CALL METHOD client->get_last_error
        IMPORTING
          code    = subrc
          message = errortext.
      WRITE: / TEXT-t26, "'Error de comunicasion en el envío',
             / TEXT-t27 , "'Código: ',
               subrc,
               TEXT-t28, "'Mensage: ',
               errortext.
      EXIT.
    ENDIF.
* Did you get an error
    client->response->get_status( IMPORTING code = http_rc ).

    IF http_rc IS INITIAL. "binary IS INITIAL.
      content = client->response->get_cdata( ).
      FIND TEXT-t31 "'OK'
      IN content MATCH OFFSET off.
      IF sy-subrc = 0.
        mensaje = content+off.
      ELSE.
        CLEAR off.
        FIND TEXT-t30 "'Salida[impresora]:'
        IN content MATCH OFFSET off.
        mensaje = content+off.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        titel = TEXT-t29 "'Resultado de impresión'
        txt1  = mensaje
        txt2  = space
        txt3  = ' '
        txt4  = ' '.
  ENDIF.

ENDFORM.                    " SEND_PRINT_DOC
*&---------------------------------------------------------------------*
*&      Form  PROC_FACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_SELECTED_ROW_ROW_ID  text
*----------------------------------------------------------------------*
FORM proc_fact USING ls_cabpedext TYPE ty. "row_id.
  DATA: mensaje  TYPE char100,
        lv_vbeln TYPE vbrk-vbeln.
  FREE: return, order_items_in, order_items_inx, order_partners,
        order_schedules_in, order_schedules_inx,
        order_conditions_in, order_conditions_inx, bill_data,
        return_fac. "success.
  CLEAR: return, order_items_in, order_items_inx, order_partners,
         order_schedules_in, order_schedules_inx,
         order_conditions_in, order_conditions_inx, order_head,
         order_headx, salesdocument, bill_data, return_fac, "success,
         bkpf, mensaje.

  PERFORM completa_cabecera_orden USING     ls_cabpedext-vkorg
                                            ls_cabpedext-vtweg
                                            ls_cabpedext-spart
                                            ls_cabpedext-fecfaccon
                                            ls_cabpedext-zblart
                                            ls_cabpedext-zelectronico
                                            ls_cabpedext-vertn
                                            ls_cabpedext-zkvgr3
                                            ls_cabpedext-zkvgr4
                                            ls_cabpedext-zuonr
                                            ls_cabpedext-zlsch
                                            ls_cabpedext-fecventes
                                   CHANGING order_head order_headx.

  PERFORM completa_partner TABLES order_partners
                            USING bill_data
                            ls_cabpedext-zrut_cli_pagador
                            ls_cabpedext-zrut_cli_fact
                            ls_cabpedext-zuonr
                            ls_cabpedext-znum_doc_core
                            CHANGING mensaje.


  IF NOT mensaje IS INITIAL.
    CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * INTO wa_zcabpedext
*      FROM zcabpedext WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  INTO wa_zcabpedext
      FROM zcabpedext WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      wa_zcabpedext-fec_car   = sy-datlo.
      wa_zcabpedext-hor_car   = sy-timlo.
      wa_zcabpedext-error     = true.
      wa_zcabpedext-log_error = mensaje.
      UPDATE zcabpedext FROM wa_zcabpedext.
    ENDIF.
  ELSE.
    CLEAR: ls_detpedext, pos, lv_vbeln.
***Validamos que no existe el numero core en alguna factura anterior
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE vbeln  INTO lv_vbeln
*      FROM vbrk WHERE znum_doc_core = ls_cabpedext-znum_doc_core
*                  AND fksto = space.
*
* NEW CODE
    SELECT vbeln
    UP TO 1 ROWS   INTO lv_vbeln
      FROM vbrk WHERE znum_doc_core = ls_cabpedext-znum_doc_core
                  AND fksto = space ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
      CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE *  INTO wa_zcabpedext
*            FROM zcabpedext
*            WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS   INTO wa_zcabpedext
            FROM zcabpedext
            WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc EQ 0.
        wa_zcabpedext-fec_car = sy-datlo.
        wa_zcabpedext-hor_car = sy-timlo.
        wa_zcabpedext-error   = true.
        CLEAR wa_zcabpedext-log_error.
        CONCATENATE TEXT-e01 lv_vbeln INTO wa_zcabpedext-log_error
                    SEPARATED BY space.
        UPDATE zcabpedext FROM wa_zcabpedext.
      ENDIF.
    ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * INTO ls_detpedext
*        FROM zdetpedext
*        WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core.
*
* NEW CODE
      SELECT *
 INTO ls_detpedext
        FROM zdetpedext
        WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        ADD 1 TO pos.
        PERFORM completa_posicion TABLES order_items_in
                                         order_items_inx
                                         order_partners
                                         order_schedules_in
                                         order_schedules_inx
                                         order_conditions_in
                                         order_conditions_inx
                                   USING ls_cabpedext ls_detpedext pos.
      ENDSELECT.

      CHECK NOT order_items_in[] IS INITIAL.
      CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2' "#EC CI_USAGE_OK[2438131]
        EXPORTING
          order_header_in      = order_head
          order_header_inx     = order_headx
        IMPORTING
          salesdocument        = salesdocument
        TABLES
          return               = return
          order_items_in       = order_items_in
          order_items_inx      = order_items_inx
          order_partners       = order_partners
          order_schedules_in   = order_schedules_in
          order_schedules_inx  = order_schedules_inx
          order_conditions_in  = order_conditions_in
          order_conditions_inx = order_conditions_inx.

      IF salesdocument IS INITIAL.
        READ TABLE return INTO wa_return WITH KEY type = 'E'.
        IF sy-subrc = 0.
          CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE *  INTO wa_zcabpedext
*            FROM zcabpedext
*            WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
*              AND zblart        EQ ls_cabpedext-zblart.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS   INTO wa_zcabpedext
            FROM zcabpedext
            WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
              AND zblart        EQ ls_cabpedext-zblart ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc = 0.
            wa_zcabpedext-fec_car   = sy-datlo.
            wa_zcabpedext-hor_car   = sy-timlo.
            wa_zcabpedext-error     = true.
            wa_zcabpedext-log_error = wa_return-message.
            UPDATE zcabpedext FROM wa_zcabpedext.
          ENDIF.
        ENDIF.
      ELSE.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = true.

        CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * INTO wa_zcabpedext
*          FROM zcabpedext
*          WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
*            AND zblart        EQ ls_cabpedext-zblart.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  INTO wa_zcabpedext
          FROM zcabpedext
          WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
            AND zblart        EQ ls_cabpedext-zblart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          wa_zcabpedext-fec_car   = sy-datlo.
          wa_zcabpedext-hor_car   = sy-timlo.
          wa_zcabpedext-pedido    = salesdocument.
          UPDATE zcabpedext FROM wa_zcabpedext.
        ENDIF.

        SUBMIT zsdcreafac WITH p_vkorg  EQ ls_cabpedext-vkorg
                          WITH p_vtweg  EQ ls_cabpedext-vtweg
                          WITH p_spart  EQ ls_cabpedext-spart
                          WITH p_doctyp EQ order_head-doc_type
                          WITH p_fecfac EQ ls_cabpedext-fecfaccon
                          WITH p_saldoc EQ salesdocument
                          WITH p_numdoc EQ ls_cabpedext-znum_doc_core
                          AND RETURN.

***Volvemos a leer la tabla para obtener la data actualizada
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM zcabpedext
*          INTO wa_zcabpedext
*          WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
*            AND zblart        EQ ls_cabpedext-zblart.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM zcabpedext
          INTO wa_zcabpedext
          WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
            AND zblart        EQ ls_cabpedext-zblart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ENDIF.
    ENDIF.
  ENDIF.
  COMMIT WORK.
  PERFORM update_ti_grid USING wa_zcabpedext-znum_doc_core.
ENDFORM.                    " PROC_FACT
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3454   text
*      -->P_3455   text
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.

  CLEAR wa_bdcdata.
  wa_bdcdata-fnam = fnam.
  wa_bdcdata-fval = fval.
  APPEND wa_bdcdata TO bdcdata.

ENDFORM.                    " BDC_FIELD
*&---------------------------------------------------------------------

*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------

*       text
*----------------------------------------------------------------------

*      -->P_3439   text
*      -->P_3440   text
*----------------------------------------------------------------------

FORM bdc_dynpro USING program dynpro.

  CLEAR wa_bdcdata.
  wa_bdcdata-program  = program.
  wa_bdcdata-dynpro   = dynpro.
  wa_bdcdata-dynbegin = true.
  APPEND wa_bdcdata TO bdcdata.

ENDFORM.                    " BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  ACT_TABLAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM act_tablas USING wa_zcabpedext TYPE zcabpedext
                      bill_doc
                      salesdocument
                      error
                      error_e
                      log_error.

  DATA: wa_vbrk TYPE vbrk,
        wa_vbak TYPE vbak,
        wa_vbkd TYPE vbkd,
        doc     TYPE bsid-belnr.

  TYPES: BEGIN OF t_vbap,
           vbeln TYPE vbap-vbeln,
           posnr TYPE vbap-posnr,
         END OF t_vbap.

  DATA: ti_vbap TYPE TABLE OF t_vbap,
        wa_vbap TYPE t_vbap.

  TYPES: BEGIN OF t_konv,
           knumv TYPE konv-knumv,
           kposn TYPE konv-kposn,
           kschl TYPE konv-kschl,
           kbetr TYPE konv-kbetr,
         END OF t_konv.

  TYPES : BEGIN OF t_zdetpedext,
            zrut_beneficiari TYPE zdetpedext-zrut_beneficiari,
            zrang_etareo     TYPE zdetpedext-zrang_etareo,
            zsector          TYPE zdetpedext-zsector,
          END OF t_zdetpedext.

  DATA: wa_zdetpedext TYPE t_zdetpedext.

  DATA: wa_fact_anex TYPE zfac_anex,
        ti_fact_anex TYPE TABLE OF zfac_anex.

  DATA: ti_konv TYPE TABLE OF t_konv,
        wa_konv TYPE t_konv.

  CLEAR: wa_fact_anex.
  wa_zcabpedext-error     = error.
  wa_zcabpedext-error_e   = error_e.
  wa_zcabpedext-log_error = log_error.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = bill_doc
    IMPORTING
      output = vbrk-vbeln.

  FREE tmp_nast.
  CLEAR wa_nast.
  SELECT kappl erdat eruhr cmfpnr INTO wa_nast
    FROM nast  WHERE kappl EQ 'V3'
                 AND objky EQ vbrk-vbeln
                ORDER BY PRIMARY KEY.
    READ TABLE tmp_nast INTO ls_tmp_nast INDEX 1.
    IF sy-subrc NE 0.
      MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
      APPEND ls_tmp_nast TO tmp_nast.
    ELSE.
      IF ls_tmp_nast-erdat < wa_nast-erdat.
        MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
        MODIFY tmp_nast FROM ls_tmp_nast INDEX 1.
      ELSEIF ls_tmp_nast-erdat = wa_nast-erdat AND
             ls_tmp_nast-eruhr <  wa_nast-eruhr.
        MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
        MODIFY tmp_nast FROM ls_tmp_nast INDEX 1.
      ENDIF.
    ENDIF.
  ENDSELECT.
  SORT tmp_nast BY cmfpnr DESCENDING.
  READ TABLE tmp_nast INTO  ls_tmp_nast INDEX 1.
  IF sy-subrc = 0.
    wa_nast-cmfpnr = ls_tmp_nast-cmfpnr.
    SELECT msgcnt msgv1 msgv2 msgv3 msgv4 INTO wa_cmfp
      FROM cmfp  WHERE aplid = 'WFMC'
                   AND nr    = wa_nast-cmfpnr
                   AND msgty = 'E'
                   ORDER BY msgcnt DESCENDING.
      wa_zcabpedext-error_e     = true.
      CONCATENATE wa_cmfp-msgv1 wa_cmfp-msgv2 wa_cmfp-msgv3
      wa_cmfp-msgv4 INTO wa_zcabpedext-log_error.
      EXIT.
    ENDSELECT.
  ENDIF.

  CLEAR wa_vbrk.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * INTO wa_vbrk
*    FROM vbrk WHERE vbeln = vbrk-vbeln.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  INTO wa_vbrk
    FROM vbrk WHERE vbeln = vbrk-vbeln ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    wa_vbrk-znum_doc_core = wa_zcabpedext-znum_doc_core.
    MOVE-CORRESPONDING wa_vbrk TO vbrk.
    UPDATE vbrk FROM wa_vbrk.
  ENDIF.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE vbelv vbeln  INTO (vbfa-vbelv, vbfa-vbeln)
*    FROM vbfa
*    WHERE vbelv   EQ salesdocument
*      AND vbtyp_n EQ 'M'
*      AND vbtyp_v EQ 'C'
*      AND vbeln   EQ bill_doc.
*
* NEW CODE
  SELECT vbelv vbeln
  UP TO 1 ROWS   INTO (vbfa-vbelv, vbfa-vbeln)
    FROM vbfa
    WHERE vbelv   EQ salesdocument
      AND vbtyp_n EQ 'M'
      AND vbtyp_v EQ 'C'
      AND vbeln   EQ bill_doc ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    wa_zcabpedext-pedido    = vbfa-vbelv.
    wa_zcabpedext-factura   = vbfa-vbeln.
    wa_zcabpedext-fec_car   = sy-datlo.
    wa_zcabpedext-hor_car   = sy-timlo.
    IF log_error NE space.
      wa_zcabpedext-log_error = log_error.
    ELSE.
      wa_zcabpedext-log_error = space.
    ENDIF.
    UPDATE zcabpedext FROM wa_zcabpedext.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = bill_doc
    IMPORTING
      output = vbrk-vbeln.

  CLEAR wa_vbrk.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * INTO wa_vbrk
*    FROM vbrk  WHERE vbeln EQ vbrk-vbeln.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  INTO wa_vbrk
    FROM vbrk  WHERE vbeln EQ vbrk-vbeln ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING wa_vbrk TO vbrk.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE bukrs belnr gjahr  INTO st_bkpf
*     FROM bkpf  WHERE awtyp EQ gv_vbrk
*                  AND awkey EQ wa_vbrk-vbeln.
*
* NEW CODE
  SELECT bukrs belnr gjahr
  UP TO 1 ROWS   INTO st_bkpf
     FROM bkpf  WHERE awtyp EQ gv_vbrk
                  AND awkey EQ wa_vbrk-vbeln ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    CLEAR wa_vbak.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *  INTO wa_vbak
*      FROM vbak  WHERE vbeln EQ salesdocument.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS   INTO wa_vbak
      FROM vbak  WHERE vbeln EQ salesdocument ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
***Inicio V1 10.07.2013***
      CLEAR doc.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE belnr  INTO doc
*        FROM bsid WHERE bukrs EQ st_bkpf-bukrs
*                    AND gjahr EQ st_bkpf-gjahr
*                    AND belnr EQ st_bkpf-belnr.
*
* NEW CODE
      SELECT belnr
      UP TO 1 ROWS   INTO doc
        FROM bsid WHERE bukrs EQ st_bkpf-bukrs
                    AND gjahr EQ st_bkpf-gjahr
                    AND belnr EQ st_bkpf-belnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc EQ 0.
        MOVE space                        TO wa_fact_anex-zcod_rechazo.
      ENDIF.

      MOVE st_bkpf-bukrs                  TO wa_fact_anex-bukrs.
      MOVE st_bkpf-belnr                  TO wa_fact_anex-belnr.
      MOVE st_bkpf-gjahr                  TO wa_fact_anex-gjahr.
      MOVE zcabpedext-zblart              TO wa_fact_anex-zblart.
      MOVE wa_vbak-kvgr1                  TO wa_fact_anex-zelectronico.
      MOVE wa_vbak-vkorg                  TO wa_fact_anex-zvkorg.
      MOVE wa_vbak-vtweg                  TO wa_fact_anex-zvtweg.
      MOVE wa_vbak-kvgr3                  TO wa_fact_anex-zkvgr3.
      MOVE wa_vbak-kvgr4                  TO wa_fact_anex-zkvgr4.
      MOVE wa_zcabpedext-znum_doc_core    TO wa_fact_anex-znum_doc_core.
      MOVE wa_zcabpedext-zrut_cli_fact    TO wa_fact_anex-zrut_cli_fact.
      MOVE wa_zcabpedext-zrut_cli_pagador TO
                                          wa_fact_anex-zrut_cli_pagador.
      MOVE wa_zcabpedext-znom_cli_fact    TO wa_fact_anex-znom_cli_fact.
      MOVE wa_zcabpedext-zgiro_cli_fact   TO
                                          wa_fact_anex-zgiro_cli_fact.
      MOVE wa_zcabpedext-zdir_fact        TO wa_fact_anex-zdir_fact.
      MOVE wa_zcabpedext-zcomuna_fact     TO wa_fact_anex-zcomuna_fact .
      MOVE wa_zcabpedext-zciudad_fact     TO wa_fact_anex-zciudad_fact.
      MOVE wa_zcabpedext-ztip_cambio_ref  TO
                                          wa_fact_anex-ztip_cambio_ref.
      MOVE wa_vbak-kvgr2                  TO wa_fact_anex-zind_afecto.
***fin V1 10.07.2013***

      SELECT bstdk  INTO wa_vbkd-bstdk UP TO 1 ROWS
        FROM vbkd WHERE vbeln EQ wa_vbak-vbeln
                  ORDER BY vbeln posnr.
      ENDSELECT.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT vbeln posnr INTO TABLE ti_vbap
*        FROM vbap  WHERE vbeln EQ wa_vbak-vbeln.
*
* NEW CODE
      SELECT vbeln posnr
 INTO TABLE ti_vbap
        FROM vbap  WHERE vbeln EQ wa_vbak-vbeln ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      IF sy-subrc EQ 0.
        REFRESH ti_konv.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT knumv kposn kschl kbetr INTO TABLE ti_konv
*          FROM konv   WHERE knumv EQ wa_vbak-knumv.
*
* NEW CODE
        SELECT knumv kposn kschl kbetr
 INTO TABLE ti_konv
          FROM konv   WHERE knumv EQ wa_vbak-knumv ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        IF sy-subrc EQ 0.
          CLEAR: tot_zprec, tot_zrec_ad, tot_zdcto_conv,
                 tot_zdcto_esp, tot_zdcto_prom,tot_zdcto_espt,
                 tot_zing_b_h, tot_zotro_ing.

          CLEAR : wa_fact_anex-zrut_benef, wa_fact_anex-zr_etareo,
                  wa_fact_anex-zsector, wa_fact_anex-buzei,
                  wa_fact_anex-zfec_cont, wa_fact_anex-zprec,
                  wa_fact_anex-zdes_ad, wa_fact_anex-zrec_ad,
                  wa_fact_anex-zdcto_conv, wa_fact_anex-zdcto_esp,
                  wa_fact_anex-zdcto_prom, wa_fact_anex-zdcto_espt,
                  wa_fact_anex-zing_b_h, wa_fact_anex-zotro_ing.
*
          SORT ti_vbap BY vbeln posnr.
          SORT ti_konv BY knumv kposn.
*
          LOOP AT ti_vbap INTO wa_vbap.
            LOOP AT ti_konv INTO wa_konv WHERE kposn EQ wa_vbap-posnr.
              CASE konv-kschl.
                WHEN 'ZPR0' OR 'ZPR3' OR 'ZPR4' OR 'ZPR5' OR 'ZPR9'.
                  ADD wa_konv-kbetr TO tot_zprec.
                WHEN 'ZRE1'.
                  ADD wa_konv-kbetr TO tot_zrec_ad.
                WHEN 'ZDC1'.
                  ADD wa_konv-kbetr TO tot_zdcto_conv.
                WHEN 'ZDC2'.
                  ADD wa_konv-kbetr TO tot_zdes_ad.
                WHEN 'ZDC3'.
                  ADD wa_konv-kbetr TO tot_zdcto_esp.
                WHEN 'ZDC4'.
                  ADD wa_konv-kbetr TO tot_zdcto_prom.
                WHEN 'ZDC5'.
                  ADD wa_konv-kbetr TO tot_zdcto_espt.
                WHEN 'ZPR1'.
                  ADD wa_konv-kbetr TO tot_zing_b_h.
                WHEN 'ZPR2'.
                  ADD wa_konv-kbetr TO tot_zotro_ing.
              ENDCASE.
            ENDLOOP.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE buzei INTO bseg-buzei
*               FROM bseg WHERE bukrs EQ st_bkpf-bukrs
*                           AND belnr EQ st_bkpf-belnr
*                           AND gjahr EQ st_bkpf-gjahr
*                           AND vbel2 EQ wa_vbap-vbeln
*                           AND posn2 EQ wa_vbap-posnr.
*
* NEW CODE
            SELECT buzei
            UP TO 1 ROWS  INTO bseg-buzei
               FROM bseg WHERE bukrs EQ st_bkpf-bukrs
                           AND belnr EQ st_bkpf-belnr
                           AND gjahr EQ st_bkpf-gjahr
                           AND vbel2 EQ wa_vbap-vbeln
                           AND posn2 EQ wa_vbap-posnr ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

            IF sy-subrc = 0.
              CLEAR tmp_pos.
              tmp_pos = wa_vbap-posnr / 10.
              CLEAR wa_zdetpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE zrut_beneficiari zrang_etareo zsector
*                INTO wa_zdetpedext
*                FROM zdetpedext
*                WHERE znum_doc_core EQ wa_zcabpedext-znum_doc_core
*                  AND zpos_ext      EQ tmp_pos.
*
* NEW CODE
              SELECT zrut_beneficiari zrang_etareo zsector
              UP TO 1 ROWS 
                INTO wa_zdetpedext
                FROM zdetpedext
                WHERE znum_doc_core EQ wa_zcabpedext-znum_doc_core
                  AND zpos_ext      EQ tmp_pos ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              IF sy-subrc = 0.
                MOVE wa_zdetpedext-zrut_beneficiari
                         TO wa_fact_anex-zrut_benef.
                MOVE wa_zdetpedext-zrang_etareo
                         TO wa_fact_anex-zr_etareo.
                MOVE wa_zdetpedext-zsector
                         TO wa_fact_anex-zsector.
              ENDIF.
            ENDIF.
          ENDLOOP.

          MOVE wa_vbkd-bstdk           TO wa_fact_anex-zfec_cont.
          MOVE tot_zprec               TO wa_fact_anex-zprec.
          MOVE tot_zdes_ad             TO wa_fact_anex-zdes_ad.
          MOVE tot_zrec_ad             TO wa_fact_anex-zrec_ad.
          MOVE tot_zdcto_conv          TO wa_fact_anex-zdcto_conv.
          MOVE tot_zdcto_esp           TO wa_fact_anex-zdcto_esp.
          MOVE tot_zdcto_prom          TO wa_fact_anex-zdcto_prom.
          MOVE tot_zdcto_espt          TO wa_fact_anex-zdcto_espt.
          MOVE tot_zing_b_h            TO wa_fact_anex-zing_b_h.
          MOVE tot_zotro_ing           TO wa_fact_anex-zotro_ing.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE buzei INTO wa_fact_anex-buzei
*            FROM bseg
*            WHERE bukrs EQ st_bkpf-bukrs
*              AND belnr EQ st_bkpf-belnr
*              AND gjahr EQ st_bkpf-gjahr
*              AND koart EQ 'D'.
*
* NEW CODE
          SELECT buzei
          UP TO 1 ROWS  INTO wa_fact_anex-buzei
            FROM bseg
            WHERE bukrs EQ st_bkpf-bukrs
              AND belnr EQ st_bkpf-belnr
              AND gjahr EQ st_bkpf-gjahr
              AND koart EQ 'D' ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          APPEND wa_fact_anex TO ti_fact_anex.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF NOT ti_fact_anex[] IS INITIAL.
    MODIFY zfac_anex FROM TABLE ti_fact_anex.
  ENDIF.
  SUBMIT zupdatefb02 WITH p_zuonr EQ wa_zcabpedext-zuonr
                   WITH p_bukrs EQ st_bkpf-bukrs
                   WITH p_gjahr EQ st_bkpf-gjahr
                   WITH p_belnr EQ st_bkpf-belnr
                   AND RETURN.
*
  IF wa_zcabpedext-pedido IS NOT INITIAL AND
     st_bkpf IS NOT INITIAL.
    PERFORM actualiza_zuonr_fi IN PROGRAM zcheckprocfac
                               USING wa_zcabpedext-pedido
                                     st_bkpf.
  ENDIF.
*
ENDFORM.                    " ACT_TABLAS
*&---------------------------------------------------------------------*
*&      Form  UPDATE_TI_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_ti_grid USING doc_core.
  DATA: l_xblnr TYPE vbrk-xblnr,
        indice  TYPE i,
        l_long  TYPE i.
  DATA: wa_ztdea TYPE ztdea.
*
  READ TABLE gt_outtab ASSIGNING <fs_outtab>
                         WITH KEY znum_doc_core = doc_core.
  IF sy-subrc = 0.
    indice = sy-tabix.
    MOVE-CORRESPONDING wa_zcabpedext TO <fs_outtab>.        "#EC ENHOK
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE xblnr INTO l_xblnr
*        FROM vbrk WHERE vbeln EQ wa_zcabpedext-factura.
*
* NEW CODE
    SELECT xblnr
    UP TO 1 ROWS  INTO l_xblnr
        FROM vbrk WHERE vbeln EQ wa_zcabpedext-factura ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
      l_long = strlen( l_xblnr ).
      l_long = l_long - 2.
      <fs_outtab>-folio = l_xblnr+2(l_long).
    ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE kunnr  INTO <fs_outtab>-zrut_cli_pagador
*      FROM kna1 WHERE stcd1 EQ wa_zcabpedext-zrut_cli_pagador.
*
* NEW CODE
    SELECT kunnr
    UP TO 1 ROWS   INTO <fs_outtab>-zrut_cli_pagador
      FROM kna1 WHERE stcd1 EQ wa_zcabpedext-zrut_cli_pagador ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE kunnr  INTO <fs_outtab>-kunnr_cli_fact
*      FROM kna1 WHERE stcd1 EQ wa_zcabpedext-zrut_cli_fact.
*
* NEW CODE
    SELECT kunnr
    UP TO 1 ROWS   INTO <fs_outtab>-kunnr_cli_fact
      FROM kna1 WHERE stcd1 EQ wa_zcabpedext-zrut_cli_fact ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    CASE wa_zcabpedext-error.
      WHEN true.
        name = 'ICON_LED_RED'.
        info = TEXT-t32. "'Documento con error'.
      WHEN '*'.
        name = 'ICON_LED_YELLOW'.
        info = TEXT-t33. "'Documento sin tratar'.
      WHEN OTHERS.
        IF NOT wa_zcabpedext-pedido IS INITIAL AND
           NOT wa_zcabpedext-factura
        IS INITIAL.
          name = 'ICON_LED_GREEN'.
          info = TEXT-t34. "'Documento tratado'.
        ELSE.
          name = 'ICON_LED_YELLOW'.
          info = TEXT-t33. "'Documento sin tratar'.
        ENDIF.
    ENDCASE.

    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = name
        info                  = info
        add_stdinf            = space
      IMPORTING
        result                = <fs_outtab>-status
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CASE wa_zcabpedext-error_e.
      WHEN true.
        name = 'ICON_LED_RED'.
        info = TEXT-t32."'Documento con error'.
      WHEN '*'.
        name = 'ICON_LED_YELLOW'.
        info = TEXT-t33. "'Documento sin tratar'.
      WHEN OTHERS.
        IF NOT wa_zcabpedext-pedido IS INITIAL AND
           NOT wa_zcabpedext-factura IS INITIAL.
          CLEAR wa_ztdea.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE *  INTO wa_ztdea
*            FROM ztdea  WHERE blart = wa_zcabpedext-zblart
*                          AND dea   = true.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS   INTO wa_ztdea
            FROM ztdea  WHERE blart = wa_zcabpedext-zblart
                          AND dea   = true ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc NE 0.
            ls_cabpedext-error_e   = '*'.
            ls_cabpedext-log_error = TEXT-t62.
            name                   = 'ICON_LED_YELLOW'.
            info                   = TEXT-t33. "'Documento sin tratar'.
          ELSE.
            CLEAR st_bkpf.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE bukrs belnr gjahr INTO st_bkpf
*              FROM bkpf WHERE awtyp EQ gv_vbrk
*                          AND awkey EQ wa_zcabpedext-factura .
*
* NEW CODE
            SELECT bukrs belnr gjahr
            UP TO 1 ROWS  INTO st_bkpf
              FROM bkpf WHERE awtyp EQ gv_vbrk
                          AND awkey EQ wa_zcabpedext-factura  ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            IF sy-subrc EQ 0.
              IF wa_zcabpedext-pedido IS NOT INITIAL AND
                 st_bkpf IS NOT INITIAL.
                PERFORM actualiza_zuonr_fi IN PROGRAM zcheckprocfac
                                           USING wa_zcabpedext-pedido
                                                 st_bkpf.
              ENDIF.
*
              CLEAR tmp_url.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE zurl  INTO tmp_url
*                FROM zfac_anex  WHERE bukrs = st_bkpf-bukrs
*                                  AND belnr = st_bkpf-belnr
*                                  AND gjahr = st_bkpf-gjahr.
*
* NEW CODE
              SELECT zurl
              UP TO 1 ROWS   INTO tmp_url
                FROM zfac_anex  WHERE bukrs = st_bkpf-bukrs
                                  AND belnr = st_bkpf-belnr
                                  AND gjahr = st_bkpf-gjahr ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              IF NOT tmp_url IS INITIAL.
                ls_cabpedext-error_e = space.
                name                 = 'ICON_LED_GREEN'.
                info                 = TEXT-t34. "'Documento tratado'.
              ELSE.
                ls_cabpedext-error_e = true.
                name                 = 'ICON_LED_RED'.
                info                 = TEXT-t32."'Documento con error'.
              ENDIF.
            ELSE.
              ls_cabpedext-error_e = true.
              name                 = 'ICON_LED_RED'.
              info                 = TEXT-t32."'Documento con error'.
            ENDIF.
          ENDIF.
        ELSE.
          ls_cabpedext-error_e   = '*'.
          ls_cabpedext-log_error = TEXT-t62.
          name                   = 'ICON_LED_YELLOW'.
          info                   = TEXT-t33. "'Documento sin tratar'.
        ENDIF.
    ENDCASE.

    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = name
        info                  = info
        add_stdinf            = space
      IMPORTING
        result                = <fs_outtab>-status_elec
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    ls_cabpedext = <fs_outtab>.
    MODIFY gt_cabpedext FROM ls_cabpedext INDEX indice.
  ENDIF.
ENDFORM.                    " UPDATE_TI_GRID
*&---------------------------------------------------------------------*
*&      Form  SAVE_GLOSA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_glosa USING wa_zcabpedext TYPE zcabpedext
                      doc.

  DATA gs_thead       TYPE thead.
  DATA t_lines        TYPE STANDARD TABLE OF tline.
  DATA gs_lines       LIKE LINE OF t_lines.

  CLEAR gs_thead.
  CLEAR gs_lines.
  REFRESH t_lines.

  gs_thead-tdobject = 'VBBK'.
  gs_thead-tdname   = doc.
  gs_thead-tdid     = '0002'.
  gs_thead-tdspras  = sy-langu.
  IF NOT wa_zcabpedext-glosa_p1 IS INITIAL.
    gs_lines-tdformat = '*'.
    gs_lines-tdline   = wa_zcabpedext-glosa_p1+0(127).
    APPEND gs_lines TO t_lines.
    CLEAR gs_lines.
    gs_lines-tdformat = '*'.
    gs_lines-tdline   = wa_zcabpedext-glosa_p1+127(127).
    APPEND gs_lines TO t_lines.
    CLEAR gs_lines.
  ENDIF.
  IF NOT wa_zcabpedext-glosa_p2 IS INITIAL.
    gs_lines-tdformat = '*'.
    gs_lines-tdline   = wa_zcabpedext-glosa_p2+0(127).
    APPEND gs_lines TO t_lines.
    CLEAR gs_lines.
    gs_lines-tdformat = '*'.
    gs_lines-tdline   = wa_zcabpedext-glosa_p2+127(127).
    APPEND gs_lines TO t_lines.
    CLEAR gs_lines.
  ENDIF.
  IF NOT wa_zcabpedext-glosa_p3 IS INITIAL.
    gs_lines-tdformat = '*'.
    gs_lines-tdline   = wa_zcabpedext-glosa_p3+0(127).
    APPEND gs_lines TO t_lines.
    CLEAR gs_lines.
    gs_lines-tdformat = '*'.
    gs_lines-tdline   = wa_zcabpedext-glosa_p3+127(127).
    APPEND gs_lines TO t_lines.
    CLEAR gs_lines.
  ENDIF.
  IF NOT wa_zcabpedext-glosa_p4 IS INITIAL.
    gs_lines-tdformat = '*'.
    gs_lines-tdline   = wa_zcabpedext-glosa_p4+0(127).
    APPEND gs_lines TO t_lines.
    CLEAR gs_lines.
    gs_lines-tdformat = '*'.
    gs_lines-tdline   = wa_zcabpedext-glosa_p4+127(127).
    APPEND gs_lines TO t_lines.
    CLEAR gs_lines.
  ENDIF.
  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = gs_thead
      savemode_direct = true
    TABLES
      lines           = t_lines
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " SAVE_GLOSA
*&---------------------------------------------------------------------*
*&      Form  UPDATE_WITH_INFO_NAST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM update_with_info_nast .
*  DATA: vl_zurl TYPE zfac_anex-zurl.
*  CLEAR : st_bkpf, wa_cmfp.
*  SELECT msgcnt msgv1 msgv2 msgv3 msgv4
*    INTO wa_cmfp
*    FROM cmfp
*    WHERE aplid = 'WFMC'
*      AND nr    = wa_nast-cmfpnr
*      AND msgty = 'E'
*      ORDER BY msgcnt DESCENDING.
*    EXIT.
*  ENDSELECT.
*  IF sy-subrc NE 0.
*    SELECT SINGLE bukrs belnr gjahr
*      INTO st_bkpf
*      FROM bkpf
*      WHERE awtyp EQ gv_vbrk
*        AND awkey EQ nast-objky.
*    IF sy-subrc = 0.
*      SELECT SINGLE zurl
*        INTO vl_zurl
*        FROM zfac_anex
*        WHERE bukrs EQ st_bkpf-bukrs
*          AND belnr EQ st_bkpf-belnr
*          AND gjahr EQ st_bkpf-gjahr.
*
*      CLEAR wa_zcabpedext.
*      SELECT SINGLE *
*        INTO wa_zcabpedext
*        FROM zcabpedext
*        WHERE znum_doc_core EQ gt_cabpedext-znum_doc_core
*          AND zblart        EQ gt_cabpedext-zblart.
*      IF sy-subrc = 0.
*        IF NOT vl_zurl IS INITIAL.
*          PERFORM act_tablas USING gt_cabpedext-factura
*          gt_cabpedext-pedido space true space.
*          MESSAGE i899(mm) WITH text-t18 "'El documento'
*                                gt_cabpedext-znum_doc_core
*                                text-t22. "'ya fue tratado'.
*        ELSE.
*          PERFORM act_tablas USING gt_cabpedext-factura
*          gt_cabpedext-pedido space space space.
*        ENDIF.
*        COMMIT WORK.
*        PERFORM update_ti_grid USING gt_cabpedext-znum_doc_core.
*      ENDIF.
*    ENDIF.
*  ELSE.
*    DATA: vl_soc TYPE bkpf-bukrs.
*    CLEAR vl_soc.
*    SELECT SINGLE bukrs
*      INTO vl_soc
*      FROM vbrk
*      WHERE vbeln EQ gt_cabpedext-factura.
*
*    PERFORM idcp IN PROGRAM zsdcreafac
*                             USING gt_cabpedext-znum_doc_core
*                                   vl_soc
*                                   gt_cabpedext-vkorg
*                                   gt_cabpedext-factura.
*  ENDIF.

*ENDFORM.                    " UPDATE_WITH_INFO_NAST
*&---------------------------------------------------------------------*
*&      Form  FINAL_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM final_check .
  LOOP AT gt_outtab ASSIGNING <fs_outtab> WHERE pedido  NE space
                                            AND factura EQ space.
    CLEAR vbfa-vbelv.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = <fs_outtab>-pedido
      IMPORTING
        output = vbfa-vbelv.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE vbeln  INTO vbfa-vbeln
*      FROM vbfa WHERE vbelv EQ vbfa-vbelv.
*
* NEW CODE
    SELECT vbeln
    UP TO 1 ROWS   INTO vbfa-vbeln
      FROM vbfa WHERE vbelv EQ vbfa-vbelv ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      <fs_outtab>-factura = vbfa-vbeln.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE xblnr INTO <fs_outtab>-folio
*        FROM vbrk  WHERE vbeln EQ vbfa-vbeln.
*
* NEW CODE
      SELECT xblnr
      UP TO 1 ROWS  INTO <fs_outtab>-folio
        FROM vbrk  WHERE vbeln EQ vbfa-vbeln ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * INTO wa_zcabpedext
*        FROM zcabpedext
*        WHERE znum_doc_core EQ <fs_outtab>-znum_doc_core
*          AND zblart        EQ <fs_outtab>-zblart.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  INTO wa_zcabpedext
        FROM zcabpedext
        WHERE znum_doc_core EQ <fs_outtab>-znum_doc_core
          AND zblart        EQ <fs_outtab>-zblart ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        wa_zcabpedext-factura = vbfa-vbeln.
        wa_zcabpedext-error   = space.
        wa_zcabpedext-error_e = space.
        wa_zcabpedext-log_error = space.
        UPDATE zcabpedext FROM wa_zcabpedext.
      ENDIF.
      <fs_outtab>-error     = space.
      <fs_outtab>-error_e   = space.
      <fs_outtab>-log_error = space.
    ELSE.
      <fs_outtab>-error        = true.
      <fs_outtab>-error_e      = '*'.
      <fs_outtab>-log_error =  TEXT-t23.
      "'Error en la creación de la factura.'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " FINAL_CHECK
*&---------------------------------------------------------------------*
*&      Form  OPEN_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_JNAME    text
*      -->V_JCOUNT   text
*----------------------------------------------------------------------*
FORM open_job USING nacj CHANGING v_jcount v_jname.

  CLEAR v_jname.

  IF nacj IS INITIAL.
    str_nacj = 'ELEC'.
  ELSE.
    str_nacj = nacj.
  ENDIF.
  CONCATENATE 'FAC_HELP' sy-datum+4(2) '/' sy-datum+6(2) '_'
  sy-uzeit+0(2) ':' sy-uzeit+2(2) '_' str_nacj
        INTO v_jname.
  CONDENSE v_jname NO-GAPS.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = v_jname
    IMPORTING
      jobcount         = v_jcount
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    MESSAGE i000(su) WITH TEXT-t24. "'Job could not be created.'.
  ENDIF.

ENDFORM.                    " OPEN_JOB
*&---------------------------------------------------------------------*
*&      Form  JOB_CLOSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM job_close USING pv_nacj
                     pv_jcount
                     pv_jname.
  DATA vi_sdlstrtdt TYPE tbtcjob-sdlstrtdt.
  DATA vi_sdlstrttm TYPE tbtcjob-sdlstrttm.
  DATA lv_jnum_ant             TYPE tbtcjob-jobcount.
  DATA lv_jname_ant            TYPE tbtcjob-jobname.
  DATA lv_jnum_ant0            TYPE tbtcjob-jobcount.
  DATA lv_jname_ant0           TYPE tbtcjob-jobname.
  DATA lv_numc                 TYPE char4.
  DATA lv_elec                 TYPE ztdea-dea.
*
*
  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount             = pv_jcount
      jobname              = pv_jname
      predjob_checkstat    = ' '
    IMPORTING
      job_was_released     = v_release
    EXCEPTIONS
      cant_start_immediate = 1
      invalid_startdate    = 2
      jobname_missing      = 3
      job_close_failed     = 4
      job_nosteps          = 5
      job_notex            = 6
      lock_failed          = 7
      invalid_target       = 8
      OTHERS               = 9.

  IF pv_nacj IS INITIAL.
    lv_numc = 'ELEC'.
    lv_elec = c_x.
  ELSE.
    lv_numc = pv_nacj.
    lv_elec = space.
  ENDIF.

  CONCATENATE 'PROC_NORM_' lv_numc INTO lv_jname_ant.
  CONDENSE lv_jname_ant NO-GAPS.
*
  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = lv_jname_ant
    IMPORTING
      jobcount         = lv_jnum_ant
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SUBMIT zcheckprocfac VIA JOB lv_jname_ant NUMBER lv_jnum_ant
                          WITH so_n_cor IN so_n_cor
                          WITH p_elec   = lv_elec
                          AND RETURN.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount             = lv_jnum_ant
      jobname              = lv_jname_ant
      predjob_checkstat    = ' '
      pred_jobcount        = pv_jcount
      pred_jobname         = pv_jname
    IMPORTING
      job_was_released     = v_release
    EXCEPTIONS
      cant_start_immediate = 1
      invalid_startdate    = 2
      jobname_missing      = 3
      job_close_failed     = 4
      job_nosteps          = 5
      job_notex            = 6
      lock_failed          = 7
      invalid_target       = 8
      OTHERS               = 9.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  vi_sdlstrtdt = sy-datum.
  vi_sdlstrttm = sy-uzeit.
  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount             = pv_jcount
      jobname              = pv_jname
      sdlstrtdt            = vi_sdlstrtdt
      sdlstrttm            = vi_sdlstrttm
      strtimmed            = p_inmed
    IMPORTING
      job_was_released     = v_release
    EXCEPTIONS
      cant_start_immediate = 1
      invalid_startdate    = 2
      jobname_missing      = 3
      job_close_failed     = 4
      job_nosteps          = 5
      job_notex            = 6
      lock_failed          = 7
      invalid_target       = 8
      OTHERS               = 9.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " JOB_CLOSE
*&---------------------------------------------------------------------*
*&      Form  %INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM %initialization .
  TYPES: BEGIN OF t_vbrk,
           vbeln TYPE vbrk-vbeln,
         END OF t_vbrk.

  DATA: lt_zcabpedext TYPE TABLE OF zcabpedext,
        ti_vbrk       TYPE TABLE OF t_vbrk,
        wa_vbrk       TYPE t_vbrk.

  FIELD-SYMBOLS: <fs_cab> TYPE zcabpedext.
  DATA: r_num_core TYPE RANGE OF zcabpedext-znum_doc_core,
        r_zblart   TYPE RANGE OF zcabpedext-zblart.

  CALL FUNCTION 'TH_WPINFO'
    TABLES
      wplist     = wplist
    EXCEPTIONS
      send_error = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    CLEAR p_npbd.
    LOOP AT wplist INTO wa_wplist WHERE wp_typ EQ 'BTC'.
      ADD 1 TO p_npbd.
    ENDLOOP.
    p_npbd = p_npbd * 75 / 100.
  ENDIF.

  CLEAR: p_dpp, p_des, p_dea, p_dpc.

  REFRESH: ti_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * INTO TABLE ti_zcabpedext
*    FROM zcabpedext
*    WHERE znum_doc_core IN r_num_core
*      AND zblart        IN r_zblart.
*
* NEW CODE
  SELECT *
 INTO TABLE ti_zcabpedext
    FROM zcabpedext
    WHERE znum_doc_core IN r_num_core
      AND zblart        IN r_zblart ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  IF sy-subrc EQ 0.
    REFRESH ti_vbrk.
    lt_zcabpedext[] = ti_zcabpedext[].
    DELETE lt_zcabpedext WHERE factura EQ space.
    IF lt_zcabpedext[] IS NOT INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT vbeln  INTO TABLE ti_vbrk
*        FROM vbrk  FOR ALL ENTRIES IN lt_zcabpedext
*        WHERE vbeln EQ lt_zcabpedext-factura
*          AND rfbsk EQ 'C'. 
*
* NEW CODE
      SELECT vbeln
  INTO TABLE ti_vbrk
        FROM vbrk  FOR ALL ENTRIES IN lt_zcabpedext
        WHERE vbeln EQ lt_zcabpedext-factura
          AND rfbsk EQ 'C' ORDER BY PRIMARY KEY. 

* END. 07-07-2026 - ATC - ATC-03"Doc.contable creado
    ENDIF.
    SORT ti_vbrk BY vbeln.
    LOOP AT ti_zcabpedext ASSIGNING <fs_cab>.
      IF NOT <fs_cab>-factura IS INITIAL.
        READ TABLE ti_vbrk INTO wa_vbrk
             WITH KEY vbeln =  <fs_cab>-factura BINARY SEARCH.
        IF sy-subrc EQ 0.
          CLEAR <fs_cab>-error.
*          APPEND <fs_cab> TO ti_aux.
        ENDIF.
      ENDIF.

      IF <fs_cab>-factura IS INITIAL AND NOT <fs_cab>-pedido IS INITIAL.
        <fs_cab>-error = true.
      ENDIF.

      IF <fs_cab>-pedido  NE space AND
         <fs_cab>-factura NE space AND
         <fs_cab>-error   EQ space AND
         <fs_cab>-error_e EQ space.
        ADD 1 TO p_dpc. "Procesados
      ENDIF.

      IF <fs_cab>-pedido  EQ space AND
         <fs_cab>-factura EQ space AND
         <fs_cab>-error   EQ space AND
         <fs_cab>-error_e EQ space.
        ADD 1 TO p_dpp. "Sin procesar
      ENDIF.

      IF <fs_cab>-error EQ true.
        ADD 1 TO p_des. "Error en SAP
      ENDIF.

      IF <fs_cab>-error   EQ space AND
         <fs_cab>-error_e NE space.
        ADD 1 TO p_dea. "Error en envío a Acepta
      ENDIF.
    ENDLOOP.

*    IF NOT ti_aux[] IS INITIAL.
*      UPDATE zcabpedext FROM TABLE ti_aux.
*    ENDIF.
  ENDIF.

  LOOP AT SCREEN.
    IF screen-name EQ 'P_NPBD' OR screen-name EQ '%_P_NPBD_%_APP_%-TEXT'
    OR screen-name EQ '%C007033_1000'.
      screen-active = 0.
    ENDIF.
    IF screen-name EQ 'P_DPP' OR screen-name EQ 'P_DES' OR screen-name
    EQ 'P_DEA' OR screen-name EQ '%C007033_1000' OR screen-name EQ
    'P_DPC'.
      screen-input       = 0.
      screen-display_3d  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " %INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  CTRL_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ctrl_screen.
  TYPES: BEGIN OF t_vbrk,
           vbeln TYPE vbrk-vbeln,
         END OF t_vbrk.

  DATA: ti_vbrk TYPE TABLE OF t_vbrk,
        wa_vbrk TYPE t_vbrk,
        ti_aux  TYPE TABLE OF zcabpedext.

  FIELD-SYMBOLS: <fs_cab> TYPE zcabpedext.

  DATA  : r_num_core TYPE RANGE OF zcabpedext-znum_doc_core,
          r_zblart   TYPE RANGE OF zcabpedext-zblart.

  CLEAR: p_dpp, p_des, p_dea, p_dpc.
  REFRESH ti_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*    INTO TABLE ti_zcabpedext
*    FROM zcabpedext
*    WHERE znum_doc_core IN r_num_core
*      AND zblart        IN r_zblart.
*
* NEW CODE
  SELECT *

    INTO TABLE ti_zcabpedext
    FROM zcabpedext
    WHERE znum_doc_core IN r_num_core
      AND zblart        IN r_zblart ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  IF sy-subrc EQ 0.
    REFRESH ti_vbrk.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT vbeln
*      INTO TABLE ti_vbrk
*      FROM vbrk
*      FOR ALL ENTRIES IN ti_zcabpedext
*      WHERE vbeln EQ ti_zcabpedext-factura
*        AND rfbsk EQ 'C'. 
*
* NEW CODE
    SELECT vbeln

      INTO TABLE ti_vbrk
      FROM vbrk
      FOR ALL ENTRIES IN ti_zcabpedext
      WHERE vbeln EQ ti_zcabpedext-factura
        AND rfbsk EQ 'C' ORDER BY PRIMARY KEY. 

* END. 07-07-2026 - ATC - ATC-03"Doc.contable creado
    SORT ti_vbrk BY vbeln.

    REFRESH ti_aux.
    LOOP AT ti_zcabpedext ASSIGNING <fs_cab>.
      IF NOT <fs_cab>-factura IS INITIAL.
        READ TABLE ti_vbrk INTO wa_vbrk
        WITH KEY vbeln =  <fs_cab>-factura BINARY SEARCH.
        IF sy-subrc EQ 0.
          CLEAR <fs_cab>-error.
*          APPEND <fs_cab> TO ti_aux.
        ENDIF.
      ENDIF.

      IF <fs_cab>-factura IS INITIAL
     AND NOT <fs_cab>-pedido  IS INITIAL.
        <fs_cab>-error = true.
      ENDIF.

      IF <fs_cab>-pedido  NE space AND
         <fs_cab>-factura NE space AND
         <fs_cab>-error   EQ space AND
         <fs_cab>-error_e EQ space.
        ADD 1 TO p_dpc. "Procesados
      ENDIF.

      IF <fs_cab>-pedido  EQ space AND
         <fs_cab>-factura EQ space AND
         <fs_cab>-error   EQ space AND
         <fs_cab>-error_e EQ space.
        ADD 1 TO p_dpp. "Sin procesar
      ENDIF.

      IF <fs_cab>-error EQ true.
        ADD 1 TO p_des. "Error en SAP
      ENDIF.

      IF <fs_cab>-error   EQ space AND
         <fs_cab>-error_e NE space.
        ADD 1 TO p_dea. "Error en envío a Acepta
      ENDIF.
    ENDLOOP.

*    IF NOT ti_aux[] IS INITIAL.
*      UPDATE zcabpedext FROM TABLE ti_aux.
*    ENDIF.
  ENDIF.

  LOOP AT SCREEN.
    IF screen-name EQ 'P_NPBD' OR screen-name EQ '%_P_NPBD_%_APP_%-TEXT'
    OR screen-name EQ '%C007033_1000'.
      CASE true.
        WHEN rb_ol.
          screen-active = 0.
        WHEN rb_bi.
          screen-input  = 0.
          screen-active = 1.
      ENDCASE.
    ENDIF.
    IF screen-name EQ 'P_DPP' OR screen-name EQ 'P_DES' OR screen-name
    EQ 'P_DEA' OR screen-name EQ 'P_DPC' OR
**********************************************************+
   screen-name EQ '%_P_DPP_%_APP_%-TEXT' OR screen-name EQ
   '%_P_DES_%_APP_%-TEXT' OR screen-name EQ '%_P_DEA_%_APP_%-TEXT' OR
       screen-name EQ '%C009012_1000'.
**********************************************************
      screen-input       = 0.
      screen-display_3d  = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " CTRL_SCREEN
*&---------------------------------------------------------------------*
*&      Form  DET_FECFACCON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MONAT  text
*      <--P_R_FECFACCON  text
*----------------------------------------------------------------------*
FORM det_fecfaccon.

  FREE r_fecfaccon.
  CLEAR wa_fecfaccon.
  IF p_monat NE space.
    wa_fecfaccon-sign   = 'I'.
    wa_fecfaccon-option = 'BT'.
    CONCATENATE sy-datum(4) p_monat '01' INTO wa_fecfaccon-low.

    CLEAR tmp_date.
    tmp_date = wa_fecfaccon-low.
    CALL FUNCTION 'SG_PS_GET_LAST_DAY_OF_MONTH'
      EXPORTING
        day_in            = tmp_date
      IMPORTING
        last_day_of_month = wa_fecfaccon-high
      EXCEPTIONS
        day_in_not_valid  = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    APPEND wa_fecfaccon TO r_fecfaccon.
    CLEAR wa_fecfaccon.
  ENDIF.

ENDFORM.                    " DET_FECFACCON
*&---------------------------------------------------------------------*
*&      Form  GEN_RAN_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gen_ran_error .

  FREE: r_error_e, r_error.
  IF p_error NE space.
    wa_error-sign   = 'I'.
    wa_error-option = 'EQ'.
    wa_error-low    = true.
    APPEND wa_error TO r_error.
  ENDIF.

ENDFORM.                    " GEN_RAN_ERROR
*&---------------------------------------------------------------------*
*&      Form  GEN_RAN_ERROR_E
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gen_ran_error_e .

  IF p_err_e NE space.
    wa_error_e-sign   = 'I'.
    wa_error_e-option = 'EQ'.
    wa_error_e-low    = true.
    APPEND wa_error_e TO r_error_e.

    wa_error_e-sign   = 'I'.
    wa_error_e-option = 'EQ'.
    wa_error_e-low    = '*'.
    APPEND wa_error_e TO r_error_e.
  ENDIF.

ENDFORM.                    " GEN_RAN_ERROR_E
*&---------------------------------------------------------------------*
*&      Form  OBT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_CABPEDEXT  text
*----------------------------------------------------------------------*
FORM obt_data TABLES gt_cabpedext LIKE gt_cabpedext
               USING flag
               CHANGING doctoproc.

  TYPES: BEGIN OF e_bkpf,
           bukrs TYPE bkpf-bukrs,
           belnr TYPE bkpf-belnr,
           gjahr TYPE bkpf-gjahr,
         END OF e_bkpf.

  DATA: st_bkpf TYPE e_bkpf.
  DATA: wa_ztdea TYPE ztdea.
  IF flag IS INITIAL.
    DELETE ti_zcabpedext WHERE NOT znum_doc_core IN so_n_cor.
    DELETE ti_zcabpedext WHERE NOT zblart        IN so_blart.
    DELETE ti_zcabpedext WHERE NOT fecventes     IN so_fp.
    DELETE ti_zcabpedext WHERE NOT zlsch         IN so_via.
    DELETE ti_zcabpedext WHERE NOT fecfaccon     IN r_fecfaccon.
    DELETE ti_zcabpedext WHERE NOT fec_car       IN so_f_c.
    DELETE ti_zcabpedext WHERE NOT hor_car       IN so_h_c.
  ELSE. "evento refresh
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT *
*      INTO CORRESPONDING FIELDS OF TABLE ti_zcabpedext
*      FROM zcabpedext WHERE znum_doc_core IN so_n_cor
*                             AND zblart        IN so_blart
*                             AND fecventes     IN so_fp
*                             AND zlsch         IN so_via
*                             AND fecfaccon     IN r_fecfaccon
*                             AND fec_car       IN so_f_c
*                             AND hor_car       IN so_h_c.
*
* NEW CODE
    SELECT *

      INTO CORRESPONDING FIELDS OF TABLE ti_zcabpedext
      FROM zcabpedext WHERE znum_doc_core IN so_n_cor
                             AND zblart        IN so_blart
                             AND fecventes     IN so_fp
                             AND zlsch         IN so_via
                             AND fecfaccon     IN r_fecfaccon
                             AND fec_car       IN so_f_c
                             AND hor_car       IN so_h_c ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDIF.

  LOOP AT ti_zcabpedext INTO wa_zcabpedext.
    CASE true.
      WHEN p_spr.
        CHECK wa_zcabpedext-pedido  EQ space AND
              wa_zcabpedext-factura EQ space AND
              wa_zcabpedext-error   EQ space AND
              wa_zcabpedext-error_e EQ space.
      WHEN p_error.
        IF p_err_e EQ true. "ZCABPEDEXT-ERROR_E NE SPACE
          CHECK wa_zcabpedext-error_e IN r_error_e.
        ELSE.
          CHECK wa_zcabpedext-error IN r_error.
        ENDIF.
      WHEN p_err_e.
        IF p_err_e EQ true.
          CHECK wa_zcabpedext-error_e IN r_error_e.
        ENDIF.
    ENDCASE.
    IF wa_zcabpedext-factura EQ space AND
       wa_zcabpedext-pedido EQ space.
      ADD 1 TO doctoproc.
    ENDIF.

    MOVE-CORRESPONDING wa_zcabpedext TO ls_cabpedext.       "#EC ENHOK
    CASE wa_zcabpedext-zblart.
      WHEN 'G1'.
        ls_cabpedext-descrip = TEXT-t35. "'Factura afecta'.
      WHEN 'G2'.
        ls_cabpedext-descrip = TEXT-t36. "'Factura exenta'.
      WHEN 'G3'.
        ls_cabpedext-descrip = TEXT-t37. "'Fac. Afec. Elec.'.
      WHEN 'G4'.
        ls_cabpedext-descrip = TEXT-t38. "'Fac. Exen. Elec.'.
      WHEN 'J1'.
        ls_cabpedext-descrip = TEXT-t39. "'NC Afecta'.
      WHEN 'J2'.
        ls_cabpedext-descrip = TEXT-t40. "'NC Exenta'.
      WHEN 'J3'.
        ls_cabpedext-descrip = TEXT-t41. "'NC Afecta Elec.'.
      WHEN 'J4'.
        ls_cabpedext-descrip = TEXT-t42. "'NC Exenta Elec.'.
      WHEN 'L1'.
        ls_cabpedext-descrip = TEXT-t43. "'ND Afecta'.
      WHEN 'L2'.
        ls_cabpedext-descrip = TEXT-t44. "'ND Exenta'.
      WHEN 'L3'.
        ls_cabpedext-descrip = TEXT-t45. "'ND Afecta Elec.'.
      WHEN 'L4'.
        ls_cabpedext-descrip = TEXT-t46. "'ND Exenta Elec.'.
      WHEN 'O1'.
        ls_cabpedext-descrip = TEXT-t47. "'Boleta Afecta'.
      WHEN 'O2'.
        ls_cabpedext-descrip = TEXT-t48. "'Boleta Exenta'.
      WHEN 'O3'.
        ls_cabpedext-descrip = TEXT-t49. "'Boleta Afecta Elec.'.
      WHEN 'O4'.
        ls_cabpedext-descrip = TEXT-t50. "'Boleta Exenta Elec.'.
    ENDCASE.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE kunnr
*      INTO ls_cabpedext-kunnr
*      FROM kna1
*      WHERE stcd1 EQ wa_zcabpedext-zrut_cli_pagador.
*
* NEW CODE
    SELECT kunnr
    UP TO 1 ROWS 
      INTO ls_cabpedext-kunnr
      FROM kna1
      WHERE stcd1 EQ wa_zcabpedext-zrut_cli_pagador ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE kunnr
*      INTO ls_cabpedext-kunnr_cli_fact
*      FROM kna1
*      WHERE stcd1 EQ wa_zcabpedext-zrut_cli_fact.
*
* NEW CODE
    SELECT kunnr
    UP TO 1 ROWS 
      INTO ls_cabpedext-kunnr_cli_fact
      FROM kna1
      WHERE stcd1 EQ wa_zcabpedext-zrut_cli_fact ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF wa_zcabpedext-factura EQ space AND
       NOT wa_zcabpedext-pedido IS INITIAL.
      CLEAR vbfa-vbelv.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_zcabpedext-pedido
        IMPORTING
          output = vbfa-vbelv.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE vbeln
*        INTO vbfa-vbeln
*        FROM vbfa
*        WHERE vbelv EQ vbfa-vbelv.
*
* NEW CODE
      SELECT vbeln
      UP TO 1 ROWS 
        INTO vbfa-vbeln
        FROM vbfa
        WHERE vbelv EQ vbfa-vbelv ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        wa_zcabpedext-factura = vbfa-vbeln.
        ls_cabpedext-factura  = vbfa-vbeln.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE xblnr INTO ls_cabpedext-folio FROM vbrk WHERE
*        vbeln EQ vbfa-vbeln.
*
* NEW CODE
        SELECT xblnr
        UP TO 1 ROWS  INTO ls_cabpedext-folio FROM vbrk WHERE
        vbeln EQ vbfa-vbeln ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        ls_cabpedext-error     = space.
        ls_cabpedext-error_e   = space.
        ls_cabpedext-log_error = space.
      ELSE.
        ls_cabpedext-error     = true.
        ls_cabpedext-error_e   = space.
        ls_cabpedext-log_error = TEXT-t51.
        "'No se ha creado la factura.'.
      ENDIF.
    ENDIF.

    IF ( NOT wa_zcabpedext-factura IS INITIAL AND
         NOT wa_zcabpedext-pedido  IS INITIAL )
         AND wa_zcabpedext-error   IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE bukrs belnr gjahr
*        INTO st_bkpf
*        FROM bkpf
*        WHERE awtyp EQ gv_vbrk
*          AND awkey EQ wa_zcabpedext-factura.
*
* NEW CODE
      SELECT bukrs belnr gjahr
      UP TO 1 ROWS 
        INTO st_bkpf
        FROM bkpf
        WHERE awtyp EQ gv_vbrk
          AND awkey EQ wa_zcabpedext-factura ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        ls_cabpedext-error     = true.
        ls_cabpedext-error_e   = space.
        CONCATENATE TEXT-t18 "'El documento'
                    ls_cabpedext-znum_doc_core
                    TEXT-t19 "'no pudo contabilizarse'
               INTO ls_cabpedext-log_error SEPARATED BY space.
      ELSE.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE *
*            INTO wa_ztdea
*            FROM ztdea
*            WHERE blart EQ ls_cabpedext-zblart.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS 
            INTO wa_ztdea
            FROM ztdea
            WHERE blart EQ ls_cabpedext-zblart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF wa_ztdea-dea IS INITIAL.
          ls_cabpedext-error_e   = space.
          ls_cabpedext-log_error = TEXT-030.
        ELSE.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_cabpedext-factura
            IMPORTING
              output = vbfa-vbeln.
          FREE tmp_nast.
          CLEAR wa_nast.
          SELECT kappl erdat eruhr cmfpnr
             INTO wa_nast
             FROM nast
             WHERE kappl EQ 'V3'
               AND objky EQ vbfa-vbeln
             ORDER BY erdat eruhr DESCENDING.

            READ TABLE tmp_nast INTO ls_tmp_nast INDEX 1.
            IF sy-subrc NE 0.
              MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
              APPEND ls_tmp_nast TO tmp_nast.
            ELSE.
              IF ls_tmp_nast-erdat < wa_nast-erdat.
                MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
                MODIFY tmp_nast FROM ls_tmp_nast INDEX 1.
              ELSEIF ls_tmp_nast-erdat = wa_nast-erdat AND
                     ls_tmp_nast-eruhr < wa_nast-eruhr.
                MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
                MODIFY tmp_nast FROM ls_tmp_nast INDEX 1.
              ENDIF.
            ENDIF.
          ENDSELECT.

          READ TABLE tmp_nast INTO ls_tmp_nast INDEX 1.
          IF sy-subrc NE 0.
            IF NOT wa_ztdea-dea IS INITIAL.
              ls_cabpedext-error     = space.
              ls_cabpedext-error_e   = true.
              CONCATENATE TEXT-t18 "'El documento'
                          ls_cabpedext-znum_doc_core
                          TEXT-t52 "'no se ha enviado a Acepta'
                     INTO ls_cabpedext-log_error SEPARATED BY space.
            ENDIF.
          ELSE.
            CLEAR ls_cabpedext-log_error.
            wa_nast-cmfpnr = ls_tmp_nast-cmfpnr.
            IF wa_nast-cmfpnr IS INITIAL.
              ls_cabpedext-error     = space.
              ls_cabpedext-error_e   = true.
              ls_cabpedext-log_error = TEXT-t53.
              "'Error al procesar documento con sistema Acepta'.
            ELSE.
              CLEAR wa_cmfp.
              SELECT msgcnt msgv1 msgv2 msgv3 msgv4 msgty
                INTO wa_cmfp
                FROM cmfp
                WHERE aplid = 'WFMC'
                  AND nr    = wa_nast-cmfpnr
                  ORDER BY msgcnt DESCENDING.
                EXIT.
              ENDSELECT.
              IF sy-subrc = 0.
                IF wa_cmfp-msgty EQ 'E'.
                  CONCATENATE wa_cmfp-msgv1 wa_cmfp-msgv2
                              wa_cmfp-msgv3 wa_cmfp-msgv4
                  INTO ls_cabpedext-log_error.
                  ls_cabpedext-error     = space.
                  ls_cabpedext-error_e   = true.
                ELSE.
                  ls_cabpedext-error     = space.
                  ls_cabpedext-error_e   = space.
                  ls_cabpedext-log_error = space.
                  sdc = space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*                  SELECT SINGLE xblnr INTO ls_cabpedext-folio
*                    FROM bkpf
*                    WHERE awtyp EQ gv_vbrk
*                      AND awkey EQ ls_cabpedext-factura.
*
* NEW CODE
                  SELECT xblnr
                  UP TO 1 ROWS  INTO ls_cabpedext-folio
                    FROM bkpf
                    WHERE awtyp EQ gv_vbrk
                      AND awkey EQ ls_cabpedext-factura ORDER BY PRIMARY KEY.

                  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
                  IF sy-subrc NE 0.
                    ls_cabpedext-error     = true.
                    ls_cabpedext-error_e   = space.
                    ls_cabpedext-log_error = TEXT-t54.
                    "'Error al procesar documento contanble en SAP'.
                  ENDIF.
                ENDIF.
              ELSE.
                ls_cabpedext-error     = space.
                ls_cabpedext-error_e   = true.
                ls_cabpedext-log_error = TEXT-t53.
                "'Error al procesar documento con sistema Acepta.'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*
    IF wa_zcabpedext-factura IS NOT INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE xblnr  INTO  ls_cabpedext-folio
*        FROM vbrk WHERE vbeln = wa_zcabpedext-factura.
*
* NEW CODE
      SELECT xblnr
      UP TO 1 ROWS   INTO  ls_cabpedext-folio
        FROM vbrk WHERE vbeln = wa_zcabpedext-factura ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc EQ 0.
        ls_cabpedext-folio(2) = space.
        CONDENSE ls_cabpedext-folio.
      ENDIF.
    ENDIF.

    MOVE-CORRESPONDING ls_cabpedext  TO wa_zcabpedext.      "#EC ENHOK
*    UPDATE zcabpedext FROM wa_zcabpedext.

    IF wa_zcabpedext-pedido  EQ space AND
       wa_zcabpedext-factura EQ space AND
       wa_zcabpedext-error   EQ space AND
       wa_zcabpedext-error_e EQ space.
      name   = 'ICON_LED_YELLOW'.
      info   = TEXT-t33. "'Documento sin tratar'.
      name_e = 'ICON_LED_YELLOW'.
      info_e = TEXT-t33. "'Documento sin tratar'.
    ELSE.
      CASE wa_zcabpedext-error.
        WHEN true.
          name   = 'ICON_LED_RED'.
          info   = TEXT-t55. "'Documento SAP con error'.
          name_e   = 'ICON_LED_YELLOW'.
          info_e   = TEXT-t56. "'Documento Electrónico sin tratar'.
        WHEN space.
          name   = 'ICON_LED_GREEN'.
          info   = TEXT-t57. "'Documento SAP tratado'.
        WHEN '*'.
          name   = 'ICON_LED_YELLOW'.
          info   = TEXT-t58. "'Documento SAP sin tratar'.
          name_e   = 'ICON_LED_YELLOW'.
          info_e   = TEXT-t56. "'Documento Electrónico sin tratar'.
      ENDCASE.
      IF name = 'ICON_LED_GREEN'.
        CASE wa_zcabpedext-error_e.
          WHEN true.
            name_e   = 'ICON_LED_RED'.
            info_e   = TEXT-t59. "'Documento Electrónico con error'.
          WHEN '*'.
            name_e   = 'ICON_LED_RED'.
            info_e   = TEXT-t59. "'Documento Electrónico con error'.
*            IF bkpf-zurl EQ space.
            ls_cabpedext-log_error = TEXT-t59.
            "'Documento Electrónico con error'.
*            ENDIF.
          WHEN OTHERS.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE *
*              INTO wa_ztdea
*              FROM ztdea
*              WHERE blart EQ wa_zcabpedext-zblart
*                AND dea   EQ true.
*
* NEW CODE
            SELECT *
            UP TO 1 ROWS 
              INTO wa_ztdea
              FROM ztdea
              WHERE blart EQ wa_zcabpedext-zblart
                AND dea   EQ true ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            IF sy-subrc = 0.
              name_e   = 'ICON_LED_GREEN'.
              info_e   = TEXT-t60. " 'Documento Electrónico tratado'.
            ELSE.
              name_e   = 'ICON_LED_YELLOW'.
              info_e   = TEXT-t61. "'No se envía a Acepta'.
              ls_cabpedext-error_e   = '*'.
              IF wa_zcabpedext-error EQ space.
                ls_cabpedext-log_error = TEXT-t62.
                "'Este tipo de documentos no se envía a Acepta. Ver transacción ZTDEA'.
              ELSE.
                ls_cabpedext-log_error = wa_zcabpedext-log_error.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDIF.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = name
        info                  = info
        add_stdinf            = space
      IMPORTING
        result                = ls_cabpedext-status
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name                  = name_e
        info                  = info_e
        add_stdinf            = space
      IMPORTING
        result                = ls_cabpedext-status_elec
      EXCEPTIONS
        icon_not_found        = 1
        outputfield_too_short = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*****************************************************************
    IF ls_cabpedext-folio EQ ls_cabpedext-factura.
      CLEAR ls_cabpedext-folio.
    ENDIF.
    APPEND ls_cabpedext TO gt_cabpedext.

    wa_zcabpedext-status_elec = ls_cabpedext-status_elec.
    wa_zcabpedext-status      = ls_cabpedext-status.
    UPDATE zcabpedext FROM wa_zcabpedext.
*
    CLEAR : ls_cabpedext, gt_cabpedext.
  ENDLOOP.

ENDFORM.                    " OBT_DATA
*&---------------------------------------------------------------------*
*&      Form  OBT_DOCTOS_PROC_FONDO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TMP_DOC_JOB  text
*----------------------------------------------------------------------*
FORM obt_doctos_proc_fondo.
  DATA: ti_ztdea TYPE TABLE OF ztdea,
        wa_ztdea TYPE ztdea.

  SELECT *
    INTO TABLE ti_ztdea
    FROM ztdea.
  SORT ti_ztdea BY blart.

  FREE tmp_doc_job.
  CLEAR wa_doc_job.
  CLEAR wa_zcabpedext.
***Separamos los que son electrónicos y no eléctronicos

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*    INTO wa_zcabpedext
*    FROM zcabpedext
*    WHERE znum_doc_core IN so_n_cor
*      AND zblart        IN so_blart
*      AND fecventes     IN so_fp
*      AND zlsch         IN so_via
*      AND fecfaccon     IN r_fecfaccon
*      AND fec_car       IN so_f_c
*      AND hor_car       IN so_h_c.
*
* NEW CODE
  SELECT *

    INTO wa_zcabpedext
    FROM zcabpedext
    WHERE znum_doc_core IN so_n_cor
      AND zblart        IN so_blart
      AND fecventes     IN so_fp
      AND zlsch         IN so_via
      AND fecfaccon     IN r_fecfaccon
      AND fec_car       IN so_f_c
      AND hor_car       IN so_h_c ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    CASE true.
      WHEN p_spr.

        CHECK wa_zcabpedext-pedido EQ space AND
              wa_zcabpedext-factura EQ space AND
              wa_zcabpedext-error EQ space AND
              wa_zcabpedext-error_e EQ space.

      WHEN p_error.
        IF p_err_e EQ true AND wa_zcabpedext-error_e NE space.
          CHECK wa_zcabpedext-error_e IN r_error_e.
        ELSE.
          CHECK wa_zcabpedext-error IN r_error.
        ENDIF.
      WHEN p_err_e.
        IF p_err_e EQ true.
          CHECK wa_zcabpedext-error_e IN r_error_e.
        ENDIF.
    ENDCASE.
    wa_doc_job-num_doc_core = wa_zcabpedext-znum_doc_core.
    READ TABLE ti_ztdea INTO wa_ztdea
    WITH KEY blart = wa_zcabpedext-zblart BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF wa_ztdea-dea IS INITIAL.
        APPEND wa_doc_job TO tmp_doc_job. "Doc.normales
      ELSE.
        APPEND wa_doc_job TO tmp_doc_ele. "Doc.electronicos
      ENDIF.
      CLEAR wa_doc_job.
    ENDIF.
  ENDSELECT.
ENDFORM.                    " OBT_DOCTOS_PROC_FONDO
*&---------------------------------------------------------------------*
*&      Form  CONTAB_VF02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_CABPEDEXT_FACTURA  text
*----------------------------------------------------------------------*
FORM contab_vf02  USING    p_factura
                  CHANGING p_rfbsk
                           p_mensaje.

  DATA: c_n TYPE c VALUE 'N',
        c_l TYPE c VALUE 'L'.

  REFRESH bdcdata.
  PERFORM bdc_dynpro USING 'SAPMV60A' '0101'.
  PERFORM bdc_field  USING 'BDC_OKCODE' '=FKFR'.
  PERFORM bdc_field  USING 'VBRK-VBELN' p_factura.

  PERFORM bdc_dynpro USING 'SAPMV60A' '0104'.
  PERFORM bdc_field  USING 'BDC_OKCODE'  '=SICH'.
  CALL TRANSACTION 'VF02' USING bdcdata
                          MODE c_n
                          UPDATE c_l
                          MESSAGES INTO messtab.

  IF sy-subrc NE 0.
    READ TABLE messtab INTO wa_messtab WITH KEY msgtyp = 'E'.
    IF sy-subrc EQ 0.
      MESSAGE ID wa_messtab-msgid  TYPE wa_messtab-msgtyp
      NUMBER wa_messtab-msgnr
      WITH wa_messtab-msgv1
           wa_messtab-msgv2
           wa_messtab-msgv3
           wa_messtab-msgv4
      INTO p_mensaje.
    ENDIF.
  ELSE.
    p_rfbsk = 'C'.
  ENDIF.

*  SELECT SINGLE rfbsk
*    INTO p_rfbsk
*    FROM vbrk
*    WHERE vbeln EQ p_factura.
ENDFORM.                    " CONTAB_VF02
