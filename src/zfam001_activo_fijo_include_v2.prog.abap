*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <27-12-2019> *
*& Transport Number: < ECDK917016 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFAM001_ACTIVO_FIJO_INCLUDE_V2
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SELECT_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_DATOS .
  refresh: it_anlz, it_anla, it_anlp, it_anlc, it_bseg, TABLA, RESUMEN, it_movtos.
  clear:   it_anlz, it_anla, it_anlp, it_anlc, it_bseg, TABLA, RESUMEN, it_movtos.
  clear:   wa_lineas.

*>>> LBERNAL 10.01.2012 <<<
  PERFORM WAEHRUNG_ERMITTELN USING P_AFABE SAV_WAER1.


  CONCATENATE p_gjahr p_peraf INTO wa_periodo.
  wa_per_cierre = 999912.

  SELECT * FROM TABA WHERE BUKRS  EQ P_BUKRS
                       ORDER BY AFBLGJ DESCENDING
                                AFBLPE DESCENDING.
        CONCATENATE TABA-AFBLGJ TABA-AFBLPE+1(2) INTO wa_per_cierre.
        exit.
  ENDSELECT.


* Maestro de Activos
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM anla
*           INTO TABLE it_anla
*           WHERE BUKRS  EQ P_BUKRS
*           AND   ANLN1  IN S_ANLN1
*           AND   ANLN2  IN S_ANLN2
*           AND   ANLKL  IN S_ANLKL.
*
* NEW CODE
  SELECT *
 FROM anla
           INTO TABLE it_anla
           WHERE BUKRS  EQ P_BUKRS
           AND   ANLN1  IN S_ANLN1
           AND   ANLN2  IN S_ANLN2
           AND   ANLKL  IN S_ANLKL ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  DESCRIBE TABLE it_anla lines wa_cont.
  check wa_cont > 0.

  CALL FUNCTION 'T093C_READ'
    EXPORTING
      i_bukrs = p_bukrs
    IMPORTING
      f_t093c = ls_t093c
    EXCEPTIONS                                               "> 576843
      not_found = 1                                          "> 576843
      others    = 2.                                         "> 576843

* Elimino AF de ejercicios no vigentes en periodos
  LOOP AT it_anla.
       wa_eliminar = 'N'.
       wa_tabix    = sy-tabix.
       refresh lt_anla. clear lt_anla.
       MOVE-CORRESPONDING it_anla TO  lt_anla.
       append lt_anla.
       PERFORM get_year_restriction USING P_BUKRS
                                          P_GJAHR.
       IF wa_eliminar = 'S'.
          DELETE it_anla INDEX wa_tabix.
       ENDIF.
  ENDLOOP.

* Filtro AF por CeCo.
  wa_cont_ceco = 0.
  LOOP AT S_KOSTL.
       add 1 to wa_cont_ceco.
  ENDLOOP.
  IF wa_cont_ceco > 0.
    LOOP AT it_anla.
         wa_tabix = sy-tabix.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*         SELECT SINGLE * FROM anlz WHERE BUKRS  EQ P_BUKRS
*                                   AND   ANLN1  EQ it_anla-ANLN1
*                                   AND   ANLN2  EQ it_anla-ANLN2
*                                   AND   KOSTL  IN S_KOSTL.
*
* NEW CODE
         SELECT *
         UP TO 1 ROWS  FROM anlz WHERE BUKRS  EQ P_BUKRS
                                   AND   ANLN1  EQ it_anla-ANLN1
                                   AND   ANLN2  EQ it_anla-ANLN2
                                   AND   KOSTL  IN S_KOSTL ORDER BY PRIMARY KEY.

         ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF SY-SUBRC <> 0.
             DELETE it_anla INDEX wa_tabix.
          ENDIF.
    ENDLOOP.
  ENDIF.

* Re-evaluo si tenemos Datos Maestros
  DESCRIBE TABLE it_anla lines wa_cont.
  check wa_cont > 0.
  SORT it_anla BY BUKRS ANLN1 ANLN2.

*Cuentas de balance de las áreas de valoración
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM t095 INTO TABLE it_t095 WHERE ktopl = p_ktopl AND afabe = 1.
*
* NEW CODE
  SELECT *
 FROM t095 INTO TABLE it_t095 WHERE ktopl = p_ktopl AND afabe = 1 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*Clases de activos fijos: descripción
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM ANKT INTO TABLE it_ANKT WHERE SPRAS = sy-langu.
*
* NEW CODE
  SELECT *
 FROM ANKT INTO TABLE it_ANKT WHERE SPRAS = sy-langu ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


* Valores Periodos
  IF wa_periodo < wa_per_cierre.
    wa_mes_cierre = 'N'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM anlp
*               INTO CORRESPONDING FIELDS OF TABLE it_anlp
*               FOR ALL ENTRIES IN it_anla
*               WHERE BUKRS  EQ P_BUKRS
*               AND   GJAHR  EQ P_GJAHR
*               AND   PERAF  LE P_PERAF
*               AND   ANLN1  EQ it_anla-ANLN1
*               AND   ANLN2  EQ it_anla-ANLN2
*               AND   AFABER EQ P_AFABE.
*
* NEW CODE
    SELECT *
 FROM anlp
               INTO CORRESPONDING FIELDS OF TABLE it_anlp
               FOR ALL ENTRIES IN it_anla
               WHERE BUKRS  EQ P_BUKRS
               AND   GJAHR  EQ P_GJAHR
               AND   PERAF  LE P_PERAF
               AND   ANLN1  EQ it_anla-ANLN1
               AND   ANLN2  EQ it_anla-ANLN2
               AND   AFABER EQ P_AFABE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ELSE.
    wa_mes_cierre = 'S'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM anlp
*               INTO CORRESPONDING FIELDS OF TABLE it_anlp
*               FOR ALL ENTRIES IN it_anla
*               WHERE BUKRS  EQ P_BUKRS
*               AND   GJAHR  EQ P_GJAHR
*               AND   PERAF  EQ P_PERAF
*               AND   ANLN1  EQ it_anla-ANLN1
*               AND   ANLN2  EQ it_anla-ANLN2
*               AND   AFABER EQ P_AFABE.
*
* NEW CODE
    SELECT *
 FROM anlp
               INTO CORRESPONDING FIELDS OF TABLE it_anlp
               FOR ALL ENTRIES IN it_anla
               WHERE BUKRS  EQ P_BUKRS
               AND   GJAHR  EQ P_GJAHR
               AND   PERAF  EQ P_PERAF
               AND   ANLN1  EQ it_anla-ANLN1
               AND   ANLN2  EQ it_anla-ANLN2
               AND   AFABER EQ P_AFABE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDIF.

* Valores Resumen
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM anlc
*       INTO CORRESPONDING FIELDS OF TABLE it_anlc
*       FOR ALL ENTRIES IN it_anla
*       WHERE BUKRS  EQ P_BUKRS
*       AND   ANLN1  EQ it_anla-ANLN1
*       AND   ANLN2  EQ it_anla-ANLN2
*       AND   GJAHR  EQ P_GJAHR
*       AND   AFABE  EQ P_AFABE.
*
* NEW CODE
  SELECT *
 FROM anlc
       INTO CORRESPONDING FIELDS OF TABLE it_anlc
       FOR ALL ENTRIES IN it_anla
       WHERE BUKRS  EQ P_BUKRS
       AND   ANLN1  EQ it_anla-ANLN1
       AND   ANLN2  EQ it_anla-ANLN2
       AND   GJAHR  EQ P_GJAHR
       AND   AFABE  EQ P_AFABE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*  Tabla de Movimientos (Altas, Bajas, Traslados)
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM ANEK
*         INTO CORRESPONDING FIELDS OF TABLE it_ANEK
*         FOR ALL ENTRIES IN it_anla
*         WHERE BUKRS  EQ P_BUKRS
*         AND   ANLN1  EQ it_anla-ANLN1
*         AND   ANLN2  EQ it_anla-ANLN2
*         AND   GJAHR  LE P_GJAHR.
*
* NEW CODE
    SELECT *
 FROM ANEK
         INTO CORRESPONDING FIELDS OF TABLE it_ANEK
         FOR ALL ENTRIES IN it_anla
         WHERE BUKRS  EQ P_BUKRS
         AND   ANLN1  EQ it_anla-ANLN1
         AND   ANLN2  EQ it_anla-ANLN2
         AND   GJAHR  LE P_GJAHR ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  SORT it_movtos BY BUKRS ANLN1 ANLN2 BELNR BUDAT BLDAT GJAHR XBLNR ANBWA.
  SORT it_anek   BY BUKRS ANLN1 ANLN2 GJAHR.

  LOOP AT it_anek.
       wa_tabix = sy-tabix.
       wa_flag = 'N'.


       WA_BELNR_NUMC  =  IT_ANEK-BELNR.

       CONCATENATE WA_BELNR_NUMC IT_ANEK-AWORG INTO WA_AWKEY.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*       SELECT SINGLE * FROM BKPF WHERE BUKRS = IT_ANEK-AWORG+0(4)
*** V1 RVY 01-02-2021
**                                AND   AWKEY = WA_AWKEY.
*                                 AND   AWKEY = WA_AWKEY
*                                 AND   BUDAT = IT_ANEK-BUDAT.
*
* NEW CODE
       SELECT *
       UP TO 1 ROWS  FROM BKPF WHERE BUKRS = IT_ANEK-AWORG+0(4)
** V1 RVY 01-02-2021
*                                AND   AWKEY = WA_AWKEY.
                                 AND   AWKEY = WA_AWKEY
                                 AND   BUDAT = IT_ANEK-BUDAT ORDER BY PRIMARY KEY.

       ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
** V1 RVY 01-02-2021

       IF sy-subrc = 0.
          wa_flag = 'S'.
       ENDIF.

       IF wa_flag = 'N'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM BKPF WHERE BUKRS = IT_ANEK-AWORG+0(4)
*                               AND   BELNR = IT_ANEK-BELNR
*                               AND   GJAHR = IT_ANEK-AWORG+4(4).
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM BKPF WHERE BUKRS = IT_ANEK-AWORG+0(4)
                               AND   BELNR = IT_ANEK-BELNR
                               AND   GJAHR = IT_ANEK-AWORG+4(4) ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc = 0.
            wa_flag = 'S'.
          ENDIF.
       ENDIF.

       IF wa_flag = 'N'.
          CONTINUE.
       ELSE.
          clear it_movtos.
          it_movtos-bukrs  = it_anek-bukrs.
          it_movtos-anln1  = it_anek-anln1.
          it_movtos-anln2  = it_anek-anln2.

          it_movtos-BELNR  = BKPF-BELNR.
          it_movtos-BUDAT  = BKPF-BUDAT.
          it_movtos-BLDAT  = BKPF-BLDAT.
          it_movtos-GJAHR  = BKPF-GJAHR.
          it_movtos-XBLNR  = BKPF-XBLNR.

          if it_anek-BUZEI > 0.
              SELECT * FROM BSEG WHERE BUKRS = BKPF-BUKRS
                                   AND BELNR = BKPF-BELNR
                                   AND GJAHR = BKPF-GJAHR
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917016*
*                                   AND BUZEI = it_anek-BUZEI.
                                   AND BUZEI = it_anek-BUZEI ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917016*
                IF BSEG-ANLN1  EQ it_anek-ANLN1 AND
                   BSEG-ANLN2  EQ it_anek-ANLN2.
                   it_movtos-ANBWA  = BSEG-ANBWA.
                   it_movtos-DMBTR  = BSEG-DMBTR.
                   it_movtos-SHKZG  = BSEG-SHKZG.
                   it_movtos-BSCHL  = BSEG-BSCHL.
                   it_movtos-BEWAR  = BSEG-BEWAR.
                   APPEND it_movtos.
                ENDIF.
              ENDSELECT.

*             Alternativa de busqueda del AF en la BSEG
              if IT_MOVTOS-ANBWA is initial.
                SELECT * FROM BSEG WHERE BUKRS = BKPF-BUKRS
                                     AND BELNR = BKPF-BELNR
                                     AND GJAHR = BKPF-GJAHR
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917016*
*                                     AND LNRAN = it_anek-BUZEI.
                                     AND LNRAN = it_anek-BUZEI ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917016*
                  IF BSEG-ANLN1  EQ it_anek-ANLN1 AND
                     BSEG-ANLN2  EQ it_anek-ANLN2.
                     it_movtos-ANBWA  = BSEG-ANBWA.
                     it_movtos-DMBTR  = BSEG-DMBTR.
                     it_movtos-SHKZG  = BSEG-SHKZG.
                     it_movtos-BSCHL  = BSEG-BSCHL.
                     it_movtos-BEWAR  = BSEG-BEWAR.
                     APPEND it_movtos.
                  ENDIF.
                ENDSELECT.
              endif.
          else.
              SELECT * FROM BSEG WHERE BUKRS = BKPF-BUKRS
                                   AND BELNR = BKPF-BELNR
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917016*
*                                   AND GJAHR = BKPF-GJAHR.
                                   AND GJAHR = BKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK917016*

                IF BSEG-ANLN1  EQ it_anek-ANLN1 AND
                   BSEG-ANLN2  EQ it_anek-ANLN2.

                   READ TABLE it_movtos WITH KEY
                                         bukrs = BKPF-BUKRS
                                         anln1 = it_anek-anln1
                                         anln2 = it_anek-anln2
                                         BELNR = BKPF-BELNR
                                         BUDAT = BKPF-BUDAT
                                         BLDAT = BKPF-BLDAT
                                         GJAHR = BKPF-GJAHR
                                         XBLNR = BKPF-XBLNR
                                         ANBWA = BSEG-ANBWA
                                         BINARY SEARCH.
                   if sy-subrc <> 0.
                      it_movtos-bukrs  = it_anek-bukrs.
                      it_movtos-anln1  = it_anek-anln1.
                      it_movtos-anln2  = it_anek-anln2.

                      it_movtos-BELNR  = BKPF-BELNR.
                      it_movtos-BUDAT  = BKPF-BUDAT.
                      it_movtos-BLDAT  = BKPF-BLDAT.
                      it_movtos-GJAHR  = BKPF-GJAHR.
                      it_movtos-XBLNR  = BKPF-XBLNR.

                      it_movtos-ANBWA  = BSEG-ANBWA.
                      it_movtos-DMBTR  = BSEG-DMBTR.
                      it_movtos-SHKZG  = BSEG-SHKZG.
                      it_movtos-BSCHL  = BSEG-BSCHL.
                      it_movtos-BEWAR  = BSEG-BEWAR.
                      APPEND it_movtos.
                   endif.

                ENDIF.
              ENDSELECT.

          endif.

       ENDIF.
  ENDLOOP.


  SORT it_anla   BY BUKRS ANLN1 ANLN2.
  SORT it_anlp   BY BUKRS ANLN1 ANLN2 GJAHR PERAF AFBNR.
  SORT it_movtos BY BUKRS ANLN1 ANLN2 GJAHR.
  SORT it_anlc   BY BUKRS ANLN1 ANLN2 GJAHR AFABE.
  SORT it_anlz   BY BUKRS ANLN1 ANLN2.
  SORT it_bseg   BY BUKRS ANLN1 ANLN2.
  SORT it_t095   BY ktopl ktogr afabe.
  SORT it_ANKT   BY SPRAS ANLKL.
  SORT TABLA     BY BUKRS ANLN1 ANLN2.

  LOOP AT it_anla.
      ADD 1 TO wa_lineas.

      CLEAR tabla.
      MOVE-CORRESPONDING it_anla TO tabla.

      READ TABLE it_anlc WITH KEY
                             bukrs = P_BUKRS
                             anln1 = tabla-anln1
                             anln2 = tabla-anln2
                             GJAHR = P_GJAHR
                             AFABE = P_AFABE
                             BINARY SEARCH.
      if sy-subrc <> 0.
         clear it_anlc.
      endif.

      tabla-lin          = wa_lineas.
      tabla-afabe        = it_anlc-afabe.
      tabla-AFBTXT       = wa_AFBTXT.

      tabla-dep_inic_eje       = it_anlc-KNAFA.
      tabla-cm_inic_eje        = it_anlc-KAUFW.
      tabla-rev_amor_inic_eje  = it_anlc-KAUFN.
      tabla-INVER_INIC_EJE     = it_anlc-KINVZ.
      tabla-INVER_ACUM_EJE     = it_anlc-INVZM.

      tabla-AMONOR_INIC_EJE_2  = it_anlc-KNAFA.
      tabla-AMOESP_INIC_EJE_2  = it_anlc-KSAFA.
      tabla-AMONPL_INIC_EJE_2  = it_anlc-KAAFA.

      tabla-amort_acum_eje =
          ABS( it_anlc-KNAFA ) + ABS( it_anlc-NAFAG ) +
          ABS( it_anlc-KSAFA ) + ABS( it_anlc-SAFAG ) +
          ABS( it_anlc-KAAFA ) + ABS( it_anlc-AAFAG ) +
          ABS( it_anlc-KAUFN ) + ABS( it_anlc-AUFNG ) +
          ABS( it_anlc-INVZM ).


      if wa_mes_cierre = 'S'.
         tabla-dep_acum_eje       = it_anlc-NAFAG.   "AmoN a Contab
         tabla-cm_acum_eje        = it_anlc-AUFWB.   "Rev.Planif
         tabla-rev_amor_acum_eje  = it_anlc-AUFNG.   "Rev.plan.AmoN acum.
         tabla-dep_espec          = it_anlc-SAFAG.   "AmorEsp
         tabla-dep_no_plan        = it_anlc-AAFAG.   "AmorNoPlanif.

         READ TABLE it_anlp WITH KEY bukrs = tabla-bukrs
                                     anln1 = tabla-anln1
                                     anln2 = tabla-anln2
                                     BINARY SEARCH.
         IF sy-subrc = 0.
            tabla-dep_mes_eje        = it_anlp-NAFAZ.
            tabla-cm_mes_eje         = it_anlp-AUFWZ.
            tabla-rev_amor_mes_eje   = it_anlp-AUFNZ.
         ENDIF.
      else.
         LOOP AT it_anlp WHERE bukrs = tabla-bukrs
                           AND anln1 = tabla-anln1
                           AND anln2 = tabla-anln2.

            IF  it_anlp-GJAHR  EQ P_GJAHR
            AND it_anlp-PERAF  EQ P_PERAF.
                tabla-dep_mes_eje        = it_anlp-NAFAZ.
                tabla-cm_mes_eje         = it_anlp-AUFWZ.
                tabla-rev_amor_mes_eje   = it_anlp-AUFNZ.
            ENDIF.

            tabla-INVER_ACUM_EJE     = it_anlp-INVZM.

            tabla-dep_acum_eje       = it_anlp-NAFAG + it_anlp-NAFAZ.
            tabla-cm_acum_eje        = it_anlp-AUFWB + it_anlp-AUFWZ.
            tabla-rev_amor_acum_eje  = it_anlp-AUFNG + it_anlp-AUFNZ.
            tabla-dep_espec          = it_anlp-SAFAG + it_anlp-SAFAZ.
            tabla-dep_no_plan        = it_anlp-AAFAG + it_anlp-AAFAZ.
         ENDLOOP.
      endif.

       tabla-altas = 0.
       tabla-bajas = 0.
       tabla-dep_bajas = 0.
       tabla-dep_trasl = 0.
       tabla-trasl = 0.

      tabla-knafa = it_anlc-knafa.
*     ---------------------------------

      READ TABLE it_anlz WITH KEY bukrs = tabla-bukrs
                                  anln1 = tabla-anln1
                                  anln2 = tabla-anln2
                                  BINARY SEARCH.

      IF sy-subrc = 0.
        tabla-kostl = it_anlz-kostl.
      else.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*         SELECT SINGLE * FROM anlz WHERE
*                                  bukrs = tabla-bukrs AND
*                                  anln1 = tabla-anln1 AND
*                                  anln2 = tabla-anln2.
*
* NEW CODE
         SELECT *
         UP TO 1 ROWS  FROM anlz WHERE
                                  bukrs = tabla-bukrs AND
                                  anln1 = tabla-anln1 AND
                                  anln2 = tabla-anln2 ORDER BY PRIMARY KEY.

         ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
         IF SY-SUBRC = 0.
            tabla-kostl = anlz-kostl.
         ENDIF.
      ENDIF.
*     ---------------------------------
*     Cuenta Contable
      READ TABLE it_t095 WITH KEY ktopl = p_ktopl
                                  ktogr = tabla-ktogr
                                  afabe = 1
                                  BINARY SEARCH.
      IF sy-subrc = 0.
         tabla-ktansw =  it_t095-ktansw.
      ENDIF.
*     ---------------------------------
*     Descripcion Clase
      READ TABLE it_ANKT WITH KEY SPRAS = sy-langu
                                  ANLKL = tabla-ANLKL
                                  BINARY SEARCH.
      IF sy-subrc = 0.
         tabla-TXK50 =  it_ANKT-TXK50         .
      ENDIF.
*     ---------------------------------
*     Acreedor Razon Social
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM LFA1 WHERE LIFNR  = tabla-LIFNR.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM LFA1 WHERE LIFNR  = tabla-LIFNR ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF SY-SUBRC = 0.
        tabla-LIEFE = LFA1-NAME1.
        tabla-STCD1 = LFA1-STCD1.
      ENDIF.

*     ---------------------------------
*     Movimientos del AF
      wa_existe = 0.
      LOOP AT it_movtos WHERE BUKRS  = tabla-BUKRS
                          AND ANLN1  = tabla-ANLN1
                          AND ANLN2  = tabla-ANLN2
                          AND GJAHR  LE P_GJAHR.


              IF it_movtos-BUDAT+0(6) <= wa_periodo.

*                  Altas y Anula o Reversa Altas
                   IF it_movtos-ANBWA >= '100' AND it_movtos-ANBWA <= '110'.
                      IF wa_existe = 0 AND it_movtos-SHKZG = 'S' AND it_movtos-BSCHL = 70.
                        tabla-BELNR  = it_movtos-BELNR.
                        tabla-BUDAT  = it_movtos-BUDAT.
                        tabla-BLDAT  = it_movtos-BLDAT.
                        tabla-GJAHR  = it_movtos-GJAHR.
                        tabla-XBLNR  = it_movtos-XBLNR.
                        wa_existe = 1.
                      ENDIF.
                      IF it_movtos-BUDAT+0(4) EQ wa_periodo+0(4).
                        IF it_movtos-SHKZG = 'S' AND it_movtos-BSCHL = 70.
                            tabla-altas =  tabla-altas + it_movtos-DMBTR.
                        ELSEIF it_movtos-SHKZG = 'H' AND it_movtos-BSCHL = 75.
                            tabla-altas =  tabla-altas + ( it_movtos-DMBTR * -1 ).
                        ENDIF.
                      ENDIF.
                   ENDIF.


*                  Bajas
                   IF it_movtos-ANBWA >= '200' AND it_movtos-ANBWA < '300'.
                      IF it_movtos-BEWAR  >= '140' AND it_movtos-BEWAR  <= '150'.
*                         *** BAJAS y REVERSAS o ANULACION BAJAS
                          IF it_movtos-BUDAT+0(4) EQ wa_periodo+0(4).
                            IF it_movtos-SHKZG = 'H' AND it_movtos-BSCHL = 75..
                                tabla-bajas =  tabla-bajas + ( it_movtos-DMBTR * -1 ).
                            ELSEIF it_movtos-SHKZG = 'S' AND it_movtos-BSCHL = 70.
                                tabla-bajas =  tabla-bajas + it_movtos-DMBTR.
                            ENDIF.
                          ENDIF.
                      ELSEIF it_movtos-BEWAR  >= '240' AND it_movtos-BEWAR  <= '250'.
*                         *** DEP.BAJAS y REVERSAS o ANULACION DEP.BAJAS
                          IF it_anek-BUDAT+0(4) EQ wa_periodo+0(4).
                            IF it_movtos-SHKZG = 'S' AND it_movtos-BSCHL = 70.
                                tabla-dep_bajas =  tabla-dep_bajas + it_movtos-DMBTR.
                            ELSEIF it_movtos-SHKZG = 'H' AND it_movtos-BSCHL = 75.
                                tabla-dep_bajas =  tabla-dep_bajas + ( it_movtos-DMBTR * -1 ).
                            ENDIF.
                          ENDIF.
                      ENDIF.
                   ENDIF.

*                  Traslados
                   IF it_movtos-ANBWA >= '300' AND it_movtos-ANBWA < '400'.
                      IF it_movtos-BEWAR  = '120' OR it_movtos-BEWAR  = '170'.
                        IF it_movtos-BUDAT+0(4) EQ wa_periodo+0(4).
                          if it_movtos-SHKZG = 'S' AND it_movtos-BSCHL = 70.
                            tabla-trasl =  tabla-trasl + it_movtos-DMBTR.

                          elseif it_movtos-SHKZG = 'H' AND it_movtos-BSCHL = 75.
                            tabla-trasl =  tabla-trasl + ( it_movtos-DMBTR * -1 ).
                          endif.
                        ENDIF.
                      ELSEIF it_movtos-BEWAR  = '270'.
                          IF it_movtos-BUDAT+0(4) EQ wa_periodo+0(4).
                            if it_movtos-SHKZG = 'S' AND it_movtos-BSCHL = 70.
                              tabla-dep_trasl =  tabla-dep_trasl + it_movtos-DMBTR.

                            elseif it_movtos-SHKZG = 'H' AND it_movtos-BSCHL = 75.
                              tabla-dep_trasl =  tabla-dep_trasl + ( it_movtos-DMBTR * -1 ).
                            endif.
                          ENDIF.
                      ENDIF.
                   ENDIF.

              ENDIF.

      ENDLOOP.

*     ---------------------------------
*     Parámetros de amortización
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM anlb WHERE bukrs = tabla-bukrs
*                                  AND anln1 = tabla-anln1
*                                  AND anln2 = tabla-anln2
*                                  AND AFABE = tabla-AFABE.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM anlb WHERE bukrs = tabla-bukrs
                                  AND anln1 = tabla-anln1
                                  AND anln2 = tabla-anln2
                                  AND AFABE = tabla-AFABE ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        tabla-ndjar      = anlb-ndjar.
        tabla-ndper      = anlb-ndper.
        tabla-afabg      = anlb-afabg.
** V1 RVY 21.01.2021
*        tabla-VUMES      = anlb-ndjar * 12.
        tabla-VUMES      = anlb-ndper + anlb-ndjar * 12.
** V1 RVY 21.01.2021
        tabla-SCHRW      = anlb-SCHRW.
        tabla-SCHRW_PROZ = anlb-SCHRW_PROZ.

        Concatenate p_gjahr p_peraf '28' INTO wa_fecha_proc.
        IF tabla-afabg is initial.
           tabla-afabg = wa_fecha_proc.
        ENDIF.

** V1 RVY 21.01.2021
        IF tabla-afabg > wa_fecha_proc.
           wa_days   = 0.
           wa_months = 0.
           wa_years  = 0.
        ELSE.
** V1 RVY 21.01.2021
           CALL FUNCTION 'FI_PSO_DAYS_MONTHS_YEARS_GET'
             EXPORTING
               I_DATE_FROM       = tabla-afabg
               I_DATE_TO         = wa_fecha_proc
             IMPORTING
               E_DAYS            = wa_days
               E_MONTHS          = wa_months
               E_YEARS           = wa_years.
        endif.
      ENDIF.
*     ---------------------------------
*     Parámetros de amortización
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM anlh WHERE bukrs = tabla-bukrs
*                                  AND anln1 = tabla-anln1.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM anlh WHERE bukrs = tabla-bukrs
                                  AND anln1 = tabla-anln1 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        tabla-ANLHTXT = anlh-ANLHTXT.
      ENDIF.

*     ---------------------------------
      tabla-VUCON  = wa_months.
      IF tabla-VUMES > tabla-VUCON.
         tabla-VURES  = tabla-VUMES - tabla-VUCON.
      ENDIF.

      tabla-monto_adq = it_anlc-kansw.
      tabla-valor_ini = it_anlc-kansw + it_anlc-KSAFA + it_anlc-KAAFA +
                        tabla-cm_inic_eje + tabla-dep_inic_eje + tabla-rev_amor_inic_eje.

      IF tabla-BAJAS <> 0.
         tabla-dep_bajas = tabla-amort_acum_eje.
         if tabla-monto_adq > 0.
** V1 RVY 07.01.2020
*             tabla-BAJAS     = tabla-monto_adq + tabla-cm_acum_eje.
            tabla-BAJAS     = tabla-bajas + tabla-cm_acum_eje.
** V1 RVY 07.01.2020
         endif.
         if tabla-BAJAS > 0.
            tabla-BAJAS = tabla-BAJAS * -1.
         endif.
         tabla-bruto     =  tabla-monto_adq + tabla-ALTAS + tabla-BAJAS + tabla-TRASL + tabla-cm_acum_eje + tabla-REAVI + tabla-REAVP + tabla-INVER_ACUM_EJE.
         tabla-neto      =  tabla-bruto     + tabla-dep_inic_eje + tabla-dep_acum_eje + tabla-dep_bajas + tabla-dep_trasl + tabla-dep_espec + tabla-dep_no_plan +
                            tabla-rev_amor_acum_eje.
      ELSE.
        tabla-bruto      = tabla-valor_ini + tabla-ALTAS + tabla-BAJAS + tabla-TRASL + tabla-cm_acum_eje + tabla-REAVI + tabla-REAVP + tabla-INVER_ACUM_EJE.
        tabla-neto       = tabla-bruto     + tabla-dep_acum_eje + tabla-dep_bajas + tabla-dep_trasl + tabla-dep_espec + tabla-dep_no_plan +
                           tabla-rev_amor_acum_eje.
      ENDIF.

* Formulacion CSC
      tabla-VALOR_INIC_EJE_CSC = tabla-valor_ini - tabla-dep_inic_eje - tabla-rev_amor_inic_eje.
      tabla-MONTO_BRUTO_CSC    = tabla-VALOR_INIC_EJE_CSC + tabla-ALTAS + tabla-BAJAS + tabla-TRASL + tabla-cm_acum_eje + tabla-INVER_ACUM_EJE.
      tabla-Dep_Inic_Eje_CSC   = tabla-dep_inic_eje + tabla-Rev_Amor_Inic_Eje.
      tabla-Dep_Acum_CSC       = tabla-Dep_Inic_Eje_CSC  + tabla-Dep_Acum_Eje + tabla-dep_bajas + tabla-dep_trasl + tabla-dep_espec + tabla-dep_no_plan +
                                 tabla-rev_amor_acum_eje + tabla-DETEP.
      tabla-MONTO_NETO_CSC     = tabla-MONTO_BRUTO_CSC   + tabla-Dep_Acum_CSC.

      tabla-DEP_INIC_EJE_2     = tabla-AMONOR_INIC_EJE_2  + tabla-AMOESP_INIC_EJE_2  + tabla-AMONPL_INIC_EJE_2.

      APPEND tabla.

  ENDLOOP.

  IF p_grupo = 'X'.
    SORT TABLA   BY bukrs ktansw ANLKL.
    SORT RESUMEN BY bukrs ktansw ANLKL.

    LOOP AT tabla.
      READ TABLE resumen WITH KEY bukrs  = tabla-bukrs
                                  ktansw = tabla-ktansw
                                  ANLKL  = tabla-ANLKL.
      IF sy-subrc = 0.
        resumen-monto_adq          = resumen-monto_adq         + tabla-monto_adq.
        resumen-valor_ini          = resumen-valor_ini         + tabla-valor_ini.
        resumen-dep_inic_eje       = resumen-dep_inic_eje      + tabla-dep_inic_eje.
        resumen-dep_acum_eje       = resumen-dep_acum_eje      + tabla-dep_acum_eje.
        resumen-dep_mes_eje        = resumen-dep_mes_eje       + tabla-dep_mes_eje.

        resumen-cm_inic_eje        = resumen-cm_inic_eje       + tabla-cm_inic_eje.
        resumen-cm_acum_eje        = resumen-cm_acum_eje       + tabla-cm_acum_eje.
        resumen-cm_mes_eje         = resumen-cm_mes_eje        + tabla-cm_mes_eje.

        resumen-rev_amor_inic_eje  = resumen-rev_amor_inic_eje + tabla-rev_amor_inic_eje.
        resumen-rev_amor_acum_eje  = resumen-rev_amor_acum_eje + tabla-rev_amor_acum_eje.
        resumen-rev_amor_mes_eje   = resumen-rev_amor_mes_eje  + tabla-rev_amor_mes_eje.

        resumen-altas              = resumen-altas + tabla-altas.
        resumen-bajas              = resumen-bajas + tabla-bajas.

        resumen-inver_inic_eje     = resumen-inver_inic_eje + tabla-inver_inic_eje.
        resumen-inver_acum_eje     = resumen-inver_acum_eje + tabla-inver_acum_eje.

        resumen-bruto              = resumen-bruto + tabla-bruto.
        resumen-neto               = resumen-neto  + tabla-neto.
        resumen-SCHRW              = resumen-SCHRW + tabla-SCHRW.

        resumen-dep_bajas          = resumen-dep_bajas   + tabla-dep_bajas.
        resumen-dep_trasl          = resumen-dep_trasl   + tabla-dep_trasl.
        resumen-dep_espec          = resumen-dep_espec   + tabla-dep_espec.
        resumen-dep_no_plan        = resumen-dep_no_plan + tabla-dep_no_plan.



* Formulacion CSC
        resumen-VALOR_INIC_EJE_CSC   = resumen-VALOR_INIC_EJE_CSC + tabla-VALOR_INIC_EJE_CSC.
        resumen-MONTO_BRUTO_CSC      = resumen-MONTO_BRUTO_CSC    + tabla-MONTO_BRUTO_CSC.
        resumen-Dep_Inic_Eje_CSC     = resumen-Dep_Inic_Eje_CSC   + tabla-Dep_Inic_Eje_CSC.
        resumen-Dep_Acum_CSC         = resumen-Dep_Acum_CSC       + tabla-Dep_Acum_CSC.
        resumen-MONTO_NETO_CSC       = resumen-MONTO_BRUTO_CSC    + tabla-MONTO_BRUTO_CSC.

* Formulacion CSC 02.12.2011
        resumen-DEP_INIC_EJE_2       = resumen-DEP_INIC_EJE_2    + tabla-DEP_INIC_EJE_2.
        resumen-AMONOR_INIC_EJE_2    = resumen-AMONOR_INIC_EJE_2 + tabla-AMONOR_INIC_EJE_2.
        resumen-AMOESP_INIC_EJE_2    = resumen-AMOESP_INIC_EJE_2 + tabla-AMOESP_INIC_EJE_2.
        resumen-AMONPL_INIC_EJE_2    = resumen-AMONPL_INIC_EJE_2 + tabla-AMONPL_INIC_EJE_2.

        MODIFY RESUMEN INDEX sy-tabix.

      ELSE.
        CLEAR RESUMEN.
        MOVE-CORRESPONDING TABLA to RESUMEN.
        APPEND RESUMEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
.


ENDFORM.                    " SELECT_DATOS
*&---------------------------------------------------------------------*
*&      Form  LISTA_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LISTA_ALV .

  REFRESH: fieldcat.
  CLEAR: fieldcat, layout, print.

* ALV
* Definicion de parametros de layout
  layout-no_keyfix = ' '.
  layout-zebra = 'X'.
  layout-f2code = 'VER'.
  layout-colwidth_optimize = 'X'.


*   wa_titulo = 'Reporte Activo Fijo'.


  PERFORM f_asigna_fieldcat USING:
    'LIN'        'TABLA' ' ' ' '  '01' ' ' ' ' 'Linea' ' ' ' ' ' ' '5',
    'BUKRS'      'TABLA' ' ' ' '  '02' ' ' ' ' 'Soc' ' ' ' ' ' ' '4',
    'ANLN1'      'TABLA' ' ' ' '  '03' ' ' ' ' 'N°Activo'  ' ' ' ' ' ' '12',
    'ANLN2'      'TABLA' ' ' ' '  '04' ' ' ' ' 'SubN°'   ' ' ' ' ' ' '4',
    'TXT50'      'TABLA' ' ' ' '  '05' ' ' ' ' 'Descripcion_AF_1'   ' ' ' ' ' ' '50',
    'TXA50'      'TABLA' ' ' ' '  '06' ' ' ' ' 'Descripcion_AF_2'   ' ' ' ' ' ' '50',
    'ANLHTXT'    'TABLA' ' ' ' '  '07' ' ' ' ' 'Descripcion_AF_3'   ' ' ' ' ' ' '50',
    'AFABE'      'TABLA' ' ' ' '  '08' ' ' ' ' 'Area'   ' ' ' ' ' ' '5',
    'AFBTXT'     'TABLA' ' ' ' '  '09' ' ' ' ' 'Desc_Area_Valoracion'   ' ' ' ' ' ' '20',
    'KTANSW'     'TABLA' ' ' ' '  '10' ' ' ' ' 'Cta_Contab'   ' ' ' ' ' ' '10',
    'ANLKL'      'TABLA' ' ' ' '  '11' ' ' ' ' 'Clase'   ' ' ' ' ' ' '5',
    'TXK50'      'TABLA' ' ' ' '  '12' ' ' ' ' 'Descripcion_Clase'   ' ' ' ' ' ' '20',
    'KOSTL'      'TABLA' ' ' ' '  '13' ' ' ' ' 'CenCos'   ' ' ' ' ' ' '10',
    'ORD41'      'TABLA' ' ' ' '  '14' ' ' ' ' 'Torre'   ' ' ' ' ' ' '5',
    'ORD42'      'TABLA' ' ' ' '  '15' ' ' ' ' 'Zona'   ' ' ' ' ' ' '5',
    'ORD44'      'TABLA' ' ' ' '  '16' ' ' ' ' 'Leasing'   ' ' ' ' ' ' '5',
    'SERNR'      'TABLA' ' ' ' '  '17' ' ' ' ' 'N°Serie'   ' ' ' ' ' ' '18',
    'INVNR'      'TABLA' ' ' ' '  '18' ' ' ' ' 'N°Inventario'   ' ' ' ' ' ' '25',
    'STCD1'      'TABLA' ' ' ' '  '19' ' ' ' ' 'RUT_Prov'   ' ' ' ' ' ' '15',
    'LIEFE'      'TABLA' ' ' ' '  '20' ' ' ' ' 'Razon_Social_Prov'   ' ' ' ' ' ' '30',
*------------------
    'BELNR'      'TABLA' ' ' ' '  '21' ' ' ' ' 'N°Comp'   ' ' ' ' ' ' '10',
    'GJAHR'      'TABLA' ' ' ' '  '22' ' ' ' ' 'Año'   ' ' ' ' ' ' '4',
    'BUDAT'      'TABLA' ' ' ' '  '23' ' ' ' ' 'Fec_Contab'   ' ' ' ' ' ' '10',
    'BLDAT'      'TABLA' ' ' ' '  '24' ' ' ' ' 'Fec_Docum'   ' ' ' ' ' ' '10',
    'AFABG'      'TABLA' ' ' ' '  '25' ' ' ' ' 'Fec_Inic_Amort'   ' ' ' ' ' ' '10',
    'XBLNR'      'TABLA' ' ' ' '  '26' ' ' ' ' 'N°Factura'   ' ' ' ' ' ' '10',
*------------------
    'NDJAR'      'TABLA' ' ' ' '  '27' ' ' ' ' 'VU_Años'   ' ' ' ' ' ' '10',
    'VUMES'      'TABLA' ' ' ' '  '28' ' ' ' ' 'VU_Meses'   ' ' ' ' ' ' '10',
    'VUCON'      'TABLA' ' ' ' '  '29' ' ' ' ' 'VU_Trans_Meses'   ' ' ' ' ' ' '10',
    'VURES'      'TABLA' ' ' ' '  '30' ' ' ' ' 'VU_Rest_Meses'   ' ' ' ' ' ' '10',
    'MONTO_ADQ'  'TABLA' ' ' ' '  '31' ' ' ' ' 'VALOR_ADQ'   ' ' ' ' ' ' '30',
    'SCHRW'      'TABLA' ' ' ' '  '32' ' ' ' ' 'Valor_Res'   ' ' ' ' ' ' '30',
    'SCHRW_PROZ' 'TABLA' ' ' ' '  '33' ' ' ' ' 'Valor_Res_%'   ' ' ' ' ' ' '30',
*------------------
    'VALOR_INI'           'TABLA' ' ' ' '  '34' ' ' ' ' 'VALOR_INICIAL_EJERC'   ' ' ' ' ' ' '30',
    'VALOR_INIC_EJE_CSC'  'TABLA' ' ' ' '  '35' ' ' ' ' 'VALOR_INIC_EJE_CSC'   ' ' ' ' ' ' '30',
    'ALTAS'               'TABLA' ' ' ' '  '36' ' ' ' ' 'Altas'   ' ' ' ' ' ' '30',
    'BAJAS'               'TABLA' ' ' ' '  '37' ' ' ' ' 'Bajas'   ' ' ' ' ' ' '30',
    'TRASL'               'TABLA' ' ' ' '  '38' ' ' ' ' 'Traslados'   ' ' ' ' ' ' '30',
    'REAVI'               'TABLA' ' ' ' '  '39' ' ' ' ' 'Reaval_Inic_Eje'   ' ' ' ' ' ' '30',
    'REAVP'               'TABLA' ' ' ' '  '40' ' ' ' ' 'Reaval_Acum_Eje'   ' ' ' ' ' ' '30',
    'CM_ACUM_EJE'         'TABLA' ' ' ' '  '41' ' ' ' ' 'CM_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'CM_MES_EJE'          'TABLA' ' ' ' '  '42' ' ' ' ' 'CM_Mes_Eje'   ' ' ' ' ' ' '30',
    'INVER_INIC_EJE'      'TABLA' ' ' ' '  '43' ' ' ' ' 'Fmto_Inv_Inic_Eje'   ' ' ' ' ' ' '30',
    'INVER_ACUM_EJE'      'TABLA' ' ' ' '  '44' ' ' ' ' 'Fmto_Inv_Acum_Eje'   ' ' ' ' ' ' '30',
    'BRUTO'               'TABLA' ' ' ' '  '45' ' ' ' ' 'MONTO_BRUTO'   ' ' ' ' ' ' '30',
    'MONTO_BRUTO_CSC'     'TABLA' ' ' ' '  '46' ' ' ' ' 'MONTO_BRUTO_CSC'   ' ' ' ' ' ' '30',
    'DEP_INIC_EJE'        'TABLA' ' ' ' '  '47' ' ' ' ' 'Dep_Inic_Eje'   ' ' ' ' ' ' '30',
*
    'DEP_INIC_EJE_2'      'TABLA' ' ' ' '  '48' ' ' ' ' 'Dep_Inic_Eje_2'   ' ' ' ' ' ' '30',
    'AMONOR_INIC_EJE_2'   'TABLA' ' ' ' '  '49' ' ' ' ' 'AmorN_Inic_Eje'   ' ' ' ' ' ' '30',
    'AMOESP_INIC_EJE_2'   'TABLA' ' ' ' '  '50' ' ' ' ' 'AmorE_Inic_Eje'   ' ' ' ' ' ' '30',
    'AMONPL_INIC_EJE_2'   'TABLA' ' ' ' '  '51' ' ' ' ' 'AmorNP_Inic_Eje'   ' ' ' ' ' ' '30',
*
    'DEP_INIC_EJE_CSC'    'TABLA' ' ' ' '  '52' ' ' ' ' 'Dep_Inic_Eje_CSC'   ' ' ' ' ' ' '30',
    'DEP_MES_EJE'         'TABLA' ' ' ' '  '53' ' ' ' ' 'Dep_Mes_Eje'   ' ' ' ' ' ' '30',
    'DEP_ACUM_EJE'        'TABLA' ' ' ' '  '54' ' ' ' ' 'Dep_Acum_Eje'   ' ' ' ' ' ' '30',
    'DEP_BAJAS'           'TABLA' ' ' ' '  '55' ' ' ' ' 'Dep_Baja'   ' ' ' ' ' ' '30',
    'DEP_TRASL'           'TABLA' ' ' ' '  '56' ' ' ' ' 'Dep_Trasl'   ' ' ' ' ' ' '30',
    'DEP_ESPEC'           'TABLA' ' ' ' '  '57' ' ' ' ' 'Dep_Esp'   ' ' ' ' ' ' '30',
    'DEP_NO_PLAN'         'TABLA' ' ' ' '  '58' ' ' ' ' 'Dep_No_Plan'   ' ' ' ' ' ' '30',
    'REV_AMOR_INIC_EJE'   'TABLA' ' ' ' '  '59' ' ' ' ' 'Rev_Amort_Inic_Eje'   ' ' ' ' ' ' '30',
    'REV_AMOR_ACUM_EJE'   'TABLA' ' ' ' '  '60' ' ' ' ' 'Rev_Amort_Acum_Eje'   ' ' ' ' ' ' '30',
    'REV_AMOR_MES_EJE'    'TABLA' ' ' ' '  '61' ' ' ' ' 'Rev_Amort_Mes_Ejerc'   ' ' ' ' ' ' '30',
    'DETEI'               'TABLA' ' ' ' '  '62' ' ' ' ' 'Deteriodo_Inic_Eje'   ' ' ' ' ' ' '30',
    'DETEP'               'TABLA' ' ' ' '  '63' ' ' ' ' 'Deteriodo_Acum_Eje'   ' ' ' ' ' ' '30',
    'DEP_ACUM_CSC'        'TABLA' ' ' ' '  '64' ' ' ' ' 'Dep_Acum_CSC'   ' ' ' ' ' ' '30',
    'NETO'                'TABLA' ' ' ' '  '65' ' ' ' ' 'MONTO_NETO'   ' ' ' ' ' ' '30',
    'MONTO_NETO_CSC'      'TABLA' ' ' ' '  '66' ' ' ' ' 'MONTO_NETO_CSC'   ' ' ' ' ' ' '30'.

*------------------

  print-no_print_listinfos = 'X'.
  print-no_print_selinfos  = 'X'.

  repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
         EXPORTING
              i_callback_program       = repid
              i_callback_user_command  = g_user_command
              i_callback_html_top_of_page = g_callback_html_top_of_page
              i_structure_name         = 'TABLA'
              i_grid_title             =  wa_titulo
              is_layout                = layout
              it_fieldcat              = fieldcat[]
*             it_sort                  = sort[]
*             i_default                = 'X'
*             i_save                   = 'A'
*             is_variant               = variante
              is_print                 = print
         TABLES
              t_outtab                 = TABLA
         EXCEPTIONS
              program_error            = 1
              OTHERS                   = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " LISTA_ALV

*----------------------------------------------------------------------*
FORM LISTA_ALV_2 .
*----------------------------------------------------------------------*

  REFRESH: fieldcat.
  CLEAR: fieldcat, layout, print.

* ALV
* Definicion de parametros de layout
  layout-no_keyfix = ' '.
  layout-zebra = 'X'.
  layout-f2code = 'VER'.
  layout-colwidth_optimize = 'X'.


*  wa_titulo = 'Reporte Activo Fijo'.


  PERFORM f_asigna_fieldcat USING:
    'BUKRS'      'RESUMEN' ' ' ' '  '01' ' ' ' ' 'Sociedad' ' ' ' ' ' ' '5',
    'AFABE'      'RESUMEN' ' ' ' '  '02' ' ' ' ' 'Area'   ' ' ' ' ' ' '5',
    'AFBTXT'     'RESUMEN' ' ' ' '  '03' ' ' ' ' 'Descripcion_Area_Valoracion'   ' ' ' ' ' ' '20',
    'KTANSW'     'RESUMEN' ' ' ' '  '04' ' ' ' ' 'Cta_Contab'   ' ' ' ' ' ' '10',
    'ANLKL'      'RESUMEN' ' ' ' '  '05' ' ' ' ' 'Clase'   ' ' ' ' ' ' '5',
    'TXK50'      'RESUMEN' ' ' ' '  '06' ' ' ' ' 'Descripcion_Clase'   ' ' ' ' ' ' '20',
    'MONTO_ADQ'         'RESUMEN' ' ' ' '  '07' ' ' ' ' 'VALOR_ADQ'   ' ' ' ' ' ' '30',
    'SCHRW'             'RESUMEN' ' ' ' '  '08' ' ' ' ' 'Valor_Res'   ' ' ' ' ' ' '30',
    'SCHRW_PROZ'        'RESUMEN' ' ' ' '  '09' ' ' ' ' 'Valor_Res_%'   ' ' ' ' ' ' '30',
*------------------
    'VALOR_INI'           'RESUMEN' ' ' ' '  '10' ' ' ' ' 'VALOR_INIC_EJE'   ' ' ' ' ' ' '30',
    'VALOR_INIC_EJE_CSC'  'RESUMEN' ' ' ' '  '11' ' ' ' ' 'VALOR_INIC_EJE_CSC'   ' ' ' ' ' ' '30',
    'ALTAS'               'RESUMEN' ' ' ' '  '12' ' ' ' ' 'Altas'   ' ' ' ' ' ' '30',
    'BAJAS'               'RESUMEN' ' ' ' '  '13' ' ' ' ' 'Bajas'   ' ' ' ' ' ' '30',
    'TRASL'               'RESUMEN' ' ' ' '  '14' ' ' ' ' 'Traslados'   ' ' ' ' ' ' '30',
    'REAVI'               'RESUMEN' ' ' ' '  '15' ' ' ' ' 'Reaval_Inic_Eje'   ' ' ' ' ' ' '30',
    'REAVP'               'RESUMEN' ' ' ' '  '16' ' ' ' ' 'Reaval_Acum_Eje'   ' ' ' ' ' ' '30',
    'CM_ACUM_EJE'         'RESUMEN' ' ' ' '  '17' ' ' ' ' 'CM_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'CM_MES_EJE'          'RESUMEN' ' ' ' '  '18' ' ' ' ' 'CM_Mes_Eje'   ' ' ' ' ' ' '30',
    'INVER_INIC_EJE'      'RESUMEN' ' ' ' '  '19' ' ' ' ' 'Fmto_Inv_Inic_Eje'   ' ' ' ' ' ' '30',
    'INVER_ACUM_EJE'      'RESUMEN' ' ' ' '  '20' ' ' ' ' 'Fmto_Inv_Acum_Eje'   ' ' ' ' ' ' '30',
    'BRUTO'               'RESUMEN' ' ' ' '  '21' ' ' ' ' 'MONTO_BRUTO'   ' ' ' ' ' ' '30',
    'MONTO_BRUTO_CSC'     'RESUMEN' ' ' ' '  '22' ' ' ' ' 'MONTO_BRUTO_CSC'   ' ' ' ' ' ' '30',
    'DEP_INIC_EJE'        'RESUMEN' ' ' ' '  '23' ' ' ' ' 'Dep_Inic_Eje'   ' ' ' ' ' ' '30',
*
    'DEP_INIC_EJE_2'      'RESUMEN' ' ' ' '  '24' ' ' ' ' 'Dep_Inic_Eje_2'   ' ' ' ' ' ' '30',
    'AMONOR_INIC_EJE_2'   'RESUMEN' ' ' ' '  '25' ' ' ' ' 'AmorN_Inic_Eje'   ' ' ' ' ' ' '30',
    'AMOESP_INIC_EJE_2'   'RESUMEN' ' ' ' '  '26' ' ' ' ' 'AmorE_Inic_Eje'   ' ' ' ' ' ' '30',
    'AMONPL_INIC_EJE_2'   'RESUMEN' ' ' ' '  '27' ' ' ' ' 'AmorNP_Inic_Eje'   ' ' ' ' ' ' '30',
*
    'DEP_INIC_EJE_CSC'    'RESUMEN' ' ' ' '  '28' ' ' ' ' 'Dep_Inic_Eje_CSC'   ' ' ' ' ' ' '30',
    'DEP_MES_EJE'         'RESUMEN' ' ' ' '  '29' ' ' ' ' 'Dep_Mes_Eje'   ' ' ' ' ' ' '30',
    'DEP_ACUM_EJE'        'RESUMEN' ' ' ' '  '30' ' ' ' ' 'Dep_Acum_Eje'   ' ' ' ' ' ' '30',
    'DEP_BAJAS'           'RESUMEN' ' ' ' '  '31' ' ' ' ' 'Dep_Baja'   ' ' ' ' ' ' '30',
    'DEP_TRASL'           'RESUMEN' ' ' ' '  '32' ' ' ' ' 'Dep_Trasl'   ' ' ' ' ' ' '30',
    'DEP_ESPEC'           'RESUMEN' ' ' ' '  '33' ' ' ' ' 'Dep_Esp'   ' ' ' ' ' ' '30',
    'DEP_NO_PLAN'         'RESUMEN' ' ' ' '  '34' ' ' ' ' 'Dep_No_Plan'   ' ' ' ' ' ' '30',
    'REV_AMOR_INIC_EJE'   'RESUMEN' ' ' ' '  '35' ' ' ' ' 'Rev_Amort_Inic_Eje'   ' ' ' ' ' ' '30',
    'REV_AMOR_ACUM_EJE'   'RESUMEN' ' ' ' '  '36' ' ' ' ' 'Rev_Amort_Acum_Eje'   ' ' ' ' ' ' '30',
    'REV_AMOR_MES_EJE'    'RESUMEN' ' ' ' '  '37' ' ' ' ' 'Rev_Amort_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'DETEI'               'RESUMEN' ' ' ' '  '38' ' ' ' ' 'Deteriodo_Inic_Eje'   ' ' ' ' ' ' '30',
    'DETEP'               'RESUMEN' ' ' ' '  '39' ' ' ' ' 'Deteriodo_Acum_Eje'   ' ' ' ' ' ' '30',
    'DEP_ACUM_CSC'        'RESUMEN' ' ' ' '  '40' ' ' ' ' 'Dep_Acum_CSC'   ' ' ' ' ' ' '30',
    'NETO'                'RESUMEN' ' ' ' '  '41' ' ' ' ' 'MONTO_NETO'   ' ' ' ' ' ' '30',
    'MONTO_NETO_CSC'      'RESUMEN' ' ' ' '  '42' ' ' ' ' 'MONTO_NETO_CSC'   ' ' ' ' ' ' '30'.

*------------------

  print-no_print_listinfos = 'X'.
  print-no_print_selinfos  = 'X'.

  repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
         EXPORTING
              i_callback_program       = repid
              i_callback_user_command  = g_user_command
              i_callback_html_top_of_page = g_callback_html_top_of_page
              i_structure_name         = 'RESUMEN'
              i_grid_title             =  wa_titulo
              is_layout                = layout
              it_fieldcat              = fieldcat[]
*             it_sort                  = sort[]
*             i_default                = 'X'
*             i_save                   = 'A'
*             is_variant               = variante
              is_print                 = print
         TABLES
              t_outtab                 = RESUMEN
         EXCEPTIONS
              program_error            = 1
              OTHERS                   = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  F_ASIGNA_FIELDCAT
*&---------------------------------------------------------------------*
FORM F_ASIGNA_FIELDCAT USING x_field
                             x_tab
                             x_ref
                             x_ref_f
                             x_col_pos
                             x_hotspot
                             x_checkbox
                             x_seltext_l
                             x_key
                             x_no_out
                             x_do_sum
                             x_largo.

  fieldcat-fieldname     = x_field.
  fieldcat-tabname       = x_tab.
  fieldcat-ref_tabname   = x_ref.
  fieldcat-ref_fieldname = x_ref_f.
  fieldcat-col_pos       = x_col_pos.
  fieldcat-hotspot       = x_hotspot.
  fieldcat-checkbox      = x_checkbox.
  fieldcat-seltext_l     = x_seltext_l.
  fieldcat-key           = x_key.
  fieldcat-no_out        = x_no_out.
  fieldcat-do_sum        = x_do_sum.
  fieldcat-outputlen     = x_largo.

  IF x_field = 'MONTO_ADQ'           OR x_field = 'VALOR_INI' OR
     x_field = 'CM_INIC_EJE'         OR x_field = 'CM_ACUM_EJE'       OR x_field = 'CM_MES_EJE'       OR
     x_field = 'DEP_INIC_EJE'        OR x_field = 'DEP_ACUM_EJE'      OR x_field = 'DEP_MES_EJE'      OR
     x_field = 'DEP_BAJAS'           OR x_field = 'DEP_TRASL'         OR
     x_field = 'DEP_ESPEC'           OR x_field = 'DEP_NO_PLAN'       OR
     x_field = 'REV_AMOR_INIC_EJE'   OR x_field = 'REV_AMOR_ACUM_EJE' OR x_field = 'REV_AMOR_MES_EJE' OR
     x_field = 'REAVI'               OR x_field = 'REAVP'             OR
     x_field = 'DETEI'               OR x_field = 'DETEP'             OR
     x_field = 'BRUTO'               OR x_field = 'NETO'              OR
     x_field = 'ALTAS'               OR x_field = 'BAJAS'             OR x_field = 'TRASL'            OR
     x_field = 'INVER_INIC_EJE'      OR x_field = 'INVER_ACUM_EJE'    OR
     x_field = 'VALOR_INIC_EJE_CSC'  OR x_field = 'MONTO_BRUTO_CSC'   OR x_field = 'DEP_INIC_EJE_CSC' OR
     x_field = 'DEP_ACUM_CSC'        OR x_field = 'MONTO_NETO_CSC'    OR
*
     x_field = 'DEP_INIC_EJE_2'      OR
     x_field = 'AMONOR_INIC_EJE_2'   OR x_field = 'AMOESP_INIC_EJE_2' OR x_field = 'AMONPL_INIC_EJE_2' OR
*
     x_field = 'SCHRW'               OR
     x_field = 'DMBTR'.
*    fieldcat-currency      = 'CLP'.
     fieldcat-currency      = SAV_WAER1.
    fieldcat-do_sum = c_x.
  ENDIF.
  IF x_field = 'LIN' OR x_field = 'BUKRS' OR x_field = 'ANLN1' OR x_field = 'ANLN2'.
     fieldcat-key    = c_x.
  ENDIF.
  IF x_field = 'BELNR'.
     fieldcat-hotspot    = c_x.
  ENDIF.


  APPEND fieldcat.
  CLEAR fieldcat.

ENDFORM.                    " F_ASIGNA_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  SELECT_PARAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_PARAM .
   wa_AFABER = P_AFABE.
   swF4 = 1.
  PERFORM varianten_AFABE CHANGING P_AFABE.
ENDFORM.

*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
*---------------------------------------------------------------------*

* Nos aseguramos que no haya pinchado sobre una linea sin nada
  CHECK NOT rs_selfield-tabname IS INITIAL.

  CASE r_ucomm.
    WHEN 'VER'.
      READ TABLE TABLA INDEX rs_selfield-tabindex.
      wa_BUKRS = TABLA-BUKRS.
      wa_ANLN1 = TABLA-ANLN1.
      wa_BELNR = TABLA-BELNR.
      wa_GJAHR = TABLA-GJAHR.


      IF rs_selfield-FIELDNAME <> 'ANLN1' AND rs_selfield-FIELDNAME <> 'BELNR'.
        MESSAGE S004(zfi) WITH 'Debe seleccionar columnas N° Activo Fijo ó N° Comprobante'.

      ELSE.
        IF rs_selfield-FIELDNAME = 'ANLN1'.
           IF wa_BUKRS IS INITIAL or wa_ANLN1 is initial.
              MESSAGE S004(zfi) WITH 'Debe seleccionar un N° Activo Fijo'.
           ELSE.
              PERFORM ver_activo_fijo.
           ENDIF.
        ELSEIF rs_selfield-FIELDNAME = 'BELNR'.
           IF wa_BUKRS IS INITIAL or wa_BELNR is initial or wa_GJAHR is initial.
              MESSAGE S004(zfi) WITH 'Debe seleccionar un N° Comprobante'.
           ELSE.
              PERFORM ver_comprobante.
           ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN OTHERS.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VER_ACTIVO_FIJO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VER_ACTIVO_FIJO .
  SET PARAMETER ID: 'BUK' FIELD wa_BUKRS,
                    'AN1' FIELD wa_ANLN1.

  CALL TRANSACTION 'AW01N' AND SKIP FIRST SCREEN.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  VER_COMPROBANTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VER_COMPROBANTE .
  SET PARAMETER ID: 'GJR' FIELD wa_GJAHR,
                    'BLN' FIELD wa_BELNR,
                    'BUK' FIELD wa_BUKRS.

  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

ENDFORM.                    " VER_COMPROBANTE

*----------------------------------------------------------------------*
FORM VARIANTEN_AFABE  CHANGING P_AFABE.
*----------------------------------------------------------------------*
DATA: it_T093B LIKE T093B OCCURS 0 WITH HEADER LINE.
DATA: it_T093T LIKE T093T OCCURS 0 WITH HEADER LINE.
DATA: IT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH header line.
DATA: BEGIN OF IT_FINAL OCCURS 0,
        AFABER LIKE T093T-AFABER,
        AFBTXT LIKE T093T-AFBTXT,
      END OF IT_FINAL.

  IF P_BUKRS IS INITIAL.
     P_BUKRS = 'CL01'.
  ENDIF.

  CALL FUNCTION 'T093B_READ_MULTIPLE'
    EXPORTING
      I_BUKRS               = P_BUKRS
    TABLES
      T_T093B               = it_T093B
      T_T093T               = it_T093T
   EXCEPTIONS
     T093B_NOT_FOUND       = 1
     OTHERS                = 2.
  DESCRIBE TABLE it_T093T lines wa_cont.
  CHECK wa_cont > 0.

  LOOP AT it_T093T.
      MOVE-CORRESPONDING it_T093T TO IT_FINAL.
      APPEND IT_FINAL.
  ENDLOOP.

  IF swF4 = 0.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
          RETFIELD               = 'AFABER'
          VALUE_ORG              = 'S'
      TABLES
          VALUE_TAB              = IT_FINAL
          RETURN_TAB             = IT_RETURN.
    WRITE IT_RETURN-FIELDVAL TO P_AFABE.
  ELSE.
    LOOP AT it_FINAL WHERE AFABER = wa_AFABER.
        wa_AFBTXT = IT_FINAL-AFBTXT.
    ENDLOOP.
  ENDIF.


  REFRESH IT_FINAL.
ENDFORM.

*----------------------------------------------------------------------*
FORM VARIANTEN_ANLKL  CHANGING S_ANLKL.
*----------------------------------------------------------------------*
DATA: it_ankt   LIKE ANKT  OCCURS 0 WITH HEADER LINE.
DATA: IT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH header line.
DATA: BEGIN OF IT_FINAL OCCURS 0,
        ANLKL LIKE ANKT-ANLKL,
        TXK20 LIKE ANKT-TXK20,
      END OF IT_FINAL.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM ankt  INTO TABLE it_ankt WHERE SPRAS = sy-langu.
*
* NEW CODE
  SELECT *
 FROM ankt  INTO TABLE it_ankt WHERE SPRAS = sy-langu ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  LOOP AT it_ankt.
      MOVE-CORRESPONDING it_ankt TO IT_FINAL.
      APPEND IT_FINAL.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
        RETFIELD               = 'ANLKL'
        VALUE_ORG              = 'S'
    TABLES
        VALUE_TAB              = IT_FINAL
        RETURN_TAB             = IT_RETURN.

 WRITE IT_RETURN-FIELDVAL TO S_ANLKL.
  REFRESH IT_FINAL.
ENDFORM.


*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  html_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DOCUMENT   text
*----------------------------------------------------------------------*
form html_top_of_page using document
                            type ref to cl_dd_document.     "#EC CALLED

  data:   l_title      type sdydo_text_element,
          l_text       type sdydo_text_element,
          l_font       type sdydo_attribute value '1',
          ls_zfigiro   type zfigiro,
          l_month      type fcltx.
*L1
  l_text = 'Sociedad:'.
  call method document->new_line.
  call method document->add_text
    exporting
      text         = l_text
      sap_emphasis = 'Strong'.

  call method document->add_gap
    exporting
      width = 8.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single * from t001 where BUKRS = p_bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  from t001 where BUKRS = p_bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  concatenate t001-BUTXT ' '
    into l_text separated by space.
  call method document->add_text
    exporting
      text         = l_text
      sap_emphasis = 'Strong'.
*L2
  l_text = 'Ejercicio / Periodo:'.
  call method document->new_line.
  call method document->add_text
    exporting
      text         = l_text
      sap_emphasis = 'Strong'.

  call method document->add_gap
    exporting
      width = 8.

  concatenate p_gjahr p_peraf into l_text separated by '/'.
  call method document->add_text
    exporting
      text         = l_text
      sap_fontsize = l_font.

*L3
  l_text = 'Area Valoracion:'.
  call method document->new_line.
  call method document->add_text
    exporting
      text         = l_text
      sap_emphasis = 'Strong'.

  call method document->add_gap
    exporting
      width = 8.

  concatenate P_AFABE wa_AFBTXT '' into l_text separated by space.
  call method document->add_text
    exporting
      text         = l_text
      sap_fontsize = l_font.
*L4
  l_text = 'Fecha/Hora/Usuario:'.
  call method document->new_line.
  call method document->add_text
    exporting
      text         = l_text
      sap_emphasis = 'Strong'.

  call method document->add_gap
    exporting
      width = 8.

  concatenate sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum+0(4) ' - ' sy-UZEIT+0(2) ':' sy-UZEIT+2(2) ' - '  sy-UNAME into l_text.
  call method document->add_text
    exporting
      text         = l_text
      sap_fontsize = l_font.


endform.                    "html_top_of_page
*&---------------------------------------------------------------------*
*&      Form  GET_YEAR_RESTRICTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_YEAR_RESTRICTION USING i_bukrs edit_jahre  .
    DATA: wa_anla TYPE anla.
    DATA: ld_flag_no_deact_date TYPE c.                        "> 711068
    DATA: gd_deakt TYPE deakt.
    DATA: gjahr TYPE t009b-bdatj.

    DATA: e_min_year TYPE gjahr, e_max_year TYPE gjahr, i_buchen TYPE c.

    e_min_year = 0.                    " im Fehlerfall
    e_max_year = 0.
    i_buchen   = ' '.


*   search for asset highest deakt date.
*   and minimum year is minimum cap. year
    LOOP AT lt_anla INTO wa_anla.
      IF ld_flag_no_deact_date IS INITIAL.                     "> 711068
        IF NOT wa_anla-deakt IS INITIAL.                       "> 711068
          IF wa_anla-deakt GT gd_deakt.                        "> 711068
            gd_deakt = wa_anla-deakt.                          "> 711068
          ENDIF.                                               "> 711068
        ELSE.                                                  "> 711068
          ld_flag_no_deact_date = 'X'.                         "> 711068
          CLEAR gd_deakt.                                      "> 711068
        ENDIF.                                                 "> 711068
      ENDIF.                                                   "> 711068

      IF e_min_year IS INITIAL.
        e_min_year = wa_anla-zujhr.
      ENDIF.

      IF NOT wa_anla-zujhr IS INITIAL AND
             wa_anla-zujhr LT e_min_year.
        e_min_year = wa_anla-zujhr.
      ENDIF.

      IF e_min_year IS INITIAL.
*        if still no year could be found take anla-erdat
        CALL FUNCTION 'DATE_TO_PERIOD_CONVERT'
          EXPORTING
            i_date         = wa_anla-erdat
            i_periv        = ls_t093c-periv
          IMPORTING
            e_gjahr        = e_min_year
          EXCEPTIONS
            input_false    = 1
            t009_notfound  = 2
            t009b_notfound = 3
            OTHERS         = 4.
      ENDIF.
    ENDLOOP.


    IF ( i_buchen IS INITIAL ).
*      e_max_year = e_min_year + 100.
      e_max_year = ls_t093c-lgjahr + 100.                      "> 648400
    ELSE.
      e_max_year = ls_t093c-lgjahr.  "laufendes Geschäftsjahr
    ENDIF.

    IF NOT gd_deakt IS INITIAL.
*         größtes mögliche Jahr soll das Jahr der Deaktivierung sein.
      CALL FUNCTION 'DATE_TO_PERIOD_CONVERT'
        EXPORTING
          i_date         = gd_deakt
          i_periv        = ls_t093c-periv
        IMPORTING
          e_gjahr        = gjahr
        EXCEPTIONS
          input_false    = 1
          t009_notfound  = 2
          t009b_notfound = 3
          OTHERS         = 4.

      e_max_year = gjahr.

    ENDIF.


    IF ( ( e_min_year GT 0 ) AND  ( e_min_year LE e_max_year ) ).
      IF ( edit_jahre GE e_min_year ) AND
         ( edit_jahre LE e_max_year ).
        wa_eliminar = 'N'.
      ELSE.
**          MESSAGE s581 WITH min_year max_year.(Seleccione un período de tiempo entre & y &)
        wa_eliminar = 'S'.
      ENDIF.
    ENDIF.


ENDFORM.                    " GET_YEAR_RESTRICTION


*---------------------------------------------------------------------*
* Ermittlung des Waehrungsschluessels zu AfA-Bereich WER_AFABE.       *
*---------------------------------------------------------------------*
* --> WER_AFABE  AfA-Bereich                                          *
* <-- WER_WAERS  Waehrungsschluessel                                  *
*---------------------------------------------------------------------*
FORM waehrung_ermitteln USING value(wer_afabe) wer_waers.

  CLEAR wer_waers.
  IF NOT umvar IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t091c WHERE umvar = umvar.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t091c WHERE umvar = umvar ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0 AND NOT t091c-waers IS INITIAL.
      wer_waers = t091c-waers.
      EXIT.
    ENDIF.
  ENDIF.

* Waehrungsschluessel aus T093B.
* select single * from t093b
*   where bukrs eq anlav-bukrs
*   and   afabe eq wer_afabe.

  t093b-bukrs = p_bukrs.
  IF wer_afabe is initial.
    t093b-afabe = con_leitbe.
  ELSE.
    t093b-afabe = wer_afabe.
  ENDIF.
*  call function 'T093B_READ'
*       exporting
*            f_t093b   = t093b
*       importing
*            f_t093b   = t093b
*       exceptions
*            not_found = 1
*            others    = 2.

  CALL FUNCTION 'T093B_READ_VIRTUAL'
*    IMPORTING
*         E_VIRTUAL =
     CHANGING
          f_t093b   = t093b
     EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
  IF sy-subrc EQ 0.
    wer_waers = t093b-waers.
* Nix gefunden?
  ELSE.
*   Dann nimm die Hauswaehrung.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t001
*      WHERE bukrs EQ p_bukrs.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t001
      WHERE bukrs EQ p_bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    wer_waers = t001-waers.
  ENDIF.

ENDFORM.                    "WAEHRUNG_ERMITTELN
