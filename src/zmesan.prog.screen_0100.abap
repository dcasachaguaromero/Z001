
process before output.

  module status_0100.

  module lleno-grilla.

  loop with control tabla.

    module fill_table_control.
  endloop.

process after input.

  module user_command_exit_0100 at exit-command.
  .
  loop with control tabla.
    chain.
      field zfimotemisan_est-sel.

      module valida-grilla.
    endchain.

  endloop.

  module user_command_0100.
