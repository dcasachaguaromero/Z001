*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDIRECCGUIA.....................................*
DATA:  BEGIN OF STATUS_ZDIRECCGUIA                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDIRECCGUIA                   .
CONTROLS: TCTRL_ZDIRECCGUIA
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZDIRECCGUIA                   .
TABLES: ZDIRECCGUIA                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
