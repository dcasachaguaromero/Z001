*----------------------------------------------------------------------*
*   INCLUDE LFDCBF4D                                                   *
*----------------------------------------------------------------------*
*------- Declarations for Help requests in FDCB ------------------------
************************************************************************
******************* GENERAL STRUCTURES *********************************

*-- internal table for fields to display: Listboxes --------------------
data:    fieldtab  like dfies      occurs 0 with header line.
DATA:    returntab LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.

*------- internal table for value request ------------------------------
DATA:    BEGIN OF VALTAB OCCURS 10,
           FELD(50)     TYPE C,
         END OF VALTAB.

******************* ACCOUNTING STRUCTURES ******************************

*-------------------- Possible rec. accounts ---------------------------
DATA:  F4KNB1_Z       LIKE KNB1,
       F4LFB1_Z       LIKE LFB1,
       HKOTAB         LIKE THKON   OCCURS 10 WITH HEADER LINE,
       ZEMTAB         LIKE IZEMTAB OCCURS 10 WITH HEADER LINE.

******************** Fields for Communication with F4-Modules **********
DATA:    BVTYP    LIKE INVFO-BVTYP,
         EMPFB    LIKE INVFO-EMPFB,
         F4DYN    LIKE SY-DYNNR,
         F4RCODE  LIKE SY-SUBRC,
         FILKD    LIKE INVFO-FILKD,
         KUNNR    LIKE INVFO-KUNNR,
         LIFNR    LIKE INVFO-LIFNR,
         RSTGR    LIKE INVFO-RSTGR,
         SGTXT_F4 LIKE INVFO-SGTXT,
         XSHOW,                      "Field is only display field
         ZTERM    LIKE INVFO-ZTERM.
