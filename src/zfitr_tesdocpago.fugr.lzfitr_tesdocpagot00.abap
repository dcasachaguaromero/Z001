*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFITR_TESDOCPAGO................................*
DATA:  BEGIN OF STATUS_ZFITR_TESDOCPAGO              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFITR_TESDOCPAGO              .
CONTROLS: TCTRL_ZFITR_TESDOCPAGO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFITR_TESDOCPAGO              .
TABLES: ZFITR_TESDOCPAGO               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
