*&---------------------------------------------------------------------*
*& Report  ZFI_CHEQUE_COMPENSA
*&
*&---------------------------------------------------------------------*
*& Consultor ABAP: Leonardo Foubert
*& Fecha Creación: 03.06.2013
*& Descripción: Reporte de carga masiva para compensar cheques mediante
*& la transaccion FEBAN.
*&---------------------------------------------------------------------*

REPORT  ZFI_CHEQUE_COMPENSA2.

INCLUDE ZFICHEQUE_COMPENSA_TOP.     " Datos Globales.
INCLUDE ZFICHEQUE_COMPENSA_SEL.     " Pantalla de Selección.
INCLUDE ZFICHEQUE_COMPENSA_F01.     " Rutinas.
INCLUDE ZFICHEQUE_COMPENSA_ALV.     " ALV (Log de Mensajes).
