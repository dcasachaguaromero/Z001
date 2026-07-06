*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <27-12-2019> *
*& Transport Number: < ECDK916974 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           J_CL_BALANCE_SHEET_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN
*&---------------------------------------------------------------------*
* Subroutine to modify LDB selection screen for unused parameters.
*----------------------------------------------------------------------*
FORM MODIFY_SCREEN .

* Eliminate unused screen selections
  LOOP AT SCREEN.

    IF     SCREEN-GROUP3 = 'IXS'
       OR  SCREEN-GROUP4 = '005'
       OR  SCREEN-GROUP4 = '020'
       OR  ( SCREEN-GROUP3 = 'VPU' AND SCREEN-GROUP4 = '007' )
*       OR  SCREEN-GROUP4 = '023'                                            'Note 1058932
       OR  SCREEN-NAME   = 'SD_BUKRS-HIGH'.
* Fields for no display
      SCREEN-ACTIVE = 0.
    ELSEIF     SCREEN-NAME = 'SD_BUKRS-LOW'.
* Fields for display
      SCREEN-REQUIRED = 1.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                               " MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  GET_COMPANY_DATA
*&---------------------------------------------------------------------*
* Subroutine to get company code data.
*----------------------------------------------------------------------*
FORM GET_COMPANY_DATA .

*Select data from T001 table.
  CLEAR: GS_T001.
  SELECT SINGLE BUKRS BUTXT WAERS ADRNR FROM T001
                INTO (GS_T001-BUKRS, GS_T001-BUTXT, GS_T001-WAERS,
                      GS_T001-ADRNR)
                WHERE BUKRS = SD_BUKRS-LOW.

  CHECK SY-SUBRC = 0.

ENDFORM.                               " GET_COMPANY_DATA

*&---------------------------------------------------------------------*
*&      Form  FILL_ITAB
*&---------------------------------------------------------------------*
* Subroutine used to fill output table with G/L accounts.
*----------------------------------------------------------------------*
FORM FILL_OUTPUT_TABLE TABLES RT_OUTTAB LIKE GT_OUTPUT[].   "#EC NEEDED

  GS_OUTPUT-BUKRS = SKB1-BUKRS.
  GS_OUTPUT-SAKNR = SKA1-SAKNR.
  GS_OUTPUT-TXT50 = SKAT-TXT50.
  GS_OUTPUT-HWAER = GS_T001-WAERS.
  GS_OUTPUT-XBILK = SKA1-XBILK.

  APPEND GS_OUTPUT TO RT_OUTTAB.
  CLEAR: GS_OUTPUT.

ENDFORM.                               " FILL_ITAB

*&---------------------------------------------------------------------*
*&      Form  FILL_RANGE_R_DATE
*&---------------------------------------------------------------------*
* Fill range table for the posting date.
*----------------------------------------------------------------------*
FORM FILL_RANGE_R_DATE .

  CLEAR: GV_LOWDATE1.
  CONCATENATE SD_GJAHR-LOW GC_01 GC_01 INTO GV_LOWDATE1.

  R_DATE-SIGN   = 'I'.
  R_DATE-OPTION = 'BT'.
  R_DATE-LOW    = GV_LOWDATE1.
  R_DATE-HIGH   = P_DATE.
  APPEND R_DATE.

ENDFORM.                               " FILL_RANGE_R_DATE

*&---------------------------------------------------------------------*
*&      Form  CORRECTION_OUTPUT_LIST
*&---------------------------------------------------------------------*
* Subroutine to get correct data from BKPF & BSEG tables From the day
* first of the reported fiscal year To the selected posting date on the
* selection screen.
*----------------------------------------------------------------------*
FORM CORRECTION_OUTPUT_LIST.

* Subroutine to get data from BKPF table.
  PERFORM GET_BKPF_DATA.

  REFRESH: GT_BSEG.
  CLEAR: REC_BSEG.
  IF NOT GT_BKPF[] IS INITIAL.
* Subroutine to get data from BSEG table.
    PERFORM GET_BSEG_DATA.
  ENDIF.
  REFRESH: GT_BKPF, GT_BSEG .
  CLEAR: REC_BSEG.

* Subroutine to modify final table based on selection from BKPF & BSEG
  PERFORM CORRECT_LIST.

ENDFORM.                               " CORRECTION_OUTPUT_LIST

*&---------------------------------------------------------------------*
*&      Form  GET_BKPF_DATA
*&---------------------------------------------------------------------*
* Subroutine to get data from BKPF table.
*----------------------------------------------------------------------*
FORM GET_BKPF_DATA.

  REFRESH: GT_BKPF.

  SELECT  BUKRS BELNR GJAHR BUDAT LDGRP BSTAT FROM BKPF
          INTO TABLE GT_BKPF
          WHERE BUKRS = SD_BUKRS-LOW
          AND   GJAHR = SD_GJAHR-LOW
*          AND BSTAT EQ SPACE              " note 935448
          AND   BUDAT IN R_DATE.

  IF SY-SUBRC <> 0.
*No records have been found for the selection specified
    MESSAGE S130.
    STOP.
  ENDIF.

ENDFORM.                               " GET_BKPF_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_BSEG_DATA
*&---------------------------------------------------------------------*
* Subroutine to get data from BSEG table.
*----------------------------------------------------------------------*
FORM GET_BSEG_DATA.
  data gt_bseg2 type bseg_add.
  data w_bseg2 like LINE OF gt_bseg.
  data w_bseg3 like LINE OF gt_bseg.
  data w_bkpf2 like LINE OF gt_bkpf.
  data gt_bseg3 like gt_bseg.


  if sd_rldnr is initial.
       sd_rldnr-low = '0L'.
  endif.
  LOOP AT gt_bkpf INTO w_bkpf2.
    IF W_BKPF2-BSTAT EQ SPACE AND W_BKPF2-ldgrp EQ SPACE.
      SELECT BUKRS BELNR GJAHR BUZEI HKONT SHKZG DMBTR FROM BSEG into TABLE gt_bseg3
      WHERE BUKRS = W_BKPF2-BUKRS
      AND   BELNR = W_BKPF2-BELNR
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916974*
*      AND   GJAHR = W_BKPF2-GJAHR.
      AND   GJAHR = W_BKPF2-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916974*
        IF sy-subrc eq 0.
          LOOP AT gt_bseg3 into w_bseg3.
            move: gt_bseg2-BUKRS to w_bseg2-bukrs,
              w_bseg3-BELNR to w_bseg2-BELNR,
              w_bseg3-GJAHR to w_bseg2-GJAHR,
              w_bseg3-BUZEI to w_bseg2-BUZEI,
              w_bseg3-HKONT to w_bseg2-HKONT,
              w_bseg3-SHKZG to w_bseg2-SHKZG,
              w_bseg3-DMBTR to w_bseg2-DMBTR.
            APPEND w_bseg2 to gt_bseg.
          ENDLOOP.
        ENDIF.

    ELSEIF W_BKPF2-ldgrp eq sd_rldnr-low.
      SELECT * from bseg_add into gt_bseg2
      where BUKRS = w_bkpf2-BUKRS
            AND   BELNR = w_bkpf2-BELNR
            AND   GJAHR = w_bkpf2-GJAHR.
          move: gt_bseg2-BUKRS to w_bseg2-bukrs,
                gt_bseg2-BELNR to w_bseg2-BELNR,
                gt_bseg2-GJAHR to w_bseg2-GJAHR,
                gt_bseg2-BUZEI to w_bseg2-BUZEI,
                gt_bseg2-HKONT to w_bseg2-HKONT,
                gt_bseg2-SHKZG to w_bseg2-SHKZG,
                gt_bseg2-DMBTR to w_bseg2-DMBTR.
            APPEND w_bseg2 to gt_bseg.
       endselect.
       IF sy-subrc ne 0.
         SELECT BUKRS BELNR GJAHR BUZEI HKONT SHKZG DMBTR FROM BSEG into TABLE gt_bseg3
          WHERE BUKRS = W_BKPF2-BUKRS
          AND   BELNR = W_BKPF2-BELNR
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916974*
*      AND   GJAHR = W_BKPF2-GJAHR.
      AND   GJAHR = W_BKPF2-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916974*
            IF sy-subrc eq 0.
              LOOP AT gt_bseg3 into w_bseg3.
                move: gt_bseg2-BUKRS to w_bseg2-bukrs,
                  w_bseg3-BELNR to w_bseg2-BELNR,
                  w_bseg3-GJAHR to w_bseg2-GJAHR,
                  w_bseg3-BUZEI to w_bseg2-BUZEI,
                  w_bseg3-HKONT to w_bseg2-HKONT,
                  w_bseg3-SHKZG to w_bseg2-SHKZG,
                  w_bseg3-DMBTR to w_bseg2-DMBTR.
                APPEND w_bseg2 to gt_bseg.
              ENDLOOP.
            ENDIF.
       ENDIF.
     ENDIF.
  ENDLOOP.

  IF SY-SUBRC = 0.
    SORT GT_BSEG BY HKONT SHKZG ASCENDING.
* Subroutine to collect data from BSEG table into another internal table
    PERFORM COLLECT_BSEG.
  ELSE.
*No records have been found for the selection specified
    MESSAGE S130.
    STOP.
  ENDIF.

ENDFORM.                               " GET_BSEG_DATA

*&---------------------------------------------------------------------*
*&      Form  collect_bseg
*&---------------------------------------------------------------------*
* Subroutine to collect data from BSEG table.
*----------------------------------------------------------------------*
FORM COLLECT_BSEG.

  REFRESH: GT_WORK.
  CLEAR: REC_WORK,
         REC_BSEG.

  LOOP AT GT_BSEG INTO REC_BSEG.

    REC_WORK-HKONT = REC_BSEG-HKONT.
    REC_WORK-SHKZG = REC_BSEG-SHKZG.
    REC_WORK-DMBTR = REC_BSEG-DMBTR.

    COLLECT REC_WORK INTO GT_WORK.

    CLEAR: REC_WORK,
           REC_BSEG.
  ENDLOOP.
ENDFORM.                               " collect_bseg

*&---------------------------------------------------------------------*
*&      Form  CORRECT_LIST
*&---------------------------------------------------------------------*
* Correct the final internal table using selected data from BKPF & BSEG.
*----------------------------------------------------------------------*
FORM CORRECT_LIST.
  TABLES FAGLFLEXT.
  DATA : LT_GLT0 TYPE TABLE OF GLT0,
       LS_GLT0 LIKE GLT0,
       LT_FAGLFLEXT TYPE TABLE OF FAGLFLEXT,
       LS_FAGLFLEXT LIKE FAGLFLEXT,
       L_BAL_CARRY TYPE JDEBIT.

  CLEAR: GS_OUTPUT,
          REC_WORK,
          GV_INDEX.

  LOOP AT GT_OUTPUT INTO GS_OUTPUT.

    GV_INDEX = SY-TABIX.

*    SELECT * FROM GLT0 INTO TABLE LT_GLT0
*            WHERE RLDNR = '00'
*            AND BUKRS = SD_BUKRS-LOW
*            AND RYEAR = SD_GJAHR-LOW
*            AND RACCT = GS_OUTPUT-SAKNR.
     IF SD_RLDNR IS INITIAL.
       SD_RLDNR-LOW = '0L'.
     ENDIF.
     SELECT * FROM FAGLFLEXT INTO TABLE LT_FAGLFLEXT
        WHERE RBUKRS = SD_BUKRS-LOW and
              RYEAR  = SD_GJAHR-LOW and
              RACCT  = GS_OUTPUT-SAKNR and
              RLDNR  = SD_RLDNR-LOW.
*  and RTCUR =
*    SORT LT_GLT0 BY RLDNR BUKRS RYEAR RACCT DRCRK.
    SORT LT_FAGLFLEXT BY RLDNR RBUKRS RYEAR RACCT DRCRK.
*    LOOP AT LT_GLT0 INTO LS_GLT0.
*      IF LS_GLT0-DRCRK = 'S'.
**       l_bal_carry = ls_glt0-tslvt + l_bal_carry.
*        L_BAL_CARRY = LS_GLT0-HSLVT + L_BAL_CARRY."local cur note 919086
*      ELSE.
**       l_bal_carry = ls_glt0-tslvt.
*        L_BAL_CARRY =  L_BAL_CARRY + LS_GLT0-HSLVT.    " note 919086
*      ENDIF.
*
*    ENDLOOP.
    CLEAR LS_FAGLFLEXT.
    LOOP AT LT_FAGLFLEXT INTO LS_FAGLFLEXT.
      IF LS_FAGLFLEXT-DRCRK = 'S'.
*       l_bal_carry = ls_glt0-tslvt + l_bal_carry.
        L_BAL_CARRY = LS_FAGLFLEXT-HSLVT + L_BAL_CARRY."local cur note 919086
      ELSE.
*       l_bal_carry = ls_glt0-tslvt.
        L_BAL_CARRY =  L_BAL_CARRY + LS_FAGLFLEXT-HSLVT.    " note 919086
      ENDIF.

    ENDLOOP.

*Modificacion Herman Balance
    LOOP AT GT_WORK INTO REC_WORK WHERE HKONT = GS_OUTPUT-SAKNR.

      IF REC_WORK-SHKZG = 'S'.
*Sum of the initial balance on the debit side and total of the debit
*postings for every G/L account
        GS_OUTPUT-SUMME_SOLL = REC_WORK-DMBTR.
      ELSE.
*Sum of the initial balance on the credit side and total of the credit
*postings for every G/L account
        GS_OUTPUT-SUMME_HABEN = REC_WORK-DMBTR.
      ENDIF.

    ENDLOOP.
*Fin Modificacion Herman Balance

    IF L_BAL_CARRY < 0.
      GS_OUTPUT-SUMME_HABEN = GS_OUTPUT-SUMME_HABEN + L_BAL_CARRY * -1.
*      GS_OUTPUT-SUMME_HABEN = L_BAL_CARRY * -1.
    ELSE.
      GS_OUTPUT-SUMME_SOLL = GS_OUTPUT-SUMME_SOLL + L_BAL_CARRY.
*      GS_OUTPUT-SUMME_SOLL = L_BAL_CARRY.
*    ELSEIF LS_FAGLFLEXT IS NOT INITIAL.
*      GS_OUTPUT-SUMME_SOLL = 0.
*      GS_OUTPUT-SUMME_HABEN = 0.
    ENDIF.

*Debit/Credit Subtotals
    ST_SUMME_SOLL = ST_SUMME_SOLL + GS_OUTPUT-SUMME_SOLL.
    ST_SUMME_HABEN = ST_SUMME_HABEN + GS_OUTPUT-SUMME_HABEN.

*Subroutine to calculate other balances.
    PERFORM OTHER_BALANCES.
*Modify Final ALV table with correct values.
    MODIFY GT_OUTPUT FROM GS_OUTPUT INDEX GV_INDEX
    TRANSPORTING SUMME_SOLL SUMME_HABEN SALDO_ENDE_SOLL
                 SALDO_ENDE_HABEN BESTANDKONTO BESTANDKONTO_PASSIV
                 ERFOLG_AUFWAND ERFOLG_ERTRAG.

    CLEAR: GS_OUTPUT,
           REC_WORK,
           GV_INDEX.
    CLEAR: L_BAL_CARRY.             "Note 937424
  ENDLOOP.

ENDFORM.                               " CORRECT_LIST

*&---------------------------------------------------------------------*
*&      Form  OTHER_BALANCES
*&---------------------------------------------------------------------*
* Subroutine to fill rows for other balance columns.
*----------------------------------------------------------------------*
FORM OTHER_BALANCES.

*Debit Balance
  CLEAR: SALDO_ENDE_SOLL, SALDO_ENDE_HABEN.

  CLEAR: V_DIFF.

*Debit balance that should be filled with the difference (absolute
*value) between credits and debits, if debits - credits > 0.
*Credit balance that should be filled with same difference (absolute
*value), but only if debits - credits < 0.
  V_DIFF = GS_OUTPUT-SUMME_SOLL - GS_OUTPUT-SUMME_HABEN.
  IF V_DIFF >= 0.
    SALDO_ENDE_SOLL = V_DIFF.
  ELSEIF V_DIFF <= 0.
    V_DIFF = V_DIFF * -1.
    SALDO_ENDE_HABEN = V_DIFF.
  ENDIF.

  ST_SALDO_ENDE_SOLL = ST_SALDO_ENDE_SOLL + SALDO_ENDE_SOLL.
  GS_OUTPUT-SALDO_ENDE_SOLL = SALDO_ENDE_SOLL.

*Credit Balance
  ST_SALDO_ENDE_HABEN = ST_SALDO_ENDE_HABEN + SALDO_ENDE_HABEN.
  GS_OUTPUT-SALDO_ENDE_HABEN = SALDO_ENDE_HABEN.

*Assets
*Check the type of account from master data. If it is balance sheet
*account, then transfer debit balance into Asset account.
  CLEAR: BESTANDKONTO.
  IF GS_OUTPUT-XBILK = 'X'.
    BESTANDKONTO = SALDO_ENDE_SOLL.

  ENDIF.
  ST_BESTANDKONTO = ST_BESTANDKONTO + BESTANDKONTO.
  GS_OUTPUT-BESTANDKONTO = BESTANDKONTO.

*Liabilities
*Check the type of account from master data. If it is balance sheet
*account, then transfer credit balance into Liability account.
  CLEAR: BESTANDKONTO_PASSIV.
  IF GS_OUTPUT-XBILK = 'X'.
    BESTANDKONTO_PASSIV = SALDO_ENDE_HABEN.

  ENDIF.
  ST_BESTANDKONTO_PASSIV = ST_BESTANDKONTO_PASSIV + BESTANDKONTO_PASSIV.
  GS_OUTPUT-BESTANDKONTO_PASSIV = BESTANDKONTO_PASSIV.

*Loss
*Check the type of account from master data. If it is Profit & Loss
*account, then transfer debit balance into Loss account.
  CLEAR: ERFOLG_AUFWAND.
  IF GS_OUTPUT-XBILK = ' '.
    ERFOLG_AUFWAND = SALDO_ENDE_SOLL.

  ENDIF.
  ST_ERFOLG_AUFWAND = ST_ERFOLG_AUFWAND + ERFOLG_AUFWAND.
  GS_OUTPUT-ERFOLG_AUFWAND = ERFOLG_AUFWAND.

*Profit
*Check the type of account from master data. If it is Profit & Loss
*account, then transfer credit balance into Profit account.
  CLEAR: ERFOLG_ERTRAG.
  IF GS_OUTPUT-XBILK = ' '.
    ERFOLG_ERTRAG = SALDO_ENDE_HABEN.

  ENDIF.
  ST_ERFOLG_ERTRAG = ST_ERFOLG_ERTRAG + ERFOLG_ERTRAG.
  GS_OUTPUT-ERFOLG_ERTRAG = ERFOLG_ERTRAG.

ENDFORM.                               " OTHER_BALANCES

*&---------------------------------------------------------------------*
*&      Form  ADD_TOTALS
*&---------------------------------------------------------------------*
* Subroutine to display Totals at the end of the report.
*----------------------------------------------------------------------*
FORM ADD_TOTALS.

*Subtotals: summarization of the amounts contained in each of the
*following columns: debits, credits, debit balance, credit balance,
*asset, liabilities, profit and loss.
  GS_OUTPUT-BUKRS = ' '.
  GS_OUTPUT-SAKNR = ' '.
  GS_OUTPUT-TXT50 = TEXT-002.
  GS_OUTPUT-SUMME_SOLL = ST_SUMME_SOLL.
  GS_OUTPUT-SUMME_HABEN = ST_SUMME_HABEN.
  GS_OUTPUT-SALDO_ENDE_SOLL = ST_SALDO_ENDE_SOLL.
  GS_OUTPUT-SALDO_ENDE_HABEN = ST_SALDO_ENDE_HABEN.
  GS_OUTPUT-BESTANDKONTO = ST_BESTANDKONTO.
  GS_OUTPUT-BESTANDKONTO_PASSIV = ST_BESTANDKONTO_PASSIV.
  GS_OUTPUT-ERFOLG_AUFWAND = ST_ERFOLG_AUFWAND.
  GS_OUTPUT-ERFOLG_ERTRAG = ST_ERFOLG_ERTRAG.
  GS_OUTPUT-HWAER = GS_T001-WAERS.
  APPEND GS_OUTPUT TO GT_OUTPUT.

*Fiscal Year Profit(loss): the difference between the total profit and
*total loss amounts.
*If loss  profit > 0, the difference should appear in the profit column
*If loss  profit < 0, the difference should appear in the loss column.
*The difference between profit and loss should be carried forward to the
*assets or liabilities column as follows:
*If the difference between loss and profit appears in the profit column,
*the same difference should be carried forward to the assets column.
*If the difference between loss and profit appears in the loss column,
*the same difference should be carried forward to the liabilities column

  CLEAR: V_DIFF, FISCAL_ERFOLG_AUFWAND, FISCAL_ERFOLG_ERTRAG,
         FISCAL_BESTANDKONTO, FISCAL_BESTANDKONTO_PASSIV.

  V_DIFF = ST_ERFOLG_AUFWAND - ST_ERFOLG_ERTRAG.
  IF V_DIFF >= 0.
    FISCAL_ERFOLG_ERTRAG = V_DIFF.
    FISCAL_BESTANDKONTO = V_DIFF.
  ELSEIF V_DIFF <= 0.
    V_DIFF = V_DIFF * -1.
    FISCAL_ERFOLG_AUFWAND = V_DIFF.
    FISCAL_BESTANDKONTO_PASSIV = V_DIFF.
  ENDIF.

  GS_OUTPUT-BUKRS = ' '.
  GS_OUTPUT-SAKNR = ' '.
  GS_OUTPUT-TXT50 = TEXT-003.
  GS_OUTPUT-SUMME_SOLL = ' '.
  GS_OUTPUT-SUMME_HABEN = ' '.
  GS_OUTPUT-SALDO_ENDE_SOLL = ' '.
  GS_OUTPUT-SALDO_ENDE_HABEN = ' '.
  GS_OUTPUT-BESTANDKONTO = FISCAL_BESTANDKONTO.
  GS_OUTPUT-BESTANDKONTO_PASSIV = FISCAL_BESTANDKONTO_PASSIV.
  GS_OUTPUT-ERFOLG_AUFWAND = FISCAL_ERFOLG_AUFWAND.
  GS_OUTPUT-ERFOLG_ERTRAG = FISCAL_ERFOLG_ERTRAG.
  GS_OUTPUT-HWAER = GS_T001-WAERS.
  APPEND GS_OUTPUT TO GT_OUTPUT.

*Final Total: summarization of Subtotal and Fiscal year profit.
  T_BESTANDKONTO = ST_BESTANDKONTO + FISCAL_BESTANDKONTO.
  T_BESTANDKONTO_PASSIV =
    ST_BESTANDKONTO_PASSIV + FISCAL_BESTANDKONTO_PASSIV.
  T_ERFOLG_AUFWAND = ST_ERFOLG_AUFWAND + FISCAL_ERFOLG_AUFWAND.
  T_ERFOLG_ERTRAG = ST_ERFOLG_ERTRAG + FISCAL_ERFOLG_ERTRAG.

  GS_OUTPUT-BUKRS = ' '.
  GS_OUTPUT-SAKNR = ' '.
  GS_OUTPUT-TXT50 = TEXT-004.
  GS_OUTPUT-SUMME_SOLL = ST_SUMME_SOLL.
  GS_OUTPUT-SUMME_HABEN = ST_SUMME_HABEN.
  GS_OUTPUT-SALDO_ENDE_SOLL = ST_SALDO_ENDE_SOLL.
  GS_OUTPUT-SALDO_ENDE_HABEN = ST_SALDO_ENDE_HABEN.
  GS_OUTPUT-BESTANDKONTO = T_BESTANDKONTO.
  GS_OUTPUT-BESTANDKONTO_PASSIV = T_BESTANDKONTO_PASSIV.
  GS_OUTPUT-ERFOLG_AUFWAND = T_ERFOLG_AUFWAND.
  GS_OUTPUT-ERFOLG_ERTRAG = T_ERFOLG_ERTRAG.
  GS_OUTPUT-HWAER = GS_T001-WAERS.
  APPEND GS_OUTPUT TO GT_OUTPUT.

ENDFORM.                               " ADD_TOTALS

*&---------------------------------------------------------------------*
*&      Form  FIND_TOTAL_ROWS
*&---------------------------------------------------------------------*
* Routine for rows with totals.
*----------------------------------------------------------------------*
FORM FIND_TOTAL_ROWS.

  CLEAR : GV_LINES, GV_ROWS.
  DESCRIBE TABLE GT_OUTPUT LINES GV_LINES.

  GV_ROWS = GV_LINES - 3.

*Increase the row variable with 1.
  GV_ROWS = GV_ROWS + 1.

  DO 3 TIMES.
    APPEND GV_ROWS TO GS_TEST-COLOR_ROWS.
*Increase the counter with 1.
    GV_ROWS = GV_ROWS + 1.
  ENDDO.
  CLEAR : GV_LINES, GV_ROWS.

ENDFORM.                               " FIND_TOTAL_ROWS

*&---------------------------------------------------------------------*
*&      Form  ALV_LIST_OUTPUT
*&---------------------------------------------------------------------*
* Subroutine for ALV list output using ALV Grid display.
*----------------------------------------------------------------------*
FORM ALV_LIST_OUTPUT.

  DATA:  LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
         LT_EVENTS   TYPE SLIS_T_EVENT,
         LS_LAYOUT   TYPE SLIS_LAYOUT_ALV,
         LS_SETT     TYPE LVC_S_GLAY,
         LS_PRNT     TYPE SLIS_PRINT_ALV.

*Begin of Note 1018053
  DATA:  LS_FIELDCAT TYPE SLIS_FIELDCAT_MAIN0,
         LV_WAERS    TYPE T001-WAERS.
*End of Note 1018053

* Build item fieldcatalog table
  PERFORM FIELDCAT_INIT CHANGING LT_FIELDCAT.
* Build Print Information.
  PERFORM SET_PRNT CHANGING LS_PRNT.
* Build Grid Settings.
  PERFORM SET_GRID_SETT CHANGING LS_SETT.
* Build event table
  PERFORM LT_EVENTS_BUILD CHANGING LT_EVENTS.
* Build Layout.
  PERFORM LAYOUT_INIT CHANGING LS_LAYOUT.
* Build comments for page header.
  PERFORM LT_COMMENT_BUILD USING GS_LIST_TOP_OF_PAGE[].
* Build the layout with row colors for totals.
  PERFORM SET_ROW_COLOR CHANGING LS_LAYOUT.

*Begin of Note 1018053
  SELECT WAERS INTO LV_WAERS FROM T001 WHERE BUKRS = SD_BUKRS-LOW.
  ENDSELECT.

  LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
    IF LS_FIELDCAT-CURRENCY IS INITIAL.
      LS_FIELDCAT-CURRENCY = LV_WAERS.
      MODIFY LT_FIELDCAT FROM LS_FIELDCAT.
    ENDIF.
  ENDLOOP.
*End of Note 1018053


*Call Function Module 'REUSE_ALV_GRID_DISPLAY' for ALV grid display.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = GV_REPID
      I_CALLBACK_PF_STATUS_SET = G_STATUS
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND_DET'
*      i_callback_html_top_of_page = l_callback_html_top_of_page
      I_BACKGROUND_ID          = 'LOGOISAPBAN002'
      I_GRID_SETTINGS          = LS_SETT
      IS_LAYOUT                = LS_LAYOUT
      IT_FIELDCAT              = LT_FIELDCAT
      I_SAVE                   = GC_SAVE
      IS_VARIANT               = GS_VARIANT
      IT_EVENTS                = LT_EVENTS
      IS_PRINT                 = LS_PRNT
      i_html_height_top         = 32
    TABLES
      T_OUTTAB                 = GT_OUTPUT
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                               " ALV_LIST_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
* Subroutine to fill fieldcatalog.
*----------------------------------------------------------------------*
FORM FIELDCAT_INIT CHANGING RT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

* User definded additional field(s) not included in structure
* but with ddic reference structure
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = GC_STRUCTURE
    CHANGING
      CT_FIELDCAT            = RT_FIELDCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

  DELETE RT_FIELDCAT WHERE FIELDNAME = GC_HWAER.

ENDFORM.                               " FIELDCAT_INIT

*&---------------------------------------------------------------------*
*&      Form  set_prnt
*&---------------------------------------------------------------------*
* Subroutine to set Print Information
*----------------------------------------------------------------------*
FORM SET_PRNT CHANGING CS_PRNT TYPE SLIS_PRINT_ALV.

  CS_PRNT-NO_PRINT_LISTINFOS     = 'X'.

ENDFORM.                    " set_prnt

*&---------------------------------------------------------------------*
*&      Form  SET_GRID_SETT
*&---------------------------------------------------------------------*
* Routine for Grid Settings.
*----------------------------------------------------------------------*
FORM SET_GRID_SETT CHANGING CS_SETT TYPE LVC_S_GLAY.

*ALV control: Optimize column width for printing
  CS_SETT-NO_COLWOPT = ' '.

ENDFORM.                               " SET_GRID_SETT

*&---------------------------------------------------------------------*
*&      Form  lt_events_build
*&---------------------------------------------------------------------*
* Subroutine for Events build.
*----------------------------------------------------------------------*
FORM LT_EVENTS_BUILD CHANGING XT_EVENTS TYPE SLIS_T_EVENT.

  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.


  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE     = 0
    IMPORTING
      ET_EVENTS       = XT_EVENTS
    EXCEPTIONS
      LIST_TYPE_WRONG = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*Pass the subroutine name to the TOP-OF-PAGE event when the top of page
*is triggered
  READ TABLE XT_EVENTS INTO LS_EVENT WITH
       KEY NAME = SLIS_EV_TOP_OF_PAGE.
  IF SY-SUBRC = 0.
    LS_EVENT-FORM = GC_TOPOFPAGE.
    MODIFY XT_EVENTS FROM LS_EVENT TRANSPORTING FORM
           WHERE NAME = SLIS_EV_TOP_OF_PAGE.
  ENDIF.


ENDFORM.                               " lt_events_build

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
* Subroutine to Initialize the Layout.
*----------------------------------------------------------------------*
FORM LAYOUT_INIT CHANGING RS_LAYOUT TYPE SLIS_LAYOUT_ALV.

*columns separated by space
*  RS_LAYOUT-NO_VLINE      = 'X'.
*Build layout for list display
  RS_LAYOUT-DETAIL_POPUP      = 'X'.
*Optimize column width
  RS_LAYOUT-COLWIDTH_OPTIMIZE  = 'X'.
*no choice for summing up
  RS_LAYOUT-NO_SUMCHOICE  = 'X'.

  RS_LAYOUT-ZEBRA = 'X'.
  RS_LAYOUT-INFO_FIELDNAME    = 'X'.


ENDFORM.                               " LAYOUT_INIT
*&---------------------------------------------------------------------*
*&      Form  HTML_TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM html_top_of_page USING document
                            TYPE REF TO cl_dd_document.     "#EC CALLED

  DATA: l_title        TYPE sdydo_text_element,
        l_text         TYPE sdydo_text_element,
        l_month     TYPE fcltx.

 data : l_fontsiz     TYPE SDYDO_ATTRIBUTE.

 DATA: TI_ZFIGIRO LIKE ZFIGIRO OCCURS 0 WITH HEADER LINE.

  IF GS_T001-ADRNR NE SPACE.
* Company name and address details for header.
    PERFORM GET_COMP_ADDRESS.
  ENDIF.
* SE EXTRAE GIRO
  SELECT * FROM ZFIGIRO
    INTO TABLE TI_ZFIGIRO
    WHERE BUKRS = GS_T001-BUKRS.

*************************************************
   l_text = GS_T001-BUTXT.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'. "'Strong'.
*********************************************************
******** Giro **************************+
  l_fontsiz = '1'.
  LOOP AT TI_ZFIGIRO.
    IF TI_ZFIGIRO-GIRO_1 IS NOT INITIAL.
    CALL METHOD document->new_line.
    CONCATENATE 'Giro : ' TI_ZFIGIRO-GIRO_1 into l_text.
*    l_text = TI_ZFIGIRO-GIRO_1.
    CALL METHOD document->add_text
    EXPORTING
      text         = l_text
*      sap_emphasis = 'HEADING' "'Strong'.
      sap_fontsize = l_fontsiz.
      CALL METHOD document->new_line.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_2 IS NOT INITIAL.
      l_text = TI_ZFIGIRO-GIRO_2.
      CALL METHOD document->add_text
      EXPORTING
        text         = l_text
*        sap_emphasis = 'HEADING'. "'Strong'.
        SAP_FONTSIZE = l_fontsiz.
        CALL METHOD document->new_line.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_3 IS NOT INITIAL.
      l_text = TI_ZFIGIRO-GIRO_3.
      CALL METHOD document->add_text
      EXPORTING
        text         = l_text
        sap_emphasis = 'HEADING'. "'Strong'.
        CALL METHOD document->new_line.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_4 IS NOT INITIAL.
      l_text = TI_ZFIGIRO-GIRO_4.
      CALL METHOD document->add_text
      EXPORTING
        text         = l_text
        sap_emphasis = 'HEADING'. "'Strong'.
        CALL METHOD document->new_line.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_5 IS NOT INITIAL.
      l_text = TI_ZFIGIRO-GIRO_5.
      CALL METHOD document->add_text
      EXPORTING
        text         = l_text
        sap_emphasis = 'HEADING'. "'Strong'.
        CALL METHOD document->new_line.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_6 IS NOT INITIAL.
      l_text = TI_ZFIGIRO-GIRO_6.
      CALL METHOD document->add_text
      EXPORTING
        text         = l_text
        sap_emphasis = 'HEADING'. "'Strong'.
        CALL METHOD document->new_line.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_7 IS NOT INITIAL.
      l_text = TI_ZFIGIRO-GIRO_7.
      CALL METHOD document->add_text
      EXPORTING
        text         = l_text
        sap_emphasis = 'HEADING'. "'Strong'.
        CALL METHOD document->new_line.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_8 IS NOT INITIAL.
      l_text = TI_ZFIGIRO-GIRO_8.
      CALL METHOD document->add_text
      EXPORTING
        text         = l_text
        sap_emphasis = 'HEADING'. "'Strong'.
        CALL METHOD document->new_line.
    ENDIF.
ENDLOOP.

  CLEAR: GS_T001Z.
* R.U.T Tax Number.
  SELECT SINGLE PAVAL FROM T001Z INTO GS_T001Z-PAVAL
                     WHERE BUKRS = GS_T001-BUKRS
                     AND PARTY = 'TAXNR'.
  CHECK SY-SUBRC = 0.
*  rut
  CONCATENATE 'Rut : ' GS_T001Z-PAVAL into l_text.
*  l_text = GS_T001Z-PAVAL.
      CALL METHOD document->add_text
      EXPORTING
       text         = l_text
       sap_emphasis = 'HEADING'. "'Strong'.
       CALL METHOD document->new_line.

* direccion
CONCATENATE 'Dirección :' GS_ADDR_COMP-STREET into l_text.
*  l_text = GS_ADDR_COMP-STREET.
      CALL METHOD document->add_text
      EXPORTING
       text         = l_text
       sap_emphasis = 'HEADING'. "'Strong'.
       CALL METHOD document->new_line.
***********************************************

*  CALL METHOD document->new_line.
*  l_text = g_butxt.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
  CALL METHOD document->new_line.
  l_title = 'BALANCE'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 170.
  CALL METHOD document->add_text
    EXPORTING
      text          = l_title
      sap_style     = 'HEADING'
      sap_fontstyle = 'C'
      sap_emphasis  = 'C'.

*  fECHA
  CLEAR : GV_LOWDATE, GV_HIGHDATE, GV_DATE.

  CONCATENATE GC_01 '.' GC_01 '.' SD_GJAHR-LOW INTO GV_LOWDATE.
  CONCATENATE P_DATE+6(2) '.' P_DATE+4(2) '.' P_DATE+0(4) INTO
  GV_HIGHDATE.
  CONCATENATE 'Desde :'GV_LOWDATE ' A ' GV_HIGHDATE INTO GV_DATE
              SEPARATED BY SPACE.

  l_title = GV_DATE.
  CALL METHOD document->new_line.
   CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'HEADING'.
*  CALL METHOD document->new_line.
*  l_title = GV_DATE.
  CALL METHOD document->add_gap
    EXPORTING
      width = 160.
  CALL METHOD document->add_text
    EXPORTING
      text          = l_title
      sap_style     = 'Strong'.







ENDFORM.                    "html_top_of_page

*&---------------------------------------------------------------------*
*&      Form  LT_COMMENT_BUILD
*&---------------------------------------------------------------------*
* Subroutine for comment build.
*----------------------------------------------------------------------*
FORM LT_COMMENT_BUILD USING XT_TOP_OF_PAGE TYPE
                               SLIS_T_LISTHEADER.

  DATA: LS_LINE TYPE SLIS_LISTHEADER,
        LV_DATE(10) TYPE C.


  DATA: TI_ZFIGIRO LIKE ZFIGIRO OCCURS 0 WITH HEADER LINE.

  IF GS_T001-ADRNR NE SPACE.
* Company name and address details for header.
    PERFORM GET_COMP_ADDRESS.
  ENDIF.

  CLEAR: GS_T001Z.
* R.U.T Tax Number.
  SELECT SINGLE PAVAL FROM T001Z INTO GS_T001Z-PAVAL
                     WHERE BUKRS = GS_T001-BUKRS
                     AND PARTY = 'TAXNR'.
  CHECK SY-SUBRC = 0.

* SE EXTRAE GIRO
  SELECT * FROM ZFIGIRO
    INTO TABLE TI_ZFIGIRO
    WHERE BUKRS = GS_T001-BUKRS.


* Listheader
  CLEAR LS_LINE.
  LS_LINE-TYP  = 'H'.
  LS_LINE-INFO = 'Balance'.
  APPEND LS_LINE TO XT_TOP_OF_PAGE.

* Listheader: show company code name
  CLEAR LS_LINE.
  LS_LINE-TYP  = 'S'.
  LS_LINE-KEY =  TEXT-005 .
  LS_LINE-INFO = GS_T001-BUTXT .
  APPEND LS_LINE TO XT_TOP_OF_PAGE.

* Listheader: show company address
  CLEAR LS_LINE.
  LS_LINE-TYP  = 'S'.
  LS_LINE-KEY =  TEXT-006 .
  LS_LINE-INFO = GS_ADDR_COMP-STREET .
  APPEND LS_LINE TO XT_TOP_OF_PAGE.

* Listheader: show city
  CLEAR LS_LINE.
  LS_LINE-TYP  = 'S'.
  LS_LINE-KEY =  TEXT-007 .
  LS_LINE-INFO = GS_ADDR_COMP-CITY1 .
  APPEND LS_LINE TO XT_TOP_OF_PAGE.
  CLEAR: GS_ADDR_COMP, GS_ADDR_SEL.

* Listheader: show R.U.T.
  CLEAR LS_LINE.
  LS_LINE-TYP  = 'S'.
  LS_LINE-KEY =  TEXT-008 .
  LS_LINE-INFO = GS_T001Z-PAVAL .
  APPEND LS_LINE TO XT_TOP_OF_PAGE.

* Listheader: show Fiscal Period
  CLEAR : GV_LOWDATE, GV_HIGHDATE, GV_DATE.

  CONCATENATE GC_01 '.' GC_01 '.' SD_GJAHR-LOW INTO GV_LOWDATE.
  CONCATENATE P_DATE+6(2) '.' P_DATE+4(2) '.' P_DATE+0(4) INTO
  GV_HIGHDATE.
  CONCATENATE GV_LOWDATE 'TO' GV_HIGHDATE INTO GV_DATE
              SEPARATED BY SPACE.

  CLEAR LS_LINE.
  LS_LINE-TYP  = 'S'.
  LS_LINE-KEY =  TEXT-009 .
  LS_LINE-INFO = GV_DATE.
  APPEND LS_LINE TO XT_TOP_OF_PAGE.

* Listheader: show Date
  CLEAR LV_DATE.
  WRITE SY-DATUM TO LV_DATE.

  CLEAR LS_LINE.
  LS_LINE-TYP  = 'S'.
  LS_LINE-KEY =  TEXT-010 .
  LS_LINE-INFO = LV_DATE .
  APPEND LS_LINE TO XT_TOP_OF_PAGE.

******** Giro **************************+
  LOOP AT TI_ZFIGIRO.
    IF TI_ZFIGIRO-GIRO_1 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR LS_LINE.
      LS_LINE-TYP  = 'S'.
      LS_LINE-KEY =  TEXT-015 .
      LS_LINE-INFO = TI_ZFIGIRO-GIRO_1 .
      APPEND LS_LINE TO XT_TOP_OF_PAGE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_2 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR LS_LINE.
      LS_LINE-TYP  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      LS_LINE-INFO = TI_ZFIGIRO-GIRO_2.
      APPEND LS_LINE TO XT_TOP_OF_PAGE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_3 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR LS_LINE.
      LS_LINE-TYP  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      LS_LINE-INFO = TI_ZFIGIRO-GIRO_3.
      APPEND LS_LINE TO XT_TOP_OF_PAGE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_4 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR LS_LINE.
      LS_LINE-TYP  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      LS_LINE-INFO = TI_ZFIGIRO-GIRO_4.
      APPEND LS_LINE TO XT_TOP_OF_PAGE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_5 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR LS_LINE.
      LS_LINE-TYP  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      LS_LINE-INFO = TI_ZFIGIRO-GIRO_5.
      APPEND LS_LINE TO XT_TOP_OF_PAGE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_6 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR LS_LINE.
      LS_LINE-TYP  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      LS_LINE-INFO = TI_ZFIGIRO-GIRO_6.
      APPEND LS_LINE TO XT_TOP_OF_PAGE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_7 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR LS_LINE.
      LS_LINE-TYP  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      LS_LINE-INFO = TI_ZFIGIRO-GIRO_7.
      APPEND LS_LINE TO XT_TOP_OF_PAGE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_8 IS NOT INITIAL.
* Listheader: show giro name
      CLEAR LS_LINE.
      LS_LINE-TYP  = 'S'.
*    LS_LINE-KEY =  TEXT-015 .
      LS_LINE-INFO = TI_ZFIGIRO-GIRO_8.
      APPEND LS_LINE TO XT_TOP_OF_PAGE.
    ENDIF.

  ENDLOOP.

ENDFORM.                               " LT_COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  GET_COMP_ADDRESS
*&---------------------------------------------------------------------*
* Subroutine to get Company Address
*----------------------------------------------------------------------*
FORM GET_COMP_ADDRESS.

  CLEAR: GS_ADDR_SEL, GS_ADDR_COMP.

*Address number
  GS_ADDR_SEL-ADDRNUMBER = GS_T001-ADRNR.

*Call Function Module to get Company code address.
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      ADDRESS_SELECTION = GS_ADDR_SEL
    IMPORTING
      ADDRESS_VALUE     = GS_ADDR_COMP
    EXCEPTIONS
      PARAMETER_ERROR   = 1
      ADDRESS_NOT_EXIST = 2
      VERSION_NOT_EXIST = 3
      INTERNAL_ERROR    = 4
      OTHERS            = 5.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " GET_COMP_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  SET_ROW_COLOR
*&---------------------------------------------------------------------*
* Routine to change layout with Color for Rows with Totals.
*----------------------------------------------------------------------*
FORM SET_ROW_COLOR CHANGING CS_LAYO TYPE SLIS_LAYOUT_ALV.

  FIELD-SYMBOLS: <LS_OUTTAB> TYPE LINES_FINAL.

  DATA: L_ROW TYPE I.

  CS_LAYO-INFO_FIELDNAME = 'COLOR'.

  LOOP AT GS_TEST-COLOR_ROWS INTO L_ROW.
    READ TABLE GT_OUTPUT ASSIGNING <LS_OUTTAB> INDEX L_ROW.
    IF SY-SUBRC EQ 0.
*Yellow color for Totals.
      <LS_OUTTAB>-COLOR = 'C300'.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " SET_ROW_COLOR

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
* FORM routine for Top of Page to display Header information.
*---------------------------------------------------------------------*
FORM TOP_OF_PAGE.                                           "#EC CALLED

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = GS_LIST_TOP_OF_PAGE.
ENDFORM.                               "TOP_OF_PAGE
*---------------------------------------------------------------------*
*       FORM standard                                                 *
*---------------------------------------------------------------------*
* FORM routine for PF Status.
*---------------------------------------------------------------------*
FORM STANDARD                                               "#EC CALLED
            USING EXTAB TYPE SLIS_T_EXTAB.                  "#EC NEEDED

  SET PF-STATUS 'STANDARD' .
  SET TITLEBAR 'TITULO'.

ENDFORM.                                                    "standard01
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_DET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->F_UCOMM    text
*      -->I_SELFIELD text
*----------------------------------------------------------------------*
FORM USER_COMMAND_DET USING F_UCOMM LIKE SY-UCOMM

    I_SELFIELD TYPE SLIS_SELFIELD.
  I_SELFIELD-REFRESH = 'X'.

  DATA : LS_OUTPUT LIKE LINE OF GT_OUTPUT.
  DATA: RS_SELFIELD TYPE SLIS_SELFIELD.
  RS_SELFIELD-REFRESH = 'X'.

  CASE SY-UCOMM.
    WHEN '&FILE'. "GENERA ARCHIVO
      IF ZFILE IS NOT INITIAL.
        PERFORM GET_FILE USING ZFILE.
      ELSE.
         MESSAGE 'Debe Indicar la Ruta del Archivo de Texto' type  'E'.
      ENDIF.
    WHEN 'LINE'.
      CALL SCREEN 0100
       STARTING AT 20 1.
  ENDCASE.

  CASE F_UCOMM.
    WHEN '&IC1'. "Doble Click
      READ TABLE  GT_OUTPUT INTO LS_OUTPUT INDEX I_SELFIELD-TABINDEX.
      IF SY-SUBRC EQ 0.
        PERFORM CALL_FAGLB03 USING LS_OUTPUT-SAKNR SD_BUKRS-LOW SD_GJAHR-LOW.
      ENDIF.
  ENDCASE.

ENDFORM.                    "USER_COMMAND_DET
*&---------------------------------------------------------------------*
*&      Form  CALL_FAGLB03
*&---------------------------------------------------------------------*
*       HACE REFERENCIA A FAGLB03
*----------------------------------------------------------------------*
*      -->P_I_SELFIELD_VALUE  text
*      -->P_BUKRS  text
*      -->P_GJAHR  text
*----------------------------------------------------------------------*
FORM CALL_FAGLB03  USING    P_CUENTA
                            P_BUKRS
                            P_GJAHR.

  DATA P_RLDNR TYPE FAGL_RLDNR.
  P_RLDNR = sd_rldnr-LOW.

  SET PARAMETER ID :'ACC' FIELD  P_CUENTA,
                    'BUK' FIELD  P_BUKRS,
                    'GJR' FIELD  P_GJAHR,
                    'GLN_FLEX' FIELD P_RLDNR.


  CALL TRANSACTION 'FAGLB03' AND SKIP FIRST SCREEN.


ENDFORM.                    " CALL_FAGLB03
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'STATUS_100'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0100  OUTPUT
