report ZANULA_FACTURA
       no standard page heading line-size 255.

include bdcrecx1.

parameters: path like RLGRAP-FILENAME default
'C:\factura.txt' obligatory lower case.

data: begin of record occurs 0,
        vbeln(10),
      end of record.


DATA WK_FILE LIKE RLGRAP-FILENAME.

start-of-selection.

  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      FILENAME = path
      FILETYPE = 'DAT'
    TABLES
      DATA_TAB = record.

  perform open_group.

  loop at record.

perform bdc_dynpro      using 'SAPMV60A' '0102'.
perform bdc_field       using 'BDC_CURSOR'
                              'KOMFK-VBELN(01)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SICH'.
perform bdc_field       using 'KOMFK-VBELN(01)'
                              record-VBELN.
perform bdc_transaction using 'VF11'.

endloop.

perform close_group.
