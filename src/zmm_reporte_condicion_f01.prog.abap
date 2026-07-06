*&---------------------------------------------------------------------*
*&  Include           ZMM_REPORTE_CONDICION_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  DATA : lv_kappl TYPE kappl VALUE 'M',
         lv_kschl TYPE kschl VALUE 'PB00'.
* sacado del programa RV13AABS
  IF p_datam IS INITIAL.
    p_datam = '00000101'.
    p_datbi = '99991231'.
    MESSAGE s023(vj).
  ENDIF.
  IF NOT p_datbi IS INITIAL AND p_datbi < p_datam.
    p_datbi =  p_datam.
    MESSAGE s022(vj).
  ENDIF.
*
  SELECT kschl, lifnr, matnr, ekorg, esokz, datbi, datab, knumh
    FROM a018 INTO TABLE @DATA(lt_a018)
    WHERE kappl EQ @lv_kappl
      AND kschl EQ @lv_kschl
      AND lifnr IN @s_lifnr
      AND matnr IN @s_matnr
      AND ekorg IN @s_ekorg
      AND esokz IN @s_esokz.
*      AND datab LE @p_datam
*      AND datbi GE @p_datam.

  CHECK sy-subrc EQ 0.
  SORT lt_a018 BY lifnr matnr ekorg esokz datbi.
  IF p_datbi IS INITIAL.
    DELETE lt_a018
      WHERE ( datab > p_datam OR datbi < p_datam ).
  ELSE.
    DELETE lt_a018
      WHERE ( datab > p_datam OR datbi < p_datam )
        AND ( datab < p_datam OR datab > p_datbi ).
  ENDIF.
*
  SELECT knumh, kopos, kschl, kbetr, konwa, kpein, kmein, krech, loevm_ko
         FROM konp INTO TABLE @DATA(lt_konp)
         FOR ALL ENTRIES IN @lt_a018 WHERE
                  knumh = @lt_a018-knumh AND
                  kschl = @lt_a018-kschl.
  LOOP AT lt_a018 INTO DATA(lw_a018).
    CLEAR wa_salida.
    DATA(lv_index) = line_index( lt_konp[ knumh = lw_a018-knumh
                                          kopos = '01'
                                          kschl = lw_a018-kschl ] ).
    CHECK lv_index GT 0.
    DATA(ls_konp) = lt_konp[ lv_index ].
    MOVE-CORRESPONDING lw_a018 TO wa_salida.
    MOVE-CORRESPONDING ls_konp TO wa_salida.
    wa_salida-fecha = p_datam.
    APPEND wa_salida TO gt_salida.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUETRA_DATOS
*&---------------------------------------------------------------------*
FORM muetra_datos .
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
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
      it_sort_lvc              = lt_sort
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
  ADD 1 TO wa_sort-spos.
  wa_sort-fieldname = 'KSCHL'.
  wa_sort-up        = gc_x.
  APPEND wa_sort TO p_it_sort.
*
  ADD 1 TO wa_sort-spos.
  wa_sort-fieldname = 'LIFNR'.
  wa_sort-up        = gc_x.
  APPEND wa_sort TO p_it_sort.
*
  ADD 1 TO wa_sort-spos.
  wa_sort-fieldname = 'MATNR'.
  wa_sort-up        = gc_x.
  APPEND wa_sort TO p_it_sort.
*
  ADD 1 TO wa_sort-spos.
  wa_sort-fieldname = 'EKORG'.
  wa_sort-up        = gc_x.
  APPEND wa_sort TO p_it_sort.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
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
*
  LOOP AT p_gt_fieldcat ASSIGNING FIELD-SYMBOL(<fieldcat>).
    <fieldcat>-colddictxt     = 'M'.
    CASE <fieldcat>-fieldname.
      WHEN 'MATNR' OR 'LIFNR' OR 'EKORG' OR 'KSCHL'.
        <fieldcat>-key        = gc_x.
      WHEN 'DATBI' OR 'DATAB'.
        <fieldcat>-colddictxt     = 'L'.
    ENDCASE.

  ENDLOOP.
ENDFORM.
