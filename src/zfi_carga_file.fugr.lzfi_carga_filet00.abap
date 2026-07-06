*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_CARGA_FILE..................................*
DATA:  BEGIN OF STATUS_ZFI_CARGA_FILE                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_CARGA_FILE                .
CONTROLS: TCTRL_ZFI_CARGA_FILE
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFI_CARGA_FILE                .
TABLES: ZFI_CARGA_FILE                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
