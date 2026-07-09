*&---------------------------------------------------------------------*
*&  Include           ZXVVFU02
*&---------------------------------------------------------------------*
TABLES: vbak, vbkd.

DATA cuota TYPE  bkpf-xblnr.
CONSTANTS pto TYPE c VALUE '.'.

IF vbrk-vkorg EQ 'CL06' OR vbrk-vkorg EQ 'CL51' OR vbrk-vkorg EQ 'CL57'.
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
  IF vbrk-vbtyp = 'O'.
    SELECT FROM vbfa FIELDS vbelv
      WHERE vbeln   = @cvbrp-vgbel
        AND vbtyp_n = 'K'
        AND vbtyp_v = 'C'
      INTO @DATA(lv_vbelv)
      UP TO 1 ROWS.
    ENDSELECT.

    IF sy-subrc = 0.
      SELECT FROM vbkd FIELDS bstkd, bstkd_e
        WHERE vbeln = @lv_vbelv
        INTO @DATA(ls_vbkd)
        UP TO 1 ROWS.
      ENDSELECT.

      IF ls_vbkd-bstkd+0(2) = 'AS'.
        xaccit-vertn = ls_vbkd-bstkd_e.
        xaccit-vertt = 'Y'.

        IF xaccit-sgtxt  IS INITIAL.
          xaccit-sgtxt  = pto.
        ENDIF.
        IF xaccit-xref2 IS INITIAL.
          xaccit-xref2 = pto.
        ENDIF.
        IF xaccit-xref2 IS INITIAL.
          xaccit-xref3 = pto.
        ENDIF.
        xaccit-zz_url = pto.
        xaccit-xref1  = ls_vbkd-bstkd.
*-> BEG INS V1-CNN 26.12.2022
      ELSE.
        xaccit-sgtxt  = pto.
        xaccit-xref1  = pto.
        xaccit-xref2  = pto.
        xaccit-xref3  = pto.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT * FROM vbkd WHERE vbeln = cvbrp-vgbel.
**
* NEW CODE
        SELECT *
 FROM vbkd WHERE vbeln = cvbrp-vgbel ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        ENDSELECT.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = vbkd-bstkd
            IMPORTING
              output = xaccit-vertn.
        ENDIF.
        xaccit-vertt  = 'A'.
        xaccit-zz_url = pto.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT * FROM vbak WHERE vbeln = cvbrp-vgbel
*                             AND kvgr3 <> space.
*
* NEW CODE
        SELECT *
 FROM vbak WHERE vbeln = cvbrp-vgbel
                             AND kvgr3 <> space ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        ENDSELECT.
        IF sy-subrc EQ 0.
          xaccit-zuonr  = vbak-zuonr.
        ELSE.
          xaccit-zuonr = space.
        ENDIF.
        xaccit-hbkid = space.
*-> END INS V1-CNN 26.12.2022
      ENDIF.

    ELSE.
*-> BEG INS V1-CNN ECDK923342 Facturación el línea HELP
      IF vbrk-fkart EQ 'ZDYA'.
        xaccit-blart = 'ZJ'.
        xaccit-sgtxt = pto.
      ENDIF.

      IF cvbrp-kvgr5 EQ '02'.
        xaccit-blart = 'ZJ'.
        xaccit-sgtxt = pto.
      ENDIF.
*-> END INS V1-CNN ECDK923342 Facturación el línea HELP
    ENDIF.

  ELSE.

    SELECT FROM vbkd FIELDS bstkd, bstkd_e
      WHERE vbeln = @cvbrp-vgbel
      INTO @ls_vbkd
      UP TO 1 ROWS.
    ENDSELECT.

    IF NOT ls_vbkd-bstkd+0(2) = 'AS'.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP
      xaccit-sgtxt  = pto.
      xaccit-xref1  = pto.
      xaccit-xref2  = pto.
      xaccit-xref3  = pto.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM vbkd WHERE vbeln = cvbrp-vgbel.
*
* NEW CODE
      SELECT *
 FROM vbkd WHERE vbeln = cvbrp-vgbel ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      ENDSELECT.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = vbkd-bstkd
          IMPORTING
            output = xaccit-vertn.
      ENDIF.
      xaccit-vertt  = 'A'.
      xaccit-zz_url = pto.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM vbak WHERE vbeln = cvbrp-vgbel
*                           AND kvgr3 <> space.
*
* NEW CODE
      SELECT *
 FROM vbak WHERE vbeln = cvbrp-vgbel
                           AND kvgr3 <> space ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      ENDSELECT.
      IF sy-subrc EQ 0.
        xaccit-zuonr  = vbak-zuonr.
      ELSE.
        xaccit-zuonr = space.
      ENDIF.
      xaccit-hbkid = space.
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
    ELSE.
      IF vbrk-vbtyp <> 'O'.
        IF xaccit-sgtxt  IS INITIAL.
          xaccit-sgtxt  = pto.
        ENDIF.
        IF xaccit-xref2 IS INITIAL.
          xaccit-xref2 = pto.
        ENDIF.
        IF xaccit-xref2 IS INITIAL.
          xaccit-xref3 = pto.
        ENDIF.
        xaccit-zz_url = pto.
        xaccit-xref1  = ls_vbkd-bstkd.
        xaccit-vertn  = ls_vbkd-bstkd_e.
        xaccit-vertt  = 'Y'.
      ENDIF.
    ENDIF.
  ENDIF.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP
ENDIF.
