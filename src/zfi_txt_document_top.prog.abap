*&---------------------------------------------------------------------*
*&  Include           ZFI_TXT_DOCUMENT_TOP
*&---------------------------------------------------------------------*

*
TYPES: BEGIN OF ty_kunnr,
         kunnr TYPE kunnr,
         name1 TYPE name1_gp,
       END OF ty_kunnr,
       ty_t_kunnr TYPE TABLE OF ty_kunnr,
*
       BEGIN OF ty_lifnr,
         lifnr TYPE lifnr,
         name1 TYPE name1_gp,
       END OF ty_lifnr,
       ty_t_lifnr TYPE TABLE OF ty_lifnr,
*
       BEGIN OF ty_hkont,
         hkont TYPE hkont,
         txt20 TYPE txt20_skat,
       END OF ty_hkont,
       ty_t_hkont TYPE TABLE OF ty_hkont.
*
CLASS lcl_report   DEFINITION DEFERRED.
DATA : gt_kunnr TYPE TABLE OF ty_kunnr,
       gt_lifnr TYPE TABLE OF ty_lifnr,
       gt_hkont TYPE TABLE OF ty_hkont,
       gt_table TYPE REF TO  cl_salv_table.
*
DATA: BEGIN OF wa_selec,
        bukrs TYPE bkpf-bukrs,
        gjahr TYPE bkpf-gjahr,
        cpudt TYPE bkpf-cpudt,
        belnr TYPE bkpf-belnr,
*Begin V1 - MJD nuevos 04/04/2023 parametros de selección
        blart TYPE bkpf-blart,
*End V1 - MJD nuevos 04/04/2023 parametros de selección
      END OF wa_selec.

*
CONSTANTS gc_x TYPE c LENGTH 01 VALUE 'X'.
*
CLASS lcl_report DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      read_kunnr
        IMPORTING iv_kunnr TYPE kunnr
        EXPORTING lw_kunnr TYPE ty_kunnr
        CHANGING  ct_kunnr TYPE ty_t_kunnr,

      read_lifnr
        IMPORTING iv_lifnr TYPE lifnr
        EXPORTING lw_lifnr TYPE ty_lifnr
        CHANGING  ct_lifnr TYPE ty_t_lifnr,

      read_hkont
        IMPORTING iv_hkont TYPE hkont
        EXPORTING lw_hkont TYPE ty_hkont
        CHANGING  ct_hkont TYPE ty_t_hkont.
ENDCLASS.

CLASS lcl_report IMPLEMENTATION.

  METHOD read_kunnr.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT kunnr name1 APPENDING TABLE ct_kunnr
*          FROM kna1 WHERE kunnr EQ iv_kunnr.
*
* NEW CODE
    SELECT kunnr name1 APPENDING TABLE ct_kunnr

          FROM kna1 WHERE kunnr EQ iv_kunnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    lw_kunnr = ct_kunnr[ kunnr = iv_kunnr ].
    IF lw_kunnr-name1 IS INITIAL.
      lw_kunnr-name1 = iv_kunnr.
    ENDIF.
  ENDMETHOD.

  METHOD read_lifnr.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT lifnr name1 APPENDING TABLE ct_lifnr
*          FROM lfa1 WHERE lifnr EQ iv_lifnr.
*
* NEW CODE
    SELECT lifnr name1 APPENDING TABLE ct_lifnr

          FROM lfa1 WHERE lifnr EQ iv_lifnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    lw_lifnr = ct_lifnr[ lifnr = iv_lifnr ].
    IF lw_lifnr-name1 IS INITIAL.
      lw_lifnr-name1 = iv_lifnr.
    ENDIF.
  ENDMETHOD.

  METHOD read_hkont.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT saknr txt20 APPENDING TABLE ct_hkont
*          FROM skat WHERE spras EQ sy-langu
*                      AND ktopl EQ 'B100'
*                      AND saknr EQ iv_hkont.
*
* NEW CODE
    SELECT saknr txt20 APPENDING TABLE ct_hkont

          FROM skat WHERE spras EQ sy-langu
                      AND ktopl EQ 'B100'
                      AND saknr EQ iv_hkont ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    lw_hkont = ct_hkont[ hkont = iv_hkont ].
    IF lw_hkont-txt20 IS INITIAL.
      lw_hkont-txt20 = iv_hkont.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
