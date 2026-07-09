*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFITR013_100 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  REFRESH tab.

  SET  PF-STATUS 'ZFITR035' EXCLUDING tab.
  SET  TITLEBAR 'T01'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE user_command_0100_exit INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      DESCRIBE TABLE int_tabla2 LINES fill.
      IF fill > 0.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = 'Confirmacion '
            text_question         = 'Esta seguro de salir?. Existe Informacion pendiente de contabilizar'
            default_button        = '2'
            display_cancel_button = 'X'
          IMPORTING
            answer                = resp.

        IF sy-subrc = 0 AND resp = '1'.
          LEAVE TO SCREEN 0.
        ENDIF.
      ELSE.

        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN '%EX' OR 'RW'.
      DESCRIBE TABLE int_tabla2 LINES fill.
      IF fill > 0.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = 'Confirmacion '
            text_question         = 'Esta seguro de salir?. Existe Informacion pendiente de contabilizar'
            default_button        = '2'
            display_cancel_button = 'X'
          IMPORTING
            answer                = resp.

        IF sy-subrc = 0 AND resp = '1'.
          LEAVE TO SCREEN 0.
        ENDIF.
      ELSE.
        LEAVE PROGRAM.
      ENDIF.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                    "user_command_0100_exit INPUT
*----------------------------------------------------------------------*
*  MODULE USER_COMMAND_0100 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA : xlinea LIKE tabla-top_line.

  CASE sy-ucomm.

    WHEN 'SEL'.
      CLEAR sy-ucomm.
      PERFORM marco_todo_tabla.

    WHEN 'DSEL'.
      CLEAR sy-ucomm.
      PERFORM desmarco_todo_tabla.

    WHEN 'SEL2'.
      CLEAR sy-ucomm.
      PERFORM marco_todo_tabla2.

    WHEN 'DSEL2'.
      CLEAR sy-ucomm.
      PERFORM desmarco_todo_tabla2.

    WHEN 'RECH'.

      GET CURSOR LINE xlinea.
      IF xlinea > 0 AND xlinea <= tabla-lines .
        xlinea = xlinea + tabla-top_line - 1.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
SORT INT_TABLA .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
        READ TABLE int_tabla INDEX xlinea.
        MOVE-CORRESPONDING  int_tabla TO zfitr035_est.
        PERFORM cargo_tabla3.
        CALL SCREEN 300 STARTING AT 20 08
              ENDING   AT 130 22.
      ENDIF.

      CLEAR sy-ucomm.

    WHEN 'ELIM'.
      CLEAR sy-ucomm.
      PERFORM elimina_tabla2.
    WHEN 'CONTAB'.
      PERFORM contabilizar.
      IF salir = 'SI'.
        LEAVE TO SCREEN 0.
      ENDIF.


  ENDCASE.

  CLEAR sy-ucomm.




ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  marco_todo_tabla
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM marco_todo_tabla .
  LOOP AT int_tabla.
    int_tabla-sel = 'X'.
    MODIFY int_tabla.
  ENDLOOP.

ENDFORM.                    " MARCO_TODO
*&---------------------------------------------------------------------*
*&      Form  marco_todo_tabla2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM marco_todo_tabla2 .
  LOOP AT int_tabla2.
    int_tabla2-sel = 'X'.
    MODIFY int_tabla2.
  ENDLOOP.

ENDFORM.                    " MARCO_TODO
*&---------------------------------------------------------------------*
*&      Form  DESMARCO_TODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM desmarco_todo_tabla.
  LOOP AT int_tabla.
    int_tabla-sel = ''.
    MODIFY int_tabla.
  ENDLOOP.

ENDFORM.                    "desmarco_todo_tabla
*&---------------------------------------------------------------------*
*&      Form  desmarco_todo_tabla2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM desmarco_todo_tabla2.
  LOOP AT int_tabla2.
    int_tabla2-sel = ''.
    MODIFY int_tabla2.
  ENDLOOP.

ENDFORM.                    "desmarco_todo_tabla2
*&---------------------------------------------------------------------*
*&      Form  CARGA_TABLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM carga_tabla .
  DATA rut LIKE lfa1-stcd1.
  DATA valor LIKE reguh-rbetr.
  DATA valor_rec LIKE reguh-rbetr.
  DATA bloqueo(01) TYPE c.
  DATA mensaje(25) TYPE c.
  DATA linea TYPE numc04.

  REFRESH: int_tabla, int_tabla2, tabla_aux.
  CLEAR  monto_i.

  LOOP AT tl_exc.
    linea = sy-tabix.
    REFRESH tabla_trab.
    CONCATENATE   tl_exc-rutpr '-' tl_exc-dvrutpr INTO rut.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM lfa1 WHERE stcd1 = rut.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM lfa1 WHERE stcd1 = rut ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM reguh WHERE valut IN  v_fecha
*                          AND   zbukr  = bukrs
*                          AND   hbkid  = v_hbkid
*                          AND   lifnr  = lfa1-lifnr
*                          AND   rzawe = rzawe
*                          AND   xvorl  = ''
*                          AND   zbnkn  = tl_exc-cuenta
*                          AND   zbnkl  = tl_exc-banco.
*
* NEW CODE
      SELECT *
 FROM reguh WHERE valut IN  v_fecha
                          AND   zbukr  = bukrs
                          AND   hbkid  = v_hbkid
                          AND   lifnr  = lfa1-lifnr
                          AND   rzawe = rzawe
                          AND   xvorl  = ''
                          AND   zbnkn  = tl_exc-cuenta
                          AND   zbnkl  = tl_exc-banco ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

        valor = reguh-rbetr * -1.
        valor_rec = tl_exc-valor .
        valor_rec = valor_rec / 100.
        IF valor = valor_rec.
          CLEAR bseg-zzmot_emis.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
*                                        AND   laufi = reguh-laufi
*                                        AND   xvorl = reguh-xvorl
*                                        AND   zbukr = reguh-zbukr
*                                        AND   lifnr = reguh-lifnr
*                                        AND   kunnr = reguh-kunnr
*                                        AND   empfg = reguh-empfg
*                                        AND   vblnr = reguh-vblnr.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM  regup WHERE laufd = reguh-laufd
                                        AND   laufi = reguh-laufi
                                        AND   xvorl = reguh-xvorl
                                        AND   zbukr = reguh-zbukr
                                        AND   lifnr = reguh-lifnr
                                        AND   kunnr = reguh-kunnr
                                        AND   empfg = reguh-empfg
                                        AND   vblnr = reguh-vblnr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
*                                      AND  belnr = regup-belnr
*                                      AND  gjahr = regup-gjahr
*                                      AND  buzei = regup-buzei.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM  bseg WHERE bukrs  = regup-bukrs
                                      AND  belnr = regup-belnr
                                      AND  gjahr = regup-gjahr
                                      AND  buzei = regup-buzei ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF bseg-zzmot_emis = tl_exc-emision.
            CLEAR   tabla_trab.
            tabla_trab-laufi = reguh-laufi.
            tabla_trab-laufd = reguh-laufd.
            tabla_trab-vblnr = reguh-vblnr.
            tabla_trab-valut = reguh-valut.
            tabla_trab-rbetr = reguh-rbetr * -1.

            IF reguh-ind_rechazo = 'X' .
              tabla_trab-estado = 'Rechazado'.
              tabla_trab-bloqueo = '1'.
            ELSE.
              IF reguh-ind_pago = 'X'.
                tabla_trab-estado = 'Ya Pagado'.
                tabla_trab-bloqueo = '1'.
              ELSE.
*Begin of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
SORT TAGE BY BUKRS ZZCOD_UNIDAD .
*End of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
                tabla_trab-estado = 'Proceso Pago'.
                tabla_trab-bloqueo = '0'.
              ENDIF.
            ENDIF.

            tabla_trab-motivo_rechazo = tl_exc-motivo.
            tabla_trab-sel = ''.
            tabla_trab-zz_agencia = bseg-zz_agencia.

            READ TABLE tage WITH KEY bukrs         =  bukrs
                                  zzcod_unidad    =  tabla_trab-zz_agencia
                                  BINARY SEARCH.

            IF sy-subrc <> 0.
              tabla_trab-zz_agencia_des  = 'Sin Descripcion'.
            ELSE.
              tabla_trab-zz_agencia_des = tage-zzdescr.
            ENDIF.
            bloqueo =  tabla_trab-bloqueo.
            APPEND tabla_trab.
          ENDIF.
        ENDIF.
      ENDSELECT.

      DESCRIBE TABLE tabla_trab LINES fill.
      IF fill = 0.

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT * FROM reguh WHERE valut IN  v_fecha
*                          AND   zbukr  = bukrs
*                          AND   hbkid  = v_hbkid
*                          AND   lifnr  = lfa1-lifnr
*                          AND   rzawe = rzawe
*                          AND   xvorl  = ''
*                          AND   zbnkn  = tl_exc-cuenta
*                          AND   zbnkl  = tl_exc-banco.
*
* NEW CODE
        SELECT *
 FROM reguh WHERE valut IN  v_fecha
                          AND   zbukr  = bukrs
                          AND   hbkid  = v_hbkid
                          AND   lifnr  = lfa1-lifnr
                          AND   rzawe = rzawe
                          AND   xvorl  = ''
                          AND   zbnkn  = tl_exc-cuenta
                          AND   zbnkl  = tl_exc-banco ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
          valor = reguh-rbetr * -1.
          valor_rec = tl_exc-valor .
          valor_rec = valor_rec / 100.
          IF valor = valor_rec.
            CLEAR bseg-zzmot_emis.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
*                                          AND   laufi = reguh-laufi
*                                          AND   xvorl = reguh-xvorl
*                                          AND   zbukr = reguh-zbukr
*                                          AND   lifnr = reguh-lifnr
*                                          AND   kunnr = reguh-kunnr
*                                          AND   empfg = reguh-empfg
*                                          AND   vblnr = reguh-vblnr.
*
* NEW CODE
            SELECT *
            UP TO 1 ROWS  FROM  regup WHERE laufd = reguh-laufd
                                          AND   laufi = reguh-laufi
                                          AND   xvorl = reguh-xvorl
                                          AND   zbukr = reguh-zbukr
                                          AND   lifnr = reguh-lifnr
                                          AND   kunnr = reguh-kunnr
                                          AND   empfg = reguh-empfg
                                          AND   vblnr = reguh-vblnr ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
*                                        AND  belnr = regup-belnr
*                                        AND  gjahr = regup-gjahr
*                                        AND  buzei = regup-buzei.
*
* NEW CODE
            SELECT *
            UP TO 1 ROWS  FROM  bseg WHERE bukrs  = regup-bukrs
                                        AND  belnr = regup-belnr
                                        AND  gjahr = regup-gjahr
                                        AND  buzei = regup-buzei ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            CLEAR   tabla_trab.
            tabla_trab-laufi = reguh-laufi.
            tabla_trab-laufd = reguh-laufd.
            tabla_trab-vblnr = reguh-vblnr.
            tabla_trab-valut = reguh-valut.
            tabla_trab-rbetr = reguh-rbetr * -1.

            IF reguh-ind_rechazo = 'X' .
              tabla_trab-estado = 'Rechazado'.
              tabla_trab-bloqueo = '1'.
            ELSE.
              IF reguh-ind_pago = 'X'.
                tabla_trab-estado = 'Ya Pagado'.
                tabla_trab-bloqueo = '1'.
              ELSE.
                tabla_trab-estado = 'Proceso Pago'.
                tabla_trab-bloqueo = '0'.
              ENDIF.
            ENDIF.
            tabla_trab-motivo_rechazo = tl_exc-motivo.
            tabla_trab-sel = ''.
            tabla_trab-zz_agencia = bseg-zz_agencia.

*ReSQ: No Need Of Change Internal Table TAGE Already Sorted
            READ TABLE tage WITH KEY bukrs         =  bukrs
                                  zzcod_unidad    =  bseg-zz_agencia
                                  BINARY SEARCH.

            IF sy-subrc <> 0.
              tabla_trab-zz_agencia_des  = 'Sin Descripcion'.
            ELSE.
              tabla_trab-zz_agencia_des = tage-zzdescr.
            ENDIF.
            bloqueo =  tabla_trab-bloqueo.
            APPEND tabla_trab.
          ENDIF.

        ENDSELECT.
        DESCRIBE TABLE tabla_trab LINES fill.

        IF fill = 0.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*          SELECT * FROM reguh WHERE valut IN  v_fecha
*                            AND   zbukr  = bukrs
*                            AND   hbkid  = v_hbkid
*                            AND   lifnr  = lfa1-lifnr
*                            AND   rzawe = rzawe
*                            AND   xvorl  = ''.
*
* NEW CODE
          SELECT *
 FROM reguh WHERE valut IN  v_fecha
                            AND   zbukr  = bukrs
                            AND   hbkid  = v_hbkid
                            AND   lifnr  = lfa1-lifnr
                            AND   rzawe = rzawe
                            AND   xvorl  = '' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
            valor = reguh-rbetr * -1.
            valor_rec = tl_exc-valor .
            valor_rec = valor_rec / 100.
            IF valor = valor_rec.
              CLEAR bseg-zzmot_emis.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
*                                            AND   laufi = reguh-laufi
*                                            AND   xvorl = reguh-xvorl
*                                            AND   zbukr = reguh-zbukr
*                                            AND   lifnr = reguh-lifnr
*                                            AND   kunnr = reguh-kunnr
*                                            AND   empfg = reguh-empfg
*                                            AND   vblnr = reguh-vblnr.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  FROM  regup WHERE laufd = reguh-laufd
                                            AND   laufi = reguh-laufi
                                            AND   xvorl = reguh-xvorl
                                            AND   zbukr = reguh-zbukr
                                            AND   lifnr = reguh-lifnr
                                            AND   kunnr = reguh-kunnr
                                            AND   empfg = reguh-empfg
                                            AND   vblnr = reguh-vblnr ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
*                                          AND  belnr = regup-belnr
*                                          AND  gjahr = regup-gjahr
*                                          AND  buzei = regup-buzei.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  FROM  bseg WHERE bukrs  = regup-bukrs
                                          AND  belnr = regup-belnr
                                          AND  gjahr = regup-gjahr
                                          AND  buzei = regup-buzei ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              CLEAR   tabla_trab.
              tabla_trab-laufi = reguh-laufi.
              tabla_trab-laufd = reguh-laufd.
              tabla_trab-vblnr = reguh-vblnr.
              tabla_trab-valut = reguh-valut.
              tabla_trab-rbetr = reguh-rbetr * -1.

              IF reguh-ind_rechazo = 'X' .
                tabla_trab-estado = 'Rechazado'.
                tabla_trab-bloqueo = '1'.
              ELSE.
                IF reguh-ind_pago = 'X'.
                  tabla_trab-estado = 'Ya Pagado'.
                  tabla_trab-bloqueo = '1'.
                ELSE.
                  tabla_trab-estado = 'Proceso Pago'.
                  tabla_trab-bloqueo = '0'.
                ENDIF.
              ENDIF.

              tabla_trab-motivo_rechazo = tl_exc-motivo.
              tabla_trab-sel = ''.
              tabla_trab-zz_agencia = bseg-zz_agencia.

*ReSQ: No Need Of Change Internal Table TAGE Already Sorted
              READ TABLE tage WITH KEY bukrs         =  bukrs
                                    zzcod_unidad    =  bseg-zz_agencia
                                    BINARY SEARCH.

              IF sy-subrc <> 0.
                tabla_trab-zz_agencia_des  = 'Sin Descripcion'.
              ELSE.
                tabla_trab-zz_agencia_des = tage-zzdescr.
              ENDIF.
              bloqueo =  tabla_trab-bloqueo.
              APPEND tabla_trab.
            ENDIF.
          ENDSELECT.

          DESCRIBE TABLE tabla_trab LINES fill.

          IF fill = 0.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*            SELECT * FROM reguh WHERE valut IN  v_fecha
*                           AND   zbukr  = bukrs
*                           AND   hbkid  = v_hbkid
*                           AND   lifnr  = lfa1-lifnr
*                           AND   rzawe = rzawe
*                           AND   xvorl  = ''.
*
* NEW CODE
            SELECT *
 FROM reguh WHERE valut IN  v_fecha
                           AND   zbukr  = bukrs
                           AND   hbkid  = v_hbkid
                           AND   lifnr  = lfa1-lifnr
                           AND   rzawe = rzawe
                           AND   xvorl  = '' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

              CLEAR bseg-zzmot_emis.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
*                                            AND   laufi = reguh-laufi
*                                            AND   xvorl = reguh-xvorl
*                                            AND   zbukr = reguh-zbukr
*                                            AND   lifnr = reguh-lifnr
*                                            AND   kunnr = reguh-kunnr
*                                            AND   empfg = reguh-empfg
*                                            AND   vblnr = reguh-vblnr.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  FROM  regup WHERE laufd = reguh-laufd
                                            AND   laufi = reguh-laufi
                                            AND   xvorl = reguh-xvorl
                                            AND   zbukr = reguh-zbukr
                                            AND   lifnr = reguh-lifnr
                                            AND   kunnr = reguh-kunnr
                                            AND   empfg = reguh-empfg
                                            AND   vblnr = reguh-vblnr ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
*                                          AND  belnr = regup-belnr
*                                          AND  gjahr = regup-gjahr
*                                          AND  buzei = regup-buzei.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  FROM  bseg WHERE bukrs  = regup-bukrs
                                          AND  belnr = regup-belnr
                                          AND  gjahr = regup-gjahr
                                          AND  buzei = regup-buzei ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              CLEAR   tabla_trab.
              tabla_trab-laufi = reguh-laufi.
              tabla_trab-laufd = reguh-laufd.
              tabla_trab-vblnr = reguh-vblnr.
              tabla_trab-valut = reguh-valut.
              tabla_trab-rbetr = reguh-rbetr * -1.

              IF reguh-ind_rechazo = 'X' .
                tabla_trab-estado = 'Rechazado'.
                tabla_trab-bloqueo = '1'.
              ELSE.
                IF reguh-ind_pago = 'X'.
                  tabla_trab-estado = 'Ya Pagado'.
                  tabla_trab-bloqueo = '1'.
                ELSE.
                  tabla_trab-estado = 'Proceso Pago'.
                  tabla_trab-bloqueo = '0'.
                ENDIF.
              ENDIF.

              tabla_trab-motivo_rechazo = tl_exc-motivo.
              tabla_trab-sel = ''.
              tabla_trab-zz_agencia = bseg-zz_agencia.

*ReSQ: No Need Of Change Internal Table TAGE Already Sorted
              READ TABLE tage WITH KEY bukrs         =  bukrs
                                    zzcod_unidad    =  bseg-zz_agencia
                                    BINARY SEARCH.

              IF sy-subrc <> 0.
                tabla_trab-zz_agencia_des  = 'Sin Descripcion'.
              ELSE.
                tabla_trab-zz_agencia_des = tage-zzdescr.
              ENDIF.
              bloqueo =  tabla_trab-bloqueo.
              APPEND tabla_trab.

            ENDSELECT.
          ENDIF.
        ENDIF.


      ENDIF.
      mensaje =''.
    ELSE.
      mensaje = 'Proveedor no Existe' .
    ENDIF.

    DESCRIBE TABLE tabla_trab LINES fill.
    IF fill = 1 AND bloqueo = 0.
      LOOP AT tabla_trab.
        MOVE-CORRESPONDING tabla_trab TO int_tabla2.
        int_tabla2-nrolinea = linea.
        int_tabla2-rut = rut.
        int_tabla2-name1 = lfa1-name1.
        int_tabla2-lifnr = lfa1-lifnr.
        int_tabla2-banco = tl_exc-banco.
        int_tabla2-cuenta = tl_exc-cuenta.
        int_tabla2-emision = tl_exc-emision.
        int_tabla2-valor = valor_rec.
        int_tabla2-motivo_rechazo = tl_exc-motivo.
        int_tabla2-observacion = ''.
        int_tabla2-proceso = 'A'.
        APPEND int_tabla2.
        monto_i =  monto_i + int_tabla2-rbetr.
        monto_p = monto_r  -  monto_i.
      ENDLOOP.
    ELSE.
      IF fill = 0.
        CLEAR int_tabla.
        int_tabla-nrolinea = linea.
        int_tabla-rut = rut.
        int_tabla-name1 = lfa1-name1.
        int_tabla-lifnr = lfa1-lifnr.
        int_tabla-banco = tl_exc-banco.
        int_tabla-cuenta = tl_exc-cuenta.
        int_tabla-emision = tl_exc-emision.
        int_tabla-motivo_rechazo = tl_exc-motivo.
        int_tabla-valor = valor_rec.
        IF mensaje = ''.
          int_tabla-observacion = 'Sin registros Pago'.
        ELSE.
          int_tabla-observacion = mensaje.
        ENDIF.
        APPEND int_tabla.
      ELSE.
        CLEAR int_tabla.
        int_tabla-nrolinea = linea.
        int_tabla-rut = rut.
        int_tabla-name1 = lfa1-name1.
        int_tabla-lifnr = lfa1-lifnr.
        int_tabla-banco = tl_exc-banco.
        int_tabla-cuenta = tl_exc-cuenta.
        int_tabla-emision = tl_exc-emision.
        int_tabla-valor = valor_rec.
        int_tabla-motivo_rechazo = tl_exc-motivo.
        int_tabla-observacion = 'Rec./Pag. o Mas de un acierto'.
        APPEND int_tabla.
        LOOP AT tabla_trab.

          MOVE-CORRESPONDING tabla_trab TO tabla_aux .
          int_tabla-nrolinea = linea.
          tabla_aux-rut = rut.
          tabla_aux-name1 = lfa1-name1.
          tabla_aux-lifnr = lfa1-lifnr.
          tabla_aux-banco = tl_exc-banco.
          tabla_aux-cuenta = tl_exc-cuenta.
          tabla_aux-emision = tl_exc-emision.
          tabla_aux-valor = valor_rec.
          tabla_aux-motivo_rechazo = tl_exc-motivo.
          tabla_aux-nrolinea = linea.
          APPEND tabla_aux.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SORT int_tabla  BY rbetr  vblnr.
  DESCRIBE TABLE int_tabla LINES fill.
  tabla-lines = fill.
  tabla-top_line = 1.

  DESCRIBE TABLE int_tabla LINES fill.
  tabla-lines = fill.
  tabla-top_line = 1.
  DESCRIBE TABLE int_tabla2 LINES fill.
  tabla2-lines = fill.
  tabla2-top_line = 1.

  SORT int_tabla  BY nrolinea .
  SORT int_tabla2 BY nrolinea  .

ENDFORM.                    " CARGA_TABLA

*&---------------------------------------------------------------------*
*&      Form  CARGA_TABLA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM carga_tabla2.
  LOOP AT int_tabla WHERE sel = 'X'.

    MOVE-CORRESPONDING int_tabla TO int_tabla2.
    IF int_tabla-bloqueo = 0.
      int_tabla2-lifnr = lfa1-lifnr.
      int_tabla2-name1 = lfa1-name1.
      monto_i =  monto_i + int_tabla2-rbetr.
      int_tabla2-sel = ''.
      APPEND  int_tabla2.
      DELETE int_tabla.
      monto_p = monto_r  -  monto_i.
    ELSE.
      int_tabla-sel = ''.
      MODIFY int_tabla.
    ENDIF.

  ENDLOOP.


  DESCRIBE TABLE int_tabla LINES fill.
  tabla-lines = fill.
  tabla-top_line = 1.
  DESCRIBE TABLE int_tabla2 LINES fill.
  tabla2-lines = fill.
  tabla2-top_line = 1.

  SORT int_tabla  BY nrolinea.
  SORT int_tabla2 BY nrolinea.

ENDFORM.                    "carga_tabla2

*&---------------------------------------------------------------------*
*&      Form  elimina_tabla2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM elimina_tabla2.
  DATA numero LIKE int_tabla-nrolinea.
  DATA monto LIKE monto_i.

  int_tabla2_aux[] = int_tabla2[].

  LOOP AT int_tabla2_aux WHERE sel = 'X'.
    IF int_tabla2-proceso = 'M'.
      LOOP AT int_tabla2 WHERE nrolinea = int_tabla2_aux-nrolinea.
        monto =  monto + int_tabla2-rbetr.
        monto_i =  monto_i - int_tabla2-rbetr.
        monto_p = monto_r  -  monto_i.
        DELETE int_tabla2.
      ENDLOOP.
      MOVE-CORRESPONDING int_tabla2_aux TO int_tabla.
      int_tabla-valor = monto.
      APPEND  int_tabla.
    ELSE.
      MESSAGE i016(z1) WITH 'Registro no se puede ' 'eliminar asignado automatico'.
    ENDIF.
  ENDLOOP.



  DESCRIBE TABLE int_tabla2 LINES fill.
  tabla2-lines = fill.
  tabla2-top_line = 1.
  DESCRIBE TABLE int_tabla LINES fill.
  tabla-lines = fill.
  tabla-top_line = 1.

  SORT int_tabla  BY nrolinea.
  SORT int_tabla2 BY nrolinea.
ENDFORM.                    "elimina_tabla2
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLA_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_tabla_control_0100 OUTPUT.
  READ TABLE int_tabla INTO zfitr035_est INDEX tabla-current_line.

ENDMODULE.                 " FILL_TABLA_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ACTUALIZA_GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE actualiza_grilla_0100 INPUT.
  MODIFY int_tabla FROM zfitr035_est INDEX tabla-current_line
      TRANSPORTING sel motivo_rechazo.
ENDMODULE.                 " ACTUALIZA_GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLA_2_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_tabla_2_control_0100 OUTPUT.
  READ TABLE int_tabla2 INTO zfitr035_est1 INDEX tabla2-current_line.
ENDMODULE.                 " FILL_TABLA_2_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ACTUALIZA_GRILLA_2_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE actualiza_grilla_2_0100 INPUT.
  MODIFY int_tabla2 FROM zfitr035_est1 INDEX tabla2-current_line
        TRANSPORTING sel.
ENDMODULE.                 " ACTUALIZA_GRILLA_2_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  CONTABILIZAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM contabilizar .

* Inicio Mod. Fosorio se comenta condición OR 25.10.2013

  IF monto_p <> 0.  "OR canti_p <> 0.

* Fin Mod. Fosorio se comenta condición OR 25.10.2013

    MESSAGE e016(z1) WITH 'Monto o Cantidad pendiente deben ser igual a cero. ' 'No se permite Contabilizacion'.
  ELSE.
    CALL SCREEN 200 STARTING AT 40 10
            ENDING   AT 100 18.
  ENDIF.


ENDFORM.                    " CONTABILIZAR
*&---------------------------------------------------------------------*
*&      Form  cargo_tabla3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cargo_tabla3.
  REFRESH int_tabla3.

  LOOP AT tabla_aux WHERE nrolinea = zfitr035_est-nrolinea.
    MOVE-CORRESPONDING tabla_aux TO int_tabla3.
    APPEND int_tabla3.

  ENDLOOP.

  DESCRIBE TABLE int_tabla3 LINES fill.
  tabla3-lines = fill.
  tabla3-top_line = 1.

ENDFORM.                    "cargo_tabla3
