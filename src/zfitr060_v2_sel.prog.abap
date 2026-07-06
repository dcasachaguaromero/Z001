*&---------------------------------------------------------------------*
*&  Include           ZFITR060_V2_SEL
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_bukrs  TYPE bukrs OBLIGATORY.
SELECT-OPTIONS: s_idpago FOR znovedadbanco-identif  OBLIGATORY .
PARAMETERS: p_fecha  TYPE sydatum DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK b1.


*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON s_idpago.

  CLEAR: gv_subrc.

  SELECT FROM reguh FIELDS identif_pago, rzawe
    WHERE identif_pago IN @s_idpago
    INTO TABLE @DATA(gt_reguh_sel).

  IF gt_reguh_sel[] IS INITIAL.
*   No se encontraron registros para los identificadores ingresados
    MESSAGE e021(zfi).
    RETURN.
  ENDIF.

  LOOP AT gt_reguh_sel ASSIGNING FIELD-SYMBOL(<ls_reguh_sel>).
    IF <ls_reguh_sel>-identif_pago+0(4) <> p_bukrs.
*     ID de pago & no corresponde a la sociedad &
      MESSAGE e022(zfi) WITH <ls_reguh_sel>-identif_pago p_bukrs.
      gv_subrc = 8.
      EXIT.
    ENDIF.

    IF <ls_reguh_sel>-identif_pago+4(3) <> '037'.
      MESSAGE e004(zfi) WITH 'ID de pago no es de SANTANDER'.
      gv_subrc = 8.
      EXIT.
    ENDIF.

    IF <ls_reguh_sel>-rzawe <> 'V'.
      MESSAGE e004(zfi) WITH 'ID de pago no corresponde a Vale Vista'.
      gv_subrc = 8.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF gv_subrc <> 0.
    LEAVE PROGRAM.
  ENDIF.
