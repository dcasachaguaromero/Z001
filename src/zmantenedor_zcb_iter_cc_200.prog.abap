*&---------------------------------------------------------------------*
*&  Include           ZFIPG001_200
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

  SET PF-STATUS 'ZFIPG001' EXCLUDING tab.

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
        PERFORM proceso.
        LEAVE TO SCREEN 0.
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

  LOOP AT SCREEN.
    IF screen-name = 'ZCB_ITER_CC_EST-SECUENCIA' OR  screen-name = 'ZCB_ITER_CC_EST-CODITER'.
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

  MOVE-CORRESPONDING zcb_iter_cc_est TO zcb_iter_cc.
  MOVE bukrs                         TO zcb_iter_cc-bukrs.
  INSERT zcb_iter_cc.
  IF sy-subrc = 0.
    MESSAGE 'Registro exitoso!' TYPE 'S'.
  ELSE.
    MESSAGE 'Ya existe el registro' TYPE 'E'.
  ENDIF.
  PERFORM proceso.
  CALL SCREEN 100.
  CLEAR: zcb_iter_cc_est.

ENDFORM.                    "INGRESO_BASE

*---------------------------------------------------------------------*
*       FORM actualiza_BASE                                           *
*---------------------------------------------------------------------*
FORM actualizo_base.

  MODIFY int_tabla FROM zcb_iter_cc_est.
  MODIFY zcb_iter_cc FROM zcb_iter_cc_est.

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
    DELETE FROM zcb_iter_cc WHERE bukrs =  int_tabla-bukrs
                            AND   hbkid =  int_tabla-hbkid
                            AND   hktid =  int_tabla-hktid
                            AND   secuencia =  int_tabla-secuencia
                            AND   coditer =  int_tabla-coditer.
  ENDIF.

ENDFORM.                    "ELIMINO_BASE

*&---------------------------------------------------------------------*
*&      Module  VALIDO-PANTALLA2  INPUT
*&---------------------------------------------------------------------*
MODULE valido-pantalla_0200 INPUT.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE descrip FROM zcb_iter
*    INTO zcb_iter_cc_est-descrip
*    WHERE coditer = zcb_iter_cc_est-coditer.
*
* NEW CODE
  SELECT descrip
  UP TO 1 ROWS  FROM zcb_iter
    INTO zcb_iter_cc_est-descrip
    WHERE coditer = zcb_iter_cc_est-coditer ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*  IF sy-ucomm <> 'CANC'.
*    PERFORM valido_0200.
*  ENDIF.

ENDMODULE.                             " VALIDO-PANTALLA2  INPUT

*---------------------------------------------------------------------*
*       FORM valido_2000
*---------------------------------------------------------------------*
FORM valido_0200.

*  IF accion <> 'M'.
*    IF zfipg001_est-blart IS INITIAL.
*      MESSAGE e004(zfi) WITH 'Debe Ingresar Clase de Documento'.
*    ENDIF.
*
*    SELECT SINGLE * FROM zfipg001 WHERE bukrs =  bukrs
*                           AND   blart =  zfipg001_est-blart.
*
*    IF sy-subrc = 0.
*      MESSAGE e004(zfi) WITH 'Clase de Documento ya Existe'.
*    ENDIF.
*
*    SELECT SINGLE * FROM t003 WHERE blart =  zfipg001_est-blart.
*
*    IF sy-subrc <> 0.
*      MESSAGE e004(zfi) WITH 'Clase de Documento no Existe'.
*    ENDIF.
*
*  ENDIF.
*
*  SELECT SINGLE * FROM t003t WHERE   spras  = sy-langu
*                             AND    blart  = zfipg001_est-blart.
*
*  IF sy-subrc <> 0.
*    t003t-ltext = '?????'.
*  ENDIF.
*
*  IF zfipg001_est-descr IS INITIAL.
*    zfipg001_est-descr = t003t-ltext.
*  ENDIF.

ENDFORM.                    "VALIDO_0200
