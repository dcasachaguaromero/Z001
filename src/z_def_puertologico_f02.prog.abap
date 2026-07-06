*&---------------------------------------------------------------------*
*&  Include           ZWSPROXY_F02
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

  SET PF-STATUS 'ZWSPROXY' EXCLUDING tab.

ENDMODULE.                             " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_EXIT_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'CANCL'.

        PERFORM proceso.

      LEAVE  TO SCREEN 0.
  ENDCASE.

ENDMODULE.
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
    IF screen-name = 'ZWSPROXY_EST-ESTADO'.
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
  MOVE   p_bukrs                  TO zws_puerto_est-sociedad.
  MOVE-CORRESPONDING zws_puerto_est TO zws_puerto.

  INSERT zws_puerto.

* Solo un puerto habilitado por cada sociedad/programa
  if zws_puerto_est-estado = 'H'.
    update zws_puerto set estado = 'I'
    where sociedad = zws_puerto_est-sociedad
    and programa = zws_puerto_est-programa
    and puerto <> zws_puerto_est-puerto.
  endif.

  CLEAR zws_puerto_est.
  MOVE p_bukrs                     TO zws_puerto_est-sociedad.

ENDFORM.                    "ingreso_base

*---------------------------------------------------------------------*
*       FORM actualiza_BASE                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM actualizo_base.

  int_tabla-estado     = zws_puerto_est-estado.
  MODIFY int_tabla.

  MOVE-CORRESPONDING zws_puerto_est       TO zws_puerto.

  MODIFY zws_puerto.

* Solo un puerto habilitado por cada sociedad/programa
  if zws_puerto_est-estado = 'H'.
    update zws_puerto set estado = 'I'
    where sociedad = zws_puerto_est-sociedad
    and programa = zws_puerto_est-programa
    and puerto <> zws_puerto_est-puerto.
  endif.

ENDFORM.                    "actualizo_base

*---------------------------------------------------------------------*
*       FORM ELIMINO_BASE                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM elimino_base .

  IF int_tabla-estado = 'H'.
    MESSAGE e004(ZFI) WITH 'No puede eliminar puerto habilitado'.
  ELSE.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Confirmacion '
        text_question         = 'Esta seguro de borrar informacion?'
        default_button        = '2'
        display_cancel_button = 'X'
      IMPORTING
        answer                = resp.

    IF sy-subrc = 0 AND resp = '1'.
      DELETE  FROM zws_puerto WHERE sociedad = int_tabla-sociedad
                                and programa = int_tabla-programa
                                and puerto = int_tabla-puerto.
    ENDIF.
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

  MOVE p_bukrs                     TO zws_puerto_est-sociedad.

  IF accion <> 'M'.
    IF zws_puerto_est-programa IS INITIAL.
      MESSAGE e004(ZFI) WITH 'Debe ingresar Nombre de Programa'.
    ENDIF.
    IF zws_puerto_est-puerto IS INITIAL.
      MESSAGE e004(ZFI) WITH 'Debe ingresar Puerto de WS'.
    ENDIF.

*    READ TABLE int_tabla WITH
*                         KEY sociedad = zws_puerto_est-sociedad.
*                         BINARY SEARCH.

    select * FROM zws_puerto WHERE sociedad = zws_puerto_est-sociedad
                             and programa = zws_puerto_est-programa
                             and puerto = zws_puerto_est-puerto.
    endselect.
    IF sy-subrc = 0.
      MESSAGE e004(ZFI) WITH 'Puerto ya Existe para esta sociedad y programa'.
    ENDIF.

  ENDIF.

  IF zws_puerto_est-estado IS INITIAL.
    MESSAGE e004(ZFI) WITH 'Debe Ingresar Estado'.
  ENDIF.

ENDFORM.                    "valido_0200
