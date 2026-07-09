*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFICO_REP05.....................................*
DATA:  BEGIN OF STATUS_ZFICO_REP05                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFICO_REP05                   .
CONTROLS: TCTRL_ZFICO_REP05
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFICO_REP05                   .
TABLES: ZFICO_REP05                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
