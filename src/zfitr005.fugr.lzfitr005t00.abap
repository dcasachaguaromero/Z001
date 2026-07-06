*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR005........................................*
DATA:  BEGIN OF STATUS_ZFITR005                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR005                      .
CONTROLS: TCTRL_ZFITR005
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFITR005                      .
TABLES: ZFITR005                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
