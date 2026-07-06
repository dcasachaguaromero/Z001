*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZOPEBCO.........................................*
DATA:  BEGIN OF STATUS_ZOPEBCO                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZOPEBCO                       .
CONTROLS: TCTRL_ZOPEBCO
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZOPEBCO                       .
TABLES: ZOPEBCO                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
