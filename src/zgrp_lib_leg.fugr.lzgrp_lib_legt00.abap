*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDATSOCELEC.....................................*
DATA:  BEGIN OF STATUS_ZDATSOCELEC                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDATSOCELEC                   .
CONTROLS: TCTRL_ZDATSOCELEC
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZNC_ESPECIAL....................................*
DATA:  BEGIN OF STATUS_ZNC_ESPECIAL                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZNC_ESPECIAL                  .
CONTROLS: TCTRL_ZNC_ESPECIAL
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZDATSOCELEC                   .
TABLES: *ZNC_ESPECIAL                  .
TABLES: ZDATSOCELEC                    .
TABLES: ZNC_ESPECIAL                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
