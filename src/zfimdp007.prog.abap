*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFIMDP007 .
*----------------------------------------------------------------------*
TYPE-POOLS: ABAP, CNTB.

***********************************************************************
DATA:  L_GUI_DYNPRO_FIELD TYPE REF TO IF_PT_GUI_SAP_DYNPRO_FIELD,
       L_DYNPRO_ID      TYPE REC_PT_GUI_SAP_DYNPRO_ID,
       L_FIELDNAME      TYPE SCRFNAME.

************************************************************************
DATA: BEGIN OF LOG_ERRORES OCCURS 50.
        INCLUDE STRUCTURE BAPIRET1.
DATA: RUT(16) TYPE C.
DATA: ERRONEO(1) TYPE C.
DATA: END OF LOG_ERRORES.


DATA : LT_F4 TYPE LVC_T_F4 WITH HEADER LINE.
*************************************************
DATA:CUADRILLA_ORG TYPE PM0D1-SEARK.
DATA:CUADRILLA_DES TYPE PM0D1-SEARK.

*§10 define data table to handle drop down boxes
DATA: BEGIN OF GT_OUTTAB OCCURS 0.
        INCLUDE STRUCTURE CSKS .
DATA: DROP_DOWN_HANDLE TYPE INT4. "dropdown handle for a field
DATA: END OF GT_OUTTAB,
      GS_OUTTAB LIKE LINE OF GT_OUTTAB.

FIELD-SYMBOLS: <CAMPO> TYPE ANY.
DATA: P_ERROR TYPE I.
DATA: ERROR_IN_DATA TYPE C.
* data for event handling
DATA: GS_F4 TYPE LVC_S_F4,
      GT_F4 TYPE LVC_T_F4.
* data for test modus
DATA: GT_OUTTAB_TEST TYPE TABLE OF  CSKS.
** custom control and grid_application object
DATA: MY_CONTAINER   TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
*      my_application TYPE REF TO grid_appl.
DATA: CONTROL_LIST TYPE REF TO CL_GUI_CONTROL.

DATA: GT_LIST TYPE CNTO_CONTROL_LIST,
      GT_WA LIKE LINE OF GT_LIST.

************************************************
DATA:  TOTJOR   LIKE BSEG-DMBTR,
       TOTVD(14) TYPE P DECIMALS 0,
       TOTVB(14) TYPE P DECIMALS 0,
       TOTAL(14) TYPE P DECIMALS 0,
       TOTAVDM(14) TYPE P DECIMALS 0,
       TOTJORFALTA LIKE BSEG-DMBTR.
DATA: BEGIN OF MY_TAB OCCURS 100,
FIELDNAME TYPE DYNFNAM,
STEPL TYPE SYSTEPL,
*FIELDVALUE TYPE FIELDVALUE,
FIELDVALUE TYPE DYNFIELDVALUE,
FIELDINP TYPE SYCHAR01,
END OF MY_TAB.


DATA: BEGIN OF MY_DYNP OCCURS 50,
       DYNUMB LIKE D020S-DNUM,
       END OF MY_DYNP.
DATA: DYNAME TYPE D020S-PROG VALUE 'ZAVANCE_DIARIO'.
DATA: DYNUMB TYPE D020S-DNUM  VALUE '0100'.
DATA: PT_EXCLUDE TYPE UI_FUNCTIONS.
DATA REFRESH_TABLE TYPE I.
*DATA:  BEGIN OF  I_ERRORES OCCURS 50.
*        INCLUDE STRUCTURE BAPIRET2.
*DATA: END OF I_ERRORES.
DATA: VALUE(1) TYPE C.
*DATA: P_TITULO(45) TYPE C VALUE 'Log Validacion'.
* Variables Globales.
DATA  UPPER_ROW(2) TYPE C VALUE '45'.
DATA  LOWER_ROW(2) TYPE C VALUE '0'.
DATA  LEFT_COL(2) TYPE C  VALUE '60'.
DATA  RIGHT_COL(2) TYPE C VALUE '50'.
DATA  VALOR(5) TYPE P DECIMALS 2.
DATA  DESCUENTO(1) TYPE C.
DATA  MARGEN(1) TYPE C.
DATA  MATERIAL LIKE MARA-MATNR.
DATA  POR_IVA LIKE EKBE-WRBTR.
DATA  NEMERO(18) TYPE C.
DATA  OK_BUSCAR(5).
DATA  OK_ERROR LIKE SY-SUBRC.
DATA  STATUS(20) TYPE C.
DATA   W_RESP(01) TYPE C.
DATA   SEARK LIKE PM0D1-SEARK.
INCLUDE: <ICON>.
*********************************************
TYPES: PICT_LINE(256) TYPE C.
DATA: PICT_TAB TYPE TABLE OF PICT_LINE,
URL(255) TYPE C.

DATA: CONTAINER1 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
PRUEBA TYPE REF TO CL_GUI_PICTURE.

DATA: L_BYTECOUNT TYPE I,
L_TDBTYPE LIKE STXBITMAPS-TDBTYPE,
L_CONTENT TYPE STANDARD TABLE OF BAPICONTEN
INITIAL SIZE 0.

DATA: GRAPHIC_SIZE TYPE I.

DATA: BEGIN OF GRAPHIC_TABLE OCCURS 0,
LINE(255) TYPE X,
END OF GRAPHIC_TABLE.
*********************************************
DATA: NORMT(10) TYPE C,
      G_ORIGINAL TYPE MARA-NORMT,
      GT_TOOLBAR_EXCLUDING TYPE UI_FUNCTIONS.
DATA: R_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      R_ALV_GRID TYPE REF TO CL_GUI_ALV_GRID,
      EDITOR_OBJ TYPE REF TO CL_GUI_TEXTEDIT.

DATA OK_CODE LIKE SY-UCOMM.
***********************************************************
*DATA:  EDITOR_OBJ  TYPE REF TO CL_GUI_TEXTEDIT.
DATA:  TEXTEDIT_CUSTOM_CONTAINER TYPE  REF TO CL_GUI_CUSTOM_CONTAINER.
DATA:   LONGTEXTCONTAINER(30) TYPE C.
DATA:   LANGTEXTBILD LIKE SY-DYNNR,
        LANGTXTVKORG LIKE MVKE-VKORG,
        LANGTXTVTWEG LIKE MVKE-VTWEG,
        LANGTEXT_MATNR LIKE RMMG1-MATNR.

CONSTANTS:   LANGTEXT_OBJEKTID  LIKE THEAD-TDOBJECT VALUE 'MATERIAL',
        VERTRIEBSTEXT_OBJ  LIKE THEAD-TDOBJECT VALUE 'MVKE',
        MATNOTIZ_OBJEKTID  LIKE THEAD-TDOBJECT VALUE 'MDTXT'.

CONSTANTS:
        GRUNDDTEXT_BILD    LIKE SY-DYNNR VALUE '0001',
        IVERMTEXT_BILD     LIKE SY-DYNNR VALUE '0002',
        PRUEFTEXT_BILD     LIKE SY-DYNNR VALUE '0003',
        VERTRIEBSTEXT_BILD LIKE SY-DYNNR VALUE '0004',
        BESTELLTEXT_BILD   LIKE SY-DYNNR VALUE '0005',
        GRUNDDTXTE_BILD    LIKE SY-DYNNR VALUE '1001',
        IVERMTXTE_BILD     LIKE SY-DYNNR VALUE '1002',
        PRUEFTXTE_BILD     LIKE SY-DYNNR VALUE '1003',
        VERTRIEBSTXTE_BILD LIKE SY-DYNNR VALUE '1004',
        BESTELLTXTE_BILD   LIKE SY-DYNNR VALUE '1005'.
DATA: OBJECT_INFO LIKE TTXOB.
DATA: WORDWRAP_POSITION LIKE CL_GUI_TEXTEDIT=>M_WORDWRAP_POSITION.
DATA REFRESH_TEXTEDIT_CONTROL TYPE C.
DATA: RS_SELFIELD TYPE SLIS_SELFIELD.
******************************************************
DATA: T_SALIDA LIKE ZACGL_ITEM OCCURS 0.

DATA: CATALOGO          TYPE LVC_T_FCAT,
      IS_LAYOUT TYPE LVC_S_LAYO.

DATA: ICON_NAME(20),
      ICONOR TYPE ICONS-TEXT,
      ICONOI TYPE ICONS-TEXT.

DATA: P_PATH         LIKE RLGRAP-FILENAME.
DATA: P_C_PCE(128)   TYPE C.
DATA IT_T001 TYPE ZACGL_ITEM OCCURS 100 WITH HEADER LINE.
DATA IT_T002 TYPE ZACGL_ITEM OCCURS 100 WITH HEADER LINE.

DATA: GT_FIELDCAT    TYPE LVC_T_FCAT WITH HEADER LINE.

DATA: P_NCOLN TYPE I.
* Ole objects declaration

DATA: H_APPL  LIKE OBJ_RECORD,
      H_WORK  LIKE OBJ_RECORD,
      H_CELL  LIKE OBJ_RECORD.

.
*DATA  BUKRS   LIKE T001-BUKRS.

DATA OK_CODE_01 LIKE SY-UCOMM.
DATA OK_CODE_02 LIKE SY-UCOMM.
DATA OK_120 LIKE SY-UCOMM.
INCLUDE OLE2INCL.
DATA: P_CAMI     LIKE RLGRAP-FILENAME. "Archivo Excel
DATA: P_NLINE    LIKE SY-INDEX. "Numero aproximado de lineas



*&      Module  SET_DEFAULT_VALUES_0010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_DEFAULT_VALUES_0010 OUTPUT.

*--------- Determine always User Parameters ----------------------------
  GET PARAMETER ID 'FOP' FIELD RFOPT.
  GET PARAMETER ID 'FO2' FIELD RFOPT2.
  GET PARAMETER ID 'FO3' FIELD RFOPTE.

  IF SY-UCOMM NE 'BACK'
 AND SY-UCOMM NE 'CANCEL'
   AND SY-UCOMM NE 'EXIT'
   AND SY-UCOMM NE 'SOC_01'
    AND SY-UCOMM NE 'B03'
    AND SY-UCOMM NE 'EBR2'.



    IF FIRSTCALL = 'X'
    OR BSEG-BUKRS NE ZINVFO-BUKRS                             "Note 300358
    OR BSEG-UMSKZ NE ZINVFO-UMSKZ                             "Note 352492
    OR BKPF-BLART NE ZINVFO-BLART.                            "Note 300358
      BKPF-BUKRS = BSEG-BUKRS.
      MOVE-CORRESPONDING BKPF TO ACGL_HEAD.

      CALL FUNCTION 'DOCHEADERFIELD_INIT'
        EXPORTING
          I_T020            = T020
          I_FIRSTCALL       = FIRSTCALL
          I_KOART           = KOART
          I_BUSCS           = BUSCS
          I_DOCUMENT_EXISTS = G_DOCUMENT_EXISTS        "Note 387235
        CHANGING
          C_HEAD            = ACGL_HEAD.

      MOVE-CORRESPONDING ACGL_HEAD TO BKPF.
      IF NOT FIRSTCALL IS INITIAL.                           "Note 352492
        GET PARAMETER ID 'XTX' FIELD BKPF-XMWST.
        REPLACE 'x' WITH 'X' INTO BKPF-XMWST.               "Note438830
      ENDIF.                                                 "Note 352492
*--------- Call from MM: don't fill currency field at first call -------
      IF BKPF-GLVOR = 'RMRP'
      AND G_DOCUMENT_EXISTS IS INITIAL.                      "Note 387235
        CLEAR BKPF-WAERS.
      ENDIF.

      BSEG-BELNR = BKPF-BELNR.
      BSEG-GJAHR = BKPF-GJAHR.
      BSEG-BUKRS = ZINVFO-BUKRS.
      BKPF-BUKRS = ZINVFO-BUKRS.
      BSEG-LIFNR = ZINVFO-ACCNT.
*------------------ Company Code Info ----------------------------------
      IF FIRSTCALL = 'X' OR                                  "Note 300358
        ZINVFO-BUKRS NE BSEG-BUKRS.                           "Note 300358
        CALL FUNCTION 'FI_COMPANY_CODE_DATA'
          EXPORTING
            I_BUKRS = BKPF-BUKRS
          IMPORTING
            E_T001  = T001
          EXCEPTIONS
            OTHERS  = 4.
        IF SY-SUBRC NE 0.                                    "Note 387235
          CLEAR SY-SUBRC.                                    "Note 387235
        ENDIF.                                               "Note 387235
* (del) concatenate t001-butxt t001-ort01 into invfo-butxt "Note 216605
        CONCATENATE T001-BUKRS T001-BUTXT T001-ORT01         "Note 216605
                    INTO ZINVFO-BUTXT                         "Note 216605
                    SEPARATED BY SPACE.                      "Note 216605
* TAX-KALSM is required for tax code listbox and           "Note 300358
* MWSKZ_DEFAULT below.                                     "Note 300358
        CLEAR TAX.                                           "Note 300358
        CALL FUNCTION 'FIND_TAX_SPREADSHEET'                 "Note 300358
               EXPORTING                                     "Note 300358
                    BUCHUNGSKREIS = BKPF-BUKRS               "Note 300358
               IMPORTING                                     "Note 300358
                    SCHEMA        = TAX-KALSM                "Note 300358
              EXCEPTIONS                                     "Note 300358
                    OTHERS        = 4.                       "Note 300358
        IF SY-SUBRC NE 0.                                    "Note 387235
          CLEAR SY-SUBRC.                                    "Note 387235
        ENDIF.                                               "Note 387235
      ENDIF.                                                 "Note 300358

*-Not for Change or Display  pp document with differt comp code
* (del) check firstcall = 'X'.                             "Note 352492
*---------------- Default values for line item -------------------------
* Read TBSL, because there is a foreign key check on UMSKZ "Note 352492
      PERFORM POSTING_KEY_DETERMINE USING BSEG-UMSKZ
                                          'X'                "Note 352492
                                 CHANGING BSEG-BSCHL.
      CHECK FIRSTCALL = 'X'.                                 "Note 352492
      PERFORM MWSKZ_DEFAULT CHANGING BSEG-MWSKZ.
      PERFORM SKFBT_DEFAULT_TRIGGER CHANGING BSEZ-XSKFB.

* >>> START OF INSERTION <<<                             "P9CK114991
*   Local variable declaration ... will move to top.
      DATA: D_COMPONENT(2) TYPE C.
      DATA: COUNTRY LIKE T001-LAND1.
      TABLES:  IDBUPLA_ACTIVE.
      DATA: WA_BUPLA_ACTIVE LIKE IDBUPLA_ACTIVE.

*   Check country specific component
      CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
        EXPORTING
          BUKRS                = BKPF-BUKRS
          COMPONENT            = '**'
        IMPORTING
          ACTIVE_COMPONENT     = D_COMPONENT
          OUT_COUNTRY          = COUNTRY
        EXCEPTIONS
          COMPONENT_NOT_ACTIVE = 1
          OTHERS               = 2.
      IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ELSE.
        CASE D_COMPONENT.
*     Country specific requirement for
*       Argentina
          WHEN 'AR'.
            GET PARAMETER ID 'JEA' FIELD BKPF-BRNCH.
*       Brazil
          WHEN 'BR'.
            GET PARAMETER ID 'ID_BUPLA' FIELD BSEG-BUPLA.
*       Thailand
          WHEN 'TH'.
            GET PARAMETER ID 'JEA' FIELD BKPF-BRNCH.
            GET PARAMETER ID 'ID_BUPLA' FIELD BSEG-BUPLA.
*       Taiwan
          WHEN 'TW'.
            GET PARAMETER ID 'ID_BUPLA' FIELD BSEG-BUPLA.
*       Other countries
          WHEN OTHERS.

        ENDCASE.
        CASE D_COMPONENT.
          WHEN 'BR' OR 'KR' OR 'AR' OR 'TW' OR 'TH' OR 'IN'.
          WHEN OTHERS.
            CLEAR WA_BUPLA_ACTIVE.
            SELECT SINGLE * FROM  IDBUPLA_ACTIVE INTO
              WA_BUPLA_ACTIVE WHERE LAND1 = COUNTRY.
            IF SY-SUBRC = 0 AND WA_BUPLA_ACTIVE-ACTIVE = 'X'.
              GET PARAMETER ID 'ID_BUPLA' FIELD BSEG-BUPLA.
            ENDIF.

        ENDCASE.


      ENDIF.

*------------ If desired: determine account from ESR-Data --------------
      IF RFOPT-XKESR = 'X' AND FIRSTCALL = 'X' AND KOART = 'K'.
        CALL FUNCTION 'COUNTRY_CODE_SAP_TO_ISO'              "Note1141901
          EXPORTING                                          "Note1141901
            SAP_CODE        = T001-LAND1                     "Note1141901
          IMPORTING                                          "Note1141901
            ISO_CODE        = T005-INTCA                     "Note1141901
          EXCEPTIONS                                         "Note1141901
            NOT_FOUND       = 1                              "Note1141901
            OTHERS          = 2.                             "Note1141901
        IF  SY-SUBRC   = 0                                   "Note1141901
        AND T005-INTCA = 'CH'.           "Switzerland        "Note1141901
          CALL FUNCTION 'LINEITEM_ESR_CHECK'                 "Note1141901
            EXPORTING                                        "Note1141901
              I_LAND           = T001-LAND1                  "Note1141901
              I_BUKRS          = BKPF-BUKRS                  "Note1141901
              I_SHKZG          = BSEG-SHKZG                  "Note1141901
              I_WAERS          = BKPF-WAERS                  "Note1141901
            EXCEPTIONS                                       "Note1141901
              NOT_ACTIVE       = 1                           "Note1141901
              CURRENCY         = 2                           "Note1141901
              SHKZG            = 3                           "Note1141901
              OTHERS           = 4.                          "Note1141901
          IF SY-SUBRC = 0.                                   "Note1141901
            BSEG-LIFNR = '*'.
          ENDIF.                                             "Note1141901
        ENDIF.                                               "Note1141901
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " SET_DEFAULT_VALUES_0010  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  POSTING_KEY_DETERMINE
*&---------------------------------------------------------------------*
FORM POSTING_KEY_DETERMINE
     USING VALUE(P_UMSKZ) TYPE UMSKZ
           VALUE(P_PBO) TYPE BOOLEAN                     "Note 352492
     CHANGING P_BSCHL TYPE BSCHL.
  IF BKPF-GLVOR = GLVOR_RMRP.                               "Note934127
*------- posting key fixed '21'/'31' for MM --------------- "Note934127*
    MOVE: C_BSLKS TO BSCHS,                                 "Note934127
          C_BSLKH TO BSCHH.                                 "Note934127
  ELSE.                                                     "Note934127
    CLEAR KTOSL.
*---------bschl determine from buscs not for pp documents
    CASE KOART.
      WHEN 'D'.
        IF  P_UMSKZ NE SPACE.
          KTOSL = 'AGX'.
        ELSE.
          KTOSL = 'AGD'.
        ENDIF.
      WHEN 'K'.
        IF P_UMSKZ NE SPACE.
          KTOSL = 'EGX'.
        ELSE.
          KTOSL = 'EGK'.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
    BSEG-KTOSL = KTOSL.
    CLEAR: BSCHH, BSCHS.
    CALL FUNCTION 'LINEITEM_POSTINGKEYDETERMINE'
      EXPORTING
        I_KTOSL         = KTOSL
      IMPORTING
        E_BSCHH         = BSCHH
        E_BSCHS         = BSCHS
      EXCEPTIONS
        KTOSL_NOT_VALID = 1
        OTHERS          = 2.
    IF SY-SUBRC <> 0.
      CLEAR: P_BSCHL.
      MESSAGE E100 WITH 'T030B' KTOSL.
    ENDIF.
  ENDIF.                                                    "Note934127
*                                                           "Note934127
*default shkzg necessary for screen layout (esr-data)
  IF ( KOART = 'D' AND BUSCS = 'R' )
    OR ( KOART = 'K' AND BUSCS = 'G' ).
    P_BSCHL = BSCHS.
    BSEG-SHKZG = 'S'.
  ELSE.
    P_BSCHL = BSCHH.
    BSEG-SHKZG = 'H'.
  ENDIF.
  CALL FUNCTION 'FI_POSTING_KEY_DATA'
    EXPORTING
      I_BSCHL       = P_BSCHL
      I_UMSKZ       = BSEG-UMSKZ
    IMPORTING
      E_T074U       = T074U
      E_TBSL        = TBSL
      E_TBSLT       = TBSLT
    EXCEPTIONS
      ERROR_MESSAGE = 1.
* 1. PBO: no message if bschl request umskz
  IF SY-SUBRC = 1.
* (del) if not ( firstcall = 'X'                           "Note 352492
    IF NOT ( P_PBO = 'X'                                 "Note 352492
    AND TBSL-XSONU NE SPACE ).
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH
              SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
*special gl indicator with class '' is only allowed
  CHECK P_PBO IS INITIAL.                                "Note 352492
  IF T074U-UMSKS CA 'AW'.
    MESSAGE E246 WITH T074U-UMSKS BSEG-UMSKZ.
*no statistic posting
  ELSEIF T074U-MERKP NE SPACE.
    MESSAGE E875 WITH BSEG-UMSKZ.
  ENDIF.

ENDFORM.                             " POSTING_KEY_DETERMINE
*&---------------------------------------------------------------------*
*&      Form  MWSKZ_DEFAULT
*&---------------------------------------------------------------------*
FORM MWSKZ_DEFAULT
     CHANGING MWSKZ TYPE MWSKZ.
  CHECK MWSKZ    =  SPACE
  AND   FIRSTCALL = 'X'.

*-------------- Find default values in customizing ---------------------
  CALL FUNCTION 'LINEITEM_TAX_INDICATOR_DEFAULT'
    EXPORTING
      I_KALSM         = TAX-KALSM
      I_KOART         = KOART
      I_GLVOR         = BKPF-GLVOR
      I_MWSKZ_KONTEXT = MWSKZ_KONTEXT
    IMPORTING
      E_MWSKZ         = MWSKZ.
ENDFORM.                               " MWSKZ_DEFAULT

*&---------------------------------------------------------------------*
*&      Form  SKFBT_DEFAULT_TRIGGER
*&---------------------------------------------------------------------*
FORM SKFBT_DEFAULT_TRIGGER
     CHANGING XSKFB TYPE XSKFB.
  CHECK BSEG-UMSKZ EQ SPACE.
  XSKFB = 'X'.

ENDFORM.                               " SKFBT_DEFAULT_TRIGGER
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZAR_CALCULOS_GRILLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ACTUALIZAR_CALCULOS_GRILLA .




ENDFORM.                    " ACTUALIZAR_CALCULOS_GRILLA
*&---------------------------------------------------------------------*
*&      Module  REC_ACCOUNT_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE REC_ACCOUNT_CHANGE INPUT.
  IF SY-UCOMM NE 'BACK'
   AND SY-UCOMM NE 'CANCEL'
   AND SY-UCOMM NE 'EXIT'
   AND SY-UCOMM NE 'SOC_01'
    AND SY-UCOMM NE 'B03'
    AND SY-UCOMM NE 'EBR2'.
    IF XERRHKONT NE SPACE.
      PERFORM DETERMINE_REC_ACCOUNT USING BSEG-BUKRS BSEG-SAKNR
                                          KOART.
    ENDIF.
    IF BSEG-HKONT = SPACE.
      MESSAGE E437.
    ENDIF.

*--------- For comparing field status: keep old field staus group ------
    CHAR(4) = SKB1-FSTAG.
    XERRHKONT = 'X'.

*------- Valid reconciliation account ? --------------------------------
    IF BSEG-HKONT NE BSEG-SAKNR.
      CALL FUNCTION 'LINEITEM_THKON_CHECK'
        EXPORTING
          I_KTOPL     = T001-KTOPL
          I_ACCNT_OLD = BSEG-SAKNR
        CHANGING
          C_ACCNT_NEW = BSEG-HKONT.
    ENDIF.

*------- Read entered account -----------------------------------------
    PERFORM DETERMINE_REC_ACCOUNT USING BSEG-BUKRS BSEG-HKONT KOART.

*------------- General checks for the new account ----------------------
    CASE KOART.
      WHEN 'K'.
        PERFORM ACCOUNT_CHECK USING BSEG-BUKRS BSEG-LIFNR BSEG-HKONT.
      WHEN 'D'.
        PERFORM ACCOUNT_CHECK USING BSEG-BUKRS BSEG-KUNNR BSEG-HKONT.
      WHEN OTHERS.
    ENDCASE.
    PERFORM ACCOUNT_PERIOD_CHECK USING BSEG-HKONT.

*----------- Special checks after change -------------------------------
    PERFORM REC_ACCNT_CHANGE_SPEC_CHECKS.

*------- Check authority for changing reconciliation account -----------
    IF BSEG-XHKOM = CHAR_X.                                 "Note598867
      PERFORM AUTHORITY_ACCOUNTS.
    ENDIF.

    CLEAR XERRHKONT.
  ENDIF.
ENDMODULE.                 " REC_ACCOUNT_CHANGE  INPUT
*&---------------------------------------------------------------------*
*&      Form  ACCOUNT_CHECK
*&---------------------------------------------------------------------*
*       Check account number, Deletion, Enqueue, etc.
*----------------------------------------------------------------------*
FORM ACCOUNT_CHECK USING
      VALUE(BUKRS) TYPE BUKRS
      ACCOUNT TYPE C
      RECACC TYPE C.
  DATA: L_DIALOG TYPE BOOLE.                               "Note 353911

*---------------- Typkonflikt ------------------------------------------
  DATA: ACC LIKE SKB1-SAKNR.
  ACC = ACCOUNT.
  L_DIALOG-BOOLE = 'X'.                                    "Note 353911
  CALL FUNCTION 'FI_ACCOUNT_CHECK'
       EXPORTING
            I_ACCOUNT      = ACC
            I_RECACCOUNT   = RECACC
            I_BUKRS        = BUKRS
            I_KOART        = KOART
            I_WAERS        = BKPF-WAERS
* (del)     x_dialog       = 'X'.                          "Note 353911
* (del)     x_dialog       = l_dialog.          "Note 353911 Note482142
            X_DIALOG       = L_DIALOG                       "Note482142
        EXCEPTIONS                                          "Note482142
            ACCOUNT_LOCKED  = 1.                            "Note482142
  CASE SY-SUBRC.                                            "Note482142
    WHEN 1.                                                 "Note482142
      IF BKPF-GLVOR NE GLVOR_RMRP                           "Note482142
      OR SY-DYNGR = 'DTMM'.                                 "Note482142
        IF BKPF-GLVOR NE GLVOR_RMRP.                        "Note482142
          SET CURSOR FIELD 'INVFO-ACCNT'.                   "Note482142
        ELSE.                                               "Note482142
          SET CURSOR FIELD 'INVFO-LIFRE'.                   "Note482142
        ENDIF.                                              "Note482142
        MESSAGE ID SY-MSGID                                 "Note482142
                TYPE SY-MSGTY                               "Note482142
                NUMBER SY-MSGNO                             "Note482142
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.   "Note482142
      ENDIF.                                                "Note482142
  ENDCASE.
ENDFORM.                               " ACCOUNT_CHECK
*&---------------------------------------------------------------------*
*&      Form  ACCOUNT_PERIOD_CHECK
*&---------------------------------------------------------------------*
FORM ACCOUNT_PERIOD_CHECK USING HKONT.

*------- Period check for account --------------------------------------
  CALL FUNCTION 'DOCHEADER_PERIOD_FIND_CHECK'
    EXPORTING
      I_BUKRS = BSEG-BUKRS
      I_BLDAT = BKPF-BLDAT
      I_BUDAT = BKPF-BUDAT
      I_KOART = KOART
      I_HKONT = HKONT
    CHANGING
      C_MONAT = BKPF-MONAT.

ENDFORM.                               " ACCOUNT_PERIOD_CHECK

*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_ACCOUNTS
*&---------------------------------------------------------------------*
FORM AUTHORITY_ACCOUNTS.
  DATA: ACTVT   LIKE TACT-ACTVT.
* activity depend of type of posting
  IF G_STATUS EQ 1.
    ACTVT = '01'.
* Display document                                         "Note 337114
  ELSEIF G_STATUS = '4'.                                   "Note 337114
    ACTVT = '03'.                                          "Note 337114
  ELSE.
* pp
    ACTVT = '77'.
  ENDIF.
  PERFORM AUTHORITY_ACCOUNT_TYPE USING TBSL-KOART ACTVT.
  CASE KOART.
    WHEN 'D'.
      PERFORM AUTHORITY_ACCOUNT USING 'D' KNA1-BEGRU ACTVT.
      PERFORM AUTHORITY_ACCOUNT USING 'D' KNB1-BEGRU ACTVT.
      PERFORM AUTHORITY_ACCOUNT USING 'S' SKB1-BEGRU ACTVT.
    WHEN 'K'.
      PERFORM AUTHORITY_ACCOUNT USING 'K' LFA1-BEGRU ACTVT.
      PERFORM AUTHORITY_ACCOUNT USING 'K' LFB1-BEGRU ACTVT.
      PERFORM AUTHORITY_ACCOUNT USING 'S' SKB1-BEGRU ACTVT.
    WHEN OTHERS.
      PERFORM AUTHORITY_ACCOUNT USING 'S' SKB1-BEGRU ACTVT.
  ENDCASE.
ENDFORM.                               " AUTHORITY_ACCOUNTS
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_ACCOUNT
*&---------------------------------------------------------------------*
*       General authority check dependent on acc. type and group
*       Note 337114: Coding replaced with function module
*----------------------------------------------------------------------*
FORM AUTHORITY_ACCOUNT USING VALUE(P_KOART) LIKE BSEG-KOART
                             VALUE(P_BEGRU) LIKE KNA1-BEGRU
                             VALUE(P_ACTVT) LIKE TACT-ACTVT.
  CALL FUNCTION 'AUTHORITY_ACCOUNT'
    EXPORTING
      I_KOART = P_KOART
      I_BEGRU = P_BEGRU
      I_ACTVT = P_ACTVT.
ENDFORM.                               " ATHORITY_ACCOUNT
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_ACCOUNT_TYPE
*&      Authority check for subledger (account type 'D' or 'K')
*&      Note 337114: Coding replaced with function module
*&---------------------------------------------------------------------*
FORM AUTHORITY_ACCOUNT_TYPE USING VALUE(P_ACCTP) LIKE BSEG-KOART
                                  VALUE(P_ACTVT) LIKE TACT-ACTVT.
  CALL FUNCTION 'AUTHORITY_ACCOUNT_TYPE'
    EXPORTING
      I_KOART = P_ACCTP
      I_ACTVT = P_ACTVT.
ENDFORM.                               " AUTHORITY_ACCOUNT_TYPE

*&---------------------------------------------------------------------*
*&      Form  DETERMINE_REC_ACCOUNT
*&---------------------------------------------------------------------*
*       Read reconciliation account and move some contnts to BSEG
*----------------------------------------------------------------------*
FORM DETERMINE_REC_ACCOUNT
     USING VALUE(BUKRS) TYPE BUKRS
           VALUE(HKONT) TYPE HKONT
           VALUE(KOART) TYPE KOART.
  DATA: DIALOG TYPE BOOLE      VALUE 'X'.

  IF NOT LFB1-LNRZE IS INITIAL AND LFB1-SPERR = 'X'.        "Note819442
    CHECK HKONT NE SPACE.                                   "Note819442
  ENDIF.                                                    "Note819442

  CALL FUNCTION 'FI_RECONCILIATION_ACCNT_CHECK'
    EXPORTING
      I_BUKRS  = BUKRS
      I_HKONT  = HKONT
      I_KOART  = KOART
      X_DIALOG = DIALOG.

*-------------- SKA1 and SKB1 get filled -------------------------------
  PERFORM READ_GL_ACCOUNT USING BUKRS HKONT.
  BSEG-XHRES = SKB1-XKRES.
  BSEG-ALTKT = SKA1-BILKT.
  BSEG-LOKKT = SKB1-ALTKT.
  IF BSEG-FIPOS IS INITIAL.                                 "Note739666
    BSEG-FIPOS = SKB1-FIPOS.
  ENDIF.                                                    "Note739666
ENDFORM.                               " DETERMINE_REC_ACCOUNT
*&---------------------------------------------------------------------*
*&      Form  READ_GL_ACCOUNT
*&---------------------------------------------------------------------*
FORM READ_GL_ACCOUNT
     USING VALUE(BUKRS) TYPE BUKRS
           VALUE(HKONT) TYPE HKONT.
  CLEAR: SKA1, SKB1.
  CHECK NOT HKONT IS INITIAL.
  CHECK NOT BUKRS IS INITIAL.
  CALL FUNCTION 'READ_HAUPTBUCH'
    EXPORTING
      BUCHUNGSKREIS        = BUKRS
      SACHKONTO            = HKONT
      AUTH_CHECK_ACTIVITY  = ' '
    IMPORTING
      KONTENPLAN_WA        = SKA1
      SACHKONTO_WA         = SKB1
    EXCEPTIONS
      KONTENPLAN_NOT_FOUND = 1
      SACHKONTO_NOT_FOUND  = 2
      NOT_AUTHORIZED       = 3
      OTHERS               = 4.
  IF SY-SUBRC NE 0.
    CLEAR: SKA1, SKB1.
  ENDIF.
ENDFORM.                               " READ_GL_ACCOUNT
*&---------------------------------------------------------------------*
*&      Form  REC_ACCNT_CHANGE_SPEC_CHECKS
*&---------------------------------------------------------------------*
*       Form is only called after rec account was changed manually
*       Special checks are processed
*----------------------------------------------------------------------*
FORM REC_ACCNT_CHANGE_SPEC_CHECKS.
  IF SKB1-FSTAG NE CHAR(4).
    MESSAGE E438 WITH SKB1-FSTAG.
  ENDIF.
  IF SKB1-XMITK = SPACE.
    MESSAGE E439.
  ENDIF.
  IF SKB1-MITKZ NE KOART.
    MESSAGE E017 WITH SKB1-SAKNR KOART.
  ENDIF.
  BSEG-XHKOM = SPACE.
  IF  KOART = 'D'
  AND BSEG-HKONT NE KNB1-AKONT.
    BSEG-XHKOM = 'X'.
  ENDIF.
  IF  KOART = 'K'
  AND BSEG-HKONT NE LFB1-AKONT.
    BSEG-XHKOM = 'X'.
  ENDIF.
ENDFORM.                               " REC_ACCNT_CHANGE_SPEC_CHECKS
*&---------------------------------------------------------------------*
*&      Module  HLP_MWSKZ  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HLP_MWSKZ INPUT.
  DATA: MWSKZ       LIKE T007A-MWSKZ,
        LOC_BUDAT  LIKE BKPF-BUDAT,
        LOC_KUNNR  LIKE BSEG-KUNNR,
        LOC_LIFNR  LIKE BSEG-LIFNR,
        LOC_STBUK  LIKE BSEG-STBUK.

  PERFORM READ_COMPANY_CODE_INFO USING BSEG-BUKRS.
  IF BSEG-STBUK IS INITIAL.
    LOC_STBUK = BSEG-BUKRS.
  ELSE.
    LOC_STBUK = BSEG-STBUK.
  ENDIF.

*------------- Are we in Argentina ?? ----------------------------------
  CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
    EXPORTING
      BUKRS     = BSEG-BUKRS
      COMPONENT = 'AR'
    EXCEPTIONS
      OTHERS    = 1.
  IF SY-SUBRC = 0 AND KOART CA 'DK'.
    IF BKPF-GLVOR = GLVOR_RMRP.                             "Note534681
*   Miro: Get lifnr form bseg.                              "Note534681
      LOC_LIFNR = BSEG-LIFNR.                               "Note534681
    ELSE.                                                   "Note534681
      PERFORM DYNP_VALUES_READ USING 'ZINVFO-ACCNT' RCODE.
      IF RCODE = 0.
        IF KOART = 'D'.
* (del) loc_kunnr = f4hlp-fieldvalue.                      "Note 339768
          PERFORM ALPHAFORMAT                                "Note 339768
            USING F4HLP-FIELDVALUE LOC_KUNNR.                "Note 339768
        ELSE.
* (del) loc_lifnr = f4hlp-fieldvalue.                      "Note 339768
          PERFORM ALPHAFORMAT                                "Note 339768
            USING F4HLP-FIELDVALUE LOC_LIFNR.                "Note 339768
        ENDIF.
      ENDIF.
    ENDIF.                                                  "Note534681
    IF BKPF-BUDAT IS INITIAL.
      LOC_BUDAT = SY-DATLO.
    ELSE.
      LOC_BUDAT = BKPF-BUDAT.
    ENDIF.
    CALL FUNCTION 'FI_TAX_INPUT_CHECK'
      EXPORTING
        I_BUKRS    = BSEG-BUKRS
        I_KUNNR    = LOC_KUNNR
        I_LIFNR    = LOC_LIFNR
        I_BUDAT    = LOC_BUDAT
      IMPORTING
        E_MWSKZ    = MWSKZ
      EXCEPTIONS
        NO_ACCOUNT = 1                              " note 314547
        OTHERS     = 0.
    IF SY-SUBRC = 1.                                      " note 314547
      PERFORM HLP_TAX_ALTERNATIVE USING LOC_STBUK.        " note 314547
    ENDIF.                                                " note 314547
  ELSE.

*---------- Build list box ---------------------------------------------
    PERFORM HLP_TAX_ALTERNATIVE USING LOC_STBUK.
  ENDIF.

*-------------- Move tax indicator to screen field ---------------------
  IF NOT MWSKZ IS INITIAL.
    ZINVFO-MWSKZ = MWSKZ.
  ENDIF.
ENDMODULE.                 " HLP_MWSKZ  INPUT
*&---------------------------------------------------------------------*
*&      Module  HLP_SGTXT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HLP_SGTXT INPUT.
*  ------- DISPLAY OR ENTRY FIELD ? --------------------------------------
  XSHOW = SPACE.
  LOOP AT SCREEN.
    CHECK SCREEN-NAME = 'ZINVFO-SGTXT'.
    IF SCREEN-INPUT = 0.
      XSHOW = 'X'.
    ENDIF.
    EXIT.
  ENDLOOP.

*------- Show values from T053 - Entry samples -------------------------
  CALL FUNCTION 'F_VALUES_SGTXT'
    EXPORTING
      I_XSHOW          = XSHOW
      I_XPLUS          = SPACE
    IMPORTING
      E_SGTXT          = SGTXT_F4
    EXCEPTIONS
      NOTHING_SELECTED = 1.
  CHECK SY-SUBRC = 0.
  ZINVFO-SGTXT = SGTXT_F4.
ENDMODULE.                 " HLP_SGTXT  INPUT
*&---------------------------------------------------------------------*
*&      Module  HLP_BLART  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HLP_BLART INPUT.
  PERFORM HLP_BLART.
ENDMODULE.                 " HLP_BLART  INPUT
*&---------------------------------------------------------------------*
*&      Form  DYNP_VALUES_READ
*&---------------------------------------------------------------------*
FORM DYNP_VALUES_READ USING    FNAME LIKE DYNPREAD-FIELDNAME
                               RC    LIKE SY-SUBRC.
  CLEAR   F4HLP.
  REFRESH F4HLP.
  F4HLP-FIELDNAME = FNAME.
  APPEND F4HLP.
  F4DYN = SY-DYNNR.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = 'SAPLFDCB'
      DYNUMB     = F4DYN
    TABLES
      DYNPFIELDS = F4HLP
    EXCEPTIONS
      OTHERS     = 01.
  RC = SY-SUBRC.
ENDFORM.                               " DYNP_VALUES_READ

*&---------------------------------------------------------------------*
*&      Form  HLP_TAX_ALTERNATIVE
*&---------------------------------------------------------------------*
*       Individual set of tax codes is displayed
*----------------------------------------------------------------------*
FORM HLP_TAX_ALTERNATIVE USING STBUK.
  DATA: LOC_XWIA,
        L_CONCT LIKE BOOLE,                                 "Note498576
        MWSKZ LIKE INVFO-MWSKZ.
*---------- Country for tax indicator if plants abroad are active ------
*---------- Fill with default value (can be changed via button ) -------
*---------- Do not fill with default value if SPACE was entered  -------
*---------- manually (note 424583).                              -------




  IF X_LSTML = SPACE.
    CALL FUNCTION 'CHECK_PLANTS_ABROAD_ACTIVE'
      EXPORTING
        I_BUKRS       = STBUK
      IMPORTING
        E_FI_ISACTIVE = LOC_XWIA.
    IF LSTML IS INITIAL AND LOC_XWIA = 'X'.
      LSTML = T005-LAND1.
    ELSEIF ( NOT G_DOCUMENT_EXISTS IS INITIAL )             "Note532443
       AND LOC_XWIA = 'X'.                                  "Note532443
      SELECT SINGLE * FROM T007A                            "Note532443
         WHERE MWSKZ = BSEG-MWSKZ                           "Note532443
           AND KALSM = T005-KALSM.                          "Note532443



      LSTML = T007A-LSTML.                                  "Note532443
    ENDIF.
    X_LSTML = 'X'.
  ENDIF.
  L_CONCT-BOOLE = RFOPTE-XMWNK.                             "Note498576
  TRANSLATE L_CONCT-BOOLE USING ' XX '.                     "Note498576
  CALL FUNCTION 'ZAC_F4_MWSKZ_WITH_SELECTION'
    EXPORTING
      I_KALSM = TAX-KALSM
      I_MWSKZ = ZINVFO-MWSKZ
      I_STBUK = STBUK
      I_KOART = KOART
      I_GLVOR = BKPF-GLVOR
      I_LSTML = LSTML
      I_CONCT = L_CONCT                                     "Note498576
    IMPORTING
      E_MWSKZ = MWSKZ.
ENDFORM.                               " HLP_TAX_ALTERNATIVE
*&---------------------------------------------------------------------*
*&      Form  HLP_BLART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM HLP_BLART .
  DATA: LTEXT(22).
  DATA: L_REPID LIKE SY-REPID.                              "Note511688

  REFRESH FIELDTAB.
  PERFORM FILL_FIELDNAMES USING 'T003' 'BLART'.
  PERFORM FILL_FIELDNAMES USING 'T003T' 'LTEXT'.
  REFRESH VALTAB.

DATA:  PVALSIGN     LIKE  SETLEAF-VALSIGN,
       PVALOPTION   LIKE  SETLEAF-VALOPTION,
       PVALFROM     LIKE  SETLEAF-VALFROM,
       PVALTO       LIKE  SETLEAF-VALTO.


RANGES: PP_BLART FOR BKPF-BLART.

REFRESH: PP_BLART.
CLEAR: PP_BLART.

SELECT  VALSIGN VALOPTION VALFROM VALTO INTO (PVALSIGN, PVALOPTION, PVALFROM, PVALTO)
 FROM SETLEAF
WHERE SETNAME EQ 'ZFABLART'.
MOVE: PVALSIGN TO PP_BLART-SIGN,
      PVALOPTION TO PP_BLART-OPTION,
      PVALFROM   TO PP_BLART-LOW,
      PVALTO     TO PP_BLART-high.
APPEND PP_BLART.
CLEAR:PVALSIGN, PVALOPTION, PVALFROM, PVALTO, PP_BLART.
ENDSELECT.


  CASE KOART.
    WHEN 'K'.
      SELECT BLART FROM  T003 INTO T003-BLART               "Note 496812
             WHERE  XKOAK  = 'X'
             AND    BLART IN PP_BLART.
        PERFORM HLP_READ_T003T  USING SY-LANGU T003-BLART.
        PERFORM FILL_FIELDVALUES USING T003-BLART.
        IF RFOPTE-DMTTP GE 3.                             "#EC PORTABLE
          CONCATENATE '(' T003T-LTEXT ')' INTO LTEXT.
          CONCATENATE T003-BLART LTEXT INTO T003T-LTEXT
                      SEPARATED BY SPACE.
        ENDIF.
        PERFORM FILL_FIELDVALUES USING T003T-LTEXT.
      ENDSELECT.
    WHEN 'D'.
      SELECT BLART FROM  T003 INTO T003-BLART               "Note 496812
             WHERE  XKOAD  = 'X'.
        PERFORM HLP_READ_T003T   USING SY-LANGU T003-BLART.
        PERFORM FILL_FIELDVALUES USING T003-BLART.
        IF RFOPTE-DMTTP GE 3.                             "#EC PORTABLE
          CONCATENATE '(' T003T-LTEXT ')' INTO LTEXT.
          CONCATENATE T003-BLART LTEXT INTO T003T-LTEXT
                      SEPARATED BY SPACE.
        ENDIF.
        PERFORM FILL_FIELDVALUES USING T003T-LTEXT.
      ENDSELECT.
  ENDCASE.

  LOOP AT SCREEN.
    CHECK SCREEN-NAME = 'ZINVFO-BLART'.
    IF SCREEN-INPUT = 0.
      XSHOW = 'X'.
    ELSE.
      CLEAR XSHOW.
    ENDIF.
    EXIT.
  ENDLOOP.

* (del) perform help_values_get using 'BLART' xshow invfo-b "Note502371
  L_REPID = SY-REPID.                                       "Note511688
  PERFORM HELP_VALUES_GET                                   "Note502371
    USING                                                   "Note502371
      'BLART'                                               "Note502371
      XSHOW                                                 "Note502371
      ZINVFO-BLART                                          "Note502371
* (del) sy-repid                                 "Note502371 Note511688
      L_REPID                                               "Note511688
      SY-DYNNR                                              "Note502371
      'ZINVFO-BLART'.                                       "Note50237
ENDFORM.                    " HLP_BLART
*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDNAMES
*&---------------------------------------------------------------------*
FORM FILL_FIELDNAMES USING
    TABNAME TYPE C
    FNAME TYPE C.
  CLEAR FIELDTAB.
  FIELDTAB-TABNAME = TABNAME.
  FIELDTAB-FIELDNAME = FNAME.
  APPEND FIELDTAB.
ENDFORM.                               " FILL_FIELDNAMES
*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDVALUES
*&---------------------------------------------------------------------*
FORM FILL_FIELDVALUES USING
    CONTENTS TYPE C.
  VALTAB-FELD = CONTENTS.
  APPEND VALTAB.
ENDFORM.                               " FILL_FIELDVALUES
*&---------------------------------------------------------------------*
*&      Form  HELP_VALUES_GET
*&---------------------------------------------------------------------*
*       Call F4-Process
FORM HELP_VALUES_GET USING
       RETFIELD TYPE C
       SHOW TYPE CHAR1
       DYNPFIELD TYPE C
       VALUE(P_DYNPPROG) TYPE C                             "Note502371
       VALUE(P_DYNPNR) TYPE C                               "Note502371
       VALUE(P_DYNPROFIELD) TYPE C.                         "Note502371
* (del) dynpfield type c.                                   "Note502371
  DATA: VALUE LIKE HELP_INFO-FLDVALUE.                      "Note502371
  DATA: L_DYNPPROG TYPE SY-REPID,                           "Note502371
        L_DYNPNR TYPE SY-DYNNR,                             "Note502371
        L_DYNPROFIELD TYPE HELP_INFO-DYNPROFLD.             "Note502371

  VALUE = DYNPFIELD.
  L_DYNPPROG = P_DYNPPROG.                                  "Note502371
  L_DYNPNR = P_DYNPNR.                                      "Note502371
  L_DYNPROFIELD = P_DYNPROFIELD.                            "Note502371
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = RETFIELD
      VALUE           = VALUE
      DISPLAY         = SHOW
      DYNPPROG        = L_DYNPPROG                          "Note502371
      DYNPNR          = L_DYNPNR                            "Note502371
      DYNPROFIELD     = L_DYNPROFIELD                       "Note502371
    TABLES
      VALUE_TAB       = VALTAB
      FIELD_TAB       = FIELDTAB
      RETURN_TAB      = RETURNTAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
  IF SY-SUBRC NE 0. ENDIF.
ENDFORM.                               " HELP_VALUES_GET
*&---------------------------------------------------------------------*
*&      Form  HLP_READ_T003T
*&---------------------------------------------------------------------*
FORM HLP_READ_T003T USING
    LANGU TYPE LANG
    BLART TYPE BLART.
  CLEAR T003T-LTEXT.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *                                           "Note 496812
  SELECT SINGLE LTEXT FROM  T003T INTO T003T-LTEXT
         WHERE  SPRAS  = LANGU
         AND    BLART  = BLART.
ENDFORM.                               " HLP_READ_T003T
