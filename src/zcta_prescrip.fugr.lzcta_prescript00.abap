*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCTA_PRESCRIP...................................*
DATA:  BEGIN OF STATUS_ZCTA_PRESCRIP                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCTA_PRESCRIP                 .
CONTROLS: TCTRL_ZCTA_PRESCRIP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCTA_PRESCRIP                 .
TABLES: ZCTA_PRESCRIP                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
