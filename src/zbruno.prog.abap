*&---------------------------------------------------------------------*
*& Report  ZBRUNO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report ZPRKFCMDMD
       no standard page heading line-size 255.

include bdcrecx1.

start-of-selection.

perform open_group.

perform bdc_dynpro      using 'SAPMFCHK' '0800'.
perform bdc_field       using 'BDC_CURSOR'
                              'PAYR-VOIDR'.
perform bdc_field       using 'BDC_OKCODE'
                              '=EDEL'.
perform bdc_field       using 'PAYR-ZBUKR'
                              '1000'.
perform bdc_field       using 'PAYR-HBKID'
                              'BBCI'.
perform bdc_field       using 'PAYR-HKTID'
                              '00100'.
perform bdc_field       using 'PAYR-CHECT'
                              '0000000000016'.
perform bdc_field       using 'PAYR-VOIDR'
                              '11'.
perform bdc_transaction using 'FCH9'.

perform close_group.
