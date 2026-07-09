*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZT042_USER......................................*
DATA:  BEGIN OF STATUS_ZT042_USER                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZT042_USER                    .
CONTROLS: TCTRL_ZT042_USER
            TYPE TABLEVIEW USING SCREEN '0030'.
*...processing: ZV_T042.........................................*
TABLES: ZV_T042, *ZV_T042. "view work areas
CONTROLS: TCTRL_ZV_T042
TYPE TABLEVIEW USING SCREEN '0010'.
DATA: BEGIN OF STATUS_ZV_T042. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZV_T042.
* Table for entries selected to show on screen
DATA: BEGIN OF ZV_T042_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZV_T042.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_T042_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZV_T042_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZV_T042.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_T042_TOTAL.

*.........table declarations:.................................*
TABLES: *ZT042_USER                    .
TABLES: T001                           .
TABLES: T042                           .
TABLES: ZT042_USER                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
