*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTIPCHEQUEMAT...................................*
DATA:  BEGIN OF STATUS_ZTIPCHEQUEMAT                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTIPCHEQUEMAT                 .
CONTROLS: TCTRL_ZTIPCHEQUEMAT
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTIPCHEQUEMAT                 .
TABLES: ZTIPCHEQUEMAT                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
