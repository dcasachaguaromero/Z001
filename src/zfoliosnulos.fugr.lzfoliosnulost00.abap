*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFOLIOSNULOS....................................*
DATA:  BEGIN OF STATUS_ZFOLIOSNULOS                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFOLIOSNULOS                  .
CONTROLS: TCTRL_ZFOLIOSNULOS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFOLIOSNULOS                  .
TABLES: ZFOLIOSNULOS                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
