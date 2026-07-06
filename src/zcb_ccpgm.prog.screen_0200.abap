
PROCESS BEFORE OUTPUT.

  MODULE status_0200.

  MODULE proteje_0200.

PROCESS AFTER INPUT.
  MODULE user_command_exit_0200 AT EXIT-COMMAND.

  CHAIN.
    FIELD zcb_ccosto_est-bukrs.
    FIELD zcb_ccosto_est-kostl.
    MODULE valido-pantalla_0200.
  ENDCHAIN.

  MODULE user_command_0200.
