*&---------------------------------------------------------------------*
*& Report ZFIMOVER_BSIS_BSAS
*&---------------------------------------------------------------------*
*& Fecha 02.12.2025
*& Llevar de la tabla BSIS a la tabla BSAS los documentos anulados que
*& por error fueron llevados a la BSIS mediante el programa
*& ZFIMODIF_BSIS
*&---------------------------------------------------------------------*
REPORT zfimover_bsis_bsas.
CONSTANTS: c_x TYPE c VALUE 'X'.
DATA: w_bukrs LIKE skb1-bukrs.
DATA: w_saknr LIKE skb1-saknr.
DATA: w_xopvw LIKE skb1-xopvw.
DATA: it_bsis TYPE TABLE OF bsis,
      it_bsas TYPE TABLE OF bsas,
      wa_bsas TYPE bsas.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-t01.
PARAMETERS: p_bukrs TYPE bkpf-bukrs OBLIGATORY,
            p_belnr TYPE bkpf-belnr OBLIGATORY,
            p_gjahr TYPE bkpf-gjahr OBLIGATORY,
            p_hkont TYPE ska1-saknr OBLIGATORY,
            p_augbl type bseg-augbl OBLIGATORY,
            p_augdt type bseg-augdt OBLIGATORY.
SELECTION-SCREEN END OF BLOCK a1.

AT SELECTION-SCREEN.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD p_bukrs
           ID 'ACTVT' FIELD '03'.
  IF sy-subrc <> 0.
    MESSAGE e398(00) WITH TEXT-e01 p_bukrs space space.
  ENDIF.

START-OF-SELECTION.

**Validamos que la cuenta gestione partida abierta.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE bukrs saknr xopvw INTO (w_bukrs, w_saknr, w_xopvw)
*         FROM skb1
*        WHERE bukrs   EQ p_bukrs
*            AND saknr EQ p_hkont
*            AND xopvw EQ c_x.
*
* NEW CODE
  SELECT bukrs saknr xopvw
  UP TO 1 ROWS  INTO (w_bukrs, w_saknr, w_xopvw)
         FROM skb1
        WHERE bukrs   EQ p_bukrs
            AND saknr EQ p_hkont
            AND xopvw EQ c_x ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc NE 0.
    MESSAGE s398(00) WITH p_hkont '/' p_bukrs
                          ' Sin Gestion de Partidas Abiertas'  DISPLAY LIKE 'E'.
  ELSE.
    SELECT *
    FROM bsis AS b
    INNER JOIN bkpf AS k ON k~bukrs = b~bukrs
                        AND k~belnr = b~belnr
                        AND k~gjahr = b~gjahr
    INTO CORRESPONDING FIELDS OF TABLE it_bsis
    WHERE b~bukrs = p_bukrs
      AND b~hkont = p_hkont
      AND b~belnr = p_belnr
      AND b~gjahr = p_gjahr
      AND b~xopvw = c_x
      AND stblg   <> space. "Anulado
    IF sy-subrc = 0.
      LOOP AT it_bsis INTO DATA(wa_bsis).
        CLEAR wa_bsas.
        MOVE-CORRESPONDING wa_bsis TO wa_bsas.
        wa_bsas-augdt = p_augdt.
        wa_bsas-augbl = p_augbl.
        APPEND wa_bsas TO it_bsas.
      ENDLOOP.

      DELETE bsis FROM TABLE it_bsis.
      IF sy-subrc = 0.
        MODIFY bsas FROM TABLE it_bsas.
        IF sy-subrc = 0.
          MESSAGE s398(00) WITH TEXT-s01 space space space.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
