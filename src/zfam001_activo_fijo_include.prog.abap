*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFAM001_ACTIVO_FIJO_INCLUDE
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
  refresh: it_anlz, it_anla, it_anlp, it_anlc, it_bseg, TABLA, RESUMEN.
  clear:   it_anlz, it_anla, it_anlp, it_anlc, it_bseg, TABLA, RESUMEN.
  clear:   wa_lineas.

  CONCATENATE p_gjahr p_peraf INTO wa_periodo.

  wa_mes_cierre = P_PERAF.
  SELECT * FROM TABA WHERE BUKRS  EQ P_BUKRS
                       AND AFBLGJ EQ P_GJAHR
                       ORDER BY AFBLPE DESCENDING.
        wa_mes_cierre = TABA-AFBLPE.
        exit.
  ENDSELECT.


* Activos con CeCos
  SELECT * FROM anlz  INTO TABLE it_anlz WHERE BUKRS  EQ P_BUKRS
                                         AND   ANLN1  IN S_ANLN1
                                         AND   ANLN2  IN S_ANLN2
                                         AND   KOSTL  IN S_KOSTL.
  DESCRIBE TABLE it_anlz lines wa_cont.
  check wa_cont > 0.

* Maestro de Activos
  SELECT * FROM anla
       INTO CORRESPONDING FIELDS OF TABLE it_anla
       FOR ALL ENTRIES IN it_anlz
       WHERE BUKRS  EQ it_anlz-BUKRS
       AND   ANLN1  EQ it_anlz-ANLN1
       AND   ANLN2  EQ it_anlz-ANLN2
       AND   ANLKL  IN S_ANLKL.

  DESCRIBE TABLE it_anla lines wa_cont.
  check wa_cont > 0.


* Valores Periodos
  IF P_PERAF < wa_mes_cierre.
      wa_distinto_mes = 'S'.
      SELECT * FROM anlp
           INTO CORRESPONDING FIELDS OF TABLE it_anlp
           FOR ALL ENTRIES IN it_anla
           WHERE BUKRS  EQ it_anla-BUKRS
           AND   GJAHR  EQ P_GJAHR
           AND   PERAF  LE P_PERAF
           AND   ANLN1  EQ it_anla-ANLN1
           AND   ANLN2  EQ it_anla-ANLN2
           AND   AFABER EQ P_AFABE.
  ELSE.
      wa_distinto_mes = 'N'.
      SELECT * FROM anlp
           INTO CORRESPONDING FIELDS OF TABLE it_anlp
           FOR ALL ENTRIES IN it_anla
           WHERE BUKRS  EQ it_anla-BUKRS
           AND   GJAHR  EQ P_GJAHR
           AND   PERAF  EQ P_PERAF
           AND   ANLN1  EQ it_anla-ANLN1
           AND   ANLN2  EQ it_anla-ANLN2
           AND   AFABER EQ P_AFABE.

  ENDIF.


* Valores
  SELECT * FROM anlc
       INTO CORRESPONDING FIELDS OF TABLE it_anlc
       FOR ALL ENTRIES IN it_anla
       WHERE BUKRS  EQ it_anla-BUKRS
       AND   ANLN1  EQ it_anla-ANLN1
       AND   ANLN2  EQ it_anla-ANLN2
       AND   GJAHR  EQ P_GJAHR
       AND   AFABE  EQ P_AFABE.

*  Tabla de Movimientos (Altas, Bajas, Traslados)
  SELECT * FROM ANEK
       INTO CORRESPONDING FIELDS OF TABLE it_ANEK
       FOR ALL ENTRIES IN it_anla
       WHERE BUKRS  EQ it_anla-BUKRS
       AND   ANLN1  EQ it_anla-ANLN1
       AND   ANLN2  EQ it_anla-ANLN2
       AND   GJAHR  LE P_GJAHR.

  SORT it_anek BY BUKRS ANLN1 ANLN2 GJAHR.
  LOOP AT it_anek.
       wa_tabix = sy-tabix.
       wa_flag = 'N'.

       SELECT SINGLE * FROM BKPF WHERE BUKRS = IT_ANEK-AWORG+0(4)
                                 AND   BELNR = IT_ANEK-BELNR
                                 AND   GJAHR = IT_ANEK-AWORG+4(4).
       IF sy-subrc = 0.
          wa_flag = 'S'.
       ELSE.
         WA_BELNR_NUMC  =  IT_ANEK-BELNR.

         CONCATENATE WA_BELNR_NUMC IT_ANEK-AWORG INTO WA_AWKEY.
         SELECT SINGLE * FROM BKPF WHERE BUKRS = IT_ANEK-AWORG+0(4)
                                   AND   AWKEY = WA_AWKEY.
         IF sy-subrc = 0.
            wa_flag = 'S'.
         ENDIF.
       ENDIF.

       IF wa_flag = 'N'.
          DELETE it_anek INDEX wa_tabix.
       ELSE.
          it_anek-BELNR2  = BKPF-BELNR.
          it_anek-BUDAT2  = BKPF-BUDAT.
          it_anek-BLDAT2  = BKPF-BLDAT.
          it_anek-GJAHR2  = BKPF-GJAHR.
          if BKPF-XBLNR is initial.
             clear it_anek-XBLNR2.
          else.
             it_anek-XBLNR2  = BKPF-XBLNR.
          endif.
SELECT * FROM BSEG WHERE BUKRS = BKPF-BUKRS
AND BELNR = BKPF-BELNR
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES04 ECDK917080 *
*AND GJAHR = BKPF-GJAHR.
AND GJAHR = BKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES04 ECDK917080 *
            IF BSEG-ANLN1  EQ it_anek-ANLN1 AND
               BSEG-ANLN2  EQ it_anek-ANLN2.
               it_anek-ANBWA2  = BSEG-ANBWA.
               it_anek-DMBTR2  = BSEG-DMBTR.
               it_anek-SHKZG2  = BSEG-SHKZG.
            ENDIF.
          ENDSELECT.

          MODIFY it_anek INDEX wa_tabix.

       ENDIF.
  ENDLOOP.


  SORT it_anlp BY BUKRS ANLN1 ANLN2 GJAHR PERAF AFBNR.
  SORT it_anek BY BUKRS ANLN1 ANLN2 GJAHR.
  SORT it_anlc BY BUKRS ANLN1 ANLN2.
  SORT it_anla BY BUKRS ANLN1 ANLN2.
  SORT it_anlz BY BUKRS ANLN1 ANLN2.
  SORT it_bseg BY BUKRS ANLN1 ANLN2.
  SORT TABLA   BY BUKRS ANLN1 ANLN2.

  LOOP AT it_anlc.
      CLEAR tabla.
      ADD 1 TO wa_lineas.

      tabla-lin          = wa_lineas.
      tabla-bukrs        = it_anlc-bukrs.
      tabla-anln1        = it_anlc-anln1.
      tabla-anln2        = it_anlc-anln2.
      tabla-afabe        = it_anlc-afabe.
      tabla-AFBTXT       = wa_AFBTXT.

      tabla-dep_inic_eje       = it_anlc-KNAFA.
      tabla-cm_inic_eje        = it_anlc-KAUFW.
      tabla-rev_amor_inic_eje  = it_anlc-KAUFN.

      if wa_distinto_mes = 'N'.
         tabla-dep_acum_eje       = it_anlc-NAFAG.
         tabla-cm_acum_eje        = it_anlc-AUFWP.
         tabla-rev_amor_acum_eje  = it_anlc-AUFNP.
         READ TABLE it_anlp WITH KEY bukrs = tabla-bukrs
                                     anln1 = tabla-anln1
                                     anln2 = tabla-anln2.
         IF sy-subrc = 0.
            tabla-dep_mes_eje        = it_anlp-NAFAZ.
            tabla-cm_mes_eje         = it_anlp-AUFWZ.
            tabla-rev_amor_mes_eje   = it_anlp-AUFNZ.
         ENDIF.
      else.
         LOOP AT it_anlp WHERE bukrs = tabla-bukrs
                           AND anln1 = tabla-anln1
                           AND anln2 = tabla-anln2.

            tabla-dep_acum_eje       = it_anlp-NAFAG + it_anlp-NAFAZ.
            tabla-cm_acum_eje        = it_anlp-AUFWB + it_anlp-AUFWZ.
            tabla-rev_amor_acum_eje  = it_anlp-AUFNG + it_anlp-AUFNZ.
            tabla-dep_mes_eje        = it_anlp-NAFAZ.
            tabla-cm_mes_eje         = it_anlp-AUFWZ.
            tabla-rev_amor_mes_eje   = it_anlp-AUFNZ.
         ENDLOOP.
      endif.

*      tabla-altas = it_anlc-ANSWL.
*      tabla-bajas = it_anlc-ABGAN.
*      tabla-inver = it_anlc-INVZM.

       tabla-altas = 0.
       tabla-bajas = 0.
       tabla-trasl = 0.
       tabla-inver = 0.

      tabla-knafa = it_anlc-knafa.
*     ---------------------------------
      READ TABLE it_anla WITH KEY bukrs = tabla-bukrs
                                  anln1 = tabla-anln1
                                  anln2 = tabla-anln2.
      IF sy-subrc = 0.
        tabla-txt50   = it_anla-txt50.
        tabla-TXA50   = it_anla-TXA50.
        tabla-aktiv = it_anla-aktiv.
        tabla-ktogr = it_anla-ktogr.
        tabla-ANLKL = it_anla-ANLKL.
        tabla-AKTIV = it_anla-AKTIV.
        tabla-LIFNR = it_anla-LIFNR.
        tabla-URWRT = it_anla-URWRT.
        tabla-ORD41 = it_anla-ORD41.
        tabla-ORD42 = it_anla-ORD42.
        tabla-ORD44 = it_anla-ORD44.
        tabla-SERNR = it_anla-SERNR.
        tabla-INVNR = it_anla-INVNR.
      ENDIF.
*     ---------------------------------
      READ TABLE it_anlz WITH KEY bukrs = tabla-bukrs
                                  anln1 = tabla-anln1
                                  anln2 = tabla-anln2.

      IF sy-subrc = 0.
        tabla-kostl = it_anlz-kostl.
      ENDIF.
*     ---------------------------------
*     Cuenta Contable
      SELECT SINGLE ktansw INTO tabla-ktansw FROM t095
                                WHERE ktopl = p_ktopl
                                  AND ktogr = tabla-ktogr
                                  AND afabe = 1.
*     ---------------------------------
*     Descripcion Clase
      SELECT SINGLE TXK50 INTO tabla-TXK50 FROM ANKT
                                WHERE SPRAS = sy-langu
                                  AND ANLKL = tabla-ANLKL.
*     ---------------------------------
*     Acreedor Razon Social
      SELECT SINGLE * FROM LFA1 WHERE LIFNR  = tabla-LIFNR.
      IF SY-SUBRC = 0.
        tabla-LIEFE = LFA1-NAME1.
        tabla-STCD1 = LFA1-STCD1.
      ENDIF.

*     ---------------------------------
*     Cabecera de documento de contabilización AF
      wa_existe = 0.
      LOOP AT it_ANEK WHERE BUKRS  = tabla-BUKRS
                        AND ANLN1  = tabla-ANLN1
                        AND ANLN2  = tabla-ANLN2
                        AND GJAHR LE P_GJAHR.


              IF it_anek-BUDAT2+0(6) <= wa_periodo.
*                  Altas
                   IF it_anek-ANBWA2 >= '100' AND it_anek-ANBWA2 <= '110'.
                      IF wa_existe = 0.
                        tabla-BELNR  = it_anek-BELNR2.
                        tabla-BUDAT  = it_anek-BUDAT2.
                        tabla-BLDAT  = it_anek-BLDAT2.
                        tabla-GJAHR  = it_anek-GJAHR2.
                        tabla-XBLNR  = it_ANEK-XBLNR2.
                        wa_existe = 1.
                      ENDIF.
                      IF it_anek-BUDAT2+0(4) EQ wa_periodo+0(4).
                        if it_anek-SHKZG2 = 'S'.
                          tabla-altas =  tabla-altas + it_anek-DMBTR2.
                        else.
                          tabla-altas =  tabla-altas - it_anek-DMBTR2.
                        endif.
                      ENDIF.
                   ENDIF.

*                  Bajas
                   IF it_anek-ANBWA2 >= '200' AND it_anek-ANBWA2 < '300'.
                      IF it_anek-BUDAT2+0(4) EQ wa_periodo+0(4).
                        if it_anek-SHKZG2 = 'S'.
                          tabla-bajas =  tabla-bajas + it_anek-DMBTR2.
                        else.
                          tabla-bajas =  tabla-bajas - it_anek-DMBTR2.
                        endif.
                      ENDIF.
                   ENDIF.

*                  Traslados
                   IF it_anek-ANBWA2 >= '300' AND it_anek-ANBWA2 < '340'.
                      IF it_anek-BUDAT2+0(4) EQ wa_periodo+0(4).
                        if it_anek-SHKZG2 = 'S'.
                          tabla-trasl =  tabla-trasl + it_anek-DMBTR2.
                        else.
                          tabla-trasl =  tabla-trasl - it_anek-DMBTR2.
                        endif.
                      ENDIF.
                   ENDIF.

              ENDIF.

      ENDLOOP.

*     ---------------------------------
*     Parámetros de amortización
      SELECT SINGLE * FROM anlb WHERE bukrs = tabla-bukrs
                                  AND anln1 = tabla-anln1
                                  AND anln2 = tabla-anln2
                                  AND AFABE = tabla-AFABE.
      IF sy-subrc = 0.
        tabla-ndjar      = anlb-ndjar.
        tabla-ndper      = anlb-ndper.
        tabla-afabg      = anlb-afabg.
        tabla-VUMES      = anlb-ndjar * 12.
        tabla-SCHRW      = anlb-SCHRW.
        tabla-SCHRW_PROZ = anlb-SCHRW_PROZ.

        Concatenate p_gjahr p_peraf '28' INTO wa_fecha_proc.
        IF tabla-afabg is initial.
           tabla-afabg = wa_fecha_proc.
        ENDIF.
        CALL FUNCTION 'FI_PSO_DAYS_MONTHS_YEARS_GET'
          EXPORTING
            I_DATE_FROM       = tabla-afabg
            I_DATE_TO         = wa_fecha_proc
          IMPORTING
            E_DAYS            = wa_days
            E_MONTHS          = wa_months
            E_YEARS           = wa_years.
      ENDIF.
*     ---------------------------------
*     Parámetros de amortización
      SELECT SINGLE * FROM anlh WHERE bukrs = tabla-bukrs
                                  AND anln1 = tabla-anln1.
      IF sy-subrc = 0.
        tabla-ANLHTXT = anlh-ANLHTXT.
      ENDIF.

*     ---------------------------------
      tabla-VUCON  = wa_months.
      IF tabla-VUMES > tabla-VUCON.
         tabla-VURES  = tabla-VUMES - tabla-VUCON.
      ENDIF.

      tabla-monto_adq = it_anlc-kansw.
      tabla-valor_ini = it_anlc-kansw +  tabla-cm_inic_eje + tabla-dep_inic_eje + tabla-rev_amor_inic_eje .
      tabla-bruto = tabla-valor_ini   +  tabla-ALTAS + tabla-BAJAS + tabla-TRASL + tabla-cm_acum_eje  +  tabla-REAVI + tabla-REAVP .
      tabla-neto  = tabla-bruto       +  tabla-dep_acum_eje + tabla-rev_amor_acum_eje.

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
        resumen-inver              = resumen-inver + tabla-inver.
        resumen-bruto              = resumen-bruto + tabla-bruto.
        resumen-neto               = resumen-neto  + tabla-neto.
        resumen-SCHRW              = resumen-SCHRW + tabla-SCHRW.

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
    'LIN'        'TABLA' ' ' ' '  '01' ' ' ' ' 'Lineas' ' ' ' ' ' ' '5',
    'BUKRS'      'TABLA' ' ' ' '  '02' ' ' ' ' 'Sociedad' ' ' ' ' ' ' '5',
    'ANLN1'      'TABLA' ' ' ' '  '03' ' ' ' ' 'Numero_Activo'  ' ' ' ' ' ' '15',
    'ANLN2'      'TABLA' ' ' ' '  '04' ' ' ' ' 'SubNro'   ' ' ' ' ' ' '5',
    'TXT50'      'TABLA' ' ' ' '  '05' ' ' ' ' 'Descripcion_Activo_1'   ' ' ' ' ' ' '50',
    'TXA50'      'TABLA' ' ' ' '  '06' ' ' ' ' 'Descripcion_Activo_2'   ' ' ' ' ' ' '50',
    'ANLHTXT'    'TABLA' ' ' ' '  '07' ' ' ' ' 'Descripcion_Activo_3'   ' ' ' ' ' ' '50',
    'AFABE'      'TABLA' ' ' ' '  '08' ' ' ' ' 'Area'   ' ' ' ' ' ' '5',
    'AFBTXT'     'TABLA' ' ' ' '  '09' ' ' ' ' 'Descripcion_Area_Valoracion'   ' ' ' ' ' ' '20',
    'KTANSW'     'TABLA' ' ' ' '  '10' ' ' ' ' 'Cta_Contable'   ' ' ' ' ' ' '15',
    'ANLKL'      'TABLA' ' ' ' '  '11' ' ' ' ' 'Clase'   ' ' ' ' ' ' '5',
    'TXK50'      'TABLA' ' ' ' '  '12' ' ' ' ' 'Descripcion_Clase'   ' ' ' ' ' ' '20',
    'KOSTL'      'TABLA' ' ' ' '  '13' ' ' ' ' 'Centro_Costo'   ' ' ' ' ' ' '15',
    'ORD41'      'TABLA' ' ' ' '  '14' ' ' ' ' 'Torre'   ' ' ' ' ' ' '15',
    'ORD42'      'TABLA' ' ' ' '  '15' ' ' ' ' 'Zona'   ' ' ' ' ' ' '15',
    'ORD44'      'TABLA' ' ' ' '  '16' ' ' ' ' 'Leasing'   ' ' ' ' ' ' '15',
    'SERNR'      'TABLA' ' ' ' '  '17' ' ' ' ' 'N° Serie'   ' ' ' ' ' ' '15',
    'INVNR'      'TABLA' ' ' ' '  '18' ' ' ' ' 'N° Inventario'   ' ' ' ' ' ' '15',
    'STCD1'      'TABLA' ' ' ' '  '19' ' ' ' ' 'RUT_Proveedor'   ' ' ' ' ' ' '15',
    'LIEFE'      'TABLA' ' ' ' '  '20' ' ' ' ' 'Nombre_del_Proveedor'   ' ' ' ' ' ' '30',
*------------------
    'BELNR'      'TABLA' ' ' ' '  '21' ' ' ' ' 'Nro_Comprobante'   ' ' ' ' ' ' '10',
    'GJAHR'      'TABLA' ' ' ' '  '22' ' ' ' ' 'Año_Contable'   ' ' ' ' ' ' '10',
    'BUDAT'      'TABLA' ' ' ' '  '23' ' ' ' ' 'Fecha_Contab'   ' ' ' ' ' ' '10',
    'BLDAT'      'TABLA' ' ' ' '  '24' ' ' ' ' 'Fecha_Documento'   ' ' ' ' ' ' '10',
    'AFABG'      'TABLA' ' ' ' '  '25' ' ' ' ' 'Fecha_Inic_Amort'   ' ' ' ' ' ' '10',
    'XBLNR'      'TABLA' ' ' ' '  '26' ' ' ' ' 'Nro_Factura'   ' ' ' ' ' ' '10',
*------------------
    'NDJAR'      'TABLA' ' ' ' '  '27' ' ' ' ' 'Vida_Util_Años'   ' ' ' ' ' ' '10',
    'VUMES'      'TABLA' ' ' ' '  '28' ' ' ' ' 'Vida_Util_Meses'   ' ' ' ' ' ' '10',
    'VUCON'      'TABLA' ' ' ' '  '29' ' ' ' ' 'VU_Trans_Meses'   ' ' ' ' ' ' '10',
    'VURES'      'TABLA' ' ' ' '  '30' ' ' ' ' 'VU_Rest_Meses'   ' ' ' ' ' ' '10',
    'MONTO_ADQ'  'TABLA' ' ' ' '  '31' ' ' ' ' 'Valor_Adq'   ' ' ' ' ' ' '30',
    'SCHRW'      'TABLA' ' ' ' '  '32' ' ' ' ' 'Valor_Residual'   ' ' ' ' ' ' '30',
    'SCHRW_PROZ' 'TABLA' ' ' ' '  '33' ' ' ' ' 'Valor_Residual_%'   ' ' ' ' ' ' '30',
*------------------
    'VALOR_INI'         'TABLA' ' ' ' '  '34' ' ' ' ' 'VALOR_INICIAL_EJERC'   ' ' ' ' ' ' '30',
    'ALTAS'             'TABLA' ' ' ' '  '35' ' ' ' ' 'Altas'   ' ' ' ' ' ' '30',
    'BAJAS'             'TABLA' ' ' ' '  '36' ' ' ' ' 'Bajas'   ' ' ' ' ' ' '30',
    'TRASL'             'TABLA' ' ' ' '  '37' ' ' ' ' 'Traslados'   ' ' ' ' ' ' '30',
    'REAVI'             'TABLA' ' ' ' '  '38' ' ' ' ' 'Reavaluo_Inicio_Ejerc'   ' ' ' ' ' ' '30',
    'REAVP'             'TABLA' ' ' ' '  '39' ' ' ' ' 'Reavaluo_Acum_Ejerc'   ' ' ' ' ' ' '30',
****'CM_INIC_EJE'       'TABLA' ' ' ' '  'xx' ' ' ' ' 'CM_Inicio_Ejerc'   ' ' ' ' ' ' '30',
    'CM_ACUM_EJE'       'TABLA' ' ' ' '  '40' ' ' ' ' 'CM_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'CM_MES_EJE'        'TABLA' ' ' ' '  '41' ' ' ' ' 'CM_Mes_Ejerc'   ' ' ' ' ' ' '30',
    'BRUTO'             'TABLA' ' ' ' '  '42' ' ' ' ' 'MONTO_BRUTO'   ' ' ' ' ' ' '30',
    'DEP_INIC_EJE'      'TABLA' ' ' ' '  '43' ' ' ' ' 'Dep_Inicio_Ejerc'   ' ' ' ' ' ' '30',
    'DEP_ACUM_EJE'      'TABLA' ' ' ' '  '44' ' ' ' ' 'Dep_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'DEP_MES_EJE'       'TABLA' ' ' ' '  '45' ' ' ' ' 'Dep_Mes_Ejerc'   ' ' ' ' ' ' '30',
    'REV_AMOR_INIC_EJE' 'TABLA' ' ' ' '  '46' ' ' ' ' 'Rev_Amort_Inicio_Ejerc'   ' ' ' ' ' ' '30',
    'REV_AMOR_ACUM_EJE' 'TABLA' ' ' ' '  '47' ' ' ' ' 'Rev_Amort_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'REV_AMOR_MES_EJE'  'TABLA' ' ' ' '  '48' ' ' ' ' 'Rev_Amort_Mes_Ejerc'   ' ' ' ' ' ' '30',
    'DETEI'             'TABLA' ' ' ' '  '49' ' ' ' ' 'Deteriodo_Inicio_Ejerc'   ' ' ' ' ' ' '30',
    'DETEP'             'TABLA' ' ' ' '  '50' ' ' ' ' 'Deteriodo_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'NETO'              'TABLA' ' ' ' '  '51' ' ' ' ' 'MONTO_NETO'   ' ' ' ' ' ' '30',
*------------------
    'INVER'             'TABLA' ' ' ' '  '52' ' ' ' ' 'Fomento_Inversion'   ' ' ' ' ' ' '30'.


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
    'KTANSW'     'RESUMEN' ' ' ' '  '04' ' ' ' ' 'Cta_Contable'   ' ' ' ' ' ' '15',
    'ANLKL'      'RESUMEN' ' ' ' '  '05' ' ' ' ' 'Clase'   ' ' ' ' ' ' '5',
    'TXK50'      'RESUMEN' ' ' ' '  '06' ' ' ' ' 'Descripcion_Clase'   ' ' ' ' ' ' '20',
    'MONTO_ADQ'         'RESUMEN' ' ' ' '  '07' ' ' ' ' 'Valor_Adq'   ' ' ' ' ' ' '30',
    'SCHRW'             'RESUMEN' ' ' ' '  '08' ' ' ' ' 'Valor_Residual'   ' ' ' ' ' ' '30',
    'SCHRW_PROZ'        'RESUMEN' ' ' ' '  '09' ' ' ' ' 'Valor_Residual_%'   ' ' ' ' ' ' '30',
*------------------
    'VALOR_INI'         'RESUMEN' ' ' ' '  '10' ' ' ' ' 'VALOR_INICIAL_EJERC'   ' ' ' ' ' ' '30',
    'ALTAS'             'RESUMEN' ' ' ' '  '11' ' ' ' ' 'Altas'   ' ' ' ' ' ' '30',
    'BAJAS'             'RESUMEN' ' ' ' '  '12' ' ' ' ' 'Bajas'   ' ' ' ' ' ' '30',
    'TRASL'             'RESUMEN' ' ' ' '  '13' ' ' ' ' 'Traslados'   ' ' ' ' ' ' '30',
    'REAVI'             'RESUMEN' ' ' ' '  '14' ' ' ' ' 'Reavaluo_Inicio_Ejerc'   ' ' ' ' ' ' '30',
    'REAVP'             'RESUMEN' ' ' ' '  '15' ' ' ' ' 'Reavaluo_Acum_Ejerc'   ' ' ' ' ' ' '30',
****'CM_INIC_EJE'       'RESUMEN' ' ' ' '  'xx' ' ' ' ' 'CM_Inicio_Ejerc'   ' ' ' ' ' ' '30',
    'CM_ACUM_EJE'       'RESUMEN' ' ' ' '  '16' ' ' ' ' 'CM_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'CM_MES_EJE'        'RESUMEN' ' ' ' '  '17' ' ' ' ' 'CM_Mes_Ejerc'   ' ' ' ' ' ' '30',
    'BRUTO'             'RESUMEN' ' ' ' '  '18' ' ' ' ' 'MONTO_BRUTO'   ' ' ' ' ' ' '30',
    'DEP_INIC_EJE'      'RESUMEN' ' ' ' '  '19' ' ' ' ' 'Dep_Inicio_Ejerc'   ' ' ' ' ' ' '30',
    'DEP_ACUM_EJE'      'RESUMEN' ' ' ' '  '20' ' ' ' ' 'Dep_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'DEP_MES_EJE'       'RESUMEN' ' ' ' '  '21' ' ' ' ' 'Dep_Mes_Ejerc'   ' ' ' ' ' ' '30',
    'REV_AMOR_INIC_EJE' 'RESUMEN' ' ' ' '  '22' ' ' ' ' 'Rev_Amort_Inicio_Ejerc'   ' ' ' ' ' ' '30',
    'REV_AMOR_ACUM_EJE' 'RESUMEN' ' ' ' '  '23' ' ' ' ' 'Rev_Amort_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'REV_AMOR_MES_EJE'  'RESUMEN' ' ' ' '  '24' ' ' ' ' 'Rev_Amort_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'DETEI'             'RESUMEN' ' ' ' '  '25' ' ' ' ' 'Deteriodo_Inicio_Ejerc'   ' ' ' ' ' ' '30',
    'DETEP'             'RESUMEN' ' ' ' '  '26' ' ' ' ' 'Deteriodo_Acum_Ejerc'   ' ' ' ' ' ' '30',
    'NETO'              'RESUMEN' ' ' ' '  '27' ' ' ' ' 'MONTO_NETO'   ' ' ' ' ' ' '30',
*------------------
    'INVER'             'RESUMEN' ' ' ' '  '28' ' ' ' ' 'Fomento_Inversion'   ' ' ' ' ' ' '30'.



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

  IF x_field = 'MONTO_ADQ'         OR x_field = 'VALOR_INI' OR
     x_field = 'CM_INIC_EJE'       OR x_field = 'CM_ACUM_EJE'       OR x_field = 'CM_MES_EJE'       OR
     x_field = 'DEP_INIC_EJE'      OR x_field = 'DEP_ACUM_EJE'      OR x_field = 'DEP_MES_EJE'      OR
     x_field = 'REV_AMOR_INIC_EJE' OR x_field = 'REV_AMOR_ACUM_EJE' OR x_field = 'REV_AMOR_MES_EJE' OR
     x_field = 'REAVI'             OR x_field = 'REAVP'             OR
     x_field = 'DETEI'             OR x_field = 'DETEP'             OR
     x_field = 'BRUTO'             OR x_field = 'NETO'              OR
     x_field = 'ALTAS' OR x_field = 'BAJAS' OR
     x_field = 'TRASL' OR x_field = 'INVER' OR
     x_field = 'SCHRW' OR
     x_field = 'DMBTR'.
    fieldcat-currency      = 'CLP'.
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

  SELECT * FROM ankt  INTO TABLE it_ankt WHERE SPRAS = sy-langu.

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

  select single * from t001 where BUKRS = p_bukrs.
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
