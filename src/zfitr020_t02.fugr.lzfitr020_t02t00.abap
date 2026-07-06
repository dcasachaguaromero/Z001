*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR020_T02....................................*
DATA:  BEGIN OF STATUS_ZFITR020_T02                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR020_T02                  .
CONTROLS: TCTRL_ZFITR020_T02
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFITR020_T02                  .
TABLES: ZFITR020_T02                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
