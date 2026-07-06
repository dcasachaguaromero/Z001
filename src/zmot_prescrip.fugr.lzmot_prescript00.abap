*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMOT_PRESCRIP...................................*
DATA:  BEGIN OF STATUS_ZMOT_PRESCRIP                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMOT_PRESCRIP                 .
CONTROLS: TCTRL_ZMOT_PRESCRIP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMOT_PRESCRIP                 .
TABLES: ZMOT_PRESCRIP                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
