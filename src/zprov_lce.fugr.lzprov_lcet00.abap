*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPROV_LCE.......................................*
DATA:  BEGIN OF STATUS_ZPROV_LCE                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPROV_LCE                     .
CONTROLS: TCTRL_ZPROV_LCE
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZPROV_LCE                     .
TABLES: ZPROV_LCE                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
