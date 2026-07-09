*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDESC_EST.......................................*
DATA:  BEGIN OF STATUS_ZDESC_EST                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDESC_EST                     .
CONTROLS: TCTRL_ZDESC_EST
            TYPE TABLEVIEW USING SCREEN '0004'.
*.........table declarations:.................................*
TABLES: *ZDESC_EST                     .
TABLES: ZDESC_EST                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
