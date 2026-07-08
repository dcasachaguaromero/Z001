*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCB_ITER_CC.....................................*
DATA:  BEGIN OF STATUS_ZCB_ITER_CC                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCB_ITER_CC                   .
CONTROLS: TCTRL_ZCB_ITER_CC
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZCB_ITER_CC                   .
TABLES: ZCB_ITER_CC                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
