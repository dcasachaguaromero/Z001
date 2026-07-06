*----------------------------------------------------------------------*
***INCLUDE LZFICO_REP05I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MUEVE_DATOS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mueve_datos INPUT.

  MOVE : sy-datum TO zfico_rep05-datum ,
         sy-uzeit TO zfico_rep05-uzeit ,
         sy-uname TO zfico_rep05-uname .
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDA_CLAVE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida_clave INPUT.
  IF zfico_rep05-clave GT 15.
    MESSAGE e899(fi) WITH 'Máximo 15 posiciones'.
  ELSEIF zfico_rep05-clave EQ 0.
    MESSAGE e899(fi) WITH 'Debe tener un valor entre 1 a 15' .
  ENDIF.
ENDMODULE.
