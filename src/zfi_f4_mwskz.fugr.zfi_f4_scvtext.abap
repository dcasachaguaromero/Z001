* Function module new with P00K018470
function ZFI_F4_SCVTEXT.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_PROGNAME) LIKE  SHDSVCI-PROGNAME DEFAULT SPACE
*"     VALUE(I_DYNPRO) LIKE  SY-DYNNR DEFAULT '0000'
*"     VALUE(I_FIELD) LIKE  HELP_INFO-DYNPROFLD
*"         DEFAULT 'SHDSVTXCI-SCVTEXT'
*"     VALUE(I_RETFIELD) LIKE  DFIES-FIELDNAME DEFAULT 'SCVTEXT'
*"     VALUE(I_DYNPPROG) LIKE  SY-REPID OPTIONAL
*"     VALUE(I_DYNPNR) LIKE  SY-DYNNR OPTIONAL
*"--------------------------------------------------------------------
  data: l_dynnr like shdsvci-dynpro.
* (del) data: l_tabix like sy-tabix.                        "Note430830
  data: l_langu like sy-langu.                              "Note430830
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
        e_shdsvci   = shdsvci_tab                           "Note430830
        e_shdsvtxci = shdsvtxci_tab.
* (del) read table scvtext_buffer with key progname = i_pro "Note430830
* (del)                                    dynnr = i_dynpro "Note430830
* (del)                                binary search.       "Note430830
* (del) l_tabix = sy-tabix.                                 "Note430830
* (del) loop at shdsvtxci_tab where langu = sy-langu.       "Note430830
* (del)   scvtext_buffer-progname = i_progname.             "Note430830
* (del)   scvtext_buffer-dynnr = i_dynpro.                  "Note430830
* (del)   move-corresponding shdsvtxci_tab to scvtext_buffe "Note430830
* (del)   insert scvtext_buffer index l_tabix.              "Note430830
* (del)   l_tabix = l_tabix + 1.                            "Note430830
* (del) endloop.                                            "Note430830
    set_secondary_language l_langu.                         "Note430830
    delete shdsvtxci_tab                                    "Note430830
      where langu ne sy-langu.                              "Note430830
    sort shdsvtxci_tab by scvariant langu.                  "Note430830
    loop at shdsvci_tab.                                    "Note430830
      clear scvtext_buffer.                                 "Note430830
      scvtext_buffer-progname = i_progname.                 "Note430830
      scvtext_buffer-dynnr = i_dynpro.                      "Note430830
      scvtext_buffer-scvariant = shdsvci_tab-scvariant.     "Note430830
      read table shdsvtxci_tab                              "Note430830
           with key langu = sy-langu                        "Note430830
                    scvariant = shdsvci_tab-scvariant       "Note430830
           binary search.                                   "Note430830
      if sy-subrc = 0.                                      "Note430830
        scvtext_buffer-scvtext = shdsvtxci_tab-scvtext.     "Note430830
      endif.                                                "Note430830
      if scvtext_buffer-scvtext = space.                    "Note430830
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single scvtext from shdsvtxci                "Note430830
*          into scvtext_buffer-scvtext                       "Note430830
*          where langu = l_langu                             "Note430830
*            and scvariant = shdsvci_tab-scvariant.          
*
* NEW CODE
        SELECT scvtext
        UP TO 1 ROWS  from shdsvtxci                "Note430830
          into scvtext_buffer-scvtext                       "Note430830
          where langu = l_langu                             "Note430830
            and scvariant = shdsvci_tab-scvariant ORDER BY PRIMARY KEY.          

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"Note430830
      endif.                                                "Note430830
      append scvtext_buffer.                                "Note430830
    endloop.                                                "Note430830
  endif.

* Copy buffer to display table
  loop at scvtext_buffer
    where progname = i_progname
      and dynnr = i_dynpro.
    move-corresponding scvtext_buffer to scvtext_tab.
    append scvtext_tab.
  endloop.

* Call selection window
  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
       exporting
           retfield    = i_retfield
* (del)    dynpprog    = i_progname                         "Note208325
* (del)    dynpnr      = i_dynpro                           "Note208325
           dynpprog    = i_dynpprog                         "Note208325
           dynpnr      = i_dynpnr                           "Note208325
           dynprofield = i_field
           value_org   = 'S'
       tables
            value_tab  = scvtext_tab
       exceptions
* (del)     others     = 99.                                "Note430830
            others     = 0.                                 "Note430830

endfunction.
