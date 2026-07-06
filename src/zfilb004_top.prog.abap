*&---------------------------------------------------------------------*
*& Include ZFILB004_TOP                                      Report ZFILB004
*&
*& Control de cambios
*& ****************************************************************************************
*& AUTOR            : Hector Castillo
*& Descripcion Cambio : se cambia tipo de las variables el tipo dmbtr por DMBTR_X8 en las variables, Modificado
*& Fecha : 23-10-2012
*& ****************************************************************************************
*&---------------------------------------------------------------------*

REPORT   zfilb004.

TABLES: bkpf,
        bseg,
        t001.
*
TYPE-POOLS slis.

TYPES: BEGIN OF ty_s_outtab,
         budat    TYPE budat,
         bukrs    TYPE bukrs,
         gjahr    TYPE gjahr,
         belnr    TYPE belnr_d,
         blart    TYPE blart,
         buzei    TYPE buzei,
         hkont    TYPE hkont,
         txt20    TYPE txt20_skat,
         sgtxt    TYPE sgtxt,
         dmbtr_h  TYPE dmbtr_x8, " dmbtr, Modificado TIPO HCD 23-10-2012
         dmbtr_s  TYPE dmbtr_x8, " dmbtr, Modificado TIPO HCD 23-10-2012
         waers    TYPE waers,
* INI WALDO ALARCON - VISIONONE - 10-10-2025
*         budat2  TYPE bkpf-budat,
         cputm    TYPE bkpf-cputm,
         cpudt    TYPE bkpf-cpudt,
         ltext    TYPE t003t-ltext,
         tcode    TYPE bkpf-tcode,
         kostl    TYPE bseg-kostl,
*         waers2  TYPE bkpf-waers,
         kursf    TYPE bkpf-kursf,
         usnam    TYPE bkpf-usnam,
         xref2_hd TYPE bkpf-xref2_hd,
* FIN WALDO ALARCON - VISIONONE - 10-10-2025
       END OF ty_s_outtab.
TYPES: ty_t_outtab TYPE TABLE OF ty_s_outtab.

TYPES: BEGIN OF ty_s_download,
         data TYPE c LENGTH 255,
       END OF ty_s_download.
TYPES: ty_t_download TYPE TABLE OF ty_s_download.
TYPES: BEGIN OF ty_s_tabtot,
         blart   TYPE blart,
         dmbtr_h TYPE dmbtr_x8, " dmbtr, Modificado TIPO HCD 23-10-2012
         dmbtr_s TYPE dmbtr_x8, " dmbtr, Modificado TIPO HCD 23-10-2012
         waers   TYPE waers,
       END OF ty_s_tabtot,
       ty_t_tabtot TYPE TABLE OF ty_s_tabtot.

TYPE-POOLS: slis, kkblo.

DATA: lt_extab                    TYPE slis_t_extab,
      gfagl_active                TYPE boole_d,
      gs_fagl_s_doc_details       TYPE  fagl_s_doc_details,
      gt_filter                   TYPE slis_t_filter_alv,
      gt_slis_sp_group_alv        TYPE slis_t_sp_group_alv,
      gs_variant                  TYPE disvariant,
      gt_list_top_of_page         TYPE slis_t_listheader,
      gt_sort                     TYPE slis_t_sortinfo_alv,
      gt_fieldcat                 TYPE slis_t_fieldcat_alv,
      gt_outtab                   TYPE ty_t_outtab,
      gt_download                 TYPE ty_t_download,
      gs_download                 TYPE ty_s_download,
      gs_outtab                   TYPE ty_s_outtab,
      gt_tabtot                   TYPE ty_t_tabtot,
      gs_tabtot                   TYPE ty_s_tabtot,
      gt_zfigiro                  TYPE TABLE OF zfigiro,
*    gt_bkpf                TYPE TABLE OF bkpf,
*    gs_bkpf                TYPE bkpf,
*    gt_bseg                TYPE TABLE OF bseg,
*    gs_bseg                TYPE bseg,
      gs_layout                   TYPE slis_layout_alv,
      gs_exit_caused_by_user      TYPE slis_exit_by_user,
      g_repid                     LIKE sy-repid,
      gt_events                   TYPE slis_t_event,
      gs_event                    TYPE slis_alv_event,
      g_num                       TYPE i,
      dmbtr_h                     TYPE dmbtr_x8, " dmbtr, Modificado TIPO HCD 23-10-2012
      dmbtr_s                     TYPE dmbtr_x8, " dmbtr, Modificado TIPO HCD 23-10-2012
      g_butxt                     TYPE butxt,
      l_callback_html_top_of_page TYPE slis_formname VALUE 'HTML_TOP_OF_PAGE',
      l_callback_html_end_of_list TYPE slis_formname  VALUE 'HTML_END_OF_LIST',
      l_callback_top_of_page      TYPE slis_formname VALUE 'TOP_OF_PAGE',
      g_path                      TYPE c LENGTH 255,
      rb_txt,
      rb_xls,
      g_line                      TYPE i VALUE 50,
      g_html_height_top           TYPE i VALUE 30,
      g_address_value             TYPE addr1_val,
      g_paval                     TYPE paval,
      wa_batch                    TYPE sy-batch,
      w_filename                  TYPE c LENGTH 120.

* INI WALDO ALARCON - VISIONONE - 10-10-2025
DATA : gv_tcode TYPE xflag.
* FIN WALDO ALARCON - VISIONONE - 10-10-2025

DATA: l_document TYPE REF TO cl_dd_document.
CREATE OBJECT l_document.
DATA  g_ucomm TYPE sy-ucomm.

CONSTANTS: c_line   TYPE c LENGTH 255  VALUE '-------------------------------------------------------------------------------------------------------------------------------------------',
           c_line_2 TYPE c LENGTH 255  VALUE '-------------------------------------------'.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-010.
PARAMETERS: p_monat TYPE monat OBLIGATORY.
SELECTION-SCREEN END OF BLOCK block1.
SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-020.
PARAMETER: p_path TYPE localfile LOWER CASE." DEFAULT 'C:\Users\Alfredo Rivera\Desktop\DESCARGA TEST'.
SELECTION-SCREEN END OF BLOCK block2.
