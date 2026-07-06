*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR020_T04....................................*
DATA:  BEGIN OF STATUS_ZFITR020_T04                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR020_T04                  .
CONTROLS: TCTRL_ZFITR020_T04
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFITR020_T04                  .
TABLES: ZFITR020_T04                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
