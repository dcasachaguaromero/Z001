*&---------------------------------------------------------------------*
*& Report  ZFI_LOG_RECHAZOS
*&
*&-------------------------------------------------------------------- *
*& Objtivo: Reporte registro de Rechazos
*& Autor  : E.Sobarzo M.  (Visionone)
*& Fecha  : 02.01.2012
*&**********************************************************************
*& Modificaciones:
*&
*&---------------------------------------------------------------------*

REPORT zfi_log_rechazos.

TABLES zfirechzrec.
*----------------------------------------------------------------------*
*       CLASS lcl_report DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_report DEFINITION.
*
  PUBLIC SECTION.
*
    DATA: t_rechazo TYPE STANDARD TABLE OF zfirechzrec.

    DATA: o_alv TYPE REF TO cl_salv_table.
*
    METHODS:
      get_data,

      generate_output.

    METHODS: set_pf_status
                     CHANGING
                         co_alv TYPE REF TO cl_salv_table. " Default Pf
*
ENDCLASS.                    "lcl_report DEFINITION
*
*
SELECTION-SCREEN BEGIN OF BLOCK b1
                          WITH FRAME TITLE title.
SELECT-OPTIONS:
    s_bukrs FOR zfirechzrec-bukrs NO-EXTENSION NO INTERVALS,
    s_kunnr  FOR zfirechzrec-kunnr,
    s_vertn  FOR zfirechzrec-vertn.

SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  title = 'Parámetros'(001).

START-OF-SELECTION.
  DATA: lo_report TYPE REF TO lcl_report.
*
  CREATE OBJECT lo_report.
*
  lo_report->get_data( ).
*
  lo_report->generate_output( ).
*
*----------------------------------------------------------------------*
*       CLASS lcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_report IMPLEMENTATION.
*
  METHOD get_data.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT *
*           INTO  TABLE t_rechazo
*           FROM  zfirechzrec
*           WHERE bukrs IN s_bukrs  AND
*                 kunnr IN s_kunnr  AND
*                 vertn IN s_vertn.
*
* NEW CODE
    SELECT *

           INTO  TABLE t_rechazo
           FROM  zfirechzrec
           WHERE bukrs IN s_bukrs  AND
                 kunnr IN s_kunnr  AND
                 vertn IN s_vertn ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  ENDMETHOD.                    "get_data
*
*.......................................................................
  METHOD generate_output.
    DATA: lx_msg TYPE REF TO cx_salv_msg.
    DATA: lv_string TYPE string.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = o_alv
          CHANGING
            t_table      = t_rechazo ).
      CATCH cx_salv_msg INTO lx_msg.
        lv_string = lx_msg->get_text( ).   " <
        MESSAGE lv_string TYPE 'I'.  "<

    ENDTRY.

***Calling Set PF status method
    CALL METHOD set_pf_status
      CHANGING
        co_alv = o_alv.       "set_end_of_page

    o_alv->display( ).

  ENDMETHOD.                    "generate_output

  METHOD set_pf_status.
    DATA: lo_functions TYPE REF TO cl_salv_functions_list.
* Default functions
    lo_functions = co_alv->get_functions( ).
    lo_functions->set_all( 'X' ).
  ENDMETHOD.                    "set_pf_status
ENDCLASS.                    "lcl_report IMPLEMENTATION
