process before output.

  module status_0200.

  loop with control tabla1.
    module fill_table_control_0200.
  endloop.

  module variables_auxiliares1.

process after input.

  module user_command_0200_exit at exit-command.

  loop with control tabla1.
     module valida-grilla_0200.
  endloop.

  module variables_auxiliares2.

  module user_command_0200.
