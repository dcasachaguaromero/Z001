*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBMNC_LISTABDET.................................*
DATA:  BEGIN OF STATUS_ZBMNC_LISTABDET               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBMNC_LISTABDET               .
CONTROLS: TCTRL_ZBMNC_LISTABDET
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBMNC_LISTABDET               .
TABLES: ZBMNC_LISTABDET                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
