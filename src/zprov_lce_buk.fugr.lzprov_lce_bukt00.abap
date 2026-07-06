*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPROV_LCE_BUK...................................*
DATA:  BEGIN OF STATUS_ZPROV_LCE_BUK                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPROV_LCE_BUK                 .
CONTROLS: TCTRL_ZPROV_LCE_BUK
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZPROV_LCE_BUK                 .
TABLES: ZPROV_LCE_BUK                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
