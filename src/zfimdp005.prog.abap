*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Modulpool         ZFIMDP005
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
PROGRAM  ZFIMDP005 MESSAGE-ID F5.
TABLES:
  BKPF,
  ZINVFO,
  BSEG,
  BSEZ,
  BSEC,
  T001,
  *LFB1,
  *KNB1,
  T004,
  ZACGL_ITEM,
  ACGL_ITEM_GEN,BSEU,
  *ZACGL_ITEM, T030B,
  TMODU,
  ZACGL_ITEM_TBCTR,
  T005,
  T014,
  T043,
  T042,
  T043T,
  T003T,
  X001,
  T020,
  T003,
  T052,
  TTXD,
  BKP1,
  NRIV,
  ICURR,
  FIN1_PARAM,
  RF05A,
  RFOPT,
  RFOPT2,
  ACGL_HEAD,
  T074U,
  TBSL,
  TBSLT,
  SKB1,
  KNA1,
  KNB1,
  LFA1,
  LFB1,
  SKA1,
  ACC_KONTEXT,
  TFBUF,
  T007A,
  ACSPLT,
  FAEDE.


DATA: MBSEG LIKE BSEG,
      MBSEC LIKE BSEC,
      MBSED LIKE BSED,
      MBKPF LIKE BKPF.

DATA: LT_BKPF TYPE TABLE OF BKPF.                        "Note 390762
DATA: LT_BSEG TYPE TABLE OF BSEG.

DATA: PANTALLA1(1) TYPE C,
      PANTALLA2(1) TYPE C,
      PANTALLA3(1) TYPE C.

DATA:
    FSTVA    TYPE FSTVA,
    FAUS1    TYPE FAUS1,
    FAUS2    TYPE FAUS1,
    FAUS(140),
    FSTTX    TYPE FSTTX VALUE 'DDD',
    TEXT1(70) VALUE '111'.
DATA: FSTAG LIKE SKB1-FSTAG.

DATA: DS_NAME     LIKE RFPDO-RFBIFILE.

DATA: BEGIN OF ZZACGL_ITEM OCCURS 0.
        INCLUDE STRUCTURE ZACGL_ITEM_TBCTR.
DATA: END OF ZZACGL_ITEM.

TYPES: BEGIN OF T_TABLE,
         STATE LIKE ZACGL_ITEM_TBCTR-STATE,
         BUKRS LIKE ZACGL_ITEM_TBCTR-BUKRS,
         SHKZG LIKE ZACGL_ITEM_TBCTR-SHKZG,
         MWSKZ LIKE ZACGL_ITEM_TBCTR-MWSKZ,
         WRBTR LIKE ZACGL_ITEM_TBCTR-WRBTR,
         VALUT LIKE ZACGL_ITEM_TBCTR-VALUT,
         ZUONR LIKE ZACGL_ITEM_TBCTR-ZUONR,
         SGTXT LIKE ZACGL_ITEM_TBCTR-SGTXT,
         KOKRS LIKE ZACGL_ITEM_TBCTR-KOKRS,
         KOSTL LIKE ZACGL_ITEM_TBCTR-KOSTL,
         AUFNR LIKE ZACGL_ITEM_TBCTR-AUFNR,
         ANBWA LIKE ZACGL_ITEM_TBCTR-ANBWA,
         HKONT LIKE ZACGL_ITEM_TBCTR-HKONT,
         PRCTR LIKE ZACGL_ITEM_TBCTR-PRCTR,
         KONTO_TXT LIKE ZACGL_ITEM_TBCTR-KONTO_TXT,
         ZZPRESTAC LIKE ZACGL_ITEM_TBCTR-ZZPRESTAC,
         ZZUNID_PRO LIKE ZACGL_ITEM_TBCTR-ZZUNID_PRO,
         ZZDESC_EST LIKE ZACGL_ITEM_TBCTR-ZZDESC_EST,
         ZZMOT_EMIS LIKE ZACGL_ITEM_TBCTR-ZZMOT_EMIS,
         ZZRUT_TERC LIKE ZACGL_ITEM_TBCTR-ZZRUT_TERC,
         ZZ_AGENCIA LIKE ZACGL_ITEM_TBCTR-ZZ_AGENCIA,
         ANLN1      LIKE ZACGL_ITEM_TBCTR-ANLN1,
         ANLN2      LIKE ZACGL_ITEM_TBCTR-ANLN2,
         BSCHL      LIKE ZACGL_ITEM_TBCTR-BSCHL,
         MARKSP     LIKE ZACGL_ITEM_TBCTR-MARKSP,
       END OF T_TABLE.

DATA:     G_TABLE_ITAB   TYPE T_TABLE OCCURS 0,
          G_TABLE_WA     TYPE T_TABLE. "work area
DATA:     G_TABLE_COPIED.           "copy flag

DATA: G_CHECK_LEVEL TYPE I VALUE 1.
DATA: G_NO_MESSAGE TYPE XFELD.


DATA: DYNNR   LIKE TCOBL-DYNNR,    "Dynpronummer des Subscreens
      PROGN   LIKE SY-CPROG,       "Name des Kontierungsblockmodulpools
      PROCESS LIKE COBL-PROCESS,   "RWIN-Prozeß
      EVENT   LIKE COBL-EVENT.     "RWIN-Zeitpunkt

DATA     I  TYPE I.      " Laufindex etc.
CONTROLS: TABLE TYPE TABLEVIEW USING SCREEN 0100,
        TC_COLS TYPE TABLEVIEW USING SCREEN 0100.
DATA TC_AAA TYPE CXTAB_COLUMN.
DATA:  COL TYPE CXTAB_COLUMN.
DATA:     G_TABLE_LINES  LIKE SY-LOOPC.

DATA: ZSTATUS_CAMPO LIKE ZSTATUS_CAMPO OCCURS 0  WITH HEADER LINE.
DATA: I_ERRORES LIKE BAPIRET2 OCCURS 0  WITH HEADER LINE.
DATA: P_ERROR_P(1) TYPE C.

DATA: PP_INDEX LIKE SY-TABIX.
DATA: P_AUTO(1) TYPE C VALUE 'X',
      P_POPUP(1) TYPE C VALUE 'X',
      P_TITULO(30) TYPE C VALUE 'Log. de Ejecución'.
INCLUDE ZCONTACTFIJO.
INCLUDE ZFINDTOP001.
INCLUDE ZFIMDTOP.
INCLUDE ZMF05ACOM.
INCLUDE ZMF05ATOP_ENJ_APAR.
INCLUDE ZMF05ATOP_ENJ_GENERAL.
INCLUDE ZMRM_CONST_MRM.
INCLUDE ZLFDCBF4D.
INCLUDE ZFIMDP006.
INCLUDE ZFIMDP007.
INCLUDE ZFIMDP008.
INCLUDE ZFIMDP009.
INCLUDE ZFIMDP_TABLE_CONTROL.
*----------------------------------------------------------------------*
*  MODULE T_001_ACTIVE_TAB_SET OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE T_001_ACTIVE_TAB_SET OUTPUT.
  T_001-ACTIVETAB = G_T_001-PRESSED_TAB.
  CASE G_T_001-PRESSED_TAB.
    WHEN C_T_001-TAB1.
      G_T_001-SUBSCREEN = '0101'.
    WHEN C_T_001-TAB2.
      G_T_001-SUBSCREEN = '0102'.
    WHEN C_T_001-TAB3.
      G_T_001-SUBSCREEN = '0103'.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                    "T_001_ACTIVE_TAB_SET OUTPUT

*----------------------------------------------------------------------*
*  MODULE T_001_ACTIVE_TAB_GET INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE T_001_ACTIVE_TAB_GET INPUT.
  OOK_CODE = SY-UCOMM.
  CASE OOK_CODE.
    WHEN C_T_001-TAB1.
      G_T_001-PRESSED_TAB = C_T_001-TAB1.
    WHEN C_T_001-TAB2.
      G_T_001-PRESSED_TAB = C_T_001-TAB2.
    WHEN C_T_001-TAB3.
      G_T_001-PRESSED_TAB = C_T_001-TAB3.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                    "T_001_ACTIVE_TAB_GET INPUT


*&---------------------------------------------------------------------*
*&      Module  SET_SOCIEDAD_FI  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SOCIEDAD_FI OUTPUT.
  IF   ZINVFO-BUKRS EQ SPACE.
    GET PARAMETER ID 'BUK' FIELD ZINVFO-BUKRS .
  ENDIF.

  IF ZINVFO-BUKRS EQ SPACE.
    CALL FUNCTION 'DOCHEADER_COMP_CODE_WITH_POPUP'
      EXPORTING
        I_BUKRS  = ZINVFO-BUKRS
        I_STATUS = G_STATUS
      IMPORTING
        E_BUKRS  = BKPF-BUKRS
      EXCEPTIONS
        CANCELED = 1
        OTHERS   = 2.
    SET PARAMETER ID 'BUK' FIELD BKPF-BUKRS .
    ZINVFO-BUKRS = BKPF-BUKRS.
  ELSE.
    SET PARAMETER ID 'BUK' FIELD ZINVFO-BUKRS .
  ENDIF.

  IF ZINVFO-BUKRS NE SPACE.
    SELECT SINGLE WAERS INTO   ZINVFO-WAERS
    FROM T001
      WHERE BUKRS = ZINVFO-BUKRS.

*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES02 ECDK917080 *
    SELECT SINGLE *
  FROM   T042
    WHERE BUKRS = ZINVFO-BUKRS.
  ENDIF.

  IF ZINVFO-BLART EQ SPACE.
    ZINVFO-BLART = 'F1'.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES02 ECDK917080 *
    SELECT SINGLE LTEXT INTO  T003T-LTEXT
       FROM T003T
      WHERE SPRAS  EQ  SY-LANGU
       AND  BLART  EQ  ZINVFO-BLART.
  ENDIF.

  IF ZINVFO-MWSKZ EQ SPACE.
    ZINVFO-MWSKZ = 'C9'.
    ZINVFO-XMWST = 'X'.
  ENDIF.

  IF ZINVFO-FDLEV IS INITIAL.
    ZINVFO-FDLEV = 'F1'.
  ENDIF.
  BKPF-WAERS  = ZINVFO-WAERS.

  IF ZINVFO-LIFNR NE SPACE.

    CALL FUNCTION 'LFB1_READ_SINGLE'
      EXPORTING
        ID_LIFNR            = ZINVFO-LIFNR
        ID_BUKRS            = ZINVFO-BUKRS
      IMPORTING
        ES_LFB1             = ES_LFB1
      EXCEPTIONS
        NOT_FOUND           = 1
        INPUT_NOT_SPECIFIED = 2
        OTHERS              = 3.
    IF SY-SUBRC <> 0.
      MESSAGE E776.
    ELSE.

      LOOP AT SCREEN.
        IF SCREEN-NAME = 'ZINVFO-LIFNR'.
          IF  SCREEN-INPUT = 1.

            SCREEN-INPUT = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDMODULE.                 " SET_SOCIEDAD_FI  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DYNPRO_MODIFICATION_1100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DYNPRO_MODIFICATION_1100 OUTPUT.
  LOOP AT SCREEN.
    CASE SCREEN-NAME.
      WHEN 'AMNT'.
        IF  BKPF-HWAER = BKPF-WAERS
        AND BKPF-HWAE2 = SPACE AND BKPF-HWAE3 = SPACE.
          SCREEN-INVISIBLE = 1.
        ENDIF.
      WHEN 'WT  '.
        CALL FUNCTION 'FI_CHECK_EXTENDED_WT'
          EXPORTING
            I_BUKRS              = BKPF-BUKRS
          EXCEPTIONS
            COMPONENT_NOT_ACTIVE = 1
            NOT_FOUND            = 2
            OTHERS               = 3.
        IF SY-SUBRC NE 0.
          READ TABLE XBSEG WITH KEY KOART = 'K'.
          IF SY-SUBRC NE 0
            OR XBSEG-QSSKZ = SPACE
            AND ( TS-ACTIVETAB NE 'WT'                      "Note494030
            OR ACTIVETAB NE SPACE ) .                       "Note494030
            SCREEN-INVISIBLE = 1.
          ENDIF.
        ENDIF.

      WHEN 'SPLT'.
        DESCRIBE TABLE SPLTTAB.                             "Note485043
        IF T001-XSPLT IS INITIAL
        OR ( G_STATUS EQ 4 AND SY-TFILL LT 2 ).             "Note485043
          SCREEN-INVISIBLE = 1.
        ENDIF.

      WHEN 'RF05A-BUSCS'.
        IF RFOPTE-XBCON = 'X'.
          SCREEN-INVISIBLE = 1.
          SCREEN-ACTIVE = 0.
        ELSEIF G_DOCUMENT_EXISTS EQ 'X' OR G_STATUS EQ '4'. "Note485043
          SCREEN-INPUT = 0.
        ELSE.

          IF FIRST_CALL IS INITIAL.
            IF  ( ACTIVETAB NE SPACE AND ACTIVETAB NE 'MAIN' ).
              SCREEN-INPUT = 0.
            ELSEIF TS-ACTIVETAB NE 'MAIN' AND ACTIVETAB = SPACE.
              SCREEN-INPUT = 0.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'RF05A-KSUCH' OR 'SEARCH'.
        IF RFOPTE-VSRCH NE 'X'.
          SCREEN-INVISIBLE = 1.
          SCREEN-ACTIVE    = 0.
          SCREEN-INPUT     = 0.
        ELSE.

          DESCRIBE TABLE XBSEG LINES RF05A-ANZBZ.
          IF RF05A-ANZBZ > 0.
            SCREEN-INPUT = 0.
          ELSEIF RF05A-KSUCH IS INITIAL.
            SET CURSOR FIELD 'RF05A-KSUCH'.
          ENDIF.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

    IF SCREEN-GROUP2 = '800' AND NO_BALANCE = 'X'.
      SCREEN-INVISIBLE = 1.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.
  CLEAR NO_BALANCE.

  IF RF05A-BUSCS EQ SPACE.
    RF05A-BUSCS = 'R'.
  ENDIF.
ENDMODULE.                 " DYNPRO_MODIFICATION_1100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  OOK_CODE = SY-UCOMM.
  CASE OOK_CODE.
    WHEN 'BACK'.
      SET SCREEN 0.
    WHEN 'CANCEL'.
      SET SCREEN 0.
    WHEN 'EXIT'.
      SET SCREEN 0.
    WHEN 'SOC_01'.
      PERFORM  COMP_CODE_NEW.
      LEAVE TO TRANSACTION 'ZFITR006'.
    WHEN 'SOC_02'.
      CLEAR: OOK_CODE.
      CLEAR SY-UCOMM.
      PERFORM  PERFOR_SIMULAR.
    WHEN 'FUN_001'.
      CLEAR: OOK_CODE.
      CLEAR SY-UCOMM.
      PERFORM MOD_GRID.
    WHEN  'SAVE'.
      CLEAR: OOK_CODE.
      CLEAR SY-UCOMM.
      PERFORM GRABA_DOC.
    WHEN  'B03'.
      CLEAR: OOK_CODE.
      CLEAR SY-UCOMM.
      CALL TRANSACTION 'FB03'.
    WHEN  'EBR2'.
      CLEAR: OOK_CODE.
      CLEAR SY-UCOMM.
      CALL TRANSACTION 'FBR2'.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  COMP_CODE_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COMP_CODE_NEW .
  CLEAR BKPF.
  READ TABLE XBKPF INDEX 1.
  IF SY-SUBRC = 0.
    BKPF = XBKPF.
  ENDIF.
  CALL FUNCTION 'DOCHEADER_COMP_CODE_WITH_POPUP'
    EXPORTING
      I_BUKRS  = BKPF-BUKRS
      I_STATUS = G_STATUS
    IMPORTING
      E_BUKRS  = BKPF-BUKRS
    EXCEPTIONS
      CANCELED = 1
      OTHERS   = 2.
  IF SY-SUBRC   NE 0
  OR BKPF-BUKRS EQ XBKPF-BUKRS.
    EXIT.
  ENDIF.
  SET PARAMETER ID 'BUK' FIELD BKPF-BUKRS.
  ACC_KONTEXT-BUKRS = BKPF-BUKRS.
*  PERFORM SAVE_CONTEXT.
*  PERFORM TREE_DELETE.
**  leave to transaction sy-tcode.      " note 360390
*  PERFORM TRANSAKTION_VERLASSEN.      " note 360390
ENDFORM.                    " COMP_CODE_NEW
*&---------------------------------------------------------------------*
*&      Form  SAVE_CONTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_CONTEXT.

  DATA: LS_ACC_KONTEXT LIKE ACC_KONTEXT.                    "Note401924
  DATA: LT_NODES TYPE TREEV_NKS WITH HEADER LINE,
        LT_AUX_NODES TYPE TREEV_NKS WITH HEADER LINE,
        WIDTH TYPE I.
* We expect less than 10 entries for these tables, so a standard
* table instead of a sorted / hashed one is ok.

* Fill g_datar evaluated in exit module
  IF NOT SY-DATAR IS INITIAL.
    G_DATAR = SY-DATAR.
  ENDIF.

* Batch input: Tree option is ignored                       "Note401924
  IF SY-BINPT = CHAR_X.                                     "Note401924
    LS_ACC_KONTEXT = TFBUF-BUFFR.                           "Note401924
    ACC_KONTEXT-XTREE = LS_ACC_KONTEXT-XTREE.               "Note401924
    IF TFBUF-BUFFR = ACC_KONTEXT.                           "Note401924
      ACC_KONTEXT-XTREE = CHAR_X.                           "Note401924
      EXIT.                                                 "Note401924
    ENDIF.                                                  "Note401924
  ENDIF.                                                    "Note401924

* ----------------------------------------------------------------------
* Get expanded nodes of tree and save them (Note 486587)
* ----------------------------------------------------------------------
* Table lt_nodes: currently expanded nodes
  CALL FUNCTION 'ACC_CA_TREE_GET_EXPANDED_NODES'
    TABLES
      IT_NODES = LT_NODES.

  SPLIT ACC_KONTEXT-EXPANDED_NODES AT '.' INTO TABLE LT_AUX_NODES.
* Table lt_aux_nodes: All nodes from old user context acc_kontext
  DELETE LT_AUX_NODES INDEX 1.            " delete first row

  LOOP AT LT_AUX_NODES.
    CONCATENATE '.' LT_AUX_NODES INTO LT_AUX_NODES.
    MODIFY LT_AUX_NODES.
  ENDLOOP.

  LOOP AT LT_AUX_NODES.
    READ TABLE NODE_TABLE WITH KEY NODE_KEY = LT_AUX_NODES.
    IF SY-SUBRC NE 0.
      APPEND LT_AUX_NODES TO LT_NODES.
* Add all nodes from old user context to new context which do NOT
* appear in the currently displayed tree and therefore cannot be
* collapsed.
    ENDIF.
  ENDLOOP.

  CLEAR ACC_KONTEXT-EXPANDED_NODES.

  LOOP AT LT_NODES.
    CONCATENATE LT_NODES ACC_KONTEXT-EXPANDED_NODES INTO
    ACC_KONTEXT-EXPANDED_NODES.
  ENDLOOP.

* ----------------------------------------------------------------------
* Get width of tree.
* ----------------------------------------------------------------------
  CALL FUNCTION 'ACC_CA_TREE_GET_WIDTH'                     "Note 575336
    IMPORTING
      E_DOCKING_SIZE = WIDTH.
  ACC_KONTEXT-TREE_WIDTH = WIDTH.                        " type cast

* ------------------  Check OLD <> NEW ? -------------------------------
  CHECK TFBUF-BUFFR NE ACC_KONTEXT.
* --------- Write TFBUF (user context) data ----------------------------
  TFBUF-BUFFR = ACC_KONTEXT.
  TFBUF-DATUM = SY-DATLO.
  MODIFY TFBUF.

  IF SY-BINPT = CHAR_X.                                     "Note401924
    ACC_KONTEXT-XTREE = CHAR_X.                             "Note401924
  ENDIF.                                                    "Note401924

ENDFORM.                               " SAVE_CONTEXT
*&---------------------------------------------------------------------*
*&      Form  TREE_INITIALIZE
*&---------------------------------------------------------------------*
*&      Form  TREE_DELETE
*&---------------------------------------------------------------------*
FORM TREE_DELETE.
  CALL FUNCTION 'ACC_CA_TREE_DELETE'
    EXPORTING
      I_NO_FLUSH = 'X'.
ENDFORM.                               " TREE_DELETE
*-----------------------------------------------------------------------
*        FORM TRANSAKTION_VERLASSEN
*-----------------------------------------------------------------------
FORM TRANSAKTION_VERLASSEN.
  DATA: L_TCVARIANT LIKE SHDTVCIU-TCVARIANT,               "Note 330523
        L_XCLIENTIND,                                      "Note 330523
        L_RC LIKE SY-SUBRC.                                "Note 330523
  IF  SY-BINPT NE CHAR_X
* (del) and ( sy-calld ne char_x or tcode = 'FBR2' ).       "ALRK237150
    AND SY-CALLD NE CHAR_X.                                 "ALRK237150
    IF TCODE = SPACE.
      TCODE = SY-TCODE.
    ENDIF.
*    IF XWFLA = CHAR_X.
*      LEAVE.
*    ENDIF.
    CALL FUNCTION 'RS_HDSYS_GET_TC_VARIANT'                "Note 330523
         IMPORTING                                         "Note 330523
              TCVARIANT               = L_TCVARIANT        "Note 330523
              FLAG_CLIENT_INDEPENDENT = L_XCLIENTIND       "Note 330523
              RC                      = L_RC.              "Note 330523
    IF L_RC > 2.                                           "Note 330523
      LEAVE TO TRANSACTION TCODE.
    ELSE.                                                  "Note 330523
      CALL FUNCTION 'RS_HDSYS_CALL_TC_VARIANT'             "Note 330523
         EXPORTING                                         "Note 330523
              TCODE                     = TCODE            "Note 330523
              VARIANT                   = L_TCVARIANT      "Note 330523
              I_FLAG_CLIENT_INDEPENDENT = L_XCLIENTIND     "Note 330523
              CALL_MODE                 = ' '              "Note 330523
              AUTHORITY_CHECK           = ' '              "Note 592165
         EXCEPTIONS                                        "Note 330523
              OTHERS                    = 0.               "Note 330523
      LEAVE TO TRANSACTION TCODE.                          "Note 330523
    ENDIF.                                                 "Note 330523
  ELSE.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.                    "transaktion_verlassen
*&---------------------------------------------------------------------*
*&      Form  MOD_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOD_GRID .
  REFRESH: IT_T001.
  CLEAR: IT_T001.

  LOOP AT   G_TABLE_ITAB
       INTO G_TABLE_WA.
    MOVE-CORRESPONDING  G_TABLE_WA TO IT_T001.
    APPEND IT_T001.
  ENDLOOP.

  DATA: P_INDEX LIKE SY-TABIX.


  IF RF05A-BUSCS NE SPACE.
    LOOP AT IT_T001.
      P_INDEX = SY-TABIX.
      MOVE: ZINVFO-MWSKZ TO IT_T001-MWSKZ.
      IF  RF05A-BUSCS = 'R'.
        MOVE: 'S'  TO IT_T001-SHKZG.
        MODIFY IT_T001 INDEX P_INDEX.
      ELSE.
        IF  RF05A-BUSCS = 'G'.
          MOVE: 'H'  TO IT_T001-SHKZG.
          MODIFY IT_T001 INDEX P_INDEX.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT IT_T001.
      P_INDEX = SY-TABIX.
      MOVE-CORRESPONDING IT_T001 TO G_TABLE_WA.
      MODIFY G_TABLE_ITAB  FROM G_TABLE_WA  INDEX  P_INDEX.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " MOD_GRID
*&---------------------------------------------------------------------*
*&      Form  PERFOR_SIMULAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PERFOR_SIMULAR .
  DATA IT_SUMULA TYPE ZACGL_ITEM OCCURS 100 WITH HEADER LINE.
  DATA E_A003 TYPE A003 OCCURS 100 WITH HEADER LINE.
  REFRESH: IT_T001.
  CLEAR: IT_T001.


  DATA: TOTAL_POS LIKE ZACGL_ITEM-WRBTR,
        TOTAL_POS_S LIKE ZACGL_ITEM-WRBTR,
        TOTAL_POS_H LIKE ZACGL_ITEM-WRBTR,
        TOTAL_IVA LIKE ZACGL_ITEM-WRBTR,
        TOTAL_IVA_NO_RE LIKE ZACGL_ITEM-WRBTR,
        IVA_PROP        LIKE KONP-KBETR,
        IVA            LIKE ZACGL_ITEM-WRBTR,
        IVA_NO_RE       LIKE ZACGL_ITEM-WRBTR.


  DATA: T_BSEG  TYPE BSEG OCCURS 100 WITH HEADER LINE,
        T_BSEG2  TYPE BSEG OCCURS 100 WITH HEADER LINE,
        T_BKPF2  TYPE BKPF OCCURS 100 WITH HEADER LINE,
        T_BKPF  TYPE BKPF OCCURS 100 WITH HEADER LINE,
       T_ERINF  TYPE ACERRLOG OCCURS 100 WITH HEADER LINE.
  DATA: I_T020  LIKE T020.
  DATA: POS TYPE I VALUE 1.

  DATA: VALOR TYPE BSEG-WRBTR,
         TOT_POR TYPE BSEG-WRBTR,
         REST_POR TYPE BSEG-WRBTR.
  DATA: VALOR2 TYPE BSEG-WRBTR,
        TOT_POR2 TYPE BSEG-WRBTR,
        REST_POR2 TYPE BSEG-WRBTR.


  DATA:   T_DIF TYPE BSEG-WRBTR,
          T_DEBE TYPE BSEG-WRBTR,
          T_HABER TYPE BSEG-WRBTR,
          AA LIKE SY-TABIX.



  DATA: PE_I_KONP TYPE  KONP.

  IF RF05A-BUSCS EQ 'R'.
    LOOP AT   G_TABLE_ITAB
         INTO G_TABLE_WA WHERE HKONT NE SPACE.
      MOVE-CORRESPONDING  G_TABLE_WA TO IT_T001.
      APPEND IT_T001.
    ENDLOOP.



    CLEAR: TOTAL_POS_S.
    LOOP AT IT_T001 WHERE HKONT NE SPACE AND  SHKZG EQ 'S' AND MWSKZ EQ 'C9'.
      ADD IT_T001-WRBTR TO TOTAL_POS_S.
      CLEAR: IT_T001.
    ENDLOOP.


    CLEAR: TOTAL_POS_H.
    LOOP AT IT_T001 WHERE HKONT NE SPACE AND  SHKZG EQ 'H' AND MWSKZ EQ 'C9'.
      ADD IT_T001-WRBTR TO TOTAL_POS_H.
      CLEAR: IT_T001.
    ENDLOOP.


    TOTAL_POS = TOTAL_POS_S - TOTAL_POS_H.
    IF TOTAL_POS > 0.
      CALL FUNCTION 'RE_KTOSL_TO_MWSKZ_GET'
        EXPORTING
          I_MWSKZ                        = ZINVFO-MWSKZ
          I_BUKRS                        = ZINVFO-BUKRS
        TABLES
          E_A003                         = E_A003
        EXCEPTIONS
          NO_MWSKZ_IN_T001LAND           = 1
          NO_KTOSL_FOR_MWSKZ_IN_T001LAND = 2
          T638S_T007B_INCONSISTENCY      = 3
          OTHERS                         = 4.
      IF SY-SUBRC = 0.
        READ TABLE E_A003 INDEX 1.
        IF SY-SUBRC EQ 0.
          CALL FUNCTION 'WV_KONP_GET'
            EXPORTING
              PI_KNUMH        = E_A003-KNUMH
              PI_KAPPL        = E_A003-KAPPL
              PI_KSCHL        = E_A003-KSCHL
            IMPORTING
              PE_I_KONP       = PE_I_KONP
            EXCEPTIONS
              NO_RECORD_FOUND = 1
              OTHERS          = 2.
          IF SY-SUBRC = 0.
* Calcula IVA.
            IVA = PE_I_KONP-KBETR / 1000.
            TOTAL_IVA = TOTAL_POS *  IVA.
            SELECT SINGLE IVA_PROP INTO  IVA_PROP
                FROM ZFIIVAPRP
              WHERE  BUKRS EQ ZINVFO-BUKRS
              AND    FEC_INICO <= ZINVFO-BUDAT
              AND    FEC_FIN  >= ZINVFO-BUDAT.
            IF SY-SUBRC EQ 0.
*              IVA_NO_RE = IVA_PROP / 100.
*              TOTAL_IVA_NO_RE = TOTAL_IVA * IVA_NO_RE.
              TOTAL_IVA_NO_RE = TOTAL_IVA * IVA_PROP / 100.

            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.



    I_T020-TCODE =  'FB60'.
    I_T020-KOART =    'K'.
    I_T020-AKTYP =    'H'.
    I_T020-DYNCL =    'B'.
    I_T020-FUNCL =    ' '.
    I_T020-STATU =    'ENJINV'.
    I_T020-GENER =    '1'.


    MOVE-CORRESPONDING BKPF TO T_BKPF.
    APPEND T_BKPF.
* Posicion de Acreedor
    MOVE-CORRESPONDING ZINVFO TO T_BSEG.
    T_BSEG-BSCHL = '31'.
    T_BSEG-SHKZG = 'H'.
    T_BSEG-BUZEI = '1'.
    T_BSEG-KOART = 'K'.
    T_BSEG-PSWSL = ZINVFO-WAERS.
    T_BSEG-WRBTR =  T_BSEG-WRBTR +  TOTAL_IVA.
    T_BSEG-DMBTR =  T_BSEG-WRBTR.
    T_BSEG-KOKRS = 'BMSA'.
    APPEND T_BSEG.
    CLEAR T_BSEG.



* Posicion de  cuentas de mayor
    LOOP AT IT_T001 WHERE HKONT NE SPACE.
      ADD 1 TO POS.
      MOVE-CORRESPONDING IT_T001 TO T_BSEG.
      IF   IT_T001-SHKZG = 'S'.
        IF TOTAL_POS_S > 0 AND IT_T001-MWSKZ EQ 'C9'.
          IT_T001-PORCENTAJE  =  ( ( T_BSEG-WRBTR * 100 ) / TOTAL_POS_S ).  ""

          TOT_POR = IT_T001-PORCENTAJE + TOT_POR.
          IF  TOT_POR > 100.               ""
            REST_POR  =  TOT_POR  - 100.  ""
            IT_T001-PORCENTAJE =  IT_T001-PORCENTAJE - REST_POR.
            CLEAR: TOT_POR, REST_POR.
          ENDIF.
          IF TOT_POR = '99.99'.
            REST_POR  =  100 - TOT_POR.  ""
            IT_T001-PORCENTAJE =  IT_T001-PORCENTAJE + REST_POR.
            CLEAR: TOT_POR, REST_POR.
          ENDIF.

          VALOR        =   TOTAL_IVA_NO_RE * IT_T001-PORCENTAJE / 100. ""
          T_BSEG-WRBTR =  T_BSEG-WRBTR +  VALOR.
        ENDIF.
      ELSE.
        IF   IT_T001-SHKZG = 'H' AND IT_T001-MWSKZ EQ 'C9'.
          IF TOTAL_POS_S > 0.
            IT_T001-PORCENTAJE2  =  ( ( T_BSEG-WRBTR * 100 ) / TOTAL_POS_S ).
            TOT_POR2 = IT_T001-PORCENTAJE2 + TOT_POR2.
            IF TOT_POR2 > 100.
              REST_POR2  =  TOT_POR2  - 100.
              IT_T001-PORCENTAJE2 =  IT_T001-PORCENTAJE2 - REST_POR2.
              CLEAR: TOT_POR, REST_POR2.
            ENDIF.

            IF TOT_POR2 = '99.99'.
              REST_POR2  =  100 - TOT_POR.  ""
              IT_T001-PORCENTAJE2 =  IT_T001-PORCENTAJE2 + REST_POR2.
              CLEAR: TOT_POR2, REST_POR2.
            ENDIF.



            VALOR2        = TOTAL_IVA_NO_RE * IT_T001-PORCENTAJE2 / 100.
            T_BSEG-WRBTR =  T_BSEG-WRBTR +  VALOR2.
          ENDIF.
        ENDIF.
      ENDIF.

      T_BSEG-BUZEI = POS.
      T_BSEG-KOART = 'S'.
      T_BSEG-PSWSL = ZINVFO-WAERS.
      T_BSEG-DMBTR =  T_BSEG-WRBTR.
      T_BSEG-GJAHR = ZINVFO-GJAHR.
      t_bseg-sgtxt = zinvfo-sgtxt.            "Quintec mvm 26.07.2010
      APPEND T_BSEG.
      CLEAR T_BSEG.
    ENDLOOP.

    IF TOTAL_IVA > 0.
* Pos iva Normal
      ADD 1 TO POS.
      T_BSEG-BUKRS = ZINVFO-BUKRS.
      T_BSEG-BSCHL = '40'.
      T_BSEG-HKONT = '1013310004'.
      T_BSEG-SHKZG = 'S'.
      T_BSEG-BUZEI = POS.
      T_BSEG-KOART = 'S'.
      T_BSEG-PSWSL = ZINVFO-WAERS.
      T_BSEG-DMBTR =  TOTAL_IVA.
      T_BSEG-WRBTR =  TOTAL_IVA.
      T_BSEG-KOKRS = 'BMSA'.
      T_BSEG-GJAHR = ZINVFO-GJAHR.
      APPEND T_BSEG.
      CLEAR T_BSEG.
    ENDIF.

* Pos Iva Proporcional
    IF TOTAL_IVA_NO_RE > 0.
      ADD 1 TO POS.
      T_BSEG-BUKRS = ZINVFO-BUKRS.
      T_BSEG-BSCHL = '50'.
      T_BSEG-HKONT = '1013310005'.
      T_BSEG-SHKZG = 'H'.
      T_BSEG-BUZEI = POS.
      T_BSEG-KOART = 'S'.
      T_BSEG-PSWSL = ZINVFO-WAERS.
      T_BSEG-WRBTR = TOTAL_IVA_NO_RE - VALOR2.
      T_BSEG-DMBTR = T_BSEG-WRBTR.
      T_BSEG-KOKRS = 'BMSA'.
      T_BSEG-GJAHR = ZINVFO-GJAHR.
      APPEND T_BSEG.
      CLEAR T_BSEG.
    ENDIF.




    LOOP AT T_BSEG.
      IF T_BSEG-SHKZG EQ 'S'.
        T_DEBE = T_DEBE + T_BSEG-WRBTR.
      ELSE.
        T_HABER = T_HABER + T_BSEG-WRBTR.
      ENDIF.
    ENDLOOP.

    T_DIF = T_DEBE - T_HABER.


    LOOP AT T_BSEG WHERE MWSKZ EQ 'C9'.
      AA = SY-TABIX.
    ENDLOOP.

    READ TABLE T_BSEG INDEX  AA.
    IF SY-SUBRC EQ 0.
      IF  T_DIF > 0.
        IF T_BSEG-SHKZG = 'H'.
          T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF.   "Valor al haber esta en negativo, se le suma la diferencia positiva.
        ELSE.
          T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF.   "Valor al debe esta en positivo, se le resta la diferencia positiva.
        ENDIF.
      ELSE.
        IF  T_DIF < 0.
          IF T_BSEG-SHKZG = 'H'.
            T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF. "Valor al haber esta negativo, se le resta la diferencia negativa.
          ELSE.
            T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF. "Valor al debe esta positivo, se le suma la diferencia negativa.
          ENDIF.
        ENDIF.
      ENDIF.
      MODIFY T_BSEG INDEX AA.

    ENDIF.

  ENDIF.







  IF RF05A-BUSCS EQ 'G'.
    LOOP AT   G_TABLE_ITAB
         INTO G_TABLE_WA WHERE HKONT NE SPACE.
      MOVE-CORRESPONDING  G_TABLE_WA TO IT_T001.
      APPEND IT_T001.
    ENDLOOP.



    CLEAR: TOTAL_POS_S.
    LOOP AT IT_T001 WHERE HKONT NE SPACE AND  SHKZG EQ 'S' AND MWSKZ EQ 'C9'.
      ADD IT_T001-WRBTR TO TOTAL_POS_S.
      CLEAR: IT_T001.
    ENDLOOP.


    CLEAR: TOTAL_POS_H.
    LOOP AT IT_T001 WHERE HKONT NE SPACE AND  SHKZG EQ 'H' AND MWSKZ EQ 'C9'.
      ADD IT_T001-WRBTR TO TOTAL_POS_H.
      CLEAR: IT_T001.
    ENDLOOP.




    TOTAL_POS = TOTAL_POS_H - TOTAL_POS_S.
    IF TOTAL_POS > 0.
      CALL FUNCTION 'RE_KTOSL_TO_MWSKZ_GET'
        EXPORTING
          I_MWSKZ                        = ZINVFO-MWSKZ
          I_BUKRS                        = ZINVFO-BUKRS
        TABLES
          E_A003                         = E_A003
        EXCEPTIONS
          NO_MWSKZ_IN_T001LAND           = 1
          NO_KTOSL_FOR_MWSKZ_IN_T001LAND = 2
          T638S_T007B_INCONSISTENCY      = 3
          OTHERS                         = 4.
      IF SY-SUBRC = 0.
        READ TABLE E_A003 INDEX 1.
        IF SY-SUBRC EQ 0.

          CALL FUNCTION 'WV_KONP_GET'
            EXPORTING
              PI_KNUMH        = E_A003-KNUMH
              PI_KAPPL        = E_A003-KAPPL
              PI_KSCHL        = E_A003-KSCHL
            IMPORTING
              PE_I_KONP       = PE_I_KONP
            EXCEPTIONS
              NO_RECORD_FOUND = 1
              OTHERS          = 2.
          IF SY-SUBRC = 0.
* Calcula IVA.
            IVA = PE_I_KONP-KBETR / 1000.
            TOTAL_IVA = TOTAL_POS *  IVA.
            SELECT SINGLE IVA_PROP INTO  IVA_PROP
                FROM ZFIIVAPRP
              WHERE  BUKRS EQ ZINVFO-BUKRS
              AND    FEC_INICO <= ZINVFO-BUDAT
              AND    FEC_FIN  >= ZINVFO-BUDAT.
            IF SY-SUBRC EQ 0.
*              IVA_NO_RE = IVA_PROP / 100.
*              TOTAL_IVA_NO_RE = TOTAL_IVA * IVA_NO_RE.
              TOTAL_IVA_NO_RE = TOTAL_IVA * IVA_PROP / 100.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.




    I_T020-TCODE =  'FB60'.
    I_T020-KOART =    'K'.
    I_T020-AKTYP =    'H'.
    I_T020-DYNCL =    'B'.
    I_T020-FUNCL =    ' '.
    I_T020-STATU =    'ENJINV'.
    I_T020-GENER =    '1'.


    MOVE-CORRESPONDING BKPF TO T_BKPF.
    APPEND T_BKPF.
* Posicion de Acreedor
    MOVE-CORRESPONDING ZINVFO TO T_BSEG.
    T_BSEG-BSCHL = '31'.
    T_BSEG-SHKZG = 'S'.
    T_BSEG-BUZEI = '1'.
    T_BSEG-KOART = 'K'.
    T_BSEG-PSWSL = ZINVFO-WAERS.
    T_BSEG-WRBTR =  T_BSEG-WRBTR +  TOTAL_IVA.
    T_BSEG-DMBTR =  T_BSEG-WRBTR.
    T_BSEG-KOKRS = 'BMSA'.
    APPEND T_BSEG.
    CLEAR T_BSEG.


* Posicion de  cuentas de mayor
    LOOP AT IT_T001 WHERE HKONT NE SPACE.
      ADD 1 TO POS.
      MOVE-CORRESPONDING IT_T001 TO T_BSEG.
      IF   IT_T001-SHKZG = 'H'.
        IF TOTAL_POS_H > 0 AND IT_T001-MWSKZ EQ 'C9'.
          IT_T001-PORCENTAJE  =  ( ( T_BSEG-WRBTR * 100 ) / TOTAL_POS_H ).
          .

          TOT_POR = IT_T001-PORCENTAJE + TOT_POR.
          IF TOT_POR > 100.
            REST_POR  =  TOT_POR  - 100.
            IT_T001-PORCENTAJE =  IT_T001-PORCENTAJE - REST_POR.
            CLEAR: TOT_POR, REST_POR.
          ENDIF.

          IF TOT_POR = '99.99'.
            REST_POR  =  100 - TOT_POR.  ""
            IT_T001-PORCENTAJE =  IT_T001-PORCENTAJE + REST_POR.
            CLEAR: TOT_POR, REST_POR.
          ENDIF.


          VALOR        = TOTAL_IVA_NO_RE * IT_T001-PORCENTAJE / 100.
          T_BSEG-WRBTR =  T_BSEG-WRBTR +  VALOR.
        ENDIF.
      ELSE.
        IF   IT_T001-SHKZG = 'S' AND IT_T001-MWSKZ EQ 'C9'.
          IF TOTAL_POS_S > 0.
            IT_T001-PORCENTAJE2  = ( ( T_BSEG-WRBTR * 100 ) / TOTAL_POS_H ).
            TOT_POR2 = IT_T001-PORCENTAJE2 + TOT_POR2.
            IF TOT_POR2 > 100.
              REST_POR2  =  TOT_POR2  - 100.
              IT_T001-PORCENTAJE2 =  IT_T001-PORCENTAJE2 - REST_POR2.
              CLEAR: TOT_POR, REST_POR2.
            ENDIF.

            IF TOT_POR2 = '99.99'.
              REST_POR2  =  100 - TOT_POR2.  ""
              IT_T001-PORCENTAJE2 =  IT_T001-PORCENTAJE2 + REST_POR2.
              CLEAR: TOT_POR2, REST_POR2.
            ENDIF.

            VALOR2        = TOTAL_IVA_NO_RE * IT_T001-PORCENTAJE2 / 100.
            T_BSEG-WRBTR =  T_BSEG-WRBTR +  VALOR2.
          ENDIF.
        ENDIF.
      ENDIF.

      T_BSEG-BUZEI = POS.
      T_BSEG-KOART = 'S'.
      T_BSEG-PSWSL = ZINVFO-WAERS.
      T_BSEG-DMBTR =  T_BSEG-WRBTR.
      T_BSEG-GJAHR = ZINVFO-GJAHR.
      t_bseg-sgtxt = zinvfo-sgtxt.            "Quintec mvm 26.07.2010
      APPEND T_BSEG.
      CLEAR T_BSEG.
    ENDLOOP.

    IF TOTAL_IVA > 0.
* Pos iva Normal
      ADD 1 TO POS.
      T_BSEG-BUKRS = ZINVFO-BUKRS.
      T_BSEG-BSCHL = '50'.
      T_BSEG-HKONT = '1013310004'.
      T_BSEG-SHKZG = 'H'.
      T_BSEG-BUZEI = POS.
      T_BSEG-KOART = 'S'.
      T_BSEG-PSWSL = ZINVFO-WAERS.
      T_BSEG-DMBTR =  TOTAL_IVA.
      T_BSEG-WRBTR =  TOTAL_IVA.
      T_BSEG-KOKRS = 'BMSA'.
      T_BSEG-GJAHR = ZINVFO-GJAHR.
      APPEND T_BSEG.
      CLEAR T_BSEG.
    ENDIF.

* Pos Iva Proporcional
    IF TOTAL_IVA_NO_RE > 0.
      ADD 1 TO POS.
      T_BSEG-BUKRS = ZINVFO-BUKRS.
      T_BSEG-BSCHL = '40'.
      T_BSEG-HKONT = '1013310005'.
      T_BSEG-SHKZG = 'S'.
      T_BSEG-BUZEI = POS.
      T_BSEG-KOART = 'S'.
      T_BSEG-PSWSL = ZINVFO-WAERS.
      T_BSEG-WRBTR = TOTAL_IVA_NO_RE - VALOR2.
      T_BSEG-DMBTR = T_BSEG-WRBTR.
      T_BSEG-KOKRS = 'BMSA'.
      T_BSEG-GJAHR = ZINVFO-GJAHR.
      APPEND T_BSEG.
      CLEAR T_BSEG.
    ENDIF.

    LOOP AT T_BSEG.
      IF T_BSEG-SHKZG EQ 'S'.
        T_DEBE = T_DEBE + T_BSEG-WRBTR.
      ELSE.
        T_HABER = T_HABER + T_BSEG-WRBTR.
      ENDIF.
    ENDLOOP.

    T_DIF = T_DEBE - T_HABER.

    LOOP AT T_BSEG WHERE MWSKZ EQ 'C9'.
      AA = SY-TABIX.
    ENDLOOP.

    READ TABLE T_BSEG INDEX  AA.
*    IF SY-SUBRC EQ 0.
*      IF  T_DIF > 0.
*        T_BSEG-WRBTR = T_BSEG-WRBTR +  T_DIF.
*      ELSE.
*        IF  T_DIF < 0.
*          T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF.
*        ENDIF.
*      ENDIF.
*      MODIFY T_BSEG INDEX AA.
*    ENDIF.
    IF SY-SUBRC EQ 0.
      IF  T_DIF > 0.
        IF T_BSEG-SHKZG = 'H'.
          T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF.   "Valor al haber esta en negativo, se le suma la diferencia positiva.
        ELSE.
          T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF.   "Valor al debe esta en positivo, se le resta la diferencia positiva.
        ENDIF.
      ELSE.
        IF  T_DIF < 0.
          IF T_BSEG-SHKZG = 'H'.
            T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF. "Valor al haber esta negativo, se le resta la diferencia negativa.
          ELSE.
            T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF. "Valor al debe esta positivo, se le suma la diferencia negativa.
          ENDIF.
        ENDIF.
      ENDIF.
      MODIFY T_BSEG INDEX AA.

    ENDIF.
  ENDIF.

  CALL FUNCTION 'CALCULATE_TAX_DOCUMENT'
    EXPORTING
      I_BUKRS                   = ZINVFO-BUKRS
    TABLES
      T_BKPF                    = T_BKPF
      T_BSEG                    = T_BSEG
    EXCEPTIONS
      ERROR_CALCULATE_DISCOUNTB = 04
      USER_EXIT                 = 16.
  IF SY-SUBRC =  0.

    CALL FUNCTION 'ZACC_SIMULATED_DOC_DISPLAY'
      EXPORTING
        I_T020     = I_T020
        TIP_SALIDA = 'X'
      TABLES
        T_BKPF     = T_BKPF
        T_BSEG     = T_BSEG
        T_ERINF    = T_ERINF
        XXBSEG     = T_BSEG2
        XXBKPF     = T_BKPF2.
  ENDIF.
ENDFORM.                    " PERFOR_SIMULAR
*&---------------------------------------------------------------------*
*&      Form  MOD_IVA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOD_IVA .
  REFRESH: IT_T001.
*  IT_T001[] = G_TABLE_ITAB[].
  DATA: P_INDEX LIKE SY-TABIX.


  LOOP AT IT_T001.
    P_INDEX = SY-TABIX.
    MOVE: ZINVFO-MWSKZ TO IT_T001-MWSKZ.
    MODIFY IT_T001 INDEX P_INDEX.
  ENDLOOP.

  REFRESH: T_SALIDA.
  T_SALIDA[] =  IT_T001[].

  DATA: FILA TYPE LVC_S_ROW,
  COLU TYPE LVC_S_COL.
  CALL METHOD R_ALV_GRID->GET_CURRENT_CELL
    IMPORTING
      ES_ROW_ID = FILA
      ES_COL_ID = COLU.

*  CALL METHOD R_ALV_GRID->REFRESH_TABLE_DISPLAY.
*
*  CALL METHOD R_ALV_GRID->SET_CURRENT_CELL_VIA_ID
*    EXPORTING
*      IS_ROW_ID    = FILA
*      IS_COLUMN_ID = COLU.
ENDFORM.                    " MOD_IVA

*----------------------------------------------------------------------*
*  MODULE TABLE_INIT OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE TABLE_INIT OUTPUT.
  IF G_TABLE_COPIED IS INITIAL.
    SELECT * FROM ZACGL_ITEM_TBCTR
       INTO CORRESPONDING FIELDS
       OF TABLE G_TABLE_ITAB.
    G_TABLE_COPIED = 'X'.
    REFRESH CONTROL 'TABLE' FROM SCREEN '0100'.
  ENDIF.
ENDMODULE.                    "TABLE_INIT OUTPUT
*----------------------------------------------------------------------*
*  MODULE TABLE_GET_LINES OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE TABLE_GET_LINES OUTPUT.
  G_TABLE_LINES = SY-LOOPC.
  IF G_TABLE_ITAB IS INITIAL.
    INITIAL_LINE = 'X'.
  ELSE.
    CLEAR INITIAL_LINE.
  ENDIF.

  IF INITIAL_LINE EQ 'X'.
*    PERFORM INIT_LINE.
    IF G_TABLE_WA-BUKRS EQ SPACE.
      IF ZINVFO-BUKRS IS INITIAL.
        G_TABLE_WA-BUKRS = BKPF-BUKRS.
        IF G_AUSBK IS INITIAL.           "auslösender Buchungskreis
          G_AUSBK = BKPF-BUKRS.
        ENDIF.
      ELSE.
        G_TABLE_WA-BUKRS = ZINVFO-BUKRS.
        G_AUSBK =  ZINVFO-BUKRS.
      ENDIF.
    ENDIF.

    IF G_TABLE_WA-SHKZG IS INITIAL.
      IF KOART = 'K'.
        G_TABLE_WA-SHKZG  = 'S'.
      ELSE.
        G_TABLE_WA-SHKZG  = 'H'.
      ENDIF.
    ENDIF.

    IF G_TABLE_WA-HKONT IS INITIAL.
      IF ZINVFO-MWSKZ NE '**'.
        G_TABLE_WA-MWSKZ  = ZINVFO-MWSKZ.
      ENDIF.
    ENDIF.

    IF G_TABLE_WA-ZZRUT_TERC  EQ SPACE.
      G_TABLE_WA-ZZRUT_TERC  =   ZINVFO-LIFNR.
    ENDIF.

    IF NOT  G_TABLE_WA-BUKRS IS INITIAL
        AND NOT G_TABLE_WA-HKONT  IS INITIAL.
      CALL FUNCTION 'READ_ACCOUNT_TEXT'
        EXPORTING
          I_CCODE  = G_TABLE_WA-BUKRS
          I_GLACC  = G_TABLE_WA-HKONT
        IMPORTING
          E_GLTEXT = G_TABLE_WA-KONTO_TXT.
    ENDIF.
  ELSE.
    IF G_TABLE_WA-BUKRS EQ SPACE.
      IF ZINVFO-BUKRS IS INITIAL.
        G_TABLE_WA-BUKRS = BKPF-BUKRS.
        IF G_AUSBK IS INITIAL.           "auslösender Buchungskreis
          G_AUSBK = BKPF-BUKRS.
        ENDIF.
      ELSE.
        G_TABLE_WA-BUKRS = ZINVFO-BUKRS.
        G_AUSBK =  ZINVFO-BUKRS.
      ENDIF.
    ENDIF.

    IF G_TABLE_WA-SHKZG IS INITIAL.
      IF KOART = 'K'.
        G_TABLE_WA-SHKZG  = 'S'.
      ELSE.
        G_TABLE_WA-SHKZG  = 'H'.
      ENDIF.
    ENDIF.

    IF G_TABLE_WA-HKONT IS INITIAL.
      IF ZINVFO-MWSKZ NE '**'.
        G_TABLE_WA-MWSKZ  = ZINVFO-MWSKZ.
      ENDIF.
    ENDIF.


    IF NOT  G_TABLE_WA-BUKRS IS INITIAL
        AND NOT G_TABLE_WA-HKONT  IS INITIAL.
      CALL FUNCTION 'READ_ACCOUNT_TEXT'
        EXPORTING
          I_CCODE  = G_TABLE_WA-BUKRS
          I_GLACC  = G_TABLE_WA-HKONT
        IMPORTING
          E_GLTEXT = G_TABLE_WA-KONTO_TXT.
    ENDIF.

  ENDIF.
  ID_FIN_COMPANY = ZINVFO-BUKRS.

  CALL FUNCTION 'CON_FIN_GET_KOKRS_FROM_COMPANY'
    EXPORTING
      ID_FIN_COMPANY = ID_FIN_COMPANY
    IMPORTING
      ED_KOKRS       = G_TABLE_WA-KOKRS.

  MOVE-CORRESPONDING G_TABLE_WA TO ZACGL_ITEM_TBCTR.
  PERFORM GET_FIELD.
ENDMODULE.                    "TABLE_GET_LINES OUTPUT


*----------------------------------------------------------------------*
*  MODULE TABLE_MODIFY INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE TABLE_MODIFY INPUT.

  IF ZACGL_ITEM_TBCTR-BUKRS EQ SPACE.
    ZACGL_ITEM_TBCTR-BUKRS = ZINVFO-BUKRS.
    ID_FIN_COMPANY = ZACGL_ITEM_TBCTR-BUKRS.

    CALL FUNCTION 'CON_FIN_GET_KOKRS_FROM_COMPANY'
      EXPORTING
        ID_FIN_COMPANY = ID_FIN_COMPANY
      IMPORTING
        ED_KOKRS       = ZACGL_ITEM_TBCTR-KOKRS.
  ENDIF.

  MOVE-CORRESPONDING ZACGL_ITEM_TBCTR TO G_TABLE_WA.

  IF ZACGL_ITEM_TBCTR-HKONT NE SPACE.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        INFO   = TEXT-E14
        NAME   = 'ICON_CHECKED'
      IMPORTING
        RESULT = G_TABLE_WA-STATE.
  ENDIF.

  IF ZACGL_ITEM_TBCTR-AUFNR NE SPACE.
    SELECT SINGLE PRCTR INTO G_TABLE_WA-PRCTR
               FROM COAS
               WHERE AUFNR EQ ZACGL_ITEM_TBCTR-AUFNR.
  ENDIF.

  IF ZACGL_ITEM_TBCTR-ZZRUT_TERC  EQ SPACE.
    G_TABLE_WA-ZZRUT_TERC  =   ZINVFO-LIFNR.
  ENDIF.



  IF ZACGL_ITEM_TBCTR-KOSTL NE SPACE.
    SELECT SINGLE PRCTR INTO G_TABLE_WA-PRCTR
               FROM CSKS
               WHERE KOSTL EQ ZACGL_ITEM_TBCTR-KOSTL.
  ENDIF.


*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES02 ECDK917080 *
SORT G_TABLE_ITAB .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES02 ECDK917080 *
  MODIFY G_TABLE_ITAB
    FROM G_TABLE_WA
    INDEX TABLE-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TABLE_WA TO G_TABLE_ITAB.
  ENDIF.
ENDMODULE.                    "TABLE_MODIFY INPUT


*----------------------------------------------------------------------*
*  MODULE TABLE_USER_COMMAND INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE TABLE_USER_COMMAND INPUT.
  OOK_CODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TABLE'
                              'G_TABLE_ITAB'
                              'MARKSP'
*                              'FLAG'
                     CHANGING OOK_CODE.
  SY-UCOMM = OOK_CODE.
ENDMODULE.                    "TABLE_USER_COMMAND INPUT

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
                         P_TABLE_NAME
                         P_MARK_NAME
                CHANGING P_OK      LIKE SY-UCOMM.

  DATA: L_OK              TYPE SY-UCOMM,
        L_OFFSET          TYPE I.

  SEARCH P_OK FOR P_TC_NAME.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  L_OFFSET = STRLEN( P_TC_NAME ) + 1.
  L_OK = P_OK+L_OFFSET.
  CASE L_OK.
    WHEN 'INSR'.                      "insert row
      PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                        P_TABLE_NAME.
      CLEAR P_OK.

    WHEN 'DELE'.                      "delete row
      PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME.
      CLEAR P_OK.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                            L_OK.
      CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                        P_TABLE_NAME
                                        P_MARK_NAME   .
      CLEAR P_OK.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                          P_TABLE_NAME
                                          P_MARK_NAME .
      CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM FCODE_INSERT_ROW
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME             .

  DATA L_LINES_NAME       LIKE FELD-NAME.
  DATA L_SELLINE          LIKE SY-STEPL.
  DATA L_LASTLINE         TYPE I.
  DATA L_LINE             TYPE I.
  DATA L_TABLE_NAME       LIKE FELD-NAME.
  FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <LINES>              TYPE I.

  ASSIGN (P_TC_NAME) TO <TC>.

  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
  ASSIGN (L_LINES_NAME) TO <LINES>.

  GET CURSOR LINE L_SELLINE.
  IF SY-SUBRC <> 0.                   " append line to table
    L_SELLINE = <TC>-LINES + 1.
    IF L_SELLINE > <LINES>.
      <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
    ELSE.
      <TC>-TOP_LINE = 1.
    ENDIF.
  ELSE.                               " insert line into table
    L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
    L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
  ENDIF.
  L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.

  INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
  <TC>-LINES = <TC>-LINES + 1.
  SET CURSOR LINE L_LINE.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM FCODE_DELETE_ROW
              USING    P_TC_NAME           TYPE DYNFNAM
                       P_TABLE_NAME
                       P_MARK_NAME   .

  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.

  ASSIGN (P_TC_NAME) TO <TC>.

  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

  DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

  LOOP AT <TABLE> ASSIGNING <WA>.
    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
    IF <MARK_FIELD> = 'X'.
      DELETE <TABLE> INDEX SYST-TABIX.
      IF SY-SUBRC = 0.
        <TC>-LINES = <TC>-LINES - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                      P_OK.
  DATA L_TC_NEW_TOP_LINE     TYPE I.
  DATA L_TC_NAME             LIKE FELD-NAME.
  DATA L_TC_LINES_NAME       LIKE FELD-NAME.
  DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <LINES>      TYPE I.

  ASSIGN (P_TC_NAME) TO <TC>.
  CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
  ASSIGN (L_TC_LINES_NAME) TO <LINES>.


  IF <TC>-LINES = 0.
    L_TC_NEW_TOP_LINE = 1.
  ELSE.
    CALL FUNCTION 'SCROLLING_IN_TABLE'
         EXPORTING
              ENTRY_ACT             = <TC>-TOP_LINE
              ENTRY_FROM            = 1
              ENTRY_TO              = <TC>-LINES
              LAST_PAGE_FULL        = 'X'
              LOOPS                 = <LINES>
              OK_CODE               = P_OK
              OVERLAPPING           = 'X'
         IMPORTING
              ENTRY_NEW             = L_TC_NEW_TOP_LINE
         EXCEPTIONS
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
              OTHERS                = 0.
  ENDIF.

  GET CURSOR FIELD L_TC_FIELD_NAME
             AREA  L_TC_NAME.

  IF SYST-SUBRC = 0.
    IF L_TC_NAME = P_TC_NAME.
      SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
    ENDIF.
  ENDIF.

  <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.
ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                               P_TABLE_NAME
                               P_MARK_NAME.
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.

  ASSIGN (P_TC_NAME) TO <TC>.

  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

  LOOP AT <TABLE> ASSIGNING <WA>.

    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                 P_TABLE_NAME
                                 P_MARK_NAME .
  DATA L_TABLE_NAME       LIKE FELD-NAME.

  FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <WA>.
  FIELD-SYMBOLS <MARK_FIELD>.

  ASSIGN (P_TC_NAME) TO <TC>.

  CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
  ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

  LOOP AT <TABLE> ASSIGNING <WA>.

    ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

    <MARK_FIELD> = SPACE.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

INCLUDE ZFIMDP010.

INCLUDE ZACTIVO_FOIJO.
