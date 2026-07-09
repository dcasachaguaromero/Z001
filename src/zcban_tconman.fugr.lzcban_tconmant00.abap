*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTCONC_MANUAL...................................*
DATA:  BEGIN OF STATUS_ZTCONC_MANUAL                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTCONC_MANUAL                 .
CONTROLS: TCTRL_ZTCONC_MANUAL
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTCONC_MANUAL                 .
TABLES: ZTCONC_MANUAL                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
