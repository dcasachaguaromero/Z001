FUNCTION ZFI_FIRST_PERIOD_CHECK.
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
      TMPMONAT LIKE T001B-FRPE1,
      o_gjahr type gjahr,
      o_monat type monat .
                .
PERIODO = IMONAT.
call function 'FI_PERIOD_DETERMINE'
        exporting
          i_budat              = sy-datum
          i_bukrs              = ibukrs
*         I_RLDNR              = ' '
*         I_PERIV              = ' '
*         I_GJAHR              = 0000
*         I_MONAT              = 00
*         X_XMO16              = ' '
       importing
         e_gjahr              = o_gjahr
         e_monat              = o_monat
*         E_POPER              =
       exceptions
         fiscal_year          = 1
         period               = 2
         period_version       = 3
         posting_period       = 4
         special_period       = 5
         version              = 6
         posting_date         = 7
         others               = 8.
**INS INI
*CHECK ( o_gjahr > igjahr or ( o_gjahr = igjahr and imonat <= o_monat  ) ).
IF NOT (
     o_gjahr > igjahr
  OR ( o_gjahr = igjahr AND imonat <= o_monat )
).
  RETURN.
ENDIF.
**INS FIN
DO.
  IF PERIODO BETWEEN 1 AND 12.
      DO.
        TMPMONAT = PERIODO.
        IF PERIODO > 12.
          EXIT.
        ENDIF.

        CALL FUNCTION 'FI_PERIOD_CHECK'
          EXPORTING
            I_BUKRS                = IBUKRS
*           I_OPVAR                = ' '
            I_GJAHR                = IGJAHR
            I_KOART                = 'K'
            I_KONTO                = '+'
            I_MONAT                = TMPMONAT
*           I_SPERI                =
*           I_RLDNR                =
*           I_GLVOR                = 'RFBU'
*         IMPORTING
*           E_OPER                 =
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
      if OMONAT = periodo and ogjahr = igjahr.
        exit.
      endif.
  ENDIF.
  IF o_gjahr < IGJAHR .
    EXIT.
  ENDIF.
  PERIODO = 1.
  ADD 1 TO IGJAHR.
ENDDO.

ENDFUNCTION.
