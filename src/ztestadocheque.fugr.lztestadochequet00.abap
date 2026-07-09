*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTESTADOCHEQUE..................................*
DATA:  BEGIN OF STATUS_ZTESTADOCHEQUE                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTESTADOCHEQUE                .
CONTROLS: TCTRL_ZTESTADOCHEQUE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTESTADOCHEQUE                .
TABLES: ZTESTADOCHEQUE                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
