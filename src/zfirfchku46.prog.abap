*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES03 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  zfirfchku45
*&
*&---------------------------------------------------------------------*
*&     PARA PRUEBAS AJUSTES EN CONCILIACION BANCARIA (MASIVO)          *
*&---------------------------------------------------------------------*

REPORT zfirfchku46.
TABLES: bseg,
        febep,
        febko,
        febcl,
        zcb_ccosto,
        zcb_logajustes,
        payr.

DATA: fecha(10)    TYPE c.
DATA: ccosto(10)   TYPE c.
DATA: idpago(14)   TYPE c.

DATA: debcre(2)   TYPE c.
DATA: digito(1)   TYPE n.
DATA: cuentat(5)  TYPE n.

DATA: cuentaok(5) TYPE n.
DATA: valor(15)   TYPE p.
DATA: valor1(15)  TYPE p.
DATA: ayer        TYPE dats.

DATA: valorc(15) TYPE p.
DATA: valorp(15) TYPE p.

DATA: difer1(15)   TYPE p.
DATA: difer(1)     TYPE n.

DATA: signo1(1)   TYPE c.
DATA: compensado  LIKE  febep-belnr.
DATA: w_belnr     LIKE  febep-belnr.
DATA: w_doc(10)   TYPE n.
DATA: w_gjahr     LIKE  bkpf-gjahr.
DATA: linea   LIKE  febep-esnum.
DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.
DATA : BEGIN OF febko_t OCCURS 0.
         INCLUDE STRUCTURE febko.
       DATA : END OF febko_t.

DATA : BEGIN OF febep_t OCCURS 0.
         INCLUDE STRUCTURE febep.
       DATA : END OF febep_t.

       INCLUDE zbatchinput.


       SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t00.
SELECT-OPTIONS   :   p_bukrs1   FOR febko-bukrs.
SELECT-OPTIONS   :   p_hbkid1   FOR febko-hbkid.
SELECT-OPTIONS   :   p_azdat1  FOR febko-azdat  DEFAULT sy-datum .
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
     ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

AT SELECTION-SCREEN ON p_bukrs1.
  SELECT bukrs INTO TABLE @DATA(lt_bukrs)
         FROM t001 WHERE bukrs IN @p_bukrs1.
  LOOP AT lt_bukrs INTO DATA(lw_bukrs).
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
       ID 'BUKRS' FIELD lw_bukrs.
    IF sy-subrc <> 0.
      MESSAGE e526(icc_tr) WITH lw_bukrs.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.

  CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum+0(4) INTO fecha.

  SELECT * FROM febko INTO TABLE febko_t
        WHERE bukrs IN p_bukrs1
          AND hbkid IN p_hbkid1
          AND azdat IN p_azdat1
          AND astat <> 8.

  LOOP AT febko_t.
    PERFORM verdetalle.
  ENDLOOP.

*&---------------------------------------------------------------------*
*&      Form  verdetalle.
*&---------------------------------------------------------------------*

FORM verdetalle.
  REFRESH febep_t.

  SELECT * FROM febep INTO TABLE febep_t
      WHERE kukey = febko_t-kukey
        AND belnr = ''
        AND vb1ok = ''
        AND  intag = '011'
        AND vgint = 'ZZ02'.

  LOOP AT febep_t.

    PERFORM vercheque.
  ENDLOOP.

  CLEAR: cuentat, cuentaok.

  SELECT * FROM febep WHERE kukey = febko_t-kukey.
    cuentat = cuentat + 1.
    IF febep-vb1ok = 'X'.
      cuentaok = cuentaok + 1.
    ENDIF.
  ENDSELECT.

  IF cuentat = cuentaok.
    UPDATE febko SET astat = 8
                     dstat = 'A'
                     vb1ok = 'X'
                     vb2ok = 'X'
               WHERE kukey = febko_t-kukey.
  ENDIF.
ENDFORM.                    "verdetalle

*&---------------------------------------------------------------------*
*&      Form  vercheque
*&---------------------------------------------------------------------*

FORM vercheque.

  SELECT SINGLE * FROM payr
                 WHERE zbukr = febko_t-bukrs
                   AND hbkid = febko_t-hbkid
                   AND hktid = febko_t-hktid
*          AND rzawe = 'C'
                   AND chect = febep_t-chect.

  IF sy-subrc = 0.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES03 ECDK917080 *
    SELECT  SINGLE * FROM bseg
                 WHERE bukrs = payr-zbukr
                   AND belnr = payr-vblnr
                   AND gjahr = payr-gjahr
                   AND hkont = payr-ubhkt.

    IF sy-subrc = 0.
      compensado = bseg-augbl.

      IF bseg-augbl IS INITIAL.

        valorc  = febep_t-kwbtr * 100.
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
            difer1 = valorc - valorp.
            difer = difer1.
            CONCATENATE febko_t-bukrs '000000' INTO ccosto.
            IF valor1 = valorc.
              SELECT SINGLE * FROM zcb_ccosto
                             WHERE bukrs = febko_t-bukrs.
              IF sy-subrc = 0.
                ccosto = zcb_ccosto-kostl.
              ENDIF.
              PERFORM compensa_ajuste.
            ELSE.
              zcb_logajustes-estpro = '0'.
              CLEAR  zcb_logajustes-obspro.
              zcb_logajustes-obspro = 'Diferencia de valores no es ajuste'.
              zcb_logajustes-belnr  = '          '.
              PERFORM graba_log.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        zcb_logajustes-estpro = '0'.
        CONCATENATE 'Cheque compensado en'  compensado INTO zcb_logajustes-obspro.
        zcb_logajustes-belnr  = '          '.
        PERFORM graba_log.
      ENDIF.
    ENDIF.
  ELSE.
    zcb_logajustes-estpro = '0'.
    CONCATENATE 'Cheque: ' febep_t-chect ' no es valido' INTO zcb_logajustes-obspro.
    zcb_logajustes-belnr  = '          '.
    PERFORM graba_log.
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
                                 febko_t-bukrs.

  PERFORM bdc_field       USING  'BKPF-BUDAT'
                                 fecha.

  PERFORM bdc_field       USING  'BKPF-WAERS'
                                 payr-waers.

  PERFORM bdc_field       USING  'BKPF-XBLNR'
                                 febep_t-xblnr.

  PERFORM bdc_field       USING  'BKPF-BKTXT'
                                 'Ajuste Cartola'.

  PERFORM bdc_field       USING  'RF05A-AUGTX'
                                 'Ajuste Cartola'.

  PERFORM bdc_field       USING  'FS006-DOCID'
                                 '*'.

  PERFORM bdc_field       USING  'RF05A-NEWBS'
                                  debcre.

  PERFORM bdc_field       USING  'RF05A-NEWKO'
                                 '8112100004'. " '4911160008'. HCD 20190702

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
                                febep_t-chect.

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

*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'COBL-ZZRUT_TERC'.

*  PERFORM bdc_field       USING 'COBL-ZZRUT_TERC'
*                                '1-9'.

*&---------------------------------------------------------------------*
  PERFORM bdc_dynpro      USING 'SAPMF05A'
                                '0710'.

  PERFORM bdc_field      USING 'BDC_CURSOR'
                                'RF05A-AGKOA'.

  PERFORM bdc_field     USING 'BDC_OKCODE'
                                '=SLB'.

  PERFORM bdc_field      USING 'RF05A-AGBUK'
                           	    febko_t-bukrs.

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
                               febep_t-ak1bl.

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
      w_doc   = w_belnr.
      w_gjahr  = sy-datum+0(4).
    ENDIF.

  ENDLOOP.

  IF w_belnr IS NOT INITIAL.
    PERFORM actualiza_archivos.
  ELSE.
    zcb_logajustes-estpro = '0'.
    zcb_logajustes-obspro = 'NO generado Comprobante de Ajuste'.
    zcb_logajustes-belnr  = '          '.
    PERFORM graba_log.
  ENDIF.

ENDFORM.                    "compensa_ajuste

*&---------------------------------------------------------------------*
*&      Form  ACTUALIZA_ARCHIVOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualiza_archivos.


  UPDATE febep SET eperl = 'X'
                   vb1ok = 'X'
                   vb2ok = 'X'
                   estat = ''
                   belnr = febep_t-ak1bl
                   info1 = 'Cheque marcado "cobrado"'
                   info2 = ''
                   ak1bl = ''
               WHERE kukey = febko_t-kukey AND
                     esnum = febep_t-esnum.

  IF sy-subrc = 0.
    UPDATE febcl SET selvon = idpago
                   WHERE kukey = febko_t-kukey
                     AND esnum = febep_t-esnum.
  ENDIF.


  IF sy-subrc = 0.
    UPDATE payr SET xbanc = 'X'
                    bancd = febko_t-azdat
              WHERE zbukr = febko_t-bukrs
                AND hbkid = febko_t-hbkid
                AND hktid = febko_t-hktid
*          AND rzawe = 'C'
                AND chect = febep_t-chect.
  ENDIF.


  IF sy-subrc = 0.
    UPDATE bseg SET zuonr = febep_t-chect
         WHERE bukrs = febko_t-bukrs
           AND belnr = w_doc
           AND gjahr = w_gjahr
           AND hkont = payr-ubhkt.
  ENDIF.

  zcb_logajustes-estpro = '1'.
  zcb_logajustes-obspro = 'Generado Comprobante de Ajuste'.
  zcb_logajustes-belnr  = w_belnr.


  PERFORM graba_log.

ENDFORM.                    "ACTUALIZA_ARCHIVOS

*&---------------------------------------------------------------------*
*&      Form  GRABA LOG DE AJUSTES CB
*&---------------------------------------------------------------------*
FORM graba_log.
  zcb_logajustes-bukrs  = febko_t-bukrs.
  zcb_logajustes-kukey  = febko_t-kukey.
  zcb_logajustes-esnum  = febep_t-esnum.
  zcb_logajustes-fecpro = sy-datum.
  zcb_logajustes-horpro = sy-uzeit.
  zcb_logajustes-usrpro = sy-uname.

  INSERT  zcb_logajustes.
ENDFORM.                    "actualiza_archivos
