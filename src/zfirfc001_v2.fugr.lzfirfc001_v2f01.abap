*&---------------------------------------------------------------------*
*&  Include           LZFIRFC001F01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LZFIRFC001F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VAL_CAB
*&---------------------------------------------------------------------*
*       Validacion de campos de cabecera de la estructura.
*----------------------------------------------------------------------*
*      -->P_TI_CABECERA  estructura de cabecera
*      <--P_T_ERROR       canpo de error.
*----------------------------------------------------------------------*
FORM val_cab  TABLES  return STRUCTURE bapiret2
              USING    p_ti_cabecera STRUCTURE zcabecera
              CHANGING p_t_error.

  DATA:  e_valid(1) TYPE c,
         e_oper LIKE  t001b-frpe1,
         error_so LIKE sy-subrc.

  CLEAR: p_t_error,
         error_so.

* Valida numero KEY
  IF p_ti_cabecera-key  EQ space.
    p_t_error = 4.
    return-number            = '1'.
    return-message           = p_ti_cabecera-key.
    return-type              = 'E'.
    return-id                = '01'.
    return-message_v1        = 'El Campo KEY  esta Incompleto'.
    return-message_v2        = ' el registro no se contabilizara.'.
    return-message_v3        = 'Numero de comprobante Externo '.
    return-message_v4        = p_ti_cabecera-ref_doc_no.
    APPEND return.
  ENDIF.

  CALL FUNCTION 'VALIDATE_COMPANY_CODE'
    EXPORTING
      i_company  = p_ti_cabecera-comp_code
    IMPORTING
      e_valid    = e_valid
    EXCEPTIONS
      incomplete = 1
      OTHERS     = 2.
  IF  e_valid EQ 0.
    p_t_error = 4.
    error_so  = 4.
    return-number            = '1'.
    return-message           = p_ti_cabecera-key.
    return-type             = 'E'.
    return-id                = '02'.
    return-message_v1        = 'La Sociedad  FI no existe o esta Vacia'.
    return-message_v2        = ' el registro no se contabilizara.'.
    return-message_v3        = 'Numero de comprobante Externo '.
    return-message_v4        = p_ti_cabecera-ref_doc_no.
    APPEND return.
  ENDIF.

  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date                      = p_ti_cabecera-doc_date
    EXCEPTIONS
      plausibility_check_failed = 1
      OTHERS                    = 2.
  IF sy-subrc <> 0.
    p_t_error = 4.
    return-number            = '1'.
    return-message           = p_ti_cabecera-key.
    return-type             = 'E'.
    return-id                = '03'.
    return-message_v1        = 'Fecha del docuemento no es valida'.
    return-message_v2        = ' el registro no se contabilizara.'.
    return-message_v3        = 'Numero de comprobante Externo '.
    return-message_v4        = p_ti_cabecera-ref_doc_no.
    APPEND return.
  ENDIF.

  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date                      = p_ti_cabecera-pstng_date
    EXCEPTIONS
      plausibility_check_failed = 1
      OTHERS                    = 2.
  IF sy-subrc <> 0.
    p_t_error = 4.
    return-number            = '1'.
    return-message           = p_ti_cabecera-key.
    return-type             = 'E'.
    return-id                = '04'.
    return-message_v1        = 'Fecha de Contabilización no es valida'.
    return-message_v2        = ' el registro no se contabilizara.'.
    return-message_v3        = 'Numero de comprobante Externo '.
    return-message_v4        = p_ti_cabecera-ref_doc_no.
    APPEND return.
  ENDIF.


  DATA: i_monat LIKE  t001b-frpe1.
  i_monat  = p_ti_cabecera-pstng_date+4(2).
  IF error_so EQ 0.

    CALL FUNCTION 'FI_PERIOD_CHECK'
      EXPORTING
        i_bukrs          = p_ti_cabecera-comp_code
        i_gjahr          = p_ti_cabecera-pstng_date+0(4)
        i_koart          = '+'
        i_konto          = '+'
        i_monat          = i_monat
        i_glvor          = 'RFBU'
      IMPORTING
        e_oper           = e_oper
      EXCEPTIONS
        error_period     = 1
        error_period_acc = 2
        invalid_input    = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-number            = '1'.
      return-message           = p_ti_cabecera-key.
      return-type             = 'E'.
      return-id                = '05'.
      return-message_v1        = 'El Periodo contabla no esta Disponible'.
      return-message_v2        = ' el registro no se contabilizara.'.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
    ENDIF.

  ENDIF.


  CALL FUNCTION 'FI_DOCUMENT_TYPE_CHECK'
    EXPORTING
      i_blart                       = p_ti_cabecera-doc_type
      i_langu                       = sy-langu
    EXCEPTIONS
      account_type                  = 1
      document_type                 = 2
      document_type_for_batch_only  = 3
      doctype_only_for_glx_postings = 4
      doctype_not_for_glx_postings  = 5
      OTHERS                        = 6.
  IF sy-subrc <> 0.
    p_t_error = 4.
    return-number            = '1'.
    return-message           = p_ti_cabecera-key.
    return-type             = 'E'.
    return-id                = '06'.
    return-message_v1        = 'Tipo de Documento no es Valido o se encuentra vacio'.
    return-message_v2        = ' el registro no se contabilizara.'.
    return-message_v3        = 'Numero de comprobante Externo '.
    return-message_v4        = p_ti_cabecera-ref_doc_no.
    APPEND return.
  ENDIF.

  IF p_ti_cabecera-ref_doc_no EQ space.
    p_t_error = 4.
    return-number            = '1'.
    return-message           = p_ti_cabecera-key.
    return-type             = 'E'.
    return-id                = '07'.
    return-message_v1        = 'Numero Documento de Referencia se encuentra Vacia'.
    return-message_v2        = ' el registro no se contabilizara.'.
    return-message_v3        = 'Numero de comprobante Externo '.
    return-message_v4        = p_ti_cabecera-ref_doc_no.
    APPEND return.
  ENDIF.

  IF ti_cont_cab-area_contab   NE space.
    DATA: i_zzcod_unidad TYPE tsad4-prefix_key.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  prefix_key FROM tsad4 INTO  i_zzcod_unidad
*       WHERE prefix_key =  ti_cont_cab-area_contab.
*
* NEW CODE
    SELECT prefix_key
    UP TO 1 ROWS  FROM tsad4 INTO  i_zzcod_unidad
       WHERE prefix_key =  ti_cont_cab-area_contab ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      p_t_error = 4.
      return-number            = '1'.
      return-message           = p_ti_cabecera-key.
      return-type             = 'E'.
      return-id                = '07'.
      return-message_v1        = 'Area de contabilidad'.
      return-message_v2        = 'No es valido.'.
      return-message_v3        = 'Numero de comprobante Externo '.
      return-message_v4        = p_ti_cabecera-ref_doc_no.
      APPEND return.
    ENDIF.
  ENDIF.

ENDFORM.                    " VAL_CAB
*&---------------------------------------------------------------------*
*&      Form  VAL_DETALLE
*&---------------------------------------------------------------------*
*      Validacion de campos de detalle de la estructura.
*----------------------------------------------------------------------*
*      -->P_TI_DETALLE  estructura de Detalle
*      <--P_T_ERROR  canpo de error.
*----------------------------------------------------------------------*
FORM val_detalle  TABLES  return STRUCTURE bapiret2
                  USING    p_ti_detalle STRUCTURE zdetalle
                           p_ti_cabecera STRUCTURE zcabecera
                  CHANGING p_t_error.

  DATA: t_thkon LIKE  thkon OCCURS 0 WITH HEADER LINE.
* Validación 1 – Número de cuenta de acreedor (VENDOR_NO)
  IF p_ti_detalle-vendor_no NE space.
    IF p_ti_detalle-vendor_no CS '-'.
*      CALL FUNCTION 'ZFI_VENDOR_CHECK'
*        EXPORTING
*          I_BUKRS       =
*          I_LIFNR       =
**       EXCEPTIONS
**         VENDOR        = 1
**         OTHERS        = 2
*                .
*      IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.

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
        return-message           = p_ti_detalle-key.
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
      return-message           = p_ti_detalle-key.
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
    DATA:     kontenplan_wa LIKE  ska1,
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
      return-message           = p_ti_detalle-key.
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
            return-message           = p_ti_detalle-key.
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
              return-message           = p_ti_detalle-key.
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
          return-message           = p_ti_detalle-key.
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
      return-message           = p_ti_detalle-key.
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
          return-message           = p_ti_detalle-key.
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
            return-message           = p_ti_detalle-key.
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
              return-message           = p_ti_detalle-key.
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
          return-message           = p_ti_detalle-key.
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
*Revisar cuenta divergente acreedor con misma cuenta que asociada.
*        P_T_ERROR = 4.
*        RETURN-NUMBER            = '2'.
*        RETURN-MESSAGE           = P_TI_DETALLE-KEY.
*        RETURN-LOG_NO            = P_TI_DETALLE-ITEMNO_ACC.
*        RETURN-TYPE              = 'E'.
*        RETURN-ID                = '01'.
*        RETURN-MESSAGE_V1        = 'El numero de Acreedor  '.
*        RETURN-MESSAGE_V2        = 'no Existe'.
*        RETURN-MESSAGE_V3        = 'Numero de comprobante Externo '.
*        RETURN-MESSAGE_V4        = P_TI_CABECERA-REF_DOC_NO.
*        APPEND RETURN.
*        CLEAR: RETURN.
      ENDIF.
    ENDIF.
  ENDIF.



* Validación 6 - Indicador IVA (TAX_CODE)
  IF p_ti_detalle-tax_code NE space.

    DATA: e_record  LIKE  t001,
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
        return-message           = p_ti_detalle-key.
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
         v_cskb LIKE  cskbv.

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
      return-message           = p_ti_detalle-key.
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
          return-message           = p_ti_detalle-key.
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
*        P_T_ERROR = 4.
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
      return-message           = p_ti_detalle-key.
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
          return-message           = p_ti_detalle-key.
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
        return-message           = p_ti_detalle-key.
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
        return-message           = p_ti_detalle-key.
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

    DATA: e_record1  LIKE  t001,
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
      return-message           = p_ti_detalle-key.
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
      return-message           = p_ti_detalle-key.
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
      return-message           = p_ti_detalle-key.
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
      return-message           = p_ti_detalle-key.
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
      return-message           = p_ti_detalle-key.
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
      return-message           = p_ti_detalle-key.
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
      return-message           = p_ti_detalle-key.
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
      return-message           = p_ti_detalle-key.
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
ENDFORM.                    " VAL_DETALLE
*&---------------------------------------------------------------------*
*&      Form  DERTMINA_GL_AP_RR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dertmina_gl_ap_rr .
  DATA: p_index LIKE sy-tabix,
        p_index_v LIKE sy-tabix.
  LOOP AT ti_cont_cab.
    p_index =  sy-tabix.
    LOOP AT ti_cont_det WHERE key EQ ti_cont_cab-key.
      p_index_v = sy-tabix.
* Determina GL.
      IF ti_cont_det-hkont <> space AND
              ti_cont_det-vendor_no EQ space  AND
                         ti_cont_det-customer EQ space.
        MOVE: 'GL' TO ti_cont_det-tipo,
              'GL' TO ti_cont_cab-tipo.
        MODIFY ti_cont_det INDEX p_index_v.
      ENDIF.
* Determina AP
      IF ti_cont_det-hkont <> space AND
              ti_cont_det-vendor_no <> space  AND
                         ti_cont_det-customer EQ space.
        MOVE: 'AP' TO ti_cont_det-tipo,
              'AP' TO ti_cont_cab-tipo.
        MODIFY ti_cont_det INDEX p_index_v.
      ENDIF.
* Determina AR
      IF ti_cont_det-hkont <> space AND
              ti_cont_det-vendor_no EQ space  AND
                         ti_cont_det-customer <> space.
        MOVE: 'AR' TO ti_cont_det-tipo,
              'AR' TO ti_cont_cab-tipo.
        MODIFY ti_cont_det INDEX p_index_v.
      ENDIF.
* Determina iva GL
      IF ti_cont_det-iva EQ 'X'.
        MOVE: 'GL' TO ti_cont_det-tipo,
              'GL' TO ti_cont_cab-tipo.
        MODIFY ti_cont_det INDEX p_index_v.
      ELSEIF ti_cont_det-iva EQ 'S'.
        MOVE: 'AR' TO ti_cont_det-tipo,
              'AR' TO ti_cont_cab-tipo.
        MODIFY ti_cont_det INDEX p_index_v.
      ENDIF.
    ENDLOOP.
    MODIFY    ti_cont_cab INDEX p_index.
  ENDLOOP.
ENDFORM.    " DERTMINA_GL_AP_RR

*&---------------------------------------------------------------------*
*&      Form  CONTABILIZACION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM contabilizacion.
  DATA: v_hkont  LIKE bseg-hkont,
        v_kschl  TYPE kschl,
        v_ktosl LIKE t030k-ktosl.

  CASE ti_cont_det-tipo.
    WHEN 'GL'.
      IF ti_cont_det-iva NE 'X'.
* estructura de Posición Pos.cta.de mayor
        accountgl-itemno_acc  = ti_cont_det-itemno_acc.
        accountgl-gl_account  = ti_cont_det-hkont.
        accountgl-item_text   = ti_cont_det-sgtxt.
        accountgl-tax_code    = ti_cont_det-tax_code.
        accountgl-costcenter  = ti_cont_det-costcenter.
        accountgl-profit_ctr  = ti_cont_det-profit_ctr.
        accountgl-alloc_nmbr  = ti_cont_det-alloc_nmbr.
        accountgl-ref_key_1   = ti_cont_det-ref_key_1.
        accountgl-ref_key_2   = ti_cont_det-ref_key_2.
        accountgl-ref_key_3   = ti_cont_det-ref_key_3.
        accountgl-orderid     = ti_cont_det-aufnr.
*        Modificacion Herman Rosales Fecha Valor 08/02/2011
        MOVE ti_cont_det-bline_date TO accountgl-value_date.
*        Fin Modificacion

        APPEND accountgl.
        CLEAR: accountgl.
      ELSE.

        DATA: p_amt_base LIKE ti_cont_det-amt_base.
        p_amt_base = ti_cont_det-amt_base.
        PERFORM steuerbasis_fw_rechnen CHANGING ti_cont_det-amt_base
                                                v_hkont
                                                v_kschl
                                                v_ktosl.

*       Inicio
*       LSC - 11.10.2011 - Ajuste para el calculo del neto en el registro de IVA
        DATA: vl_reg_det LIKE zdetalle.
        p_amt_base = 0.
        LOOP AT ti_cont_det INTO vl_reg_det WHERE tipo EQ 'GL' AND iva NE 'X' .
          p_amt_base = p_amt_base + vl_reg_det-amt_doccur.
        ENDLOOP.

*       FIN LSC - 11.10.2011
        IF p_amt_base EQ 0.
          currencyamount-amt_base   = ti_cont_det-amt_base.
        ELSE.
          ti_cont_det-amt_base = p_amt_base.
          currencyamount-amt_base   = p_amt_base.
          p_amt_base = 0.
        ENDIF.
*        IF TI_CONT_DET-AMT_DOCCUR  eq 0.
*        CURRENCYAMOUNT-AMT_BASE   = TI_CONT_DET-AMT_BASE.
*        ELSE.
*          CURRENCYAMOUNT-AMT_BASE   = TI_CONT_DET-AMT_DOCCUR.
*        ENDIF.

        accounttax-itemno_acc     = ti_cont_det-itemno_acc.
        accounttax-cond_key       = v_kschl.
        accounttax-tax_code       = ti_cont_det-tax_code.
        accounttax-gl_account     = v_hkont.
        IF ti_cont_det-tax_code = 'C6'.
          accounttax-acct_key = v_ktosl.
        ENDIF.
*        accounttax-direct_tax     = 'X'."JOROZCO 21.01.2020
        APPEND accounttax.
        CLEAR: accounttax.
      ENDIF.
    WHEN 'AP'.
* Estructura de Posición Acreedor
      accountpayable-itemno_acc = ti_cont_det-itemno_acc.
      accountpayable-vendor_no  = ti_cont_det-vendor_no.
      accountpayable-gl_account = ti_cont_det-hkont.
      accountpayable-item_text  = ti_cont_det-sgtxt.
      accountpayable-tax_code   = ti_cont_det-tax_code.
      accountpayable-pmnttrms   = ti_cont_det-pmnttrms.
      accountpayable-bline_date = ti_cont_det-bline_date.
      accountpayable-pymt_meth  = ti_cont_det-pymt_meth.
      accountpayable-pmnt_block = ti_cont_det-pmnt_block.
      accountpayable-alloc_nmbr = ti_cont_det-alloc_nmbr.
      accountpayable-ref_key_1  = ti_cont_det-ref_key_1.
      accountpayable-ref_key_2  = ti_cont_det-ref_key_2.
      accountpayable-ref_key_3  = ti_cont_det-ref_key_3.
      accountpayable-alt_payee  = ti_cont_det-alt_payee.
      accountpayable-bank_id      = ti_cont_det-bank_id.
      accountpayable-housebankacctid = ti_cont_det-hktid.
      APPEND accountpayable.
      CLEAR: accountpayable.
      IF ti_cont_det-wt_type <> space AND
                                         ti_cont_det-wt_code  <> space.
        accountwt-itemno_acc = ti_cont_det-itemno_acc.
*        ACCOUNTWT-WT_TYPE    = TI_CONT_DET-WT_TYPE.
*        ACCOUNTWT-WT_CODE    = TI_CONT_DET-WT_CODE.
        accountwt-wt_type    = 'Q1'.
        accountwt-wt_code    = 'B1'.
        APPEND accountwt.
        CLEAR: accountwt.
      ENDIF.
    WHEN 'AR'.
* Estructura de Posición Deudor
      accountreceivable-itemno_acc = ti_cont_det-itemno_acc.
      accountreceivable-customer   = ti_cont_det-customer.
      accountreceivable-gl_account = ti_cont_det-hkont.
      accountreceivable-item_text  = ti_cont_det-sgtxt.
      accountreceivable-tax_code   = ti_cont_det-tax_code.
      accountreceivable-pmnttrms   = ti_cont_det-pmnttrms.
      accountreceivable-bline_date = ti_cont_det-bline_date.
      accountreceivable-pymt_meth  = ti_cont_det-pymt_meth.
      accountreceivable-alloc_nmbr = ti_cont_det-alloc_nmbr.
      accountreceivable-ref_key_1  = ti_cont_det-ref_key_1.
      accountreceivable-ref_key_2  = ti_cont_det-ref_key_2.
      accountreceivable-ref_key_3  = ti_cont_det-ref_key_3.
      accountreceivable-bank_id      = ti_cont_det-bank_id.
      accountreceivable-housebankacctid	= ti_cont_det-hktid.
      IF ti_cont_det-iva = 'S'.
        accountreceivable-sp_gl_ind = ti_cont_det-iva.

      ENDIF.
      APPEND accountreceivable.
      CLEAR: accountreceivable.
  ENDCASE.
* Estructura Posiciones Moneda
  currencyamount-itemno_acc = ti_cont_det-itemno_acc.
  currencyamount-amt_doccur = ti_cont_det-amt_doccur.
  currencyamount-currency   = ti_cont_det-currency.
  APPEND currencyamount.
  CLEAR:  currencyamount.
* Estructura de Extencion para Atributos de Cuentas.
  CONCATENATE ti_cont_det-itemno_acc
              ti_cont_det-zzprestac
              ti_cont_det-zzunid_pro
              ti_cont_det-zzdesc_est
              ti_cont_det-zzmot_emis
              ti_cont_det-zzrut_terc
              ti_cont_det-zz_agencia
              ti_cont_det-fdlev
              ti_cont_det-atributo_8
              ti_cont_cab-area_contab
              ti_cont_det-costcenter
              INTO extension1-field1 SEPARATED BY ';'.
  APPEND extension1.
  CLEAR: extension1.

ENDFORM.                    " CONTABILIZACION
*&---------------------------------------------------------------------*
*&      Form  EJECUTA_BAPI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ejecuta_bapi TABLES  return STRUCTURE bapiret2
                          p_ti_resumen    STRUCTURE zresumen
                  USING   contador.

  DATA: lv_contador TYPE i. "JOROZCO 27.01.2020

* LLena Datos de Cabecera BAPI BAPI_ACC_DOCUMENT_POST
  REFRESH: documentheader.
  CLEAR: documentheader.
  documentheader-username  =  ti_cont_cab-username.
  documentheader-header_txt = ti_cont_cab-header_txt.
  documentheader-comp_code  = ti_cont_cab-comp_code.
  documentheader-doc_date   = ti_cont_cab-doc_date.
  documentheader-pstng_date = ti_cont_cab-pstng_date.
  documentheader-fisc_year  = ti_cont_cab-pstng_date+0(4).
  documentheader-fis_period = ti_cont_cab-pstng_date+4(2).
  documentheader-doc_type   = ti_cont_cab-doc_type.
  documentheader-ref_doc_no = ti_cont_cab-ref_doc_no.
  APPEND documentheader.

*  INI --------------------------------------------- JOROZCO 27.01.2020
  LOOP AT accounttax ASSIGNING FIELD-SYMBOL(<ls_accountax>)
    WHERE tax_code EQ 'C9'.
    lv_contador = lv_contador + 1.
    IF lv_contador GT 1.
      <ls_accountax>-direct_tax = abap_true.
    ENDIF.
  ENDLOOP.
*  FIN --------------------------------------------- JOROZCO 27.01.2020

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST' "#EC CI_USAGE_OK[2438131]
    EXPORTING
      documentheader    = documentheader
    TABLES
      accountgl         = accountgl
      accountreceivable = accountreceivable
      accountpayable    = accountpayable
      accounttax        = accounttax
      currencyamount    = currencyamount
      extension1        = extension1
      accountwt         = accountwt
      return            = return2.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  DATA: error TYPE sy-subrc.
* Traspasa log de ejecucioón de BAPI BAPI_ACC_DOCUMENT_POST
  LOOP AT   return2.
    MOVE-CORRESPONDING return2 TO return.
    return-field  = ti_cont_cab-key.
    APPEND return.
    IF return2-type EQ 'E'.
      error = 4.
    ENDIF.
  ENDLOOP.
* Traspaso datos de ejecucion de bapi a estructura de resumen.
  IF error EQ 4.
    MOVE: ti_cont_cab-key TO  p_ti_resumen-key,
          ti_cont_cab-ref_doc_no TO  p_ti_resumen-ref.

    WRITE contador TO p_ti_resumen-con_pos.
    p_ti_resumen-estado = '3'.
    APPEND  p_ti_resumen.
    CLEAR: p_ti_resumen.
  ELSE.

    READ TABLE return2 WITH KEY type = 'S'
                                number = 605.

    MOVE: ti_cont_cab-key TO  p_ti_resumen-key,
             ti_cont_cab-ref_doc_no TO  p_ti_resumen-ref.
    WRITE contador TO p_ti_resumen-con_pos.
    p_ti_resumen-n_sap = return2-message_v2+0(10).
    p_ti_resumen-estado = '0'.
    APPEND  p_ti_resumen.
    CLEAR: p_ti_resumen.
  ENDIF.

  REFRESH: return2, currencyamount, accountpayable, accountreceivable, accountgl, documentheader, currencyamount, extension1,
           accountwt, accounttax.
ENDFORM.                    " EJECUTA_BAPI

*---------------------------------------------------------------------*
*       RUTINA                                                        *
*---------------------------------------------------------------------*
*        Rechnen Steuerbasisbetrag mit MWSKZ, T007A.                  *
*---------------------------------------------------------------------*
FORM steuerbasis_fw_rechnen CHANGING ti_cont_det-amt_base
                                     v_hkont
                                     v_kschl
                                     v_ktosl.
  DATA: taxcom LIKE taxcom.
  DATA:   hfwnaf       LIKE bsez-fwnaf,
          refe1(16)    TYPE p,
          refe2(16)    TYPE p,
          xfwnaf       LIKE bsez-fwnaf,
          xhwbas       LIKE bset-hwbas,
          xdmbtr       LIKE bseg-dmbtr,
          xmwsts       LIKE bseg-mwsts,
          xanz(1)      TYPE c,
          xkurs        LIKE bkpf-kursf,
          xkzinc(1)    TYPE c,
          xmwst(1)     TYPE c,
          xpruef(1)    TYPE c,
          xwwert       LIKE bkpf-wwert.
  DATA:   tkurs        LIKE bkpf-txkrs.
  DATA: v_fwnaf LIKE bsez-fwnaf.

  taxcom-bukrs = ti_cont_cab-comp_code.
  taxcom-budat = ti_cont_cab-pstng_date.
  taxcom-waers = ti_cont_det-currency.
  taxcom-kposn = ti_cont_det-itemno_acc.
  taxcom-mwskz = ti_cont_det-tax_code.

  taxcom-koart = 'S'.
  IF ti_cont_det-amt_doccur > 0.
    taxcom-shkzg = 'S'.
  ELSE.
    taxcom-shkzg = 'H'.
  ENDIF.
  taxcom-wrbtr = 9000000000.    " MMT   one Zero deleted
  taxcom-wmwst = 0.
  taxcom-wskto = 0.
  taxcom-skfbt = 0.
  taxcom-zbd1p = 0.
  taxcom-xmwst = 'X'.
  xpruef = space.
  DATA: v_fwbas LIKE bseg-fwbas.

  CALL FUNCTION 'CALCULATE_TAX_ITEM'
    EXPORTING
      dialog              = space
      inklusive           = 'X'
      i_taxcom            = taxcom
      pruefen             = xpruef
      reset               = space
    IMPORTING
      e_taxcom            = taxcom
      nav_anteil          = v_fwnaf
    EXCEPTIONS
      mwskz_not_found     = 04
      mwskz_not_defined   = 04
      steuerbetrag_falsch = 08.
  CASE sy-subrc.
    WHEN 04.
*      MESSAGE E201 WITH BSEG-MWSKZ T001-LAND1.
    WHEN 08.
  ENDCASE.

  taxcom-wrbtr = taxcom-wrbtr - taxcom-wmwst.
  refe1 = ti_cont_det-amt_doccur * taxcom-wrbtr.
  v_fwbas = refe1 / taxcom-wmwst.

  ti_cont_det-amt_base =  v_fwbas.
* Busca KONV
  CALL FUNCTION 'CALCULATE_TAX_ITEM'
    EXPORTING
      dialog     = space
      inklusive  = 'X'
      i_taxcom   = taxcom
      pruefen    = xpruef
      reset      = 'X'
    IMPORTING
      e_taxcom   = taxcom
      nav_anteil = v_fwnaf.

  DATA: v_i_wrbtr  LIKE bseg-wrbtr.
  v_i_wrbtr = ti_cont_det-amt_base.

  CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
    EXPORTING
      i_bukrs           = ti_cont_cab-comp_code
      i_mwskz           = ti_cont_det-tax_code
      i_waers           = ti_cont_det-currency
      i_wrbtr           = v_i_wrbtr
    TABLES
      t_mwdat           = t_mwdat
    EXCEPTIONS
      bukrs_not_found   = 1
      country_not_found = 2
      mwskz_not_defined = 3
      mwskz_not_valid   = 4
      ktosl_not_found   = 5
      kalsm_not_found   = 6
      parameter_error   = 7
      knumh_not_found   = 8
      kschl_not_found   = 9
      unknown_error     = 10
      account_not_found = 11
      txjcd_not_valid   = 12
      OTHERS            = 13.
  IF sy-subrc = 0.
    READ TABLE t_mwdat INDEX 1.
    IF sy-subrc EQ 0.
      v_hkont =   t_mwdat-hkont.
      v_kschl =  t_mwdat-kschl.
      v_ktosl = t_mwdat-ktosl.
    ENDIF.
  ENDIF.
ENDFORM.                    "STEUERBASIS_FW_RECHNEN
*&---------------------------------------------------------------------*
*&      Form  PROECESA_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TI_ERROR_CAB  text
*      -->P_TI_ERROR_DET  text
*      -->P_TI_CONT_CAB  text
*      -->P_TI_CONT_DET  text
*----------------------------------------------------------------------*
FORM proecesa_error  TABLES   p_ti_error_cab  STRUCTURE ti_error_cab
                              p_ti_error_det  STRUCTURE ti_error_det
                              p_ti_cont_cab   STRUCTURE ti_cont_cab
                              p_ti_cont_det   STRUCTURE ti_cont_det
                              p_ti_tlogcaberr STRUCTURE ztlogcaberr
                              p_ti_tlogdeterr STRUCTURE ztlogdeterr
                              p_ti_resumen    STRUCTURE zresumen
                              return          STRUCTURE bapiret2
                              ti_detalle      STRUCTURE zdetalle.




  DATA: BEGIN OF error_det OCCURS 0.
          INCLUDE STRUCTURE zdetalle.
  DATA: END OF   error_det.

  DATA: BEGIN OF error_cab OCCURS 0.
          INCLUDE STRUCTURE ti_cont_cab.
  DATA: END OF   error_cab.

  DATA: p_index LIKE sy-tabix.

  LOOP AT p_ti_error_cab.
    LOOP AT p_ti_cont_det WHERE key EQ p_ti_error_cab-key.
      p_index = sy-tabix.
      MOVE-CORRESPONDING p_ti_cont_det TO error_det.
      APPEND error_det.
      DELETE p_ti_cont_det INDEX p_index.
    ENDLOOP.
  ENDLOOP.

  LOOP AT error_det.
    READ TABLE p_ti_error_det WITH KEY key = error_det-key.
    IF sy-subrc NE 0.
      MOVE-CORRESPONDING error_det TO p_ti_error_det.
      APPEND p_ti_error_det.
    ENDIF.
  ENDLOOP.


  LOOP AT p_ti_error_det.
    LOOP AT p_ti_cont_cab WHERE key = p_ti_error_det-key.
      p_index = sy-tabix.
      MOVE-CORRESPONDING p_ti_cont_cab TO error_cab.
      APPEND error_cab.
      DELETE p_ti_cont_cab INDEX p_index.
    ENDLOOP.
  ENDLOOP.


  LOOP AT error_cab.
    READ TABLE p_ti_error_cab WITH KEY key = error_cab-key.
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
      CONCATENATE return-message_v1 return-message_v2 return-message_v3    return-message_v4  INTO  p_ti_tlogcaberr-descripcion SEPARATED BY space.
      APPEND p_ti_tlogcaberr.
    ELSE.
      IF return-number  EQ 2.
        MOVE:
              return-message+0(6)   TO p_ti_tlogdeterr-key,
              return-log_no+0(3) TO p_ti_tlogdeterr-posic,
              return-number  TO p_ti_tlogdeterr-cod_err.
        CONCATENATE return-message_v1 return-message_v2 return-message_v3  return-message_v4  INTO p_ti_tlogdeterr-descripcion SEPARATED BY space.
        APPEND p_ti_tlogdeterr.
      ENDIF.
    ENDIF.
  ENDLOOP.



* Ingresa los datos a la estructura P_TI_RESUMEN.
  LOOP  AT p_ti_error_cab.
    LOOP AT ti_detalle WHERE key EQ p_ti_error_cab-key.
      ADD 1 TO  p_ti_resumen-con_pos.
    ENDLOOP.
    MOVE: p_ti_error_cab-key TO  p_ti_resumen-key,
          p_ti_error_cab-ref_doc_no TO  p_ti_resumen-ref.

    READ TABLE return WITH KEY  message+0(6) = p_ti_error_cab-key
                                number = 1.
    IF sy-subrc EQ 0.
      p_ti_resumen-estado = '1'.
    ELSE.
      READ TABLE return WITH KEY  message+0(6) = p_ti_error_cab-key
                                  number = 2.
      IF sy-subrc EQ 0.
        p_ti_resumen-estado = '2'.
      ENDIF.
    ENDIF.
    APPEND p_ti_resumen.
    CLEAR: p_ti_resumen.
  ENDLOOP.
ENDFORM.                    " PROECESA_ERROR
