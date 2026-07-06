*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIRFC03........................................*
DATA:  BEGIN OF STATUS_ZFIRFC03                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIRFC03                      .
CONTROLS: TCTRL_ZFIRFC03
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFIRFC03                      .
TABLES: ZFIRFC03                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
