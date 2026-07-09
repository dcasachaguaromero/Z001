*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIMTVRECHZ.....................................*
DATA:  BEGIN OF STATUS_ZFIMTVRECHZ                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIMTVRECHZ                   .
CONTROLS: TCTRL_ZFIMTVRECHZ
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZFIMTVRECHZ                   .
TABLES: ZFIMTVRECHZ                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
