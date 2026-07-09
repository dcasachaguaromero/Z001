*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIMOTEMISAN....................................*
DATA:  BEGIN OF STATUS_ZFIMOTEMISAN                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIMOTEMISAN                  .
CONTROLS: TCTRL_ZFIMOTEMISAN
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFIMOTEMISAN                  .
TABLES: ZFIMOTEMISAN                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
