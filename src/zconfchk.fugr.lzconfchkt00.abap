*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCONFCHK........................................*
DATA:  BEGIN OF STATUS_ZCONFCHK                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCONFCHK                      .
CONTROLS: TCTRL_ZCONFCHK
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCONFCHK                      .
TABLES: ZCONFCHK                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
