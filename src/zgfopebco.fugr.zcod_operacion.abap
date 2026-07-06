FUNCTION ZCOD_OPERACION.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_CBANCO) TYPE  BANKK
*"     VALUE(I_CBUSQ) TYPE  ZCONDINI
*"     VALUE(I_MOVBCO) TYPE  SIGN
*"     VALUE(I_DESC) TYPE  CHAR100
*"  EXPORTING
*"     VALUE(E_CODIGO) TYPE  BANKL
*"----------------------------------------------------------------------

DATA: IT_ZOPEBCO TYPE STANDARD TABLE OF ZOPEBCO,
      WA_ZOPEBCO TYPE ZOPEBCO,
      w_len type i.

  SELECT * FROM ZOPEBCO CLIENT SPECIFIED
    INTO TABLE IT_ZOPEBCO
    WHERE MANDT EQ SY-MANDT
          AND CBANCO EQ I_CBANCO
          AND CBUSQ EQ I_CBUSQ
          AND MOVBCO EQ I_MOVBCO
    ORDER BY SBUSQ ASCENDING.
  CLEAR w_len.
  LOOP AT IT_ZOPEBCO INTO WA_ZOPEBCO.
    IF I_DESC CS WA_ZOPEBCO-SBUSQ.
      IF w_len < strlen( WA_ZOPEBCO-SBUSQ ).
        w_len = strlen( WA_ZOPEBCO-SBUSQ ).
        E_CODIGO = WA_ZOPEBCO-CODIGO.
      ENDIF.
    ENDIF.
  ENDLOOP.
    IF E_CODIGO IS INITIAL.
      E_CODIGO = '0000'.
    ENDIF.

ENDFUNCTION.
