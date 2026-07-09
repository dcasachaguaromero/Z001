*&---------------------------------------------------------------------*
*&  Include           ZFI_TXT_DOCUMENT_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-000.
PARAMETERS p_opc1 RADIOBUTTON GROUP uno.

*Begin V1 - MJD nuevos 04/04/2023 parametros de selección
SELECT-OPTIONS: s_bukrp FOR wa_selec-bukrs,
                s_gjahp FOR wa_selec-gjahr,
                s_blart FOR wa_selec-blart.
*Begin V1 - MJD nuevos 04/04/2023 parametros de selección
SELECT-OPTIONS: s_cpudt  FOR wa_selec-cpudt NO-EXTENSION,
                s_belnr  FOR wa_selec-belnr.
SELECTION-SCREEN SKIP.
PARAMETERS p_opc2 RADIOBUTTON GROUP uno.
SELECT-OPTIONS: s_bukrs  FOR wa_selec-bukrs,
                s_gjahr  FOR wa_selec-gjahr NO-EXTENSION NO INTERVALS.
PARAMETERS    : p_lineas TYPE i.
SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.

AT SELECTION-SCREEN ON BLOCK block1.
  IF p_opc1 EQ gc_x.
    IF s_cpudt[] IS INITIAL.
      MESSAGE e899(fi) WITH 'Ingrese fecha de entrada'.
    ENDIF.
  ELSEIF p_opc2 EQ gc_x.
    IF s_gjahr-low IS INITIAL .
      SET CURSOR FIELD 'S_GJAHR-LOW'.
      MESSAGE e899(fi) WITH 'Campo Ejercicio obligatorio'.
    ENDIF.
    IF p_lineas IS INITIAL.
      SET CURSOR FIELD 'P_LINEAS'.
      MESSAGE e899(fi) WITH 'Líneas a procesar obligatorio'.
    ENDIF.
  ENDIF.
