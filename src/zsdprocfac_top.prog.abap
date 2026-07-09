*&---------------------------------------------------------------------*
*&  Include           ZSDPROCFAC_TOP
*&---------------------------------------------------------------------*
TABLES zstr_mon_fac.
TABLES vbrk.
TABLES bkpf.
TABLES bseg.
TABLES nast.
TABLES vbak.
TABLES vbap.
TABLES vbkd.
TABLES cmfp.
TABLES bsid.
TABLES bsad.
TABLES vbfa.
TABLES mara.
TABLES ztdea.


DATA: ti_zcabpedext TYPE TABLE OF zcabpedext,
      wa_zcabpedext TYPE zcabpedext.
DATA: wplist TYPE STANDARD TABLE OF wpinfo, " WITH HEADER LINE.
      wa_wplist TYPE wpinfo.
DATA : gv_vbrk TYPE bkpf-awtyp VALUE 'VBRK',
       gv_vbeln TYPE vbrk-vbeln.
DATA ls_zcabpedext TYPE zcabpedext.
DATA lt_selected_rows TYPE lvc_t_roid .
DATA ls_selected_row TYPE lvc_s_roid .
DATA numcore TYPE c LENGTH 10.
DATA str_awkey TYPE string.
CONSTANTS: soc TYPE bukrs VALUE 'CL51',
           c_x type c value 'X'.
DATA sdc TYPE c.
DATA tmp_url TYPE zurl.
DATA: ok_code            TYPE sy-ucomm,
      save_ok            TYPE sy-ucomm,
      g_container        TYPE scrfname VALUE 'BCALV_GRID_DEMO_0100_CONT1',
      g_grid             TYPE REF TO cl_gui_alv_grid,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      gt_fieldcat        TYPE lvc_t_fcat,
      gs_layout          TYPE lvc_s_layo,
      lay_var            TYPE disvariant,
      g_max              TYPE i VALUE 100,
      gs_spfli           TYPE spfli,
      g_success          TYPE c.
DATA l TYPE i.

*DATA BEGIN OF gt_outtab OCCURS 0.     "with header line
*        INCLUDE STRUCTURE zstr_mon_fac.
*DATA celltab TYPE lvc_t_styl.
*DATA END OF gt_outtab.

TYPES: BEGIN OF t_outtab.
        INCLUDE STRUCTURE zstr_mon_fac.
TYPES:  celltab TYPE lvc_t_styl.
TYPES: END OF t_outtab.

DATA:  gt_outtab TYPE STANDARD TABLE OF t_outtab,
       wa_outtab type t_outtab.
FIELD-SYMBOLS : <fs_outtab> TYPE t_outtab.

DATA l_stable  TYPE lvc_s_stbl.
DATA: t_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat type slis_fieldcat_alv.  "WITH HEADER LINE.
DATA ls_fc LIKE LINE OF t_fieldcat.

TYPES: BEGIN OF lt_log,
        status TYPE bapi_mtype,
        texto  TYPE bapi_msg,
       END OF lt_log.

DATA t_log TYPE STANDARD TABLE OF lt_log.
DATA ls_log type lt_log.

DATA ls_outtab LIKE LINE OF gt_outtab.
DATA: lt_exclude TYPE ui_functions.

TABLES zcabpedext.
TABLES zdetpedext.
TABLES konv.
DATA tmp_pos TYPE vbap-posnr.
DATA tot_zprec   TYPE bseg-zprec.
DATA tot_zrec_ad TYPE bseg-zrec_ad.
DATA tot_zdcto_conv TYPE bseg-zdcto_conv.
DATA tot_zdes_ad TYPE bseg-zdes_ad.
DATA tot_zdcto_esp TYPE bseg-zdcto_esp.
DATA tot_zdcto_prom TYPE bseg-zdcto_prom.
DATA tot_zdcto_espt TYPE bseg-zdcto_espt.
DATA tot_zing_b_h TYPE bseg-zing_b_h.
DATA tot_zotro_ing TYPE bseg-zotro_ing.

TYPES: BEGIN OF ty.
        INCLUDE STRUCTURE zstr_mon_fac.
TYPES:  cell_styles TYPE lvc_t_styl,
       END OF ty.

CONSTANTS true        TYPE c VALUE 'X'.
DATA gt_cabpedext     TYPE STANDARD TABLE OF ty."WITH HEADER LINE.      "Output-Table
DATA ls_cabpedext     type ty.
DATA gt_detpedext     TYPE STANDARD TABLE OF zdetpedext. "WITH HEADER LINE.      "Output-Table
DATA ls_detpedext     type zdetpedext.
DATA pos              TYPE i.
DATA pos_ti           TYPE i.
DATA: bdcdata         TYPE TABLE OF bdcdata,
      wa_bdcdata      TYPE bdcdata.
DATA: messtab         TYPE TABLE OF bdcmsgcoll,
      wa_messtab      type bdcmsgcoll.
DATA r_fecfaccon      TYPE RANGE OF zcabpedext-fecfaccon.
DATA wa_fecfaccon     LIKE LINE OF r_fecfaccon.
DATA r_error          TYPE RANGE OF zcabpedext-error.
DATA wa_error         LIKE LINE OF r_error.
DATA r_error_e        TYPE RANGE OF zcabpedext-error_e.
DATA : wa_error_e       LIKE LINE OF r_error_e.
DATA ctumode.
DATA tmp_date TYPE sy-datum.
DATA: gt_fieldcatalog TYPE lvc_t_fcat, "Fieldcatalog
      ls_fieldcatalog TYPE lvc_s_fcat,
      gt_sort         TYPE lvc_t_sort.

DATA l_tree_container_name(30) TYPE c.

DATA name TYPE icon-name.
DATA info(20).
DATA name_e TYPE icon-name.
DATA info_e(20).
DATA order_head           TYPE bapisdhd1.
DATA order_headx          TYPE bapisdhd1x.
DATA salesdocument        TYPE bapivbeln-vbeln.
DATA : return             TYPE TABLE OF bapiret2,
       wa_return          TYPE bapiret2.

DATA: wa_items_in  TYPE  bapisditm,
      wa_items_inx TYPE bapisditmx,
      wa_cond_in   TYPE bapicond,
      wa_cond_inx  TYPE bapicondx,
      wa_partners  TYPE bapiparnr,
      wa_schedules_in TYPE bapischdl,
      wa_schedules_inx TYPE bapischdlx.

DATA: order_partners       TYPE STANDARD TABLE OF bapiparnr,
      order_items_in       TYPE STANDARD TABLE OF bapisditm,
      order_items_inx      TYPE STANDARD TABLE OF bapisditmx,
      order_schedules_in   TYPE STANDARD TABLE OF bapischdl,
      order_schedules_inx  TYPE STANDARD TABLE OF bapischdlx,
      order_conditions_in  TYPE STANDARD TABLE OF bapicond,
      order_conditions_inx TYPE STANDARD TABLE OF bapicondx.

DATA ind_out              TYPE lvc_t_indx.
DATA it_index_outtab      TYPE lvc_t_indx.
DATA ls_ind_out           TYPE lvc_index.
DATA tmp_index            TYPE i.
DATA bill_data            TYPE bapivbrk.
DATA return_fac           TYPE STANDARD TABLE OF bapiret1.
DATA wa_return_fac        TYPE bapiret1.
DATA v_jname              TYPE tbtcjob-jobname.
DATA v_jcount             TYPE tbtcjob-jobcount.
DATA jnum_ant             TYPE tbtcjob-jobcount.
DATA jname_ant            TYPE tbtcjob-jobname.
DATA p_inmed              TYPE c.
DATA v_release            TYPE btch0000-char1.
DATA str_nacj             TYPE c LENGTH 10.
DATA: lt_sflight          TYPE TABLE OF sflight,
      ls_sflight          TYPE sflight,
      l_index             TYPE i,
      ls_spfli            TYPE spfli,
      lt_celltab          TYPE lvc_t_styl.
DATA doctoproc            TYPE i.
DATA tmp_vertn            TYPE zcabpedext-vertn.

TYPES: BEGIN OF t_nast,
       kappl  TYPE nast-kappl,
       erdat  TYPE nast-erdat,
       eruhr  TYPE nast-eruhr,
       cmfpnr TYPE nast-cmfpnr,
      END OF t_nast.

TYPES : BEGIN OF t_cmfp,
           msgcnt TYPE cmfp-msgcnt,
           msgv1 TYPE cmfp-msgv1,
           msgv2 TYPE cmfp-msgv2,
           msgv3 TYPE cmfp-msgv3,
           msgv4 TYPE cmfp-msgv4,
           msgty TYPE cmfp-msgty,
        END OF t_cmfp.

DATA: wa_cmfp TYPE t_cmfp.
DATA: tmp_nast TYPE TABLE OF t_nast,
      ls_tmp_nast TYPE t_nast,
      wa_nast TYPE t_nast.
DATA answer.
DATA text_opt1(16).
DATA text_opt2(16).

TYPES: BEGIN OF t_doc_job,
        num_doc_core TYPE zcabpedext-znum_doc_core,
      END OF t_doc_job.

DATA: tmp_doc_job TYPE STANDARD TABLE OF t_doc_job,
      tmp_doc_ele type standard table of t_doc_job,
      wa_doc_job TYPE t_doc_job.

DATA n_d_p_f TYPE i.
DATA np      TYPE i.
DATA nacj    TYPE i.

TYPES: BEGIN OF e_bkpf,
         bukrs TYPE bkpf-bukrs,
         belnr TYPE bkpf-belnr,
         gjahr TYPE bkpf-gjahr,
       END OF e_bkpf.

DATA: st_bkpf TYPE e_bkpf.
