
PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  LOOP WITH CONTROL tabla.
    MODULE fill_tabla_control_0100.
  ENDLOOP.

  LOOP WITH CONTROL tabla2.
    MODULE fill_tabla_2_control_0100.
  ENDLOOP.

*
PROCESS AFTER INPUT.

  MODULE user_command_0100_exit AT EXIT-COMMAND.


  LOOP WITH CONTROL tabla.
    MODULE actualiza_grilla_0100.
  ENDLOOP.
  LOOP WITH CONTROL tabla2.
    MODULE actualiza_grilla_2_0100.
  ENDLOOP.


  CHAIN.
    FIELD *lfa1-lifnr.
    MODULE user_command_0100.
  ENDCHAIN.
