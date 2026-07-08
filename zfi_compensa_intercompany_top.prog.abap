*&---------------------------------------------------------------------*
*&  Include           ZFI_COMPENSA_INTERCOMPANY_TOP
*&---------------------------------------------------------------------*
TABLES: kna1, bsid.

*----------------------------------------------------------------------*
*       CLASS lcl_report DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.

    CONSTANTS : c_x TYPE c VALUE 'X'.

    TYPES: BEGIN OF ty_data,
             llave TYPE char40,              " LLave
             bukrs TYPE bsid-bukrs,          " Sociedad
             kunnr TYPE bsid-kunnr,          " Cliente
             umskz TYPE bsid-umskz,          " Cme
             zuonr TYPE bsid-zuonr,          " Asignación
             belnr TYPE bsid-belnr,          " Identificador
             gjahr TYPE bsid-gjahr,          " Ejercicio
             buzei TYPE bsid-buzei,          " Posición
             budat TYPE bsid-budat,          " Fecha contable
             bldat TYPE bsid-bldat,          " Fecha documento
             wrbtr TYPE wrshb,          " Importe
             waers TYPE bsid-waers,          " Moneda
             augbl TYPE bsid-augbl,          " Doc.compensación
             augdt TYPE bsid-augdt,          " Fecha compensación
             message type bapiret2-message,
           END OF ty_data.

    TYPES: BEGIN OF ty_aux,
             llave TYPE char40,              " LLave
             wrbtr TYPE wrshb,
             waers TYPE bsid-waers,
           END OF ty_aux.

    DATA: ti_data TYPE TABLE OF ty_data,
          ti_aux  TYPE TABLE OF ty_aux,
          wa_aux  TYPE ty_aux,
          wa_data TYPE ty_data.

    DATA: o_alv_r TYPE REF TO cl_salv_table.

    METHODS:
      get_data,
      compensar,
      generate_out.

    METHODS:
      on_link_click
          FOR EVENT link_click OF cl_salv_events_table
        IMPORTING
          row
          column  .

*    METHODS:
*      on_user_command
*                  FOR EVENT added_function OF cl_salv_events
*        IMPORTING e_salv_function.

  PRIVATE SECTION.
    METHODS:
      set_pf_status
        CHANGING
          co_alv TYPE REF TO cl_salv_table.

    METHODS:
      set_columns
        CHANGING
          co_alv TYPE REF TO cl_salv_table.

    METHODS:
      set_aggregations
        CHANGING
          co_alv TYPE REF TO cl_salv_table.

    METHODS:
      set_display_setting
        CHANGING
          co_alv TYPE REF TO cl_salv_table.
ENDCLASS.
