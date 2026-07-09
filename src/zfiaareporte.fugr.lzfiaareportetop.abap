FUNCTION-POOL ZFIAAREPORTE.                 "MESSAGE-ID ..

* INCLUDE LZFIAAREPORTED...                  " Local class definition

include ZFIAA015NEW_DAT.

selection-screen begin of screen 2000.
include ZFIAA015NEW_SSCR.
selection-screen end of screen 2000.

include ZFIAA015NEW_SSCRAT.

data: %dbcursor  type cursor,
      %auth_tabs type aqttabname.
