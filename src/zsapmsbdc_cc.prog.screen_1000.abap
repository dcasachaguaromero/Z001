process before output.
  module d1000_status.
  module clear_itab_selected.
  call subscreen d1000_header    including 'ZSAPMSBDC_CC' '1005'.
  call subscreen d1000_subscreen including 'ZSAPMSBDC_CC' '1010'.
  call subscreen d1000_foot      including 'ZSAPMSBDC_CC' '1015'.
*
process after input.
  module exit at exit-command.
  call subscreen d1000_header.
  call subscreen d1000_subscreen.
  call subscreen d1000_foot.
  module d1000_cmd.
