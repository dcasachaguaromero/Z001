*&---------------------------------------------------------------------*
*&  Include           ZFIBI_AS91_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
PARAMETER: p_arch LIKE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-001.
PARAMETERS: cb_actua  RADIOBUTTON GROUP grup DEFAULT 'X',
            cb_antes  RADIOBUTTON GROUP grup.
SELECTION-SCREEN END OF BLOCK b2.
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
  PERFORM crea_af.                                  " Crea Activo Fijo
  PERFORM mostrar_alv_msj.                          " Mostrar Log de Mensajes
