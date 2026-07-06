*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
REPORT  zfi_genera_consulta_pago
  NO STANDARD PAGE HEADING
    MESSAGE-ID zfi.

TABLES: zmot_emis.

TYPES: BEGIN OF ty_salida,
  stcd1           LIKE kna1-stcd1,        "rut
  lifnr           LIKE lfa1-lifnr,        "id_maestro
  bukrs           LIKE bsik-bukrs,        "sociedad
  hkont           LIKE bsik-hkont,        "cuenta
  belnr           LIKE bsik-belnr,        "documento
  budat           LIKE bsik-budat,        "fecha doc
  blart           LIKE bsik-blart,        "clase doc
  xblnr           LIKE bsid-xblnr,        "doc pago
  wrbtr           LIKE bsid-wrbtr,        "importe
  waers           LIKE bsid-waers,
  cambio_estado   LIKE zfitr020_t03-cambio_estado, "tipo doc
  zzmot_emis      LIKE bsik-zzmot_emis,   "motivo giro
  augdt           LIKE bsak-augdt,
  augbl           LIKE bsak-augbl,
  buzei           LIKE bsik-buzei,              "agregado 15.12.2014
  hbkid           LIKE bsak-hbkid,
  hktid           LIKE bsak-hktid,
  zlsch           LIKE bsak-zlsch,
  zlspr           LIKE bsak-zlspr,
  zfbdt           LIKE bsak-zfbdt,
  shkzg           LIKE bsak-shkzg,
  zuonr           LIKE bsak-zuonr,
END OF ty_salida.

DATA: ti_salida1          TYPE TABLE OF ty_salida,
      ti_salida_bsak      TYPE TABLE OF ty_salida,
        wa_salida1          TYPE ty_salida,
        wa_salida_bsak      TYPE ty_salida.



SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
PARAMETERS:     p_bukrs LIKE t001-bukrs OBLIGATORY.    "Sociedad
PARAMETERS:     p_budat LIKE sy-datum OBLIGATORY,      "Fecha
                p_hkont   LIKE bsik-hkont OBLIGATORY.
SELECTION-SCREEN END OF BLOCK blk1.

AT SELECTION-SCREEN ON p_bukrs.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e004(zfi) WITH 'Sin autorización para Sociedad.' p_bukrs.
  ENDIF.

INITIALIZATION.
  MOVE  sy-datum TO p_budat.

START-OF-SELECTION.


  SELECT lf~stcd1
  lf~lifnr
  bs~bukrs
  bs~hkont
  bs~belnr
  bs~budat
  bs~blart
  bs~xblnr
  bs~wrbtr
  bs~waers
  bs~buzei                                    "agregado 15.12.2014
  bs~hbkid
  bs~zlsch
  bs~zlspr
  bs~zzmot_emis
  bs~zfbdt
  bs~hktid
  bs~shkzg
  bs~zuonr
  INTO CORRESPONDING FIELDS OF TABLE ti_salida1
  FROM bsik AS bs INNER JOIN lfa1 AS lf
  ON bs~lifnr = lf~lifnr
  WHERE bs~bukrs = p_bukrs
  AND bs~budat <= p_budat
  AND bs~hkont = p_hkont.

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
SORT TI_SALIDA1 .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES04 ECDK917080 *
  LOOP AT ti_salida1 INTO wa_salida1 .

    SELECT SINGLE *
    FROM zmot_emis
    WHERE cta_cadf = wa_salida1-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADF'.
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

    SELECT SINGLE *
    FROM zmot_emis
    WHERE cta_cade = wa_salida1-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADE'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

    SELECT SINGLE *
    FROM zmot_emis
    WHERE cta_pres_h = wa_salida1-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_PRES_H'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

    SELECT SINGLE *
    FROM zmot_emis
    WHERE cta_cadvv = wa_salida1-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida1-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADVV'.
*ReSQ: No Need Of Change Internal Table TI_SALIDA1 Already Sorted
      MODIFY ti_salida1 FROM wa_salida1 INDEX sy-tabix.
    ENDIF.

  ENDLOOP.


  SELECT lfa~stcd1
  lfa~lifnr
  bsa~bukrs
  bsa~hkont
  bsa~belnr
  bsa~budat
  bsa~blart
  bsa~xblnr
  bsa~wrbtr
  bsa~waers
  bsa~zzmot_emis
  bsa~augdt
  bsa~augbl
  bsa~buzei
  bsa~hbkid
  bsa~zlsch
  bsa~zlspr
  bsa~zfbdt
  bsa~hktid
  bsa~shkzg
  bsa~zuonr
  INTO CORRESPONDING FIELDS OF TABLE ti_salida_bsak
  FROM bsak AS bsa INNER JOIN lfa1 AS lfa
  ON bsa~lifnr = lfa~lifnr
  WHERE bsa~bukrs = p_bukrs
  AND bsa~budat <= p_budat

  AND bsa~hkont = p_hkont
  AND bsa~augdt  > p_budat.

  LOOP AT ti_salida_bsak INTO wa_salida_bsak .

    SELECT SINGLE *
      FROM zmot_emis
      WHERE cta_cadf = wa_salida_bsak-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida_bsak-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADF'.
    ENDIF.

    SELECT SINGLE *
    FROM zmot_emis
    WHERE cta_cade = wa_salida_bsak-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida_bsak-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADE'.
    ENDIF.

    SELECT SINGLE *
    FROM zmot_emis
    WHERE cta_pres_h = wa_salida_bsak-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida_bsak-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_PRES_H'.
    ENDIF.

    SELECT SINGLE *
    FROM zmot_emis
    WHERE cta_cadvv = wa_salida_bsak-hkont.

    IF sy-subrc EQ 0.
      SELECT SINGLE glosa
      INTO wa_salida_bsak-cambio_estado
      FROM zfitr020_t06
      WHERE campo = 'CTA_CADVV'.
    ENDIF.

    APPEND wa_salida_bsak TO ti_salida1.

  ENDLOOP.

  IF ti_salida1 IS NOT INITIAL.
    PERFORM graba.
    else.
       MESSAGE 'No se selecciono informacion' TYPE 'I'.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  graba
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM graba.
  DATA: estado(40) TYPE c,
        importe_2(1) TYPE n.

  importe_2 = 0.

  EXEC SQL.
    connect to 'SAPCSC' as 'con'
  ENDEXEC.

  EXEC SQL.
    set connection 'con'
  ENDEXEC.


  EXEC SQL.
    delete from  ZPAGOSINCOBRO  where sociedad  = :p_bukrs
                                and   fecha_de_corte = :p_budat
                                and   cta_sap    =  :p_hkont

  ENDEXEC.
  LOOP AT ti_salida1 INTO wa_salida1.
    IF wa_salida1-shkzg = 'H'.
      wa_salida1-wrbtr = wa_salida1-wrbtr * -1.
    ENDIF.
    wa_salida1-wrbtr = wa_salida1-wrbtr  * 100.
    EXEC SQL.
      INSERT  INTO ZPAGOSINCOBRO(fecha_de_corte,
                            SOCIEDAD,
                            cta_sap,
                            id_maestro,
                            rut,
                            doc_sap,
                            fechadoc,
                            clase_doc,
                            doc_pago,
                            importe,
                            estado,
                            motivo_giro,
                            fecha_de_pago,
                            via_pago,
                            banco_propio,
                            id_banco,
                            importe_2,
                            posicion,
                            modif_pago,
                            bloqueo_pago,
                            zuonr)
                    values(:p_budat,
                           :P_bukrs,
                           :wa_salida1-hkont,
                           :wa_salida1-lifnr,
                           :wa_salida1-stcd1,
                           :wa_salida1-belnr,
                           :wa_salida1-budat,
                           :wa_salida1-blart,
                           :wa_salida1-augbl,
                           :wa_salida1-wrbtr,
                           :wa_salida1-cambio_estado,
                           :wa_salida1-zzmot_emis,
                           :wa_salida1-zfbdt,
                           :wa_salida1-zlsch,
                           :wa_salida1-hbkid,
                           :wa_salida1-hktid,
                           :importe_2,
                           :wa_salida1-buzei,
                           :estado,
                           :wa_salida1-zlspr,
                           :wa_salida1-zuonr )
    ENDEXEC.

  ENDLOOP.

 MESSAGE 'Informacion Generada' TYPE 'I'.

  EXEC SQL.
    SET CONNECTION DEFAULT
  ENDEXEC.

ENDFORM.                    "graba
