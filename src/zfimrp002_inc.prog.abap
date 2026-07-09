*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <23-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFIMRP002_INC .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LLENA_ESTRUCTURA
*&---------------------------------------------------------------------*
*       SE REALIZA LLAMADO A LA TABLA ZREVERSACHEQUE CON ID CORRESPONDIENTES
*
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM llena_estructura .

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_ok
*    FROM zreversacheque
*   WHERE bukrs EQ sbukrs-low
*     AND hbkid EQ shbkid-low
*     AND hktid EQ shktid-low
*     AND chect EQ schect-low.
*
* NEW CODE
  SELECT *
 INTO CORRESPONDING FIELDS OF TABLE t_ok
    FROM zreversacheque
   WHERE bukrs EQ sbukrs-low
     AND hbkid EQ shbkid-low
     AND hktid EQ shktid-low
     AND chect EQ schect-low ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  IF sy-subrc EQ 0.
    SORT t_ok BY fecproceso horaproceso.
    PERFORM clcestc. " coloca la descripcion del estado actual
*    PERFORM CLFECCONT. " ACTUALIZA FECHA CONTABLE.
  ENDIF.

ENDFORM.                    " LLENA_ESTRUCTURA
*&---------------------------------------------------------------------*
*&      Form  CLCESTC
*&---------------------------------------------------------------------*
*       Se coloca descripcion del estado del cambio estructura : t_ok-estadoc
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clcestc .
  TABLES: bseg.
  DATA: ctadewst TYPE zreversacheque-hkontd.
  DATA: des_cta(60)  TYPE c.
  DATA : ti_zctap LIKE zcta_prescrip OCCURS 0 WITH HEADER LINE,
         v_indice LIKE sy-tabix.

* SE SACAN LAS CUENTAS DE LA TABLA ZCTA_PRESCRIP
*mod ini
  SELECT T_CUENTA, CUENTA_P, DESCRIPCION
   FROM zcta_prescrip
   INTO CORRESPONDING FIELDS OF TABLE @ti_zctap
    FOR ALL ENTRIES IN @t_ok
    where cuenta_p EQ @t_ok-hkontd.
*mod fin
  IF t_ok[] IS NOT INITIAL.
    LOOP AT t_ok INTO t_ok.
      v_indice = sy-tabix.
      IF t_ok-hkontd EQ 'ANULACION'.
        t_ok-estadoc =  'CHEQUE ANULADO'. " SE ASIGNA ESTADO DE DESTINO
      ELSE.
        PERFORM desc_cta USING t_ok-hkontd+9(1) CHANGING des_cta .

        LOOP AT ti_zctap WHERE cuenta_p EQ t_ok-hkontd.
          des_cta = ti_zctap-descripcion.
        ENDLOOP.

        t_ok-estadoc = des_cta.
* FCV - 07.07.2010
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE *
*          FROM zreversacheque
*         WHERE bukrs EQ t_ok-bukrs
*           AND hbkid EQ t_ok-hbkid
*           AND hktid EQ t_ok-hktid
*           AND chect EQ t_ok-chect
*           AND belnr = t_ok-belnract.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS 
          FROM zreversacheque
         WHERE bukrs EQ t_ok-bukrs
           AND hbkid EQ t_ok-hbkid
           AND hktid EQ t_ok-hktid
           AND chect EQ t_ok-chect
           AND belnr = t_ok-belnract ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc NE 0.
*ResQ Comment:Correction not required as Select Single is used 23/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE zzmot_emis INTO bseg-zzmot_emis
*          FROM bseg
*          WHERE belnr = t_ok-belnract
*            AND zuonr = t_ok-chect
*            AND zzmot_emis = 'SUBMATERNA'.
*
* NEW CODE
          SELECT zzmot_emis
          UP TO 1 ROWS  INTO bseg-zzmot_emis
          FROM bseg
          WHERE belnr = t_ok-belnract
            AND zuonr = t_ok-chect
            AND zzmot_emis = 'SUBMATERNA' ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          IF sy-subrc EQ 0.
            IF t_ok-estadoc = 'NUEVO CHEQUE REVALIDADO'.
              t_ok-estadoc = 'NUEVO CHEQUE MATERNAL'.
            ENDIF.
          ENDIF.
        ENDIF.
* FCV - 07.07.2010
      ENDIF.
      MODIFY  t_ok INDEX v_indice. " SE ASIGNA ESTADO DE DESTINO
    ENDLOOP.

  ENDIF.


ENDFORM.                    " CLCESTC
*&---------------------------------------------------------------------*
*&      Form  DESC_CTA
*&---------------------------------------------------------------------*
*       text obtiene descripcion de cuenta
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM desc_cta USING cta TYPE c
              CHANGING des_cta.

  CASE cta.
    WHEN 0.
      des_cta =  'SALDO'.
    WHEN 1.
      des_cta =  'DEPOSITO'.
    WHEN 2.
      des_cta =  'CHEQUE GIRADO'.
    WHEN 3.
      des_cta =  'CARGOS'.
    WHEN 4.
      des_cta =  'ABONOS'.
    WHEN 5.
      des_cta =  'TRANSFERENCIAS'.
    WHEN 6.
      des_cta =  'CADUCADO FÍSICO'.
    WHEN 7.
      des_cta =  'CADUCADO ELECTRÓNICO'.
    WHEN 8.
      des_cta =  'CADUCADO FISCAL'.
    WHEN 9.
      des_cta =  'REVALIDADO'.
    WHEN OTHERS.
      des_cta =  '--'.
  ENDCASE.


ENDFORM.                    "DESC_CTA
*&---------------------------------------------------------------------*
*&      Form  CLFECCONT
*&---------------------------------------------------------------------*
*       SE TRAE FECHA DE CONTABILIZACION PARA EL DOCUMENTO NUEVO
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clfeccont.

  DATA p_feccont LIKE bkpf-budat.
  DATA t_bseg LIKE bseg OCCURS 0 WITH HEADER LINE.

  IF t_ok[] IS NOT INITIAL.
    LOOP AT t_ok.
      IF t_ok-belnract IS NOT INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * INTO CORRESPONDING FIELDS OF t_bseg
*        FROM bseg
*       WHERE bukrs    EQ  t_ok-bukrs
*         AND  belnr   EQ  t_ok-belnract
*         AND  gjahr   EQ  t_ok-gjahr
*         AND  shkzg   EQ  'H'
*         AND  zuonr   EQ  t_ok-chect.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF t_bseg
        FROM bseg
       WHERE bukrs    EQ  t_ok-bukrs
         AND  belnr   EQ  t_ok-belnract
         AND  gjahr   EQ  t_ok-gjahr
         AND  shkzg   EQ  'H'
         AND  zuonr   EQ  t_ok-chect ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc EQ 0.
*                  LOOP AT T_BSEG.
*                    MOVE T_BSEG-VALUT TO T_OK-BUDAT.
*                  ENDLOOP.
*                  MODIFY  T_OK INDEX SY-TABIX . " SE ASIGNA ESTADO DE DESTINO
          MOVE t_bseg-valut TO t_ok-budat.
          MODIFY  t_ok TRANSPORTING budat.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " CLFECCONT
