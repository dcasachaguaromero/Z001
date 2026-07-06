*&---------------------------------------------------------------------*
*&  Include           ZMM_BAJA_CARGA_STOCK_TOP
*&---------------------------------------------------------------------*

  TYPE-POOLS kkblo.
*
  TYPES: BEGIN OF gty_salida,
*----------- Accesos ------------
           bldat(010),
           budat(010),
           bktxt(25),
           bwart(003),
           werks(004),
           sobkz(001), "stock especial
           lifnr(010),
           kunnr(010),
*          gsber(004),
*---------- Posiciones ----------
           matnr(018),
           erfmg(017),
           erfme(003),
           lgort(004),
           charg(015),
           err,
*
           mtart      TYPE mara-mtart,
           maktx      TYPE makt-maktx,
*
           salk3(018),
         END OF gty_salida,
         gty_T_salida TYPE TABLE OF gty_salida.

  DATA : BEGIN OF wa_select,
           matnr TYPE marc-matnr,
           werks TYPE marc-werks,
           lgort TYPE mard-lgort,
           charg TYPE mchb-charg,
           mtart TYPE mara-mtart,
           sobkz TYPE mkol-sobkz,
         END OF wa_select.

  DATA: gv_repid TYPE sy-repid.

  CONSTANTS : gc_x   TYPE c LENGTH 01 VALUE 'X'.
