*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR020_T05....................................*
DATA:  BEGIN OF STATUS_ZFITR020_T05                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR020_T05                  .
CONTROLS: TCTRL_ZFITR020_T05
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFITR020_T05                  .
TABLES: ZFITR020_T05                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
