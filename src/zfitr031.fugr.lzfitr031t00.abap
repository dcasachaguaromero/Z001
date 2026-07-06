*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR031........................................*
DATA:  BEGIN OF STATUS_ZFITR031                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR031                      .
CONTROLS: TCTRL_ZFITR031
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZFITR031                      .
TABLES: ZFITR031                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
