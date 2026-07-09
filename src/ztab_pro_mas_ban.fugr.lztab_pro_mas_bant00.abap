*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTAB_PRO_MAS_BAN................................*
DATA:  BEGIN OF STATUS_ZTAB_PRO_MAS_BAN              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTAB_PRO_MAS_BAN              .
CONTROLS: TCTRL_ZTAB_PRO_MAS_BAN
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZTAB_PRO_MAS_BAN              .
TABLES: ZTAB_PRO_MAS_BAN               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
