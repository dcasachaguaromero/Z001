
PROCESS BEFORE OUTPUT.
  MODULE status_0300.
*
  LOOP WITH CONTROL tabla3.
    MODULE fill_tabla_control_0300.
  ENDLOOP.

PROCESS AFTER INPUT.

  LOOP WITH CONTROL tabla3.
    MODULE actualiza_grilla_0300.
  ENDLOOP.
    MODULE user_command_0300.

  .
