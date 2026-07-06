*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVBWROOSFIELD...................................*
TABLES: ZVBWROOSFIELD, *ZVBWROOSFIELD. "view work areas
CONTROLS: TCTRL_ZVBWROOSFIELD
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_ZVBWROOSFIELD. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVBWROOSFIELD.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVBWROOSFIELD_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVBWROOSFIELD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVBWROOSFIELD_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVBWROOSFIELD_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVBWROOSFIELD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVBWROOSFIELD_TOTAL.

*.........table declarations:.................................*
TABLES: ROOSFIELD                      .
