*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR004........................................*
DATA:  BEGIN OF STATUS_ZFITR004                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR004                      .
CONTROLS: TCTRL_ZFITR004
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZV_ZFITR004.....................................*
TABLES: ZV_ZFITR004, *ZV_ZFITR004. "view work areas
CONTROLS: TCTRL_ZV_ZFITR004
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_ZV_ZFITR004. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZV_ZFITR004.
* Table for entries selected to show on screen
DATA: BEGIN OF ZV_ZFITR004_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZV_ZFITR004.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_ZFITR004_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZV_ZFITR004_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZV_ZFITR004.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_ZFITR004_TOTAL.

*.........table declarations:.................................*
TABLES: *ZFITR004                      .
TABLES: ZFITR004                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
