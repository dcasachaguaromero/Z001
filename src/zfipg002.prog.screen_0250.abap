process before output.

  module status_0200.

  loop with control tabla2.

    module fill_table_control_0200.
  endloop.


process after input.

  loop with control tabla2.

  endloop.

  chain.
    field zfipg002_cab-descr.

    module valido-pantalla_0200.
  endchain.

  module user_command_0200.
