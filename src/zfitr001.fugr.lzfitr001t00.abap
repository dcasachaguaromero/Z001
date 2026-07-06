*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR001........................................*
DATA:  BEGIN OF STATUS_ZFITR001                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR001                      .
CONTROLS: TCTRL_ZFITR001
            TYPE TABLEVIEW USING SCREEN '0003'.
*.........table declarations:.................................*
TABLES: *ZFITR001                      .
TABLES: ZFITR001                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
