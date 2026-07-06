FUNCTION ZSUBEFIRMA.
*"--------------------------------------------------------------------
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
*"     VALUE(TDNAME_001) LIKE  BDCDATA-FVAL DEFAULT 'FIRMA1'
*"     VALUE(BTYPE_BMON_002) LIKE  BDCDATA-FVAL DEFAULT ''
*"     VALUE(BTYPE_BCOL_003) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"     VALUE(FILENAME_004) LIKE  BDCDATA-FVAL DEFAULT 'C:\Dibujo.bmp'
*"     VALUE(TDNAME_005) LIKE  BDCDATA-FVAL DEFAULT 'FIRMA1'
*"     VALUE(RB_GRAPHIC_BCOL_006) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"     VALUE(AUTOHEIGHT_007) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"     VALUE(TDNAME_008) LIKE  BDCDATA-FVAL DEFAULT 'FIRMA1'
*"     VALUE(BTYPE_BCOL_009) LIKE  BDCDATA-FVAL DEFAULT 'X'
*"  EXPORTING
*"     VALUE(SUBRC) LIKE  SYST-SUBRC
*"  TABLES
*"      MESSTAB STRUCTURE  BDCMSGCOLL OPTIONAL
*"--------------------------------------------------------------------

subrc = 0.

perform bdc_nodata      using NODATA.

perform open_group      using GROUP USER KEEP HOLDDATE CTU.

perform bdc_dynpro      using 'ZSAPMSSCH' '2000'.
perform bdc_field       using 'BDC_OKCODE'
                              '=GIMP'.
perform bdc_field       using 'BDC_CURSOR'
                              'RSSCG-BTYPE_BCOL'.
perform bdc_field       using 'RSTXT-TDNAME'
                              TDNAME_001.
perform bdc_field       using 'RSSCG-BTYPE_BMON'
                              BTYPE_BMON_002.
perform bdc_field       using 'RSSCG-BTYPE_BCOL'
                              BTYPE_BCOL_003.
perform bdc_dynpro      using 'SAPLSTXBITMAPS' '4001'.
perform bdc_field       using 'BDC_CURSOR'
                              'RLGRAP-FILENAME'.
perform bdc_field       using 'BDC_OKCODE'
                              '=OK'.
perform bdc_field       using 'RLGRAP-FILENAME'
                              FILENAME_004.
perform bdc_field       using 'STXBITMAPS-TDNAME'
                              TDNAME_005.
perform bdc_field       using 'RB_GRAPHIC_BCOL'
                              RB_GRAPHIC_BCOL_006.
perform bdc_field       using 'STXBITMAPS-AUTOHEIGHT'
                              AUTOHEIGHT_007.
perform bdc_dynpro      using 'ZSAPMSSCH' '2000'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BACK'.
perform bdc_field       using 'BDC_CURSOR'
                              'RSTXT-TDNAME'.
perform bdc_field       using 'RSTXT-TDNAME'
                              TDNAME_008.
perform bdc_field       using 'RSSCG-BTYPE_BCOL'
                              BTYPE_BCOL_009.
perform bdc_transaction tables messtab
using                         'ZSE78'
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
