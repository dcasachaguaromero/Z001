*&---------------------------------------------------------------------*
*&  Include           ZXVVFU04
*&---------------------------------------------------------------------*
  TABLES: kna1.
  DATA  : cuota TYPE  bkpf-xblnr.

  IF vbrk-vkorg = 'CL06' OR vbrk-vkorg = 'CL51' OR vbrk-vkorg = 'CL57'.
    xaccit-sgtxt = '.'.
    xaccit-kdauf = xvbrp-vgbel.
    xaccit-kdpos = xvbrp-vgpos.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM vbak
*      WHERE  vbeln = xvbrp-vgbel
*      AND    kvgr4 <> ''.
*
* NEW CODE
    SELECT *
 FROM vbak
      WHERE  vbeln = xvbrp-vgbel
      AND    kvgr4 <> '' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    ENDSELECT.

    IF sy-subrc EQ 0 AND vbrk-znum_cuotas <> '001'.
      CONCATENATE 'CUOTA' '001' '/'  vbrk-znum_cuotas INTO cuota SEPARATED BY space.
      xaccit-xblnr      =  cuota.
      xaccit-sgtxt      =  cuota.
    ENDIF.

    CASE vbrk-vkorg.
      WHEN 'CL51'.
*-> BEG INS V1-CNN 16.11.2022 Facturación On demmand
        SELECT FROM vbkd FIELDS bstkd, bstkd_e
          WHERE vbeln = @xvbrp-vgbel
          INTO @DATA(ls_vbkd)
          UP TO 1 ROWS.
        ENDSELECT.
        IF ls_vbkd-bstkd+0(2) = 'AS'.
          xaccit-kostl = 'CL51015101'.
          xaccit-prctr = 'CL51015101'.
        ELSE.
*-> END INS V1-CNN 16.11.2022 Facturación On demmand
*-> BEG INS V1-CNN 17.02.2025 Medy Saas
*          DATA: lr_mat TYPE RANGE OF matnr.
*          DATA: lv_matnr TYPE matnr.
*
*          SELECT FROM tvarvc FIELDS sign, opti AS options, low, high
*            WHERE name = 'ZMEDYSAAS'
*              AND type = 'S'
*            INTO TABLE @lr_mat.
*
*          LOOP AT lr_mat ASSIGNING FIELD-SYMBOL(<fs_mat>).
*            lv_matnr     = |{ <fs_mat>-low ALPHA = IN }|.
*            <fs_mat>-low = lv_matnr.
*
*            IF NOT <fs_mat>-high IS INITIAL.
*              lv_matnr      = |{ <fs_mat>-high ALPHA = IN }|.
*              <fs_mat>-high = lv_matnr.
*            ENDIF.
*          ENDLOOP.
*
*          IF xvbrp-matnr IN lr_mat.
          SELECT SINGLE FROM ZFI_REL_MAT_CB FIELDS prctr, kostl
            WHERE vkorg = @vbrk-vkorg
              AND matnr = @xvbrp-matnr
            INTO @DATA(ls_rel_mat_cb).
          IF sy-subrc = 0.
            xaccit-prctr = ls_rel_mat_cb-prctr.
            xaccit-kostl = ls_rel_mat_cb-kostl.
          ELSE.
*-> END INS V1-CNN 17.02.2025 Medy Saas
            CASE xvbrp-werks.
              WHEN '5101'.
                xaccit-kostl = 'CL51011201'.
              WHEN '5102'.
                xaccit-kostl = 'CL51021201'.
              WHEN '5103'.
                xaccit-kostl = 'CL51031201'.
            ENDCASE.
          ENDIF.
        ENDIF.
      WHEN 'CL06'.
        CASE xvbrp-werks.
          WHEN '0601'.
            xaccit-kostl = 'CL06011201'.
          WHEN '0602'.
            xaccit-kostl = 'CL06021201'.
          WHEN '0603'.
            xaccit-kostl = 'CL06031201'.
        ENDCASE.
      WHEN 'CL57'.
        CASE xvbrp-werks.
          WHEN '5701'.
            xaccit-kostl = 'CL57011201'.
        ENDCASE.
    ENDCASE.

    IF vbrk-vkorg EQ 'CL51' OR vbrk-vkorg EQ 'CL57' OR vbrk-vkorg EQ 'CL07'.
      xaccit-zuonr = ''.
    ENDIF.

*-> BEG INS V1-CNN 18.06.2019
    DATA: lv_stcd1   TYPE stcd1.
    IF vbrk-vkorg = 'CL51'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT stcd1 INTO lv_stcd1
*        FROM kna1 UP TO 1 ROWS
*        WHERE  kunnr = vbrk-kunrg.
*
* NEW CODE
      SELECT stcd1
 INTO lv_stcd1
        FROM kna1 UP TO 1 ROWS
        WHERE  kunnr = vbrk-kunrg ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      ENDSELECT.
      IF sy-subrc = 0.
        xaccit-zzrut_terc = lv_stcd1.
      ENDIF.
    ENDIF.
*-> END INS V1-CNN 18.06.2019

    IF vbrk-vkorg = 'CL06' OR vbrk-vkorg = 'CL51' OR vbrk-vkorg = 'CL57'.
      IF xaccit-hkont EQ '2012710005'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT *
*        FROM   kna1
*        WHERE  kunnr = vbrk-kunag.
*
* NEW CODE
        SELECT *

        FROM   kna1
        WHERE  kunnr = vbrk-kunag ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        ENDSELECT.
        IF sy-subrc EQ 0.
          xaccit-zzrut_terc =  kna1-stcd1.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*          SELECT *
*          FROM vbkd
*          WHERE vbeln = xvbrp-vgbel.
*
* NEW CODE
          SELECT *

          FROM vbkd
          WHERE vbeln = xvbrp-vgbel ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
          ENDSELECT.
          IF sy-subrc EQ 0.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = vbkd-bstkd
              IMPORTING
                output = xaccit-zuonr.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = xaccit-zuonr
              IMPORTING
                output = xaccit-zuonr.
          ENDIF.
*        xaccit-zuonr      =  xaccit-vertn.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
