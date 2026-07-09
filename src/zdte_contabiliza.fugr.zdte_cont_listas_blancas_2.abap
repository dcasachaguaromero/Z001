*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION zdte_cont_listas_blancas_2.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_FOLIO) TYPE  ZDTE_FOLIO
*"     VALUE(I_RUTEMISOR) TYPE  ZRUT_EMI
*"     VALUE(I_NUMERO_CLIENTE) TYPE  ZNUMCLIENTE
*"     VALUE(I_RUTRECEPTOR) TYPE  CHAR10
*"     VALUE(I_MONTO_NETO) TYPE  ZMNT_NETO
*"     VALUE(I_CTUMODE) TYPE  CTU_MODE
*"  EXPORTING
*"     VALUE(RESULTADO) TYPE  SUBRC
*"     VALUE(FACTURA) TYPE  BELNR_D
*"     VALUE(EJERCICIO) TYPE  GJAHR
*"     VALUE(ESTADO) TYPE  ZDTE_ESTADO
*"     VALUE(MENSAJE) TYPE  BAPI_MSG
*"  TABLES
*"      MENSAJE_SALIDA STRUCTURE  BDCMSGCOLL OPTIONAL
*"----------------------------------------------------------------------

  TABLES: zbmnc_listabcab, zbmnc_listabdet, t001z.

  DATA: lv_bukrs          TYPE bukrs.
  DATA: ti_cab            TYPE STANDARD TABLE OF zbmnc_listabcab WITH HEADER LINE.
  DATA: ti_det            TYPE STANDARD TABLE OF zbmnc_listabdet WITH HEADER LINE.
  DATA  wa_cab            TYPE zbmnc_listabcab.
  DATA: lv_dat8(8)        TYPE c.
  DATA: lv_dat10(10)      TYPE c.
  DATA: lv_campo(40)      TYPE c.
  DATA: lv_pos(2)         TYPE c.
  DATA: lv_monto_cab      TYPE int4.
  DATA: lv_monto_cab_txt(15).
  DATA: lv_monto_det      TYPE int4,
        lv_monto_acu      TYPE int4,
        lv_diferencia     TYPE int4.
  DATA: lv_monto_det_txt(15).
  DATA  lv_asignacion     TYPE dzuonr.
  DATA  lv_lifnr          TYPE lfa1-lifnr.
  DATA w_bsik type bsik.
*Averiguamos si rut receptor corresponde a lista blanca
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *
*         FROM   t001z
*         WHERE  paval EQ i_rutreceptor
*         AND    party EQ 'TAXNR'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
         FROM   t001z
         WHERE  paval EQ i_rutreceptor
         AND    party EQ 'TAXNR' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc EQ 0.
    CASE t001z-bukrs.
      WHEN 'CL12' OR 'CL16' OR 'CL65'.
        lv_bukrs = t001z-bukrs.
    ENDCASE.
  ELSE.
    "Error
  ENDIF.

  SET PARAMETER ID 'BUK' FIELD lv_bukrs.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = i_folio
    IMPORTING
      output = i_folio.

*Lee cabecera listas blancas
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT  * INTO CORRESPONDING FIELDS OF TABLE ti_cab
*  FROM  zbmnc_listabcab
*  WHERE sociedad        = lv_bukrs
*    AND rut_proveedor   = i_rutemisor
*    AND numero_cliente  = i_numero_cliente.
*
* NEW CODE
  SELECT *
 INTO CORRESPONDING FIELDS OF TABLE ti_cab
  FROM  zbmnc_listabcab
  WHERE sociedad        = lv_bukrs
    AND rut_proveedor   = i_rutemisor
    AND numero_cliente  = i_numero_cliente ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_det
*    FROM zbmnc_listabdet
*    FOR ALL ENTRIES IN ti_cab
*    WHERE sociedad  = ti_cab-sociedad
*      AND lifnr     = ti_cab-lifnr .
*
* NEW CODE
    SELECT *
 INTO CORRESPONDING FIELDS OF TABLE ti_det
    FROM zbmnc_listabdet
    FOR ALL ENTRIES IN ti_cab
    WHERE sociedad  = ti_cab-sociedad
      AND lifnr     = ti_cab-lifnr  ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*      AND ceco      = ti_cab-ceco.
    IF sy-subrc EQ 0.

**********************************************************************
* Inicio Batch Input
**********************************************************************

      PERFORM bdc_dynpro      USING 'ZFIMDP005B'                          '0100'.
      PERFORM bdc_field       USING 'BDC_CURSOR'                          'ZACGL_ITEM_TBCTR-ZZRUT_TERC(04)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'                          '/00'.
      PERFORM bdc_field       USING 'RF05A-BUSCS'                         'R'.

      LOOP AT ti_cab.

        CLEAR: lv_monto_cab, lv_monto_acu, lv_diferencia.

        lv_monto_cab      = ( ti_cab-porcentaje * i_monto_neto ) / 100.

        lv_monto_cab_txt  = lv_monto_cab.
        CONDENSE lv_monto_cab_txt NO-GAPS.

        DATA:  vl_lineas  TYPE i,
               vl_indice1 TYPE i,
               vl_indice2 TYPE i.
        CLEAR: vl_lineas,
               vl_indice1,
               vl_indice2.
        SORT ti_det BY porcentaje DESCENDING.
        DESCRIBE TABLE ti_det LINES vl_lineas.

        LOOP AT ti_det.

          CLEAR lv_lifnr.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE lifnr INTO lv_lifnr
*          FROM lfa1
**          WHERE stcd1 EQ ti_det-lifnr.
*          WHERE lifnr EQ ti_det-lifnr.
*
* NEW CODE
          SELECT lifnr
          UP TO 1 ROWS  INTO lv_lifnr
          FROM lfa1
*          WHERE stcd1 EQ ti_det-lifnr.
          WHERE lifnr EQ ti_det-lifnr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc EQ  0.
            "Nada
          ENDIF.

          ADD 1 TO vl_indice1.
          ADD 1 TO vl_indice2.

* Genero la variable con la posicion de detalle
          lv_pos = lv_pos + 1.

          IF lv_pos LT 10.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_pos
              IMPORTING
                output = lv_pos.
          ENDIF.

* Genero el campo de la posicion de detalle
          CLEAR lv_campo.
          CONCATENATE 'ZACGL_ITEM_TBCTR-HKONT(' lv_pos ')' INTO lv_campo.

          PERFORM bdc_field       USING lv_campo                              ti_det-cta_contable.


*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-HKONT(01)'          record-hkont_01_002.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-HKONT(02)'          record-hkont_02_003.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-HKONT(03)'          record-hkont_03_004.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-HKONT(04)'          record-hkont_04_005.

* Genero el campo de la posicion de detalle
          CLEAR lv_campo.
          CONCATENATE 'ZACGL_ITEM_TBCTR-WRBTR(' lv_pos ')' INTO lv_campo.

          CLEAR lv_monto_det.
          IF ti_det-porcentaje EQ 0.
            lv_monto_det      = ( ti_det-porcentaje * lv_monto_cab ) / 100.
          ELSE.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT TI_CAB .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
            lv_monto_det      = ( ti_det-porcentaje * lv_monto_cab ) / 100.
          ENDIF.

          lv_monto_acu = lv_monto_acu + lv_monto_det.

          "lv_monto_cab
          IF vl_indice2 EQ vl_lineas."para el ultimo registro.
            lv_diferencia = lv_monto_acu - lv_monto_cab.

*            lv_monto_det = lv_monto_det + lv_diferencia.
            lv_monto_det = lv_monto_det - lv_diferencia.
          ENDIF.

          lv_monto_det_txt  = lv_monto_det.
          CONDENSE lv_monto_det_txt NO-GAPS.

          PERFORM bdc_field       USING lv_campo                              lv_monto_det_txt.

*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-WRBTR(01)'          record-wrbtr_01_006.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-WRBTR(02)'          record-wrbtr_02_007.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-WRBTR(03)'          record-wrbtr_03_008.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-WRBTR(04)'          record-wrbtr_04_009.


* Genero el campo Asignación
          CLEAR lv_campo.
          CONCATENATE 'ZACGL_ITEM_TBCTR-ZUONR(' lv_pos ')' INTO lv_campo.

          lv_asignacion = i_folio.
          PERFORM bdc_field       USING lv_campo                              lv_asignacion.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZUONR(01)'          record-zuonr_01_010.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZUONR(02)'          record-zuonr_02_011.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZUONR(03)'          record-zuonr_03_012.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZUONR(04)'          record-zuonr_04_013.

* Genero el campo de la posicion de detalle
          CLEAR lv_campo.
          CONCATENATE 'ZACGL_ITEM_TBCTR-SGTXT(' lv_pos ')' INTO lv_campo.

          PERFORM bdc_field       USING lv_campo                              ti_det-descripcion.

*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-SGTXT(01)'          record-sgtxt_01_014.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-SGTXT(02)'          record-sgtxt_02_015.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-SGTXT(03)'          record-sgtxt_03_016.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-SGTXT(04)'          record-sgtxt_04_017.

* Genero el campo de la posicion de detalle
          CLEAR lv_campo.
          CONCATENATE 'ZACGL_ITEM_TBCTR-KOSTL(' lv_pos ')' INTO lv_campo.

          PERFORM bdc_field       USING lv_campo                              ti_det-ceco.

*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-KOSTL(01)'          record-kostl_01_018.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-KOSTL(02)'          record-kostl_02_019.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-KOSTL(03)'          record-kostl_03_020.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-KOSTL(04)'          record-kostl_04_021.

* Genero el campo de la posicion de detalle
          CLEAR lv_campo.
          CONCATENATE 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(' lv_pos ')' INTO lv_campo.

          PERFORM bdc_field       USING lv_campo                              ti_det-codigoprod_cont.

*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(01)'     record-zzunid_pro_01_022.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(02)'     record-zzunid_pro_02_023.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(03)'     record-zzunid_pro_03_024.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(04)'     record-zzunid_pro_04_025.

* Genero el campo de la posicion de detalle
          CLEAR lv_campo.
          CONCATENATE 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(' lv_pos ')' INTO lv_campo.

          PERFORM bdc_field       USING lv_campo                               lv_lifnr."ti_det-lifnr.

*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(01)'     record-zzrut_terc_01_026.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(02)'     record-zzrut_terc_02_027.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(03)'     record-zzrut_terc_03_028.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(04)'     record-zzrut_terc_04_029.

          READ TABLE ti_cab INTO wa_cab INDEX 1.
          IF sy-subrc EQ 0.

            CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+0(4) INTO lv_dat8.
************Pestaña 1
            PERFORM bdc_field       USING 'ZINVFO-LIFNR'                        lv_lifnr."wa_cab-lifnr.     "record-lifnr_030.
            PERFORM bdc_field       USING 'ZINVFO-BLART'                        'F4'.             "recwa_cab-LIFNRord-blart_031.
            PERFORM bdc_field       USING 'ZINVFO-BLDAT'                        lv_dat8.          "record-bldat_032.
            PERFORM bdc_field       USING 'ZINVFO-XBLNR'                        i_folio.          "record-xblnr_033.
            PERFORM bdc_field       USING 'ZINVFO-BUDAT'                        lv_dat8.          "record-budat_034.
            PERFORM bdc_field       USING 'ZINVFO-WAERS'                        'CLP'.            "record-waers_035.
            PERFORM bdc_field       USING 'ZINVFO-WRBTR'                        lv_monto_cab_txt. "record-wrbtr_036.
            PERFORM bdc_field       USING 'ZINVFO-SGTXT'                        'TEXTO'.          "record-sgtxt_037.
            PERFORM bdc_field       USING 'ZINVFO-ZZMOT_EMIS'                   'PARTICIP.'. "record-zzmot_emis_038.
            PERFORM bdc_field       USING 'ZINVFO-ZZRUT_TERC'                   lv_lifnr."ti_det-lifnr. "record-zzrut_terc_039.

          ENDIF.

          IF vl_indice1 EQ 10.
            CLEAR vl_indice1.

            PERFORM bdc_dynpro      USING 'ZFIMDP005B'                          '0100'.
            PERFORM bdc_field       USING 'BDC_CURSOR'                          'ZACGL_ITEM_TBCTR-ZZRUT_TERC(09)'.
            PERFORM bdc_field       USING 'BDC_OKCODE'                          '=TABLE_P+'.
            PERFORM bdc_field       USING 'RF05A-BUSCS'                         'R'.

          ENDIF.

*
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-HKONT(05)'          record-hkont_05_041.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-HKONT(06)'          record-hkont_06_042.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-HKONT(07)'          record-hkont_07_043.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-HKONT(08)'          record-hkont_08_044.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-HKONT(09)'          record-hkont_09_045.
*
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-WRBTR(05)'          record-wrbtr_05_046.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-WRBTR(06)'          record-wrbtr_06_047.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-WRBTR(07)'          record-wrbtr_07_048.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-WRBTR(08)'          record-wrbtr_08_049.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-WRBTR(09)'          record-wrbtr_09_050.
*
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZUONR(05)'          record-zuonr_05_051.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZUONR(06)'          record-zuonr_06_052.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZUONR(07)'          record-zuonr_07_053.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZUONR(08)'          record-zuonr_08_054.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZUONR(09)'          record-zuonr_09_055.
*
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-SGTXT(05)'          record-sgtxt_05_056.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-SGTXT(06)'          record-sgtxt_06_057.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-SGTXT(07)'          record-sgtxt_07_058.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-SGTXT(08)'          record-sgtxt_08_059.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-SGTXT(09)'          record-sgtxt_09_060.
*
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-KOSTL(05)'          record-kostl_05_061.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-KOSTL(06)'          record-kostl_06_062.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-KOSTL(07)'          record-kostl_07_063.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-KOSTL(08)'          record-kostl_08_064.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-KOSTL(09)'          record-kostl_09_065.
*
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(05)'     record-zzunid_pro_05_066.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(06)'     record-zzunid_pro_06_067.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(07)'     record-zzunid_pro_07_068.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(08)'     record-zzunid_pro_08_069.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(09)'     record-zzunid_pro_09_070.
*
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(05)'     record-zzrut_terc_05_071.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(06)'     record-zzrut_terc_06_072.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(07)'     record-zzrut_terc_07_073.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(08)'     record-zzrut_terc_08_074.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(09)'     record-zzrut_terc_09_075.
*
*        PERFORM bdc_field       USING 'ZINVFO-ZFBDT'                        record-zfbdt_076.
*        PERFORM bdc_field       USING 'ZINVFO-ZTERM'                        record-zterm_077.
*        PERFORM bdc_field       USING 'ZINVFO-ZBD1T'                        record-zbd1t_078.
*
*        PERFORM bdc_dynpro      USING 'ZFIMDP005B'                          '0100'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'                          'TABLE_P+'.
*        PERFORM bdc_field       USING 'RF05A-BUSCS'                         record-buscs_079.
*        PERFORM bdc_field       USING 'BDC_CURSOR'                          'ZINVFO-BKTXT'.
*        PERFORM bdc_field       USING 'ZINVFO-HKONT'                        record-hkont_080.
*        PERFORM bdc_field       USING 'ZINVFO-FDLEV'                        record-fdlev_081.
*        PERFORM bdc_field       USING 'ZINVFO-ZUONR'                        record-zuonr_082.
*        PERFORM bdc_field       USING 'ZINVFO-BKTXT'                        record-bktxt_083.
*
*        PERFORM bdc_dynpro      USING 'ZFIMDP005B'                          '0100'.
*        PERFORM bdc_field       USING 'BDC_CURSOR'                          'RF05A-BUSCS'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'                          '=TABLE_P+'.
*        PERFORM bdc_field       USING 'RF05A-BUSCS'                         record-buscs_084.
*        PERFORM bdc_field       USING 'ZINVFO-BLART'                        record-blart_085.
*        PERFORM bdc_field       USING 'ZINVFO-BLDAT'                        record-bldat_086.
*        PERFORM bdc_field       USING 'ZINVFO-XBLNR'                        record-xblnr_087.
*        PERFORM bdc_field       USING 'ZINVFO-BUDAT'                        record-budat_088.
*        PERFORM bdc_field       USING 'ZINVFO-WAERS'                        record-waers_089.
*        PERFORM bdc_field       USING 'ZINVFO-WRBTR'                        record-wrbtr_090.
*        PERFORM bdc_field       USING 'ZINVFO-SGTXT'                        record-sgtxt_091.
*        PERFORM bdc_field       USING 'ZINVFO-ZZMOT_EMIS'                   record-zzmot_emis_092.
*        PERFORM bdc_field       USING 'ZINVFO-ZZRUT_TERC'                   record-zzrut_terc_093.
*
*        PERFORM bdc_dynpro      USING 'ZFIMDP005B'                          '0100'.
*        PERFORM bdc_field       USING 'BDC_CURSOR'                          'RF05A-BUSCS'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'                          '=TABLE_INSR'.
*        PERFORM bdc_field       USING 'RF05A-BUSCS'                         record-buscs_094.
*        PERFORM bdc_field       USING 'ZINVFO-BLART'                        record-blart_095.
*        PERFORM bdc_field       USING 'ZINVFO-BLDAT'                        record-bldat_096.
*        PERFORM bdc_field       USING 'ZINVFO-XBLNR'                        record-xblnr_097.
*        PERFORM bdc_field       USING 'ZINVFO-BUDAT'                        record-budat_098.
*        PERFORM bdc_field       USING 'ZINVFO-WAERS'                        record-waers_099.
*        PERFORM bdc_field       USING 'ZINVFO-WRBTR'                        record-wrbtr_100.
*        PERFORM bdc_field       USING 'ZINVFO-SGTXT'                        record-sgtxt_101.
*        PERFORM bdc_field       USING 'ZINVFO-ZZMOT_EMIS'                   record-zzmot_emis_102.
*        PERFORM bdc_field       USING 'ZINVFO-ZZRUT_TERC'                   record-zzrut_terc_103.
*
*        PERFORM bdc_dynpro      USING 'ZFIMDP005B'                          '0100'.
*        PERFORM bdc_field       USING 'BDC_CURSOR'                          'ZACGL_ITEM_TBCTR-ZZRUT_TERC(01)'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'                          '/00'.
*        PERFORM bdc_field       USING 'RF05A-BUSCS'                         record-buscs_104.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-HKONT(01)'          record-hkont_01_105.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-WRBTR(01)'          record-wrbtr_01_106.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZUONR(01)'          record-zuonr_01_107.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-SGTXT(01)'          record-sgtxt_01_108.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-KOSTL(01)'          record-kostl_01_109.
*
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZPRESTAC(01)'      record-zzprestac_01_110.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(01)'     record-zzunid_pro_01_111.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(01)'     record-zzrut_terc_01_112.
*        PERFORM bdc_field       USING 'ZINVFO-BLART'                        record-blart_113.
*        PERFORM bdc_field       USING 'ZINVFO-BLDAT'                        record-bldat_114.
*        PERFORM bdc_field       USING 'ZINVFO-XBLNR'                        record-xblnr_115.
*        PERFORM bdc_field       USING 'ZINVFO-BUDAT'                        record-budat_116.
*        PERFORM bdc_field       USING 'ZINVFO-WAERS'                        record-waers_117.
*        PERFORM bdc_field       USING 'ZINVFO-WRBTR'                        record-wrbtr_118.
*        PERFORM bdc_field       USING 'ZINVFO-SGTXT'                        record-sgtxt_119.
*        PERFORM bdc_field       USING 'ZINVFO-ZZMOT_EMIS'                   record-zzmot_emis_120.
*        PERFORM bdc_field       USING 'ZINVFO-ZZRUT_TERC'                   record-zzrut_terc_121.
*
*        PERFORM bdc_dynpro      USING 'ZFIMDP005B'                          '0100'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'                          '=TABLE_INSR'.
*        PERFORM bdc_field       USING 'RF05A-BUSCS'                         record-buscs_122.
*        PERFORM bdc_field       USING 'BDC_CURSOR'                          'ZINVFO-SGTXT'.
*        PERFORM bdc_field       USING 'ZINVFO-BLART'                        record-blart_123.
*        PERFORM bdc_field       USING 'ZINVFO-BLDAT'                        record-bldat_124.
*        PERFORM bdc_field       USING 'ZINVFO-XBLNR'                        record-xblnr_125.
*        PERFORM bdc_field       USING 'ZINVFO-BUDAT'                        record-budat_126.
*        PERFORM bdc_field       USING 'ZINVFO-WAERS'                        record-waers_127.
*        PERFORM bdc_field       USING 'ZINVFO-WRBTR'                        record-wrbtr_128.
*        PERFORM bdc_field       USING 'ZINVFO-SGTXT'                        record-sgtxt_129.
*        PERFORM bdc_field       USING 'ZINVFO-ZZMOT_EMIS'                   record-zzmot_emis_130.
*        PERFORM bdc_field       USING 'ZINVFO-ZZRUT_TERC'                   record-zzrut_terc_131.
*
*        PERFORM bdc_dynpro      USING 'ZFIMDP005B'                          '0100'.
*        PERFORM bdc_field       USING 'BDC_CURSOR'                          'ZACGL_ITEM_TBCTR-ZZRUT_TERC(02)'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'                          '/00'.
*        PERFORM bdc_field       USING 'RF05A-BUSCS'                         record-buscs_132.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-HKONT(02)'          record-hkont_02_133.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-WRBTR(02)'          record-wrbtr_02_134.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZUONR(02)'          record-zuonr_02_135.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-SGTXT(02)'          record-sgtxt_02_136.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-KOSTL(02)'          record-kostl_02_137.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-PRCTR(02)'          record-prctr_02_138.
*
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZUNID_PRO(02)'     record-zzunid_pro_02_139.
*        PERFORM bdc_field       USING 'ZACGL_ITEM_TBCTR-ZZRUT_TERC(02)'     record-zzrut_terc_02_140.
*        PERFORM bdc_field       USING 'ZINVFO-BLART'                        record-blart_141.
*        PERFORM bdc_field       USING 'ZINVFO-BLDAT'                        record-bldat_142.
*        PERFORM bdc_field       USING 'ZINVFO-XBLNR'                        record-xblnr_143.
*        PERFORM bdc_field       USING 'ZINVFO-BUDAT'                        record-budat_144.
*        PERFORM bdc_field       USING 'ZINVFO-WAERS'                        record-waers_145.
*        PERFORM bdc_field       USING 'ZINVFO-WRBTR'                        record-wrbtr_146.
*        PERFORM bdc_field       USING 'ZINVFO-SGTXT'                        record-sgtxt_147.
*        PERFORM bdc_field       USING 'ZINVFO-ZZMOT_EMIS'                   record-zzmot_emis_148.
*        PERFORM bdc_field       USING 'ZINVFO-ZZRUT_TERC'                   record-zzrut_terc_149.
*
*        PERFORM bdc_dynpro      USING 'ZFIMDP005B'                          '0100'.
*        PERFORM bdc_field       USING 'BDC_CURSOR'                          'ZACGL_ITEM_TBCTR-KOSTL(02)'.
*        PERFORM bdc_field       USING 'BDC_OKCODE'                          '=SOC_02'.
*        PERFORM bdc_field       USING 'RF05A-BUSCS'                         record-buscs_150.
*        PERFORM bdc_field       USING 'ZINVFO-BLART'                        record-blart_151.
*        PERFORM bdc_field       USING 'ZINVFO-BLDAT'                        record-bldat_152.
*        PERFORM bdc_field       USING 'ZINVFO-XBLNR'                        record-xblnr_153.
*        PERFORM bdc_field       USING 'ZINVFO-BUDAT'                        record-budat_154.
*        PERFORM bdc_field       USING 'ZINVFO-WAERS'                        record-waers_155.
*        PERFORM bdc_field       USING 'ZINVFO-WRBTR'                        record-wrbtr_156.
*        PERFORM bdc_field       USING 'ZINVFO-SGTXT'                        record-sgtxt_157.
*        PERFORM bdc_field       USING 'ZINVFO-ZZMOT_EMIS'                   record-zzmot_emis_158.
*        PERFORM bdc_field       USING 'ZINVFO-ZZRUT_TERC'                   record-zzrut_terc_159.

          IF vl_indice2 EQ vl_lineas.

************Pestaña 2
            PERFORM bdc_dynpro      USING 'ZFIMDP005B'          '0100'.
            PERFORM bdc_field       USING 'BDC_OKCODE'          '/00'.          ".

************Pestaña 3 texto para BKTXT
            PERFORM bdc_dynpro      USING 'ZFIMDP005B'          '0100'.
            PERFORM bdc_field       USING 'BDC_CURSOR'          'ZINVFO-BKTXT'.          ".
            PERFORM bdc_field       USING 'ZINVFO-BKTXT'        'Txt'.
            PERFORM bdc_field       USING 'BDC_OKCODE'          '/00'.

************boton simular
            PERFORM bdc_dynpro      USING 'ZFIMDP005B'          '0100'.
            PERFORM bdc_field       USING 'BDC_OKCODE'          '=SOC_02'.

************volver atras
            PERFORM bdc_dynpro      USING 'SAPMSSY0'            '0120'.
            PERFORM bdc_field       USING 'BDC_OKCODE'          '=F03'.
************Grabar
            PERFORM bdc_dynpro      USING 'ZFIMDP005B'          '0100'.
            PERFORM bdc_field       USING 'BDC_CURSOR'          'ZACGL_ITEM_TBCTR-KOSTL(02)'.
            PERFORM bdc_field       USING 'BDC_OKCODE'          '=SAVE'.

          ENDIF.

*        PERFORM bdc_field       USING 'RF05A-BUSCS'                         record-buscs_160.
*        PERFORM bdc_field       USING 'ZINVFO-BLART'                        record-blart_161.
*        PERFORM bdc_field       USING 'ZINVFO-BLDAT'                        record-bldat_162.
*        PERFORM bdc_field       USING 'ZINVFO-XBLNR'                        record-xblnr_163.
*        PERFORM bdc_field       USING 'ZINVFO-BUDAT'                        record-budat_164.
*        PERFORM bdc_field       USING 'ZINVFO-WAERS'                        record-waers_165.
*        PERFORM bdc_field       USING 'ZINVFO-WRBTR'                        record-wrbtr_166.
*        PERFORM bdc_field       USING 'ZINVFO-SGTXT'                        record-sgtxt_167.
*        PERFORM bdc_field       USING 'ZINVFO-ZZMOT_EMIS'                   record-zzmot_emis_168.
*        PERFORM bdc_field       USING 'ZINVFO-ZZRUT_TERC'                   record-zzrut_terc_169.

        ENDLOOP.
        EXIT.
      ENDLOOP.

      PERFORM bdc_transaction TABLES mensaje_salida USING 'ZFITR006B' i_folio resultado i_ctumode.

      "buscar referencia de contabilización.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * INTO w_bsik FROM bsik
*        WHERE bukrs EQ lv_bukrs
*         AND lifnr EQ lv_lifnr
*         AND gjahr EQ sy-datum(4)
*         AND zuonr EQ i_folio
*         AND xblnr EQ i_folio.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  INTO w_bsik FROM bsik
        WHERE bukrs EQ lv_bukrs
         AND lifnr EQ lv_lifnr
         AND gjahr EQ sy-datum(4)
         AND zuonr EQ i_folio
         AND xblnr EQ i_folio ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF resultado EQ 0.
        factura   = w_bsik-belnr.
        ejercicio = w_bsik-GJAHR.
        estado    = 'CO'.
        mensaje   = 'LB - Contabilización ok'.
      ENDIF.
**********************************************************************
* Fin Batch Input
**********************************************************************
    ENDIF.
  ELSE.
    "No hay datos para la consulta
  ENDIF.

ENDFUNCTION.
