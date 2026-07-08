
PROCESS BEFORE OUTPUT.

  MODULE status_0100.

  MODULE lleno-grilla.

  LOOP WITH CONTROL tabla.

    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE user_command_exit_0100 AT EXIT-COMMAND.
  .
  LOOP WITH CONTROL tabla.
    CHAIN.
      FIELD zws_puerto_est-sel.

      MODULE valida-grilla.
    ENDCHAIN.

  ENDLOOP.

  MODULE user_command_0100.
