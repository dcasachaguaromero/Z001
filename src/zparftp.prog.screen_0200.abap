
PROCESS BEFORE OUTPUT.

  MODULE status_0200.

  MODULE proteje_0200.

PROCESS AFTER INPUT.
  MODULE user_command_exit_0200 AT EXIT-COMMAND.

  CHAIN.
    FIELD ztparamftp_est-zprog.

    FIELD ztparamftp_est-zruta.
    FIELD ztparamftp_est-zruta_respaldo.
    MODULE valido-pantalla_0200.
  ENDCHAIN.

  MODULE user_command_0200.
