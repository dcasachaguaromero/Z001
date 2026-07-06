*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBANCOSSBIF.....................................*
DATA:  BEGIN OF STATUS_ZBANCOSSBIF                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBANCOSSBIF                   .
CONTROLS: TCTRL_ZBANCOSSBIF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBANCOSSBIF                   .
TABLES: ZBANCOSSBIF                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
