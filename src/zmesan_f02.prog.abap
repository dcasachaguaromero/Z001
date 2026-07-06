*&---------------------------------------------------------------------*
*&  Include          zmesan_F02
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  REFRESH tab.
  MOVE 'ACTU' TO tab-fcode.
  APPEND tab.
  MOVE 'CREA' TO tab-fcode.
  APPEND tab.

  IF accion <>  'M'.
    MOVE 'ELIM' TO tab-fcode.
    APPEND tab.
  ENDIF.

  SET PF-STATUS 'ZMESAN' EXCLUDING tab.

ENDMODULE.                             " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_exit_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'CANCL'.

      PERFORM proceso.

      LEAVE  TO SCREEN 0.
  ENDCASE.

ENDMODULE.                    "user_command_EXIT_0200 INPUT
*----------------------------------------------------------------------*
*  MODULE user_command_0200 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
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
        PERFORM proceso.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.

ENDMODULE.                             " USER_COMMAND_0200  INPUT

*---------------------------------------------------------------------*
*       MODULE PROTEJE_0200 OUTPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE proteje_0200 OUTPUT.

  DATA: x(1).

  x = '1'.

  LOOP AT SCREEN.
    IF screen-name = 'ZFIMOTEMISAN_EST-BUKRS'.
      IF accion <>  'M'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
    IF screen-name = 'ZFIMOTEMISAN_EST-ZMOTIV'.
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
*       ........                                                      *
*---------------------------------------------------------------------*
FORM ingreso_base.
*  MOVE   p_bukrs                  TO ZFIMOTEMISAN-bukrs.
  MOVE-CORRESPONDING zfimotemisan_est TO zfimotemisan.

  INSERT zfimotemisan.

  CLEAR zfimotemisan_est.
*  MOVE p_bukrs                     TO ZFIMOTEMISAN_EST-bukrs.

ENDFORM.                    "ingreso_base

*---------------------------------------------------------------------*
*       FORM actualiza_BASE                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM actualizo_base.

* int_tabla-kostl      = ZFIMOTEMISAN_EST-kostl.
  MODIFY int_tabla.

  MOVE-CORRESPONDING zfimotemisan_est       TO zfimotemisan.

  MODIFY zfimotemisan.

ENDFORM.                    "actualizo_base

*---------------------------------------------------------------------*
*       FORM ELIMINO_BASE                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM elimino_base .

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Confirmacion '
      text_question         = 'Esta seguro de borrar informacion?'
      default_button        = '2'
      display_cancel_button = 'X'
    IMPORTING
      answer                = resp.

  IF sy-subrc = 0 AND resp = '1'.
    DELETE  FROM zfimotemisan WHERE bukrs = int_tabla-bukrs
                               AND zmotiv = int_tabla-zmotiv.
  ENDIF.

ENDFORM.                    "elimino_base

*&---------------------------------------------------------------------*
*&      Module  VALIDO-PANTALLA2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valido-pantalla_0200 INPUT.

  IF sy-ucomm <> 'CANC'.
    PERFORM valido_0200.
  ENDIF.

ENDMODULE.                             " VALIDO-PANTALLA2  INPUT
*---------------------------------------------------------------------*
*       FORM valido_2000
*
*---------------------------------------------------------------------*
FORM valido_0200.

  IF accion <> 'M'.
    IF zfimotemisan_est-bukrs IS INITIAL.
      MESSAGE e004(zfi) WITH 'Debe ingresar Sociedad'.
    ELSE.
      SELECT SINGLE * FROM t001
             WHERE bukrs = zfimotemisan_est-bukrs.
      IF sy-subrc <> 0.
        MESSAGE e004(zfi) WITH 'Debe ingresar Sociedad Válida'.
      ELSE.
        zfimotemisan_est-butxt = t001-butxt.
      ENDIF.
      SELECT SINGLE * FROM zfimotemisan
          WHERE bukrs  = zfimotemisan_est-bukrs
            AND zmotiv = zfimotemisan_est-zmotiv.
      IF sy-subrc = 0.
        MESSAGE e004(zfi) WITH 'Sociedad/Motivo ya existe en tabla'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF zfimotemisan_est-zmotiv IS INITIAL.
    MESSAGE e004(zfi) WITH 'Debe ingresar MOTIVO DE EMISION'.
  ELSE.
    SELECT SINGLE * FROM zmot_emis
          WHERE bukrs = zfimotemisan_est-bukrs
            AND zzmot_emis = zfimotemisan_est-zmotiv.
    IF sy-subrc <> 0.
      MESSAGE e004(zfi) WITH 'MOTIVO Emisión no valido para sociedad'.
    ENDIF.
  ENDIF.

  IF zfimotemisan_est-znumero < 1 OR zfimotemisan_est-znumero > 8.
    MESSAGE e004(zfi) WITH 'Numero debe estar entre 1 y 8'.
  ENDIF.

  IF zfimotemisan_est-zletras IS INITIAL.
    MESSAGE e004(zfi) WITH 'Debe ingresar equivalencia en Letras'.
  ENDIF.

 IF zfimotemisan_est-zaccion <> 'R' and zfimotemisan_est-zaccion <> 'P'.
    MESSAGE e004(zfi) WITH 'Accion debe ser P o R'.
  ENDIF.
ENDFORM.                    "valido_0200
"valido_0200
