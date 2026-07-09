*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIPG002_CAB....................................*
DATA:  BEGIN OF STATUS_ZFIPG002_CAB                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIPG002_CAB                  .
CONTROLS: TCTRL_ZFIPG002_CAB
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFIPG002_CAB                  .
TABLES: ZFIPG002_CAB                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
