*&---------------------------------------------------------------------*
*&  Include           ZFI_F110_MOT_EMIS_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LEE_MEMORY_F110
*&---------------------------------------------------------------------*
FORM lee_memory_f110 .
  DATA fbtch(2) TYPE n.
*
*  CLEAR reguh.
*  IMPORT reguh-laufd reguh-laufi reguh-zbukr reguh-absbu fbtch
*         FROM MEMORY ID 'FBZ0CALL'.
*  IF reguh IS NOT INITIAL.
*    p_zbukr = reguh-zbukr.
*    p_laufd = reguh-laufd.
*    p_laufi = reguh-laufi.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  HELP_LAUFD
*&---------------------------------------------------------------------*
FORM help_laufd CHANGING p_laufd.
  DATA:    BEGIN OF tlaufk OCCURS 1.
             INCLUDE STRUCTURE ilaufk.
           DATA:    END OF tlaufk,
           xf4_c1(1) TYPE c,
           lv_laufi  TYPE f110v-laufi.
*
  REFRESH tlaufk.
  tlaufk-laufk = space.
  tlaufk-sign  = 'I'.
  APPEND tlaufk.
*
  CALL FUNCTION 'F4_ZAHLLAUF'
    EXPORTING
      f1typ            = 'D'
*     f2nme            = 'S_LAUFI-LOW'
    IMPORTING
      laufd            = p_laufd
      laufi            = lv_laufi
      nothing_selected = xf4_c1
    TABLES
      laufk            = tlaufk.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  HELP_LAUFI
*&---------------------------------------------------------------------*
FORM help_laufi CHANGING p_laufi.
  DATA:    BEGIN OF tlaufk OCCURS 1.
             INCLUDE STRUCTURE ilaufk.
           DATA:    END OF tlaufk,
           xf4_c1(1) TYPE c,
           lv_laufd  TYPE f110v-laufd.
*
  REFRESH tlaufk.
  tlaufk-laufk = space.
  tlaufk-sign  = 'I'.
  APPEND tlaufk.
  CALL FUNCTION 'F4_ZAHLLAUF'
    EXPORTING
      f1typ            = 'I'
      f2nme            = 'S_LAUFD-LOW'
    IMPORTING
      laufd            = lv_laufd
      laufi            = p_laufi
      nothing_selected = xf4_c1
    TABLES
      laufk            = tlaufk.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDA_SELECCION
*&---------------------------------------------------------------------*
FORM valida_seleccion .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESA_DATOS
*&---------------------------------------------------------------------*
FORM procesa_datos .
  DATA: lt_bdcdata_tab    TYPE TABLE OF bdcdata,
        lt_itab           TYPE TABLE OF bdcmsgcoll,
        lw_opt            TYPE ctu_params,
        lx_auth_check     TYPE REF TO cx_root,
        l_auth_check_text TYPE string.
*
  IF p_f110 EQ gc_x. " IS INITIAL.
*    zw_laufd = p_laufd.
*    zw_laufi = p_laufi.
    s_laufd = VALUE #( sign = 'I' option = 'EQ'
                       low  = zw_laufd ).

    s_laufi = VALUE #( sign = 'I' option = 'EQ'
                       low  = zw_laufi ).
  ENDIF.
*
  SELECT DISTINCT laufd, laufi, zbukr, vblnr, zaldt, absbu, zzmot_emis
        INTO TABLE @DATA(lt_datos)
        FROM zv_mot_emis WHERE laufd IN @s_laufd
                          AND  laufi IN @s_laufi
                          AND  zbukr IN @zw_zbukr
                          AND  absbu IN @zw_absbu.
  SORT lt_datos BY laufd laufi zbukr vblnr.
*
  LOOP AT lt_datos INTO DATA(wa_datos).
    CLEAR : lt_bdcdata_tab[], lt_itab[].
*
    lt_bdcdata_tab = VALUE #(
      ( program  = 'SAPMF05L'     dynpro = '0102' dynbegin = 'X' )
      ( fnam = 'RF05L-BELNR'      fval   = wa_datos-vblnr    )
      ( fnam = 'RF05L-BUKRS'      fval   = wa_datos-zbukr    )
      ( fnam = 'RF05L-GJAHR'      fval   = wa_datos-zaldt(4) )
      ( fnam = 'RF05L-BUZEI'      fval   = ''                )
      ( fnam = 'RF05L-XKKRE'      fval   = 'X'               )
      ( fnam = 'BDC_OKCODE'       fval   = '/00'             )

      ( program  = 'SAPMF05L'     dynpro = '0302' dynbegin = 'X' )
      ( fnam = 'BSEG-SGTXT'       fval   = '.'               )
      ( fnam = 'BDC_OKCODE'       fval   = '=ZK'             )

      ( program  = 'SAPMF05L'     dynpro = '1302' dynbegin = 'X' )
      ( fnam = 'BSEG-ZZMOT_EMIS'  fval   = wa_datos-zzmot_emis   )
      ( fnam = 'BDC_OKCODE'       fval   = '=ENTR'               )

      ( program  = 'SAPMF05L'     dynpro = '0302' dynbegin = 'X' )
      ( fnam = 'BDC_OKCODE'       fval   = '=AE'               )
                         ).

    lw_opt-dismode = p_mode.
    lw_opt-defsize = 'X'.

    TRY.
        CALL TRANSACTION 'FB09' WITH AUTHORITY-CHECK
                                USING lt_bdcdata_tab OPTIONS FROM lw_opt
                                MESSAGES INTO lt_itab.
*
        MOVE-CORRESPONDING wa_datos TO wa_salida.
*
        READ TABLE lt_itab WITH KEY msgtyp = 'E' TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          wa_salida-mensaje = 'Documento Modificado'.
        ELSE.
          wa_salida-mensaje = 'Documento NO Modificado:'.
          LOOP AT lt_itab INTO DATA(wa_itab) WHERE msgtyp EQ 'E'.
            MESSAGE ID     wa_itab-msgid
                    TYPE   wa_itab-msgtyp
                    NUMBER wa_itab-msgnr
                    WITH   wa_itab-msgv1 wa_itab-msgv2 wa_itab-msgv3 wa_itab-msgv4
                    INTO   DATA(lv_mens).

            CONCATENATE wa_salida-mensaje lv_mens INTO
                        wa_salida-mensaje SEPARATED BY '/'.
          ENDLOOP.
        ENDIF.
        APPEND wa_salida TO gt_salida.
*
      CATCH cx_sy_authorization_error INTO lx_auth_check.
*     Authorization missing for user when executing transaction
        l_auth_check_text = lx_auth_check->get_text( ).

    ENDTRY.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESA_DATOS_FUNCION
*&---------------------------------------------------------------------*
FORM procesa_datos_funcion .
  DATA: lr_laufd TYPE RANGE OF f110v-laufd,
        lr_laufi TYPE RANGE OF f110v-laufi,
        lr_bukrs TYPE RANGE OF zv_mot_emis-zbukr.
* copia desde LJ1AETOP - LJ1AEF02
  DATA: change_bkdf TYPE STANDARD TABLE OF bkdf INITIAL SIZE 1 WITH HEADER LINE,
        change_bkpf TYPE STANDARD TABLE OF bkpf INITIAL SIZE 1 WITH HEADER LINE,
        change_bsec TYPE STANDARD TABLE OF bsec INITIAL SIZE 1 WITH HEADER LINE,
        change_bsed TYPE STANDARD TABLE OF bsed INITIAL SIZE 1 WITH HEADER LINE,
        change_bseg TYPE STANDARD TABLE OF bseg INITIAL SIZE 1 WITH HEADER LINE,
        change_bset TYPE STANDARD TABLE OF bset INITIAL SIZE 1 WITH HEADER LINE.
*
  IF p_f110 EQ gc_x. "IS INITIAL.
    lr_laufd = VALUE #( sign = 'I' option = 'BT'
                        ( low  = zw_laufd high = zw_laufd  ) ).
    lr_laufi = VALUE #( sign = 'I' option = 'BT'
                        ( low  = zw_laufi high = zw_laufi  ) ).
    lr_bukrs[] = zw_zbukr[].
  ELSE.
    lr_laufd[] = s_laufd[].
    lr_laufi[] = s_laufi[].
    lr_bukrs[] = s_bukrs[].
  ENDIF.
*
  SELECT DISTINCT laufd, laufi, zbukr, vblnr, zaldt, absbu, zzmot_emis, xref1
        INTO TABLE @DATA(lt_datos)
        FROM zv_mot_emis WHERE laufd IN @lr_laufd
                          AND  laufi IN @lr_laufi
                          AND  zbukr IN @lr_bukrs
                          AND  absbu IN @zw_absbu.
  SORT lt_datos BY laufd laufi zbukr vblnr.
  LOOP AT lt_datos INTO DATA(wa_datos) WHERE zzmot_emis NE space.

    MOVE-CORRESPONDING wa_datos TO wa_salida.
*  lectura de cabecera del documento
    SELECT SINGLE * INTO @DATA(lw_bkpf)
           FROM bkpf  WHERE bukrs = @wa_datos-zbukr
                        AND gjahr = @wa_datos-zaldt(4)
                        AND belnr = @wa_datos-vblnr.
    IF sy-subrc EQ 0.
      REFRESH: change_bkpf,
               change_bkdf,
               change_bseg,
               change_bsec,
               change_bsed,
               change_bset.
*
      change_bkpf       = lw_bkpf.
      change_bkpf-aedat = sy-datum.
      APPEND change_bkpf.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM bkdf INTO TABLE change_bkdf
*                         WHERE bukrs EQ lw_bkpf-bukrs
*                           AND belnr EQ lw_bkpf-belnr
*                           AND gjahr EQ lw_bkpf-gjahr.
*
* NEW CODE
      SELECT *
 FROM bkdf INTO TABLE change_bkdf
                         WHERE bukrs EQ lw_bkpf-bukrs
                           AND belnr EQ lw_bkpf-belnr
                           AND gjahr EQ lw_bkpf-gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM bseg INTO TABLE change_bseg
*                         WHERE bukrs EQ lw_bkpf-bukrs
*                           AND belnr EQ lw_bkpf-belnr
*                           AND gjahr EQ lw_bkpf-gjahr.
*
* NEW CODE
      SELECT *
 FROM bseg INTO TABLE change_bseg
                         WHERE bukrs EQ lw_bkpf-bukrs
                           AND belnr EQ lw_bkpf-belnr
                           AND gjahr EQ lw_bkpf-gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM bsec INTO TABLE change_bsec
*                         WHERE bukrs EQ lw_bkpf-bukrs
*                           AND belnr EQ lw_bkpf-belnr
*                           AND gjahr EQ lw_bkpf-gjahr.
*
* NEW CODE
      SELECT *
 FROM bsec INTO TABLE change_bsec
                         WHERE bukrs EQ lw_bkpf-bukrs
                           AND belnr EQ lw_bkpf-belnr
                           AND gjahr EQ lw_bkpf-gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM bsed INTO TABLE change_bsed
*                         WHERE bukrs EQ lw_bkpf-bukrs
*                           AND belnr EQ lw_bkpf-belnr
*                           AND gjahr EQ lw_bkpf-gjahr.
*
* NEW CODE
      SELECT *
 FROM bsed INTO TABLE change_bsed
                         WHERE bukrs EQ lw_bkpf-bukrs
                           AND belnr EQ lw_bkpf-belnr
                           AND gjahr EQ lw_bkpf-gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM bset INTO TABLE change_bset
*                         WHERE bukrs EQ lw_bkpf-bukrs
*                           AND belnr EQ lw_bkpf-belnr
*                           AND gjahr EQ lw_bkpf-gjahr.
*
* NEW CODE
      SELECT *
 FROM bset INTO TABLE change_bset
                         WHERE bukrs EQ lw_bkpf-bukrs
                           AND belnr EQ lw_bkpf-belnr
                           AND gjahr EQ lw_bkpf-gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*
      LOOP AT change_bseg ASSIGNING FIELD-SYMBOL(<bseg>).
        <bseg>-zzmot_emis = wa_datos-zzmot_emis.
        <bseg>-xref1      = wa_datos-xref1.
      ENDLOOP.
*   Update FI document
      CALL FUNCTION 'CHANGE_DOCUMENT'
        TABLES
          t_bkdf = change_bkdf
          t_bkpf = change_bkpf
          t_bsec = change_bsec
          t_bsed = change_bsed
          t_bseg = change_bseg
          t_bset = change_bset
        EXCEPTIONS
          OTHERS = 1.
      IF sy-subrc EQ 0.
        wa_salida-mensaje = 'Documento Modificado'.
      ELSE.
        wa_salida-mensaje = 'Documento NO Modificado:'.
      ENDIF.
    ELSE.
      wa_salida-mensaje   = 'Documento NO Encontrado:'.
    ENDIF.
    APPEND wa_salida TO gt_salida.
  ENDLOOP.
  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: lt_fieldcat TYPE lvc_t_fcat,
        wa_layout   TYPE lvc_s_layo.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM fieldcat_init   USING lt_fieldcat[].
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
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
  DATA : l_getfeld  TYPE  t354s-initfield,
         l_getvalue TYPE  t354s-initfield,
         ti_iobject TYPE TABLE OF iopick.
*
  CASE rs_selfield-fieldname.
    WHEN 'VBLNR'.
      IF rs_selfield-value IS NOT INITIAL.
        READ TABLE gt_salida INTO wa_salida INDEX rs_selfield-tabindex.
        SET PARAMETER ID : 'BLN' FIELD wa_salida-vblnr,
                           'BUK' FIELD wa_salida-zbukr,
                           'GJR' FIELD wa_salida-zaldt(04).
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA: lt_fcode_attrib_tab TYPE TABLE OF smp_dyntxt.
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
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
  DATA : gs_fieldcat TYPE lvc_s_fcat.
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

  LOOP AT p_gt_fieldcat ASSIGNING FIELD-SYMBOL(<campos>).
    CASE <campos>-fieldname.
      WHEN 'LAUFD' OR 'LAUFI'.
        <campos>-key     = gc_x.
      WHEN 'VBLNR'.
        <campos>-hotspot = gc_x.
      WHEN 'BELNR_B' OR 'BUKRS_B' OR 'GJHAR_B' OR 'BUZEI_B'.
        <campos>-tech = gc_x.
    ENDCASE.
    <campos>-colddictxt = 'M'.
  ENDLOOP.
ENDFORM.
