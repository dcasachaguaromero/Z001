*&---------------------------------------------------------------------*
*&  Include           ZMM_MONITOR_STOCK_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  TYPES : BEGIN OF ty_s033,
            matnr TYPE s033-matnr,
            werks TYPE s033-werks,
            lgort TYPE s033-lgort,
            sptag TYPE s033-sptag,
            mgvbr TYPE s033-mgvbr,
            mblnr TYPE s033-mblnr,
          END OF ty_s033,
          tty_s033 TYPE STANDARD TABLE OF ty_s033 WITH EMPTY KEY.
  DATA : lt_s033    TYPE SORTED TABLE OF ty_s033 WITH UNIQUE KEY matnr werks lgort sptag mblnr,
         lw_s033    TYPE ty_s033,
         lr_sptag3  TYPE RANGE OF s033-sptag,
         lr_sptag6  TYPE RANGE OF s033-sptag,
         lr_sptag24 TYPE RANGE OF s033-sptag,
         lr_mjahr   TYPE RANGE OF mseg-mjahr,
         lw_sptag   LIKE LINE OF lr_sptag3,
         lv_date    TYPE sydatum,
         lv_magbb3  TYPE s033-mgvbr,
         lv_magbb6  TYPE s033-mgvbr,
         lv_fecha   TYPE sy-datum,
         lv_mes3    TYPE p DECIMALS 2,
         lv_mes6    TYPE p DECIMALS 2.
  CONSTANTS : lc_const1 TYPE p DECIMALS 2 VALUE '1.2',
              lc_const2 TYPE p DECIMALS 2 VALUE '0.8'.
* Ultimo día del mes anterior
  lv_fecha = sy-datum(6) && '01'.
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = lv_fecha
      days      = 1
      months    = 0
      signum    = '-'
      years     = 0
    IMPORTING
      calc_date = lv_fecha.
* rango de 3 meses
  PERFORM   calcula_meses USING    lv_fecha
                                   2
                          CHANGING lv_date.
  lw_sptag-sign = 'I'.                   lw_sptag-option = 'BT'.
  lw_sptag-low  = lv_date(6) && '01'.    lw_sptag-high   = lv_fecha.
  APPEND lw_sptag TO lr_sptag3.
* rango de 6 meses
  CLEAR lw_sptag.
  PERFORM calcula_meses USING    lv_fecha
                                 5
                        CHANGING lv_date.
  lw_sptag-sign = 'I'.        lw_sptag-option = 'BT'.
  lw_sptag-low  = lv_date(6) && '01'.    lw_sptag-high   = lv_fecha.
  APPEND lw_sptag TO lr_sptag6.
* rango de 24 meses
  CLEAR lw_sptag.
  PERFORM calcula_meses USING    lv_fecha
                                 24
                        CHANGING lv_date.
  lw_sptag-sign = 'I'.        lw_sptag-option = 'BT'.
  lw_sptag-low  = lv_date(6) && '01'.    lw_sptag-high   = lv_fecha.
  APPEND lw_sptag TO lr_sptag24.
*
  lr_mjahr = VALUE #( sign = 'I' option = 'BT'
                      ( low  = lv_date(4)
                        high = lv_fecha(4) ) ).
*
  SELECT mard~matnr, mard~werks, mard~lgort, mard~labst, mara~meins,
         mara~mtart, makt~maktx INTO TABLE @DATA(lt_mater)
         FROM mard INNER JOIN mara
              ON mard~matnr EQ mara~matnr
                   INNER JOIN makt
              ON mara~matnr EQ makt~matnr
             WHERE mard~matnr IN @s_matnr
               AND mard~werks IN @s_werks
               AND mard~lgort IN @s_lgort
               AND mara~mtart IN @s_mtart
               AND makt~spras EQ @sy-langu.
  CHECK sy-subrc EQ 0.

  SELECT werks_i, lgort_i, matnr_i, budat INTO TABLE @DATA(lt_mseg)
        FROM wb2_v_mkpf_mseg2 FOR ALL ENTRIES IN @lt_mater
                  WHERE matnr_i     EQ @lt_mater-matnr
                   AND  werks_i     EQ @lt_mater-werks
                   AND  lgort_i     EQ @lt_mater-lgort
                   AND  bwart_i     IN @s_bwart.
  SORT lt_mseg BY werks_i lgort_i matnr_i budat DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_mseg COMPARING werks_i lgort_i matnr_i .

* Estadística: Movimientos de stocks actuales (Reg. indiv.)
  SELECT s033~matnr s033~werks s033~lgort s033~sptag s033~mgvbr s033~mblnr
         INTO TABLE lt_s033
         FROM s033 INNER JOIN mseg
             ON s033~mblnr EQ mseg~mblnr AND
                s033~matnr EQ mseg~matnr AND
                s033~werks EQ mseg~werks AND
                s033~lgort EQ mseg~lgort
                FOR ALL ENTRIES IN lt_mater
                   WHERE s033~matnr EQ lt_mater-matnr
                    AND  s033~werks EQ lt_mater-werks
                    AND  s033~lgort EQ lt_mater-lgort
                    AND  s033~sptag IN lr_sptag6
                    AND  mseg~mjahr IN lr_mjahr
                    AND mseg~bwart  IN s_bwart.
  IF sy-subrc EQ 0.
* Acumula por 3 mess
    READ TABLE lr_sptag3 INTO lw_sptag INDEX 1.
    DATA(lt_mes3) = REDUCE tty_s033( INIT cline = VALUE tty_s033( )
                          FOR GROUPS <group_key> OF <g> IN lt_s033
                          GROUP BY ( matnr = <g>-matnr
                                     werks = <g>-werks
                                     lgort = <g>-lgort )
                          NEXT cline = VALUE #(
                                       BASE cline ( matnr = <group_key>-matnr
                                                    werks = <group_key>-werks
                                                    lgort = <group_key>-lgort
                                                    mgvbr = REDUCE mgvbr(
                                      INIT val1 TYPE mgvbr
                                      FOR wa IN
                                      FILTER #( lt_s033 WHERE matnr = <group_key>-matnr
                                                          AND werks = <group_key>-werks
                                                          AND lgort = <group_key>-lgort
                                                          AND sptag >= lw_sptag-low )
                                      NEXT val1 = val1 + wa-mgvbr ) ) ) ) .
* Acumula por 6 mess
    READ TABLE lr_sptag6 INTO lw_sptag INDEX 1.
    DATA(lt_mes6) = REDUCE tty_s033( INIT cline = VALUE tty_s033( )
                          FOR GROUPS <group_key> OF <g> IN lt_s033
                          GROUP BY ( matnr = <g>-matnr
                                     werks = <g>-werks
                                     lgort = <g>-lgort )
                          NEXT cline = VALUE #(
                                       BASE cline ( matnr = <group_key>-matnr
                                                    werks = <group_key>-werks
                                                    lgort = <group_key>-lgort
                                                    mgvbr = REDUCE mgvbr(
                                      INIT val1 TYPE mgvbr
                                       FOR wa IN
                                       FILTER #( lt_s033 WHERE matnr = <group_key>-matnr
                                                           AND werks = <group_key>-werks
                                                           AND lgort = <group_key>-lgort
                                                           AND sptag >= lw_sptag-low )
                                      NEXT val1 = val1 + wa-mgvbr  ) ) ) ) .
  ENDIF.
*
  LOOP AT lt_mater INTO DATA(lw_mater).
    MOVE-CORRESPONDING lw_mater TO wa_salida.
* valor del mes 3
    DATA(lv_index) = line_index( lt_mes3[ matnr     = wa_salida-matnr
                                          werks     = wa_salida-werks
                                          lgort     = wa_salida-lgort ] ).
    IF lv_index GT 0.
      lv_mes3             = lt_mes3[ lv_index ]-mgvbr   / 3.
      wa_salida-s033_mes3 = lt_mes3[ lv_index ]-mgvbr .
    ENDIF.
* valor del mes 6
    lv_index = line_index( lt_mes6[ matnr     = wa_salida-matnr
                                    werks     = wa_salida-werks
                                    lgort     = wa_salida-lgort ] ).
    IF lv_index GT 0.
      lv_mes6              = lt_mes6[ lv_index ]-mgvbr / 6.
      wa_salida-s033_mes6  = lt_mes6[ lv_index ]-mgvbr.
    ENDIF.
* verifica que valor es mayor para hacer la operacion
    IF lv_mes3 GE lv_mes6.
      wa_salida-stock_minimo = lc_const1 * lv_mes3.
      DATA(lv_mes)           = lv_mes3.
    ELSE.
      wa_salida-stock_minimo = lc_const1 * lv_mes6.
      lv_mes                 = lv_mes6.
    ENDIF.
*
    wa_salida-stock_critico = wa_salida-stock_minimo + ( lc_const2 * lv_mes ).
*
    wa_salida-stock_maximo  = wa_salida-stock_minimo + ( lc_const1 * lv_mes ).
*
    IF wa_salida-labst         EQ 0 AND wa_salida-stock_minimo EQ 0 AND
       wa_salida-stock_critico EQ 0 AND wa_salida-stock_maximo EQ 0.
      wa_salida-alerta = 'Sin Movimiento'.
    ELSEIF wa_salida-labst LE wa_salida-stock_minimo.
      wa_salida-alerta = 'Comprar Urgente'.
    ELSEIF wa_salida-labst GT wa_salida-stock_minimo AND
           wa_salida-labst LT wa_salida-stock_critico.
      wa_salida-alerta = 'Revisar'.
    ELSEIF wa_salida-labst GT wa_salida-stock_maximo.
      wa_salida-alerta = 'Sobre Stock'.
    ELSEIF wa_salida-labst LE wa_salida-stock_maximo AND
           wa_salida-labst GE wa_salida-stock_critico.
      wa_salida-alerta = 'OK'.
    ENDIF.
* fecha de SM
    lv_index = line_index( lt_mseg[ werks_i     = wa_salida-werks
                                    lgort_i     = wa_salida-lgort
                                    matnr_i     = wa_salida-matnr ] ).
    IF lv_index GT 0.
      wa_salida-fecha_sm = |{ lt_mseg[ lv_index ]-budat DATE = USER }|.
    ENDIF.
*
    APPEND wa_salida TO gt_salida.
    CLEAR : wa_salida, lv_mes3, lv_mes6, lv_mes.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALCULA_MESES
*&---------------------------------------------------------------------*
FORM calcula_meses  USING    p_lv_fecha
                             VALUE(p_meses)
                    CHANGING p_lv_date.

  CLEAR p_lv_date.
  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = p_lv_fecha
      days      = 0
      months    = p_meses
      signum    = '-'
      years     = 0
    IMPORTING
      calc_date = p_lv_date.
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
  wa_sort-fieldname = 'MATNR'.
  wa_sort-up        = gc_x.
  APPEND wa_sort TO p_it_sort.

  wa_sort-fieldname = 'MAKTX'.
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
    CASE <fieldcat>-fieldname.
      WHEN 'MATNR' OR 'WERKS' OR 'LGORT' OR 'MAKTX'.
        <fieldcat>-key        = gc_x.
      WHEN 's033_MES3'.
        <fieldcat>-no_out     = gc_x.
        <fieldcat>-seltext    = 'Valor 3M'.
      WHEN 's033_MES6'.
        <fieldcat>-no_out     = gc_x.
        <fieldcat>-seltext    = 'Valor 6M'.
    ENDCASE.
    <fieldcat>-colddictxt     = 'M'.
  ENDLOOP.
ENDFORM.
