*&---------------------------------------------------------------------*
*&  Include           ZFITR046_NEW_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&    Declaración de parametros de Programa
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_opc1 RADIOBUTTON GROUP uno DEFAULT 'X' USER-COMMAND pro,
             p_opc2 RADIOBUTTON GROUP uno.
SELECTION-SCREEN SKIP.
PARAMETER : bukrs    LIKE bkpf-bukrs          VALUE CHECK OBLIGATORY .
PARAMETER : ubnkl    LIKE znovedadbanco-banco VALUE CHECK OBLIGATORY
                                              DEFAULT '037'.
* ini - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
SELECT-OPTIONS : s_numlot FOR znovedadbanco-numlot       MODIF ID ver,
                 s_ctacte FOR znovedadbanco-cuenta       MODIF ID ver,
                 s_fecpag FOR znovedadbanco-fecpag       MODIF ID ver,
                 s_feccon FOR zfitr045_est_002-fechacon  MODIF ID ver,
                 s_datum  FOR ztfi_log_pago-datum        MODIF ID rev,
                 s_cuenta FOR znovedadbanco-cuenta NO-DISPLAY.
* fin - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
PARAMETER : p_newko  LIKE rf05a-newko         VALUE CHECK OBLIGATORY
                                              DEFAULT '2011800007'
                                                         MODIF ID ver.
PARAMETER : p_estado LIKE zfitr045_est_001-estado_pago
                                              VALUE CHECK OBLIGATORY
                                      DEFAULT 'VALE VISTA REINTEGRAD'
                                                          MODIF ID ver.
SELECTION-SCREEN SKIP.
PARAMETER : p_lineas  TYPE i DEFAULT  0                   MODIF ID ver."HCD 20200421
PARAMETER : p_mode   LIKE ctu_params-dismode DEFAULT 'N'  MODIF ID ver.
*PARAMETER : p_seg     TYPE numc1 DEFAULT '1'.
PARAMETER : p_fb09   LIKE ctu_params-dismode DEFAULT 'N' NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
    ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

  MOVE sy-tcode TO gv_tcode.
  IF gv_tcode NE 'ZFITR046_NEW_2'.
    gv_tcode = 'ZFITR046_NEW_2'.
  ENDIF.

*
AT SELECTION-SCREEN ON BLOCK b1.
* ini - Waldo Alarcón - 22.06.2020 - Solicitud de Banmedica
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'BUKRS' FIELD bukrs .
  IF sy-subrc <> 0.
    MESSAGE e083(f5) WITH bukrs .
  ENDIF.
* fin - Waldo Alarcón - 22.06.2020

  REFRESH s_cuenta[].
  LOOP AT s_ctacte.
    IF s_ctacte-low IS NOT INITIAL.
      APPEND s_ctacte TO s_cuenta.
* variable de 10 caracteres
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = s_ctacte-low
        IMPORTING
          output = gv_char10.
      s_ctacte-low = gv_char10.
      IF s_ctacte-high IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = s_ctacte-high
          IMPORTING
            output = gv_char10.
        s_ctacte-high = gv_char10.
      ENDIF.
      APPEND s_ctacte TO s_cuenta.
* variable de 18 caracteres
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = s_ctacte-low
        IMPORTING
          output = gv_char18.
      s_ctacte-low = gv_char18.
      IF s_cuenta-high IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = s_ctacte-high
          IMPORTING
            output = gv_char18.
        s_ctacte-high = gv_char18.
      ENDIF.
      APPEND s_ctacte TO s_cuenta.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'VER'.
        IF p_opc1 IS INITIAL.
          screen-active = 0.
        ENDIF.
      WHEN 'REV'.
        IF p_opc1 IS NOT INITIAL.
          screen-active = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
