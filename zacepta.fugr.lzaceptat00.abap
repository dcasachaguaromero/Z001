*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZHOSTACEPTA.....................................*
DATA:  BEGIN OF STATUS_ZHOSTACEPTA                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHOSTACEPTA                   .
CONTROLS: TCTRL_ZHOSTACEPTA
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHOSTACEPTA                   .
TABLES: ZHOSTACEPTA                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
