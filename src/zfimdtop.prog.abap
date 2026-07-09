*&---------------------------------------------------------------------*
*&  Include           ZFIMDTOP
*&---------------------------------------------------------------------*

DATA: BEGIN OF MANDTAB OCCURS 5,
        TAB(5),
        FIELDNAME LIKE DFIES-FIELDNAME,                    "Note 332655
        REPTEXT LIKE DFIES-REPTEXT,                        "Note 332655
        MSGID LIKE SY-MSGID,                               "Note 389107
        MSGNO LIKE SY-MSGNO,                               "Note 389107
        MSGV1 LIKE SY-MSGV1,                               "Note 389107
        MSGV2 LIKE SY-MSGV1,                               "Note 389107
        MSGV3 LIKE SY-MSGV1,                               "Note 389107
        MSGV4 LIKE SY-MSGV1,                               "Note 389107
      END OF MANDTAB.

DATA: SKLIN1 LIKE SKLIN, SKLIN2 LIKE SKLIN.
**DATA  g_status(1).                     "01: FB60 02: FV60 03: vollst.
*DATA  g_aktyp LIKE t020-aktyp.         "=A: display mode Miru
DATA: G_139_DISPLAYED(1) TYPE C.
DATA: G_252_DISPLAYED(1) TYPE C.                            "Note517172
DATA: G_ESR_REQ(1) TYPE C.             "Manual input ESR    Note 318313
DATA: G_SOFTCHECK TYPE XFELD.          "...because del of pp Note444834
DATA: G_ORG_BELNR LIKE BKPF-BELNR.     "No of parked doc   "Note 393538
DATA  G_ORG_GJAHR LIKE BKPF-GJAHR.     "Year of parked doc   Note419812
DATA: G_PFKEY LIKE SY-PFKEY.                                "Note481737
DATA: G_SPLITTCLINES LIKE SY-LOOPC.                         "Note481737
DATA: G_LOOPC LIKE SY-LOOPC.                                "Note481737
DATA: G_ACTIVETAB(4).                  "New tab              Note486418
DATA: G_EMPFB_WARNED TYPE XFELD.                            "Note489923


DATA: G_NO_ITEM TYPE FLAG_X.           "No items in MIRO     Note636506

DATA: CHANGE_STATUS(3).
CONSTANTS: BEGIN OF C_T_001,
             TAB1 LIKE SY-UCOMM VALUE 'T_001_FC1',
             TAB2 LIKE SY-UCOMM VALUE 'T_001_FC2',
             TAB3 LIKE SY-UCOMM VALUE 'T_001_FC3',
           END OF C_T_001.

CONTROLS:  T_001 TYPE TABSTRIP.

DATA:      BEGIN OF G_T_001,
             SUBSCREEN   LIKE SY-DYNNR,
             PROG        LIKE SY-REPID VALUE 'ZFIMDP005',
             PRESSED_TAB LIKE SY-UCOMM VALUE C_T_001-TAB1,
           END OF G_T_001.





DATA:      OOK_CODE LIKE SY-UCOMM.

DATA: ACCOUNT_TYPE(10),                "'Vendor' or 'Customer'
      AKONT LIKE LFB1-AKONT,           "Rec. account
      BLART_PAI LIKE BKPF-BLART,       "Doc. type early transported
      BUTTON_VISIBLE,                  "'1': det. button for EWT vis.
*      CHAR(20),                        "Character for several actions
      CHAR61(61),
      CURSOR(61),                      "Fieldname for cursor
      ICONCODE LIKE ICON-NAME,
      FIRSTCALL VALUE 'X',             "='X' <=> first PBO of screens
      KOART LIKE BSEG-KOART  VALUE 'K',           "Rel. acc. type for screen det.
      KTOSL LIKE BSEG-KTOSL,
      BSCHH LIKE BSEG-BSCHL,
      BSCHS LIKE BSEG-BSCHL,
*      FAUS1 LIKE TBSL-FAUS1,           "Field status part 1
*      FAUS2 LIKE TBSL-FAUS2,           "Field status part 2
      FNAME LIKE ACSCR-FNAME,          "Fieldname
      G_JPINVSUM TYPE BOOLE_D,         "JP invoice summary   Note933772
      G_LIFNR TYPE LNRZA,              "alt. payer vendor    Note558064
      G_BEGRU TYPE BRGRU,              "alt. payer vendor    Note558064
      G_KTOKK TYPE KTOKK,              "alt. payer vendor    Note558064
      G_KTOKD TYPE KTOKD,              "alt. payee customer  Note558064
      G_KUNNR TYPE KNRZA,              "alt. payee customer  Note558064
      LSTML LIKE T007A-LSTML,          "Country if plants abroad is act
      MASTER_DATA_DISPL,               "Master Data was displayed
      MWSKZ_KONTEXT LIKE BSEG-MWSKZ,   "last used tax indicator
      NO_CHECKS,                       " 'X' = keine Prüfungen durchf.
      NO_SPLIT_ORG,                    " X = no amount split in org doc
      G_EXIT_COMMAND TYPE XFELD,       "Exit com processed  Note 397489
      NROBK TYPE I,                    "Number of banks (LFBK or KNBK)
      OKCODE(5),
      E_OKCODE LIKE OKCODE,            "To return to FBVB    Note481737
      OLD_FDTAG LIKE BSEG-FDTAG,       "For manual Cash Forecast entry
      OLD_FDLEV LIKE BSEG-FDLEV,       "Dito
      OLD_ESR_LIFNR LIKE LFA1-LIFNR,   "For populating ESR  Note 204840
      OLD_ZFBDT LIKE BSEG-ZFBDT,       "Keeping Basel. Date Note 542237
      PARGB     LIKE BSEG-PARGB,       " Keep Partner BA
      PROG0100 LIKE RS37A-DYNPROG,
      RC_AUTH_BANK,                    " bank data display allowed ?
      REFE(8)   TYPE P,                " Fields for several
*      REFE1(8)  TYPE P,                "      |
      REFE2(8)  TYPE P,                " calculations
      S_STATUS(1),                     "message expired currency
      S_DATE LIKE BKPF-BUDAT,          "message expired currency
      S_WAERS LIKE BKPF-WAERS,         "message expired currency
      SCRN0100  LIKE FELD-DYNNR,
      SGTXT     LIKE BSEG-SGTXT,
      SUM       LIKE ACSPLT-WRBTR,
      TEXT_BKTXT(15),                  "Text for dynpro
      TEXT_BLDAT(15),                  "Text for document date
      QST_BUKRS LIKE BSEG-BUKRS,
      XDOCT_CHG,                       "Document type changed (N664972)
      XCPD_CALL,                       "CPD Call was done
      XNOTETEXT,                       "Text in TextControl was loaded
      XERRHKONT,                       "Error when rec acc. was entered
      XFDAE,                      "Entry of cash forecast data allowed
      XHEAD,                           "Manual head office !
      XNOZENT,                     "posting to branch accountNote 574261
      XUMSM,                           "Special GL was reported
      XWFLA1 LIKE BOOLE-BOOLE,                              "Note916729
      XDERIVE,                         "Suppress message F5231
      VORSCHL_GRICD       LIKE BSEG-GRICD,    " Vorschl.Gross.Inc.Cd.
      VORSCHL_GRIRG       LIKE BSEG-GRIRG,    " Vorschl.Gross.Inc.Rg.
      VORSCHL_GITYP       LIKE BSEG-GITYP,    " Vorschl. Verteil.typ
      WT_STATUS,                       "'N'ew/'O'ld WT or none
      WT_DYNPROG   LIKE RS37A-DYNPROG, " Progr. which owns subscreen
      WT_SUBSCREEN LIKE RS37A-DYNNUMB, " Subscreen for new/old WT
      WTPNT_MAX    LIKE ACSPLT-WTPNT,  "maximal pointer number
      XWT_FIRST_TIME,             "initialize WT only once note 497854
      XMAND,                      "Are mandatory fields not filled ?
      XSGTXT_FROM_RSTGR,          "Indicator: Text was taken fr. RSTGR
      X_HEADVALCH,                "Validation of header checked in MF05A
      X_LSTML,                    "Indicator: LSTML entered manually
      ZTERM_DEF LIKE BSEG-ZTERM,  "Amountsplit default copy "Note539451
      ZTERM_TEXT(60),             "Basic Tab Text for ZTERM
      ZTERM_ZLSCH LIKE BSEG-ZLSCH,                          "Note893433
      ZTERM_XCHPM LIKE T052-XCHPM,                          "Note893433
      ZBD1T(3), ZBD2T(3), ZBD3T(3), ZBD1P(6), ZBD2P(6).

DATA: INVFO_OLD LIKE ZINVFO.

DATA: CON_SPACE(3)        TYPE C VALUE ''' ''',
      FLD_GSBER(1)        TYPE C VALUE '1',
      FLD_GSBER_ANZ(1)    TYPE C VALUE '2',
      FLD_KOART(1)        TYPE C VALUE '3',
      NULL8(8)            TYPE C VALUE '00000000',
      TCODE               LIKE SY-TCODE VALUE 'FREE'.
CONSTANTS:
      GLVOR_RMRP       LIKE BKPF-GLVOR VALUE 'RMRP',       "Note 303582
*
      CHAR_RFBU(4)     TYPE C VALUE 'RFBU'.                "Note 202102
CONSTANTS: CON_SPLIT_LOOPC LIKE SY-STEPL VALUE 13,          "Note481737
           CON_SPLIT_WT_LOOPC LIKE SY-STEPL VALUE 16,       "Note481737
           CON_SPLIT_WRBTR(12) VALUE 'ACSPLT-WRBTR',        "Note481737
           CON_SPLIT_WTICO(12) VALUE 'ACSPLT-WTICO',        "Note481737
           CON_SPLIT_ZLSCH(12) VALUE 'ACSPLT-ZLSCH',        "Note481737
           CON_SPLIT_MWSKZ(12) VALUE 'ACSPLT-MWSKZ',        "Note481737
           CON_SPLIT_UZAWE(12) VALUE 'ACSPLT-UZAWE',        "Note481737
           CON_SPLIT_ZTERM(12) VALUE 'ACSPLT-ZTERM',        "Note481737
           CON_SPLIT_WT_KEY(19)                             "Note481737
             VALUE 'ACWT_ITEM-SPLIT_KEY',                   "Note481737
           CON_SPLIT_WT_WITHC(19)                           "Note481737
             VALUE 'ACWT_ITEM-WT_WITHCD',                   "Note481737
           CON_SPLIT_WT_QSSHB(18)                           "Note481737
             VALUE 'ACWT_ITEM-WT_QSSHB',                    "Note481737
           CON_SPLIT_WT_QBSHB(18)                           "Note481737
             VALUE 'ACWT_ITEM-WT_QBSHB'.                    "Note481737

DATA: NETSUM LIKE BSEG-WRBTR.
DATA: BUTXT(60).
*DATA: G_SOFTCHECK TYPE XFELD.          "...because del of pp Note444834
*DATA: G_ORG_BELNR LIKE BKPF-BELNR.     "No of parked doc   "Note 393538
*-- internal table for fields to display: normal F4 --------------------
DATA: FLDTAB LIKE HELP_VALUE OCCURS 2 WITH HEADER LINE.
DATA: F4HLP  LIKE DYNPREAD   OCCURS 0 WITH HEADER LINE.

*-- internal table for text of temporary document.
DATA: IT_TMP_TEXT LIKE RF61F OCCURS 1.
DATA: CHAR_A(1) TYPE C VALUE 'A',
      CHAR_B(1) TYPE C VALUE 'B',
      CHAR_C(1) TYPE C VALUE 'C',
      CHAR_D(1) TYPE C VALUE 'D',
      CHAR_E(1) TYPE C VALUE 'E',
      CHAR_F(1) TYPE C VALUE 'F',
      CHAR_G(1) TYPE C VALUE 'G',
      CHAR_H(1) TYPE C VALUE 'H',
      CHAR_I(1) TYPE C VALUE 'I',
      CHAR_J(1) TYPE C VALUE 'J',
      CHAR_K(1) TYPE C VALUE 'K',
      CHAR_L(1) TYPE C VALUE 'L',
      CHAR_M(1) TYPE C VALUE 'M',
      CHAR_N(1) TYPE C VALUE 'N',
      CHAR_O(1) TYPE C VALUE 'O',
      CHAR_P(1) TYPE C VALUE 'P',
      CHAR_Q(1) TYPE C VALUE 'Q',
      CHAR_R(1) TYPE C VALUE 'R',
      CHAR_S(1) TYPE C VALUE 'S',
      CHAR_T(1) TYPE C VALUE 'T',
      CHAR_U(1) TYPE C VALUE 'U',
      CHAR_V(1) TYPE C VALUE 'V',
      CHAR_W(1) TYPE C VALUE 'W',
      CHAR_X(1) TYPE C VALUE 'X',
      CHAR_Y(1) TYPE C VALUE 'Y',
      CHAR_Z(1) TYPE C VALUE 'Z',
      CHAR__(1) TYPE C VALUE '_',
      CHAR_*(1) TYPE C VALUE '*',
      CHAR_-(1) TYPE C VALUE '-',
      CHAR_?(1) TYPE C VALUE '?',
      CHAR_0(1) TYPE C VALUE '0',
      CHAR_1(1) TYPE C VALUE '1',
      CHAR_2(1) TYPE C VALUE '2',
      CHAR_3(1) TYPE C VALUE '3',
      CHAR_4(1) TYPE C VALUE '4',
      CHAR_5(1) TYPE C VALUE '5',
      CHAR_6(1) TYPE C VALUE '6',
      CHAR_7(1) TYPE C VALUE '7',
      CHAR_8(1) TYPE C VALUE '8',
      CHAR_9(1) TYPE C VALUE '9'.

DATA: INFINITY(20) VALUE 'ZZZZZZZZZZZZZZZZZZZZ'.
*-------------- Fields that are passed to or from outside --------------
DATA: ACTAB(5),                        " Active Tab set automatically
      ANZBZ LIKE RF05A-ANZBZ,          " Number of items in document
      AZSAL LIKE RF05A-AZSAL,          " Balance of current document
      BUSCS TYPE BUSCASE,              " Invoice or Credit Memo (R or G)
      EGREL,                           " Flag: relevant for EG
      REGUL_DEFINED,                   " Individual payer(e) defined
      TXJCD LIKE BSEG-TXJCD.      "Information about tjrdcde in master


DATA:  BEGIN OF TAX,
         BUKRS             LIKE BSEG-BUKRS,    " Bulrs f. Steuer
         KALSM             LIKE T005-KALSM,    " Schema
         MWSKZ             LIKE BSEG-MWSKZ,    " St.Kennz. Kontokorr.
         FWSTE             LIKE BSET-FWSTE,    " Steuerbetrag FW
         HWSTE             LIKE BSET-HWSTE,    " Steuerbetrag HW
         SHKZG             LIKE BSET-SHKZG,    " S/H Kennz. Steuern
         XSTVR             LIKE BKPF-XMWST,    " Steuern im Steuerbild
         ZDEKR             LIKE BSEG-BUZEI,    " Erste Kontokorrent Zl
         H2STE             LIKE BSET-H2STE,    " Steuerbetrag Hw2
         H3STE             LIKE BSET-H3STE,    " Steuerbetrag Hw3
       END OF TAX.
*DATA: TACSCR LIKE ACSCR OCCURS 0 WITH HEADER LINE.
DATA: SGLTAB LIKE T074T OCCURS 0 WITH HEADER LINE.
