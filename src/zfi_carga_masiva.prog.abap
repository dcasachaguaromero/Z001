*&---------------------------------------------------------------------*
*& Report ZFI_CARGA_MASIVA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_carga_masiva.

INCLUDE zfi_carga_masiva_top.
INCLUDE zfi_carga_masiva_sel.
INCLUDE zfi_carga_masiva_f01.

START-OF-SELECTION.
  CHECK gv_ok EQ gc_x.
  CLEAR gt_excel[].
  CASE gc_x.
    WHEN p_opc1.
      PERFORM lee_archivo_csv.
    WHEN p_opc2.
      PERFORM lee_archivo_excel.
  ENDCASE.
  IF gt_excel[] IS NOT INITIAL.
    PERFORM prepara_datos.
    IF gt_detalle[] IS NOT INITIAL.
      gv_num_docum = 1.
      PERFORM asiento_contable.
      PERFORM muestra_datos.
    ELSE.
      MESSAGE 'Sin datos de posición cargados' TYPE 'I'.
    ENDIF.
  ELSE.
    MESSAGE 'Sin datos cargados' TYPE 'I'.
  ENDIF.
