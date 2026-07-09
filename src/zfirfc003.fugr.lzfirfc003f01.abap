*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LZFIRFC003F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CREA_ACREEDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RETURN  text
*      -->P_T_DEUDOR  text
*----------------------------------------------------------------------*
FORM crea_acreedor  TABLES  return STRUCTURE bapiret2
                   USING   t_acreedor STRUCTURE zacreedor.


  REFRESH: messtab, bdcdata.


  PERFORM bdc_dynpro  USING 'SAPMF02K'           '0105'.
  PERFORM bdc_field   USING 'BDC_CURSOR'         'RF02K-LIFNR'.
  PERFORM bdc_field   USING 'BDC_OKCODE'         '/00'.
  PERFORM bdc_field   USING 'RF02K-BUKRS'        t_acreedor-bukrs.

  IF t_acreedor-lifnr EQ space.
    CLEAR bdcdata.
    bdcdata-fnam = 'RF02K-LIFNR'.
    bdcdata-fval =  t_acreedor-lifnr.
    APPEND bdcdata.
  ELSE.
    PERFORM bdc_field   USING 'RF02K-LIFNR'        t_acreedor-lifnr.
  ENDIF.

  PERFORM bdc_field   USING 'RF02K-KTOKK'        t_acreedor-ktokk.

  IF t_ampli EQ 'N'.
    PERFORM bdc_dynpro  USING 'SAPMF02K'           '0111'.
    PERFORM bdc_field   USING 'BDC_OKCODE'          '=$2OC'.
    PERFORM bdc_field   USING 'ADDR1_DATA-NAME1'  t_acreedor-name1.
    IF t_acreedor-name2 IS INITIAL.
      t_acreedor-name2 = '  '.
    ENDIF.
    PERFORM bdc_field   USING 'ADDR1_DATA-NAME2'  t_acreedor-name2.
    PERFORM bdc_field   USING 'ADDR1_DATA-SORT1'   t_acreedor-sort1.
    PERFORM bdc_field   USING 'ADDR1_DATA-COUNTRY' 'CL'.

    PERFORM bdc_dynpro  USING 'SAPMF02K'                 '0111'.
    PERFORM bdc_field   USING 'BDC_OKCODE'               '=VW'.
    PERFORM bdc_field   USING 'SZA1_D0100-TITLE_MEDI'    t_acreedor-title.
    PERFORM bdc_field   USING 'ADDR1_DATA-NAME1'         t_acreedor-name1.
    IF t_acreedor-name2 IS INITIAL.
      t_acreedor-name2 = '  '.
    ENDIF.
    PERFORM bdc_field   USING 'ADDR1_DATA-NAME2'         t_acreedor-name2.
    PERFORM bdc_field   USING 'ADDR1_DATA-SORT1'         t_acreedor-sort1.
    PERFORM bdc_field   USING 'ADDR1_DATA-SORT2'         t_acreedor-sort2.
    PERFORM bdc_field   USING 'ADDR1_DATA-STREET'        t_acreedor-street.
    PERFORM bdc_field   USING 'ADDR1_DATA-HOUSE_NUM1'    t_acreedor-house_num1.
    PERFORM bdc_field   USING 'ADDR1_DATA-CITY2'         t_acreedor-ort02.
    PERFORM bdc_field   USING 'ADDR1_DATA-CITY1'         t_acreedor-ort01.
    PERFORM bdc_field   USING 'ADDR1_DATA-COUNTRY'       t_acreedor-land1.
    PERFORM bdc_field   USING 'ADDR1_DATA-PO_BOX'        t_acreedor-po_box.
    PERFORM bdc_field   USING 'ADDR1_DATA-LANGU'         sy-langu.
    PERFORM bdc_field   USING 'SZA1_D0100-TEL_NUMBER'    t_acreedor-tel_number.
    PERFORM bdc_field   USING 'SZA1_D0100-TEL_EXTENS'    t_acreedor-tel1_ext.
    PERFORM bdc_field   USING 'SZA1_D0100-FAX_NUMBER'    t_acreedor-telfax.
    PERFORM bdc_field   USING 'SZA1_D0100-FAX_EXTENS'    t_acreedor-fax_extens.
    PERFORM bdc_field   USING 'SZA1_D0100-SMTP_ADDR'     t_acreedor-smtp_addr.

    PERFORM bdc_dynpro  USING 'SAPMF02K'                  '0120'.
    PERFORM bdc_field   USING 'BDC_CURSOR'                'LFA1-STCD1'.
    PERFORM bdc_field   USING 'BDC_OKCODE'                '/00'.
    PERFORM bdc_field   USING 'LFA1-KUNNR'                t_acreedor-kunnr.
    PERFORM bdc_field   USING 'LFA1-STCD1'                t_acreedor-stcd1.


    PERFORM bdc_dynpro      USING 'SAPMF02K'    '0130'.
    PERFORM bdc_field       USING 'BDC_CURSOR'  'LFBK-BKONT(01)'.
    IF  t_acreedor-empfk = space.
      PERFORM bdc_field       USING 'BDC_OKCODE' '=VW'.
    ELSE.
      PERFORM bdc_field       USING 'BDC_OKCODE' '=LFZA'.
    ENDIF.
** modif por art 15-01-2014 seidor***
    IF t_acreedor-banks IS NOT INITIAL AND t_acreedor-bankl IS NOT INITIAL AND t_acreedor-bankn IS NOT INITIAL.
      PERFORM bdc_field       USING 'LFBK-BANKS(01)'  t_acreedor-banks.
      PERFORM bdc_field       USING 'LFBK-BANKL(01)'  t_acreedor-bankl.
      PERFORM bdc_field       USING 'LFBK-BANKN(01)'  t_acreedor-bankn.
      PERFORM bdc_field       USING 'LFBK-KOINH(01)'  t_acreedor-koinh.
      PERFORM bdc_field       USING 'LFBK-BKONT(01)'  t_acreedor-bkont.
*-> BEG INS V1-CNN ECDK926773 30.09.2025
      PERFORM bdc_field       USING 'LFBK-BVTYP(01)'  t_acreedor-bvtyp.
      PERFORM bdc_field       USING 'LFBK-BKREF(01)'  t_acreedor-bkref.
*-> END INS V1-CNN ECDK926773 30.09.2025

    ENDIF.
*** fin modif  art *******
    IF  t_acreedor-empfk <> space.
      PERFORM bdc_dynpro      USING 'SAPMF02K'         '1130'.
      PERFORM bdc_field       USING 'BDC_OKCODE'       '=BACK'.
      PERFORM bdc_field       USING 'LFZA-EMPFK(01)'  t_acreedor-empfk.
      PERFORM bdc_dynpro      USING 'SAPMF02K'         '0130'.
      PERFORM bdc_field       USING 'BDC_CURSOR'       'LFBK-BKONT(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'       '=VW'.
    ENDIF.
  ENDIF.

  PERFORM bdc_dynpro  USING 'SAPMF02K'                  '0210'.
  PERFORM bdc_field   USING 'BDC_CURSOR'                'LFB1-ZUAWA'.
  PERFORM bdc_field   USING 'BDC_OKCODE'                '/00'.
  PERFORM bdc_field   USING 'LFB1-AKONT'                t_acreedor-akont.
  PERFORM bdc_field   USING 'LFB1-FDGRV'                t_acreedor-fdgrv.
  PERFORM bdc_field   USING 'LFB1-ZUAWA'                t_acreedor-zuawa.

  PERFORM bdc_dynpro  USING 'SAPMF02K'                  '0215'.
  PERFORM bdc_field   USING 'BDC_CURSOR'                'LFB1-ZAHLS'.
  PERFORM bdc_field   USING 'BDC_OKCODE'                '/00'.
  PERFORM bdc_field   USING 'LFB1-ZTERM'                t_acreedor-zterm1.
  PERFORM bdc_field   USING 'LFB1-REPRF'                'X'. "Factura Doble Acreedores.
  IF t_acreedor-bukrs EQ 'CL01' OR t_acreedor-bukrs EQ 'CL24'.
    t_acreedor-zgrup = 'Z1'.
  ENDIF.
  PERFORM bdc_field   USING 'LFB1-ZGRUP'                t_acreedor-zgrup.
  PERFORM bdc_field   USING 'LFB1-TOGRU'                'KRE1'.
  PERFORM bdc_field   USING 'LFB1-ZWELS'                t_acreedor-zwels.
  PERFORM bdc_field   USING 'LFB1-ZAHLS'                t_acreedor-zahls.

  PERFORM bdc_dynpro  USING 'SAPMF02K'                  '0220'.
  PERFORM bdc_field   USING 'BDC_CURSOR'                'LFB5-MAHNA'.
  PERFORM bdc_field   USING 'BDC_OKCODE'                '/00'.

  PERFORM bdc_dynpro  USING 'SAPMF02K'                  '0610'.
  PERFORM bdc_field   USING 'BDC_OKCODE'                '=UPDA'.
  PERFORM bdc_field   USING 'BDC_CURSOR'                'LFB1-QLAND'.
  PERFORM bdc_field   USING 'LFB1-QLAND'                t_acreedor-land1.
*  PERFORM BDC_FIELD   USING 'LFBW-WITHT(01)'            'Q1'.
*  PERFORM BDC_FIELD   USING 'LFBW-WT_WITHCD(01)'        'B2'.
  PERFORM bdc_field   USING 'LFBW-WITHT(01)'            t_acreedor-witht.
  PERFORM bdc_field   USING 'LFBW-WT_WITHCD(01)'        t_acreedor-wt_withcd.
  PERFORM bdc_field   USING 'LFBW-WT_SUBJCT(01)'        'X'.


  DATA: ctumode LIKE ctu_params-dismode VALUE 'N'.
  DATA: cupdate LIKE ctu_params-updmode VALUE 'L'.
  DATA opt TYPE ctu_params.
  opt-nobinpt = 'X'.
  opt-dismode = ctumode.
  opt-updmode = cupdate.

  CALL TRANSACTION 'FK01' USING bdcdata
                    OPTIONS FROM opt
                   MESSAGES INTO messtab.



  DATA: BEGIN OF itlog OCCURS 0,
          texto(100),
        END OF itlog.

  DATA: v_texto LIKE t100-text,
        v_msgid LIKE sy-msgid,
        v_msgno LIKE sy-msgno,
        v_msgv1 LIKE sy-msgv1,
        v_msgv2 LIKE sy-msgv2,
        v_msgv3 LIKE sy-msgv3,
        v_msgv4 LIKE sy-msgv4.

  LOOP AT messtab WHERE msgid NE 'I'.

    v_msgid = messtab-msgid.
    v_msgno = messtab-msgnr.
    v_msgv1 = messtab-msgv1.
    v_msgv2 = messtab-msgv2.
    v_msgv3 = messtab-msgv3.
    v_msgv4 = messtab-msgv4.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE text
*      INTO  v_texto
*       FROM t100 WHERE sprsl = sy-langu
*                   AND arbgb = v_msgid
*                   AND msgnr = v_msgno.
*
* NEW CODE
    SELECT text
    UP TO 1 ROWS 
      INTO  v_texto
       FROM t100 WHERE sprsl = sy-langu
                   AND arbgb = v_msgid
                   AND msgnr = v_msgno ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      DATA:
        maximum_length TYPE i,
        hlp_text(100)  TYPE c,
        msgv_no(1)     TYPE c,
        offset         TYPE i,
        index          TYPE i,
        strl           LIKE sy-fdpos,
        p_fdpos        LIKE sy-fdpos.

      DESCRIBE FIELD v_texto LENGTH maximum_length IN CHARACTER MODE.
      hlp_text = v_texto.
      CLEAR v_texto.

      offset = 0.
      DO 4 TIMES.
        SEARCH hlp_text FOR '&'.
        IF sy-subrc <> 0. EXIT. ENDIF.
        IF sy-fdpos <> 0.
          CHECK offset < maximum_length.
          MOVE hlp_text(sy-fdpos) TO v_texto+offset.
          offset = offset + sy-fdpos.
        ENDIF.
        index = sy-fdpos + 1.
        SHIFT hlp_text BY index PLACES LEFT.
        p_fdpos  = sy-fdpos.
        IF hlp_text(1) CO '1234'.
          msgv_no = hlp_text(1).
          SHIFT hlp_text BY 1 PLACES LEFT.
        ELSE.
          msgv_no = sy-index.
        ENDIF.
        CHECK offset < maximum_length.
        CASE msgv_no.
          WHEN 1.
            WRITE v_msgv1 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv1 ).

          WHEN 2.
            WRITE v_msgv2 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv2 ).
          WHEN 3.
            WRITE v_msgv3 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv3 ).
          WHEN 4.
            WRITE v_msgv4 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv4 ).
        ENDCASE.
        offset = offset + strl.
      ENDDO.

      IF offset < maximum_length.
        sy-fdpos = strlen( hlp_text ).
        IF sy-fdpos <> 0.
          MOVE hlp_text(sy-fdpos) TO v_texto+offset.
        ENDIF.
      ENDIF.

      return-message_v1 = messtab-msgv1.
      return-message_v2 = v_texto+0(50).
      return-message_v3 = v_texto+50(13).

      return-type              = messtab-msgtyp.
      return-id                = '01'.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CREA_ACREEDOR


*&---------------------------------------------------------------------*
*&      Form  VALIDA_ACREEDOR
*&---------------------------------------------------------------------*
FORM valida_acreedor  TABLES  return STRUCTURE bapiret2
                      USING    p_ti_acreedor STRUCTURE zacreedor
                      CHANGING p_t_error
                               p_t_ampli.

* Validacion Grupo de ctas. Deudor (KTOKD) y ID de cliente (KUNNR)
  DATA: p_ktokd     LIKE t077d-ktokd,
        p_numkr     LIKE nriv-nrrangenr,
        p_externind LIKE nriv-externind.
  DATA: e_valid(1) TYPE c.

  DATA: o_t077d  LIKE  t077d OCCURS 0 WITH HEADER LINE.
  DATA: interval LIKE  nriv OCCURS 0 WITH HEADER LINE.
  DATA: es_lfa1 LIKE  lfa1.
  DATA: es_lfb1 LIKE  lfb1.


  IF p_ti_acreedor-lifnr NE space.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p_ti_acreedor-lifnr
      IMPORTING
        output = p_ti_acreedor-lifnr.


    CALL FUNCTION 'LFA1_READ_SINGLE'
      EXPORTING
        id_lifnr            = p_ti_acreedor-lifnr
      IMPORTING
        es_lfa1             = es_lfa1
      EXCEPTIONS
        not_found           = 1
        input_not_specified = 2
        OTHERS              = 3.
    IF sy-subrc = 0.
      p_ti_acreedor-ktokk = es_lfa1-ktokk.
      p_ti_acreedor-land1 = es_lfa1-land1.
      p_ti_acreedor-stcd1 = es_lfa1-stcd1.

      CALL FUNCTION 'LFB1_READ_SINGLE'
        EXPORTING
          id_lifnr            = p_ti_acreedor-lifnr
          id_bukrs            = p_ti_acreedor-bukrs
        IMPORTING
          es_lfb1             = es_lfb1
        EXCEPTIONS
          not_found           = 1
          input_not_specified = 2
          OTHERS              = 3.
      IF sy-subrc <> 0.
        t_ampli = 'S'.
      ELSE.
        p_t_error = 4.
        return-type              = 'E'.
        return-id                = '01'.
        return-message_v1        = 'Acreedor'.
        return-message_v2        = p_ti_acreedor-lifnr.
        return-message_v3        = ' Ya existe en la Sociedad '.
        return-message_v4        = p_ti_acreedor-bukrs.
        APPEND return.
      ENDIF.
    ELSE.
      t_ampli = 'N'.
    ENDIF.
  ELSE.
    t_ampli = 'N'.
  ENDIF.

  IF es_lfa1-ktokk EQ space.
    DATA:  numkr LIKE t077k-numkr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE numkr INTO numkr
*    FROM t077k
*    WHERE ktokk  EQ p_ti_acreedor-ktokk.
*
* NEW CODE
    SELECT numkr
    UP TO 1 ROWS  INTO numkr
    FROM t077k
    WHERE ktokk  EQ p_ti_acreedor-ktokk ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc =  0.
      CALL FUNCTION 'NUMBER_GET_INFO'
        EXPORTING
          nr_range_nr        = numkr
          object             = 'KREDITOR'
        IMPORTING
          interval           = interval
        EXCEPTIONS
          interval_not_found = 1
          object_not_found   = 2
          OTHERS             = 3.
      IF sy-subrc EQ 0.
        IF interval-externind EQ space.
          IF   p_ti_acreedor-lifnr NE space.
            p_t_error = 4.
            return-type              = 'E'.
            return-id                = '01'.
            return-message_v1        = 'La asignación  del Acreedor'.
            return-message_v2        = ' debe ser interna'.
            APPEND return.
          ENDIF.
        ELSE.
          IF interval-externind EQ 'X'.
            IF p_ti_acreedor-lifnr  >= interval-fromnumber  AND
                p_ti_acreedor-lifnr <= interval-tonumber.
              CALL FUNCTION 'FI_VENDOR_CHECK'
                EXPORTING
                  i_bukrs = ' '
                  i_lifnr = p_ti_acreedor-lifnr
                EXCEPTIONS
                  vendor  = 1
                  OTHERS  = 2.
              IF sy-subrc = 0.
                p_t_error = 4.
                return-type              = 'E'.
                return-id                = '02'.
                return-message_v1        = 'El Numero de Acreedor '.
                return-message_v2        = p_ti_acreedor-lifnr.
                return-message_v3        = 'ya Existe'.
                APPEND return.
              ENDIF.
            ELSE.
              p_t_error = 4.
* error grupo de cuentas no existe.
              return-type              = 'E'.
              return-id                = '03'.
              return-message_v1        = 'El Grupo de Cuenteas '.
              return-message_v2        = p_ti_acreedor-ktokk.
              return-message_v3        = ' NO Existe'.
              APPEND return.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        p_t_error = 4.
* error grupo de cuentas no existe.
        return-type              = 'E'.
        return-id                = '03'.
        return-message_v1        = 'El Grupo de Cuenteas '.
        return-message_v2        = p_ti_acreedor-ktokk.
        return-message_v3        = ' NO Existe'.
        APPEND return.
      ENDIF.
    ELSE.
      p_t_error = 4.
* error grupo de cuentas no existe.
      return-type              = 'E'.
      return-id                = '03'.
      return-message_v1        = 'El Grupo de Cuenteas '.
      return-message_v2        = p_ti_acreedor-ktokk.
      return-message_v3        = ' NO Existe'.
      APPEND return.
    ENDIF.
  ENDIF.

* Validación Sociedad (BUKRS)
  CALL FUNCTION 'VALIDATE_COMPANY_CODE'
    EXPORTING
      i_company  = p_ti_acreedor-bukrs
    IMPORTING
      e_valid    = e_valid
    EXCEPTIONS
      incomplete = 1
      OTHERS     = 2.
  IF  e_valid EQ 0.
    p_t_error = 4.
    p_t_error = 4.
    return-type              = 'E'.
    return-id                = '04'.
    return-message_v1        = 'La Sociedad FI'.
    return-message_v2        = p_ti_acreedor-bukrs.
    return-message_v3        = ' NO Existe'.
    APPEND return.
  ENDIF.

  DATA:
    kontenplan_wa        LIKE  ska1 OCCURS 0 WITH HEADER LINE,
    sachkonto_wa         LIKE  skb1 OCCURS 0 WITH HEADER LINE,
    et_duplicate_vendors TYPE vmds_checkdata_vendor_t.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_ti_acreedor-akont
    IMPORTING
      output = p_ti_acreedor-akont.

* Validación Cuenta de mayor (AKONT)
  CALL FUNCTION 'READ_HAUPTBUCH'
    EXPORTING
      buchungskreis        = p_ti_acreedor-bukrs
      sachkonto            = p_ti_acreedor-akont
      auth_check_activity  = ' '
    IMPORTING
      kontenplan_wa        = kontenplan_wa
      sachkonto_wa         = sachkonto_wa
    EXCEPTIONS
      kontenplan_not_found = 1
      sachkonto_not_found  = 2
      not_authorized       = 3
      OTHERS               = 4.
  IF sy-subrc = 0.
    READ TABLE sachkonto_wa INDEX 1.
    IF sy-subrc EQ 0.
      IF sachkonto_wa-mitkz NE  'D'.
        p_t_error = 4.
        return-type              = 'E'.
        return-id                = '05'.
        return-message_v1        = 'La cuenta de Mayor'.
        return-message_v2        =  p_ti_acreedor-akont.
        return-message_v3        = ' no asociada'.
        APPEND return.
      ENDIF.
    ENDIF.
  ENDIF.

  IF p_ti_acreedor-title NE space.
    CALL FUNCTION 'ADDR_TSAD3_READ'
      EXPORTING
        title_key           = p_ti_acreedor-title
      EXCEPTIONS
        title_key_not_found = 1
        OTHERS              = 2.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-type              = 'E'.
      return-id                = '06'.
      return-message_v1        = 'El Tratamiento '.
      return-message_v2        =  p_ti_acreedor-title.
      return-message_v3        = ' NO existe'.
      APPEND return.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'FSBP_CHECK_COUNTRY'
    EXPORTING
      country = p_ti_acreedor-land1
    EXCEPTIONS
      country = 1
      OTHERS  = 2.
  IF sy-subrc <> 0.
    p_t_error = 4.
    return-type              = 'E'.
    return-id                = '07'.
    return-message_v1        = 'El Pais ingresado'.
    return-message_v2        =   p_ti_acreedor-land1.
    return-message_v3        = ' NO existe'.
    APPEND return.
  ENDIF.

  CALL FUNCTION 'BPAR_C_REGIONALCODE_CHECK'
    EXPORTING
      country      = p_ti_acreedor-land1
      regionalcode = p_ti_acreedor-regio
    EXCEPTIONS
      regionalcode = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    p_t_error = 4.
    return-type              = 'E'.
    return-id                = '08'.
    return-message_v1        = 'La Region ingresada'.
    return-message_v2        =  p_ti_acreedor-regio.
    return-message_v3        = ' NO existe'.
    APPEND return.
  ENDIF.

  IF p_ti_acreedor-kunnr NE space.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = p_ti_acreedor-kunnr
      IMPORTING
        output = p_ti_acreedor-kunnr.

    CALL FUNCTION 'FI_VENDOR_CHECK'
      EXPORTING
        i_bukrs = p_ti_acreedor-bukrs
        i_lifnr = p_ti_acreedor-kunnr
      EXCEPTIONS
        vendor  = 1
        OTHERS  = 2.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-type              = 'E'.
      return-id                = '09'.
      return-message_v1        = 'El Numero de Acreedor'.
      return-message_v2        =  p_ti_acreedor-kunnr.
      return-message_v3        = ' Ya existe'.
      APPEND return.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'TAX_NUMBER_CHECK'
    EXPORTING
      country         = p_ti_acreedor-land1
      tax_code_1      = p_ti_acreedor-stcd1
    EXCEPTIONS
      not_valid       = 1
      different_fprcd = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    p_t_error = 4.
    return-type              = 'E'.
    return-id                = '10'.
    return-message_v1        = 'El R.U.T Ingresado'.
    return-message_v2        =   p_ti_acreedor-stcd1.
    return-message_v3        = ' No es Valido'.
    APPEND return.
  ELSE.
    DATA:  t_kna1 TYPE  lfa1.

    t_kna1-mandt = sy-mandt.
    t_kna1-land1 =  p_ti_acreedor-land1.
    t_kna1-stcd1 =  p_ti_acreedor-stcd1.
    t_kna1-lifnr =  p_ti_acreedor-lifnr.

    DATA: xfeld TYPE xfeld VALUE 'X'.

    CALL FUNCTION 'TAXNUMBER_CHECK_DUPL_VENDOR'
      EXPORTING
        vendor               = t_kna1
        iv_no_dialog         = xfeld
      IMPORTING
        et_duplicate_vendors = et_duplicate_vendors.
    DATA: cont_reg TYPE i.
    DESCRIBE TABLE et_duplicate_vendors LINES  cont_reg.
    IF cont_reg > 0.
      p_t_error = 4.
      p_t_error = 4.
      return-type              = 'E'.
      return-id                = '11'.
      return-message_v1        = 'El R.U.T Ingresado'.
      return-message_v2        =  p_ti_acreedor-stcd1.
      return-message_v3        = 'ya esta registrado'.
      APPEND return.
    ENDIF.
  ENDIF.


  CALL FUNCTION 'TZUN_SINGLE_READ'
    EXPORTING
      i_zuawa   = p_ti_acreedor-zuawa
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
    p_t_error = 4.
    return-type              = 'E'.
    return-id                = '12'.
    return-message_v1        = 'La condicion de Clacificación'.
    return-message_v2        =  p_ti_acreedor-zuawa.
    return-message_v3        = 'No existe o no es Valida'.
    APPEND return.
  ENDIF.


  CALL FUNCTION 'CASH_FORECAST_CHECK_LEVEL_GRP'
    EXPORTING
      fdgrp         = p_ti_acreedor-fdgrv
      koart         = 'K'
    EXCEPTIONS
      group_invalid = 1
      level_invalid = 2
      orign_invalid = 3
      OTHERS        = 4.
  IF sy-subrc <> 0.
    p_t_error = 4.
    return-type             = 'E'.
    return-id                = '14'.
    return-message_v1        = 'El Grupo de tesorería'.
    return-message_v2        =  p_ti_acreedor-fdgrv.
    return-message_v3        = 'No existe o no es Valida'.
    APPEND return.
  ENDIF.


  CALL FUNCTION 'FI_CHECK_ZTERM'
    EXPORTING
      i_zterm       = p_ti_acreedor-zterm1
    EXCEPTIONS
      invalid_zterm = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    p_t_error = 4.
    return-type             = 'E'.
    return-id                = '15'.
    return-message_v1        = 'La Condición de pago'.
    return-message_v2        =  p_ti_acreedor-zterm1.
    return-message_v3        = 'No existe o no es Valida'.
    APPEND return.
  ENDIF.

  DATA: it_t042z LIKE  t042z_key OCCURS 0 WITH HEADER LINE.
  DATA: et_t042z LIKE t042z OCCURS 0 WITH HEADER LINE.
  it_t042z-land1 = p_ti_acreedor-land1.
  it_t042z-zlsch = p_ti_acreedor-zwels+0(1).
  IF it_t042z-zlsch NE space.
    APPEND it_t042z. CLEAR it_t042z.
  ENDIF.
  it_t042z-land1 = p_ti_acreedor-land1.
  it_t042z-zlsch = p_ti_acreedor-zwels+1(1).
  IF it_t042z-zlsch NE space.
    APPEND it_t042z. CLEAR it_t042z.
  ENDIF.
  it_t042z-land1 = p_ti_acreedor-land1.
  it_t042z-zlsch = p_ti_acreedor-zwels+2(1).
  IF it_t042z-zlsch NE space.
    APPEND it_t042z. CLEAR it_t042z.
  ENDIF.
  it_t042z-land1 = p_ti_acreedor-land1.
  it_t042z-zlsch = p_ti_acreedor-zwels+3(1).
  IF it_t042z-zlsch NE space.
    APPEND it_t042z. CLEAR it_t042z.
  ENDIF.
  it_t042z-land1 = p_ti_acreedor-land1.
  it_t042z-zlsch = p_ti_acreedor-zwels+4(1).
  IF it_t042z-zlsch NE space.
    APPEND it_t042z. CLEAR it_t042z.
  ENDIF.
  it_t042z-land1 = p_ti_acreedor-land1.
  it_t042z-zlsch = p_ti_acreedor-zwels+5(1).
  IF it_t042z-zlsch NE space.
    APPEND it_t042z. CLEAR it_t042z.
  ENDIF.
  it_t042z-land1 = p_ti_acreedor-land1.
  it_t042z-zlsch = p_ti_acreedor-zwels+6(1).
  IF it_t042z-zlsch NE space.
    APPEND it_t042z. CLEAR it_t042z.
  ENDIF.
  it_t042z-land1 = p_ti_acreedor-land1.
  it_t042z-zlsch = p_ti_acreedor-zwels+7(1).
  IF it_t042z-zlsch NE space.
    APPEND it_t042z. CLEAR it_t042z.
  ENDIF.
  it_t042z-land1 = p_ti_acreedor-land1.
  it_t042z-zlsch = p_ti_acreedor-zwels+8(1).
  IF it_t042z-zlsch NE space.
    APPEND it_t042z. CLEAR it_t042z.
  ENDIF.
  it_t042z-land1 = p_ti_acreedor-land1.
  it_t042z-zlsch = p_ti_acreedor-zwels+9(1).
  IF it_t042z-zlsch NE space.
    APPEND it_t042z. CLEAR it_t042z.
  ENDIF.
  CALL FUNCTION 'WB2_T042Z_ARRAY_SELECT'
    TABLES
      it_t042z        = it_t042z
      et_t042z        = et_t042z
    EXCEPTIONS
      not_found       = 1
      parameter_error = 2
      OTHERS          = 3.
  IF sy-subrc EQ 0.

    LOOP AT it_t042z.
      READ TABLE et_t042z WITH  KEY zlsch = it_t042z-zlsch
                                     land1 = it_t042z-land1.
      IF sy-subrc NE 0.
        p_t_error = 4.
        return-type             = 'E'.
        return-id                = '17'.
        return-message_v1        = 'La via de pago '.
        return-message_v2        =  it_t042z-zlsch.
        return-message_v3        = 'No existe o no es Valida'.
        APPEND return.
        CLEAR:  return.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF p_ti_acreedor-zgrup NE space.
    DATA: p_zgrup LIKE tzgr-zgrup.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zgrup INTO p_zgrup FROM tzgr
*      WHERE zgrup EQ p_ti_acreedor-zgrup.
*
* NEW CODE
    SELECT zgrup
    UP TO 1 ROWS  INTO p_zgrup FROM tzgr
      WHERE zgrup EQ p_ti_acreedor-zgrup ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      p_t_error = 4.
      return-type             = 'E'.
      return-id                = '18'.
      return-message_v1        = 'Clave de Aprupaciòn '.
      return-message_v2        =  p_ti_acreedor-zgrup.
      return-message_v3        = 'No existe o no es Valida'.
      APPEND return.
      CLEAR:  return.
    ENDIF.
  ENDIF.

ENDFORM.                    " VALIDA_ACREEDOR


*&---------------------------------------------------------------------*
*&      Form  BUSCA_ACREEDOR
*&---------------------------------------------------------------------*
FORM busca_acreedor  TABLES  return STRUCTURE bapiret2
                        USING    p_ti_acreedor STRUCTURE zacreedor
                        CHANGING p_t_error.

  DATA: creditor_general_detail LIKE  lfa1,
        creditor_company_detail LIKE  lfb1,
        p_return                LIKE  bapireturn.

  DATA:  creditor_bank_detail  LIKE lfbk OCCURS 0 WITH HEADER LINE.
  DATA:  p_lfbw  LIKE lfbw OCCURS 0 WITH HEADER LINE.
  DATA:  p_lfza  LIKE lfza OCCURS 0 WITH HEADER LINE.
  DATA:  pp_return  LIKE  bapireturn OCCURS 0 WITH HEADER LINE.

  DATA: ls_vrsd LIKE LINE OF pp_return.

  CALL FUNCTION 'ZBAPI_CREDITOR_GETDETAIL'
    EXPORTING
      creditorid              = p_ti_acreedor-lifnr
      companycode             = p_ti_acreedor-bukrs
    IMPORTING
      creditor_general_detail = creditor_general_detail
      creditor_company_detail = creditor_company_detail
      return                  = p_return
    TABLES
      creditor_bank_detail    = creditor_bank_detail
      lfbw                    = p_lfbw
      lfza                    = p_lfza.

  IF p_return-type NE 'E'.
    p_t_error = 0.

  ELSE.
    IF p_return-type EQ 'E'.
      p_t_error = 4.
      return-type              = 'E'.
      return-id                = '04'.
      return-message_v1        = 'Acreedor no existe'.
      APPEND return.
    ENDIF.
  ENDIF.

  IF p_ti_acreedor-empfk NE space AND p_ti_acreedor-bukrs NE space.
    READ TABLE p_lfza WITH KEY  lifnr =  p_ti_acreedor-lifnr
                                empfk =  p_ti_acreedor-empfk.
    IF sy-subrc EQ 0.
      p_t_error = 4.
      return-type              = 'E'.
      return-id                = '04'.
      return-message_v1        = 'El pagador alternativo'.
      return-message_v2        = 'ya existe para el acreedor'.
      return-message_v3        = p_ti_acreedor-lifnr.
      APPEND return.
    ENDIF.
  ENDIF.

ENDFORM.                    " BUSCA_ACREEDOR


*&---------------------------------------------------------------------*
*&      Form  VALIDA_UPDATE_ACREEDOR
*&---------------------------------------------------------------------*
FORM valida_update_acreedor TABLES return STRUCTURE bapiret2
                            USING p_ti_acreedor STRUCTURE zacreedor
                            CHANGING p_t_error.

* Validacion Grupo de ctas. Deudor (KTOKD) y ID de cliente (KUNNR)
  DATA: p_ktokd     LIKE t077d-ktokd,
        p_numkr     LIKE nriv-nrrangenr,
        p_externind LIKE nriv-externind.
  DATA: e_valid(1) TYPE c.

  DATA: o_t077d  LIKE  t077d OCCURS 0 WITH HEADER LINE.
  DATA: interval LIKE  nriv OCCURS 0 WITH HEADER LINE.
  DATA: es_lfa1 LIKE  lfa1.
  DATA: es_lfb1 LIKE  lfb1.

  CALL FUNCTION 'FI_VENDOR_CHECK'
    EXPORTING
      i_bukrs = p_ti_acreedor-bukrs
      i_lifnr = p_ti_acreedor-lifnr
    EXCEPTIONS
      vendor  = 1
      OTHERS  = 2.
  IF sy-subrc <> 0.

    p_t_error = 4.
    return-type              = 'E'.
    return-id                = '04'.
    return-message_v1        = 'Acreedor  tiene error'.
    return-message_v2        = p_ti_acreedor-bukrs.
    return-message_v3        = ' NO Existe'.
    APPEND return.

  ENDIF.

* Validación Sociedad (BUKRS)
  IF p_ti_acreedor-bukrs NE space.
    CALL FUNCTION 'VALIDATE_COMPANY_CODE'
      EXPORTING
        i_company  = p_ti_acreedor-bukrs
      IMPORTING
        e_valid    = e_valid
      EXCEPTIONS
        incomplete = 1
        OTHERS     = 2.
    IF  e_valid EQ 0.
      p_t_error = 4.
      return-type              = 'E'.
      return-id                = '04'.
      return-message_v1        = 'La Sociedad FI'.
      return-message_v2        = p_ti_acreedor-bukrs.
      return-message_v3        = ' NO Existe'.
      APPEND return.
    ENDIF.
  ENDIF.

  DATA:
    kontenplan_wa        LIKE  ska1 OCCURS 0 WITH HEADER LINE,
    sachkonto_wa         LIKE  skb1 OCCURS 0 WITH HEADER LINE,
    et_duplicate_vendors TYPE vmds_checkdata_vendor_t.


* Validación Cuenta de mayor (AKONT)
  IF p_ti_acreedor-akont NE space.
    CALL FUNCTION 'READ_HAUPTBUCH'
      EXPORTING
        buchungskreis        = p_ti_acreedor-bukrs
        sachkonto            = p_ti_acreedor-akont
        auth_check_activity  = ' '
      IMPORTING
        kontenplan_wa        = kontenplan_wa
        sachkonto_wa         = sachkonto_wa
      EXCEPTIONS
        kontenplan_not_found = 1
        sachkonto_not_found  = 2
        not_authorized       = 3
        OTHERS               = 4.
    IF sy-subrc = 0.
      READ TABLE sachkonto_wa INDEX 1.
      IF sy-subrc EQ 0.
        IF sachkonto_wa-mitkz NE  'D'.
          p_t_error = 4.
          return-type              = 'E'.
          return-id                = '05'.
          return-message_v1        = 'La cuenta de Mayor'.
          return-message_v2        =  p_ti_acreedor-akont.
          return-message_v3        = ' no asociada'.
          APPEND return.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF p_ti_acreedor-title NE space.

    CALL FUNCTION 'ADDR_TSAD3_READ'
      EXPORTING
        title_key           = p_ti_acreedor-title
      EXCEPTIONS
        title_key_not_found = 1
        OTHERS              = 2.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-type              = 'E'.
      return-id                = '06'.
      return-message_v1        = 'El Tratamiento '.
      return-message_v2        =  p_ti_acreedor-title.
      return-message_v3        = ' NO existe'.
      APPEND return.
    ENDIF.
  ENDIF.

  IF p_ti_acreedor-regio NE space.
    CALL FUNCTION 'BPAR_C_REGIONALCODE_CHECK'
      EXPORTING
        country      = p_ti_acreedor-land1
        regionalcode = p_ti_acreedor-regio
      EXCEPTIONS
        regionalcode = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-type              = 'E'.
      return-id                = '08'.
      return-message_v1        = 'La Region ingresada'.
      return-message_v2        =  p_ti_acreedor-regio.
      return-message_v3        = ' NO existe'.
      APPEND return.
    ENDIF.
  ENDIF.

  IF p_ti_acreedor-kunnr NE space.
    CALL FUNCTION 'FI_VENDOR_CHECK'
      EXPORTING
        i_bukrs = p_ti_acreedor-bukrs
        i_lifnr = p_ti_acreedor-kunnr
      EXCEPTIONS
        vendor  = 1
        OTHERS  = 2.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-type              = 'E'.
      return-id                = '09'.
      return-message_v1        = 'El Numero de Acreedor'.
      return-message_v2        =  p_ti_acreedor-kunnr.
      return-message_v3        = ' Ya existe'.
      APPEND return.
    ENDIF.
  ENDIF.

  IF p_ti_acreedor-zuawa NE space.
    CALL FUNCTION 'TZUN_SINGLE_READ'
      EXPORTING
        i_zuawa   = p_ti_acreedor-zuawa
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-type              = 'E'.
      return-id                = '12'.
      return-message_v1        = 'La condicion de Clacificación'.
      return-message_v2        =  p_ti_acreedor-zuawa.
      return-message_v3        = 'No existe o no es Valida'.
      APPEND return.
    ENDIF.
  ENDIF.


  IF p_ti_acreedor-fdgrv NE space.

    CALL FUNCTION 'CASH_FORECAST_CHECK_LEVEL_GRP'
      EXPORTING
        fdgrp         = p_ti_acreedor-fdgrv
        koart         = 'K'
      EXCEPTIONS
        group_invalid = 1
        level_invalid = 2
        orign_invalid = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-type             = 'E'.
      return-id                = '14'.
      return-message_v1        = 'El Grupo de tesorería'.
      return-message_v2        =  p_ti_acreedor-fdgrv.
      return-message_v3        = 'No existe o no es Valida'.
      APPEND return.
    ENDIF.
  ENDIF.


  IF p_ti_acreedor-zterm1 NE space.
    CALL FUNCTION 'FI_CHECK_ZTERM'
      EXPORTING
        i_zterm       = p_ti_acreedor-zterm1
      EXCEPTIONS
        invalid_zterm = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      p_t_error = 4.
      return-type             = 'E'.
      return-id                = '15'.
      return-message_v1        = 'La Condición de pago'.
      return-message_v2        =  p_ti_acreedor-zterm1.
      return-message_v3        = 'No existe o no es Valida'.
      APPEND return.
    ENDIF.
  ENDIF.


  DATA: it_t042z LIKE  t042z_key OCCURS 0 WITH HEADER LINE.
  DATA: et_t042z LIKE t042z OCCURS 0 WITH HEADER LINE.

  IF p_ti_acreedor-zwels NE space.
    it_t042z-land1 = p_ti_acreedor-land1.
    it_t042z-zlsch = p_ti_acreedor-zwels+0(1).
    IF it_t042z-zlsch NE space.
      APPEND it_t042z. CLEAR it_t042z.
    ENDIF.
    it_t042z-land1 = p_ti_acreedor-land1.
    it_t042z-zlsch = p_ti_acreedor-zwels+1(1).
    IF it_t042z-zlsch NE space.
      APPEND it_t042z. CLEAR it_t042z.
    ENDIF.
    it_t042z-land1 = p_ti_acreedor-land1.
    it_t042z-zlsch = p_ti_acreedor-zwels+2(1).
    IF it_t042z-zlsch NE space.
      APPEND it_t042z. CLEAR it_t042z.
    ENDIF.
    it_t042z-land1 = p_ti_acreedor-land1.
    it_t042z-zlsch = p_ti_acreedor-zwels+3(1).
    IF it_t042z-zlsch NE space.
      APPEND it_t042z. CLEAR it_t042z.
    ENDIF.
    it_t042z-land1 = p_ti_acreedor-land1.
    it_t042z-zlsch = p_ti_acreedor-zwels+4(1).
    IF it_t042z-zlsch NE space.
      APPEND it_t042z. CLEAR it_t042z.
    ENDIF.
    it_t042z-land1 = p_ti_acreedor-land1.
    it_t042z-zlsch = p_ti_acreedor-zwels+5(1).
    IF it_t042z-zlsch NE space.
      APPEND it_t042z. CLEAR it_t042z.
    ENDIF.
    it_t042z-land1 = p_ti_acreedor-land1.
    it_t042z-zlsch = p_ti_acreedor-zwels+6(1).
    IF it_t042z-zlsch NE space.
      APPEND it_t042z. CLEAR it_t042z.
    ENDIF.
    it_t042z-land1 = p_ti_acreedor-land1.
    it_t042z-zlsch = p_ti_acreedor-zwels+7(1).
    IF it_t042z-zlsch NE space.
      APPEND it_t042z. CLEAR it_t042z.
    ENDIF.
    it_t042z-land1 = p_ti_acreedor-land1.
    it_t042z-zlsch = p_ti_acreedor-zwels+8(1).
    IF it_t042z-zlsch NE space.
      APPEND it_t042z. CLEAR it_t042z.
    ENDIF.
    it_t042z-land1 = p_ti_acreedor-land1.
    it_t042z-zlsch = p_ti_acreedor-zwels+9(1).
    IF it_t042z-zlsch NE space.
      APPEND it_t042z. CLEAR it_t042z.
    ENDIF.
    CALL FUNCTION 'WB2_T042Z_ARRAY_SELECT'
      TABLES
        it_t042z        = it_t042z
        et_t042z        = et_t042z
      EXCEPTIONS
        not_found       = 1
        parameter_error = 2
        OTHERS          = 3.
    IF sy-subrc EQ 0.

      LOOP AT it_t042z.
        READ TABLE et_t042z WITH  KEY zlsch = it_t042z-zlsch
                                       land1 = it_t042z-land1.
        IF sy-subrc NE 0.
          p_t_error = 4.
          return-type             = 'E'.
          return-id                = '17'.
          return-message_v1        = 'La via de pago '.
          return-message_v2        =  it_t042z-zlsch.
          return-message_v3        = 'No existe o no es Valida'.
          APPEND return.
          CLEAR:  return.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF p_ti_acreedor-zgrup NE space.
    DATA: p_zgrup LIKE tzgr-zgrup.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zgrup INTO p_zgrup FROM tzgr
*      WHERE zgrup EQ p_ti_acreedor-zgrup.
*
* NEW CODE
    SELECT zgrup
    UP TO 1 ROWS  INTO p_zgrup FROM tzgr
      WHERE zgrup EQ p_ti_acreedor-zgrup ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      p_t_error = 4.
      return-type             = 'E'.
      return-id                = '18'.
      return-message_v1        = 'Clave de Aprupaciòn '.
      return-message_v2        =  p_ti_acreedor-zgrup.
      return-message_v3        = 'No existe o no es Valida'.
      APPEND return.
      CLEAR:  return.
    ENDIF.
  ENDIF.

ENDFORM.                    " VALIDA_UPDATE_ACREEDOR


*&---------------------------------------------------------------------*
*&      Form  PROCESO_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TI_BAPI_ACRE  text
*      -->P_TI_CONT_ACRE  text
*----------------------------------------------------------------------*
FORM proceso_data  TABLES p_ti_bapi_acre STRUCTURE zacreedor
                            p_ti_cont_acre STRUCTURE ti_cont_acre.


ENDFORM.                    " PROCESO_DATA
*&---------------------------------------------------------------------*
*&      Form  UPDATE_ACREEDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RETURN  text
*      -->P_TI_CONT_ACRE  text
*----------------------------------------------------------------------*
FORM update_acreedor  TABLES  return STRUCTURE bapiret2
                        USING   p_ti_acreedor STRUCTURE zacreedor.
  REFRESH: messtab, bdcdata.
  DATA: cont_reg TYPE i,
        resul1   TYPE i,
        resul2   TYPE i,
        resul3   TYPE i,
        info     TYPE string,
        iter(2)  TYPE n.


  DATA: creditor_general_detail LIKE  lfa1,
        creditor_company_detail LIKE  lfb1,
        p_return                LIKE  bapireturn.
  DATA:  creditor_bank_detail  LIKE lfbk OCCURS 0 WITH HEADER LINE.
  DATA:  p_lfbw     LIKE lfbw OCCURS 0 WITH HEADER LINE.
  DATA:  p_lfza     LIKE lfza OCCURS 0 WITH HEADER LINE.
  DATA:  pp_return  LIKE  bapireturn OCCURS 0 WITH HEADER LINE.
  DATA: ls_vrsd LIKE LINE OF pp_return.


  DATA: dympro_c(132)  TYPE c,
        dympro_c2(132) TYPE c,
        num(1)         TYPE c.


  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0106'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'RF02K-D0610'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.
  PERFORM bdc_field       USING 'RF02K-LIFNR'            p_ti_acreedor-lifnr.
  PERFORM bdc_field       USING 'RF02K-BUKRS'            p_ti_acreedor-bukrs.
  PERFORM bdc_field       USING 'RF02K-D0110'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0120'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0130'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0210'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0215'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0220'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0610'            'X'.


  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0111'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '=$2OC'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'SZA1_D0100-TITLE_MEDI'.
  PERFORM bdc_field       USING 'SZA1_D0100-TITLE_MEDI'  p_ti_acreedor-title.
  IF p_ti_acreedor-accion EQ '30'.
    PERFORM bdc_field       USING 'ADDR1_DATA-NAME1'       p_ti_acreedor-name1.
  ENDIF.
*  IF P_TI_ACREEDOR-NAME2 is INITIAL.
*    P_TI_ACREEDOR-NAME2 = '  '.
*  ENDIF.
  IF p_ti_acreedor-accion EQ '30' AND p_ti_acreedor-name2 IS NOT INITIAL. "HCD 23-09-2022
    PERFORM bdc_field       USING 'ADDR1_DATA-NAME2'       p_ti_acreedor-name2."HCD 23-09-2022
  ENDIF."HCD 23-09-2022
  PERFORM bdc_field       USING 'ADDR1_DATA-SORT1'       p_ti_acreedor-sort1.
  PERFORM bdc_field       USING 'ADDR1_DATA-SORT2'       p_ti_acreedor-sort2.

  PERFORM bdc_field       USING 'ADDR1_DATA-STREET'      p_ti_acreedor-street.
  PERFORM bdc_field       USING 'ADDR1_DATA-HOUSE_NUM1'  p_ti_acreedor-house_num1.
  PERFORM bdc_field       USING 'ADDR1_DATA-CITY2'       p_ti_acreedor-ort02.
  PERFORM bdc_field       USING 'ADDR1_DATA-CITY1'       p_ti_acreedor-ort01.
  PERFORM bdc_field       USING 'ADDR1_DATA-PO_BOX'       p_ti_acreedor-po_box.

  PERFORM bdc_field   USING 'SZA1_D0100-TEL_NUMBER'    p_ti_acreedor-tel_number.
  PERFORM bdc_field   USING 'SZA1_D0100-TEL_EXTENS'    p_ti_acreedor-tel1_ext.
  PERFORM bdc_field   USING 'SZA1_D0100-FAX_NUMBER'    p_ti_acreedor-telfax.
  PERFORM bdc_field   USING 'SZA1_D0100-FAX_EXTENS'    p_ti_acreedor-fax_extens.
  PERFORM bdc_field   USING 'SZA1_D0100-SMTP_ADDR'     p_ti_acreedor-smtp_addr.


  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0111'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'SZA1_D0100-TITLE_MEDI'.

  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0120'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'LFA1-BRSCH'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.

  CALL FUNCTION 'ZBAPI_CREDITOR_GETDETAIL'
    EXPORTING
      creditorid              = p_ti_acreedor-lifnr
      companycode             = p_ti_acreedor-bukrs
    IMPORTING
      creditor_general_detail = creditor_general_detail
      creditor_company_detail = creditor_company_detail
      return                  = p_return
    TABLES
      creditor_bank_detail    = creditor_bank_detail
      lfbw                    = p_lfbw
      lfza                    = p_lfza.

  IF p_ti_acreedor-empfk NE space.
    IF p_return-type NE 'E'.
      DESCRIBE TABLE p_lfza LINES  cont_reg.
      IF cont_reg > 0.
        resul1 = cont_reg / 7.
        IF resul1 >= 2.
          resul2 = resul1 * 7.
        ENDIF.
        resul3 = cont_reg - resul2 + 1.
        IF resul3 > 7.
          ADD 1 TO  resul1.
          resul3 = 1.
        ENDIF.

        num = resul3.
        dympro_c = 'LFZA-EMPFK'.

        IF resul1 >= 2.
          IF p_ti_acreedor-banks IS NOT INITIAL
             AND p_ti_acreedor-bankl IS NOT INITIAL
             AND p_ti_acreedor-bankn IS NOT INITIAL.
            LOOP AT creditor_bank_detail.
              PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
              PERFORM bdc_field       USING 'BDC_CURSOR'
                                            'LFBK-BANKS(01)'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '=BDEL'.
            ENDLOOP.
          ENDIF.

          PERFORM bdc_dynpro      USING 'SAPMF02K'               '0130'.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=LFZA'.
          PERFORM bdc_field       USING 'LFBK-BANKS(01)'  p_ti_acreedor-banks.
          PERFORM bdc_field       USING 'LFBK-BANKL(01)'  p_ti_acreedor-bankl.
          PERFORM bdc_field       USING 'LFBK-BANKN(01)'  p_ti_acreedor-bankn.
          PERFORM bdc_field       USING 'LFBK-KOINH(01)'  p_ti_acreedor-koinh.
          PERFORM bdc_field       USING 'LFBK-BKONT(01)'  p_ti_acreedor-bkont.
*-> BEG INS V1-CNN ECDK926773 30.09.2025
          PERFORM bdc_field       USING 'LFBK-BVTYP(01)'  p_ti_acreedor-bvtyp.
          PERFORM bdc_field       USING 'LFBK-BKREF(01)'  p_ti_acreedor-bkref.
*-> END INS V1-CNN ECDK926773 30.09.2025
          resul1 = resul1 - 1.
          DO resul1 TIMES.
            PERFORM bdc_dynpro      USING 'SAPMF02K'               '1130'.
            PERFORM bdc_field       USING 'BDC_CURSOR'             'LFZA-EMPFK(01)'.
            PERFORM bdc_field       USING 'BDC_OKCODE'             '=P+'.
          ENDDO.

          PERFORM bdc_dynpro      USING 'SAPMF02K'               '1130'.
          CONCATENATE  dympro_c '(' num  ')'  INTO dympro_c2.
          PERFORM bdc_field       USING  dympro_c2               p_ti_acreedor-empfk.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=BACK'.

          PERFORM bdc_dynpro      USING 'SAPMF02K'     '0130'.
          PERFORM bdc_field       USING 'BDC_CURSOR'   'LFBK-BANKS(01)'.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=VW'.


        ELSE.
          IF p_ti_acreedor-banks IS NOT INITIAL
             AND p_ti_acreedor-bankl IS NOT INITIAL
             AND p_ti_acreedor-bankn IS NOT INITIAL.
            LOOP AT creditor_bank_detail.
              PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
              PERFORM bdc_field       USING 'BDC_CURSOR'
                                            'LFBK-BANKS(01)'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '=BDEL'.
            ENDLOOP.
          ENDIF.
          PERFORM bdc_dynpro      USING 'SAPMF02K'               '0130'.
          PERFORM bdc_field       USING 'BDC_CURSOR'             'LFBK-BANKS(01)'.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=LFZA'.

          PERFORM bdc_field       USING 'LFBK-BANKS(01)'  p_ti_acreedor-banks.
          PERFORM bdc_field       USING 'LFBK-BANKL(01)'  p_ti_acreedor-bankl.
          PERFORM bdc_field       USING 'LFBK-BANKN(01)'  p_ti_acreedor-bankn.
          PERFORM bdc_field       USING 'LFBK-KOINH(01)'  p_ti_acreedor-koinh.
          PERFORM bdc_field       USING 'LFBK-BKONT(01)'  p_ti_acreedor-bkont.
*-> BEG INS V1-CNN ECDK926773 30.09.2025
          PERFORM bdc_field       USING 'LFBK-BVTYP(01)'  p_ti_acreedor-bvtyp.
          PERFORM bdc_field       USING 'LFBK-BKREF(01)'  p_ti_acreedor-bkref.
*-> END INS V1-CNN ECDK926773 30.09.2025

          CONCATENATE  dympro_c '(' num  ')'  INTO dympro_c2.
          PERFORM bdc_dynpro      USING 'SAPMF02K'               '1130'.
          PERFORM bdc_field       USING  dympro_c2               p_ti_acreedor-empfk.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=BACK'.

          PERFORM bdc_dynpro      USING 'SAPMF02K'     '0130'.
          PERFORM bdc_field       USING 'BDC_CURSOR'   'LFBK-BANKS(01)'.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=VW'.

        ENDIF.
      ELSE.
        num = 1.
        IF p_ti_acreedor-banks IS NOT INITIAL
             AND p_ti_acreedor-bankl IS NOT INITIAL
             AND p_ti_acreedor-bankn IS NOT INITIAL.
          LOOP AT creditor_bank_detail.
            PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
            PERFORM bdc_field       USING 'BDC_CURSOR'
                                          'LFBK-BANKS(01)'.
            PERFORM bdc_field       USING 'BDC_OKCODE'
                                          '=BDEL'.
          ENDLOOP.
        ENDIF.
        PERFORM bdc_dynpro      USING 'SAPMF02K'               '0130'.
        PERFORM bdc_field       USING 'BDC_CURSOR'             'LFZA-EMPFK(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'             '=LFZA'.

        PERFORM bdc_field       USING 'LFBK-BANKS(01)'  p_ti_acreedor-banks.
        PERFORM bdc_field       USING 'LFBK-BANKL(01)'  p_ti_acreedor-bankl.
        PERFORM bdc_field       USING 'LFBK-BANKN(01)'  p_ti_acreedor-bankn.
        PERFORM bdc_field       USING 'LFBK-KOINH(01)'  p_ti_acreedor-koinh.
        PERFORM bdc_field       USING 'LFBK-BKONT(01)'  p_ti_acreedor-bkont.
*-> BEG INS V1-CNN ECDK926773 30.09.2025
        PERFORM bdc_field       USING 'LFBK-BVTYP(01)'  p_ti_acreedor-bvtyp.
        PERFORM bdc_field       USING 'LFBK-BKREF(01)'  p_ti_acreedor-bkref.
*-> END INS V1-CNN ECDK926773 30.09.2025
        PERFORM bdc_dynpro      USING 'SAPMF02K'               '1130'.
        CONCATENATE  dympro_c '(' num  ')'  INTO dympro_c2.
        PERFORM bdc_field       USING  dympro_c2               p_ti_acreedor-empfk.
        PERFORM bdc_field       USING 'BDC_OKCODE'             '=BACK'.

        PERFORM bdc_dynpro      USING 'SAPMF02K'     '0130'.
        PERFORM bdc_field       USING 'BDC_CURSOR'   'LFBK-BANKS(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'             '=VW'.

      ENDIF.
    ENDIF.
  ENDIF.

  IF p_ti_acreedor-empfk EQ space.
    IF p_ti_acreedor-banks IS NOT INITIAL
             AND p_ti_acreedor-bankl IS NOT INITIAL
             AND p_ti_acreedor-bankn IS NOT INITIAL.
      LOOP AT creditor_bank_detail.
        PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'LFBK-BANKS(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=BDEL'.
      ENDLOOP.
    ENDIF.
    PERFORM bdc_dynpro      USING 'SAPMF02K'               '0130'.
    PERFORM bdc_field       USING 'BDC_CURSOR'             'LFBK-BANKS(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.

    PERFORM bdc_field       USING 'LFBK-BANKS(01)'  p_ti_acreedor-banks.
    PERFORM bdc_field       USING 'LFBK-BANKL(01)'  p_ti_acreedor-bankl.
    PERFORM bdc_field       USING 'LFBK-BANKN(01)'  p_ti_acreedor-bankn.
    PERFORM bdc_field       USING 'LFBK-KOINH(01)'  p_ti_acreedor-koinh.
    PERFORM bdc_field       USING 'LFBK-BKONT(01)'  p_ti_acreedor-bkont.
*-> BEG INS V1-CNN ECDK926773 30.09.2025
    PERFORM bdc_field       USING 'LFBK-BVTYP(01)'  p_ti_acreedor-bvtyp.
    PERFORM bdc_field       USING 'LFBK-BKREF(01)'  p_ti_acreedor-bkref.
*-> END INS V1-CNN ECDK926773 30.09.2025
    PERFORM bdc_field       USING 'BDC_OKCODE'             '=VW'.
  ENDIF.


  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0210'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'LFB1-AKONT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.
  PERFORM bdc_field       USING 'LFB1-AKONT'             p_ti_acreedor-akont.
  PERFORM bdc_field       USING 'LFB1-ZUAWA'             p_ti_acreedor-zuawa.
  PERFORM bdc_field       USING 'LFB1-FDGRV'             p_ti_acreedor-fdgrv.

  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0215'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'LFB1-ZTERM'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.
  PERFORM bdc_field       USING 'LFB1-ZTERM'             p_ti_acreedor-zterm1.
  PERFORM bdc_field       USING 'LFB1-REPRF'             'X'. "Factura Doble Acreedores.
  IF p_ti_acreedor-bukrs EQ 'CL01' OR p_ti_acreedor-bukrs EQ 'CL24'.
    p_ti_acreedor-zgrup = 'Z1'.
  ENDIF.
  PERFORM bdc_field       USING 'LFB1-ZGRUP'             p_ti_acreedor-zgrup.

  PERFORM bdc_field       USING 'LFB1-ZWELS'             p_ti_acreedor-zwels.
  PERFORM bdc_field       USING 'LFB1-ZAHLS'             p_ti_acreedor-zahls.

  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0220'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'LFB5-MAHNA'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.

  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0610'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'LFB1-QLAND'.

  PERFORM bdc_dynpro      USING 'SAPLSPO1'               '0300'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '=YES'.

  DATA: ctumode LIKE ctu_params-dismode VALUE 'N'.
  DATA: cupdate LIKE ctu_params-updmode VALUE 'L'.
  DATA opt TYPE ctu_params.
  opt-nobinpt = 'X'.
  opt-dismode = ctumode.
  opt-updmode = cupdate.

  CALL TRANSACTION 'FK02' USING bdcdata
                    OPTIONS FROM opt
                   MESSAGES INTO messtab.

  DATA: BEGIN OF itlog OCCURS 0,
          texto(100),
        END OF itlog.

  DATA: v_texto LIKE t100-text,
        v_msgid LIKE sy-msgid,
        v_msgno LIKE sy-msgno,
        v_msgv1 LIKE sy-msgv1,
        v_msgv2 LIKE sy-msgv2,
        v_msgv3 LIKE sy-msgv3,
        v_msgv4 LIKE sy-msgv4.

  LOOP AT messtab WHERE msgid NE 'I'.

    v_msgid = messtab-msgid.
    v_msgno = messtab-msgnr.
    v_msgv1 = messtab-msgv1.
    v_msgv2 = messtab-msgv2.
    v_msgv3 = messtab-msgv3.
    v_msgv4 = messtab-msgv4.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE text
*      INTO  v_texto
*       FROM t100 WHERE sprsl = sy-langu
*                   AND arbgb = v_msgid
*                   AND msgnr = v_msgno.
*
* NEW CODE
    SELECT text
    UP TO 1 ROWS 
      INTO  v_texto
       FROM t100 WHERE sprsl = sy-langu
                   AND arbgb = v_msgid
                   AND msgnr = v_msgno ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      DATA:
        maximum_length TYPE i,
        hlp_text(100)  TYPE c,
        msgv_no(1)     TYPE c,
        offset         TYPE i,
        index          TYPE i,
        strl           LIKE sy-fdpos,
        p_fdpos        LIKE sy-fdpos.

      DESCRIBE FIELD v_texto LENGTH maximum_length IN CHARACTER MODE.
      hlp_text = v_texto.
      CLEAR v_texto.

      offset = 0.
      DO 4 TIMES.
        SEARCH hlp_text FOR '&'.
        IF sy-subrc <> 0. EXIT. ENDIF.
        IF sy-fdpos <> 0.
          CHECK offset < maximum_length.
          MOVE hlp_text(sy-fdpos) TO v_texto+offset.
          offset = offset + sy-fdpos.
        ENDIF.
        index = sy-fdpos + 1.
        SHIFT hlp_text BY index PLACES LEFT.
        p_fdpos  = sy-fdpos.
        IF hlp_text(1) CO '1234'.
          msgv_no = hlp_text(1).
          SHIFT hlp_text BY 1 PLACES LEFT.
        ELSE.
          msgv_no = sy-index.
        ENDIF.
        CHECK offset < maximum_length.
        CASE msgv_no.
          WHEN 1.
            WRITE v_msgv1 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv1 ).

          WHEN 2.
            WRITE v_msgv2 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv2 ).
          WHEN 3.
            WRITE v_msgv3 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv3 ).
          WHEN 4.
            WRITE v_msgv4 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv4 ).
        ENDCASE.
        offset = offset + strl.
      ENDDO.



      IF offset < maximum_length.
        sy-fdpos = strlen( hlp_text ).
        IF sy-fdpos <> 0.
          MOVE hlp_text(sy-fdpos) TO v_texto+offset.
        ENDIF.
      ENDIF.

      return-message_v1 = v_texto+0(50).
      return-message_v2 = v_texto+50(13).

      return-type              = messtab-msgtyp.
      return-id                = '01'.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " UPDATE_ACREEDOR

*----------------------------------------------------------------------*
*       Form  AUTHORITYCHECK_F_BKPF_BEK
*----------------------------------------------------------------------*
*       Berechtigungsprüfung: Kontenberechtigung Buchen                *
*----------------------------------------------------------------------*
*  -->  PR_BEGRU  Berechtigungsgruppe
*  -->  PR_TOSET  Zu setzender Returncode
*  <--  PR_SET    Gesetzter Returncode
*----------------------------------------------------------------------*
FORM authoritycheck_f_bkpf_bek USING pr_begru pr_toset pr_set.
  CHECK NOT pr_begru IS INITIAL.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BEK'
           ID 'BRGRU' FIELD pr_begru
           ID 'ACTVT' FIELD auth-actvt.
  CHECK sy-subrc NE 0.
  pr_set = pr_toset.
ENDFORM.                    "AUTHORITYCHECK_F_BKPF_BEK

*----------------------------------------------------------------------*
*       Form  AUTHORITYCHECK_F_BKPF_BUK
*----------------------------------------------------------------------*
*       Berechtigungsprüfung: Bukrs-Berechtigung Buchen                *
*----------------------------------------------------------------------*
*  -->  PR_BUKRS  Buchungskreis
*  -->  PR_TOSET  Zu setzender Returncode
*  <--  PR_SET    Gesetzter Returncode
*----------------------------------------------------------------------*
FORM authoritycheck_f_bkpf_buk USING pr_bukrs pr_toset pr_set.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD pr_bukrs
           ID 'ACTVT' FIELD auth-actvt.
  CHECK sy-subrc NE 0.
  pr_set = pr_toset.
ENDFORM.                    "AUTHORITYCHECK_F_BKPF_BUK

*----------------------------------------------------------------------*
*       Form  AUTHORITYCHECK_F_BKPF_KOA
*----------------------------------------------------------------------*
*       Berechtigungsprüfung: Kontoartberechtigung Buchen              *
*----------------------------------------------------------------------*
*  -->  PR_TOSET  Zu setzender Returncode
*  <--  PR_SET    Gesetzter Returncode
*----------------------------------------------------------------------*
FORM authoritycheck_f_bkpf_koa USING pr_toset pr_set.
  AUTHORITY-CHECK OBJECT 'F_BKPF_KOA'
           ID 'KOART' FIELD 'K'
           ID 'ACTVT' FIELD auth-actvt.
  CHECK sy-subrc NE 0.
  pr_set = pr_toset.
ENDFORM.                    "AUTHORITYCHECK_F_BKPF_KOA

*----------------------------------------------------------------------*
*       Form  AUTHORITYCHECK_F_LFA1_APP
*----------------------------------------------------------------------*
*       Berechtigungsprüfung: Anzeige Kreditor / Applikatiion F        *
*----------------------------------------------------------------------*
*  -->  PR_APPLK  Anwendung
*  -->  PR_TOSET  Zu setzender Returncode
*  <--  PR_SET    Gesetzter Returncode
*----------------------------------------------------------------------*
FORM authoritycheck_f_lfa1_app USING pr_appkz
                                     pr_set LIKE bapireturn.
  AUTHORITY-CHECK OBJECT 'F_LFA1_APP'
           ID 'ACTVT' FIELD auth-actvt
           ID 'APPKZ' FIELD pr_appkz.
  CHECK sy-subrc NE 0.
  CLEAR message.
* MESSAGE = 'EFN519'.
  message-msgty = 'E'.
  message-msgid = 'FN'.
  message-msgno = '519'.
  PERFORM set_return_message USING    message
                             CHANGING pr_set.
  IF 1 = 2.            " Für Verwendungsnachweis Message
    MESSAGE e519(fn).
  ENDIF.
ENDFORM.                    "AUTHORITYCHECK_F_LFA1_APP

*----------------------------------------------------------------------*
*       Form  AUTHORITYCHECK_F_LFA1_BEK
*----------------------------------------------------------------------*
*       Berechtigungsprüfung: Berechtigungsgruppe                      *
*----------------------------------------------------------------------*
*  -->  PR_BEGRU  Berechtigungsgruppe
*  -->  PR_TOSET  Zu setzender Returncode
*  <--  PR_SET    Gesetzter Returncode
*----------------------------------------------------------------------*
FORM authoritycheck_f_lfa1_bek USING pr_begru
                                     pr_set LIKE bapireturn.
  CHECK NOT pr_begru IS INITIAL.
  AUTHORITY-CHECK OBJECT 'F_LFA1_BEK'
           ID 'BRGRU' FIELD pr_begru
           ID 'ACTVT' FIELD auth-actvt.
  CHECK sy-subrc NE 0.
  CLEAR message.
  message-msgty = 'E'.
  message-msgid = 'FN'.
  message-msgno = '523'.
  PERFORM set_return_message USING    message
                             CHANGING pr_set.
  IF 1 = 2.
    MESSAGE e523(fn).
  ENDIF.
ENDFORM.                    "AUTHORITYCHECK_F_LFA1_BEK

*----------------------------------------------------------------------*
*       Form  AUTHORITYCHECK_F_LFA1_BUK
*----------------------------------------------------------------------*
*       Berechtigungsprüfung: Anzeige Kreditor im Buchungskreis        *
*----------------------------------------------------------------------*
*  -->  PR_BUKRS  Buchungskreis
*  -->  PR_TOSET  Zu setzender Returncode
*  <--  PR_SET    Gesetzter Returncode
*----------------------------------------------------------------------*
FORM authoritycheck_f_lfa1_buk USING pr_bukrs
                                     pr_set LIKE bapireturn.
  AUTHORITY-CHECK OBJECT 'F_LFA1_BUK'
           ID 'BUKRS' FIELD pr_bukrs
           ID 'ACTVT' FIELD auth-actvt.
  CHECK sy-subrc NE 0.
  CLEAR message.
  message-msgty = 'E'.
  message-msgid = 'FN'.
  message-msgno = '520'.
  message-msgv1 = pr_bukrs.
  PERFORM set_return_message USING    message
                             CHANGING pr_set.
  IF 1 = 2.
    MESSAGE e520(fn) WITH pr_bukrs.
  ENDIF.
ENDFORM.                    "AUTHORITYCHECK_F_LFA1_BUK

*----------------------------------------------------------------------*
*       Form  AUTHORITYCHECK_F_LFA1_GRP
*----------------------------------------------------------------------*
*       Berechtigungsprüfung: Kontengruppe                             *
*----------------------------------------------------------------------*
*  -->  PR_KTOKK  Kontengruppe
*  <--  PR_SET    Gesetzter Returncode
*----------------------------------------------------------------------*
FORM authoritycheck_f_lfa1_grp USING pr_ktokk
                                     pr_set LIKE bapireturn.
  AUTHORITY-CHECK OBJECT 'F_LFA1_GRP'
           ID 'KTOKK' FIELD pr_ktokk
           ID 'ACTVT' FIELD auth-actvt.
  CHECK sy-subrc NE 0.
  CLEAR message.
  message-msgty = 'E'.
  message-msgid = 'FN'.
  message-msgno = '540'.
  message-msgv1 = pr_ktokk.
  PERFORM set_return_message USING    message
                             CHANGING pr_set.
  IF 1 = 2.
    MESSAGE e540(fn).
  ENDIF.
ENDFORM.                    "AUTHORITYCHECK_F_LFA1_GRP

*----------------------------------------------------------------------*
*       Form  AUTHORITYCHECK_F_LFA1_GEN
*----------------------------------------------------------------------*
*       Berechtigungsprüfung: Allgemeine Daten                         *
*----------------------------------------------------------------------*
*  <--  PR_SET          Gesetzter Returncode
*----------------------------------------------------------------------*
FORM authoritycheck_f_lfa1_gen USING pr_set LIKE bapireturn.
  AUTHORITY-CHECK OBJECT 'F_LFA1_GEN'
           ID 'ACTVT' FIELD auth-actvt.
  CHECK sy-subrc NE 0.
  CLEAR message.

  message-msgty = 'E'.
  message-msgid = 'FN'.
  message-msgno = '541'.
  PERFORM set_return_message USING    message
                             CHANGING pr_set.
  IF 1 = 2.
    MESSAGE e541(fn).
  ENDIF.
ENDFORM.                    "AUTHORITYCHECK_F_LFA1_GEN
*----------------------------------------------------------------------*
*       Form  CONV_TO_EXT
*----------------------------------------------------------------------*
*       Konvertieren eines Betragsfeldes intern -> extern              *
*----------------------------------------------------------------------*
*  -->  PR_INTAMOUNT: Betrag intern
*  -->  PR_WAERS    : Währung
*  <--  PR_EXTAMOUNT: Betrag extern
*----------------------------------------------------------------------*
FORM conv_to_ext USING    pr_intamount pr_waers
                 CHANGING pr_extamount.
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
    EXPORTING
      currency        = pr_waers
      amount_internal = pr_intamount
    IMPORTING
      amount_external = pr_extamount
    EXCEPTIONS
      OTHERS          = 1.
ENDFORM.                    "CONV_TO_EXT



*----------------------------------------------------------------------*
*       FORM SET_RETURN_MESSAGE                                        *
*----------------------------------------------------------------------*
*       set return parameter for output
*----------------------------------------------------------------------*
*      -->P_MESSAGE    messageid                                       *
*      <--P_RETURN     RETURN parameter                                *
*----------------------------------------------------------------------*
FORM set_return_message USING    VALUE(p_message) LIKE message
                        CHANGING p_return         LIKE bapireturn.

  CHECK NOT message IS INITIAL.

  CALL FUNCTION 'BALW_BAPIRETURN_GET'
    EXPORTING
      type       = p_message-msgty
      cl         = p_message-msgid
      number     = p_message-msgno
      par1       = p_message-msgv1
      par2       = p_message-msgv2
      par3       = p_message-msgv3
      par4       = p_message-msgv4
    IMPORTING
      bapireturn = p_return
    EXCEPTIONS
      OTHERS     = 1.

ENDFORM.                               " SET_RETURN_MESSAGE

*----------------------------------------------------------------------*
*       FORM SET_RETURN1_MESSAGE                                       *
*----------------------------------------------------------------------*
*       set return parameter for output
*       (Returncode structure BAPIRETURN1)
*----------------------------------------------------------------------*
*      -->P_MESSAGE    messageid                                       *
*      <--P_RETURN     RETURN parameter                                *
*----------------------------------------------------------------------*
FORM set_return1_message USING    VALUE(p_message) LIKE message
                         CHANGING p_return         LIKE bapireturn1.

  CHECK NOT message IS INITIAL.

  CALL FUNCTION 'BALW_BAPIRETURN_GET1'
    EXPORTING
      type       = p_message-msgty
      cl         = p_message-msgid
      number     = p_message-msgno
      par1       = p_message-msgv1
      par2       = p_message-msgv2
      par3       = p_message-msgv3
      par4       = p_message-msgv4
    IMPORTING
      bapireturn = p_return.

ENDFORM.                               " SET_RETURN1_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  MATCHCODEFIELD_FILL
*&---------------------------------------------------------------------*
*       ADD the matchcode field to the WHERE statement
*       OR MCOD<tfmc-fldnr> = '<upper_value>'
*----------------------------------------------------------------------*
*      -->P_KTOID      account type                                    *
*      -->P_FIELDNAME  field name                                      *
*      -->P_FIELDVALUE field value                                     *
*      -->P_P_XLIKE    placeholder used?                               *
*      <--P_TAB_WHERE  WHERE statement                                 *
*----------------------------------------------------------------------*
FORM matchcodefield_fill USING    VALUE(p_ktoid)
                                  p_fieldname
                                  p_fieldvalue
                                  p_p_xlike
                         CHANGING p_tab_where.

  DATA: upper_value LIKE bapi1008_8-fieldvalue.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM tfmc WHERE ktoid = p_ktoid
*                       AND fldnr BETWEEN '1' AND '3'
*                       AND fldna = p_fieldname.
*
* NEW CODE
  SELECT *
 FROM tfmc WHERE ktoid = p_ktoid
                       AND fldnr BETWEEN '1' AND '3'
                       AND fldna = p_fieldname ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDSELECT.
  IF sy-subrc = 0.
    upper_value = p_fieldvalue.
    TRANSLATE upper_value TO UPPER CASE.                 "#EC TRANSLANG
    offset = strlen( p_tab_where ).
    WRITE ' OR ' TO p_tab_where+offset.
    offset = strlen( p_tab_where ).
    WRITE ' MCOD' TO p_tab_where+offset.
    offset = strlen( p_tab_where ).
    WRITE tfmc-fldnr TO p_tab_where+offset.
    offset = strlen( p_tab_where ).
    IF p_p_xlike NE space.
      WRITE ' LIKE ''' TO p_tab_where+offset.
    ELSE.
      WRITE ' = '''    TO p_tab_where+offset.
    ENDIF.
    offset = strlen( p_tab_where ).
    WRITE upper_value(25) TO p_tab_where+offset.
    offset = strlen( p_tab_where ).
    WRITE ''''    TO p_tab_where+offset.
  ENDIF.

ENDFORM.                    " MATCHCODEFIELD_FILL


*&---------------------------------------------------------------------*
*&      Form  UPDATE_ACREEDOR_V2
*&---------------------------------------------------------------------*
*       Consultor FI-CO: Oscar Agudelo Seidor Crystalis
*       Consultor ABAP:  Pablo Cabezas Seidor Crystalis
*----------------------------------------------------------------------*
*      -->P_RETURN  text
*      -->P_TI_BAPI_ACRE  text
*----------------------------------------------------------------------*
FORM update_acreedor_v2  TABLES  return STRUCTURE bapiret2
                         USING   p_ti_acreedor STRUCTURE zacreedor.
*  REFRESH: MESSTAB, BDCDATA.
  DATA: cont_reg TYPE i,
        resul1   TYPE i,
        resul2   TYPE i,
        resul3   TYPE i,
        info     TYPE string,
        iter     TYPE n LENGTH 2.

  DATA: creditor_general_detail LIKE  lfa1,
        creditor_company_detail LIKE  lfb1,
        p_return                LIKE  bapireturn.
  DATA:  creditor_bank_detail     LIKE lfbk OCCURS 0 WITH HEADER LINE.
  DATA:  p_lfbw     LIKE lfbw       OCCURS 0 WITH HEADER LINE.
  DATA:  p_lfza     LIKE lfza       OCCURS 0 WITH HEADER LINE.
  DATA:  pp_return  LIKE bapireturn OCCURS 0 WITH HEADER LINE.
  DATA:  ls_vrsd    LIKE LINE OF pp_return.
  DATA:  num        TYPE c LENGTH 1.
  DATA: lv_lines    TYPE i.
  DATA: lv_num      TYPE n LENGTH 3.
  DATA: lv_cha      TYPE c.
  DATA: lv_bvtyp    TYPE bvtyp.


  CALL FUNCTION 'ZBAPI_CREDITOR_GETDETAIL'
    EXPORTING
      creditorid              = p_ti_acreedor-lifnr
      companycode             = p_ti_acreedor-bukrs
    IMPORTING
      creditor_general_detail = creditor_general_detail
      creditor_company_detail = creditor_company_detail
      return                  = p_return
    TABLES
      creditor_bank_detail    = creditor_bank_detail
      lfbw                    = p_lfbw
      lfza                    = p_lfza.

  SORT creditor_bank_detail BY bvtyp.
  DESCRIBE TABLE creditor_bank_detail LINES lv_lines.
  READ TABLE creditor_bank_detail
              INDEX lv_lines.
  SPLIT creditor_bank_detail-bvtyp AT 'C' INTO lv_cha lv_num.
  ADD 1 TO lv_num.
  CONCATENATE 'C' lv_num INTO lv_bvtyp.
  CONDENSE lv_bvtyp NO-GAPS.

  "CREDITOR_BANK_DETAIL (tabla con la informacion)
  READ TABLE creditor_bank_detail
              WITH KEY bankn = p_ti_acreedor-bankn
                       bankl = p_ti_acreedor-bankl.
*    situaciones 1.- la cuenta no esta registrada
*                2.- la cuenta esta registrada pero le faltan campos
*                3.-  la cuenta esta correctamente registrada
  IF sy-subrc <> 0.
    "caso 1.(Para la situacion 1 se debera registrar
    "una nueva cuenta) mediante la funcion VENDOR_UPDATE

    PERFORM vendor_insert USING p_ti_acreedor
                                lv_bvtyp.

  ELSE.
    IF creditor_bank_detail-bvtyp IS INITIAL OR creditor_bank_detail-bkref IS INITIAL.
      "caso 2. (Para la situacion 2 se debera eliminar la cuenta
      "existente y registrar una nueva cuenta) mediante la funcion VENDOR_UPDATE

      PERFORM vendor_update USING creditor_bank_detail.

      PERFORM vendor_insert USING p_ti_acreedor
                                  lv_bvtyp.
*-> hcd 22012026    ELSE.
      "Caso 3. (Para la situacion 3 no se realizara ningun proceso adicional)
*-> BEG INS V1-CNN ECDK926773 30.09.2025
*-> hcd 22012026        PERFORM vendor_insert USING p_ti_acreedor
*-> hcd 22012026                                    lv_bvtyp.
*-> END INS V1-CNN ECDK926773 30.09.2025
    ENDIF.
  ENDIF.

ENDFORM.                    " UPDATE_ACREEDOR_V2


*&---------------------------------------------------------------------*
*&      Form  VENDOR_INSERT
*&---------------------------------------------------------------------*
*       Consultor FI-CO: Oscar Agudelo Seidor Crystalis
*       Consultor ABAP:  Pablo Cabezas Seidor Crystalis
*----------------------------------------------------------------------*
*      -->P_TI_ACREEDOR  text
*----------------------------------------------------------------------*
FORM vendor_insert  USING    p_ti_acreedor STRUCTURE zacreedor
                             lv_bvtyp .

  DATA: t_lfa1 LIKE lfa1 OCCURS 0 WITH HEADER LINE.
  CLEAR t_lfa1.   CLEAR t_lfa1[].
  DATA: t_lfb1 LIKE lfb1 OCCURS 0 WITH HEADER LINE.
  CLEAR t_lfb1.   CLEAR t_lfb1[].
  DATA: t_lfm1 LIKE lfm1 OCCURS 0 WITH HEADER LINE.
  CLEAR t_lfm1.   CLEAR t_lfm1[].


  DATA: t_xlfas LIKE flfas OCCURS 0 WITH HEADER LINE.
  CLEAR t_xlfas. CLEAR t_xlfas[].
  DATA: t_xlfb5 LIKE flfb5 OCCURS 0 WITH HEADER LINE.
  CLEAR t_xlfb5. CLEAR t_xlfb5[].
  DATA: t_xlfbk LIKE flfbk OCCURS 0 WITH HEADER LINE.
  CLEAR t_xlfbk. CLEAR t_xlfbk[].
  DATA: t_xlfza LIKE flfza OCCURS 0 WITH HEADER LINE.
  CLEAR t_xlfza. CLEAR t_xlfza[].
  DATA: t_xknvk LIKE fknvk OCCURS 0 WITH HEADER LINE.
  CLEAR t_xknvk. CLEAR t_xknvk[].

  CLEAR t_xlfbk. CLEAR t_xlfbk[].
  t_xlfbk-lifnr = p_ti_acreedor-lifnr.
  t_xlfbk-banks = p_ti_acreedor-banks.
  t_xlfbk-bankl = p_ti_acreedor-bankl.
  t_xlfbk-bankn = p_ti_acreedor-bankn.
  t_xlfbk-bkont = p_ti_acreedor-bkont.
*-> BEG MOD V1-CNN ECDK927129 09.12.2025
  IF NOT lv_bvtyp IS INITIAL.
    t_xlfbk-bvtyp = lv_bvtyp.
  ELSE.
    t_xlfbk-bvtyp = p_ti_acreedor-bvtyp.
  ENDIF.
  IF NOT p_ti_acreedor-bkref IS INITIAL.
    t_xlfbk-bkref = p_ti_acreedor-bkref.
  ENDIF.
*-> END MOD V1-CNN ECDK927129 09.12.2025
  t_xlfbk-bkref = p_ti_acreedor-bukrs.
  t_xlfbk-koinh = p_ti_acreedor-koinh.
  APPEND t_xlfbk.

  CALL FUNCTION 'VENDOR_INSERT'
    EXPORTING
      i_lfa1  = t_lfa1
      i_lfb1  = t_lfb1
      i_lfm1  = t_lfm1
    TABLES
      t_xlfas = t_xlfas
      t_xlfb5 = t_xlfb5
      t_xlfbk = t_xlfbk
      t_xlfza = t_xlfza
      t_xknvk = t_xknvk.

  COMMIT WORK.

ENDFORM.                    " VENDOR_INSERT


*&---------------------------------------------------------------------*
*&      Form  VENDOR_UPDATE
*&---------------------------------------------------------------------*
*       Borra la cuenta del maestro.
*       Consultor FI-CO: Oscar Agudelo Seidor Crystalis
*       Consultor ABAP:  Pablo Cabezas Seidor Crystalis
*----------------------------------------------------------------------*
*      -->P_CREDITOR_BANK_DETAIL  text
*----------------------------------------------------------------------*
FORM vendor_update  USING    p_creditor_bank_detail STRUCTURE lfbk.
  DATA: t_lfa1 LIKE lfa1  OCCURS 0 WITH HEADER LINE.
  CLEAR t_lfa1 . CLEAR t_lfa1[].
  DATA: t_lfb1 LIKE lfb1  OCCURS 0 WITH HEADER LINE.
  CLEAR t_lfb1 . CLEAR t_lfb1[].
  DATA: t_lfm1 LIKE lfm1  OCCURS 0 WITH HEADER LINE.
  CLEAR t_lfm1 . CLEAR t_lfm1[].
  DATA: t_ylfa1 LIKE lfa1  OCCURS 0 WITH HEADER LINE.
  CLEAR t_ylfa1. CLEAR t_ylfa1[].
  DATA: t_ylfb1 LIKE lfb1  OCCURS 0 WITH HEADER LINE.
  CLEAR t_ylfb1. CLEAR t_ylfb1[].
  DATA: t_ylfm1 LIKE lfm1  OCCURS 0 WITH HEADER LINE.
  CLEAR t_ylfm1. CLEAR t_ylfm1[].
  DATA: t_xlfas LIKE flfas OCCURS 0 WITH HEADER LINE.
  CLEAR t_xlfas. CLEAR t_xlfas[].
  DATA: t_xlfb5 LIKE flfb5 OCCURS 0 WITH HEADER LINE.
  CLEAR t_xlfb5. CLEAR t_xlfb5[].
  DATA: t_xlfbk LIKE flfbk OCCURS 0 WITH HEADER LINE.
  CLEAR t_xlfbk. CLEAR t_xlfbk[].
  DATA: t_xlfza LIKE flfza OCCURS 0 WITH HEADER LINE.
  CLEAR t_xlfza. CLEAR t_xlfza[].
  DATA: t_ylfas LIKE flfas OCCURS 0 WITH HEADER LINE.
  CLEAR t_ylfas. CLEAR t_ylfas[].
  DATA: t_ylfb5 LIKE flfb5 OCCURS 0 WITH HEADER LINE.
  CLEAR t_ylfb5. CLEAR t_ylfb5[].
  DATA: t_ylfbk LIKE flfbk OCCURS 0 WITH HEADER LINE.
  CLEAR t_ylfbk. CLEAR t_ylfbk[].
  DATA: t_ylfza LIKE flfza OCCURS 0 WITH HEADER LINE.
  CLEAR t_ylfza. CLEAR t_ylfza[].


  CLEAR t_ylfbk.CLEAR t_ylfbk[].

  t_ylfbk-lifnr = p_creditor_bank_detail-lifnr.
  t_ylfbk-banks = p_creditor_bank_detail-banks.
  t_ylfbk-bankl = p_creditor_bank_detail-bankl.
  t_ylfbk-bankn = p_creditor_bank_detail-bankn.
  t_ylfbk-bkont = p_creditor_bank_detail-bkont.
*-> BEG INS V1-CNN ECDK926773 30.09.2025
  t_ylfbk-bvtyp = p_creditor_bank_detail-bvtyp.
  t_ylfbk-bkref = p_creditor_bank_detail-bkref.
*-> END INS V1-CNN ECDK926773 30.09.2025
  APPEND t_ylfbk.

  CALL FUNCTION 'VENDOR_UPDATE'
    EXPORTING
      i_lfa1  = t_lfa1
      i_lfb1  = t_lfb1
      i_lfm1  = t_lfm1
      i_ylfa1 = t_ylfa1
      i_ylfb1 = t_ylfb1
      i_ylfm1 = t_ylfm1
    TABLES
      t_xlfas = t_xlfas
      t_xlfb5 = t_xlfb5
      t_xlfbk = t_xlfbk
      t_xlfza = t_xlfza
      t_ylfas = t_ylfas
      t_ylfb5 = t_ylfb5
      t_ylfbk = t_ylfbk "T_YLFBK
      t_ylfza = t_ylfza.
*     T_XKNVK =
*     T_YKNVK =

  COMMIT WORK.

ENDFORM.                    " VENDOR_UPDATE

"
FORM update_acreedor2  TABLES  return STRUCTURE bapiret2
                        USING   p_ti_acreedor STRUCTURE zacreedor.
  REFRESH: messtab, bdcdata.
  DATA: cont_reg TYPE i,
        resul1   TYPE i,
        resul2   TYPE i,
        resul3   TYPE i,
        info     TYPE string,
        iter(2)  TYPE n.


  DATA: creditor_general_detail LIKE  lfa1,
        creditor_company_detail LIKE  lfb1,
        p_return                LIKE  bapireturn.
  DATA:  creditor_bank_detail  LIKE lfbk OCCURS 0 WITH HEADER LINE.
  DATA:  p_lfbw     LIKE lfbw OCCURS 0 WITH HEADER LINE.
  DATA:  p_lfza     LIKE lfza OCCURS 0 WITH HEADER LINE.
  DATA:  pp_return  LIKE  bapireturn OCCURS 0 WITH HEADER LINE.
  DATA: ls_vrsd LIKE LINE OF pp_return.


  DATA: dympro_c(132)  TYPE c,
        dympro_c2(132) TYPE c,
        num(1)         TYPE c.


  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0106'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'RF02K-D0610'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.
  PERFORM bdc_field       USING 'RF02K-LIFNR'            p_ti_acreedor-lifnr.
  PERFORM bdc_field       USING 'RF02K-BUKRS'            p_ti_acreedor-bukrs.
  PERFORM bdc_field       USING 'RF02K-D0110'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0120'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0130'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0210'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0215'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0220'            'X'.
  PERFORM bdc_field       USING 'RF02K-D0610'            'X'.


  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0111'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '=$2OC'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'SZA1_D0100-TITLE_MEDI'.
  PERFORM bdc_field       USING 'SZA1_D0100-TITLE_MEDI'  p_ti_acreedor-title.
  PERFORM bdc_field       USING 'ADDR1_DATA-NAME1'       p_ti_acreedor-name1.
  IF p_ti_acreedor-name2 IS INITIAL.
    p_ti_acreedor-name2 = '  '.
  ENDIF.
  PERFORM bdc_field       USING 'ADDR1_DATA-NAME2'       p_ti_acreedor-name2.
  PERFORM bdc_field       USING 'ADDR1_DATA-SORT1'       p_ti_acreedor-sort1.
  PERFORM bdc_field       USING 'ADDR1_DATA-SORT2'       p_ti_acreedor-sort2.

  PERFORM bdc_field       USING 'ADDR1_DATA-STREET'      p_ti_acreedor-street.
  PERFORM bdc_field       USING 'ADDR1_DATA-HOUSE_NUM1'  p_ti_acreedor-house_num1.
  PERFORM bdc_field       USING 'ADDR1_DATA-CITY2'       p_ti_acreedor-ort02.
  PERFORM bdc_field       USING 'ADDR1_DATA-CITY1'       p_ti_acreedor-ort01.
  PERFORM bdc_field       USING 'ADDR1_DATA-PO_BOX'       p_ti_acreedor-po_box.

  PERFORM bdc_field   USING 'SZA1_D0100-TEL_NUMBER'    p_ti_acreedor-tel_number.
  PERFORM bdc_field   USING 'SZA1_D0100-TEL_EXTENS'    p_ti_acreedor-tel1_ext.
  PERFORM bdc_field   USING 'SZA1_D0100-FAX_NUMBER'    p_ti_acreedor-telfax.
  PERFORM bdc_field   USING 'SZA1_D0100-FAX_EXTENS'    p_ti_acreedor-fax_extens.
  PERFORM bdc_field   USING 'SZA1_D0100-SMTP_ADDR'     p_ti_acreedor-smtp_addr.


  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0111'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'SZA1_D0100-TITLE_MEDI'.

  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0120'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'LFA1-BRSCH'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.

  CALL FUNCTION 'ZBAPI_CREDITOR_GETDETAIL'
    EXPORTING
      creditorid              = p_ti_acreedor-lifnr
      companycode             = p_ti_acreedor-bukrs
    IMPORTING
      creditor_general_detail = creditor_general_detail
      creditor_company_detail = creditor_company_detail
      return                  = p_return
    TABLES
      creditor_bank_detail    = creditor_bank_detail
      lfbw                    = p_lfbw
      lfza                    = p_lfza.

  IF p_ti_acreedor-empfk NE space.
    IF p_return-type NE 'E'.
      DESCRIBE TABLE p_lfza LINES  cont_reg.
      IF cont_reg > 0.
        resul1 = cont_reg / 7.
        IF resul1 >= 2.
          resul2 = resul1 * 7.
        ENDIF.
        resul3 = cont_reg - resul2 + 1.
        IF resul3 > 7.
          ADD 1 TO  resul1.
          resul3 = 1.
        ENDIF.

        num = resul3.
        dympro_c = 'LFZA-EMPFK'.

        IF resul1 >= 2.
          IF p_ti_acreedor-banks IS NOT INITIAL
             AND p_ti_acreedor-bankl IS NOT INITIAL
             AND p_ti_acreedor-bankn IS NOT INITIAL.
            LOOP AT creditor_bank_detail.
              PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
              PERFORM bdc_field       USING 'BDC_CURSOR'
                                            'LFBK-BANKS(01)'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '=BDEL'.
            ENDLOOP.
          ENDIF.

          PERFORM bdc_dynpro      USING 'SAPMF02K'               '0130'.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=LFZA'.
          PERFORM bdc_field       USING 'LFBK-BANKS(01)'  p_ti_acreedor-banks.
          PERFORM bdc_field       USING 'LFBK-BANKL(01)'  p_ti_acreedor-bankl.
          PERFORM bdc_field       USING 'LFBK-BANKN(01)'  p_ti_acreedor-bankn.
          PERFORM bdc_field       USING 'LFBK-KOINH(01)'  p_ti_acreedor-koinh.
          PERFORM bdc_field       USING 'LFBK-BKONT(01)'  p_ti_acreedor-bkont.


          resul1 = resul1 - 1.
          DO resul1 TIMES.
            PERFORM bdc_dynpro      USING 'SAPMF02K'               '1130'.
            PERFORM bdc_field       USING 'BDC_CURSOR'             'LFZA-EMPFK(01)'.
            PERFORM bdc_field       USING 'BDC_OKCODE'             '=P+'.
          ENDDO.

          PERFORM bdc_dynpro      USING 'SAPMF02K'               '1130'.
          CONCATENATE  dympro_c '(' num  ')'  INTO dympro_c2.
          PERFORM bdc_field       USING  dympro_c2               p_ti_acreedor-empfk.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=BACK'.

          PERFORM bdc_dynpro      USING 'SAPMF02K'     '0130'.
          PERFORM bdc_field       USING 'BDC_CURSOR'   'LFBK-BANKS(01)'.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=VW'.


        ELSE.
          IF p_ti_acreedor-banks IS NOT INITIAL
             AND p_ti_acreedor-bankl IS NOT INITIAL
             AND p_ti_acreedor-bankn IS NOT INITIAL.
            LOOP AT creditor_bank_detail.
              PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
              PERFORM bdc_field       USING 'BDC_CURSOR'
                                            'LFBK-BANKS(01)'.
              PERFORM bdc_field       USING 'BDC_OKCODE'
                                            '=BDEL'.
            ENDLOOP.
          ENDIF.
          PERFORM bdc_dynpro      USING 'SAPMF02K'               '0130'.
          PERFORM bdc_field       USING 'BDC_CURSOR'             'LFBK-BANKS(01)'.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=LFZA'.

          PERFORM bdc_field       USING 'LFBK-BANKS(01)'  p_ti_acreedor-banks.
          PERFORM bdc_field       USING 'LFBK-BANKL(01)'  p_ti_acreedor-bankl.
          PERFORM bdc_field       USING 'LFBK-BANKN(01)'  p_ti_acreedor-bankn.
          PERFORM bdc_field       USING 'LFBK-KOINH(01)'  p_ti_acreedor-koinh.
          PERFORM bdc_field       USING 'LFBK-BKONT(01)'  p_ti_acreedor-bkont.

          CONCATENATE  dympro_c '(' num  ')'  INTO dympro_c2.
          PERFORM bdc_dynpro      USING 'SAPMF02K'               '1130'.
          PERFORM bdc_field       USING  dympro_c2               p_ti_acreedor-empfk.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=BACK'.

          PERFORM bdc_dynpro      USING 'SAPMF02K'     '0130'.
          PERFORM bdc_field       USING 'BDC_CURSOR'   'LFBK-BANKS(01)'.
          PERFORM bdc_field       USING 'BDC_OKCODE'             '=VW'.

        ENDIF.
      ELSE.
        num = 1.
        IF p_ti_acreedor-banks IS NOT INITIAL
             AND p_ti_acreedor-bankl IS NOT INITIAL
             AND p_ti_acreedor-bankn IS NOT INITIAL.
          LOOP AT creditor_bank_detail.
            PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
            PERFORM bdc_field       USING 'BDC_CURSOR'
                                          'LFBK-BANKS(01)'.
            PERFORM bdc_field       USING 'BDC_OKCODE'
                                          '=BDEL'.
          ENDLOOP.
        ENDIF.
        PERFORM bdc_dynpro      USING 'SAPMF02K'               '0130'.
        PERFORM bdc_field       USING 'BDC_CURSOR'             'LFZA-EMPFK(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'             '=LFZA'.

        PERFORM bdc_field       USING 'LFBK-BANKS(01)'  p_ti_acreedor-banks.
        PERFORM bdc_field       USING 'LFBK-BANKL(01)'  p_ti_acreedor-bankl.
        PERFORM bdc_field       USING 'LFBK-BANKN(01)'  p_ti_acreedor-bankn.
        PERFORM bdc_field       USING 'LFBK-KOINH(01)'  p_ti_acreedor-koinh.
        PERFORM bdc_field       USING 'LFBK-BKONT(01)'  p_ti_acreedor-bkont.

        PERFORM bdc_dynpro      USING 'SAPMF02K'               '1130'.
        CONCATENATE  dympro_c '(' num  ')'  INTO dympro_c2.
        PERFORM bdc_field       USING  dympro_c2               p_ti_acreedor-empfk.
        PERFORM bdc_field       USING 'BDC_OKCODE'             '=BACK'.

        PERFORM bdc_dynpro      USING 'SAPMF02K'     '0130'.
        PERFORM bdc_field       USING 'BDC_CURSOR'   'LFBK-BANKS(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'             '=VW'.

      ENDIF.
    ENDIF.
  ENDIF.

  IF p_ti_acreedor-empfk EQ space.
    IF p_ti_acreedor-banks IS NOT INITIAL
             AND p_ti_acreedor-bankl IS NOT INITIAL
             AND p_ti_acreedor-bankn IS NOT INITIAL.
      LOOP AT creditor_bank_detail.
        PERFORM bdc_dynpro      USING 'SAPMF02K' '0130'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'LFBK-BANKS(01)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=BDEL'.
      ENDLOOP.
    ENDIF.
    PERFORM bdc_dynpro      USING 'SAPMF02K'               '0130'.
    PERFORM bdc_field       USING 'BDC_CURSOR'             'LFBK-BANKS(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.

    PERFORM bdc_field       USING 'LFBK-BANKS(01)'  p_ti_acreedor-banks.
    PERFORM bdc_field       USING 'LFBK-BANKL(01)'  p_ti_acreedor-bankl.
    PERFORM bdc_field       USING 'LFBK-BANKN(01)'  p_ti_acreedor-bankn.
    PERFORM bdc_field       USING 'LFBK-KOINH(01)'  p_ti_acreedor-koinh.
    PERFORM bdc_field       USING 'LFBK-BKONT(01)'  p_ti_acreedor-bkont.
    PERFORM bdc_field       USING 'BDC_OKCODE'             '=VW'.
  ENDIF.



  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0210'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'LFB1-AKONT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.
  PERFORM bdc_field       USING 'LFB1-AKONT'             p_ti_acreedor-akont.
  PERFORM bdc_field       USING 'LFB1-ZUAWA'             p_ti_acreedor-zuawa.
  PERFORM bdc_field       USING 'LFB1-FDGRV'             p_ti_acreedor-fdgrv.

  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0215'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'LFB1-ZTERM'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.
  PERFORM bdc_field       USING 'LFB1-ZTERM'             p_ti_acreedor-zterm1.
  PERFORM bdc_field       USING 'LFB1-REPRF'             'X'. "Factura Doble Acreedores.
  IF p_ti_acreedor-bukrs EQ 'CL01' OR p_ti_acreedor-bukrs EQ 'CL24'.
    p_ti_acreedor-zgrup = 'Z1'.
  ENDIF.
  PERFORM bdc_field       USING 'LFB1-ZGRUP'             p_ti_acreedor-zgrup.

  PERFORM bdc_field       USING 'LFB1-ZWELS'             p_ti_acreedor-zwels.
  PERFORM bdc_field       USING 'LFB1-ZAHLS'             p_ti_acreedor-zahls.

  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0220'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'LFB5-MAHNA'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.

  PERFORM bdc_dynpro      USING 'SAPMF02K'               '0610'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'             'LFB1-QLAND'.

  PERFORM bdc_dynpro      USING 'SAPLSPO1'               '0300'.
  PERFORM bdc_field       USING 'BDC_OKCODE'             '=YES'.

  DATA: ctumode LIKE ctu_params-dismode VALUE 'N'.
  DATA: cupdate LIKE ctu_params-updmode VALUE 'L'.
  DATA opt TYPE ctu_params.
  opt-nobinpt = 'X'.
  opt-dismode = ctumode.
  opt-updmode = cupdate.

  CALL TRANSACTION 'FK02' USING bdcdata
                    OPTIONS FROM opt
                   MESSAGES INTO messtab.



  DATA: BEGIN OF itlog OCCURS 0,
          texto(100),
        END OF itlog.

  DATA: v_texto LIKE t100-text,
        v_msgid LIKE sy-msgid,
        v_msgno LIKE sy-msgno,
        v_msgv1 LIKE sy-msgv1,
        v_msgv2 LIKE sy-msgv2,
        v_msgv3 LIKE sy-msgv3,
        v_msgv4 LIKE sy-msgv4.

  LOOP AT messtab WHERE msgid NE 'I'.

    v_msgid = messtab-msgid.
    v_msgno = messtab-msgnr.
    v_msgv1 = messtab-msgv1.
    v_msgv2 = messtab-msgv2.
    v_msgv3 = messtab-msgv3.
    v_msgv4 = messtab-msgv4.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE text
*      INTO  v_texto
*       FROM t100 WHERE sprsl = sy-langu
*                   AND arbgb = v_msgid
*                   AND msgnr = v_msgno.
*
* NEW CODE
    SELECT text
    UP TO 1 ROWS 
      INTO  v_texto
       FROM t100 WHERE sprsl = sy-langu
                   AND arbgb = v_msgid
                   AND msgnr = v_msgno ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      DATA:
        maximum_length TYPE i,
        hlp_text(100)  TYPE c,
        msgv_no(1)     TYPE c,
        offset         TYPE i,
        index          TYPE i,
        strl           LIKE sy-fdpos,
        p_fdpos        LIKE sy-fdpos.

      DESCRIBE FIELD v_texto LENGTH maximum_length IN CHARACTER MODE.
      hlp_text = v_texto.
      CLEAR v_texto.

      offset = 0.
      DO 4 TIMES.
        SEARCH hlp_text FOR '&'.
        IF sy-subrc <> 0. EXIT. ENDIF.
        IF sy-fdpos <> 0.
          CHECK offset < maximum_length.
          MOVE hlp_text(sy-fdpos) TO v_texto+offset.
          offset = offset + sy-fdpos.
        ENDIF.
        index = sy-fdpos + 1.
        SHIFT hlp_text BY index PLACES LEFT.
        p_fdpos  = sy-fdpos.
        IF hlp_text(1) CO '1234'.
          msgv_no = hlp_text(1).
          SHIFT hlp_text BY 1 PLACES LEFT.
        ELSE.
          msgv_no = sy-index.
        ENDIF.
        CHECK offset < maximum_length.
        CASE msgv_no.
          WHEN 1.
            WRITE v_msgv1 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv1 ).

          WHEN 2.
            WRITE v_msgv2 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv2 ).
          WHEN 3.
            WRITE v_msgv3 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv3 ).
          WHEN 4.
            WRITE v_msgv4 TO v_texto+offset LEFT-JUSTIFIED.
            strl = strlen( v_msgv4 ).
        ENDCASE.
        offset = offset + strl.
      ENDDO.



      IF offset < maximum_length.
        sy-fdpos = strlen( hlp_text ).
        IF sy-fdpos <> 0.
          MOVE hlp_text(sy-fdpos) TO v_texto+offset.
        ENDIF.
      ENDIF.

      return-message_v1 = v_texto+0(50).
      return-message_v2 = v_texto+50(13).

      return-type              = messtab-msgtyp.
      return-id                = '01'.
      APPEND return.
      CLEAR: return.


    ENDIF.
  ENDLOOP.



ENDFORM.                    " UPDATE_ACREEDOR
