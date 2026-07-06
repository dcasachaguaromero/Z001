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
REPORT   zfilb005_2_v3.
*
INCLUDE zfilb005_top_2_v3.
INCLUDE zfilb005_o01_2_v3.
INCLUDE zfilb005_i01_2_v3.
INCLUDE zfilb005_f01_2_v3.
*
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

* ini Waldo Alarcón - Visionone - 25-05-2020
  CLEAR  r_budat1[].
  lr_budat-sign = 'I'.  lr_budat-option = 'BT'.
  CONCATENATE p_gjahr p_monat '01' INTO lr_budat-low.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lr_budat-low
    IMPORTING
      last_day_of_month = lr_budat-high
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  APPEND lr_budat TO r_budat1.
*
  OPEN CURSOR: WITH HOLD gv_bkpf1
                        FOR SELECT bukrs belnr gjahr blart budat
                                   waers xblnr bstat monat stblg
                           FROM bkpf  WHERE bukrs EQ p_bukrs
                                        AND gjahr EQ p_gjahr
                                        AND monat EQ p_monat
                                        AND budat IN r_budat1
                                        AND bstat IN r_bstat.
  DO.
*
    IF gv_flag_1 EQ abap_false.
      FETCH NEXT CURSOR gv_bkpf1 INTO CORRESPONDING FIELDS OF TABLE gt_bkpf1
             PACKAGE SIZE gv_maxlin.
      IF sy-subrc EQ 0.
        ADD 1 TO gv_proc.
        PERFORM procesa_tabla TABLES gt_bkpf1.
        CALL FUNCTION 'DB_COMMIT'  .
      ELSE.
        CLOSE CURSOR gv_bkpf1.
        gv_flag_1 = abap_true.
      ENDIF.
    ENDIF.
*
    IF gv_flag_1 EQ abap_true.
      EXIT.
    ENDIF.

  ENDDO.
* fin Waldo Alarcón - Visionone - 25-05-2020
END-OF-SELECTION.
  IF wa_batch EQ 'S'.
    WRITE :/ 'Fin:', gv_proc.
  ENDIF.
*
  CASE space.
    WHEN p_mov.
*      DELETE gt_outtab  WHERE  dmbtr_h EQ 0
*                           AND dmbtr_s EQ 0
*                           AND belnr NE space.
* SE REALIZA ESTE PERFORM PARA SACAR LAS CUENTA CUYA SUMA DE DEBE Y  HABER SEA CERO
      PERFORM dele_dh_ceros.
  ENDCASE.

  SORT gt_outtab BY hkont budat belnr.
  PERFORM get_saldos.

  IF  wa_batch = 'N'.
    PERFORM layout_init USING gs_layout.
    PERFORM fieldcat_init USING gt_fieldcat.

* LSC - 24.10.2011. Se incorpora la seleccion para decidir mediante
* parametros de entrada si el libro se despliega resumido o detallado.
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

    IF wa_batch EQ 'S'.
      DESCRIBE TABLE gt_download LINES sy-tabix.
      WRITE :/ 'OPEN DATASET:', sy-tabix.
    ENDIF.
    OPEN DATASET w_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

    IF sy-subrc <> 0.
      MESSAGE e899(fi) WITH 'Error al abrir archivo de salida :'(e99)
                             w_filename.
    ENDIF.

    LOOP AT gt_download INTO gs_download.
      TRANSFER gs_download  TO w_filename.
    ENDLOOP.

    CLOSE DATASET w_filename.

  ENDIF.
