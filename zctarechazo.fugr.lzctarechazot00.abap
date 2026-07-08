*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCTARECHAZO.....................................*
DATA:  BEGIN OF STATUS_ZCTARECHAZO                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCTARECHAZO                   .
CONTROLS: TCTRL_ZCTARECHAZO
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZCTARECHAZO                   .
TABLES: ZCTARECHAZO                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
