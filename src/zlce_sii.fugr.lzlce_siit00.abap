*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZLCE_SII........................................*
DATA:  BEGIN OF STATUS_ZLCE_SII                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZLCE_SII                      .
CONTROLS: TCTRL_ZLCE_SII
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZLCE_SII                      .
TABLES: ZLCE_SII                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
