*&---------------------------------------------------------------------*
*&  Include           ZFI_CHEQUE_COMPENSA_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
PARAMETER: p_arch LIKE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b1.
*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_arch.
  PERFORM filename_get CHANGING p_arch.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM valida_parametros.                        " Validar Parametro de entradas.
  PERFORM carga_archivo.                            " Cargar Archivo Excel
  PERFORM call_feban.                               " Compensa cheques por Tx: FEBAN
  PERFORM mostrar_alv_msj.                          " Mostrar Log de Mensajes
