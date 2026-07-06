report ZCAMBIA_GRUPO_CTA_YBAC
       NO STANDARD PAGE HEADING LINE-SIZE 255.

INCLUDE bdcrecx1.
**
PARAMETERS: path LIKE rlgrap-filename DEFAULT
'C:\cliente.txt' OBLIGATORY LOWER CASE.


data: begin of record occurs 0,
        kunnr(016),
      END OF record.


START-OF-SELECTION.

  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename = path
      filetype = 'DAT'
    TABLES
      data_tab = record.

  PERFORM open_group.

  LOOP AT record.

perform bdc_dynpro      using 'SAPMF02D' '0102'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF02D-KUNNR'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'RF02D-KUNNR'
                              record-KUNNR.
perform bdc_dynpro      using 'SAPMF02D' '1030'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF02D-KUNNR'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTR'.
perform bdc_dynpro      using 'SAPMF02D' '1020'.
perform bdc_field       using 'BDC_CURSOR'
                              'RF02D-KTOKD_NEW'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTR'.
perform bdc_field       using 'RF02D-KTOKD_NEW'
                              'Z001'.
perform bdc_dynpro      using 'SAPMF02D' '0110'.
perform bdc_field       using 'BDC_CURSOR'
                              'KNA1-ANRED'.
perform bdc_field       using 'BDC_OKCODE'
                              '=UPDA'.
perform bdc_transaction using 'XD07'.


  ENDLOOP.
  PERFORM close_group.
