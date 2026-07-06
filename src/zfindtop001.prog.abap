*&---------------------------------------------------------------------*
*&  Include           ZFINDTOP001
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ZZACGL_ITEM.
        INCLUDE STRUCTURE ZACGL_ITEM.
TYPES: END OF ZZACGL_ITEM.

DATA: gener LIKE t020-gener.                                "Note424583

data: g_lstml LIKE t007a-lstml.

*DATA:    WA_TABLE TYPE CXTAB_COLUMN,
*         G_SUPPRESS_DIALOG,                                   "Note 206755
*      G_MAIN_SUPPRESS_DIALOG. " Main screen invisible      "Note 410289
DATA: GD_PS_US_ACTIVE(1) TYPE C,
      GD_PS_US_UZAWE TYPE UZAWE.                 "ALC & payment office
DATA:    DUMMY_C(1)          TYPE C.             " Initialisierung <FS>
DATA:
      BEGIN OF TAB_NAMES OCCURS 0,
        MODIF(3),
        TABNM LIKE TMODU-TABNM,
        FELDN LIKE TMODU-FELDN,
      END OF TAB_NAMES.


DATA:    G_CURSORFIELD(30).
DATA: TAB_FSKB TYPE ZACGL_ITEM OCCURS 0 WITH HEADER LINE.
DATA:    INITIAL_LINE(1),
            G_BSEG_KK LIKE BSEG.

DATA: G_CURSORLINE LIKE SY-STEPL,
      G_CURSORLINE_COPY LIKE G_CURSORLINE.                  "Note425926
DATA:
      CRS_SAVELINE LIKE G_CURSORLINE.

DATA: CRS_SAVEFIELD LIKE G_CURSORFIELD.

TYPES: BEGIN OF SCREEN_MODIF,                               "Note410691
         GROUP1 LIKE SCREEN-GROUP1,                         "Note410691
       END OF SCREEN_MODIF,                                 "Note410691
       MODIFS TYPE SORTED TABLE OF SCREEN_MODIF             "Note410691
              WITH UNIQUE KEY GROUP1.                       "Note410691

DATA:                                                       "Note410691

*------- Field status, as requested by MM                   "Note398937
      TACSCR LIKE ACSCR OCCURS 0 WITH HEADER LINE,          "Note398937

*------- Table for dynpro field modifs -------------------- "Note410691
      MODIFS TYPE MODIFS,                                   "Note410691
      MODIF_WA TYPE LINE OF MODIFS.                         "Note410691


DATA: BEGIN OF LT_RCVID_MAN OCCURS 0,
        BUZEI LIKE BSEG-BUZEI,
        XRIMN TYPE XFELD,
      END OF LT_RCVID_MAN.

DATA:    G_LINES TYPE I VALUE 12,
      G_NEW_LINES TYPE I VALUE 12.
DATA: BEGIN OF GT_MANTAX OCCURS 0,
         BUZEI    LIKE BSEG-BUZEI,
         MWSKZ    LIKE BSEG-MWSKZ,
         WRBTR    LIKE BSEG-WRBTR,
         DMBTR    LIKE BSEG-DMBTR,
         FWBAS    LIKE BSEG-FWBAS,
         HWBAS    LIKE BSEG-HWBAS,
      END OF GT_MANTAX.

*DATA: G_FIRST_BUZEI LIKE BSEG-BUZEI,                        "Note487375
*      G_LAST_BUZEI LIKE BSEG-BUZEI,                         "Note487375
*      G_SAVE_TOP_LINE LIKE TABLE-TOP_LINE.                  "Note487375

DATA:
   G_AUSBK LIKE BKPF-BUKRS,
      G_BUSCS LIKE RF05A-BUSCS,
            G_AUSBK_BKPF LIKE BKPF,
              G_OLD_KURSF LIKE BKPF-KURSF,
                    G_OLD_TXJCD LIKE BSEG-TXJCD,
    G_TXJCD LIKE BSEG-TXJCD,
    G_TXJCD_STEPL LIKE SY-STEPL,
          FELDAUSWAHL   LIKE TBSL-FAUS1,
      FELDAUSWAHL2        LIKE TBSL-FAUS2,
            G_VORSCHL_GRIRG LIKE LFA1-REGIO, "Argentinia
      G_VORSCHL_GRICD LIKE LFB1-GRICD,
      G_VORSCHL_GITYP LIKE LFB1-GRIDT,
            G_CHECKS_BYPASSED.               "OK changed to no ch Note 386041





* field symbols
FIELD-SYMBOLS:  <FIELD> TYPE SIMPLE,
                <FAUSW> TYPE C.
* field symbols for generic tablecontrol fields
FIELD-SYMBOLS: <T_C1> TYPE ANY, <T_C2> TYPE ANY, <T_C3> TYPE ANY, "ERP05
               <T_C4> TYPE ANY, <T_C5> TYPE ANY.            "ERP05

* Note 568934: account assignment templates and field status
DATA: BEGIN OF LT_TAB_FSKB OCCURS 0.
        INCLUDE STRUCTURE BSEGS.
        INCLUDE STRUCTURE NONBSEG.
DATA: END OF LT_TAB_FSKB.

DATA: GT_MATCH   TYPE TABLE OF FAGL_TCMATCH,                "ERP05
      GT_FLDTAB TYPE TABLE OF DFIES.                        "ERP05



DATA: TAB_MARKED_LINES LIKE ZACGL_ITEM OCCURS 0 WITH HEADER LINE,
      TAB_XBKPF_IMP LIKE BKPF OCCURS 0 WITH HEADER LINE,
      TAB_ERROR LIKE ACERRLOG OCCURS 0 WITH HEADER LINE.
