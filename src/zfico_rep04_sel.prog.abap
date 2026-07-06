*&---------------------------------------------------------------------*
*&  Include           ZFICO_REP04_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : s_budat FOR wa_select-budat OBLIGATORY NO-EXTENSION,
                 s_gjahr FOR wa_select-gjahr NO-EXTENSION NO INTERVALS
*                                             DEFAULT sy-datum(4)
                                             NO-DISPLAY,
                 s_bukrs FOR wa_select-bukrs OBLIGATORY,
                 s_hkont FOR wa_select-hkont,
                 s_kostl FOR wa_select-kostl MATCHCODE OBJECT ehswah_kost,
                 s_stcd1 FOR wa_select-stcd1 MATCHCODE OBJECT kred_c.
SELECTION-SCREEN SKIP.
PARAMETERS : p_local RADIOBUTTON GROUP uno DEFAULT 'X',
             p_docum RADIOBUTTON GROUP uno,
             p_socie RADIOBUTTON GROUP uno.
SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.
  PERFORM autorizacion.

AT SELECTION-SCREEN ON s_bukrs.

  CLEAR gt_t001[].
  SELECT bukrs waers INTO TABLE gt_t001
         FROM t001 WHERE bukrs IN s_bukrs.
  LOOP AT gt_t001 INTO DATA(ls_t001).
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD ls_t001-bukrs
           ID 'ACTVT' FIELD '03'.    "Visualizar
    IF sy-subrc <> 0.
*     Ud. carece de autorización para la sociedad &.
      MESSAGE e460(f5) WITH ls_t001-bukrs.
      LEAVE PROGRAM.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON BLOCK block1.

  PERFORM valida_fechas.
