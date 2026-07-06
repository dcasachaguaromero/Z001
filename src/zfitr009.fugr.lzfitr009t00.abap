*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR009........................................*
DATA:  BEGIN OF STATUS_ZFITR009                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR009                      .
CONTROLS: TCTRL_ZFITR009
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFITR009                      .
TABLES: ZFITR009                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
