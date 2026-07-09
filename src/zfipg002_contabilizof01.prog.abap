*----------------------------------------------------------------------*
***INCLUDE ZFIPG002_CONTABILIZOF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CONTABILIZO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TREC  text
*      -->P_0890   text
*----------------------------------------------------------------------*
form CONTABILIZO  tables  tdat LIKE reg1x USING texto LIKE bkpf-bktxt.


  IF entrar EQ 'X'.



***      PERFORM bdc_field       USING 'RF05A-NEWBS'
***                                     '40'.
***      PERFORM bdc_field       USING 'RF05A-NEWKO'
***                                    reguh-ubhkt.
***      PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
***      PERFORM bdc_field       USING 'BDC_CURSOR'
***                                    'BSEG-SGTXT'.
***      PERFORM bdc_field       USING 'BDC_OKCODE'
***                                    '=BU'.
***      PERFORM bdc_field       USING 'BSEG-WRBTR'
***                                     valor.
***      PERFORM bdc_field       USING 'BSEG-VALUT'
***                                     fecha1.
***      PERFORM bdc_field       USING 'BSEG-SGTXT'
***                                     texto.
***      PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
***      PERFORM bdc_field       USING 'BDC_CURSOR'
***                                    'COBL-PRCTR'.
***      PERFORM bdc_field       USING 'BDC_OKCODE'
***                                    '=ENTE'.

      CALL TRANSACTION 'F-02' USING  bdcdata
                                      MODE 'E'
                                      UPDATE 'S'
                                      MESSAGES INTO itab.


  ENDIF.



endform.                    " CONTABILIZO
