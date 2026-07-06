*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZESTADOSBANCO...................................*
DATA:  BEGIN OF STATUS_ZESTADOSBANCO                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZESTADOSBANCO                 .
CONTROLS: TCTRL_ZESTADOSBANCO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZESTADOSBANCO                 .
TABLES: ZESTADOSBANCO                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
