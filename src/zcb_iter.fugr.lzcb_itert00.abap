*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCB_ITER........................................*
DATA:  BEGIN OF STATUS_ZCB_ITER                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCB_ITER                      .
CONTROLS: TCTRL_ZCB_ITER
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZCB_ITER                      .
TABLES: ZCB_ITER                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
