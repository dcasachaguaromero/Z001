*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_WS_TRANSF...................................*
DATA:  BEGIN OF STATUS_ZFI_WS_TRANSF                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_WS_TRANSF                 .
CONTROLS: TCTRL_ZFI_WS_TRANSF
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFI_WS_TRANSF                 .
TABLES: ZFI_WS_TRANSF                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
