*&---------------------------------------------------------------------*
*&  Include           ZMM_REPORTE_CONDICION_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
*PARAMETERS     : p_kschl LIKE rv13a-kschl.
SELECT-OPTIONS : s_lifnr FOR wa_selec-lifnr ,
                 s_matnr FOR wa_selec-matnr ,
                 s_ekorg FOR wa_selec-ekorg ,
                 s_esokz FOR wa_selec-esokz.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK bereich  WITH FRAME TITLE TEXT-005.
*PARAMETERS     : p_datam LIKE wa_selec-datam OBLIGATORY .
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) TEXT-f01 FOR FIELD p_datam.
SELECTION-SCREEN POSITION 33.
PARAMETERS p_datam LIKE rv130-datam .
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) TEXT-f02 FOR FIELD p_datbi.
SELECTION-SCREEN POSITION 33.
PARAMETERS p_datbi LIKE rv130-datbi.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bereich.
*SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-002.
*SELECTION-SCREEN END OF BLOCK block1.
SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.
  p_datam = sy-datum.

AT SELECTION-SCREEN ON BLOCK block1.
  IF s_lifnr[] IS INITIAL AND s_matnr[] IS INITIAL AND s_ekorg[] IS INITIAL.
    MESSAGE e899(mm) WITH 'Ingrese al menos una Selección de Datos'.
  ENDIF.
