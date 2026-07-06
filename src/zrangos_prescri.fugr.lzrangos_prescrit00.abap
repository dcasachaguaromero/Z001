*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZRANGOS_PRESCRI.................................*
DATA:  BEGIN OF STATUS_ZRANGOS_PRESCRI               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZRANGOS_PRESCRI               .
CONTROLS: TCTRL_ZRANGOS_PRESCRI
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZRANGOS_PRESCRI               .
TABLES: ZRANGOS_PRESCRI                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
