*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR016........................................*
DATA:  BEGIN OF STATUS_ZFITR016                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR016                      .
CONTROLS: TCTRL_ZFITR016
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFITR016                      .
TABLES: ZFITR016                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
