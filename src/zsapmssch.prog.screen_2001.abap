PROCESS BEFORE OUTPUT.
  module set_fields_2001.
*
PROCESS AFTER INPUT.
  chain.
    field: rstxt-tdname, rsscg-btype_bmon, rsscg-btype_bcol
    module stxbitmaps_name on chain-request.
  endchain.
*
process on value-request.
   field rstxt-tdname    module graphicname_get.
