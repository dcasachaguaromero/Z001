*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_100
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   INCLUDE ZCLPRFI_SIMFIN12_100_I                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  REFRESH tab.
  MOVE 'PROP' TO tab-fcode.
  APPEND tab.
  MOVE 'CANC' TO tab-fcode.
  APPEND tab.
  MOVE 'MOD' TO tab-fcode.
  APPEND tab.
  MOVE 'MODMASS' TO tab-fcode.
  APPEND tab.
  MOVE 'MODREF' TO tab-fcode.
  APPEND tab.

*  MOVE 'EXCEL' TO tab-fcode.
*  APPEND tab.

  SET  PF-STATUS 'ZFIPG002' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100_exit INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0100_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA : xlinea LIKE tabla-top_line.

  CASE sy-ucomm.

    WHEN 'PROP'.
      CLEAR sy-ucomm.
      PERFORM genero_propuesta.

    WHEN 'MARCA'.
      CLEAR sy-ucomm.
      PERFORM marco_todo.

    WHEN 'DESMA'.
      CLEAR sy-ucomm.
      PERFORM desmarco_todo.

    WHEN 'ORDEN'.
      CLEAR sy-ucomm.
      PERFORM ordenar.

    WHEN 'REFR'.
      CLEAR sy-ucomm.
      PERFORM proceso.

    WHEN 'SEL'.
      GET CURSOR FIELD cursorfield.
      GET CURSOR LINE xlinea.
      IF xlinea > 0 AND xlinea <= tabla-lines .
        xlinea = xlinea + tabla-top_line - 1.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
*SORT INT_TABLA . "jorozco 24.01.2020
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
        READ TABLE int_tabla INDEX xlinea.
        CLEAR sy-ucomm.
        PERFORM detalle.
      ENDIF.

    WHEN 'EXCEL'.
      REFRESH texcel.
      LOOP AT int_tabla.

        IF sy-tabix = 1.

          texcel-zzmot_emis = 'Mot. Emisión'.
          texcel-blart = 'Descripción'.
          texcel-gjahr = 'N° Documentos'.
          texcel-belnr = 'Monto a Pago'.
          texcel-buzei = 'N° Doc. NS'.
          texcel-zfbdt = 'Monto No Seleccionado'.
          texcel-hbkid = 'Fecha Vencimiento'.
          texcel-zlsch = 'Via de Pago'.

          APPEND texcel.
          CLEAR texcel.

        ENDIF.

        texcel-zzmot_emis = int_tabla-zzmot_emis.
        texcel-blart = int_tabla-descr.
        texcel-gjahr = int_tabla-docto.
        texcel-buzei = int_tabla-docto_r.
        texcel-hbkid = int_tabla-fecha_v.
        texcel-zlsch = int_tabla-zlsch.

        WRITE int_tabla-monto_r   TO texcel-belnr CURRENCY t001-waers.
        WRITE int_tabla-monto     TO texcel-zfbdt CURRENCY t001-waers.

        APPEND texcel.

      ENDLOOP.

      CALL FUNCTION 'WS_EXCEL'
        TABLES
          data          = texcel
        EXCEPTIONS
          unknown_error = 1
          OTHERS        = 2.

    WHEN 'PAGO'.
** Modificado por L_FOUBERT 03.09.2013 Validacion Doc. unico.

      DATA: lv_error TYPE c,
            lv_belnr TYPE bkpf-belnr,
            lv_xblnr TYPE bkpf-xblnr,
            lv_wrbtr TYPE bseg-wrbtr.
      REFRESH: t_belnr.
      CLEAR: lv_error, lv_belnr, lv_xblnr, lv_wrbtr, t_belnr.
      LOOP AT int_tabla WHERE sel = 'X'.
        MOVE int_tabla-fecha_v TO lv_xblnr.
*        CONCATENATE  int_tabla-fecha_v+6(2) int_tabla-fecha_v+4(2)
*                     int_tabla-fecha_v+0(4) INTO lv_xblnr.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT belnr stblg
*          FROM bkpf
*          INTO TABLE t_belnr
*          WHERE bukrs EQ bukrs
*           AND  gjahr EQ sy-datum(4)
*           AND  blart EQ 'SA'
*           AND  xblnr EQ lv_xblnr.
*
* NEW CODE
        SELECT belnr stblg

          FROM bkpf
          INTO TABLE t_belnr
          WHERE bukrs EQ bukrs
           AND  gjahr EQ sy-datum(4)
           AND  blart EQ 'SA'
           AND  xblnr EQ lv_xblnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

        LOOP AT t_belnr WHERE stblg IS INITIAL.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE wrbtr
*            FROM bseg
*            INTO lv_wrbtr
*            WHERE bukrs EQ bukrs
*              AND belnr EQ t_belnr-belnr
*              AND gjahr EQ sy-datum(4)
*              AND bschl EQ '40'.
*
* NEW CODE
          SELECT wrbtr
          UP TO 1 ROWS 
            FROM bseg
            INTO lv_wrbtr
            WHERE bukrs EQ bukrs
              AND belnr EQ t_belnr-belnr
              AND gjahr EQ sy-datum(4)
              AND bschl EQ '40' ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF lv_wrbtr EQ int_tabla-monto.
            lv_error = 'X'.
            lv_belnr = t_belnr-belnr.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      IF lv_error IS INITIAL.
        CALL SCREEN '0500'.
      ELSE.
        MESSAGE s899(mm) DISPLAY LIKE 'E'
        WITH 'Verifique el documento ya contabilizado' lv_belnr.
      ENDIF.
** END L_FOUBERT 03.09.2013 Validacion Doc. unico.
** Fin Mod. 26.08.2013 Boton Financiamiento del Pago

  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

**&---------------------------------------------------------------------
**&      Module  FILL_TABLE_CONTROL  OUTPUT
**&---------------------------------------------------------------------
**   Lleno grilla con valores desde tabla
**----------------------------------------------------------------------
*&      Module  FILL_TABLE_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control_0100 OUTPUT.

*ReSQ: No Need Of Change Internal Table INT_TABLA Already Sorted
  READ TABLE int_tabla INTO zfipg200_est INDEX tabla-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VALIDA-GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida-grilla_0100 INPUT.

*ReSQ: No Need Of Change Internal Table INT_TABLA Already Sorted
  MODIFY int_tabla FROM zfipg200_est INDEX tabla-current_line
     TRANSPORTING sel.

ENDMODULE.                 " VALIDA-GRILLA_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  genero_propuesta
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM genero_propuesta.

  DATA: fecha0    LIKE sy-datum,
        clave(6),
        clave1(6),
        clave2(6),
        sec(3)    TYPE n.

  REFRESH tprop1.

  LOOP AT tpago.
    IF tpago-shkzg = 'S'.
      MULTIPLY tpago-wrbtr BY -1.
      MODIFY tpago FROM tpago
       TRANSPORTING wrbtr.
    ENDIF.
  ENDLOOP.

  LOOP AT int_tabla.
    IF int_tabla-sel = 'X'.
*      LOOP AT tpago WHERE zzmot_emis = int_tabla-zzmot_emis
*                    AND   zfbdt      = int_tabla-fecha_v
*                    AND   zlsch      = int_tabla-zlsch
*                    AND   lifnr     >= int_tabla-CLI_DDE
*                    AND   lifnr     <= int_tabla-CLI_HTA.

      tprop1-zfbdt = int_tabla-fecha_v.
      tprop1-hbkid = int_tabla-banco_pgo.
      tprop1-zlsch = int_tabla-zlsch.
      tprop1-zzmot_emis = int_tabla-zzmot_emis.
      tprop1-lifnr_dde = int_tabla-cli_dde.
      tprop1-lifnr_hta = int_tabla-cli_hta.
      tprop1-docto = int_tabla-reg_pro.
      tprop1-docto_ban = int_tabla-reg_ban.
      tprop1-wrbtr = int_tabla-monto.
      APPEND tprop1.

*      ENDLOOP.
    ENDIF.
  ENDLOOP.

  LOOP AT tpago.
    IF tpago-shkzg = 'S'.
      MULTIPLY tpago-wrbtr BY -1.
      MODIFY tpago FROM tpago
       TRANSPORTING wrbtr.
    ENDIF.
  ENDLOOP.

  CLEAR   tprop2.
  REFRESH tprop2.

  SORT tprop1 BY zfbdt  hbkid zlsch zzmot_emis lifnr_dde.

  LOOP AT tprop1.

*    AT END OF zzmot_emis.
*      IF tprop2-xzzmot_emis = ''.
*        tprop2-xzzmot_emis = tprop1-zzmot_emis.
*      ELSE.
*        CONCATENATE tprop2-xzzmot_emis ',' tprop1-zzmot_emis INTO  tprop2-xzzmot_emis.
*      ENDIF.
*    ENDAT.

    AT END OF lifnr_hta.
      SUM.
      tprop2-zfbdt = tprop1-zfbdt.
      tprop2-hbkid = tprop1-hbkid.
      tprop2-zlsch = tprop1-zlsch.
      tprop2-xzzmot_emis = tprop1-zzmot_emis.
      tprop2-lifnr_dde = tprop1-lifnr_dde.
      tprop2-lifnr_hta = tprop1-lifnr_hta.
      tprop2-docto = tprop1-docto.
      tprop2-docto_ban =  tprop1-docto_ban.
      tprop2-wrbtr = tprop1-wrbtr.

      APPEND tprop2.
      CLEAR tprop2.
    ENDAT.

  ENDLOOP.

  fecha0 = sy-datum.

  CONCATENATE 'M' bukrs+2(2) '%' INTO clave.

  SELECT MAX( laufi ) INTO clave1   FROM reguv WHERE laufd = fecha0
                                    AND  laufi LIKE clave.

  SELECT MAX( laufi ) INTO clave2   FROM zfipg200_det WHERE laufd = fecha0
                                    AND  laufi LIKE clave.

  IF clave2 > clave1.
    clave1 =  clave2.
  ENDIF.
  LOOP AT tprop2.
    fecha0 = sy-datum.
*&-------------------------------------------------------------------*
*& ** BLOQUEO Y RECUPERACION DE FOLIO DE PROPUESTA POR SOCIEDAD-DIA
*&-------------------------------------------------------------------*
    CALL FUNCTION 'ENQUEUE_EZ_ZFOLIO_SOC01'
      EXPORTING
        mode_zfolio_soc01 = 'E'
        mandt             = sy-mandt
        bukrs             = bukrs
        fecha             = fecha0
        _scope            = 1
      EXCEPTIONS
        foreign_lock      = 1
        system_failure    = 2
        OTHERS            = 3.

    WHILE sy-subrc <> 0.
      CALL FUNCTION 'ENQUEUE_EZ_ZFOLIO_SOC01'
        EXPORTING
          mode_zfolio_soc01 = 'E'
          mandt             = sy-mandt
          bukrs             = bukrs
          fecha             = fecha0
          _scope            = 1
        EXCEPTIONS
          foreign_lock      = 1
          system_failure    = 2
          OTHERS            = 3.
    ENDWHILE.

*&----------------------------------------------------------------------------------------------------------------*

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *  FROM zfolio_soc01  WHERE bukrs  = bukrs
*                                          AND fecha  = fecha0.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS   FROM zfolio_soc01  WHERE bukrs  = bukrs
                                          AND fecha  = fecha0 ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc <> 0.
      zfolio_soc01-bukrs = bukrs.
      zfolio_soc01-fecha = sy-datum.
      zfolio_soc01-folsoc01 = 0.
    ENDIF.

* USO E INCREMENTO
    zfolio_soc01-folsoc01 =  zfolio_soc01-folsoc01 + 1.
    MODIFY  zfolio_soc01.

* DESBLOQUEO
    CALL FUNCTION 'DEQUEUE_EZ_ZFOLIO_SOC01'
      EXPORTING
        mode_zfolio_soc01 = 'E'
        mandt             = sy-mandt
        bukrs             = bukrs
        fecha             = fecha0.

*  LOOP AT tprop2.
    tprop2-laufd  = fecha0.
    sec = zfolio_soc01-folsoc01.
    CONCATENATE bukrs+2(2)  sec INTO  tprop2-laufi.
*    CONCATENATE 'M' bukrs+2(2)  sec INTO  tprop2-laufi.
    MODIFY tprop2.
  ENDLOOP.

  REFRESH int_tabla2.

  LOOP AT tprop2.
    MOVE-CORRESPONDING tprop2 TO int_tabla2.
    int_tabla2-monto = tprop2-wrbtr.
    APPEND int_tabla2.
  ENDLOOP.

  DESCRIBE TABLE int_tabla2 LINES fill.
  SORT int_tabla2 BY laufd laufi .
  tabla2-lines = fill.
  tabla2-top_line = 1.
  CLEAR zfipg200_cab-descr.


  CALL SCREEN 200 STARTING AT 20 05 ENDING AT 154 19.

ENDFORM.                    "
*&---------------------------------------------------------------------*
*&      Form  DETALLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detalle.

  REFRESH int_tabla3.

  CASE cursorfield.
    WHEN 'ZFIPG200_EST-MONTO'.
      titulo = '        DOCUMENTOS  SELECCIONADOS       '.
      LOOP AT tpago WHERE msg = ''
                    AND   zzmot_emis = int_tabla-zzmot_emis
                    AND   zfbdt = int_tabla-fecha_v
                    AND   zlsch = int_tabla-zlsch
                    AND   hbkid = int_tabla-banco_pgo
                    AND   lifnr >= int_tabla-cli_dde
                    AND   lifnr <= int_tabla-cli_hta.
***                    AND   wrbtr = int_tabla-monto.
        MOVE-CORRESPONDING tpago TO int_tabla3.
        APPEND int_tabla3.
      ENDLOOP.

      DESCRIBE TABLE int_tabla3 LINES fill.
      tabla3-lines = fill.
      tabla3-top_line = 1.
      LOOP AT tabla3-cols INTO cols WHERE index = 14 .
        cols-screen-input = 0.
        cols-invisible = '1'.
        MODIFY tabla3-cols FROM cols INDEX sy-tabix.
      ENDLOOP.
      SORT int_tabla3 BY zzmot_emis  lifnr gjahr  belnr buzei.
      CALL SCREEN 300 STARTING AT 10 05 ENDING AT 135 24.
    WHEN 'ZFIPG200_EST-MONTO_R'.
      titulo = '       DOCUMENTOS NO SELECCIONADOS      '.
      int_tabla-monto = int_tabla-monto_r.
      LOOP AT tpago WHERE msg <> ''
                    AND   msg <> 'Abono/FAC No Aplicado'
                    AND   zzmot_emis = int_tabla-zzmot_emis
                    AND   zfbdt = int_tabla-fecha_v
                    AND   zlsch = int_tabla-zlsch
                    AND   hbkid = int_tabla-banco_pgo
                    AND   lifnr >= int_tabla-cli_dde
                    AND   lifnr <= int_tabla-cli_hta.
***                    AND   wrbtr = int_tabla-monto.
        MOVE-CORRESPONDING tpago TO int_tabla3.
        int_tabla3-wrbtr = tpago-wrbtr_r.
        APPEND int_tabla3.
      ENDLOOP.
      DESCRIBE TABLE int_tabla3 LINES fill.
      tabla3-lines = fill.
      tabla3-top_line = 1.
      LOOP AT tabla3-cols INTO cols WHERE index = 14 .
        cols-screen-input = 0.
        cols-invisible = '0'.
        MODIFY tabla3-cols FROM cols INDEX sy-tabix.
      ENDLOOP.
      SORT int_tabla3 BY zzmot_emis lifnr gjahr   belnr buzei.
      CALL SCREEN 300 STARTING AT 10 05 ENDING AT 135 24.
    WHEN 'ZFIPG200_EST-MONTO_NA'.
      titulo = '       DOCUMENTOS NO APLICADOS      '.
      int_tabla-monto = int_tabla-monto_na.
      LOOP AT tpago WHERE msg <> ''
                    AND   msg = 'Abono/FAC No Aplicado'
                    AND   zzmot_emis = int_tabla-zzmot_emis
                    AND   zfbdt = int_tabla-fecha_v
                    AND   zlsch = int_tabla-zlsch
                    AND   hbkid = int_tabla-banco_pgo
                    AND   lifnr >= int_tabla-cli_dde
                    AND   lifnr <= int_tabla-cli_hta.
        MOVE-CORRESPONDING tpago TO int_tabla3.
        int_tabla3-wrbtr = tpago-wrbtr_na.
        APPEND int_tabla3.
      ENDLOOP.
      DESCRIBE TABLE int_tabla3 LINES fill.
      tabla3-lines = fill.
      tabla3-top_line = 1.
      LOOP AT tabla3-cols INTO cols WHERE index = 14 .
        cols-screen-input = 0.
        cols-invisible = '0'.
        MODIFY tabla3-cols FROM cols INDEX sy-tabix.
      ENDLOOP.
      SORT int_tabla3 BY zzmot_emis lifnr gjahr  belnr buzei.
      CALL SCREEN 300 STARTING AT 10 05 ENDING AT 135 24.
  ENDCASE.

ENDFORM.                    " DETALLE

*&---------------------------------------------------------------------*
*&      Form  MARCO_TODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM marco_todo.

  LOOP AT int_tabla.
    int_tabla-sel = 'X'.
    MODIFY int_tabla.
  ENDLOOP.

ENDFORM.                    " MARCO_TODO

*&---------------------------------------------------------------------*
*&      Form  DESMARCO_TODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM desmarco_todo.

  LOOP AT int_tabla.
    int_tabla-sel = ''.
    MODIFY int_tabla.
  ENDLOOP.

ENDFORM.                    " DESMARCO_TODO

*&---------------------------------------------------------------------*
*&      Form  ordenar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ordenar.

  LOOP AT tabla-cols INTO cols.

    IF cols-selected = 'X'.
      IF sy-tabix = 1.
        SORT int_tabla BY fecha_v zzmot_emis zlsch.
      ELSEIF sy-tabix = 2.
        SORT int_tabla BY zzmot_emis fecha_v  zlsch.
      ENDIF.
    ENDIF.

    MODIFY tabla-cols FROM cols INDEX sy-tabix.

  ENDLOOP.

ENDFORM.                               " ORDENAR
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500_exit INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0500_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.

  IF r1 = 'X'.

    CASE sy-ucomm.

      WHEN 'PAGAR'.

        CALL SCREEN '0600'.

    ENDCASE.

  ELSEIF

    r2 = 'X'.

    CASE sy-ucomm.

      WHEN 'PAGAR'.
        CALL SCREEN '0700'.
**  a petición de jose rogel se deja un tiempo de ej. y un mensaje para el boton pago por carta.
*    WAIT UP TO 5 SECONDS.
*   MESSAGE s899(mm) DISPLAY LIKE 'S' WITH 'Se ha generado Financiamiento por Carta'.
*        CALL TRANSACTION 'ZFITR012'.

    ENDCASE.

  ENDIF.


ENDMODULE.                 " USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0600_exit INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0600_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0600 INPUT.

  DATA: monto2 TYPE bseg-wrbtr.
  DATA: monto3(15).
  DATA: motiv(10) TYPE c.
  DATA: zz_agencia1 LIKE bsik-zz_agencia.
  DATA: xref2       LIKE bsik-xref2.
  DATA:  lv_textout LIKE t100-text.
  DATA: fecha_v1(2) TYPE c,
        fecha_v2(2) TYPE c,
        fecha_v3(4) TYPE c,
        fecha_vf(8) TYPE c.

  REFRESH: tprop1, bdcdata, itab.

  CASE sy-ucomm.

    WHEN 'ENTRAR'.

      LOOP AT int_tabla.
        IF int_tabla-sel = 'X'.
          LOOP AT tpago WHERE zzmot_emis = int_tabla-zzmot_emis
                        AND   zfbdt      = int_tabla-fecha_v
                        AND   zlsch      = tpago-zlsch.

            tprop1-zfbdt = int_tabla-fecha_v.
            tprop1-hbkid = tpago-hbkid.
            tprop1-zlsch = tpago-zlsch.
            tprop1-zz_agencia = tpago-zz_agencia.
            tprop1-zzmot_emis = int_tabla-zzmot_emis.
            tprop1-docto = tpago-docto.
            tprop1-wrbtr = tpago-wrbtr.
            APPEND tprop1.

            fecha_v1 = int_tabla-fecha_v+6(2).
            fecha_v2 = int_tabla-fecha_v+4(2).
            fecha_v3 = int_tabla-fecha_v+0(4).
            MOVE int_tabla-fecha_v TO fecha_vf.
*            CONCATENATE  fecha_v1 fecha_v2 fecha_v3 INTO fecha_vf.

            motiv = int_tabla-zzmot_emis.
*            zz_agencia1 = tpago-zz_agencia.

            monto3 = int_tabla-monto.
            REPLACE ALL OCCURRENCES OF '.' IN monto3 WITH ''.
            CONDENSE monto3.

            monto1 = tprop1-wrbtr + monto1.

          ENDLOOP.
        ENDIF.
      ENDLOOP.

      PERFORM batch_f_02.
      CLEAR: lv_textout.
      CALL TRANSACTION 'F-02' USING  bdcdata
                                MODE gv_mode "'E'
*                                UPDATE gv_update "'S'
                                MESSAGES INTO itab.
      READ TABLE itab  WITH KEY msgtyp = 'S' msgnr = 312. " contab.
      IF sy-subrc EQ 0. " se creo
        MESSAGE ID itab-msgid
        TYPE itab-msgtyp
        NUMBER itab-msgnr
        WITH itab-msgv1 itab-msgv2 itab-msgv3 itab-msgv4 INTO lv_textout.
        MESSAGE s899(mm) DISPLAY LIKE 'S' WITH lv_textout.
      ELSE.
        READ TABLE itab  WITH KEY msgtyp = 'E'.
        MESSAGE ID itab-msgid
        TYPE itab-msgtyp
        NUMBER itab-msgnr
        WITH itab-msgv1 itab-msgv2 itab-msgv3 itab-msgv4 INTO lv_textout.
        MESSAGE s899(mm) DISPLAY LIKE 'E' WITH lv_textout.
      ENDIF.

      SUBMIT zfipg002 WITH bukrs   EQ bukrs
                      WITH p_zfbdt IN p_zfbdt
                      WITH budat   EQ budat
                      WITH zlsch   EQ zlsch
                      WITH xref1   EQ xref1.
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*&      Form  BATCH_F_02
*&---------------------------------------------------------------------*
FORM batch_f_02.

  DATA: fecha1(2)  TYPE c,
        fecha2(2)  TYPE c,
        fecha3(4)  TYPE c,
        fecha_f(8) TYPE c.


  fecha1 = sy-datum+6(2).
  fecha2 = sy-datum+4(2).
  fecha3 = sy-datum+0(4).

  CONCATENATE fecha1 fecha2 fecha3 INTO fecha_f.

  PERFORM bdc_dynpro USING  'SAPMF05A' '0100'.

  PERFORM bdc_field  USING: 'BDC_OKCODE'    '/00' ,
                            'BKPF-BLART'  'SA'    ,
                            'BKPF-BUKRS'  bukrs,"'CL01'  ,LF
                            'BKPF-BUDAT'  fecha_f ,
                            'BKPF-BLDAT'  fecha_f ,
                            'BKPF-WAERS'  'CLP',
                            'BKPF-XBLNR'  fecha_vf,
                            'BKPF-BKTXT'  'Chq Deposito Transfer',
                            'RF05A-NEWBS'  '40',
                            'RF05A-NEWKO'  gv_hkont,"'1011110005',  "buscar dato
                            'BDC_SUBSCR'  'SAPMF05A                                1300APPL_SUB_T',
                            'BDC_SUBSCR'  'SAPLSEXM                                0200APPL_SUB'.


  PERFORM bdc_dynpro USING  'SAPMF05A' '0300'.

  PERFORM bdc_field  USING: "'BDC_OKCODE'      '/00',
                            'BSEG-WRBTR'  monto3,
                            'BSEG-VALUT'  fecha_f,
                            'BSEG-ZUONR'  fecha_vf,
                            'BSEG-SGTXT'  'Cheque Deposito',"'CHQ. Cheque Transfer',
                            'RF05A-NEWBS' '31',
                            'RF05A-NEWKO' lfa1-lifnr. "'100001247'.  "debe ser 2011730002 " LF
*                                'BDC_SUBSCR'  'SAPLKACB                                0001BLOCK',
*                                'DKACB-FMORE'  'X'.

  PERFORM bdc_dynpro USING  'SAPLKACB' '0002'.

  PERFORM bdc_field  USING: 'BDC_CURSOR'  'COBL-PRCTR',
                            'BDC_OKCODE'  '=ENTE',
                            'COBL-ZZRUT_TERC' lfa1-lifnr,
                            'COBL-ZZMOT_EMIS' motiv,
                            'COBL-ZZ_AGENCIA' zz_agencia1,
                            'BDC_SUBSCR'  'SAPLKACB                                9999BLOCK1'.

  PERFORM bdc_dynpro USING  'SAPMF05A' '0302'.

  PERFORM bdc_field  USING: 'BDC_CURSOR'  'BSEG-ZZ_AGENCIA',
                            'BDC_OKCODE'   '=ZK',"'=BU',   LFF
                            'BSEG-HKONT'  '2011730002',
                            'BSEG-WRBTR'  monto3,
                            'BSEG-MWSKZ'  '**',
                            'BSEG-ZTERM'  'ZC01'," 'ZD03', " LF
                            'BSEG-ZBD1T'  '0',
                            'BSEG-ZFBDT'  fecha_f,
                            'BSEG-ZUONR'  fecha_vf,
                            'BSEG-ZLSCH'  'C',
                            'BSEG-SGTXT'  banco1,
                            'BSEG-ZZMOT_EMIS'  motiv,
                            'BSEG-ZZRUT_TERC' lfa1-lifnr,
                            'BSEG-ZZ_AGENCIA' zz_agencia1.
** Modificado por L_FOUBERT 03.09.2013 Se agregan campos nuevos a BI.
  PERFORM bdc_dynpro USING  'SAPMF05A' '0332'.
  PERFORM bdc_field  USING: 'BDC_CURSOR'  'BSEG-XREF2',
                            'BDC_OKCODE'   '/00', "'=BU', LFF
                             'BSEG-HBKID' bsik-hbkid,
                             'BSEG-HKTID' gv_hktid,
                             'BSEG-XREF2' xref2,
                             'BSEG-ZZ_AGENCIA' zz_agencia1.
  PERFORM bdc_field  USING: 'BDC_CURSOR'  'BSEG-XREF2',
                            'BDC_OKCODE'   '=BU', "LFF
                             'BSEG-HBKID' bsik-hbkid,
                             'BSEG-HKTID' gv_hktid,
                             'BSEG-XREF2' xref2,
                             'BSEG-ZZ_AGENCIA' zz_agencia1.
** END L_FOUBERT 03.09.2013 Se agregan campos nuevos a BI.


ENDFORM.                    " BATCH_F_02
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600_DATO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0600_dato INPUT.

  DATA: hbkid      LIKE bsik-hbkid,
        lv_cont(2) TYPE n,
        lv_hkont   TYPE t012k-hkont.
  CLEAR: lv_cont, lv_hkont, gv_hktid.

  banco = bsik-hbkid. " LF

  CONCATENATE banco 'Transfer' INTO banco1 SEPARATED BY space.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE hktid hkont
*    FROM t012k
*    INTO (gv_hktid, lv_hkont)
*    WHERE bukrs EQ bukrs
*      AND hbkid EQ bsik-hbkid.
*
* NEW CODE
  SELECT hktid hkont
  UP TO 1 ROWS 
    FROM t012k
    INTO (gv_hktid, lv_hkont)
    WHERE bukrs EQ bukrs
      AND hbkid EQ bsik-hbkid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  lv_cont = strlen( lv_hkont ).
  lv_cont = lv_cont - 1.
  CONCATENATE lv_hkont(lv_cont) '5' INTO gv_hkont.
  CONDENSE gv_hkont NO-GAPS.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE stcd1
*     FROM lfa1
*     INTO gv_stcd1
*     WHERE lifnr EQ lfa1-lifnr.
*
* NEW CODE
  SELECT stcd1
  UP TO 1 ROWS 
     FROM lfa1
     INTO gv_stcd1
     WHERE lifnr EQ lfa1-lifnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


ENDMODULE.                 " USER_COMMAND_0600_DATO  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0600 OUTPUT.
  SET PF-STATUS 'ZFIPG002_3'.
*  SET TITLEBAR 'xxx'.
  IF sy-ucomm EQ 'PAGAR'.
    CLEAR: bsik-hbkid, lfa1-lifnr, zz_agencia1, gv_hktid, gv_stcd1.
  ENDIF.
ENDMODULE.                 " STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  SET PF-STATUS 'ZFIPG002_3'.
*  SET TITLEBAR 'xxx'.
*IF SY-UCOMM EQ 'ENTRAR'.
* LEAVE TO SCREEN 0.
*  ENDIF.
ENDMODULE.                 " STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0700 OUTPUT.
  DATA: txt_banc TYPE fibl_txt50,
        txt_agen TYPE char40.
  CLEAR: txt_banc, txt_agen.
  SET PF-STATUS 'ZFIPG002_3'.
*  SET TITLEBAR 'xxx'.
  IF sy-ucomm EQ 'PAGAR'.
    CLEAR: bsik-hbkid, lfa1-lifnr, zz_agencia1, gv_hktid, gv_stcd1.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE text1
*    FROM t012t
*    INTO txt_banc
*    WHERE bukrs EQ bukrs
*      AND hbkid EQ bsik-hbkid.
*
* NEW CODE
  SELECT text1
  UP TO 1 ROWS 
    FROM t012t
    INTO txt_banc
    WHERE bukrs EQ bukrs
      AND hbkid EQ bsik-hbkid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE zzdescr
*    FROM zagencia
*    INTO txt_agen
*    WHERE bukrs EQ bukrs
*      AND zzcod_unidad EQ zz_agencia1.
*
* NEW CODE
  SELECT zzdescr
  UP TO 1 ROWS 
    FROM zagencia
    INTO txt_agen
    WHERE bukrs EQ bukrs
      AND zzcod_unidad EQ zz_agencia1 ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

ENDMODULE.                 " STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0700 INPUT.
  REFRESH: tprop1, bdcdata, itab.
  CLEAR: monto3.
  CASE sy-ucomm.
    WHEN 'ENTRAR'.
      LOOP AT int_tabla WHERE sel = 'X'.
        LOOP AT tpago WHERE zzmot_emis = int_tabla-zzmot_emis
                      AND   zfbdt      = int_tabla-fecha_v
                      AND   zlsch      = tpago-zlsch.

          tprop1-zfbdt = int_tabla-fecha_v.
          tprop1-hbkid = tpago-hbkid.
          tprop1-zlsch = tpago-zlsch.
          tprop1-zz_agencia = tpago-zz_agencia.
          tprop1-zzmot_emis = int_tabla-zzmot_emis.
          tprop1-docto = tpago-docto.
          tprop1-wrbtr = tpago-wrbtr.
          APPEND tprop1.

          MOVE int_tabla-fecha_v TO fecha_vf.

          motiv = int_tabla-zzmot_emis.

          monto3 = int_tabla-monto.
          REPLACE ALL OCCURRENCES OF '.' IN monto3 WITH ''.
          CONDENSE monto3.

          monto1 = tprop1-wrbtr + monto1.

        ENDLOOP.
      ENDLOOP.
      PERFORM bi_carta.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0700_exit INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0700_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700_DATO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0700_dato INPUT.
  DATA: hbkid2      LIKE bsik-hbkid,
        lv_cont2(2) TYPE n,
        lv_hkont2   TYPE t012k-hkont.
  CLEAR: lv_cont2, lv_hkont, gv_hktid,gv_hkont, gv_hkont3.

  banco = bsik-hbkid. " LF

  CONCATENATE banco 'Transfer' INTO banco1 SEPARATED BY space.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE hktid hkont
*    FROM t012k
*    INTO (gv_hktid, lv_hkont2)
*    WHERE bukrs EQ bukrs
*      AND hbkid EQ bsik-hbkid.
*
* NEW CODE
  SELECT hktid hkont
  UP TO 1 ROWS 
    FROM t012k
    INTO (gv_hktid, lv_hkont2)
    WHERE bukrs EQ bukrs
      AND hbkid EQ bsik-hbkid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  lv_cont2 = strlen( lv_hkont2 ).
  lv_cont2 = lv_cont2 - 1.
** Cuenta terminada en 5
  CONCATENATE lv_hkont2(lv_cont2) '5' INTO gv_hkont.
  CONDENSE gv_hkont NO-GAPS.
** Cuenta terminada en 3
  CONCATENATE lv_hkont2(lv_cont2) '3' INTO gv_hkont3.
  CONDENSE gv_hkont3 NO-GAPS.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE stcd1
*     FROM lfa1
*     INTO gv_stcd1
*     WHERE lifnr EQ lfa1-lifnr.
*
* NEW CODE
  SELECT stcd1
  UP TO 1 ROWS 
     FROM lfa1
     INTO gv_stcd1
     WHERE lifnr EQ lfa1-lifnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
ENDMODULE.                 " USER_COMMAND_0700_DATO  INPUT
*&---------------------------------------------------------------------*
*&      Form  BI_CARTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bi_carta .
  DATA: fecha_f(8) TYPE c.
  CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
    EXPORTING
      input  = sy-datum
    IMPORTING
      output = fecha_f.


  PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
  PERFORM bdc_field       USING: 'BDC_CURSOR' 'RF05A-NEWKO',
                                'BDC_OKCODE'  '/00',
                                'BKPF-BLDAT'  fecha_f,
                                'BKPF-BLART'  'SA',
                                'BKPF-BUKRS'  bukrs,
                                'BKPF-BUDAT'  fecha_f,
                                'BKPF-WAERS' 'CLP',
                                'BKPF-XBLNR' fecha_vf,
                                'BKPF-BKTXT' 'Carta Deposito Transfer',
                                'FS006-DOCID' '*',
                                'RF05A-NEWBS' '40',
                                'RF05A-NEWKO' gv_hkont.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.

  PERFORM bdc_field       USING: 'BDC_CURSOR' 'BSEG-SGTXT',
                                 'BDC_OKCODE' '=LTXT',
                                 'BSEG-WRBTR' monto3,
                                 'BSEG-VALUT' fecha_f,
                                 'BSEG-ZUONR' fecha_vf,
                                'BSEG-SGTXT' 'Carta Deposito'.

  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING: 'BDC_OKCODE'  '=ENTE',
                                 'BDC_CURSOR'  'COBL-ZZMOT_EMIS',
                                 'COBL-ZZMOT_EMIS'  motiv,
                                 'COBL-ZZ_AGENCIA'  zz_agencia1.
  PERFORM bdc_dynpro      USING  'SAPLFTXT' '0110'.
  PERFORM bdc_field       USING: 'BDC_OKCODE' '=ACCPT',
                                 'BDC_CURSOR' 'EENO_DYNP-ZEILE(01)'.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING: 'BDC_CURSOR' 'RF05A-NEWKO',
                                 'BDC_OKCODE'  '/00',
                                 'BSEG-WRBTR'  monto3,
                                 'BSEG-VALUT'  fecha_f,
                                 'BSEG-ZUONR'  fecha_vf,
                                 'BSEG-SGTXT'  'Carta Deposito',
                                 'RF05A-NEWBS' '50',
                                 'RF05A-NEWKO' gv_hkont3.

  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING: 'BDC_CURSOR' 'COBL-PRCTR',
                                 'BDC_OKCODE' '=ENTE',
                                 'COBL-ZZMOT_EMIS' motiv,
                                 'COBL-ZZ_AGENCIA' zz_agencia1.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING: 'BDC_CURSOR' 'BSEG-SGTXT',
                                 'BDC_OKCODE' '/00',
                                 'BSEG-WRBTR' monto3,
                                 'BSEG-VALUT' fecha_f,
                                 'BSEG-ZUONR' fecha_vf,
                                 'BSEG-SGTXT' 'Carta Deposito'.

  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING: 'BDC_OKCODE' '=ENTE',
                                 'BDC_CURSOR' 'COBL-ZZ_AGENCIA',
                                 'COBL-ZZMOT_EMIS' motiv,
                                 'COBL-ZZ_AGENCIA' zz_agencia1.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
  PERFORM bdc_field       USING: 'BDC_CURSOR'  'BSEG-WRBTR',
                                 'BDC_OKCODE'   '/00',
                                 'BSEG-WRBTR' monto3,
                                 'BSEG-VALUT' fecha_f,
                                 'BSEG-ZUONR' fecha_vf,
                                 'BSEG-SGTXT' 'Carta Deposito'.

  PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
  PERFORM bdc_field       USING: 'BDC_OKCODE' '/EESC',
                                 'BDC_CURSOR' 'COBL-PRCTR'.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0700'.
  PERFORM bdc_field       USING: 'BDC_CURSOR' 'RF05A-NEWBS',
                                 'BDC_OKCODE' '=BU',
                                 'BKPF-XBLNR' fecha_vf,
                                 'BKPF-BKTXT' 'Carta Deposito Transfer'.

  CALL TRANSACTION 'F-02' USING  bdcdata
                                 MODE gv_mode "'E'
*                                UPDATE gv_update "'S'
                                 MESSAGES INTO itab.
  CLEAR: lv_textout.
  READ TABLE itab  WITH KEY msgtyp = 'S' msgnr = 312. " contab.
  IF sy-subrc EQ 0. " se creo
    MESSAGE ID itab-msgid
    TYPE itab-msgtyp
    NUMBER itab-msgnr
    WITH itab-msgv1 itab-msgv2 itab-msgv3 itab-msgv4 INTO lv_textout.
    MESSAGE s899(mm) DISPLAY LIKE 'S' WITH lv_textout.
  ELSE.
    READ TABLE itab  WITH KEY msgtyp = 'E'.
    IF sy-subrc EQ 0.
      MESSAGE ID itab-msgid
      TYPE itab-msgtyp
      NUMBER itab-msgnr
      WITH itab-msgv1 itab-msgv2 itab-msgv3 itab-msgv4 INTO lv_textout.
      MESSAGE s899(mm) DISPLAY LIKE 'E' WITH lv_textout.
    ELSE.
      READ TABLE itab  INDEX 1.
      IF sy-subrc EQ 0.
        MESSAGE ID itab-msgid
        TYPE itab-msgtyp
        NUMBER itab-msgnr
        WITH itab-msgv1 itab-msgv2 itab-msgv3 itab-msgv4 INTO lv_textout.
        MESSAGE s899(mm) DISPLAY LIKE 'E' WITH lv_textout.
      ENDIF.
    ENDIF.
  ENDIF.

  SUBMIT zfipg002 WITH bukrs   EQ bukrs
                  WITH p_zfbdt IN p_zfbdt
                  WITH budat   EQ budat
                  WITH zlsch   EQ zlsch
                  WITH xref1   EQ xref1.
ENDFORM.                    " BI_CARTA
