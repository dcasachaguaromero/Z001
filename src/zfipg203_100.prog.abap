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

  CASE sy-ucomm.

    WHEN 'PAGO'.
      PERFORM genero_pago.
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
SORT TABLA-COLS .
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
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control_0100 OUTPUT.
  READ TABLE int_tabla INTO zfipg203_est INDEX tabla-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VALIDA-GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida-grilla_0100 INPUT.

  IF zfipg203_est-nchequ_s > 3.
    MESSAGE e004(zfi) WITH 'Cheques sueltos Mayor a 3'.
  ENDIF.


  IF zfipg203_est-nchequ_s > zfipg203_est-nchequ.

    MESSAGE e004(zfi) WITH 'Cheques sueltos Mayor a N° de Cheques'.
  ENDIF.

  IF zfipg203_est-nchequ_s <  zfipg203_est-nchequ.
    zfipg203_est-nhojas =  ( ( zfipg203_est-nchequ - zfipg203_est-nchequ_s ) / 4 ).
    resto  =  ( ( zfipg203_est-nchequ - zfipg203_est-nchequ_s ) MOD 4 ).
    IF resto = 1 .
      zfipg203_est-nhojas = zfipg203_est-nhojas + 1.
    ENDIF.
  ELSE.
    zfipg203_est-nhojas = 0.
  ENDIF.

  MODIFY int_tabla FROM zfipg203_est INDEX tabla-current_line
     TRANSPORTING sel nchequ_s nhojas.

ENDMODULE.                 " VALIDA-GRILLA_0100  INPUT



*&---------------------------------------------------------------------*
*&      Form  GENERO_PAGO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM genero_pago .

  DATA: fecha1(8),
        fecha2(8),
        veces(4)     TYPE n,
        n_min TYPE i VALUE 600. "Numero de iteraciones del docto


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

        PERFORM bdc_dynpro      USING 'SAPF110V' '0200'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'F110V-LAUFI'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=ENTER'.
        PERFORM bdc_field       USING 'F110V-LAUFD'
                                      fecha2.
        PERFORM bdc_field       USING 'F110V-LAUFI'
                                      int_tabla-laufi.

        PERFORM bdc_dynpro      USING 'SAPF110V' '0200'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'F110V-LAUFI'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=ZAEX'.




        PERFORM bdc_dynpro      USING 'SAPF110V' '1106'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'F110V-XSTRF'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=EP'.
        PERFORM bdc_field       USING 'F110V-STRDT'
                                       fecha1.
        PERFORM bdc_field       USING 'F110V-XSTRF'
                                      'X'.
        PERFORM bdc_field       USING 'F110V-STRZT'
                                      ''.
        CALL TRANSACTION 'F110' USING bdcdata
                                  MODE 'E'
                                  UPDATE 'S'
                                  MESSAGES INTO itab.

        CLEAR v_bankl.

        SELECT SINGLE bankl FROM t012 INTO v_bankl
          WHERE bukrs EQ bukrs AND hbkid EQ int_tabla-hbkid.
" OBTENER TIPO DETALLE PARA EMPRESA 037 INI
        IF v_bankl EQ '037'. " Si es banco '037' validar si tiene detalle de nomina
             SELECT SINGLE DETALLE_NOMINA INTO v_DETALLE
               FROM ZMOT_PAG
               WHERE BUKRS  EQ bukrs
               AND   ZZMOT_EMIS EQ int_tabla-XZZMOT_EMIS
               AND  ID_BANCO EQ '037'.
        ENDIF.
" OBTENER TIPO DETALLE PARA EMPRESA 037 FIN


*        IF v_bankl EQ '037' and sy-subrc = 0.

*              IF v_DETALLE EQ 'A'.
*                CONCATENATE 'C:\TRANSFER\' bukrs '_BSANT' '_' int_tabla-laufi '_' sy-datum '_' sy-uzeit '.txt'
*                INTO v_archivo.
*                SET PARAMETER ID: 'SOC' FIELD bukrs,
*                                  'FEC' FIELD int_tabla-laufd,
*                                  'NOM' FIELD int_tabla-laufi,
*                                  'ARC' FIELD v_archivo.
*                CALL TRANSACTION 'ZTRANSFERSDIV'.
*
*              ELSEIF v_DETALLE EQ 'D'.
*                CONCATENATE 'C:\TRANSFER\' bukrs '_BSANT' '_' int_tabla-laufi '_' sy-datum '_' sy-uzeit '.txt'
*                INTO v_archivo.
*                SET PARAMETER ID: 'SOC' FIELD bukrs,
*                                  'FEC' FIELD int_tabla-laufd,
*                                  'NOM' FIELD int_tabla-laufi,
*                                  'ARC' FIELD v_archivo.
*                CALL TRANSACTION 'ZTRANSFERSPROV'.
*
*              ENDIF.
*        else.
*                  IF v_bankl EQ '037' AND zlsch EQ 'T'.
*                CONCATENATE 'C:\TRANSFER\' bukrs '_BSANT' '_' int_tabla-laufi '_' sy-datum '_' sy-uzeit '.txt'
*                INTO v_archivo.
*                SET PARAMETER ID: 'SOC' FIELD bukrs,
*                                  'FEC' FIELD int_tabla-laufd,
*                                  'NOM' FIELD int_tabla-laufi,
*                                  'ARC' FIELD v_archivo.
*                CALL TRANSACTION 'ZTRANSFERSDIV'.
*
*              ELSEIF v_bankl EQ '037' AND zlsch EQ 'V'.
*                CONCATENATE 'C:\TRANSFER\' bukrs '_BSANT' '_' int_tabla-laufi '_' sy-datum '_' sy-uzeit '.txt'
*                INTO v_archivo.
*                SET PARAMETER ID: 'SOC' FIELD bukrs,
*                                  'FEC' FIELD int_tabla-laufd,
*                                  'NOM' FIELD int_tabla-laufi,
*                                  'ARC' FIELD v_archivo.
*                CALL TRANSACTION 'ZTRANSFERSPROV'.
*
*              ELSEIF v_bankl EQ '027' AND zlsch EQ 'V'.
              IF v_bankl EQ '027' AND zlsch EQ 'V'.
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

*        endif.
        sy-subrc = 1.
        veces = 0.
        WHILE sy-subrc <> 0 AND veces <= n_min .
          WAIT UP TO 06 SECONDS.
          veces = veces + 1.
          SELECT SINGLE * FROM reguv
                          WHERE laufd = int_tabla-laufd
                          AND laufi   = int_tabla-laufi
                          AND xecht    = 'X'.

        ENDWHILE.

        IF sy-subrc <> 0 AND veces > n_min.
          MESSAGE e004(zfi) WITH 'Se supero tiempo de espera(60 min).' 'Verifique Por F110 Propuesta' int_tabla-laufd int_tabla-laufi.
        ELSE.
          IF zlsch = 'C' .
            UPDATE zfipg200_det
                 SET    estado = 'I'
                 WHERE  bukrs = bukrs
                 AND    nproceso = int_tabla-nproceso
                 AND    laufi    = int_tabla-laufi
                 AND    laufd    = int_tabla-laufd .
          ELSE.
            UPDATE zfipg200_det
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
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM genero_cheque .

  DATA v_remesa LIKE int_tabla-chect.

  SELECT SINGLE * FROM zfipg003 WHERE bukrs = bukrs.

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

          SELECT chect checl FROM pcec INTO CORRESPONDING FIELDS OF TABLE ti_pcec
           WHERE zbukr = soc_pago
                 AND hbkid = int_tabla-hbkid
                 AND xchch NE 'X'.
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
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
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
      .

    ENDIF.


  ENDLOOP.


ENDFORM.                    " VER_DETALLE
