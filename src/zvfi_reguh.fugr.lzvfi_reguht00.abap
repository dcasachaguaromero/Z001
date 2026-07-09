*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVFI_REGUH......................................*
TABLES: ZVFI_REGUH, *ZVFI_REGUH. "view work areas
CONTROLS: TCTRL_ZVFI_REGUH
TYPE TABLEVIEW USING SCREEN '0010'.
DATA: BEGIN OF STATUS_ZVFI_REGUH. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVFI_REGUH.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVFI_REGUH_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVFI_REGUH.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVFI_REGUH_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVFI_REGUH_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVFI_REGUH.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVFI_REGUH_TOTAL.

*.........table declarations:.................................*
TABLES: REGUH                          .
