*----------------------------------------------------------------------*
***INCLUDE ZFITR001I01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  B_BANKL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE B_BANKL INPUT.
  PERFORM OKCODE_BANK_SUCHEN.
ENDMODULE.                 " B_BANKL  INPUT

*&      Form  OKCODE_BANK_SUCHEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM OKCODE_BANK_SUCHEN.
*  DATA: PROG LIKE SY-REPID,
*        DYNM LIKE SY-DYNNR.
*  DATA: LOC_DYNPREAD  LIKE DYNPREAD   OCCURS 0 WITH HEADER LINE.
*
*  MOVE SY-REPID TO PROG.
*  MOVE SY-DYNNR TO DYNM.
*  LOC_DYNPREAD-FIELDNAME = 'BNKA-BANKS'.
*  APPEND LOC_DYNPREAD.
**  CLEAR: OK-CODE.
*
*  CALL FUNCTION 'DYNP_VALUES_READ'
*    EXPORTING
*      DYNAME             = PROG
*      DYNUMB             = DYNM
*      TRANSLATE_TO_UPPER = 'X'
*    TABLES
*      DYNPFIELDS         = LOC_DYNPREAD
*    EXCEPTIONS
*      OTHERS             = 4.
*
**  IF SY-SUBRC = 0.
**    READ TABLE LOC_DYNPREAD WITH KEY FIELDNAME = 'BNKA-BANKS'.
**    BNKA-BANKS = LOC_DYNPREAD-FIELDVALUE.
**  ENDIF.
*
*  CALL FUNCTION 'SEARCH_BANK_ADDRESS'
*    EXPORTING
*      I_BANKS = 'CL'
*    IMPORTING
*      E_BNKA  = *BNKA.
*
*  IF *BNKA IS INITIAL.
*    SET SCREEN SY-DYNNR.
*    LEAVE SCREEN.
*  ELSE.
*    ZFITR001- = *BNKA.
*  ENDIF.

ENDFORM.                    "okcode_bank_suchen
