*----------------------------------------------------------------------*
***INCLUDE ZIMP_CHEQUE_REVALIDA_F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SEL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sel_data .
**MOD INI
  SELECT BUKRS ORDEN TDNAME RESPONSABLE RFCDEST
    INTO CORRESPONDING FIELDS OF TABLE ti_firma
    FROM zfirmadigital WHERE bukrs EQ bukrs
    ORDER BY PRIMARY KEY.
**MOD FIN
  READ TABLE ti_firma INDEX 3.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING ti_firma TO firma1.
  ENDIF.
*  READ TABLE ti_firma INDEX 2.
*  IF sy-subrc EQ 0.
*    MOVE-CORRESPONDING ti_firma TO firma2.
*  ENDIF.
ENDFORM.                    " F_SEL_DATA
