*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFILB005_2_V1
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE zfilb005_top_2_v1.

INITIALIZATION.
  g_repid = sy-repid.
  CLEAR g_saldo_s1.
  CLEAR g_saldo_e1.

  CALL FUNCTION 'FAGL_CHECK_GLFLEX_ACTIV_CLIENT'
    EXPORTING
      client          = sy-mandt
    IMPORTING
      e_glflex_active = g_fagl_active.
  IF sy-subrc NE 0.
    CLEAR g_fagl_active.
  ENDIF.

  PERFORM fill_bstat.
  p_path = '/backup/ftpfile '.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  PERFORM value_request_path_down CHANGING  p_path.

START-OF-SELECTION.

  IF sy-batch IS INITIAL.
    wa_batch = 'N'.
  ELSE.
    wa_batch = 'S'.
  ENDIF.


  range_racct[] = s_saknr[].
  PERFORM get_saknr.

  PERFORM get_description_bukrs USING p_bukrs
                                CHANGING g_butxt.

  SELECT bukrs belnr gjahr blart  budat  waers xblnr bstat monat stblg
    FROM bkpf
    INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
    WHERE bukrs EQ p_bukrs
    AND gjahr EQ p_gjahr
    AND monat EQ p_monat
*    AND stblg EQ space
    AND bstat IN r_bstat.
  LOOP AT gt_bkpf INTO gs_bkpf.
    CALL FUNCTION 'FAGL_GET_DOC_DETAILS_OF_LEDGER'
      EXPORTING
        i_rldnr   = p_rldnr
        i_bukrs   = gs_bkpf-bukrs
        i_belnr   = gs_bkpf-belnr
        i_gjahr   = gs_bkpf-gjahr
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING gs_bkpf TO gs_outtab.
SELECT buzei hkont sgtxt dmbtr shkzg
FROM bseg
INTO CORRESPONDING FIELDS OF TABLE gt_bseg
WHERE bukrs EQ gs_bkpf-bukrs
AND belnr EQ gs_bkpf-belnr
AND gjahr EQ gs_bkpf-gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES02 ECDK917080 *
*AND hkont IN range_racct.
AND HKONT IN RANGE_RACCT ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES02 ECDK917080 *

      IF gt_bseg IS INITIAL.
        SELECT buzei hkont sgtxt dmbtr shkzg
        FROM bseg_add
        INTO CORRESPONDING FIELDS OF TABLE gt_bseg
        WHERE bukrs EQ gs_bkpf-bukrs
          AND belnr EQ gs_bkpf-belnr
          AND gjahr EQ gs_bkpf-gjahr
          AND hkont IN range_racct.
      ENDIF .

      LOOP AT gt_bseg INTO gs_bseg.
        MOVE gs_bseg-buzei TO gs_outtab-buzei.
*        MOVE gs_bseg-hkont TO gs_outtab-hkont.

        call function 'SCP_REPLACE_STRANGE_CHARS'
          exporting
          INTEXT = gs_bseg-sgtxt
          importing
          OUTTEXT = gs_outtab-sgtxt.
*       Change 28/01/2016 PYV.
*       MOVE gs_bseg-sgtxt TO gs_outtab-sgtxt.

*       DESCRIPCION CUENTA.
        PERFORM get_description_hkont2
            USING
               gs_bseg-hkont
            CHANGING
               g_txt20.
        CONCATENATE gs_bseg-hkont '-' g_txt20 INTO gs_outtab-hkont.
*        MOVE gs_bseg-hkont TO gs_outtab-hkont.*
*        MOVE G_TXT20 TO gs_outtab-sgtxt2.

        CASE  gs_bseg-shkzg.
          WHEN 'H'.
            MOVE gs_bseg-dmbtr TO gs_outtab-dmbtr_h.
            dmbtr_h = dmbtr_h + gs_bseg-dmbtr.
          WHEN 'S'.
            MOVE gs_bseg-dmbtr TO gs_outtab-dmbtr_s.

            dmbtr_s = dmbtr_s + gs_bseg-dmbtr.
        ENDCASE.

        MOVE gs_bkpf-blart TO gs_tabtot-blart.
        MOVE gs_bkpf-waers TO gs_tabtot-waers.
        MOVE gs_outtab-dmbtr_h TO gs_tabtot-dmbtr_h.
        MOVE gs_outtab-dmbtr_s TO gs_tabtot-dmbtr_s.
        COLLECT gs_tabtot INTO gt_tabtot.
        CLEAR gs_tabtot.
        APPEND gs_outtab TO gt_outtab.
        CLEAR: gs_outtab-buzei,
       gs_outtab-hkont,
       gs_outtab-sgtxt,
       gs_outtab-dmbtr_s,
       gs_outtab-dmbtr_h.
      ENDLOOP.
    ENDIF.
  ENDLOOP.



  CASE space.
    WHEN p_mov.
      DELETE gt_outtab
        WHERE
*        hkont eq space AND
        dmbtr_h EQ 0
        AND dmbtr_s EQ 0
        AND belnr NE space.
*     SE REALIZA ESTE PERFORM PARA SACAR LAS CUENTA CUYA SUMA DE DEBE Y  HABER SEA CERO
      PERFORM dele_dh_ceros.

  ENDCASE.

  SORT gt_outtab BY hkont budat belnr.
  PERFORM get_saldos.

  IF  wa_batch = 'N'.
    PERFORM layout_init USING gs_layout.
    PERFORM fieldcat_init USING gt_fieldcat.

* LSC - 24.10.2011. Se incorpora la seleccion para decidir mediante parametros de entrada si el libro se despliega resumido o detallado.
    IF p_extend IS INITIAL.
      g_expa = 'X'.
    ELSE.
      CLEAR: g_expa.
    ENDIF.

    PERFORM sort_init USING  g_expa CHANGING gt_sort.
    PERFORM show_alv.
  ELSE.
    PERFORM fill_file USING gt_outtab
                         CHANGING gt_download.
    PERFORM fill_total2 USING gt_tabtot
                           CHANGING gt_download.

    CONCATENATE p_path  '/libro_mayor_' p_bukrs
                '_' sy-datum '_'
                sy-uzeit '.TXT'INTO w_filename.

    OPEN DATASET w_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

    IF sy-subrc <> 0.
      MESSAGE text-e99 TYPE 'E'.
    ENDIF.

    LOOP AT gt_download INTO gs_download.
      TRANSFER gs_download  TO w_filename.
    ENDLOOP.

    CLOSE DATASET w_filename.

  ENDIF.


  INCLUDE zfilb005_o01_2_v1.
  INCLUDE zfilb005_i01_2_v1.
  INCLUDE zfilb005_f01_2_v1.
