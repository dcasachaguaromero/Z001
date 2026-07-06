*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTOPEBANC.......................................*
DATA:  BEGIN OF STATUS_ZTOPEBANC                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTOPEBANC                     .
CONTROLS: TCTRL_ZTOPEBANC
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTOPEBANC                     .
TABLES: ZTOPEBANC                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
