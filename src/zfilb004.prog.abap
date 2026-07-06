*&---------------------------------------------------------------------*
*& Report  ZFILB004
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE zfilb004_top                            .    " global Data



INITIALIZATION.

  g_repid  = sy-repid.

* INI WALDO ALARCON - VISIONONE - 10-10-2025
  gv_tcode = 'X'.
  IF sy-tcode EQ 'ZLIBRODIARIO_V2'.
    CLEAR gv_tcode.
  ENDIF.
  SELECT blart, ltext INTO TABLE @DATA(gt_blart)
         FROM t003t WHERE spras EQ @sy-langu.
* FIN WALDO ALARCON - VISIONONE - 10-10-2025

  CALL FUNCTION 'FAGL_CHECK_GLFLEX_ACTIV_CLIENT'
    EXPORTING
      client          = sy-mandt
    IMPORTING
      e_glflex_active = gfagl_active.
  IF sy-subrc NE 0.
    CLEAR gfagl_active.
  ENDIF.

  p_path = '/backup/ftpfile'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  PERFORM value_request_path_down CHANGING  p_path.

AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_screen.

START-OF-SELECTION.

  IF sy-batch IS INITIAL.
    wa_batch = 'N'.
  ELSE.
    wa_batch = 'S'.
  ENDIF.
*PERFORM Campos_obligatorios.

  IF p_monat = 1.
    PERFORM get_saldo.
  ENDIF.

  PERFORM get_description_bukrs
              USING
                 br_bukrs-low
              CHANGING
                 g_butxt.

GET bkpf
  FIELDS bukrs belnr gjahr blart budat waers xblnr bstat monat stblg
         cpudt cputm tcode kursf usnam xref2_hd.
*

  IF NOT p_monat IS INITIAL.
    CHECK bkpf-monat EQ p_monat.
  ENDIF.

*  Modificacion Herman Rosales
*  Documentos anulados
*  CHECK bkpf-stblg IS INITIAL.
*  Fin Modificacion

  IF gfagl_active = 'X'
   AND ( bkpf-bstat  NA 'ADMSVWZ' ).


    CALL FUNCTION 'FAGL_GET_DOC_DETAILS_OF_LEDGER'
      EXPORTING
        i_rldnr    = br_rldnr-low
        i_bukrs    = bkpf-bukrs
        i_belnr    = bkpf-belnr
        i_gjahr    = bkpf-gjahr
*       I_ARCH     = 'X'
      IMPORTING
        es_details = gs_fagl_s_doc_details
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING bkpf TO gs_outtab.
      MOVE 'CLP' TO gs_outtab-waers.

* INI WALDO ALARCON - VISIONONE - 10-10-2025
      DATA(lv_index) = line_index( gt_blart[ blart = gs_outtab-blart ] ).
      IF lv_index GT 0.
        gs_outtab-ltext = gt_blart[ lv_index ]-ltext.
      ENDIF.
* FIN WALDO ALARCON - VISIONONE - 10-10-2025
    ELSE.
      REJECT 'BKPF'.
    ENDIF.
  ENDIF.

GET bseg FIELDS buzei hkont sgtxt dmbtr shkzg kostl.
  ADD 1 TO g_num.
  CASE  bseg-shkzg.
    WHEN 'H'.
      MOVE bseg-dmbtr TO gs_outtab-dmbtr_h.
      dmbtr_h = dmbtr_h + bseg-dmbtr.
    WHEN 'S'.
      MOVE bseg-dmbtr TO gs_outtab-dmbtr_s.
      dmbtr_s = dmbtr_s + bseg-dmbtr.
  ENDCASE.

  MOVE bseg-buzei TO gs_outtab-buzei.
  MOVE bseg-hkont TO gs_outtab-hkont.
  MOVE bseg-sgtxt TO gs_outtab-sgtxt.
  MOVE bseg-kostl TO gs_outtab-kostl.

  PERFORM get_description_hkont
              USING
                 gs_outtab-hkont
              CHANGING
                 gs_outtab-txt20.

  MOVE bkpf-blart TO gs_tabtot-blart.
  MOVE bkpf-waers TO gs_tabtot-waers.
  MOVE 'CLP' TO gs_tabtot-waers.
  MOVE gs_outtab-dmbtr_h TO gs_tabtot-dmbtr_h.
  MOVE gs_outtab-dmbtr_s TO gs_tabtot-dmbtr_s.
  COLLECT gs_tabtot INTO gt_tabtot.
  CLEAR gs_tabtot.

  APPEND gs_outtab TO gt_outtab.
  CLEAR: gs_outtab-buzei,
         gs_outtab-hkont,
         gs_outtab-txt20,
         gs_outtab-sgtxt,
         gs_outtab-dmbtr_s,
         gs_outtab-dmbtr_h.


END-OF-SELECTION.

  SORT gt_outtab BY budat belnr.

  IF  wa_batch = 'N'.
    PERFORM layout_init USING gs_layout.
*  PERFORM eventtab_build USING gt_events.
    PERFORM fieldcat_init  USING gt_fieldcat.
    PERFORM show_alv.
  ELSE.
    PERFORM fill_file USING gt_outtab
                         CHANGING gt_download.
    PERFORM fill_total USING gt_tabtot
                           CHANGING gt_download.

    CONCATENATE p_path  '/libro_diario_' br_bukrs-low
                '_' sy-datum '_'
                sy-uzeit '.TXT'INTO w_filename.

    OPEN DATASET w_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

    IF sy-subrc <> 0.
      MESSAGE TEXT-e99 TYPE 'E'.
    ENDIF.

    LOOP AT gt_download INTO gs_download.
      TRANSFER gs_download  TO w_filename.
    ENDLOOP.

    CLOSE DATASET w_filename.

  ENDIF.

  INCLUDE zfilb004_f01                            .  " FORM-Routines
  INCLUDE zfilb004_o01                            .  " PBO-Modules
  INCLUDE zfilb004_i01                            .  " PAI-Modules
