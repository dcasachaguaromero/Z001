*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFICH001........................................*
DATA:  BEGIN OF STATUS_ZFICH001                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFICH001                      .
CONTROLS: TCTRL_ZFICH001
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFICH001                      .
TABLES: ZFICH001                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
