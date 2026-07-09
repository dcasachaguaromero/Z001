*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIPG002_DET....................................*
DATA:  BEGIN OF STATUS_ZFIPG002_DET                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIPG002_DET                  .
CONTROLS: TCTRL_ZFIPG002_DET
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZFIPG002_DET                  .
TABLES: ZFIPG002_DET                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
