FUNCTION ZFI_TEXT_ZTERM.
*"--------------------------------------------------------------------
*"*"Interfase global
*"  IMPORTING
*"     VALUE(I_T052) LIKE  T052 STRUCTURE  T052
*"  TABLES
*"      T_ZTEXT STRUCTURE  TTEXT
*"--------------------------------------------------------------------

*------- Initialisierung -----------------------------------------------
  REFRESH T_ZTEXT.
  CLEAR T_ZTEXT.
  XT052 = I_T052.

*------- EXIT, falls I_T052 initial ------------------------------------
  CHECK NOT I_T052 IS INITIAL.

*------- ZBTXT füllen --------------------------------------------------
  PERFORM ZBTXT_FUELLEN_TEXT.

*------- T_ZTEXT füllen ------------------------------------------------
  LOOP AT ZBTXT.
    IF  ZBTXT-ZTEXT(1) = SPACE
    AND ZBTXT-ZTEXT <> SPACE.
      WHILE ZBTXT-ZTEXT(1) = SPACE.
        SHIFT ZBTXT-ZTEXT.
      ENDWHILE.
    ENDIF.
    T_ZTEXT-TEXT1 = ZBTXT-ZTEXT.
    APPEND T_ZTEXT.
  ENDLOOP.

ENDFUNCTION.
