*&---------------------------------------------------------------------*
*&  Include           ZFITR011_NEW_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_opc1 RADIOBUTTON GROUP uno DEFAULT 'X' USER-COMMAND pro,
             p_opc2 RADIOBUTTON GROUP uno.
SELECTION-SCREEN SKIP.
PARAMETER : bukrs    LIKE bkpf-bukrs    VALUE CHECK OBLIGATORY .
* ini - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
SELECTION-SCREEN SKIP.
SELECT-OPTIONS : s_numlot FOR tdev-numero_lote          MODIF ID ver,
                 s_ctacte FOR znovedadbanco-cuenta      MODIF ID ver,
                 s_fecpag FOR znovedadbanco-fecpag      MODIF ID ver,
                 s_feccon FOR zfitr011_est_002-fechacon MODIF ID ver,
                 s_datum  FOR ztfi_log_pago-datum       MODIF ID rev,
                 s_cuenta FOR znovedadbanco-cuenta      NO-DISPLAY,
                 s_fecha  FOR zfitr011_est_001-fechadev NO-DISPLAY,
                 s_lote   FOR tdev-numero_lote          NO-DISPLAY.
* fin - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
SELECTION-SCREEN SKIP.
PARAMETER : p_mode   LIKE ctu_params-dismode DEFAULT 'N' MODIF ID ver.
*PARAMETER : p_seg    TYPE numc1 DEFAULT '1' NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
    ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

  MOVE sy-tcode TO gv_tcode.
  IF gv_tcode NE 'ZFITR012_NEW_2'.
    gv_tcode = 'ZFITR012_NEW_2'.
  ENDIF.

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

AT SELECTION-SCREEN ON BLOCK b1.
* ini - Waldo Alarcón - 22.06.2020 - Solicitud de Banmedica
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'BUKRS' FIELD bukrs .
  IF sy-subrc <> 0.
    MESSAGE e083(f5) WITH bukrs .
  ENDIF.
* fin - Waldo Alarcón - 22.06.2020

  PERFORM ajusta_cuenta.
  PERFORM ajusta_fecha.
  PERFORM ajusta_lote.
