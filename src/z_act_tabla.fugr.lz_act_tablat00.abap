*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIRFC04........................................*
DATA:  BEGIN OF STATUS_ZFIRFC04                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIRFC04                      .
CONTROLS: TCTRL_ZFIRFC04
            TYPE TABLEVIEW USING SCREEN '0100'.
*...processing: ZNOVEDADBANCO...................................*
DATA:  BEGIN OF STATUS_ZNOVEDADBANCO                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZNOVEDADBANCO                 .
CONTROLS: TCTRL_ZNOVEDADBANCO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFIRFC04                      .
TABLES: *ZNOVEDADBANCO                 .
TABLES: ZFIRFC04                       .
TABLES: ZNOVEDADBANCO                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
