process before output.

  module status_0100.

  module lleno-grilla.

  loop with control tabla.
    module fill_table_control.
  endloop.

process after input.

  loop with control tabla.
    chain.
      field zcb_iter_cc_est-sel.

      module valida-grilla.
    endchain.

  endloop.

  module user_command_0100.
