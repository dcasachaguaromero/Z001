*&---------------------------------------------------------------------*
*& Report  ZFIMODIF_BSIS
*&
*&---------------------------------------------------------------------*
*& Programa para modificar tabla BSIS solo algunos registros
*&
*&---------------------------------------------------------------------*

INCLUDE zfimodif_bsis_top                       .    "  global Data

* INCLUDE ZFIMODIF_BSIS_O01                       .  " PBO-Modules
* INCLUDE ZFIMODIF_BSIS_I01                       .  " PAI-Modules
* INCLUDE ZFIMODIF_BSIS_F01                       .  " FORM-Routines

START-OF-SELECTION.

SELECT SINGLE bukrs saknr xopvw INTO (w_bukrs, w_saknr, w_xopvw)
       FROM skb1
      WHERE bukrs   EQ p_bukrs
          AND saknr EQ p_hkont
          AND xopvw EQ 'X'.

IF sy-subrc NE 0.
  MESSAGE s398(00) WITH p_hkont '/' p_bukrs
                        ' Sin Gestion de Partidas Abiertas'  DISPLAY LIKE 'E'.
  EXIT.
ENDIF.

SELECT b~bukrs b~hkont b~gjahr b~belnr b~buzei b~xopvw
    FROM bsis as b
    INNER JOIN bkpf as k on k~bukrs = b~bukrs
                        and k~belnr = b~belnr
                        and k~gjahr = b~gjahr
    INTO CORRESPONDING FIELDS OF TABLE it_bsis
    WHERE b~bukrs EQ p_bukrs
      AND b~hkont EQ p_hkont
      AND b~gjahr EQ p_gjahr
      AND b~xopvw EQ ' '
      and stblg   = space. "No anulado

IF sy-subrc NE 0.
  MESSAGE s398(00) WITH 'No hay partidas a Selecionar de tabla BSIS'
                   DISPLAY LIKE 'E'.
  EXIT.
ENDIF.

LOOP AT it_bsis.
  UPDATE bsis SET xopvw = 'X'
    WHERE bukrs     = p_bukrs
          AND hkont = p_hkont
          AND gjahr = p_gjahr
          AND xopvw = ' '.
ENDLOOP.

MESSAGE 'Los datos han sido actualizados' TYPE 'I'.
LEAVE PROGRAM.
