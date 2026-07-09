
PROCESS BEFORE OUTPUT.

  MODULE status_0200.

  MODULE proteje_0200.

PROCESS AFTER INPUT.
MODULE user_command_exit_0200 AT EXIT-COMMAND.

  CHAIN.
    FIELD zfich002_est-estado.
    FIELD zfich002_est-descri.
    FIELD zfich002_est-tipo_est.
    FIELD zfich002_est-shkzg.

    MODULE valido-pantalla_0200.
  ENDCHAIN.

  MODULE user_command_0200.

