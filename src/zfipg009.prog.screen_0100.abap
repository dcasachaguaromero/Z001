
process before output.
  module status_0100.

  loop with control tabla.
    module fill_table_control_0100.
  endloop.

process after input.
  module user_command_0100_exit at exit-command.

  loop with control tabla.
    module valida-grilla_0100.
  endloop.

  module user_command_0100.
