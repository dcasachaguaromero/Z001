*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR026........................................*
DATA:  BEGIN OF STATUS_ZFITR026                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR026                      .
CONTROLS: TCTRL_ZFITR026
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZFITR026                      .
TABLES: ZFITR026                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
