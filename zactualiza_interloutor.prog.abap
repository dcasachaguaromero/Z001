REPORT zactualiza_interloutor
       NO STANDARD PAGE HEADING LINE-SIZE 255.

INCLUDE bdcrecx1.

PARAMETERS: path LIKE rlgrap-filename DEFAULT
'C:\inter.txt' OBLIGATORY LOWER CASE.

DATA: BEGIN OF record OCCURS 0,
        kunnr(016),
        vkorg(004),
        vtweg(002),
        spart(002),
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

    PERFORM bdc_dynpro      USING 'SAPMF02D' '0101'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF02D-D0324'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'RF02D-KUNNR'
                                  record-kunnr.
    PERFORM bdc_field       USING 'RF02D-VKORG'
                                  record-vkorg.
    PERFORM bdc_field       USING 'RF02D-VTWEG'
                                  record-vtweg.
    PERFORM bdc_field       USING 'RF02D-SPART'
                                  record-spart.
    PERFORM bdc_field       USING 'RF02D-D0324'
                                  'X'.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0324'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNVP-PARVW(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=UPDA'.
    PERFORM bdc_transaction USING 'XD02'.

  ENDLOOP.
  PERFORM close_group.
