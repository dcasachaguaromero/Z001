*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDTE_TABLA_DOC..................................*
DATA:  BEGIN OF STATUS_ZDTE_TABLA_DOC                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDTE_TABLA_DOC                .
CONTROLS: TCTRL_ZDTE_TABLA_DOC
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDTE_TABLA_DOC                .
TABLES: ZDTE_TABLA_DOC                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
