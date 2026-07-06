*----------------------------------------------------------------------*
***INCLUDE ZFIMDP004 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REPORTE_
*&---------------------------------------------------------------------*
FORM reporte.

*PYV

  TABLES: lfa1.

  IF t_ok[] IS NOT INITIAL.
    LOOP AT t_ok.
      v_index = sy-tabix.
      IF NOT motemi IS INITIAL.
        IF t_ok-zmote <> motemi.
          DELETE t_ok INDEX v_index.
          CONTINUE.
        ENDIF.
      ENDIF.
      SELECT SINGLE jdatos lote INTO (t_ok-jdatos, t_ok-lote)
              FROM zjdatos_edocheq
              WHERE bukrs EQ bukrs AND
                    hbkid EQ hbkid AND
                    hktid EQ hktid AND
                    chect EQ t_ok-chect.

      IF NOT juegodatos IS INITIAL.
        IF t_ok-jdatos <> juegodatos.
          DELETE t_ok INDEX v_index.
          CONTINUE.
        ENDIF.
      ENDIF.

      MODIFY t_ok TRANSPORTING jdatos.

      SELECT SINGLE secuencia INTO t_ok-secuencia
        FROM zjdatos_secuen
        WHERE jdatos = t_ok-lote
          AND bukrs EQ bukrs AND
              hbkid EQ hbkid AND
              hktid EQ hktid AND
              chect EQ t_ok-chect.
      MODIFY t_ok  INDEX v_index.


      IF t_ok-zmote = 'SUBMATERNA'.
        CLEAR zcambiocheque-xblnr.
        SELECT SINGLE xblnr INTO zcambiocheque-xblnr
          FROM zcambiocheque
          WHERE zbukr = bukrs
            AND hbkid = hbkid
            AND hktid = hktid
            AND rzawe = 'C'
            AND chect = t_ok-chect.

        IF sy-subrc EQ 0.
          SELECT SINGLE belnr budat
            INTO (bkpf-belnr, bkpf-budat)
          FROM bkpf
          WHERE bukrs = bukrs
            AND gjahr = t_ok-gjahr
            AND xblnr = zcambiocheque-xblnr.

          IF sy-subrc EQ 0.
            t_ok-belnr = bkpf-belnr.
            t_ok-bldat = bkpf-budat.
            MODIFY t_ok  INDEX v_index.
          ENDIF.
        ENDIF.
      ENDIF.

* Cuando la opción sea Caducado electrónico, se dejan en semáforo en rojo los estados CHEQUE ANULADO
      IF t_ok-estado = 'CHEQUE ANULADO'.
        MOVE '@0A@' TO t_ok-status. " ICONO MAL
        MODIFY t_ok INDEX v_index.
      ENDIF.

* Se rescata el ID Acreedor y rut
      SELECT SINGLE * FROM payr
        WHERE zbukr EQ bukrs AND
              hbkid EQ hbkid AND
              hktid EQ hktid AND
              chect EQ t_ok-chect.

      IF sy-subrc EQ 0.
        SELECT SINGLE * FROM lfa1
        WHERE lifnr = payr-lifnr.

        IF sy-subrc EQ 0.
          t_ok-lifnr = lfa1-lifnr.
          t_ok-sortl = lfa1-sortl.
          MODIFY t_ok INDEX v_index.
        ENDIF.
      ENDIF.


      SELECT SINGLE * FROM payr
        WHERE zbukr = bukrs
          AND hbkid = hbkid
          AND hktid = hktid
          AND chect = t_ok-chect.

      IF sy-subrc EQ 0.
        SELECT SINGLE zz_agencia INTO t_ok-zagencia
          FROM bsak
          WHERE bukrs = bukrs
            AND lifnr = t_ok-lifnr
            AND augbl = payr-vblnr
            AND belnr <> t_ok-vblnr.

        IF sy-subrc  EQ 0.
          SELECT SINGLE zzdescr INTO t_ok-zzdescr
            FROM zagencia
            WHERE bukrs = bukrs
              AND zzcod_unidad = t_ok-zagencia.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = t_ok-zagencia
            IMPORTING
              output = t_ok-zagencia.

          MODIFY t_ok INDEX v_index.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDIF.

*Se realiza ejecucion directa para ejecucion en proceso de fondo
  PERFORM marcar_all.
  PERFORM gene_juego_datos.

ENDFORM.                    " REPORTE_

*&---------------------------------------------------------------------*
*&      Form  GENE_JUEGO_DATOS
*&---------------------------------------------------------------------*
FORM gene_juego_datos.

*PYV

  TABLES: bbkpf,      "Cab.documento para documento contable (estruct. bat
          bbseg,      "Segmento de documento contable (estruct. batch inpu
          bgr00,      "Estructura batch input para datos de juego de datos
          bselk,
          bselp,
          apqi.

  DATA: nombre_logico LIKE v_filenaci-fileintern VALUE
                         'Z_INTERFAZ_FI',
                         juego_datos(75),
                         arch_entrada(75),
                         nom_jd1(12),
                         fecha_jd LIKE sy-datum,
                         reg(44),
                         nuevo_docto(1),
                         seltab TYPE TABLE OF rsparams,
                         v_primera(1),
                         tipojuego(2),
                         v_hora TYPE t.

  errorfechacontab = ' '.
  g_exis =  'N'.
  CLEAR juego_datos.

  juego_datos = 'CE'.

  tipojuego = juego_datos+0(2).
  CONCATENATE juego_datos sy-datum+6(2) sy-datum+4(2) sy-datum+2(2) sy-uzeit(4) INTO lote.
  CONCATENATE juego_datos sy-datum+6(2) sy-datum+4(2) sy-uzeit(6) INTO juego_datos.
  group = juego_datos.
  v_primera = ' '.

  CLEAR aux.
  CLEAR: v_correlativo, nro_secuencia.

  REFRESH t_control.
  CLEAR: v_hora.
  v_hora = sy-timlo.

  LOOP AT t_ok WHERE box = 'X'.

      IF v_primera IS INITIAL.
        v_primera = 'X'.
      ELSE.
        CLEAR juego_datos.
* Se le suma un segundo a la hora con la finalidad de no repetir nombre en el juego de datos
        CALL FUNCTION 'DIMP_ADD_TIME'
          EXPORTING
            iv_starttime = v_hora
            iv_startdate = sy-datum
            iv_addtime   = '000001'
          IMPORTING
            ev_endtime   = v_hora.

        CONCATENATE tipojuego sy-datum+6(2) sy-datum+4(2) v_hora(6) INTO juego_datos.
        group = juego_datos.
      ENDIF.

      sw_bi = ''.

*      Inicializa las estructuras del batch-input con '/' (nodata)
      PERFORM inicializa_jd USING bbseg.
      PERFORM inicializa_jd USING bbkpf.
      PERFORM inicializa_jd USING bselk.
      PERFORM inicializa_jd USING bselp.

* Se genera la estructura de datos
      PERFORM crear_juego_datos USING juego_datos.

      IF g_exis EQ 'S' AND errorfechacontab IS INITIAL.
*      Se llama al programa estandar que genera el batch input.
        IF sw_bi = ''.
          SUBMIT rfbibl00 WITH ds_name  = juego_datos
                          WITH callmode = 'B'
                          WITH xinf = 'X'
                      AND RETURN.
        ENDIF.

        PERFORM parametros_jdatos.

* lanza el juego de datos.
        SUBMIT zrsbdcsub  WITH SELECTION-TABLE i_tablsubm EXPORTING LIST TO MEMORY AND RETURN.
        WAIT UP TO 1 SECONDS.
        PERFORM zreserva USING i_tablsubm.
      ENDIF.

      sw_bi = ''.

      CLEAR t_control.
      t_control-juego = juego_datos.
      t_control-chect = t_ok-chect.
      APPEND t_control.
      WAIT UP TO 1 SECONDS.

  ENDLOOP.

* Refresca grilla
  WAIT UP TO 3 SECONDS.
  CLEAR t_ok.
  REFRESH t_ok.
  PERFORM caduca_elec_indiv TABLES psel
                                   t_ok
                            USING bukrs hbkid hktid bkpf-budat.

  IF NOT t_ok[] IS INITIAL.

    LOOP AT t_ok.
      v_index = sy-tabix.
      SELECT SINGLE jdatos lote INTO (t_ok-jdatos, t_ok-lote)
        FROM zjdatos_edocheq
        WHERE bukrs EQ bukrs AND
              hbkid EQ hbkid AND
              hktid EQ hktid AND
              chect EQ t_ok-chect.
      MODIFY t_ok TRANSPORTING jdatos.

      SELECT SINGLE secuencia INTO t_ok-secuencia
        FROM zjdatos_secuen
        WHERE jdatos = t_ok-lote
          AND bukrs EQ bukrs AND
              hbkid EQ hbkid AND
              hktid EQ hktid AND
              chect EQ t_ok-chect.
      MODIFY t_ok INDEX v_index.

      READ TABLE t_control WITH KEY chect = t_ok-chect.
      IF sy-subrc EQ 0.
        SELECT SINGLE qstate INTO apqi-qstate
        FROM apqi
        WHERE groupid = t_control-juego.

        IF sy-subrc EQ 0.
          IF apqi-qstate = 'F'.
* Job finalizó exitosamente, por lo que se coloca con semáforo en ROJO
            t_ok-status = '@0A@'.
          ELSEIF apqi-qstate = 'E'.
* Semáforo continúa en VERDE
            t_ok-status = '@08@'.
          ELSE.
* Se revisa si el registro está en status P en tabla Zjdatos_edocheq
            SELECT SINGLE estado INTO zjdatos_edocheq-estado
              FROM zjdatos_edocheq
              WHERE bukrs = bukrs
                AND hbkid = hbkid
                AND hktid = hktid
                AND chect = t_control-chect.

            IF sy-subrc EQ 0.
              IF zjdatos_edocheq-estado = 'P'.
                t_ok-status = '@09@'.    " Amarillo
              ELSE.
                t_ok-status = '@0A@'.    " Rojo
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        MODIFY t_ok INDEX v_index.
      ENDIF.

      IF t_ok-estado = 'CHEQUE ANULADO'.
        MOVE '@0A@' TO t_ok-status. " ICONO MAL
        MODIFY t_ok INDEX v_index.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " GENE_JUEGO_DATOS

*&---------------------------------------------------------------------*
*&      Form  INICIALIZA_JD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TABLA      text
*----------------------------------------------------------------------*
FORM   inicializa_jd USING tabla.

*PYV

  DATA: l_acumu TYPE i.
  DO.
    ADD 1 TO l_acumu.
    ASSIGN COMPONENT l_acumu OF STRUCTURE tabla TO <f>.
    IF sy-subrc NE 0. EXIT. ENDIF.
    MOVE '/' TO <f>.
  ENDDO.

ENDFORM.                    "INICIALIZA_JD

*&---------------------------------------------------------------------*
*&      Form  CREAR_JUEGO_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM crear_juego_datos USING juego_datos.

*PYV

    OPEN DATASET juego_datos FOR OUTPUT IN TEXT MODE
                                 ENCODING DEFAULT.
    PERFORM crea_cabecera_jd USING juego_datos.

    CLEAR: v_primera.

    IF t_ok-status EQ '@08@' AND t_ok-box EQ 'X'.
      v_correlativo = v_correlativo + 1.
      nro_secuencia = nro_secuencia + 1.
      g_exis = 'S'.
      PERFORM crea_cabecera_bbkpf USING juego_datos.
      IF NOT v_errorfechareval IS INITIAL AND save_code = 'PRO_05'.
        MESSAGE 'Existen registros con fecha contable mayor a la fecha ingresada. Revisar.'
                                      TYPE 'E'.
        EXIT.
      ENDIF.
      IF NOT v_erroragencia IS INITIAL AND save_code = 'PRO_05'.
        MESSAGE 'Existen registros seleccionados SIN agencia, es OBLIGATORIO ingresar una. Revisar.'
                                      TYPE 'E'.
        EXIT.
      ENDIF.
      IF errorfechacontab IS INITIAL.
        PERFORM crea_cabecera_bbseg USING juego_datos.
        PERFORM crea_cabecera_bselk USING juego_datos.
        PERFORM crea_cabecera_bselp USING juego_datos.
        CLOSE DATASET juego_datos.
      ENDIF.
    ENDIF.

ENDFORM.                    "CREAR_JUEGO_DATOS

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_JD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM crea_cabecera_jd USING fichero.

*PYV

  MOVE: '0'            TO bgr00-stype,
        fichero        TO bgr00-group,
        sy-mandt       TO bgr00-mandt,
        sy-uname       TO bgr00-usnam,
        'X'            TO bgr00-xkeep,
        '/'            TO bgr00-nodata.
  TRANSFER bgr00 TO fichero.

ENDFORM.                               "F_BATCH_DOCU

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BBKPF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM crea_cabecera_bbkpf USING fichero.

*PYV

* Se levanta dynpro para ingreso de fecha de contabilización
  v_errorfechareval = ' '.
  v_erroragencia = ' '.

  CLEAR: bukrs_aux.

  DATA : p_bldat TYPE bldat.

  IF v_errorfechareval IS INITIAL AND v_erroragencia IS INITIAL.

    IF errorfechacontab IS INITIAL.

        bukrs_aux = t_ok-bukrs.

        MOVE: '1'                   TO bbkpf-stype,
*             'BBKPF'               TO BBKPF-TBNAM,
              'FB05'                TO bbkpf-tcode,    "Cod. transaccion
              'ZA'                  TO bbkpf-blart,    "Clase documento
               bukrs_aux            TO bbkpf-bukrs,    "Sociedad
               bkpf-budat+4(2)      TO bbkpf-monat,    "Mes contable
              'CLP'                 TO bbkpf-waers,    "Moneda
        'Cambio Estado Cheque'      TO bbkpf-bktxt.    "Texto Cab.Docto

        SELECT SINGLE  bldat INTO p_bldat
          FROM  bkpf
         WHERE  bukrs EQ t_ok-bukrs
           AND  belnr EQ t_ok-vblnr
           AND  gjahr EQ t_ok-gjahr.

        IF sy-subrc EQ 0.
          CONCATENATE p_bldat+6(2)
                      p_bldat+4(2)
                      p_bldat+0(4) INTO bbkpf-bldat.
        ELSE.
          CONCATENATE bkpf-budat+6(2)
                      bkpf-budat+4(2)
                      bkpf-budat+0(4) INTO bbkpf-bldat.
        ENDIF.

* Sólo para cuando sea anulación y días negativos, fecha de contabilización = fecha emisión

        CONCATENATE bkpf-budat+6(2)
                    bkpf-budat+4(2)
                    bkpf-budat+0(4) INTO bbkpf-budat.


        bbkpf-auglv = 'UMBUCHNG'.
        bbkpf-docid = '*'.
        MOVE '1'    TO bbkpf-kursf.
        CLEAR v_xblnr.
        CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+2(2) sy-uzeit(6) v_correlativo
                    INTO v_xblnr.
        bbkpf-xblnr = v_xblnr.

        TRANSFER bbkpf TO fichero.

        zjdatos_edocheq-bukrs  = bukrs.
        zjdatos_edocheq-hbkid  = hbkid.
        zjdatos_edocheq-hktid  = hktid.
        zjdatos_edocheq-chect  = t_ok-chect.
        zjdatos_edocheq-jdatos = group.
        zjdatos_edocheq-lote   = lote.
        zjdatos_edocheq-estado = 'P'.
        zjdatos_edocheq-fecha  = sy-datum.

        TRANSLATE t_ok-estado TO UPPER CASE.

        SELECT SINGLE codigo INTO zjdatos_edocheq-ultimo_estado
        FROM ztestadocheque
          WHERE glosa = t_ok-estado.
        zjdatos_edocheq-secuencia = nro_secuencia.
        MODIFY  zjdatos_edocheq.

        CLEAR wa_secuen.
        wa_secuen-bukrs  = bukrs.
        wa_secuen-hbkid  = hbkid.
        wa_secuen-hktid  = hktid.
        wa_secuen-chect  = t_ok-chect.
        wa_secuen-jdatos = lote.
        wa_secuen-secuencia = nro_secuencia.
        INSERT zjdatos_secuen FROM wa_secuen.

        PERFORM inicializa_jd USING bbkpf.

    ENDIF.

  ENDIF.

ENDFORM.                               "F_CREA_CABECERA_BBKPF
*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BBSEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM crea_cabecera_bbseg USING fichero.

*PYV

  TABLES: bseg.

  DATA :  g_wrbtr(10),
          g_wrbtri TYPE p DECIMALS 0.
  g_wrbtr = t_ok-wrbtr.

  REPLACE '.'  WITH ' ' INTO g_wrbtr.
  CONDENSE g_wrbtr NO-GAPS.
  g_wrbtri =  g_wrbtr.

  MOVE: '2'                   TO bbseg-stype,
        'BBSEG'               TO bbseg-tbnam.

  IF t_rpt = 'C'.
    MOVE g_newbs              TO bbseg-newbs.    "Clave contabil.
    MOVE: t_ok-hkontd         TO bbseg-newko.    "Cuenta
  ENDIF.

  IF t_rpt = 'A'.
    MOVE g_newbs              TO bbseg-newbs.    "Clave contabil.
    IF g_newbs EQ '31' AND save_code NE 'PRO_06'.
      MOVE 'A'                 TO bbseg-zlspr.    "ANULACION DE DOCUMENTO
    ENDIF.
    MOVE: t_ok-lifnr          TO bbseg-newko.    "Cuenta
  ENDIF.

  MOVE: g_wrbtri              TO bbseg-wrbtr,    "Importe mon doc
      t_ok-sgtxt              TO bbseg-sgtxt.

  IF t_ok-chect IS NOT INITIAL.
    MOVE t_ok-chect           TO bbseg-zuonr.    "ASIGNACION
  ENDIF.

  MOVE  t_ok-zmote            TO bbseg-zzmot_emis.

  IF t_rpt = 'C'.

      CONCATENATE bkpf-budat+6(2)
                  bkpf-budat+4(2)
                  bkpf-budat+0(4) INTO bbseg-valut.

  ENDIF.

  TRANSFER bbseg TO fichero.
  PERFORM inicializa_jd USING bbseg.

ENDFORM.                    "CREA_CABECERA_BBSEG
*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BSELK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JUEGO_DATOS  text
*----------------------------------------------------------------------*
FORM crea_cabecera_bselk  USING    juego_datos.

*PYV

  MOVE: '2'                   TO bselk-stype,
        'BSELK'               TO bselk-tbnam.

  bselk-agkon  = t_ok-hkont.
  bselk-agbuk  = t_ok-bukrs.
  bselk-agkoa  = 'S'.
  bselk-xnops  = 'X'.
  TRANSFER bselk TO juego_datos.
  PERFORM inicializa_jd USING bselk.

ENDFORM.                    " CREA_CABECERA_BSELK
*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BSELP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JUEGO_DATOS  text
*----------------------------------------------------------------------*
FORM crea_cabecera_bselp  USING    juego_datos.

*PYV

  MOVE: '2'                 TO bselp-stype,
      'BSELP'               TO bselp-tbnam.

  bselp-feldn_1 = 'BELNR'.
  CONCATENATE t_ok-belnr t_ok-gjahr t_ok-buzei INTO bselp-slvon_1.
  TRANSFER bselp TO juego_datos.
  PERFORM inicializa_jd USING bselp.

ENDFORM.                    " CREA_CABECERA_BSELP

*&---------------------------------------------------------------------*
*&      Form  VALID_CTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->G_CTA       CUENTA
*      -->G_PROCESO   PROCESO QUE SE VALIDA
*
*      -->G_VALID_CTA RESULTADO DE VALIDACION  0 = BIEN  1 = MAL
*----------------------------------------------------------------------*
FORM valid_cta  USING    g_cta g_proceso
                CHANGING g_valid_cta.

* PYV

      g_valid_cta = 0.

      IF g_cta EQ 0.
        g_valid_cta = 1.
      ENDIF.

      IF g_cta EQ 1.
        g_valid_cta = 1.
      ENDIF.

      IF g_cta EQ 3.
        g_valid_cta = 1.
      ENDIF.

      IF g_cta EQ 4.
        g_valid_cta = 1.
      ENDIF.

      IF g_cta EQ 5.
        g_valid_cta = 1.
      ENDIF.

      IF g_cta EQ 6.
        g_valid_cta = 1.
      ENDIF.

      IF g_cta EQ 7.
        g_valid_cta = 1.
      ENDIF.

      IF g_cta EQ 8.
        g_valid_cta = 1.
      ENDIF.

ENDFORM.                    " VALID_CTA

*&---------------------------------------------------------------------*
*&      Form  MARCAR_ALL
*&---------------------------------------------------------------------*
FORM marcar_all.

*PYV

  IF t_ok[] IS NOT INITIAL.

    LOOP AT t_ok.
      IF t_ok-status EQ '@08@'.
        t_ok-box = 'X'.
        MODIFY t_ok INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " MARCAR_ALL
