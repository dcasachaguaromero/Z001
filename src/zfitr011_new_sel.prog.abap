*&---------------------------------------------------------------------*
*&  Include           ZFITR011_NEW_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETER : bukrs    LIKE bkpf-bukrs    VALUE CHECK OBLIGATORY .
* ini - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
SELECTION-SCREEN SKIP.
SELECT-OPTIONS : s_numlot FOR tdev-numero_lote,
                 s_ctacte FOR znovedadbanco-cuenta,
                 s_fecpag FOR znovedadbanco-fecpag,
                 s_feccon FOR zfitr011_est_002-fechacon,
                 s_cuenta FOR znovedadbanco-cuenta      NO-DISPLAY,
                 s_fecha  FOR zfitr011_est_001-fechadev NO-DISPLAY,
                 s_lote   FOR tdev-numero_lote          NO-DISPLAY.
* fin - Waldo Alarcón - Nuevos campos de Selección - 23.04.2020
SELECTION-SCREEN SKIP.
PARAMETER : p_mode   LIKE ctu_params-dismode DEFAULT 'E' MODIF ID a1.
SELECTION-SCREEN END OF BLOCK b1.


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CHECK screen-group1 EQ 'A1' AND sy-sysid EQ 'ECP'.
    screen-active = 0.
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
