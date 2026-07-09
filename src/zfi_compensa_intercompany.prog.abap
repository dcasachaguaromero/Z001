*&---------------------------------------------------------------------*
*& Report ZFI_COMPENSA_INTERCOMPANY
*&---------------------------------------------------------------------*
*& Transacción: ZFI_COMP_INTER
*& Descripción: Compensación intercompany
*& Fecha: 22.04.2025
*&---------------------------------------------------------------------*
REPORT zfi_compensa_intercompany.

INCLUDE zfi_compensa_intercompany_top.
INCLUDE zfi_compensa_intercompany_sel.
INCLUDE zfi_compensa_intercompany_f01.

START-OF-SELECTION.

  DATA: lo_report TYPE REF TO lcl_report.
  CREATE OBJECT lo_report.

  lo_report->get_data( ).

end-of-selection.
  lo_report->generate_out( ).
