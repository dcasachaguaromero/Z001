FUNCTION-POOL ZFI_F4_MWSKZ MESSAGE-ID FH.
TYPE-POOLS: SHLP.
INCLUDE MF05A_COMMON_MACROS.                                "Note430830
TABLES:  KNBK,
         LFBK,
         RFCU1,
         RFCU3,
         SKA1,
         SKAT,
         SKB1,
         T001,
         T004,
         T005,                                              "Note814711
         T007A,
         T007S,
         T030B,
         T050T,
         T052, *T052,
         T052S,
         T052U,
         T074,
         T074T,
         T074U.

*------- Tabelle aller Partnerbanktypen und zugehöriger Bankverb. ------
DATA:    BEGIN OF BVTTAB OCCURS 20,
           BVTYP(50) TYPE C,                         "Note590483/642346
         END OF BVTTAB.

*------- Tabelle aller Währungstypen und ihrer Bezeichnung -------------
DATA:    BEGIN OF CTPTAB OCCURS 5,
           CURTP LIKE DD07T-DDTEXT,
         END OF CTPTAB.

*------- Tabelle aller Steuerkennzeichen und ihrer Bezeichnung ---------
DATA:    BEGIN OF MWSTAB OCCURS 5,
           MWSTX LIKE DD07T-DDTEXT,
         END OF MWSTAB.

*------- DFIES-Informationen zu allen Tabellen aus TABTAB --------------
DATA:    BEGIN OF DFIESTAB OCCURS 200.
        INCLUDE STRUCTURE DFIES.
DATA:    END OF DFIESTAB.

*------- Tabelle aller nicht zulässigen OK-Codes -----------------------
DATA:    BEGIN OF EXCLTAB OCCURS 1,
           OKCOD(5) TYPE C,
         END OF EXCLTAB.

*------- Tabelle aller möglichen Feldnamen und ihrer Beschreibung ------
DATA:    BEGIN OF FELDTAB OCCURS 200,
           FNAME LIKE RFCU3-FNAME,
           FTEXT LIKE DD03D-DDTEXT,
           DLENG LIKE DD01D-LENG,
           OUTPL LIKE DD01D-OUTPUTLEN,
           INTTP LIKE DD03D-INTTYPE,
           INTLN LIKE DD03D-INTLEN,
         END OF FELDTAB.

*------- interne Tabelle der Bezugsfelder für F4 -----------------------
DATA:    BEGIN OF FLDTAB OCCURS 2.
        INCLUDE STRUCTURE HELP_VALUE.
DATA:    END OF FLDTAB.

*-------- Kommunikationsstruktur für schöne neue F4-Welt ---------------
DATA:    INTERFACE_WA LIKE DDSHIFACE.

*------- Save-Tabelle für EXCTAB ---------------------------------------
DATA:    BEGIN OF OLD_EXCTAB OCCURS 15.
        INCLUDE STRUCTURE RFFLD.
DATA:    END OF OLD_EXCTAB.

*------- Save-Tabelle für TABTAB ---------------------------------------
DATA:    BEGIN OF OLD_TABTAB OCCURS 5.
        INCLUDE STRUCTURE RFTAB.
DATA:    END OF OLD_TABTAB.

*------- Tabelle für dynamische WHERE-Bedingung ------------------------
DATA:    WTAB(72) TYPE C OCCURS 3 WITH HEADER LINE.

*------- Zahlungsbedingungen aus T052 ----------------------------------
DATA:    BEGIN OF XT052 OCCURS 30.
        INCLUDE STRUCTURE T052.
DATA:    END OF XT052.

*------- Zahlungsbedingungen aus T052 und ihre Beschreibung ------------
DATA:    BEGIN OF ZBTXT OCCURS 100,
           ZTERM     LIKE T052-ZTERM,
           ZTEXT(60) TYPE C,           " > 50 wegen Raten
         END OF ZBTXT.

*------- Einzelfelder --------------------------------------------------
DATA:    BREITE_POPUP   TYPE I,        " Breite des Popups
         CHAR(80)       TYPE C,        " Textfeld
         CHAR7(7)       TYPE C,        " Textfeld
         HEADER1(10)    TYPE C,        " Spaltenüberschrift
         HEADER2(20)    TYPE C,        " Spaltenüberschrift
         INCLUDE(8)     TYPE C,        " aktueller Include
         INDEX          LIKE SY-TABIX, " Index zum Lesen int. Tab.
         LAENGE_FNAME   TYPE I,        " max. Länge von FNAME
         LAENGE_FTEXT   TYPE I,        " max. Länge von FTEXT
         OFFSET         TYPE I,        " Offset-Angabe
         OK_CODE(5)     TYPE C,        " OK-Code
         OLD_INDEX      LIKE SY-TABIX, " Save-Feld für INDEX
         OLD_INTTP      LIKE RFCU4-INTTP,   " Save-Feld für I_INTTP
         OLD_KUNNR      LIKE KNBK-KUNNR,    " Save-Feld für I_KUNNR
         OLD_LIFNR      LIKE LFBK-LIFNR,    " Save-Feld für I_LIFNR
         OLD_XFELD      LIKE RFCU4-FLAGX,   " Save-Feld für I_XKEYF
         OLD_XGRKL      LIKE RFCU4-FLAGX,   " Save-Feld für I_XKEYF
         OLD_XKEYF      LIKE RFCU4-FLAGX,   " Save-Feld für I_XKEYF
         OLD_XLOGF      LIKE RFCU4-FLAGX,   " Save-Feld für I_XKEYF
         POS            LIKE SY-CUCOL, " Position für WRITE
         RC             LIKE SY-SUBRC, " Return-Code
         REFE           TYPE I,        " Rechenfeld
         SROWS          LIKE SY-SROWS, " Anzahl Zeilen auf Dynpro
         X1             LIKE SY-CUCOL, " X-Koordiante für Popup
         X2             LIKE SY-CUCOL, " X-Koordinate für Popup
         Y1             LIKE SY-CUROW, " Y-Koordinate für Popup
         Y2             LIKE SY-CUROW. " Y-Koordinate für Popup

TYPES: BEGIN OF SCVTEXT_TYPE,                               "P00K019158
         SCVARIANT LIKE SHDSVTXCI-SCVARIANT,                "P00K019158
         SCVTEXT LIKE SHDSVTXCI-SCVTEXT,                    "P00K019158
       END OF SCVTEXT_TYPE.                                 "P00K019158

TYPES: BEGIN OF SCVTEXT_BUFFER,                             "P00K019158
         PROGNAME LIKE SY-REPID,                            "P00K019158
         DYNNR LIKE SY-DYNNR,                               "P00K019158
         SCVARIANT LIKE SHDSVTXCI-SCVARIANT,                "P00K019158
         SCVTEXT LIKE SHDSVTXCI-SCVTEXT,                    "P00K019158
       END OF SCVTEXT_BUFFER.                               "P00K019158

TYPES: BEGIN OF TEMPDOC_TYPE,                              "Note 208325
         TEMPD LIKE UF05A-TEMPD,                           "Note 208325
       END OF TEMPDOC_TYPE.                                "Note 208325

DATA  SHDSVTXCI_TAB LIKE SHDSVTXCI OCCURS 0                 "P00K019158
                    WITH HEADER LINE.                       "P00K019158

DATA: SCVTEXT_BUFFER TYPE TABLE OF SCVTEXT_BUFFER           "P00K019158
                           WITH HEADER LINE.                "P00k019158

DATA  SHDSVCI_TAB LIKE SHDSVCI OCCURS 0
                    WITH HEADER LINE.
