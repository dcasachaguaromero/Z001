*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMOT_EMIS.......................................*
DATA:  BEGIN OF STATUS_ZMOT_EMIS                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMOT_EMIS                     .
CONTROLS: TCTRL_ZMOT_EMIS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMOT_EMIS                     .
TABLES: ZMOT_EMIS                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
