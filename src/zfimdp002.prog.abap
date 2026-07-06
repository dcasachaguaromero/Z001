*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFIMDP002 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*





*----------------------------------------------------------------------*
*  MODULE STATUS_0101 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE status_0101 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

*SELECTION-SCREEN BEGIN OF SCREEN 0101 AS SUBSCREEN.
*SELECT-OPTIONS:  NRO_DOC FOR PAYR-CHECT.
*SELECTION-SCREEN END OF SCREEN 0101.
ENDMODULE.                 " STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  %_PF_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE %_PF_STATUS OUTPUT.
**if T_RADIO_02 eq 'X'.
**
**ENDIF.
*ENDMODULE.                 " %_PF_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  %_PBO_REPORT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE %_PBO_REPORT OUTPUT.
***if T_RADIO_02 eq 'X'.
***
***ENDIF.
*ENDMODULE.                 " %_PBO_REPORT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PBO_REPORT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_report OUTPUT.

*  LOOP AT SCREEN.
*    IF t_radio_01 EQ 'X'.
*      IF screen-name EQ '%_PSEL_%_APP_%-TEXT' OR screen-name EQ '%_PSEL_%_APP_%-OPTI_PUSH' OR
*        screen-name EQ '%_PSEL_%_APP_%-VALU_PUSH' OR  screen-name EQ '%_17SNJ0000701213_%_%_%_%_%_%_'
*        OR  screen-name EQ 'PSEL-LOW'.
*        screen-active = 0.
*      ENDIF.
*    ELSE.
*      IF t_radio_02 EQ 'X'.
*        IF screen-name EQ '%_PSEL_%_APP_%-TEXT' OR screen-name EQ '%_PSEL_%_APP_%-OPTI_PUSH' OR
*      screen-name EQ '%_PSEL_%_APP_%-VALU_PUSH' OR  screen-name EQ '%_17SNJ0000701213_%_%_%_%_%_%_'
*          OR  screen-name EQ 'PSEL-LOW'.
*          screen-active = 1.
*        ENDIF.
*
*      ENDIF.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.
ENDMODULE.                 " PBO_REPORT  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  CADUCA_ELEC_INDIV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM caduca_elec_indiv  TABLES  psel STRUCTURE psel
                                t_ok STRUCTURE t_ok
                        USING bukrs hbkid hktid bkpf-budat.

  DATA: t_payr LIKE payr  OCCURS 0 WITH HEADER LINE.
  DATA: t_bsis LIKE bsis.  "OCCURS 0 WITH HEADER LINE.
  DATA: t_bsas LIKE bsas  OCCURS 0 WITH HEADER LINE.
  DATA: g_hkod LIKE bseg-hkont. "GUARDA CUENTA DE DESTINO"
  DATA: g_sgtxt  LIKE bseg-sgtxt. "ALMACENAMOS EL TEXTO PARA LA POSICION.

  SELECT *
   FROM zcta_prescrip
   INTO CORRESPONDING FIELDS OF TABLE ti_zctap.



  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_payr
    FROM payr
     WHERE ichec EQ ''
       AND zbukr EQ bukrs
       AND hbkid EQ hbkid
       AND hktid EQ hktid
       AND chect IN psel
       AND zaldt IN pfepag.
  DATA: vnun TYPE n,
        vnun2(9) TYPE c.

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 20/12/2019 EY_DES01 ECDK917080 *
SORT T_CTA .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 20/12/2019 EY_DES01 ECDK917080 *
  LOOP AT t_payr.
    g_valid_cta = 0.
    REFRESH t_cta.
    vnun = 2.
    DO 7 TIMES.
      ADD 1 TO vnun.
      vnun2 = vnun.
      CONCATENATE t_payr-ubhkt+0(9) vnun2 INTO t_cta-low.
      t_cta-sign = 'I'.
      t_cta-option = 'EQ'.
      APPEND t_cta.
    ENDDO.
    PERFORM ctas_zcta_prescrip.
    DELETE ADJACENT DUPLICATES FROM t_cta.


*    ASIGNA VALOR A G_HKOD ******************************
    CONCATENATE t_payr-ubhkt+0(9) '7' INTO g_hkod.
*********************************************************
    CONCATENATE 'Caducar Electronico Individual'  ' - '  sy-datum INTO g_sgtxt.
    g_little = 'Caducar Electronico Individual'.
    IF t_payr-xbanc = 'X'.
      CLEAR: t_ok.
      des_cta = 'CHEQUE PAGADO'.
      MOVE: t_payr-vblnr TO t_ok-belnr,
            '@0A@'       TO t_ok-status,
            t_payr-zbukr TO t_ok-bukrs,
            t_payr-gjahr  TO t_ok-gjahr,
            t_payr-chect  TO t_ok-chect,
            g_hkod        TO t_ok-hkontd,
            g_sgtxt       TO t_ok-sgtxt,
            t_payr-vblnr  TO t_ok-vblnr,
            des_cta       TO t_ok-estado,
            '--'          TO t_ok-bldat,
            t_payr-zaldt  TO t_ok-zaldt,
            t_payr-znme1  TO t_ok-znme1,
            '--'           TO t_ok-zmote.
      APPEND t_ok.
    ELSE.
      IF t_payr-ubhkt EQ space.
        CLEAR: t_ok.
        PERFORM desc_cta USING '99' CHANGING des_cta.
        IF t_payr-voidr GT 0. " causa de anulacion
          des_cta = 'CHEQUE ANULADO'.
        ENDIF.

        MOVE: t_payr-vblnr TO t_ok-belnr,
              '@0A@'       TO t_ok-status,
              t_payr-zbukr TO t_ok-bukrs,
              t_payr-gjahr  TO t_ok-gjahr,
              t_payr-chect  TO t_ok-chect,
              g_hkod        TO t_ok-hkontd,
              g_sgtxt       TO t_ok-sgtxt,
              t_payr-vblnr  TO t_ok-vblnr,
              des_cta       TO t_ok-estado,
              '--'          TO t_ok-bldat,
              t_payr-zaldt  TO t_ok-zaldt,
              t_payr-znme1  TO t_ok-znme1,
              '--'           TO t_ok-zmote.
        APPEND t_ok.
      ELSE.

        SELECT SINGLE * INTO CORRESPONDING FIELDS OF  t_bsis
          FROM bsis
           WHERE bukrs EQ t_payr-zbukr
             AND hkont EQ t_payr-ubhkt
             AND gjahr EQ t_payr-gjahr
             AND belnr EQ t_payr-vblnr.
        IF sy-subrc EQ 0.
* Si 	Existe registro, por lo tanto cheque sin compensar, verificar si han pasado los 60 días para caducar
          DATA: datediff  TYPE  p,
          timediff  TYPE  p,
          earliest  TYPE  c.
          DATA: p_kouhr1 TYPE kouhr,
                p_kouhr2 TYPE kouhr.
          p_kouhr1 = sy-uzeit.
          p_kouhr2 =  p_kouhr1.
          CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
            EXPORTING
*          DATE1            = T_BSIS-BLDAT
              date1            = t_bsis-valut
              time1            = p_kouhr1
              date2            = bkpf-budat
              time2            = p_kouhr2
            IMPORTING
              datediff         = datediff
              timediff         = timediff
              earliest         = earliest
            EXCEPTIONS
              invalid_datetime = 1
              OTHERS           = 2.
          IF sy-subrc EQ 0.
            PERFORM desc_cta USING t_bsis-hkont+9(1) CHANGING des_cta .

            LOOP AT ti_zctap WHERE cuenta_p EQ t_bsis-hkont.
              des_cta = ti_zctap-descripcion.
            ENDLOOP.

            IF earliest EQ 2.
              datediff = datediff * -1.
*          des_cta = g_desf.
            ENDIF.
* FCV - 19.07.2010 - Se revisa si corresponde a glosa de anulaciòn
            IF t_payr-voidr GT 0. " causa de anulacion
              des_cta = 'CHEQUE ANULADO'.
            ENDIF.
* fin FCV - 19.07.2010
******** SE RESCATA BLDAT *****************************.
            CLEAR g_bldat.
            PERFORM  resc_bldat USING bukrs t_payr-vblnr t_bsis-gjahr
                                CHANGING g_bldat.
******** Validacion de cuenta **************************
            PERFORM valid_cta  USING t_bsis-hkont+9(1)  save_code
                               CHANGING g_valid_cta.
***************************************************************************
            PERFORM  zmot_emis USING bukrs  t_bsis-belnr t_bsis-gjahr
                               CHANGING p_zmot_emis.
**************************************************************************

* Si diferencia de fechas es menos a 60 doias no se podra caducar.
            IF datediff >= 60.
              CLEAR: t_ok.
              MOVE: t_bsis-belnr TO t_ok-belnr.
              IF g_valid_cta EQ 1.
                MOVE '@0A@'    TO t_ok-status. " ICONO MAL
              ELSE.
                MOVE '@08@'    TO t_ok-status. " ICONO BIEN
              ENDIF.

              MOVE: t_bsis-bukrs TO t_ok-bukrs,
               t_bsis-buzei  TO t_ok-buzei,
               t_bsis-gjahr  TO t_ok-gjahr,
               t_bsis-hkont  TO t_ok-hkont,
               t_bsis-wrbtr  TO t_ok-wrbtr,
               t_payr-chect  TO t_ok-chect,
               g_hkod        TO t_ok-hkontd,
               g_sgtxt       TO t_ok-sgtxt,
               datediff      TO t_ok-datev,
               des_cta       TO t_ok-estado,
               t_payr-vblnr  TO t_ok-vblnr,
               g_bldat       TO t_ok-bldat,
               t_bsis-bldat  TO t_ok-bldat,
               t_payr-zaldt  TO t_ok-zaldt,
               t_payr-znme1  TO t_ok-znme1,
               p_zmot_emis   TO t_ok-zmote.
            ELSE.
              CLEAR: t_ok.
              MOVE: t_bsis-belnr TO t_ok-belnr,
              '@0A@'    TO t_ok-status,
              t_bsis-bukrs TO t_ok-bukrs,
              t_bsis-buzei TO t_ok-buzei,
              t_bsis-gjahr TO t_ok-gjahr,
              t_bsis-hkont TO t_ok-hkont,
              t_bsis-wrbtr TO t_ok-wrbtr,
              t_payr-chect TO t_ok-chect,
              g_hkod       TO t_ok-hkontd,
              g_sgtxt      TO t_ok-sgtxt,
              datediff     TO t_ok-datev,
              des_cta      TO t_ok-estado,
              t_payr-vblnr TO t_ok-vblnr,
              t_bsis-bldat TO t_ok-bldat,
              t_payr-zaldt TO t_ok-zaldt,
              t_payr-znme1 TO t_ok-znme1,
              p_zmot_emis  TO t_ok-zmote.
            ENDIF.
            APPEND t_ok.
          ENDIF.
        ELSE.
* Si registro no existe, buscarlo en tabla de compensados (BSAS)
          SELECT * INTO CORRESPONDING FIELDS OF TABLE t_bsas
            FROM bsas
             WHERE bukrs EQ t_payr-zbukr
               AND hkont EQ t_payr-ubhkt
               AND gjahr EQ t_payr-gjahr
               AND belnr EQ t_payr-vblnr.

          LOOP AT t_bsas.
            CLEAR t_ok.
            PERFORM busca_compen  TABLES t_cta
                                          t_ok
                                   USING  t_bsas-bukrs  t_bsas-augbl g_hkod g_sgtxt t_payr-voidr
                                          t_payr-vblnr t_payr-lifnr t_payr-gjahr t_payr-chect t_payr-zaldt
                                          t_payr-znme1.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CADUCA_ELEC_INDIV

*&---------------------------------------------------------------------*
*&      Form  CADUCA_ELEC_MASIV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PSEL       text
*      -->T_OK       text
*      -->BUKRS      text
*      -->HBKID      text
*      -->HKTID      text
*      -->BKPF-BUDAT text
*----------------------------------------------------------------------*
FORM  caduca_elec_masiv   TABLES  psel STRUCTURE psel
                                  t_ok STRUCTURE t_ok
                            USING bukrs hbkid hktid bkpf-budat.



  DATA: t_payr LIKE t012k  OCCURS 0 WITH HEADER LINE.
  DATA: t_bsis LIKE bsis OCCURS 0 WITH HEADER LINE.
  DATA: t_bsas LIKE bsas  OCCURS 0 WITH HEADER LINE.
  DATA: g_hkod LIKE bseg-hkont. "GUARDA CUENTA DE DESTINO"
  DATA: g_sgtxt  LIKE bseg-sgtxt. "ALMACENAMOS EL TEXTO PARA LA POSICION.
  DATA: g_checaux LIKE t_ok-chect.

  REFRESH t_cta.

  RANGES: p_bukrs FOR payr-zbukr.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_payr
      FROM t012k
       WHERE bukrs EQ bukrs
         AND hbkid EQ hbkid
         AND hktid EQ hktid.

  DATA: vnun TYPE n,
        vnun2(9) TYPE c,
        v_voidr LIKE payr-voidr.

  LOOP AT t_payr.
    REFRESH t_cta.
    vnun = 1.
    DO 2 TIMES.
      ADD 1 TO vnun.
      vnun2 = vnun.
      CONCATENATE t_payr-hkont+0(9) vnun2 INTO t_cta-low.
      t_cta-sign = 'I'.
      t_cta-option = 'EQ'.
      APPEND t_cta.
      IF   vnun EQ 2.
        vnun = 8.
      ENDIF.
    ENDDO.
  ENDLOOP.

*ReSQ: No Need Of Change Internal Table T_CTA Already Sorted
  DELETE ADJACENT DUPLICATES FROM t_cta.

*    ASIGNA VALOR A G_HKOD ******************************
  CONCATENATE t_payr-hkont+0(9) '7' INTO g_hkod.
*********************************************************

  SELECT  * APPENDING  CORRESPONDING FIELDS OF TABLE  t_bsis
    FROM bsis
     WHERE bukrs = bukrs
       AND hkont IN t_cta.

  CONCATENATE 'Caducar Electronico Masivo'  ' - '  sy-datum INTO g_sgtxt.
  g_little = 'Caducar Electronico Masivo'.

  LOOP AT  t_bsis.
* Si 	Existe registro, por lo tanto cheque sin compensar, verificar si han pasado los 60 días para caducar
    DATA: datediff  TYPE  p,
    timediff  TYPE  p,
    earliest  TYPE  c.
    DATA: p_kouhr1 TYPE kouhr,
          p_kouhr2 TYPE kouhr.
    p_kouhr1 = sy-uzeit.
    p_kouhr2 =  p_kouhr1.
    CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
      EXPORTING
        date1            = t_bsis-bldat
        time1            = p_kouhr1
        date2            = bkpf-budat
        time2            = p_kouhr2
      IMPORTING
        datediff         = datediff
        timediff         = timediff
        earliest         = earliest
      EXCEPTIONS
        invalid_datetime = 1
        OTHERS           = 2.
    IF sy-subrc EQ 0.
      CLEAR: g_checaux, v_voidr.
      IF t_bsis-hkont+9(1) EQ 2.
        SELECT SINGLE chect voidr
        FROM payr
        INTO (g_checaux, v_voidr)
        WHERE ichec EQ ''
          AND zbukr EQ bukrs
          AND hbkid EQ hbkid
          AND hktid EQ hktid
          AND vblnr EQ t_bsis-belnr
          AND zaldt IN pfepag.
      ENDIF.

      PERFORM desc_cta USING t_bsis-hkont+9(1) CHANGING des_cta.
      IF earliest EQ 2.
        datediff = datediff * -1.
*        des_cta = g_desf.
      ENDIF.

* FCV - 19.07.2010 - Se revisa si corresponde a glosa de anulaciòn
      IF v_voidr GT 0. " causa de anulacion
        des_cta = 'CHEQUE ANULADO'.
      ENDIF.
* fin FCV - 19.07.2010
******** SE RESCATA BLDAT *****************************.
      CLEAR g_bldat.
      PERFORM  resc_bldat USING bukrs t_bsis-belnr t_bsis-gjahr
                          CHANGING g_bldat.
******** Validacion de cuenta **************************
      PERFORM valid_cta  USING t_bsis-hkont+9(1)  save_code
                      CHANGING g_valid_cta.
********************************************************

* Si diferencia de fechas es menos a 60 doias no se podra caducar.
      IF datediff >= 60.
        CLEAR:   t_ok.
        MOVE: t_bsis-belnr TO t_ok-belnr.
        IF g_valid_cta EQ 1.
          MOVE '@0A@'    TO t_ok-status. " ICONO MAL
        ELSE.
          MOVE '@08@'    TO t_ok-status. " ICONO BIEN
        ENDIF.

        MOVE: t_bsis-bukrs TO t_ok-bukrs,
              t_bsis-buzei  TO t_ok-buzei,
              t_bsis-gjahr  TO t_ok-gjahr,
              t_bsis-hkont  TO t_ok-hkont,
              t_bsis-wrbtr  TO t_ok-wrbtr,
              g_hkod        TO t_ok-hkontd,
* FCV - 22.04.2010
*               'X'          TO t_ok-chek1,
               'X'          TO t_ok-box,
* fin FCV - 22.04.2010
              g_sgtxt       TO t_ok-sgtxt,
              datediff      TO t_ok-datev,
              g_checaux     TO t_ok-chect,
              des_cta       TO t_ok-estado,
              g_bldat       TO t_ok-bldat.
      ELSE.
        CLEAR:   t_ok.
        MOVE: t_bsis-belnr TO t_ok-belnr,
              '@0A@'    TO t_ok-status,
              t_bsis-bukrs TO t_ok-bukrs,
              t_bsis-buzei TO t_ok-buzei,
              t_bsis-gjahr TO t_ok-gjahr,
              t_bsis-hkont TO t_ok-hkont,
              t_bsis-wrbtr TO t_ok-wrbtr,
* FCV - 22.04.2010
*               'X'         TO t_ok-chek1,
               'X'         TO t_ok-box,
* fin FCV - 22.04.2010
              g_hkod       TO t_ok-hkontd,
              g_sgtxt      TO t_ok-sgtxt,
              datediff     TO t_ok-datev,
              g_checaux    TO t_ok-chect,
              des_cta       TO t_ok-estado.
      ENDIF.
      APPEND t_ok.
    ENDIF.
  ENDLOOP.

ENDFORM.  " CADUCA_ELEC_MASIV

*&---------------------------------------------------------------------*
*&      Form  CADUCA_FISIC_INDIV
*&---------------------------------------------------------------------*
*       text
FORM caduca_fisic_indiv TABLES  psel STRUCTURE psel
                                t_ok STRUCTURE t_ok
                        USING bukrs hbkid hktid bkpf-budat.

  DATA: t_payr LIKE payr  OCCURS 0 WITH HEADER LINE.
  DATA: t_bsis LIKE bsis.  "OCCURS 0 WITH HEADER LINE.
  DATA: t_bsas LIKE bsas  OCCURS 0 WITH HEADER LINE.
  DATA: g_hkod LIKE bseg-hkont. "GUARDA CUENTA DE DESTINO"
  DATA: g_sgtxt  LIKE bseg-sgtxt. "ALMACENAMOS EL TEXTO PARA LA POSICION.
  DATA: g_checaux LIKE t_ok-chect.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_payr
    FROM payr
     WHERE ichec EQ ''
       AND zbukr EQ bukrs
       AND hbkid EQ hbkid
       AND hktid EQ hktid
       AND chect IN psel
       AND zaldt IN pfepag.
  DATA: vnun TYPE n,
        vnun2(9) TYPE c.


  CONCATENATE 'Caducar Fisico Individual'  ' - '  sy-datum INTO g_sgtxt.
  g_little = 'Caducar Fisico Individual'.
  LOOP AT t_payr.
    g_valid_cta = 0.
    REFRESH t_cta.
    vnun = 1.
    DO 4 TIMES.
      ADD 1 TO vnun.
      vnun2 = vnun.
      CONCATENATE t_payr-ubhkt+0(9) vnun2 INTO t_cta-low.
      t_cta-sign = 'I'.
      t_cta-option = 'EQ'.
      APPEND t_cta.
      IF vnun EQ 2.
        vnun = 5.
      ENDIF.
      IF vnun EQ 7.
        vnun = 8.
      ENDIF.
    ENDDO.

    PERFORM ctas_zcta_prescrip.
*ReSQ: No Need Of Change Internal Table T_CTA Already Sorted
    DELETE ADJACENT DUPLICATES FROM t_cta.

*    ASIGNA VALOR A G_HKOD ******************************
    CONCATENATE t_payr-ubhkt+0(9) '6' INTO g_hkod.
*********************************************************
    IF t_payr-xbanc = 'X'.
      CLEAR: t_ok.
      des_cta = 'CHEQUE PAGADO'.
      MOVE: t_payr-vblnr TO t_ok-belnr,
            '@0A@'       TO t_ok-status,
            t_payr-zbukr TO t_ok-bukrs,
            t_payr-gjahr TO t_ok-gjahr,
            t_payr-chect TO t_ok-chect,
            g_sgtxt      TO t_ok-sgtxt,
            t_payr-vblnr TO t_ok-vblnr,
            des_cta      TO t_ok-estado,
            t_payr-zaldt TO t_ok-zaldt,
            t_payr-znme1 TO t_ok-znme1,
            '--'         TO t_ok-zmote..

      APPEND t_ok.

    ELSE.
      IF t_payr-ubhkt EQ space.
        CLEAR: t_ok.
        PERFORM desc_cta USING '99' CHANGING des_cta.
        IF t_payr-voidr GT 0. " causa de anulacion
          des_cta = 'CHEQUE ANULADO'.
        ENDIF.
        MOVE: t_payr-vblnr TO t_ok-belnr,
              '@0A@'       TO t_ok-status,
              t_payr-zbukr TO t_ok-bukrs,
              t_payr-gjahr TO t_ok-gjahr,
              t_payr-chect TO t_ok-chect,
              g_sgtxt      TO t_ok-sgtxt,
              t_payr-vblnr TO t_ok-vblnr,
              des_cta      TO t_ok-estado,
              t_payr-zaldt TO t_ok-zaldt,
              t_payr-znme1 TO t_ok-znme1,
              '--'         TO t_ok-zmote..

        APPEND t_ok.

      ELSE.
        SELECT SINGLE * INTO CORRESPONDING FIELDS OF  t_bsis
          FROM bsis
           WHERE bukrs EQ t_payr-zbukr
             AND hkont EQ  t_payr-ubhkt "T_CTA
             AND gjahr EQ t_payr-gjahr
             AND belnr EQ t_payr-vblnr.
        IF sy-subrc EQ 0.
* Si 	Existe registro, por lo tanto cheque sin compensar, verificar si han pasado los 60 días para caducar
          DATA: datediff  TYPE  p,
          timediff  TYPE  p,
          earliest  TYPE  c.
          DATA: p_kouhr1 TYPE kouhr,
                p_kouhr2 TYPE kouhr.
          p_kouhr1 = sy-uzeit.
          p_kouhr2 =  p_kouhr1.
          CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
            EXPORTING
*          DATE1            = T_BSIS-BLDAT
              date1            = t_bsis-valut
              time1            = p_kouhr1
              date2            = bkpf-budat
              time2            = p_kouhr2
            IMPORTING
              datediff         = datediff
              timediff         = timediff
              earliest         = earliest
            EXCEPTIONS
              invalid_datetime = 1
              OTHERS           = 2.
          IF sy-subrc EQ 0.
            PERFORM desc_cta USING t_bsis-hkont+9(1) CHANGING des_cta.
            IF earliest EQ 2.
              datediff = datediff * -1.
*          des_cta = g_desf.
              g_valid_cta = 1.
            ENDIF.
            IF t_payr-voidr GT 0. " causa de anulacion
              des_cta = 'CHEQUE ANULADO'.
              datediff = 0.
            ENDIF.

*        SELECT SINGLE CHECT
*        FROM PAYR
*        INTO G_CHECAUX
*        WHERE ICHEC EQ ''
*          AND ZBUKR EQ BUKRS
*          AND HBKID EQ HBKID
*          AND HKTID EQ HKTID
*          AND VBLNR EQ T_BSIS-BELNR.


******** SE RESCATA BLDAT *****************************.
            CLEAR g_bldat.
            PERFORM  resc_bldat USING bukrs t_bsis-belnr t_bsis-gjahr
                                CHANGING g_bldat.

******** Validacion de cuenta **************************
            PERFORM valid_cta  USING t_bsis-hkont+9(1)  save_code
                            CHANGING g_valid_cta.
********************************************************
***************************************************************************
            PERFORM  zmot_emis USING bukrs  t_bsis-belnr t_bsis-gjahr
                            CHANGING p_zmot_emis.
***************************************************************************

* Si diferencia de fechas es menos a 60 doias no se podra caducar.
            IF datediff >= 60 OR t_bsis-hkont+9(1) NE '2'. " T_BSIS-HKONT+9(1) EQ '9'.
              CLEAR: t_ok.
              MOVE: t_bsis-belnr TO t_ok-belnr.
* FCV - 18.08.2010 - Se deja fuera de validaciòn de fecha a cheques con estado CADUCADO FISCAL
              IF NOT des_cta = 'CADUCADO FISCAL'.
* fin FCV - 18.08.2010
                IF g_valid_cta EQ 1.
                  MOVE '@0A@'    TO t_ok-status. " ICONO MAL
                ELSE.
                  MOVE '@08@'    TO t_ok-status. " ICONO BIEN
                ENDIF.
              ELSE.
                MOVE '@08@'    TO t_ok-status. " ICONO BIEN
              ENDIF.
              MOVE:t_bsis-bukrs  TO t_ok-bukrs,
              t_bsis-buzei  TO t_ok-buzei,
              t_bsis-gjahr  TO t_ok-gjahr,
              t_bsis-hkont  TO t_ok-hkont,
              t_bsis-wrbtr  TO t_ok-wrbtr,
              t_payr-chect  TO t_ok-chect,
              g_hkod        TO t_ok-hkontd,
              g_sgtxt       TO t_ok-sgtxt,
              datediff      TO t_ok-datev,
              des_cta       TO t_ok-estado,
              t_payr-vblnr  TO t_ok-vblnr,
              g_bldat       TO t_ok-bldat,
              t_payr-zaldt  TO t_ok-zaldt,
              t_payr-znme1  TO t_ok-znme1,
              p_zmot_emis   TO t_ok-zmote..
            ELSE.
              CLEAR: t_ok.
              MOVE: t_bsis-belnr  TO t_ok-belnr,
                    '@0A@'        TO t_ok-status,
                    t_bsis-bukrs  TO t_ok-bukrs,
                    t_bsis-buzei  TO t_ok-buzei,
                    t_bsis-gjahr  TO t_ok-gjahr,
                    t_bsis-hkont  TO t_ok-hkont,
                    t_bsis-wrbtr  TO t_ok-wrbtr,
                    t_payr-chect  TO t_ok-chect,
                    g_hkod        TO t_ok-hkontd,
                    g_sgtxt       TO t_ok-sgtxt,
                    datediff      TO t_ok-datev,
                    des_cta       TO t_ok-estado,
                    t_payr-vblnr  TO t_ok-vblnr,
                    g_bldat       TO t_ok-bldat,
                    t_payr-zaldt  TO t_ok-zaldt,
                    t_payr-znme1  TO t_ok-znme1,
                    p_zmot_emis   TO t_ok-zmote.
            ENDIF.
            APPEND t_ok.
          ENDIF.
        ELSE.
* Si registro no existe, buscarlo en tabla de compensados (BSAS)
          SELECT * INTO CORRESPONDING FIELDS OF TABLE t_bsas
            FROM bsas
             WHERE bukrs EQ t_payr-zbukr
               AND hkont EQ t_payr-ubhkt
               AND gjahr EQ t_payr-gjahr
               AND belnr EQ t_payr-vblnr.

          LOOP AT t_bsas.
            CLEAR t_ok.
            PERFORM busca_compen  TABLES t_cta
                                          t_ok
                                   USING  t_bsas-bukrs  t_bsas-augbl g_hkod g_sgtxt t_payr-voidr
                                          t_payr-vblnr t_payr-lifnr t_payr-gjahr t_payr-chect t_payr-zaldt
                                          t_payr-znme1.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDFORM. " CADUCA_FISIC_INDIV
*&---------------------------------------------------------------------*
*&      Form  BUSCA_COMPEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BSAS  text
*----------------------------------------------------------------------*
FORM busca_compen    TABLES t_t_cta STRUCTURE t_cta
                            t_ok    STRUCTURE t_ok
                     USING  p_t_bsas-bukrs  p_t_bsas-augbl g_hkod g_sgtxt g_voidr
                            p_t_belnr p_t_lifnr p_gjahr p_chect p_zaldt
                            p_znme1.

  DATA: t_bseg LIKE bseg  OCCURS 0 WITH HEADER LINE.
  DATA: g_checaux LIKE t_ok-chect.
  DATA: g_hkot LIKE bseg-hkont. "GUARDA CUENTA ACTUAL"
  DATA: p_motemis TYPE ZZMOT_EMIS. " motivo de emision para maternales

  SELECT *
   FROM zcta_prescrip
   INTO CORRESPONDING FIELDS OF TABLE ti_zctap.

SELECT * INTO CORRESPONDING FIELDS OF TABLE t_bseg
FROM bseg
WHERE bukrs EQ p_t_bsas-bukrs
AND belnr EQ p_t_bsas-augbl
AND shkzg EQ 'H'
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 20/12/2019 EY_DES01 ECDK917080 *
*AND zuonr EQ p_chect.
AND ZUONR EQ P_CHECT ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 20/12/2019 EY_DES01 ECDK917080 *

  LOOP AT t_bseg.
    CHECK t_bseg-hkont IN t_t_cta.
    IF t_bseg-augbl NE space.
      PERFORM busca_compen  TABLES t_cta
                                   t_ok
                            USING  t_bseg-bukrs  t_bseg-augbl g_hkod g_sgtxt g_voidr
                                   p_t_belnr p_t_lifnr p_gjahr p_chect p_zaldt
                                   p_znme1.
    ELSE.
* Si 	Existe registro, por lo tanto cheque sin compensar, verificar si han pasado los 60 días para caducar
      DATA: p_bldat TYPE bldat.
      SELECT SINGLE  budat INTO p_bldat
          FROM bkpf
        WHERE  bukrs EQ t_bseg-bukrs
          AND  belnr EQ t_bseg-belnr
          AND  gjahr EQ t_bseg-gjahr.

******** SE RESCATA BLDAT *****************************.
      CLEAR g_bldat.
      IF save_code EQ'PRO_01'.
        PERFORM  resc_bldat USING t_bseg-bukrs p_t_belnr t_bseg-gjahr
                          CHANGING g_bldat.
      ELSE.
        PERFORM  resc_bldat USING t_bseg-bukrs t_bseg-belnr t_bseg-gjahr
                         CHANGING g_bldat.
      ENDIF.



      DATA: datediff  TYPE  p,
            timediff  TYPE  p,
            earliest  TYPE  c.


      DATA: p_kouhr1 TYPE kouhr,
            p_kouhr2 TYPE kouhr.

      p_kouhr1 = sy-uzeit.
      p_kouhr2 =  p_kouhr1.

      CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
        EXPORTING
          date1            = p_bldat
          time1            = p_kouhr1
          date2            = bkpf-budat
          time2            = p_kouhr2
        IMPORTING
          datediff         = datediff
          timediff         = timediff
          earliest         = earliest
        EXCEPTIONS
          invalid_datetime = 1
          OTHERS           = 2.
      IF sy-subrc EQ 0.
******** Validacion de cuenta **************************
        PERFORM valid_cta  USING t_bseg-hkont+9(1)  save_code
                        CHANGING g_valid_cta.
********************************************************
        PERFORM desc_cta USING t_bseg-hkont+9(1) CHANGING des_cta .


        IF g_voidr GT 0. " causa de anulacion
          des_cta = 'CHEQUE ANULADO'.
          g_hkot ='ANULACION'.
          datediff = 0.
          IF save_code NE 'PRO_08'.
            g_valid_cta = 1.
          ENDIF.
        ENDIF.

        LOOP AT ti_zctap WHERE cuenta_p EQ t_bseg-hkont.
          des_cta = ti_zctap-descripcion.
        ENDLOOP.

        IF des_cta  = 'CHEQUE ANULADO'.
          g_hkot ='ANULACION'.
        ELSE.
          g_hkot = t_bseg-hkont.
        ENDIF.


        IF earliest EQ 2.
          datediff = datediff * -1.
*          des_cta  = g_desf.
* FCV - 04.07.2010 - Se controla la diferencia de dias negativa para la Anulación
*          IF save_code NE 'PRO_08'.
          IF save_code NE 'PRO_08' AND save_code NE 'PRO_03' .
            g_valid_cta = 1.
          ENDIF.
        ENDIF.

***************************************************************************
        PERFORM  zmot_emis USING p_t_bsas-bukrs  p_t_belnr p_gjahr
                           CHANGING p_zmot_emis.
**************************************************************************

*********     Se revisa y el cheque tiene historia ***********************
        IF save_code EQ 'PRO_08'.
          PERFORM sestchqrever USING bukrs
                                     hbkid
                                     hktid
                                     g_hkot
                                     p_chect
                                     CHANGING p_ctareversa p_belnrant.


          IF p_ctareversa EQ '--'.
            des_cta = 'CHEQUE GIRADO'.
            g_valid_cta = 1.
          ENDIF.
        ENDIF.

        CASE save_code.
          WHEN 'PRO_03' OR 'PRO_05' OR 'PRO_06' OR 'PRO_08'.
            CLEAR: t_ok.
            MOVE: t_bseg-belnr TO t_ok-belnr.
* FCV - 21.04.2010
* Si la cuenta corresponde a nuevo cheque validado,
* se debe permitir la Anulación
            IF save_code = 'PRO_03' AND t_bseg-hkont = '2011730013'.
              g_valid_cta = 0.
            ENDIF.
* fin FCV - 21.04.2010
            IF g_valid_cta EQ 1.
              MOVE '@0A@'    TO t_ok-status. " ICONO MAL
            ELSE.
              MOVE '@08@'    TO t_ok-status. " ICONO BIEN
            ENDIF.
*********************************

* FCV - 07.07.2010 02-04-2012 HC cambio de luehar esta instruccion
* Si el motivo es Submaernal, sólo debe permitir anular cheques con estado CHEQUE GIRADO.
*           IF t_ok-zmote = 'SUBMATERNA'.
*              IF t_ok-estado <> 'CHEQUE GIRADO'.
*                MOVE '@0A@'    TO t_ok-status. " ICONO MAL
*              ENDIF.
*            ENDIF.
* fin FCV - 07.07.2010 HC cambio de luehar esta instruccion

            MOVE:t_bseg-bukrs  TO t_ok-bukrs,
                 t_bseg-buzei  TO t_ok-buzei,
                 t_bseg-gjahr  TO t_ok-gjahr,
                 g_hkot        TO t_ok-hkont,
                 t_bseg-zuonr  TO t_ok-chect,
                 t_bseg-wrbtr  TO t_ok-wrbtr,
                 g_hkod        TO t_ok-hkontd,
                 g_sgtxt       TO t_ok-sgtxt,
                 datediff      TO t_ok-datev,
                 des_cta       TO t_ok-estado,
                 p_t_belnr     TO t_ok-vblnr,
                 p_bldat       TO t_ok-bldat,
                 p_t_lifnr     TO t_ok-lifnr,
                 p_zaldt    TO t_ok-zaldt,
                 p_znme1    TO t_ok-znme1,
                 p_zmot_emis   TO t_ok-zmote.

*********************************
* HCASTILLO 30 Marzo 2012
*********************************

SELECT SINGLE ZZMOT_EMIS
INTO  p_motemis
FROM  ZTIPCHEQUEMAT
WHERE BUKRS      EQ t_ok-bukrs
  AND ZZMOT_EMIS EQ t_ok-zmote.
* FCV - 07.07.2010 HC cambio de luehar esta instruccion
* Si el motivo es Submaernal, sólo debe permitir anular cheques con estado CHEQUE GIRADO.
*            IF t_ok-zmote = 'SUBMATERNA'.
            IF sy-subrc = 0.
              IF t_ok-estado <> 'CHEQUE GIRADO'.
                MOVE '@0A@'    TO t_ok-status. " ICONO MAL
              ENDIF.
            ENDIF.
* fin FCV - 07.07.2010 HC cambio de luehar esta instruccion
*********************************
* HCASTILLO 30 Marzo 2012
*********************************

SELECT SINGLE ZZMOT_EMIS
INTO  p_motemis
FROM  ZTIPCHEQUEMAT
WHERE BUKRS      EQ t_ok-bukrs
  AND ZZMOT_EMIS EQ t_ok-zmote.
* FCV - 06.07.2010
*            IF t_ok-zmote = 'SUBMATERNA' AND t_ok-estado = 'CHEQUE ANULADO'.
          IF sy-subrc = 0 AND t_ok-estado = 'CHEQUE ANULADO'.
              t_ok-estado = 'NUEVO CHEQUE MATERNAL'.
            ENDIF.
* fin FCV - 06.07.2010

          WHEN 'PRO_02'.
            IF t_bseg-hkont+9(1) EQ 7.
              CLEAR: t_ok.


              MOVE: t_bseg-belnr TO t_ok-belnr.
              IF g_valid_cta EQ 1.
                MOVE '@0A@'    TO t_ok-status. " ICONO MAL
              ELSE.
                MOVE '@08@'    TO t_ok-status. " ICONO BIEN
              ENDIF.
              MOVE:t_bseg-bukrs  TO t_ok-bukrs,
                   t_bseg-buzei  TO t_ok-buzei,
                   t_bseg-gjahr  TO t_ok-gjahr,
                   t_bseg-hkont  TO t_ok-hkont,
                   t_bseg-zuonr  TO t_ok-chect,
                   t_bseg-wrbtr  TO t_ok-wrbtr,
                   g_hkod        TO t_ok-hkontd,
                   g_sgtxt       TO t_ok-sgtxt,
                   datediff      TO t_ok-datev,
                   des_cta       TO t_ok-estado,
                   p_t_belnr     TO t_ok-vblnr,
                   p_bldat       TO t_ok-bldat,
                   p_t_lifnr     TO t_ok-lifnr,
                   p_zaldt       TO t_ok-zaldt,
                   p_znme1       TO t_ok-znme1,
                   p_zmot_emis   TO t_ok-zmote.

*********************************
* HCASTILLO 30 Marzo 2012
*********************************

SELECT SINGLE ZZMOT_EMIS
INTO  p_motemis
FROM  ZTIPCHEQUEMAT
WHERE BUKRS      EQ t_ok-bukrs
  AND ZZMOT_EMIS EQ t_ok-zmote.
* FCV - 06.07.2010
*              IF t_ok-zmote = 'SUBMATERNA' AND t_ok-estado = 'CHEQUE ANULADO'.
              IF sy-subrc = 0 AND t_ok-estado = 'CHEQUE ANULADO'.
                t_ok-estado = 'NUEVO CHEQUE MATERNAL'.
              ENDIF.
* fin FCV - 06.07.2010

            ELSE.
              IF datediff >= 60.
                CLEAR: t_ok.
                MOVE: t_bseg-belnr TO t_ok-belnr.
                IF g_valid_cta EQ 1.
                  MOVE '@0A@'    TO t_ok-status. " ICONO MAL
                ELSE.
                  MOVE '@08@'    TO t_ok-status. " ICONO BIEN
                ENDIF.
                MOVE:t_bseg-bukrs  TO t_ok-bukrs,
                     t_bseg-buzei  TO t_ok-buzei,
                     t_bseg-gjahr  TO t_ok-gjahr,
                     t_bseg-hkont  TO t_ok-hkont,
                     t_bseg-zuonr  TO t_ok-chect,
                     t_bseg-wrbtr  TO t_ok-wrbtr,
                     g_hkod        TO t_ok-hkontd,
                     g_sgtxt       TO t_ok-sgtxt,
                     datediff      TO t_ok-datev,
                     des_cta       TO t_ok-estado,
                     p_t_belnr     TO t_ok-vblnr,
                     p_bldat       TO t_ok-bldat,
                     p_t_lifnr     TO t_ok-lifnr,
                      p_zaldt       TO t_ok-zaldt,
                     p_znme1       TO t_ok-znme1,
                     p_zmot_emis   TO t_ok-zmote.

*********************************
* HCASTILLO 30 Marzo 2012
*********************************

SELECT SINGLE ZZMOT_EMIS
INTO  p_motemis
FROM  ZTIPCHEQUEMAT
WHERE BUKRS      EQ t_ok-bukrs
  AND ZZMOT_EMIS EQ t_ok-zmote.
* FCV - 06.07.2010
*                IF t_ok-zmote = 'SUBMATERNA' AND t_ok-estado = 'CHEQUE ANULADO'.
                IF sy-subrc = 0 AND t_ok-estado = 'CHEQUE ANULADO'.
                  t_ok-estado = 'NUEVO CHEQUE MATERNAL'.
                ENDIF.
* fin FCV - 06.07.2010

              ELSE.
                CLEAR: t_ok.
                MOVE: t_bseg-belnr TO t_ok-belnr,
                         '@0A@'    TO t_ok-status,
                      t_bseg-bukrs TO t_ok-bukrs,
                      t_bseg-buzei TO t_ok-buzei,
                      t_bseg-gjahr TO t_ok-gjahr,
                      t_bseg-hkont TO t_ok-hkont,
                      t_bseg-zuonr TO t_ok-chect,
                      t_bseg-wrbtr TO t_ok-wrbtr,
                      g_hkod       TO t_ok-hkontd,
                      g_sgtxt      TO t_ok-sgtxt,
                      datediff     TO t_ok-datev,
                      des_cta      TO t_ok-estado,
                      p_t_belnr    TO t_ok-vblnr,
                      p_t_lifnr    TO t_ok-lifnr,
                      p_bldat       TO t_ok-bldat,
                      p_zaldt    TO t_ok-zaldt,
                      p_znme1    TO t_ok-znme1,
                      p_zmot_emis   TO t_ok-zmote.

*********************************
* HCASTILLO 30 Marzo 2012
*********************************

SELECT SINGLE ZZMOT_EMIS
INTO  p_motemis
FROM  ZTIPCHEQUEMAT
WHERE BUKRS      EQ t_ok-bukrs
  AND ZZMOT_EMIS EQ t_ok-zmote.
* FCV - 06.07.2010
*                IF t_ok-zmote = 'SUBMATERNA' AND t_ok-estado = 'CHEQUE ANULADO'.
                IF sy-subrc = 0 AND t_ok-estado = 'CHEQUE ANULADO'.
                  t_ok-estado = 'NUEVO CHEQUE MATERNAL'.
                ENDIF.
* fin FCV - 06.07.2010

              ENDIF.
            ENDIF.
          WHEN OTHERS.
            IF datediff >= 60.
              CLEAR: t_ok.
              MOVE: t_bseg-belnr TO t_ok-belnr.
              IF g_valid_cta EQ 1.
                MOVE '@0A@'    TO t_ok-status. " ICONO MAL
              ELSE.
                MOVE '@08@'    TO t_ok-status. " ICONO BIEN
              ENDIF.
              MOVE:t_bseg-bukrs  TO t_ok-bukrs,
                   t_bseg-buzei  TO t_ok-buzei,
                   t_bseg-gjahr  TO t_ok-gjahr,
                   t_bseg-hkont  TO t_ok-hkont,
                   t_bseg-zuonr  TO t_ok-chect,
                   t_bseg-wrbtr  TO t_ok-wrbtr,
                   g_hkod        TO t_ok-hkontd,
                   g_sgtxt       TO t_ok-sgtxt,
                   datediff      TO t_ok-datev,
                   des_cta       TO t_ok-estado,
                   p_t_belnr     TO t_ok-vblnr,
                   p_bldat       TO t_ok-bldat,
                   p_t_lifnr     TO t_ok-lifnr,
                   p_zaldt       TO t_ok-zaldt,
                   p_znme1       TO t_ok-znme1,
                   p_zmot_emis   TO t_ok-zmote.

*********************************
* HCASTILLO 30 Marzo 2012
*********************************

SELECT SINGLE ZZMOT_EMIS
INTO  p_motemis
FROM  ZTIPCHEQUEMAT
WHERE BUKRS      EQ t_ok-bukrs
  AND ZZMOT_EMIS EQ t_ok-zmote.
* FCV - 06.07.2010
*              IF t_ok-zmote = 'SUBMATERNA' AND t_ok-estado = 'CHEQUE ANULADO'.
              IF sy-subrc = 0 AND t_ok-estado = 'CHEQUE ANULADO'.
                t_ok-estado = 'NUEVO CHEQUE MATERNAL'.
              ENDIF.
* fin FCV - 06.07.2010

* FCV - 23.08.2010 - Se determina la fecha de emisión
              IF save_code = 'PRO_04'.
                SELECT SINGLE * FROM zprescribe_fecha
                  WHERE bukrs = t_ok-bukrs
                    AND hbkid = hbkid
                    AND hktid = hktid
                    AND chect = t_ok-chect.

                IF sy-subrc EQ 0.
                  t_ok-zaldt = zprescribe_fecha-fecemi.
                ENDIF.
              ENDIF.
* fin FCV - 23.08.2010

            ELSE.
              CLEAR: t_ok.
              MOVE: t_bseg-belnr TO t_ok-belnr,
                       '@0A@'    TO t_ok-status,
                    t_bseg-bukrs TO t_ok-bukrs,
                    t_bseg-buzei TO t_ok-buzei,
                    t_bseg-gjahr TO t_ok-gjahr,
                    t_bseg-hkont TO t_ok-hkont,
                    t_bseg-zuonr TO t_ok-chect,
                    t_bseg-wrbtr TO t_ok-wrbtr,
                    g_hkod       TO t_ok-hkontd,
                    g_sgtxt      TO t_ok-sgtxt,
                    datediff     TO t_ok-datev,
                    des_cta      TO t_ok-estado,
                    p_t_belnr    TO t_ok-vblnr,
                    p_t_lifnr    TO t_ok-lifnr,
                    p_bldat      TO t_ok-bldat,
                    p_zaldt    TO t_ok-zaldt,
                    p_znme1    TO t_ok-znme1,
                    p_zmot_emis   TO t_ok-zmote.
*********************************
* HCASTILLO 30 Marzo 2012
*********************************

SELECT SINGLE ZZMOT_EMIS
INTO  p_motemis
FROM  ZTIPCHEQUEMAT
WHERE BUKRS      EQ t_ok-bukrs
  AND ZZMOT_EMIS EQ t_ok-zmote.
* FCV - 06.07.2010
*              IF t_ok-zmote = 'SUBMATERNA' AND t_ok-estado = 'CHEQUE ANULADO'.
              IF sy-subrc = 0 AND t_ok-estado = 'CHEQUE ANULADO'.
                t_ok-estado = 'NUEVO CHEQUE MATERNAL'.
              ENDIF.
* fin FCV - 06.07.2010
            ENDIF.
        ENDCASE.
* FCV - 04.07.2010
        IF save_code EQ 'PRO_06'.
          SELECT SINGLE xblnr INTO zcambiocheque-xblnr
            FROM zcambiocheque
            WHERE zbukr = t_bseg-bukrs
              AND hbkid = wa_payr-hbkid
              AND hktid = wa_payr-hktid
              AND rzawe = 'C'
              AND chect = t_bseg-zuonr.

          IF sy-subrc EQ 0.
            SELECT SINGLE belnr budat
              INTO (bkpf-belnr, bkpf-budat)
            FROM bkpf
            WHERE bukrs = t_bseg-bukrs
              AND gjahr = t_bseg-gjahr
              AND xblnr = zcambiocheque-xblnr.

            IF sy-subrc EQ 0.
              t_ok-belnr = bkpf-belnr.
* FCV - 04.08.2010
              t_ok-bldat = bkpf-budat.
* fin FCV - 04.08.2010
            ENDIF.
          ENDIF.
        ENDIF.
* fin FCV - 04.07.2010
        APPEND t_ok.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF t_ok IS INITIAL.
    DATA: it_payr LIKE payr  OCCURS 0 WITH HEADER LINE.
    CLEAR: t_ok.
    SELECT *
      FROM payr
      INTO CORRESPONDING FIELDS OF TABLE it_payr
     WHERE ichec EQ ''
       AND zbukr EQ bukrs
       AND hbkid EQ hbkid
       AND hktid EQ hktid
       AND vblnr EQ p_t_belnr
       AND chect EQ p_chect
       AND gjahr EQ p_gjahr
       AND zaldt IN pfepag.
    IF sy-subrc EQ 0.
    ENDIF.
    PERFORM desc_cta USING t_bseg-hkont+9(1) CHANGING des_cta.


    LOOP AT it_payr.

      SELECT SINGLE  budat INTO p_bldat
          FROM bkpf
        WHERE  bukrs EQ bukrs
          AND  belnr EQ t_bseg-belnr
          AND  gjahr EQ it_payr-gjahr.


      p_kouhr1 = sy-uzeit.
      p_kouhr2 =  p_kouhr1.
      CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
        EXPORTING
          date1            = p_bldat
          time1            = p_kouhr1
          date2            = bkpf-budat
          time2            = p_kouhr2
        IMPORTING
          datediff         = datediff
          timediff         = timediff
          earliest         = earliest
        EXCEPTIONS
          invalid_datetime = 1
          OTHERS           = 2.
      IF sy-subrc EQ 0.
******** Validacion de cuenta **************************
        PERFORM valid_cta  USING t_bseg-hkont+9(1)  save_code
                        CHANGING g_valid_cta.
********************************************************
***************************************************************************
        PERFORM  zmot_emis USING bukrs p_t_belnr it_payr-gjahr
                           CHANGING p_zmot_emis.
**************************************************************************

        IF earliest EQ 2.
          datediff = datediff * -1.
*          des_cta  = g_desf.
          IF save_code NE 'PRO_08'.
            g_valid_cta = 1.
          ENDIF.
        ENDIF.

        IF g_voidr GT 0 . " causa de anulacion
          des_cta = 'CHEQUE ANULADO'.
          datediff = 0.
          IF save_code NE 'PRO_08'.
            g_valid_cta = 1.
          ENDIF.
        ENDIF.

        LOOP AT ti_zctap WHERE cuenta_p EQ t_bseg-hkont.
          des_cta = ti_zctap-descripcion.
        ENDLOOP.

        IF des_cta  = 'CHEQUE ANULADO'.
          g_hkot ='ANULACION'.
        ELSE.
          g_hkot = t_bseg-hkont.
        ENDIF.

*********Se revisa y el cheque tiene historia ***********************
        IF save_code EQ 'PRO_08'.
          PERFORM sestchqrever USING bukrs
                                     hbkid
                                     hktid
                                     g_hkot
                                     p_chect
                                     CHANGING p_ctareversa p_belnrant.


          IF p_ctareversa EQ '--'.
            des_cta = 'CHEQUE GIRADO'.
            g_valid_cta = 1.
          ENDIF.

        ENDIF.

*************************************************************************
        MOVE: t_bseg-belnr  TO t_ok-belnr.
        IF g_valid_cta EQ 1.
          MOVE '@0A@'    TO t_ok-status. " ICONO MAL
        ELSE.
          MOVE '@08@'    TO t_ok-status. " ICONO BIEN
        ENDIF.
* FCV - 24.04.2010
*        MOVE:t_bseg-bukrs  TO t_ok-bukrs,
*             t_bseg-buzei  TO t_ok-buzei,
*             t_bseg-gjahr  TO t_ok-gjahr,
*             g_hkot        TO t_ok-hkont,
*             g_sgtxt       TO t_ok-sgtxt,
*             des_cta       TO t_ok-estado,
*             it_payr-chect TO t_ok-chect,
*             p_t_belnr     TO t_ok-vblnr,
*             datediff      TO t_ok-datev,
*             p_bldat       TO t_ok-bldat,
*             p_t_lifnr     TO t_ok-lifnr,
*             p_zaldt       TO t_ok-zaldt,
*             p_znme1       TO t_ok-znme1,
*             p_zmot_emis   TO t_ok-zmote.
        MOVE:t_bseg-bukrs  TO t_ok-bukrs,
             t_bseg-buzei  TO t_ok-buzei,
             t_bseg-gjahr  TO t_ok-gjahr,
             t_bseg-hkont  TO t_ok-hkont,
             t_bseg-zuonr  TO t_ok-chect,
             t_bseg-wrbtr  TO t_ok-wrbtr,
             g_hkod        TO t_ok-hkontd,
             g_sgtxt       TO t_ok-sgtxt,
             datediff      TO t_ok-datev,
             des_cta       TO t_ok-estado,
             p_t_belnr     TO t_ok-vblnr,
             p_bldat       TO t_ok-bldat,
             p_t_lifnr     TO t_ok-lifnr,
             p_zaldt       TO t_ok-zaldt,
             p_znme1       TO t_ok-znme1,
             p_zmot_emis   TO t_ok-zmote.
* fin FCV - 24.04.2010
        APPEND t_ok.
      ENDIF.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " BUSCA_COMPEN
*&---------------------------------------------------------------------*
*&      Form  BUILD2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build2 CHANGING e_object
TYPE REF TO cl_alv_event_toolbar_set.


  CLEAR ls_toolbar.
  ls_toolbar-function = '%ALL'.
  ls_toolbar-icon = 'ICON_CHANGE'.
  ls_toolbar-quickinfo = text-009.
  ls_toolbar-disabled = space.
  APPEND ls_toolbar TO e_object->mt_toolbar.
ENDFORM.                                                    " BUILD2
*&---------------------------------------------------------------------*
*&      Form  EJEC_MAS
*&---------------------------------------------------------------------*
*       text EJECUCION DE PROCESOS MASIVOS.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ejec_mas .
  DATA : namejob(32) TYPE c.
  DATA : pmsgjob(70) TYPE c.
  DATA g_resp.
  IF t_ok IS NOT INITIAL.
*    CALL FUNCTION 'POPUP_TO_CONFIRM'
*      EXPORTING
*        titlebar                    = g_little
**           DIAGNOSE_OBJECT             = ' '
*        text_question               = '¿ Desea Procesar en Forma Masiva ?'
**           TEXT_BUTTON_1               = 'Ja'(001)
**           ICON_BUTTON_1               = ' '
**           TEXT_BUTTON_2               = 'Nein'(002)
**           ICON_BUTTON_2               = ' '
*        default_button              = '2'
**           DISPLAY_CANCEL_BUTTON       = 'X'
**           USERDEFINED_F1_HELP         = ' '
**           START_COLUMN                = 25
**           START_ROW                   = 6
**           POPUP_TYPE                  =
**           IV_QUICKINFO_BUTTON_1       = ' '
**           IV_QUICKINFO_BUTTON_2       = ' '
*     IMPORTING
*       answer                      = g_resp
**         TABLES
**           PARAMETER                   =
**         EXCEPTIONS
**           TEXT_NOT_FOUND              = 1
**           OTHERS                      = 2
*              .
*    IF sy-subrc <> 0.
**         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
    g_resp = '1'.
    IF g_resp EQ '1'. " SI"
*        PERFORM GENE_JUEGO_DATOS.
      PERFORM ejec_submit USING save_code ' ' CHANGING namejob .
      CONCATENATE 'Se ha Generado el JOB : ' namejob   INTO pmsgjob.
      MESSAGE pmsgjob TYPE 'I'.
    ELSEIF g_resp EQ '2'. " NO
      CLEAR t_ok.
      REFRESH t_ok.
    ELSEIF g_resp EQ 'A'. "CANCELAR".
      CLEAR t_ok.
      REFRESH t_ok.
    ENDIF.

  ENDIF.
ENDFORM.                    " EJEC_MAS
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


ENDFORM.                    " DESC_CTA
*&---------------------------------------------------------------------*
*&      Form  PARAMETROS_JDATOS
*&---------------------------------------------------------------------*
FORM parametros_jdatos.
* FCV - 02.05.2010 - Nunca se estaba borrando la tabla
  REFRESH i_tablsubm.
  CLEAR i_tablsubm.
* fin FCV - 02.05.2010
*- Nombre Juego Datos
  i_tablsubm-selname = 'MAPPE'.
  i_tablsubm-kind    = 'P'.
  i_tablsubm-sign    = 'I'.
  i_tablsubm-option  = 'EQ'.
  i_tablsubm-low     = group.
  APPEND i_tablsubm.
*- Fecha Desde
  i_tablsubm-selname = 'VON'.
  i_tablsubm-kind    = 'P'.
  i_tablsubm-sign    = 'I'.
  i_tablsubm-option  = 'EQ'.
  i_tablsubm-low     = sy-datum.
  APPEND i_tablsubm.

*- Checkbox A Procesar
  i_tablsubm-selname = 'Z_VERARB'.
  i_tablsubm-kind    = 'P'.
  i_tablsubm-sign    = 'I'.
  i_tablsubm-option  = 'EQ'.
  i_tablsubm-low     = 'X'.
  APPEND i_tablsubm.

  i_tablsubm-selname = 'FEHLER'.
  i_tablsubm-kind    = 'P'.
  i_tablsubm-sign    = 'I'.
  i_tablsubm-option  = 'EQ'.
  i_tablsubm-low     = space.
  APPEND i_tablsubm.

*- Máquina Destino
  i_tablsubm-selname = 'BATCHSYS'.
  i_tablsubm-kind    = 'P'.
  i_tablsubm-sign    = 'I'.
  i_tablsubm-option  = 'EQ'.
  i_tablsubm-low     = sy-host.
  APPEND i_tablsubm.


ENDFORM.                    " PARAMETROS_JDATOS

*&---------------------------------------------------------------------*
*&      Form  OPEN_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM open_job USING namejob CHANGING jobcount.
*data: G_Job.
*
*CONCATENATE 'MAS' '_'sy-datum '_' sy-uzeit into G_Job.



  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
*   DELANFREP              = ' '
*   JOBGROUP               = ' '
      jobname                = namejob
*   SDLSTRTDT              = NO_DATE
*   SDLSTRTTM              = NO_TIME
*   JOBCLASS               =
   IMPORTING
     jobcount               = jobcount
* CHANGING
*   RET                    =
* EXCEPTIONS
*   CANT_CREATE_JOB        = 1
*   INVALID_JOB_DATA       = 2
*   JOBNAME_MISSING        = 3
*   OTHERS                 = 4
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " OPEN_JOB
*&---------------------------------------------------------------------*
*&      Form  SUBMIT_REPORT
*&---------------------------------------------------------------------*
*       se llama a
*----------------------------------------------------------------------*
*      -->P_SAVE_CODE  text
*----------------------------------------------------------------------*
FORM submit_report  USING    p_save_code  p_chect namejob jobcount.

  IF p_save_code EQ 'PRO_01'.
    SUBMIT zfimrp005
*          WITH PSEL
            WITH s_bukrs EQ bukrs
            WITH s_hbkid EQ hbkid
            WITH s_hktid EQ hktid
            WITH s_pbudat EQ bkpf-budat
            WITH xele EQ 'X'
            VIA JOB namejob NUMBER jobcount AND RETURN.
    .
*          WITH XFIS ...


  ENDIF.

  IF p_save_code EQ 'PRO_04'. "PRESCRIBIR.
    SUBMIT zfimrp005
*          WITH PSEL ...
            WITH s_bukrs EQ bukrs
            WITH s_hbkid EQ hbkid
            WITH s_hktid EQ hktid
            WITH s_motpre EQ 1
            WITH s_pbudat EQ bkpf-budat
*          WITH XELE ...
            WITH xfis EQ 'X'
            VIA JOB namejob NUMBER jobcount AND RETURN.

  ENDIF.

  IF p_save_code EQ 'PRO_08'. "REVERSAR.
    SUBMIT rfchkd30
      WITH par_chkf EQ p_chect
      WITH par_chkt EQ p_chect
      WITH par_hbki EQ hbkid
      WITH par_hkti EQ hktid
      WITH par_xein EQ ' '
      WITH par_xext EQ ' '
      WITH par_xper EQ ' '
      WITH par_xvoi EQ 'X'
      WITH par_zbuk EQ bukrs
      VIA JOB namejob NUMBER jobcount AND RETURN.


  ENDIF.

ENDFORM.                    " SUBMIT_REPORT
*&---------------------------------------------------------------------*
*&      Form  RESC_BLDAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*      -->P_T_PAYR_VBLNR  text
*      -->P_T_BSIS_GJAHR  text
*      <--P_G_BLDAT  text
*----------------------------------------------------------------------*
FORM resc_bldat  USING    p_bukrs
                          p_t_payr_vblnr
                          p_t_bsis_gjahr
                 CHANGING p_g_bldat.
  CLEAR p_g_bldat.

  SELECT SINGLE  bldat INTO p_g_bldat
          FROM bkpf
        WHERE  bukrs EQ p_bukrs
          AND  belnr EQ p_t_payr_vblnr
          AND  gjahr EQ p_t_bsis_gjahr.

  IF sy-subrc EQ 0.

  ENDIF.

ENDFORM.                    " RESC_BLDAT
*&---------------------------------------------------------------------*
*&      Form  EJEC_SUBMIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ejec_submit USING p_save_code p_chect CHANGING namejob.
*  SE CREA NOMBRE JOB

  DATA jobcount LIKE tbtcjob-jobcount.

  CONCATENATE 'MAS' '_'sy-datum '_' sy-uzeit INTO namejob.
*NAMEJOB = 'ZLUIS'.
*  OPEN JOB
  PERFORM open_job USING namejob CHANGING jobcount .
  PERFORM submit_report USING p_save_code p_chect namejob jobcount.
  PERFORM close_job USING namejob jobcount.



ENDFORM.                    " EJEC_SUBMIT
*&---------------------------------------------------------------------*
*&      Form  CLOSE_JOB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAMEJOB  text
*----------------------------------------------------------------------*
FORM close_job  USING    p_namejob jobcount.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
*           AT_OPMODE                         = ' '
*           AT_OPMODE_PERIODIC                = ' '
*           CALENDAR_ID                       = ' '
*           EVENT_ID                          = ' '
*           EVENT_PARAM                       = ' '
*           EVENT_PERIODIC                    = ' '
      jobcount                          = jobcount
      jobname                           = p_namejob
*           LASTSTRTDT                        = NO_DATE
*           LASTSTRTTM                        = NO_TIME
*           PRDDAYS                           = 0
*           PRDHOURS                          = 0
*           PRDMINS                           = 0
*           PRDMONTHS                         = 0
*           PRDWEEKS                          = 0
*           PREDJOB_CHECKSTAT                 = ' '
*           PRED_JOBCOUNT                     = ' '
*           PRED_JOBNAME                      = ' '
*           SDLSTRTDT                         = NO_DATE
*           SDLSTRTTM                         = NO_TIME
*           STARTDATE_RESTRICTION             = BTC_PROCESS_ALWAYS
     strtimmed                         = 'X'
*           TARGETSYSTEM                      = ' '
*           START_ON_WORKDAY_NOT_BEFORE       = SY-DATUM
*           START_ON_WORKDAY_NR               = 0
*           WORKDAY_COUNT_DIRECTION           = 0
*           RECIPIENT_OBJ                     =
*           TARGETSERVER                      = ' '
*           DONT_RELEASE                      = ' '
*           TARGETGROUP                       = ' '
*           DIRECT_START                      =
*         IMPORTING
*           JOB_WAS_RELEASED                  =
*         CHANGING
*           RET                               =
*         EXCEPTIONS
*           CANT_START_IMMEDIATE              = 1
*           INVALID_STARTDATE                 = 2
*           JOBNAME_MISSING                   = 3
*           JOB_CLOSE_FAILED                  = 4
*           JOB_NOSTEPS                       = 5
*           JOB_NOTEX                         = 6
*           LOCK_FAILED                       = 7
*           INVALID_TARGET                    = 8
*           OTHERS                            = 9
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDFORM.                    " CLOSE_JOB
*&---------------------------------------------------------------------*
*&      Form  ANULACION_INDIV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PSEL  text
*      -->P_T_OK  text
*      -->P_BUKRS  text
*      -->P_HBKID  text
*      -->P_HKTID  text
*      -->P_BKPF_BUDAT  text
*----------------------------------------------------------------------*
FORM anulacion_indiv  TABLES   p_psel STRUCTURE psel
                               p_t_ok STRUCTURE t_ok
                      USING    p_bukrs p_hbkid p_hktid p_bkpf_budat.


  DATA: t_payr LIKE payr  OCCURS 0 WITH HEADER LINE.
  DATA: t_bsis LIKE bsis.  "OCCURS 0 WITH HEADER LINE.
  DATA: t_bsas LIKE bsas  OCCURS 0 WITH HEADER LINE.
  DATA: g_hkod LIKE bseg-hkont. "GUARDA CUENTA DE DESTINO"
  DATA: g_sgtxt  LIKE bseg-sgtxt. "ALMACENAMOS EL TEXTO PARA LA POSICION.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_payr
    FROM payr
     WHERE ichec EQ ''
       AND zbukr EQ bukrs
       AND hbkid EQ hbkid
       AND hktid EQ hktid
       AND chect IN psel
       AND zaldt IN pfepag.
  DATA: vnun TYPE n,
         vnun2(9) TYPE c.

  LOOP AT t_payr.
    g_valid_cta = 0.
    REFRESH t_cta.
    vnun = 2.
    DO 7 TIMES.
      ADD 1 TO vnun.
      vnun2 = vnun.
      CONCATENATE t_payr-ubhkt+0(9) vnun2 INTO t_cta-low.
      t_cta-sign = 'I'.
      t_cta-option = 'EQ'.
      APPEND t_cta.
    ENDDO.

*ReSQ: No Need Of Change Internal Table T_CTA Already Sorted
    PERFORM ctas_zcta_prescrip.
    DELETE ADJACENT DUPLICATES FROM t_cta.

*    ASIGNA VALOR A G_HKOD ******************************
*    CONCATENATE T_PAYR-UBHKT+0(9) '7' INTO G_HKOD.
    g_hkod = 'ANULACION'.
*********************************************************
    g_datum = sy-datum.
    CONCATENATE 'Anulación '  ' - '  g_datum INTO g_sgtxt.
    g_little = 'Anulación de Documento'.

    IF t_payr-xbanc = 'X'.
      CLEAR: t_ok.
      des_cta = 'CHEQUE PAGADO'.
      MOVE: t_payr-vblnr TO t_ok-belnr,
            '@0A@'       TO t_ok-status,
            t_payr-zbukr TO t_ok-bukrs,
            t_payr-gjahr  TO t_ok-gjahr,
            t_payr-chect  TO t_ok-chect,
            g_hkod        TO t_ok-hkontd,
            g_sgtxt       TO t_ok-sgtxt,
            t_payr-vblnr  TO t_ok-vblnr,
            des_cta       TO t_ok-estado,
            '--'          TO t_ok-bldat,
            t_payr-lifnr  TO t_ok-lifnr,
            t_payr-zaldt  TO t_ok-zaldt,
            t_payr-znme1  TO t_ok-znme1,
            '--'          TO t_ok-zmote.
      APPEND t_ok.
    ELSE.
      IF t_payr-ubhkt EQ space.
        CLEAR: t_ok.
        PERFORM desc_cta USING '99' CHANGING des_cta.
        IF t_payr-voidr GT 0. " causa de anulacion
          des_cta = 'CHEQUE ANULADO'.
        ENDIF.

        MOVE: t_payr-vblnr TO t_ok-belnr,
              '@0A@'       TO t_ok-status,
              t_payr-zbukr TO t_ok-bukrs,
              t_payr-gjahr  TO t_ok-gjahr,
              t_payr-chect  TO t_ok-chect,
              g_hkod        TO t_ok-hkontd,
              g_sgtxt       TO t_ok-sgtxt,
              t_payr-vblnr  TO t_ok-vblnr,
              des_cta       TO t_ok-estado,
              '--'          TO t_ok-bldat,
              t_payr-lifnr  TO t_ok-lifnr,
              t_payr-zaldt  TO t_ok-zaldt,
              t_payr-znme1  TO t_ok-znme1,
              '--'          TO t_ok-zmote.
      ELSE.

        SELECT SINGLE * INTO CORRESPONDING FIELDS OF  t_bsis
          FROM bsis
           WHERE bukrs EQ t_payr-zbukr
             AND hkont EQ t_payr-ubhkt
             AND gjahr EQ t_payr-gjahr
             AND belnr EQ t_payr-vblnr.
        IF sy-subrc EQ 0.

* Si 	Existe registro, por lo tanto cheque sin compensar, verificar si han pasado los 60 días para caducar
          DATA: datediff  TYPE  p,
          timediff  TYPE  p,
          earliest  TYPE  c.
          DATA: p_kouhr1 TYPE kouhr,
                p_kouhr2 TYPE kouhr.
          p_kouhr1 = sy-uzeit.
          p_kouhr2 =  p_kouhr1.
          CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
            EXPORTING
*          DATE1            = T_BSIS-BLDAT
              date1            = t_bsis-valut
              time1            = p_kouhr1
              date2            = bkpf-budat
              time2            = p_kouhr2
            IMPORTING
              datediff         = datediff
              timediff         = timediff
              earliest         = earliest
            EXCEPTIONS
              invalid_datetime = 1
              OTHERS           = 2.
          IF sy-subrc EQ 0.
            PERFORM desc_cta USING t_bsis-hkont+9(1) CHANGING des_cta .

* Si diferencia de fechas es menos a 60 doias no se podra caducar.
*        IF DATEDIFF >= 60.
            CLEAR: t_ok.
******** SE RESCATA BLDAT *****************************.
            CLEAR g_bldat.
            PERFORM  resc_bldat USING bukrs t_payr-vblnr t_bsis-gjahr
                                CHANGING g_bldat.
******** Validacion de cuenta **************************
            PERFORM valid_cta  USING t_bsis-hkont+9(1)  save_code
                            CHANGING g_valid_cta.
********************************************************
            PERFORM  zmot_emis USING bukrs  t_bsis-belnr t_bsis-gjahr
                               CHANGING p_zmot_emis.
**************************************************************************

            IF earliest EQ 2.
              datediff = datediff * -1.
*          des_cta = g_desf.
* FCV - 06.07.2010 - Se debe permitir la anulación de dìas negativos
*          g_valid_cta = 1.
* fin FCV - 06.07.2010 - Se debe permitir la anulación de dìas negativos
            ENDIF.
            IF t_payr-voidr GT 0. " causa de anulacion
              des_cta = 'CHEQUE ANULADO'.
              g_valid_cta = 1.
            ENDIF.

            MOVE: t_bsis-belnr TO t_ok-belnr.

            IF g_valid_cta EQ 1.
              MOVE '@0A@'    TO t_ok-status. " ICONO MAL
            ELSE.
              MOVE '@08@'    TO t_ok-status. " ICONO BIEN
            ENDIF.

            MOVE: t_bsis-bukrs TO t_ok-bukrs,
             t_bsis-buzei  TO t_ok-buzei,
             t_bsis-gjahr  TO t_ok-gjahr,
             t_bsis-hkont  TO t_ok-hkont,
             t_bsis-wrbtr  TO t_ok-wrbtr,
             t_payr-chect  TO t_ok-chect,
             g_hkod        TO t_ok-hkontd,
             g_sgtxt       TO t_ok-sgtxt,
             datediff      TO t_ok-datev,
             des_cta       TO t_ok-estado,
             t_payr-vblnr  TO t_ok-vblnr,
             g_bldat       TO t_ok-bldat,
             t_payr-lifnr  TO t_ok-lifnr,
             t_bsis-bldat  TO t_ok-bldat,
             t_payr-zaldt  TO t_ok-zaldt,
             t_payr-znme1  TO t_ok-znme1,
             p_zmot_emis   TO t_ok-zmote.

            APPEND t_ok.
          ENDIF.
        ELSE.
* Si registro no existe, buscarlo en tabla de compensados (BSAS)
          SELECT * INTO CORRESPONDING FIELDS OF TABLE t_bsas
            FROM bsas
             WHERE bukrs EQ t_payr-zbukr
               AND hkont EQ t_payr-ubhkt
               AND gjahr EQ t_payr-gjahr
               AND belnr EQ t_payr-vblnr.

          LOOP AT t_bsas.
            CLEAR t_ok.
            PERFORM busca_compen  TABLES t_cta
                                          t_ok
                                   USING  t_bsas-bukrs  t_bsas-augbl g_hkod g_sgtxt t_payr-voidr
                                          t_payr-vblnr t_payr-lifnr t_payr-gjahr t_payr-chect t_payr-zaldt
                                          t_payr-znme1.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.



ENDFORM.                    " ANULACION_INDIV
*&---------------------------------------------------------------------*
*&      Form  PRESCRIPCION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PSEL  text
*      -->P_T_OK  text
*      -->P_BUKRS  text
*      -->P_HBKID  text
*      -->P_HKTID  text
*      -->P_BKPF_BUDAT  text
*----------------------------------------------------------------------*
FORM prescripcion  TABLES   p_psel STRUCTURE psel
                              "Insertar nombre correcto para <...>
                            p_t_ok STRUCTURE t_ok
                   USING    p_bukrs
                            p_hbkid
                            p_hktid
                            p_bkpf_budat.


  TABLES: zrangos_prescri.

  DATA: t_payr LIKE payr  OCCURS 0 WITH HEADER LINE.
  DATA: t_bsis LIKE bsis  ."OCCURS 0 WITH HEADER LINE.
  DATA: t_bsas LIKE bsas  OCCURS 0 WITH HEADER LINE.
  DATA: g_hkod LIKE bseg-hkont. "GUARDA CUENTA DE DESTINO"
  DATA: g_sgtxt  LIKE bseg-sgtxt. "ALMACENAMOS EL TEXTO PARA LA POSICION.
  DATA: difdias(6) TYPE n,
        v_index LIKE sy-tabix.
  DATA: vnun TYPE n,
        vnun2(9) TYPE c.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_payr
    FROM payr
     WHERE ichec EQ ''
       AND zbukr EQ bukrs
       AND hbkid EQ hbkid
       AND hktid EQ hktid
       AND chect IN psel
       AND zaldt IN pfepag.

** Modificado por L_FOUBERT 03.06.2013 Consulta BSIS Mejorada.
*        REFRESH: t2_bsis, t2_bsas.
*        SELECT  bukrs  hkont belnr gjahr buzei bldat wrbtr
*          INTO TABLE t2_bsis
*          FROM bsis
*          FOR ALL ENTRIES IN t_payr
*           WHERE bukrs EQ t_payr-zbukr
*             AND hkont EQ t_payr-ubhkt
*             AND gjahr EQ t_payr-gjahr
*             AND belnr EQ t_payr-vblnr.
** END L_FOUBERT 03.06.2013 Consulta BSIS Mejorada.
  LOOP AT t_payr.
*    g_valid_cta = 0.
    REFRESH t_cta.
    vnun = 5.
    DO 2 TIMES.
      ADD 1 TO vnun.
      vnun2 = vnun.
      CONCATENATE t_payr-ubhkt+0(9) vnun2 INTO t_cta-low.
      t_cta-sign = 'I'.
      t_cta-option = 'EQ'.
      APPEND t_cta.

      IF vnun2 EQ 7.
        vnun = 8.
      ENDIF.
    ENDDO.


*    ASIGNA VALOR A G_HKOD ******************************
*    CONCATENATE T_PAYR-UBHKT+0(9) '7' INTO G_HKOD.
*    se buscara en tabla : CTA_PRESCRIPCION la cuenta de destino
*

*********************************************************
    CONCATENATE 'Prescribir'  ' - '  sy-datum INTO g_sgtxt.
    g_little = 'Prescribir'.

    IF t_payr-xbanc = 'X'.
      CLEAR: t_ok.
      des_cta = 'CHEQUE PAGADO'.

      MOVE: t_payr-vblnr TO t_ok-belnr,
            '@0A@'       TO t_ok-status,
            t_payr-zbukr TO t_ok-bukrs,
            t_payr-gjahr  TO t_ok-gjahr,
            t_payr-chect  TO t_ok-chect,
            g_hkod        TO t_ok-hkontd,
            g_sgtxt       TO t_ok-sgtxt,
            t_payr-vblnr  TO t_ok-vblnr,
            des_cta       TO t_ok-estado.
      APPEND t_ok.
    ELSE.
      IF t_payr-ubhkt EQ space.
        CLEAR: t_ok.
        PERFORM desc_cta USING '99' CHANGING des_cta.
        IF t_payr-voidr GT 0. " causa de anulacion
          des_cta = 'CHEQUE ANULADO'.
        ENDIF.

        MOVE: t_payr-vblnr TO t_ok-belnr,
              '@0A@'       TO t_ok-status,
              t_payr-zbukr TO t_ok-bukrs,
              t_payr-gjahr  TO t_ok-gjahr,
              t_payr-chect  TO t_ok-chect,
              g_hkod        TO t_ok-hkontd,
              g_sgtxt       TO t_ok-sgtxt,
              t_payr-vblnr  TO t_ok-vblnr,
              des_cta       TO t_ok-estado.
        APPEND t_ok.
      ELSE.
*** Modificado por L_FOUBERT 03.06.2013  Consulta BSIS.
        SELECT SINGLE * INTO CORRESPONDING FIELDS OF  t_bsis
          FROM bsis
           WHERE bukrs EQ t_payr-zbukr
             AND hkont EQ t_payr-ubhkt
             AND gjahr EQ t_payr-gjahr
             AND belnr EQ t_payr-vblnr.
*       READ TABLE  t2_bsis WITH KEY bukrs = t_payr-zbukr
*                                   hkont = t_payr-ubhkt
*                                   gjahr = t_payr-gjahr
*                                   belnr = t_payr-vblnr.
** END L_FOUBERT 03.06.2013 Consulta BSIS
        IF sy-subrc EQ 0.
* FCV - 28.04.2010
          PERFORM  zmot_emis USING t_payr-zbukr  t_bsis-belnr t_bsis-gjahr
                             CHANGING p_zmot_emis.
* fin FCV - 28.04.2010
* Si 	Existe registro, por lo tanto cheque sin compensar, verificar si han pasado los 60 días para caducar
          DATA: datediff  TYPE  p,
          timediff  TYPE  p,
          earliest  TYPE  c.
          DATA: p_kouhr1 TYPE kouhr,
                p_kouhr2 TYPE kouhr.
          p_kouhr1 = sy-uzeit.
          p_kouhr2 =  p_kouhr1.

          CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
            EXPORTING
              date1            = t_bsis-bldat
              time1            = p_kouhr1
              date2            = bkpf-budat
              time2            = p_kouhr2
            IMPORTING
              datediff         = datediff
              timediff         = timediff
              earliest         = earliest
            EXCEPTIONS
              invalid_datetime = 1
              OTHERS           = 2.

          IF sy-subrc EQ 0.
            PERFORM desc_cta USING t_bsis-hkont+9(1) CHANGING des_cta .
            IF earliest EQ 2.
              datediff = datediff * -1.
*          des_cta = g_desf.
            ENDIF.

* FCV - 19.07.2010 - Se revisa si corresponde a glosa de anulaciòn
            IF t_payr-voidr GT 0. " causa de anulacion
              des_cta = 'CHEQUE ANULADO'.
            ENDIF.
* fin FCV - 19.07.2010

* Si diferencia de fechas es menos a 60 doias no se podra caducar.
            IF datediff >= 60.
              CLEAR: t_ok.
              t_ok-zmote = p_zmot_emis.

******** SE RESCATA BLDAT *****************************.
              CLEAR g_bldat.
              PERFORM  resc_bldat USING bukrs t_payr-vblnr t_bsis-gjahr
                                  CHANGING g_bldat.
******** Validacion de cuenta **************************
              PERFORM valid_cta  USING t_bsis-hkont+9(1)  save_code
                              CHANGING g_valid_cta.
********************************************************

              MOVE: t_bsis-belnr TO t_ok-belnr.
              IF g_valid_cta EQ 1.
                MOVE '@0A@'    TO t_ok-status. " ICONO MAL
              ELSE.
                MOVE '@08@'    TO t_ok-status. " ICONO BIEN
              ENDIF.

              MOVE: t_bsis-bukrs TO t_ok-bukrs,
               t_bsis-buzei  TO t_ok-buzei,
               t_bsis-gjahr  TO t_ok-gjahr,
               t_bsis-hkont  TO t_ok-hkont,
               t_bsis-wrbtr  TO t_ok-wrbtr,
               t_payr-chect  TO t_ok-chect,
               g_hkod        TO t_ok-hkontd,
               g_sgtxt       TO t_ok-sgtxt,
               datediff      TO t_ok-datev,
               des_cta       TO t_ok-estado,
               t_payr-vblnr  TO t_ok-vblnr,
* FCV - 28.04.2010
               t_payr-zaldt  TO t_ok-zaldt,
               t_payr-znme1  TO t_ok-znme1,
* fin FCV - 28.04.2010
               g_bldat       TO t_ok-bldat.
            ELSE.
              CLEAR: t_ok.
              MOVE: t_bsis-belnr TO t_ok-belnr,
              '@0A@'    TO t_ok-status,
              t_bsis-bukrs TO t_ok-bukrs,
              t_bsis-buzei TO t_ok-buzei,
              t_bsis-gjahr TO t_ok-gjahr,
              t_bsis-hkont TO t_ok-hkont,
              t_bsis-wrbtr TO t_ok-wrbtr,
              t_payr-chect TO t_ok-chect,
              g_hkod       TO t_ok-hkontd,
              g_sgtxt      TO t_ok-sgtxt,
              datediff     TO t_ok-datev,
              des_cta      TO t_ok-estado,
* FCV - 28.04.2010
              t_payr-zaldt TO t_ok-zaldt,
              t_payr-znme1 TO t_ok-znme1,
* fin FCV - 28.04.2010
              t_payr-vblnr TO t_ok-vblnr.
            ENDIF.
            APPEND t_ok.
          ENDIF.
        ELSE.
* Si registro no existe, buscarlo en tabla de compensados (BSAS)
** Modificado por L_FOUBERT 03.06.2013 Consulta BSAS.
          SELECT * INTO CORRESPONDING FIELDS OF TABLE t_bsas
            FROM bsas
             WHERE bukrs EQ t_payr-zbukr
               AND hkont EQ t_payr-ubhkt
               AND gjahr EQ t_payr-gjahr
               AND belnr EQ t_payr-vblnr.
*          SELECT bukrs hkont augbl belnr gjahr
*          INTO TABLE t2_bsas
*           FROM bsas
*            WHERE bukrs EQ t_payr-zbukr
*               AND hkont EQ t_payr-ubhkt
*              AND gjahr EQ t_payr-gjahr
*              AND belnr EQ t_payr-vblnr.
** END L_FOUBERT 03.06.2013 Consulta BSAS.
          LOOP AT t_bsas.
            CLEAR t_ok.
            PERFORM busca_compen  TABLES t_cta
                                          t_ok
                                   USING  t_bsas-bukrs  t_bsas-augbl g_hkod g_sgtxt t_payr-voidr
                                          t_payr-vblnr t_payr-lifnr t_payr-gjahr t_payr-chect t_payr-zaldt
                                          t_payr-znme1.
          ENDLOOP.          " comentado L_FOUBERT
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
* FCV - 22.04.2010
* Se revisa el motivo de compensación v/s los días que lleva el documento
* fin FCV - 22.04.2010
  LOOP AT t_ok.
    v_index = sy-tabix.

* FCV - 28.08.2010 - Se determina la fecha de emisión
    IF save_code = 'PRO_04'.
      SELECT SINGLE * FROM zprescribe_fecha
        WHERE bukrs = t_ok-bukrs
          AND hbkid = hbkid
          AND hktid = hktid
          AND chect = t_ok-chect.

      IF sy-subrc EQ 0.
        t_ok-zaldt = zprescribe_fecha-fecemi.
        MODIFY t_ok INDEX v_index.
      ENDIF.

* FCV - 08.09.2010
      CLEAR difdias.
      difdias = sy-datum - t_ok-zaldt.
      TRANSLATE t_ok-zmote TO UPPER CASE.

      SELECT SINGLE * FROM zrangos_prescri
        WHERE motivoemision = t_ok-zmote.

      IF sy-subrc EQ 0.
        IF difdias >= zrangos_prescri-dias.
          MOVE '@08@'    TO t_ok-status. " ICONO BIEN
        ELSE.
          MOVE '@0A@'    TO t_ok-status. " ICONO MAL
        ENDIF.
        t_ok-datev = difdias.
      ELSE.
        t_ok-datev = difdias.
        MOVE '@0A@'    TO t_ok-status. " ICONO MAL
      ENDIF.
      MODIFY t_ok INDEX v_index.
    ENDIF.
* fin FCV - 08.09.2010
* Se consideran sólo status CADUCO ELECTRONICO y FISICO
    IF t_ok-estado CS 'CADUCADO FÍSICO' OR
       t_ok-estado CS 'CADUCADO ELECTR'.

* Se busca la cuenta destino que se debe utilizar
      SELECT SINGLE cuenta_p INTO g_hkod
      FROM zcta_prescrip
      WHERE t_cuenta = 4.

      IF sy-subrc EQ 0.
        t_ok-hkontd = g_hkod.
      ENDIF.

      CLEAR difdias.
      difdias = sy-datum - t_ok-zaldt.
      TRANSLATE t_ok-zmote TO UPPER CASE.

      SELECT SINGLE * FROM zrangos_prescri
        WHERE motivoemision = t_ok-zmote.

      IF sy-subrc EQ 0.
        IF difdias >= zrangos_prescri-dias.
          MOVE '@08@'    TO t_ok-status. " ICONO BIEN
        ELSE.
          MOVE '@0A@'    TO t_ok-status. " ICONO MAL
        ENDIF.
        t_ok-datev = difdias.
      ELSE.
        MOVE '@0A@'    TO t_ok-status. " ICONO MAL
      ENDIF.
      MODIFY t_ok INDEX v_index.
    ELSE.
*      DELETE t_ok INDEX v_index.
      MOVE '@0A@'    TO t_ok-status. " ICONO MAL
      MODIFY t_ok INDEX v_index.
    ENDIF.

  ENDLOOP.
ENDFORM.                    " PRESCRIPCION
*&---------------------------------------------------------------------*
*&      Form  REVALIDAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PSEL  text
*      -->P_T_OK  text
*      -->P_BUKRS  text
*      -->P_HBKID  text
*      -->P_HKTID  text
*      -->P_BKPF_BUDAT  text
*----------------------------------------------------------------------*
FORM revalidar  TABLES   p_psel STRUCTURE psel
                           "Insertar nombre correcto para <...>
                         p_t_ok STRUCTURE t_ok
                USING    p_bukrs
                         p_hbkid
                         p_hktid
                         p_bkpf_budat.


  DATA: t_payr LIKE payr  OCCURS 0 WITH HEADER LINE.
  DATA: t_bsis LIKE bsis.  "OCCURS 0 WITH HEADER LINE.
  DATA: t_bsas LIKE bsas  OCCURS 0 WITH HEADER LINE.
  DATA: g_hkod LIKE bseg-hkont. "GUARDA CUENTA DE DESTINO"
  DATA: g_sgtxt  LIKE bseg-sgtxt. "ALMACENAMOS EL TEXTO PARA LA POSICION.
  DATA v_index LIKE sy-tabix.
  DATA: p_motemis TYPE ZZMOT_EMIS. " variable para maternales 02042012 HC

  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_payr
    FROM payr
     WHERE ichec EQ ''
       AND zbukr EQ bukrs
       AND hbkid EQ hbkid
       AND hktid EQ hktid
       AND chect IN psel
       AND zaldt IN pfepag.
  DATA: vnun TYPE n,
        vnun2(9) TYPE c.

  LOOP AT t_payr.
    g_valid_cta = 0.
    REFRESH t_cta.
    vnun = 5.
    DO 3 TIMES.
      ADD 1 TO vnun.
      vnun2 = vnun.
      CONCATENATE t_payr-ubhkt+0(9) vnun2 INTO t_cta-low.
      t_cta-sign = 'I'.
      t_cta-option = 'EQ'.
      APPEND t_cta.

      IF vnun2 EQ 7.
        vnun = 8.
      ENDIF.
    ENDDO.

    PERFORM ctas_zcta_prescrip.
*ReSQ: No Need Of Change Internal Table T_CTA Already Sorted
    DELETE ADJACENT DUPLICATES FROM t_cta.

*    ASIGNA VALOR A G_HKOD ******************************
    CONCATENATE t_payr-ubhkt+0(9) '9' INTO g_hkod.
*********************************************************
    CONCATENATE 'Revalidación'  ' - '  sy-datum INTO g_sgtxt.
    g_little = 'Revalidación'.

    IF t_payr-xbanc = 'X'.
      CLEAR: t_ok.
      des_cta = 'CHEQUE PAGADO'.

      MOVE: t_payr-vblnr TO t_ok-belnr,
            '@0A@'       TO t_ok-status,
            t_payr-zbukr TO t_ok-bukrs,
            t_payr-gjahr  TO t_ok-gjahr,
            t_payr-chect  TO t_ok-chect,
            g_hkod        TO t_ok-hkontd,
            g_sgtxt       TO t_ok-sgtxt,
            t_payr-vblnr  TO t_ok-vblnr,
            des_cta       TO t_ok-estado,
            '--'          TO t_ok-bldat,
            t_payr-zaldt  TO t_ok-zaldt,
            t_payr-znme1  TO t_ok-znme1,
            '--'          TO t_ok-zmote.
      APPEND t_ok.
    ELSE.
      IF t_payr-ubhkt EQ space.
        CLEAR: t_ok.
        PERFORM desc_cta USING '99' CHANGING des_cta.
        IF t_payr-voidr GT 0. " causa de anulacion
          des_cta = 'CHEQUE ANULADO'.
        ENDIF.

        MOVE: t_payr-vblnr TO t_ok-belnr,
              '@0A@'       TO t_ok-status,
              t_payr-zbukr TO t_ok-bukrs,
              t_payr-gjahr  TO t_ok-gjahr,
              t_payr-chect  TO t_ok-chect,
              g_hkod        TO t_ok-hkontd,
              g_sgtxt       TO t_ok-sgtxt,
              t_payr-vblnr  TO t_ok-vblnr,
              des_cta       TO t_ok-estado,
              '--'          TO t_ok-bldat,
              t_payr-zaldt  TO t_ok-zaldt,
              t_payr-znme1  TO t_ok-znme1,
              '--'          TO t_ok-zmote.
        APPEND t_ok.
      ELSE.

        SELECT SINGLE * INTO CORRESPONDING FIELDS OF  t_bsis
          FROM bsis
           WHERE bukrs EQ t_payr-zbukr
             AND hkont EQ t_payr-ubhkt
             AND gjahr EQ t_payr-gjahr
             AND belnr EQ t_payr-vblnr.
        IF sy-subrc EQ 0.

* Si 	Existe registro, por lo tanto cheque sin compensar, verificar si han pasado los 60 días para caducar
          DATA: datediff  TYPE  p,
          timediff  TYPE  p,
          earliest  TYPE  c.
          DATA: p_kouhr1 TYPE kouhr,
                p_kouhr2 TYPE kouhr.
          p_kouhr1 = sy-uzeit.
          p_kouhr2 =  p_kouhr1.
          CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
            EXPORTING
*          DATE1            = T_BSIS-BLDAT
              date1            = t_bsis-valut
              time1            = p_kouhr1
              date2            = bkpf-budat
              time2            = p_kouhr2
            IMPORTING
              datediff         = datediff
              timediff         = timediff
              earliest         = earliest
            EXCEPTIONS
              invalid_datetime = 1
              OTHERS           = 2.
          IF sy-subrc EQ 0.
            PERFORM desc_cta USING t_bsis-hkont+9(1) CHANGING des_cta .
            IF earliest EQ 2.
              datediff = datediff * -1.
*          des_cta = g_desf.
            ENDIF.

* FCV - 19.07.2010 - Se revisa si corresponde a glosa de anulaciòn
            IF t_payr-voidr GT 0. " causa de anulacion
              des_cta = 'CHEQUE ANULADO'.
            ENDIF.
* fin FCV - 19.07.2010

* Si diferencia de fechas es menos a 60 doias no se podra caducar.
            IF datediff >= 0.
              CLEAR: t_ok.

******** SE RESCATA BLDAT *****************************.
              CLEAR g_bldat.
              PERFORM  resc_bldat USING bukrs t_payr-vblnr t_bsis-gjahr
                                  CHANGING g_bldat.
******** Validacion de cuenta **************************
              PERFORM valid_cta  USING t_bsis-hkont+9(1)  save_code
                              CHANGING g_valid_cta.
********************************************************
              PERFORM  zmot_emis USING bukrs  t_bsis-belnr t_bsis-gjahr
                                 CHANGING p_zmot_emis.
**************************************************************************

              MOVE: t_bsis-belnr TO t_ok-belnr.
              IF g_valid_cta EQ 1.
                MOVE '@0A@'    TO t_ok-status. " ICONO MAL
              ELSE.
                MOVE '@08@'    TO t_ok-status. " ICONO BIEN
              ENDIF.

              MOVE: t_bsis-bukrs TO t_ok-bukrs,
               t_bsis-buzei  TO t_ok-buzei,
               t_bsis-gjahr  TO t_ok-gjahr,
               t_bsis-hkont  TO t_ok-hkont,
               t_bsis-wrbtr  TO t_ok-wrbtr,
               t_payr-chect  TO t_ok-chect,
               g_hkod        TO t_ok-hkontd,
               g_sgtxt       TO t_ok-sgtxt,
               datediff      TO t_ok-datev,
               des_cta       TO t_ok-estado,
               t_payr-vblnr  TO t_ok-vblnr,
               g_bldat       TO t_ok-bldat,
               t_payr-zaldt  TO t_ok-zaldt,
               t_payr-znme1  TO t_ok-znme1,
               p_zmot_emis   TO t_ok-zmote.
            ELSE.
              CLEAR: t_ok.
              MOVE: t_bsis-belnr TO t_ok-belnr,
              '@0A@'    TO t_ok-status,
              t_bsis-bukrs TO t_ok-bukrs,
              t_bsis-buzei TO t_ok-buzei,
              t_bsis-gjahr TO t_ok-gjahr,
              t_bsis-hkont TO t_ok-hkont,
              t_bsis-wrbtr TO t_ok-wrbtr,
              t_payr-chect TO t_ok-chect,
              g_hkod       TO t_ok-hkontd,
              g_sgtxt      TO t_ok-sgtxt,
              datediff     TO t_ok-datev,
              des_cta      TO t_ok-estado,
              t_payr-vblnr TO t_ok-vblnr,
              g_bldat      TO t_ok-bldat,
              t_payr-zaldt TO t_ok-zaldt,
              t_payr-znme1 TO t_ok-znme1,
              p_zmot_emis  TO t_ok-zmote.
            ENDIF.
            APPEND t_ok.
          ENDIF.
        ELSE.
* Si registro no existe, buscarlo en tabla de compensados (BSAS)
          SELECT * INTO CORRESPONDING FIELDS OF TABLE t_bsas
            FROM bsas
             WHERE bukrs EQ t_payr-zbukr
               AND hkont EQ t_payr-ubhkt
               AND gjahr EQ t_payr-gjahr
               AND belnr EQ t_payr-vblnr.

          LOOP AT t_bsas.
            CLEAR t_ok.
            PERFORM busca_compen  TABLES t_cta
                                          t_ok
                                   USING  t_bsas-bukrs  t_bsas-augbl g_hkod g_sgtxt t_payr-voidr
                                          t_payr-vblnr t_payr-lifnr t_payr-gjahr t_payr-chect t_payr-zaldt
                                          t_payr-znme1.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT t_ok.
    v_index = sy-tabix.
    v_puntero = v_index.
    TRANSLATE t_ok-zmote TO UPPER CASE.
*    ********************************
*     HCASTILLO 30 Marzo 2012
*    ********************************

    SELECT SINGLE ZZMOT_EMIS
    INTO  p_motemis
    FROM  ZTIPCHEQUEMAT
    WHERE BUKRS      EQ t_ok-bukrs
      AND ZZMOT_EMIS EQ t_ok-zmote.
*    ********************************
*     FIN HCASTILLO 30 Marzo 2012
*    ********************************

*    IF t_ok-status <> '@0A@' AND t_ok-zmote = 'SUBMATERNA'.  " No se permite revalidar el motivo cambio HCD 02042012
    IF t_ok-status <> '@0A@' AND sy-subrc = 0.
      t_ok-status =  '@0A@'.
      MODIFY t_ok INDEX v_index.
    ENDIF.
* FCV - 30.07.2010 - Se rescata agencia
    PERFORM rescata_agencia.
* fin FCV - 30.07.2010 - Se rescata agencia

* FCV - 15.08.2010 - Para el caso de la Revalidación, no se pueden revalidar Caducados electrónicos
    IF save_code = 'PRO_05'.
      IF t_ok-estado CS 'CADUCADO ELECTR' AND t_ok-status = '@08@'.
        MOVE '@0A@' TO t_ok-status. " ICONO MAL
        MODIFY t_ok INDEX v_index.
      ENDIF.
    ENDIF.
* fin FCV - 15.08.2010
  ENDLOOP.
ENDFORM.                    " REVALIDAR
*&---------------------------------------------------------------------*
*&      Form  REVALIDARCHNEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PSEL  text
*      -->P_T_OK  text
*      -->P_BUKRS  text
*      -->P_HBKID  text
*      -->P_HKTID  text
*      -->P_BKPF_BUDAT  text
*----------------------------------------------------------------------*
FORM revalidarchnew  TABLES   p_psel STRUCTURE psel
                               p_t_ok STRUCTURE t_ok
                      USING    p_bukrs p_hbkid p_hktid p_bkpf_budat.


  DATA: t_payr LIKE payr  OCCURS 0 WITH HEADER LINE.
  DATA: t_bsis LIKE bsis.  "OCCURS 0 WITH HEADER LINE.
  DATA: t_bsas LIKE bsas  OCCURS 0 WITH HEADER LINE.
  DATA: g_hkod LIKE bseg-hkont. "GUARDA CUENTA DE DESTINO"
  DATA: g_sgtxt  LIKE bseg-sgtxt. "ALMACENAMOS EL TEXTO PARA LA POSICION.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_payr
    FROM payr
     WHERE ichec EQ ''
       AND zbukr EQ bukrs
       AND hbkid EQ hbkid
       AND hktid EQ hktid
       AND chect IN psel
       AND zaldt IN pfepag.
  DATA: vnun TYPE n,
        vnun2(9) TYPE c.

  LOOP AT t_payr.
    g_valid_cta = 0.
    REFRESH t_cta.
    vnun = 2.
    DO 7 TIMES.
      ADD 1 TO vnun.
      vnun2 = vnun.
      CONCATENATE t_payr-ubhkt+0(9) vnun2 INTO t_cta-low.
      t_cta-sign = 'I'.
      t_cta-option = 'EQ'.
      APPEND t_cta.
    ENDDO.
    PERFORM ctas_zcta_prescrip.
*ReSQ: No Need Of Change Internal Table T_CTA Already Sorted
    DELETE ADJACENT DUPLICATES FROM t_cta.

*    ASIGNA VALOR A G_HKOD ******************************
*    CONCATENATE T_PAYR-UBHKT+0(9) '7' INTO G_HKOD.
*   SE DEBE TRAER CUENTA DE TABLA ZCTA_PRESCRIP.

    SELECT SINGLE cuenta_p
      FROM zcta_prescrip
      INTO g_hkod
     WHERE t_cuenta EQ 6.

*********************************************************
    CONCATENATE 'Cambio Cheque '  ' - '  sy-datum INTO g_sgtxt.
    g_little = 'Cambio Cheque'.
    IF t_payr-xbanc = 'X'.
      CLEAR: t_ok.
      des_cta = 'CHEQUE PAGADO'.
      MOVE: t_payr-vblnr TO t_ok-belnr,
            '@0A@'       TO t_ok-status,
            t_payr-zbukr TO t_ok-bukrs,
            t_payr-gjahr  TO t_ok-gjahr,
            t_payr-chect  TO t_ok-chect,
            g_hkod        TO t_ok-hkontd,
            g_sgtxt       TO t_ok-sgtxt,
            t_payr-vblnr  TO t_ok-vblnr,
            des_cta       TO t_ok-estado,
            t_payr-lifnr  TO t_ok-lifnr,
            '--'          TO t_ok-bldat,
            t_payr-zaldt  TO t_ok-zaldt,
            t_payr-znme1  TO t_ok-znme1,
            '--'          TO t_ok-zmote.
      APPEND t_ok.
    ELSE.
      IF t_payr-ubhkt EQ space.
        CLEAR: t_ok.
        PERFORM desc_cta USING '99' CHANGING des_cta.
        IF t_payr-voidr GT 0. " causa de anulacion
          des_cta = 'CHEQUE ANULADO'.
        ENDIF.

        MOVE: t_payr-vblnr TO t_ok-belnr,
              '@0A@'       TO t_ok-status,
              t_payr-zbukr TO t_ok-bukrs,
              t_payr-gjahr  TO t_ok-gjahr,
              t_payr-chect  TO t_ok-chect,
              g_hkod        TO t_ok-hkontd,
              g_sgtxt       TO t_ok-sgtxt,
              t_payr-vblnr  TO t_ok-vblnr,
              des_cta       TO t_ok-estado,
              t_payr-lifnr  TO t_ok-lifnr,
              '--'          TO t_ok-bldat,
              t_payr-zaldt  TO t_ok-zaldt,
              t_payr-znme1  TO t_ok-znme1,
              '--'          TO t_ok-zmote.
        APPEND t_ok.
      ELSE.
        SELECT SINGLE * INTO CORRESPONDING FIELDS OF  t_bsis
          FROM bsis
           WHERE bukrs EQ t_payr-zbukr
             AND hkont EQ t_payr-ubhkt
             AND gjahr EQ t_payr-gjahr
             AND belnr EQ t_payr-vblnr.
        IF sy-subrc EQ 0.

* Si 	Existe registro, por lo tanto cheque sin compensar, verificar si han pasado los 60 días para caducar
          DATA: datediff  TYPE  p,
          timediff  TYPE  p,
          earliest  TYPE  c.
          DATA: p_kouhr1 TYPE kouhr,
                p_kouhr2 TYPE kouhr.
          p_kouhr1 = sy-uzeit.
          p_kouhr2 =  p_kouhr1.
          CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
            EXPORTING
*          DATE1            = T_BSIS-BLDAT
              date1            = t_bsis-valut
              time1            = p_kouhr1
              date2            = bkpf-budat
              time2            = p_kouhr2
            IMPORTING
              datediff         = datediff
              timediff         = timediff
              earliest         = earliest
            EXCEPTIONS
              invalid_datetime = 1
              OTHERS           = 2.
          IF sy-subrc EQ 0.
            PERFORM desc_cta USING t_bsis-hkont+9(1) CHANGING des_cta .

* Si diferencia de fechas es menos a 60 doias no se podra caducar.
*        IF DATEDIFF >= 60.
            CLEAR: t_ok.
******** SE RESCATA BLDAT *****************************.
            CLEAR g_bldat.
            PERFORM  resc_bldat USING bukrs t_payr-vblnr t_bsis-gjahr
                                CHANGING g_bldat.
******** Validacion de cuenta **************************
            PERFORM valid_cta  USING t_bsis-hkont+9(1)  save_code
                            CHANGING g_valid_cta.
********************************************************
            PERFORM  zmot_emis USING bukrs  t_bsis-belnr t_bsis-gjahr
                               CHANGING p_zmot_emis.
**************************************************************************
            IF earliest EQ 2.
              datediff = datediff * -1.
*          des_cta = g_desf.
              g_valid_cta = 1.
            ENDIF.
            IF t_payr-voidr GT 0. " causa de anulacion
              des_cta = 'CHEQUE ANULADO'.
              g_valid_cta = 1.
            ENDIF.

            LOOP AT ti_zctap WHERE cuenta_p EQ t_bsis-hkont.
              des_cta = ti_zctap-descripcion.
            ENDLOOP.

            MOVE: t_bsis-belnr TO t_ok-belnr.
            IF g_valid_cta EQ 1.
              MOVE '@0A@'    TO t_ok-status. " ICONO MAL
            ELSE.
              MOVE '@08@'    TO t_ok-status. " ICONO BIEN
            ENDIF.

            MOVE: t_bsis-bukrs TO t_ok-bukrs,
             t_bsis-buzei  TO t_ok-buzei,
             t_bsis-gjahr  TO t_ok-gjahr,
             t_bsis-hkont  TO t_ok-hkont,
             t_bsis-wrbtr  TO t_ok-wrbtr,
             t_payr-chect  TO t_ok-chect,
             g_hkod        TO t_ok-hkontd,
             g_sgtxt       TO t_ok-sgtxt,
             datediff      TO t_ok-datev,
             des_cta       TO t_ok-estado,
             t_payr-vblnr  TO t_ok-vblnr,
             g_bldat       TO t_ok-bldat,
             t_payr-lifnr  TO t_ok-lifnr,
             t_payr-zaldt  TO t_ok-zaldt,
             t_payr-znme1  TO t_ok-znme1,
             p_zmot_emis   TO t_ok-zmote.
            APPEND t_ok.
          ENDIF.
        ELSE.
* Si registro no existe, buscarlo en tabla de compensados (BSAS)
          SELECT * INTO CORRESPONDING FIELDS OF TABLE t_bsas
            FROM bsas
             WHERE bukrs EQ t_payr-zbukr
               AND hkont EQ t_payr-ubhkt
               AND gjahr EQ t_payr-gjahr
               AND belnr EQ t_payr-vblnr.

          LOOP AT t_bsas.
            CLEAR: t_ok, wa_payr.
            wa_payr = t_payr.
            PERFORM busca_compen  TABLES t_cta
                                          t_ok
                                   USING  t_bsas-bukrs  t_bsas-augbl g_hkod g_sgtxt t_payr-voidr
                                          t_payr-vblnr t_payr-lifnr t_payr-gjahr t_payr-chect t_payr-zaldt
                                          t_payr-znme1.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.





ENDFORM.                    " REVALIDARCHNEW
*&---------------------------------------------------------------------*
*&      Form  CTAS_ZCTA_PRESCRIP
*&---------------------------------------------------------------------*
*       AGREGA LAS CUENTAS DE PRESCRIPCION Y REVALIDACION CON CHEQUE NUEVO
*
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ctas_zcta_prescrip .
  DATA : ti_zcta LIKE zcta_prescrip OCCURS 0 WITH HEADER LINE.


  SELECT *
    FROM zcta_prescrip
    INTO CORRESPONDING FIELDS OF TABLE ti_zcta.

  IF sy-subrc EQ 0.
    LOOP AT ti_zcta.
      t_cta-low  = ti_zcta-cuenta_p.
      t_cta-sign = 'I'.
      t_cta-option = 'EQ'.
      APPEND t_cta.
    ENDLOOP.
  ENDIF.


ENDFORM.                    " CTAS_ZCTA_PRESCRIP
*&---------------------------------------------------------------------*
*&      Form  CALL_TRAN_FB03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_tran_fb03 USING bukrs datad gjahr.

  SET PARAMETER ID 'BLN' FIELD datad.
  SET PARAMETER ID 'BUK' FIELD bukrs.
  SET PARAMETER ID 'GJR' FIELD gjahr.


  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.




ENDFORM.                    " CALL_TRAN_FB03
*&---------------------------------------------------------------------*
*&      Form  ZMOT_EMIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_OK_BUKRS  text
*      -->P_T_BSIS_BELNR  text
*      -->P_T_BSIS_GJAHR  text
*      <--P_P_ZMOT_EMIS  text
*      <--P_MOVE  text
*      <--P_T_BSIS_BELNR  text
*      <--P_TO  text
*      <--P_T_OK_BELNR  text
*----------------------------------------------------------------------*
FORM zmot_emis  USING    p_bukrs
                         z_belnr
                         p_gjahr
                CHANGING p_emis.


  DATA:    BEGIN OF s_postab OCCURS 50,
            xauth(1)      TYPE c,                 " Berechtigung?
            xhell(1)      TYPE c.                 " Hell anzeigen?
          INCLUDE STRUCTURE rfpos.              " Listanzeigen-Struktur
  INCLUDE rfeposc9.                     " Kunden-Sonderfelder
  DATA:      xbkpf(1)      TYPE c,                 " BKPF nachgelesen?
             xbseg(1)      TYPE c,                 " BSEG nachgelesen?
             xbsec(1)      TYPE c,                 " BSEC nachgelesen?
             xbsed(1)      TYPE c,                 " BSED nachgelesen?
             xpayr(1)      TYPE c,                 " PAYR nachgelesen?
             xbsegc(1)     TYPE c,                 " BSEGC nachgelesen?
             xbsbv(1)      TYPE c,                 " BSBV nachgelesen?
             xmod(1)       TYPE c,                 " POSTAB modifiziert?
           END OF s_postab.


  DATA:
  i_gjahr LIKE payr-gjahr,
  i_vblnr LIKE payr-vblnr,
  i_xbukr LIKE payr-xbukr,
  i_zbukr LIKE payr-zbukr.

  i_xbukr = 'X'.
  i_zbukr = p_bukrs.

  CLEAR p_emis.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
  SELECT SINGLE zzmot_emis INTO p_emis
    FROM bseg
   WHERE bukrs EQ p_bukrs
     AND belnr EQ z_belnr
     AND ( buzei EQ 1 OR
              buzei EQ 2 )
     AND gjahr EQ p_gjahr
     AND zzmot_emis NE ' '.

  IF sy-subrc NE 0.

    CALL FUNCTION 'GET_INVOICE_DOCUMENT_NUMBERS'
      EXPORTING
        i_gjahr   = p_gjahr
        i_vblnr   = z_belnr
        i_xbukr   = i_xbukr
        i_zbukr   = i_zbukr
      TABLES
        t_invoice = s_postab
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    DATA: r_belnr LIKE bkpf-belnr.
    DATA: p_buzei LIKE bseg-buzei.

    LOOP AT s_postab.
      MOVE s_postab-belnr TO r_belnr.
      MOVE s_postab-buzei TO p_buzei.
    ENDLOOP.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
    SELECT SINGLE zzmot_emis INTO p_emis
   FROM bseg
  WHERE bukrs EQ p_bukrs
    AND belnr EQ r_belnr
    AND ( buzei EQ 1 OR
             buzei EQ 2 )
    AND gjahr EQ p_gjahr
    AND zzmot_emis NE ' '.


    IF sy-subrc NE 0.
      p_emis = '--'.
    ENDIF.
  ENDIF.


ENDFORM.                    " ZMOT_EMIS
