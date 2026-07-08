function ZFI_POPUP_LSTML.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_LAND1) LIKE  T001-LAND1
*"  EXPORTING
*"     REFERENCE(E_LSTML) LIKE  T007A-LSTML
*"--------------------------------------------------------------------

* Set default
  t007a-lstml = i_land1.

* Call Popup to fill T007A-LSTML
  call screen 010 starting at 17 07.

* Transfer to output parameter
  e_lstml = t007a-lstml.

endfunction.
