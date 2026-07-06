*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPRESTACION.....................................*
DATA:  BEGIN OF STATUS_ZPRESTACION                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPRESTACION                   .
CONTROLS: TCTRL_ZPRESTACION
            TYPE TABLEVIEW USING SCREEN '0004'.
*.........table declarations:.................................*
TABLES: *ZPRESTACION                   .
TABLES: ZPRESTACION                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
