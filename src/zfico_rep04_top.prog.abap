*&---------------------------------------------------------------------*
*&  Include           ZFICO_REP04_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF ty_t001,
          bukrs TYPE t001-bukrs,
          waers TYPE t001-waers,
        END OF ty_t001.

TYPES: BEGIN OF gty_datos,
         bukrs      TYPE bseg-bukrs,
         gjahr      TYPE bseg-gjahr,
         monat      TYPE monat,
         kostl      TYPE bseg-kostl,
         ltext      TYPE cskt-ltext,
         hkont      TYPE bseg-hkont,
         txt50      TYPE skat-txt50,
         blart      TYPE bkpf-blart,
         belnr      TYPE bseg-belnr,
         sgtxt      TYPE bseg-sgtxt,
         lifnr      TYPE lfa1-lifnr,
         zzrut_terc TYPE bseg-zzrut_terc,
         stcd1      TYPE lfa1-stcd1,
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
       BEGIN OF gty_meses,
*         bukrs TYPE bukrs,
         gjahr TYPE gjahr,
         monat TYPE monat,
         mes   type numc2,
       END OF gty_meses,
       gtt_meses TYPE TABLE OF gty_meses.

DATA : BEGIN OF wa_select,
         bukrs TYPE bkpf-bukrs,
         gjahr TYPE bkpf-gjahr,
         hkont TYPE bseg-hkont,
         kostl TYPE bseg-kostl,
         stcd1 TYPE bseg-zzrut_terc,
         budat TYPE bkpf-budat,
         lifnr TYPE lfa1-lifnr,
       END OF wa_select.

DATA : gt_salida     TYPE TABLE OF zes_fico_rep04,
       gt_salida_det TYPE gtt_datos,
       gt_datos      TYPE gtt_datos,
       gt_meses      TYPE gtt_meses,
       gt_t001       TYPE TABLE OF ty_t001,
       gv_repid      TYPE sy-repid.
*
FIELD-SYMBOLS <tables> TYPE STANDARD TABLE .
*
CONSTANTS : gc_x     TYPE c LENGTH 01 VALUE 'X',
            gc_kokrs TYPE c LENGTH 04 VALUE 'BMSA',
            gc_ktopl TYPE c LENGTH 04 VALUE 'B100',
            gc_tabla TYPE c LENGTH 30 VALUE 'ZES_FICO_REP04'.

******************************************************************************
CLASS cl_handler DEFINITION.
  PUBLIC SECTION.
*    METHODS on_double_click FOR EVENT double_click OF cl_salv_events_table
    METHODS on_double_click FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.                    "cl_handler DEFINITION
