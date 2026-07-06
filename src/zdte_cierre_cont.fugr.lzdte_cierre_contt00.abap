*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDTE_CIERRE_CONT................................*
DATA:  BEGIN OF STATUS_ZDTE_CIERRE_CONT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDTE_CIERRE_CONT              .
CONTROLS: TCTRL_ZDTE_CIERRE_CONT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDTE_CIERRE_CONT              .
TABLES: ZDTE_CIERRE_CONT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
