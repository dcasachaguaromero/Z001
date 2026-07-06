*&---------------------------------------------------------------------*
*& Report  ZFISD001
*&
*&---------------------------------------------------------------------*
*& Autor:    Programador VisionOne.
*& Fecha:    12.09.2013
*& Objetivo: Actualizar Nro. Core en algunas facturas. Se lee archivo
*&           el detalle con las facturas y sus Nro. Core a actualizar.
*&
*&--------------------MODIFICACIONES-----------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT  zfisd001.

INCLUDE zfisd001_top.
INCLUDE zfisd001_sel.
INCLUDE zfisd001_rut.

START-OF-SELECTION.
  g_repid = sy-repid.
  PERFORM subir_archivo.
  IF NOT ti_entrada[] IS INITIAL.
    PERFORM procesar.
    IF NOT ti_VBRK[] IS INITIAL.
       PERFORM mostrar_alv.
    ENDIF.
  ELSE.
    MESSAGE text-002 TYPE 'I'.
  ENDIF.
