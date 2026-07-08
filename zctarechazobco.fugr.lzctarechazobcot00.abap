*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCTARECHAZOBCO..................................*
DATA:  BEGIN OF STATUS_ZCTARECHAZOBCO                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCTARECHAZOBCO                .
CONTROLS: TCTRL_ZCTARECHAZOBCO
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZCTARECHAZOBCO                .
TABLES: ZCTARECHAZOBCO                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
