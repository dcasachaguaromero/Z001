*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIIVAPRP.......................................*
DATA:  BEGIN OF STATUS_ZFIIVAPRP                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIIVAPRP                     .
CONTROLS: TCTRL_ZFIIVAPRP
            TYPE TABLEVIEW USING SCREEN '0004'.
*.........table declarations:.................................*
TABLES: *ZFIIVAPRP                     .
TABLES: ZFIIVAPRP                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
