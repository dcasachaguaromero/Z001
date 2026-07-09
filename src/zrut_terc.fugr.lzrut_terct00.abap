*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZRUT_TERC.......................................*
DATA:  BEGIN OF STATUS_ZRUT_TERC                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZRUT_TERC                     .
*.........table declarations:.................................*
TABLES: *ZRUT_TERC                     .
TABLES: ZRUT_TERC                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
