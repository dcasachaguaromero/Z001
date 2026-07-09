*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZUNID_PROD......................................*
DATA:  BEGIN OF STATUS_ZUNID_PROD                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZUNID_PROD                    .
CONTROLS: TCTRL_ZUNID_PROD
            TYPE TABLEVIEW USING SCREEN '0004'.
*.........table declarations:.................................*
TABLES: *ZUNID_PROD                    .
TABLES: ZUNID_PROD                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
