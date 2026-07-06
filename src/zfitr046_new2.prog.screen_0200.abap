PROCESS BEFORE OUTPUT.
  MODULE status_0200.

  LOOP WITH CONTROL tabla2.

    MODULE fill_table_control_0200.
  ENDLOOP.
*
PROCESS AFTER INPUT.

  LOOP WITH CONTROL tabla2.
    MODULE valida-grilla_0200.
  ENDLOOP.

  MODULE user_command_0200.
