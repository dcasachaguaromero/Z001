*&---------------------------------------------------------------------*
*& Report ZFITR0032                                                    *
*& Autor : Waldo Alarcón                                               *
*% Fecha : 06-07-2020                                                  *
*& Empresa : Visionone                                                 *
*& Descripción : Programa para actualizar el Motivo de Emisión y       *
*& generar un reporte de la trazabilidad de los documentos.            *
*&---------------------------------------------------------------------*
*& Programa de apoyo SALV_DEMO_TABLE_COLUMNS
*&---------------------------------------------------------------------*
REPORT zfitr0032.

INCLUDE zfitr0032_top.
INCLUDE zfitr0032_sel.
INCLUDE zfitr0032_f01.

START-OF-SELECTION.
*
  PERFORM inicializa_var.
*
  CASE gc_x.
    WHEN p_fecha. "Toma desde la fecha seleccionada hacia atras.
      PERFORM lee_datos_fecha.
    WHEN p_codz6. "Toma del documento Z6 hacia adelante
      PERFORM lee_datos_z6.
  ENDCASE.
* Crea la tabla en forma dinamica
  PERFORM crear_tabla.
* Mueve los datos seleccionados a la tabla dinamica
  PERFORM mueve_datos.
* Verifica si es proceso Batch o ON-LINE
  IF <table> IS ASSIGNED.
    IF sy-batch IS INITIAL.
      PERFORM muestra_datos.
    ELSE.
      PERFORM ajusta_motivo.
      PERFORM muestra_datos.
    ENDIF.
  ELSE.
    MESSAGE e899(fi) WITH 'Tabla creada con error'.
  ENDIF.
