PROCESS BEFORE OUTPUT.
  module modify_201x.
  module set_fields_2012.

PROCESS AFTER INPUT.
  chain.
    field: rstxt-tdtitle, rstxt-tdmacode1, rstxt-tdmacode2.
    module stxh_titles on chain-request.
  endchain.
  field rsscg-resolution  module stxh_resolution on request.
  chain.
    field: rsscg-resident, rsscg-autoheight.
    module stxh_techinfo on chain-request.
  endchain.
