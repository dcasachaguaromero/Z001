*&---------------------------------------------------------------------*
*& Include MSSCHTOP                                                    *
*&                                                                     *
*&---------------------------------------------------------------------*

program  sapmssch message-id td.

class lcl_application definition deferred.
class cl_gui_cfw definition load.

tables:
   rstxt, rsscg,
   ttxot, ttxid, ttxit,
   ttxgr, ttxgrt,
   stxh,
   stxbitmaps.

type-pools: cndp,          " data provider
            sbdst.         " class cl_bds_document_set

types:
   item_table_type like standard table of ssftreeit with default key.


*---------------------- Selection screens -----------------------------*
include msschsel.

*---------------------- Screen handling -------------------------------*
data:
   fcode     like sy-ucomm,
   fcode_old like sy-ucomm.

constants:
   fcode_import     like sy-ucomm  value 'GIMP',
   fcode_delete     like sy-ucomm  value 'GDEL',
   fcode_prop       like sy-ucomm  value 'GPRP',
   fcode_copy       like sy-ucomm  value 'GCPY',
   fcode_print      like sy-ucomm  value 'GPRI',
   fcode_preview    like sy-ucomm  value 'GPRV',
   fcode_find       like sy-ucomm  value 'CATA',
   fcode_transport  like sy-ucomm  value 'TRAN',
   fcode_ok         like sy-ucomm  value 'OK',
   fcode_f3         like sy-ucomm  value 'BACK',
   fcode_f12        like sy-ucomm  value 'CANC',
   fcode_f15        like sy-ucomm  value 'BEEN',
   fcode_change_att like sy-ucomm  value 'CH1',
   fcode_save_att   like sy-ucomm  value 'SV1',
   fcode_rb_btype   like sy-ucomm  value 'BTYPE'.
constants:
   screen_sub_header_bds        like sy-dynnr value '2001',
   screen_sub_header_graphics   like sy-dynnr value '2002',
   screen_sub_header_text       like sy-dynnr value '2003',
   screen_sub_preview           like sy-dynnr value '2005',
   screen_sub_empty             like sy-dynnr value '2009',
   screen_sub_attr_bds          like sy-dynnr value '2011',
   screen_sub_attr_text         like sy-dynnr value '2012'.

data:
   g_repid      like sy-repid value 'ZSAPMSSCH',
   g_dynnr      like sy-dynnr value '2000',
   sub_headernr like sy-dynnr,
   sub_areanr   like sy-dynnr.

* radio buttons
data: rb_graphic_bmon(1),
      rb_graphic_bcol(1).
* text fields
data: t_size(40).

* Screen attributes
constants:
      c_screen_on   like screen-active value '1',
      c_screen_off  like screen-active value '0'.

*---------------------- Control handling ------------------------------*
include <ctldef>.

data:
   h_picture       type ref to cl_gui_picture,
   h_pic_container type ref to cl_gui_custom_container,
   h_tree          type ref to cl_gui_list_tree,
   h_docking       type ref to cl_gui_docking_container,
   h_application   type ref to lcl_application.

*---------------------- Tree handling ---------------------------------*
data:
   g_selected_node    type tv_nodekey,
   g_selected_item    type tv_itmname,
   g_new_node         type tv_nodekey,
   g_last_node        type tv_nodekey,
   g_prefix(3)        type c,
   g_prefix_old(3)    type c.

constants:
   c_key_root            type tv_nodekey value '%ROOT',
   c_key_bds             type tv_nodekey value '%BDS',
   c_key_stxl            type tv_nodekey value '%STXL',
   c_key_stxl_graphics   type tv_nodekey value '%OBGRAPHICS',
   c_key_stxl_text       type tv_nodekey value '%OBTEXT',
   prefix_bds_object     like g_prefix   value 'GRO',
   prefix_bds_id         like g_prefix   value 'GRI',
   prefix_tx_graphics    like g_prefix   value 'TX_',
   prefix_standard_texts like g_prefix   value 'ID_'.
* Node keys:
* 'GRO#'    graphic object specified in line # of table g_ttxgr
* 'GRI#'    graphic ID     specified in line # of table g_ttxgr
* 'TX_BMON' black/white bitmap stored as text in obj. GRAPHICS ID BMON
* 'TX_BCOL' colour bitmap      stored as text in obj. GRAPHICS ID BCOL
* 'ID_#'    standard text ID specified in line # of table g_ttxid
data:
   g_ttxgr   type standard table of ttxgr  with header line,
   g_ttxid   type standard table of ttxid  with header line.

*---------------------- Graphic handling ------------------------------*
constants:
   c_stdtext  like thead-tdobject value 'TEXT',
   c_graphics like thead-tdobject value 'GRAPHICS',
   c_bmon     like thead-tdid     value 'BMON',
   c_bcol     like thead-tdid     value 'BCOL'.

constants: c_device_printer(8) value 'PRINTER',
           c_device_screen(8)  value 'SCREEN'.

data: graphic_url(255),
      graphic_refresh(1).

data: begin of graphic_table occurs 0,
        line(255) type x,
      end of graphic_table.
data: graphic_size type i.

*---------------------- General global data ---------------------------*
constants: true(1)  value 'X',
           false(1) value ' '.

data:
   g_stxbitmaps       type stxbitmaps,
   begin of g_bds_properties,
     fuser            like rsscg-bds_fuser,
     fdate            like rsscg-fdate,
     ftime            like rsscg-ftime,
     luser            like rsscg-bds_luser,
     ldate            like rsscg-ldate,
     ltime            like rsscg-ltime,
     description      like rsscg-bds_title,
   end of g_bds_properties,

   g_stxh             type stxh,
   g_techinfo         type rsscg.

data:
   g_change_screen(1)           type c,
   g_modify_screen              like sy-ucomm,
   g_modified_administration(1) type c,
   g_modified_properties(1)     type c,
   g_result                     like cntl_true.
