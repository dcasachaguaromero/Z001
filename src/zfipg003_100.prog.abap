*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_100
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*

MODULE status_0100 OUTPUT.

  REFRESH tab.
  MOVE 'IMPR' TO tab-fcode.
  APPEND tab.
  MOVE 'CANCL' TO tab-fcode.
  APPEND tab.

  CLEAR: pass1, pass2.

  SET  PF-STATUS 'ZFIPG003' EXCLUDING tab.
  SET  TITLEBAR 'T01'.
  IF zlsch = 'T' OR zlsch = 'V'.
    LOOP AT SCREEN.
      IF screen-name = 'BOTON2'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.

    ENDLOOP.
  ENDIF.

  CLEAR: gv_linsel.

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

*-> BEG INS V1-CNN ECDK925124 22.05.2024
  IF gv_linsel > 1.
    LOOP AT int_tabla WHERE sel = abap_false.
      int_tabla-sel = abap_false.
      MODIFY int_tabla.
    ENDLOOP.

    MESSAGE i004(zfi) WITH 'Seleccione solo un proceso'.
    CLEAR: gv_linsel.
    RETURN.
  ENDIF.
*-> END INS V1-CNN ECDK925124 22.05.2024

  CASE sy-ucomm.

    WHEN 'PAGO'.
*->   BEG INS V1-CNN ECDK925124 14.05.2024
      IF zlsch = 'T' OR zlsch = 'V'.   "19.08.2024
        PERFORM genero_transfer.
      ELSE.
*->   END INS V1-CNN ECDK925124 14.05.2024
        PERFORM genero_pago.
      ENDIF.
    WHEN 'CHEQ'.
      PERFORM genero_cheque.
    WHEN 'DETA'.
      PERFORM ver_detalle.
    WHEN 'REFR'.
      PERFORM proceso.
    WHEN 'ORD1'. " ordenamiento de grilla ascendente
      READ TABLE tabla-cols INTO cols WITH KEY selected = 'X'.
      IF sy-subrc = 0.
        SORT int_tabla STABLE BY (cols-screen-name+13) ASCENDING.
        cols-selected = ' '.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
        SORT tabla-cols .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
        MODIFY tabla-cols FROM cols INDEX sy-tabix.
      ENDIF.
    WHEN 'ORD2'. " ordenamiento de grilla descendente
      READ TABLE tabla-cols INTO cols WITH KEY selected = 'X'.
      IF sy-subrc = 0.
        SORT int_tabla STABLE BY (cols-screen-name+13) DESCENDING.
        cols-selected = ' '.
*ReSQ: No Need Of Change Internal Table TABLA-COLS Already Sorted
        MODIFY tabla-cols FROM cols INDEX sy-tabix.
      ENDIF.
    WHEN 'EXCEL'.
      REFRESH texcel.
      LOOP AT int_tabla.

        IF sy-tabix = 1.

          texcel-descr       = 'Proceso'.
          texcel-estado      = 'Estado'.
          texcel-listopara   = 'Listo Para'.
          texcel-laufi       = 'Identificador'.
          texcel-laufd       = 'Ejecución el'.
          texcel-hbkid       = 'Banco Propio'.
          texcel-zfbdt       = 'Fecha Vencimiento'.
          texcel-xzzmot_emis = 'Motivo Emisión'.
          texcel-monto       = 'Total Pago'.
          texcel-nchequ      = 'N° Cheques'..
          texcel-ult_remesa  = 'N° Inicial'.
          texcel-tot_remesa  = 'N° Final'.
          texcel-nchequ_s    = 'N° Cheques Sueltos'.
          texcel-nhojas      = 'N° Hojas'.

          APPEND texcel.
          CLEAR texcel.

        ENDIF.

        MOVE-CORRESPONDING int_tabla TO texcel.
        WRITE int_tabla-monto        TO texcel-monto CURRENCY t001-waers.

        APPEND texcel.

      ENDLOOP.

      CALL FUNCTION 'WS_EXCEL'
        TABLES
          data          = texcel
        EXCEPTIONS
          unknown_error = 1
          OTHERS        = 2.

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
MODULE fill_table_control_0100 OUTPUT.

  READ TABLE int_tabla INTO zfipg003_est INDEX tabla-current_line.

  IF zfipg003_est-descr IS NOT INITIAL.
    gv_waers = t001-waers.
    IF zfipg003_est-waers IS INITIAL.
      zfipg003_est-waers = t001-waers.
    ENDIF.
  ENDIF.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  VALIDA_GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
MODULE valida_grilla_0100 INPUT.

*-> BEG INS V1-CNN ECDK925124 22.05.2024
  IF zfipg003_est-sel = abap_true.
    gv_linsel = gv_linsel + 1.
  ENDIF.
*-> END INS V1-CNN ECDK925124 22.05.2024

  IF zfipg003_est-nchequ_s > 3.
    MESSAGE e004(zfi) WITH 'Cheques sueltos Mayor a 3'.
  ENDIF.

  IF zfipg003_est-nchequ_s > zfipg003_est-nchequ.
    MESSAGE e004(zfi) WITH 'Cheques sueltos Mayor a N° de Cheques'.
  ENDIF.

  IF zfipg003_est-nchequ_s <  zfipg003_est-nchequ.
    zfipg003_est-nhojas =  ( ( zfipg003_est-nchequ - zfipg003_est-nchequ_s ) / 4 ).
    resto  =  ( ( zfipg003_est-nchequ - zfipg003_est-nchequ_s ) MOD 4 ).
    IF resto = 1 .
      zfipg003_est-nhojas = zfipg003_est-nhojas + 1.
    ENDIF.
  ELSE.
    zfipg003_est-nhojas = 0.
  ENDIF.

  MODIFY int_tabla FROM zfipg003_est INDEX tabla-current_line
     TRANSPORTING sel nchequ_s nhojas.

ENDMODULE.                 " VALIDA_GRILLA_0100  INPUT



*&---------------------------------------------------------------------*
*&      Form  GENERO_PAGO
*&---------------------------------------------------------------------*
FORM genero_pago .

  DATA: fecha1(8),
        fecha2(8),
        veces(4)  TYPE n,
        n_min     TYPE i VALUE 600. "Numero de iteraciones del docto


  LOOP AT int_tabla.

    IF int_tabla-sel = 'X'.
      IF int_tabla-estado = ''.

        fecha1+0(2) = sy-datum+6(2).
        fecha1+2(2) = sy-datum+4(2).
        fecha1+4(4) = sy-datum+0(4).


        fecha2+0(2) = int_tabla-laufd+6(2).
        fecha2+2(2) = int_tabla-laufd+4(2).
        fecha2+4(4) = int_tabla-laufd+0(4).

        REFRESH bdcdata.

        PERFORM bdc_dynpro USING 'SAPF110V'     '0200'.
        PERFORM bdc_field  USING 'BDC_CURSOR'   'F110V-LAUFI'.
        PERFORM bdc_field  USING 'BDC_OKCODE'   '=ENTER'.
        PERFORM bdc_field  USING 'F110V-LAUFD'  fecha2.
        PERFORM bdc_field  USING 'F110V-LAUFI'  int_tabla-laufi.
*
        PERFORM bdc_dynpro USING 'SAPF110V'     '0200'.
        PERFORM bdc_field  USING 'BDC_CURSOR'   'F110V-LAUFI'.
        PERFORM bdc_field  USING 'BDC_OKCODE'   '=ZAEX'.
*
        PERFORM bdc_dynpro USING 'SAPF110V'     '1106'.
        PERFORM bdc_field  USING 'BDC_CURSOR'   'F110V-XSTRF'.
        PERFORM bdc_field  USING 'BDC_OKCODE'   '=EP'.
        PERFORM bdc_field  USING 'F110V-STRDT'  fecha1.
        PERFORM bdc_field  USING 'F110V-XSTRF'  'X'.
        PERFORM bdc_field  USING 'F110V-STRZT'  ''.
*
        CALL TRANSACTION 'F110' USING bdcdata
                                MODE 'E'
                                UPDATE 'S'
                                MESSAGES INTO itab.

        CLEAR v_bankl.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE bankl FROM t012 INTO v_bankl
*          WHERE bukrs EQ bukrs AND hbkid EQ int_tabla-hbkid.
*
* NEW CODE
        SELECT bankl
        UP TO 1 ROWS  FROM t012 INTO v_bankl
          WHERE bukrs EQ bukrs AND hbkid EQ int_tabla-hbkid ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        " OBTENER TIPO DETALLE PARA EMPRESA 037 INI
        IF v_bankl EQ '037'. " Si es banco '037' validar si tiene detalle de nomina
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE detalle_nomina INTO v_detalle
*            FROM zmot_pag
*            WHERE bukrs  EQ bukrs
*            AND   zzmot_emis EQ int_tabla-xzzmot_emis
*            AND  id_banco EQ '037'.
*
* NEW CODE
          SELECT detalle_nomina
          UP TO 1 ROWS  INTO v_detalle
            FROM zmot_pag
            WHERE bukrs  EQ bukrs
            AND   zzmot_emis EQ int_tabla-xzzmot_emis
            AND  id_banco EQ '037' ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        ENDIF.

        IF v_bankl EQ '037' AND sy-subrc = 0.

          IF v_detalle EQ 'A'.
            CONCATENATE 'C:\TRANSFER\' bukrs '_BSANT' '_' int_tabla-laufi '_' sy-datum '_' sy-uzeit '.txt'
            INTO v_archivo.
            SET PARAMETER ID: 'SOC' FIELD bukrs,
                              'FEC' FIELD int_tabla-laufd,
                              'NOM' FIELD int_tabla-laufi,
                              'ARC' FIELD v_archivo.
            CALL TRANSACTION 'ZTRANSFERSDIV'.

          ELSEIF v_detalle EQ 'D'.
            CONCATENATE 'C:\TRANSFER\' bukrs '_BSANT' '_' int_tabla-laufi '_' sy-datum '_' sy-uzeit '.txt'
            INTO v_archivo.
            SET PARAMETER ID: 'SOC' FIELD bukrs,
                              'FEC' FIELD int_tabla-laufd,
                              'NOM' FIELD int_tabla-laufi,
                              'ARC' FIELD v_archivo.
            CALL TRANSACTION 'ZTRANSFERSPROV'.

          ENDIF.
        ELSE.
          IF v_bankl EQ '037' AND zlsch EQ 'T'.
            CONCATENATE 'C:\TRANSFER\' bukrs '_BSANT' '_' int_tabla-laufi '_' sy-datum '_' sy-uzeit '.txt'
            INTO v_archivo.
            SET PARAMETER ID: 'SOC' FIELD bukrs,
                              'FEC' FIELD int_tabla-laufd,
                              'NOM' FIELD int_tabla-laufi,
                              'ARC' FIELD v_archivo.
            CALL TRANSACTION 'ZTRANSFERSDIV'.

          ELSEIF v_bankl EQ '037' AND zlsch EQ 'V'.
            CONCATENATE 'C:\TRANSFER\' bukrs '_BSANT' '_' int_tabla-laufi '_' sy-datum '_' sy-uzeit '.txt'
            INTO v_archivo.
            SET PARAMETER ID: 'SOC' FIELD bukrs,
                              'FEC' FIELD int_tabla-laufd,
                              'NOM' FIELD int_tabla-laufi,
                              'ARC' FIELD v_archivo.
            CALL TRANSACTION 'ZTRANSFERSPROV'.

          ELSEIF v_bankl EQ '027' AND zlsch EQ 'V'.
            CONCATENATE 'C:\TRANSFER\' bukrs '_BCORPBANCA' '_' int_tabla-laufi '_' sy-datum '_' sy-uzeit '.txt'
            INTO v_archivo.
            SET PARAMETER ID: 'SOC' FIELD bukrs,
                    'FEC' FIELD int_tabla-laufd,
                    'NOM' FIELD int_tabla-laufi,
                    'ARC' FIELD v_archivo,
                    'FEP' FIELD sy-datum,
                    'RSF' FIELD 'CHEQUE',
                    'NUM' FIELD '1'.
            CALL TRANSACTION 'ZFITR030'.

          ENDIF.

        ENDIF.


        sy-subrc = 1.
        veces = 0.
        WHILE sy-subrc <> 0 AND veces <= n_min .
          WAIT UP TO 06 SECONDS.
          veces = veces + 1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM reguv
*                          WHERE laufd = int_tabla-laufd
*                          AND laufi   = int_tabla-laufi
*                          AND xecht    = 'X'.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM reguv
                          WHERE laufd = int_tabla-laufd
                          AND laufi   = int_tabla-laufi
                          AND xecht    = 'X' ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        ENDWHILE.

        IF sy-subrc <> 0 AND veces > n_min.
          MESSAGE e004(zfi) WITH 'Se supero tiempo de espera(60 min).' 'Verifique Por F110 Propuesta' int_tabla-laufd int_tabla-laufi.
        ELSE.
          IF zlsch = 'C' .
            UPDATE zfipg002_det
                 SET    estado = 'I'
                 WHERE  bukrs = bukrs
                 AND    nproceso = int_tabla-nproceso
                 AND    laufi    = int_tabla-laufi
                 AND    laufd    = int_tabla-laufd .
          ELSE.
            UPDATE zfipg002_det
                   SET    estado = 'P'
                   WHERE  bukrs = bukrs
                   AND    nproceso = int_tabla-nproceso
                   AND    laufi    = int_tabla-laufi
                   AND    laufd    = int_tabla-laufd .
          ENDIF.
          PERFORM proceso.
        ENDIF.
      ELSE.
        IF int_tabla-estado = 'I'.

          MESSAGE s004(zfi) WITH 'Propuesta ya tiene confirmacion de pago'.
        ELSE.
          MESSAGE s004(zfi) WITH 'Propuesta con errores no puede confirmar pago'.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " GENERO_PAGO


*&---------------------------------------------------------------------*
*&      Form  GENERO_CHEQUE
*&---------------------------------------------------------------------*
FORM genero_cheque .

  DATA v_remesa LIKE int_tabla-chect.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM zfipg003 WHERE bukrs = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM zfipg003 WHERE bukrs = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc = 0.
    nfirma1  = zfipg003-nfirma1.
    dir_org1 = zfipg003-dir_org1.
*    dir_des1 = zfipg003-dir_des1.
    nfirma2  = zfipg003-nfirma2.
    dir_org2 = zfipg003-dir_org2.
*    dir_des2 = zfipg003-dir_des2.
  ELSE.
    nfirma1  = ''.
    dir_org1 = ''.
*    dir_des1 = ''.
    nfirma2  = ''.
    dir_org2 = ''.
*    dir_des2 =''.
  ENDIF.
  CLEAR: pass1, pass2.
  LOOP AT int_tabla.
    IF int_tabla-sel = 'X'.
      IF int_tabla-estado = 'I'.

        v_remesa = int_tabla-ult_remesa + int_tabla-nchequ.
        CONDENSE v_remesa.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = v_remesa
          IMPORTING
            output = v_remesa.

        IF v_remesa > int_tabla-chect.

          DATA: bdcdata_wa  TYPE bdcdata,
                bdcdata_tab TYPE TABLE OF bdcdata.
          DATA opt TYPE ctu_params.

          SET PARAMETER ID: 'BUK' FIELD bukrs,
                            'HBK' FIELD int_tabla-hbkid,
                            'HKT' FIELD ''.

          CALL TRANSACTION 'FCHI'.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*          SELECT chect checl FROM pcec INTO CORRESPONDING FIELDS OF TABLE ti_pcec
*           WHERE zbukr = soc_pago
*                 AND hbkid = int_tabla-hbkid
*                 AND xchch NE 'X'.
*
* NEW CODE
          SELECT chect checl
 FROM pcec INTO CORRESPONDING FIELDS OF TABLE ti_pcec
           WHERE zbukr = soc_pago
                 AND hbkid = int_tabla-hbkid
                 AND xchch NE 'X' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
          LOOP AT ti_pcec.
            int_tabla-chect = ti_pcec-chect.
            IF ti_pcec-checl < ti_pcec-chect.
              int_tabla-ult_remesa = ti_pcec-checl + 1.
              EXIT.
            ENDIF.
          ENDLOOP.

          int_tabla-tot_remesa = ( int_tabla-ult_remesa + int_tabla-nchequ ) - 1.
          CONDENSE int_tabla-tot_remesa.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = int_tabla-tot_remesa
            IMPORTING
              output = int_tabla-tot_remesa.
          IF int_tabla-tot_remesa > ti_pcec-chect.

          ENDIF.

          IF int_tabla-tot_remesa > int_tabla-chect.
            CLEAR band.
            LOOP AT ti_pcec.
              IF ti_pcec-stapl = int_tabla-fstap AND ti_pcec-chect >= int_tabla-tot_remesa.
                band = 1.
                int_tabla-chect = ti_pcec-chect.
                EXIT.
              ENDIF.
            ENDLOOP.

            IF band IS INITIAL.
              MESSAGE 'La Remesa no esta activa' TYPE 'E'.
            ENDIF.
          ENDIF.

          PERFORM proceso.
        ENDIF.

        CALL SCREEN 300 STARTING AT 20 05 ENDING AT 125 20.

      ELSE.
        IF int_tabla-estado = ''.
          MESSAGE s004(zfi) WITH 'Propuesta sin confirmacion de pago'.
        ELSE.
          MESSAGE s004(zfi) WITH 'Propuesta con errores no puede confirmar pago'.
        ENDIF.


      ENDIF.


    ENDIF.

  ENDLOOP.

ENDFORM.                    " GENERO_CHEQUE


*&---------------------------------------------------------------------*
*&      Form  VER_DETALLE
*&---------------------------------------------------------------------*
FORM ver_detalle .

  DATA: fecha1(8).

  LOOP AT int_tabla.
    IF int_tabla-sel = 'X'.
      CLEAR int_tabla-sel.
      MODIFY int_tabla.

      REFRESH bdcdata.
      fecha1+0(2) = int_tabla-laufd+6(2).
      fecha1+2(2) = int_tabla-laufd+4(2).
      fecha1+4(4) = int_tabla-laufd+0(4).

      PERFORM bdc_dynpro      USING 'SAPF110O' '0100'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'REGUH-ABSBU'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    'UE'.
      PERFORM bdc_field       USING 'REGUH-LAUFD'
                                    fecha1.
      PERFORM bdc_field       USING 'REGUH-LAUFI'
                                    int_tabla-laufi.
      PERFORM bdc_field       USING 'REGUH-ZBUKR'
                                    bukrs.
      PERFORM bdc_field       USING 'REGUH-ABSBU'
                                    bukrs.

      CALL TRANSACTION 'FBZ0' USING bdcdata
                                    MODE 'E'.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " VER_DETALLE


*&---------------------------------------------------------------------*
*&      Form  GENERO_TRANSFER
*&---------------------------------------------------------------------*
FORM genero_transfer.

  DATA: ls_fipg003_par TYPE zst_fipg003_par.

  DATA: fecha1 TYPE c LENGTH 8,
        fecha2 TYPE c LENGTH 8,
        veces  TYPE n LENGTH 4,
        n_min  TYPE i VALUE 600. "Numero de iteraciones del docto

***
  LOOP AT int_tabla WHERE sel = abap_true.

    IF int_tabla-estado = ''.

      CLEAR: ls_fipg003_par.
      PERFORM det_param_value USING bukrs int_tabla-hbkid int_tabla-laufd
                                    int_tabla-laufi zlsch
                              CHANGING ls_fipg003_par.
      IF ls_fipg003_par IS INITIAL.
*       No se encontró configuración para la sociedad & / Banco &
        MESSAGE i023(zfi) WITH bukrs int_tabla-hbkid.
      ENDIF.


      fecha1 = |{ sy-datum+6(2) }{ sy-datum+4(2) }{ sy-datum+0(4) }|.
      fecha2 = |{ int_tabla-laufd+6(2) }{ int_tabla-laufd+4(2) }{ int_tabla-laufd+0(4) }|.

*     Transacción F110 pagos automáticos
      REFRESH bdcdata.

      PERFORM bdc_dynpro USING 'SAPF110V'     '0200'.
      PERFORM bdc_field  USING 'BDC_CURSOR'   'F110V-LAUFI'.
      PERFORM bdc_field  USING 'BDC_OKCODE'   '=ENTER'.
      PERFORM bdc_field  USING 'F110V-LAUFD'  fecha2.
      PERFORM bdc_field  USING 'F110V-LAUFI'  int_tabla-laufi.
*
      PERFORM bdc_dynpro USING 'SAPF110V'     '0200'.
      PERFORM bdc_field  USING 'BDC_CURSOR'   'F110V-LAUFI'.
      PERFORM bdc_field  USING 'BDC_OKCODE'   '=ZAEX'.
*
      PERFORM bdc_dynpro USING 'SAPF110V'     '1106'.
      PERFORM bdc_field  USING 'BDC_CURSOR'   'F110V-XSTRF'.
      PERFORM bdc_field  USING 'BDC_OKCODE'   '=EP'.
      PERFORM bdc_field  USING 'F110V-STRDT'  fecha1.
      PERFORM bdc_field  USING 'F110V-XSTRF'  'X'.
      PERFORM bdc_field  USING 'F110V-STRZT'  ''.

      CALL TRANSACTION 'F110' USING bdcdata
                              MODE 'E'
                              UPDATE 'S'
                              MESSAGES INTO itab.

      IF NOT ls_fipg003_par-programm IS INITIAL.
        PERFORM submit_prog USING ls_fipg003_par int_tabla-XZZMOT_EMIS.
      ENDIF.

**    Continua lo viejo
      sy-subrc = 1.
      veces    = 0.

      WHILE sy-subrc <> 0 AND veces <= n_min .
        WAIT UP TO 06 SECONDS.
        veces = veces + 1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM reguv
*                        WHERE laufd = int_tabla-laufd
*                        AND laufi   = int_tabla-laufi
*                        AND xecht    = 'X'.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM reguv
                        WHERE laufd = int_tabla-laufd
                        AND laufi   = int_tabla-laufi
                        AND xecht    = 'X' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      ENDWHILE.

      IF sy-subrc <> 0 AND veces > n_min.
        MESSAGE e004(zfi) WITH 'Se supero tiempo de espera(60 min).' 'Verifique Por F110 Propuesta' int_tabla-laufd int_tabla-laufi.
      ELSE.
        IF zlsch = 'C' .
          UPDATE zfipg002_det
            SET estado = 'I'
            WHERE bukrs = bukrs
              AND nproceso = int_tabla-nproceso
              AND laufi    = int_tabla-laufi
              AND laufd    = int_tabla-laufd .
        ELSE.
          UPDATE zfipg002_det
            SET estado = 'P'
            WHERE bukrs = bukrs
              AND nproceso = int_tabla-nproceso
              AND laufi    = int_tabla-laufi
              AND laufd    = int_tabla-laufd .
        ENDIF.
        PERFORM proceso.
      ENDIF.
    ELSE.
      IF int_tabla-estado = 'I'.
        MESSAGE s004(zfi) WITH 'Propuesta ya tiene confirmacion de pago'.
      ELSE.
        MESSAGE s004(zfi) WITH 'Propuesta con errores no puede confirmar pago'.
      ENDIF.
    ENDIF.

  ENDLOOP.
***

ENDFORM.                    " GENERO_TRANSFER


*&---------------------------------------------------------------------*
*&      Form  DET_PARAM_VALUE
*&---------------------------------------------------------------------*
FORM det_param_value  USING    iv_bukrs       TYPE bukrs
                               iv_hbkid       TYPE hbkid
                               iv_laufd       TYPE laufd
                               iv_laufi       TYPE laufi
                               iv_zlsch       TYPE dzlsch
                      CHANGING cs_fipg003_par TYPE zst_fipg003_par.

  DATA: lt_fields TYPE STANDARD TABLE OF sval.

  DATA: lv_returncode TYPE c.

* Busca datos de tabla de configuración de salida
  CLEAR: cs_fipg003_par.

  SELECT SINGLE FROM zfipg003_out
    FIELDS programm, f_laufd, f_laufi, f_zlsch, f_nrotran, f_retvvfi, f_filename,
           f_fecpag, f_convenio, f_modulo, f_servicio, f_descripcion
    WHERE bukrs = @iv_bukrs
      AND hbkid = @iv_hbkid
    INTO @DATA(ls_confi).

  IF sy-subrc = 0.
*-> BEG Nueva definición de RV para que no aparezca popup 06.08.2024
*    IF ls_confi-f_nrotran = abap_true.
*      APPEND INITIAL LINE TO lt_fields ASSIGNING FIELD-SYMBOL(<ls_fields>).
*      <ls_fields>-tabname    = 'ZST_FIPG003_PAR'.
*      <ls_fields>-fieldname  = 'NROTRAN'.
*      <ls_fields>-field_attr = '01'.
*      <ls_fields>-field_obl  = 'X'.
*      <ls_fields>-fieldtext  = 'N° transferencia'.
*    ENDIF.
*    IF ls_confi-f_retvvfi = abap_true.
*      APPEND INITIAL LINE TO lt_fields ASSIGNING <ls_fields>.
*      <ls_fields>-tabname    = 'ZST_FIPG003_PAR'.
*      <ls_fields>-fieldname  = 'RETVVF'.
*      <ls_fields>-field_attr = '01'.
*      <ls_fields>-field_obl  = ' '.
*      <ls_fields>-fieldtext  = 'Retiro VV Filial'.
*    ENDIF.
*    IF ls_confi-f_filename = abap_true.
*      APPEND INITIAL LINE TO lt_fields ASSIGNING <ls_fields>.
*      <ls_fields>-tabname    = 'ZST_FIPG003_PAR'.
*      <ls_fields>-fieldname  = 'FILENAME'.
*      <ls_fields>-field_attr = '01'.
*      <ls_fields>-field_obl  = 'X'.
*      <ls_fields>-fieldtext  = 'Directorio del archivo'.
*      <ls_fields>-value = 'C:\TRANSFER\'.
*    ENDIF.
*    IF ls_confi-f_fecpag = abap_true.
*      APPEND INITIAL LINE TO lt_fields ASSIGNING <ls_fields>.
*      <ls_fields>-tabname    = 'ZST_FIPG003_PAR'.
*      <ls_fields>-fieldname  = 'FECPAG'.
*      <ls_fields>-field_attr = '01'.
*      <ls_fields>-field_obl  = 'X'.
*      <ls_fields>-fieldtext  = 'Fecha pago'.
*    ENDIF.
*    IF ls_confi-f_convenio = abap_true.
*      APPEND INITIAL LINE TO lt_fields ASSIGNING <ls_fields>.
*      <ls_fields>-tabname    = 'ZST_FIPG003_PAR'.
*      <ls_fields>-fieldname  = 'CONVENIO'.
*      <ls_fields>-field_attr = '01'.
*      <ls_fields>-field_obl  = 'X'.
*      <ls_fields>-fieldtext  = 'Convenio'.
*    ENDIF.
*    IF  ls_confi-f_modulo = abap_true.
*      APPEND INITIAL LINE TO lt_fields ASSIGNING <ls_fields>.
*      <ls_fields>-tabname    = 'ZST_FIPG003_PAR'.
*      <ls_fields>-fieldname  = 'MODULO'.
*      <ls_fields>-field_attr = '01'.
*      <ls_fields>-field_obl  = 'X'.
*      <ls_fields>-fieldtext  = 'Módulo'.
*    ENDIF.
*    IF ls_confi-f_servicio = abap_true.
*      APPEND INITIAL LINE TO lt_fields ASSIGNING <ls_fields>.
*      <ls_fields>-tabname    = 'ZST_FIPG003_PAR'.
*      <ls_fields>-fieldname  = 'SERVICIO'.
*      <ls_fields>-field_attr = '01'.
*      <ls_fields>-field_obl  = 'X'.
*      <ls_fields>-fieldtext  = 'Servicio'.
*    ENDIF.
*    IF ls_confi-f_descripcion = abap_true.
*      APPEND INITIAL LINE TO lt_fields ASSIGNING <ls_fields>.
*      <ls_fields>-tabname    = 'ZST_FIPG003_PAR'.
*      <ls_fields>-fieldname  = 'DESCRIPCION'.
*      <ls_fields>-field_attr = '01'.
*      <ls_fields>-field_obl  = 'X'.
*      <ls_fields>-fieldtext  = 'Descripción'.
*    ENDIF.
*
*    CALL FUNCTION 'POPUP_GET_VALUES'
*      EXPORTING
*        popup_title     = 'Datos adicionales'
**       START_COLUMN    = '5'
**       START_ROW       = '5'
*      IMPORTING
*        returncode      = lv_returncode
*      TABLES
*        fields          = lt_fields
*      EXCEPTIONS
*        error_in_fields = 1
*        OTHERS          = 2.
*
*    IF sy-subrc <> 0 OR lv_returncode = 'A'.
*      CLEAR: cs_fipg003_par.
*      RETURN.
*    ENDIF.
*-> END Nueva definición de RV para que no aparezca popup 06.08.2024

    CLEAR: cs_fipg003_par.
    cs_fipg003_par-programm = ls_confi-programm.
    cs_fipg003_par-bukrs    = iv_bukrs.
    cs_fipg003_par-laufd    = iv_laufd.
    cs_fipg003_par-laufi    = iv_laufi.
    cs_fipg003_par-zlsch    = iv_zlsch.
    cs_fipg003_par-hbkid    = iv_hbkid.

*-> BEG Nueva definición de RV para que no aparezca popup 06.08.2024
*    LOOP AT lt_fields ASSIGNING <ls_fields>.
*      CASE <ls_fields>-fieldname.
*        WHEN 'NROTRAN'.
*          cs_fipg003_par-nrotran = <ls_fields>-value.
*        WHEN 'RETVVF'.
*          cs_fipg003_par-retvvf  = <ls_fields>-value.
*        WHEN 'FILENAME'.
*          cs_fipg003_par-filename = <ls_fields>-value.
*        WHEN 'FECPAG'.
*          cs_fipg003_par-fecpag = <ls_fields>-value.
*        WHEN 'CONVENIO'.
*          cs_fipg003_par-convenio = <ls_fields>-value.
*        WHEN 'MODULO'.
*          cs_fipg003_par-modulo = <ls_fields>-value.
*        WHEN 'SERVICIO'.
*          cs_fipg003_par-servicio = <ls_fields>-value.
*        WHEN 'DESCRIPCION'.
*          cs_fipg003_par-descripcion = <ls_fields>-value.
*      ENDCASE.
*    ENDLOOP.
*-> END Nueva definición de RV para que no aparezca popup 06.08.2024
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  SUBMIT_PROG
*&---------------------------------------------------------------------*
FORM submit_prog  USING is_fipg003_par TYPE zst_fipg003_par
                        zzmot_emisx.
  DATA  : archivo     TYPE string.
  DATA: lv_archivo TYPE string.
DATA:  numero(9)        TYPE n,
        numero11(11)     TYPE n,
        numero14(14)     TYPE n,
        num_c(8)         TYPE c,
        dv,
         numsan(2)        TYPE n,
        secw(3)          TYPE n,
        v_rut(10)        TYPE c,

            letsan(2),
            v_adrnr          TYPE adrc-addrnumber,
         f_adrnr          TYPE adrc-addrnumber,
         ti_adrc       TYPE adrc       OCCURS 0 WITH HEADER LINE.
 archivo = 'C:\TRANSFER\'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*   SELECT SINGLE adrnr
*            FROM t001
*            INTO v_adrnr
*            WHERE bukrs EQ   is_fipg003_par-bukrs.
*
* NEW CODE
   SELECT adrnr
   UP TO 1 ROWS 
            FROM t001
            INTO v_adrnr
            WHERE bukrs EQ   is_fipg003_par-bukrs ORDER BY PRIMARY KEY.

   ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    f_adrnr = v_adrnr.
IF f_adrnr IS NOT INITIAL.
      CALL FUNCTION 'RTP_US_DB_ADRC_READ'
        EXPORTING
          i_address_number = f_adrnr
        IMPORTING
          e_adrc           = ti_adrc
        EXCEPTIONS
          not_found        = 1
          OTHERS           = 2.
    ENDIF.

    v_rut = ti_adrc-sort1.

    IF v_rut IS NOT INITIAL.
      SPLIT v_rut AT '-' INTO num_c dv.
      numero = num_c.

    ENDIF.


  SELECT SINGLE FROM zfipg003_out
    FIELDS programm, f_laufd, f_laufi, f_zlsch, f_nrotran, f_retvvfi, f_filename,
           f_fecpag, f_convenio, f_modulo, f_servicio, f_descripcion
    WHERE bukrs = @is_fipg003_par-bukrs
      AND hbkid = @is_fipg003_par-hbkid
    INTO @DATA(ls_confi).

*  BREAK v1_fun.

  CASE is_fipg003_par-programm.
    WHEN 'ZFITR010_V2_WS' OR 'ZFITR010_WS'.
      SUBMIT (is_fipg003_par-programm) VIA SELECTION-SCREEN
        WITH bukrs    = is_fipg003_par-bukrs
        WITH v_fecha  = is_fipg003_par-laufd
        WITH v_nomina = is_fipg003_par-laufi
        WITH p_viapag = is_fipg003_par-zlsch
        WITH v_nrotra = is_fipg003_par-nrotran
        WITH v_modulo = is_fipg003_par-modulo
        WITH v_servi  = is_fipg003_par-servicio
        WITH v_fpago  = is_fipg003_par-fecpag
        WITH v_descr  = is_fipg003_par-descripcion
        WITH par_tes  = abap_true
        AND RETURN.

    WHEN 'ZFITR030'.
*     ID de banco propio
      SELECT SINGLE FROM t012 FIELDS bankl
        WHERE bukrs =  @is_fipg003_par-bukrs
          AND hbkid =  @is_fipg003_par-hbkid
        INTO @DATA(lv_bankl).
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*     SELECT SINGLE  * FROM  zfimotemisan WHERE bukrs      =  is_fipg003_par-bukrs
*                                          AND zmotiv     =   zzmot_emisx.
*
* NEW CODE
     SELECT *
     UP TO 1 ROWS  FROM  zfimotemisan WHERE bukrs      =  is_fipg003_par-bukrs
                                          AND zmotiv     =   zzmot_emisx ORDER BY PRIMARY KEY.

     ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


            IF sy-subrc = 0.
              numsan = zfimotemisan-znumero.
              letsan = zfimotemisan-zletras.
            ELSE.
              MESSAGE e004(zfi) WITH 'No existe equivalencia para HUB Santander: ' is_fipg003_par-bukrs zzmot_emisx.
            ENDIF.
    secw = is_fipg003_par-laufi+2(3).
    IF bukrs = 'CL24'.
      numero = 96572800.
      dv     = '7'.
      secw = secw + 700.
    ENDIF.
      numero14 = numero.
*     Nombre de archivo
      CLEAR: lv_archivo.
*      lv_archivo = |{ is_fipg003_par-filename }{ is_fipg003_par-bukrs }_BSANT_{ is_fipg003_par-laufi }_{ sy-datum }_{ sy-uzeit }.txt|.
          if lv_bankl = '037' or lv_bankl = '37'.
          " CONCATENATE archivo 'MN' letsan numero14 dv is_fipg003_par-laufd secw+0(3) '.txt'
          "    INTO lv_archivo.
                lv_archivo = 'C:\TRANSFER\'. "HCD 27-02-2025
                SUBMIT (is_fipg003_par-programm) VIA SELECTION-SCREEN
                  WITH bukrs    = is_fipg003_par-bukrs
                  WITH v_fecha  = is_fipg003_par-laufd
                  WITH v_nomina = is_fipg003_par-laufi
                  WITH v_banco  = lv_bankl
                  WITH v_nrotra = is_fipg003_par-nrotran
                  WITH archivo  = lv_archivo
                  WITH par_vv   = is_fipg003_par-retvvf
                  WITH par_tes  = abap_true
                  AND RETURN.
          else.
              lv_archivo = 'C:\TRANSFER\'.  "HCD 27-02-2025
             SUBMIT (is_fipg003_par-programm) VIA SELECTION-SCREEN
                  WITH bukrs    = is_fipg003_par-bukrs
                  WITH v_fecha  = is_fipg003_par-laufd
                  WITH v_nomina = is_fipg003_par-laufi
                  WITH v_banco  = lv_bankl
                  WITH v_nrotra = is_fipg003_par-nrotran
                  WITH archivo  = lv_archivo
                  WITH par_vv   = is_fipg003_par-retvvf
                  WITH par_tes  = abap_true
                  AND RETURN.


          endif.
    WHEN 'ZFITR016'.
"      lv_archivo = |{ is_fipg003_par-filename }{ is_fipg003_par-bukrs }_BSANT_{ is_fipg003_par-laufi }_{ sy-datum }_{ sy-uzeit }.txt|.
  lv_archivo = 'C:\TRANSFER\'.  "HCD 27-02-2025
      SUBMIT (is_fipg003_par-programm) VIA SELECTION-SCREEN
        WITH p_proc   = abap_true
        WITH p_bukrs  = is_fipg003_par-bukrs
        WITH p_fecha  = is_fipg003_par-laufd
        WITH p_nomina = is_fipg003_par-laufi
        WITH p_conven = is_fipg003_par-convenio
        WITH p_fecpag = is_fipg003_par-fecpag
        WITH par_nom  = abap_true
        WITH par_tes  = abap_false
        WITH par_di   = abap_true
        WITH p_archiv = lv_archivo
        AND RETURN.
 WHEN 'ZFITR016_WS'. " 19-03-2025 HCD
"      lv_archivo = |{ is_fipg003_par-filename }{ is_fipg003_par-bukrs }_BSANT_{ is_fipg003_par-laufi }_{ sy-datum }_{ sy-uzeit }.txt|.
 lv_archivo = 'C:\TRANSFER\'.  "HCD 27-02-2025
      SUBMIT (is_fipg003_par-programm) VIA SELECTION-SCREEN
        WITH p_proc   = abap_true
        WITH p_bukrs  = is_fipg003_par-bukrs
        WITH p_fecha  = is_fipg003_par-laufd
        WITH p_nomina = is_fipg003_par-laufi
      "  WITH p_conven = is_fipg003_par-convenio
        WITH p_fecpag = is_fipg003_par-fecpag
        WITH par_nom  = abap_true
        WITH par_tes  = abap_false
        WITH par_di   = abap_true
        WITH p_archiv = lv_archivo
        AND RETURN.
*HCD 13-12-2024 INI
      when 'ZTRANSFERSPROV'.
       CONCATENATE 'C:\TRANSFER\' is_fipg003_par-bukrs  '_BSANT' '_' is_fipg003_par-laufi '_' sy-datum '_' sy-uzeit '.txt'
            INTO lv_archivo.
   if is_fipg003_par-ZLSCH EQ 'T'.
  is_fipg003_par-programm = 'ZFITR006'."''ZTRANSFERSDIV'.
        SUBMIT (is_fipg003_par-programm) VIA SELECTION-SCREEN
            WITH p_proc   = abap_true
            WITH bukrs  = is_fipg003_par-bukrs
            WITH v_fecha  = is_fipg003_par-laufd
            WITH v_nomina = is_fipg003_par-laufi
* WITH p_conven = is_fipg003_par-convenio
* WITH p_fecpag = is_fipg003_par-fecpag
            WITH par_nom  = abap_true
            WITH par_tes  = abap_false
            WITH par_di   = abap_true
             WITH archivo  = lv_archivo
           AND RETURN.
     elseif is_fipg003_par-ZLSCH EQ 'V'.
              is_fipg003_par-programm = 'ZFITR007'. "'ZTRANSFERSPROV'.
                    SUBMIT (is_fipg003_par-programm) VIA SELECTION-SCREEN
                        WITH p_proc   = abap_true
                        WITH bukrs  = is_fipg003_par-bukrs
                        WITH V_fecha  = is_fipg003_par-laufd
                        WITH V_nomina = is_fipg003_par-laufi
*                        WITH p_conven = is_fipg003_par-convenio
*                        WITH p_fecpag = is_fipg003_par-fecpag
                        WITH par_nom  = abap_true
                        WITH par_tes  = abap_false
                        WITH par_di   = abap_true
                         WITH archivo  = lv_archivo
                       AND RETURN.
        endif.
       when 'ZTRANSFERSDIV'.
       CONCATENATE 'C:\TRANSFER\' is_fipg003_par-bukrs '_BSANT' '_' is_fipg003_par-laufi '_' sy-datum '_' sy-uzeit '.txt'
            INTO lv_archivo.

            if is_fipg003_par-ZLSCH EQ 'T'.
            is_fipg003_par-programm = 'ZFITR006'."''ZTRANSFERSDIV'.
                  SUBMIT (is_fipg003_par-programm) VIA SELECTION-SCREEN
                      WITH p_proc   = abap_true
                      WITH bukrs  = is_fipg003_par-bukrs
                      WITH v_fecha  = is_fipg003_par-laufd
                      WITH v_nomina = is_fipg003_par-laufi
*                      WITH p_conven = is_fipg003_par-convenio
*                      WITH p_fecpag = is_fipg003_par-fecpag
                      WITH par_nom  = abap_true
                      WITH par_tes  = abap_false
                      WITH par_di   = abap_true
                       WITH archivo  = lv_archivo
                     AND RETURN.
               elseif is_fipg003_par-ZLSCH EQ 'V'.
                        is_fipg003_par-programm = 'ZFITR007'. "'ZTRANSFERSPROV'.
                              SUBMIT (is_fipg003_par-programm) VIA SELECTION-SCREEN
                                  WITH p_proc   = abap_true
                                  WITH bukrs  = is_fipg003_par-bukrs
                                  WITH v_fecha  = is_fipg003_par-laufd
                                  WITH v_nomina = is_fipg003_par-laufi
*                                  WITH p_conven = is_fipg003_par-convenio
*                                  WITH p_fecpag = is_fipg003_par-fecpag
                                  WITH par_nom  = abap_true
                                  WITH par_tes  = abap_false
                                  WITH par_di   = abap_true
                                  WITH archivo  = lv_archivo
                                 AND RETURN.
                  endif.

*HCD 13-12-2024 FIN


  ENDCASE.

ENDFORM.
