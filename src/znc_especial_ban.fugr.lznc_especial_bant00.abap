*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZNC_ESPECIAL_BAN................................*
DATA:  BEGIN OF STATUS_ZNC_ESPECIAL_BAN              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZNC_ESPECIAL_BAN              .
CONTROLS: TCTRL_ZNC_ESPECIAL_BAN
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZNC_ESPECIAL_BAN              .
TABLES: ZNC_ESPECIAL_BAN               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
