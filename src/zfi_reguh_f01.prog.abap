*&---------------------------------------------------------------------*
*&  Include           ZFI_REGUH_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  AUTORIZACION
*&---------------------------------------------------------------------*
FORM autorizacion .
  AUTHORITY-CHECK OBJECT 'S_TCODE'
    ID 'TCD' FIELD sy-tcode.
  IF sy-subrc <> 0.
    MESSAGE e899(fi) WITH TEXT-e01.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREPARA_DATOS
*&---------------------------------------------------------------------*
FORM prepara_datos .
  DATA : lt_sellist        TYPE TABLE OF vimsellist,
         lt_excl_cua_funct TYPE TABLE OF vimexclfun,
         wa_sellist        TYPE vimsellist,
         wa_excl_cua_funct TYPE vimexclfun,
         lv_view           TYPE dd02v-tabname,
         lr_laufi          TYPE RANGE OF reguh-laufi.
*
  lv_view              = 'ZVFI_REGUH'.
* SELECCION POR IDENTIFICADOR DEL PAGO
  SELECT DISTINCT laufd, laufi, identif_pago INTO TABLE @DATA(lt_identif_pago)
        FROM reguh WHERE zbukr        IN @s_bukrs
                    AND  laufd        IN @s_laufd
                    AND  laufi        IN @s_laufi
                    AND  identif_pago IN @s_idpago
                    AND  xvorl        NE 'X'
                    ORDER BY laufd, laufi.
*
  IF lt_identif_pago[] IS NOT INITIAL.
* SELECCION POR SOCIEDAD
    wa_sellist-viewfield = 'ZBUKR'.
    wa_sellist-operator  = 'EQ'.
    wa_sellist-value     = s_bukrs-low.
    wa_sellist-and_or    = 'AND'.
    APPEND wa_sellist TO lt_sellist.
*
    wa_sellist-viewfield = 'XVORL'.
    wa_sellist-operator  = 'NE'.
    wa_sellist-value     = 'X'.
    wa_sellist-and_or    = 'AND'.
    APPEND wa_sellist TO lt_sellist.
*
    DATA(lt_laufd) = lt_identif_pago[].
    DELETE ADJACENT DUPLICATES FROM lt_laufd COMPARING laufd.
    IF s_laufi[] IS NOT INITIAL.
      DATA(lt_laufi) = lt_identif_pago[].
      SORT lt_laufi BY laufd laufi .
      DELETE ADJACENT DUPLICATES FROM lt_laufi COMPARING laufd laufi.
    ENDIF.
    IF s_idpago[] IS NOT INITIAL.
      DATA(lt_pago) = lt_identif_pago[].
      SORT lt_pago BY laufd laufi identif_pago.
      DELETE ADJACENT DUPLICATES FROM lt_pago COMPARING laufd laufi identif_pago.
    ENDIF.
*
    LOOP AT lt_laufd INTO DATA(lw_laufd).
* Fecha en la que debe ejecutarse el programa
      wa_sellist-viewfield = 'LAUFD'.
      wa_sellist-operator  = 'EQ'.
      wa_sellist-value     = |{ lw_laufd-laufd DATE = USER }|.
      IF s_laufi[] IS NOT INITIAL.
        wa_sellist-and_or    = 'AND'.
      ELSE.
        wa_sellist-and_or    = 'OR'.
      ENDIF.
      APPEND wa_sellist TO lt_sellist.
*
      LOOP AT lt_laufi INTO DATA(lw_laufi) WHERE laufd EQ lw_laufd-laufd.
* Fecha en la que debe ejecutarse el programa
        wa_sellist-viewfield = 'LAUFI'.
        wa_sellist-operator  = 'EQ'.
        wa_sellist-value     = lw_laufi-laufi.
        IF s_idpago[] IS NOT INITIAL.
          wa_sellist-and_or    = 'AND'.
        ELSE.
          wa_sellist-and_or    = 'OR'.
        ENDIF.
        APPEND wa_sellist TO lt_sellist.
*
        LOOP AT lt_pago INTO DATA(wa_identif_pago) WHERE laufd EQ lw_laufd-laufd
                                                     AND laufi EQ lw_laufd-laufi.
          wa_sellist-viewfield = 'IDENTIF_PAGO'.
          wa_sellist-operator  = 'EQ'.
          wa_sellist-value     = wa_identif_pago-identif_pago.
          wa_sellist-and_or    = 'OR'.
          APPEND wa_sellist TO lt_sellist.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
**
*    LOOP AT lt_identif_pago INTO DATA(wa_identif_pago).
** Fecha en la que debe ejecutarse el programa
*      wa_sellist-viewfield = 'LAUFD'.
*      wa_sellist-operator  = 'EQ'.
*      wa_sellist-value     = |{ wa_identif_pago-laufd DATE = USER }|.
*      wa_sellist-and_or    = 'AND'.
*      APPEND wa_sellist TO lt_sellist.
** Característica de identificación adicional
*      wa_sellist-viewfield = 'LAUFI'.
*      wa_sellist-operator  = 'EQ'.
*      wa_sellist-value     = wa_identif_pago-laufi.
*      IF s_idpago[] IS NOT INITIAL.
*        wa_sellist-and_or    = 'AND'.
*      ELSE.
*        wa_sellist-and_or    = 'OR'.
*      ENDIF.
*      APPEND wa_sellist TO lt_sellist.
*
*      IF s_idpago[] IS NOT INITIAL.
*        wa_sellist-viewfield = 'IDENTIF_PAGO'.
*        wa_sellist-operator  = 'EQ'.
*        wa_sellist-value     = wa_identif_pago-identif_pago.
*        wa_sellist-and_or    = 'OR'.
*        APPEND wa_sellist TO lt_sellist.
*      ENDIF.
*    ENDLOOP.
    DESCRIBE TABLE lt_sellist LINES sy-tabix.
    CLEAR wa_sellist-and_or.
    MODIFY lt_sellist FROM wa_sellist INDEX sy-tabix.
*
    wa_excl_cua_funct-function = 'NEWL'.
    APPEND wa_excl_cua_funct TO lt_excl_cua_funct.
    wa_excl_cua_funct-function = 'DELE'.
    APPEND wa_excl_cua_funct TO lt_excl_cua_funct.
    wa_excl_cua_funct-function = 'KOPE'.
    APPEND wa_excl_cua_funct TO lt_excl_cua_funct.
*
* MUESTRA TABLA
    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        action            = 'U'
        view_name         = lv_view
        suppress_wa_popup = 'X'
      TABLES
        dba_sellist       = lt_sellist
        excl_cua_funct    = lt_excl_cua_funct.
  ELSE.
    MESSAGE i899(fi) WITH 'Sin datos seleccionados'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F4_LAUFD
*&---------------------------------------------------------------------*
FORM f4_laufd  CHANGING p_s_laufd.
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
  CALL FUNCTION 'F4_ZAHLLAUF'
    EXPORTING
      f1typ            = 'D'
*     f2nme            = 'P_LAUFI'
    IMPORTING
      laufd            = p_s_laufd
      laufi            = lv_laufi
      nothing_selected = xf4_c1
    TABLES
      laufk            = tlaufk.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F4_LAUFI
*&---------------------------------------------------------------------*
FORM f4_laufi  CHANGING p_s_laufi.
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
      laufi            = p_s_laufi
      nothing_selected = xf4_c1
    TABLES
      laufk            = tlaufk.
ENDFORM.
