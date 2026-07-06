PROCESS BEFORE OUTPUT.
  module status_2000.
  call subscreen sub_header including g_repid sub_headernr.
  call subscreen sub_area   including g_repid sub_areanr.
*
PROCESS AFTER INPUT.
  call subscreen sub_header.
  call subscreen sub_area.
  module user_command_2000.
