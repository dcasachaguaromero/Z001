
process before output.
  module status_0100.
   call subscreen a_sub0101 including sy-repid '0101'.
process after input.
  call subscreen: a_sub0101.

  chain.
    field bukrs.
    module tcc_modify_bukrs.
  endchain.

  chain.
    field hbkid.
    module tcc_modify_hbkid.
  endchain.

  chain.
    field hktid.
    module tcc_modify_hktid.
  endchain.

    chain.
    field SECONDS.
    module tcc_modify_seconds.
  endchain.

  module user_command_0100.

process on value-request.
  field hktid module module_match1.
