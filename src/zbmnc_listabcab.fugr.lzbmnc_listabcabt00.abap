*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBMNC_LISTABCAB.................................*
DATA:  BEGIN OF STATUS_ZBMNC_LISTABCAB               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBMNC_LISTABCAB               .
CONTROLS: TCTRL_ZBMNC_LISTABCAB
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBMNC_LISTABCAB               .
TABLES: ZBMNC_LISTABCAB                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
