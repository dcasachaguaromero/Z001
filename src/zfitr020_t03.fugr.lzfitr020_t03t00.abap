*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR020_T03....................................*
DATA:  BEGIN OF STATUS_ZFITR020_T03                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR020_T03                  .
CONTROLS: TCTRL_ZFITR020_T03
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFITR020_T03                  .
TABLES: ZFITR020_T03                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
