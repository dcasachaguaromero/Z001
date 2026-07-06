*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFIRFCHKU40
*&
*&---------------------------------------------------------------------*
*&     PARA RUEBAS AJUSTES EN CONCILIACION BANCARIA                    *
*&---------------------------------------------------------------------*

REPORT zfirfchku40.

DATA: fecha(10)    TYPE c.
DATA: ccosto(10)   TYPE c.
DATA: glosaf(35)   TYPE c.
DATA: idpago(14)   TYPE c.

DATA: debcre(2)   TYPE c.
DATA: digito(1)   TYPE n.
DATA: cuentat(5)  TYPE n.
DATA: cuentaok(5) TYPE n.

DATA: valor(15)  TYPE p.
DATA: valor1(15) TYPE p.

DATA: valorc(15) TYPE p.
DATA: valorp(15) TYPE p.

DATA: difer1(15)   TYPE p.
DATA: difer(1)     TYPE n.

DATA: signo1(1)   TYPE c.
DATA: w_belnr     LIKE  febep-belnr.
DATA: compensado  LIKE  febep-belnr.
DATA: w_doc(10)   TYPE n.
DATA: w_gjahr     LIKE  bkpf-gjahr.
DATA: w_febep-kwbtr LIKE  febep-kwbtr.
DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.

TABLES: bseg,
        febep,
        febko,
        febcl,
        zcb_ccosto,
        payr.

PARAMETER : cartola  LIKE febep-kukey         OBLIGATORY,
              linea  LIKE febep-esnum         OBLIGATORY.

INCLUDE zbatchinput.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
     ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

START-OF-SELECTION.

  SELECT SINGLE * FROM febko
  WHERE kukey = cartola.

  CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum+0(4) INTO fecha.

  IF sy-subrc = 0.
    IF febko-astat <>  8.
      SELECT SINGLE * FROM febep
            WHERE kukey = cartola
              AND esnum = linea.
      IF sy-subrc = 0.
        IF febep-belnr IS INITIAL AND febep-vb1ok = ' '.
          PERFORM vercheque.
        ELSE.
          WRITE: / '-----------------------------------------------------------------'.
          WRITE: / '-    LINEA DE CARTOLA YA COMPENSADA                               '.
          WRITE: / '-----------------------------------------------------------------'.
          WRITE: / 'Clave Breve Cartola                                     :', cartola.
          WRITE: / 'Lìnea en Cartola                                        :', linea.
          EXIT.
        ENDIF.
      ELSE.
        WRITE: / '-----------------------------------------------------------------'.
        WRITE: / '-    NO SE ENCONTRO EN TABLA DE CARTOLAS DATOS                   '.
        WRITE: / '-----------------------------------------------------------------'.
        WRITE: / 'Clave Breve Cartol                                      :', cartola.
        WRITE: / 'Lìnea en Cartola                                        :', linea.
        EXIT.
      ENDIF.
    ELSE.
      WRITE: / '-----------------------------------------------------------------'.
      WRITE: / '-    NUMERO DE CARTOLA INGRESADO YA ESTA COMPENSADA              '.
      WRITE: / '-----------------------------------------------------------------'.
      WRITE: / 'Clave Breve Cartola                                       :', cartola.
    ENDIF.
  ELSE.
    WRITE: / '-----------------------------------------------------------------'.
    WRITE: / '-    NUMERO DE CARTOLA INGRESADO NO EXISTE CABECERA               '.
    WRITE: / '-----------------------------------------------------------------'.
    WRITE: / 'Clave Breve Cartola                                           :', cartola.
  ENDIF.


END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  vercheque
*&---------------------------------------------------------------------*

FORM vercheque.

  IF febep-intag = '011' AND febep-vgint = 'ZZ02'.

    SELECT SINGLE * FROM payr
    WHERE zbukr = febko-bukrs
    AND hbkid = febko-hbkid
    AND hktid = febko-hktid
*          AND rzawe = 'C'
    AND chect = febep-chect.

    IF sy-subrc = 0.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
      SELECT  SINGLE * FROM bseg
             WHERE bukrs = payr-zbukr
               AND belnr = payr-vblnr
               AND gjahr = payr-gjahr
               AND hkont = payr-ubhkt.

      IF sy-subrc = 0.
        compensado = bseg-augbl.
        IF bseg-augbl IS INITIAL.
          valorc  = febep-kwbtr * 100.
          valorp  = payr-rwbtr  * -100.

          IF valorp <> valorc.
            valor1 = valorp.
            digito = valor1 + 0.
            IF digito <> 0.
              IF digito < 6.
                valor1 = valorp - digito.
                signo1 = '-'.
                debcre = '50'.
              ELSE.
                valor1 = valorp - digito + 10.
                signo1 = '+'.
                debcre = '40'.
              ENDIF.
            ELSE.
              WRITE: / '-----------------------------------------------------------------'.
              WRITE: / '-    NO APLICA AJUSTE PUES VALOR TERMINA EN CEROS                '.
              WRITE: / '-----------------------------------------------------------------'.
              WRITE: / 'Clave Breve Cartola                                     :', cartola.
              WRITE: / 'Lìnea en Cartola                                        :', linea.
              WRITE: / 'Valor antes de analisis                                 :', valor.
            ENDIF.
            difer1 = valorc - valorp.
            difer = difer1.
            CONCATENATE febko-bukrs '000000' INTO ccosto.
            IF valor1 = valorc.
              SELECT SINGLE * FROM zcb_ccosto
                             WHERE bukrs = febko-bukrs.
              IF sy-subrc = 0.
                ccosto = zcb_ccosto-kostl.
              ENDIF.

              PERFORM compensa_ajuste.
              CLEAR glosaf.
              IF w_belnr IS NOT INITIAL.
                CONCATENATE 'Comprobante Ajuste ' w_belnr INTO glosaf.
              ELSE.
                glosaf =  'NO Se genero comprobante de Ajuste '.
              ENDIF.
              WRITE: / '-----------------------------------------------------------------'.
              WRITE: / '-    BUSQUEDA DE CHEQUE PARA VER VALOR CORRECTO                 '.
              WRITE: / '-----------------------------------------------------------------'.
              WRITE: / '-    SE ENCONTRO CHEQUE                                       '.
              WRITE: / '-----------------------------------------------------------------'.
              WRITE: / 'Clave Breve Cartola                                     :', cartola.
              WRITE: / 'Lìnea en Cartola                                        :', linea.
              WRITE: / 'SOCIEDAD                                                :', febko-bukrs.
              WRITE: / 'BANCO PROPIO                                            :', febko-hbkid.
              WRITE: / 'CUENTA                                                  :', febko-hktid.
              WRITE: / 'NUMERO DE CHEQUE                                        :', febep-chect.
              WRITE: / 'VALOR EN CARTOLA                                        :', febep-kwbtr.
              WRITE: / 'COMPROBANTE CARTOLA                                     :', febep-ak1bl.
              WRITE: / 'VALOR EN PAGO DE CHEQUE                                 :', payr-rwbtr.
              WRITE: / 'COMPROBANTE PAGO DE CHEQUE                              :', payr-vblnr.
              WRITE: / 'DIFERENCIA A AJUSTAR CONTRA CARTOLA                     :', difer1.
              WRITE: / 'SIGNO DE LA DIFERENCIA CONTRA CARTOLA                   :', signo1.
              WRITE: / '-----------------------------------------------------------------'.
              WRITE: / 'RESULTADO                                                '.
              WRITE: / '-----------------------------------------------------------------'.
              WRITE: / glosaf.
              IF w_belnr IS NOT INITIAL.
                PERFORM actualiza_archivos.
              ENDIF.
            ELSE.
              WRITE: / '-----------------------------------------------------------------'.
              WRITE: / '-    BUSQUEDA DE CHEQUE PARA VER VALOR CORRECTO                 '.
              WRITE: / '-----------------------------------------------------------------'.
              WRITE: / '-    SE ENCONTRO CHEQUE  NO APLICA AJUSTE DIFERENCIA MAYOR       '.
              WRITE: / '-----------------------------------------------------------------'.
              WRITE: / 'SOCIEDAD                                                :', febko-bukrs.
              WRITE: / 'BANCO PROPIO                                            :', febko-hbkid.
              WRITE: / 'CUENTA                                                  :', febko-hktid.
              WRITE: / 'NUMERO DE CHEQUE                                        :', febep-chect.
              WRITE: / 'VALOR EN CARTOLA                                        :', febep-kwbtr.
              WRITE: / 'COMPROBANTE CARTOLA                                     :', febep-ak1bl.
              WRITE: / 'VALOR EN PAGO DE CHEQUE                                 :', payr-rwbtr.
              WRITE: / 'COMPROBANTE PAGO DE CHEQUE                              :', payr-vblnr.
              WRITE: / 'DIFERENCIA A AJUSTAR CONTRA CARTOLA                     :', difer1.
              WRITE: / 'SIGNO DE LA DIFERENCIA CONTRA CARTOLA                   :', signo1.
            ENDIF.

          ELSE.

            WRITE: / '-----------------------------------------------------------------'.
            WRITE: / '-    NO APLICA AJUSTE PUES VALOR CHEQUE IGUAL A CARTOLA          '.
            WRITE: / '-----------------------------------------------------------------'.
            WRITE: / 'Clave Breve Cartola                                     :', cartola.
            WRITE: / 'Lìnea en Cartola                                        :', linea.
            WRITE: / 'Valor en cartola                                        :', valorc.
            WRITE: / 'Valor en pago                                           :', valorp.
          ENDIF.
        ELSE.
          WRITE: / '-----------------------------------------------------------------'.
          WRITE: / '-    SE ENCONTRO CHEQUE PERO YA COMPENSADO                     '.
          WRITE: / '-----------------------------------------------------------------'.
          WRITE: / 'Clave Breve Cartola                               :', cartola.
          WRITE: / 'Lìnea en Cartola                                  :', linea.
          WRITE: / 'SOCIEDAD                                          :', febko-bukrs.
          WRITE: / 'BANCO PROPIO                                      :', febko-hbkid.
          WRITE: / 'CUENTA                                            :', febko-hktid.
          WRITE: / 'NUMERO DE CHEQUE                                  :', febep-chect.
          WRITE: / 'COMPROBANTE COMPENSACION                          :', compensado.

        ENDIF.
      ENDIF.
    ELSE.
      WRITE: / '-----------------------------------------------------------------'.
      WRITE: / '-    NO SE ENCONTRO CHEQUE EN TABLA DE CHEQUES                   '.
      WRITE: / '-----------------------------------------------------------------'.
      WRITE: / 'SOCIEDAD                                          :', febko-bukrs.
      WRITE: / 'BANCO PROPIO                                      :', febko-hbkid.
      WRITE: / 'CUENTA                                            :', febko-hktid.
      WRITE: / 'NUMERO DE CHEQUE                                  :', febep-chect.
    ENDIF.
  ELSE.
    WRITE: / '-----------------------------------------------------------------'.
    WRITE: / '-    LINEA DE MOVIMIENTO INGRESADO NO ES CHEQUE                  '.
    WRITE: / '-----------------------------------------------------------------'.
    WRITE: / 'Clave Breve Cartola                                     :', cartola.
    WRITE: / 'Lìnea en Cartola                                        :', linea.
    WRITE: / 'Regla de contabilización (debe ser ZZ02)                :', febep-vgint.
    WRITE: / 'Algoritmo de interpretación (debe ser 11)               :', febep-intag.
  ENDIF.

ENDFORM.                                                    "REVISAR


*&---------------------------------------------------------------------*
*&      Form  compensa_ajuste
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM compensa_ajuste.
  CLEAR bdcdata.
  REFRESH bdcdata.
*&---------------------------------------------------------------------*
  PERFORM bdc_dynpro      USING 'SAPMF05A'
                                '0122'.

  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.

  PERFORM bdc_field       USING 'BDC_OKCODE'
                                 '/00'.

  PERFORM bdc_field       USING 'BKPF-BLDAT'
                                 fecha.

  PERFORM bdc_field       USING  'BKPF-BLART'
                                 'SA'.

  PERFORM bdc_field       USING  'BKPF-BUKRS'
                                 febko-bukrs.

  PERFORM bdc_field       USING  'BKPF-BUDAT'
                                 fecha.

  PERFORM bdc_field       USING  'BKPF-WAERS'
                                 payr-waers.

  PERFORM bdc_field       USING  'BKPF-XBLNR'
                                 febep-xblnr.

  PERFORM bdc_field       USING  'BKPF-BKTXT'
                                 'Ajuste Cartola'.

  PERFORM bdc_field       USING  'RF05A-AUGTX'
                                 'Ajuste Cartola'.

  PERFORM bdc_field       USING  'FS006-DOCID'
                                 '*'.

  PERFORM bdc_field       USING  'RF05A-NEWBS'
                                  debcre.

  PERFORM bdc_field       USING  'RF05A-NEWKO'
                                 '8112100004'. " '4911160008'.  HCD cambio cuenta 20190806

*&---------------------------------------------------------------------*
  PERFORM bdc_dynpro      USING  'SAPMF05A'
                                 '0300'.

  PERFORM bdc_field       USING 'BDC_CURSOR'
                                 'BSEG-SGTXT'.

  PERFORM bdc_field      USING 'BDC_OKCODE'
                                '=SL'.

  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                difer.

  PERFORM bdc_field       USING 'BSEG-MWSKZ'
                                'C0'.

  PERFORM bdc_field       USING 'BSEG-ZUONR'
                                febep-chect.

  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                'Ajuste cheque pagado por caja'.

  PERFORM bdc_field       USING 'BDC_SUBSCR'
                                'SAPLKACB'.                 "0001BLOCK

  PERFORM bdc_field       USING 'DKACB-FMORE'
                                'X'.

*&---------------------------------------------------------------------*
  PERFORM bdc_dynpro      USING 'SAPLKACB'
                                '0002'.


  PERFORM bdc_field       USING 'BDC_OKCODE'
                                 '=ENTE'.

  PERFORM bdc_field       USING 'COBL-KOSTL'
                                     ccosto.

  PERFORM bdc_field       USING 'BDC_SUBSCR'
                                'SAPLKACB'.                 "9999BLOCK1

* PERFORM bdc_field       USING 'BDC_CURSOR'
*                               'COBL-ZZRUT_TERC'.

* PERFORM bdc_field       USING 'COBL-ZZRUT_TERC'
*                               '1-9'.

*&---------------------------------------------------------------------*
  PERFORM bdc_dynpro      USING 'SAPMF05A'
                                '0710'.

  PERFORM bdc_field      USING 'BDC_CURSOR'
                                'RF05A-AGKOA'.

  PERFORM bdc_field     USING 'BDC_OKCODE'
                                '=SLB'.

  PERFORM bdc_field      USING 'RF05A-AGBUK'
                           	    febko-bukrs.

  PERFORM bdc_field      USING 'RF05A-AGKON'
                                payr-ubhkt.

  PERFORM bdc_field      USING 'RF05A-AGKOA'
                                'S'.

  PERFORM bdc_field      USING 'RF05A-XNOPS'
                               	'X'.

*&---------------------------------------------------------------------*
  PERFORM bdc_dynpro     USING 'SAPMF05A'
                               '0733'.

  PERFORM bdc_field      USING 'BDC_CURSOR'
                               'RF05A-SEL01(02)'.

  PERFORM bdc_field      USING 'BDC_OKCODE'
                               '=BU'.

  PERFORM bdc_field      USING 'RF05A-FELDN(01)'
                               'BELNR'.

  PERFORM bdc_field      USING 'RF05A-FELDN(02)'
                               'BELNR'.

  PERFORM bdc_field      USING 'RF05A-SEL01(01)'
                                febep-ak1bl.

  CONCATENATE payr-vblnr payr-gjahr INTO idpago.
  PERFORM bdc_field      USING 'RF05A-SEL01(02)'
                                idpago.
*&---------------------------------------------------------------------*
  CALL TRANSACTION 'FB05' USING bdcdata
                                  MODE 'E'
                                  UPDATE 'S'
                                  MESSAGES INTO itab.
  CLEAR: w_belnr, w_gjahr.

  LOOP AT itab.
    IF itab-msgid = 'F5' AND  itab-msgnr = '312'.
      w_belnr = itab-msgv1.
      w_doc = w_belnr.
      w_gjahr  = sy-datum+0(4).
    ENDIF.

  ENDLOOP.

* IF w_belnr IS NOT INITIAL.
*   PERFORM actualiza_archivos.
* ENDIF.


ENDFORM.                    "compensa_ajuste

*&---------------------------------------------------------------------*
*&      Form  ACTUALIZA_ARCHIVOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualiza_archivos.

  CLEAR: cuentat, cuentaok.

  UPDATE febep SET eperl = 'X'
                   vb1ok = 'X'
                   vb2ok = 'X'
                   estat = ' '
                   belnr = febep-ak1bl
                   info1 = 'Cheque marcado "cobrado"'
                   info2 = '                                  '
                   ak1bl = '         '
               WHERE kukey = cartola AND
                     esnum = linea.

  SELECT SINGLE * FROM febcl WHERE kukey = cartola
                               AND esnum = linea.

  IF sy-subrc = 0.
    UPDATE febcl SET selvon = idpago
                   WHERE kukey = cartola
                     AND esnum = linea.
  ENDIF.

  SELECT SINGLE * FROM payr
         WHERE zbukr = febko-bukrs
           AND hbkid = febko-hbkid
           AND hktid = febko-hktid
*          AND rzawe = 'C'
           AND chect = febep-chect.

  IF sy-subrc = 0.
    UPDATE payr SET xbanc = 'X'
                    bancd = febko-azdat
              WHERE zbukr = febko-bukrs
                AND hbkid = febko-hbkid
                AND hktid = febko-hktid
                AND chect = febep-chect.
  ENDIF.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
  SELECT  SINGLE * FROM bseg
         WHERE bukrs = febko-bukrs
           AND belnr =  w_doc
           AND gjahr = w_gjahr
           AND hkont = payr-ubhkt.

  IF sy-subrc = 0.
    UPDATE bseg SET zuonr = febep-chect
         WHERE bukrs = febko-bukrs
           AND belnr = w_doc
           AND gjahr = w_gjahr.
  ENDIF.


  SELECT * FROM febep WHERE kukey = cartola.
    cuentat = cuentat + 1.
    IF febep-vb1ok = 'X'.
      cuentaok = cuentaok + 1.
    ENDIF.
  ENDSELECT.

  SELECT SINGLE * FROM febko WHERE kukey = cartola.

  IF cuentat = cuentaok.
    UPDATE febko SET astat = 8
                     dstat = 'A'
                     vb1ok = 'X'
                     vb2ok = 'X'
               WHERE kukey = cartola.
  ENDIF.
ENDFORM.                    "ACTUALIZA_ARCHIVOS
