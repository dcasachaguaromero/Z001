*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFOLIO_PAGOBANCO................................*
DATA:  BEGIN OF STATUS_ZFOLIO_PAGOBANCO              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFOLIO_PAGOBANCO              .
CONTROLS: TCTRL_ZFOLIO_PAGOBANCO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFOLIO_PAGOBANCO              .
TABLES: ZFOLIO_PAGOBANCO               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
