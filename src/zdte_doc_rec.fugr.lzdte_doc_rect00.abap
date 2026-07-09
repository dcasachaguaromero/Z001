*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDTE_DOC_REC....................................*
DATA:  BEGIN OF STATUS_ZDTE_DOC_REC                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDTE_DOC_REC                  .
CONTROLS: TCTRL_ZDTE_DOC_REC
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDTE_DOC_REC                  .
TABLES: ZDTE_DOC_REC                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
