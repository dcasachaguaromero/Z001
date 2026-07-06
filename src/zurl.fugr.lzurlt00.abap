*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTDEA...........................................*
DATA:  BEGIN OF STATUS_ZTDEA                         .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTDEA                         .
CONTROLS: TCTRL_ZTDEA
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTDEA                         .
TABLES: ZTDEA                          .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
