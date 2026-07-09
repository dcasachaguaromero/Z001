*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZV_ITER_CC......................................*
TABLES: ZV_ITER_CC, *ZV_ITER_CC. "view work areas
CONTROLS: TCTRL_ZV_ITER_CC
TYPE TABLEVIEW USING SCREEN '9000'.
DATA: BEGIN OF STATUS_ZV_ITER_CC. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZV_ITER_CC.
* Table for entries selected to show on screen
DATA: BEGIN OF ZV_ITER_CC_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZV_ITER_CC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_ITER_CC_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZV_ITER_CC_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZV_ITER_CC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_ITER_CC_TOTAL.

*.........table declarations:.................................*
TABLES: ZCB_ITER                       .
TABLES: ZCB_ITER_CC                    .
