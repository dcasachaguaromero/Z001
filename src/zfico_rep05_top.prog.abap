*&---------------------------------------------------------------------*
*&  Include           ZFICO_REP04_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF ty_t001,
          bukrs TYPE t001-bukrs,
          waers TYPE t001-waers,
        END OF ty_t001,
*
        BEGIN OF ty_rep05,
          clave  TYPE zfico_rep05-clave,
          nombre TYPE zfico_rep05-nombre,
          bukrs  TYPE zfico_rep05-bukrs,
        END OF ty_rep05,
*
        BEGIN OF gty_kostl,
          kostl TYPE cskt-kostl,
          ltext TYPE cskt-ltext,
        END OF gty_kostl,
        gtt_kostl TYPE TABLE OF gty_kostl,
*
        BEGIN OF gty_hkont,
          hkont TYPE skat-saknr,
          ltext TYPE skat-txt50,
        END OF gty_hkont,
        gtt_hkont TYPE TABLE OF gty_hkont.
*
TYPES: BEGIN OF gty_datos,
         bukrs      TYPE bseg-bukrs,
         gjahr      TYPE bseg-gjahr,
         kostl      TYPE bseg-kostl,
         ltext      TYPE cskt-ltext,
         hkont      TYPE bseg-hkont,
         txt50      TYPE skat-txt50,
         blart      TYPE bkpf-blart,
         belnr      TYPE bseg-belnr,
         sgtxt      TYPE bseg-sgtxt,
         zzrut_terc TYPE bseg-zzrut_terc,
         budat      TYPE bkpf-budat,
         wrbtr      TYPE bseg-wrbtr,
         waers      TYPE bkpf-waers,
         dmbtr      TYPE bseg-dmbtr,
         waers_soc  TYPE t001-waers,
         dmbe3      TYPE bseg-dmbe3,
         pswbt      TYPE bseg-pswbt,
         hwae3      TYPE bkpf-hwae3,
         shkzg      TYPE bseg-shkzg,
       END OF gty_datos,
       gtt_datos TYPE TABLE OF gty_datos,
       BEGIN OF gty_lfa1,
         zzrut_terc TYPE bseg-zzrut_terc,
         lifnr      TYPE lfa1-lifnr,
         name1      TYPE lfa1-name1,
         stcd1      TYPE lfa1-stcd1,
       END OF gty_lfa1,
       gtt_lfa1 TYPE TABLE OF gty_lfa1, "TYPE STANDARD TABLE OF gty_lfa1 WITH KEY zzrut_terc,
       BEGIN OF gty_datos_res,
         clave      TYPE numc2,
         gjahr      TYPE bseg-gjahr,
         hkont      TYPE bseg-hkont,
         txt50      TYPE skat-txt50,
         kostl      TYPE bseg-kostl,
         ltext      TYPE cskt-ltext,
         zzrut_terc TYPE bseg-zzrut_terc,
         stcd1      TYPE lfa1-stcd1,
         lifnr      TYPE lifnr,
         nombre     TYPE name1,
         bukrs_01   TYPE wtgxxx,
         bukrs_02   TYPE wtgxxx,
         bukrs_03   TYPE wtgxxx,
         bukrs_04   TYPE wtgxxx,
         bukrs_05   TYPE wtgxxx,
         bukrs_06   TYPE wtgxxx,
         bukrs_07   TYPE wtgxxx,
         bukrs_08   TYPE wtgxxx,
         bukrs_09   TYPE wtgxxx,
         bukrs_10   TYPE wtgxxx,
         bukrs_11   TYPE wtgxxx,
         bukrs_12   TYPE wtgxxx,
         bukrs_13   TYPE wtgxxx,
         bukrs_14   TYPE wtgxxx,
         bukrs_15   TYPE wtgxxx,
         waers      TYPE bkpf-waers,
       END OF gty_datos_res,
       gtt_datos_res TYPE TABLE OF gty_datos_res,
       gtt_salida    TYPE STANDARD TABLE OF  zes_fico_rep05 WITH DEFAULT KEY.

DATA : BEGIN OF wa_select,
         bukrs TYPE bkpf-bukrs,
         gjahr TYPE bkpf-gjahr,
         hkont TYPE bseg-hkont,
         kostl TYPE bseg-kostl,
         budat TYPE bkpf-budat,
         stcd1 TYPE bseg-zzrut_terc,
       END OF wa_select.

DATA : gt_salida     TYPE TABLE OF zes_fico_rep05,
       gt_rep05      TYPE TABLE OF ty_rep05,
       gt_salida_det TYPE gtt_datos,
       gt_datos      TYPE gtt_datos,
       gt_t001       TYPE TABLE OF ty_t001,
       gv_repid      TYPE sy-repid.
*
FIELD-SYMBOLS <tables> TYPE STANDARD TABLE .
*
CONSTANTS : gc_x     TYPE c LENGTH 01 VALUE 'X',
            gc_kokrs TYPE c LENGTH 04 VALUE 'BMSA',
            gc_ktopl TYPE c LENGTH 04 VALUE 'B100',
            gc_tabla TYPE c LENGTH 30 VALUE 'ZES_FICO_REP05'.
*
CLASS lcl_report    DEFINITION DEFERRED.
DATA: lo_report     TYPE REF TO lcl_report.

******************************************************************************
CLASS cl_handler DEFINITION.
  PUBLIC SECTION.
*    METHODS on_double_click FOR EVENT double_click OF cl_salv_events_table
    METHODS on_double_click FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.                    "cl_handler DEFINITION

*
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    DATA : lr_bukrs  TYPE RANGE OF t001-bukrs.

    METHODS:
      lee_datos
        CHANGING co_data_out TYPE gtt_datos,
      lee_acreedor
        IMPORTING co_data_in  TYPE gtt_datos
        CHANGING  co_lfa1_out TYPE gtt_lfa1,
      acumula_datos
        IMPORTING co_data_in  TYPE gtt_datos
                  co_lfa1_in  TYPE gtt_lfa1
        CHANGING  co_data_res TYPE gtt_datos_res,
      genera_salida
        IMPORTING co_data_in TYPE gtt_datos_res
        CHANGING  co_salida  TYPE gtt_salida.
ENDCLASS.
