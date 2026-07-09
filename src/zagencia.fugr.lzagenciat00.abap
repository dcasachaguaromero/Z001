*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZAGENCIA........................................*
DATA:  BEGIN OF STATUS_ZAGENCIA                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAGENCIA                      .
CONTROLS: TCTRL_ZAGENCIA
            TYPE TABLEVIEW USING SCREEN '0004'.
*.........table declarations:.................................*
TABLES: *ZAGENCIA                      .
TABLES: ZAGENCIA                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
