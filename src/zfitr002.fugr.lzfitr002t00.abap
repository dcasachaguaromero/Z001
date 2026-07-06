*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR002........................................*
DATA:  BEGIN OF STATUS_ZFITR002                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR002                      .
CONTROLS: TCTRL_ZFITR002
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFITR002                      .
TABLES: ZFITR002                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
