
PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  LOOP WITH CONTROL tabla.
    MODULE fill_tabla_control_0100.
  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE user_command_0100_exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tabla.
    MODULE actualiza_grilla_0100.
  ENDLOOP.

  MODULE user_command_0100.
