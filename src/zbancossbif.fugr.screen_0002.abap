PROCESS BEFORE OUTPUT.
  MODULE detail_init.
*
PROCESS AFTER INPUT.
  MODULE detail_exit_command AT EXIT-COMMAND.
  MODULE detail_set_pfstatus.
  CHAIN.
    FIELD zbancossbif-banco .
    FIELD zbancossbif-descr .
    FIELD zbancossbif-usa_fecha.
    MODULE set_update_flag ON CHAIN-REQUEST.
  ENDCHAIN.
  CHAIN.
    FIELD zbancossbif-banco .
    MODULE detail_pai.
  ENDCHAIN.
