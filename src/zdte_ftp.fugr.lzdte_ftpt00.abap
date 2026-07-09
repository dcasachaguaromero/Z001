*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDTE_FTP........................................*
DATA:  BEGIN OF STATUS_ZDTE_FTP                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDTE_FTP                      .
CONTROLS: TCTRL_ZDTE_FTP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDTE_FTP                      .
TABLES: ZDTE_FTP                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
