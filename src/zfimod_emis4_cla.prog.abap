*&---------------------------------------------------------------------*
*&  Include           ZFIMOD_EMIS4_CLA
*&---------------------------------------------------------------------*

CLASS lcl_motor DEFINITION.

  PUBLIC SECTION.

    TYPES: BEGIN OF gty_zp,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
             buzei TYPE buzei,
           END OF gty_zp,

           BEGIN OF gty_bsas,
             bukrs TYPE bukrs,
             augbl TYPE augbl,
             blart TYPE blart,
             gjahr TYPE gjahr,
             belnr TYPE belnr_d,
             buzei TYPE buzei,
             augdt TYPE augdt,
             budat TYPE budat,
             auggj TYPE auggj,
           END OF gty_bsas,

           BEGIN OF gty_log,
             bukrs      TYPE bukrs,
             belnr      TYPE belnr_d,
             gjahr      TYPE gjahr,
             bukrs_zp   TYPE bukrs,
             belnr_zp   TYPE belnr_d,
             gjahr_zp   TYPE gjahr,
             zzmot_emis TYPE zzmot_emis,
             logtx      TYPE text50,
           END OF gty_log.

    TYPES: gtt_bsas TYPE STANDARD TABLE OF gty_bsas,
           gtt_log  TYPE STANDARD TABLE OF gty_log.

    DATA: gt_log TYPE gtt_log.

    METHODS:
      get_docs EXPORTING et_bkpf TYPE gtt_bkpf
                         et_bseg TYPE gtt_bseg,

      process_docs IMPORTING it_bkpf TYPE gtt_bkpf
                             it_bseg TYPE gtt_bseg,

      show_log.

  PRIVATE SECTION.
    METHODS:
      get_docs_zp IMPORTING is_bkpf TYPE bkpf
                            it_bsas TYPE gtt_bsas
                  EXPORTING es_zp   TYPE gty_zp,

      update_doc IMPORTING is_bkpf     TYPE bkpf
                           it_bseg     TYPE gtt_bseg
                           iv_mot_emis TYPE zzmot_emis
                 CHANGING  cv_logtx    TYPE text50,

      get_zp IMPORTING iv_bukrs TYPE bukrs
                       iv_belnr TYPE belnr_d
                       iv_gjahr TYPE gjahr
             EXPORTING ev_blart TYPE blart
                       ev_bukrs TYPE bukrs
                       ev_belnr TYPE belnr_d
                       ev_gjahr TYPE gjahr
                       ev_buzei TYPE buzei.

ENDCLASS.


CLASS lcl_motor IMPLEMENTATION.

  METHOD get_docs.
*<- et_bkpf  TYPE gty_bkpf
*<- et_bseg  TYPE gty_bseg

*   Se necesitan todos los campos para la función de UPDATE del documento
    SELECT FROM bkpf
      FIELDS *
      WHERE bukrs IN @s_bukr
        AND belnr IN @s_beln
        AND blart IN @s_blar
        AND cpudt IN @s_cpud
        AND stblg  = @space
      INTO TABLE @DATA(lt_bkpf).

    IF lt_bkpf[] IS INITIAL.
      RETURN.
    ENDIF.

    SORT lt_bkpf BY bukrs belnr gjahr.

*   Posiciones asociadas
    SELECT FROM bseg FIELDS *
      FOR ALL ENTRIES IN @lt_bkpf
      WHERE bukrs = @lt_bkpf-bukrs
        AND belnr = @lt_bkpf-belnr
        AND gjahr = @lt_bkpf-gjahr
      INTO TABLE @DATA(lt_bseg).

    IF lt_bseg[] IS INITIAL.
      RETURN.
    ENDIF.

    SORT: lt_bkpf BY bukrs belnr gjahr,
          lt_bseg BY bukrs belnr gjahr.

*   Determinar posiciones con motivos de emisión vacíos
    LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<ls_bseg>) WHERE zzmot_emis IS INITIAL.
      APPEND INITIAL LINE TO et_bseg ASSIGNING FIELD-SYMBOL(<ls_bseg_out>).
      <ls_bseg_out> = <ls_bseg>.
    ENDLOOP.

    CHECK NOT et_bseg[] IS INITIAL.

*   Determinar las cabeceras de documentos correspondientes
    LOOP AT et_bseg ASSIGNING <ls_bseg_out>.
      READ TABLE lt_bkpf ASSIGNING FIELD-SYMBOL(<ls_bkpf>)
        WITH KEY bukrs = <ls_bseg_out>-bukrs
                 belnr = <ls_bseg_out>-belnr
                 gjahr = <ls_bseg_out>-gjahr BINARY SEARCH.
      IF sy-subrc = 0.
        APPEND INITIAL LINE TO et_bkpf ASSIGNING FIELD-SYMBOL(<ls_bkpf_out>).
        <ls_bkpf_out> = <ls_bkpf>.
      ENDIF.
    ENDLOOP.

*   Finalmente se dejan bien armadas las tablas de salida
    SORT et_bkpf BY bukrs belnr gjahr.
    DELETE ADJACENT DUPLICATES FROM et_bkpf COMPARING bukrs belnr gjahr.

    CLEAR: et_bseg[].

    LOOP AT et_bkpf ASSIGNING <ls_bkpf>.

      LOOP AT lt_bseg ASSIGNING <ls_bseg> WHERE bukrs = <ls_bkpf>-bukrs
                                            AND belnr = <ls_bkpf>-belnr
                                            AND gjahr = <ls_bkpf>-gjahr.
        APPEND INITIAL LINE TO et_bseg ASSIGNING <ls_bseg_out>.
        <ls_bseg_out> = <ls_bseg>.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD process_docs.
*-> it_bkpf TYPE gtt_bkpf
*-> it_bseg TYPE gtt_bseg
    DATA: ls_zp TYPE gty_zp.

    DATA: lt_bsas TYPE gtt_bsas,
          lt_bseg TYPE gtt_bseg.

    DATA: lv_mot_emis TYPE zzmot_emis.

    CHECK NOT it_bkpf[] IS INITIAL.

    CLEAR: gt_log.

*   Busca todos los documentos de compensación asociados con su clase de documento
    SELECT FROM bsas
      FIELDS bukrs, augbl, blart, gjahr, belnr, buzei, augdt, budat, auggj
      FOR ALL ENTRIES IN @it_bkpf
      WHERE bukrs = @it_bkpf-bukrs
        AND augbl = @it_bkpf-belnr
        AND auggj = @it_bkpf-gjahr
      INTO TABLE @lt_bsas.


*** Recorre uno a uno los documentos ZA
    LOOP AT it_bkpf ASSIGNING FIELD-SYMBOL(<ls_bkpf>).
      CLEAR: lv_mot_emis, ls_zp.
      SORT lt_bsas BY bukrs augbl auggj blart.

*     Busca el documento ZP de compensación
      get_docs_zp( EXPORTING is_bkpf = <ls_bkpf>
                             it_bsas = lt_bsas
                   IMPORTING es_zp   = ls_zp
      ).

      IF ls_zp IS INITIAL.
        APPEND INITIAL LINE TO gt_log ASSIGNING FIELD-SYMBOL(<ls_log>).
        <ls_log>-bukrs      = <ls_bkpf>-bukrs.
        <ls_log>-belnr      = <ls_bkpf>-belnr.
        <ls_log>-gjahr      = <ls_bkpf>-gjahr.
        <ls_log>-bukrs_zp   = ''.
        <ls_log>-belnr_zp   = ''.
        <ls_log>-gjahr_zp   = ''.
        <ls_log>-zzmot_emis = ''.
        <ls_log>-logtx      = TEXT-l01.  "No se encontró documento ZP asociado.
        CONTINUE.
      ENDIF.

*     Determinar motivo de emisión
      SELECT SINGLE FROM bseg FIELDS zzmot_emis
        WHERE bukrs = @ls_zp-bukrs
          AND belnr = @ls_zp-belnr
          AND gjahr = @ls_zp-gjahr
          "AND buzei = ls_zp-buzei
          AND zzmot_emis <> ''
        INTO @lv_mot_emis.

      APPEND INITIAL LINE TO gt_log ASSIGNING <ls_log>.
      <ls_log>-bukrs      = <ls_bkpf>-bukrs.
      <ls_log>-belnr      = <ls_bkpf>-belnr.
      <ls_log>-gjahr      = <ls_bkpf>-gjahr.
      <ls_log>-bukrs_zp   = ls_zp-bukrs.
      <ls_log>-belnr_zp   = ls_zp-belnr.
      <ls_log>-gjahr_zp   = ls_zp-gjahr.

      IF lv_mot_emis IS INITIAL.
        <ls_log>-zzmot_emis = lv_mot_emis.
        <ls_log>-logtx      = TEXT-l02.  "Motivo de emisión vacío
        CONTINUE.
      ELSE.
        <ls_log>-zzmot_emis = lv_mot_emis.
      ENDIF.

      CLEAR: lt_bseg.

      lt_bseg = VALUE #( FOR ls_bseg IN it_bseg
                             WHERE ( bukrs = <ls_bkpf>-bukrs AND
                                     belnr = <ls_bkpf>-belnr AND
                                     gjahr = <ls_bkpf>-gjahr  ) ( ls_bseg ) ).

      update_doc( EXPORTING is_bkpf     = <ls_bkpf>
                            it_bseg     = lt_bseg
                            iv_mot_emis = lv_mot_emis
                  CHANGING  cv_logtx    = <ls_log>-logtx
                ).

    ENDLOOP.
****

  ENDMETHOD.

  METHOD get_docs_zp.
*-> is_bkpf TYPE bkpf
*-> it_bsas TYPE gtt_bsas
*<- es_zp   TYPE gty_zp

    DATA: lt_bsas_x TYPE gtt_bsas.

    DATA: lv_blart    TYPE blart,
          lv_bukrs    TYPE bukrs,
          lv_belnr    TYPE belnr_d,
          lv_gjahr    TYPE gjahr,
          lv_buzei    TYPE buzei,
          lv_bukrs_za TYPE bukrs,
          lv_belnr_za TYPE belnr_d,
          lv_gjahr_za TYPE gjahr.

*   Revisa si hay ZP en algún documento de compensación
    READ TABLE it_bsas ASSIGNING FIELD-SYMBOL(<ls_bsas>)
      WITH KEY bukrs = is_bkpf-bukrs
               augbl = is_bkpf-belnr
               auggj = is_bkpf-gjahr
               blart = 'ZP' BINARY SEARCH.

    IF sy-subrc = 0.
      es_zp-bukrs = <ls_bsas>-bukrs.
      es_zp-belnr = <ls_bsas>-belnr.
      es_zp-gjahr = <ls_bsas>-gjahr.
      es_zp-buzei = <ls_bsas>-buzei.
      RETURN.
    ENDIF.

*   Si no tiene ZP se busca ZA
    LOOP AT it_bsas ASSIGNING <ls_bsas> WHERE bukrs  = is_bkpf-bukrs AND
                                              augbl  = is_bkpf-belnr AND
                                              blart  = 'ZA'          AND
                                              belnr <> is_bkpf-belnr.


      get_zp( EXPORTING iv_bukrs = <ls_bsas>-bukrs
                        iv_belnr = <ls_bsas>-belnr
                        iv_gjahr = <ls_bsas>-gjahr
              IMPORTING ev_blart = lv_blart
                        ev_bukrs = lv_bukrs
                        ev_belnr = lv_belnr
                        ev_gjahr = lv_gjahr
                        ev_buzei = lv_buzei
             ).

      IF lv_blart = 'ZP'.
        es_zp-bukrs = lv_bukrs.
        es_zp-belnr = lv_belnr.
        es_zp-gjahr = lv_gjahr.
        es_zp-buzei = lv_buzei.
        EXIT.
      ENDIF.

    ENDLOOP.

    CHECK es_zp IS INITIAL.

    DO 5 TIMES.
      IF lv_blart = 'ZA'.
        lv_bukrs_za = lv_bukrs.
        lv_belnr_za = lv_belnr.
        lv_gjahr_za = lv_gjahr.

        get_zp( EXPORTING iv_bukrs = lv_bukrs_za
                          iv_belnr = lv_belnr_za
                          iv_gjahr = lv_gjahr_za
                IMPORTING ev_blart = lv_blart
                          ev_bukrs = lv_bukrs
                          ev_belnr = lv_belnr
                          ev_gjahr = lv_gjahr
                          ev_buzei = lv_buzei
               ).

        IF lv_blart = 'ZP'.
          es_zp-bukrs = lv_bukrs.
          es_zp-belnr = lv_belnr.
          es_zp-gjahr = lv_gjahr.
          es_zp-buzei = lv_buzei.
          EXIT.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.

  METHOD update_doc.
*->  is_bkpf     TYPE bkpf
*->  it_bseg     TYPE gtt_bseg
*->  iv_mot_emis TYPE zzmot_emis
*<-> cv_logtx    TYPE text50

    DATA: lt_bkdf   TYPE STANDARD TABLE OF bkdf,
          lt_bkpf   TYPE STANDARD TABLE OF bkpf,
          lt_bseg   TYPE STANDARD TABLE OF bseg,
          lt_bsec   TYPE STANDARD TABLE OF bsec,
          lt_bsed   TYPE STANDARD TABLE OF bsed,
          lt_bset   TYPE STANDARD TABLE OF bset,
          lt_update TYPE STANDARD TABLE OF protocol_line.

    DATA: lv_noprot  TYPE c VALUE 'X',
          lv_ptype   TYPE c,
          lv_pageend TYPE c VALUE 'X'.

    CLEAR: xbseg, ybseg, *bkpf, bkpf.
    REFRESH: xbseg, ybseg.

    APPEND INITIAL LINE TO lt_bkpf ASSIGNING FIELD-SYMBOL(<ls_bkpf>).
    <ls_bkpf> = is_bkpf.

    LOOP AT it_bseg ASSIGNING FIELD-SYMBOL(<ls_bseg>).
*     Table with the OLD content of: BSEG
      APPEND INITIAL LINE TO ybseg ASSIGNING FIELD-SYMBOL(<ls_ybseg>).
      MOVE-CORRESPONDING <ls_bseg> TO <ls_ybseg>.

*     Actualiza motivo de emisión
      APPEND INITIAL LINE TO lt_bseg ASSIGNING FIELD-SYMBOL(<ls_bseg_n>).
      <ls_bseg_n> = <ls_bseg>.
      <ls_bseg_n>-zzmot_emis = iv_mot_emis.

*     Table with the NEW content of: BSEG
      APPEND INITIAL LINE TO xbseg ASSIGNING FIELD-SYMBOL(<ls_xbseg>).
      MOVE-CORRESPONDING <ls_bseg_n> TO <ls_xbseg>.

*     Tabla de protocolo de salida
      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
      MOVE-CORRESPONDING <ls_bseg_n> TO <ls_update>.
    ENDLOOP.

*   Para registro de modificación
    upd_bseg = 'U'.

    *bkpf    = is_bkpf.
    bkpf     = is_bkpf.
    upd_bkpf = 'U'.

*   Document update
    CALL FUNCTION 'CHANGE_DOCUMENT'
      TABLES
        t_bkdf = lt_bkdf
        t_bkpf = lt_bkpf
        t_bsec = lt_bsec
        t_bsed = lt_bsed
        t_bseg = lt_bseg
        t_bset = lt_bset
      EXCEPTIONS
        OTHERS = 4.

    IF sy-subrc = 0.
*     Create a change document for the document modifications
      objectid = bkpf(21).
      tcode    = 'FB02'.
      utime    = sy-uzeit.
      udate    = sy-datum.
      username = sy-uname.
      SET UPDATE TASK LOCAL.
      PERFORM cd_call_beleg.
      COMMIT WORK.
    ENDIF.

**   Protocol output of updated documents
*    LOOP AT lt_update ASSIGNING <ls_update>.
*      AT FIRST.
*        CLEAR: lv_noprot.
*        lv_ptype   = 'U'.
*        NEW-PAGE.
*      ENDAT.
*      PERFORM protocol_output USING <ls_update>.
*      AT LAST.
*        WRITE: / sy-uline(70).
*        CLEAR: lv_pageend.
*      ENDAT.
*    ENDLOOP.
    cv_logtx = TEXT-l03.   "Motivo de emisión actualizado.

  ENDMETHOD.

  METHOD get_zp.
*-> iv_bukrs TYPE bukrs
*-> iv_belnr TYPE belnr_d
*-> iv_gjahr TYPE gjahr
*<- ev_blart TYPE blart
*<- ev_bukrs TYPE bukrs
*<- ev_belnr TYPE belnr_d
*<- ev_gjahr TYPE gjahr
*<- ev_buzei TYPE buzei.

    CLEAR: ev_blart, ev_bukrs, ev_belnr, ev_gjahr, ev_buzei.

    SELECT FROM bsas
      FIELDS blart, bukrs, belnr, gjahr, buzei
      WHERE bukrs  = @iv_bukrs
        AND augbl  = @iv_belnr
        AND auggj  = @iv_gjahr
        AND belnr <> @iv_belnr
        AND blart IN ( 'ZP', 'ZA' )
      INTO TABLE @DATA(lt_bsas_y).

    READ TABLE lt_bsas_y ASSIGNING FIELD-SYMBOL(<ls_bsas_y>) WITH KEY blart = 'ZP'.
    IF sy-subrc = 0.
      ev_blart = <ls_bsas_y>-blart.
      ev_bukrs = <ls_bsas_y>-bukrs.
      ev_belnr = <ls_bsas_y>-belnr.
      ev_gjahr = <ls_bsas_y>-gjahr.
      ev_buzei = <ls_bsas_y>-buzei.
    ELSE.
      READ TABLE lt_bsas_y ASSIGNING <ls_bsas_y> WITH KEY blart = 'ZA'.
      IF sy-subrc = 0.
        ev_blart = <ls_bsas_y>-blart.
        ev_bukrs = <ls_bsas_y>-bukrs.
        ev_belnr = <ls_bsas_y>-belnr.
        ev_gjahr = <ls_bsas_y>-gjahr.
        ev_buzei = <ls_bsas_y>-buzei.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD show_log.

    PERFORM fieldcat_init USING gt_fieldcat[].
*   cl_demo_output=>display( gt_log ).

    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = gv_repid
        it_fieldcat        = gt_fieldcat[]
      TABLES
        t_outtab           = gt_log.


  ENDMETHOD.

ENDCLASS.
