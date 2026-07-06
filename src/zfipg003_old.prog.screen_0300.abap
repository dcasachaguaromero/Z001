
PROCESS BEFORE OUTPUT.
  MODULE status_0300.
*
PROCESS AFTER INPUT.
  MODULE user_command_0300_exit AT EXIT-COMMAND.

  CHAIN.
    FIELD nfirma1.
    FIELD dir_org1.
    FIELD dir_des1.
    FIELD pass1.
    FIELD nfirma2.
    FIELD dir_org2.
    FIELD dir_des2.
    FIELD pass2.

    MODULE valida_0300.

  ENDCHAIN.

  MODULE user_command_0300.

*PROCESS ON VALUE-REQUEST.
*  FIELD dir_org1 MODULE value_org1.
*  FIELD dir_des1 MODULE value_des1.
*
*  FIELD dir_org2 MODULE value_org2.
*  FIELD dir_des2 MODULE value_des2.
