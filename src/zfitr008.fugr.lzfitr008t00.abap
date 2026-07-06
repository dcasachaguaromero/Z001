*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR008........................................*
DATA:  BEGIN OF STATUS_ZFITR008                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR008                      .
CONTROLS: TCTRL_ZFITR008
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFITR008                      .
TABLES: ZFITR008                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
