FUNCTION-POOL ZSD_FACT_ELE.                 "MESSAGE-ID ..

RANGES: r_vbeln FOR likp-vbeln.

TYPES: ty_treferenica TYPE TABLE OF zdte_referencia.

DATA gt_referencia TYPE ty_treferenica.

DATA: gs_hd_kond_w TYPE lbbil_hd_kond,
      gs_it_gen TYPE lbbil_it_gen,
      gs_it_kond TYPE lb_t_bil_it_kond,
      gs_it_price TYPE lbbil_it_price.

DATA gs_detalle TYPE zdte_detalle.

*TYPES ty_t_control_st TYPE STANDARD TABLE OF zdte_control_st.
*DATA gt_control_st TYPE ty_t_control_st.
*DATA gt_control TYPE zdte_tt_control.
data gt_header type SPERS_XMLT.

data gt_ref type TABLE OF ZDTE_DOC_REC_REF.

TYPES: BEGIN OF ty_control_res,
        tipo_dte(25),
        enviados TYPE sy-tabix,
        status_ws_apr TYPE sy-tabix,
        status_ws_rch TYPE sy-tabix,
        emitidos TYPE sy-tabix,
        status_sii_apr TYPE sy-tabix,
        status_sii_rch TYPE sy-tabix,
        acuse_rec TYPE sy-tabix,
        status_com_apr TYPE sy-tabix,
        status_com_rch TYPE sy-tabix,
 END OF ty_control_res.

DATA gt_control_res TYPE TABLE OF ty_control_res.
DATA f_detalle TYPE char1.


**********************************************************************
* SALV Data
**********************************************************************

DATA: gr_table        TYPE REF TO cl_salv_table.

DATA: lr_columns      TYPE REF TO cl_salv_columns_table,
      lr_column       TYPE REF TO cl_salv_column.

DATA: lr_layout       TYPE REF TO cl_salv_layout.
DATA  ls_key          TYPE salv_s_layout_key.
DATA:
      gt_fcat   TYPE lvc_s_fcat OCCURS 0,
      gs_fcat   LIKE LINE OF gt_fcat,
      gs_layout TYPE lvc_s_layo.
DATA  gt_sort   TYPE lvc_t_sort .
DATA  gs_sort   TYPE lvc_s_sort .
DATA: lt_ex     TYPE ui_functions,
      ls_ex     TYPE ui_func.
DATA  ls_style  TYPE lvc_s_styl .
DATA: lr_display_settings TYPE REF TO cl_salv_display_settings,
      l_title TYPE lvc_title.
DATA: gr_functions TYPE REF TO cl_salv_functions_list.

DATA  o_split_vertical    TYPE REF TO cl_gui_easy_splitter_container.
DATA  o_split_horizontal  TYPE REF TO cl_gui_easy_splitter_container.
DATA  o_html              TYPE REF TO cl_gui_html_viewer.
**********************************************************************
*CLASS lcl_event_receiver DEFINITION DEFERRED.
DATA :
g_container TYPE scrfname VALUE 'CC_CONTAINER',
g_custom_container TYPE REF TO cl_gui_custom_container,
g_grid TYPE REF TO cl_gui_alv_grid.

DATA ok_code TYPE sy-ucomm.
