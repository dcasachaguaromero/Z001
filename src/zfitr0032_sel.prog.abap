*&---------------------------------------------------------------------*
*&  Include           ZFITR0032_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : p_fecha RADIOBUTTON GROUP uno USER-COMMAND opc
                                           DEFAULT 'X',
                 p_codz6 RADIOBUTTON GROUP uno.
*SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME.
SELECT-OPTIONS : s_bukrs  FOR wa_selec-bukrs NO-EXTENSION NO INTERVALS
                                      OBLIGATORY MEMORY ID buk,
                 s_cpudt  FOR wa_selec-cpudt,
                 s_belnr  FOR wa_selec-belnr,
                 s_buzei  FOR wa_selec-buzei MODIF ID zz,
                 s_blart  FOR wa_selec-blart MODIF ID z6,
                 s_blaz6  FOR wa_selec-blart MODIF ID zz.
SELECTION-SCREEN END OF BLOCK block2.
PARAMETERS     : p_error AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
    ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

  CLEAR s_cpudt[].
  s_cpudt-sign = 'I'.         s_cpudt-option = 'BT'.
  s_cpudt-low = sy-datum - 1. s_cpudt-high   = sy-datum.
  APPEND s_cpudt.
*
  PERFORM selecciona_blart.

AT SELECTION-SCREEN ON s_blart.
  IF p_fecha EQ gc_x AND s_blart[] IS INITIAL.
    MESSAGE e899(fi) WITH 'Ingrese Clase Documento'.
  ENDIF.

AT SELECTION-SCREEN ON s_blaz6.
  IF p_codz6 EQ gc_x AND s_blaz6[] IS INITIAL.
    MESSAGE e899(fi) WITH 'Ingrese Clase Documento'.
  ENDIF.

AT SELECTION-SCREEN ON BLOCK block1.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'BUKRS' FIELD s_bukrs-low .
  IF sy-subrc <> 0.
    MESSAGE e899(fi) WITH 'Sin autorización para la sociedad'(m01)
                           s_bukrs-low .
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE gc_x.
      WHEN p_fecha.
        IF screen-group1 EQ 'ZZ'.
          screen-active = 0.
        ENDIF.
      WHEN p_codz6.
        IF screen-group1 EQ 'Z6'.
          screen-active = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
