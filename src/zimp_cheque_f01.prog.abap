*----------------------------------------------------------------------*
***INCLUDE ZIMP_CHEQUE_F01 .
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
  SELECT bukrs orden tdname responsable rfcdest
  INTO CORRESPONDING FIELDS OF TABLE ti_firma
  FROM zfirmadigital WHERE bukrs EQ bukrs
  ORDER BY PRIMARY KEY.
**MOD FIN
  READ TABLE ti_firma INDEX 1.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING ti_firma TO firma1.
  ENDIF.
  READ TABLE ti_firma INDEX 2.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING ti_firma TO firma2.
  ENDIF.
ENDFORM.                    " F_SEL_DATA
*&---------------------------------------------------------------------*
*&      Form  BORRAR_FIRMAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NFIRMA2  text
*----------------------------------------------------------------------*
FORM borrar_firmas  USING    value(firma).


  iname = firma.
  CALL FUNCTION 'SAPSCRIPT_DELETE_GRAPHIC_BDS'
    EXPORTING
      i_object       = 'GRAPHICS'
      i_name         = iname
      i_id           = 'BMAP'
      i_btype        = 'BCOL'
      dialog         = ''
    EXCEPTIONS
      enqueue_failed = 1
      delete_failed  = 2
      not_found      = 3
      canceled       = 4
      OTHERS         = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDFORM.                    " BORRAR_FIRMAS
