*&---------------------------------------------------------------------*
*&  Include           ZINTHELPT00
*&---------------------------------------------------------------------*
CONSTANTS clase_contrato TYPE c LENGTH 010 VALUE 'ZCONTRATOS'.

TYPES: gty_data TYPE zsd_bi_clientes,
       gtt_data TYPE STANDARD TABLE OF gty_data.

TABLES: kna1,
        adrc.

DATA: wa_data  TYPE gty_data,
      ls_bdc   TYPE bdcdata,
      ls_mess  TYPE bdcmsgcoll,
      opciones TYPE ctu_params.

DATA: t_data  TYPE STANDARD TABLE OF zsd_bi_clientes,
      bdcdata TYPE STANDARD TABLE OF bdcdata,
      messtab TYPE STANDARD TABLE OF bdcmsgcoll.

DATA: tmp_fec TYPE c LENGTH 10,
      ctumode TYPE ctu_mode   VALUE 'N',
      cupdate TYPE ctu_update VALUE 'S'.
