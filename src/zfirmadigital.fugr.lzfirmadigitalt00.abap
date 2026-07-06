*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIRMADIGITAL...................................*
DATA:  BEGIN OF STATUS_ZFIRMADIGITAL                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIRMADIGITAL                 .
CONTROLS: TCTRL_ZFIRMADIGITAL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFIRMADIGITAL                 .
TABLES: ZFIRMADIGITAL                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
