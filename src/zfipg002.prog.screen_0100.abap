PROCESS BEFORE OUTPUT.
  MODULE status_0100.

  LOOP WITH CONTROL tabla.
    MODULE fill_table_control_0100.

* ini - 04-06-2020 - Waldo alarcon - Visionone.
    MODULE marca_columna.
* fin - 04-06-2020 - Waldo alarcon - Visionone.
  ENDLOOP.


PROCESS AFTER INPUT.
  MODULE user_command_0100_exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tabla.
    MODULE valida-grilla_0100.
  ENDLOOP.

  MODULE user_command_0100.
