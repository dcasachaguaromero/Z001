FUNCTION-POOL ZACC_SIMULATED_DOC_DISPLAY MESSAGE-ID F5.
TYPE-POOLS: SLIS.

TYPES: BEGIN OF T_TIME,
        DATE LIKE SY-DATUM,
        TIME LIKE SY-UZEIT,
        END OF T_TIME.

INCLUDE IS01HK02.

INCLUDE RFEPOSC5.                                           "ALRK240194

* (del) tables: bkpf,                                      "Note 193397
TABLES: ANLA,                                              "Note 193397
        BKPF,                                              "Note 193397
       *BKPF,
        BKDF,
       *BKDF,
        BSEG,
        BSET,                                               "N1023317
        BSIS,                                               "ALRK225335
        BVOR,
        KNA1,
        KNB1,                                              "Note 321533
        LFA1,
        LFB1,                                              "Note 321533
        SKA1,
        SKAT,
        T001,
        T003,
        T003T,
        T020,
        T041CT,                                             "ALRK225335
        TTXD,
        TVOIT,                                              "ALRK225335
        RF05A,                                              "ALRK225335
        UF05A,                                              "ALRK225335
        RF05L,
        RFOPT,
        RFOPT2.



DATA: COLOR_WA    TYPE SLIS_SPECIALCOL_ALV,
      EVENTS_WA   TYPE SLIS_ALV_EVENT,
      EVENTS      TYPE SLIS_T_EVENT,
      FIELDCAT_WA TYPE SLIS_FIELDCAT_ALV,
      FIELDCAT    TYPE SLIS_T_FIELDCAT_ALV,
      FIELDCAT_T  TYPE SLIS_T_FIELDCAT_ALV,
      IT_EVENT_EXIT_WA TYPE SLIS_EVENT_EXIT,
      IT_EVENT_EXIT TYPE SLIS_EVENT_EXIT OCCURS 1,
      LAYOUT      TYPE SLIS_LAYOUT_ALV,
      GS_KEYINFO  TYPE SLIS_KEYINFO_ALV,
      GS_PRINT    TYPE SLIS_PRINT_ALV,
      VARIANT     LIKE DISVARIANT,
      XVBSEC      LIKE FVBSEC  OCCURS 0 WITH HEADER LINE,
      XVBKPF      LIKE FVBKPF  OCCURS 1 WITH HEADER LINE,
      XVBSEG      LIKE FVBSEG  OCCURS 0 WITH HEADER LINE,
      XVBSET      LIKE FVBSET  OCCURS 0 WITH HEADER LINE.

DATA: TERRINF LIKE ACERRLOG OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF S_STATUS,
        WAEHR,                         "F = FW, H = HW, 2 = 2.HW, 3=3.HW
        BUPER(1)    TYPE C,            "X = Buper noch offen
      END OF S_STATUS.

DATA: XOPAR(1)     TYPE C,             "Soll Beleg ins opt.Archiv
      XWFLA(1)     TYPE C,             "Workflow active
      G_AKTYP      LIKE T020-AKTYP,    "activity type: change/displ
      G_EXIT(1)    TYPE C,             "Exit from 'New Document'
      G_UCOMM      LIKE SY-UCOMM.
DATA: G_DOCUMENT_EXISTS TYPE CHAR1.    "Parked/held doc     Note 361420

DATA: XZLBLG(1) TYPE C.                "Clearing document   Note1139298

*---- Ausgabetabellen/Strukturen mit Farbinfo --------------------------
DATA: BEGIN OF XBKPF OCCURS 0.
        INCLUDE STRUCTURE BKPF.
DATA: EXPAND(1),
      ANZSO LIKE RF05L-ANZSO,
      END OF XBKPF.

DATA: BEGIN OF XBSEG OCCURS 0.
        INCLUDE STRUCTURE BSEG.
DATA: KONTO LIKE RFPSD-KONTO,
      FAEDT LIKE RFPSD-FAEDT,
      KTEXT LIKE RFPSD-KTEXT,
      KTEXT_GL LIKE RFPSD-KTEXT_GL,
      ASSET_TXT LIKE ANLA-TXT50,                      "Note 0435578,
      GL_LTXT LIKE SKAT-TXT50,                        "Note 0446719
      SAKAN LIKE SKA1-SAKAN,
      WAERS LIKE BKPF-WAERS,
      HWAER LIKE BKPF-HWAER,
      HWAE2 LIKE BKPF-HWAE2,
      HWAE3 LIKE BKPF-HWAE3,
      projk_ext TYPE PROJK_EXT,                        "Note 575107
      COLOR(3),
      COLFW TYPE SLIS_T_SPECIALCOL_ALV,
      END OF XBSEG.

*------- Tabelle der Kontobezeichnungen -------------------------------*
DATA:    BEGIN OF TABBEZ OCCURS 10,
           BUKRS         LIKE BKPF-BUKRS,
           BELNR         LIKE BKPF-BELNR,
           BUZEI(3)      TYPE C,
           HKBEZ         LIKE BSEGL-HKBEZ,
           KTOBK(30)     TYPE C,
           KTOBL(50)     TYPE C,
           KONTO(10)     TYPE C,
           AUTHO(1)      TYPE C,
           EGMLD         LIKE RF05L-EGMLD,
         END OF TABBEZ.

DATA: YBVOR LIKE BVOR OCCURS 0 WITH HEADER LINE.

DATA: ARCHBSEG LIKE BSEG OCCURS 0 WITH HEADER LINE.         "ALRK238277
DATA: ARCHBSET LIKE BSET OCCURS 0 WITH HEADER LINE.        "Note 490520

DATA: XBSET LIKE BSET OCCURS 0 WITH HEADER LINE.

DATA: TACCDN TYPE TABLE OF ACCDN WITH HEADER LINE.         "Note 319123

* Buztab now included via RFEPOSC5                          "ALRK240194
* (del) data: begin of buztab occurs 30,                    "ALRK240194
* (del)   bukrs like bseg-bukrs,       " Buchungskreis       ALRK240194
* (del)   belnr like bseg-belnr,       " Belegnummer         ALRK240194
* (del)   gjahr like bseg-gjahr,       " Geschaeftsjahr      ALRK240194
* (del)   buzei like bseg-buzei,       " Buchungszeile       ALRK240194
* (del)   flaen(1) type c,             " X = Posten geaende  ALRK240194
* (del) end   of buztab.                                    "ALRK240194

* table for document items that cannot be displayed because of
* missing authority:
DATA: BEGIN OF GT_MISSING_AUTH OCCURS 0,
        BUKRS LIKE BSEG-BUKRS,                             "Note 0388044
        BELNR LIKE BSEG-BELNR,
        DASH,
        BUZEI LIKE BSEG-BUZEI,
        SEMICOLON,
      END OF GT_MISSING_AUTH.

* Buffer for creditor data                                 "Note 321533
DATA: BEGIN OF LFB1_BUFFER OCCURS 5,                       "Note 321533
        LIFNR LIKE LFA1-LIFNR,                             "Note 321533
        BUKRS LIKE LFB1-BUKRS,                             "Note 321533
        BEGRA LIKE LFA1-BEGRU,                             "Note 321533
        BEGRB LIKE LFB1-BEGRU,                             "Note 321533
        NAME1 LIKE LFA1-NAME1,                             "Note 321533
      END OF LFB1_BUFFER.                                  "Note 321533

* Buffer for debitor data                                  "Note 321533
DATA: BEGIN OF KNB1_BUFFER OCCURS 5,                       "Note 321533
        KUNNR LIKE LFA1-LIFNR,                             "Note 321533
        BUKRS LIKE LFB1-BUKRS,                             "Note 321533
        BEGRA LIKE LFA1-BEGRU,                             "Note 321533
        BEGRB LIKE LFB1-BEGRU,                             "Note 321533
        NAME1 LIKE LFA1-NAME1,                             "Note 321533
      END OF KNB1_BUFFER.                                  "Note 321533

* Maximum number of creditor/debitor buffer lines          "Note 321533
CONSTANTS: MAXBUF LIKE SY-TFILL VALUE 10.                  "Note 321533

DATA: ANZST(40),
      BEGRU        LIKE SKB1-BEGRU,
      BEGRA        LIKE LFA1-BEGRU,                        "Note 321533
      BEGRB        LIKE LFB1-BEGRU,                        "Note 321533
       DATE         LIKE BKPF-BUDAT,                        "Note 382301
      INDEX        LIKE SY-TABIX,
      OK-CODE(5)   TYPE C,             "OK Code (Funktionscode)
      XFELD        TYPE C,             " s. comments in MF05LTOP
* (del) buztab-zeile like sy-tabix,                         "ALRK240194
      COMREQ(1),                       "Commitrequest
      FRPE1        LIKE T001B-FRPE1,   "Monat dreistellig
      XBMODZ(1)    TYPE C,             "Zeile aenderbar ?
      DDTEXT       LIKE DD07T-DDTEXT,
      DOMVALUE     LIKE DD07L-DOMVALUE_L,
      EPOS,                            "Ruf aus Einzelpostenanzeige
      RCODE        LIKE SY-SUBRC,
      TCODE        LIKE SY-TCODE,
      OKCODE(5),                       "OKCODE to pass to caller
      D1120_OKCODE LIKE OK-CODE,       "OK-Code Dynpro 1120  ALRK225335
      CSLINE       LIKE SCREEN-NAME,   " Selected field     Note 369284
      OLD_BKTXT    LIKE BKPF-BKTXT,
      OLD_XBLNR    LIKE BKPF-XBLNR,
      STATUS(1),                       " 'L'ist, 'H'ierarchische Liste
      VARIANT_FIX,                     "'X': Variante nicht bestimmen
* (del) x_commit(1),                                         ARLK240194
* (del) x_nextl(1),                    " Next line item      ALRK232386
      XCHNG(1),                        " 'X':Es gab Änderungen
      XREVS(1),                        " Reverse document    ALRK225335
      XXREF(1)     TYPE C,             " Suche über Referenz ALRK241034
      X_POSTING_FORBIDDEN TYPE XFELD,  " Worflow active     Note 308896
      X_PARKING_FORBIDDEN TYPE XFELD,  " User must not park  Note449741
      XSPIU(1),                        " Benutzeroption aus RFOPT
      no_docu_exchange(1)  TYPE c.     "Kz.: Absprung zu anderem Beleg?

DATA: AUTH_GSB(1).                     "authority check      Note 634582


*------- Felder fuer Workflow
DATA:    BEGIN OF WFLKEY,
            BUKRS            LIKE BKPF-BUKRS,
            BELNR            LIKE BKPF-BELNR,
            GJAHR            LIKE BKPF-GJAHR,
         END OF WFLKEY.

DATA:    BEGIN OF WFLPOS,
            BUKRS            LIKE BKPF-BUKRS,
            BELNR            LIKE BKPF-BELNR,
            GJAHR            LIKE BKPF-GJAHR,
            BUZEI            LIKE BSEG-BUZEI,
         END OF WFLPOS.

*------- BDCDATA-Tabelle für CALL TRANSACTION ------------- "ALRK225335
DATA: BDCTAB     TYPE BDCDATA OCCURS 8 WITH HEADER LINE.    "ALRK225335
DATA: BDCMODE(1) TYPE C.                                    "ALRK225335
* Constants
CONSTANTS: C_AKTYP_DISPLAY VALUE 'A',
           C_AKTYP_CHANGE  VALUE 'V',
           C_AKTYP_ADD     VALUE 'H',
           C_BEL_VORERF    VALUE 'V',
           C_YES           VALUE 'J',
           C_STAT_LIST     VALUE 'L',
           C_STAT_HIERSEQ  VALUE 'H',
           C_DEBIT         VALUE 'H',
           C_OFF           VALUE '0',
           C_ON            VALUE '1',
           C_0             VALUE '0',                      "Note 193397
           C_A             VALUE 'A',
           C_B             VALUE 'B',
           C_D             VALUE 'D',
           C_H             VALUE 'H',                      "Note 302995
           C_L             VALUE 'L',                            "ERP05
           C_M             VALUE 'M',
           C_S             VALUE 'S',
           C_U             VALUE 'U',                       "ALRK240194
           C_V             VALUE 'V',                      "Note 313252
           C_X             VALUE 'X',
           C_Z             VALUE 'Z',                      "Note 302995
           C_*             VALUE '*',                      "Note 193397
           C_DASH          VALUE '-',
           C_SEMICOLON     VALUE ';'.
CONSTANTS: C_ACT_POST(2)   VALUE '01',                      "Note449741
           C_ACT_CHGE(2)   VALUE '02',                      "Note449741
           C_ACT_DISP(2)   VALUE '03',                      "Note449741
           C_ACT_FIPP(2)   VALUE '77'.                      "Note449741

************************************************************************
* Object type references, data for object services
************************************************************************

DATA: GOS_ICON TYPE REF TO CL_GOS_MANAGER.                  "Note 402273

CONSTANTS: C_FI_OBJECT(4) VALUE 'BKPF'.
