
PROCESS BEFORE OUTPUT.

  MODULE status_0200.

  MODULE proteje_0200.

PROCESS AFTER INPUT.
  MODULE user_command_exit_0200 AT EXIT-COMMAND.

  CHAIN.
    FIELD zws_puerto_est-programa.
    FIELD zws_puerto_est-puerto.
    FIELD zws_puerto_est-estado.
    MODULE valido-pantalla_0200.
  ENDCHAIN.

  MODULE user_command_0200.
