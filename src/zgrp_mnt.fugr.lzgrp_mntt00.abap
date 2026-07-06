*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTAB_PRO_MAS....................................*
DATA:  BEGIN OF STATUS_ZTAB_PRO_MAS                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTAB_PRO_MAS                  .
CONTROLS: TCTRL_ZTAB_PRO_MAS
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZTAB_PRO_MAS                  .
TABLES: ZTAB_PRO_MAS                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
