*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_200
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  REFRESH tab.

  tab-fcode = 'DETA'.
  APPEND tab.

  tab-fcode = 'EXCEL'.
  APPEND tab.

  SET PF-STATUS 'ZFIPG010' EXCLUDING tab.
  SET TITLEBAR 'T02'.

ENDMODULE.                             " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.

    WHEN 'BACK' OR '%EX'.
      LEAVE TO SCREEN 0.
    WHEN 'ASIGNAR'.
      PERFORM cambia_fecha.
    WHEN 'DESB'.
      PERFORM desbloquea.
    WHEN 'SEL'.
      GET CURSOR FIELD cursorfield.
      GET CURSOR LINE xlinea.
      IF xlinea > 0 AND xlinea <= tabla1-lines.
        xlinea = xlinea + tabla1-top_line - 1.
        READ TABLE int_tabla1 INDEX xlinea.
        PERFORM detalle_doc.
      ENDIF.


  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

**&---------------------------------------------------------------------
**   Lleno grilla con valores desde tabla
**----------------------------------------------------------------------
*&      Module  FILL_TABLE_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control_0200 OUTPUT.

  READ TABLE int_tabla1 INTO zfipg010_det_est INDEX tabla1-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT

*----------------------------------------------------------------------*
*  MODULE valida-grilla_0200 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE valida-grilla_0200 INPUT.

  MODIFY int_tabla1 FROM zfipg010_det_est INDEX tabla1-current_line
     TRANSPORTING sel.

ENDMODULE.                 " VALIDA-GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200_exit INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX'.
      LEAVE TO SCREEN 0.
    WHEN 'RW'.
      LEAVE PROGRAM.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0200_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Form  Cambia_Fecha
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cambia_fecha.

  DATA : modi(1).

  CLEAR modi.

  LOOP AT int_tabla1.

    IF int_tabla1-sel = 'X'.
      CLEAR int_tabla1-sel.
      MODIFY int_tabla1.

      CLEAR record.
      REFRESH record.
      MOVE-CORRESPONDING int_tabla1 TO record.
      MOVE bukrs                    TO record-bukrs.

      READ TABLE tpago WITH KEY lifnr = int_tabla1-lifnr
                                belnr = int_tabla1-belnr.
      MOVE tpago-sgtxt              TO record-sgtxt.

      IF int_tabla1-hbkid_1 IS NOT INITIAL.
        MOVE int_tabla1-hbkid_1     TO record-hbkid.
      ENDIF.
      IF int_tabla1-zzmot_emis_1 IS NOT INITIAL.
        MOVE int_tabla1-zzmot_emis_1 TO record-zzmot_emis.
      ENDIF.
      IF int_tabla1-zlsch_1 IS NOT INITIAL.
        MOVE int_tabla1-zlsch_1    TO record-zlsch.
      ENDIF.
      APPEND record.

      PERFORM batchinput USING '1'.

      modi = 'X'.
    ENDIF.

  ENDLOOP.

  IF modi IS INITIAL.
    MESSAGE s011(zfi).
  ELSE.
    LEAVE TO SCREEN 0.
  ENDIF.

  accion = ''.

ENDFORM.                    "Cambia_Fecha

*&---------------------------------------------------------------------*
*&      Form  Desbloquea
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM desbloquea.

  DATA : modi(1).

  CLEAR modi.

  LOOP AT int_tabla1.

    IF int_tabla1-sel = 'X'.
      CLEAR int_tabla1-sel.
      MODIFY int_tabla1.

      CLEAR record.
      REFRESH record.
      MOVE-CORRESPONDING int_tabla1 TO record.
      MOVE bukrs                    TO record-bukrs.
      APPEND record.

      PERFORM batchinput USING '2'.

      modi = 'X'.
    ENDIF.

  ENDLOOP.

  IF modi IS INITIAL.
    MESSAGE s011(zfi).
  ELSE.
    LEAVE TO SCREEN 0.
  ENDIF.

  accion = ''.

ENDFORM.                    "Desbloquea

*&---------------------------------------------------------------------*
*&      Form  BatchInput
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TIPO       text
*----------------------------------------------------------------------*
FORM batchinput USING tipo TYPE c.

  DATA : fecha(8)  TYPE c,
         zlspr_aux LIKE bsik-zlspr.

  IF tipo = '2'.
    CLEAR zlspr_aux.
  ENDIF.

  CLEAR fecha.
  IF NOT  bsik-zfbdt IS INITIAL.
    CONCATENATE bsik-zfbdt+6(2) bsik-zfbdt+4(2) bsik-zfbdt(4) INTO fecha.
  ENDIF.




  LOOP AT record.
    REFRESH bdcdata.

    IF zlsch_aux IS INITIAL.
      zlsch_aux = record-zlsch.
    ENDIF.

    IF hbkid_aux IS INITIAL.
      hbkid_aux = record-hbkid.
    ENDIF.

    IF zzmot_emis_aux IS INITIAL.
      zzmot_emis_aux = record-zzmot_emis.
    ENDIF.

    PERFORM bdc_dynpro      USING 'SAPMF05L' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05L-GJAHR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'RF05L-BELNR'
                                  record-belnr.
    PERFORM bdc_field       USING 'RF05L-BUKRS'
                                  record-bukrs.
    PERFORM bdc_field       USING 'RF05L-GJAHR'
                                  record-gjahr.

    PERFORM bdc_dynpro      USING 'SAPMF05L' '0700'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'BKPF-BELNR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ABZL'.
    PERFORM bdc_dynpro      USING 'SAPMF05L' '1130'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05L-BUZEI'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_field       USING 'RF05L-BUZEI'
                                  record-buzei .

    PERFORM bdc_dynpro      USING 'SAPMF05L' '0700'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05L-ANZDT(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=PK'.
    PERFORM bdc_dynpro      USING 'SAPMF05L' '0302'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'BSEG-SGTXT'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  'ZK'.
    IF  tipo = '2'.
      PERFORM bdc_field     USING 'BSEG-ZLSPR'
                                  zlspr_aux.
    ELSE.
      IF NOT fecha IS INITIAL.
        PERFORM bdc_field     USING 'BSEG-ZFBDT'
                                    fecha.
      ENDIF.

      IF NOT   zlsch_aux IS INITIAL.
        PERFORM bdc_field       USING 'BSEG-ZLSCH'
                                   zlsch_aux.
      ENDIF.

    ENDIF.

    PERFORM bdc_dynpro      USING 'SAPMF05L' '1302'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'BSEG-ZZMOT_EMIS'.

    IF  tipo = '1'.
      IF NOT  hbkid_aux IS INITIAL.
        PERFORM bdc_field       USING 'BSEG-HBKID'
                                     hbkid_aux.
      ENDIF.
      IF NOT  zzmot_emis_aux  IS INITIAL.
        PERFORM bdc_field       USING 'BSEG-ZZMOT_EMIS'
                                 zzmot_emis_aux.
      ENDIF.
    ENDIF.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.




    PERFORM bdc_dynpro      USING 'SAPMF05L' '0302'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'BSEG-ZTERM'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=AE'.




*    PERFORM bdc_field       USING 'BSEG-ZUONR'
*                                  record-zuonr.
*    PERFORM bdc_field       USING 'BSEG-SGTXT'
*                                  record-sgtxt.
*    PERFORM bdc_dynpro      USING 'SAPMF05L' '1302'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'BSEG-ZZMOT_EMIS'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=ENTR'.
*
**    PERFORM bdc_field       USING 'BSEG-FDLEV'
**                                  record-fdlev.
*
*    PERFORM bdc_dynpro      USING 'SAPMF05L' '0302'.
*    PERFORM bdc_field       USING 'BDC_CURSOR'
*                                  'BSEG-ZTERM'.
*    PERFORM bdc_field       USING 'BDC_OKCODE'
*                                  '=AE'.
*    PERFORM bdc_field       USING 'BSEG-ZTERM'
*                                  record-zterm.
*    PERFORM bdc_field       USING 'BSEG-ZFBDT'
*                                  fecha.
*
*    PERFORM bdc_field       USING 'BSEG-ZLSCH'
*                                  zlsch_aux.
*
*
*    PERFORM bdc_field       USING 'BSEG-ZLSPR'
*                                  zlspr_aux.

    CALL TRANSACTION 'FB02' USING bdcdata
                            MODE 'A'
                            UPDATE 'S'
                            MESSAGES INTO itab.

    LOOP AT itab.

      IF itab-msgid = 'F5' AND itab-msgnr = '312'.

      ENDIF.

    ENDLOOP.

  ENDLOOP.

ENDFORM.                    "BatchInput
*&---------------------------------------------------------------------*
*&      Module  VARIABLES_AUXILIARES1  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE variables_auxiliares1 OUTPUT.

  MOVE hbkid_aux      TO zfipg010_det_est-hbkid_1.
  MOVE zzmot_emis_aux TO zfipg010_det_est-zzmot_emis_1.
  MOVE zlsch_aux      TO zfipg010_det_est-zlsch_1.

ENDMODULE.                 " VARIABLES_AUXILIARES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  VARIABLES_AUXILIARES2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE variables_auxiliares2 INPUT.

  MOVE zfipg010_det_est-hbkid_1      TO hbkid_aux.
  MOVE zfipg010_det_est-zzmot_emis_1 TO zzmot_emis_aux.
  MOVE zfipg010_det_est-zlsch_1      TO zlsch_aux.

ENDMODULE.                 " VARIABLES_AUXILIARES2  INPUT
*&---------------------------------------------------------------------*
*&      Form  detalle_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM detalle_doc .
  SET PARAMETER ID 'BLN' FIELD int_tabla1-belnr.
  SET PARAMETER ID 'BUK' FIELD bukrs.
  SET PARAMETER ID 'GJR' FIELD int_tabla1-gjahr.
  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.


ENDFORM.                    "detalle_doc
