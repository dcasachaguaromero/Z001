*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIPG003_OUT....................................*
DATA:  BEGIN OF STATUS_ZFIPG003_OUT                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIPG003_OUT                  .
CONTROLS: TCTRL_ZFIPG003_OUT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFIPG003_OUT                  .
TABLES: ZFIPG003_OUT                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
