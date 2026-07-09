*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIAM001........................................*
DATA:  BEGIN OF STATUS_ZFIAM001                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIAM001                      .
CONTROLS: TCTRL_ZFIAM001
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFIAM001                      .
TABLES: ZFIAM001                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
