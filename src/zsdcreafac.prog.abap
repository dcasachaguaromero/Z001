*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZSDCREAFAC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zsdcreafac.

TABLES nast.
TABLES cmfp.
TABLES vbrk.
TABLES vbfa.
TABLES zcabpedext.

CONSTANTS true TYPE c VALUE 'X'.
DATA: bill_data    TYPE STANDARD TABLE OF bapivbrk,
      wa_bill_data TYPE bapivbrk.
DATA: return_fac    TYPE STANDARD TABLE OF bapiret1,
      wa_return_fac TYPE bapiret1.
DATA: success    TYPE STANDARD TABLE OF bapivbrksuccess,
      wa_success TYPE bapivbrksuccess.
DATA numcore    TYPE znum_doc_core.
DATA nast_tmp   LIKE nast.
DATA sw_ef.
DATA: l_lotno TYPE idcn_boma-lotno.
DATA: wa_zcabpedext TYPE zcabpedext.
*----------------------------------------------------------------------*
*   data definition
*----------------------------------------------------------------------*
*       Batchinputdata of single transaction
DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   messtab TYPE TABLE OF bdcmsgcoll.

DATA: BEGIN OF tmp_nast OCCURS 0,
        kappl  LIKE nast-kappl,
        erdat  LIKE nast-erdat,
        eruhr  LIKE nast-eruhr,
        cmfpnr LIKE nast-cmfpnr,
      END OF tmp_nast.

DATA : ls_tmp_nast LIKE LINE OF tmp_nast,
       lv_dea      TYPE ztdea-dea.

PARAMETERS: p_vkorg  TYPE vkorg,
            p_vtweg  TYPE vtweg,
            p_spart  TYPE spart,
            p_doctyp TYPE auart,
            p_fecfac TYPE zfecfaccon,
            p_saldoc TYPE vbeln_va,
            p_numdoc TYPE znum_doc_core,
            p_import TYPE c NO-DISPLAY.

START-OF-SELECTION.
  FREE: bill_data, return_fac, success.
  CLEAR wa_bill_data.
  wa_bill_data-salesorg   = p_vkorg.
  wa_bill_data-distr_chan = p_vtweg.
  wa_bill_data-division   = p_spart.
  wa_bill_data-ordbilltyp = p_doctyp.
  wa_bill_data-bill_date  = p_fecfac.
  wa_bill_data-ref_doc    = p_saldoc.
  wa_bill_data-ref_doc_ca = 'V'.
  APPEND wa_bill_data TO bill_data.

  numcore = p_numdoc.

  CALL FUNCTION 'BAPI_BILLINGDOC_CREATEMULTIPLE'
    TABLES
      billingdatain = bill_data
      return        = return_fac
      success       = success.

  WAIT UP TO 1 SECONDS.

  CLEAR sw_ef.
**Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
*  SORT tmp_nast .
**End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
**Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
*  SORT tmp_nast .
**End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 24/12/2019 EY_DES02 ECDK917080 *
  LOOP AT success INTO wa_success WHERE bill_doc NE space.
    sw_ef = true.
    CLEAR vbrk.
**Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
*    SORT tmp_nast .
**End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
    DO 10 TIMES.
      SELECT SINGLE * FROM vbrk WHERE vbeln EQ wa_success-bill_doc.
      IF sy-subrc NE 0.
        WAIT UP TO 1 SECONDS.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    IF vbrk-vbeln NE space.
      CLEAR wa_zcabpedext.
      SELECT SINGLE *  INTO  wa_zcabpedext
        FROM  zcabpedext  WHERE znum_doc_core = numcore.

      SELECT SINGLE vbeln   INTO vbfa-vbeln
         FROM vbfa
         WHERE vbelv   EQ p_saldoc
           AND vbtyp_n EQ 'M'
           AND vbtyp_v EQ 'C'
           AND vbeln   EQ wa_success-bill_doc.
      IF sy-subrc = 0.
        wa_zcabpedext-fec_car = sy-datlo.
        wa_zcabpedext-hor_car = sy-timlo.
        wa_zcabpedext-factura = vbfa-vbeln.
        wa_zcabpedext-error   = space.
        wa_zcabpedext-log_error = space.
      ENDIF.

      FREE tmp_nast.
      SELECT * FROM nast WHERE kappl EQ 'V3'
                           AND objky EQ wa_success-bill_doc
                           ORDER BY PRIMARY KEY.
        READ TABLE tmp_nast INDEX 1.
        IF sy-subrc NE 0.
          MOVE-CORRESPONDING nast TO tmp_nast.
          APPEND tmp_nast.
        ELSE.
          IF tmp_nast-erdat < nast-erdat.
            MOVE-CORRESPONDING nast TO tmp_nast.
            MODIFY tmp_nast INDEX 1.
          ELSEIF tmp_nast-erdat EQ nast-erdat AND tmp_nast-eruhr < nast-eruhr.
            MOVE-CORRESPONDING nast TO tmp_nast.
            MODIFY tmp_nast INDEX 1.
          ENDIF.
        ENDIF.
      ENDSELECT.

*ReSQ: No Need Of Change Internal Table TMP_NAST Already Sorted
      READ TABLE tmp_nast INDEX 1.
      IF sy-subrc = 0.
        nast-cmfpnr = tmp_nast-cmfpnr.
        SELECT msgv1 msgv2 msgv3 msgv4
          INTO (cmfp-msgv1, cmfp-msgv2, cmfp-msgv3, cmfp-msgv4)
          FROM cmfp WHERE aplid = 'WFMC'
                      AND nr    = nast-cmfpnr
                      AND msgty = 'E'.
          IF sy-subrc EQ 0.
            wa_zcabpedext-fec_car   = sy-datlo.
            wa_zcabpedext-hor_car   = sy-timlo.
            wa_zcabpedext-error_e   = true.
            CONCATENATE cmfp-msgv1 cmfp-msgv2
                        cmfp-msgv3 cmfp-msgv4
                   INTO wa_zcabpedext-log_error.
            EXIT.
          ENDIF.
        ENDSELECT.
      ENDIF.
    ELSE.
      CLEAR wa_zcabpedext.
      SELECT SINGLE *  INTO wa_zcabpedext
        FROM zcabpedext WHERE znum_doc_core = numcore.
      wa_zcabpedext-fec_car   = sy-datlo.
      wa_zcabpedext-hor_car   = sy-timlo.
      wa_zcabpedext-error     = true.
      wa_zcabpedext-factura   = space.
      wa_zcabpedext-log_error = TEXT-002.
      "'Error en la creación de la factura.'.
    ENDIF.
    UPDATE zcabpedext FROM wa_zcabpedext.
    EXIT.
  ENDLOOP.

  IF NOT wa_success-bill_doc IS INITIAL.
    IF NOT p_import IS INITIAL.
      TABLES:indx.
      indx-aedat = sy-datum.
      indx-usera = sy-uname.
      indx-srtfd = wa_success-bill_doc.
      EXPORT wa_success-bill_doc TO DATABASE indx(xy)
      ID wa_success-bill_doc. "'FAC'
    ENDIF.

    CLEAR wa_zcabpedext.
    SELECT SINGLE *  INTO wa_zcabpedext
      FROM zcabpedext WHERE znum_doc_core EQ p_numdoc.
    IF sy-subrc = 0.
      PERFORM save_glosa IN PROGRAM zsdprocfac
                              USING wa_zcabpedext
                                    wa_success-bill_doc.

      PERFORM act_tablas IN PROGRAM zsdprocfac
                              USING wa_zcabpedext
                                    wa_success-bill_doc
                                    p_saldoc
                                    space
                                    space
                                    space.
    ENDIF.

***Llamamos a la IDCP
    CLEAR lv_dea.
    SELECT SINGLE dea INTO lv_dea
      FROM ztdea   WHERE blart = wa_zcabpedext-zblart.
    IF NOT lv_dea IS INITIAL.
      PERFORM idcp USING p_numdoc
                         vbrk-bukrs
                         vbrk-vkorg
                         vbrk-vbeln.
    ELSE.
      wa_zcabpedext-error_e     = space.
      wa_zcabpedext-log_error   = TEXT-003.
      UPDATE zcabpedext FROM wa_zcabpedext.
    ENDIF.

  ELSE.
    READ TABLE return_fac INTO wa_return_fac WITH KEY type = 'E'.
    IF sy-subrc EQ 0.
      SELECT SINGLE * INTO wa_zcabpedext
        FROM zcabpedext WHERE znum_doc_core EQ p_numdoc.

      wa_zcabpedext-fec_car   = sy-datlo.
      wa_zcabpedext-hor_car   = sy-timlo.
      wa_zcabpedext-error     = true.
      wa_zcabpedext-log_error = wa_return_fac-message.
      UPDATE zcabpedext FROM wa_zcabpedext.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  CALL_IDCP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VBRK_VBELN  text
*      -->P_VBRK_FKART  text
*----------------------------------------------------------------------*
FORM call_idcp  USING    p_vkorg
                         p_vbeln
                         p_fkart
                         p_bokno.

  DATA: c_mode    TYPE c VALUE 'N',
        c_update  TYPE c VALUE 'S', "L
        l_fkart   TYPE fkart,
        l_kschl   TYPE kschl,
        l_vbeln   TYPE vbrk-vbeln,
* ini Waldo Alarcon - Visionone - 23-01-2020
        l_options TYPE ctu_params.
* fin Waldo Alarcon - Visionone - 23-01-2020

* BUSCA EL TIPO DE MENSAJE ASOCIADO A LA FACTURA
  SELECT SINGLE fkart INTO l_fkart
         FROM vbrk WHERE vbeln EQ p_vbeln.
  CASE l_fkart.
    WHEN 'ZBOL'.
      l_kschl = 'ZBOE'.
    WHEN OTHERS.
      l_kschl = 'ZFAE'.
  ENDCASE.

  REFRESH bdcdata.
  PERFORM bdc_dynpro      USING 'IDPRCNINVOICE' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'.
  PERFORM bdc_field       USING 'CHK_BILL'
                                true.
  PERFORM bdc_field       USING 'VKORG'
                                 p_vkorg.
  PERFORM bdc_field       USING 'LOTNO'
                                 p_fkart.
  PERFORM bdc_field       USING 'BOKNO'
                                 p_bokno.                   "'02'.
  PERFORM bdc_field       USING 'CHK_PRI'
                                true.
  PERFORM bdc_dynpro      USING 'IDPRCNINVOICE' '0111'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RFBSK_C'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=CRET'.
  PERFORM bdc_field       USING 'PR_NUM'
                                'Local Printer'.
  PERFORM bdc_field       USING 'VBELN-LOW'
                                 p_vbeln.

  PERFORM bdc_field       USING 'MSG_TYPE' l_kschl.
  PERFORM bdc_field       USING 'RFBSK_AB'
                                ''.
  PERFORM bdc_field       USING 'RFBSK_C'
                                true.
  PERFORM bdc_field       USING 'NO_RPRT'
                                true.

  PERFORM bdc_dynpro      USING 'SAPMSSY0' '0120'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=&ALL'.

  PERFORM bdc_dynpro      USING 'SAPMSSY0' '0120'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BTCI'.

* ini Waldo Alarcon - Visionone - 23-01-2020
  l_options-dismode   = c_mode.
  l_options-updmode  = c_update.
  l_options-defsize  = 'X'.
  l_options-racommit = 'X'.
* fin Waldo Alarcon - Visionone - 23-01-2020

  CALL TRANSACTION 'IDCP' USING bdcdata
                          MESSAGES INTO messtab
* ini Waldo Alarcon - Visionone - 23-01-2020
                          OPTIONS FROM l_options.
*                          MODE c_mode
*                          UPDATE c_update.
* fin Waldo Alarcon - Visionone - 23-01-2020
*
  COMMIT WORK AND WAIT.
ENDFORM.                    " CALL_IDCP

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = true.
  APPEND bdcdata.
ENDFORM.                    "bdc_dynpro

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.                    "bdc_field
*&---------------------------------------------------------------------*
*&      Form  IDCP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_NUMDOC  text
*      -->P_VBRK_BUKRS  text
*      -->P_VBRK_VKORG  text
*      -->P_VBRK_VBELN  text
*----------------------------------------------------------------------*
FORM idcp  USING    p_numdoc
                    p_bukrs
                    p_vkorg
                    p_vbeln.

  DATA: ti_libro TYPE TABLE OF idcn_boma,
        wa_libro TYPE idcn_boma,
        lineas   TYPE i.

  CLEAR: lineas.
  CLEAR l_lotno.
  SELECT SINGLE *
    INTO wa_zcabpedext
    FROM zcabpedext
    WHERE znum_doc_core EQ p_numdoc.

  l_lotno = wa_zcabpedext-zblart.

  REFRESH ti_libro.
  SELECT *
    INTO TABLE ti_libro
    FROM idcn_boma
    WHERE bukrs EQ p_bukrs
      AND lotno EQ l_lotno
      ORDER BY bukrs lotno bokno.
  IF sy-subrc EQ 0.
    DESCRIBE TABLE ti_libro LINES lineas.
    READ TABLE ti_libro INTO wa_libro INDEX lineas.
    IF sy-subrc EQ 0.
****Llamamos a la IDCP
      PERFORM call_idcp USING p_vkorg
                              p_vbeln
                              l_lotno
                              wa_libro-bokno.

      COMMIT WORK AND WAIT.
    ENDIF.
  ELSE.
    PERFORM act_tablas IN PROGRAM zsdprocfac USING wa_zcabpedext
                                                   wa_success-bill_doc
                                                   p_saldoc
                                                   space
                                                   true
                                                   TEXT-001.
  ENDIF.
ENDFORM.                    " IDCP
