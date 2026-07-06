DATA:    BEGIN OF COMMON PART RF05A.
*----------------------------------------------------------------------
*        MF05ACOM
*----------------------------------------------------------------------
*
*        COMMON DATA für Berichte SAPMF05A ...
*
*  XBKPF  Belegkoepfe beim Erstellen neuer Belege
*  XBSEG  Belegzeilen des neuen Beleges
*  XBSEGT Zu generierende Steuerbuchungen
*  XBSEC  CPD-Zeilen des neuen Beleges
*  XBSED  Wechsel-Zeilen des neuen Beleges
*  XBSET  Steuerzeilen des neuen Beleges
*  YBKPF  Belegkoepfe eines gemerkten Beleges
*  YBSEG  Belegzeilen eines gelesenen / gemerkten Beleges
*  YBSEC  CPD-Zeilen eines gelesenen / gemerkten Beleges
*  YBSED  Wechsel-Zeilen eines gelesenen / gemerkten Beleges
*  YBSET  Steuerzeilen des gemerkten Beleges
*  XBSEGZ Zusatzinformation zum Beleg, die ans RWIN weitergereicht wird
*
*----------------------------------------------------------------------

*------- Belegkoepfe beim Erstellen neuer Belege
DATA:    BEGIN OF XBKPF OCCURS 2.
        INCLUDE STRUCTURE BKPF.
DATA:    END OF XBKPF.

*------- Belegzeilen des neuen Beleges
DATA:    BEGIN OF XBSEG OCCURS 7.
        INCLUDE STRUCTURE BSEG.
DATA:    END OF XBSEG.

*------- Zu generierende Steuerbuchungen (CREATE_TAX_ITEM)
DATA:    BEGIN OF XBSEGT OCCURS 3.
        INCLUDE STRUCTURE BSEGT.
DATA:    END OF XBSEGT.

*------- CPD-Zeilen des neuen Beleges
DATA:    BEGIN OF XBSEC OCCURS 1.
        INCLUDE STRUCTURE BSEC.
DATA:    END OF XBSEC.

*------- Wechsel-Zeilen des neuen Beleges
DATA:    BEGIN OF XBSED OCCURS 1.
        INCLUDE STRUCTURE BSED.
DATA:    END OF XBSED.

*------- Steuerzeilen des neuen Beleges
DATA:    BEGIN OF XBSET OCCURS 2.
        INCLUDE STRUCTURE BSET.
DATA:    END OF XBSET.

*------- Steuerzeilen des neuen Beleges
DATA:    BEGIN OF XBSEGZ OCCURS 7.
        INCLUDE STRUCTURE BSEGZ.
DATA:    END OF XBSEGZ.

*------- erweiterte Quellensteuer des neuen Beleges
DATA:    BEGIN OF XACCWT OCCURS 7.
        INCLUDE STRUCTURE ACCIT_WT.
DATA:    END OF XACCWT.

*------- Belegkoepfe gelesener / gemerkter Belege
DATA:    BEGIN OF YBKPF OCCURS 5.
        INCLUDE STRUCTURE BKPF.
DATA:    END OF YBKPF.

*------- Belegzeilen eines gelesenen / gemerkten Beleges
DATA:    BEGIN OF YBSEG OCCURS 5.
        INCLUDE STRUCTURE BSEG.
DATA:    END OF YBSEG.

*------- CPD-Zeilen eines gelesenen / gemerkten Beleges
DATA:    BEGIN OF YBSEC OCCURS 1.
        INCLUDE STRUCTURE BSEC.
DATA:    END OF YBSEC.

*------- Wechsel-Zeilen eines gelesenen / gemerkten Beleges
DATA:    BEGIN OF YBSED OCCURS 1.
        INCLUDE STRUCTURE BSED.
DATA:    END OF YBSED.

*------- Steuerzeilen eines gemerkten Beleges
DATA:    BEGIN OF YBSET OCCURS 1.
        INCLUDE STRUCTURE BSET.
DATA:    END OF YBSET.

*------- IBAN informations of hold documents (Note 1033963)
DATA:    BEGIN OF xtiban OCCURS 1.
        INCLUDE STRUCTURE tiban.
DATA:    END OF xtiban.

*------- new bank informations of hold documents (Note 1033963)
DATA:    BEGIN OF xbnka OCCURS 1.
        INCLUDE STRUCTURE bnka.
DATA:    END OF xbnka.


*------- note 998521
DATA:    gt_bkpf LIKE bkpf,
         GT_BSEG LIKE BSEG OCCURS 2 WITH HEADER LINE.
*
*------- Einzelfelder

DATA:    CRS-FIELD(61)       TYPE C,   " Cursor Feld
         CRS-LINE            LIKE SY-STEPL.      " Cursor Zeile im Loop

DATA:    OK-CODE(4)         TYPE C,    " Funktionscode
         OLD-OKCODE          LIKE OK-CODE.       " Rettfeld dazu

DATA:    END OF COMMON PART.
