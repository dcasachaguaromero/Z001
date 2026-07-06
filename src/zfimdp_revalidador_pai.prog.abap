*&---------------------------------------------------------------------*
*&  Include           ZFIMDP_REVALIDADOR_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'EXIT' OR 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EJECUTAR'.
      PERFORM ejecuta_consulta.
    WHEN 'IMPTABLE'.
      REFRESH t_data1.
      CLEAR t_data1.
      LOOP AT t_data.
        TRANSLATE t_data-dmbtr USING '. '.
        CONDENSE t_data-dmbtr NO-GAPS.
        MOVE-CORRESPONDING t_data TO t_data1.
        APPEND t_data1.
      ENDLOOP.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_structure_name = 'ZREVALIDADOR'
        TABLES
          t_outtab         = t_data1
        EXCEPTIONS
          program_error    = 1
          OTHERS           = 2.
      CLEAR sy-ucomm.
    WHEN 'TIMBRE'.
      READ TABLE t_data WITH KEY marca = 'X'.
      IF sy-subrc NE 0.
        MESSAGE 'Debe seleccionar al menos un registro.' TYPE 'I'.
      ELSE.
* Se despliega reporte con la información requerida según requerimiento
        PERFORM reporte.
        WHILE sy-ucomm <> 'PRIN'.
          PERFORM reporte.
        ENDWHILE.
*
        paso_data = t_data.
        REFRESH ti_cheque.
        CLEAR: v_totaltimbre, totaltimbre, v_totalcheque.
        LOOP AT t_data WHERE marca = 'X'
                         AND status NE c_timbrado.
          ti_cheque-zuonr = t_data-zuonr.
          APPEND ti_cheque.
          TRANSLATE t_data-dmbtr USING '. '.
          CONDENSE t_data-dmbtr NO-GAPS.
          v_totaltimbre = v_totaltimbre + t_data-dmbtr.
        ENDLOOP.
        DESCRIBE TABLE ti_cheque.
        CHECK sy-tfill > 0.
        totaltimbre = v_totaltimbre.
        totaltimbre1 = totaltimbre.
        totaltimbre1 = totaltimbre1 / 100.
        WRITE totaltimbre1 CURRENCY 'CLP' TO totaltimbre.
        SORT ti_cheque BY zuonr.
        DELETE ADJACENT DUPLICATES FROM ti_cheque.
        DESCRIBE TABLE ti_cheque LINES v_totalcheque.
* Se despliega popup con información de cantidad y monto de los cheques
* seleccionados a imprimir
        CLEAR: texto1, texto2, v_answer.
        CONDENSE: v_totalcheque NO-GAPS,
                  totaltimbre NO-GAPS.
        CONCATENATE 'Se efectuará impresión de' v_totalcheque 'cheque(s)'
             INTO texto1 SEPARATED BY space.
        CONCATENATE 'por un monto total de $' totaltimbre INTO texto2.
        CALL FUNCTION 'POPUP_TO_DECIDE_WITH_MESSAGE'
          EXPORTING
            defaultoption  = '1'
            diagnosetext1  = texto1
            diagnosetext2  = texto2
            textline1      = '¿Continúa con la impresión?'
            text_option1   = 'Si'
            text_option2   = 'No'
            titel          = 'Impresión de cheques'
            cancel_display = ' '
          IMPORTING
            answer         = v_answer.

        IF v_answer = 1.
* Se desencriptan las firmas
          SET PARAMETER ID 'BUK' FIELD paso_data-bukrs.
          CLEAR error.
          CALL TRANSACTION 'ZIMP_CHEQUE_REVALIDA'.
          IMPORT error FROM MEMORY ID 'ERR'.
          IMPORT ejecuta FROM MEMORY ID 'EJE'.
* Si ejecuta = 'X' ==> Se ejecutó programa de desencriptación
          IF ejecuta = 'X'.
            IF error IS INITIAL.
* Se imprimen los cheques revalidados
              PERFORM imprime_data.
* Se eliminan las firmas
              PERFORM borra_firmas IN PROGRAM zimp_cheque_revalida.
* Se refresca la información de la grilla del Table Control
              PERFORM ejecuta_consulta.
              REFRESH CONTROL 'TC_REVALIDA' FROM SCREEN '0100'.
            ELSE.
* Problema en las firmas, por lo tanto no se imprimió nada.
*              MESSAGE 'Existen problemas al desencriptar firmas, favor revisar.'
*                       TYPE 'I'.
            ENDIF.
          ELSE.
* NO se ejecutó programa ==> Repetir desencriptación
            MESSAGE 'Debe ejecutar desencriptación antes de continuar con el proceso.'
                     TYPE 'I'.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR sy-ucomm.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  TC_POS_MARK  INPUT
*&---------------------------------------------------------------------*
MODULE tc_pos_mark INPUT.
  DATA: g_tc_pos LIKE LINE OF t_data.
  IF tc_revalida-line_sel_mode = 1
  AND t_data-marca = 'X'.
    LOOP AT t_data INTO g_tc_pos
      WHERE marca = 'X'.
      g_tc_pos-marca = ''.
      MODIFY t_data
        FROM g_tc_pos
        TRANSPORTING marca.
    ENDLOOP.
  ENDIF.
  MODIFY t_data
    INDEX tc_revalida-current_line
    TRANSPORTING marca.
ENDMODULE.                 " TC_POS_MARK  INPUT

*&---------------------------------------------------------------------*
*&      Module  TC_REVALIDA_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE tc_revalida_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_REVALIDA'
                              'T_DATA'
                              'MARCA'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                 " TC_REVALIDA_USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  REVISA_CUENTA  INPUT
*&---------------------------------------------------------------------*
MODULE revisa_cuenta INPUT.
  DATA: fld(20) TYPE c,
        off     TYPE i,
        val(20) TYPE c,
        len     TYPE i.

  GET CURSOR FIELD fld OFFSET off VALUE val LENGTH len.

  IF sy-subrc EQ 0.
    IF fld = 'T_DATA-BELNR' AND ok_code = 'EJECUTAR'.
      READ TABLE t_data WITH KEY belnr = val.
      IF sy-subrc EQ 0.
        SET PARAMETER ID 'BLN' FIELD t_data-belnr.
        SET PARAMETER ID 'BUK' FIELD t_data-bukrs.
        SET PARAMETER ID 'GJR' FIELD t_data-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " REVISA_CUENTA  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_exit INPUT.

  CASE sy-ucomm.
    WHEN 'EXIT' OR 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_EXIT  INPUT
