*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCEBE_PRESCRIP..................................*
DATA:  BEGIN OF STATUS_ZCEBE_PRESCRIP                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCEBE_PRESCRIP                .
CONTROLS: TCTRL_ZCEBE_PRESCRIP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCEBE_PRESCRIP                .
TABLES: ZCEBE_PRESCRIP                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
