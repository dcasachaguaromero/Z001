*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <23-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
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

*PYV

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
       AND chect IN psel.
  DATA: vnun TYPE n,
        vnun2(9) TYPE c.

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 23/12/2019 EY_DES02 ECDK917080 *
SORT T_CTA .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 23/12/2019 EY_DES02 ECDK917080 *
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

    CONCATENATE t_payr-ubhkt+0(9) '7' INTO g_hkod.

    CONCATENATE 'Caducar Electronico Individual'  ' - '  sy-datum INTO g_sgtxt.
    g_little = 'Caducar Electronico Individual'.

    IF t_payr-XBANC ='X'.
      CLEAR: t_ok.
      des_cta = 'CHEQUE PAGADO'.
      MOVE: t_payr-vblnr  TO t_ok-belnr,
            '@0A@'        TO t_ok-status,
            t_payr-zbukr  TO t_ok-bukrs,
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

        MOVE: t_payr-vblnr  TO t_ok-belnr,
              '@0A@'        TO t_ok-status,
              t_payr-zbukr  TO t_ok-bukrs,
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
          p_kouhr2 = p_kouhr1.
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
            ENDIF.
            IF t_payr-voidr GT 0. " causa de anulacion
              des_cta = 'CHEQUE ANULADO'.
            ENDIF.

            CLEAR g_bldat.
            PERFORM  resc_bldat USING bukrs t_payr-vblnr t_bsis-gjahr
                                CHANGING g_bldat.

            PERFORM valid_cta  USING t_bsis-hkont+9(1)  save_code
                               CHANGING g_valid_cta.

            PERFORM  zmot_emis USING bukrs  t_bsis-belnr t_bsis-gjahr
                               CHANGING p_zmot_emis.

* Si diferencia de fechas es menos a 60 dias no se podra caducar.
            IF datediff >= 60.
              CLEAR: t_ok.
              MOVE: t_bsis-belnr TO t_ok-belnr.
              IF g_valid_cta EQ 1.
                MOVE '@0A@'    TO t_ok-status. " ICONO MAL
              ELSE.
                MOVE '@08@'    TO t_ok-status. " ICONO BIEN
              ENDIF.

              MOVE: t_bsis-bukrs  TO t_ok-bukrs,
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
                                   USING t_bsas-bukrs  t_bsas-augbl g_hkod g_sgtxt t_payr-voidr
                                         t_payr-vblnr t_payr-lifnr t_payr-gjahr t_payr-chect t_payr-zaldt
                                         t_payr-znme1.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "caduca_elec_indiv

*&---------------------------------------------------------------------*
*&      Form  PARAMETROS_JDATOS
*&---------------------------------------------------------------------*
FORM parametros_jdatos.

*PYV

  REFRESH i_tablsubm.
  CLEAR i_tablsubm.

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
*&      Form  CTAS_ZCTA_PRESCRIP
*&---------------------------------------------------------------------*
*       AGREGA LAS CUENTAS DE PRESCRIPCION Y REVALIDACION CON CHEQUE NUEVO
*
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ctas_zcta_prescrip.

*PYV

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
*&      Form  DESC_CTA
*&---------------------------------------------------------------------*
*       text obtiene descripcion de cuenta
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM desc_cta USING cta TYPE c
              CHANGING des_cta.

*PYV

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

*PYV

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

* PYV

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

*ResQ Comment:Correction not required as Select Single is used 23/12/2019 EY_DES02 ECDK917080 *
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

*ResQ Comment:Correction not required as Select Single is used 23/12/2019 EY_DES02 ECDK917080 *
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

* PYV

  DATA: t_bseg LIKE bseg  OCCURS 0 WITH HEADER LINE.
  DATA: g_checaux LIKE t_ok-chect.
  DATA: g_hkot LIKE bseg-hkont. "GUARDA CUENTA ACTUAL"


  SELECT *
   FROM zcta_prescrip
   INTO CORRESPONDING FIELDS OF TABLE ti_zctap.

SELECT * INTO CORRESPONDING FIELDS OF TABLE t_bseg
FROM bseg
WHERE bukrs EQ p_t_bsas-bukrs
AND belnr EQ p_t_bsas-augbl
AND shkzg EQ 'H'
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *
*AND zuonr EQ p_chect.
AND ZUONR EQ P_CHECT ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *

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
      PERFORM  resc_bldat USING t_bseg-bukrs p_t_belnr t_bseg-gjahr
                          CHANGING g_bldat.

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
          g_valid_cta = 1.
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
          g_valid_cta = 1.
        ENDIF.

        PERFORM  zmot_emis USING p_t_bsas-bukrs  p_t_belnr p_gjahr
                           CHANGING p_zmot_emis.


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

          IF t_ok-zmote = 'SUBMATERNA' AND t_ok-estado = 'CHEQUE ANULADO'.
            t_ok-estado = 'NUEVO CHEQUE MATERNAL'.
          ENDIF.

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
                p_zaldt      TO t_ok-zaldt,
                p_znme1      TO t_ok-znme1,
                p_zmot_emis  TO t_ok-zmote.

          IF t_ok-zmote = 'SUBMATERNA' AND t_ok-estado = 'CHEQUE ANULADO'.
            t_ok-estado = 'NUEVO CHEQUE MATERNAL'.
          ENDIF.

        ENDIF.

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
       AND gjahr EQ p_gjahr.
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
      p_kouhr2 = p_kouhr1.
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

        PERFORM valid_cta  USING t_bseg-hkont+9(1)  save_code
                        CHANGING g_valid_cta.

        PERFORM  zmot_emis USING bukrs p_t_belnr it_payr-gjahr
                           CHANGING p_zmot_emis.

        IF earliest EQ 2.
          datediff = datediff * -1.
          g_valid_cta = 1.
        ENDIF.

        IF g_voidr GT 0 . " causa de anulacion
          des_cta = 'CHEQUE ANULADO'.
          datediff = 0.
          g_valid_cta = 1.
        ENDIF.

        LOOP AT ti_zctap WHERE cuenta_p EQ t_bseg-hkont.
          des_cta = ti_zctap-descripcion.
        ENDLOOP.

        IF des_cta  = 'CHEQUE ANULADO'.
          g_hkot ='ANULACION'.
        ELSE.
          g_hkot = t_bseg-hkont.
        ENDIF.

        MOVE: t_bseg-belnr  TO t_ok-belnr.
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
        APPEND t_ok.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " BUSCA_COMPEN
