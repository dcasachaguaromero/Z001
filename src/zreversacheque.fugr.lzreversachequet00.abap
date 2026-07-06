*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZREVERSACHEQUE..................................*
DATA:  BEGIN OF STATUS_ZREVERSACHEQUE                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZREVERSACHEQUE                .
CONTROLS: TCTRL_ZREVERSACHEQUE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZREVERSACHEQUE                .
TABLES: ZREVERSACHEQUE                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
