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

  SET  PF-STATUS 'ZFITR013' EXCLUDING tab.
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
    WHEN 'BUSCA'.
      CLEAR sy-ucomm.
      PERFORM carga_tabla.
    WHEN 'RECH'.
      CLEAR sy-ucomm.
      PERFORM carga_tabla2.
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
  REFRESH int_tabla.


  SELECT SINGLE * FROM lfa1 WHERE lifnr = *lfa1-lifnr.

  IF sy-subrc <> 0.
    MESSAGE e016(z1) WITH 'Proveedor  no Existe' rzawe.
  ENDIF.


  SELECT * FROM reguh WHERE valut IN  v_fecha
                     AND   zbukr = bukrs
                     AND   hbkid = v_hbkid
                     AND   lifnr = *lfa1-lifnr
                     AND   rzawe = rzawe
                     AND   xvorl = ''.

    READ TABLE int_tabla2 WITH KEY   laufi = reguh-laufi
                               laufd = reguh-laufd
                               vblnr = reguh-vblnr
                               lifnr = reguh-lifnr.
    IF sy-subrc <> 0.

      int_tabla-laufi = reguh-laufi.
      int_tabla-laufd = reguh-laufd.
      int_tabla-vblnr = reguh-vblnr.
      int_tabla-valut = reguh-valut.
      int_tabla-rbetr = reguh-rbetr * -1.

      IF reguh-ind_rechazo = 'X' .
        int_tabla-estado = 'Rechazado'.
        int_tabla-bloqueo = 1.
      ELSE.
*Begin of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
SORT TAGE BY BUKRS ZZCOD_UNIDAD .
*End of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 24/12/2019 EY_DES02 ECDK917080 *
        int_tabla-estado = 'Pagado'.
        int_tabla-bloqueo = 0.
      ENDIF.

      int_tabla-motivo_rechazo = reguh-motivo_rechazo.
      int_tabla-sel = ''.

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
      SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
                                      AND   laufi = reguh-laufi
                                      AND   xvorl = reguh-xvorl
                                      AND   zbukr = reguh-zbukr
                                      AND   lifnr = reguh-lifnr
                                      AND   kunnr = reguh-kunnr
                                      AND   empfg = reguh-empfg
                                      AND   vblnr = reguh-vblnr.

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
      SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
                             AND  belnr = regup-belnr
                             AND  gjahr = regup-gjahr
                             AND  buzei = regup-buzei.

      int_tabla-zz_agencia = bseg-zz_agencia.

      READ TABLE tage WITH KEY bukrs         =  bukrs
                            zzcod_unidad    =  int_tabla-zz_agencia
                            BINARY SEARCH.

      IF sy-subrc <> 0.
        tage-zzdescr  = 'Sin Descripcion'.
      ELSE.
        int_tabla-zz_agencia_des = tage-zzdescr.
      ENDIF.


      APPEND int_tabla.
    ENDIF.
  ENDSELECT.
  SORT int_tabla  BY rbetr  vblnr.
  DESCRIBE TABLE int_tabla LINES fill.
  tabla-lines = fill.
  tabla-top_line = 1.





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


      IF NOT int_tabla2-motivo_rechazo IS INITIAL OR
         NOT motivo_rechazo_gen  IS INITIAL.

        IF  int_tabla2-motivo_rechazo IS INITIAL.
          int_tabla2-motivo_rechazo = motivo_rechazo_gen.
        ENDIF.
        int_tabla2-lifnr = lfa1-lifnr.
        int_tabla2-name1 = lfa1-name1.
        monto_i =  monto_i + int_tabla2-rbetr.
        canti_i  = canti_i + 1.
        int_tabla2-sel = ''.
        APPEND  int_tabla2.
        DELETE int_tabla.



        monto_p = monto_r  -  monto_i.
        canti_p  = canti_r - canti_i.
      ELSE.
        MESSAGE e016(z1) WITH 'Debe Ingresar Motivo de Rechazo'  .
      ENDIF.

    ELSE.
      int_tabla-sel = ''.
      MODIFY int_tabla.
    ENDIF.

  ENDLOOP.

  CLEAR motivo_rechazo_gen.

  DESCRIBE TABLE int_tabla LINES fill.
  tabla-lines = fill.
  tabla-top_line = 1.
  DESCRIBE TABLE int_tabla2 LINES fill.
  tabla2-lines = fill.
  tabla2-top_line = 1.

  SORT int_tabla  BY rbetr  vblnr.
  SORT int_tabla2 BY lifnr rbetr  vblnr.

ENDFORM.                    "carga_tabla2

*&---------------------------------------------------------------------*
*&      Form  elimina_tabla2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM elimina_tabla2.
  LOOP AT int_tabla2 WHERE sel = 'X'.
    int_tabla2-sel = ''.
    IF int_tabla2-lifnr  = *lfa1-lifnr.
      MOVE-CORRESPONDING int_tabla2 TO int_tabla.
      CLEAR int_tabla-motivo_rechazo.
      APPEND  int_tabla.
    ENDIF.

    monto_i =  monto_i - int_tabla2-rbetr.
    canti_i  = canti_i - 1.
    monto_p = monto_r  -  monto_i.
    canti_p  = canti_r - canti_i.

    DELETE int_tabla2.
  ENDLOOP.
  DESCRIBE TABLE int_tabla2 LINES fill.
  tabla2-lines = fill.
  tabla2-top_line = 1.
  DESCRIBE TABLE int_tabla LINES fill.
  tabla-lines = fill.
  tabla-top_line = 1.

  SORT int_tabla  BY rbetr  vblnr.
  SORT int_tabla2 BY lifnr rbetr  vblnr.
ENDFORM.                    "elimina_tabla2
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLA_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_tabla_control_0100 OUTPUT.
  READ TABLE int_tabla INTO zfitr013_est INDEX tabla-current_line.

  LOOP AT SCREEN .
    IF screen-name  = 'ZFITR013_EST-MOTIVO_RECHAZO'.
      IF zfitr013_est-estado = 'Rechazado'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDMODULE.                 " FILL_TABLA_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ACTUALIZA_GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE actualiza_grilla_0100 INPUT.
  MODIFY int_tabla FROM zfitr013_est INDEX tabla-current_line
      TRANSPORTING sel motivo_rechazo.


ENDMODULE.                 " ACTUALIZA_GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLA_2_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_tabla_2_control_0100 OUTPUT.
  READ TABLE int_tabla2 INTO zfitr013_est1 INDEX tabla2-current_line.
ENDMODULE.                 " FILL_TABLA_2_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ACTUALIZA_GRILLA_2_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE actualiza_grilla_2_0100 INPUT.
  MODIFY int_tabla2 FROM zfitr013_est1 INDEX tabla2-current_line
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
