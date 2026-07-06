*&---------------------------------------------------------------------*
*&  Include          zcb_ccpgm_F02
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

  SET PF-STATUS 'ZCB_CCPGM' EXCLUDING tab.

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
*      IF screen-name = 'ZFICH002_EST-ESTADO'.
    IF screen-name = 'ZCB_CCOSTO_EST-BUKRS'.
      IF accion <>  'M'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
    IF screen-name = 'ZCB_CCOSTO_EST-KOSTL'.
      screen-input = 1.
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
*  MOVE   p_bukrs                  TO zcb_ccosto-bukrs.
  MOVE-CORRESPONDING zcb_ccosto_est TO zcb_ccosto.

  INSERT zcb_ccosto.

  CLEAR zcb_ccosto_est.
*  MOVE p_bukrs                     TO zcb_ccosto_est-bukrs.

ENDFORM.                    "ingreso_base

*---------------------------------------------------------------------*
*       FORM actualiza_BASE                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM actualizo_base.

  int_tabla-kostl      = zcb_ccosto_est-kostl.
  MODIFY int_tabla.

  MOVE-CORRESPONDING zcb_ccosto_est       TO zcb_ccosto.

  MODIFY zcb_ccosto.

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
    DELETE  FROM zcb_ccosto WHERE bukrs = int_tabla-bukrs.
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
    IF zcb_ccosto_est-bukrs IS INITIAL.
      MESSAGE e004(zfi) WITH 'Debe ingresar Sociedad'.
    ELSE.
      SELECT SINGLE * FROM t001
             WHERE bukrs = zcb_ccosto_est-bukrs.
      IF sy-subrc <> 0.
        MESSAGE e004(zfi) WITH 'Debe ingresar Sociedad Vàlida'.
      ELSE.
        zcb_ccosto_est-butxt = t001-butxt.
      ENDIF.
      SELECT SINGLE * FROM zcb_ccosto
          WHERE bukrs = zcb_ccosto_est-bukrs.
      IF sy-subrc = 0.

        MESSAGE e004(zfi) WITH 'Sociedad ya tiene asignado Centro Costo'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF zcb_ccosto_est-kostl IS INITIAL.
    MESSAGE e004(zfi) WITH 'Debe ingresar Centro de Costo'.
  ELSE.
    SELECT SINGLE * FROM csks
          WHERE kokrs = 'BMSA'
            AND kostl =   zcb_ccosto_est-kostl
            AND datbi >= sy-datum.
    IF sy-subrc <> 0 OR csks-kostl+0(4) <> zcb_ccosto_est-bukrs.
      MESSAGE e004(zfi) WITH 'Centro de costo no valido para sociedad'.
    ENDIF.
  ENDIF.

ENDFORM.                    "valido_0200
