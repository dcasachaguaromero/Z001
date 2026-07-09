*----------------------------------------------------------------------*
***INCLUDE ZFIMDP004 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REPORTE_
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reporte.
  TABLES: lfa1.
** INICIO L_FOUBERT  Perform consultas
*  PERFORM  CONSULTAS.
** FIN L_FOUBERT
  DATA: p_motemis TYPE zzmot_emis. " motivo de emision para maternales
* chidalgo - Quintec 27.05.2010
* Agregar columna de juego de datos

  IF t_ok[] IS NOT INITIAL.
    LOOP AT t_ok.
      v_index = sy-tabix.
      IF NOT motemi IS INITIAL.
        IF t_ok-zmote <> motemi.
          DELETE t_ok INDEX v_index.
          CONTINUE.
        ENDIF.
      ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE jdatos lote INTO (t_ok-jdatos, t_ok-lote)
*              FROM zjdatos_edocheq
*              WHERE bukrs EQ bukrs AND
*                    hbkid EQ hbkid AND
*                    hktid EQ hktid AND
*                    chect EQ t_ok-chect.
*
* NEW CODE
      SELECT jdatos lote
      UP TO 1 ROWS  INTO (t_ok-jdatos, t_ok-lote)
              FROM zjdatos_edocheq
              WHERE bukrs EQ bukrs AND
                    hbkid EQ hbkid AND
                    hktid EQ hktid AND
                    chect EQ t_ok-chect ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
** INICIO L_FOUBERT zjdatos_edocheq
*      CLEAR: gw_jdatos.
*        READ TABLE gt_jdatos INTO gw_jdatos WITH KEY  bukrs = bukrs
*                                                     hbkid = hbkid
*                                                     hktid = hktid
*                                                     chect = t_ok-chect.
*        t_ok-jdatos = gw_jdatos-jdatos.
*        t_ok-lote   = gw_jdatos-lote.
** FIN L_FOUBERT
      IF NOT juegodatos IS INITIAL.
        IF t_ok-jdatos <> juegodatos.
          DELETE t_ok INDEX v_index.
          CONTINUE.
        ENDIF.
      ENDIF.

      MODIFY t_ok TRANSPORTING jdatos.

* FCV - 07.08.2010 - Incorporar secuencia del Juego de Datos
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE secuencia INTO t_ok-secuencia
*        FROM zjdatos_secuen
** FCV - 05.09.2010 - Lotes
**        WHERE jdatos = t_ok-jdatos
*        WHERE jdatos = t_ok-lote
** fin FCV - 05.09.2010 - Lotes
*          AND bukrs EQ bukrs AND
*              hbkid EQ hbkid AND
*              hktid EQ hktid AND
*              chect EQ t_ok-chect.
*
* NEW CODE
      SELECT secuencia
      UP TO 1 ROWS  INTO t_ok-secuencia
        FROM zjdatos_secuen
* FCV - 05.09.2010 - Lotes
*        WHERE jdatos = t_ok-jdatos
        WHERE jdatos = t_ok-lote
* fin FCV - 05.09.2010 - Lotes
          AND bukrs EQ bukrs AND
              hbkid EQ hbkid AND
              hktid EQ hktid AND
              chect EQ t_ok-chect ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*              CLEAR: gw_secuen.
** INICIO L_FOUBERT zjdatos_secuen
*      CLEAR: gw_secuen.
*        READ TABLE  gt_secuen INTO gw_secuen WITH KEY jdatos = t_ok-lote
*                                                      bukrs  = bukrs
*                                                      hbkid  = hbkid
*                                                      hktid  = hktid
*                                                      chect  = t_ok-chect.
*      t_ok-secuencia = gw_secuen-secuencia.
** FIN L_FOUBERT zjdatos_secuen
      MODIFY t_ok  INDEX v_index.
* fin FCV - 07.08.2010 - Incorporar secuencia del Juego de Datos

* FCV - 21.06.2010 - Se descarta el status NUEVO CHEQUE REVALIDADO
      IF save_code = 'PRO_03'.
        IF t_ok-estado = 'NUEVO CHEQUE REVALIDADO'.
          MOVE '@0A@' TO t_ok-status. " ICONO MAL
          MODIFY t_ok INDEX v_index.
        ENDIF.

* HCD 04042012
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE zzmot_emis
*        INTO  p_motemis
*        FROM  ztipchequemat
*        WHERE bukrs      EQ t_ok-bukrs
*        AND   zzmot_emis EQ t_ok-zmote.
*
* NEW CODE
        SELECT zzmot_emis
        UP TO 1 ROWS 
        INTO  p_motemis
        FROM  ztipchequemat
        WHERE bukrs      EQ t_ok-bukrs
        AND   zzmot_emis EQ t_ok-zmote ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* FIN HCD 04042012

* HCD 04042012   cambio condicion de IF si   sy-subrc  = 0 encontro dato en tabla en caso contrario no
*        IF t_ok-zmote = 'SUBMATERNA'.
        IF sy-subrc = 0.
          IF t_ok-estado <> 'CHEQUE GIRADO'.
            MOVE '@0A@' TO t_ok-status. " ICONO MAL
            MODIFY t_ok INDEX v_index.
          ENDIF.
        ENDIF.
      ENDIF.
* fin FCV - 21.06.2010

*********************************************************************
* FCV - 12.08.2010 - Se obtiene último N° de documento generado en proceso de Cambio de cheque
* para motivo SUBMATERNA
*********************************************************************
* HCD 04042012
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE zzmot_emis
*      INTO  p_motemis
*      FROM  ztipchequemat
*      WHERE bukrs      EQ t_ok-bukrs
*      AND   zzmot_emis EQ t_ok-zmote.
*
* NEW CODE
      SELECT zzmot_emis
      UP TO 1 ROWS 
      INTO  p_motemis
      FROM  ztipchequemat
      WHERE bukrs      EQ t_ok-bukrs
      AND   zzmot_emis EQ t_ok-zmote ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* FIN HCD 04042012
* HCD 04042012   cambio condicion de IF si   sy-subrc  = 0 encontro dato en tabla en caso contrario no
*      IF t_ok-zmote = 'SUBMATERNA'.cambio por consulta dinamica
      IF sy-subrc = 0.
        CLEAR zcambiocheque-xblnr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE xblnr INTO zcambiocheque-xblnr
*          FROM zcambiocheque
*          WHERE zbukr = bukrs
*            AND hbkid = hbkid
*            AND hktid = hktid
*            AND rzawe = 'C'
*            AND chect = t_ok-chect.
*
* NEW CODE
        SELECT xblnr
        UP TO 1 ROWS  INTO zcambiocheque-xblnr
          FROM zcambiocheque
          WHERE zbukr = bukrs
            AND hbkid = hbkid
            AND hktid = hktid
            AND rzawe = 'C'
            AND chect = t_ok-chect ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE belnr budat
*            INTO (bkpf-belnr, bkpf-budat)
*          FROM bkpf
*          WHERE bukrs = bukrs
*            AND gjahr = t_ok-gjahr
*            AND xblnr = zcambiocheque-xblnr.
*
* NEW CODE
          SELECT belnr budat
          UP TO 1 ROWS 
            INTO (bkpf-belnr, bkpf-budat)
          FROM bkpf
          WHERE bukrs = bukrs
            AND gjahr = t_ok-gjahr
            AND xblnr = zcambiocheque-xblnr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          IF sy-subrc EQ 0.
            t_ok-belnr = bkpf-belnr.
            t_ok-bldat = bkpf-budat.
            MODIFY t_ok  INDEX v_index.
          ENDIF.
        ENDIF.
      ENDIF.
*********************************************************************
* fin FCV - 12.08.2010
*********************************************************************



* FCV - 21.06.2010 - Se descarta status para "Cambio de Cheque"
      IF save_code = 'PRO_06'.
        IF t_ok-estado CS 'CADUCADO ELECTR' OR
           t_ok-estado CS 'CADUCADO F'.
* HCD 04042012
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE zzmot_emis
*          INTO  p_motemis
*          FROM  ztipchequemat
*          WHERE bukrs      EQ t_ok-bukrs
*          AND   zzmot_emis EQ t_ok-zmote.
*
* NEW CODE
          SELECT zzmot_emis
          UP TO 1 ROWS 
          INTO  p_motemis
          FROM  ztipchequemat
          WHERE bukrs      EQ t_ok-bukrs
          AND   zzmot_emis EQ t_ok-zmote ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* FIN HCD 04042012
* HCD 04042012   cambio condicion de IF si   sy-subrc  = 0 encontro dato en tabla en caso contrario no
*          IF t_ok-zmote = 'SUBMATERNA'. cambio por consulta dinamica
          IF sy-subrc = 0.
            MOVE '@08@' TO t_ok-status. " ICONO BIEN
* FCV - 01.07.2010
* Se determina el documento asociado
*            SELECT SINGLE belnr INTO t_ok-belnr
*              FROM bseg
*              WHERE bukrs = t_ok-bukrs
*                AND gjahr = t_ok-gjahr
*                AND zuonr = t_ok-chect
*                AND hkont = '2011730013'.
* fin FCV - 01.07.2010
            MODIFY t_ok INDEX v_index.
          ELSE.
            MOVE '@0A@' TO t_ok-status. " ICONO MAL
            MODIFY t_ok INDEX v_index.
          ENDIF.
        ELSE.
          MOVE '@0A@' TO t_ok-status. " ICONO MAL
          MODIFY t_ok INDEX v_index.
        ENDIF.
      ENDIF.
* fin FCV - 21.06.2010

* FCV - 20.07.2010
* Cuando la opción sea Caducado electrónico, se dejan en semáforo en rojo los estados CHEQUE ANULADO
      IF save_code = 'PRO_01' AND t_ok-estado = 'CHEQUE ANULADO'.
        MOVE '@0A@' TO t_ok-status. " ICONO MAL
        MODIFY t_ok INDEX v_index.
      ENDIF.

* Se rescata el ID Acreedor y rut
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM payr
*        WHERE zbukr EQ bukrs AND
*              hbkid EQ hbkid AND
*              hktid EQ hktid AND
*              chect EQ t_ok-chect.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM payr
        WHERE zbukr EQ bukrs AND
              hbkid EQ hbkid AND
              hktid EQ hktid AND
              chect EQ t_ok-chect ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
** INICIO L_FOUBERT PAYR 1
*       SELECT SINGLE zbukr  hbkid hktid chect lifnr vblnr
*          FROM payr
*          INTO PAYR
*        WHERE zbukr EQ bukrs AND
*              hbkid EQ hbkid AND
*              hktid EQ hktid AND
*              chect EQ t_ok-chect.
** FIN L_FOUBERT PAYR 1
      IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM lfa1
*        WHERE lifnr = payr-lifnr.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM lfa1
        WHERE lifnr = payr-lifnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc EQ 0.
          t_ok-lifnr = lfa1-lifnr.
          t_ok-sortl = lfa1-sortl.
          MODIFY t_ok INDEX v_index.
        ENDIF.
      ENDIF.
* fin FCV - 20.07.2010

* FCV - 29.07.2010
* Se rescata la agencia para todos los status de los cheques
*      IF save_code EQ 'PRO_05'.      "Revalidación

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM payr
*        WHERE zbukr = bukrs
*          AND hbkid = hbkid
*          AND hktid = hktid
*          AND chect = t_ok-chect.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM payr
        WHERE zbukr = bukrs
          AND hbkid = hbkid
          AND hktid = hktid
          AND chect = t_ok-chect ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
** INICIO L_FOUBERT PAYR2
*SELECT SINGLE zbukr  hbkid hktid chect lifnr vblnr
*          FROM payr
*          INTO PAYR
*          WHERE zbukr = bukrs
*          AND hbkid = hbkid
*          AND hktid = hktid
*          AND chect = t_ok-chect.
** FIN L_FOUBERT PAYR2
      IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE zz_agencia INTO t_ok-zagencia
*          FROM bsak
*          WHERE bukrs = bukrs
*            AND lifnr = t_ok-lifnr
*            AND augbl = payr-vblnr
*            AND belnr <> t_ok-vblnr.
*
* NEW CODE
        SELECT zz_agencia
        UP TO 1 ROWS  INTO t_ok-zagencia
          FROM bsak
          WHERE bukrs = bukrs
            AND lifnr = t_ok-lifnr
            AND augbl = payr-vblnr
            AND belnr <> t_ok-vblnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc  EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE zzdescr INTO t_ok-zzdescr
*            FROM zagencia
*            WHERE bukrs = bukrs
*              AND zzcod_unidad = t_ok-zagencia.
*
* NEW CODE
          SELECT zzdescr
          UP TO 1 ROWS  INTO t_ok-zzdescr
            FROM zagencia
            WHERE bukrs = bukrs
              AND zzcod_unidad = t_ok-zagencia ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* FCV - 01.08.2010
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = t_ok-zagencia
            IMPORTING
              output = t_ok-zagencia.
* fin FCV - 01.08.2010
          MODIFY t_ok INDEX v_index.
        ENDIF.
      ENDIF.
*      ENDIF.
* fin FCV - 29.07.2010

* FCV - 15.08.2010 - Para el caso de la Revalidación, no se pueden revalidar Caducados electrónicos
      IF save_code = 'PRO_05'.
        IF t_ok-estado CS 'CADUCADO ELECTR' AND t_ok-status = '@08@'.
          MOVE '@0A@' TO t_ok-status. " ICONO MAL
          MODIFY t_ok INDEX v_index.
        ENDIF.
      ENDIF.
* fin FCV - 15.08.2010

    ENDLOOP.
  ENDIF.

* Fin modificación

  REFRESH: gt_fieldcat.
  CLEAR: gt_events, gt_list_top_of_page, ls_toolbar.
  PERFORM build.
*  PERFORM BUILD2.
  PERFORM eventtab_build CHANGING gt_events.
  PERFORM layout_init USING gs_layout.
  PERFORM comment_build  CHANGING gt_list_top_of_page.
  PERFORM call_alv.
ENDFORM.                    " REPORTE_


*&---------------------------------------------------------------------*
*&      Form  BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build.
* DATA FIELD CATALOG
* Explain Field Description to ALV
  DATA: fieldcat_in TYPE slis_fieldcat_alv.

* FCV - 22.04.2010
* Se omite checkbox, ya que la ALV trae el manejo del registro
* en forma automática
*  CLEAR: fieldcat_ln.
*  fieldcat_ln-fieldname = 'CHEK1'.
**  FIELDCAT_LN-KEY       = 'X'.   "SUBTOTAL KEY
*  fieldcat_ln-checkbox    = 'X'.
*  fieldcat_ln-edit    = 'X'.
*  fieldcat_ln-seltext_l = 'Selección'.
*  fieldcat_ln-hotspot = ' '.
*  fieldcat_ln-fix_column = 'X'.
*  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_in.
  fieldcat_ln-fieldname = 'BUKRS'.
  fieldcat_ln-key       = ' '.   "SUBTOTAL KEY
  fieldcat_ln-checkbox   = ' '.
  fieldcat_ln-edit    = ' '.
  fieldcat_ln-seltext_l = 'Sociedad FI'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-fix_column = 'X'.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname = 'VBLNR'.
  fieldcat_ln-key       = ' '.   "SUBTOTAL KEY
  fieldcat_ln-checkbox   = ' '.
  fieldcat_ln-edit    = ' '.
  fieldcat_ln-seltext_l = 'Numero de Doc Orig.'.
  fieldcat_ln-hotspot = 'X'.
  fieldcat_ln-fix_column = ' '.
  fieldcat_ln-just = 'R'.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname = 'ZALDT'.
  fieldcat_ln-key       = ' '.   "SUBTOTAL KEY
  fieldcat_ln-checkbox   = ' '.
  fieldcat_ln-edit    = ' '.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-seltext_l = 'Fecha Doc. Orig'.
  fieldcat_ln-just = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

* FCV - 20.07.2010
  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname  = 'LIFNR'.
  fieldcat_ln-seltext_l = 'ID Acreedor'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-sp_group = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.
* fin FCV - 20.07.2010

  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname = 'ZNME1'.
  fieldcat_ln-key       = ' '.   "SUBTOTAL KEY
  fieldcat_ln-checkbox   = ' '.
  fieldcat_ln-edit    = ' '.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-seltext_l = 'Acreedor'.
  APPEND fieldcat_ln TO gt_fieldcat.

* FCV - 20.07.2010
  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname  = 'SORTL'.
  fieldcat_ln-seltext_l = 'Rut'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-sp_group = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.
* fin FCV - 20.07.2010

  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname = 'BELNR'.
  fieldcat_ln-key       = ' '.   "SUBTOTAL KEY
  fieldcat_ln-checkbox   = ' '.
  fieldcat_ln-edit    = ' '.
  fieldcat_ln-seltext_l = 'Numero de Doc.'.
  fieldcat_ln-hotspot = 'X'.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname = 'BLDAT'.
  fieldcat_ln-seltext_l = 'Fecha Contab.'.
  fieldcat_ln-hotspot = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

*  CLEAR: fieldcat_ln.
*  fieldcat_ln-fieldname = 'BUZEI'.
*  fieldcat_ln-seltext_l = 'Posición'.
*  fieldcat_ln-hotspot = ' '.
*  APPEND fieldcat_ln TO gt_fieldcat.

* FCV - 26.07.2010
  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname = 'NRO'.
  fieldcat_ln-seltext_l = 'Secuencia entrada'.
  fieldcat_ln-hotspot = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.
* fin FCV - 26.07.2010

  CLEAR: fieldcat_ln.
* FCV - 21.04.2010
  fieldcat_ln-ref_tabname = 'PAYR'.
  fieldcat_ln-ref_fieldname = 'CHECT'.
  fieldcat_ln-outputlen = '17'.
* fin FCV - 21.04.2010
  fieldcat_ln-fieldname = 'CHECT'.
  fieldcat_ln-seltext_l = 'Numero de Cheque'.
  fieldcat_ln-hotspot = 'X'.
  fieldcat_ln-do_sum  = ' '.
  fieldcat_ln-just = 'R'.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname = 'WRBTR'.
  fieldcat_ln-currency  = 'CLP'.
  fieldcat_ln-seltext_l = 'Monto Cheque'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-do_sum  = 'X'.
* FCV - 21.04.2010
*  fieldcat_ln-just = ' '.
  fieldcat_ln-just = 'R'.
*  fieldcat_ln-ref_tabname = 'BSEG'.
*  fieldcat_ln-ref_fieldname = 'WRBTR'.
* fin FCV - 21.04.2010
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_ln.
  fieldcat_ln-currency  = '   '.
  fieldcat_ln-fieldname = 'ZMOTE'.
  fieldcat_ln-seltext_l = 'Motivo Emisión'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-do_sum  = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

* FCV - 29.07.2010
  CLEAR: fieldcat_ln.
  fieldcat_ln-currency  = '   '.
  fieldcat_ln-fieldname = 'ZAGENCIA'.
  fieldcat_ln-seltext_l = 'N° Agencia'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-do_sum  = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_ln.
  fieldcat_ln-currency  = '   '.
  fieldcat_ln-fieldname = 'ZZDESCR'.
  fieldcat_ln-seltext_l = 'Nombre Agencia'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-do_sum  = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.
* fin FCV - 29.07.2010

  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname = 'DATEV'.
  fieldcat_ln-currency  = '  '.
  fieldcat_ln-seltext_l = 'Cant. Dias'.
  fieldcat_ln-hotspot = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname  = 'STATUS'.
  fieldcat_ln-seltext_l = 'STATUS'.
  fieldcat_ln-icon      = 'X'.
  fieldcat_ln-hotspot = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname  = 'ESTADO'.
  fieldcat_ln-seltext_l = 'Estado'.
*  fieldcat_ln-icon      = 'X'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-sp_group = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname  = 'JDATOS'.
  fieldcat_ln-seltext_l = 'Juego Datos'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-sp_group = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.

* FCV - 26.08.2010 - Lote
  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname  = 'LOTE'.
  fieldcat_ln-seltext_l = 'Lote Asignado'.
  fieldcat_ln-hotspot = ' '.
  fieldcat_ln-sp_group = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.
* fin FCV - 26.08.2010

* FCV - 07.08.2010 - Secuencia del juego de datos
  CLEAR: fieldcat_ln.
  fieldcat_ln-fieldname = 'SECUENCIA'.
  fieldcat_ln-seltext_l = 'Secuencia Lote'.
  fieldcat_ln-hotspot = ' '.
  APPEND fieldcat_ln TO gt_fieldcat.
* fin FCV - 07.08.2010

* DATA SORTING AND SUBTOTAL
  DATA: gs_sort TYPE slis_sortinfo_alv.
ENDFORM.                    "BUILD
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.
  rs_layout-group_change_edit = 'X'.
  rs_layout-detail_popup      = 'X'.
  rs_layout-info_fieldname    = 'X'.
*  rs_layout-colwidth_optimize = 'X'.
  rs_layout-zebra             = 'X'.
* FCV - 22.04.2010
  rs_layout-box_fieldname = 'BOX'.
* fin FCV - 22.04.2010
ENDFORM.                    "LAYOUT_INIT

*&---------------------------------------------------------------------*
*&      Form  CALL_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_alv.
* FCV - 26.07.2010
  DATA: BEGIN OF t_orden OCCURS 0,
           chect LIKE payr-chect,
           nro(6) TYPE n,
        END OF t_orden.
  DATA: v_nro(6) TYPE n,
        v_indice LIKE sy-tabix,
        v_orden(1).

  CLEAR: v_nro, v_orden.
  LOOP AT psel WHERE option = 'EQ'.
    v_nro = v_nro + 1.
    t_orden-chect = psel-low.
    t_orden-nro = v_nro.
    APPEND t_orden.
    v_orden = 'X'.
  ENDLOOP.

  LOOP AT t_orden.
    LOOP AT t_ok WHERE chect = t_orden-chect.
      v_indice = sy-tabix.
      t_ok-nro = t_orden-nro.
      MODIFY t_ok INDEX v_indice.
    ENDLOOP.
  ENDLOOP.
* fin FCV - 26.07.2010

  g_repid = sy-repid.

  PERFORM cant_registros.

* FCV - 12.05.2010
* Muestra sólo registros con semáforo en verde
  REFRESH itfilter.
  CLEAR itfilter.
  itfilter-tabname = 'T_OK'.
  itfilter-fieldname = 'STATUS'.
  itfilter-sign0     = 'I'.
  itfilter-optio     = 'EQ'.
  itfilter-valuf_int = '@08@'.
  itfilter-valut_int = '@08@'.
  APPEND itfilter.
* fin FCV - 12.05.2010

  IF v_orden = 'X'.
    SORT t_ok BY nro.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
      i_callback_pf_status_set = 'ZFULLSCREEN'
      i_callback_user_command  = 'USER_COMMAND_DET'
      i_background_id          = 'LOGOISAPBAN002'
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat[]
      it_events                = gt_events
      it_filter                = itfilter[]
    TABLES
      t_outtab                 = t_ok
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.

  ENDIF.

* FCV - 06.09.2010
  IF sy-ucomm = '&F03' OR
     sy-ucomm = '&F15' OR
     sy-ucomm = '&F12'.
    CLEAR v_comienzo.
    bkpf-budat = '00000000'.
  ENDIF.
* fin FCV - 06.09.2010
ENDFORM.                    "CALL_ALV

*&---------------------------------------------------------------------*
*&      Form  f008_set_pf_status
*&---------------------------------------------------------------------*
*       Customized PF status to include the icon for creating SES
*----------------------------------------------------------------------*
FORM zfullscreen USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZFULLSCREEN'.
ENDFORM.                    "f008_set_pf_status


* HEADER FORM
FORM eventtab_build CHANGING lt_events TYPE slis_t_event.
  CONSTANTS:
  gc_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE'.
  DATA: ls_event TYPE slis_alv_event.

  ls_event-name = slis_ev_user_command.
  ls_event-form = 'USER_COMMAND_DET'.
  APPEND ls_event TO gt_events.

  ls_event-name = slis_ev_pf_status_set.
  ls_event-form = 'ZFULLSCREEN'.
  APPEND ls_event TO gt_events.


  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = lt_events.
  READ TABLE lt_events WITH KEY name =  slis_ev_top_of_page   INTO ls_event.
  IF sy-subrc = 0.
    MOVE gc_formname_top_of_page TO ls_event-form.
    APPEND ls_event TO lt_events.
  ENDIF.
ENDFORM.                    "EVENTTAB_BUILD


*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->GT_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
FORM comment_build CHANGING gt_top_of_page TYPE slis_t_listheader.
  DATA: gs_line TYPE slis_listheader.
  CLEAR gs_line.
  gs_line-typ  = 'H'.
  CASE save_code.
    WHEN 'PRO_01'.
      IF t_radio_02 EQ 'X'.
        gs_line-info = 'Caducar Electrónico Individual'.
      ELSE.
        gs_line-info = 'Caducar Electrónico Masivo'.
      ENDIF.
    WHEN 'PRO_02'.
      IF t_radio_02 EQ 'X'.
        gs_line-info = 'Caducar Físico Individual'.
      ENDIF.
    WHEN 'PRO_03'.
      IF t_radio_02 EQ 'X'.
        gs_line-info = 'Anulación de Documento'.
      ENDIF.
    WHEN 'PRO_04'.
      IF t_radio_02 EQ 'X'.
        gs_line-info = 'Prescripción Cheques'.
      ENDIF.
    WHEN 'PRO_05'.
      IF t_radio_02 EQ 'X'.
        gs_line-info = 'Revalidar Cheques'.
      ENDIF.
    WHEN 'PRO_06'.
      IF t_radio_02 EQ 'X'.
        gs_line-info = 'Cambio Cheque'.
      ENDIF.
    WHEN 'PRO_08'.
      IF t_radio_02 EQ 'X'.
        gs_line-info = 'Reverso de Cheques'.
      ENDIF.
  ENDCASE.
  APPEND gs_line TO gt_top_of_page.

  CLEAR gs_line.
  gs_line-typ  = 'S'.
  gs_line-key  = 'Sociedad'.
  gs_line-info = bukrs.
  APPEND gs_line TO gt_top_of_page.

  gs_line-key  = 'Banco'.
  gs_line-info = hbkid.
  APPEND gs_line TO gt_top_of_page.

  gs_line-key  = 'ID Cuenta'.
  gs_line-info = hktid.
  APPEND gs_line TO gt_top_of_page.

  gs_line-typ  = 'S'.
  gs_line-key  = 'Fecha de Ejecución'.
* FCV - 01.09.2010
*  IF save_code = 'PRO_06'.
  CLEAR p_budat.
  GET PARAMETER ID 'FC' FIELD p_budat.
  WRITE: p_budat TO gs_line-info.
*  ELSE.
*    WRITE: bkpf-budat TO gs_line-info.
*  ENDIF.
* fin FCV - 01.09.2010
  APPEND gs_line TO gt_top_of_page.

  gs_line-key  = 'Usuario'.
  gs_line-info = sy-uname.
  APPEND gs_line TO gt_top_of_page.

ENDFORM.                    "COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_list_top_of_page.
  WRITE: sy-datum, 'Page No', sy-pagno LEFT-JUSTIFIED.
ENDFORM.                    "TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  END_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM end_of_page.
  WRITE AT (sy-linsz) sy-pagno CENTERED.
ENDFORM.                    "END_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_DET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->F_UCOMM    text
*      -->I_SELFIELD text
*----------------------------------------------------------------------*
FORM user_command_det USING f_ucomm LIKE sy-ucomm
    i_selfield TYPE slis_selfield.

  i_selfield-refresh = 'X'.

  DATA: ann TYPE payr-gjahr.
  DATA: an1 TYPE payr-vblnr.
  DATA: fec(4) TYPE c.

  DATA: save_code TYPE sy-ucomm.
  DATA: g_concep   TYPE slis_fieldname.
  DATA: rs_selfield TYPE slis_selfield.
  rs_selfield-refresh = 'X'.

  save_code = sy-ucomm.
  CASE save_code.
    WHEN '&DATA_SAVE'.

      IF t_rpt EQ 'C'.
        PERFORM gene_juego_datos.
      ENDIF.

      IF t_rpt EQ 'A'. " Anulacion.
* Se asigna la fecha de contabilización asignada en la pantalla principal
        CLEAR p_budat.
        GET PARAMETER ID 'FC' FIELD p_budat.
        PERFORM gene_tr_fch9 USING bukrs hbkid hktid.
      ENDIF.

      IF t_rpt EQ 'R'. " REVERSA.
        PERFORM reversa_cheques USING bukrs hbkid hktid.
      ENDIF.
    WHEN '&ALL1'.
      PERFORM marcar_all.
    WHEN '&SAL1'.
      PERFORM desmarca_marcar_all.
*     WHEN '&MASIVO'.
*        PERFORM ARCHIVOS_MASIVO.

  ENDCASE.

  CASE f_ucomm.
    WHEN '&IC1'. "Doble Click
      CASE i_selfield-fieldname.
        WHEN 'VBLNR'.
          an1 = i_selfield-value.
          an1 = i_selfield-value.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = an1
            IMPORTING
              output = an1.
*          SELECT SINGLE GJAHR
*            FROM PAYR
*            INTO ANN
*           WHERE ZBUKR EQ BUKRS
*             AND HBKID EQ HBKID
*             AND HKTID EQ HKTID
*             AND VBLNR EQ AN1.
          READ TABLE  t_ok INDEX i_selfield-tabindex.
          IF sy-subrc EQ 0.
            fec = ann.
            PERFORM call_tran_fb03 USING bukrs i_selfield-value t_ok-zaldt+0(4).
          ENDIF.

        WHEN 'BELNR'.
          DATA: len TYPE p.
          DESCRIBE FIELD i_selfield-value.

          an1 = i_selfield-value.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = an1
            IMPORTING
              output = an1.

*                SELECT SINGLE GJAHR
*                  FROM BKPF
*                  INTO ANN
*                 WHERE BUKRS EQ BUKRS
*                   AND BELNR EQ AN1.

          READ TABLE  t_ok INDEX i_selfield-tabindex.

          IF sy-subrc EQ 0.
            fec = ann.
            PERFORM call_tran_fb03 USING bukrs an1 t_ok-gjahr.
          ENDIF.
        WHEN 'CHECT'.
* FCV - 21.04.2010
          IF NOT i_selfield-value IS INITIAL.
* fin FCV - 21.04.2010
            PERFORM call_zfimrp001 USING bukrs hbkid hktid i_selfield-value.
          ENDIF.
      ENDCASE.
  ENDCASE.

ENDFORM.                    "USER_COMMAND_DET
*&---------------------------------------------------------------------*
*&      Form  GENE_JUEGO_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gene_juego_datos .
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
** Modificado por H_FOUBERT 28.05.2013 Definición de Variable Local 'Mode'
  DATA: lv_mode TYPE ALLGAZMD VALUE 'A'.
** END H_FOUBERT 28.05.2013 Definición de Variable Local 'Mode'
  errorfechacontab = ' '.
  g_exis =  'N'.
  CLEAR juego_datos.
  IF     save_code EQ 'PRO_01'.
    juego_datos = 'CE'.
  ELSEIF save_code EQ 'PRO_02'.
    juego_datos = 'CF'.
  ELSEIF save_code EQ 'PRO_03'.
    juego_datos = 'AN'.
  ELSEIF save_code EQ 'PRO_04'.
    juego_datos = 'PR'.
  ELSEIF save_code EQ 'PRO_05'.
    juego_datos = 'RE'.
  ELSEIF save_code EQ 'PRO_06'.
    juego_datos = 'CC'.
  ENDIF.
  tipojuego = juego_datos+0(2).
  CONCATENATE juego_datos sy-datum+6(2) sy-datum+4(2) sy-datum+2(2) sy-uzeit(4) INTO lote.
  CONCATENATE juego_datos sy-datum+6(2) sy-datum+4(2) sy-uzeit(6) INTO juego_datos.
  group = juego_datos.
  v_primera = ' '.

  bkpf-budat = p_budat.

* FCV - 24.06.2010
  CLEAR aux.
  CLEAR: v_correlativo, nro_secuencia.
  IF save_code EQ 'PRO_06'.
    PERFORM ejecuta_submater USING juego_datos.
    aux = 'X'.
    WAIT UP TO 1 SECONDS.
    PERFORM zreserva USING i_tablsubm.
  ELSE.
* fin FCV - 24.06.2010
    REFRESH t_control.
    CLEAR: v_hora, v_revalida.
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

*        CONCATENATE tipojuego juego_datos sy-datum+6(2) sy-datum+4(2) sy-datum+2(2) sy-uzeit(4) INTO juego_datos.
        CONCATENATE tipojuego sy-datum+6(2) sy-datum+4(2) v_hora(6) INTO juego_datos.
        group = juego_datos.
      ENDIF.





      sw_bi = ''.
*     OPEN DATASET juego_datos FOR OUTPUT IN TEXT MODE
*                                ENCODING DEFAULT.
*                             WITH SMART.
*      Inicializa las estructuras del batch-input con '/' (nodata)
      PERFORM inicializa_jd USING bbseg.
      PERFORM inicializa_jd USING bbkpf.
      PERFORM inicializa_jd USING bselk.
      PERFORM inicializa_jd USING bselp.

* Se genera la estructura de datos
      PERFORM crear_juego_datos USING juego_datos.


*     CLOSE DATASET juego_datos.

*  PERFORM FILE_RES.

      IF g_exis EQ 'S' AND errorfechacontab IS INITIAL.
*      Se llama al programa estandar que genera el batch input.
        IF sw_bi = ''.
** Modificado por H_FOUBERT 28.05.2013 Se modifica el programa rfbibl00 por Z
** Se borra defaul de variable para el modo de ejecucion del bach input, permitiendo especificar el modo.
*          SUBMIT rfbibl00 WITH ds_name  = juego_datos " Logica Anterior.
*          INI JOROZCO 21.01.2020
          REPLACE ALL OCCURRENCES OF '/tmp/' IN juego_datos WITH ''.
*          FIN JOROZCO 21.01.2020
          SUBMIT zrfbibl00 WITH ds_name  = juego_datos " se modifica programa Standar a Z
                           WITH callmode = 'B'
                           WITH anz_mode = lv_mode     " se agrega variable para modo de ejec. Batch Input
                           WITH xinf = 'X'
                       AND RETURN.
** END H_FOUBERT 28.05.2013 Se modifica el programa rfbibl00 por Z
        ENDIF.
        PERFORM parametros_jdatos.

* lanza el juego de datos.
*        SUBMIT zrsbdcsub  WITH SELECTION-TABLE i_tablsubm AND RETURN.
        SUBMIT zrsbdcsub  WITH SELECTION-TABLE i_tablsubm EXPORTING LIST TO MEMORY AND RETURN.
        WAIT UP TO 1 SECONDS.
        PERFORM zreserva USING i_tablsubm.
      ENDIF.

      sw_bi = ''.


      CLEAR t_control.
      t_control-juego = juego_datos.
      t_control-chect = t_ok-chect.
      APPEND t_control.
** Modificado por L_FOUBERT 30.05.2013 definicion de segundos
      WAIT UP TO seconds SECONDS.
** END L_FOUBERT 30.05.2013 definicion de segundos
    ENDLOOP.
* Refresca grilla
    IF save_code EQ 'PRO_01'.
      WAIT UP TO 3 SECONDS.
      CLEAR t_ok.
      REFRESH t_ok.
      PERFORM caduca_elec_indiv     TABLES psel
                                             t_ok
                                      USING bukrs hbkid hktid bkpf-budat.
    ENDIF.

    IF save_code EQ 'PRO_02'.
      WAIT UP TO 3 SECONDS.
      CLEAR t_ok.
      REFRESH t_ok.
      PERFORM caduca_fisic_indiv     TABLES psel
                                              t_ok
                                         USING bukrs hbkid hktid bkpf-budat.
    ENDIF.
****   PRESCRIPCION ***********
    IF save_code EQ 'PRO_04'.
* FCV - 22.04.2010
      WAIT UP TO 3 SECONDS.
      CLEAR t_ok.
      REFRESH t_ok.
      PERFORM prescripcion     TABLES psel
                                            t_ok
                                         USING bukrs hbkid hktid bkpf-budat.
* fin FCV - 22.04.2010
    ENDIF.
****   Revalidar ***********
    IF save_code EQ 'PRO_05'.
      WAIT UP TO 3 SECONDS.
      CLEAR t_ok.
      REFRESH t_ok.
      PERFORM revalidar     TABLES psel
                                            t_ok
                                         USING bukrs hbkid hktid bkpf-budat.
    ENDIF.
  ENDIF.

* chidalgo - Quintec 27.05.2010
* Agregar columna de juego de datos
  IF NOT t_ok[] IS INITIAL.
    LOOP AT t_ok.
      v_index = sy-tabix.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE jdatos lote INTO (t_ok-jdatos, t_ok-lote)
*        FROM zjdatos_edocheq
*        WHERE bukrs EQ bukrs AND
*              hbkid EQ hbkid AND
*              hktid EQ hktid AND
*              chect EQ t_ok-chect.
*
* NEW CODE
      SELECT jdatos lote
      UP TO 1 ROWS  INTO (t_ok-jdatos, t_ok-lote)
        FROM zjdatos_edocheq
        WHERE bukrs EQ bukrs AND
              hbkid EQ hbkid AND
              hktid EQ hktid AND
              chect EQ t_ok-chect ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      MODIFY t_ok TRANSPORTING jdatos.

* FCV - 07.08.2010 - Incorporar secuencia del Juego de Datos
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE secuencia INTO t_ok-secuencia
*        FROM zjdatos_secuen
** FCV - 05.09.2010 - Lotes
**        WHERE jdatos = t_ok-jdatos
*        WHERE jdatos = t_ok-lote
** fin FCV - 05.09.2010 - Lotes
*          AND bukrs EQ bukrs AND
*              hbkid EQ hbkid AND
*              hktid EQ hktid AND
*              chect EQ t_ok-chect.
*
* NEW CODE
      SELECT secuencia
      UP TO 1 ROWS  INTO t_ok-secuencia
        FROM zjdatos_secuen
* FCV - 05.09.2010 - Lotes
*        WHERE jdatos = t_ok-jdatos
        WHERE jdatos = t_ok-lote
* fin FCV - 05.09.2010 - Lotes
          AND bukrs EQ bukrs AND
              hbkid EQ hbkid AND
              hktid EQ hktid AND
              chect EQ t_ok-chect ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      MODIFY t_ok INDEX v_index.
* fin FCV - 07.08.2010 - Incorporar secuencia del Juego de Datos

*********************************************************************************
* FCV - 21.10.2010
* Se revisa si el cheque fue seleccionado para proceso. Si es encontrado en la tabla
* T_CONTROL, entonces se revisa el status del termino del proceso.
*********************************************************************************
      READ TABLE t_control WITH KEY chect = t_ok-chect.
      IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE qstate INTO apqi-qstate
*        FROM apqi
*        WHERE groupid = t_control-juego.
*
* NEW CODE
        SELECT qstate
        UP TO 1 ROWS  INTO apqi-qstate
        FROM apqi
        WHERE groupid = t_control-juego ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc EQ 0.
          IF apqi-qstate = 'F'.
* Job finalizó exitosamente, por lo que se coloca con semáforo en ROJO
            t_ok-status = '@0A@'.
          ELSEIF apqi-qstate = 'E'.
* Semáforo continúa en VERDE
            t_ok-status = '@08@'.
          ELSE.
* Se revisa si el registro está en status P en tabla Zjdatos_edocheq
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE estado INTO zjdatos_edocheq-estado
*              FROM zjdatos_edocheq
*              WHERE bukrs = bukrs
*                AND hbkid = hbkid
*                AND hktid = hktid
*                AND chect = t_control-chect.
*
* NEW CODE
            SELECT estado
            UP TO 1 ROWS  INTO zjdatos_edocheq-estado
              FROM zjdatos_edocheq
              WHERE bukrs = bukrs
                AND hbkid = hbkid
                AND hktid = hktid
                AND chect = t_control-chect ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

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

      IF save_code = 'PRO_01' AND t_ok-estado = 'CHEQUE ANULADO'.
        MOVE '@0A@' TO t_ok-status. " ICONO MAL
        MODIFY t_ok INDEX v_index.
      ENDIF.

*********************************************************************************
* fin FCV - 21.10.2010
*********************************************************************************
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
  RANGES: xlaufi FOR payr-laufi.

  IF save_code NE  'PRO_03'.
    CONCATENATE '/tmp/' juego_datos INTO juego_datos."JOROZCO 20.01.2020
    OPEN DATASET juego_datos FOR OUTPUT IN TEXT MODE
                                 ENCODING DEFAULT.
    PERFORM crea_cabecera_jd USING juego_datos.

    CLEAR: v_primera.
***    LOOP AT t_ok.
* FCV - 22.04.2010
*      IF t_ok-status EQ '@08@' AND t_ok-chek1 EQ 'X'.
    IF t_ok-status EQ '@08@' AND t_ok-box EQ 'X'.
      v_correlativo = v_correlativo + 1.
      nro_secuencia = nro_secuencia + 1.
* fin FCV - 22.04.2010
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
***    ENDLOOP.
  ELSE. "SOLO PARA PROCESO DE ANULACION"

* FCV - 24.04.2010 - Faltaba ciclo de loop y además la
* validación de la marca del registro con el semáforo en verde
***    LOOP AT t_ok.

    IF t_ok-status EQ '@08@' AND t_ok-box EQ 'X'.
      v_correlativo = v_correlativo + 1.
      nro_secuencia = nro_secuencia + 1.
* fin FCV - 24.04.2010 - Faltaba ciclo de loop y además la
      g_exis = 'S'.
      CLEAR:  hkont_aux, bukrs_aux.
      bukrs_aux = t_ok-bukrs.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM payr WHERE ichec  = ''
*                                AND   zbukr  = t_ok-bukrs
*                                AND   hbkid  = hbkid
*                                AND   hktid  = hktid
*                                AND   chect  = t_ok-chect.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM payr WHERE ichec  = ''
                                AND   zbukr  = t_ok-bukrs
                                AND   hbkid  = hbkid
                                AND   hktid  = hktid
                                AND   chect  = t_ok-chect ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01




      REFRESH xlaufi.
      xlaufi-sign = 'I'.
      xlaufi-low = payr-laufi.

      IF   payr-laufi+5(1) = '*' .
        xlaufi-option  = 'CP'.
      ELSE.
        xlaufi-option  = 'EQ'.
      ENDIF.

      APPEND xlaufi.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM reguh WHERE laufd = payr-laufd
*                                 AND   laufi IN xlaufi
*                                 AND   xvorl = ''
*                                 AND   zbukr = payr-zbukr
*                                 AND   lifnr = payr-lifnr
*                                 AND   kunnr = payr-kunnr
*                                 AND   empfg = payr-empfg
*                                 AND   vblnr = payr-vblnr.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM reguh WHERE laufd = payr-laufd
                                 AND   laufi IN xlaufi
                                 AND   xvorl = ''
                                 AND   zbukr = payr-zbukr
                                 AND   lifnr = payr-lifnr
                                 AND   kunnr = payr-kunnr
                                 AND   empfg = payr-empfg
                                 AND   vblnr = payr-vblnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF reguh-zbukr <> reguh-absbu.
        bukrs_aux = reguh-absbu.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM regup WHERE laufd = reguh-laufd
*                         AND   laufi = reguh-laufi
*                         AND   xvorl = ''
*                         AND   zbukr = reguh-zbukr
*                         AND   lifnr = reguh-lifnr
*                         AND   kunnr = reguh-kunnr
*                         AND   empfg = reguh-empfg
*                         AND   vblnr = reguh-vblnr
*                         AND   bukrs = reguh-absbu.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM regup WHERE laufd = reguh-laufd
                         AND   laufi = reguh-laufi
                         AND   xvorl = ''
                         AND   zbukr = reguh-zbukr
                         AND   lifnr = reguh-lifnr
                         AND   kunnr = reguh-kunnr
                         AND   empfg = reguh-empfg
                         AND   vblnr = reguh-vblnr
                         AND   bukrs = reguh-absbu ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        hkont_aux = regup-hkont.
        PERFORM batch_input_inter USING juego_datos.
        sw_bi = 'X'.
      ELSE.
        CONCATENATE '/tmp/' juego_datos INTO juego_datos."JOROZCO 20.01.2020
        OPEN DATASET juego_datos FOR OUTPUT IN TEXT MODE
                                 ENCODING DEFAULT.
        PERFORM crea_cabecera_jd USING juego_datos.

        PERFORM crea_cabecera_bbkpf USING juego_datos.
        PERFORM crea_cabecera_bbseg USING juego_datos.
        PERFORM crea_cabecera_bselk USING juego_datos.
        PERFORM crea_cabecera_bselp USING juego_datos.
        CLOSE DATASET juego_datos.
      ENDIF.

    ENDIF.
***    ENDLOOP.
  ENDIF.

*    ELSE.
*      PERFORM CREA_CABECERA_BBSEG USING JUEGO_DATOS.
*    ENDIF.

ENDFORM.                    "CREAR_JUEGO_DATOS


*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_JD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM crea_cabecera_jd USING fichero.

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

  DATA: xbudat LIKE bkpf-budat.
* FCV - 13.05.2010
* Se levanta dynpro para ingreso de fecha de contabilización
  v_errorfechareval = ' '.
  v_erroragencia = ' '.

  CLEAR:  hkont_aux, bukrs_aux.

  IF save_code = 'PRO_05'.  " Revalidación
*    IF v_primera IS INITIAL.
    IF v_revalida IS INITIAL.
      CLEAR: fechacontab, errorfechacontab.
      v_primeravez = ' '.
      v_check = ' '.

      CALL SCREEN '200' STARTING AT 5 5 ENDING AT 45 10.

      IF fechacontab = '00000000' OR sy-subrc EQ 1.
        errorfechacontab = 'X'.
        MESSAGE 'Fecha y Agencia no se modifican.' TYPE 'W'.
      ELSE.
* FCV - 07.08.2010
* Se revisa que la fecha contable ingresada no sea menor que ningun registro de la tabla interna
* T_OK cuyo campo MARCA = 'X'
        LOOP AT t_ok WHERE box = 'X'
                       AND bldat > fechacontab.
          v_errorfechareval = 'X'.
          EXIT.
        ENDLOOP.
* Se revisa si no ingreso agencia, que no exista ningún registro marcado con agencia
        IF v_errorfechareval IS INITIAL.
          IF v_agencia IS INITIAL.
            LOOP AT t_ok WHERE box = 'X'
                           AND zagencia = ' '.
              v_erroragencia = 'X'.
              EXIT.
            ENDLOOP.
          ENDIF.
        ENDIF.
        IF v_errorfechareval IS INITIAL AND v_erroragencia IS INITIAL.
          bkpf-budat = fechacontab.
        ENDIF.
      ENDIF.
*      v_primera = 'X'.
      v_revalida = 'X'.
    ENDIF.
  ENDIF.
* fin FCV - 13.05.2010
  DATA : p_bldat TYPE bldat.
  IF v_errorfechareval IS INITIAL AND v_erroragencia IS INITIAL.
    IF errorfechacontab IS INITIAL.
      IF save_code = 'PRO_06'.
        MOVE: '1'                   TO bbkpf-stype,
              'FB05'                TO bbkpf-tcode.    "Cod. transaccion

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE  bldat INTO p_bldat
*          FROM  bkpf
*         WHERE  bukrs EQ t_ok-bukrs
*           AND  belnr EQ t_ok-vblnr
*           AND  gjahr EQ t_ok-gjahr.
*
* NEW CODE
        SELECT bldat
        UP TO 1 ROWS  INTO p_bldat
          FROM  bkpf
         WHERE  bukrs EQ t_ok-bukrs
           AND  belnr EQ t_ok-vblnr
           AND  gjahr EQ t_ok-gjahr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc EQ 0.
          CONCATENATE p_bldat+6(2)
                      p_bldat+4(2)
                      p_bldat+0(4) INTO bbkpf-bldat.
        ELSE.
          CONCATENATE bkpf-budat+6(2)
                      bkpf-budat+4(2)
                      bkpf-budat+0(4) INTO bbkpf-bldat.
        ENDIF.
        MOVE: 'ZA'                  TO bbkpf-blart,    "Clase documento
              t_ok-bukrs            TO bbkpf-bukrs.    "Sociedad

        CONCATENATE bkpf-budat+6(2)
                    bkpf-budat+4(2)
                    bkpf-budat+0(4) INTO bbkpf-budat.

        MOVE: bkpf-budat+4(2)        TO bbkpf-monat,    "Mes contable
              'CLP'                  TO bbkpf-waers,    "Moneda
              'Cambio Estado Cheque' TO bbkpf-bktxt.    "Texto Cab.Docto

        CLEAR v_xblnr.
        CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+2(2) sy-uzeit(4) v_correlativo
                    INTO v_xblnr.
        bbkpf-xblnr = v_xblnr.

        bbkpf-auglv = 'UMBUCHNG'.
        bbkpf-docid   = '*'.

        TRANSFER bbkpf TO fichero.
* chidalgo - Quintec 27.05.2010
* Agregar columna de juego de datos
        zjdatos_edocheq-bukrs  = bukrs.
        zjdatos_edocheq-hbkid  = hbkid.
        zjdatos_edocheq-hktid  = hktid.
        zjdatos_edocheq-chect  = t_ok-chect.
        zjdatos_edocheq-jdatos = group.
* FCV - 05.09.2010 - Lote
        zjdatos_edocheq-lote = lote.
        zjdatos_edocheq-estado = 'P'.
        zjdatos_edocheq-fecha = sy-datum.
*        zjdatos_edocheq-ultimo_estado = t_ok-estado.
        TRANSLATE t_ok-estado TO UPPER CASE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE codigo INTO zjdatos_edocheq-ultimo_estado
*        FROM ztestadocheque
*          WHERE glosa = t_ok-estado.
*
* NEW CODE
        SELECT codigo
        UP TO 1 ROWS  INTO zjdatos_edocheq-ultimo_estado
        FROM ztestadocheque
          WHERE glosa = t_ok-estado ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        zjdatos_edocheq-secuencia = nro_secuencia.
* fin FCV - 05.09.2010 - Lote
        MODIFY  zjdatos_edocheq.

* FCV - 07.08.2010 - Se inserta el Juego de datos y su secuencia respectiva
        CLEAR wa_secuen.
        wa_secuen-bukrs  = bukrs.
        wa_secuen-hbkid  = hbkid.
        wa_secuen-hktid  = hktid.
        wa_secuen-chect  = t_ok-chect.
* FCV - 05.09.2010 - Lote
*        wa_secuen-jdatos = group.
        wa_secuen-jdatos = lote.
* fin FCV - 05.09.2010 - Lote
        wa_secuen-secuencia = nro_secuencia.
        INSERT zjdatos_secuen FROM wa_secuen.
* fin FCV - 07.08.2010

* Fin Modificación
        PERFORM inicializa_jd USING bbkpf.

      ELSE.

        bukrs_aux = t_ok-bukrs.

        IF save_code EQ 'PRO_03'.      " Anular

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM payr WHERE ichec  = ''
*                                    AND   zbukr  = t_ok-bukrs
*                                    AND   hbkid  = hbkid
*                                    AND   hktid  = hktid
*                                    AND   chect  = t_ok-chect.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM payr WHERE ichec  = ''
                                    AND   zbukr  = t_ok-bukrs
                                    AND   hbkid  = hbkid
                                    AND   hktid  = hktid
                                    AND   chect  = t_ok-chect ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM reguh WHERE laufd = payr-laufd
*                                     AND   laufi = payr-laufi
*                                     AND   xvorl = ''
*                                     AND   zbukr = payr-zbukr
*                                     AND   lifnr = payr-lifnr
*                                     AND   kunnr = payr-kunnr
*                                     AND   empfg = payr-empfg
*                                     AND   vblnr = payr-vblnr.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM reguh WHERE laufd = payr-laufd
                                     AND   laufi = payr-laufi
                                     AND   xvorl = ''
                                     AND   zbukr = payr-zbukr
                                     AND   lifnr = payr-lifnr
                                     AND   kunnr = payr-kunnr
                                     AND   empfg = payr-empfg
                                     AND   vblnr = payr-vblnr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          IF reguh-zbukr <> reguh-absbu.
            bukrs_aux = reguh-absbu.
          ENDIF.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM regup WHERE laufd = reguh-laufd
*                             AND   laufi = reguh-laufi
*                             AND   xvorl = ''
*                             AND   zbukr = reguh-zbukr
*                             AND   lifnr = reguh-lifnr
*                             AND   kunnr = reguh-kunnr
*                             AND   empfg = reguh-empfg
*                             AND   vblnr = reguh-vblnr
*                             AND   bukrs = reguh-absbu.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM regup WHERE laufd = reguh-laufd
                             AND   laufi = reguh-laufi
                             AND   xvorl = ''
                             AND   zbukr = reguh-zbukr
                             AND   lifnr = reguh-lifnr
                             AND   kunnr = reguh-kunnr
                             AND   empfg = reguh-empfg
                             AND   vblnr = reguh-vblnr
                             AND   bukrs = reguh-absbu ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          hkont_aux = regup-hkont.
        ENDIF.


        MOVE: '1'                   TO bbkpf-stype,
*        'BBKPF'               TO BBKPF-TBNAM,
              'FB05'                TO bbkpf-tcode,    "Cod. transaccion
              'ZA'                  TO bbkpf-blart,    "Clase documento
               bukrs_aux            TO bbkpf-bukrs,    "Sociedad
               bkpf-budat+4(2)      TO bbkpf-monat,    "Mes contable
              'CLP'                 TO bbkpf-waers,    "Moneda
        'Cambio Estado Cheque'      TO bbkpf-bktxt.    "Texto Cab.Docto

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE  bldat INTO p_bldat
*          FROM  bkpf
*         WHERE  bukrs EQ t_ok-bukrs
*           AND  belnr EQ t_ok-vblnr
*           AND  gjahr EQ t_ok-gjahr.
*
* NEW CODE
        SELECT bldat
        UP TO 1 ROWS  INTO p_bldat
          FROM  bkpf
         WHERE  bukrs EQ t_ok-bukrs
           AND  belnr EQ t_ok-vblnr
           AND  gjahr EQ t_ok-gjahr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc EQ 0.
          CONCATENATE p_bldat+6(2)
                      p_bldat+4(2)
                      p_bldat+0(4) INTO bbkpf-bldat.
        ELSE.
          CONCATENATE bkpf-budat+6(2)
                      bkpf-budat+4(2)
                      bkpf-budat+0(4) INTO bbkpf-bldat.
        ENDIF.


* FCV - 13.05.2010
        IF save_code = 'PRO_05'.  " Revalidación
          IF NOT fechacontab IS INITIAL.
            bkpf-budat = fechacontab.
          ENDIF.
        ENDIF.
* FCV - 04.07.2010 - Sólo para cuando sea anulación y días negativos, fecha de contabilización = fecha emisión
        IF save_code = 'PRO_03' AND t_ok-datev < 0.
          CONCATENATE t_ok-bldat+6(2)
                      t_ok-bldat+4(2)
                      t_ok-bldat+0(4) INTO bbkpf-budat.
        ELSE.
          CONCATENATE bkpf-budat+6(2)
                      bkpf-budat+4(2)
                      bkpf-budat+0(4) INTO bbkpf-budat.
* Fin FCV - 13.05.2010
        ENDIF.
*********************************
* FCV - 17.06.2010
*********************************
        IF save_code EQ 'PRO_03'.      " Anular
          IF t_ok-estado = 'REVALIDADO'.
* Se rescata la fecha contable del documento que revalidó
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE budat INTO xbudat FROM bkpf
*            WHERE bukrs =  t_ok-bukrs
*              AND belnr =  t_ok-belnr
*              AND gjahr =  t_ok-gjahr.
*
* NEW CODE
            SELECT budat
            UP TO 1 ROWS  INTO xbudat FROM bkpf
            WHERE bukrs =  t_ok-bukrs
              AND belnr =  t_ok-belnr
              AND gjahr =  t_ok-gjahr ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

            IF sy-subrc EQ 0.
              CONCATENATE xbudat+6(2) xbudat+4(2) xbudat+0(4) INTO bbkpf-bldat.
            ENDIF.
          ENDIF.
        ENDIF.
*********************************
* FCV - 17.06.2010
*********************************


        bbkpf-auglv = 'UMBUCHNG'.
        bbkpf-docid   = '*'.
        MOVE '1'    TO bbkpf-kursf.
* FCV - 21.06.2010 - Se incluye referencia en todos los cambios de status
        CLEAR v_xblnr.
        CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+2(2) sy-uzeit(6) v_correlativo
                    INTO v_xblnr.
        bbkpf-xblnr = v_xblnr.
* fin FCV - 21.06.2010

        TRANSFER bbkpf TO fichero.
* chidalgo - Quintec 27.05.2010
* Agregar columna de juego de datos
        zjdatos_edocheq-bukrs  = bukrs.
        zjdatos_edocheq-hbkid  = hbkid.
        zjdatos_edocheq-hktid  = hktid.
        zjdatos_edocheq-chect  = t_ok-chect.
        zjdatos_edocheq-jdatos = group.
* FCV - 05.09.2010 - Lote
        zjdatos_edocheq-lote = lote.
        zjdatos_edocheq-estado = 'P'.
        zjdatos_edocheq-fecha = sy-datum.
*        zjdatos_edocheq-ultimo_estado = t_ok-estado.
        TRANSLATE t_ok-estado TO UPPER CASE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE codigo INTO zjdatos_edocheq-ultimo_estado
*        FROM ztestadocheque
*          WHERE glosa = t_ok-estado.
*
* NEW CODE
        SELECT codigo
        UP TO 1 ROWS  INTO zjdatos_edocheq-ultimo_estado
        FROM ztestadocheque
          WHERE glosa = t_ok-estado ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        zjdatos_edocheq-secuencia = nro_secuencia.
* fin FCV - 05.09.2010 - Lote
        MODIFY  zjdatos_edocheq.

* FCV - 07.08.2010 - Se inserta el Juego de datos y su secuencia respectiva
        CLEAR wa_secuen.
        wa_secuen-bukrs  = bukrs.
        wa_secuen-hbkid  = hbkid.
        wa_secuen-hktid  = hktid.
        wa_secuen-chect  = t_ok-chect.
* FCV - 05.09.2010 - Lote
*        wa_secuen-jdatos = group.
        wa_secuen-jdatos = lote.
* fin FCV - 05.09.2010 - Lote
        wa_secuen-secuencia = nro_secuencia.
        INSERT zjdatos_secuen FROM wa_secuen.
* fin FCV - 07.08.2010

* Fin Modificación
        PERFORM inicializa_jd USING bbkpf.
      ENDIF.
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
  TABLES: bseg.

*  INI - JOROZCO 20.01.2020
*  DATA :  g_wrbtr(10),
  DATA :  g_wrbtr(15),
*  FIN - JOROZCO 20.01.2020
          g_wrbtri TYPE p DECIMALS 0.
  g_wrbtr = t_ok-wrbtr.
  DATA: p_motemis TYPE zzmot_emis. " motivo de emision para maternales
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
    IF save_code EQ 'PRO_06'. "REVALIDADO CON CHEQUE NUEVO"
      MOVE 'ZC01'               TO bbseg-zterm.
      MOVE 'C'                  TO bbseg-zlsch.
      MOVE: t_ok-lifnr          TO bbseg-newko.    "ACREEDOR
      MOVE: t_ok-hkontd         TO bbseg-hkont.    "Cuenta
    ELSE. " PARA ANULACION
      MOVE: t_ok-lifnr          TO bbseg-newko.    "Cuenta
    ENDIF.
  ENDIF.

***********************************************************************
* FCV - 16.06.2010
* Se realiza movimiento de cuenta original para que se haga la reversa
* Siempre se rescata la cuenta desde la primera posición
***********************************************************************
  IF save_code EQ 'PRO_03'.      " Anular
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM bseg
*      WHERE bukrs =  t_ok-bukrs
*        AND belnr =  t_ok-vblnr
*        AND gjahr =  t_ok-gjahr
*        AND shkzg = 'S'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM bseg
      WHERE bukrs =  t_ok-bukrs
        AND belnr =  t_ok-vblnr
        AND gjahr =  t_ok-gjahr
        AND shkzg = 'S' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*        AND buzei = '001'.

    IF sy-subrc EQ 0.
      MOVE: bseg-hkont TO bbseg-hkont,    "Cuenta
           '31' TO bbseg-newbs.          " Clave contabilizaciòn

    ENDIF.

*********************************************************************
* FCV - 08.08.2010
*********************************************************************
* Se mueven los campos Banco propio, condición de pago, vía de pago,
* y clave de referencia 1
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM payr
*      WHERE zbukr = bukrs
*        AND hbkid = hbkid
*        AND hktid = hktid
*        AND chect = t_ok-chect.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM payr
      WHERE zbukr = bukrs
        AND hbkid = hbkid
        AND hktid = hktid
        AND chect = t_ok-chect ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM bsak
*        WHERE bukrs = payr-zbukr
*          AND lifnr = payr-lifnr
*          AND augbl = payr-vblnr
*          AND belnr <> payr-vblnr.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM bsak
        WHERE bukrs = payr-zbukr
          AND lifnr = payr-lifnr
          AND augbl = payr-vblnr
          AND belnr <> payr-vblnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF sy-subrc EQ 0.
        bbseg-hbkid = payr-hbkid.   " Banco propio
        bbseg-zterm = bsak-zterm.   " Condición de pago
        bbseg-zlsch = bsak-zlsch.   " Vía de pago
        bbseg-xref1 = bsak-xref1.   " Clave referencia 1
        IF t_ok-zagencia IS INITIAL.
          MOVE bsak-zz_agencia TO bbseg-zz_agencia.
        ELSE.
          MOVE t_ok-zagencia TO bbseg-zz_agencia.
        ENDIF.
      ENDIF.
*********************************************************************
* fin FCV - 08.08.2010
*********************************************************************
    ENDIF.
  ENDIF.
***********************************************************************
* fin FCV - 16.06.2010
***********************************************************************

***********************************************************************
* FCV - 24.06.2010
* Se realiza movimiento de cuenta definida para el Cambio de cheque y
* motivo de emision SUBMATERNA (subsidio por maternidad)
***********************************************************************
  IF save_code EQ 'PRO_06'.      " Cambio cheque maternal
* 04042012 HCD
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zzmot_emis
*    INTO  p_motemis
*    FROM  ztipchequemat
*    WHERE bukrs      EQ t_ok-bukrs
*    AND zzmot_emis EQ t_ok-zmote.
*
* NEW CODE
    SELECT zzmot_emis
    UP TO 1 ROWS 
    INTO  p_motemis
    FROM  ztipchequemat
    WHERE bukrs      EQ t_ok-bukrs
    AND zzmot_emis EQ t_ok-zmote ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* FIN 04042012 HCD

* IF t_ok-zmote = 'SUBMATERNA' AND t_ok-estado = 'REVALIDADO'. se deja dinamico la busqueda de tipo maternal
    IF sy-subrc = 0 AND t_ok-estado = 'REVALIDADO'.
      MOVE: '2011730013' TO bbseg-hkont,    "Cuenta
            '31' TO bbseg-newbs.          " Clave contabilizaciòn
    ENDIF.
  ENDIF.
***********************************************************************
* fin FCV - 18.06.2010
***********************************************************************
  MOVE: g_wrbtri              TO bbseg-wrbtr,    "Importe mon doc
      t_ok-sgtxt              TO bbseg-sgtxt.


  IF t_ok-chect IS NOT INITIAL.
    MOVE t_ok-chect            TO bbseg-zuonr.    "ASIGNACION
  ENDIF.

  MOVE  t_ok-zmote              TO bbseg-zzmot_emis.

* FCV - 13.08.2010
* Sólo en el caso de la prescripción, se traspasa el valor de la prestación y la unid/prod
  IF save_code EQ 'PRO_04'.
    bbseg-zzprestac = 'SUB07'.
    bbseg-zzunid_pro = 'PROD2'.
  ENDIF.
* fin FCV - 13.08.2010

* FCV - 29.07.2010
  IF save_code EQ 'PRO_05'.      "Revalidación
    IF v_agencia IS INITIAL.
      MOVE  t_ok-zagencia   TO bbseg-zz_agencia.
    ELSE.
      MOVE  v_agencia       TO bbseg-zz_agencia.
    ENDIF.
* Se actualiza tabla BSAK con la nueva agencia
    UPDATE bsak SET zz_agencia = bbseg-zz_agencia
    WHERE bukrs = t_ok-bukrs
      AND lifnr = t_ok-lifnr
      AND augbl = t_ok-vblnr
      AND belnr <> t_ok-vblnr
      AND gjahr = t_ok-gjahr.
  ENDIF.
* fin FCV - 29.07.2010

*  DATA:    BEGIN OF S_POSTAB OCCURS 50,
*             XAUTH(1)      TYPE C,                 " Berechtigung?
*             XHELL(1)      TYPE C.                 " Hell anzeigen?
*          INCLUDE STRUCTURE RFPOS.              " Listanzeigen-Struktur
*  INCLUDE RFEPOSC9.                     " Kunden-Sonderfelder
*  DATA:      XBKPF(1)      TYPE C,                 " BKPF nachgelesen?
*             XBSEG(1)      TYPE C,                 " BSEG nachgelesen?
*             XBSEC(1)      TYPE C,                 " BSEC nachgelesen?
*             XBSED(1)      TYPE C,                 " BSED nachgelesen?
*             XPAYR(1)      TYPE C,                 " PAYR nachgelesen?
*             XBSEGC(1)     TYPE C,                 " BSEGC nachgelesen?
*             XBSBV(1)      TYPE C,                 " BSBV nachgelesen?
*             XMOD(1)       TYPE C,                 " POSTAB modifiziert?
*           END OF S_POSTAB.
*
*
*  DATA:
*  I_GJAHR LIKE PAYR-GJAHR,
*  I_VBLNR LIKE PAYR-VBLNR,
*  I_XBUKR LIKE PAYR-XBUKR,
*  I_ZBUKR LIKE PAYR-ZBUKR.
*
*  I_XBUKR = 'X'.
*  I_ZBUKR = T_OK-BUKRS.
*
*  CALL FUNCTION 'GET_INVOICE_DOCUMENT_NUMBERS'
*    EXPORTING
*      I_GJAHR   = T_OK-GJAHR
*      I_VBLNR   = T_OK-VBLNR
*      I_XBUKR   = I_XBUKR
*      I_ZBUKR   = I_ZBUKR
*    TABLES
*      T_INVOICE = S_POSTAB
*    EXCEPTIONS
*      NOT_FOUND = 1
*      OTHERS    = 2.
*  IF SY-SUBRC <> 0.
**   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*  DATA: P_BELNR LIKE BKPF-BELNR.
*  DATA: P_BUZEI LIKE BSEG-BUZEI.
*  LOOP AT S_POSTAB.
*    MOVE S_POSTAB-BELNR TO P_BELNR.
*    MOVE S_POSTAB-BUZEI TO P_BUZEI.
*  ENDLOOP.
*
*  SELECT SINGLE ZZMOT_EMIS INTO BBSEG-ZZMOT_EMIS
*    FROM BSEG
*   WHERE BUKRS EQ T_OK-BUKRS
*     AND BELNR EQ P_BELNR
*     AND BUZEI EQ 1
*     AND GJAHR EQ T_OK-GJAHR.

  IF t_rpt = 'C'.
    IF save_code NE 'PRO_04'.   " Prescripciòn
      CONCATENATE bkpf-budat+6(2)
            bkpf-budat+4(2)
            bkpf-budat+0(4) INTO bbseg-valut.
    ENDIF.
  ENDIF.

*     Si los campos vienen vacíos, se deja el signo '/' (nodata)

*  IF ARCH_PLANO-DMBTR NE SPACE.
*    MOVE ARCH_PLANO-DMBTR    TO BBSEG-DMBTR.
*  ENDIF.
*
*  IF ARCH_PLANO-NEWUM NE SPACE.
*    MOVE ARCH_PLANO-NEWUM    TO BBSEG-NEWUM.
*  ENDIF.
*  IF ARCH_PLANO-NEWBW NE SPACE.
*    MOVE ARCH_PLANO-NEWBW    TO BBSEG-NEWBW.
*  ENDIF.
*  IF ARCH_PLANO-ZFBDT NE SPACE.
*    CONCATENATE ARCH_PLANO-ZFBDT+0(2)
*                ARCH_PLANO-ZFBDT+3(2)
*                ARCH_PLANO-ZFBDT+6(4) INTO BBSEG-ZFBDT.
*  ENDIF.
*  IF ARCH_PLANO-ZTERM NE SPACE.
*    MOVE ARCH_PLANO-ZTERM    TO BBSEG-ZTERM.
*  ENDIF.
*  IF ARCH_PLANO-VALUT NE SPACE.
*    CONCATENATE ARCH_PLANO-VALUT+0(2)
*                ARCH_PLANO-VALUT+3(2)
*                ARCH_PLANO-VALUT+6(4) INTO BBSEG-VALUT.


*  BBSEG-VALUT = BKPF-BUDAT.
*  ENDIF.
*  IF ARCH_PLANO-ZLSPR NE SPACE.
*    MOVE ARCH_PLANO-ZLSPR    TO BBSEG-ZLSPR.
*  ENDIF.
*  IF ARCH_PLANO-ZLSCH NE SPACE.
*    MOVE ARCH_PLANO-ZLSCH    TO BBSEG-ZLSCH.
*  ENDIF.
*  IF ARCH_PLANO-BANKL NE SPACE.
*    MOVE ARCH_PLANO-BANKL    TO BBSEG-BANKL.
*  ENDIF.
*  IF ARCH_PLANO-BANKS NE SPACE.
*    MOVE ARCH_PLANO-BANKS    TO BBSEG-BANKS.
*  ENDIF.
*  IF ARCH_PLANO-BANKN NE SPACE.
*    MOVE ARCH_PLANO-BANKN    TO BBSEG-BANKN.
*  ENDIF.
*  IF ARCH_PLANO-HBKID NE SPACE.
*    MOVE ARCH_PLANO-HBKID    TO BBSEG-HBKID.
*  ENDIF.
*  IF ARCH_PLANO-REGUL NE SPACE.
*    MOVE ARCH_PLANO-REGUL    TO BBSEG-REGUL.
*  ENDIF.
*  IF ARCH_PLANO-NAME1 NE SPACE.
*    MOVE ARCH_PLANO-NAME1    TO BBSEG-NAME1.
*  ENDIF.
*  IF ARCH_PLANO-NAME3 NE SPACE.
*    MOVE ARCH_PLANO-NAME3    TO BBSEG-NAME3.
*  ENDIF.
*  IF ARCH_PLANO-ORT01 NE SPACE.
*    MOVE ARCH_PLANO-ORT01    TO BBSEG-ORT01.
*  ENDIF.
*  IF ARCH_PLANO-ZUONR NE SPACE.
*    MOVE ARCH_PLANO-ZUONR    TO BBSEG-ZUONR.
*  ENDIF.
*  IF ARCH_PLANO-SGTXT NE SPACE.
*    MOVE ARCH_PLANO-SGTXT    TO BBSEG-SGTXT.
*  ENDIF.
*  IF ARCH_PLANO-KOSTL NE SPACE.
*    MOVE ARCH_PLANO-KOSTL    TO BBSEG-KOSTL.
*  ENDIF.
*  IF ARCH_PLANO-SKFBT NE SPACE.
*    MOVE ARCH_PLANO-SKFBT    TO BBSEG-SKFBT.
*  ENDIF.
*  IF ARCH_PLANO-AUFNR NE SPACE.
*    MOVE ARCH_PLANO-AUFNR    TO BBSEG-AUFNR.
*  ENDIF.
*
*  IF ARCH_PLANO-MENGE NE SPACE.
*    MOVE ARCH_PLANO-MENGE    TO BBSEG-MENGE.
*  ENDIF.
*
*  IF ARCH_PLANO-MEINS NE SPACE.
*    MOVE ARCH_PLANO-MEINS    TO BBSEG-MEINS.
*  ENDIF.

  TRANSFER bbseg TO fichero.
  PERFORM inicializa_jd USING bbseg.

* FCV - 25.06.2010
* Se incorpora la segunda cuenta para compensar
  IF save_code EQ 'PRO_06'.      " Cambio cheque maternal
* 04042012 HCD
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zzmot_emis
*    INTO  p_motemis
*    FROM  ztipchequemat
*    WHERE bukrs      EQ t_ok-bukrs
*    AND zzmot_emis   EQ t_ok-zmote.
*
* NEW CODE
    SELECT zzmot_emis
    UP TO 1 ROWS 
    INTO  p_motemis
    FROM  ztipchequemat
    WHERE bukrs      EQ t_ok-bukrs
    AND zzmot_emis   EQ t_ok-zmote ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* FIN 04042012 HCD

*    IF t_ok-zmote = 'SUBMATERNA' AND t_ok-estado = 'REVALIDADO'. cambia por consulta dinamica motivo maternal
    IF sy-subrc = 0 AND t_ok-estado = 'REVALIDADO'.
      bbseg-stype = '2'.
      bbseg-tbnam = 'BBSEG'.
      bbseg-newbs = '40'.          " Clave contabilización
      bbseg-newko = '1011970007'.  " Cuenta
      bbseg-wrbtr = '*'.    "Importe mon doc
      TRANSFER bbseg TO fichero.
      PERFORM inicializa_jd USING bbseg.
    ENDIF.
  ENDIF.
ENDFORM.                    "CREA_CABECERA_BBSEG
*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BSELK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JUEGO_DATOS  text
*----------------------------------------------------------------------*
FORM crea_cabecera_bselk  USING    juego_datos.
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
  MOVE: '2'                   TO bselp-stype,
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
*  G_VALID_CTA = 0.
  CASE g_proceso.
    WHEN 'PRO_01'. " caducado electronico.
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
    WHEN 'PRO_02'. " caducado fisico
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

      IF g_cta EQ 8.
        g_valid_cta = 1.
      ENDIF.
    WHEN 'PRO_03'. " anulacion.
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

      IF g_cta EQ 8.
        g_valid_cta = 1.
      ENDIF.
    WHEN 'PRO_04'. " PREESCRIBIR.
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

      IF g_cta EQ 8.
        g_valid_cta = 1.
      ENDIF.
    WHEN 'PRO_05'. " REVALIDAR.
      IF g_cta EQ 0.
        g_valid_cta = 1.
      ENDIF.

      IF g_cta EQ 1.
        g_valid_cta = 1.
      ENDIF.

      IF g_cta EQ 2.
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

      IF g_cta EQ 8.
        g_valid_cta = 1.
      ENDIF.

      IF g_cta EQ 9.
        g_valid_cta = 1.
      ENDIF.
    WHEN 'PRO_06'. " REVALIDADO C/CHEQUE NUEVO
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

      IF g_cta EQ 8.
        g_valid_cta = 1.
      ENDIF.
    WHEN OTHERS.
      g_valid_cta = 0.
  ENDCASE.

ENDFORM.                    " VALID_CTA
*&---------------------------------------------------------------------*
*&      Form  GENE_TR_FCH9
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gene_tr_fch9 USING bukrs hbkid hktid .

  DATA: p_exist TYPE i.
  p_exist = 0.
  LOOP AT  t_ok.
* FCV - 22.04.2010
*    IF t_ok-status EQ '@08@' AND t_ok-chek1 EQ 'X'.
    IF t_ok-status EQ '@08@' AND t_ok-box EQ 'X'.
* fin FCV - 22.04.2010
      p_exist = 1.
      CLEAR bdcdata.
      REFRESH bdcdata.
      PERFORM bdc_dynpro      USING 'SAPMFCHK'    '0800'.
      PERFORM bdc_field       USING 'BDC_CURSOR'  'PAYR-VOIDR'.
      PERFORM bdc_field       USING 'BDC_OKCODE'  '=EDEL'.
      PERFORM bdc_field       USING 'PAYR-ZBUKR'  bukrs.
      PERFORM bdc_field       USING 'PAYR-HBKID'  hbkid.
      PERFORM bdc_field       USING 'PAYR-HKTID'  hktid.
      PERFORM bdc_field       USING 'PAYR-CHECT'  t_ok-chect.
      PERFORM bdc_field       USING 'PAYR-VOIDR'  '99'. " ANULACION DE CHEQUE

      DATA: p_motemis TYPE zzmot_emis. " motivo de emision para maternales
      DATA: ctumode LIKE ctu_params-dismode VALUE 'N'.
      DATA: cupdate LIKE ctu_params-updmode VALUE 'L'.
      DATA opt TYPE ctu_params.
      DATA w_rut LIKE lfa1-stcd1.
      opt-nobinpt = 'X'.
      opt-dismode = ctumode.
      opt-updmode = cupdate.

      CLEAR messtab.
      REFRESH messtab.

      CALL TRANSACTION 'FCH9' USING bdcdata
                        OPTIONS FROM opt
                       MESSAGES INTO messtab.


      READ TABLE messtab WITH KEY msgtyp = 'E'.

*Modificacion Anulacion de Cheques Herman Rosales
*Inicio
      IF sy-subrc NE 0.
        IF bukrs EQ 'CL01' OR bukrs EQ 'CL24'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE stcd1 INTO w_rut
*            FROM lfa1 CLIENT SPECIFIED
*            WHERE mandt EQ sy-mandt
*                  AND lifnr EQ t_ok-lifnr.
*
* NEW CODE
          SELECT stcd1
          UP TO 1 ROWS  INTO w_rut
            FROM lfa1 CLIENT SPECIFIED
            WHERE mandt EQ sy-mandt
                  AND lifnr EQ t_ok-lifnr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          CALL FUNCTION 'ZANULA_CHEQUES'
            EXPORTING
              vempresa                = bukrs
              vtipo                   = 'C'
              vnumero                 = t_ok-chect
              vctacte_sap             = t_ok-hkont
              vrol_beneficiario       = w_rut
              vctactecad_sap          = t_ok-hkont
              vfec_emision2           = t_ok-zaldt
              vfec_anula              = g_datum
*           IMPORTING
*             STATUS                  =
                    .
        ENDIF.
      ENDIF.
*Fin
*      LOOP AT MESSTAB  WHERE MSGTYP NE 'E'.
*        G_NEWBS = '31'.
*        PERFORM GENE_JUEGO_DATOS.
*      ENDLOOP.
    ENDIF.
  ENDLOOP.
  IF p_exist  = 1.
    g_newbs = '31'.
    PERFORM gene_juego_datos.
  ENDIF.

  IF save_code EQ 'PRO_03'. " anulacion
    CLEAR t_ok.
    REFRESH t_ok.
    PERFORM anulacion_indiv     TABLES psel
                                          t_ok
                                       USING bukrs hbkid hktid bkpf-budat.
* FCV - 06.08.2010
*    LOOP AT t_ok WHERE zmote = 'SUBMATERNA'. se cambia por consulta dinamica a tabla
    LOOP AT t_ok .
* 04042012 HCD
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE zzmot_emis
*      INTO  p_motemis
*      FROM  ztipchequemat
*      WHERE bukrs      EQ t_ok-bukrs
*      AND   zzmot_emis EQ t_ok-zmote.
*
* NEW CODE
      SELECT zzmot_emis
      UP TO 1 ROWS 
      INTO  p_motemis
      FROM  ztipchequemat
      WHERE bukrs      EQ t_ok-bukrs
      AND   zzmot_emis EQ t_ok-zmote ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* FIN 04042012 HCD
      IF sy-subrc = 0.
        v_puntero = sy-tabix.
        IF t_ok-estado = 'CHEQUE GIRADO'.
          MOVE '@08@'    TO t_ok-status. " ICONO BIEN
        ELSE.
          MOVE '@0A@'    TO t_ok-status. " ICONO MAL
        ENDIF.
        MODIFY t_ok INDEX v_puntero.
      ENDIF.

    ENDLOOP.
* fin FCV - 06.08.2010
  ENDIF.

  IF save_code EQ 'PRO_06'. " REVALIDAR CON CHEQUE NUEVO
    CLEAR t_ok.
    REFRESH t_ok.
    PERFORM revalidarchnew     TABLES psel
                                          t_ok
                                       USING bukrs hbkid hktid bkpf-budat.
    PERFORM reporte.

  ENDIF.

  DATA: BEGIN OF itlog OCCURS 0,
  texto(100),
  END OF itlog.

  DATA: v_texto LIKE t100-text,
  v_msgid LIKE sy-msgid,
  v_msgno LIKE sy-msgno,
  v_msgv1 LIKE sy-msgv1,
  v_msgv2 LIKE sy-msgv2,
  v_msgv3 LIKE sy-msgv3,
  v_msgv4 LIKE sy-msgv4.

  LOOP AT messtab WHERE msgid NE 'I'.

    v_msgid = messtab-msgid.
    v_msgno = messtab-msgnr.
    v_msgv1 = messtab-msgv1.
    v_msgv2 = messtab-msgv2.
    v_msgv3 = messtab-msgv3.
    v_msgv4 = messtab-msgv4.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE text
*      INTO  v_texto
*       FROM t100 WHERE sprsl = sy-langu
*                   AND arbgb = v_msgid
*                   AND msgnr = v_msgno.
*
* NEW CODE
    SELECT text
    UP TO 1 ROWS 
      INTO  v_texto
       FROM t100 WHERE sprsl = sy-langu
                   AND arbgb = v_msgid
                   AND msgnr = v_msgno ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      DATA:
         maximum_length TYPE i,
         hlp_text(100)  TYPE c,
         msgv_no(1)     TYPE c,
         offset         TYPE i,
         index          TYPE i,
         strl           LIKE sy-fdpos,
         p_fdpos        LIKE sy-fdpos.

      DESCRIBE FIELD v_texto LENGTH maximum_length IN CHARACTER MODE.
      hlp_text = v_texto.
      CLEAR v_texto.

      offset = 0.
      DO 4 TIMES.
        SEARCH hlp_text FOR '&'.
        IF sy-subrc <> 0. EXIT. ENDIF.
        IF sy-fdpos <> 0.
          CHECK offset < maximum_length.
          MOVE hlp_text(sy-fdpos) TO v_texto+offset.
          offset = offset + sy-fdpos.
        ENDIF.
        index = sy-fdpos + 1.
        SHIFT hlp_text BY index PLACES LEFT.
        p_fdpos  = sy-fdpos.
        IF hlp_text(1) CO '1234'.
          msgv_no = hlp_text(1).
          SHIFT hlp_text BY 1 PLACES LEFT.
        ELSE.
          msgv_no = sy-index.
        ENDIF.
        CHECK offset < maximum_length.
        CASE msgv_no.
          WHEN 1.
            WRITE v_msgv1 TO v_texto+offset LEFT-JUSTIFIED.
            strl = STRLEN( v_msgv1 ).

          WHEN 2.
            WRITE v_msgv2 TO v_texto+offset LEFT-JUSTIFIED.
            strl = STRLEN( v_msgv2 ).
          WHEN 3.
            WRITE v_msgv3 TO v_texto+offset LEFT-JUSTIFIED.
            strl = STRLEN( v_msgv3 ).
          WHEN 4.
            WRITE v_msgv4 TO v_texto+offset LEFT-JUSTIFIED.
            strl = STRLEN( v_msgv4 ).
        ENDCASE.
        offset = offset + strl.
      ENDDO.

      IF offset < maximum_length.
        sy-fdpos = STRLEN( hlp_text ).
        IF sy-fdpos <> 0.
          MOVE hlp_text(sy-fdpos) TO v_texto+offset.
        ENDIF.
      ENDIF.

      return-message_v1 = messtab-msgv1.
      return-message_v2 = v_texto+0(50).
      return-message_v3 = v_texto+50(13).

      return-type              = messtab-msgtyp.
      return-id                = '01'.
      APPEND return.
      CLEAR: return.
    ENDIF.
  ENDLOOP.

* chidalgo - Quintec 27.05.2010
* Agregar columna de juego de datos

  IF t_ok IS NOT INITIAL.
    LOOP AT t_ok.
      v_index = sy-tabix.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE jdatos lote INTO (t_ok-jdatos, t_ok-lote)
*        FROM zjdatos_edocheq
*        WHERE bukrs EQ bukrs AND
*              hbkid EQ hbkid AND
*              hktid EQ hktid AND
*              chect EQ t_ok-chect.
*
* NEW CODE
      SELECT jdatos lote
      UP TO 1 ROWS  INTO (t_ok-jdatos, t_ok-lote)
        FROM zjdatos_edocheq
        WHERE bukrs EQ bukrs AND
              hbkid EQ hbkid AND
              hktid EQ hktid AND
              chect EQ t_ok-chect ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      MODIFY t_ok TRANSPORTING jdatos.

* FCV - 07.08.2010 - Incorporar secuencia del Juego de Datos
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE secuencia INTO t_ok-secuencia
*        FROM zjdatos_secuen
** FCV - 05.09.2010 - Lotes
**        WHERE jdatos = t_ok-jdatos
*        WHERE jdatos = t_ok-lote
** fin FCV - 05.09.2010 - Lotes
*          AND bukrs EQ bukrs AND
*              hbkid EQ hbkid AND
*              hktid EQ hktid AND
*              chect EQ t_ok-chect.
*
* NEW CODE
      SELECT secuencia
      UP TO 1 ROWS  INTO t_ok-secuencia
        FROM zjdatos_secuen
* FCV - 05.09.2010 - Lotes
*        WHERE jdatos = t_ok-jdatos
        WHERE jdatos = t_ok-lote
* fin FCV - 05.09.2010 - Lotes
          AND bukrs EQ bukrs AND
              hbkid EQ hbkid AND
              hktid EQ hktid AND
              chect EQ t_ok-chect ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      MODIFY t_ok INDEX v_index.
* fin FCV - 07.08.2010 - Incorporar secuencia del Juego de Datos

    ENDLOOP.
  ENDIF.

* Fin modificación

ENDFORM.                    " GENE_TR_FCH9
*&---------------------------------------------------------------------*
*&      Form  VALID_FEC_CONT
*&---------------------------------------------------------------------*
*       VALIDA SI ES FECHA CONTABLE ABIERTA
*----------------------------------------------------------------------*
*      -->P_BUKRS         SOCIEDAD INGRESA EN PANTALLA
*      -->P_BKPF_BUDAT    FECHA INGRESADA
*      <--P_G_V_FEC_CONT  RETORNO DE FUNCIONALIDAD 1 validaciones basicas
*                                                  2 fecha contable no abierta
*----------------------------------------------------------------------*
FORM valid_fec_cont  USING    p_bukrs
                              p_bkpf_budat
                     CHANGING p_g_v_fec_cont
                              p_message.

  DATA : p_mes    TYPE t001b-frpe1,
         p_gjahr  TYPE t001b-frye1,
         t_e_oper	TYPE t001b-frpe1.

  CLEAR :p_message,p_g_v_fec_cont.

  IF p_bukrs IS INITIAL.
    p_g_v_fec_cont = 1.
    p_message = 'Error : Debe Ingresar Sociedad'.
    EXIT.
  ENDIF.

  IF p_bkpf_budat IS INITIAL.
    p_g_v_fec_cont = 1.
    p_message = 'Error : Debe Ingresar Fecha de Contabilización'.
    EXIT.
  ENDIF.

  p_gjahr = p_bkpf_budat+0(4).
  p_mes  = p_bkpf_budat+4(2).



  CALL FUNCTION 'FI_PERIOD_CHECK'
    EXPORTING
     i_bukrs                = p_bukrs
*   I_OPVAR                = ' '
      i_gjahr                = p_gjahr
      i_koart                = '+'
     i_konto                 = '+'
      i_monat                = p_mes
*   I_SPERI                =
*   I_RLDNR                =
*   I_GLVOR                = 'RFBU'
   IMPORTING
     e_oper                 = t_e_oper
   EXCEPTIONS
     error_period           = 1
     error_period_acc       = 2
     invalid_input          = 3
     OTHERS                 = 4
      .

  IF sy-subrc <> 0.
    p_g_v_fec_cont = 2.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.




ENDFORM.                    " VALID_FEC_CONT
*&---------------------------------------------------------------------*
*&      Form  MARCAR_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM marcar_all .

  IF t_ok[] IS NOT INITIAL.

    LOOP AT t_ok.
      IF t_ok-status EQ '@08@'.
* FCV - 22.04.2010
*        t_ok-chek1 = 'X'.
        t_ok-box = 'X'.
* fin FCV - 22.04.2010
        MODIFY t_ok INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " MARCAR_ALL
*&---------------------------------------------------------------------*
*&      Form  DESMARCA_MARCAR_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM desmarca_marcar_all .
  IF t_ok[] IS NOT INITIAL.

    LOOP AT t_ok WHERE chek1 = 'X'..
*          IF T_OK-STATUS EQ '@08@'.
* FCV - 22.04.2010
*      t_ok-chek1 = ' '.
      t_ok-box = ' '.
* fin FCV - 22.04.2010
      MODIFY t_ok INDEX sy-tabix.
*          ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " DESMARCA_MARCAR_ALL
*&---------------------------------------------------------------------*
*&      Form  CANT_REGISTROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cant_registros .
  DATA: t_reg TYPE i.
  DATA: s_reg(4) TYPE c.
  DATA :p_texto2(40) TYPE c.
  CLEAR p_texto2.
  IF t_ok[] IS NOT INITIAL.
    DESCRIBE TABLE t_ok LINES t_reg.
    s_reg = t_reg.
    SHIFT s_reg RIGHT DELETING TRAILING space.
    CONCATENATE 'Se Visualizan'  s_reg ' Registro(s).'   INTO p_texto2.
    MESSAGE p_texto2 TYPE 'S'.
  ENDIF.
ENDFORM.                    " CANT_REGISTROS
*&---------------------------------------------------------------------*
*&      Form  ARCHIVOS_MASIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM archivos_masivo.

  CALL TRANSACTION 'ZAL11' AND SKIP FIRST SCREEN.

ENDFORM.                    " ARCHIVOS_MASIVO

* FCV - 24.06.20100
*&---------------------------------------------------------------------*
*&      Form  ejecuta_submater
*&---------------------------------------------------------------------*
FORM ejecuta_submater USING juego_datos.
  DATA : p_bldat TYPE bldat,
         fecha_bldat(8),
         fecha_budat(8),
         c_mode VALUE 'N',
         v_monto(13),
         v_hora TYPE t.
  DATA: p_motemis TYPE zzmot_emis. " motivo de emision para maternales
  CONCATENATE sy-datum+6(2)
              sy-datum+4(2)
              sy-datum+0(4) INTO fecha_bldat.   " DDMMYYYY

  CONCATENATE p_budat+6(2)
              p_budat+4(2)
              p_budat+0(4) INTO fecha_budat.   " DDMMYYYY

  CLEAR: nro_secuencia, v_correlativo.
  REFRESH: t_ftpost.

  CLEAR v_hora.
  v_hora = sy-timlo.

  LOOP AT t_ok WHERE status EQ '@08@'
                 AND box EQ 'X'.
*                 AND zmote = 'SUBMATERNA'. elimino linea en duro para dejaro dinamico
* HCD 04042012
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zzmot_emis
*    INTO  p_motemis
*    FROM  ztipchequemat
*    WHERE bukrs      EQ t_ok-bukrs
*      AND zzmot_emis EQ t_ok-zmote.
*
* NEW CODE
    SELECT zzmot_emis
    UP TO 1 ROWS 
    INTO  p_motemis
    FROM  ztipchequemat
    WHERE bukrs      EQ t_ok-bukrs
      AND zzmot_emis EQ t_ok-zmote ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* FIN HCD 04042012
    IF sy-subrc = 0.
      v_correlativo = v_correlativo + 1.
      nro_secuencia = nro_secuencia + 1.
*    sy-uzeit = sy-uzeit + 1.

* Se le suma un segundo a la hora con la finalidad de no repetir nombre en el juego de datos
      CALL FUNCTION 'DIMP_ADD_TIME'
        EXPORTING
          iv_starttime = v_hora
          iv_startdate = sy-datum
          iv_addtime   = '000001'
        IMPORTING
          ev_endtime   = v_hora.

      CONCATENATE juego_datos sy-datum+6(2) sy-datum+4(2) v_hora(6) INTO juego_datos.

      CLEAR: v_xblnr, v_monto.
      WRITE t_ok-wrbtr TO v_monto CURRENCY 'CLP'.
      CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+2(2) v_hora+0(6) v_correlativo
                INTO v_xblnr.

      t_ftpost-stype = 'K'.
      t_ftpost-count = '1'.
      PERFORM carga_ftpost USING 'BKPF-BLDAT' fecha_budat.
      PERFORM carga_ftpost USING 'BKPF-BLART' 'ZA'.
      PERFORM carga_ftpost USING 'BKPF-BUKRS' t_ok-bukrs.
      PERFORM carga_ftpost USING 'BKPF-BUDAT' fecha_budat.
      PERFORM carga_ftpost USING 'BKPF-MONAT' fecha_budat+2(2).
      PERFORM carga_ftpost USING 'BKPF-WAERS' 'CLP'.
      PERFORM carga_ftpost USING 'BKPF-BKTXT' 'Cambio Estado Cheque'.
      PERFORM carga_ftpost USING 'BKPF-XBLNR' v_xblnr.
*    PERFORM carga_ftpost USING 'RF05A-NEWBS' '31'.
*    PERFORM carga_ftpost USING 'RF05A-NEWKO' t_ok-lifnr.

* ---  Posicion 1 ---
      t_ftpost-stype = 'P'.
      t_ftpost-count = '1'.
      PERFORM carga_ftpost USING 'RF05A-NEWBS' '31'.
      PERFORM carga_ftpost USING 'RF05A-NEWKO' t_ok-lifnr.
      PERFORM carga_ftpost USING 'BSEG-HKONT' '2011730013'.
      PERFORM carga_ftpost USING 'BSEG-WRBTR' v_monto.
      PERFORM carga_ftpost USING 'BSEG-ZTERM' 'ZC01'.
      PERFORM carga_ftpost USING 'BSEG-ZFBDT' fecha_bldat.
      PERFORM carga_ftpost USING 'BSEG-SGTXT' t_ok-sgtxt.
      PERFORM carga_ftpost USING 'BSEG-ZLSPR' 'A'.
      PERFORM carga_ftpost USING 'BSEG-ZLSCH' 'C'.
      PERFORM carga_ftpost USING 'BSEG-ZZMOT_EMIS' t_ok-zmote.
      PERFORM carga_ftpost USING 'BSEG-ZUONR' t_ok-chect.

* ---  Posicion 2 ---
      t_ftpost-stype = 'P'.
      t_ftpost-count = '2'.
      PERFORM carga_ftpost USING 'RF05A-NEWBS' '40'.
      PERFORM carga_ftpost USING 'RF05A-NEWKO' '1011970007'.
      PERFORM carga_ftpost USING 'BSEG-WRBTR' '*'.
      PERFORM carga_ftpost USING 'BSEG-SGTXT' t_ok-sgtxt.
      PERFORM carga_ftpost USING 'DKACB-FMORE' 'X'.

      grupo = juego_datos+0(12).
      CALL FUNCTION 'POSTING_INTERFACE_START'
        EXPORTING
          i_function = 'B'
          i_group    = grupo
          i_keep     = 'X'
          i_user     = sy-uname.

      CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
        EXPORTING
          i_auglv                    = 'UMBUCHNG'
          i_tcode                    = 'FB05'
        IMPORTING
          e_msgid                    = sy-msgid
          e_msgno                    = sy-msgno
          e_msgty                    = sy-msgty
          e_msgv1                    = sy-msgv1
          e_msgv2                    = sy-msgv2
          e_msgv3                    = sy-msgv3
          e_msgv4                    = sy-msgv4
          e_subrc                    = e_subrc
        TABLES
          t_blntab                   = t_blntab
          t_ftclear                  = t_ftclear
          t_ftpost                   = t_ftpost
          t_fttax                    = t_fttax
        EXCEPTIONS
          clearing_procedure_invalid = 1
          clearing_procedure_missing = 2
          table_t041a_empty          = 3
          transaction_code_invalid   = 4
          amount_format_error        = 5
          too_many_line_items        = 6
          company_code_invalid       = 7
          screen_not_found           = 8
          no_authorization           = 9
          OTHERS                     = 10.

      CALL FUNCTION 'POSTING_INTERFACE_END'
        EXPORTING
          i_bdcimmed = 'X'.

* Se actualiza nombre del juego de datos
      zjdatos_edocheq-bukrs  = bukrs.
      zjdatos_edocheq-hbkid  = hbkid.
      zjdatos_edocheq-hktid  = hktid.
      zjdatos_edocheq-chect  = t_ok-chect.
      zjdatos_edocheq-jdatos = grupo.
* FCV - 05.09.2010 - Lotes
      zjdatos_edocheq-lote = lote.
      zjdatos_edocheq-estado = 'P'.
      zjdatos_edocheq-fecha = sy-datum.
*    zjdatos_edocheq-ultimo_estado = t_ok-estado.
      TRANSLATE t_ok-estado TO UPPER CASE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE codigo INTO zjdatos_edocheq-ultimo_estado
*      FROM ztestadocheque
*        WHERE glosa = t_ok-estado.
*
* NEW CODE
      SELECT codigo
      UP TO 1 ROWS  INTO zjdatos_edocheq-ultimo_estado
      FROM ztestadocheque
        WHERE glosa = t_ok-estado ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      zjdatos_edocheq-secuencia = nro_secuencia.
* fin FCV - 05.09.2010 - Lotes
      MODIFY  zjdatos_edocheq.

* FCV - 07.08.2010 - Se inserta el Juego de datos y su secuencia respectiva
      CLEAR wa_secuen.
      wa_secuen-bukrs  = bukrs.
      wa_secuen-hbkid  = hbkid.
      wa_secuen-hktid  = hktid.
      wa_secuen-chect  = t_ok-chect.
* FCV - 05.09.2010 - Lotes
*    wa_secuen-jdatos = grupo.
      wa_secuen-jdatos = lote.
* fin FCV - 05.09.2010 - Lotes
      wa_secuen-secuencia = nro_secuencia.
      INSERT zjdatos_secuen FROM wa_secuen.
* fin FCV - 07.08.2010

      group = grupo.
      PERFORM parametros_jdatos.
* lanza el juego de datos.
*    SUBMIT zrsbdcsub  WITH SELECTION-TABLE i_tablsubm AND RETURN.
      SUBMIT zrsbdcsub  WITH SELECTION-TABLE i_tablsubm EXPORTING LIST TO MEMORY AND RETURN.

* FCV - 04.07.2010
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM zcambiocheque
*      WHERE zbukr = bukrs
*        AND hbkid = hbkid
*        AND hktid = hktid
*        AND rzawe = 'C'
*        AND chect = t_ok-chect
*        AND xblnr = v_xblnr.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM zcambiocheque
      WHERE zbukr = bukrs
        AND hbkid = hbkid
        AND hktid = hktid
        AND rzawe = 'C'
        AND chect = t_ok-chect
        AND xblnr = v_xblnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF sy-subrc NE 0.
        CLEAR wa_xblnr.
        wa_xblnr-zbukr = bukrs.
        wa_xblnr-hbkid = hbkid.
        wa_xblnr-hktid = hktid.
        wa_xblnr-rzawe = 'C'.
        wa_xblnr-chect = t_ok-chect.
        wa_xblnr-xblnr = v_xblnr.
        INSERT zcambiocheque FROM wa_xblnr.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ELSE.
        UPDATE zcambiocheque
        SET xblnr = v_xblnr
        WHERE zbukr = bukrs
          AND hbkid = hbkid
          AND hktid = hktid
          AND rzawe = 'C'
          AND chect = t_ok-chect.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
* fin valida si es tipo maternal 04042012
    ENDIF.
* fin FCV - 04.07.2010
  ENDLOOP.
ENDFORM.                    "ejecuta_submater
* fin FCV - 24.06.20101

*&---------------------------------------------------------------------*
*&      Module  REVISA_CHECK  OUTPUT
*&---------------------------------------------------------------------*
MODULE revisa_check OUTPUT.
  IF v_check = 'X'.
    LOOP AT SCREEN.
      IF screen-name = 'BSAK-ZZ_AGENCIA'.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    CLEAR bsak-zz_agencia.
    LOOP AT SCREEN.
      IF screen-name = 'BSAK-ZZ_AGENCIA'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " REVISA_CHECK  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  IF sy-ucomm = 'CANCEL'.
    fechacontab = '00000000'.
    v_agencia = ' '.
    sy-subrc = '1'.
    SET SCREEN 0.
  ELSEIF sy-ucomm = 'GRABAR'.
    IF v_check = 'X'.
      IF bsak-zz_agencia IS INITIAL.
        MESSAGE 'Debe ingresar agencia.' TYPE 'I'.
      ELSE.
        fechacontab = bkpf-budat.
        v_agencia = bsak-zz_agencia.
        SET SCREEN 0.
      ENDIF.
    ELSE.
      fechacontab = bkpf-budat.
      v_agencia = bsak-zz_agencia.
      SET SCREEN 0.
    ENDIF.
  ENDIF.
  v_primeravez = 'X'.
ENDMODULE.                 " USER_COMMAND_0200  INPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'ST0200'.
  IF v_primeravez = ' '.
    CLEAR: bkpf-budat, bsak-zz_agencia.
  ENDIF.
*  SET TITLEBAR ''.
ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  rescata_agencia
*&---------------------------------------------------------------------*
FORM rescata_agencia.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM payr
*    WHERE zbukr = bukrs
*      AND hbkid = hbkid
*      AND hktid = hktid
*      AND chect = t_ok-chect.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM payr
    WHERE zbukr = bukrs
      AND hbkid = hbkid
      AND hktid = hktid
      AND chect = t_ok-chect ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zz_agencia INTO t_ok-zagencia
*      FROM bsak
*      WHERE bukrs = bukrs
*        AND lifnr = t_ok-lifnr
*        AND augbl = payr-vblnr
*        AND belnr <> t_ok-vblnr.
*
* NEW CODE
    SELECT zz_agencia
    UP TO 1 ROWS  INTO t_ok-zagencia
      FROM bsak
      WHERE bukrs = bukrs
        AND lifnr = t_ok-lifnr
        AND augbl = payr-vblnr
        AND belnr <> t_ok-vblnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc  EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE zzdescr INTO t_ok-zzdescr
*        FROM zagencia
*        WHERE bukrs = bukrs
*          AND zzcod_unidad = t_ok-zagencia.
*
* NEW CODE
      SELECT zzdescr
      UP TO 1 ROWS  INTO t_ok-zzdescr
        FROM zagencia
        WHERE bukrs = bukrs
          AND zzcod_unidad = t_ok-zagencia ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* FCV - 01.08.2010
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = t_ok-zagencia
        IMPORTING
          output = t_ok-zagencia.
* fin FCV - 01.08.2010

      MODIFY t_ok INDEX v_puntero.
    ENDIF.
  ENDIF.
ENDFORM.                    "rescata_agencia
*&---------------------------------------------------------------------*
*&      Form  BATCH_INPUT_INTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JUEGO_DATOS  text
*----------------------------------------------------------------------*
FORM batch_input_inter  USING    fichero.


  DATA :  p_bldat TYPE bldat.
  DATA :  g_wrbtr(10),
          g_wrbtri TYPE p DECIMALS 0.



  MOVE: '1'                   TO bbkpf-stype,
        'FB05'                TO bbkpf-tcode,    "Cod. transaccion
        'ZA'                  TO bbkpf-blart,    "Clase documento
         bukrs_aux            TO bbkpf-bukrs,    "Sociedad
         bkpf-budat+4(2)      TO bbkpf-monat,    "Mes contable
        'CLP'                 TO bbkpf-waers,    "Moneda
  'Cambio Estado Cheque'      TO bbkpf-bktxt.    "Texto Cab.Docto

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE  bldat INTO p_bldat
*    FROM  bkpf
*   WHERE  bukrs EQ t_ok-bukrs
*     AND  belnr EQ t_ok-vblnr
*     AND  gjahr EQ t_ok-gjahr.
*
* NEW CODE
  SELECT bldat
  UP TO 1 ROWS  INTO p_bldat
    FROM  bkpf
   WHERE  bukrs EQ t_ok-bukrs
     AND  belnr EQ t_ok-vblnr
     AND  gjahr EQ t_ok-gjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc EQ 0.
    CONCATENATE p_bldat+6(2)
                p_bldat+4(2)
                p_bldat+0(4) INTO bbkpf-bldat.
  ELSE.
    CONCATENATE bkpf-budat+6(2)
                bkpf-budat+4(2)
                bkpf-budat+0(4) INTO bbkpf-bldat.
  ENDIF.

  IF t_ok-datev < 0.
    CONCATENATE t_ok-bldat+6(2)
                t_ok-bldat+4(2)
                t_ok-bldat+0(4) INTO bbkpf-budat.
  ELSE.
    CONCATENATE bkpf-budat+6(2)
                bkpf-budat+4(2)
                bkpf-budat+0(4) INTO bbkpf-budat.

  ENDIF.
*********************************
* FCV - 17.06.2010
*********************************

  IF t_ok-estado = 'REVALIDADO'.
* Se rescata la fecha contable del documento que revalidó
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM bkpf
*    WHERE bukrs =  t_ok-bukrs
*      AND belnr =  t_ok-belnr
*      AND gjahr =  t_ok-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM bkpf
    WHERE bukrs =  t_ok-bukrs
      AND belnr =  t_ok-belnr
      AND gjahr =  t_ok-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc EQ 0.
      CONCATENATE bkpf-budat+6(2) bkpf-budat+4(2) bkpf-budat+0(4) INTO bbkpf-bldat.
    ENDIF.
  ENDIF.

  bbkpf-auglv = 'UMBUCHNG'.
  bbkpf-docid   = '*'.
  MOVE '1'    TO bbkpf-kursf.

  CLEAR v_xblnr.
  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+2(2) sy-uzeit(6) v_correlativo
              INTO v_xblnr.
  bbkpf-xblnr = v_xblnr.

*        TRANSFER bbkpf TO fichero.

  zjdatos_edocheq-bukrs  = bukrs.
  zjdatos_edocheq-hbkid  = hbkid.
  zjdatos_edocheq-hktid  = hktid.
  zjdatos_edocheq-chect  = t_ok-chect.
  zjdatos_edocheq-jdatos = group.
  zjdatos_edocheq-lote = lote.
  zjdatos_edocheq-estado = 'P'.
  zjdatos_edocheq-fecha = sy-datum.
  TRANSLATE t_ok-estado TO UPPER CASE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE codigo INTO zjdatos_edocheq-ultimo_estado
*  FROM ztestadocheque
*    WHERE glosa = t_ok-estado.
*
* NEW CODE
  SELECT codigo
  UP TO 1 ROWS  INTO zjdatos_edocheq-ultimo_estado
  FROM ztestadocheque
    WHERE glosa = t_ok-estado ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
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
    IF g_newbs EQ '31' .
      MOVE 'A'                 TO bbseg-zlspr.    "ANULACION DE DOCUMENTO
    ENDIF.
    MOVE: t_ok-lifnr          TO bbseg-newko.    "Cuenta
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM bseg
*    WHERE bukrs =  t_ok-bukrs
*      AND belnr =  t_ok-vblnr
*      AND gjahr =  t_ok-gjahr
*      AND shkzg = 'S'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM bseg
    WHERE bukrs =  t_ok-bukrs
      AND belnr =  t_ok-vblnr
      AND gjahr =  t_ok-gjahr
      AND shkzg = 'S' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc EQ 0.
    MOVE: hkont_aux TO bbseg-hkont,    "Cuenta
         '31' TO bbseg-newbs.          " Clave contabilizaciòn

  ENDIF.

  MOVE t_ok-zagencia TO bbseg-zz_agencia.
  bbseg-hbkid = payr-hbkid.  " Banco propio
  bbseg-zterm = 'ZC01'.      " Condición de pago
  bbseg-zlsch = 'C'.         " Vía de pago



* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM payr
*     WHERE zbukr = bukrs
*       AND hbkid = hbkid
*       AND hktid = hktid
*       AND chect = t_ok-chect.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM payr
     WHERE zbukr = bukrs
       AND hbkid = hbkid
       AND hktid = hktid
       AND chect = t_ok-chect ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
*  IF sy-subrc EQ 0.
*    SELECT SINGLE * FROM bsak
*      WHERE bukrs = bukrs_aux
*        AND lifnr = payr-lifnr
*        AND augbl = payr-vblnr
*        AND belnr <> payr-vblnr.
*
*    IF sy-subrc EQ 0.
*      bbseg-hbkid = payr-hbkid.   " Banco propio
*      bbseg-zterm = bsak-zterm.   " Condición de pago
*      bbseg-zlsch = bsak-zlsch.   " Vía de pago
*      bbseg-xref1 = bsak-xref1.   " Clave referencia 1
*      IF t_ok-zagencia IS INITIAL.
*        MOVE bsak-zz_agencia TO bbseg-zz_agencia.
*      ELSE.
*        MOVE t_ok-zagencia TO bbseg-zz_agencia.
*      ENDIF.
*    ENDIF.
*
*  ENDIF.

  CLEAR agencia_aux.

  IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  * FROM  regup WHERE laufd = payr-laufd
*                                 AND   laufi = payr-laufi
*                                 AND   xvorl = ''
*                                 AND   zbukr = payr-zbukr
*                                 AND   lifnr = payr-lifnr
*                                 AND   kunnr = payr-kunnr
*                                 AND   empfg = payr-empfg
*                                 AND   vblnr = payr-vblnr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  regup WHERE laufd = payr-laufd
                                 AND   laufi = payr-laufi
                                 AND   xvorl = ''
                                 AND   zbukr = payr-zbukr
                                 AND   lifnr = payr-lifnr
                                 AND   kunnr = payr-kunnr
                                 AND   empfg = payr-empfg
                                 AND   vblnr = payr-vblnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
*                             AND  belnr = regup-belnr
*                             AND  gjahr = regup-gjahr
*                             AND  buzei = regup-buzei.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM  bseg WHERE bukrs  = regup-bukrs
                             AND  belnr = regup-belnr
                             AND  gjahr = regup-gjahr
                             AND  buzei = regup-buzei ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc EQ 0.
        MOVE bseg-zz_agencia TO agencia_aux.
        MOVE bseg-zzmot_emis TO bbseg-zzmot_emis.
      ENDIF.
    ENDIF.
  ENDIF.





  CONCATENATE  agencia_aux '00000000' INTO  bbseg-xref1.


  MOVE: g_wrbtri              TO bbseg-wrbtr,    "Importe mon doc
      t_ok-sgtxt              TO bbseg-sgtxt.


  IF t_ok-chect IS NOT INITIAL.
    MOVE t_ok-chect            TO bbseg-zuonr.    "ASIGNACION
  ENDIF.

  MOVE  t_ok-zmote              TO bbseg-zzmot_emis.


  CONCATENATE bkpf-budat+6(2)
           bkpf-budat+4(2)
           bkpf-budat+0(4) INTO bbseg-valut.



* TRANSFER bbseg TO fichero.

  PERFORM genero_batch_input_inter USING    fichero.


  PERFORM inicializa_jd USING bbkpf.
  PERFORM inicializa_jd USING bbseg.

ENDFORM.                    " BATCH_INPUT_INTER
*&---------------------------------------------------------------------*
*&      Form  GENERO_BATCH_INPUT_INTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM genero_batch_input_inter USING    fichero.
  DATA :group LIKE apqi-groupid.
  group = fichero.
  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      client = sy-mandt
      group  = group
      user   = sy-uname
      keep   = 'X'.

  REFRESH bdcdata.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0122'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWKO'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BKPF-BLDAT'
                                bbkpf-bldat.
  PERFORM bdc_field       USING 'BKPF-BLART'
                                bbkpf-blart.
  PERFORM bdc_field       USING 'BKPF-BUKRS'
                                bbkpf-bukrs.
  PERFORM bdc_field       USING 'BKPF-BUDAT'
                                bbkpf-budat.
  PERFORM bdc_field       USING 'BKPF-WAERS'
                                bbkpf-waers.
  PERFORM bdc_field       USING 'BKPF-XBLNR'
                                bbkpf-xblnr.
  PERFORM bdc_field       USING 'BKPF-BKTXT'
                                bbkpf-bktxt.

  PERFORM bdc_field       USING 'FS006-DOCID'
                                '*'.
  PERFORM bdc_field       USING 'RF05A-NEWBS'
                                bbseg-newbs.
  PERFORM bdc_field       USING 'RF05A-NEWKO'
                                bbseg-newko.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0302'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BSEG-ZZMOT_EMIS'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ZK'.

  PERFORM bdc_field       USING 'BSEG-HKONT'
                                bbseg-hkont.

  PERFORM bdc_field       USING 'BSEG-WRBTR'
                                bbseg-wrbtr.

  PERFORM bdc_field       USING 'BSEG-ZTERM'
                                bbseg-zterm.

  PERFORM bdc_field       USING 'BSEG-ZFBDT'
                                bbseg-valut.

  PERFORM bdc_field       USING 'BSEG-ZLSPR'
                                bbseg-zlspr.

  PERFORM bdc_field       USING 'BSEG-ZUONR'
                                bbseg-zuonr.


  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                bbseg-sgtxt.

  PERFORM bdc_field       USING 'BSEG-ZZMOT_EMIS'
                                bbseg-zzmot_emis.


  PERFORM bdc_dynpro      USING 'SAPMF05A' '0332'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BSEG-HBKID'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SL'.
  PERFORM bdc_field       USING 'BSEG-XREF1'
                                bbseg-xref1.
  PERFORM bdc_field       USING 'BSEG-HBKID'
                                bbseg-hbkid.
  PERFORM bdc_field       USING 'BSEG-ZZ_AGENCIA'
                                agencia_aux.
  PERFORM bdc_field       USING 'BSEG-ZZ_AGENCIA'
                                agencia_aux.



  PERFORM bdc_dynpro      USING 'SAPMF05A' '0710'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-AGKOA'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SLB'.

  PERFORM bdc_field       USING 'RF05A-AGBUK'
                                 t_ok-bukrs.
  PERFORM bdc_field       USING 'RF05A-AGKON'
                                 t_ok-hkont.
  PERFORM bdc_field       USING 'RF05A-AGKOA'
                                 'S'.
  PERFORM bdc_field       USING 'RF05A-XNOPS'
                                 'X'.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0733'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-SEL01(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BU'.

  PERFORM bdc_field       USING 'RF05A-FELDN(01)'
                                 'BELNR'.
  CONCATENATE t_ok-belnr t_ok-gjahr t_ok-buzei INTO bselp-slvon_1.

  PERFORM bdc_field       USING 'RF05A-SEL01(01)'
                                 bselp-slvon_1.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0701'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-AZEI1(03)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=PI'.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0301'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BSEG-SGTXT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=AB'.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                                 t_ok-chect.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                 bbseg-sgtxt.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0701'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-AZEI1(04)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=PI'.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0302'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'BSEG-SGTXT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM bdc_field       USING 'BSEG-ZUONR'
                                 t_ok-chect.
  PERFORM bdc_field       USING 'BSEG-SGTXT'
                                 bbseg-sgtxt.

  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'FB05'
    TABLES
      dynprotab = bdcdata.

  PERFORM close_group USING ' '.

ENDFORM.                    " GENERO_BATCH_INPUT_INTER

*&---------------------------------------------------------------------*
*&      Form  CONSULTAS
*&---------------------------------------------------------------------*
FORM CONSULTAS .

  " Select 1
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT bukrs  hbkid hktid chect jdatos  lote
*          FROM zjdatos_edocheq
*          INTO TABLE GT_JDATOS "(t_ok-jdatos, t_ok-lote)
*          FOR ALL ENTRIES IN T_OK
*          WHERE bukrs EQ bukrs AND
*                hbkid EQ hbkid AND
*                hktid EQ hktid AND
*                chect EQ t_ok-chect.
*
* NEW CODE
        SELECT bukrs  hbkid hktid chect jdatos  lote

          FROM zjdatos_edocheq
          INTO TABLE GT_JDATOS "(t_ok-jdatos, t_ok-lote)
          FOR ALL ENTRIES IN T_OK
          WHERE bukrs EQ bukrs AND
                hbkid EQ hbkid AND
                hktid EQ hktid AND
                chect EQ t_ok-chect ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  " Select 2
*       SELECT zbukr  hbkid hktid chect lifnr vblnr
*         FROM payr
*         INTO TABLE T_PAYR
*          FOR ALL ENTRIES IN T_OK
*        WHERE zbukr EQ bukrs AND
*              hbkid EQ hbkid AND
*              hktid EQ hktid AND
*              chect EQ t_ok-chect.
    " Select 3
*         SELECT bukrs  belnr gjahr budat xblnr
*          FROM bkpf
*           INTO TABLE gt_bkpf
*          WHERE bukrs = bukrs
*            AND gjahr = t_ok-gjahr
*            AND xblnr = zcambiocheque-xblnr.
     " Select 4
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT  jdatos secuencia bukrs hbkid hktid chect
*        FROM zjdatos_secuen
*        INTO TABLE gt_secuen
*        FOR ALL ENTRIES IN t_ok
*        WHERE jdatos EQ t_ok-lote AND
*              bukrs  EQ bukrs AND
*              hbkid  EQ hbkid AND
*              hktid  EQ hktid AND
*              chect  EQ t_ok-chect.
*
* NEW CODE
      SELECT jdatos secuencia bukrs hbkid hktid chect

        FROM zjdatos_secuen
        INTO TABLE gt_secuen
        FOR ALL ENTRIES IN t_ok
        WHERE jdatos EQ t_ok-lote AND
              bukrs  EQ bukrs AND
              hbkid  EQ hbkid AND
              hktid  EQ hktid AND
              chect  EQ t_ok-chect ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    " Select 4
*     SELECT lifnr sortl
*       FROM lfa1
*       INTO TABLE gt_lfa1
*      FOR ALL ENTRIES IN t_payr
*        WHERE lifnr EQ t_payr-lifnr.



ENDFORM.                    " CONSULTAS
