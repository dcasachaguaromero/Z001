*----------------------------------------------------------------------*
***INCLUDE LZFIRFC004F02.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GENERA_CABECERA
*&---------------------------------------------------------------------*
FORM genera_cabecera CHANGING co_bdc TYPE REF TO lcl_bdc.

  DATA: lv_fecha TYPE c LENGTH 10.

  co_bdc->new_data( ).

* SAPMF05A / 0100 Registrar documento tipo: Datos cabecera
  co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05A' iv_dynpro  = '0100' ).
* Fecha de documento
  WRITE ti_cont_cab-doc_date TO lv_fecha.
  co_bdc->add_field( EXPORTING iv_field = 'BKPF-BLDAT' iv_value = lv_fecha ).
* Tipo de documento
  co_bdc->add_field( EXPORTING iv_field = 'BKPF-BLART' iv_value = ti_cont_cab-doc_type ).
* Sociedad
  co_bdc->add_field( EXPORTING iv_field = 'BKPF-BUKRS' iv_value = ti_cont_cab-comp_code ).
* Fecha de contabilización
  WRITE ti_cont_cab-pstng_date TO lv_fecha.
  co_bdc->add_field( EXPORTING iv_field = 'BKPF-BUDAT' iv_value = lv_fecha ).
* Moneda
  READ TABLE ti_cont_det_ct ASSIGNING FIELD-SYMBOL(<ls_det>) INDEX 1.
  co_bdc->add_field( EXPORTING iv_field = 'BKPF-WAERS' iv_value = <ls_det>-currency ).
* Referencia
  co_bdc->add_field( EXPORTING iv_field = 'BKPF-XBLNR' iv_value = ti_cont_cab-ref_doc_no ).
* Texto cabecera
  co_bdc->add_field( EXPORTING iv_field = 'BKPF-BKTXT' iv_value = ti_cont_cab-header_txt ).
** RVY 10-10-2023
* ledger
  IF ti_cont_cab-ACC_PRINCIPLE <> ' '.
     co_bdc->add_field( EXPORTING iv_field = 'BKPF-LDGRP' iv_value = ti_cont_cab-ACC_PRINCIPLE ).
  endif.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  GENERA_APUNTE
*&---------------------------------------------------------------------*
FORM genera_apunte USING is_det     TYPE gty_cont_det_ct
                         is_det_iva TYPE gty_cont_det_ct
                         is_lfbw    TYPE gty_lfbw
                   CHANGING co_bdc  TYPE REF TO lcl_bdc.

  DATA: lv_bschl TYPE bschl,
        lv_wrbtr TYPE gty_importe,
        lv_dmbtr TYPE gty_importe,
        lv_fwbas TYPE gty_importe,
        lv_wmwst TYPE gty_importe,
        lv_fecha TYPE c LENGTH 10.



  PERFORM det_cc CHANGING is_det
                          lv_bschl.

  CASE is_det-tipo.


    WHEN 'GL'.

      co_bdc->add_field( EXPORTING iv_field = 'RF05A-NEWBS' iv_value = lv_bschl ).
      co_bdc->add_field( EXPORTING iv_field = 'RF05A-NEWKO' iv_value = is_det-hkont ).
      co_bdc->add_field( EXPORTING iv_field = 'BDC_OKCODE'  iv_value = '/00' ).

*      IF is_det-iva = abap_false.   "No tiene IVA
*     SAPMF05A / 0300 Registrar documento tipo Añadir posición de cta. mayor
      co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05A' iv_dynpro  = '0300' ).

      PERFORM format_value USING is_det-amt_doccur is_det-currency
                           CHANGING lv_wrbtr.
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-WRBTR'  iv_value = lv_wrbtr ).

      IF is_det-currency <> 'CLP'.
        PERFORM format_value USING is_det-amt_doccur_me is_det-currency_me
                             CHANGING lv_dmbtr.
        co_bdc->add_field( EXPORTING iv_field = 'BSEG-DMBTR'  iv_value = lv_dmbtr ).
      ENDIF.

      IF NOT is_det-tax_code IS INITIAL.
        co_bdc->add_field( EXPORTING iv_field = 'BSEG-MWSKZ'  iv_value = is_det-tax_code ).
      ENDIF.
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZUONR'  iv_value = is_det-alloc_nmbr ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-SGTXT'  iv_value = is_det-sgtxt ).
      co_bdc->add_field( EXPORTING iv_field = 'DKACB-FMORE' iv_value = 'X' ).
      co_bdc->add_field( EXPORTING iv_field = 'BDC_OKCODE'  iv_value = 'ZK' ).

*     SAPLKACB / 0002 Bloque de imputación
      co_bdc->add_dynpro( EXPORTING iv_program = 'SAPLKACB' iv_dynpro  = '0002' ).
      co_bdc->add_field( EXPORTING iv_field = 'COBL-KOSTL'      iv_value = is_det-costcenter ).
      co_bdc->add_field( EXPORTING iv_field = 'COBL-ZZPRESTAC'  iv_value = is_det-zzprestac ).
      co_bdc->add_field( EXPORTING iv_field = 'COBL-ZZUNID_PRO' iv_value = is_det-zzunid_pro ).
      co_bdc->add_field( EXPORTING iv_field = 'COBL-ZZDESC_EST' iv_value = is_det-zzdesc_est ).
      co_bdc->add_field( EXPORTING iv_field = 'COBL-ZZMOT_EMIS' iv_value = is_det-zzmot_emis ).
      co_bdc->add_field( EXPORTING iv_field = 'COBL-ZZRUT_TERC' iv_value = is_det-zzrut_terc ).
      co_bdc->add_field( EXPORTING iv_field = 'COBL-ZZ_AGENCIA' iv_value = is_det-zz_agencia ).
      co_bdc->add_field( EXPORTING iv_field = 'BDC_OKCODE'      iv_value = '=ENTE' ).

*     SAPMF05A / 0330 Registrar documento tipo Corregir posición de cta. mayor
      co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05A' iv_dynpro  = '0330' ).
*V1 RVY 27.04.2023
      IF is_det-hkont <> '2012310001' and
         is_det-hkont <> '2012310003' and
         is_det-hkont <> '2012310005'.
         co_bdc->add_field( EXPORTING iv_field = 'BSEG-XREF1'      iv_value = is_det-ref_key_1 ).
         co_bdc->add_field( EXPORTING iv_field = 'BSEG-XREF2'      iv_value = is_det-ref_key_2 ).
      ENDIF.
    WHEN 'AP'.
      co_bdc->add_field( EXPORTING iv_field = 'RF05A-NEWBS' iv_value = lv_bschl ).
      co_bdc->add_field( EXPORTING iv_field = 'RF05A-NEWKO' iv_value = is_det-vendor_no ).
      co_bdc->add_field( EXPORTING iv_field = 'BDC_OKCODE'  iv_value = '/00' ).

***   SAPMF05A / 0302 Registrar documento tipo: Añadir posición acreedor
      co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05A' iv_dynpro  = '0302' ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-HKONT'  iv_value = is_det-hkont ).

      " Importe
      PERFORM format_value USING is_det-amt_doccur is_det-currency
                           CHANGING lv_wrbtr.
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-WRBTR'  iv_value = lv_wrbtr ).
      " Impuesto
      IF NOT is_det_iva-amt_doccur IS INITIAL.
        PERFORM format_value USING is_det_iva-amt_doccur is_det_iva-currency
                             CHANGING lv_wmwst.
        co_bdc->add_field( EXPORTING iv_field = 'BSEG-WMWST'  iv_value = lv_wmwst ).
      ENDIF.

      IF is_det-currency <> 'CLP'.
        " Importe en ML
        PERFORM format_value USING is_det-amt_doccur_me is_det-currency_me
                             CHANGING lv_dmbtr.
        co_bdc->add_field( EXPORTING iv_field = 'BSEG-DMBTR'  iv_value = lv_dmbtr ).
        " Impuesto en ML
        IF NOT is_det_iva-amt_doccur_me IS INITIAL.
          PERFORM format_value USING is_det_iva-amt_doccur_me is_det_iva-currency_me
                               CHANGING lv_dmbtr.
          co_bdc->add_field( EXPORTING iv_field = 'BSEG-MWSTS'  iv_value = lv_dmbtr ).
        ENDIF.
      ENDIF.

      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZTERM'  iv_value = is_det-pmnttrms ).

      IF NOT is_det-bline_date IS INITIAL.
        WRITE is_det-bline_date TO lv_fecha.
        co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZFBDT' iv_value = lv_fecha ).
      ENDIF.

      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZLSPR'      iv_value = is_det-pmnt_block ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZLSCH'      iv_value = is_det-pymt_meth ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZUONR'      iv_value = is_det-alloc_nmbr ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-SGTXT'  iv_value = is_det-sgtxt ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZZMOT_EMIS' iv_value = is_det-zzmot_emis ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZZRUT_TERC' iv_value = is_det-zzrut_terc ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZZ_AGENCIA' iv_value = is_det-zz_agencia ).

*     Retenciones
      IF is_lfbw-wt_subjct = abap_true.
        co_bdc->add_field( EXPORTING iv_field = 'BDC_OKCODE'      iv_value = '/00' ).

***     SAPLFWTD / 0100 Retenciones
        co_bdc->add_dynpro( EXPORTING iv_program = 'SAPLFWTD' iv_dynpro  = '0100' ).
        IF is_det-wt_type = '1' AND is_det-wt_code = '1'.
          co_bdc->add_field( EXPORTING iv_field = 'WITH_ITEM-WT_WITHCD(01)' iv_value = is_lfbw-wt_withcd ).
        ELSE.
          co_bdc->add_field( EXPORTING iv_field = 'WITH_ITEM-WT_WITHCD(01)' iv_value = '\' ).
        ENDIF.
        co_bdc->add_field( EXPORTING iv_field = 'BDC_OKCODE'              iv_value = '=GO' ).

        co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05A' iv_dynpro  = '0302' ).
      ENDIF.
      co_bdc->add_field( EXPORTING iv_field = 'BDC_OKCODE'      iv_value = '=ZK' ).

***   SAPMF05A / 0332 Registrar documento tipo: Corregir posición acreedor
      co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05A' iv_dynpro  = '0332' ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-XREF1' iv_value = is_det-ref_key_1 ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-HBKID' iv_value = is_det-bank_id ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-HKTID' iv_value = is_det-hktid ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-XREF2' iv_value = is_det-ref_key_2 ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-BVTYP' iv_value = is_det-ATRIBUTO_8 ).

    WHEN 'AR'.
      co_bdc->add_field( EXPORTING iv_field = 'RF05A-NEWBS' iv_value = lv_bschl ).
      co_bdc->add_field( EXPORTING iv_field = 'RF05A-NEWKO' iv_value = is_det-customer ).
      co_bdc->add_field( EXPORTING iv_field = 'BDC_OKCODE'  iv_value = '/00' ).

*     SAPMF05A / 0301 Registrar documento tipo Añadir posición de deudor
      co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05A' iv_dynpro  = '0301' ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-HKONT'  iv_value = is_det-hkont ).

      PERFORM format_value USING is_det-amt_doccur is_det-currency
                           CHANGING lv_wrbtr.
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-WRBTR'  iv_value = lv_wrbtr ).

      IF is_det-currency <> 'CLP'.
        PERFORM format_value USING is_det-amt_doccur_me is_det-currency_me
                             CHANGING lv_dmbtr.
        co_bdc->add_field( EXPORTING iv_field = 'BSEG-DMBTR'  iv_value = lv_dmbtr ).
      ENDIF.

      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZTERM'  iv_value = is_det-pmnttrms ).

      IF NOT is_det-bline_date IS INITIAL.
        WRITE is_det-bline_date TO lv_fecha.
        co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZFBDT' iv_value = lv_fecha ).
      ENDIF.

      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZLSPR' iv_value = is_det-pmnt_block ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZLSCH' iv_value = is_det-pymt_meth ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-ZUONR' iv_value = is_det-alloc_nmbr ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-SGTXT'  iv_value = is_det-sgtxt ).
      co_bdc->add_field( EXPORTING iv_field = 'BDC_OKCODE' iv_value = '=ZK' ).

*     SAPMF05A / 0331 Registrar documento tipo Corregir posición de deudor
      co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05A' iv_dynpro  = '0331' ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-XREF1' iv_value = is_det-ref_key_1 ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-XREF2' iv_value = is_det-ref_key_2 ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-HBKID' iv_value = is_det-bank_id ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-HKTID' iv_value = is_det-hktid ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-XREF3' iv_value = is_det-ref_key_3 ).
      co_bdc->add_field( EXPORTING iv_field = 'BSEG-BVTYP' iv_value = is_det-ATRIBUTO_8 ).

*      co_bdc->add_field( EXPORTING iv_field = 'BDC_OKCODE' iv_value = '=AB' ).
*
**     SAPMF05A / 0700
*      co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05A' iv_dynpro  = '0700' ).

  ENDCASE.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  DET_CC
*&---------------------------------------------------------------------*
FORM det_cc CHANGING is_det      TYPE gty_cont_det_ct
                     cv_bschl TYPE bschl.

  CASE is_det-tipo.

    WHEN 'GL'.
      IF is_det-amt_doccur > 0.
        cv_bschl = '40'.
      ELSE.
        cv_bschl = '50'.
        is_det-amt_doccur = 0 - is_det-amt_doccur.
      ENDIF.

    WHEN 'AP'.
      IF is_det-amt_doccur > 0.
        cv_bschl = '21'.
      ELSE.
        cv_bschl = '31'.
        is_det-amt_doccur = 0 - is_det-amt_doccur.
      ENDIF.

    WHEN 'AR'.
      IF is_det-amt_doccur > 0.
        cv_bschl = '01'.
      ELSE.
        cv_bschl = '11'.
        is_det-amt_doccur = 0 - is_det-amt_doccur.
      ENDIF.

  ENDCASE.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  VAL_DETALLE_CT
*&---------------------------------------------------------------------*
FORM val_detalle_ct  TABLES   return        STRUCTURE bapiret2
                     USING    p_ti_detalle  STRUCTURE zdetalle_me_ct
                              p_ti_cabecera STRUCTURE zcabecera_me
                     CHANGING p_t_error.

  DATA: t_thkon LIKE  thkon OCCURS 0 WITH HEADER LINE.
* Validación 1 – Número de cuenta de acreedor (VENDOR_NO)
  IF p_ti_detalle-vendor_no NE space.
    IF p_ti_detalle-vendor_no CS '-'.

    ELSE.
      CALL FUNCTION 'FI_VENDOR_CHECK'
        EXPORTING
          i_bukrs = p_ti_cabecera-comp_code
          i_lifnr = p_ti_detalle-vendor_no
        EXCEPTIONS
          vendor  = 1
          OTHERS  = 2.
      IF sy-subrc <> 0.
        p_t_error = 4.
        return-number            = '2'.
        return-message           = p_ti_detalle-zkey.
        return-log_no            = p_ti_detalle-itemno_acc.
        return-type              = 'E'.
        return-id                = '01'.
        return-message_v1        = 'El numero de Acreedor  '.
        CONCATENATE p_ti_detalle-vendor_no 'No Existe.'  INTO return-message_v2 SEPARATED BY space.
        return-message_v3        = 'Numero de comprobante Externo '.
        return-message_v4        = p_ti_cabecera-ref_doc_no.
        APPEND return.
        CLEAR: return.
      ENDIF.
    ENDIF.


  ENDIF.
* Validación 2 – Número de Cliente (CUSTOMER)
  IF p_ti_detalle-customer NE space.
    CALL FUNCTION 'FI_CUSTOMER_CHECK'
      EXPORTING
        i_bukrs  = p_ti_cabecera-comp_code
        i_kunnr  = p_ti_detalle-customer
      EXCEPTIONS
        customer = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'El numero de Cliente  '.
      CONCATENATE p_ti_detalle-customer 'No Existe.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDIF.
* Validación 3 – Número de cuenta de mayor (HKONT)
  IF p_ti_detalle-hkont NE space.
    DATA: kontenplan_wa LIKE  ska1,
          sachkonto_wa  LIKE  skb1.
    CALL FUNCTION 'READ_HAUPTBUCH'
      EXPORTING
        buchungskreis        = p_ti_cabecera-comp_code
        sachkonto            = p_ti_detalle-hkont
      IMPORTING
        kontenplan_wa        = kontenplan_wa
        sachkonto_wa         = sachkonto_wa
      EXCEPTIONS
        kontenplan_not_found = 1
        sachkonto_not_found  = 2
        not_authorized       = 3
        OTHERS               = 4.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'El numero de Cta mayor'.
      CONCATENATE p_ti_detalle-hkont 'No Existe.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDIF.
* Validación 4 – Numero de cuenta asociada deudor (HKONT)
  IF p_ti_detalle-hkont NE space AND p_ti_detalle-customer NE space.
    DATA: e_kna1 LIKE kna1,
          e_knb1 LIKE knb1.
    CALL FUNCTION 'CUSTOMER_READ'
      EXPORTING
        i_bukrs   = p_ti_cabecera-comp_code
        i_kunnr   = p_ti_detalle-customer
      IMPORTING
        e_kna1    = e_kna1
        e_knb1    = e_knb1
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc EQ  0.
      IF e_knb1-akont <>  p_ti_detalle-hkont.
        CALL FUNCTION 'LINEITEM_THKON_READ'
          EXPORTING
            i_ktopl = kontenplan_wa-ktopl
            i_saknr = e_knb1-akont
          TABLES
            t_thkon = t_thkon.
        DATA: p_t_error3 LIKE sy-subrc.
        LOOP AT t_thkon.
          IF  t_thkon-abwhk  EQ  p_ti_detalle-hkont.
            p_t_error3 = 0.
          ELSE.
            p_t_error3 = 4.
          ENDIF.
          IF p_t_error3 = 0.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF  p_t_error3 = 0.
          CALL FUNCTION 'READ_HAUPTBUCH'
            EXPORTING
              buchungskreis        = p_ti_cabecera-comp_code
              sachkonto            = p_ti_detalle-hkont
            IMPORTING
              kontenplan_wa        = kontenplan_wa
              sachkonto_wa         = sachkonto_wa
            EXCEPTIONS
              kontenplan_not_found = 1
              sachkonto_not_found  = 2
              not_authorized       = 3
              OTHERS               = 4.
          IF sy-subrc <> 0.
            p_t_error = 4.
            return-number            = '2'.
            return-message           = p_ti_detalle-zkey.
            return-log_no            = p_ti_detalle-itemno_acc.
            return-type              = 'E'.
            return-id                = '01'.
            return-message_v1        = 'El numero de Cta  mayor'.
            CONCATENATE p_ti_detalle-hkont 'No Existe.'  INTO return-message_v2 SEPARATED BY space.
            return-message_v3        = 'Numero de comprobante Externo '.
            return-message_v4        = p_ti_cabecera-ref_doc_no.
            APPEND return.
            CLEAR: return.
          ELSE.
            IF sachkonto_wa-xmitk NE  'X'.
* la ccuenta no esta marca como cueta asociedad lista para entrada
              p_t_error = 4.
              return-number            = '2'.
              return-message           = p_ti_detalle-zkey.
              return-log_no            = p_ti_detalle-itemno_acc.
              return-type              = 'E'.
              return-id                = '01'.
              return-message_v1        = 'La cuenta No Esta marcada'.
              return-message_v2        = 'como Cuenta Asociedad para Entrada'.
              return-message_v3        = 'Numero de comprobante Externo '.
              return-message_v4        = p_ti_cabecera-ref_doc_no.
              APPEND return.
              CLEAR: return.
            ENDIF.
          ENDIF.
        ELSE.
          p_t_error =   p_t_error3.
*            P_T_ERROR = 4.
          return-number            = '2'.
          return-message           = p_ti_detalle-zkey.
          return-log_no            = p_ti_detalle-itemno_acc.
          return-type              = 'E'.
          return-id                = '01'.
          return-message_v1        = 'Cuenta Asociedad '.
          return-message_v2        = 'es distinta '.
          return-message_v3        = 'Numero de comprobante Externo '.
          return-message_v4        = p_ti_cabecera-ref_doc_no.
          APPEND return.
          CLEAR: return.
        ENDIF.
      ENDIF.
    ELSE.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'El numero de Cliente  '.
      return-message_v2        = 'no Existe'.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDIF.
* Validación 5 – Numero de cuenta asociada acreedor(HKONT)
  DATA:
    e_lfa1 LIKE lfa1,
    e_lfb1 LIKE lfb1.
  IF p_ti_detalle-hkont NE space AND p_ti_detalle-vendor_no NE space.

    CALL FUNCTION 'VENDOR_READ'
      EXPORTING
        i_bukrs   = p_ti_cabecera-comp_code
        i_lifnr   = p_ti_detalle-vendor_no
      IMPORTING
        e_lfa1    = e_lfa1
        e_lfb1    = e_lfb1
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc = 0.

      IF  e_lfb1-akont <>  p_ti_detalle-hkont.

        CALL FUNCTION 'LINEITEM_THKON_READ'
          EXPORTING
            i_ktopl = kontenplan_wa-ktopl
            i_saknr = e_lfb1-akont
          TABLES
            t_thkon = t_thkon.


        DATA: p_t_error2 LIKE sy-subrc.

        IF t_thkon[] IS  INITIAL.
          p_t_error = 4.
          return-number            = '2'.
          return-message           = p_ti_detalle-zkey.
          return-log_no            = p_ti_detalle-itemno_acc.
          return-type              = 'E'.
          return-id                = '01'.
          return-message_v1        = 'La cuenta Divergente'.
          return-message_v2        = 'no existe'.
          return-message_v3        = 'Numero de comprobante Externo '.
          return-message_v4        = p_ti_cabecera-ref_doc_no.
          APPEND return.
          CLEAR: return.
        ENDIF.

        LOOP AT t_thkon.
          IF  t_thkon-abwhk  EQ  p_ti_detalle-hkont.
            p_t_error2 = 0.
          ELSE.
            p_t_error2 = 4.
          ENDIF.
          IF p_t_error2 = 0.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF  p_t_error2 = 0.
          CALL FUNCTION 'READ_HAUPTBUCH'
            EXPORTING
              buchungskreis        = p_ti_cabecera-comp_code
              sachkonto            = p_ti_detalle-hkont
            IMPORTING
              kontenplan_wa        = kontenplan_wa
              sachkonto_wa         = sachkonto_wa
            EXCEPTIONS
              kontenplan_not_found = 1
              sachkonto_not_found  = 2
              not_authorized       = 3
              OTHERS               = 4.
          IF sy-subrc <> 0.
            p_t_error = 4.
            return-number            = '2'.
            return-message           = p_ti_detalle-zkey.
            return-log_no            = p_ti_detalle-itemno_acc.
            return-type              = 'E'.
            return-id                = '01'.
            return-message_v1        = 'El numero de Cta mayor   '.
            CONCATENATE p_ti_detalle-hkont 'No Existe.'  INTO return-message_v2 SEPARATED BY space.
            return-message_v3        = 'Numero de comprobante Externo '.
            return-message_v4        = p_ti_cabecera-ref_doc_no.
            APPEND return.
            CLEAR: return.
          ELSE.
            IF sachkonto_wa-xmitk NE  'X'.
* la ccuenta no esta marca como cueta asociedad lista para entrada
              p_t_error = 4.
              return-number            = '2'.
              return-message           = p_ti_detalle-zkey.
              return-log_no            = p_ti_detalle-itemno_acc.
              return-type              = 'E'.
              return-id                = '01'.
              return-message_v1        = 'La cuenta No Esta marcada'.
              return-message_v2        = 'como Cuenta Asociedad para Entrada'.
              return-message_v3        = 'Numero de comprobante Externo '.
              return-message_v4        = p_ti_cabecera-ref_doc_no.
              APPEND return.
              CLEAR: return.
            ENDIF.
          ENDIF.
        ELSE.
          p_t_error =   p_t_error2.
          return-number            = '2'.
          return-message           = p_ti_detalle-zkey.
          return-log_no            = p_ti_detalle-itemno_acc.
          return-type              = 'E'.
          return-id                = '01'.
          return-message_v1        = 'Cuenta Asociedad '.
          return-message_v2        = 'es distinta '.
          return-message_v3        = 'Numero de comprobante Externo '.
          return-message_v4        = p_ti_cabecera-ref_doc_no.
          APPEND return.
          CLEAR: return.
        ENDIF.
      ELSE.
      ENDIF.
    ENDIF.
  ENDIF.



* Validación 6 - Indicador IVA (TAX_CODE)
  IF p_ti_detalle-tax_code NE space.

    DATA: e_record   LIKE  t001,
          e_valid(1) TYPE c.
    CALL FUNCTION 'VALIDATE_COMPANY_CODE'
      EXPORTING
        i_company  = p_ti_cabecera-comp_code
      IMPORTING
        e_record   = e_record
        e_valid    = e_valid
      EXCEPTIONS
        incomplete = 1
        OTHERS     = 2.
    IF sy-subrc = 0.
      CALL FUNCTION 'TAX_INDICATOR_CHECK'
        EXPORTING
          land              = e_record-land1
          steuerkennzeichen = p_ti_detalle-tax_code
        EXCEPTIONS
          kalsm_not_valid   = 1
          not_valid         = 2
          parameter_error   = 3
          OTHERS            = 4.
      IF sy-subrc <> 0.
        p_t_error = 4.
        return-number            = '2'.
        return-message           = p_ti_detalle-zkey.
        return-log_no            = p_ti_detalle-itemno_acc.
        return-type              = 'E'.
        return-id                = '01'.
        return-message_v1        = 'El Indicador de Iva Ingresado  '.
        return-message_v2        = 'No Es Valido'.
        return-message_v3        = 'Numero de comprobante Externo '.
        return-message_v4        = p_ti_cabecera-ref_doc_no.
        APPEND return.
        CLEAR: return.
      ENDIF.
    ENDIF.
  ENDIF.


  DATA: id_fin_company TYPE  con_fin_company.
  id_fin_company = p_ti_cabecera-comp_code.

* Validación 7 – Centro de Costo (KOSTL)
  IF p_ti_detalle-costcenter NE space.
    DATA: ed_kokrs TYPE  kokrs,
          v_cskb   LIKE  cskbv.

    CALL FUNCTION 'CON_FIN_GET_KOKRS_FROM_COMPANY'
      EXPORTING
        id_fin_company = id_fin_company
      IMPORTING
        ed_kokrs       = ed_kokrs.

    CALL FUNCTION 'RK_KSTAR_READ'
      EXPORTING
        datum           = p_ti_cabecera-pstng_date
        kokrs           = ed_kokrs
        kstar           = p_ti_detalle-hkont
      IMPORTING
        v_cskb          = v_cskb
      EXCEPTIONS
        kstar_not_found = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'La Clase costo Ingresada '.
      CONCATENATE p_ti_detalle-hkont  'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ELSE.
      IF v_cskb-katyp = 1.
* Valida ceco
        CALL FUNCTION 'K_COSTCENTER_EXISTENCE_CHECK'
          EXPORTING
            kokrs      = ed_kokrs
            kostl      = p_ti_detalle-costcenter
            datab      = p_ti_cabecera-pstng_date
            datbi      = p_ti_cabecera-pstng_date
          EXCEPTIONS
            not_at_all = 1
            OTHERS     = 2.
        IF sy-subrc <> 0.
          p_t_error = 4.
          return-number            = '2'.
          return-message           = p_ti_detalle-zkey.
          return-log_no            = p_ti_detalle-itemno_acc.
          return-type              = 'E'.
          return-id                = '01'.
          return-message_v1        = 'El Centro de Costo Ingreso'.
          CONCATENATE p_ti_detalle-costcenter  'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
          return-message_v3        = 'Numero de comprobante Externo '.
          return-message_v4        = p_ti_cabecera-ref_doc_no.
          APPEND return.
          CLEAR: return.
* Centro de Costo no Vañlido
        ENDIF.
      ELSE.
      ENDIF.
    ENDIF.
  ENDIF.
* Validación 8 – Centro de beneficio (PROFIT_CTR)
  IF p_ti_detalle-profit_ctr NE space.
    CALL FUNCTION 'CON_FIN_GET_KOKRS_FROM_COMPANY'
      EXPORTING
        id_fin_company = id_fin_company
      IMPORTING
        ed_kokrs       = ed_kokrs.

    CALL FUNCTION 'RK_KSTAR_READ'
      EXPORTING
        datum           = p_ti_cabecera-pstng_date
        kokrs           = ed_kokrs
        kstar           = p_ti_detalle-hkont
      IMPORTING
        v_cskb          = v_cskb
      EXCEPTIONS
        kstar_not_found = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'La Clase costo Ingresada '.
      CONCATENATE p_ti_detalle-hkont  'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.

    ELSE.
      IF v_cskb-katyp = 1.
* Valida cebe
        CALL FUNCTION 'KE_PROFIT_CENTER_CHECK'
          EXPORTING
            bukrs                 = p_ti_cabecera-comp_code
            datum                 = p_ti_cabecera-pstng_date
            datum_bis             = p_ti_cabecera-pstng_date
            prctr                 = p_ti_detalle-profit_ctr
          EXCEPTIONS
            not_found             = 1
            not_defined_for_date  = 2
            no_kokrs_for_bukrs    = 3
            parameter_mismatch    = 4
            prctr_locked          = 5
            not_defined_for_bukrs = 6
            OTHERS                = 7.
        IF sy-subrc <> 0.
          p_t_error = 4.
          return-number            = '2'.
          return-message           = p_ti_detalle-zkey.
          return-log_no            = p_ti_detalle-itemno_acc.
          return-type              = 'E'.
          return-id                = '01'.
          return-message_v1        = 'El Centro de beneficio Ingresado '.
          CONCATENATE p_ti_detalle-profit_ctr  'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
          return-message_v3        = 'Numero de comprobante Externo '.
          return-message_v4        = p_ti_cabecera-ref_doc_no.
          APPEND return.
          CLEAR: return.
* Centro de Beneficio no Vañlido
        ENDIF.
      ELSE.
*        P_T_ERROR = 4.
      ENDIF.
    ENDIF.
  ENDIF.
* Validación 9 – Condición de pago (PMNTTRMS)
  IF p_ti_detalle-pmnttrms NE space.
* Determina AP
    IF p_ti_detalle-hkont <> space AND
            p_ti_detalle-vendor_no <> space  AND
                       p_ti_detalle-customer EQ space.

      CALL FUNCTION 'FI_CHECK_ZTERM'
        EXPORTING
          i_koart       = 'K'
          i_zterm       = p_ti_detalle-pmnttrms
        EXCEPTIONS
          invalid_zterm = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        p_t_error = 4.
        return-number            = '2'.
        return-message           = p_ti_detalle-zkey.
        return-log_no            = p_ti_detalle-itemno_acc.
        return-type              = 'E'.
        return-id                = '01'.
        return-message_v1        = 'La Condicion de Pago '.
        CONCATENATE p_ti_detalle-pmnttrms 'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
        return-message_v3        = 'Numero de comprobante Externo '.
        return-message_v4        = p_ti_cabecera-ref_doc_no.
        APPEND return.
        CLEAR: return.
      ENDIF.
    ENDIF.
* Determina AR
    IF p_ti_detalle-hkont <> space AND
            p_ti_detalle-vendor_no EQ space  AND
                       p_ti_detalle-customer <> space.

      CALL FUNCTION 'FI_CHECK_ZTERM'
        EXPORTING
          i_koart       = 'D'
          i_zterm       = p_ti_detalle-pmnttrms
        EXCEPTIONS
          invalid_zterm = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        p_t_error = 4.
        return-number            = '2'.
        return-message           = p_ti_detalle-zkey.
        return-log_no            = p_ti_detalle-itemno_acc.
        return-type              = 'E'.
        return-id                = '01'.
        return-message_v1        = 'La Condicion de Pago'.
        CONCATENATE p_ti_detalle-pmnttrms 'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
        return-message_v3        = 'Numero de comprobante Externo '.
        return-message_v4        = p_ti_cabecera-ref_doc_no.
        APPEND return.
        CLEAR: return.
      ENDIF.
    ENDIF.
  ENDIF.
* Validación 10- Vía de pago (PYMT_METH)
  IF p_ti_detalle-pymt_meth NE space.

    DATA: e_record1   LIKE  t001,
          e_valid1(1) TYPE c.
    CALL FUNCTION 'VALIDATE_COMPANY_CODE'
      EXPORTING
        i_company  = p_ti_cabecera-comp_code
      IMPORTING
        e_record   = e_record1
        e_valid    = e_valid1
      EXCEPTIONS
        incomplete = 1
        OTHERS     = 2.

    CALL FUNCTION 'T042Z_SINGLE_READ'
      EXPORTING
        i_land1   = e_record1-land1
        i_zlsch   = p_ti_detalle-pymt_meth
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'La Via de Pago'.
      CONCATENATE p_ti_detalle-pymt_meth 'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDIF.

  IF  p_ti_detalle-zzprestac NE space.
    DATA: p_zzprestac TYPE zprestacion-zzprestac.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p_ti_detalle-zzprestac
      IMPORTING
        output = p_ti_detalle-zzprestac.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zzprestac FROM zprestacion INTO p_zzprestac
*       WHERE zzprestac = p_ti_detalle-zzprestac
*      AND    bukrs     = p_ti_cabecera-comp_code.
*
* NEW CODE
    SELECT zzprestac
    UP TO 1 ROWS  FROM zprestacion INTO p_zzprestac
       WHERE zzprestac = p_ti_detalle-zzprestac
      AND    bukrs     = p_ti_cabecera-comp_code ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'codigo de Prestación'.
      CONCATENATE p_ti_detalle-zzprestac 'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDIF.

  IF   p_ti_detalle-zzunid_pro NE space.
    DATA: p_zzcod_unidad TYPE zunid_prod-zzcod_unidad.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p_ti_detalle-zzunid_pro
      IMPORTING
        output = p_ti_detalle-zzunid_pro.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  zzcod_unidad FROM zunid_prod INTO  p_zzcod_unidad
*       WHERE zzcod_unidad = p_ti_detalle-zzunid_pro
*      AND    bukrs     = p_ti_cabecera-comp_code.
*
* NEW CODE
    SELECT zzcod_unidad
    UP TO 1 ROWS  FROM zunid_prod INTO  p_zzcod_unidad
       WHERE zzcod_unidad = p_ti_detalle-zzunid_pro
      AND    bukrs     = p_ti_cabecera-comp_code ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'codigo de Unidad de Producto'.
      CONCATENATE p_ti_detalle-zzunid_pro 'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDIF.
  IF  p_ti_detalle-zzdesc_est NE space.
    DATA: e_zzcod_unidad TYPE zdesc_est-zzcod_unidad.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p_ti_detalle-zzdesc_est
      IMPORTING
        output = p_ti_detalle-zzdesc_est.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  zzcod_unidad FROM zdesc_est INTO  e_zzcod_unidad
*       WHERE zzcod_unidad = p_ti_detalle-zzdesc_est
*      AND    bukrs     = p_ti_cabecera-comp_code.
*
* NEW CODE
    SELECT zzcod_unidad
    UP TO 1 ROWS  FROM zdesc_est INTO  e_zzcod_unidad
       WHERE zzcod_unidad = p_ti_detalle-zzdesc_est
      AND    bukrs     = p_ti_cabecera-comp_code ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'Codigo de Estamento'.
      CONCATENATE p_ti_detalle-zzdesc_est 'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDIF.


  IF  p_ti_detalle-zzmot_emis NE space.
    DATA: i_zzcod_unidad TYPE zmot_emis-zzmot_emis.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p_ti_detalle-zzmot_emis
      IMPORTING
        output = p_ti_detalle-zzmot_emis.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  zzmot_emis FROM zmot_emis INTO  i_zzcod_unidad
*       WHERE zzmot_emis =  p_ti_detalle-zzmot_emis
*      AND    bukrs     = p_ti_cabecera-comp_code.
*
* NEW CODE
    SELECT zzmot_emis
    UP TO 1 ROWS  FROM zmot_emis INTO  i_zzcod_unidad
       WHERE zzmot_emis =  p_ti_detalle-zzmot_emis
      AND    bukrs     = p_ti_cabecera-comp_code ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'Codigo de Emisor'.
      CONCATENATE p_ti_detalle-zzmot_emis 'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDIF.

  IF   p_ti_detalle-zzrut_terc NE space.
    DATA: a_zzcod_unidad TYPE lfa1-lifnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p_ti_detalle-zzrut_terc
      IMPORTING
        output = p_ti_detalle-zzrut_terc.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  lifnr FROM lfb1 INTO  a_zzcod_unidad
*       WHERE lifnr =  p_ti_detalle-zzrut_terc
*      AND    bukrs     = p_ti_cabecera-comp_code.
*
* NEW CODE
    SELECT lifnr
    UP TO 1 ROWS  FROM lfb1 INTO  a_zzcod_unidad
       WHERE lifnr =  p_ti_detalle-zzrut_terc
      AND    bukrs     = p_ti_cabecera-comp_code ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'Rut de Tercero'.
      CONCATENATE p_ti_detalle-zzrut_terc 'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDIF.

  IF p_ti_detalle-zz_agencia NE space.
    DATA: r_zzcod_unidad TYPE zagencia-zzcod_unidad.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p_ti_detalle-zz_agencia
      IMPORTING
        output = p_ti_detalle-zz_agencia.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  zzcod_unidad FROM zagencia INTO  r_zzcod_unidad
*       WHERE zzcod_unidad = p_ti_detalle-zz_agencia
*      AND    bukrs     = p_ti_cabecera-comp_code.
*
* NEW CODE
    SELECT zzcod_unidad
    UP TO 1 ROWS  FROM zagencia INTO  r_zzcod_unidad
       WHERE zzcod_unidad = p_ti_detalle-zz_agencia
      AND    bukrs     = p_ti_cabecera-comp_code ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'Codigo de Agencia'.
      CONCATENATE p_ti_detalle-zz_agencia 'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDIF.
  IF p_ti_detalle-fdlev  NE space.
    DATA: p_fdlev LIKE t036-ebene.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE ebene  FROM t036 INTO p_fdlev
*      WHERE ebene EQ p_ti_detalle-fdlev
*      AND orign = 'PSK'.
*
* NEW CODE
    SELECT ebene
    UP TO 1 ROWS   FROM t036 INTO p_fdlev
      WHERE ebene EQ p_ti_detalle-fdlev
      AND orign = 'PSK' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      p_t_error = 4.
      return-number            = '2'.
      return-message           = p_ti_detalle-zkey.
      return-log_no            = p_ti_detalle-itemno_acc.
      return-type              = 'E'.
      return-id                = '01'.
      return-message_v1        = 'Nivel de tesoreria'.
      CONCATENATE p_ti_detalle-fdlev 'No Es Valido.'  INTO return-message_v2 SEPARATED BY space.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDIF.

ENDFORM.                    " VAL_DETALLE_CT


*&---------------------------------------------------------------------*
*&      Form  PROCESA_ERROR_CT
*&---------------------------------------------------------------------*
FORM procesa_error_ct  TABLES p_ti_error_cab  STRUCTURE ti_error_cab
                              p_ti_error_det  STRUCTURE ti_error_det_ct
                              p_ti_cont_cab   STRUCTURE ti_cont_cab
                              p_ti_cont_det   STRUCTURE ti_cont_det_ct
                              p_ti_tlogcaberr STRUCTURE ztlogcaberr
                              p_ti_tlogdeterr STRUCTURE ztlogdeterr
                              p_ti_resumen    STRUCTURE zresumen
                              return          STRUCTURE bapiret2
                              ti_detalle      STRUCTURE zdetalle_me_ct.

  DATA: BEGIN OF error_det OCCURS 0.
          INCLUDE STRUCTURE zdetalle_me_ct.
        DATA: END OF   error_det.

  DATA: BEGIN OF error_cab OCCURS 0.
          INCLUDE STRUCTURE ti_cont_cab.
        DATA: END OF   error_cab.

  DATA: p_index LIKE sy-tabix.

  LOOP AT p_ti_error_cab.
    LOOP AT p_ti_cont_det WHERE zkey EQ p_ti_error_cab-zkey.
      p_index = sy-tabix.
      MOVE-CORRESPONDING p_ti_cont_det TO error_det.
      APPEND error_det.
      DELETE p_ti_cont_det INDEX p_index.
    ENDLOOP.
  ENDLOOP.

  LOOP AT error_det.
    READ TABLE p_ti_error_det WITH KEY zkey = error_det-zkey.
    IF sy-subrc NE 0.
      MOVE-CORRESPONDING error_det TO p_ti_error_det.
      APPEND p_ti_error_det.
    ENDIF.
  ENDLOOP.


  LOOP AT p_ti_error_det.
    LOOP AT p_ti_cont_cab WHERE zkey = p_ti_error_det-zkey.
      p_index = sy-tabix.
      MOVE-CORRESPONDING p_ti_cont_cab TO error_cab.
      APPEND error_cab.
      DELETE p_ti_cont_cab INDEX p_index.
    ENDLOOP.
  ENDLOOP.


  LOOP AT error_cab.
    READ TABLE p_ti_error_cab WITH KEY zkey = error_cab-zkey.
    IF sy-subrc NE 0.
      MOVE-CORRESPONDING error_cab TO p_ti_error_cab.
      APPEND p_ti_error_cab.
    ENDIF.
  ENDLOOP.

* Llena tabla de errores de Cabecera  y detalle estructuras P_TI_TLOGCABERR y P_TI_TLOGDETERR.
  LOOP AT return.
    IF  return-number  EQ 1.
      MOVE:  return-message TO p_ti_tlogcaberr-key,
             return-number  TO p_ti_tlogcaberr-cod_err.
      CONCATENATE return-message_v1 return-message_v2 return-message_v3    return-message_v4
        INTO  p_ti_tlogcaberr-descripcion SEPARATED BY space.
      APPEND p_ti_tlogcaberr.
    ELSE.
      IF return-number  EQ 2.
        MOVE:
              return-message+0(6)   TO p_ti_tlogdeterr-key,
              return-log_no+0(3)    TO p_ti_tlogdeterr-posic,
              return-number         TO p_ti_tlogdeterr-cod_err.
        CONCATENATE return-message_v1 return-message_v2 return-message_v3  return-message_v4
          INTO p_ti_tlogdeterr-descripcion SEPARATED BY space.
        APPEND p_ti_tlogdeterr.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Ingresa los datos a la estructura P_TI_RESUMEN.
  LOOP  AT p_ti_error_cab.
    LOOP AT ti_detalle WHERE zkey EQ p_ti_error_cab-zkey.
      ADD 1 TO  p_ti_resumen-con_pos.
    ENDLOOP.
    MOVE: p_ti_error_cab-zkey TO  p_ti_resumen-key,
          p_ti_error_cab-ref_doc_no TO  p_ti_resumen-ref.

    READ TABLE return WITH KEY  message+0(6) = p_ti_error_cab-zkey
                                number = 1.
    IF sy-subrc EQ 0.
      p_ti_resumen-estado = '1'.
    ELSE.
      READ TABLE return WITH KEY  message+0(6) = p_ti_error_cab-zkey
                                  number = 2.
      IF sy-subrc EQ 0.
        p_ti_resumen-estado = '2'.
      ENDIF.
    ENDIF.
    APPEND p_ti_resumen.
    CLEAR: p_ti_resumen.
  ENDLOOP.

ENDFORM.                    " PROCESA_ERROR_CT


*&---------------------------------------------------------------------*
*&      Form  DETERMINA_TIPO_CC
*&---------------------------------------------------------------------*
FORM determina_tipo_cc.

  DATA: p_index   LIKE sy-tabix,
        p_index_v LIKE sy-tabix.

  LOOP AT ti_cont_cab.
    p_index =  sy-tabix.
    LOOP AT ti_cont_det_ct WHERE zkey EQ ti_cont_cab-zkey.
      p_index_v = sy-tabix.
* Determina GL.
      IF ti_cont_det_ct-hkont <> space AND
              ti_cont_det_ct-vendor_no EQ space  AND
                         ti_cont_det_ct-customer EQ space.
        MOVE: 'GL' TO ti_cont_det_ct-tipo,
              'GL' TO ti_cont_cab-tipo.
        MODIFY ti_cont_det_ct INDEX p_index_v.
      ENDIF.
* Determina AP
      IF ti_cont_det_ct-hkont <> space AND
              ti_cont_det_ct-vendor_no <> space  AND
                         ti_cont_det_ct-customer EQ space.
        MOVE: 'AP' TO ti_cont_det_ct-tipo,
              'AP' TO ti_cont_cab-tipo.
        MODIFY ti_cont_det_ct INDEX p_index_v.
      ENDIF.
* Determina AR
      IF ti_cont_det_ct-hkont <> space AND
              ti_cont_det_ct-vendor_no EQ space  AND
                         ti_cont_det_ct-customer <> space.
        MOVE: 'AR' TO ti_cont_det_ct-tipo,
              'AR' TO ti_cont_cab-tipo.
        MODIFY ti_cont_det_ct INDEX p_index_v.
      ENDIF.
* Determina iva GL
      IF ti_cont_det_ct-iva EQ 'X'.
        MOVE: 'GL' TO ti_cont_det_ct-tipo,
              'GL' TO ti_cont_cab-tipo.
        MODIFY ti_cont_det_ct INDEX p_index_v.
      ELSEIF ti_cont_det_ct-iva EQ 'S'.
        MOVE: 'AR' TO ti_cont_det_ct-tipo,
              'AR' TO ti_cont_cab-tipo.
        MODIFY ti_cont_det_ct INDEX p_index_v.
      ENDIF.
    ENDLOOP.
    MODIFY    ti_cont_cab INDEX p_index.
  ENDLOOP.

ENDFORM.    " DETERMINA_TIPO_CC

*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
FORM call_transaction TABLES   et_return     TYPE bapiret2_t
                               et_resumen    STRUCTURE zresumen
                      USING    iv_contador   TYPE numc3
                               io_bdc        TYPE REF TO lcl_bdc
                      CHANGING iv_msg_err    TYPE bapi_msg.

  DATA: ls_retcode   TYPE bapiret2.

  DATA: lv_tcode   TYPE sytcode VALUE 'FB01',
        lv_tcodeld TYPE sytcode VALUE 'FB01L',
        lv_mode    TYPE ctu_mode,
        lv_update  TYPE ctu_update,
        lv_rc      TYPE sysubrc.

  CLEAR iv_msg_err.
  lv_mode   = 'N'.
  lv_update = 'S'.
  io_bdc->call_transaction( EXPORTING iv_tcode   = lv_tcode
                                      iv_mode    = lv_mode
                                      iv_update  = lv_update
                            IMPORTING es_retcode = ls_retcode
                                      ev_rc      = lv_rc  ).

  IF NOT lv_rc IS INITIAL.   "Hay errores
*   Tabla RETURN
    APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<ls_return>).
    <ls_return>        = ls_retcode.
    <ls_return>-field  = ti_cont_cab-zkey.

*   Traspasa datos de ejecucion a estructura de resumen
    APPEND INITIAL LINE TO et_resumen ASSIGNING FIELD-SYMBOL(<ls_resumen>).
    <ls_resumen>-key = ti_cont_cab-zkey.
    <ls_resumen>-ref = ti_cont_cab-ref_doc_no.
    WRITE iv_contador TO <ls_resumen>-con_pos.
    <ls_resumen>-estado = '3'.

    iv_msg_err = ls_retcode-message.
  ELSE.                  "Se creó el documento
*   S F5 312
    APPEND INITIAL LINE TO et_resumen ASSIGNING <ls_resumen>.
    <ls_resumen>-key = ti_cont_cab-zkey.
    <ls_resumen>-ref = ti_cont_cab-ref_doc_no.
    WRITE iv_contador TO <ls_resumen>-con_pos.
    <ls_resumen>-n_sap = ls_retcode-message_v1.
    <ls_resumen>-estado = '0'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
FORM call_transaction_LG TABLES et_return     TYPE bapiret2_t
                                et_resumen    STRUCTURE zresumen
                         USING  iv_contador   TYPE numc3
                                io_bdc        TYPE REF TO lcl_bdc
                       CHANGING iv_msg_err    TYPE bapi_msg.

  DATA: ls_retcode   TYPE bapiret2.

  DATA: lv_tcode   TYPE sytcode VALUE 'FB01',
        lv_tcodeld TYPE sytcode VALUE 'FB01L',
        lv_mode    TYPE ctu_mode,
        lv_update  TYPE ctu_update,
        lv_rc      TYPE sysubrc.

  CLEAR iv_msg_err.
  lv_mode   = 'N'.
  lv_update = 'S'.
  io_bdc->call_transaction( EXPORTING iv_tcode   = lv_tcodeld
                                      iv_mode    = lv_mode
                                      iv_update  = lv_update
                            IMPORTING es_retcode = ls_retcode
                                      ev_rc      = lv_rc  ).

  IF NOT lv_rc IS INITIAL.   "Hay errores
*   Tabla RETURN
    APPEND INITIAL LINE TO et_return ASSIGNING FIELD-SYMBOL(<ls_return>).
    <ls_return>        = ls_retcode.
    <ls_return>-field  = ti_cont_cab-zkey.

*   Traspasa datos de ejecucion a estructura de resumen
    APPEND INITIAL LINE TO et_resumen ASSIGNING FIELD-SYMBOL(<ls_resumen>).
    <ls_resumen>-key = ti_cont_cab-zkey.
    <ls_resumen>-ref = ti_cont_cab-ref_doc_no.
    WRITE iv_contador TO <ls_resumen>-con_pos.
    <ls_resumen>-estado = '3'.

    iv_msg_err = ls_retcode-message.
  ELSE.                  "Se creó el documento
*   S F5 312
    APPEND INITIAL LINE TO et_resumen ASSIGNING <ls_resumen>.
    <ls_resumen>-key = ti_cont_cab-zkey.
    <ls_resumen>-ref = ti_cont_cab-ref_doc_no.
    WRITE iv_contador TO <ls_resumen>-con_pos.
    <ls_resumen>-n_sap = ls_retcode-message_v1.
    <ls_resumen>-estado = '0'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MOFIFICAR-DOCUMENTO
*&---------------------------------------------------------------------*
FORM MODIFICAR-DOCUMENTO TABLES   et_resumen    STRUCTURE zresumen
                         CHANGING co_bdc   TYPE REF TO lcl_bdc.

  DATA: ls_retcode   TYPE bapiret2.
* DATA: io_bdc       TYPE REF TO lcl_bdc.

  DATA: lv_tcode    TYPE sytcode VALUE 'FB02',
        lv_mode     TYPE ctu_mode,
        lv_update   TYPE ctu_update,
        lv_rc       TYPE sysubrc,
        lv_GJAHR(4) TYPE C.

  DATA: i_zzcod_unidad2 TYPE tsad4-prefix_txt.

  co_bdc->new_data( ).

  READ TABLE et_resumen INDEX 1.

  lv_gjahr = ti_cont_cab-pstng_date+0(4).

  co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05L'    iv_dynpro  = '0100' ).
  co_bdc->add_field(  EXPORTING iv_field   = 'BDC_CURSOR'  iv_value = 'RF05L-BELNR' ).
  co_bdc->add_field(  EXPORTING iv_field   = 'BDC_OKCODE'  iv_value = '/00' ).
  co_bdc->add_field(  EXPORTING iv_field   = 'RF05L-BUKRS' iv_value = ti_cont_cab-comp_code ).
  co_bdc->add_field(  EXPORTING iv_field   = 'RF05L-BELNR' iv_value = et_resumen-N_SAP ).
  co_bdc->add_field(  EXPORTING iv_field   = 'RF05L-GJAHR' iv_value = lv_gjahr ).
**
  co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05L'    iv_dynpro  = '0700' ).
  co_bdc->add_field(  EXPORTING iv_field   = 'BDC_CURSOR'  iv_value = 'BKPF-BELNR' ).
  co_bdc->add_field(  EXPORTING iv_field   = 'BDC_OKCODE'  iv_value = '=VK' ).

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE  prefix_txt FROM tsad4 INTO  i_zzcod_unidad2
*         WHERE prefix_key =  ti_cont_cab-area_contab.
*
* NEW CODE
  SELECT prefix_txt
  UP TO 1 ROWS  FROM tsad4 INTO  i_zzcod_unidad2
         WHERE prefix_key =  ti_cont_cab-area_contab ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


  co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05L'      iv_dynpro  = '1710' ).
  co_bdc->add_field(  EXPORTING iv_field   = 'BDC_CURSOR'    iv_value = 'BKPF-XREF2_HD' ).
  co_bdc->add_field(  EXPORTING iv_field   = 'BDC_OKCODE'    iv_value = '=ENTR' ).
  co_bdc->add_field(  EXPORTING iv_field   = 'BKPF-XREF2_HD' iv_value = i_zzcod_unidad2 ).

  co_bdc->add_dynpro( EXPORTING iv_program = 'SAPMF05L'    iv_dynpro  = '0700' ).
  co_bdc->add_field(  EXPORTING iv_field   = 'BDC_CURSOR'  iv_value = 'BKPF-BELNR' ).
  co_bdc->add_field(  EXPORTING iv_field   = 'BDC_OKCODE'  iv_value = '=AE' ).

  lv_mode   = 'N'.
  lv_update = 'S'.
  co_bdc->call_transaction( EXPORTING iv_tcode   = lv_tcode
                                      iv_mode    = lv_mode
                                      iv_update  = lv_update
                            IMPORTING es_retcode = ls_retcode
                                      ev_rc      = lv_rc  ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORMAT_VALUE
*&---------------------------------------------------------------------*
FORM format_value  USING    iv_importe  TYPE zde_wrbtr5
                            iv_currency TYPE currency
                   CHANGING ev_wrbtr    TYPE gty_importe.

  CLEAR: ev_wrbtr.
  IF iv_currency IS INITIAL OR iv_importe IS INITIAL.
    RETURN.
  ENDIF.

  SELECT SINGLE FROM tcurx FIELDS currdec
    WHERE currkey = @iv_currency
    INTO @DATA(lv_currdec).

  IF sy-subrc <>  0.
    lv_currdec = 2.
  ENDIF.

  WRITE iv_importe TO ev_wrbtr NO-SIGN NO-GROUPING DECIMALS lv_currdec
                               LEFT-JUSTIFIED.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  GET_RETEN
*&---------------------------------------------------------------------*
FORM get_reten  TABLES et_lfbw   TYPE gtt_lfbw.

  TYPES: BEGIN OF lty_lfb1,
           bukrs TYPE bukrs,
           lifnr TYPE lifnr,
         END OF lty_lfb1,

         ltt_lfb1 TYPE STANDARD TABLE OF lty_lfb1.

  DATA: lt_lfb1 TYPE ltt_lfb1.

  LOOP AT ti_cont_cab ASSIGNING FIELD-SYMBOL(<ls_cab>).
    LOOP AT ti_cont_det_ct ASSIGNING FIELD-SYMBOL(<ls_det>)
      WHERE zkey = <ls_cab>-zkey.

      CHECK <ls_det>-tipo = 'AP'.

      APPEND INITIAL LINE TO lt_lfb1 ASSIGNING FIELD-SYMBOL(<ls_lfb1>).
      <ls_lfb1>-bukrs = <ls_cab>-comp_code.
      <ls_lfb1>-lifnr = <ls_det>-vendor_no.
    ENDLOOP.
  ENDLOOP.

  SORT lt_lfb1 BY bukrs lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_lfb1 COMPARING ALL FIELDS.

  IF NOT lt_lfb1 IS INITIAL.
    SELECT FROM lfbw FIELDS lifnr, bukrs, witht, wt_subjct, wt_withcd
      FOR ALL ENTRIES IN @lt_lfb1
      WHERE lifnr = @lt_lfb1-lifnr
        AND bukrs = @lt_lfb1-bukrs
      INTO TABLE @et_lfbw.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VAL_TOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RETURN  text
*      -->P_TI_CABECERA  text
*      -->P_DMBTR_TOT  text
*      -->P_WRBTR_TOT  text
*      <--P_T_ERROR  text
*----------------------------------------------------------------------*
FORM val_tot  TABLES  return STRUCTURE bapiret2
              USING    p_ti_cabecera STRUCTURE zcabecera_me
                       p_currency TYPE currency
                       p_dmbtr_tot TYPE decfloat34
                       p_currency_me TYPE currency
                       p_wrbtr_tot TYPE decfloat34
              CHANGING p_t_error.
  DATA lv_message_v1   TYPE symsgv.

  CLEAR p_t_error.

  IF p_dmbtr_tot <> 0.
    CONCATENATE 'Total en moneda ' p_currency ' no es cero' INTO lv_message_v1 RESPECTING BLANKS.
    p_t_error = 4.
    return-number            = '1'.
    return-message           = p_ti_cabecera-zkey.
    return-type              = 'E'.
    return-id                = '08'.
    return-message_v1        = lv_message_v1.
    return-message_v2        = ' el registro no se contabilizara.'.
    return-message_v3        = 'Numero de comprobante Externo '.
    return-message_v4        = p_ti_cabecera-ref_doc_no.
    APPEND return.
  ENDIF.
  IF  p_wrbtr_tot <> 0.
    CONCATENATE 'Total en moneda ' p_currency_me ' no es cero' INTO lv_message_v1 RESPECTING BLANKS.
    p_t_error = 4.
    return-number            = '1'.
    return-message           = p_ti_cabecera-zkey.
    return-type              = 'E'.
    return-id                = '08'.
    return-message_v1        = lv_message_v1.
    return-message_v2        = ' el registro no se contabilizara.'.
    return-message_v3        = 'Numero de comprobante Externo '.
    return-message_v4        = p_ti_cabecera-ref_doc_no.
    APPEND return.
  ENDIF.
ENDFORM.
