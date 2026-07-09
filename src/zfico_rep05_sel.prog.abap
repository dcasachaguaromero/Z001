*&---------------------------------------------------------------------*
*&  Include           ZFICO_REP04_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : s_bukrs FOR wa_select-bukrs NO-DISPLAY,
                 s_budat FOR wa_select-budat OBLIGATORY,
                 s_gjahr FOR wa_select-gjahr NO-EXTENSION NO INTERVALS
*                                             DEFAULT sy-datum(4)
                                             NO-DISPLAY,
                 s_hkont FOR wa_select-hkont,
                 s_kostl FOR wa_select-kostl MATCHCODE OBJECT ehswah_kost,
                 s_stcd1 FOR wa_select-stcd1 MATCHCODE OBJECT kred_c.
SELECTION-SCREEN SKIP.
PARAMETERS : p_local RADIOBUTTON GROUP uno DEFAULT 'X',
             p_docum RADIOBUTTON GROUP uno,
             p_socie RADIOBUTTON GROUP uno.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(25)    TEXT-m01 MODIF ID azu.
SELECTION-SCREEN PUSHBUTTON 45(25) but1 USER-COMMAND opc.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK a2.
SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.
  PERFORM autorizacion.

AT SELECTION-SCREEN.
  IF sy-ucomm EQ 'OPC'.
    PERFORM tabla_param.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  CONCATENATE icon_parameter TEXT-but
               INTO but1 SEPARATED BY space.

*AT SELECTION-SCREEN ON s_bukrs.
*
*  CLEAR gt_t001[].
*  SELECT bukrs waers INTO TABLE gt_t001
*         FROM t001 WHERE bukrs IN s_bukrs.
*  LOOP AT gt_t001 INTO DATA(ls_t001).
*    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*           ID 'BUKRS' FIELD ls_t001-bukrs
*           ID 'ACTVT' FIELD '03'.    "Visualizar
*    IF sy-subrc <> 0.
**     Ud. carece de autorización para la sociedad &.
*      DELETE gt_t001 INDEX sy-tabix.
*    ENDIF.
*  ENDLOOP.
**
*  IF  gt_t001[] IS INITIAL.
*    MESSAGE e898(f5) WITH 'Sin permisos para ver Sociedades'.
*    LEAVE PROGRAM.
*  ENDIF.
