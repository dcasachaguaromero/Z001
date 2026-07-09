*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCB_ITER_SUC....................................*
DATA:  BEGIN OF STATUS_ZCB_ITER_SUC                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCB_ITER_SUC                  .
CONTROLS: TCTRL_ZCB_ITER_SUC
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZCB_ITER_SUC                  .
TABLES: ZCB_ITER_SUC                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
