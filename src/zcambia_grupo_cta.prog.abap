REPORT zcambia_grupo_cta
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

    PERFORM bdc_dynpro      USING 'SAPMF02D' '0102'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF02D-KUNNR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'RF02D-KUNNR'
                                  record-kunnr.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '1030'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF02D-KUNNR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '1020'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF02D-KTOKD_NEW'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_field       USING 'RF02D-KTOKD_NEW'
                                   'Z001'.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '1040'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF02D-KUNNR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0110'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNA1-ANRED'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=UPDA'.
    PERFORM bdc_transaction USING 'XD07'.


  ENDLOOP.
  PERFORM close_group.
