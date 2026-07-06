*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDATSOCELEC_BAN.................................*
DATA:  BEGIN OF STATUS_ZDATSOCELEC_BAN               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDATSOCELEC_BAN               .
CONTROLS: TCTRL_ZDATSOCELEC_BAN
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDATSOCELEC_BAN               .
TABLES: ZDATSOCELEC_BAN                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
