PROCESS BEFORE OUTPUT.
  module set_fields_200x.
*
PROCESS AFTER INPUT.
  chain.
    field: rstxt-tdname, rstxt-tdspras.
    module stxh_name_spras on chain-request.
  endchain.
*
process on value-request.
   field rstxt-tdname    module textname_get.
