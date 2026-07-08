FUNCTION ZFI_PRINT_ZTERM.
*"--------------------------------------------------------------------
*"*"Interfase global
*"  IMPORTING
*"     VALUE(I_ZTERM) LIKE  T052-ZTERM OPTIONAL
*"     VALUE(I_LANGU) LIKE  SY-LANGU DEFAULT SY-LANGU
*"     VALUE(I_XT052U) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"     VALUE(I_T052) LIKE  T052 STRUCTURE  T052 OPTIONAL
*"  TABLES
*"      T_ZTEXT STRUCTURE  TTEXT
*"  EXCEPTIONS
*"      ZTERM_NOT_FOUND
*"--------------------------------------------------------------------

*------- Initialisierung -----------------------------------------------
  REFRESH T_ZTEXT.
  CLEAR T_ZTEXT.
  SET LANGUAGE I_LANGU.

*------- I_ZTERM gefüllt ==> Beschreibung aus T052/T052U ermitteln -----
  IF NOT I_ZTERM IS INITIAL.

*------- ... XT052 ggf. um I_ZTERM erweitern ---------------------------
    LOOP AT XT052
         WHERE ZTERM = I_ZTERM.
      EXIT.
    ENDLOOP.
    IF SY-SUBRC <> 0.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM T052 APPENDING TABLE XT052
*             WHERE ZTERM = I_ZTERM.
*
* NEW CODE
      SELECT *
 FROM T052 APPENDING TABLE XT052
             WHERE ZTERM = I_ZTERM ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      IF SY-SUBRC <> 0.
        MESSAGE E410 WITH I_ZTERM RAISING ZTERM_NOT_FOUND.
      ENDIF.
    ENDIF.

*------- ... ZBTXT füllen ----------------------------------------------
    PERFORM ZBTXT_FUELLEN_PRINT.

*------- I_ZTERM nicht gefüllt ==> Beschreibung aus I_T052 ermitteln
*        bzw. EXIT (vgl. Problem 1031325/1996)
  ELSEIF NOT I_T052 IS INITIAL.
    REFRESH ZBTXT.
    CLEAR ZBTXT.
    XT052 = I_T052.
    PERFORM ZTEXT_ERMITTELN_PRINT USING ZBTXT-ZTEXT.
  ELSE.
    EXIT.
  ENDIF.

*------- T_ZTEXT füllen ------------------------------------------------
  LOOP AT ZBTXT.
    T_ZTEXT-TEXT1 = ZBTXT-ZTEXT.
    APPEND T_ZTEXT.
  ENDLOOP.

ENDFUNCTION.
