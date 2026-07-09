
PROCESS BEFORE OUTPUT.

  MODULE status_0200.

  MODULE proteje_0200.

PROCESS AFTER INPUT.
 MODULE user_command_exit_0200 AT EXIT-COMMAND.

  CHAIN.
    FIELD zfipg201_est-zzmot_emis.
    FIELD zfipg201_est-bancop.
    FIELD zfipg201_est-rmaxp.
    FIELD zfipg201_est-rmaxb.
    MODULE valido-pantalla_0200.
  ENDCHAIN.

  MODULE user_command_0200.
