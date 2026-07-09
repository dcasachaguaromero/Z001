*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_000
*&---------------------------------------------------------------------*

START-OF-SELECTION.


  PERFORM proceso.

  CALL SCREEN 150.

END-OF-SELECTION.

*---------------------------------------------------------------------*
*       FORM PROCESO                                                  *
*---------------------------------------------------------------------*
FORM proceso.

  DATA: BEGIN OF p_blart OCCURS 10,
          sign   TYPE c LENGTH 1,
          option TYPE c LENGTH 2,
          low    LIKE bsik-blart,
          high   LIKE bsik-blart,
        END OF p_blart.

  DATA: BEGIN OF p_budat OCCURS 10,
          sign   TYPE c LENGTH 1,
          option TYPE c LENGTH 2,
          low    LIKE bsik-budat,
          high   LIKE bsik-budat,
        END OF p_budat.

  DATA: BEGIN OF p_zlsch OCCURS 10,
          sign   TYPE c LENGTH 1,
          option TYPE c LENGTH 2,
          low    LIKE bsik-zlsch,
          high   LIKE bsik-zlsch,
        END OF p_zlsch.


  DATA: BEGIN OF p_xref1 OCCURS 10,
          sign   TYPE c LENGTH 1,
          option TYPE c LENGTH 2,
          low    LIKE bsik-xref1,
          high   LIKE bsik-xref1,
        END OF p_xref1.

* ini - 04-06-2020 - Waldo alarcon - Visionone.
  DATA : lv_bvtyp TYPE xflag.
* fin - 04-06-2020 - Waldo alarcon - Visionone.
* ini - 28-04-2022 - Waldo alarcon - Visionone.
  DATA : wa_tpago LIKE tpago,
         lv_monto TYPE dmbtr_x8.
* fin - 28-04-2022 - Waldo alarcon - Visionone.

*  SELECT * FROM    zfipg001 WHERE bukrs  = bukrs.
*    p_blart-sign   = 'I'.
*    p_blart-option = 'EQ'.
*    p_blart-low    = zfipg001-blart.
*    CLEAR p_blart-high.
*    APPEND p_blart.
*  ENDSELECT.

  IF NOT  budat IS INITIAL.
    p_budat-sign   = 'I'.
    p_budat-option = 'LE'.
    p_budat-low    = budat.
    CLEAR p_budat-high.
    APPEND p_budat.
  ENDIF.

  IF NOT  zlsch IS INITIAL.
    p_zlsch-sign   = 'I'.
    p_zlsch-option = 'EQ'.
    p_zlsch-low    = zlsch.
    CLEAR p_zlsch-high.
    APPEND p_zlsch.
  ENDIF.

  IF NOT  xref1 IS INITIAL.
    p_xref1-sign   = 'I'.
    p_xref1-option = 'EQ'.
    p_xref1-low    = xref1.
    CLEAR p_xref1-high.
    APPEND p_xref1.
  ENDIF.

  REFRESH tpago.
  CLEAR tpago.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM bsik WHERE bukrs = bukrs
*    AND   budat IN p_budat
*    AND   zfbdt IN p_zfbdt
*    AND   zlsch IN p_zlsch
*    AND   xref1 IN p_xref1
*    AND   waers IN s_waers.
*
* NEW CODE
  SELECT *
 FROM bsik WHERE bukrs = bukrs
    AND   budat IN p_budat
    AND   zfbdt IN p_zfbdt
    AND   zlsch IN p_zlsch
    AND   xref1 IN p_xref1
    AND   waers IN s_waers ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*    AND   hbkid <> ''.

    CLEAR tpago.
    IF  bsik-zlspr  <> '' .
      IF  bsik-zlspr  <> 'Z'.
        MOVE-CORRESPONDING bsik TO tpago.
        tpago-wrbtr_r = tpago-wrbtr.
        tpago-dmbtr_r = tpago-dmbtr. "ini 28-04-2022 - Waldo alarcon - Visionone.
        CLEAR tpago-wrbtr.
        CLEAR tpago-dmbtr.           "ini 28-04-2022 - Waldo alarcon - Visionone.
        tpago-msg     = 'Pago Bloqueado'.
        tpago-docto_r = 1.
        APPEND tpago.
      ENDIF.
      IF  bsik-zlspr  = 'Z'.
        MOVE-CORRESPONDING bsik TO tpago.
        tpago-wrbtr_na = tpago-wrbtr.
        tpago-dmbtr_na = tpago-dmbtr. "ini 28-04-2022 - Waldo alarcon - Visionone.
        CLEAR tpago-wrbtr.
        CLEAR tpago-dmbtr.            "ini 28-04-2022 - Waldo alarcon - Visionone.
        tpago-msg      = 'Abono/FAC No Aplicado'.
        tpago-docto_na = 1.
        APPEND tpago.
      ENDIF.
    ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM regus WHERE koart = 'K'
*                                 AND   bukrs = bsik-bukrs
*                                 AND   konko = bsik-lifnr.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM regus WHERE koart = 'K'
                                 AND   bukrs = bsik-bukrs
                                 AND   konko = bsik-lifnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc <> 0.
        MOVE-CORRESPONDING bsik TO tpago.
        tpago-docto = 1.
        APPEND tpago.
      ELSE.
        MOVE-CORRESPONDING bsik TO tpago.
        tpago-wrbtr_r = tpago-wrbtr.
        tpago-dmbtr_r = tpago-dmbtr. "ini 28-04-2022 - Waldo alarcon - Visionone.
        CLEAR tpago-wrbtr.
        CLEAR tpago-dmbtr.           "ini 28-04-2022 - Waldo alarcon - Visionone.
        tpago-docto_r = 1.
        CONCATENATE 'Acreedor se encuentra en propuesta:'  regus-laufd regus-laufi INTO tpago-msg SEPARATED BY space.
        APPEND tpago.
      ENDIF.
    ENDIF.

  ENDSELECT.

  REFRESH int_tabla.
  CLEAR  int_tabla.

  LOOP AT tpago.
    IF tpago-shkzg = 'S'.
      MULTIPLY tpago-wrbtr    BY -1.
      MULTIPLY tpago-wrbtr_r  BY -1.
      MULTIPLY tpago-wrbtr_na BY -1.
* ini - 28-04-2022 - Waldo alarcon - Visionone.
      MULTIPLY tpago-dmbtr    BY -1.
      MULTIPLY tpago-dmbtr_r  BY -1.
      MULTIPLY tpago-dmbtr_na BY -1.
* fin - 28-04-2022 - Waldo alarcon - Visionone.
    ENDIF.
* ini - 28-04-2022 - Waldo alarcon - Visionone.
    PERFORM tipo_cambio USING    tpago-zfbdt
                                 tpago-wrbtr
                                 tpago-waers
                        CHANGING tpago-monto_ml_tc
                                 tpago-ukurs.
* fin - 28-04-2022 - Waldo alarcon - Visionone.
    MODIFY tpago FROM tpago
     TRANSPORTING wrbtr wrbtr_r wrbtr_na
* ini - 28-04-2022 - Waldo alarcon - Visionone.
                  dmbtr dmbtr_r dmbtr_na
                  monto_ml_tc   ukurs.
* fin - 28-04-2022 - Waldo alarcon - Visionone.
  ENDLOOP.

  SORT tpago BY zfbdt zzmot_emis hbkid zlsch.

  LOOP AT tpago.
* ini - 28-04-2022 - Waldo alarcon - Visionone.
    MOVE-CORRESPONDING tpago TO wa_tpago.
* fin - 28-04-2022 - Waldo alarcon - Visionone.

* ini - 04-06-2020 - Waldo alarcon - Visionone.
    IF tpago-bvtyp IS INITIAL.
      lv_bvtyp = 'X'.
    ENDIF.
* fin - 04-06-2020 - Waldo alarcon - Visionone.

    AT END OF zlsch.
      SUM.
      CLEAR int_tabla.
      int_tabla-zzmot_emis = tpago-zzmot_emis.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE zzdescr INTO  int_tabla-descr
*                            FROM  zmot_emis
*                            WHERE bukrs = bukrs
*                            AND   zzmot_emis  =  int_tabla-zzmot_emis.
*
* NEW CODE
      SELECT zzdescr
      UP TO 1 ROWS  INTO  int_tabla-descr
                            FROM  zmot_emis
                            WHERE bukrs = bukrs
                            AND   zzmot_emis  =  int_tabla-zzmot_emis ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      int_tabla-zlsch     = tpago-zlsch.
      int_tabla-docto     = tpago-docto.
*      IF tpago-wrbtr < 0.
*       MULTIPLY tpago-wrbtr BY -1.
*      ENDIF.
      int_tabla-monto     = tpago-wrbtr.
      int_tabla-docto_r   = tpago-docto_r.
      int_tabla-monto_r   = tpago-wrbtr_r.
      int_tabla-docto_na  = tpago-docto_na.
      int_tabla-monto_na  = tpago-wrbtr_na.
      int_tabla-fecha_v   = tpago-zfbdt.
* ini - 04-06-2020 - Waldo alarcon - Visionone.
      int_tabla-bvtyp_existe = lv_bvtyp.
      CLEAR lv_bvtyp.
* fin - 04-06-2020 - Waldo alarcon - Visionone.

* ini - 28-04-2022 - Waldo alarcon - Visionone.
      int_tabla-waers        = wa_tpago-waers.
      int_tabla-monto_ml     = tpago-dmbtr.
      int_tabla-monto_ml_r   = tpago-dmbtr_r.
      int_tabla-monto_ml_na  = tpago-dmbtr_na.
      int_tabla-monto_ml_tc  = tpago-monto_ml_tc.
*      int_tabla-ukurs        = tpago-ukurs / lv_ukurs.
      PERFORM tipo_cambio USING    int_tabla-fecha_v
                                   int_tabla-monto
                                   int_tabla-waers
                          CHANGING lv_monto
                                   int_tabla-ukurs.
* fin - 28-04-2022 - Waldo alarcon - Visionone.

      APPEND int_tabla.
    ENDAT.
  ENDLOOP.

  LOOP AT tpago.
    IF tpago-shkzg = 'S'.
      MULTIPLY tpago-wrbtr    BY -1.
      MULTIPLY tpago-wrbtr_r  BY -1.
      MULTIPLY tpago-wrbtr_na BY -1.
* ini - 28-04-2022 - Waldo alarcon - Visionone.
      MULTIPLY tpago-dmbtr       BY -1.
      MULTIPLY tpago-dmbtr_r     BY -1.
      MULTIPLY tpago-dmbtr_na    BY -1.
      MULTIPLY tpago-monto_ml_tc BY -1.
* fin - 28-04-2022 - Waldo alarcon - Visionone.

      MODIFY tpago FROM tpago
       TRANSPORTING wrbtr wrbtr_r wrbtr_na
                    dmbtr dmbtr_r dmbtr_na monto_ml_tc.  "ini - 28-04-2022 - Waldo alarcon - Visionone.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY fecha_v zzmot_emis zlsch.
  tabla-lines    = fill.
  tabla-top_line = 1.

  LOOP AT tabla-cols INTO cols.
    cols-index        = sy-tabix.
    IF cols-screen-name EQ 'ZFIPG002_EST-ZLSCH' OR
       cols-screen-name EQ 'ZFIPG002_EST-DESCR'.
      cols-screen-input = 0.
      cols-invisible    = '1'.
    ENDIF.
    MODIFY tabla-cols FROM cols INDEX sy-tabix.
  ENDLOOP.
ENDFORM.                    "PROCESO
*&---------------------------------------------------------------------*
*&      Form  TIPO_CAMBIO
*&---------------------------------------------------------------------*
FORM tipo_cambio  USING    p_fecha_v
                           p_monto_ml
                           p_waers
                  CHANGING p_monto_ml_tc
                           p_ukurs.
  DATA : lv_local_amount  TYPE dmbtr,
         lv_local_factor  TYPE tcurr-tfact,
         lv_exchange_rate TYPE ukurs_curr.
* SOLO SI LAS MONEDAS SON DISTINTAS
  CHECK p_waers NE t001-waers.
* VERIFICA SI EL DATO ESTA PARA LA FECHA EXACTA.
*  CALL FUNCTION 'READ_EXCHANGE_RATE'
*    EXPORTING
*      date             = p_fecha_v
*      foreign_currency = p_waers
*      local_currency   = t001-waers
*      exact_date       = 'X'
*    EXCEPTIONS
*      no_rate_found    = 1
*      no_factors_found = 2
*      no_spread_found  = 3
*      derived_2_times  = 4
*      overflow         = 5
*      zero_rate        = 6
*      OTHERS           = 7.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
* REALIZA EL TIPO DE CAMBIO DEL MONTO IGRESADO
  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
    EXPORTING
      date             = p_fecha_v
      foreign_amount   = p_monto_ml
      foreign_currency = p_waers
      local_currency   = t001-waers
    IMPORTING
      exchange_rate    = lv_exchange_rate
      local_amount     = lv_local_amount
      local_factor     = lv_local_factor
    EXCEPTIONS
      no_rate_found    = 1
      overflow         = 2
      no_factors_found = 3
      no_spread_found  = 4
      derived_2_times  = 5
      OTHERS           = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    p_monto_ml_tc = lv_local_amount .
    p_ukurs       = lv_exchange_rate * lv_local_factor.
  ENDIF.
ENDFORM.
