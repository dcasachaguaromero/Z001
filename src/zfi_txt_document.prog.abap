*&---------------------------------------------------------------------*
*& Report ZFI_TXT_DOCUMENT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_txt_document LINE-COUNT 65(8) LINE-SIZE 255.

INCLUDE zfi_txt_document_top.
INCLUDE zfi_txt_document_sel.
INCLUDE zfi_txt_document_f01.

START-OF-SELECTION.
  CLEAR : gt_table, gt_kunnr, gt_lifnr, gt_hkont.
*
  CASE gc_x.
    WHEN p_opc1.
      PERFORM actualiza_texto.
    WHEN p_opc2.
      PERFORM actualiza_texto_hist.
  ENDCASE.
*
  IF gt_table IS INITIAL.
    MESSAGE i899(fi) WITH 'Sin datos seleccionados'.
  ENDIF.
