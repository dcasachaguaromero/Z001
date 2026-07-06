*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
* Function module new with P00K019158
FUNCTION ZFI_CHECK_SCVTEXT.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_PROGNAME) LIKE  SHDSVCI-PROGNAME DEFAULT SPACE
*"     VALUE(I_DYNPRO) LIKE  SY-DYNNR DEFAULT '0000'
*"     VALUE(I_SCVTEXT) LIKE  SHDSVTXCI-SCVTEXT DEFAULT SPACE
*"  EXCEPTIONS
*"      NOT_FOUND
*"--------------------------------------------------------------------
  data: l_dynnr like shdsvci-dynpro.
  data: l_tabix like sy-tabix.
  data: scvtext_tab type table of scvtext_type
                     with header line.

* Initialize display table
  refresh scvtext_tab.

* Variants for screen already read into buffer?
  loop at scvtext_buffer
    where progname = i_progname
      and dynnr = i_dynpro.
    exit.
  endloop.

* Read variants from data base
  if sy-subrc ne 0.
    l_dynnr = i_dynpro.
    call function 'RS_HDSYS_VALUES_SC_VARIANT'
         exporting
              i_progname  = i_progname
              i_dynpro    = l_dynnr
              i_liste     = space
              texts_too   = 'X'
         tables
              e_shdsvtxci = shdsvtxci_tab.
*Begin of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 19/12/2019 EY_DES01 ECDK917080 *
SORT SCVTEXT_BUFFER BY PROGNAME DYNNR .
*End of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 19/12/2019 EY_DES01 ECDK917080 *
    read table scvtext_buffer with key progname = i_progname
                                       dynnr = i_dynpro
                                   binary search.
    l_tabix = sy-tabix.
    loop at shdsvtxci_tab where langu = sy-langu.
      scvtext_buffer-progname = i_progname.
      scvtext_buffer-dynnr = i_dynpro.
      move-corresponding shdsvtxci_tab to scvtext_buffer.
      insert scvtext_buffer index l_tabix.
      l_tabix = l_tabix + 1.
    endloop.
  endif.

* Copy buffer to display table
  read table scvtext_buffer with key progname = i_progname
                                     dynnr    = i_dynpro
                                     scvtext  = i_scvtext.
  if sy-subrc ne 0.
    message E178(F5A) with sy-langu raising not_found.
  endif.

endfunction.
