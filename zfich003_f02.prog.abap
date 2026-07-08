*&---------------------------------------------------------------------*
*&  Include           ZFICH003_F02
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

  SET PF-STATUS 'ZFICH003' EXCLUDING tab.

ENDMODULE.                             " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_EXIT_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'CANCL'.
      IF accion <> 'M'.
        PERFORM proceso.
      ENDIF.
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
    IF screen-name = 'ZFICH002_EST-ESTADO'.
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
  MOVE   p_bukrs                  TO zfich002_est-bukrs.
  MOVE-CORRESPONDING zfich002_est TO zfich002.

  INSERT zfich002.

  CLEAR zfich002_est.
  MOVE p_bukrs                     TO zfich002_est-bukrs.

ENDFORM.                    "ingreso_base

*---------------------------------------------------------------------*
*       FORM actualiza_BASE                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM actualizo_base.

  int_tabla-descri     = zfich002_est-descri.
  int_tabla-tipo_est   = zfich002_est-tipo_est.
  int_tabla-shkzg      = zfich002_est-shkzg.
  int_tabla-gench      = zfich002_est-gench.
  MODIFY int_tabla.

  MOVE-CORRESPONDING zfich002_est       TO zfich002.

  MODIFY zfich002.

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
    DELETE  FROM zfich002 WHERE estado = int_tabla-estado. "#EC CI_NOFIRST
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
    IF zfich002_est-estado IS INITIAL.
      MESSAGE e004(ZFI) WITH 'Debe ingresar Código de Estado'.
    ENDIF.
    READ TABLE int_tabla WITH
                         KEY estado = zfich002_est-estado
                         BINARY SEARCH.
    IF sy-subrc = 0.
      MESSAGE e004(ZFI) WITH 'Código de Estado ya Existe'.
    ENDIF.
  ENDIF.

  IF zfich002_est-descri IS INITIAL.
    MESSAGE e004(ZFI) WITH 'Debe Ingresar Descripcion'.
  ENDIF.

  IF zfich002_est-tipo_est IS INITIAL.
    MESSAGE e004(ZFI) WITH 'Debe Ingresar Tipo de Estado'.
  ENDIF.

  IF zfich002_est-tipo_est = 'C' AND zfich002_est-shkzg IS INITIAL.
    MESSAGE e004(ZFI) WITH 'Debe Ingresar indicador D/H'.
  ENDIF.

  IF zfich002_est-tipo_est = 'L'.
     CLEAR  zfich002_est-shkzg .
  ENDIF.

ENDFORM.                    "valido_0200
