*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZCHECKPROCFAC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zcheckprocfac.
TABLES bkpf.
TABLES vbfa.
TABLES vbrk.
TABLES cmfp.
TABLES nast.
TABLES zcabpedext.
TABLES ztdea.

CONSTANTS: c_x TYPE c VALUE 'X'.
TYPES: BEGIN OF ty.
        INCLUDE STRUCTURE zstr_mon_fac.
TYPES:  cell_styles TYPE lvc_t_styl,
       END OF ty.
DATA gt_cabpedext TYPE STANDARD TABLE OF ty WITH HEADER LINE.
DATA str_awkey TYPE string.
DATA: BEGIN OF tmp_nast OCCURS 0,
       kappl  LIKE nast-kappl,
       erdat  LIKE nast-erdat,
       eruhr  LIKE nast-eruhr,
       cmfpnr LIKE nast-cmfpnr,
      END OF tmp_nast.
DATA ls_tmp_nast LIKE LINE OF tmp_nast.
DATA sdc TYPE c.
DATA : gv_vbrk TYPE bkpf-awtyp VALUE 'VBRK',
       gv_vbeln TYPE vbrk-vbeln,
       BEGIN OF wa_bkpf,
         bukrs TYPE bkpf-bukrs,
         belnr TYPE bkpf-belnr,
         gjahr TYPE bkpf-gjahr,
       END OF wa_bkpf,
       BEGIN OF t_kunnr OCCURS 0,
           kunnr TYPE kunnr,
           stcd1 TYPE stcd1,
       END OF t_kunnr.

DATA: ti_ztdea TYPE TABLE OF ztdea,
      wa_ztdea TYPE ztdea.

RANGES r_error        FOR zcabpedext-error.
RANGES r_error_e      FOR zcabpedext-error_e.

SELECT-OPTIONS   so_n_cor FOR  zcabpedext-znum_doc_core.
SELECT-OPTIONS   so_blart FOR  zcabpedext-zblart.
PARAMETERS       p_error  AS   CHECKBOX.
PARAMETERS       p_err_e  AS   CHECKBOX.
PARAMETERS       p_elec   TYPE ztdea-dea NO-DISPLAY.
*
START-OF-SELECTION.
**COMMENT INI
*  SELECT *
*    INTO TABLE ti_ztdea
*    FROM ztdea
*    WHERE dea = p_elec.
**COMMENT FIN
  PERFORM gen_ran_error.
  PERFORM gen_ran_error_e.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM zcabpedext WHERE znum_doc_core IN so_n_cor
*                              AND zblart       IN so_blart
*                              AND error        IN r_error
*                              AND error_e      IN r_error_e.
*
* NEW CODE
  SELECT *
 FROM zcabpedext WHERE znum_doc_core IN so_n_cor
                              AND zblart       IN so_blart
                              AND error        IN r_error
                              AND error_e      IN r_error_e ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    MOVE-CORRESPONDING zcabpedext TO gt_cabpedext.
**ADD INI
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*    INTO TABLE ti_ztdea
*    FROM ztdea
*    WHERE dea = p_elec
*    AND BLART = gt_cabpedext-zblart.
*
* NEW CODE
  SELECT *

    INTO TABLE ti_ztdea
    FROM ztdea
    WHERE dea = p_elec
    AND BLART = gt_cabpedext-zblart ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
**ADD FIN
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
SORT ti_ztdea .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
    READ TABLE ti_ztdea INTO wa_ztdea
    WITH KEY blart = gt_cabpedext-zblart BINARY SEARCH.
    IF sy-subrc EQ 0.
* CLIENTE PAGADOR
      READ TABLE t_kunnr WITH KEY stcd1 = zcabpedext-zrut_cli_pagador.
      IF sy-subrc NE 0.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT kunnr stcd1 APPENDING TABLE t_kunnr
*               FROM kna1 WHERE stcd1 EQ zcabpedext-zrut_cli_pagador.
*
* NEW CODE
        SELECT kunnr stcd1 APPENDING TABLE t_kunnr

               FROM kna1 WHERE stcd1 EQ zcabpedext-zrut_cli_pagador ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        READ TABLE t_kunnr WITH KEY stcd1 = zcabpedext-zrut_cli_pagador.
      ENDIF.
      IF sy-subrc EQ 0.
        MOVE t_kunnr-kunnr TO gt_cabpedext-kunnr.
      ENDIF.
* CLIENTE FACTURA
      READ TABLE t_kunnr WITH KEY stcd1 = zcabpedext-zrut_cli_fact.
      IF sy-subrc NE 0.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT kunnr stcd1 APPENDING TABLE t_kunnr
*               FROM kna1 WHERE stcd1 EQ zcabpedext-zrut_cli_pagador.
*
* NEW CODE
        SELECT kunnr stcd1 APPENDING TABLE t_kunnr

               FROM kna1 WHERE stcd1 EQ zcabpedext-zrut_cli_pagador ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        READ TABLE t_kunnr WITH KEY stcd1 = zcabpedext-zrut_cli_fact.
      ENDIF.
      IF sy-subrc EQ 0.
        MOVE t_kunnr-kunnr TO gt_cabpedext-zrut_cli_fact.
      ENDIF.

      APPEND gt_cabpedext.
    ENDIF.
  ENDSELECT.

END-OF-SELECTION.
  LOOP AT gt_cabpedext.
*
    CLEAR wa_bkpf.
    IF gt_cabpedext-factura EQ space AND NOT gt_cabpedext-pedido IS INITIAL.
      CLEAR vbfa-vbelv.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gt_cabpedext-pedido
        IMPORTING
          output = vbfa-vbelv.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM vbfa WHERE vbelv EQ vbfa-vbelv.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM vbfa WHERE vbelv EQ vbfa-vbelv ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        gt_cabpedext-factura = vbfa-vbeln.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE xblnr INTO gt_cabpedext-folio
*               FROM vbrk WHERE vbeln EQ vbfa-vbeln.
*
* NEW CODE
        SELECT xblnr
        UP TO 1 ROWS  INTO gt_cabpedext-folio
               FROM vbrk WHERE vbeln EQ vbfa-vbeln ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        gt_cabpedext-error     = space.
        gt_cabpedext-error_e   = space.
        gt_cabpedext-log_error = space.
      ELSE.
        gt_cabpedext-error     = c_x.
        gt_cabpedext-error_e   = space.
        gt_cabpedext-log_error = 'No se ha creado la factura.'.
      ENDIF.
    ENDIF.

    IF ( NOT gt_cabpedext-factura IS INITIAL AND NOT gt_cabpedext-pedido IS INITIAL )
         AND gt_cabpedext-error NE c_x.
      CLEAR gv_vbeln.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gt_cabpedext-factura
        IMPORTING
          output = gv_vbeln.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE *
*        FROM  bkpf
*        WHERE awtyp EQ gv_vbrk
*          AND awkey EQ gv_vbeln.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS 
        FROM  bkpf
        WHERE awtyp EQ gv_vbrk
          AND awkey EQ gv_vbeln ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        gt_cabpedext-error     = c_x.
        gt_cabpedext-error_e   = space.
        CONCATENATE 'EL DOCUMENTO' gt_cabpedext-znum_doc_core 'NO PUDO CONTABILIZARSE'
               INTO gt_cabpedext-log_error SEPARATED BY space.
      ELSE.
        MOVE-CORRESPONDING bkpf TO wa_bkpf.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = gt_cabpedext-factura
          IMPORTING
            output = vbfa-vbeln.
        FREE tmp_nast.
        SELECT * FROM nast WHERE kappl EQ 'V3'
                             AND objky EQ vbfa-vbeln
                        ORDER BY erdat eruhr DESCENDING.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
SORT tmp_nast .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
          READ TABLE tmp_nast INDEX 1.
          IF sy-subrc NE 0.
            MOVE-CORRESPONDING nast TO tmp_nast.
            APPEND tmp_nast.
          ELSE.
            IF tmp_nast-erdat < nast-erdat.
              MOVE-CORRESPONDING nast TO tmp_nast.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
SORT tmp_nast .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
              MODIFY tmp_nast INDEX 1.
            ELSEIF tmp_nast-erdat EQ nast-erdat AND tmp_nast-eruhr < nast-eruhr.
              MOVE-CORRESPONDING nast TO tmp_nast.
              MODIFY tmp_nast INDEX 1.
            ENDIF.
          ENDIF.
        ENDSELECT.
        READ TABLE tmp_nast INDEX 1.
        IF sy-subrc NE 0.
          gt_cabpedext-error     = space.
          gt_cabpedext-error_e   = c_x.
          CONCATENATE 'EL DOCUMENTO' gt_cabpedext-znum_doc_core 'NO SE HA ENVIADO A ACEPTA'
                 INTO gt_cabpedext-log_error SEPARATED BY space.
        ELSE.
          CLEAR gt_cabpedext-log_error.
          nast-cmfpnr = tmp_nast-cmfpnr.
          SELECT * FROM cmfp WHERE aplid = 'WFMC'
                               AND nr    = nast-cmfpnr
                          ORDER BY msgcnt DESCENDING.
            EXIT.
          ENDSELECT.
          IF sy-subrc = 0.
            IF cmfp-msgty EQ 'E'.
              CONCATENATE cmfp-msgv1 cmfp-msgv2 cmfp-msgv3 cmfp-msgv4 INTO gt_cabpedext-log_error.
              gt_cabpedext-error     = space.
              gt_cabpedext-error_e   = c_x.
            ELSE.
              gt_cabpedext-error     = space.
              gt_cabpedext-error_e   = space.
              gt_cabpedext-log_error = space.
              CLEAR str_awkey.
              CONCATENATE '%' gt_cabpedext-factura '%' INTO str_awkey.
              sdc = space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE xblnr INTO gt_cabpedext-folio
*                     FROM bkpf WHERE awtyp EQ gv_vbrk AND
*                                     awkey LIKE str_awkey.
*
* NEW CODE
              SELECT xblnr
              UP TO 1 ROWS  INTO gt_cabpedext-folio
                     FROM bkpf WHERE awtyp EQ gv_vbrk AND
                                     awkey LIKE str_awkey ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              IF sy-subrc NE 0.
                gt_cabpedext-error     = c_x.
                gt_cabpedext-error_e   = space.
                gt_cabpedext-log_error = 'ERROR AL PROCESAR DOCUMENTO CONTABLE EN SAP'.
              ENDIF.
            ENDIF.
          ELSE.
            gt_cabpedext-error     = space.
            gt_cabpedext-error_e   = c_x.
            CONCATENATE 'EL DOCUMENTO' gt_cabpedext-znum_doc_core 'NO SE HA ENVIADO A ACEPTA'
                   INTO gt_cabpedext-log_error SEPARATED BY space.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY gt_cabpedext.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*           FROM zcabpedext WHERE znum_doc_core EQ gt_cabpedext-znum_doc_core.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
           FROM zcabpedext WHERE znum_doc_core EQ gt_cabpedext-znum_doc_core ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      zcabpedext-factura   = gt_cabpedext-factura.
      zcabpedext-error     = gt_cabpedext-error.
      zcabpedext-error_e   = gt_cabpedext-error_e.
      zcabpedext-log_error = gt_cabpedext-log_error.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE *
*             FROM ztdea WHERE blart EQ zcabpedext-zblart
*                          AND dea   EQ c_x.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS 
             FROM ztdea WHERE blart EQ zcabpedext-zblart
                          AND dea   EQ c_x ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        zcabpedext-error_e   = gt_cabpedext-error_e.
        zcabpedext-log_error = gt_cabpedext-log_error.
      ELSE.
        zcabpedext-error_e   = space.
        IF gt_cabpedext-error EQ space.
          zcabpedext-log_error = 'Este tipo de documentos no se envía a Acepta. Ver transacción ZTDEA'.
        ELSE.
          zcabpedext-log_error = gt_cabpedext-log_error.
        ENDIF.
      ENDIF.
      IF zcabpedext-error_e NE c_x.
        zcabpedext-error_e = space.
      ENDIF.
      UPDATE zcabpedext.
*
      IF gt_cabpedext-pedido IS NOT INITIAL AND zcabpedext-error_e IS INITIAL AND
        wa_bkpf IS NOT INITIAL.
        PERFORM actualiza_zuonr_fi USING gt_cabpedext-pedido wa_bkpf.
      ENDIF.
*
    ENDIF.
  ENDLOOP.
*&---------------------------------------------------------------------*
*&      Form  GEN_RAN_ERROR
*&---------------------------------------------------------------------*
FORM gen_ran_error .

  FREE: r_error_e, r_error.
  IF p_error NE space.
    r_error-sign   = 'I'.
    r_error-option = 'EQ'.
    r_error-low    = '*'.
    APPEND r_error.
    r_error-low    = c_x.
    APPEND r_error.
  ENDIF.

ENDFORM.                    " GEN_RAN_ERROR
*&---------------------------------------------------------------------*
*&      Form  GEN_RAN_ERROR_E
*&---------------------------------------------------------------------*
FORM gen_ran_error_e.

  IF p_err_e NE space.
    r_error_e-sign   = 'I'.
    r_error_e-option = 'EQ'.
    r_error_e-low    = '*'.
    APPEND r_error_e.
    r_error_e-low    = c_x.
    APPEND r_error_e.
  ENDIF.

ENDFORM.                    " GEN_RAN_ERROR_E
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZA_ZUONR_FI
*&---------------------------------------------------------------------*
FORM actualiza_zuonr_fi  USING p_pedido
                               p_wa_bkpf STRUCTURE wa_bkpf.
  DATA :  lv_zuonr TYPE vbak-zuonr,
          lv_vbeln TYPE vbrk-vbeln,
          BEGIN OF wa_bseg,
            bukrs TYPE bseg-bukrs,
            belnr TYPE bseg-belnr,
            gjahr TYPE bseg-gjahr,
            buzei TYPE bseg-buzei,
          END OF wa_bseg.
*
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_pedido
    IMPORTING
      output = lv_vbeln.
* lee pedido
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE zuonr INTO lv_zuonr
*         FROM vbak WHERE vbeln EQ lv_vbeln.
*
* NEW CODE
  SELECT zuonr
  UP TO 1 ROWS  INTO lv_zuonr
         FROM vbak WHERE vbeln EQ lv_vbeln ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CHECK sy-subrc EQ 0 AND lv_zuonr IS NOT INITIAL.
  SUBMIT zupdatefb02 WITH p_zuonr EQ lv_zuonr
                     WITH p_bukrs EQ p_wa_bkpf-bukrs
                     WITH p_gjahr EQ p_wa_bkpf-gjahr
                     WITH p_belnr EQ p_wa_bkpf-belnr
                     AND RETURN.
ENDFORM.                    " ACTUALIZA_ZUONR_FI
