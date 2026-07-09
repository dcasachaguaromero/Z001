*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZSDPROCFAC_PBO
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       MODULE PBO OUTPUT                                             *
*---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  TYPES ls_n_cor LIKE LINE OF so_n_cor.
  TYPES: BEGIN OF t_doc_pro_pos,
          num     TYPE i,
          jname   TYPE tbtcjob-jobname,
          jcount  TYPE tbtcjob-jobcount,
          r_n_cor TYPE RANGE OF ls_n_cor,
        END OF t_doc_pro_pos.

  DATA: wa_n_cor LIKE so_n_cor.
  DATA: tmp_rang_doc_pro_pos TYPE TABLE OF t_doc_pro_pos,
        wa_rang_doc_pro_pos  TYPE t_doc_pro_pos,
        lv_chec  TYPE c,
        num_ini  TYPE i,
        num_fin  TYPE i,
        num_tabl TYPE i,
        resto TYPE i.

  SET PF-STATUS 'MAIN100'.
  SET TITLEBAR  'MAIN100'.
*
  FREE gt_cabpedext.
  FREE gt_outtab.
*
  CASE true.
    WHEN rb_ol.
      IF g_custom_container IS INITIAL.
        PERFORM create_and_init_alv CHANGING gt_outtab[]
                                             gt_fieldcat.
      ENDIF.
    WHEN rb_bi.
      CLEAR: text_opt1, text_opt2.
      CONCATENATE '@8X@' text-t63 "'Aceptar'
      INTO text_opt1.
      CONCATENATE '@8Y@' text-t64 "'Rechazar'
       INTO text_opt2.

      CALL FUNCTION 'POPUP_WITH_2_BUTTONS_TO_CHOOSE'
        EXPORTING
          defaultoption = '1'
          diagnosetext1 = text-t65
          "'¡Atención! Se generará un proceso de fondo.'
          textline1     = text-t66 "'¿Desea continuar?'
          text_option1  = text_opt1
          text_option2  = text_opt2
          titel         = text-t67 "'Información'
        IMPORTING
          answer        = answer.

      IF answer EQ 1.
        FREE tmp_rang_doc_pro_pos.
        PERFORM det_fecfaccon.
        PERFORM gen_ran_error.
        PERFORM gen_ran_error_e.
        PERFORM obt_doctos_proc_fondo." TABLES tmp_doc_job.

        SORT tmp_doc_job BY num_doc_core ASCENDING.
        SORT tmp_doc_ele BY num_doc_core ASCENDING.
        CLEAR n_d_p_f.
* Número de documentos para proceso de fondo
        DESCRIBE TABLE tmp_doc_job LINES n_d_p_f.
*Determinar cuantos documentos por proceso de fondo deben ser
*distribuidos
        num_tabl = n_d_p_f.
        num_ini  = 1.
        IF n_d_p_f LE 100.
          num_fin  = n_d_p_f.
          p_npbd   = 1.
        ELSE.
          resto = n_d_p_f MOD p_npbd.
          DIVIDE n_d_p_f BY p_npbd.
          IF NOT resto IS INITIAL.
            num_fin = n_d_p_f + 1.
          ELSE.
            num_fin = n_d_p_f.
          ENDIF.
        ENDIF.
        CLEAR nacj.

        DO p_npbd TIMES.
          ADD 1 TO nacj.
          REFRESH so_n_cor.
          CLEAR wa_n_cor.
* Genera rango de documentos a procesar en Job
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
*SORT SO_N_COR .  "JOROZCO 20.01.2020
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
          LOOP AT tmp_doc_job INTO wa_doc_job FROM num_ini TO num_fin.
            wa_n_cor-sign   = 'I'.
* Si la cantidad es mayor a 950 definir rangos de lectura
            IF n_d_p_f > 950.
              wa_n_cor-option = 'BT'.
              IF wa_n_cor-low EQ space.
                wa_n_cor-low = wa_doc_job-num_doc_core.
                APPEND wa_n_cor TO so_n_cor.
              ELSE.
                wa_n_cor-high = wa_doc_job-num_doc_core.
                MODIFY so_n_cor FROM wa_n_cor INDEX 1.
                IF sy-subrc NE 0.
                  APPEND wa_n_cor TO so_n_cor.
                ENDIF.
              ENDIF.
            ELSE.
*Si la cantidad es menor a 950 definir registros individuales en el
*rango
              wa_n_cor-option = 'EQ'.
              wa_n_cor-low = wa_doc_job-num_doc_core.
              wa_n_cor-high = space.
              APPEND wa_n_cor TO so_n_cor.
            ENDIF.
          ENDLOOP.
          num_ini = num_fin + 1.
          num_fin = num_fin + n_d_p_f.
          IF num_fin GT num_tabl.
            num_fin = num_tabl.
            IF num_ini GE num_fin.
              num_ini = num_fin.
            ENDIF.
          ELSEIF num_ini GT num_fin.
            num_fin = num_ini.
          ENDIF.
* Evaluación si el rango contiene datos.
          CHECK NOT so_n_cor[] IS INITIAL.
          CLEAR: v_release, v_jcount, v_jname.
* Definición de Job de fondo para el rango de documentos enviado.

          PERFORM open_job USING nacj CHANGING v_jcount v_jname.
* Llamado proceso de fondo
          SUBMIT zsdjobfac VIA JOB v_jname NUMBER v_jcount
                              WITH so_n_cor IN so_n_cor
                              WITH p_elec   EQ space "Doc.normal
                               AND RETURN.
* Cierre del proceso de fondo
          PERFORM job_close USING nacj
                                  v_jcount
                                  v_jname .
*
          wa_rang_doc_pro_pos-jname     = v_jname.
          wa_rang_doc_pro_pos-jcount    = v_jcount.
          wa_rang_doc_pro_pos-num       = nacj.
          wa_rang_doc_pro_pos-r_n_cor[] = so_n_cor[].
          APPEND wa_rang_doc_pro_pos TO tmp_rang_doc_pro_pos.
          CLEAR wa_rang_doc_pro_pos.
          FREE so_n_cor.
          CLEAR so_n_cor.
        ENDDO.

***Procesamos los documentos electrónicos
        REFRESH so_n_cor.
        CLEAR wa_n_cor.
        IF NOT tmp_doc_ele[] IS INITIAL.
          DESCRIBE TABLE tmp_doc_ele LINES n_d_p_f.
          LOOP AT tmp_doc_ele INTO wa_doc_job.
            wa_n_cor-sign   = 'I'.
            IF n_d_p_f > 950.
              wa_n_cor-option = 'BT'.
              IF wa_n_cor-low EQ space.
                wa_n_cor-low = wa_doc_job-num_doc_core.
                APPEND wa_n_cor TO so_n_cor.
              ELSE.
                wa_n_cor-high = wa_doc_job-num_doc_core.
*ReSQ: No Need Of Change Internal Table SO_N_COR Already Sorted
                MODIFY so_n_cor FROM wa_n_cor INDEX 1.
                IF sy-subrc NE 0.
                  APPEND wa_n_cor TO so_n_cor.
                ENDIF.
              ENDIF.
            ELSE.
              wa_n_cor-option = 'EQ'.
              wa_n_cor-low = wa_doc_job-num_doc_core.
              wa_n_cor-high = space.
              APPEND wa_n_cor TO so_n_cor.
            ENDIF.
          ENDLOOP.

* Evaluación si el rango contiene datos.
          CHECK NOT so_n_cor[] IS INITIAL.
          CLEAR: v_release, v_jcount, v_jname, nacj.

* Definición de Job de fondo para el rango de documentos enviado.
          PERFORM open_job USING nacj CHANGING v_jcount v_jname.

* Llamado proceso de fondo
          SUBMIT zsdjobfac VIA JOB v_jname NUMBER v_jcount
                              WITH so_n_cor IN so_n_cor
                              WITH p_elec   = c_x "Doc.electronico
                               AND RETURN.
* Cierre del proceso de fondo
          PERFORM job_close USING nacj
                                  v_jcount
                                  v_jname .
*
          wa_rang_doc_pro_pos-jname     = v_jname.
          wa_rang_doc_pro_pos-jcount    = v_jcount.
          wa_rang_doc_pro_pos-num       = nacj.
          wa_rang_doc_pro_pos-r_n_cor[] = so_n_cor[].
          APPEND wa_rang_doc_pro_pos TO tmp_rang_doc_pro_pos.
          CLEAR wa_rang_doc_pro_pos.
          FREE so_n_cor.
          CLEAR so_n_cor.
        ENDIF.

        IF NOT v_jname IS INITIAL.
          MESSAGE s398(00) WITH text-t68. "Job lanzado. Ver sm37
        ENDIF.
      ENDIF.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                    "pbo OUTPUT
