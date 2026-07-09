*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIFPAGREC......................................*
DATA:  BEGIN OF STATUS_ZFIFPAGREC                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIFPAGREC                    .
CONTROLS: TCTRL_ZFIFPAGREC
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFIFPAGREC                    .
TABLES: ZFIFPAGREC                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
