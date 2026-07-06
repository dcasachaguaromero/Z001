*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_200
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  DATA: fecha(10),
        hora(10).

  REFRESH tab.
  MOVE 'REFR' TO tab-fcode.
  APPEND tab.
  MOVE 'PAGO' TO tab-fcode.
  APPEND tab.
  MOVE 'MOD' TO tab-fcode.
  APPEND tab.
  MOVE 'MODMASS' TO tab-fcode.
  APPEND tab.
  MOVE 'MODREF' TO tab-fcode.
  APPEND tab.

  AUTHORITY-CHECK OBJECT 'Z_TCODE'
     ID 'ACTVT'  FIELD '01'
     ID 'ZTCODE' FIELD 'ZFIPG002'.

  IF sy-subrc NE 0.
    MOVE 'PROP' TO tab-fcode.
    APPEND tab.        " the user is NOT authorized to create
  ENDIF.

  SET  PF-STATUS 'ZFIPG002' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

  WRITE sy-datum  TO fecha.
  WRITE sy-uzeit  TO hora.

  CONCATENATE 'PROCESO-' fecha '-' hora '-' zlsch INTO zfipg200_cab-descr.

ENDMODULE.                             " STATUS_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'RW'.
      LEAVE TO SCREEN 0.

    WHEN 'PROP'.
      PERFORM batchinput_propuesta.

    WHEN 'EXCEL'.
      REFRESH texcel.
      LOOP AT tprop2.

        IF sy-tabix = 1.

          texcel-zzmot_emis = 'Ejecución el'.
          texcel-blart = 'Identificador'.
          texcel-gjahr = 'Fecha Base'.
          texcel-belnr = 'Banco Propio'.
          texcel-buzei = 'Via de Pago'.
          texcel-zfbdt = 'Motivos'.
          texcel-hbkid = 'N° Pagos'.
          texcel-zlsch = 'Monto'.

          APPEND texcel.
          CLEAR texcel.

        ENDIF.

        texcel-zzmot_emis = tprop2-laufd .
        texcel-blart = tprop2-laufi.
        texcel-gjahr = tprop2-zfbdt.
        texcel-belnr = tprop2-hbkid.
        texcel-buzei = tprop2-zlsch.
        texcel-zfbdt = tprop2-xzzmot_emis.
        texcel-hbkid = tprop2-docto_ban.
        WRITE tprop2-wrbtr     TO texcel-zlsch CURRENCY t001-waers.

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
MODULE fill_table_control_0200 OUTPUT.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
*SORT INT_TABLA2 . "JOROZCO 24.01.2020
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
  READ TABLE int_tabla2 INTO zfipg200_a_est INDEX tabla2-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Form  batchinput_propuesta
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM batchinput_propuesta.

  DATA: fecha1(8),
        fecha2(8),
        fecha3(8),
        fecha         LIKE sy-datum,
        nproceso      LIKE zfipg200_cab-nproceso,
        variante1(20),
        variante2(20),
        veces(4)      TYPE n.

  IF zfipg200_cab-descr IS INITIAL.
    MESSAGE s004(zfi) WITH 'Debe Ingresar Descripcion'.
  ELSE.


*&-------------------------------------------------------------------*
*& ** BLOQUEO Y RECUPERACION DE FOLIO DE PROPUESTA POR SOCIEDAD-DIA
*&-------------------------------------------------------------------*
    CALL FUNCTION 'ENQUEUE_EZ_ZFOLIO_SOC'
      EXPORTING
        mode_zfolio_soc = 'E'
        mandt           = sy-mandt
        bukrs           = bukrs
        _scope          = 1
      EXCEPTIONS
        foreign_lock    = 1
        system_failure  = 2
        OTHERS          = 3.

    WHILE sy-subrc <> 0.
      WAIT UP TO 03 SECONDS.
      CALL FUNCTION 'ENQUEUE_EZ_ZFOLIO_SOC'
        EXPORTING
          mode_zfolio_soc = 'E'
          mandt           = sy-mandt
          bukrs           = bukrs
          _scope          = 1
        EXCEPTIONS
          foreign_lock    = 1
          system_failure  = 2
          OTHERS          = 3.
    ENDWHILE.
*&--------------------------------------------------------------------------------------------------------------------*

    SELECT SINGLE *  FROM zfolio_soc  WHERE bukrs  = bukrs.

    IF sy-subrc <> 0.
      zfolio_soc-bukrs = bukrs.
      zfolio_soc-folsoc = 0.
    ENDIF.

* USO E INCREMENTO
    nproceso = zfolio_soc-folsoc + 1.
    zfolio_soc-folsoc =  nproceso.
    MODIFY  zfolio_soc.

* DESBLOQUEO
    CALL FUNCTION 'DEQUEUE_EZ_ZFOLIO_SOC'
      EXPORTING
        mode_zfolio_soc = 'E'
        mandt           = sy-mandt
        bukrs           = bukrs.

*----------------------------------------------------------------------------------------
*  De esta manera se determinaba el siguiente numero de proceso
*----------------------------------------------------------------------------------------
*    SELECT MAX( nproceso ) INTO  nproceso
*                           FROM  zfipg200_cab
*                           WHERE bukrs = bukrs.
*----------------------------------------------------------------------------------------

    zfipg200_cab-bukrs       = bukrs.
    zfipg200_cab-nproceso    = nproceso.
    zfipg200_cab-crea_fecha  = sy-datum.
    zfipg200_cab-crea_hora   = sy-uzeit.
    zfipg200_cab-uname       = sy-uname.
    INSERT zfipg200_cab.

    PERFORM limpiar_variantes.

    LOOP AT tprop2 WHERE hbkid <> ''.
      fecha1+0(2) = tprop2-laufd+6(2).
      fecha1+2(2) = tprop2-laufd+4(2).
      fecha1+4(4) = tprop2-laufd+0(4).

      fecha = tprop2-zfbdt + 1.
      fecha2+0(2) = fecha+6(2).
      fecha2+2(2) = fecha+4(2).
      fecha2+4(4) = fecha+0(4).

      fecha3+0(2) = tprop2-zfbdt+6(2).
      fecha3+2(2) = tprop2-zfbdt+4(2).
      fecha3+4(4) = tprop2-zfbdt+0(4).

      CONCATENATE 'ZFO_' bukrs tprop2-hbkid '1'INTO variante1.
      CONCATENATE 'ZFO_' bukrs tprop2-hbkid INTO variante2.

      REFRESH bdcdata.

      PERFORM bdc_dynpro      USING 'SAPF110V' '0200'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'F110V-LAUFI'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM bdc_field       USING 'F110V-LAUFD'
                                     fecha1.
      PERFORM bdc_field       USING 'F110V-LAUFI'
                                     tprop2-laufi.

      PERFORM bdc_dynpro      USING 'SAPF110V' '0200'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'F110V-LAUFD'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=PAR'.
      PERFORM bdc_dynpro      USING 'SAPF110V' '0200'.

      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=SEL'.
      PERFORM bdc_field       USING 'F110C-BUDAT'
                                    fecha3.
      PERFORM bdc_field       USING 'F110C-GRDAT'
                                    fecha3.
      PERFORM bdc_field       USING 'F110V-BUKLS(01)'
                                    bukrs.
      PERFORM bdc_field       USING 'F110V-ZWELS(01)'
                                    tprop2-zlsch.
      PERFORM bdc_field       USING 'F110V-NEDAT(01)'
                                    fecha2.

      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'R_LIFNR-HIGH'.
      PERFORM bdc_field       USING 'R_LIFNR-LOW'
                                    tprop2-lifnr_dde.
      PERFORM bdc_field       USING 'R_LIFNR-HIGH'
                                    tprop2-lifnr_hta.

      PERFORM bdc_dynpro      USING 'SAPF110V' '0200'.

      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=PRI'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'F110V-LIST1(02)'.
      PERFORM bdc_field       USING 'F110V-TEXT1(01)'
                                    'BSEG-ZZMOT_EMIS'.
      PERFORM bdc_field       USING 'F110V-LIST1(01)'
                                    tprop2-xzzmot_emis.
      PERFORM bdc_field       USING 'F110V-TEXT1(02)'
                                    'BSEG-HBKID'.
      PERFORM bdc_field       USING 'F110V-LIST1(02)'
                                    tprop2-hbkid.
      PERFORM bdc_field       USING 'F110V-TEXT1(03)'
                                    'BSEG-ZFBDT'.
      PERFORM bdc_field       USING 'F110V-LIST1(03)'
                                    tprop2-zfbdt.
      PERFORM bdc_field       USING 'F110V-TEXT1(04)'
                                    'BSEG-ZLSCH'.
      PERFORM bdc_field       USING 'F110V-LIST1(04)'
                                    tprop2-zlsch.

      PERFORM bdc_dynpro      USING 'SAPF110V' '0200'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '/EBCK'.

      IF tprop2-zlsch = 'C'.
        PERFORM bdc_field       USING 'F110V-VARI1(03)'
                                      variante1.
        PERFORM bdc_field       USING 'F110V-VARI2(03)'
                                      variante2.
      ENDIF.

      PERFORM bdc_dynpro      USING 'SAPLSPO1' '0100'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                 '=YES'.
      PERFORM bdc_dynpro      USING 'SAPF110V' '0200'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'F110V-LAUFD'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=VOEX'.

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

      PERFORM bdc_dynpro      USING 'SAPF110V' '0200'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'F110V-LAUFD'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=BACK'.
      CALL TRANSACTION 'F110' USING bdcdata
                                MODE 'E'
                                UPDATE 'S'
                                MESSAGES INTO itab.


      sy-subrc = 1.
      veces = 0.
      WHILE sy-subrc <> 0 AND veces < 030 .
        WAIT UP TO 02 SECONDS.
        veces = veces + 1.
        SELECT SINGLE * FROM reguv
                        WHERE laufd = tprop2-laufd
                        AND laufi   = tprop2-laufi
                        AND xvore    = 'X'.


      ENDWHILE.
      zfipg200_det-bukrs       = bukrs.
      zfipg200_det-nproceso    = nproceso.
      zfipg200_det-laufi       = tprop2-laufi .
      zfipg200_det-laufd       = tprop2-laufd.
      zfipg200_det-xzzmot_emis = tprop2-xzzmot_emis.
      zfipg200_det-hbkid       = tprop2-hbkid.
      zfipg200_det-zlsch       = tprop2-zlsch.
      zfipg200_det-zfbdt       = tprop2-zfbdt.
      zfipg200_det-ndocu       = tprop2-docto.
      zfipg200_det-ndocu_ban   = tprop2-docto_ban.
      zfipg200_det-montop      = tprop2-wrbtr.
      zfipg200_det-lifnr_dde   = tprop2-lifnr_dde.
      zfipg200_det-lifnr_hta   = tprop2-lifnr_hta.
      INSERT zfipg200_det.

      IF sy-subrc <> 0 AND veces > 030.
        MESSAGE e004(zfi) WITH 'Se supero tiempo de espera(1 min).' 'Proceso detenido en propueta:' tprop2-laufd tprop2-laufi.
      ENDIF.

*      Grabar tabla zfipg200_det_2
      LOOP AT tpago WHERE zfbdt = tprop2-zfbdt
                      AND zzmot_emis = tprop2-xzzmot_emis
                      AND hbkid = tprop2-hbkid
                      AND zlsch = tprop2-zlsch
                      AND lifnr >= tprop2-lifnr_dde
                      AND lifnr <= tprop2-lifnr_hta.

        zfipg200_det_2-bukrs      = bukrs.
        zfipg200_det_2-nproceso   = zfipg200_det-nproceso.
        zfipg200_det_2-laufi      = zfipg200_det-laufi.
        zfipg200_det_2-laufd      = zfipg200_det-laufd.
        zfipg200_det_2-belnr      = tpago-belnr.
        zfipg200_det_2-gjahr      = tpago-gjahr.
        zfipg200_det_2-buzei      = tpago-buzei.
        zfipg200_det_2-blart      = tpago-blart.
        zfipg200_det_2-waers      = tpago-waers.
        zfipg200_det_2-wrbtr      = tpago-wrbtr.
        INSERT zfipg200_det_2.

      ENDLOOP.

    ENDLOOP.

    LOOP AT int_tabla.
      IF int_tabla-sel = 'X'.
        DELETE int_tabla.
      ENDIF.
    ENDLOOP.
    LEAVE TO SCREEN 0.
  ENDIF.


ENDFORM.                    "
*&---------------------------------------------------------------------*
*&      Form  LIMPIAR_VARIANTES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM limpiar_variantes .

  DATA:
    variante1(20),
    variante2(20).

  LOOP AT tprop2 WHERE hbkid <> ''.

    CONCATENATE 'ZFO_' bukrs tprop2-hbkid '1'INTO variante1.
    CONCATENATE 'ZFO_' bukrs tprop2-hbkid    INTO variante2.

    REFRESH bdcdata.

    PERFORM limpiar_var USING variante1.

    WAIT UP TO 03 SECONDS.

    REFRESH bdcdata.
    PERFORM limpiar_var USING variante2.

    WAIT UP TO 03 SECONDS.

  ENDLOOP.

ENDFORM.                    " LIMPIAR_VARIANTES


*&---------------------------------------------------------------------*
*&      Form  LIMPIAR_VAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE(VARIABLE)  text
*----------------------------------------------------------------------*
FORM limpiar_var USING VALUE(variable).

  PERFORM bdc_dynpro      USING 'SAPLWBABAP'                '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                'RS38M-PROGRAMM'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                '=STRV'.
  PERFORM bdc_field       USING 'RS38M-PROGRAMM'            'ZRFFOUS_C'.
  PERFORM bdc_field       USING 'RS38M-FUNC_EDIT'           'X'.

  PERFORM bdc_dynpro      USING 'SAPLS38R'                   '0020'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                 'RS38M-SELSET'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                 '=STRT'.
  PERFORM bdc_field       USING 'RS38M-SELSET'               variable.

  PERFORM bdc_dynpro      USING 'ZRFFOUS_C'                   '1000'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                  'PAR_NOVO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                  '=SPOS'.

*  PERFORM bdc_field       USING 'ZW_ZBUKR-LOW'                bukrs.
*  PERFORM bdc_field       USING 'ZW_ABSBU-LOW'                bukrs.
  PERFORM bdc_field       USING 'ZW_LAUFD'                    ''.
  PERFORM bdc_field       USING 'ZW_LAUFI'                    ''.
  PERFORM bdc_field       USING 'PAR_RCHK'                    ''.
  PERFORM bdc_field       USING 'SEL_VBLN-LOW'                ''.
  PERFORM bdc_field       USING 'PAR_NOVO'                    ''.
  PERFORM bdc_field       USING 'PAR_NEUD'                    ''.
  PERFORM bdc_field       USING 'PAR_CHKF'                    ''.
  PERFORM bdc_field       USING 'PAR_CHKT'                    ''.
  PERFORM bdc_field       USING 'PAR_VOID'                    ''.

  PERFORM bdc_dynpro      USING 'SAPLSVAR'                    '0281'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                  '=SAVE'.

  PERFORM bdc_dynpro      USING 'SAPLSPO1'                    '0500'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                  '=OPT1'.

  PERFORM bdc_dynpro      USING 'ZRFFOUS_C'                   '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                  '/EE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                  'PAR_NOVO'.

  PERFORM bdc_dynpro      USING 'SAPLWBABAP'                   '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'                   'RS38M-PROGRAMM'.
  PERFORM bdc_field       USING 'BDC_OKCODE'                   '=BACK'.
  PERFORM bdc_field       USING 'RS38M-PROGRAMM'               'ZRFFOUS_C'.
  PERFORM bdc_field       USING 'RS38M-FUNC_EDIT'              'X'.



  CALL TRANSACTION 'SE38' USING bdcdata
                            MODE 'E'
                            UPDATE 'S'
                            MESSAGES INTO itab.

ENDFORM.                    "LIMPIAR_VAR
