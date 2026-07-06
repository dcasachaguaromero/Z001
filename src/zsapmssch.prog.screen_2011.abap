PROCESS BEFORE OUTPUT.
  module modify_201x.
  module set_fields_2011.

PROCESS AFTER INPUT.
  field rsscg-bds_title  module bds_title on request.
  chain.
    field: rsscg-resident, rsscg-autoheight.
    module bds_techinfo on chain-request.
  endchain.
