*&---------------------------------------------------------------------*
*&  Include           ZAFTR0002_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  TYPES : BEGIN OF ty_fi,
            bukrs TYPE bkpf-bukrs,
            gjahr TYPE bkpf-gjahr,
            bldat TYPE bkpf-bldat,
            budat TYPE bkpf-budat,
            awkey TYPE bkpf-awkey,
          END OF ty_fi,
          BEGIN OF ty_lifnr,
            lifnr TYPE lifnr,
          END OF ty_lifnr,
          BEGIN OF ty_ekbe,
            ebeln TYPE ekbe-ebeln,
            ebelp TYPE ekbe-ebelp,
            menge TYPE ekbe-menge,
            wrbtr TYPE ekbe-wrbtr,
          END OF ty_ekbe.
  DATA : lt_fi       TYPE TABLE OF ty_fi,
         lt_lifnr    TYPE TABLE OF ty_lifnr,
         lt_ekbe_sum TYPE TABLE OF ty_ekbe.
*
  cl_progress_indicator=>progress_indicate(
      i_text = TEXT-con
      i_output_immediately = abap_true ).
*
* dato de documentos de compras
  SELECT ekkn~ebeln, ekkn~ebelp, anln1, anln2, bukrs
        INTO TABLE @DATA(lt_ekko_ekpo_new)
        FROM wb2_v_ekko_ekpo2 INNER JOIN ekkn
               ON wb2_v_ekko_ekpo2~ebeln_i EQ ekkn~ebeln AND
                  wb2_v_ekko_ekpo2~ebelp_i EQ ekkn~ebelp
                 WHERE ebeln_i   IN @s_ebeln
                   AND bukrs     IN @s_bukrs
                   AND anln1     IN @s_anln1
                   AND anln2     IN @s_anln2
                   AND bedat     IN @s_bldat
                   AND knttp_i   EQ 'A'.
  CHECK sy-subrc EQ 0.

  cl_progress_indicator=>progress_indicate(
    i_text = TEXT-otr
    i_output_immediately = abap_true ).

  SELECT bukrs, anln1, anln2, bldat, budat, bzdat, bwasl,
         anbtr, xblnr, ebeln, ebelp, belnr, gjahr, zujhr
        INTO TABLE @DATA(lt_enepk)
        FROM v_anepk
              FOR ALL ENTRIES IN @lt_ekko_ekpo_new
                     WHERE bukrs EQ @lt_ekko_ekpo_new-bukrs
                       AND anln1 EQ @lt_ekko_ekpo_new-anln1
                       AND anln2 EQ @lt_ekko_ekpo_new-anln2
                       AND afabe IN @s_afabe
                       AND ebeln EQ @lt_ekko_ekpo_new-ebeln.
*
  IF sy-subrc EQ 0.
    lt_fi = VALUE #( FOR ly_detalle IN lt_enepk
                              LET awkey =  ly_detalle-belnr && ly_detalle-gjahr
                              IN ( VALUE #( BASE CORRESPONDING #( ly_detalle )
                                            awkey = awkey ) ) ).
    SORT lt_fi.
    DELETE ADJACENT DUPLICATES FROM lt_fi COMPARING ALL FIELDS.
  ENDIF.
* datos de activo fijo
  SELECT bukrs, anln1, anln2, anlue, lifnr, liefe, kostl
        INTO TABLE @DATA(lt_anlaz)
        FROM v_anlaz FOR ALL ENTRIES IN @lt_ekko_ekpo_new
                 WHERE bukrs EQ @lt_ekko_ekpo_new-bukrs
                   AND anln1 EQ @lt_ekko_ekpo_new-anln1
                   AND anln2 EQ @lt_ekko_ekpo_new-anln2.
*
  IF sy-subrc EQ 0.
* datos del proveedor
    lt_lifnr = VALUE #( FOR ly_detalle2 IN lt_anlaz
                                        WHERE ( lifnr NE space )
                                      ( CORRESPONDING #( ly_detalle2 ) ) ).
    IF lt_lifnr[] IS NOT INITIAL.
      SORT lt_lifnr.
      DELETE ADJACENT DUPLICATES FROM lt_lifnr COMPARING ALL FIELDS.

      SELECT lifnr, name1 INTO TABLE @DATA(lt_lfa1)
             FROM lfa1 FOR ALL ENTRIES IN @lt_lifnr
                       WHERE lifnr EQ @lt_lifnr-lifnr.
    ENDIF.
  ENDIF.
* dato de documentos de compras
  SELECT ebeln_i, ebelp_i, bsart, waers, txz01_i, netpr_i, menge_i, meins_i,
         netwr_i, navnw_i, elikz_i, werks_i
        INTO TABLE @DATA(lt_ekko_ekpo)
        FROM wb2_v_ekko_ekpo2 FOR ALL ENTRIES IN @lt_ekko_ekpo_new
                 WHERE ebeln_i EQ @lt_ekko_ekpo_new-ebeln
                   AND ebelp_i EQ @lt_ekko_ekpo_new-ebelp.
* unidades recepcionadas.
  IF lt_ekko_ekpo[] IS NOT INITIAL.
    SELECT ekkn~ebeln, ekkn~ebelp, ekkn~vproz, ekkn~menge AS ekkn_menge,
           ekbe~menge, ekbe~wrbtr, ekbe~waers
           INTO TABLE @DATA(lt_ekbe)
           FROM ekkn INNER JOIN ekbe
                ON ekkn~ebeln EQ ekbe~ebeln AND
                   ekkn~ebelp EQ ekbe~ebelp AND
                   ekkn~zekkn EQ ekbe~zekkn
                FOR ALL ENTRIES IN @lt_enepk
                WHERE ekkn~ebeln EQ @lt_enepk-ebeln
                 AND  ekkn~ebelp EQ @lt_enepk-ebelp
                 AND  ekkn~anln1 EQ @lt_enepk-anln1
                 AND  ekkn~anln2 EQ @lt_enepk-anln2
                 AND  ekbe~vgabe EQ '2'
                 AND  ekbe~bewtp EQ 'Q'
                 AND  ekbe~belnr EQ @lt_enepk-belnr.
    IF lt_ekbe[] IS NOT INITIAL.
      LOOP AT lt_ekbe ASSIGNING FIELD-SYMBOL(<ls_data>)
                         GROUP BY ( ebeln     = <ls_data>-ebeln
                                    ebelp     = <ls_data>-ebelp )
                         INTO DATA(ls_datos).
        DATA(ls_comm) = VALUE ty_ekbe( ebeln   = ls_datos-ebeln
                                       ebelp   = ls_datos-ebelp ).
        LOOP AT GROUP ls_datos INTO DATA(ls_datos_sum).
          ADD ls_datos_sum-menge       TO ls_comm-menge.
          ADD ls_datos_sum-wrbtr       TO ls_comm-wrbtr.
        ENDLOOP.
*
        APPEND ls_comm TO lt_ekbe_sum.
      ENDLOOP.
    ENDIF.
  ENDIF.
* datos de documento de fi
  IF lt_fi[] IS NOT INITIAL.
    SELECT bkpf~bukrs, bkpf~belnr, bkpf~gjahr, bseg~buzei, bkpf~bldat, bkpf~budat,
           bkpf~awkey, bkpf~xblnr, bkpf~blart,
           bseg~bschl, bseg~pswsl, bseg~werks, bseg~menge, bseg~meins,
           bseg~bwkey, bseg~hkont
           INTO TABLE @DATA(lt_bkpf)
           FROM bkpf INNER JOIN bseg
                ON bkpf~bukrs EQ bseg~bukrs AND
                   bkpf~belnr EQ bseg~belnr AND
                   bkpf~gjahr EQ bseg~gjahr
                FOR ALL ENTRIES IN @lt_fi
                WHERE bkpf~bukrs EQ @lt_fi-bukrs
                  AND bkpf~gjahr EQ @lt_fi-gjahr
                  AND bkpf~bldat EQ @lt_fi-bldat
                  AND bkpf~budat EQ @lt_fi-budat
                  AND bkpf~awkey EQ @lt_fi-awkey
                  AND bseg~koart EQ 'A'.
  ENDIF.

  DESCRIBE TABLE lt_enepk LINES DATA(lv_registro).

  LOOP AT lt_ekko_ekpo_new INTO DATA(lw_enepk).
    MOVE-CORRESPONDING lw_enepk TO wa_salida.
*
    cl_progress_indicator=>progress_indicate(
        i_text = | { TEXT-sal } { sy-tabix } / { lv_registro } |
                 i_output_immediately = abap_true
                 i_processed          = sy-tabix
                 i_total              = lv_registro ).
*
    DATA(lv_index) = line_index( lt_enepk[  bukrs = lw_enepk-bukrs
                                            anln1 = lw_enepk-anln1
                                            anln2 = lw_enepk-anln2
                                            ebeln = lw_enepk-ebeln
                                            ebelp = lw_enepk-ebelp ] ).
    IF lv_index GT 0.
      DATA(lw_enepk_new) =  lt_enepk[ lv_index ].
      MOVE-CORRESPONDING lw_enepk_new TO wa_salida.
      MOVE : lw_enepk_new-gjahr TO wa_salida-gjahr_mm,
             lw_enepk_new-belnr TO wa_salida-belnr_mm.

*  datos finanacieros
      DATA(lv_awkey) = lw_enepk_new-belnr && lw_enepk_new-gjahr.
      lv_index       = line_index( lt_bkpf[  bukrs = lw_enepk_new-bukrs
                                             gjahr = lw_enepk_new-gjahr
                                             bldat = lw_enepk_new-bldat
                                             budat = lw_enepk_new-budat
                                             awkey = lv_awkey ] ).
      IF lv_index GT 0.
        DATA(lw_bkpf) = lt_bkpf[ lv_index ].
        MOVE-CORRESPONDING lw_bkpf TO wa_salida.
        MOVE : lw_bkpf-gjahr TO wa_salida-gjahr_fi,
               lw_bkpf-belnr TO wa_salida-belnr_fi.
      ENDIF.
    ENDIF.
* activo fijo.
    lv_index = line_index( lt_anlaz[  bukrs = lw_enepk-bukrs
                                      anln1 = lw_enepk-anln1
                                      anln2 = lw_enepk-anln2 ] ).
    IF lv_index GT 0.
      MOVE-CORRESPONDING lt_anlaz[ lv_index ] TO wa_salida.
    ENDIF.

* datos de compras
    lv_index       = line_index( lt_ekko_ekpo[ ebeln_i = lw_enepk-ebeln
                                               ebelp_i = lw_enepk-ebelp ] ).
    IF lv_index GT 0.
      DATA(lw_ekko_ekpo) = lt_ekko_ekpo[ lv_index ].
      MOVE-CORRESPONDING lw_ekko_ekpo TO wa_salida.
      MOVE : lw_ekko_ekpo-txz01_i     TO wa_salida-txz01,
             lw_ekko_ekpo-netpr_i     TO wa_salida-netpr,
             lw_ekko_ekpo-menge_i     TO wa_salida-menge_mm,
             lw_ekko_ekpo-meins_i     TO wa_salida-meins,
             lw_ekko_ekpo-werks_i     TO wa_salida-werks.
      wa_salida-importe_doc = lw_ekko_ekpo-netwr_i + lw_ekko_ekpo-navnw_i.
*
      lv_index       = line_index( lt_ekbe_sum[ ebeln = lw_enepk-ebeln
                                                ebelp = lw_enepk-ebelp ] ).
      IF lv_index GT 0.
        DATA(lw_ekbe_sum) = lt_ekbe_sum[ lv_index ].
        MOVE : lw_ekbe_sum-menge TO wa_salida-unid_oc,
               lw_ekbe_sum-wrbtr TO wa_salida-detalle_imp.

        lv_index       = line_index( lt_ekbe[ ebeln = lw_enepk-ebeln
                                              ebelp = lw_enepk-ebelp ] ).
        DATA(lw_ekbe) = lt_ekbe[ lv_index ].
        MOVE : lw_ekbe-vproz      TO wa_salida-vproz,
               lw_ekbe-ekkn_menge TO wa_salida-menge_mm_imp,
               lw_ekbe-waers      TO wa_salida-waers_ekbe.
      ENDIF.
      wa_salida-dif_total   = wa_salida-menge_mm_imp - wa_salida-unid_oc.
      wa_salida-tot_imp_imp = lw_ekko_ekpo-netpr_i + ( lw_ekko_ekpo-navnw_i / lw_ekko_ekpo-menge_i ).
*
      IF wa_salida-pswsl EQ wa_salida-waers.
        wa_salida-diferencia_imp = wa_salida-tot_imp_imp - wa_salida-detalle_imp.
        wa_salida-observac = 'Monedas iguales'.
      ELSE.
        wa_salida-observac = 'Monedas distintas'.
      ENDIF.
*
      CASE lw_ekko_ekpo-elikz_i.
        WHEN gc_x.   MOVE TEXT-s01 TO wa_salida-status_oc.
        WHEN OTHERS. MOVE TEXT-s02 TO wa_salida-status_oc.
      ENDCASE.
    ENDIF.
* datos de cliente
    lv_index       = line_index( lt_lfa1[ lifnr =  wa_salida-lifnr ] ).
    IF lv_index GT 0.
      MOVE-CORRESPONDING lt_lfa1[ lv_index ] TO wa_salida.
    ENDIF.
*
    APPEND wa_salida TO gt_salida.
    CLEAR wa_salida.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: lt_fieldcat TYPE lvc_t_fcat,
        lt_sort     TYPE lvc_t_sort,
        ls_variant  TYPE disvariant,
        wa_layout   TYPE lvc_s_layo.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM sort_init       TABLES lt_sort.
  PERFORM fieldcat_init   USING lt_fieldcat[].
*
*  ls_variant-report = 'SAPF110O'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
      i_save                   = 'A'
      is_variant               = ls_variant
      it_sort_lvc              = lt_sort
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
  DATA : l_getfeld      TYPE t354s-initfield,
         l_getvalue     TYPE t354s-initfield,
         ti_iobject     TYPE TABLE OF iopick,
         lv_opt         TYPE ctu_params,
         lt_bdcdata_tab TYPE TABLE OF bdcdata.
*
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
    WHEN 'BELNR_MM'.
      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
      SET PARAMETER ID : 'RBN' FIELD wa_salida-belnr_mm,
                         'GJR' FIELD wa_salida-gjahr_mm.
      CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
    WHEN 'BELNR_FI'.
      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
      SET PARAMETER ID : 'BLN' FIELD wa_salida-belnr_fi,
                         'BUK' FIELD wa_salida-bukrs,
                         'GJR' FIELD wa_salida-gjahr_fi.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    WHEN 'EBELN'.
      READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
      l_getfeld  = 'VIQMEL-EBELN'.
      l_getvalue = wa_salida-ebeln.
      CALL FUNCTION 'MASTER_DATA'
        EXPORTING
          datenfeld  = l_getfeld
          fieldvalue = l_getvalue
        TABLES
          iobject    = ti_iobject.  "OPCIONAL
  ENDCASE.

ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA: lt_fcode_attrib_tab TYPE TABLE OF smp_dyntxt,
        lw_fcode_attrib_tab TYPE smp_dyntxt,
        lw_ce_func_exclude  TYPE slis_extab.
*
  CLEAR: lt_fcode_attrib_tab[].
*
  PERFORM dynamic_report_fcodes IN PROGRAM rhteiln0
                                          TABLES lt_fcode_attrib_tab
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
  rs_layout-zebra                = gc_x.
  rs_layout-detailinit           = gc_x.
  rs_layout-cwidth_opt           = gc_x.
  rs_layout-info_fname           = 'EMPHASIZE'.
ENDFORM.                    " LAYOUT_INIT
*&---------------------------------------------------------------------*
*&      Form  SORT_INIT
*&---------------------------------------------------------------------*
FORM sort_init  TABLES   p_it_sort TYPE lvc_t_sort.
  DATA wa_sort TYPE lvc_s_sort.
*
  CLEAR p_it_sort[].
  wa_sort-fieldname = 'BUKRS'.
  wa_sort-up        = gc_x.
  APPEND wa_sort TO p_it_sort.

  wa_sort-fieldname = 'ANLN1'.
  wa_sort-up        = gc_x.
  APPEND wa_sort TO p_it_sort.

  wa_sort-fieldname = 'ANLN2'.
  wa_sort-up        = gc_x.
  APPEND wa_sort TO p_it_sort.

*  wa_sort-fieldname = 'EBELN'.
*  wa_sort-up        = gc_x.
*  APPEND wa_sort TO p_it_sort.
*
*  wa_sort-fieldname = 'EBELP'.
*  wa_sort-up        = gc_x.
*  APPEND wa_sort TO p_it_sort.
ENDFORM.                    " SORT_INIT
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
  DATA : ls_fieldcat    TYPE  lvc_s_fcat,
         tmp_fldcat     TYPE lvc_t_fcat,
         lv_textfeld    TYPE char80,
         lv_hwae2       TYPE  x001-hwae2,
         lv_hwae3       TYPE  x001-hwae3,
         lv_col_pos     TYPE  lvc_colpos,
         lv_col_pos_out TYPE  lvc_colpos.
  FIELD-SYMBOLS:  <fs_fieldcat>    TYPE lvc_s_fcat.
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
*
  LOOP AT p_gt_fieldcat ASSIGNING <fs_fieldcat>.
    <fs_fieldcat>-colddictxt = 'M'.
    CASE <fs_fieldcat>-fieldname.
      WHEN 'BUKRS' OR 'ANLN2'.
        <fs_fieldcat>-key       = gc_x.
      WHEN 'ANLN1'.
        <fs_fieldcat>-hotspot   = gc_x.
        <fs_fieldcat>-key       = gc_x.
      WHEN 'BELNR_MM'.
        <fs_fieldcat>-scrtext_m = TEXT-a01.
        <fs_fieldcat>-hotspot   = gc_x.
      WHEN 'BELNR_FI'.
        <fs_fieldcat>-scrtext_m = TEXT-a02.
        <fs_fieldcat>-hotspot   = gc_x.
      WHEN 'MENGE_MM'.
        <fs_fieldcat>-scrtext_m = TEXT-a03.
      WHEN 'MENGE_MM_IMP'.
        <fs_fieldcat>-scrtext_m = TEXT-a10.
      WHEN 'UNID_OC'.
        <fs_fieldcat>-scrtext_m = TEXT-a04.
      WHEN 'DIF_TOTAL'.
        <fs_fieldcat>-scrtext_m = TEXT-a05.
      WHEN 'IMPORTE_DOC'.
        <fs_fieldcat>-scrtext_m = TEXT-a06.
      WHEN 'TOT_IMP_IMP'.
        <fs_fieldcat>-scrtext_m = TEXT-a11.
      WHEN 'DETALLE_IMP'.
        <fs_fieldcat>-scrtext_m = TEXT-a07.
      WHEN 'DIFERENCIA_IMP'.
        <fs_fieldcat>-scrtext_m = TEXT-a08.
      WHEN 'STATUS_OC'.
        <fs_fieldcat>-scrtext_m = TEXT-a09.
      WHEN 'OBSERVAC'.
        <fs_fieldcat>-scrtext_m = TEXT-a12.
      WHEN 'EBELN'.
        <fs_fieldcat>-hotspot   = gc_x.
      WHEN 'WAERS_EKBE' or 'MENGE'.
        <fs_fieldcat>-tech      = gc_x.
*      WHEN 'ANLUE' OR 'KOSTL' OR 'LIFNR' OR 'NAME1' OR 'ZUJHR'.
*        <fs_fieldcat>-tech      = gc_x.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " FIELDCAT_INIT
