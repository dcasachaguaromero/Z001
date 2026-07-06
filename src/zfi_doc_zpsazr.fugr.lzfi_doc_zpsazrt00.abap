*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_DOC_ZPSAZR..................................*
DATA:  BEGIN OF STATUS_ZFI_DOC_ZPSAZR                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_DOC_ZPSAZR                .
CONTROLS: TCTRL_ZFI_DOC_ZPSAZR
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFI_DOC_ZPSAZR                .
TABLES: ZFI_DOC_ZPSAZR                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
