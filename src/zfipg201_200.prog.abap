*&---------------------------------------------------------------------*
*& Author: < PYV > *
*& Description: < Pagos masivos con Limite> *
*& Date: <31-01-2020> * *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG201_200
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  REFRESH tab.
  MOVE 'ACTUA' TO tab-fcode.
  APPEND tab.
  MOVE 'CREA' TO tab-fcode.
  APPEND tab.

  IF accion <>  'M'.
    MOVE 'ELIM' TO tab-fcode.
    APPEND tab.
  ENDIF.

  SET PF-STATUS 'ZFIPG201' EXCLUDING tab.

ENDMODULE.                             " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'CANC'.
      IF accion <> 'M'.
        PERFORM proceso.
      ENDIF.
      LEAVE  TO SCREEN 0.
    WHEN 'ELIM'.
      PERFORM elimino_base.
      IF resp = '1'.
        PERFORM proceso.
        LEAVE  TO SCREEN 0.
      ENDIF.
    WHEN 'GRABA'.
      IF accion <> 'M'.
        PERFORM ingreso_base.
      ELSE.
        PERFORM actualizo_base.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.

ENDMODULE.                             " USER_COMMAND_0200  INPUT

*---------------------------------------------------------------------*
*       MODULE PROTEJE_0200 OUTPUT                                    *
*---------------------------------------------------------------------*
MODULE proteje_0200 OUTPUT.

  DATA: x(1).

  x = '1'.

  LOOP AT SCREEN.
    IF screen-name = 'ZFIPG201_EST-ZZMOT_EMIS'
      or  screen-name = 'ZFIPG201_EST-BANCOP'.
      IF accion <>  'M'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                             " PROTEJE  OUTPUT

*---------------------------------------------------------------------*
*       FORM INGRESO_bASE                                             *
*---------------------------------------------------------------------*
FORM ingreso_base.

  MOVE-CORRESPONDING zfipg201_est TO zfipg201.

  MOVE bukrs    TO zfipg201-bukrs.
  Move sy-uname to zfipg201-zusuario.
  Move sy-datum to zfipg201-zfecha.
  Move sy-uzeit to zfipg201-zhora.
  INSERT zfipg201.

  CLEAR: zfipg201_est.

ENDFORM.                    "INGRESO_BASE

*---------------------------------------------------------------------*
*       FORM actualiza_BASE                                           *
*---------------------------------------------------------------------*
FORM actualizo_base.
  int_tabla-mandt          = zfipg201_est-mandt.
  int_tabla-bukrs          = zfipg201_est-bukrs.
  int_tabla-zzmot_emis     = zfipg201_est-zzmot_emis.
  int_tabla-bancop         = zfipg201_est-bancop.
  int_tabla-rmaxp          = zfipg201_est-rmaxp.
  int_tabla-rmaxb          = zfipg201_est-rmaxb.
  Move sy-uname to int_tabla-zusuariom.
  Move sy-datum to int_tabla-zfecham.
  Move sy-uzeit to int_tabla-zhoram.
*  int_tabla-zusuariom      = zfipg201_est-zusuariom.
* int_tabla-zfecham         = zfipg201_est-zfecham.
* int_tabla-zhoram          = zfipg201_est-zhoram.
  MODIFY int_tabla..

  MOVE-CORRESPONDING zfipg201_est to zfipg201.
  Move sy-uname to zfipg201-zusuariom.
  Move sy-datum to zfipg201-zfecham.
  Move sy-uzeit to zfipg201-zhoram.
  MODIFY zfipg201.

ENDFORM.                    "ACTUALIZO_BASE

*---------------------------------------------------------------------*
*       FORM ELIMINO_BASE                                             *
*---------------------------------------------------------------------*
FORM elimino_base.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Confirmación '
      text_question         = 'Esta Seguro de Borrar Informacion?'
      default_button        = '2'
      display_cancel_button = 'X'
    IMPORTING
      answer                = resp.

  IF sy-subrc = 0 AND resp = '1'.
    DELETE FROM zfipg201 WHERE bukrs =  int_tabla-bukrs
                           and zzmot_emis = int_tabla-zzmot_emis
                           and bancop = int_tabla-bancop.

  ENDIF.

ENDFORM.                    "ELIMINO_BASE

*&---------------------------------------------------------------------*
*&      Module  VALIDO-PANTALLA2  INPUT
*&---------------------------------------------------------------------*
MODULE valido-pantalla_0200 INPUT.

  IF sy-ucomm <> 'CANC'.
    PERFORM valido_0200.
  ENDIF.

ENDMODULE.                             " VALIDO-PANTALLA2  INPUT

*---------------------------------------------------------------------*
*       FORM valido_2000
*---------------------------------------------------------------------*
FORM valido_0200.

  IF accion <> 'M'.
    IF zfipg201_est-zzmot_emis IS INITIAL.
      MESSAGE e004(zfi) WITH 'Debe Ingresar Motivo Emision'.
    ENDIF.
    zfipg201_est-bukrs = bukrs.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM zmot_emis WHERE         bukrs =  zfipg201_est-bukrs
*                                     and    zzmot_emis =  zfipg201_est-zzmot_emis.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM zmot_emis WHERE         bukrs =  zfipg201_est-bukrs
                                     and    zzmot_emis =  zfipg201_est-zzmot_emis ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc <> 0.
      MESSAGE e004(zfi) WITH 'Motivo Emisiòn no Existe en Tabla'.
    ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM zfipg201 WHERE bukrs =  zfipg201_est-bukrs
*                             AND   zzmot_emis =  zfipg201_est-zzmot_emis
*                             AND       bancop =  zfipg201_est-bancop.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM zfipg201 WHERE bukrs =  zfipg201_est-bukrs
                             AND   zzmot_emis =  zfipg201_est-zzmot_emis
                             AND       bancop =  zfipg201_est-bancop ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      MESSAGE e004(zfi) WITH 'Motivo Emisiòn/Banco YA Existe'.
    ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t012 WHERE bukrs =  zfipg201_est-bukrs
*                             AND   HBKID  =  zfipg201_est-bancop.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t012 WHERE bukrs =  zfipg201_est-bukrs
                             AND   HBKID  =  zfipg201_est-bancop ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc <> 0.
      MESSAGE e004(zfi) WITH 'Banco Propio No existe'.
    ENDIF.
  ENDIF.
    IF zfipg201_est-rmaxp < 1 or zfipg201_est-rmaxp > 5000.
      MESSAGE e004(zfi) WITH 'Maximo proceso debe estar entre 1 y 5000'.
    ENDIF.

   IF zfipg201_est-rmaxb < 1 or zfipg201_est-rmaxb > 5000.
      MESSAGE e004(zfi) WITH 'Maximo banco debe estar entre 1 y 5000'.
    ENDIF.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
*  SELECT SINGLE * FROM t003t WHERE   spras  = sy-langu
*                             AND    blart  = zfipg201_est-blart.


ENDFORM.                    "VALIDO_0200
