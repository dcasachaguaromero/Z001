*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <27-12-2019> *
*& Transport Number: < ECDK916984 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZSDJOBFAC_F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OPT_JOB_FAC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM opt_job_fac .

  PERFORM select_data.
  LOOP AT gt_cabpedext INTO ls_cabpedext.
    CLEAR pos_ti.
    pos_ti = sy-tabix.
    PERFORM facturacion USING ls_cabpedext
                              pos_ti.

    MODIFY gt_cabpedext FROM ls_cabpedext.
  ENDLOOP.
  PERFORM final_check.

ENDFORM.                    " OPT_JOB_FAC
*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_data .
  DATA: ti_ztdea TYPE TABLE OF ztdea,
        wa_ztdea TYPE ztdea.
  RANGES r_error        FOR zcabpedext-error.
  RANGES r_error_e      FOR zcabpedext-error_e.
  FREE r_fecfaccon.
  CLEAR r_fecfaccon.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*    INTO TABLE ti_ztdea
*    FROM ztdea
*    WHERE dea = p_elec.
*
* NEW CODE
  SELECT *

    INTO TABLE ti_ztdea
    FROM ztdea
    WHERE dea = p_elec ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  SORT ti_ztdea BY blart.
  IF p_monat NE space.
    wa_fecfaccon-sign   = 'I'.
    wa_fecfaccon-option = 'BT'.
    CONCATENATE sy-datum(4) p_monat '01' INTO wa_fecfaccon-low.

    CLEAR tmp_date.
    tmp_date = wa_fecfaccon-low.
    CALL FUNCTION 'SG_PS_GET_LAST_DAY_OF_MONTH'
      EXPORTING
        day_in            = tmp_date
      IMPORTING
        last_day_of_month = wa_fecfaccon-high
      EXCEPTIONS
        day_in_not_valid  = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    APPEND wa_fecfaccon TO r_fecfaccon.
    CLEAR wa_fecfaccon.
  ENDIF.
  FREE: r_error_e, r_error.
  IF p_error NE space.
    r_error-sign   = 'I'.
    r_error-option = 'EQ'.
    r_error-low    = true.
    APPEND r_error.
  ENDIF.
  IF p_err_e NE space.
    r_error_e-sign   = 'I'.
    r_error_e-option = 'EQ'.
    r_error_e-low    = true.
    APPEND r_error_e.
  ENDIF.

  CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*    INTO wa_zcabpedext
*    FROM zcabpedext WHERE znum_doc_core IN so_n_cor
*                                 AND zblart        IN so_blart
*                                 AND fecventes     IN so_fp
*                                 AND zlsch         IN so_via
*                                 AND fecfaccon     IN r_fecfaccon
*                                 AND fec_car       IN so_f_c
*                                 AND hor_car       IN so_h_c.
*
* NEW CODE
  SELECT *

    INTO wa_zcabpedext
    FROM zcabpedext WHERE znum_doc_core IN so_n_cor
                                 AND zblart        IN so_blart
                                 AND fecventes     IN so_fp
                                 AND zlsch         IN so_via
                                 AND fecfaccon     IN r_fecfaccon
                                 AND fec_car       IN so_f_c
                                 AND hor_car       IN so_h_c ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    READ TABLE ti_ztdea INTO wa_ztdea
    WITH KEY blart = wa_zcabpedext-zblart BINARY SEARCH.
    IF sy-subrc EQ 0.
      CASE true.
        WHEN p_spr.
          CHECK wa_zcabpedext-pedido  EQ space AND
                wa_zcabpedext-factura EQ space AND
                wa_zcabpedext-pedido  EQ space AND
                wa_zcabpedext-factura EQ space.
        WHEN p_error.
          IF wa_zcabpedext-error_e NE space.
            CHECK wa_zcabpedext-error_e EQ p_err_e.
          ELSE.
            CHECK wa_zcabpedext-error EQ p_error.
          ENDIF.
        WHEN p_err_e.
          IF p_err_e EQ true.
            CHECK wa_zcabpedext-error_e IN r_error_e.
          ENDIF.
      ENDCASE.

      IF wa_zcabpedext-factura EQ space AND
         wa_zcabpedext-pedido  EQ space.
        ADD 1 TO doctoproc.
      ENDIF.

      MOVE-CORRESPONDING wa_zcabpedext TO ls_cabpedext.
      CASE ls_cabpedext-zblart.
        WHEN 'G1'.
          ls_cabpedext-descrip = TEXT-001. "'Factura afecta'.
        WHEN 'G2'.
          ls_cabpedext-descrip = TEXT-002. "'Factura exenta'.
        WHEN 'G3'.
          ls_cabpedext-descrip = TEXT-003. "'Fac. Afec. Elec.'.
        WHEN 'G4'.
          ls_cabpedext-descrip = TEXT-004. "'Fac. Exen. Elec.'.
        WHEN 'J1'.
          ls_cabpedext-descrip = TEXT-005. "'NC Afecta'.
        WHEN 'J2'.
          ls_cabpedext-descrip = TEXT-006. "'NC Exenta'.
        WHEN 'J3'.
          ls_cabpedext-descrip = TEXT-007. "'NC Afecta Elec.'.
        WHEN 'J4'.
          ls_cabpedext-descrip = TEXT-008. "'NC Exenta Elec.'.
        WHEN 'L1'.
          ls_cabpedext-descrip = TEXT-009. "'ND Afecta'.
        WHEN 'L2'.
          ls_cabpedext-descrip = TEXT-010. "'ND Exenta'.
        WHEN 'L3'.
          ls_cabpedext-descrip = TEXT-011. "'ND Afecta Elec.'.
        WHEN 'L4'.
          ls_cabpedext-descrip = TEXT-012. "'ND Exenta Elec.'.
        WHEN 'O1'.
          ls_cabpedext-descrip = TEXT-013. "'Boleta Afecta'.
        WHEN 'O2'.
          ls_cabpedext-descrip = TEXT-014. "'Boleta Exenta'.
        WHEN 'O3'.
          ls_cabpedext-descrip = TEXT-015. "'Boleta Afecta Elec.'.
        WHEN 'O4'.
          ls_cabpedext-descrip = TEXT-016. "'Boleta Exenta Elec.'.
      ENDCASE.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE kunnr
*       INTO ls_cabpedext-kunnr
*       FROM kna1
*       WHERE stcd1 EQ wa_zcabpedext-zrut_cli_pagador.
*
* NEW CODE
      SELECT kunnr
      UP TO 1 ROWS 
       INTO ls_cabpedext-kunnr
       FROM kna1
       WHERE stcd1 EQ wa_zcabpedext-zrut_cli_pagador ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE kunnr
*        INTO ls_cabpedext-kunnr_cli_fact
*        FROM kna1
*        WHERE stcd1 EQ wa_zcabpedext-zrut_cli_fact.
*
* NEW CODE
      SELECT kunnr
      UP TO 1 ROWS 
        INTO ls_cabpedext-kunnr_cli_fact
        FROM kna1
        WHERE stcd1 EQ wa_zcabpedext-zrut_cli_fact ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF ls_cabpedext-factura EQ space AND
     NOT ls_cabpedext-pedido  IS INITIAL.
        CLEAR vbfa-vbelv.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_cabpedext-pedido
          IMPORTING
            output = vbfa-vbelv.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE vbeln
*         INTO vbfa-vbeln
*         FROM vbfa
*         WHERE vbelv EQ vbfa-vbelv.
*
* NEW CODE
        SELECT vbeln
        UP TO 1 ROWS 
         INTO vbfa-vbeln
         FROM vbfa
         WHERE vbelv EQ vbfa-vbelv ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          ls_cabpedext-factura = vbfa-vbeln.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE xblnr
*            INTO ls_cabpedext-folio
*            FROM vbrk
*            WHERE vbeln EQ vbfa-vbeln.
*
* NEW CODE
          SELECT xblnr
          UP TO 1 ROWS 
            INTO ls_cabpedext-folio
            FROM vbrk
            WHERE vbeln EQ vbfa-vbeln ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          ls_cabpedext-error     = space.
          ls_cabpedext-error_e   = space.
          ls_cabpedext-log_error = space.
        ELSE.
          ls_cabpedext-error     = true.
          ls_cabpedext-error_e   = space.
          ls_cabpedext-log_error = TEXT-017."'No se ha creado la factura.
        ENDIF.
      ENDIF.

      IF ( NOT ls_cabpedext-factura IS INITIAL AND
           NOT ls_cabpedext-pedido  IS INITIAL ) AND
               ls_cabpedext-error NE true.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_cabpedext-factura
          IMPORTING
            output = gv_vbeln.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM bkpf WHERE awtyp = gv_vbrk
*                                    AND awkey = gv_vbeln.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM bkpf WHERE awtyp = gv_vbrk
                                    AND awkey = gv_vbeln ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc NE 0.
          ls_cabpedext-error     = true.
          ls_cabpedext-error_e   = space.
          CONCATENATE TEXT-019 "'El documento'
                      ls_cabpedext-znum_doc_core
                      TEXT-021 "'no pudo contabilizarse'
                 INTO ls_cabpedext-log_error SEPARATED BY space.
        ELSE.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_cabpedext-factura
            IMPORTING
              output = vbfa-vbeln.

          REFRESH tmp_nast.
          SELECT kappl erdat eruhr cmfpnr
            FROM nast
            INTO wa_nast
            WHERE kappl EQ 'V3'
              AND objky EQ vbfa-vbeln
            ORDER BY erdat eruhr DESCENDING.

            READ TABLE tmp_nast INTO ls_tmp_nast INDEX 1.
            IF sy-subrc NE 0.
              MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
              APPEND ls_tmp_nast TO tmp_nast.
            ELSE.
              IF ls_tmp_nast-erdat < wa_nast-erdat.
                MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
                MODIFY tmp_nast FROM ls_tmp_nast INDEX 1.
              ELSEIF ls_tmp_nast-erdat = wa_nast-erdat AND
                     ls_tmp_nast-eruhr <  wa_nast-eruhr.
                MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
                MODIFY tmp_nast FROM ls_tmp_nast INDEX 1.
              ENDIF.
            ENDIF.
          ENDSELECT.

          READ TABLE tmp_nast INTO ls_tmp_nast INDEX 1.
          IF sy-subrc NE 0.
            ls_cabpedext-error     = space.
            ls_cabpedext-error_e   = true.
            CONCATENATE TEXT-019 "'El documento'
                        ls_cabpedext-znum_doc_core
                        TEXT-020 " 'no se ha enviado a Acepta'
                   INTO ls_cabpedext-log_error SEPARATED BY space.
          ELSE.
            CLEAR ls_cabpedext-log_error.
            wa_nast-cmfpnr = ls_tmp_nast-cmfpnr.
            SELECT msgcnt msgv1 msgv2 msgv3 msgv4
              INTO wa_cmfp
              FROM cmfp
              WHERE aplid = 'WFMC'
              AND nr    = wa_nast-cmfpnr
              AND msgty = 'E'
              ORDER BY msgcnt DESCENDING.
            ENDSELECT.
            IF sy-subrc = 0.
              IF wa_cmfp-msgty EQ 'E'.
                CONCATENATE wa_cmfp-msgv1
                            wa_cmfp-msgv2
                            wa_cmfp-msgv3
                            wa_cmfp-msgv4
                INTO ls_cabpedext-log_error.
                ls_cabpedext-error     = space.
                ls_cabpedext-error_e   = true.
              ELSE.
                ls_cabpedext-error     = space.
                ls_cabpedext-error_e   = space.
                ls_cabpedext-log_error = space.

                sdc = space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*                SELECT SINGLE xblnr
*                  INTO ls_cabpedext-folio
*                  FROM bkpf
*                  WHERE awtyp EQ gv_vbrk
*                    AND awkey EQ ls_cabpedext-factura.
*
* NEW CODE
                SELECT xblnr
                UP TO 1 ROWS 
                  INTO ls_cabpedext-folio
                  FROM bkpf
                  WHERE awtyp EQ gv_vbrk
                    AND awkey EQ ls_cabpedext-factura ORDER BY PRIMARY KEY.

                ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
                IF sy-subrc NE 0.
                  ls_cabpedext-error     = true.
                  ls_cabpedext-error_e   = space.
                  ls_cabpedext-log_error = TEXT-018.
                  "'Error al procesar documento contanble en SAP'.
                ENDIF.
              ENDIF.
            ELSE.
              ls_cabpedext-error     = space.
              ls_cabpedext-error_e   = true.
              CONCATENATE TEXT-019 "'El documento'
                          ls_cabpedext-znum_doc_core
                          TEXT-020 " 'no se ha enviado a Acepta'
                     INTO ls_cabpedext-log_error SEPARATED BY space.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ls_cabpedext-folio EQ ls_cabpedext-factura.
        CLEAR ls_cabpedext-folio.
      ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE xblnr
*        INTO ls_cabpedext-folio
*        FROM vbrk
*        WHERE vbeln EQ ls_cabpedext-factura.
*
* NEW CODE
      SELECT xblnr
      UP TO 1 ROWS 
        INTO ls_cabpedext-folio
        FROM vbrk
        WHERE vbeln EQ ls_cabpedext-factura ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc EQ 0.
        ls_cabpedext-folio(2) = space.
        CONDENSE ls_cabpedext-folio.
      ENDIF.

      IF ls_cabpedext-pedido EQ space AND ls_cabpedext-factura EQ space
      AND ls_cabpedext-error EQ space AND ls_cabpedext-error_e EQ space.
        name   = 'ICON_LED_YELLOW'.
        info   = TEXT-028."'Documento sin tratar'.
        name_e = 'ICON_LED_YELLOW'.
        info_e = TEXT-028."'Documento sin tratar'.
      ELSE.
        CASE ls_cabpedext-error.
          WHEN true.
            name   = 'ICON_LED_RED'.
            info   = TEXT-022. "'Documento SAP con error'.
            name_e   = 'ICON_LED_YELLOW'.
            info_e   = TEXT-023. "'Documento Electrónico sin tratar'.
          WHEN space.
            name   = 'ICON_LED_GREEN'.
            info   = TEXT-024. "'Documento SAP tratado'.
          WHEN '*'.
            name   = 'ICON_LED_YELLOW'.
            info   = TEXT-025. "'Documento SAP sin tratar'.
            name_e = 'ICON_LED_YELLOW'.
            info_e = TEXT-023. "'Documento Electrónico sin tratar'.
        ENDCASE.

        IF name = 'ICON_LED_GREEN'.
          CASE ls_cabpedext-error_e.
            WHEN true.
              name_e   = 'ICON_LED_RED'.
              info_e   = TEXT-026. "'Documento Electrónico con error'.
            WHEN OTHERS.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE * FROM ztdea
*                WHERE blart EQ ls_cabpedext-zblart
*                  AND dea   EQ true.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  FROM ztdea
                WHERE blart EQ ls_cabpedext-zblart
                  AND dea   EQ true ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              IF sy-subrc = 0.
                CASE ls_cabpedext-error_e.
                  WHEN space.
                    name_e   = 'ICON_LED_GREEN'.
                    info_e   = TEXT-027. "'Documento Electrónico tratado'.
                  WHEN '*'.
                    name_e   = 'ICON_LED_YELLOW'.
                    info_e   = TEXT-023."Documento Electrónico sin tratar
                ENDCASE.
              ELSE.
                name_e   = 'ICON_LED_YELLOW'.
                info_e   = TEXT-029. "'No se envía a Acepta'.
                ls_cabpedext-error_e   = '*'.
                IF ls_cabpedext-error EQ space.
                  ls_cabpedext-log_error = TEXT-030.
                  "'Este tipo de documentos no se envía a Acepta. Ver transacción ZTDEA'.
                ELSE.
                  ls_cabpedext-log_error = ls_cabpedext-log_error.
                ENDIF.
              ENDIF.
          ENDCASE.
        ENDIF.
      ENDIF.

      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = name
          info                  = info
          add_stdinf            = space
        IMPORTING
          result                = ls_cabpedext-status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = name_e
          info                  = info_e
          add_stdinf            = space
        IMPORTING
          result                = ls_cabpedext-status_elec
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.

      APPEND ls_cabpedext TO gt_cabpedext.
      CLEAR ls_cabpedext.
    ENDIF.
  ENDSELECT.
ENDFORM.                    " SELECT_DATA
*&---------------------------------------------------------------------*
*&      Form  FACTURACION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_CABPEDEXT  text
*      -->P_SY_TABIX  text
*----------------------------------------------------------------------*
FORM facturacion  USING ls_cabpedext TYPE ty
                        ls_selected_row_row_id.

  DATA: zurl    TYPE zfac_anex-zurl,
        c_rfbsk TYPE vbrk-rfbsk.
  DATA: vl_soc    TYPE bkpf-bukrs,
        c_mensaje TYPE char100,
        lv_dea    TYPE ztdea-dea.

  IF NOT ls_cabpedext-factura IS INITIAL.
    CLEAR st_bkpf.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE bukrs belnr gjahr
*           INTO st_bkpf
*           FROM bkpf
*           WHERE awtyp EQ gv_vbrk
*             AND awkey EQ ls_cabpedext-factura.
*
* NEW CODE
    SELECT bukrs belnr gjahr
    UP TO 1 ROWS 
           INTO st_bkpf
           FROM bkpf
           WHERE awtyp EQ gv_vbrk
             AND awkey EQ ls_cabpedext-factura ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
      CLEAR tmp_url.
      SELECT zurl INTO tmp_url UP TO 1 ROWS
        FROM zfac_anex
        WHERE bukrs = st_bkpf-bukrs
          AND belnr = st_bkpf-belnr
          AND gjahr = st_bkpf-gjahr
          ORDER BY PRIMARY KEY.
      ENDSELECT.
      IF NOT tmp_url IS INITIAL.
        MESSAGE i899(mm) WITH TEXT-t18 "'El documento'
                              ls_cabpedext-znum_doc_core
                              TEXT-t21.
        "'fue procesado/normado completamente'.
        CHECK 1 = 2.
      ELSE.
        CLEAR lv_dea.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE dea  INTO lv_dea
*          FROM ztdea  WHERE blart = ls_cabpedext-zblart.
*
* NEW CODE
        SELECT dea
        UP TO 1 ROWS   INTO lv_dea
          FROM ztdea  WHERE blart = ls_cabpedext-zblart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF NOT lv_dea IS INITIAL.
          CLEAR vl_soc.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE bukrs INTO vl_soc
*            FROM vbrk  WHERE vbeln EQ ls_cabpedext-factura.
*
* NEW CODE
          SELECT bukrs
          UP TO 1 ROWS  INTO vl_soc
            FROM vbrk  WHERE vbeln EQ ls_cabpedext-factura ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

***Repetimos clase de mensaje ZFAE
          SUBMIT zsdrepmsg WITH p_vbeln EQ ls_cabpedext-factura
                                AND RETURN.

          PERFORM idcp IN PROGRAM zsdcreafac
                                   USING ls_cabpedext-znum_doc_core
                                         vl_soc
                                         ls_cabpedext-vkorg
                                         ls_cabpedext-factura.
          CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE *   INTO wa_zcabpedext
*            FROM zcabpedext
*            WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
*              AND zblart        EQ ls_cabpedext-zblart.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS    INTO wa_zcabpedext
            FROM zcabpedext
            WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
              AND zblart        EQ ls_cabpedext-zblart ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING wa_zcabpedext TO ls_cabpedext.
          ENDIF.
          CHECK 1 = 2.
        ELSE.
          ls_cabpedext-error_e = space.
          ls_cabpedext-log_error = TEXT-030.
        ENDIF.
      ENDIF.
    ELSE.
***Contabilizar factura desde la VF02
      CLEAR c_rfbsk.
      PERFORM contab_vf02 IN PROGRAM zsdprocfac
                          USING ls_cabpedext-factura
                          CHANGING c_rfbsk
                                   c_mensaje.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM zcabpedext
*                INTO wa_zcabpedext
*                WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
*                  AND zblart        EQ ls_cabpedext-zblart.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM zcabpedext
                INTO wa_zcabpedext
                WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
                  AND zblart        EQ ls_cabpedext-zblart ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF c_rfbsk EQ 'C'.
        CLEAR : wa_zcabpedext-error, wa_zcabpedext-error_e.
        PERFORM act_tablas IN PROGRAM zsdprocfac
                                      USING wa_zcabpedext
                                            wa_zcabpedext-factura
                                            wa_zcabpedext-pedido
                                            space
                                            space
                                            space.

        CLEAR lv_dea.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE dea INTO lv_dea
*          FROM ztdea  WHERE blart = ls_cabpedext-zblart.
*
* NEW CODE
        SELECT dea
        UP TO 1 ROWS  INTO lv_dea
          FROM ztdea  WHERE blart = ls_cabpedext-zblart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF NOT lv_dea IS INITIAL.
***Repetimos clase de mensaje ZFAE
          SUBMIT zsdrepmsg WITH p_vbeln EQ ls_cabpedext-factura
                           AND RETURN.

          CLEAR vl_soc.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE bukrs  INTO vl_soc
*            FROM vbrk  WHERE vbeln EQ ls_cabpedext-factura.
*
* NEW CODE
          SELECT bukrs
          UP TO 1 ROWS   INTO vl_soc
            FROM vbrk  WHERE vbeln EQ ls_cabpedext-factura ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
          PERFORM idcp IN PROGRAM zsdcreafac
                                   USING ls_cabpedext-znum_doc_core
                                         vl_soc
                                         ls_cabpedext-vkorg
                                         ls_cabpedext-factura.

          CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM zcabpedext
*            INTO wa_zcabpedext
*            WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
*              AND zblart        EQ ls_cabpedext-zblart.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM zcabpedext
            INTO wa_zcabpedext
            WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core
              AND zblart        EQ ls_cabpedext-zblart ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING wa_zcabpedext TO ls_cabpedext.
          ENDIF.
          CHECK 1 = 2.
        ELSE.
          ls_cabpedext-error_e = space.
          ls_cabpedext-log_error = TEXT-030.
        ENDIF.
      ELSE.
        wa_zcabpedext-error     = true.
        wa_zcabpedext-error_e   = space.
        IF c_mensaje IS INITIAL.
          CONCATENATE TEXT-t18 "'El documento'
                      ls_cabpedext-znum_doc_core
                      TEXT-t19 "'no pudo contabilizarse'
                 INTO wa_zcabpedext-log_error SEPARATED BY space.
        ELSE.
          wa_zcabpedext-log_error = c_mensaje.
        ENDIF.
        wa_zcabpedext-fec_car   = sy-datlo.
        wa_zcabpedext-hor_car   = sy-timlo.
        UPDATE zcabpedext FROM wa_zcabpedext.
        CHECK wa_zcabpedext-error NE true.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ls_cabpedext-pedido EQ space AND ls_cabpedext-factura EQ space.
    PERFORM proc_fact USING ls_cabpedext ls_selected_row_row_id.
  ELSE.
    IF ls_cabpedext-pedido  NE space AND "Pedido Creado
       ls_cabpedext-factura EQ space.    "Factura vacía
      SUBMIT zsdcreafac WITH p_vkorg  EQ ls_cabpedext-vkorg
                        WITH p_vtweg  EQ ls_cabpedext-vtweg
                        WITH p_spart  EQ ls_cabpedext-spart
                        WITH p_doctyp EQ order_head-doc_type
                        WITH p_fecfac EQ ls_cabpedext-fecfaccon
                        WITH p_saldoc EQ ls_cabpedext-pedido
                        WITH p_numdoc EQ ls_cabpedext-znum_doc_core
                        AND RETURN.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.
ENDFORM.                    " FACTURACION
*&---------------------------------------------------------------------*
*&      Form  ACT_TABLAS
*&---------------------------------------------------------------------*
FORM act_tablas USING wa_zcabpedext TYPE zcabpedext
                      bill_doc
                      salesdocument
                      error
                      error_e
                      log_error.

  TYPES: BEGIN OF e_bkpf,
           bukrs TYPE bkpf-bukrs,
           belnr TYPE bkpf-belnr,
           gjahr TYPE bkpf-gjahr,
         END OF e_bkpf.

  DATA: st_bkpf TYPE e_bkpf.

  TYPES: BEGIN OF t_vbap,
           vbeln TYPE vbap-vbeln,
           posnr TYPE vbap-posnr,
         END OF t_vbap.

  DATA: ti_vbap TYPE TABLE OF t_vbap,
        wa_vbap TYPE t_vbap.

  TYPES: BEGIN OF t_konv,
           knumv TYPE konv-knumv,
           kposn TYPE konv-kposn,
           kschl TYPE konv-kschl,
           kbetr TYPE konv-kbetr,
         END OF t_konv.

  DATA: ti_konv TYPE TABLE OF t_konv,
        wa_konv TYPE t_konv.

  TYPES : BEGIN OF t_cmfp,
            msgv1 TYPE cmfp-msgv1,
            msgv2 TYPE cmfp-msgv2,
            msgv3 TYPE cmfp-msgv3,
            msgv4 TYPE cmfp-msgv4,
          END OF t_cmfp.

  DATA: ti_cmfp TYPE TABLE OF t_cmfp,
        wa_cmfp TYPE t_cmfp.


  DATA: BEGIN OF str_tmp_bseg,
          zrut_benef LIKE bseg-zrut_benef,
          zr_etareo  LIKE bseg-zr_etareo,
          zsector    LIKE bseg-zsector,
          vertn      LIKE bseg-vertn,
          vertt      LIKE bseg-vertt,
          zfec_cont  LIKE bseg-zfec_cont,
          zterm      LIKE bseg-zterm,
          menge      LIKE bseg-menge,
          zuonr      LIKE bseg-zuonr,
          fdtag      LIKE bseg-fdtag,
          zlsch      LIKE bseg-zlsch,
          zprec      LIKE bseg-zprec,
          zdes_ad    LIKE bseg-zdes_ad,
          zrec_ad    LIKE bseg-zrec_ad,
          zdcto_conv LIKE bseg-zdcto_conv,
          zdcto_esp  LIKE bseg-zdcto_esp,
          zdcto_prom LIKE bseg-zdcto_prom,
          zdcto_espt LIKE bseg-zdcto_espt,
          zing_b_h   LIKE bseg-zing_b_h,
          zotro_ing  LIKE bseg-zotro_ing,
        END OF str_tmp_bseg.

  DATA: wa_fact_anex TYPE zfac_anex,
        ti_fact_anex TYPE TABLE OF zfac_anex.
  CLEAR wa_fact_anex.

  wa_zcabpedext-error     = error.
  wa_zcabpedext-error_e   = error_e.
  wa_zcabpedext-log_error = log_error.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = bill_doc
    IMPORTING
      output = vbrk-vbeln.

  FREE tmp_nast.
  SELECT kappl erdat eruhr cmfpnr
  FROM nast
  INTO wa_nast
  WHERE kappl EQ 'V3'
    AND objky EQ vbrk-vbeln
  ORDER BY erdat eruhr DESCENDING.
    READ TABLE tmp_nast INTO ls_tmp_nast INDEX 1.
    IF sy-subrc NE 0.
      MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
      APPEND ls_tmp_nast TO tmp_nast.
    ELSE.
      IF ls_tmp_nast-erdat < wa_nast-erdat.
        MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
        MODIFY tmp_nast FROM ls_tmp_nast INDEX 1.
      ELSEIF ls_tmp_nast-erdat = wa_nast-erdat AND
             ls_tmp_nast-eruhr <  wa_nast-eruhr.
        MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
        MODIFY tmp_nast FROM ls_tmp_nast INDEX 1.
      ENDIF.
    ENDIF.
  ENDSELECT.

  READ TABLE tmp_nast INTO ls_tmp_nast INDEX 1.
  IF sy-subrc = 0.
    nast-cmfpnr = ls_tmp_nast-cmfpnr.
    CLEAR wa_cmfp.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE msgv1 msgv2 msgv3 msgv4
*      INTO wa_cmfp
*      FROM cmfp
*      WHERE aplid = 'WFMC'
*        AND nr    = nast-cmfpnr
*        AND msgty = 'E'.
*
* NEW CODE
    SELECT msgv1 msgv2 msgv3 msgv4
    UP TO 1 ROWS 
      INTO wa_cmfp
      FROM cmfp
      WHERE aplid = 'WFMC'
        AND nr    = nast-cmfpnr
        AND msgty = 'E' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
      wa_zcabpedext-error_e     = true.
      CONCATENATE wa_cmfp-msgv1 wa_cmfp-msgv2
                  wa_cmfp-msgv3 wa_cmfp-msgv4 INTO
                  wa_zcabpedext-log_error SEPARATED BY space.
    ENDIF.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM vbrk WHERE vbeln = vbrk-vbeln.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM vbrk WHERE vbeln = vbrk-vbeln ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    vbrk-znum_doc_core = wa_zcabpedext-znum_doc_core.
    UPDATE vbrk.
  ENDIF.

  wa_zcabpedext-pedido    = salesdocument.
  wa_zcabpedext-factura   = bill_doc.
  wa_zcabpedext-fec_car   = sy-datlo.
  wa_zcabpedext-hor_car   = sy-timlo.
  UPDATE zcabpedext FROM wa_zcabpedext.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM vbrk WHERE vbeln EQ vbrk-vbeln.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM vbrk WHERE vbeln EQ vbrk-vbeln ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE bukrs belnr gjahr
*    INTO st_bkpf
*    FROM bkpf
*    WHERE awtyp EQ gv_vbrk
*      AND awkey EQ vbrk-vbeln.
*
* NEW CODE
  SELECT bukrs belnr gjahr
  UP TO 1 ROWS 
    INTO st_bkpf
    FROM bkpf
    WHERE awtyp EQ gv_vbrk
      AND awkey EQ vbrk-vbeln ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM vbak WHERE vbeln EQ salesdocument.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM vbak WHERE vbeln EQ salesdocument ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
***Inicio V1 10.07.2013***

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM bsid WHERE bukrs EQ st_bkpf-bukrs
*                                  AND gjahr EQ st_bkpf-gjahr
*                                  AND belnr EQ st_bkpf-belnr.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM bsid WHERE bukrs EQ st_bkpf-bukrs
                                  AND gjahr EQ st_bkpf-gjahr
                                  AND belnr EQ st_bkpf-belnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc EQ 0.
        MOVE space                 TO wa_fact_anex-zcod_rechazo.
      ENDIF.

      MOVE st_bkpf-bukrs               TO wa_fact_anex-bukrs.
      MOVE st_bkpf-belnr               TO wa_fact_anex-belnr.
      MOVE st_bkpf-gjahr               TO wa_fact_anex-gjahr.
      MOVE zcabpedext-zblart           TO wa_fact_anex-zblart.
      MOVE vbak-kvgr1	                 TO wa_fact_anex-zelectronico.
      MOVE vbak-vkorg	                 TO wa_fact_anex-zvkorg.
      MOVE vbak-vtweg	                 TO wa_fact_anex-zvtweg.
      MOVE vbak-kvgr3	                 TO wa_fact_anex-zkvgr3.
      MOVE vbak-kvgr4	                 TO wa_fact_anex-zkvgr4.
      MOVE wa_zcabpedext-znum_doc_core    TO wa_fact_anex-znum_doc_core.
      MOVE wa_zcabpedext-zrut_cli_fact    TO wa_fact_anex-zrut_cli_fact.
      MOVE wa_zcabpedext-zrut_cli_pagador TO
                                          wa_fact_anex-zrut_cli_pagador.
      MOVE wa_zcabpedext-znom_cli_fact    TO wa_fact_anex-znom_cli_fact.
      MOVE wa_zcabpedext-zgiro_cli_fact   TO
                                          wa_fact_anex-zgiro_cli_fact.
      MOVE wa_zcabpedext-zdir_fact        TO wa_fact_anex-zdir_fact.
      MOVE wa_zcabpedext-zcomuna_fact     TO wa_fact_anex-zcomuna_fact .
      MOVE wa_zcabpedext-zciudad_fact     TO wa_fact_anex-zciudad_fact.
      MOVE wa_zcabpedext-ztip_cambio_ref  TO
                                          wa_fact_anex-ztip_cambio_ref.
      MOVE vbak-kvgr2                  TO wa_fact_anex-zind_afecto.
***fin V1 10.07.2013***

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM vbkd WHERE vbeln EQ vbak-vbeln.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM vbkd WHERE vbeln EQ vbak-vbeln ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT vbeln posnr
*        INTO TABLE ti_vbap
*        FROM vbap
*        WHERE vbeln EQ vbak-vbeln.
*
* NEW CODE
      SELECT vbeln posnr

        INTO TABLE ti_vbap
        FROM vbap
        WHERE vbeln EQ vbak-vbeln ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      IF sy-subrc EQ 0.
        REFRESH ti_konv.
        SELECT knumv kposn kschl kbetr
          INTO TABLE ti_konv
          FROM konv
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916984*
*          WHERE knumv EQ vbak-knumv.
          WHERE knumv EQ vbak-knumv ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916984*
        IF sy-subrc EQ 0.
          CLEAR: tot_zprec, tot_zrec_ad, tot_zdcto_conv,
                 tot_zdcto_esp, tot_zdcto_prom,tot_zdcto_espt,
                 tot_zing_b_h, tot_zotro_ing.

          CLEAR : wa_fact_anex-zrut_benef, wa_fact_anex-zr_etareo,
                  wa_fact_anex-zsector, wa_fact_anex-buzei,
                  wa_fact_anex-zfec_cont, wa_fact_anex-zprec,
                  wa_fact_anex-zdes_ad, wa_fact_anex-zrec_ad,
                  wa_fact_anex-zdcto_conv, wa_fact_anex-zdcto_esp,
                  wa_fact_anex-zdcto_prom, wa_fact_anex-zdcto_espt,
                  wa_fact_anex-zing_b_h, wa_fact_anex-zotro_ing.

          LOOP AT ti_vbap INTO wa_vbap.
            LOOP AT ti_konv INTO wa_konv WHERE kposn EQ wa_vbap-posnr.
              CASE konv-kschl.
                WHEN 'ZPR0' OR 'ZPR3' OR 'ZPR4' OR 'ZPR5' OR 'ZPR9'.
                  ADD wa_konv-kbetr TO tot_zprec.
                WHEN 'ZRE1'.
                  ADD wa_konv-kbetr TO tot_zrec_ad.
                WHEN 'ZDC1'.
                  ADD wa_konv-kbetr TO tot_zdcto_conv.
                WHEN 'ZDC2'.
                  ADD wa_konv-kbetr TO tot_zdes_ad.
                WHEN 'ZDC3'.
                  ADD wa_konv-kbetr TO tot_zdcto_esp.
                WHEN 'ZDC4'.
                  ADD wa_konv-kbetr TO tot_zdcto_prom.
                WHEN 'ZDC5'.
                  ADD wa_konv-kbetr TO tot_zdcto_espt.
                WHEN 'ZPR1'.
                  ADD wa_konv-kbetr TO tot_zing_b_h.
                WHEN 'ZPR2'.
                  ADD wa_konv-kbetr TO tot_zotro_ing.
              ENDCASE.
            ENDLOOP.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE buzei INTO bseg-buzei
*               FROM bseg WHERE bukrs EQ st_bkpf-bukrs
*                           AND belnr EQ st_bkpf-belnr
*                           AND gjahr EQ st_bkpf-gjahr
*                           AND vbel2 EQ wa_vbap-vbeln
*                           AND posn2 EQ wa_vbap-posnr.
*
* NEW CODE
            SELECT buzei
            UP TO 1 ROWS  INTO bseg-buzei
               FROM bseg WHERE bukrs EQ st_bkpf-bukrs
                           AND belnr EQ st_bkpf-belnr
                           AND gjahr EQ st_bkpf-gjahr
                           AND vbel2 EQ wa_vbap-vbeln
                           AND posn2 EQ wa_vbap-posnr ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            IF sy-subrc = 0.
              CLEAR tmp_pos.
              tmp_pos = wa_vbap-posnr / 10.
              CLEAR zdetpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE * FROM zdetpedext
*                WHERE znum_doc_core EQ zcabpedext-znum_doc_core
*                  AND zpos_ext      EQ tmp_pos.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  FROM zdetpedext
                WHERE znum_doc_core EQ zcabpedext-znum_doc_core
                  AND zpos_ext      EQ tmp_pos ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              IF sy-subrc = 0.
                MOVE zdetpedext-zrut_beneficiari
                         TO wa_fact_anex-zrut_benef.
                MOVE zdetpedext-zrang_etareo
                         TO wa_fact_anex-zr_etareo.
                MOVE zdetpedext-zsector
                         TO wa_fact_anex-zsector.
              ENDIF.
            ENDIF.
          ENDLOOP.

          MOVE vbkd-bstdk              TO wa_fact_anex-zfec_cont.
          MOVE tot_zprec               TO wa_fact_anex-zprec.
          MOVE tot_zdes_ad             TO wa_fact_anex-zdes_ad.
          MOVE tot_zrec_ad             TO wa_fact_anex-zrec_ad.
          MOVE tot_zdcto_conv          TO wa_fact_anex-zdcto_conv.
          MOVE tot_zdcto_esp           TO wa_fact_anex-zdcto_esp.
          MOVE tot_zdcto_prom          TO wa_fact_anex-zdcto_prom.
          MOVE tot_zdcto_espt          TO wa_fact_anex-zdcto_espt.
          MOVE tot_zing_b_h            TO wa_fact_anex-zing_b_h.
          MOVE tot_zotro_ing           TO wa_fact_anex-zotro_ing.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE buzei
*            INTO wa_fact_anex-buzei
*            FROM bseg
*            WHERE bukrs EQ st_bkpf-bukrs
*              AND belnr EQ st_bkpf-belnr
*              AND gjahr EQ st_bkpf-gjahr
*              AND koart EQ 'D'. 
*
* NEW CODE
          SELECT buzei
          UP TO 1 ROWS 
            INTO wa_fact_anex-buzei
            FROM bseg
            WHERE bukrs EQ st_bkpf-bukrs
              AND belnr EQ st_bkpf-belnr
              AND gjahr EQ st_bkpf-gjahr
              AND koart EQ 'D' ORDER BY PRIMARY KEY. 

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"Deudor

          APPEND wa_fact_anex TO ti_fact_anex.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF NOT ti_fact_anex[] IS INITIAL.
    MODIFY zfac_anex FROM TABLE ti_fact_anex.
  ENDIF.

  SUBMIT zupdatefb02 WITH p_zuonr EQ zcabpedext-zuonr
                   WITH p_bukrs EQ st_bkpf-bukrs
                   WITH p_gjahr EQ st_bkpf-gjahr
                   WITH p_belnr EQ st_bkpf-belnr
                   AND RETURN.

ENDFORM.                    " ACT_TABLAS
*&---------------------------------------------------------------------*
*&      Form  PROC_FACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM proc_fact USING ls_cabpedext TYPE ty
                     indice.
  DATA: mensaje TYPE char100.
  DATA: success TYPE bapivbrksuccess.
  DATA: lv_dea TYPE ztdea-dea.
  DATA: zurl     TYPE zfac_anex-zurl,
        lv_vbeln TYPE vbrk-vbeln.
  FREE: return, order_items_in, order_items_inx, order_partners,
  order_schedules_in, order_schedules_inx,
          order_conditions_in, order_conditions_inx, bill_data,
          return_fac. "success.
  CLEAR: return, order_items_in, order_items_inx, order_partners,
  order_schedules_in, order_schedules_inx,
      order_conditions_in, order_conditions_inx, order_head,
      order_headx, salesdocument, bill_data, return_fac, success,
      bkpf, mensaje.

  PERFORM completa_cabecera_orden USING     ls_cabpedext-vkorg
                                            ls_cabpedext-vtweg
                                            ls_cabpedext-spart
                                            ls_cabpedext-fecfaccon
                                            space
                                            space
                                            ls_cabpedext-zblart
                                            ls_cabpedext-vkbur
                                            space
                                            space
                                            space
                                            ls_cabpedext-zelectronico
                                            ls_cabpedext-vertn
                                            ls_cabpedext-zkvgr3
                                            ls_cabpedext-zkvgr4
                                            ls_cabpedext-znum_doc_core
                                            ls_cabpedext-zuonr
                                            ls_cabpedext-zlsch
                                            ls_cabpedext-fecventes
                                   CHANGING order_head order_headx.
*
  PERFORM completa_partner TABLES order_partners
                            USING bill_data
                            ls_cabpedext-zrut_cli_pagador
                            ls_cabpedext-zrut_cli_fact
                            ls_cabpedext-zuonr
                            ls_cabpedext-znum_doc_core
                            CHANGING mensaje.

  IF NOT mensaje IS INITIAL.
    CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM zcabpedext
*      INTO wa_zcabpedext
*      WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM zcabpedext
      INTO wa_zcabpedext
      WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      wa_zcabpedext-fec_car   = sy-datlo.
      wa_zcabpedext-hor_car   = sy-timlo.
      wa_zcabpedext-error     = true.
      wa_zcabpedext-log_error = mensaje.
      UPDATE zcabpedext FROM wa_zcabpedext.
      MOVE-CORRESPONDING wa_zcabpedext TO ls_cabpedext.
    ENDIF.
  ELSE.
    CLEAR: ls_detpedext, pos, lv_vbeln.
***Validamos que no existe el numero core en alguna factura anterior
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE vbeln
*      INTO lv_vbeln
*      FROM vbrk
*      WHERE znum_doc_core = ls_cabpedext-znum_doc_core
*        AND fksto = space.
*
* NEW CODE
    SELECT vbeln
    UP TO 1 ROWS 
      INTO lv_vbeln
      FROM vbrk
      WHERE znum_doc_core = ls_cabpedext-znum_doc_core
        AND fksto = space ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE *
*        FROM zcabpedext
*        INTO wa_zcabpedext
*        WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS 
        FROM zcabpedext
        INTO wa_zcabpedext
        WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc EQ 0.
        CLEAR wa_zcabpedext-log_error.
        wa_zcabpedext-fec_car = sy-datlo.
        wa_zcabpedext-hor_car = sy-timlo.
        wa_zcabpedext-error  = true.
        CONCATENATE TEXT-e01 lv_vbeln INTO wa_zcabpedext-log_error
        SEPARATED BY space.
        UPDATE zcabpedext FROM wa_zcabpedext.
        MOVE-CORRESPONDING wa_zcabpedext TO ls_cabpedext.
      ENDIF.
    ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * INTO ls_detpedext
*        FROM zdetpedext
*        WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core.
*
* NEW CODE
      SELECT *
 INTO ls_detpedext
        FROM zdetpedext
        WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        ADD 1 TO pos.
        PERFORM completa_posicion TABLES order_items_in
                                         order_items_inx
                                         order_partners
                                         order_schedules_in
                                         order_schedules_inx
                                         order_conditions_in
                                         order_conditions_inx
                                   USING ls_cabpedext ls_detpedext pos.
      ENDSELECT.

      READ TABLE order_items_in INTO wa_items_in INDEX 1.
      CHECK sy-subrc = 0.
      CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2' "#EC CI_USAGE_OK[2438131]
        EXPORTING
          order_header_in      = order_head
          order_header_inx     = order_headx
        IMPORTING
          salesdocument        = salesdocument
        TABLES
          return               = return
          order_items_in       = order_items_in
          order_items_inx      = order_items_inx
          order_partners       = order_partners
          order_schedules_in   = order_schedules_in
          order_schedules_inx  = order_schedules_inx
          order_conditions_in  = order_conditions_in
          order_conditions_inx = order_conditions_inx.
      IF salesdocument IS INITIAL.
        READ TABLE return INTO wa_return WITH KEY type = 'E'.
        IF sy-subrc = 0.
          CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM zcabpedext
*            INTO wa_zcabpedext
*            WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM zcabpedext
            INTO wa_zcabpedext
            WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc = 0.
            ls_cabpedext-fec_car = wa_zcabpedext-fec_car = sy-datlo.
            ls_cabpedext-hor_car = wa_zcabpedext-hor_car = sy-timlo.
            ls_cabpedext-error = wa_zcabpedext-error  = true.
            ls_cabpedext-log_error = wa_zcabpedext-log_error = wa_return-message.
            MODIFY gt_cabpedext FROM ls_cabpedext INDEX indice.
            UPDATE zcabpedext FROM wa_zcabpedext.
            EXIT.
          ENDIF.
        ENDIF.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = true.

        CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM zcabpedext
*          INTO wa_zcabpedext
*          WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM zcabpedext
          INTO wa_zcabpedext
          WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          wa_zcabpedext-fec_car   = sy-datlo.
          wa_zcabpedext-hor_car   = sy-timlo.
          wa_zcabpedext-pedido    = salesdocument.
          UPDATE zcabpedext FROM wa_zcabpedext.
        ENDIF.

        SUBMIT zsdcreafac WITH p_vkorg  EQ ls_cabpedext-vkorg
                          WITH p_vtweg  EQ ls_cabpedext-vtweg
                          WITH p_spart  EQ ls_cabpedext-spart
                          WITH p_doctyp EQ order_head-doc_type
                          WITH p_fecfac EQ ls_cabpedext-fecfaccon
                          WITH p_saldoc EQ salesdocument
                          WITH p_numdoc EQ ls_cabpedext-znum_doc_core
                          WITH p_import EQ c_x
                          AND RETURN.
        TABLES:indx.
        indx-aedat = sy-datum.
        indx-usera = sy-uname.
        indx-srtfd = success-bill_doc.
        IMPORT success-bill_doc TO success-bill_doc
        FROM DATABASE indx(xy) ID success-bill_doc. "'FAC'.
        DELETE FROM DATABASE indx(xy) ID success-bill_doc. "'FAC'.

        CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM zcabpedext
*          INTO wa_zcabpedext
*          WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM zcabpedext
          INTO wa_zcabpedext
          WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF success-bill_doc NE space.
          PERFORM save_glosa IN PROGRAM zsdprocfac USING wa_zcabpedext
                                                       success-bill_doc.
          PERFORM act_tablas USING wa_zcabpedext
                                   success-bill_doc
                                   salesdocument
                                   space
                                   space
                                   space.
        ELSE.
          READ TABLE return_fac INTO wa_return_fac WITH KEY type = 'E'.
          IF sy-subrc = 0.
            ls_cabpedext-fec_car = wa_zcabpedext-fec_car = sy-datlo.
            ls_cabpedext-hor_car = wa_zcabpedext-hor_car = sy-timlo.
            ls_cabpedext-error = wa_zcabpedext-error  = true.
            ls_cabpedext-log_error = wa_zcabpedext-log_error = wa_return-message.
            MODIFY gt_cabpedext FROM ls_cabpedext INDEX indice.
            UPDATE zcabpedext FROM wa_zcabpedext.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.

      READ TABLE gt_cabpedext INTO ls_cabpedext
      WITH KEY znum_doc_core = wa_zcabpedext-znum_doc_core.
      IF sy-subrc = 0.
        ls_cabpedext-fec_car   = wa_zcabpedext-fec_car.
        ls_cabpedext-hor_car   = wa_zcabpedext-hor_car.
        IF success-bill_doc IS INITIAL.
          ls_cabpedext-error = true.
        ELSE.
          ls_cabpedext-error = space.
***Verificamos que este marcado en la ZTDEA
          CLEAR lv_dea.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE dea
*            INTO lv_dea
*            FROM ztdea
*            WHERE blart = wa_zcabpedext-zblart.
*
* NEW CODE
          SELECT dea
          UP TO 1 ROWS 
            INTO lv_dea
            FROM ztdea
            WHERE blart = wa_zcabpedext-zblart ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF lv_dea IS INITIAL.
            ls_cabpedext-error_e = space.
            ls_cabpedext-log_error = TEXT-030.
          ELSE.
***Verificamos si tiene url
            PERFORM url USING success-bill_doc
                        CHANGING zurl.
            IF zurl IS INITIAL.
              ls_cabpedext-error_e = true.
              ls_cabpedext-log_error = wa_zcabpedext-log_error.
            ELSE.
              ls_cabpedext-error_e = space.
              ls_cabpedext-log_error = space.
            ENDIF.
          ENDIF.
        ENDIF.
        MODIFY gt_cabpedext FROM ls_cabpedext INDEX indice.
      ENDIF.
    ENDIF.
  ENDIF.
  COMMIT WORK.
ENDFORM.                    " PROC_FACT
*&---------------------------------------------------------------------*
*&      Form  COMPLETA_CABECERA_ORDEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_CABPEDEXT_VKORG  text
*      -->P_GT_CABPEDEXT_VTWEG  text
*      -->P_GT_CABPEDEXT_SPART  text
*      -->P_SY_DATUM  text
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_GT_CABPEDEXT_ZBLART  text
*      -->P_GT_CABPEDEXT_VKBUR  text
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_SPACE  text
*      -->P_GT_CABPEDEXT_ZELECTRONICO  text
*      -->P_GT_CABPEDEXT_VERTN  text
*      -->P_GT_CABPEDEXT_ZKVGR3  text
*      -->P_GT_CABPEDEXT_ZKVGR4  text
*      <--P_ORDER_HEAD  text
*      <--P_ORDER_HEADX  text
*----------------------------------------------------------------------*
FORM completa_cabecera_orden USING p_vkorg
                                   p_vtweg
                                   p_spart
                                   p_bstdk
                                   p_bstkd
                                   p_taxk1
                                   p_auart
                                   p_vkbur
                                   p_konda
                                   p_xblnr
                                   p_version
                                   p_ind_e
                                   p_vertn
                                   p_zkvgr3
                                   p_zkvgr4
                                   p_znum_doc_core
                                   p_zuonr
                                   p_zlsch
                                   p_fecventes
                          CHANGING p_order_header_in  STRUCTURE
                          bapisdhd1
                                   p_order_header_inx STRUCTURE
                                   bapisdhd1x.
*
  CASE p_auart.
    WHEN 'G1' OR 'G2' OR 'G3' OR 'G4'. "Factura
      p_order_header_in-doc_type = 'ZFAC'.
    WHEN 'J1' OR 'J2' OR 'J3' OR 'J4'. "NC
      p_order_header_in-doc_type = 'ZNC'.
    WHEN 'L1' OR 'L2' OR 'L3' OR 'L4'. "ND
      p_order_header_in-doc_type = 'ZND'.
    WHEN 'O1' OR 'O2' OR 'O3' OR 'O4'. "BO
      p_order_header_in-doc_type = 'ZBOL'.
  ENDCASE.
  p_order_header_inx-doc_type = true.
  p_order_header_in-cust_grp1 = p_ind_e.
  p_order_header_inx-cust_grp1 = true.
  CASE p_auart.
    WHEN 'G1' OR 'G3' OR 'J1' OR 'J3' OR 'L1' OR 'L3' OR 'O1' OR 'O3'.
      p_order_header_in-cust_grp2 = '01'.
    WHEN OTHERS.
      p_order_header_in-cust_grp2 = '02'.
  ENDCASE.
  p_order_header_inx-cust_grp2 = true.

  p_order_header_in-cust_grp3  = p_zkvgr3.
  p_order_header_inx-cust_grp3 = true.
  p_order_header_in-cust_grp4  = p_zkvgr4.
  p_order_header_inx-cust_grp4 = true.
*
  p_order_header_in-sales_org   = p_vkorg.  " Organizacion de venta
  p_order_header_inx-sales_org  = true.
  p_order_header_in-distr_chan  = p_vtweg.  " Canal de ditribucucion
  p_order_header_inx-distr_chan = true.
  p_order_header_in-division    = p_spart.  " Sector
  p_order_header_inx-division   = true.
  p_order_header_in-fix_val_dy  = p_fecventes.  " Fecha vencimiento
  p_order_header_inx-fix_val_dy = true.

  CLEAR tmp_vertn.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_vertn
    IMPORTING
      output = tmp_vertn.

  p_order_header_in-purch_no_c  = tmp_vertn.  "n° de check
  p_order_header_inx-purch_no_c = true.
*  P_ORDER_HEADER_IN-ALTTAX_CLS  = P_TAXK1.  "Clasificación fiscal
  p_order_header_in-pmnttrms    = 'ZD00'.   "Condicion de pago.
  p_order_header_inx-pmnttrms   = true.
*  P_ORDER_HEADER_IN-VERSION     = P_VERSION."FORMA DE PAGO
*  P_ORDER_HEADER_IN-PRICE_GRP   = P_KONDA.  "Grupo de precios - Cliente
*  P_ORDER_HEADER_IN-SALES_OFF   = P_VKBUR.  "Oficina de Ventas
*  P_ORDER_HEADER_IN-REF_DOC_L   = P_XBLNR.  "Referencia
*  P_ORDER_HEADER_IN-PRICE_DATE  = P_BSTDK.  "Fecha det. precios
*
  p_order_header_in-req_date_h  = p_bstdk.  "Fecha preferente entrega
  p_order_header_inx-req_date_h = true.
  p_order_header_in-purch_date  = p_bstdk.  "Fecha del pedido
  p_order_header_inx-purch_date = true.
  p_order_header_in-price_date  = p_bstdk.  "Fecha pedido del destinat.
  p_order_header_inx-price_date = true.
  p_order_header_in-po_dat_s    = p_bstdk.
  p_order_header_inx-po_dat_s   = true.
  p_order_header_in-ass_number  = p_zuonr. "ZNUM_DOC_CORE.
  p_order_header_inx-ass_number = true.
  p_order_header_in-pymt_meth   = p_zlsch.
  p_order_header_inx-pymt_meth  = true.

ENDFORM.                    " COMPLETA_CABECERA_ORDEN
*&---------------------------------------------------------------------*
*&      Form  COMPLETA_PARTNER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ORDER_PARTNERS  text
*      -->P_BILL_DATA  text
*      -->P_GT_CABPEDEXT_ZRUT_CLI_PAGADOR  text
*      -->P_GT_CABPEDEXT_ZRUT_CLI_FACT  text
*----------------------------------------------------------------------*
FORM completa_partner  TABLES order_partners STRUCTURE bapiparnr
                       USING bill_data      STRUCTURE  bapivbrk
                             tmp_pagador
                             tmp_cli_fact
                             lp_zuonr
                             lp_znum_doc_core
                       CHANGING msj.
*
  DATA pagador  TYPE kunnr.
  DATA cli_fact TYPE kunnr.
  DATA : l_zrut_beneficiari TYPE stcd1,
         rut                TYPE stcd1.
*
  CLEAR pagador.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE kunnr INTO pagador FROM kna1 WHERE stcd1 EQ tmp_pagador.
*
* NEW CODE
  SELECT kunnr
  UP TO 1 ROWS  INTO pagador FROM kna1 WHERE stcd1 EQ tmp_pagador ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc NE 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE kunnr INTO pagador FROM kna1 WHERE kunnr EQ
*    tmp_pagador.
*
* NEW CODE
    SELECT kunnr
    UP TO 1 ROWS  INTO pagador FROM kna1 WHERE kunnr EQ
    tmp_pagador ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      pagador = tmp_pagador.
    ENDIF.
  ENDIF.
*
  CLEAR cli_fact.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE kunnr INTO cli_fact FROM kna1 WHERE stcd1 EQ
*  tmp_cli_fact.
*
* NEW CODE
  SELECT kunnr
  UP TO 1 ROWS  INTO cli_fact FROM kna1 WHERE stcd1 EQ
  tmp_cli_fact ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc NE 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE kunnr INTO cli_fact FROM kna1 WHERE kunnr EQ
*    tmp_cli_fact.
*
* NEW CODE
    SELECT kunnr
    UP TO 1 ROWS  INTO cli_fact FROM kna1 WHERE kunnr EQ
    tmp_cli_fact ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      cli_fact = tmp_cli_fact.
    ENDIF.
  ENDIF.
*
  CLEAR cli_fact.
  CONDENSE lp_zuonr NO-GAPS.
  IF lp_zuonr IS NOT INITIAL AND lp_zuonr NE '0'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zrut_beneficiari  INTO l_zrut_beneficiari
*      FROM zdetpedext WHERE znum_doc_core EQ lp_znum_doc_core.
*
* NEW CODE
    SELECT zrut_beneficiari
    UP TO 1 ROWS   INTO l_zrut_beneficiari
      FROM zdetpedext WHERE znum_doc_core EQ lp_znum_doc_core ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE kunnr INTO cli_fact
*           FROM kna1 WHERE stcd1 EQ l_zrut_beneficiari.
*
* NEW CODE
      SELECT kunnr
      UP TO 1 ROWS  INTO cli_fact
           FROM kna1 WHERE stcd1 EQ l_zrut_beneficiari ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE kunnr INTO cli_fact
*         FROM kna1 WHERE stcd1 EQ tmp_cli_fact.
*
* NEW CODE
    SELECT kunnr
    UP TO 1 ROWS  INTO cli_fact
         FROM kna1 WHERE stcd1 EQ tmp_cli_fact ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc NE 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE kunnr INTO cli_fact
*          FROM kna1 WHERE kunnr EQ  tmp_cli_fact.
*
* NEW CODE
      SELECT kunnr
      UP TO 1 ROWS  INTO cli_fact
          FROM kna1 WHERE kunnr EQ  tmp_cli_fact ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        cli_fact = tmp_cli_fact.
      ENDIF.
    ENDIF.
  ENDIF.
*
  order_partners-partn_role = 'AG'.
  bill_data-bill_to = order_partners-partn_numb = pagador.
  APPEND order_partners.
  CLEAR order_partners.
*
  order_partners-partn_role = 'RG'.
  order_partners-partn_numb = pagador.
  APPEND order_partners.
  CLEAR order_partners.
*
  IF  NOT l_zrut_beneficiari IS INITIAL
      AND cli_fact IS INITIAL.
    CONCATENATE TEXT-t22 l_zrut_beneficiari
    INTO msj SEPARATED BY space.
  ELSE.
    order_partners-partn_role = 'RE'.
    bill_data-ship_to = order_partners-partn_numb = cli_fact.
    APPEND order_partners.
    CLEAR order_partners.
  ENDIF.
*
  order_partners-partn_role = 'WE'.
  bill_data-payer = order_partners-partn_numb = pagador.
  APPEND order_partners.
  CLEAR order_partners.

ENDFORM.                    " COMPLETA_PARTNER
*&---------------------------------------------------------------------*
*&      Form  COMPLETA_POSICION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ORDER_ITEMS_IN  text
*      -->P_ORDER_ITEMS_INX  text
*      -->P_ORDER_PARTNERS  text
*      -->P_ORDER_SCHEDULES_IN  text
*      -->P_ORDER_SCHEDULES_INX  text
*      -->P_ORDER_CONDITIONS_IN  text
*      -->P_ORDER_CONDITIONS_INX  text
*      -->P_GT_CABPEDEXT  text
*      -->P_LS_DETPEDEXT  text
*      -->P_POS  text
*----------------------------------------------------------------------*
FORM completa_posicion TABLES ti_items_in       LIKE order_items_in
                              ti_items_inx      LIKE order_items_inx
                              ti_partners       LIKE order_partners
                              ti_schedules_in   LIKE order_schedules_in
                              ti_schedules_inx  LIKE order_schedules_inx
                              ti_cond_in  LIKE order_conditions_in
                              ti_cond_inx LIKE order_conditions_inx
                        USING gt_cabpedext         STRUCTURE
                              zstr_mon_fac
                              ls_detpedext         STRUCTURE zdetpedext
                              tabix.

  CLEAR:  wa_items_in, wa_items_inx, wa_partners,
  wa_schedules_in, wa_schedules_inx,  wa_items_in,  wa_items_inx,
  wa_cond_in, wa_cond_inx.

  wa_items_in-itm_number  = tabix * 10.
  wa_items_inx-itm_number = wa_items_in-itm_number.
  wa_cond_in-itm_number   = wa_items_in-itm_number.
  wa_cond_inx-itm_number  = wa_items_in-itm_number.
  wa_items_inx-updateflag     = true.
*
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE matnr INTO mara-matnr FROM mara WHERE bismt EQ
*  ls_detpedext-matnr.
*
* NEW CODE
  SELECT matnr
  UP TO 1 ROWS  INTO mara-matnr FROM mara WHERE bismt EQ
  ls_detpedext-matnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    wa_items_in-material        = mara-matnr.
  ELSE.
    IF ls_detpedext-matnr NE '000000000000000000' OR
      NOT ls_detpedext-matnr IS INITIAL.
      WHILE ls_detpedext-matnr(1) EQ '0'.
        SHIFT ls_detpedext-matnr LEFT.
      ENDWHILE.
    ENDIF.
    CONCATENATE 'CORE-' ls_detpedext-matnr INTO wa_items_in-material.
    CONDENSE ls_detpedext-matnr NO-GAPS.
  ENDIF.
  wa_items_inx-material       = true.
*
  wa_items_in-plant           = gt_cabpedext-zcentro.
  wa_items_inx-plant          = true.
*
  wa_items_in-target_qty      = ls_detpedext-menge.
  wa_items_inx-target_qty     = true.
*
  wa_schedules_in-itm_number  = wa_items_in-itm_number.
  wa_schedules_inx-itm_number = true.
*
  wa_schedules_in-req_qty     = ls_detpedext-menge.
  wa_schedules_inx-req_qty    = true.
*
  wa_items_in-purch_date      = sy-datum.
  wa_items_inx-purch_date     = true.
*
  wa_items_in-po_dat_s        = sy-datum.
  wa_items_inx-po_dat_s       = true.
*
  wa_items_in-pymt_meth       = gt_cabpedext-zlsch.
  wa_items_inx-pymt_meth      = true.

  wa_partners-partn_role      = 'ZB'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE kunnr
*    INTO wa_partners-partn_numb
*    FROM kna1
*    WHERE stcd1 EQ ls_detpedext-zrut_beneficiari.
*
* NEW CODE
  SELECT kunnr
  UP TO 1 ROWS 
    INTO wa_partners-partn_numb
    FROM kna1
    WHERE stcd1 EQ ls_detpedext-zrut_beneficiari ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc NE 0.
    wa_partners-partn_numb = ls_detpedext-zrut_beneficiari.
  ENDIF.

  wa_partners-itm_number = wa_items_in-itm_number.
********************************************************
  DATA tip_cond      TYPE c LENGTH 4.
  DATA tmp_divisor   TYPE i.
  DATA tmp_prec      LIKE ls_detpedext-zprec.
  DATA tmp_val_cuota LIKE ls_detpedext-zprec.

  CLEAR tip_cond.

  tmp_divisor = '1'.
  IF gt_cabpedext-zkvgr4 IS INITIAL.
    IF gt_cabpedext-zuonr IS INITIAL.
      tip_cond = 'ZPR0'.
    ELSE.
      CASE gt_cabpedext-zkvgr3.
        WHEN '01'.
          tip_cond = 'ZPR3'.
        WHEN '02'.
          tip_cond = 'ZPR4'.
        WHEN '03'.
          tip_cond = 'ZPR9'.
        WHEN OTHERS.
          tip_cond = 'ZPR0'.
      ENDCASE.
    ENDIF.
  ELSE.
    tip_cond = 'ZPR5'.
    CLEAR tmp_divisor.
    CASE gt_cabpedext-zkvgr4.
      WHEN '01'.
        tmp_divisor = '1'.
      WHEN '02'.
        tmp_divisor = '3'.
      WHEN '03'.
        tmp_divisor = '6'.
      WHEN '04'.
        tmp_divisor = '12'.
    ENDCASE.
    CLEAR tmp_prec.
    tmp_prec = ls_detpedext-zprec + ls_detpedext-zrec_ad +
    ls_detpedext-zdes_ad + ls_detpedext-zdcto_conv +
               ls_detpedext-zdcto_esp + ls_detpedext-zdcto_prom +
               ls_detpedext-zdcto_esp_t.
  ENDIF.

  IF tip_cond = 'ZPR5'.
    wa_cond_in-cond_type   = 'ZCUO'.
    wa_cond_inx-cond_type  = true.

    wa_cond_in-cond_value  = ls_detpedext-zprec / tmp_divisor.
    wa_cond_inx-cond_value = true.

    wa_cond_in-currency   = 'CLP'.
    wa_cond_inx-currency  = true.

  ELSE.
    wa_cond_in-cond_type   = tip_cond.
    wa_cond_inx-cond_type  = true.
*
    wa_cond_in-cond_value  = ls_detpedext-zprec. "valor
    wa_cond_inx-cond_value = true.
*
    wa_cond_in-currency   = 'CLP'." GT_CABPEDEXT-WAERS.
    wa_cond_inx-currency  = true.
  ENDIF.
*
  APPEND: wa_cond_in TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.
********************************************************
  wa_cond_in-cond_type   = 'ZRE1'.
  wa_cond_inx-cond_type  = true.

  wa_cond_in-cond_value  = ls_detpedext-zrec_ad / tmp_divisor.
  wa_cond_inx-cond_value = true.

  wa_cond_in-currency   = 'CLP'. "GT_CABPEDEXT-WAERS.
  wa_cond_inx-currency  = true.

  APPEND: wa_cond_in TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.
********************************************************
  wa_cond_in-cond_type   = 'ZDC2'.
  wa_cond_inx-cond_type  = true.
*
  wa_cond_in-cond_value  = ls_detpedext-zdes_ad / tmp_divisor.
  wa_cond_inx-cond_value = true.
*
  wa_cond_in-currency   = 'CLP'. "GT_CABPEDEXT-WAERS.
  wa_cond_inx-currency  = true.
*
  APPEND: wa_cond_in TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.
********************************************************
  wa_cond_in-cond_type   = 'ZDC1'.
  wa_cond_inx-cond_type  = true.
*
  wa_cond_in-cond_value  = ls_detpedext-zdcto_conv /
  tmp_divisor.
  wa_cond_inx-cond_value = true.
*
  wa_cond_in-currency   = 'CLP'. "GT_CABPEDEXT-WAERS.
  wa_cond_inx-currency  = true.
*
  APPEND: wa_cond_in TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.
********************************************************
  wa_cond_in-cond_type   = 'ZDC3'.
  wa_cond_inx-cond_type  = true.
*
  wa_cond_in-cond_value  = ls_detpedext-zdcto_esp / tmp_divisor
  .
  wa_cond_inx-cond_value = true.
*
  wa_cond_in-currency   = 'CLP'. "GT_CABPEDEXT-WAERS.
  wa_cond_inx-currency  = true.
*
  APPEND: wa_cond_in TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.
********************************************************
  wa_cond_in-cond_type   = 'ZDC4'.
  wa_cond_inx-cond_type  = true.
*
  wa_cond_in-cond_value  = ls_detpedext-zdcto_prom /
  tmp_divisor.
  wa_cond_inx-cond_value = true.
*
  wa_cond_in-currency   = 'CLP'. "GT_CABPEDEXT-WAERS.
  wa_cond_inx-currency  = true.
*
  APPEND: wa_cond_in TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.
********************************************************
  wa_cond_in-cond_type   = 'ZDC5'.
  wa_cond_inx-cond_type  = true.
*
  wa_cond_in-cond_value  = ls_detpedext-zdcto_esp_t /
  tmp_divisor.
  wa_cond_inx-cond_value = true.
*
  wa_cond_in-currency   = 'CLP'. "GT_CABPEDEXT-WAERS.
  wa_cond_inx-currency  = true.
*
  APPEND: wa_cond_in TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.
********************************************************
  wa_cond_in-cond_type   = 'ZPR1'.
  wa_cond_inx-cond_type  = true.
*
  wa_cond_in-cond_value  = ls_detpedext-zing_b_h.
  wa_cond_inx-cond_value = true.
*
  wa_cond_in-currency   = 'CLP'. "GT_CABPEDEXT-WAERS.
  wa_cond_inx-currency  = true.
*
  APPEND: wa_cond_in TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.
********************************************************
  wa_cond_in-cond_type   = 'ZPR2'.
  wa_cond_inx-cond_type  = true.
*
  wa_cond_in-cond_value  = ls_detpedext-zotro_ing.
  wa_cond_inx-cond_value = true.
*
  wa_cond_in-currency   = 'CLP'. "GT_CABPEDEXT-WAERS.
  wa_cond_inx-currency  = true.
*
  APPEND: wa_cond_in TO ti_cond_in,
          wa_cond_inx TO ti_cond_inx.
********************************************************
  IF tip_cond = 'ZPR5'.
*
    CLEAR tmp_val_cuota.
    LOOP AT ti_cond_in INTO wa_cond_in
      WHERE itm_number EQ wa_items_in-itm_number.
      ADD wa_cond_in-cond_value TO tmp_val_cuota.
    ENDLOOP.
*
    wa_cond_in-cond_type   = tip_cond.
    wa_cond_inx-cond_type  = true.
*
    wa_cond_in-cond_value  = tmp_prec - tmp_val_cuota.
    wa_cond_inx-cond_value = true.
*
    wa_cond_in-currency   = 'CLP'.
    wa_cond_inx-currency  = true.
*
    APPEND: wa_cond_in TO ti_cond_in,
            wa_cond_inx TO ti_cond_inx.
  ENDIF.

  APPEND: wa_items_in      TO ti_items_in,
          wa_items_inx     TO ti_items_inx,
          wa_schedules_in  TO ti_schedules_in,
          wa_schedules_inx TO ti_schedules_inx,
          wa_partners      TO ti_partners.

ENDFORM.                    " COMPLETA_POSICION
*&---------------------------------------------------------------------*
*&      Form  final_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM final_check .
  DATA: BEGIN OF wa_bkpf,
          bukrs TYPE bkpf-bukrs,
          belnr TYPE bkpf-belnr,
          gjahr TYPE bkpf-gjahr,
        END OF wa_bkpf.
*
  LOOP AT gt_cabpedext INTO ls_cabpedext.
    IF ls_cabpedext-factura EQ space AND
   NOT ls_cabpedext-pedido  IS INITIAL.
      CLEAR vbfa-vbelv.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_cabpedext-pedido
        IMPORTING
          output = vbfa-vbelv.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM vbfa
*        WHERE vbelv EQ vbfa-vbelv.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM vbfa
        WHERE vbelv EQ vbfa-vbelv ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        ls_cabpedext-factura = vbfa-vbeln.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE xblnr
*          INTO ls_cabpedext-folio
*          FROM vbrk
*          WHERE vbeln EQ vbfa-vbeln.
*
* NEW CODE
        SELECT xblnr
        UP TO 1 ROWS 
          INTO ls_cabpedext-folio
          FROM vbrk
          WHERE vbeln EQ vbfa-vbeln ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        ls_cabpedext-error     = space.
        ls_cabpedext-error_e   = space.
        ls_cabpedext-log_error = space.
      ELSE.
        ls_cabpedext-error     = true.
        ls_cabpedext-error_e   = space.
        ls_cabpedext-log_error = TEXT-017."No se ha creado la factura.'.
      ENDIF.
    ENDIF.

    IF ( NOT ls_cabpedext-factura IS INITIAL AND
         NOT ls_cabpedext-pedido  IS INITIAL )
         AND ls_cabpedext-error NE true.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM bkpf WHERE awtyp EQ gv_vbrk
*                                  AND awkey EQ ls_cabpedext-factura.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM bkpf WHERE awtyp EQ gv_vbrk
                                  AND awkey EQ ls_cabpedext-factura ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        ls_cabpedext-error     = true.
        ls_cabpedext-error_e   = space.
        CONCATENATE TEXT-019 "'El documento'
        ls_cabpedext-znum_doc_core
        TEXT-021 "'no pudo contabilizarse'
               INTO ls_cabpedext-log_error SEPARATED BY space.
      ELSE.
        MOVE-CORRESPONDING bkpf TO wa_bkpf.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_cabpedext-factura
          IMPORTING
            output = vbfa-vbeln.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM ztdea WHERE blart EQ ls_cabpedext-zblart
*                                     AND dea   EQ true.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM ztdea WHERE blart EQ ls_cabpedext-zblart
                                     AND dea   EQ true ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc NE 0.
          ls_cabpedext-error_e = space.
          ls_cabpedext-log_error = TEXT-030.
        ELSE.
          FREE tmp_nast.
          CLEAR wa_nast.
          SELECT kappl erdat eruhr cmfpnr
            FROM nast
            INTO wa_nast
            WHERE kappl EQ 'V3'
              AND objky EQ vbfa-vbeln
            ORDER BY erdat eruhr DESCENDING.

            READ TABLE tmp_nast INTO ls_tmp_nast INDEX 1.
            IF sy-subrc NE 0.
              MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
              APPEND ls_tmp_nast TO tmp_nast.
            ELSE.
              IF ls_tmp_nast-erdat < wa_nast-erdat.
                MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
                MODIFY tmp_nast FROM ls_tmp_nast INDEX 1.
              ELSEIF ls_tmp_nast-erdat = wa_nast-erdat AND
                     ls_tmp_nast-eruhr <  wa_nast-eruhr.
                MOVE-CORRESPONDING wa_nast TO ls_tmp_nast.
                MODIFY tmp_nast FROM ls_tmp_nast INDEX 1.
              ENDIF.
            ENDIF.
          ENDSELECT.

          CLEAR ls_tmp_nast.
          READ TABLE tmp_nast INTO ls_tmp_nast INDEX 1.
          IF sy-subrc NE 0.
            ls_cabpedext-error     = space.
            ls_cabpedext-error_e   = true.
            CONCATENATE TEXT-019 "'El documento'
            ls_cabpedext-znum_doc_core
            TEXT-020 "'no se ha enviado a Acepta'
                   INTO ls_cabpedext-log_error SEPARATED BY space.
          ELSE.
            CLEAR: wa_cmfp, ls_cabpedext-log_error.
            nast-cmfpnr = ls_tmp_nast-cmfpnr.
            SELECT msgcnt msgv1 msgv2 msgv3 msgv4
              INTO wa_cmfp
              FROM cmfp
              WHERE aplid = 'WFMC'
                AND nr    = wa_nast-cmfpnr
                AND msgty = 'E'
              ORDER BY msgcnt DESCENDING.
              EXIT.
            ENDSELECT.

*          IF sy-subrc = 0.
            IF wa_cmfp-msgty EQ 'E'.
              CONCATENATE wa_cmfp-msgv1 wa_cmfp-msgv2
                          wa_cmfp-msgv3 wa_cmfp-msgv4
              INTO ls_cabpedext-log_error.
              ls_cabpedext-error     = space.
              ls_cabpedext-error_e   = true.
            ELSE.
              ls_cabpedext-error     = space.
              ls_cabpedext-error_e   = space.
              ls_cabpedext-log_error = space.
              CLEAR: str_awkey, gv_vbeln.
              sdc = space.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = ls_cabpedext-factura
                IMPORTING
                  output = gv_vbeln.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE xblnr
*                INTO ls_cabpedext-folio
*                FROM bkpf
*                WHERE awtyp EQ gv_vbrk
*                  AND awkey EQ gv_vbeln.
*
* NEW CODE
              SELECT xblnr
              UP TO 1 ROWS 
                INTO ls_cabpedext-folio
                FROM bkpf
                WHERE awtyp EQ gv_vbrk
                  AND awkey EQ gv_vbeln ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              IF sy-subrc NE 0.
                ls_cabpedext-error     = true.
                ls_cabpedext-error_e   = space.
                ls_cabpedext-log_error = TEXT-018.
                "'Error al procesar documento contanble en SAP'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY gt_cabpedext FROM ls_cabpedext.

    CLEAR wa_zcabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*      INTO wa_zcabpedext
*      FROM zcabpedext
*      WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
      INTO wa_zcabpedext
      FROM zcabpedext
      WHERE znum_doc_core EQ ls_cabpedext-znum_doc_core ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      wa_zcabpedext-error     = ls_cabpedext-error.
      wa_zcabpedext-error_e   = ls_cabpedext-error_e.
      wa_zcabpedext-log_error = ls_cabpedext-log_error.
      wa_zcabpedext-factura   = ls_cabpedext-factura.
      UPDATE zcabpedext FROM wa_zcabpedext.

      IF wa_zcabpedext-pedido IS NOT INITIAL AND
         st_bkpf IS NOT INITIAL.
        PERFORM actualiza_zuonr_fi IN PROGRAM zcheckprocfac
                                   USING wa_zcabpedext-pedido
                                         st_bkpf.
      ENDIF.

    ENDIF.
  ENDLOOP.
ENDFORM.                    " FINAL_CHECK
*&---------------------------------------------------------------------*
*&      Form  URL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_NAST_OBJKY  text
*      <--P_ZURL  text
*----------------------------------------------------------------------*
FORM url  USING    p_vbeln
          CHANGING p_zurl.
  CLEAR: st_bkpf, p_zurl.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE bukrs belnr gjahr
*    INTO st_bkpf
*    FROM bkpf
*    WHERE awtyp EQ 'VBRK'
*      AND awkey EQ p_vbeln.
*
* NEW CODE
  SELECT bukrs belnr gjahr
  UP TO 1 ROWS 
    INTO st_bkpf
    FROM bkpf
    WHERE awtyp EQ 'VBRK'
      AND awkey EQ p_vbeln ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zurl
*      INTO p_zurl
*      FROM zfac_anex
*      WHERE bukrs = st_bkpf-bukrs
*        AND belnr = st_bkpf-belnr
*        AND gjahr = st_bkpf-gjahr.
*
* NEW CODE
    SELECT zurl
    UP TO 1 ROWS 
      INTO p_zurl
      FROM zfac_anex
      WHERE bukrs = st_bkpf-bukrs
        AND belnr = st_bkpf-belnr
        AND gjahr = st_bkpf-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.
ENDFORM.                    " URL
