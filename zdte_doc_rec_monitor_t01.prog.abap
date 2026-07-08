*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZDTE_DOC_REC_MONITOR_T01
*&---------------------------------------------------------------------*
TYPE-POOLS icon.

TABLES: zdte_fb60 , ekko , t001 , BKPF.

CONSTANTS: col_heading   TYPE i VALUE  1,
           col_normal    TYPE i VALUE  2,
           col_total     TYPE i VALUE  3,
           col_key       TYPE i VALUE  4,
           col_positive  TYPE i VALUE  5,
           col_negative  TYPE i VALUE  6,
           col_group     TYPE i VALUE  7.


TYPES: BEGIN OF ty_rechazados,
          rutemisor TYPE zdte_doc_rec-rutemisor,
          tipodte   TYPE zdte_doc_rec-tipodte,
          folio     TYPE zdte_doc_rec-folio,
          rut(10),
          string    TYPE string,
       END OF ty_rechazados.

TYPES: BEGIN OF ty_data.
*TYPES  marca(1).
*TYPES  icon_field LIKE  icon_green_light.
INCLUDE TYPE zdte_doc_rec.
*TYPES belnr TYPE belnr_d.
*TYPES  ebeln TYPE ekko-ebeln.
TYPES  folioref  TYPE zfolioref.
TYPES  status(15).
TYPES  icon_sts  TYPE icon_d.
TYPES  dias      type numc3.
TYPES  statrec(15).
TYPES  icon_rec  TYPE icon_d."icono rechazo
types  del TYPE c.
types  sel TYPE c.
TYPES bukrs TYPE bukrs.

*TYPES: color(4).
TYPES: END OF ty_data.

TYPES ty_tdoc_ref       TYPE STANDARD TABLE OF zdte_doc_rec_ref.

*TYPES ty_tdesc          TYPE TABLE OF zdte_resp_proceso_desc.
*DATA gt_desc            TYPE TABLE OF zdte_resp_proceso_desc.

DATA gt_rechazados      TYPE STANDARD TABLE OF ty_rechazados.

DATA gt_eksel           TYPE /bev1/ne_eksel_tt.
DATA gt_data            TYPE TABLE OF ty_data.
DATA gt_doc_rec_ref     TYPE TABLE OF zdte_doc_rec_ref.
DATA wa_data            LIKE LINE OF gt_data.
DATA wa_doc_rec         TYPE zdte_doc_rec.
DATA wa_doc_ref         TYPE zdte_doc_rec_ref.

DATA g_subrc            TYPE sy-subrc.
DATA ok_code            TYPE sy-ucomm.

DATA w_t001z            TYPE t001z.

DATA vl_index TYPE sy-tabix.
RANGES s_rut FOR zdte_doc_rec-rutrecep.

"Campos Conexión FTP
DATA: wa_datos                  TYPE  zemm157 ,
      o_retorno                 TYPE  subrc   .

DATA:   p_user(30)            TYPE c VALUE ''.
DATA:   p_pwd(30)             TYPE c VALUE ''.
DATA:   p_ip(64)              TYPE c VALUE ''.

* ----- Output in Log --------------------------------------------------
DATA:    BEGIN OF news OCCURS 10,      " Log
           rutemisor  TYPE zdte_doc_rec-rutemisor,
           tipodte    TYPE zdte_doc_rec-tipodte,
           folio      TYPE zdte_doc_rec-folio,
           text(100),
           color      TYPE i,
         END OF news.

**********************************************************************
*----------------------------------------------------------------------*
* batch input  data definition
*----------------------------------------------------------------------*
DATA    gv_nodata(1) VALUE '/'.
*       Batchinputdata of single transaction
DATA    gt_bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA    gt_messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')
DATA    gv_e_group_opened.
*       message texts
TABLES: t100.

**********************************************************************
**********************************************************************
DATA:
      gd_documentheader  LIKE bapiache03,
      gd_customercpd     LIKE bapiacpa00,
      it_accountpayable  LIKE bapiacap03 OCCURS 0 WITH HEADER LINE,
      it_accountgl       LIKE bapiacgl03 OCCURS 0 WITH HEADER LINE,
      it_accounttax      LIKE bapiactx01 OCCURS 0 WITH HEADER LINE,
      it_criteria        LIKE bapiackecr OCCURS 0 WITH HEADER LINE,
      it_valuefield      LIKE bapiackeva OCCURS 0 WITH HEADER LINE,
      it_currencyamount  LIKE bapiaccr01 OCCURS 0 WITH HEADER LINE,
      it_return          LIKE bapiret2   OCCURS 0 WITH HEADER LINE,
      it_purchaseorder   LIKE bapiacpo00 OCCURS 0 WITH HEADER LINE,
      it_purchaseamount  LIKE bapiaccrpo OCCURS 0 WITH HEADER LINE,
      it_receivers       LIKE bdi_logsys OCCURS 0 WITH HEADER LINE.

**********************************************************************
*
**********************************************************************
* ALV data
DATA: gr_table      TYPE REF TO cl_salv_table.
DATA: gr_selections TYPE REF TO cl_salv_selections,
      gt_rows       TYPE salv_t_row.
DATA: gr_functions  TYPE REF TO cl_salv_functions_list.

DATA : gt_color     TYPE lvc_t_scol,
       st_color     TYPE lvc_s_scol.
**********************************************************************

CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.

    METHODS on_link_click
            FOR EVENT link_click OF cl_salv_events_table
            IMPORTING row column.

    METHODS on_double_click
               FOR EVENT double_click OF cl_salv_events_table
               IMPORTING row column.

ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
* §5.2 implement the events for handling the events of cl_salv_table
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
*    PERFORM user_command USING e_salv_function.
  ENDMETHOD.                    "on_user_command

  METHOD on_link_click.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
SORT GT_DATA .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
    READ TABLE gt_data INTO wa_data INDEX row.
    IF sy-subrc = 0.
      CASE column.
        WHEN 'FOLIO'.
          CALL FUNCTION 'ZSD_DTE_MONITOR_REF'
            EXPORTING
              im_rutemisor = wa_data-rutemisor
              im_folio     = wa_data-folio
              im_tipodte   = wa_data-tipodte.

        WHEN 'URL'.
          TRANSLATE wa_data-url TO LOWER CASE.

          CALL FUNCTION 'GUI_RUN'
            EXPORTING
              command          = wa_data-url
*              PARAMETER        =
*              CD               =
*            IMPORTING
*              RETURNCODE       =
                    .


        WHEN 'ICON_STS'.

        WHEN 'ICON_FIELD'.  "despliega detalle


        WHEN 'NRO_DOCUMENTO'.
*          SET PARAMETER ID 'VF' FIELD wa_data-nro_documento.
*          CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
      ENDCASE.

    ENDIF.

  ENDMETHOD.                    "on_single_click

  METHOD on_double_click.

*ReSQ: No Need Of Change Internal Table GT_DATA Already Sorted
    READ TABLE gt_data INTO wa_data INDEX row.
    IF sy-subrc = 0.
      CASE column.
        WHEN 'ICON_STS'.

        WHEN 'ICON_FIELD'.  "despliega detalle

      ENDCASE.

      IF wa_data-estado = c_contabilizado.
        CASE wa_data-tcode .
          WHEN 'MIRO'.
            SET PARAMETER ID 'RBN' FIELD wa_data-belnr.
            SET PARAMETER ID 'GJR' FIELD wa_data-gjahr.
            CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
          WHEN 'FB60'.
            SET PARAMETER ID 'BLN' FIELD wa_data-belnr.
            SET PARAMETER ID 'GJR' FIELD wa_data-gjahr.
            SET PARAMETER ID 'BUK' FIELD '0100'.
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        ENDCASE.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "on_double_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS mycheckbox DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS mycheckbox DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS on_click_checkbox FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.                    "mycheckbox DEFINITION

*----------------------------------------------------------------------*
*       CLASS mycheckbox IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS mycheckbox IMPLEMENTATION.
  METHOD on_click_checkbox.
*    READ TABLE gt_data INDEX row INTO wa_data.
*    IF wa_data-selkz IS INITIAL ."AND wa_data-icon <> icon_green_light.
*      wa_data-selkz = 'X'.
*    ELSE.
*      CLEAR wa_data-selkz.
*    ENDIF.
*    MODIFY gt_data FROM wa_data INDEX sy-tabix.
    gr_table->refresh( refresh_mode = if_salv_c_refresh=>full ).

  ENDMETHOD.                    "on_click_checkbox

ENDCLASS.                    "mycheckbox IMPLEMENTATION

* for handling the events of cl_salv_table
DATA: gr_events TYPE REF TO lcl_handle_events.
