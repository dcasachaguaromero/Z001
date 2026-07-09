*&---------------------------------------------------------------------*
*& Report  ZFIMODSALDOSCAR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFIMODSALDOSCAR.

tables: febko.

*PARAMETERS: p_ssbtr like febko-ssbtr,
*            p_sumso like febko-sumso,
*            p_sumha like febko-sumha,
*            p_esbtr like febko-esbtr,
*            p_aznum like febko-aznum,
*            p_kukey like febko-kukey.

PARAMETERS: p_ssbtr(15) type n,
            p_sumso(15) type n,
            p_sumha(15) type n,
            p_esbtr(15) type n,
            p_aznum like febko-aznum,
            p_kukey like febko-kukey.

DATA: wa_febko type febko,
      it_febko type STANDARD TABLE OF febko,
      w_lines type i,
      wa_ssbtr like febko-ssbtr,
      wa_sumso like febko-sumso,
      wa_sumha like febko-sumha,
      wa_esbtr like febko-esbtr,
      wa_amountin like WMTO_S-AMOUNT,
      wa_amount like WMTO_S-AMOUNT.

START-OF-SELECTION.

wa_amountin = p_ssbtr.
CALL FUNCTION 'CURRENCY_AMOUNT_DISPLAY_TO_SAP'
  EXPORTING
    CURRENCY              = 'CLP'
    AMOUNT_DISPLAY        = wa_amountin
 IMPORTING
   AMOUNT_INTERNAL       = wa_amount
* EXCEPTIONS
*   INTERNAL_ERROR        = 1
*   OTHERS                = 2
          .
  wa_ssbtr = wa_amount.

  wa_amountin = p_sumso.
  CALL FUNCTION 'CURRENCY_AMOUNT_DISPLAY_TO_SAP'
  EXPORTING
    CURRENCY              = 'CLP'
    AMOUNT_DISPLAY        = wa_amountin
 IMPORTING
   AMOUNT_INTERNAL       = wa_amount
* EXCEPTIONS
*   INTERNAL_ERROR        = 1
*   OTHERS                = 2
          .
  wa_sumso = wa_amount.

  wa_amountin = p_sumha.
  CALL FUNCTION 'CURRENCY_AMOUNT_DISPLAY_TO_SAP'
  EXPORTING
    CURRENCY              = 'CLP'
    AMOUNT_DISPLAY        = wa_amountin
 IMPORTING
   AMOUNT_INTERNAL       = wa_amount
* EXCEPTIONS
*   INTERNAL_ERROR        = 1
*   OTHERS                = 2
          .
  wa_sumha = wa_amount.

  wa_amountin = p_esbtr.
  CALL FUNCTION 'CURRENCY_AMOUNT_DISPLAY_TO_SAP'
  EXPORTING
    CURRENCY              = 'CLP'
    AMOUNT_DISPLAY        = wa_amountin
 IMPORTING
   AMOUNT_INTERNAL       = wa_amount
* EXCEPTIONS
*   INTERNAL_ERROR        = 1
*   OTHERS                = 2
          .
  wa_esbtr = wa_amount.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * from febko CLIENT SPECIFIED into table it_febko
*  where mandt = sy-mandt
*        and aznum = p_aznum
*        and kukey = p_kukey.
*
* NEW CODE
SELECT *
 from febko CLIENT SPECIFIED into table it_febko
  where mandt = sy-mandt
        and aznum = p_aznum
        and kukey = p_kukey ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  DESCRIBE TABLE it_febko LINES w_lines.

  IF w_lines = 1.
    LOOP AT it_febko into wa_febko.
      wa_febko-ssbtr = wa_ssbtr.
      wa_febko-sumso = wa_sumso.
      wa_febko-sumha = wa_sumha.
      wa_febko-esbtr = wa_esbtr.
      UPDATE febko from wa_febko.
    ENDLOOP.
  ENDIF.
