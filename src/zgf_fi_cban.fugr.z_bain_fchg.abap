FUNCTION Z_BAIN_FCHG.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(CTU) LIKE  APQI-PUTACTIVE DEFAULT 'X'
*"     VALUE(MODE) LIKE  APQI-PUTACTIVE DEFAULT 'N'
*"     VALUE(UPDATE) LIKE  APQI-PUTACTIVE DEFAULT 'L'
*"     VALUE(GROUP) LIKE  APQI-GROUPID OPTIONAL
*"     VALUE(USER) LIKE  APQI-USERID OPTIONAL
*"     VALUE(KEEP) LIKE  APQI-QERASE OPTIONAL
*"     VALUE(HOLDDATE) LIKE  APQI-STARTDATE OPTIONAL
*"     VALUE(NODATA) LIKE  APQI-PUTACTIVE DEFAULT '/'
*"     VALUE(PAR_ZBUK_001) TYPE  DZBUKR
*"     VALUE(PAR_HBKI_002) TYPE  HBKID
*"     VALUE(PAR_HKTI_003) TYPE  HKTID
*"     VALUE(PAR_CHKF_004) TYPE  CHECT
*"     VALUE(PAR_CHKT_005) TYPE  CHECT
*"     VALUE(PAR_XEIN_006) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"  EXPORTING
*"     VALUE(SUBRC) LIKE  SYST-SUBRC
*"  TABLES
*"      MESSTAB STRUCTURE  BDCMSGCOLL OPTIONAL
*"----------------------------------------------------------------------

subrc = 0.

perform bdc_nodata      using NODATA.

perform open_group      using GROUP USER KEEP HOLDDATE CTU.

perform bdc_dynpro      using 'RFCHKD30' '1000'.
perform bdc_field       using 'BDC_CURSOR'
                              'PAR_XEIN'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ONLI'.
perform bdc_field       using 'PAR_ZBUK'
                              PAR_ZBUK_001.
perform bdc_field       using 'PAR_HBKI'
                              PAR_HBKI_002.
perform bdc_field       using 'PAR_HKTI'
                              PAR_HKTI_003.
perform bdc_field       using 'PAR_CHKF'
                              PAR_CHKF_004.
perform bdc_field       using 'PAR_CHKT'
                              PAR_CHKT_005.
perform bdc_field       using 'PAR_XEIN'
                              PAR_XEIN_006.
perform bdc_dynpro      using 'SAPLSPO1' '0100'.
perform bdc_field       using 'BDC_OKCODE'
                              '=YES'.
perform bdc_dynpro      using 'RFCHKD30' '1000'.
perform bdc_field       using 'BDC_OKCODE'
                              '/EE'.
perform bdc_field       using 'BDC_CURSOR'
                              'PAR_ZBUK'.
perform bdc_transaction tables messtab
using                         'FCHG'
                              CTU
                              MODE
                              UPDATE.
if sy-subrc <> 0.
  subrc = sy-subrc.
  exit.
endif.

perform close_group using     CTU.





ENDFUNCTION.
INCLUDE BDCRECXY .
