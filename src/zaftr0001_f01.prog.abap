*&---------------------------------------------------------------------*
*&  Include           ZAFTR0001_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  DATA : lt_anlsum TYPE TABLE OF v_anlsum_1,
         lt_t087v  TYPE TABLE OF t087v,
         lw_t087v  TYPE t087v,
         lw_anlsum TYPE v_anlsum_1.
*
  CLEAR gt_salida.
**add comment ini
  SELECT anlue anlue_txt INTO CORRESPONDING FIELDS OF TABLE lt_t087v
         FROM t087v WHERE spras EQ sy-langu
                      AND anlue IN s_anlue."#EC CI_SGLSELECT
**add comment fin
  SELECT * INTO TABLE lt_anlsum
         FROM v_anlsum_1 WHERE bukrs IN s_bukrs
                           AND anln1 IN s_anln1
                           AND anln2 IN s_anln2
                           AND anlkl IN s_anlkl
                           AND kostl IN s_kostl
                           AND stort IN s_stort
                           AND anlue IN s_anlue
                           AND deakt IN s_deakt
                           AND gjahr EQ p_fecha(4)
                           AND afabe IN s_afabe.
*
  LOOP AT lt_anlsum INTO lw_anlsum.
    CLEAR wa_salida.
    MOVE-CORRESPONDING lw_anlsum TO wa_salida.
*
    PERFORM lee_moneda.
*
    PERFORM lee_acreedor.
*
    PERFORM lee_anek.
*
    PERFORM lee_anlp.
*
    READ TABLE lt_t087v INTO lw_t087v
                        WITH KEY anlue = wa_salida-anlue.
    IF sy-subrc EQ 0.
      MOVE lw_t087v-anlue_txt TO wa_salida-anlue_txt.
    ENDIF.
*
    APPEND wa_salida TO gt_salida.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: lt_sort     TYPE lvc_t_sort,
        lt_fieldcat TYPE lvc_t_fcat,
        wa_layout   TYPE lvc_s_layo,
        wa_variant  TYPE disvariant.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM sort            TABLES lt_sort.
  PERFORM fieldcat_init   USING lt_fieldcat[].
*
  wa_variant-report   = gv_repid.
  wa_variant-variant  = p_vari.
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
      is_variant               = wa_variant
*     it_sort_lvc              = lt_sort
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_salida
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm    LIKE sy-ucomm            "#EC NEEDED
                        rs_selfield TYPE slis_selfield.     "#EC CALLED
  TYPES : BEGIN OF ty_documfi,
            bukrs TYPE bukrs,
            belnr TYPE belnr_d,
            gjahr TYPE gjahr,
          END OF ty_documfi.
*
  DATA : lv_salida      TYPE zeaf_trazabilidad_mod,
         lv_docfi       TYPE ty_documfi,
         l_getfeld      TYPE t354s-initfield,
         l_getvalue     TYPE t354s-initfield,
         ti_iobject     TYPE TABLE OF iopick,
         lv_opt         TYPE ctu_params,
         lt_bdcdata_tab TYPE TABLE OF bdcdata.

  CASE rs_selfield-fieldname.
    WHEN 'ANLN1'.
      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
      lt_bdcdata_tab = VALUE #(
        ( program  = 'AW01N' dynpro   = '0100' dynbegin = 'X' )
        ( fnam = 'ANLA-BUKRS'   fval = wa_salida-bukrs )
        ( fnam = 'ANLA-ANLN1'   fval = wa_salida-anln1 )
        ( fnam = 'ANLA-ANLN2'   fval = wa_salida-anln2 )
        ( fnam = 'EDIT_JAHRE'   fval = wa_salida-zujhr )
        ( fnam = 'BDC_OKCODE'  fval = '/00' )
        ( program  = 'AW01N' dynpro   = '0100' dynbegin = 'X' )
        ( fnam = 'EDIT_JAHRE'   fval = wa_salida-zujhr )
        ( fnam = 'BDC_OKCODE'  fval = '/00' ) ).
*
      lv_opt-dismode = 'E'.
      lv_opt-defsize = 'X'.
      CALL TRANSACTION 'AW01N' USING lt_bdcdata_tab OPTIONS FROM lv_opt.
    WHEN 'BKPF-BELNR'.
      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
      MOVE-CORRESPONDING wa_salida-bkpf TO lv_docfi.
    WHEN 'MKPF-BELNR_FI'.
      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
      MOVE-CORRESPONDING wa_salida-mkpf TO lv_docfi.
      MOVE wa_salida-mkpf-belnr_fi      TO lv_docfi-belnr.
    WHEN 'AIBU-BELNR_FI'.
      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
      MOVE-CORRESPONDING wa_salida-aibu TO lv_docfi.
      MOVE wa_salida-aibu-belnr_fi      TO lv_docfi-belnr.
    WHEN 'MKPF-BELNR'.
      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
      MOVE-CORRESPONDING wa_salida-mkpf TO lv_salida.
      l_getfeld  = 'RIHAUFM-MBLNR'.
      l_getvalue = lv_salida-belnr.
      CALL FUNCTION 'MASTER_DATA'
        EXPORTING
          datenfeld  = l_getfeld
          fieldvalue = l_getvalue
        TABLES
          iobject    = ti_iobject.  "OPCIONAL
*    WHEN 'AIBU-BELNR'.
*      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
*      MOVE-CORRESPONDING wa_salida-aibu TO lv_docfi.
    WHEN 'BKPF-MODULO' OR 'MKPF-MODULO' OR 'AIBU-MODULO'.
      PERFORM muestra_subscreen USING rs_selfield-fieldname
                                      rs_selfield-tabindex.
    WHEN 'AIBU-ANLU1'.
*      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
*      lt_bdcdata_tab = VALUE #(
*        ( program  = 'RABEST_ALV01' dynpro   = '1000' dynbegin = 'X' )
*        ( fnam = 'BUKRS-LOW'   fval = wa_salida-aibu-bukrs )
*        ( fnam = 'ANLAGE-LOW'  fval = wa_salida-aibu-anlu1 )
*        ( fnam = 'UNTNR-LOW'   fval = wa_salida-aibu-anlu2 )
*        ( fnam = 'BEREICH1'    fval = wa_salida-afabe      )
*        ( fnam = 'BDC_OKCODE'  fval = '=ONLI' ) ).
**
*      lv_opt-dismode = 'E'.
*      lv_opt-defsize = 'X'.
*      CALL TRANSACTION 'AR01' USING lt_bdcdata_tab OPTIONS FROM lv_opt.
      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
      lt_bdcdata_tab = VALUE #(
        ( program  = 'AW01N' dynpro   = '0100' dynbegin = 'X' )
        ( fnam = 'ANLA-BUKRS'   fval = wa_salida-aibu-bukrs )
        ( fnam = 'ANLA-ANLN1'   fval = wa_salida-aibu-anlu1 )
        ( fnam = 'ANLA-ANLN2'   fval = wa_salida-aibu-anlu2 )
        ( fnam = 'EDIT_JAHRE'   fval = wa_salida-aibu-gjahr )
        ( fnam = 'BDC_OKCODE'  fval = '/00' )
        ( program  = 'AW01N' dynpro   = '0100' dynbegin = 'X' )
        ( fnam = 'EDIT_JAHRE'   fval = wa_salida-aibu-gjahr )
        ( fnam = 'BDC_OKCODE'  fval = '/00' ) ).
*
      lv_opt-dismode = 'E'.
      lv_opt-defsize = 'X'.
      CALL TRANSACTION 'AW01N' USING lt_bdcdata_tab OPTIONS FROM lv_opt.
  ENDCASE.
*
  CASE rs_selfield-fieldname.
    WHEN 'BKPF-BELNR' OR 'MKPF-BELNR_FI' OR 'AIBU-BELNR_FI'.
      SET PARAMETER ID : 'BLN' FIELD lv_docfi-belnr,
                         'BUK' FIELD lv_docfi-bukrs,
                         'GJR' FIELD lv_docfi-gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA: fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE,
        l_procesado      TYPE char50.
*
  CLEAR: fcode_attrib_tab, fcode_attrib_tab[].
*
  PERFORM dynamic_report_fcodes(rhteiln0) TABLES fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.
  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.
ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE lvc_s_layo.
  CLEAR rs_layout.
*  rs_layout-f2code               = 'DISPLAY'.
  rs_layout-zebra                = gc_x.
  rs_layout-detailinit           = gc_x.
  rs_layout-cwidth_opt           = gc_x.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SORT
*&---------------------------------------------------------------------*
FORM sort  TABLES   p_it_sort TYPE lvc_t_sort.
  DATA wa_sort TYPE lvc_s_sort.
*
  CLEAR p_it_sort[].
  wa_sort-fieldname = 'BUKRS'.
  wa_sort-up        = gc_x.
  APPEND wa_sort TO p_it_sort.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
  DATA : lt_fieldcat TYPE lvc_t_fcat,
         gs_fieldcat TYPE lvc_s_fcat,
         lv_col_pos  TYPE lvc_colpos,
         lv_proces   TYPE char5,
         lv_proces2  TYPE char2,
         lv_color    TYPE char04.
*
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gc_tabla
    CHANGING
      ct_fieldcat            = p_gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
**
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gc_estrc
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*
  DESCRIBE TABLE p_gt_fieldcat LINES lv_col_pos.
  DO 3 TIMES.
    CASE sy-index.
      WHEN 1.
        MOVE 'BKPF-' TO lv_proces.
        MOVE 'FI'    TO lv_proces2.
        MOVE 'C110'  TO lv_color.
      WHEN 2.
        MOVE 'MKPF-' TO lv_proces.
        MOVE 'MM'    TO lv_proces2.
        MOVE 'C310'  TO lv_color.
      WHEN 3.
        MOVE 'AIBU-' TO lv_proces.
        MOVE 'AF'    TO lv_proces2.
        MOVE 'C510'  TO lv_color.
    ENDCASE.
*
    LOOP AT lt_fieldcat INTO gs_fieldcat .
      ADD 1 TO lv_col_pos.
      MOVE lv_col_pos  TO gs_fieldcat-col_pos.
*
      CASE gs_fieldcat-fieldname.
        WHEN 'PROCESO'.
          gs_fieldcat-scrtext_m = lv_proces2.
        WHEN 'XBLNR'.
          IF lv_proces(4) NE 'MKPF'.
            gs_fieldcat-tech = gc_x.
          ENDIF.
        WHEN 'BELNR_FI'.
          IF lv_proces(4) EQ 'BKPF'.
            gs_fieldcat-tech      = gc_x.
          ENDIF.
          gs_fieldcat-scrtext_m = 'N°Docum. FI'.
          gs_fieldcat-hotspot   = gc_x.
        WHEN 'BLART_FI'.
          IF lv_proces(4) EQ 'BKPF'.
            gs_fieldcat-tech      = gc_x.
          ENDIF.
        WHEN 'MODULO'.
          gs_fieldcat-scrtext_m = 'Mas datos'.
          gs_fieldcat-hotspot   = gc_x.
        WHEN 'BELNR'.
          IF lv_proces(4) NE 'AIBU'.
            gs_fieldcat-hotspot   = gc_x.
          ENDIF.
        WHEN 'BUKRS'.
          gs_fieldcat-tech      = gc_x.
        WHEN 'CLAVE'.
          gs_fieldcat-tech      = gc_x.
        WHEN 'ANLU1'.
          IF lv_proces(4) NE 'AIBU'.
            gs_fieldcat-tech = gc_x.
          ENDIF.
          gs_fieldcat-hotspot   = gc_x.
          gs_fieldcat-scrtext_m = 'N°Inmovil. emisor'(m02).
        WHEN 'ANLU2'.
          IF lv_proces(4) NE 'AIBU'.
            gs_fieldcat-tech = gc_x.
          ENDIF.
          gs_fieldcat-scrtext_m = 'SubN°Inmovil. emisor'(m03).
      ENDCASE.
*
      CONCATENATE lv_proces gs_fieldcat-fieldname
                                   INTO gs_fieldcat-fieldname.
*
      gs_fieldcat-emphasize = lv_color.
      APPEND gs_fieldcat TO p_gt_fieldcat.
    ENDLOOP.
  ENDDO.
*
  LOOP AT p_gt_fieldcat INTO gs_fieldcat .
    CASE gs_fieldcat-fieldname.
      WHEN 'BUKRS'.
        gs_fieldcat-key        = gc_x.
      WHEN 'ANLN1'.
        gs_fieldcat-key        = gc_x.
        gs_fieldcat-hotspot   = gc_x.
      WHEN 'ANLN2'.
        gs_fieldcat-key        = gc_x.

      WHEN 'TOTAL'.
        gs_fieldcat-scrtext_m = 'Total'.
    ENDCASE.
**
    gs_fieldcat-scrtext_s = gs_fieldcat-scrtext_m.
    gs_fieldcat-scrtext_l = gs_fieldcat-scrtext_m.
    gs_fieldcat-colddictxt = 'M'.
    MODIFY p_gt_fieldcat FROM gs_fieldcat.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_ACREEDOR
*&---------------------------------------------------------------------*
FORM lee_acreedor.
  DATA : lw_lifnr TYPE ty_lifnr.
*
  READ TABLE gt_lifnr INTO lw_lifnr WITH KEY lifnr = wa_salida-lifnr.
  IF sy-subrc NE 0.
    SELECT lifnr land1 name1 stcd1 APPENDING TABLE gt_lifnr
           FROM lfa1 WHERE lifnr EQ wa_salida-lifnr.
    READ TABLE gt_lifnr INTO lw_lifnr WITH KEY lifnr = wa_salida-lifnr.
  ENDIF.
*
  CHECK sy-subrc EQ 0.
  MOVE-CORRESPONDING lw_lifnr TO wa_salida.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_ANEK
*&---------------------------------------------------------------------*
FORM lee_anek.
  DATA : lt_anek  TYPE TABLE OF anek,
         lw_anek  TYPE anek,
         lv_awkey TYPE awkey,
         lv_clave TYPE char20,
         BEGIN OF lw_datos,
           bkpf TYPE i,
           mkpf TYPE i,
           aibu TYPE i,
         END OF lw_datos.
*
  CONCATENATE wa_salida-bukrs wa_salida-anln1 wa_salida-anln2
              INTO lv_clave.
*
  SELECT * INTO TABLE lt_anek
        FROM anek WHERE bukrs EQ wa_salida-bukrs
                    AND anln1 EQ wa_salida-anln1
                    AND anln2 EQ wa_salida-anln2
                    AND awtyp IN ('BKPF','MKPF','AIBU')
                    ORDER BY PRIMARY KEY.
*
  LOOP AT lt_anek INTO lw_anek.
    CLEAR wa_datos.
    CASE lw_anek-awtyp.
      WHEN 'BKPF'.
        MOVE-CORRESPONDING lw_anek TO wa_datos.
        MOVE : wa_salida-bukrs       TO wa_datos-bukrs,
               lv_clave              TO wa_datos-clave.
        SELECT SINGLE blart bktxt xref1_hd xref2_hd waers
               INTO (wa_datos-blart, wa_datos-bktxt,
                     wa_datos-xref1_hd, wa_datos-xref2_hd,
                     wa_datos-waers )
               FROM bkpf WHERE bukrs EQ wa_datos-bukrs
                           AND belnr EQ wa_datos-belnr
                           AND gjahr EQ wa_datos-gjahr.
*
        PERFORM lee_anep USING    lw_anek
                         CHANGING wa_datos-bwasl
                                  wa_datos-anbtr.
*
        APPEND wa_datos TO gt_datos_fi.

        IF lw_datos-bkpf IS INITIAL.
          MOVE-CORRESPONDING wa_datos TO wa_salida-bkpf.
        ENDIF.
*
        ADD 1 TO lw_datos-bkpf.
      WHEN 'MKPF'.
        MOVE-CORRESPONDING lw_anek TO wa_datos.
        MOVE : wa_salida-bukrs       TO wa_datos-bukrs,
               lv_clave              TO wa_datos-clave.
        CONCATENATE lw_anek-belnr lw_anek-aworg INTO lv_awkey.
        SELECT SINGLE belnr blart bktxt xref1_hd xref2_hd waers
               INTO (wa_datos-belnr_fi, wa_datos-blart_fi, wa_datos-bktxt,
                     wa_datos-xref1_hd, wa_datos-xref2_hd,
                     wa_datos-waers )
               FROM bkpf WHERE bukrs EQ wa_datos-bukrs
                           AND awtyp EQ lw_anek-awtyp
                           AND awkey EQ lv_awkey.
*
        PERFORM lee_anep USING    lw_anek
                         CHANGING wa_datos-bwasl
                                  wa_datos-anbtr.
*
        APPEND wa_datos TO gt_datos_mm.

        IF lw_datos-mkpf IS INITIAL.
          MOVE-CORRESPONDING wa_datos TO wa_salida-mkpf.
        ENDIF.

        ADD 1 TO lw_datos-mkpf.
      WHEN 'AIBU'.
        MOVE-CORRESPONDING lw_anek TO wa_datos.
        MOVE : wa_salida-bukrs       TO wa_datos-bukrs,
               lv_clave              TO wa_datos-clave.

        CONCATENATE lw_anek-belnr lw_anek-bukrs lw_anek-gjahr INTO lv_awkey.
        SELECT SINGLE belnr blart bktxt xref1_hd xref2_hd waers
               INTO (wa_datos-belnr_fi, wa_datos-blart_fi, wa_datos-bktxt,
                     wa_datos-xref1_hd, wa_datos-xref2_hd,
                     wa_datos-waers )
               FROM bkpf WHERE bukrs EQ wa_datos-bukrs
                           AND awtyp EQ lw_anek-awtyp
                           AND awkey EQ lv_awkey.
*
        PERFORM lee_anep USING    lw_anek
                         CHANGING wa_datos-bwasl
                                  wa_datos-anbtr.
*
        APPEND wa_datos TO gt_datos_af.

        IF lw_datos-aibu IS INITIAL.
          MOVE-CORRESPONDING wa_datos TO wa_salida-aibu.
        ENDIF.

        ADD 1 TO lw_datos-aibu.
    ENDCASE.
  ENDLOOP.
*
  IF lw_datos-bkpf GT 1.
    wa_salida-bkpf-modulo = gc_x.
    DELETE ADJACENT DUPLICATES FROM gt_datos_fi COMPARING bukrs belnr gjahr.
  ENDIF.
  IF lw_datos-mkpf GT 1.
    wa_salida-mkpf-modulo = gc_x.
    DELETE ADJACENT DUPLICATES FROM gt_datos_mm COMPARING bukrs belnr gjahr.
  ENDIF.
  IF lw_datos-aibu GT 1.
    wa_salida-aibu-modulo = gc_x.
    DELETE ADJACENT DUPLICATES FROM gt_datos_af COMPARING bukrs belnr gjahr.
  ENDIF.
*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_ANLP
*&---------------------------------------------------------------------*
FORM lee_anlp.
  TYPES : BEGIN OF ty_anlp,
            nafaz TYPE anlp-nafaz,
            aufwz TYPE anlp-aufwz,
            aufnz TYPE anlp-aufnz,
            nafag TYPE anlp-nafag,
          END OF ty_anlp.
  DATA : lt_anlp  TYPE TABLE OF ty_anlp,
         lw_anlp  TYPE ty_anlp,
         lr_peraf TYPE RANGE OF anlp-peraf,
         lw_peraf LIKE LINE OF lr_peraf.
*
  lw_peraf-sign = 'I'.   lw_peraf-option = 'BT'.
  lw_peraf-low  = '01'.  lw_peraf-high   = p_fecha+4(2).
  APPEND lw_peraf TO lr_peraf.
*
  SELECT SUM( nafaz ) SUM( aufwz ) SUM( aufnz ) SUM( nafag )
       INTO lw_anlp
       FROM anlp WHERE bukrs  EQ wa_salida-bukrs
                   AND gjahr  EQ p_fecha(4)
                   AND peraf  IN lr_peraf
                   AND anln1  EQ wa_salida-anln1
                   AND anln2  EQ wa_salida-anln2
                   AND afaber EQ wa_salida-afabe.
  IF sy-subrc EQ 0.
    MOVE : lw_anlp-nafaz TO wa_salida-nafaz,
           lw_anlp-aufwz TO wa_salida-aufwz,
           lw_anlp-aufnz TO wa_salida-aufnz,
           lw_anlp-nafag TO wa_salida-nafag.
  ENDIF.
  wa_salida-total = wa_salida-kansw + wa_salida-answl +
                    wa_salida-knafa + wa_salida-nafaz +
                    wa_salida-aufwz + wa_salida-kaufw +
                    wa_salida-kaufn + wa_salida-aufnz.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_ANEP
*&---------------------------------------------------------------------*
FORM lee_anep USING    p_lw_anek TYPE anek
              CHANGING s_bwasl
                       s_anbtr.

  SELECT SINGLE bwasl anbtr INTO (s_bwasl, s_anbtr )
         FROM anep WHERE bukrs  EQ p_lw_anek-bukrs
                     AND anln1  EQ p_lw_anek-anln1
                     AND anln2  EQ p_lw_anek-anln2
                     AND gjahr  EQ p_lw_anek-gjahr
                     AND lnran  EQ p_lw_anek-lnran
                     AND afabe  EQ wa_salida-afabe
                     AND lnsan  EQ space.
  CHECK sy-subrc NE 0.
  CLEAR: s_bwasl, s_anbtr.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_MONEDA
*&---------------------------------------------------------------------*
FORM lee_moneda .
  DATA : lw_t093b  TYPE ty_t093b.
*
  READ TABLE gt_t093b INTO lw_t093b WITH KEY bukrs = wa_salida-bukrs
                                             afabe = wa_salida-afabe.
  CHECK sy-subrc EQ 0.
  wa_salida-waers = lw_t093b-waers.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_SUBSCREEN
*&---------------------------------------------------------------------*
FORM muestra_subscreen  USING    p_fieldname
                                 p_tabindex.

*
  CLEAR : gt_datos[], gv_proceso.
*
  READ TABLE gt_salida INTO wa_salida INDEX p_tabindex.
  CASE p_fieldname.
    WHEN 'BKPF-MODULO'.
      LOOP AT gt_datos_fi INTO wa_datos WHERE clave EQ wa_salida-bkpf-clave.
        APPEND wa_datos TO gt_datos.
      ENDLOOP.
      gv_proceso = 'FI'.
    WHEN 'MKPF-MODULO'.
      LOOP AT gt_datos_mm INTO wa_datos WHERE clave EQ wa_salida-mkpf-clave.
        APPEND wa_datos TO gt_datos.
      ENDLOOP.
      gv_proceso = 'MM'.
    WHEN 'AIBU-MODULO'.
      LOOP AT gt_datos_af INTO wa_datos WHERE clave EQ wa_salida-aibu-clave.
        APPEND wa_datos TO gt_datos.
      ENDLOOP.
      gv_proceso = 'AF'.
  ENDCASE.
*
  CALL SCREEN 100 STARTING AT 10 5.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MASK_COLUMNS
*&---------------------------------------------------------------------*
FORM mask_columns TABLES p_gt_fieldcat TYPE lvc_t_fcat.
  DATA gs_fieldcat TYPE lvc_s_fcat.
*
  CLEAR p_gt_fieldcat[].
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = gc_estrc
    CHANGING
      ct_fieldcat      = p_gt_fieldcat[].

  LOOP AT p_gt_fieldcat INTO gs_fieldcat .
*
    CASE gs_fieldcat-fieldname.
      WHEN 'ANLU1' OR 'ANLU2'.
        IF gv_proceso NE 'AF'.
          gs_fieldcat-tech = gc_x.
        ENDIF.
      WHEN 'XBLNR'.
        IF gv_proceso NE 'MM'.
          gs_fieldcat-tech = gc_x.
        ENDIF.
      WHEN 'BELNR_FI'.
        IF gv_proceso EQ 'FI'.
          gs_fieldcat-tech      = gc_x.
        ENDIF.
        gs_fieldcat-scrtext_m = 'N°Docum. FI'.
        gs_fieldcat-hotspot   = gc_x.
      WHEN 'BLART_FI'.
        IF gv_proceso NE 'MM'.
          gs_fieldcat-tech      = gc_x.
        ENDIF.
        gs_fieldcat-scrtext_m = 'ClDoc. FI'.
        gs_fieldcat-hotspot   = gc_x.
      WHEN 'BELNR'.
        gs_fieldcat-key       = gc_x.
        IF gv_proceso NE 'AF'.
          gs_fieldcat-hotspot   = gc_x.
        ENDIF.
      WHEN 'BUKRS'.
        gs_fieldcat-tech      = gc_x.
      WHEN 'MODULO' OR 'CLAVE' OR 'PROCESO'.
        gs_fieldcat-tech = gc_x.
    ENDCASE.
*
    gs_fieldcat-colddictxt = 'M'.
    MODIFY  p_gt_fieldcat FROM gs_fieldcat .
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VARIANTEN_AUSWAHL
*&---------------------------------------------------------------------*
FORM varianten_auswahl CHANGING pvari LIKE disvariant-variant.
  DATA: x_exit(1)   TYPE c,
        x_variant   LIKE disvariant,
        x_variant2  LIKE disvariant,
        fieldvalues TYPE dynpread OCCURS 1 WITH HEADER LINE.
*
* Aktueller Reportname
  x_variant-report  = sy-repid.
  x_variant-variant = pvari.
  x_variant-handle  = ''.
*
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = x_variant
      i_save     = 'A'
    IMPORTING
      e_exit     = x_exit
      es_variant = x_variant2
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
*   Keine Varianten für den Report vorhanden
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF x_exit = space.
*     Augewählten Variantennamen übernehmen
      pvari = x_variant2-variant.
    ENDIF.
  ENDIF.

ENDFORM.
