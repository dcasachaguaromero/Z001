*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_REL_MAT_CB..................................*
DATA:  BEGIN OF STATUS_ZFI_REL_MAT_CB                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_REL_MAT_CB                .
CONTROLS: TCTRL_ZFI_REL_MAT_CB
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_REL_MAT_CB                .
TABLES: ZFI_REL_MAT_CB                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
