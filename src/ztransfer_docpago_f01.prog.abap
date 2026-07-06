*&---------------------------------------------------------------------*
*&  Include           ZTRANSFER_DOCPAGO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VALIDAR_EJEC
*&---------------------------------------------------------------------*
FORM validar_ejec .
  CLEAR: gw_valida, gv_insmod, gv_message.

  SELECT SINGLE status usnam date_act
    FROM zfitr_tesdocpago
    INTO CORRESPONDING FIELDS OF gw_valida
    WHERE bukrs EQ gw_propuesta-zbukr AND
          laufd EQ gw_propuesta-laufd AND
          laufi EQ gw_propuesta-laufi.

  IF sy-subrc EQ 0 AND gw_valida-status EQ 'X'.
*    MESSAGE s899(mm) DISPLAY LIKE 'E' WITH text-m01 gw_valida-usnam gw_valida-date_act.
    CONCATENATE 'El usuario' gw_valida-usnam 'Genero propuesta de pago el' gw_valida-date_act INTO gv_message
    SEPARATED BY space.
    WRITE :/ gv_message.
    EXIT.
*    STOP.
  ELSEIF sy-subrc EQ 0 AND gw_valida-status NE 'X'.
    gv_insmod = 1.  " Modificar Registro Existente
  ELSE.
    gv_insmod = 2.  " Insertar Nuevo Registro
  ENDIF.
ENDFORM.                    " VALIDAR_EJEC
*&---------------------------------------------------------------------*
*&      Form  INSERT_TRANS
*&---------------------------------------------------------------------*

FORM insert_trans .
  IF gv_insmod IS NOT INITIAL.
    CALL FUNCTION 'ZINSERTA_TRANSFER'
      EXPORTING
        bukrs    = gw_propuesta-zbukr
        v_fecha  = gw_propuesta-laufd
        v_nomina = gw_propuesta-laufi
      IMPORTING
        status   = gv_status.
  ENDIF.
ENDFORM.                    " INSERT_TRANS
*&---------------------------------------------------------------------*
*&      Form  ACT_TABLA_Z
*&---------------------------------------------------------------------*
FORM act_tabla_z .
  DATA: lv_fecha   TYPE ze_fechora.
  CLEAR: gv_message, lv_fecha.
  CASE gv_insmod.
    WHEN 1. " Modificar
      IF gv_status NE 'X'. " Ejec. Incorrecta
        gw_tesdocpago-status = ''.
        gv_message = 'No se Inserto Propuesta de Pago'.
      ELSE.                " Ejec. Correcta
        gw_tesdocpago-status = 'X'.
        gv_message = 'Se Inserto Propuesta de Pago de forma Correcta'.
      ENDIF.
      CONCATENATE sy-datum+6(2)'.'sy-datum+4(2)'.'sy-datum(4)'/'sy-uzeit(2)':'sy-uzeit+2(2)':'sy-uzeit+4(2) INTO lv_fecha.
      gw_tesdocpago-bukrs = gw_propuesta-zbukr.
      gw_tesdocpago-laufd = gw_propuesta-laufd.
      gw_tesdocpago-laufi = gw_propuesta-laufi.
      gw_tesdocpago-usnam = sy-uname.
      gw_tesdocpago-date_act = lv_fecha.
      MODIFY zfitr_tesdocpago FROM gw_tesdocpago.
      COMMIT WORK AND WAIT.
*      WRITE :/ gv_message.
    WHEN 2. " Insertar
      IF gv_status NE 'X'. " Ejec. Incorrecta
        gw_tesdocpago-status = ''.
        gv_message = 'No se Inserto Propuesta de Pago'.
      ELSE.                " Ejec. Correcta
        gw_tesdocpago-status = 'X'.
        gv_message = 'Se Inserto Propuesta de Pago de forma Correcta'.
      ENDIF.
      CONCATENATE sy-datum+6(2)'.'sy-datum+4(2)'.'sy-datum(4)'/'sy-uzeit(2)':'sy-uzeit+2(2)':'sy-uzeit+4(2) INTO lv_fecha.
      gw_tesdocpago-bukrs = gw_propuesta-zbukr.
      gw_tesdocpago-laufd = gw_propuesta-laufd.
      gw_tesdocpago-laufi = gw_propuesta-laufi.
      gw_tesdocpago-usnam = sy-uname.
      gw_tesdocpago-date_act = lv_fecha.
      INSERT zfitr_tesdocpago FROM gw_tesdocpago.
      COMMIT WORK AND WAIT.
*      WRITE :/ gv_message.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " ACT_TABLA_Z
*&---------------------------------------------------------------------*
*&      Form  CONSUL_PROP
*&---------------------------------------------------------------------*
FORM consul_prop .

  SELECT laufd laufi zbukr
    FROM reguh
    INTO TABLE gt_propuesta
    WHERE laufd IN s_fecha AND
          zbukr IN s_zbukr AND
          xvorl NE 'X'     AND
          rzawe EQ 'T'.

SORT gt_propuesta by laufd laufi zbukr DESCENDING.
DELETE ADJACENT DUPLICATES FROM gt_propuesta.
ENDFORM.                    " CONSUL_PROP
