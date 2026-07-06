*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFIMDP009 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_FORM_0020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_FORM_0020 INPUT.
  IF SY-UCOMM NE 'BACK'
   AND SY-UCOMM NE 'CANCEL'
   AND SY-UCOMM NE 'EXIT'
   AND SY-UCOMM NE 'SOC_01'
    AND SY-UCOMM NE 'B03'
    AND SY-UCOMM NE 'EBR2'.
  BSEG-BVTYP =  ZINVFO-BVTYP.
  BSEG-DTWS1 = ZINVFO-DTWS1.
  BSEG-DTWS2 = ZINVFO-DTWS2.
  BSEG-DTWS3 = ZINVFO-DTWS3.
  BSEG-DTWS4 = ZINVFO-DTWS4.
  BSEG-EMPFB = ZINVFO-EMPFB.
  BSEG-HBKID = ZINVFO-HBKID.
  BSEG-HKTID = ZINVFO-HKTID.
  BSEG-KIDNO = ZINVFO-KIDNO.
  BSEG-PYCUR = ZINVFO-PYCUR.
  BSEG-PYAMT = ZINVFO-PYAMT.
  BSEG-REBZG = ZINVFO-REBZG.
  BSEG-REBZJ = ZINVFO-REBZJ.
  BSEG-REBZZ = ZINVFO-REBZZ.
  BSEG-SKFBT = ZINVFO-SKFBT.
  BSEG-UZAWE = ZINVFO-UZAWE.
  BSEG-WSKTO = ZINVFO-WSKTO.
  BSEG-ZFBDT = ZINVFO-ZFBDT.
  BSEG-ZBD1P = ZINVFO-ZBD1P.
  BSEG-ZBD2P = ZINVFO-ZBD2P.
  BSEG-ZBD1T = ZINVFO-ZBD1T.
  BSEG-ZBD2T = ZINVFO-ZBD2T.
  BSEG-ZBD3T = ZINVFO-ZBD3T.
  IF KOART = 'K'.
    BSEG-ZBFIX = ZINVFO-ZBFIX.
  ENDIF.
  BSEG-ZLSCH = ZINVFO-ZLSCH.
  BSEG-ZLSPR = ZINVFO-ZLSPR.
  BSEG-ZTERM = ZINVFO-ZTERM.
  BSEG-RSTGR = ZINVFO-RSTGR.
  GET CURSOR FIELD CURSOR.
  CLEAR G_EXIT_COMMAND.
  endif.
ENDMODULE.                 " GET_FORM_0020  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_CASH_DISCOUNT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_CASH_DISCOUNT INPUT.
  CHECK G_AKTYP NE 'A'.
  IF FAUS1+6(2) CN '-'.
    PERFORM CHECK_CASH_DISCOUNT.
  ENDIF.
  IF BSEG-WRBTR NE 0.
    BSEG-SKNTO = BSEG-WSKTO * BSEG-DMBTR / BSEG-WRBTR.
    BSEG-SKNT2 = BSEG-WSKTO * BSEG-DMBE2 / BSEG-WRBTR.
    BSEG-SKNT3 = BSEG-WSKTO * BSEG-DMBE3 / BSEG-WRBTR.
  ELSE.
    PERFORM CALCULATE_SKONTO.                               "Note545122
  ENDIF.

ENDMODULE.                 " CHECK_CASH_DISCOUNT  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_CASH_DISCOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_CASH_DISCOUNT .
  DATA: REFE1(8)   TYPE P.
  DATA: L_DIFF LIKE BSEG-WSKTO.                            "Note 336642

  CHECK BSEG-DMBTR NE 0
     OR BSEG-WRBTR NE 0.

*------- Check Cash Discount basis -------------------------------------
  IF BSEG-SKFBT > BSEG-WRBTR.
    MESSAGE W232.
  ENDIF.
  IF  BSEG-SKFBT < BSEG-WRBTR
  AND BSEZ-XSKFB = SPACE
  AND BSEG-ZBD1P > 0
  AND BKPF-GLVOR NE 'RMRP'.
    MESSAGE W229.
  ENDIF.

  IF G_STATUS NE '4'.
    CALL FUNCTION 'ROUND_AMOUNT'
      EXPORTING
        AMOUNT_IN  = BSEG-WSKTO
        COMPANY    = BSEG-BUKRS
        CURRENCY   = BKPF-WAERS
      IMPORTING
        AMOUNT_OUT = BSEG-WSKTO
        DIFFERENCE = L_DIFF.
    IF L_DIFF NE 0.
      ZINVFO-WSKTO = BSEG-WSKTO.
      MESSAGE I458(M8).
    ENDIF.
  ENDIF.

  CHECK G_STATUS CO '13'.
  IF BSEG-SKFBT = 0.
    REFE1 = BSEG-WRBTR * T043T-MAXSK / 100000.
  ELSE.
    REFE1 = BSEG-SKFBT * T043T-MAXSK / 100000.
  ENDIF.
  IF BSEG-WSKTO > REFE1.
    MESSAGE E233 WITH T043T-MAXSK.
  ENDIF.
ENDFORM.                    " CHECK_CASH_DISCOUNT
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_SKONTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALCULATE_SKONTO .
  CHECK BSEG-WSKTO NE 0.
  CHECK BSEG-SKNTO EQ 0.
  MOVE-CORRESPONDING BKPF TO ICURR.
  MOVE-CORRESPONDING BSEG TO ICURR.
  MOVE BSEG-WSKTO TO ICURR-WRBTR.
  CLEAR: ICURR-DMBTR, ICURR-DMBE2, ICURR-DMBE3.
  ICURR-KURST = T003-KURST.
  CALL FUNCTION 'FI_CURRENCIES_CONVERT'
    EXPORTING
      I_ICURR       = ICURR
    IMPORTING
      E_ICURR       = ICURR
    EXCEPTIONS
      ERROR_MESSAGE = 1.
  IF SY-SUBRC IS INITIAL.
    MOVE ICURR-DMBTR TO BSEG-SKNTO.
    MOVE ICURR-DMBE2 TO BSEG-SKNT2.
    MOVE ICURR-DMBE3 TO BSEG-SKNT3.
  ENDIF.
ENDFORM.                    " CALCULATE_SKONTO
*&---------------------------------------------------------------------*
*&      Module  CHECK_PAYMENT_METHOD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PAYMENT_METHOD INPUT.
  IF SY-UCOMM NE 'BACK'
   AND SY-UCOMM NE 'CANCEL'
   AND SY-UCOMM NE 'EXIT'
   AND SY-UCOMM NE 'SOC_01'
    AND SY-UCOMM NE 'B03'
    AND SY-UCOMM NE 'EBR2'.
  CHECK G_AKTYP NE 'A'.
  PERFORM PAYMENT_METHOD_CHECK USING BSEG-ZLSCH T001-LAND1.
 endif.
ENDMODULE.                 " CHECK_PAYMENT_METHOD  INPUT
*&---------------------------------------------------------------------*
*&      Form  PAYMENT_METHOD_CHECK
*&---------------------------------------------------------------------*
FORM PAYMENT_METHOD_CHECK
     USING VALUE(ZLSCH) TYPE SCHZW_BSEG
           VALUE(LAND1) TYPE LAND1.
  CHECK G_AKTYP NE 'A'.
  CHECK BSEG-DMBTR NE 0
     OR BSEG-WRBTR NE 0.
  CALL FUNCTION 'LINEITEM_CHECK_PAYMENT_METHOD'
    EXPORTING
      I_LAND  = LAND1
      I_ZLSCH = ZLSCH
      I_BUKRS = BSEG-BUKRS.

ENDFORM.                             " PAYMENT_METHOD_CHECK
*&---------------------------------------------------------------------*
*&      Module  CHECK_PAYMENT_REFERENCE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PAYMENT_REFERENCE INPUT.
  IF SY-UCOMM NE 'BACK'
   AND SY-UCOMM NE 'CANCEL'
   AND SY-UCOMM NE 'EXIT'
   AND SY-UCOMM NE 'SOC_01'
    AND SY-UCOMM NE 'B03'
    AND SY-UCOMM NE 'EBR2'.
  CHECK G_AKTYP NE 'A'.
  CALL FUNCTION 'FI_PAYREF_CHECK'
    EXPORTING
      I_KIDNO = ZINVFO-KIDNO
      I_LAND1 = T001-LAND1.
 endif.
ENDMODULE.                 " CHECK_PAYMENT_REFERENCE  INPUT
*&---------------------------------------------------------------------*
*&      Module  PAYMENT_CONDITIONS_PROCESS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAYMENT_CONDITIONS_PROCESS INPUT.
  IF SY-UCOMM NE 'BACK'
   AND SY-UCOMM NE 'CANCEL'
   AND SY-UCOMM NE 'EXIT'
   AND SY-UCOMM NE 'SOC_01'
    AND SY-UCOMM NE 'B03'
    AND SY-UCOMM NE 'EBR2'.
  CHECK G_AKTYP NE 'A'.
  CHECK NO_CHECKS IS INITIAL.                              "Note 301654

*-------------- '*' means: give me the payment conditions from master --
  IF BSEG-ZTERM = '*'.
    IF G_DOCUMENT_EXISTS IS INITIAL.                        "Note792838
      BSEG-ZTERM = BSEZ-ZTERM.
    ELSE.                                                   "Note792838
      CASE KOART.                                           "Note792838
        WHEN 'D'.                                           "Note792838
          MOVE KNB1-ZTERM TO BSEG-ZTERM.                    "Note792838
          IF  BSEG-SHKZG = 'H'                              "Note792838
          AND NOT KNB1-GUZTE IS INITIAL.                    "Note792838
            MOVE KNB1-GUZTE TO BSEG-ZTERM.                  "note792838
          ENDIF.                                            "Note792838
        WHEN 'K'.                                           "Note792838
          MOVE LFB1-ZTERM TO BSEG-ZTERM.                    "Note792838
          IF  BSEG-SHKZG = 'S'                              "Note792838
          AND NOT LFB1-GUZTE IS INITIAL.                    "Note792838
            MOVE LFB1-GUZTE TO BSEG-ZTERM.                  "note792838
          ENDIF.                                            "Note792838
        WHEN OTHERS.                                        "Note792838
      ENDCASE.                                              "Note792838
    ENDIF.                                                  "Note792838
  ENDIF.

*- Check Payment Block: Workflow uses blocks that can not be altered ---
  IF BSEG-REBZG EQ SPACE.
    CALL FUNCTION 'PR_WF_PAYMENT_BLOCK_CHECK'
      EXPORTING
        WFVAR = T001-WFVAR
        DMBTR = BSEG-DMBTR
        ZLSPR = BSEG-ZLSPR
        BLART = BKPF-BLART
        BKPF  = BKPF                                        "Note559590
        BSEG  = BSEG.                                       "Note559590
  ENDIF.

*---------------------- Manually entered payment conditions ------------
  IF BSEG-REBZG = SPACE
  OR BSEG-REBZG = 'V'
  OR BSEG-REBZT = 'V'.
    PERFORM PAYMENT_CONDITIONS_PROCESS.
  ENDIF.
 endif.
ENDMODULE.                 " PAYMENT_CONDITIONS_PROCESS  INPUT
*&---------------------------------------------------------------------*
*&      Form  PAYMENT_CONDITIONS_PROCESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PAYMENT_CONDITIONS_PROCESS .
  IF BKPF-GLVOR = 'RMRP' AND BSEG-LIFNR = SPACE
  AND BSEG-ZTERM = SPACE
  AND INVFO_OLD-ZTERM = SPACE.
    EXIT.
  ENDIF.

  PERFORM PAYMENT_COND_PREL_CHECKS.
  PERFORM PAYMENT_COND_SET_SKLINX.
  PERFORM PAYMENT_COND_PROCESS.
  PERFORM PAYMENT_COND_ERROR_BSL_DATE USING 'E'.
  PERFORM CHECK_DISCOUNT_DAYS USING CHAR_E.
  PERFORM PAYMENT_COND_SET.
  PERFORM PAYMENT_COND_CLOSE.
  CHECK CHANGE_STATUS NE SPACE.
  PERFORM READ_T052 USING SPACE.
  CLEAR CHANGE_STATUS.
ENDFORM.                    " PAYMENT_CONDITIONS_PROCESS
*&---------------------------------------------------------------------*
*&      Form  PAYMENT_COND_PREL_CHECKS
*&---------------------------------------------------------------------*
*       Error messages in certain situations
*----------------------------------------------------------------------*
FORM PAYMENT_COND_PREL_CHECKS.

*------- Baseline Date empty and cannot derived ? ----------------------
  IF BKPF-GLVOR NE GLVOR_RMRP                               "Note636506
  OR G_NO_ITEM NE CHAR_X.                                   "Note636506
    IF  BSEG-ZFBDT LE NULL8                               "#EC PORTABLE
     AND BSEG-ZTERM IS INITIAL.
      MESSAGE E220.
    ENDIF.
  ENDIF.                                                    "Note636506

*------- Posting net + split is not allowed ----------------------------
  IF  T052-ZTERM EQ BSEG-ZTERM.
    PERFORM PAYMENT_COND_ERR_NET_SPLIT.
  ENDIF.

*------- Check account type --------------------------------------------
  IF T052-ZTERM NE BSEG-ZTERM.                              "Note848745
    PERFORM READ_T052 USING BSEG-ZTERM.                     "Note848745
  ENDIF.                                                    "Note848745
  IF  T052-ZTERM EQ BSEG-ZTERM
  AND T052-KOART NE KOART
  AND T052-KOART NE SPACE.
    IF T052-KOART = 'D'.
      MESSAGE E550 WITH BSEG-ZTERM.
    ELSEIF T052-KOART = 'K'.
      MESSAGE E551 WITH BSEG-ZTERM.
    ENDIF.
  ENDIF.
ENDFORM.                             " PAYMENT_COND_PREL_CHECKS
*&---------------------------------------------------------------------*
*&      Form  PAYMENT_COND_SET_SKLINX
*&---------------------------------------------------------------------*
FORM PAYMENT_COND_SET_SKLINX.

*--------------- Old values --------------------------------------------
  SKLIN1-ZTAG1 = INVFO_OLD-ZBD1T.
  SKLIN1-ZTAG2 = INVFO_OLD-ZBD2T.
  SKLIN1-ZTAG3 = INVFO_OLD-ZBD3T.
  SKLIN1-ZPRZ1 = INVFO_OLD-ZBD1P.
  SKLIN1-ZPRZ2 = INVFO_OLD-ZBD2P.

*--------------- New values --------------------------------------------
  SKLIN2-ZTAG1 = ZINVFO-ZBD1T.
  SKLIN2-ZTAG2 = ZINVFO-ZBD2T.
  SKLIN2-ZTAG3 = ZINVFO-ZBD3T.
  SKLIN2-ZPRZ1 = ZINVFO-ZBD1P.
  SKLIN2-ZPRZ2 = ZINVFO-ZBD2P.

ENDFORM.                             " PAYMENT_COND_SET_SKLINX
*&---------------------------------------------------------------------*
*&      Form  PAYMENT_COND_PROCESS
*&---------------------------------------------------------------------*
FORM PAYMENT_COND_PROCESS.
  CALL FUNCTION 'FI_CHANGE_PAYMENT_CONDITIONS'
    EXPORTING
      I_BLDAT    = BKPF-BLDAT
      I_BUDAT    = BKPF-BUDAT
*--Retrofit Public Sector: PPA Functionality:
      I_LIFNR    = INVFO_OLD-LIFNR
      I_BUKRS    = BKPF-BUKRS
      I_CPUDT    = BKPF-CPUDT                            "Note 199967
      I_NEWZTERM = BSEG-ZTERM
      I_NEWZFBDT = BSEG-ZFBDT
      I_NEWSKLIN = SKLIN2
      I_OLDZTERM = INVFO_OLD-ZTERM
      I_OLDZFBDT = INVFO_OLD-ZFBDT
      I_OLDSKLIN = SKLIN1
      I_ZSCHF    = BSEG-ZLSPR
      I_ZLSCH    = BSEG-ZLSCH
      I_OLDZLSCH = INVFO_OLD-ZLSCH                          "ALRK244978
      I_OLDZSCHF = INVFO_OLD-ZLSPR                          "ALRK244978
      I_XDERIVE  = XDERIVE                                "Note 617053
    IMPORTING
      E_ZTERM    = BSEG-ZTERM
      E_ZFBDT    = BSEG-ZFBDT
      E_SKLIN    = SKLIN2
      E_STATUS   = CHANGE_STATUS
      E_ZSCHF    = BSEG-ZLSPR
      E_ZLSCH    = BSEG-ZLSCH                               "Note425136
    CHANGING
      C_T052     = T052                                     "Note425136
      C_REINDAT  = ZINVFO-REINDAT.                        "Note 974077
* (del) e_zlsch    = bseg-zlsch.                            "Note425136

*------------- Further processing only if there were changes -----------
  CHECK CHANGE_STATUS NE SPACE.


*-- Amount split: crucial to know if ZFBDT has been changed manually
*-- Created by note 653069
  IF BKPF-GLVOR = 'RMRP'.
*     ZFBDT entered manually
    IF ( CHANGE_STATUS = 'B'
         AND NOT INVFO_OLD-ZFBDT IS INITIAL )               "Note787897
      OR
      ( CHANGE_STATUS = 'BZ'
        AND INVFO_OLD-ZTERM NE SPACE ).
      CALL FUNCTION 'FI_ZFBDT_MAN_SET'.
    ENDIF.

*     ZFBDT derived
    IF CHANGE_STATUS = 'Z'.
      CALL FUNCTION 'FI_ZFBDT_DER_SET'.
    ENDIF.
  ENDIF.

*---------- New ZTERM or new base line date ----------------------------
* The following coding is never performed                   "Note425136
  IF CHANGE_STATUS CS 'ZB'.
    IF BSEG-ZTERM NE SPACE.
      IF BSEG-ZFBDT LE NULL8.                             "#EC PORTABLE
        CALL FUNCTION 'FI_FIND_PAYMENT_CONDITIONS'
          EXPORTING
            I_ZTERM            = BSEG-ZTERM
            I_BLDAT            = BKPF-BLDAT
            I_BUDAT            = BKPF-BUDAT
            I_CPUDT            = SY-DATUM
          IMPORTING
            E_T052             = T052
            E_ZFBDT            = BSEG-ZFBDT
            E_SKLIN            = SKLIN2
          EXCEPTIONS
            TERMS_INCORRECT    = 1
            TERMS_NOT_FOUND    = 2
            NO_DAY_LIMIT_FOUND = 3
            OTHERS             = 4.
        CASE SY-SUBRC.
          WHEN 1.
            MESSAGE E158.
          WHEN 2.
            MESSAGE E100 WITH 'T052' BSEG-ZTERM.
          WHEN 3.
            IF BSEG-ZFBDT LE NULL8.                       "#EC PORTABLE
              MESSAGE E220.
            ELSE.
              MESSAGE E024 WITH BSEG-ZTERM BSEG-ZFBDT+6(2).
            ENDIF.
          WHEN 4.
        ENDCASE.
        PERFORM PAYMENT_COND_PREL_CHECKS.
        PERFORM BASELINEDATE_CHECK.
      ENDIF.
      IF SY-SUBRC NE 0.
        MESSAGE E100 WITH 'T052' BSEG-ZTERM.
      ENDIF.
      PERFORM PAYMENT_COND_PREL_CHECKS.
    ENDIF.
  ENDIF.
ENDFORM.                             " PAYMENT_COND_PROCESS
*&---------------------------------------------------------------------*
*&      Form  PAYMENT_COND_ERROR_BSL_DATE
*&---------------------------------------------------------------------*
*       No baseline date found: send error message
*       Not in MM: baseline date may be appended in ACC Interface
*----------------------------------------------------------------------*
FORM PAYMENT_COND_ERROR_BSL_DATE
     USING VALUE(MSGTY) TYPE SYMSGTY.

  IF BKPF-GLVOR = GLVOR_RMRP.                               "Note636506
    CHECK G_NO_ITEM NE CHAR_X.                              "Note636506
  ENDIF.                                                    "Note636506

  IF BSEG-ZFBDT IS INITIAL.          " and bkpf-glvor ne 'RMRP'.
    IF MSGTY = 'S'.
      MESSAGE S220.
      ACTAB = 'PAYM'.
      CURSOR = 'INVFO-ZFBDT'.
    ELSEIF MSGTY = 'E'.
      MESSAGE E220.
    ELSEIF MSGTY = ''.                                      "Note407518
      PERFORM APPEND_MANDTAB                                "Note407518
              USING 'PAYM'                                  "Note407518
                    'ZFBDT'                                 "Note407518
                    'F5'                                    "Note407518
                    '220'                                   "Note407518
                    ''                                      "Note407518
                    ''                                      "Note407518
                    ''                                      "Note407518
                    ''.                                     "Note407518
    ELSE.
      MESSAGE W220.
      ACTAB = 'PAYM'.
      CURSOR = 'INVFO-ZFBDT'.
    ENDIF.
  ENDIF.
ENDFORM.                             " PAYMENT_COND_ERROR_BSL_DATE

*&---------------------------------------------------------------------*
*&      Form  CHECK_DISCOUNT_DAYS
*&      Form created by note 320428
*&---------------------------------------------------------------------*
*       Check in certain cases if cash discount 1 has expired
*----------------------------------------------------------------------*
FORM CHECK_DISCOUNT_DAYS
     USING VALUE(P_MSGTY) TYPE SYMSGTY.
  DATA: L_DAT8 TYPE D,
        L_MSGTY TYPE SYMSGTY.

  CHECK: BSEG-KOART = CHAR_K,          "Only creditor invoices
         BSEG-ZBD1P > 0,               "Only if discount percentage
         BSEG-ZBD1T > 0,               "Only if discount days
         NOT BSEG-ZFBDT IS INITIAL,    "Due date calculated
         BSEG-REBZT = SPACE.           "No residual item
  CHECK: T020-DYNCL = CHAR_B OR        "Only posting        "Note630692
         T020-DYNCL = CHAR_V.          "or parking          "Note630692
  CHECK: XDERIVE IS INITIAL.                                "Note653053
* Always warn if net posting
  IF BKPF-XNETB = SPACE.
    IF T042-BUKRS NE BSEG-BUKRS.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
      SELECT SINGLE * FROM T042
        WHERE BUKRS = BSEG-BUKRS.
      IF SY-SUBRC NE 0.
        CLEAR T042.
        T042-BUKRS = BSEG-BUKRS.
      ENDIF.
    ENDIF.
* Warn if maximum discount is deducted
    CHECK T042-XSKR1 = CHAR_X.
  ENDIF.
  L_DAT8 = BSEG-ZFBDT + BSEG-ZBD1T.
  IF L_DAT8 < SY-DATLO.
* Issue warning, if customized. Dummy message for where-used list
    IF 1 = 2.
      MESSAGE W252(F5A).
    ELSE.
      CALL FUNCTION 'READ_CUSTOMIZED_MESSAGE'
        EXPORTING
          I_ARBGB = 'F5A'
          I_DTYPE = CHAR_W
          I_MSGNR = '252'
        IMPORTING
          E_MSGTY = L_MSGTY.
      CASE L_MSGTY.
        WHEN '-'.
          EXIT.
        WHEN CHAR_W.
          IF G_252_DISPLAYED IS INITIAL.              "Note517172/653053
            MESSAGE W252(F5A).                              "   /634438
            G_252_DISPLAYED = CHAR_X.                       "Note517172
          ENDIF.
        WHEN CHAR_E.
          IF P_MSGTY = CHAR_E.
            MESSAGE E252(F5A).
          ELSE.
            PERFORM APPEND_MANDTAB
            USING 'PAYM'
                  'ZFBDT'
                  'F5A'
                  '252'
                  ''
                  ''
                  ''
                  ''.

          ENDIF.
      ENDCASE.
    ENDIF.
  ENDIF.
ENDFORM.                               " CHECK_DISCOUNT_DAYS

*&---------------------------------------------------------------------*
*&      Form  PAYMENT_COND_SET
*&---------------------------------------------------------------------*
*       New determined data is moved to BSEG-Fields
*----------------------------------------------------------------------*
FORM PAYMENT_COND_SET.
  BSEG-ZBD1T = SKLIN2-ZTAG1.
  BSEG-ZBD2T = SKLIN2-ZTAG2.
  BSEG-ZBD3T = SKLIN2-ZTAG3.
  BSEG-ZBD1P = SKLIN2-ZPRZ1.
  BSEG-ZBD2P = SKLIN2-ZPRZ2.

*------- Error when posting net with split conditions ------------------
  PERFORM PAYMENT_COND_ERR_NET_SPLIT.

*------- Split Condition: reset all values -----------------------------
  IF T052-XSPLT NE SPACE.
    BSEG-ZBD1T = 0.
    BSEG-ZBD1P = 0.
    BSEG-ZBD2T = 0.
    BSEG-ZBD2P = 0.
    BSEG-ZBD3T = 0.
  ENDIF.
  PERFORM PAYMENT_COND_SET_SPLIT_IND.

*------- Move to form for error processing --------------- "Note 388588
*        Move to old structure, user might change again    "Note 388588
*        during error processing                           "Note 388588
  ZINVFO-ZBD1T = INVFO_OLD-ZBD1T = BSEG-ZBD1T.            "Note 388588
  ZINVFO-ZBD2T = INVFO_OLD-ZBD2T = BSEG-ZBD2T.            "Note 388588
  ZINVFO-ZBD3T = INVFO_OLD-ZBD3T = BSEG-ZBD3T.            "Note 388588
  ZINVFO-ZBD1P = INVFO_OLD-ZBD1P = BSEG-ZBD1P.            "Note 388588
  ZINVFO-ZBD2P = INVFO_OLD-ZBD2P = BSEG-ZBD2P.            "Note 388588
  ZINVFO-ZFBDT = INVFO_OLD-ZFBDT = BSEG-ZFBDT.              "Note436770
  ZINVFO-ZTERM = INVFO_OLD-ZTERM = BSEG-ZTERM.              "Note436770
ENDFORM.                             " PAYMENT_COND_SET

*&---------------------------------------------------------------------*
*&      Form  PAYMENT_COND_CLOSE
*&---------------------------------------------------------------------*
*       Checks after payment conditions were determined
*----------------------------------------------------------------------*
FORM PAYMENT_COND_CLOSE.
*  TABLES: FAEDE.

*------- Check allowed percentages ------------------------------------
  IF G_STATUS CO '13'.                                      "Note407518
    IF BSEG-ZBD1P > T043T-MAXSK.
      SET CURSOR FIELD 'ZINVFO-ZBD1P'.                      "Note407518
      MESSAGE E233 WITH T043T-MAXSK.
    ENDIF.
  ENDIF.                                                    "Note407518

*------- Check due date ------------------------------------------------
  PERFORM PAYMENT_COND_DUE_DATE USING SPACE.

*------- Check Baselinedate for plausibility ---------------------------
  IF CHANGE_STATUS CA 'ZB'.                                 "Note434037
    PERFORM BASELINEDATE_CHECK.                             "Note434037
  ENDIF.                                                    "Note434037

*------- Message for changes -------------------------------------------
  IF CHANGE_STATUS CA 'Z' AND BSEG-LIFNR NE SPACE           "Note448234
  AND XDERIVE <> CHAR_X.                                    "Note612565
*    IF 1 = 2. MESSAGE W231. ENDIF.
*    CALL FUNCTION 'CUSTOMIZED_MESSAGE'
*      EXPORTING
*        I_ARBGB = 'F5'
*        I_DTYPE = 'S'
*        I_MSGNR = '231'.
  ENDIF.
ENDFORM.                             " PAYMENT_COND_CLOSE

*&---------------------------------------------------------------------*
*&      Form  READ_T052
*&---------------------------------------------------------------------*
FORM READ_T052
 USING VALUE(P_ZTERM) TYPE BSEG-ZTERM.                      "Note539451

* Set Default Zterm.                                        "Note539451
  IF P_ZTERM IS INITIAL.                                    "Note539451
    P_ZTERM = BSEG-ZTERM.                                   "Note539451
  ENDIF.                                                    "Note539451

  CALL FUNCTION 'FI_FIND_PAYMENT_CONDITIONS'
    EXPORTING
      I_ZTERM = P_ZTERM                                     "Note539451
      I_BLDAT = BKPF-BLDAT
      I_BUDAT = BKPF-BUDAT
      I_CPUDT = SY-DATLO
    IMPORTING
      E_T052  = T052
    EXCEPTIONS
      OTHERS  = 5.

* Notes 710915 and 726178 removed by note 738938

ENDFORM.                                                    " READ_T052
*---------------------------------------------------------------------*
*  FORM append_mandtab
*  Form created by note 407158
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  VALUE(P_ACTAB)
*  -->  VALUE(P_TAB)
*  -->  VALUE(P_MSGID)
*  -->  VALUE(P_MSGNO)
*  -->  VALUE(P_MSGV1)
*  -->  VALUE(P_MSGV2)
*  -->  VALUE(P_MSGV3)
*  -->  VALUE(P_MSGV4)
*---------------------------------------------------------------------*
FORM APPEND_MANDTAB
  USING VALUE(P_ACTAB) TYPE C
        VALUE(P_FIELDNAME) TYPE C
        VALUE(P_MSGID) LIKE SY-MSGID
        VALUE(P_MSGNO) LIKE SY-MSGNO
        VALUE(P_MSGV1) LIKE SY-MSGV1
        VALUE(P_MSGV2) LIKE SY-MSGV2
        VALUE(P_MSGV3) LIKE SY-MSGV3
        VALUE(P_MSGV4) LIKE SY-MSGV4.
  CLEAR MANDTAB.
  MANDTAB-TAB   = P_ACTAB.
  MANDTAB-FIELDNAME = P_FIELDNAME.                          "Note482142
  MANDTAB-MSGID = P_MSGID.
  MANDTAB-MSGNO = P_MSGNO.
  MANDTAB-MSGV1 = P_MSGV1.
  MANDTAB-MSGV2 = P_MSGV2.
  MANDTAB-MSGV3 = P_MSGV3.
  MANDTAB-MSGV4 = P_MSGV4.
  APPEND MANDTAB.
  CLEAR MANDTAB.
ENDFORM.                    "append_mandtab

*&---------------------------------------------------------------------*
*&      Form  BASELINEDATE_CHECK
*&---------------------------------------------------------------------*
*--------- Is the baseline date not too far away from BLDAT / SY-DATUM ?
FORM BASELINEDATE_CHECK.

*------- ZFBDT plausibel ? ---------------------------------------------
  IF  BSEG-ZFBDT NE 0
  AND BKPF-BLDAT NE 0.
    REFE = ABS( BSEG-ZFBDT(4) - SY-DATUM(4) ).
    IF REFE > 99.
      IF 1 = 2. MESSAGE E729. ENDIF.                        "Note434037
      CALL FUNCTION 'CUSTOMIZED_MESSAGE'                    "Note434037
        EXPORTING                                           "Note434037
          I_ARBGB = 'F5'                                    "Note434037
          I_DTYPE = 'S'                                     "Note434037
          I_MSGNR = '729'.                                  "Note434037
    ENDIF.
    REFE = BSEG-ZFBDT - BKPF-BLDAT.
    IF REFE > 365.
      MESSAGE W430 WITH REFE.
    ENDIF.
  ENDIF.

ENDFORM.                               " BASELINEDATE_CHECK
**&---------------------------------------------------------------------*
**&      Form  payment_cond_due_date
**&---------------------------------------------------------------------*
**       determine due date and send warnng if NETDT < BUDAT
**----------------------------------------------------------------------*
*FORM PAYMENT_COND_DUE_DATE USING
*     VALUE(NO_WARNING) TYPE XFELD.
*  STATICS: WARNING_SENT.
*  DATA: OLD_NETDT LIKE FAEDE-NETDT.                      "Note 565953
*
*  CHECK NOT BSEG-ZFBDT IS INITIAL.                          "P00K009405
*  FAEDE-SHKZG = BSEG-SHKZG.
*  FAEDE-KOART = KOART.
*  FAEDE-ZFBDT = BSEG-ZFBDT.
*  FAEDE-ZBD1T = BSEG-ZBD1T.
*  FAEDE-ZBD2T = BSEG-ZBD2T.
*  FAEDE-ZBD3T = BSEG-ZBD3T.
*  FAEDE-REBZG = BSEG-REBZG.
*  FAEDE-REBZT = BSEG-REBZT.
*  FAEDE-BLDAT = BKPF-BLDAT.
*  CALL FUNCTION 'DETERMINE_DUE_DATE'
*    EXPORTING
*      I_FAEDE = FAEDE
*    IMPORTING
*      E_FAEDE = FAEDE
*    EXCEPTIONS
*      OTHERS  = 1.
*  OLD_NETDT = ZINVFO-NETDT.                               "Note 565953
*  ZINVFO-NETDT = FAEDE-NETDT.
*  IF ZINVFO-NETDT NE OLD_NETDT.                           "Note 565953
**     Due date changed: sent warning.                      "Note 565953
*    WARNING_SENT = SPACE.                                "Note 565953
*  ENDIF.                                                 "Note 565953
*  CHECK NO_WARNING = SPACE AND WARNING_SENT = SPACE.
*  CHECK: XDERIVE IS INITIAL.                                "Note653053
*  IF FAEDE-NETDT < SY-DATLO
*     AND SY-SUBRC = 0
*     AND G_STATUS NE '4'.                                   "Note485043
*    IF 1 = 2. MESSAGE W149 WITH ''. ENDIF.
*    WRITE FAEDE-NETDT TO CHAR(10) DD/MM/YYYY.
*    CALL FUNCTION 'CUSTOMIZED_MESSAGE'
*      EXPORTING
*        I_ARBGB = 'F5'
*        I_DTYPE = 'W'
*        I_MSGNR = '149'
*        I_VAR01 = CHAR(10).
*    WARNING_SENT = 'X'.
*  ENDIF.
*ENDFORM.                             " payment_cond_due_date

*&---------------------------------------------------------------------*
*&      Form  PAYMENT_COND_ERR_NET_SPLIT
*&---------------------------------------------------------------------*
FORM PAYMENT_COND_ERR_NET_SPLIT.

  CHECK XDERIVE IS INITIAL.                                 "Note685656

  IF  BKPF-XNETB NE SPACE
  AND T052-XSPLT NE SPACE.
    MESSAGE E552.
  ENDIF.

ENDFORM.                             " PAYMENT_COND_ERR_NET_SPLIT
*&---------------------------------------------------------------------*
*&      Form  PAYMENT_COND_SET_SPLIT_IND
*&---------------------------------------------------------------------*
FORM PAYMENT_COND_SET_SPLIT_IND.
  IF T052-XSPLT NE SPACE.
    BSEZ-XSPLT = 'X'.
  ELSE.
    BSEZ-XSPLT = SPACE.
  ENDIF.
ENDFORM.                             " PAYMENT_COND_SET_SPLIT_IND
*&---------------------------------------------------------------------*
*&      Module  RESET_CASH_FORECAST  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE RESET_CASH_FORECAST INPUT.
  IF SY-UCOMM NE 'BACK'
   AND SY-UCOMM NE 'CANCEL'
   AND SY-UCOMM NE 'EXIT'
   AND SY-UCOMM NE 'SOC_01'
    AND SY-UCOMM NE 'B03'
    AND SY-UCOMM NE 'EBR2'.

  CHECK BKPF-GLVOR EQ 'RMRP'.
  CHECK G_AKTYP NE 'A'.

  IF BSEZ-XFDLEV IS INITIAL.
    CLEAR: ZINVFO-FDLEV, BSEG-FDLEV.
  ENDIF.
  IF BSEZ-XFDTAG IS INITIAL.
    CLEAR: ZINVFO-FDTAG, BSEG-FDTAG.
  ENDIF.
  endif.
ENDMODULE.                 " RESET_CASH_FORECAST  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_PAYMENT_CURRENCY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_PAYMENT_CURRENCY INPUT.
  CHECK G_AKTYP NE 'A'.
  CHECK BSEG-WRBTR NE 0.
  CHECK BSEG-REBZT CA ' V'.
*check expired currency
  CALL FUNCTION 'CURRENCY_CODE_CHECK'
    EXPORTING
      I_OBJECT        = 'BKPF'
      I_BUKRS         = BKPF-BUKRS
      I_CURRENCY_CODE = BSEG-PYCUR
      I_BUDAT         = BKPF-BUDAT
      I_BLDAT         = BKPF-BLDAT
      I_WWERT         = BKPF-WWERT
      I_TCODE         = SY-TCODE
      I_AWTYP         = 'BKPF'
      I_BLART         = BKPF-BLART.
  CALL FUNCTION 'FI_PAYMENT_CURRENCY_CHECK'
    EXPORTING
      I_BUKRS = BSEG-BUKRS
      I_WAERS = BKPF-WAERS
      I_WWERT = BKPF-WWERT
      I_KURSF = BKPF-KURSF
      I_WRBTR = BSEG-WRBTR
      I_PYCUR = BSEG-PYCUR
      I_PYAMT = BSEG-PYAMT
      I_REBZT = BSEG-REBZT.
ENDMODULE.                 " CHECK_PAYMENT_CURRENCY  INPUT
*&---------------------------------------------------------------------*
*&      Module  HOUSEBANK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HOUSEBANK INPUT.
  IF SY-UCOMM NE 'BACK'
   AND SY-UCOMM NE 'CANCEL'
   AND SY-UCOMM NE 'EXIT'
   AND SY-UCOMM NE 'SOC_01'
    AND SY-UCOMM NE 'B03'
    AND SY-UCOMM NE 'EBR2'.

  CHECK G_STATUS NE 'A'.
  CALL FUNCTION 'LINEITEM_CHECK_HOUSEBANK'
    EXPORTING
      I_BUKRS = BSEG-BUKRS
      I_HBKID = BSEG-HBKID
      I_BUPLA = BSEG-BUPLA.
endif.
ENDMODULE.                 " HOUSEBANK  INPUT
*&---------------------------------------------------------------------*
*&      Module  BANKTYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE BANKTYPE INPUT.
  CHECK G_STATUS NE 'A'.
  CALL FUNCTION 'LINEITEM_CHECK_BANKTYPE'
    EXPORTING
      I_BUKRS      = BSEG-BUKRS
      I_KOART      = KOART
      I_BVTYP      = BSEG-BVTYP
      I_LIFNR      = BSEG-LIFNR
      I_KUNNR      = BSEG-KUNNR
      I_XVERR      = KNB1-XVERR
      I_KNA1_LIFNR = KNA1-LIFNR
      I_EMPFB      = BSEG-EMPFB
      I_FILKD      = BSEG-FILKD.
  PERFORM ERROR_BVTYP_ALTERNATIVE_PAYE.
ENDMODULE.                 " BANKTYPE  INPUT
*&---------------------------------------------------------------------*
*&      Form  ERROR_BVTYP_ALTERNATIVE_PAYE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ERROR_BVTYP_ALTERNATIVE_PAYE .
  DATA: XCPDK LIKE BSEG-XCPDD.
  CASE KOART.
    WHEN 'K'.
      XCPDK = LFA1-XCPDK.
    WHEN 'D'.
      XCPDK = KNA1-XCPDK.
  ENDCASE.
  IF  XCPDK = SPACE
  AND BSEC-NAME1 NE SPACE
  AND BSEG-BVTYP NE SPACE.
    MESSAGE W112(F5A).
  ENDIF.
ENDFORM.                    " ERROR_BVTYP_ALTERNATIVE_PAYE
*&---------------------------------------------------------------------*
*&      Module  INSTRUCTION_KEYS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INSTRUCTION_KEYS INPUT.
  DATA FIELD(61).
  CHECK G_STATUS NE 'A'.
  GET CURSOR FIELD FIELD.
  SET CURSOR FIELD 'ZINVFO-DTWS1'.
  CALL FUNCTION 'FI_PAYMENT_INSTRUCTION_CHECK'
    EXPORTING
      I_COMPANY            = BSEG-BUKRS
      I_BANKID             = BSEG-HBKID
      I_INSTRUCTION_NUMBER = '1'
      I_INSTRUCTION        = BSEG-DTWS1.
  SET CURSOR FIELD 'ZINVFO-DTWS2'.
  CALL FUNCTION 'FI_PAYMENT_INSTRUCTION_CHECK'
    EXPORTING
      I_COMPANY            = BSEG-BUKRS
      I_BANKID             = BSEG-HBKID
      I_INSTRUCTION_NUMBER = '2'
      I_INSTRUCTION        = BSEG-DTWS2.
  SET CURSOR FIELD 'ZINVFO-DTWS3'.
  CALL FUNCTION 'FI_PAYMENT_INSTRUCTION_CHECK'
    EXPORTING
      I_COMPANY            = BSEG-BUKRS
      I_BANKID             = BSEG-HBKID
      I_INSTRUCTION_NUMBER = '3'
      I_INSTRUCTION        = BSEG-DTWS3.
  SET CURSOR FIELD 'ZINVFO-DTWS4'.
  CALL FUNCTION 'FI_PAYMENT_INSTRUCTION_CHECK'
    EXPORTING
      I_COMPANY            = BSEG-BUKRS
      I_BANKID             = BSEG-HBKID
      I_INSTRUCTION_NUMBER = '4'
      I_INSTRUCTION        = BSEG-DTWS4.
  SET CURSOR FIELD FIELD.
ENDMODULE.                 " INSTRUCTION_KEYS  INPUT
*&---------------------------------------------------------------------*
*&      Module  HLP_ZTERM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HLP_ZTERM INPUT.
  LOOP AT SCREEN.
    CHECK SCREEN-NAME = 'ZINVFO-ZTERM' OR SCREEN-NAME = 'ACSPLT-ZTERM'.
    IF SCREEN-INPUT = '1'.
      XSHOW = SPACE.
    ELSE.
      XSHOW = 'X'.
    ENDIF.
    EXIT.
  ENDLOOP.

*------- Eingabewert für generische Suche besorgen ---------------------
  PERFORM DYNP_VALUES_READ USING 'ZINVFO-ZTERM' F4RCODE.
  IF F4RCODE = 0.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
*SORT F4HLP . "JOROZCO 28.01.2020
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
    READ TABLE F4HLP INDEX 1.
*    bseg-zterm = f4hlp-fieldvalue.
    ZINVFO-ZTERM = F4HLP-FIELDVALUE.                        "Note 607469
  ENDIF.

  CALL FUNCTION 'FI_F4_ZTERM'
    EXPORTING
      I_KOART = KOART
      I_ZTERM = ZINVFO-ZTERM
      I_XSHOW = XSHOW
    IMPORTING
      E_ZTERM = ZTERM.
  IF NOT ZTERM IS INITIAL
  AND    XSHOW IS INITIAL.
    IF SY-DYNGR = 'SPLT'.
      ACSPLT-ZTERM = ZTERM.
    ELSE.
      ZINVFO-ZTERM = ZTERM.
    ENDIF.
  ENDIF.

ENDMODULE.                 " HLP_ZTERM  INPUT
*&---------------------------------------------------------------------*
*&      Module  HLP_EMPFB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HLP_EMPFB INPUT.
  FILKD = BSEG-FILKD.
  KUNNR = BSEG-KUNNR.
  LIFNR = BSEG-LIFNR.

*----------- Read master data of head office ---------------------------
  IF KOART = 'K'.
    IF  LFB1-LIFNR = LIFNR
    AND LFB1-BUKRS = BSEG-BUKRS.
      F4LFB1_Z = LFB1.
    ELSEIF *LFB1-LIFNR = LIFNR
    AND    *LFB1-BUKRS = BSEG-BUKRS.
      F4LFB1_Z = *LFB1.
    ELSE.
      SELECT SINGLE * FROM  LFB1 INTO F4LFB1_Z
                      WHERE LIFNR = LIFNR
                      AND   BUKRS = BSEG-BUKRS.
    ENDIF.

  ELSEIF KOART = 'D'.
    IF  KNB1-KUNNR = KUNNR
    AND KNB1-BUKRS = BSEG-BUKRS.
      F4KNB1_Z = KNB1.
    ELSEIF *KNB1-KUNNR = KUNNR
    AND    *KNB1-BUKRS = BSEG-BUKRS.
      F4KNB1_Z = *KNB1.
    ELSE.
      SELECT SINGLE * FROM  KNB1 INTO F4KNB1_Z
                      WHERE KUNNR = KUNNR
                      AND   BUKRS = BSEG-BUKRS.
    ENDIF.
  ENDIF.

*------- FB-Aufruf -----------------------------------------------------
  IF KOART = 'K'.
    CALL FUNCTION 'FI_VENDOR_ALTERN_PAYERS_READ'
      EXPORTING
        I_LIFNR            = LIFNR
        I_FILKD            = FILKD
        I_BUKRS            = BSEG-BUKRS
        I_LFB1_HEAD_OFFICE = F4LFB1_Z
      TABLES
        T_ZEMTAB           = ZEMTAB.
  ELSEIF KOART  = 'D'.
    CALL FUNCTION 'FI_CUSTOMER_ALTERN_PAYEES_READ'
      EXPORTING
        I_KUNNR            = KUNNR
        I_FILKD            = FILKD
        I_BUKRS            = BSEG-BUKRS
        I_KNB1_HEAD_OFFICE = F4KNB1_Z
      TABLES
        T_ZEMTAB           = ZEMTAB.
  ENDIF.

*---------- ZEMTAB contains possible values ----------------------------
  DESCRIBE TABLE ZEMTAB LINES SY-TFILL.
  IF SY-TFILL = 0.
    MESSAGE I747.
  ENDIF.
  CHECK SY-TFILL > 0.

*------- Fill table of fieldnames --------------------------------------
  REFRESH FLDTAB.
  CLEAR FLDTAB.
  FLDTAB-TABNAME    = 'IZEMTAB'.
  FLDTAB-FIELDNAME  = 'EMPFB'.
  FLDTAB-SELECTFLAG = 'X'.
  APPEND FLDTAB.
  CLEAR FLDTAB.
  FLDTAB-TABNAME    = 'IZEMTAB'.
  FLDTAB-FIELDNAME  = 'NAME1'.
  APPEND FLDTAB.
  CLEAR FLDTAB.
  FLDTAB-TABNAME    = 'IZEMTAB'.
  FLDTAB-FIELDNAME  = 'ORT01'.
  APPEND FLDTAB.
  CLEAR FLDTAB.
  FLDTAB-TABNAME    = 'IZEMTAB'.
  FLDTAB-FIELDNAME  = 'STRAS'.
  APPEND FLDTAB.

*------- Fill Values for Function Module Call --------------------------
  REFRESH VALTAB.
  LOOP AT ZEMTAB.
    VALTAB-FELD = ZEMTAB-EMPFB.
    APPEND VALTAB.
    VALTAB-FELD = ZEMTAB-NAME1.
    APPEND VALTAB.
    VALTAB-FELD = ZEMTAB-ORT01.
    APPEND VALTAB.
    IF ZEMTAB-STRAS NE SPACE.
      VALTAB-FELD = ZEMTAB-STRAS.
    ELSEIF ZEMTAB-PFACH NE SPACE.
      CONCATENATE 'Postfach:'(019) ZEMTAB-PFACH INTO VALTAB-FELD.
    ELSE.
      VALTAB-FELD = SPACE.
    ENDIF.
    APPEND VALTAB.
  ENDLOOP.

*------- F4 Dialog -----------------------------------------------------
  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
    EXPORTING
      DISPLAY      = SPACE
      FIELDNAME    = 'EMPFB'
      TABNAME      = 'ZINVFO'
    IMPORTING
      SELECT_VALUE = EMPFB
    TABLES
      FIELDS       = FLDTAB
      VALUETAB     = VALTAB.
  IF NOT EMPFB IS INITIAL.
    ZINVFO-EMPFB = EMPFB.
  ENDIF.
ENDMODULE.                 " HLP_EMPFB  INPUT
*&---------------------------------------------------------------------*
*&      Module  HLP_BVTYP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HLP_BVTYP INPUT.
  IF KOART = 'K'.
    LIFNR = BSEG-LIFNR.
  ELSE.
    IF KNB1-XVERR <> SPACE.
      LIFNR = KNA1-LIFNR.
    ENDIF.
    IF LIFNR = SPACE.
      KUNNR = BSEG-KUNNR.
    ENDIF.
  ENDIF.

*------- Read alternative payee from dynpro ----------------------------
  PERFORM DYNP_VALUES_READ USING 'ZINVFO-EMPFB' F4RCODE.    "Note 206687
  IF F4RCODE = 0.                                          "Note 206687
*ReSQ: No Need Of Change Internal Table F4HLP Already Sorted
    READ TABLE F4HLP INDEX 1.                              "Note 206687
    IF NOT F4HLP-FIELDVALUE IS INITIAL.                    "Note 206687
      PERFORM ALPHAFORMAT(SAPFF001)                        "Note 206687
        USING F4HLP-FIELDVALUE                             "Note 206687
              BSEG-EMPFB.                                  "Note 206687
    ENDIF.                                                 "Note 206687
  ENDIF.                                                   "Note 206687

*------- Alternative payee/payer may be filled into LIFNR / KUNNR ------
  CALL FUNCTION 'LINEITEM_REPLACE_WITH_ALT_PAYE'
    EXPORTING
      I_FILKD = BSEG-FILKD
      I_BUKRS = BSEG-BUKRS
      I_EMPFB = BSEG-EMPFB                           "Note 206687
    CHANGING
      C_LIFNR = LIFNR
      C_KUNNR = KUNNR.

*------- Partnerbanktypen anzeigen -------------------------------------
  CALL FUNCTION 'FI_F4_BVTYP'
    EXPORTING
      I_KUNNR = KUNNR
      I_LIFNR = LIFNR
      I_XSHOW = SPACE
    IMPORTING
      E_BVTYP = BVTYP.
  IF NOT BVTYP IS INITIAL.
    ZINVFO-BVTYP = BVTYP.
  ENDIF.
ENDMODULE.                 " HLP_BVTYP  INPUT
*&---------------------------------------------------------------------*
*&      Module  HLP_DTWS1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HLP_DTWS1 INPUT.
  PERFORM HLP_DTWSX USING '1' CHANGING ZINVFO-DTWS1.
ENDMODULE.                 " HLP_DTWS1  INPUT
*&---------------------------------------------------------------------*
*&      Form  HLP_DTWSX
*&---------------------------------------------------------------------*
FORM HLP_DTWSX USING    DTWSF LIKE T015W1-DTWSF
               CHANGING DTWSX LIKE T015W1-DTWSX.
  PERFORM DYNP_VALUES_READ USING 'ZINVFO-HBKID' F4RCODE.
  IF F4RCODE EQ 0.
    READ TABLE F4HLP INDEX 1.
    ZINVFO-HBKID = F4HLP-FIELDVALUE.
  ENDIF.
  CALL FUNCTION 'FI_PAYMENT_INSTRUCTION_F4'
    EXPORTING
      I_COMPANY            = BSEG-BUKRS
      I_BANKID             = ZINVFO-HBKID
      I_INSTRUCTION_NUMBER = DTWSF
    IMPORTING
      E_INSTRUCTION        = DTWSX
    EXCEPTIONS
      OTHERS               = 4.
  IF SY-SUBRC NE 0. ENDIF.
ENDFORM.                               " HLP_DTWSX
*&---------------------------------------------------------------------*
*&      Module  HLP_DTWS2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HLP_DTWS2 INPUT.
  PERFORM HLP_DTWSX USING '2' CHANGING ZINVFO-DTWS2.
ENDMODULE.                 " HLP_DTWS2  INPUT
*&---------------------------------------------------------------------*
*&      Module  HLP_DTWS3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HLP_DTWS3 INPUT.
  PERFORM HLP_DTWSX USING '3' CHANGING ZINVFO-DTWS3.
ENDMODULE.                 " HLP_DTWS3  INPUT
*&---------------------------------------------------------------------*
*&      Module  HLP_DTWS4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HLP_DTWS4 INPUT.
  PERFORM HLP_DTWSX USING '4' CHANGING ZINVFO-DTWS4.
ENDMODULE.                 " HLP_DTWS4  INPUT
