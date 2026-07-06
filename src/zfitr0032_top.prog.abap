*&---------------------------------------------------------------------*
*&  Include           ZFITR0032_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_bkpf,
          bukrs TYPE bkpf-bukrs,
          belnr TYPE bkpf-belnr,
          gjahr TYPE bkpf-gjahr,
          blart TYPE bkpf-blart,
          budat TYPE bkpf-budat,
          waers TYPE waers,
        END OF ty_bkpf,
*
        BEGIN OF ty_hist,
          clave         TYPE char25,
          bukrs_clr	    TYPE bkpf-bukrs,
          gjahr_clr     TYPE bse_clr-gjahr,
          belnr_clr     TYPE bse_clr-belnr,
          bukrs         TYPE bkpf-bukrs,
          gjahr         TYPE bkpf-gjahr,
          belnr         TYPE bkpf-belnr,
          buzei         TYPE buzei,
          zzmot_emis    TYPE zzmot_emis,
          blart         TYPE blart,
          lifnr         TYPE lifnr,
          sgtxt         TYPE sgtxt,
          wrbtr         TYPE wrbtr,
          budat         TYPE bkpf-budat,
          waers         TYPE waers,
          zzmot_emis_or TYPE zzmot_emis,
          error         TYPE char01,
        END OF ty_hist,
*
        BEGIN OF ty_skat,
          lifnr TYPE lifnr,
          txt50 TYPE txt50_skat,
        END OF ty_skat.
*
CLASS lcl_event_handler DEFINITION DEFERRED.
*
DATA : gt_hist          TYPE TABLE OF ty_hist,
       gt_skat          TYPE TABLE OF ty_skat,
       wa_hist          TYPE ty_hist,
       wa_hist_bkpf     TYPE ty_hist,
       wa_skat          TYPE ty_skat,
       gv_table         TYPE REF TO cl_salv_table,
       gv_columns_table TYPE REF TO cl_salv_columns_table,
       gv_column_table  TYPE REF TO cl_salv_column_table,
       gv_column        TYPE i,
       gv_corr          TYPE numc06,
       gv_repid         TYPE sy-repid,
       gv_belnr         TYPE belnr_d,
       gv_zzmot_emis    TYPE zzmot_emis,
       gv_clave         TYPE char25,
       gr_events        TYPE REF TO lcl_event_handler.
*
DATA : BEGIN OF wa_selec,
         bukrs TYPE bkpf-bukrs,
         cpudt TYPE bkpf-cpudt,
         belnr TYPE bkpf-belnr,
         blart TYPE bkpf-blart,
         buzei type bseg-buzei,
       END OF wa_selec.
*
CONSTANTS : gc_x     TYPE c LENGTH 01 VALUE 'X'.
*
FIELD-SYMBOLS : <table> TYPE STANDARD TABLE,
                <lines> TYPE any.
* CLASES
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column,

      on_single_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_user_command.
    PERFORM user_command USING e_salv_function.
  ENDMETHOD.                    "on_user_command

  METHOD on_double_click.

  ENDMETHOD.

  METHOD on_single_click.
    PERFORM lee_documento_fi USING row column.
  ENDMETHOD.
ENDCLASS.
