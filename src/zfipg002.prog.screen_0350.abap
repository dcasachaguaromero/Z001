PROCESS BEFORE OUTPUT.

  MODULE status_0300.

  LOOP WITH CONTROL tabla3.

    MODULE fill_table_control_0300.
  ENDLOOP.
*
PROCESS AFTER INPUT.

  LOOP WITH CONTROL tabla3.
    MODULE valida-grilla_0300.
  ENDLOOP.

  MODULE user_command_0300.
