function ZFI_F4_TEMP_DOCUMENT.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_FIELD) LIKE  HELP_INFO-DYNPROFLD DEFAULT 'UF5A-TEMPD'
*"     VALUE(I_RETFIELD) LIKE  DFIES-FIELDNAME DEFAULT 'TEMPD'
*"     VALUE(I_DYNPPROG) LIKE  SY-REPID OPTIONAL
*"     VALUE(I_DYNPNR) LIKE  SY-DYNNR OPTIONAL
*"--------------------------------------------------------------------
*
* Function module created by note 208325
  data: l_srtfd like rfdt-srtfd,
        l_len type i.
  data: begin of l_rfdttab occurs 0,
          srtfd like rfdt-srtfd,
        end of l_rfdttab.

  data: tempdoc_tab type table of tempdoc_type
                    with header line.

* Initialize display table
  l_srtfd = sy-uname.
  describe field sy-uname length l_len in character mode.
  l_srtfd+l_len(1) = '%'.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * from rfdt
*    into corresponding fields of table l_rfdttab
*    where relid = 'BB'
*      and srtfd like l_srtfd.
*
* NEW CODE
  SELECT *
 from rfdt
    into corresponding fields of table l_rfdttab
    where relid = 'BB'
      and srtfd like l_srtfd ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* avoid multiple display of large held documents (Note 0334295)
  sort l_rfdttab by srtfd.
  delete adjacent duplicates from l_rfdttab.

  loop at l_rfdttab.
    tempdoc_tab-tempd = l_rfdttab-srtfd+l_len.
    append tempdoc_tab.
  endloop.

* Call selection window
  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield    = i_retfield
      dynprofield = i_field
      dynpprog    = i_dynpprog
      dynpnr      = i_dynpnr
      value_org   = 'S'
    tables
      value_tab   = tempdoc_tab
    exceptions
      others      = 99.
  clear sy-subrc.

endfunction.
