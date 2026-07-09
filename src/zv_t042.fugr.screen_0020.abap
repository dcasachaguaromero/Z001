PROCESS BEFORE OUTPUT.
  MODULE detail_init.
  MODULE modify_0020.
*
PROCESS AFTER INPUT.
  MODULE detail_exit_command AT EXIT-COMMAND.
  MODULE detail_set_pfstatus.
  CHAIN.
    FIELD zv_t042-bukrs.
    FIELD zv_t042-zbukr.
    FIELD zv_t042-absbu.
    FIELD zv_t042-xuzaw.
    FIELD zv_t042-toltg.
    FIELD zv_t042-xgbtr.
    FIELD zv_t042-sktug.
    FIELD zv_t042-xskr1.
    MODULE check_0020_1 ON CHAIN-INPUT.
  ENDCHAIN.
  CHAIN.
    FIELD zv_t042-ulsk1.
    FIELD zv_t042-ulsk2.
    MODULE check_167_2 ON CHAIN-INPUT.
  ENDCHAIN.
  CHAIN.
    FIELD zv_t042-ulsd1.
    FIELD zv_t042-ulsd2.
    MODULE check_167_3 ON CHAIN-INPUT.
  ENDCHAIN.
  CHAIN.
    FIELD zv_t042-bukrs .
    FIELD zv_t042-zbukr MODULE valida_zbukr.
    FIELD zv_t042-ulsk1 .
    FIELD zv_t042-ulsk2 .
    FIELD zv_t042-ulsd1 .
    FIELD zv_t042-ulsd2 .
*    FIELD V_T042-XKDFB .
    FIELD zv_t042-xgbtr .
    FIELD zv_t042-toltg .
    FIELD zv_t042-sktug .
    FIELD zv_t042-xskr1 .
    FIELD zv_t042-absbu .
    FIELD zv_t042-xuzaw .
    FIELD zv_t042-xbptr .
    FIELD zv_t042-butxt .
    MODULE set_update_flag ON CHAIN-REQUEST.
    MODULE complete_zv_t042 ON CHAIN-REQUEST.
  ENDCHAIN.
  CHAIN.
    FIELD zv_t042-bukrs .
    MODULE user_command_0020.
    MODULE detail_pai.
  ENDCHAIN.

PROCESS ON VALUE-REQUEST.
  FIELD zv_t042-ulsk1 MODULE f4_ulsk1.
  FIELD zv_t042-ulsk2 MODULE f4_ulsk2.
  FIELD zv_t042-ulsd1 MODULE f4_ulsd1.
  FIELD zv_t042-ulsd2 MODULE f4_ulsd2.
  FIELD zv_t042-zbukr MODULE f4_zbukr.
