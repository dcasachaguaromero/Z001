*&---------------------------------------------------------------------*
*&  Include           ZFIBI_AS92_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
PARAMETER: p_arch LIKE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_arch.
  PERFORM filename_get CHANGING p_arch.

  START-OF-SELECTION.
  PERFORM valida_parametros.                        " Validar Parametro de entradas.
  PERFORM carga_archivo.                            " Cargar Archivo Excel
  PERFORM modifica_af.                              " Modifica Activo Fijo
  PERFORM mostrar_alv_msj.                          " Mostrar Log de Mensajes
