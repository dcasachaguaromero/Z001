PROCESS BEFORE OUTPUT.

  MODULE status_0250.

  LOOP WITH CONTROL tabla3.

    MODULE fill_table_control_0250.
  ENDLOOP.

PROCESS AFTER INPUT.

  LOOP WITH CONTROL tabla3.
    MODULE valida-grilla_0250.
  ENDLOOP.

  MODULE user_command_0250.
