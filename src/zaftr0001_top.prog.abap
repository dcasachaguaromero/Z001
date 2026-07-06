*&---------------------------------------------------------------------*
*&  Include           ZAFTR0001_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.
*
TYPES : BEGIN OF ty_lifnr,
          lifnr TYPE lifnr,
          land1 TYPE land1,
          name1 TYPE name1,
          stcd1 TYPE stcd1,
        END OF ty_lifnr,

        BEGIN OF ty_t093b,
          bukrs TYPE bukrs,
          afabe TYPE afabe_d,
          waers TYPE waers,
        END OF ty_t093b.
*
DATA : BEGIN OF wa_selecc,
         bukrs TYPE anla-bukrs,
         anln1 TYPE anla-anln1,
         anln2 TYPE anla-anln2,
         anlkl TYPE anla-anlkl,
         kostl TYPE anlz-kostl,
         stort TYPE anlz-stort,
         anlue TYPE anla-anlue,
         deakt TYPE anla-deakt,
         afabe TYPE anlc-afabe,
         fecha TYPE anla-deakt,
       END OF wa_selecc.
*
CLASS lcl_event_receiver DEFINITION DEFERRED.
*
DATA : gt_salida           TYPE TABLE OF zeaf_trazabilidad,
       gt_lifnr            TYPE TABLE OF ty_lifnr,
       gt_datos            TYPE TABLE OF zeaf_trazabilidad_mod,
       gt_datos_fi         TYPE TABLE OF zeaf_trazabilidad_mod,
       gt_datos_mm         TYPE TABLE OF zeaf_trazabilidad_mod,
       gt_datos_af         TYPE TABLE OF zeaf_trazabilidad_mod,
       gt_t093b            TYPE TABLE OF ty_t093b,
       wa_salida           TYPE zeaf_trazabilidad,
       wa_datos            TYPE zeaf_trazabilidad_mod,
       wa_t093b            TYPE ty_t093b,
       gv_repid            TYPE sy-repid,
       gv_proceso          TYPE char02,
*
       gv_custom_container TYPE REF TO cl_gui_custom_container,
       gv_cont_on_dialog   TYPE scrfname VALUE 'ACTIVO_FIJO',
       gv_grid             TYPE REF TO cl_gui_alv_grid,
       gt_fieldcat         TYPE lvc_t_fcat,
       gs_layout           TYPE lvc_s_layo,
       ok_code             LIKE sy-ucomm,
       lv_event_receiver   TYPE REF TO lcl_event_receiver.
*
*
CONSTANTS : gc_x     TYPE c LENGTH 01 VALUE 'X',
            gc_tabla TYPE c LENGTH 30 VALUE 'ZEAF_TRAZABILIDAD_ALV',
            gc_estrc TYPE c LENGTH 30 VALUE 'ZEAF_TRAZABILIDAD_MOD'.
*
* Definition:
* ~~~~~~~~~~~
CLASS lcl_event_receiver DEFINITION.

  PUBLIC SECTION.
    METHODS:
      handle_hotspot_click
                  FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id es_row_no.
  PRIVATE SECTION.
ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_hotspot_click.
*
    DATA : l_getfeld  TYPE t354s-initfield,
           l_getvalue TYPE t354s-initfield,
           ti_iobject TYPE TABLE OF iopick.
*
    CASE e_column_id.
      WHEN 'BELNR'.
        READ TABLE gt_datos INTO wa_datos INDEX e_row_id-index .
        l_getfeld  = 'RIHAUFM-MBLNR'.
        l_getvalue = wa_datos-belnr.
        CALL FUNCTION 'MASTER_DATA'
          EXPORTING
            datenfeld  = l_getfeld
            fieldvalue = l_getvalue
          TABLES
            iobject    = ti_iobject.
      WHEN 'BELNR_FI'.
        READ TABLE gt_datos INTO wa_datos INDEX e_row_id-index .
        SET PARAMETER ID : 'BLN' FIELD wa_datos-belnr_fi,
                           'BUK' FIELD wa_datos-bukrs,
                           'GJR' FIELD wa_datos-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
