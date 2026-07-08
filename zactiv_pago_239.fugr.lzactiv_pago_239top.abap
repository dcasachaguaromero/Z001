FUNCTION-POOL ZACTIV_PAGO_239.              "MESSAGE-ID ..

DATA: bdcdata TYPE STANDARD TABLE OF bdcdata WITH HEADER LINE.
DATA: messtab TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE.
DATA: w_mode." value 'N'.
DATA: tcode TYPE C LENGTH 10."string value 'MP38'.
*&---------------------------------------------------------------------*
*&      Form  BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0084   text
*      -->P_0085   text
*      -->P_0086   text
*----------------------------------------------------------------------*
FORM bdc  USING    a
      b
      C.

  CLEAR bdcdata.
  IF a = 'X'.
    bdcdata-PROGRAM   = b.
    bdcdata-DYNPRO    = C.
    bdcdata-dynbegin  = a.
  ELSE.
    bdcdata-fnam = b.
    WRITE C TO bdcdata-fval LEFT-JUSTIFIED.
  ENDIF.
  APPEND bdcdata.

ENDFORM.                    "bdc
