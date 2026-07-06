*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR007........................................*
DATA:  BEGIN OF STATUS_ZFITR007                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR007                      .
CONTROLS: TCTRL_ZFITR007
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFITR007                      .
TABLES: ZFITR007                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
