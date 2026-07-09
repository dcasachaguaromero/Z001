*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMM_VAL_DTE.....................................*
DATA:  BEGIN OF STATUS_ZMM_VAL_DTE                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMM_VAL_DTE                   .
CONTROLS: TCTRL_ZMM_VAL_DTE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMM_VAL_DTE                   .
TABLES: ZMM_VAL_DTE                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
