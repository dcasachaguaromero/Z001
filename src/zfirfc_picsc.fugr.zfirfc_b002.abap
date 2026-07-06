FUNCTION ZFIRFC_B002.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(IBUKRS) TYPE  BUKRS
*"     VALUE(IGJAHR) TYPE  GJAHR
*"     VALUE(IMONAT) TYPE  MONAT
*"  EXPORTING
*"     VALUE(OGJAHR) TYPE  GJAHR
*"     VALUE(OMONAT) TYPE  MONAT
*"----------------------------------------------------------------------

DATA: PERIODO TYPE I,
      TMPMONAT LIKE T001B-FRPE1.
                .
PERIODO = IMONAT.
IF PERIODO BETWEEN 1 AND 12.
    DO.
      TMPMONAT = PERIODO.
      IF PERIODO > 12.
        EXIT.
      ENDIF.

      CALL FUNCTION 'FI_PERIOD_CHECK'
        EXPORTING
          I_BUKRS                = IBUKRS
*         I_OPVAR                = ' '
          I_GJAHR                = IGJAHR
          I_KOART                = 'K'
          I_KONTO                = '+'
          I_MONAT                = TMPMONAT
*         I_SPERI                =
*         I_RLDNR                =
*         I_GLVOR                = 'RFBU'
*       IMPORTING
*         E_OPER                 =
       EXCEPTIONS
         ERROR_PERIOD           = 1
         ERROR_PERIOD_ACC       = 2
         INVALID_INPUT          = 3
         OTHERS                 = 4
                .
      IF SY-SUBRC = 0.
        OMONAT = PERIODO.
        OGJAHR = IGJAHR.
        EXIT.
      ENDIF.
      ADD 1 TO PERIODO.
    ENDDO.
ENDIF.
ENDFUNCTION.
