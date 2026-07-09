*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSUCUR.........................................*
DATA:  BEGIN OF STATUS_ZTSUCUR                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSUCUR                       .
CONTROLS: TCTRL_ZTSUCUR
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTSUCUR                       .
TABLES: ZTSUCUR                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
