*&---------------------------------------------------------------------*
*& Include ZFILB005_TOP                                      Report ZFILB005
*& Control de cambios
*& ****************************************************************************************
*& AUTOR            : Hector Castillo
*& Descripcion Cambio : se cambia tipo de las variables el tipo dmbtr por DMBTR_X8 en las variables, Modificado
*& Fecha : 23-10-2012
*& ****************************************************************************************
*&---------------------------------------------------------------------*

REPORT   zfilb005.
TABLES: ska1, faglflexa.
TYPE-POOLS slis.

TYPES: BEGIN OF ty_s_outtab,
*          hkont   TYPE hkont,
          hkont   TYPE txt40,
          budat   TYPE budat,
          bukrs   TYPE bukrs,
          gjahr   TYPE gjahr,
          belnr   TYPE belnr_d,
          blart   TYPE blart,
          buzei   TYPE buzei,
          sgtxt   TYPE sgtxt,
          sgtxt2  TYPE sgtxt,
          dmbtr_h TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
          dmbtr_s TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
          saldo_start TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
          saldo_end   TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
          waers   TYPE waers,
       END OF ty_s_outtab.

TYPES: BEGIN OF ty_s_grptab,
*          hkont   TYPE hkont,
          hkont   TYPE txt40,
          dmbtr_h TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
          dmbtr_s TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
       END OF ty_s_grptab,
           ty_t_grptab TYPE TABLE OF ty_s_grptab.

TYPES: BEGIN OF ty_s_saknr,
        saknr TYPE saknr,
       END OF ty_s_saknr.
TYPES: ty_t_saknr TYPE TABLE OF ty_s_saknr.
TYPES: ty_t_outtab TYPE TABLE OF ty_s_outtab.
TYPES: BEGIN OF ty_s_tabtot,
         blart   TYPE blart,
         dmbtr_h TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
         dmbtr_s TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
         waers   TYPE waers,
       END OF ty_s_tabtot,
        ty_t_tabtot TYPE TABLE OF ty_s_tabtot.
TYPES: BEGIN OF ty_s_download,
          data TYPE c LENGTH 255,
       END OF ty_s_download.
TYPES: ty_t_download TYPE TABLE OF ty_s_download.

DATA: lt_extab             TYPE slis_t_extab,
    g_fagl_active           TYPE boole_d,
    gs_fagl_s_doc_details  TYPE  fagl_s_doc_details,
    gt_filter              TYPE slis_t_filter_alv,
    gt_slis_sp_group_alv   TYPE slis_t_sp_group_alv,
    gs_variant             TYPE disvariant,
    gt_list_top_of_page    TYPE slis_t_listheader,
    gt_sort                TYPE slis_t_sortinfo_alv,
    gt_fieldcat            TYPE slis_t_fieldcat_alv,
    gt_outtab              TYPE ty_t_outtab,
    gt_outtab_tree         TYPE ty_t_outtab,
    gt_download            TYPE ty_t_download  ,
    gs_download            TYPE ty_s_download ,
    gs_outtab              TYPE ty_s_outtab,
    gt_bkpf                TYPE TABLE OF bkpf,
    gs_bkpf                TYPE bkpf,
    gt_bseg                TYPE TABLE OF bseg,
    gt_zfigiro             TYPE TABLE OF zfigiro,
    gt_tabtot              TYPE ty_t_tabtot,
    gs_tabtot              TYPE ty_s_tabtot,
    gt_grptab              TYPE ty_t_grptab,
    gs_grptab              TYPE ty_s_grptab,
    gs_bseg                TYPE bseg,
    gt_saknr               TYPE ty_t_saknr,
    gs_layout              TYPE slis_layout_alv,
    gs_exit_caused_by_user TYPE slis_exit_by_user,
    g_repid                LIKE sy-repid,
    gt_events              TYPE slis_t_event,
    gs_event               TYPE slis_alv_event,
    g_num                  TYPE i,
    g_butxt                TYPE butxt,
    g_txt20                TYPE txt20_skat,
    l_callback_html_top_of_page  TYPE slis_formname VALUE 'HTML_TOP_OF_PAGE',
    l_callback_html_end_of_list  TYPE slis_formname  VALUE 'HTML_END_OF_LIST',
    l_callback_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE',
    g_expa                 TYPE c, " VALUE 'X', LSC - 24.10.2011 Comentado por LSC
    g_ucomm                TYPE sy-ucomm,
    rb_txt,
    rb_xls,
    dmbtr_h               TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
    dmbtr_s               TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
    g_saldo_s             TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
    g_saldo_e             TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
    g_html_height_top     TYPE i VALUE 30,
    g_address_value       TYPE addr1_val,
    g_paval               TYPE paval,
    g_line                TYPE i VALUE 50,
    g_path                TYPE c LENGTH 255,
    wa_batch              type sy-batch,
    w_filename  TYPE c LENGTH 120.

DATA: g_alv_tree         TYPE REF TO cl_gui_alv_tree,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      gt_fieldcatalog TYPE lvc_t_fcat.

*  VALORES DE SALDO ACUMULADO TOTAL
DATA : g_saldo_s1 TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012
       g_saldo_e1 TYPE DMBTR_X8, " dmbtr, Modificado TIPO HCD 23-10-2012 dmbtr.
       g_dmbtr_s TYPE dmbtr_x8, " dmbtr, Modificado TIPO HCD 23-10-2012dmbtr.
       g_dmbtr_h TYPE dmbtr_x8. " dmbtr, Modificado TIPO HCD 23-10-2012dmbtr.


DATA: gt_glt0  TYPE fagl_t_glt0,
      gs_glt0 TYPE glt0,
      range_racct TYPE fagl_range_t_racct.
RANGES: r_bstat FOR bkpf-bstat.

CONSTANTS: c_line TYPE c LENGTH 255  VALUE '-----------------------------------------------------------------------------------------------------------------------------------------------------',
           c_line_2 TYPE c LENGTH 255  VALUE '-----------------------------------------'.
*----------------------------------------------------------------------*
*       CLASS lcl_tree_event_receiver DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_tree_event_receiver DEFINITION.

  PUBLIC SECTION.
*§2. Define an event handler method for each event you want to react to.
    METHODS handle_node_double_click
      FOR EVENT node_double_click OF cl_gui_alv_tree
      IMPORTING node_key sender.

ENDCLASS.                    "lcl_tree_event_receiver DEFINITION
******************************************************************
CLASS lcl_tree_event_receiver IMPLEMENTATION.
*§3. Implement your event handler methods.

  METHOD handle_node_double_click.
    DATA: lt_children TYPE lvc_t_nkey.
*first check if the node is a leaf, i.e. can not be expanded

    CALL METHOD sender->get_children
      EXPORTING
        i_node_key  = node_key
      IMPORTING
        et_children = lt_children.

    IF NOT lt_children IS INITIAL.

      CALL METHOD sender->expand_node
        EXPORTING
          i_node_key    = node_key
          i_level_count = 2.
    ENDIF.

  ENDMETHOD.                    "handle_node_double_click

ENDCLASS.                    "lcl_tree_event_receiver IMPLEMENTATION
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-010.
PARAMETERS: p_bukrs TYPE bukrs OBLIGATORY.
SELECT-OPTIONS: s_saknr FOR ska1-saknr.
PARAMETERS:p_rldnr      TYPE rldnr OBLIGATORY  MATCHCODE OBJECT fagl_rldnr_and_rollup_w_lead.
SELECTION-SCREEN SKIP.
PARAMETERS:p_extend AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK block1.


SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-020.
PARAMETERS: p_gjahr TYPE gjahr OBLIGATORY,
            p_monat TYPE monat OBLIGATORY,
            p_mov TYPE c AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK block2.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK block3  WITH FRAME TITLE text-020.
PARAMETERS: p_path TYPE localfile LOWER CASE ." DEFAULT 'C:\Users\Alfredo Rivera\Desktop\DESCARGA TEST'.
SELECTION-SCREEN END OF BLOCK block3.
