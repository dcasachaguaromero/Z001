*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZMON_FACT_PAI
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI INPUT.

  CASE OK_CODE.
    WHEN 'EXIT' OR 'BACK' OR 'CANC'.
      PERFORM EXIT_PROGRAM.
    WHEN OTHERS.
*
      FREE: ORDER_ITEMS_IN, ORDER_ITEMS_INX, ORDER_PARTNERS, ORDER_SCHEDULES_IN, ORDER_SCHEDULES_INX, BILL_DATA, RETURN.
      CLEAR: ORDER_ITEMS_IN, ORDER_ITEMS_INX, ORDER_PARTNERS, ORDER_SCHEDULES_IN, ORDER_SCHEDULES_INX,
             GT_CABPEDEXT, ORDER_HEAD, ORDER_HEADX, BILL_DATA.
      CALL METHOD TREE1->GET_SELECTED_NODES
        CHANGING
          CT_INDEX_OUTTAB = IND_OUT.
*
      CLEAR: TMP_INDEX, LS_IND_OUT.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
SORT IND_OUT .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
      READ TABLE IND_OUT INTO LS_IND_OUT INDEX 1.
      CHECK SY-SUBRC = 0.
      TMP_INDEX = LS_IND_OUT.
      CHECK TMP_INDEX > 0.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
SORT GT_CABPEDEXT .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
      READ TABLE GT_CABPEDEXT INDEX TMP_INDEX.
*
      PERFORM COMPLETA_CABECERA_ORDEN USING GT_CABPEDEXT-VKORG
                                            GT_CABPEDEXT-VTWEG
                                            GT_CABPEDEXT-SPART
                                            SY-DATUM
                                            SPACE
                                            SPACE
                                            GT_CABPEDEXT-ZBLART
                                            GT_CABPEDEXT-VKBUR
                                            SPACE
                                            SPACE
                                            SPACE
                                            GT_CABPEDEXT-ZELECTRONICO
                                       CHANGING  ORDER_HEAD ORDER_HEADX.
*
      PERFORM COMPLETA_PARTNER TABLES ORDER_PARTNERS
                                USING BILL_DATA GT_CABPEDEXT-ZRUT_CLI_PAGADOR GT_CABPEDEXT-ZRUT_CLI_FACT.
      CLEAR: LS_DETPEDEXT, POS.
      SELECT * INTO LS_DETPEDEXT FROM ZDETPEDEXT WHERE ZNUM_DOC_CORE EQ GT_CABPEDEXT-ZNUM_DOC_CORE.
        ADD 1 TO POS.
        PERFORM COMPLETA_POSICION TABLES ORDER_ITEMS_IN ORDER_ITEMS_INX ORDER_PARTNERS
                                         ORDER_SCHEDULES_IN ORDER_SCHEDULES_INX
                                         ORDER_CONDITIONS_IN ORDER_CONDITIONS_INX
                                   USING GT_CABPEDEXT LS_DETPEDEXT POS.
        APPEND: ORDER_ITEMS_IN, ORDER_ITEMS_INX, ORDER_PARTNERS, ORDER_SCHEDULES_IN, ORDER_SCHEDULES_INX.
        CLEAR: ORDER_ITEMS_IN, ORDER_ITEMS_INX, ORDER_PARTNERS, ORDER_SCHEDULES_IN, ORDER_SCHEDULES_INX.

      ENDSELECT.
*
      CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
        EXPORTING
          ORDER_HEADER_IN      = ORDER_HEAD
          ORDER_HEADER_INX     = ORDER_HEADX
        IMPORTING
          SALESDOCUMENT        = SALESDOCUMENT
        TABLES
          RETURN               = RETURN
          ORDER_ITEMS_IN       = ORDER_ITEMS_IN
          ORDER_ITEMS_INX      = ORDER_ITEMS_INX
          ORDER_PARTNERS       = ORDER_PARTNERS
          ORDER_SCHEDULES_IN   = ORDER_SCHEDULES_IN
          ORDER_SCHEDULES_INX  = ORDER_SCHEDULES_INX
          ORDER_CONDITIONS_IN  = ORDER_CONDITIONS_IN
          ORDER_CONDITIONS_INX = ORDER_CONDITIONS_INX.
*
      IF SALESDOCUMENT IS INITIAL.
        READ TABLE RETURN WITH KEY TYPE = 'E'.
        IF SY-SUBRC = 0.
          SELECT SINGLE * FROM ZCABPEDEXT WHERE ZNUM_DOC_CORE EQ GT_CABPEDEXT-ZNUM_DOC_CORE.
          IF SY-SUBRC = 0.
            ZCABPEDEXT-FEC_CAR   = SY-DATLO.
            ZCABPEDEXT-HOR_CAR   = SY-TIMLO.
            ZCABPEDEXT-ERROR     = 'X'.
            ZCABPEDEXT-LOG_ERROR = RETURN-MESSAGE.
            UPDATE ZCABPEDEXT.
          ENDIF.
        ENDIF.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = TRUE.
*
        BILL_DATA-SALESORG   = GT_CABPEDEXT-VKORG.
        BILL_DATA-DISTR_CHAN = GT_CABPEDEXT-VTWEG.
        BILL_DATA-DIVISION   = GT_CABPEDEXT-SPART.
        BILL_DATA-ORDBILLTYP = ORDER_HEAD-DOC_TYPE.
        BILL_DATA-BILL_DATE  = SY-DATUM.
        BILL_DATA-REF_DOC    = SALESDOCUMENT.
        BILL_DATA-REF_DOC_CA = 'V'.
        APPEND BILL_DATA.
*
        CALL FUNCTION 'BAPI_BILLINGDOC_CREATEMULTIPLE'
          TABLES
            BILLINGDATAIN = BILL_DATA
            RETURN        = RETURN_FAC
            SUCCESS       = SUCCESS.

        READ TABLE RETURN_FAC WITH KEY TYPE = 'E'.
        IF SY-SUBRC NE 0.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
SORT SUCCESS .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
          READ TABLE SUCCESS INDEX 1.
          SELECT SINGLE * FROM ZCABPEDEXT WHERE ZNUM_DOC_CORE EQ GT_CABPEDEXT-ZNUM_DOC_CORE.
          IF SY-SUBRC = 0.
            ZCABPEDEXT-PEDIDO    = SALESDOCUMENT.
            ZCABPEDEXT-FACTURA   = SUCCESS-BILL_DOC.
            ZCABPEDEXT-FEC_CAR   = SY-DATLO.
            ZCABPEDEXT-HOR_CAR   = SY-TIMLO.
            ZCABPEDEXT-ERROR     = SPACE.
            ZCABPEDEXT-LOG_ERROR = SPACE.
            UPDATE ZCABPEDEXT.
          ENDIF.
        ELSE.
          ZCABPEDEXT-FEC_CAR   = SY-DATLO.
          ZCABPEDEXT-HOR_CAR   = SY-TIMLO.
          ZCABPEDEXT-ERROR     = 'X'.
          ZCABPEDEXT-LOG_ERROR = RETURN_FAC-MESSAGE.
          UPDATE ZCABPEDEXT.
        ENDIF.
      ENDIF.
      COMMIT WORK.
      READ TABLE GT_CABPEDEXT WITH KEY ZNUM_DOC_CORE = ZCABPEDEXT-ZNUM_DOC_CORE.
      IF SY-SUBRC = 0.
        MOVE-CORRESPONDING ZCABPEDEXT TO GT_CABPEDEXT.
        SELECT SINGLE KUNNR INTO GT_CABPEDEXT-ZRUT_CLI_PAGADOR FROM KNA1 WHERE STCD1 EQ ZCABPEDEXT-ZRUT_CLI_PAGADOR.
        SELECT SINGLE KUNNR INTO GT_CABPEDEXT-ZRUT_CLI_FACT    FROM KNA1 WHERE STCD1 EQ ZCABPEDEXT-ZRUT_CLI_FACT.
        CASE ZCABPEDEXT-ERROR.
          WHEN TRUE.
            NAME = 'ICON_LED_RED'.
            INFO = 'Documento con error'.
          WHEN OTHERS.
            IF NOT ZCABPEDEXT-PEDIDO IS INITIAL AND NOT ZCABPEDEXT-FACTURA IS INITIAL.
              NAME = 'ICON_LED_GREEN'.
              INFO = 'Documento tratado'.
            ELSE.
              NAME = 'ICON_LED_YELLOW'.
              INFO = 'Documento sin tratar'.
            ENDIF.
        ENDCASE.

        CALL FUNCTION 'ICON_CREATE'
          EXPORTING
            NAME                  = NAME
            INFO                  = INFO
            ADD_STDINF            = SPACE
          IMPORTING
            RESULT                = GT_CABPEDEXT-STATUS
          EXCEPTIONS
            ICON_NOT_FOUND        = 1
            OUTPUTFIELD_TOO_SHORT = 2
            OTHERS                = 3.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
SORT GT_CABPEDEXT .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
        MODIFY GT_CABPEDEXT INDEX SY-TABIX.
      ENDIF.
      CALL METHOD TREE1->REFRESH_TABLE_DISPLAY
        EXPORTING
          IT_SORT = GT_SORT[].

      CALL METHOD CL_GUI_CFW=>DISPATCH.
  ENDCASE.
  CLEAR OK_CODE.
*
ENDMODULE.                    "pai INPUT
