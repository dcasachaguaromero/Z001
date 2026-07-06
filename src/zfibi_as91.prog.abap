*&---------------------------------------------------------------------*
*& Report  ZFIBI_AS91
*&---------------------------------------------------------------------*
*& Consultor ABAP: Leonardo Foubert
*& Consultor Funcional: Claudio Garcia - FI
*& Fecha: 22.04.2013
*& Descripción: Reporte para carga masiva de AF. a partir de un
*& archivo excel, se crean activos fijos mendiante la transaccion AS91
*& se rescatan los mensajes y se muestran por pantalla.
*&---------------------------------------------------------------------*

REPORT  ZFIBI_AS91.

INCLUDE ZFIBI_AS91_TOP.     " Datos Globales.
INCLUDE ZFIBI_AS91_SEL.     " Pantalla de Selección.
INCLUDE ZFIBI_AS91_F01.     " Rutinas.
INCLUDE ZFIBI_AS91_ALV.     " ALV (Log de Mensajes).
