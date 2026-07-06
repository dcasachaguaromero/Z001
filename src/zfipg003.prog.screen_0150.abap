PROCESS BEFORE OUTPUT.
  MODULE status_0100.

  LOOP WITH CONTROL tabla.
    MODULE fill_table_control_0100.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE user_command_0100_exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tabla.
    CHAIN.
      FIELD zfipg003_est-nchequ_s.
      MODULE valida_grilla_0100.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command_0100.
