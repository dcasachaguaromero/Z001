*&---------------------------------------------------------------------*
*&  Include           ZTRANSFER_DOCPAGO_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
SELECT-OPTIONS: s_zbukr  FOR reguh-zbukr OBLIGATORY,
                s_fecha  FOR reguh-laufd OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
PERFORM consul_prop.    " Consulta Propuestas
LOOP AT gt_propuesta INTO gw_propuesta.
PERFORM validar_ejec.   " Valida Ejecucion realizada en tabla ZFITR_TESDOCPAGO.
PERFORM insert_trans.   " Inserta transferencia.
PERFORM act_tabla_z.    " Actualiza tabla ZFITR_TESDOCPAGO.
CLEAR: gw_propuesta.
ENDLOOP.
