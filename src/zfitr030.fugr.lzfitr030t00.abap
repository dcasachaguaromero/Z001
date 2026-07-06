*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR030........................................*
DATA:  BEGIN OF STATUS_ZFITR030                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR030                      .
CONTROLS: TCTRL_ZFITR030
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFITR030                      .
TABLES: ZFITR030                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
