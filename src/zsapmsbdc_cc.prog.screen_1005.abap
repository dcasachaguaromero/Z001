PROCESS BEFORE OUTPUT.
  MODULE user_name.
*
PROCESS AFTER INPUT.
  CHAIN.
    FIELD: d0100-von, d0100-bis.
    MODULE check_selection.
  ENDCHAIN.
