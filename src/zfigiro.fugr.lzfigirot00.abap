*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIGIRO.........................................*
DATA:  BEGIN OF STATUS_ZFIGIRO                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIGIRO                       .
CONTROLS: TCTRL_ZFIGIRO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFIGIRO                       .
TABLES: ZFIGIRO                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
