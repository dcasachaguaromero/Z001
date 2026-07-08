FUNCTION ZFI_CHECK_ZTERM.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_KOART) LIKE  T052-KOART DEFAULT SPACE
*"     VALUE(I_ZTERM) LIKE  T052-ZTERM
*"  EXPORTING
*"     VALUE(E_T052) LIKE  T052 STRUCTURE  T052
*"  EXCEPTIONS
*"      INVALID_ZTERM
*"--------------------------------------------------------------------

  CLEAR E_T052.
  CHECK NOT I_ZTERM IS INITIAL.

*------- Zahlungsbedingung bereits in XT052 von F4? --------------------
  IF I_KOART CA 'DK'.
    LOOP AT XT052
         WHERE ZTERM = I_ZTERM
         AND   ( KOART = SPACE OR
                 KOART = I_KOART ).
      EXIT.
    ENDLOOP.
  ELSE.
    LOOP AT XT052
         WHERE ZTERM = I_ZTERM.
      EXIT.
    ENDLOOP.
  ENDIF.
  IF SY-SUBRC = 0.
    E_T052 = XT052.
    EXIT.
  ENDIF.

*------- Zahlungsbedingung definiert? ----------------------------------
  IF I_KOART CA 'DK'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM T052
*           WHERE ZTERM = I_ZTERM
*           AND   ( KOART = SPACE OR
*                   KOART = I_KOART ).
*
* NEW CODE
    SELECT *
 FROM T052
           WHERE ZTERM = I_ZTERM
           AND   ( KOART = SPACE OR
                   KOART = I_KOART ) ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      EXIT.
    ENDSELECT.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM T052
*           WHERE ZTERM = I_ZTERM.
*
* NEW CODE
    SELECT *
 FROM T052
           WHERE ZTERM = I_ZTERM ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      EXIT.
    ENDSELECT.
  ENDIF.
  IF SY-SUBRC = 0.
    E_T052 = T052.
  ELSE.
    MESSAGE E409 WITH I_ZTERM RAISING INVALID_ZTERM.
  ENDIF.

ENDFUNCTION.

