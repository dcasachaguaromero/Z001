*&---------------------------------------------------------------------*
*&  Include           J_CL_BALANCE_SHEET_TOP
*&---------------------------------------------------------------------*
REPORT J_CL_BALANCE_SHEET MESSAGE-ID FR LINE-SIZE 170
       NO STANDARD PAGE HEADING.

************************************************************************
* Table definition
************************************************************************
TABLES SKB1.     " G/L account master (company code)
TABLES SKA1.     " G/L Account Master (Chart of Accounts)
TABLES SKC1A.    " G/L Account Sales Segment Derived from GLDB -LC
TABLES SKAT.     " G/L Account Master Record (CoAccounts: Description)

************************************************************************
* Type Pool
************************************************************************
* Type Pool of ALV specific data types
TYPE-POOLS: SLIS.

************************************************************************
* Types                                                                *
************************************************************************
* Structure to maintain the BKPF data.
TYPES :   BEGIN OF LINES_BKPF,
            BUKRS TYPE BKPF-BUKRS,     " Company Code
            BELNR TYPE BKPF-BELNR,     " Accounting document number
            GJAHR TYPE BKPF-GJAHR,     " Fiscal Year
            BUDAT TYPE BKPF-BUDAT,     " Posting date in the document
            ldgrp type bkpf-ldgrp,
            BSTAT TYPE BKPF-BSTAT,
          END   OF LINES_BKPF.

* Structure to maintain the BSEG data.
TYPES :   BEGIN OF LINES_BSEG,
            BUKRS TYPE BSEG-BUKRS,     " Company Code
            BELNR TYPE BSEG-BELNR,     " Accounting document number
            GJAHR TYPE BSEG-GJAHR,     " Fiscal Year
            BUZEI TYPE BSEG-BUZEI,     " Line Item number
            HKONT TYPE BSEG-HKONT,     " General ledger account
            SHKZG TYPE BSEG-SHKZG,     " Debit/credit indicator
            DMBTR TYPE BSEG-DMBTR,     " Amount in local currency
          END   OF LINES_BSEG,

* Structure used to store the collected value from BSEG
          BEGIN OF LINES_WORK,
            HKONT TYPE BSEG-HKONT,     " General ledger account
            SHKZG TYPE BSEG-SHKZG,     " Debit/credit indicator
* CBD            DMBTR TYPE BSEG-DMBTR,     " Amount in local currency
            DMBTR TYPE P DECIMALS 2,     " Amount in local currency
* CBD
          END   OF LINES_WORK.

* Stucture used to color Rows with Totals.
TYPES:    BEGIN OF LINES_ROWS,
            COLOR_ROWS  TYPE I OCCURS 0, " Rows
          END   OF LINES_ROWS.

* Structure for final ALV Table.
TYPES: GS_FINAL TYPE J_BALANCE_CHILE.
TYPES:    BEGIN OF LINES_FINAL,
            BUKRS TYPE T001-BUKRS.       " Company Code
            INCLUDE TYPE ZBALANCECHILE.
*DATA  l_callback_html_top_of_page.
*DATA  GT_DATA.
TYPES:      XBILK TYPE SKA1-XBILK,       " Indicator: Account is a
                                         " balance sheet account?
            COLOR(4) TYPE C,             " Row color for totals
          END   OF LINES_FINAL.

************************************************************************
* Internal Tables
************************************************************************
* Table for displaying the ALV output using DDIC structure
DATA: GT_OUTPUT TYPE STANDARD TABLE OF LINES_FINAL.

* Internal tables used for report processing
DATA: GT_BKPF   TYPE STANDARD TABLE OF LINES_BKPF,
      GT_BSEG   TYPE STANDARD TABLE OF LINES_BSEG,
      GT_WORK   TYPE STANDARD TABLE OF LINES_WORK.

************************************************************************
* Work area
************************************************************************
* Work area for output table using DDIC structure
DATA: GS_OUTPUT TYPE LINES_FINAL.

* Work area for intermidiate tables for report processing
DATA : REC_BSEG TYPE LINES_BSEG,
       REC_WORK TYPE LINES_WORK.

* Work areas used for Page Header
DATA: GS_T001 TYPE T001,
      GS_T001Z TYPE T001Z,
      GS_ADDR_SEL TYPE ADDR1_SEL,
      GS_ADDR_COMP TYPE ADDR1_VAL,
      GS_TEST TYPE LINES_ROWS.

************************************************************************
* Structures
************************************************************************
* Structure for variant
DATA: GS_VARIANT TYPE DISVARIANT,
      G_VARIANT  TYPE DISVARIANT,
* GUI status
      G_STATUS TYPE SLIS_FORMNAME VALUE 'STANDARD',
* Top of Page
      GS_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.

************************************************************************
* Variables
************************************************************************
DATA: GV_REPID TYPE SY-REPID.           " Name of Calling Program

DATA: GV_LOWDATE1(8) TYPE C,            " Date
      GV_LOWDATE(10) TYPE C,            " Date
      GV_HIGHDATE(10) TYPE C,           " Date
      GV_DATE(45) TYPE C,               " Date
      GV_LINES    TYPE I,               " No. of records
      GV_ROWS     TYPE I,               " Row index for totals
      GV_INDEX TYPE I.                  " System Index

*Delaration of work variables used to fill output table
DATA: SALDO_ENDE_SOLL TYPE SKC1A-UM01K,        " Debit Balance
      SALDO_ENDE_HABEN TYPE SKC1A-UM01K,       " Credit Balance
      BESTANDKONTO TYPE SKC1A-UM01K,           " Assets
      BESTANDKONTO_PASSIV TYPE SKC1A-UM01K,    " Liabilities
      ERFOLG_AUFWAND TYPE SKC1A-UM01K,         " Loss
      ERFOLG_ERTRAG TYPE SKC1A-UM01K,          " Profit

*Delaration of variables used for Subtotals
      ST_SUMME_SOLL TYPE SKC1A-UM01K,          " Debit - Subtotal
      ST_SUMME_HABEN TYPE SKC1A-UM01K,         " Credit - Subtotal
      ST_SALDO_ENDE_SOLL TYPE SKC1A-UM01K,     " Debit Balance-Subtotal
      ST_SALDO_ENDE_HABEN TYPE SKC1A-UM01K,    " Credit Balance-Subtotal
      ST_BESTANDKONTO TYPE SKC1A-UM01K,        " Assets - Subtotal
      ST_BESTANDKONTO_PASSIV TYPE SKC1A-UM01K, " Liabilities - Subtotal
      ST_ERFOLG_AUFWAND TYPE SKC1A-UM01K,      " Loss - Subtotal
      ST_ERFOLG_ERTRAG TYPE SKC1A-UM01K,       " Profit - Subtotal

*Delaration of variables used for Fiscal Year Profit (Loss)
      V_DIFF TYPE SKC1A-UM01K,
      FISCAL_ERFOLG_AUFWAND TYPE SKC1A-UM01K,      " Loss - FYear P/L
      FISCAL_ERFOLG_ERTRAG TYPE SKC1A-UM01K,       " Profit - FYear P/L
      FISCAL_BESTANDKONTO TYPE SKC1A-UM01K,        " Assets - FYear P/L
      FISCAL_BESTANDKONTO_PASSIV TYPE SKC1A-UM01K, " Liab. - FYear P/L

*Delaration of variables used for Final Total
      T_BESTANDKONTO TYPE SKC1A-UM01K,        " Assets - Total
      T_BESTANDKONTO_PASSIV TYPE SKC1A-UM01K, " Liabilities - Total
      T_ERFOLG_AUFWAND TYPE SKC1A-UM01K,      " Loss - Total
      T_ERFOLG_ERTRAG TYPE SKC1A-UM01K.       " Profit - Total

************************************************************************
* Constants
************************************************************************
CONSTANTS:
     GC_TOPOFPAGE TYPE SLIS_ALV_EVENT-FORM VALUE 'TOP_OF_PAGE',
     GC_STRUCTURE(30) TYPE C VALUE 'ZBALANCECHILE',
     GC_HWAER(30)     TYPE C VALUE 'HWAER',
     GC_SAVE(1)       TYPE C VALUE 'N',
     GC_01(02)        TYPE C VALUE '01'.

************************************************************************
* Ranges                                                               *
************************************************************************
RANGES : R_DATE     FOR BKPF-BUDAT.             "Range for date
