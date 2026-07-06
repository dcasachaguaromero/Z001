*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR006........................................*
DATA:  BEGIN OF STATUS_ZFITR006                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR006                      .
CONTROLS: TCTRL_ZFITR006
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFITR006                      .
TABLES: ZFITR006                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
