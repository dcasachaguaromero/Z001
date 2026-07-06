*----------------------------------------------------------------------*
***INCLUDE LZVFI_REGUHF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REVISAR_ANTES_GRABAR
*&---------------------------------------------------------------------*
FORM revisar_antes_grabar.
  DATA : lw_reguh_paso TYPE zvfi_reguh,
         lw_reguh_modi TYPE zfi_reguh_log,
         lv_correl     TYPE numc4.
  FIELD-SYMBOLS:  <campo> TYPE any.
*
  SELECT * INTO TABLE @DATA(lt_reguh)
         FROM reguh WHERE zbukr        EQ @zvfi_reguh-zbukr
                      AND identif_pago EQ @zvfi_reguh-identif_pago.

  SELECT * INTO TABLE @DATA(lt_dd03l)
        FROM dd03l WHERE tabname EQ 'ZVFI_REGUH'
                         ORDER BY position.
* recorre la tabla interna con los campos que fueron actualizados
  LOOP AT zvfi_reguh_total ASSIGNING FIELD-SYMBOL(<lw_datos>)
                                WHERE action IS NOT INITIAL.
    DATA(lv_index) = line_index( lt_reguh[ zbukr        = <lw_datos>-zbukr
                                           identif_pago = <lw_datos>-identif_pago ] ).
    CHECK lv_index GT 0.
    DATA(lw_reguh) = lt_reguh[ lv_index ].
    MOVE-CORRESPONDING lw_reguh TO lw_reguh_paso.
    CHECK lw_reguh_paso NE zvfi_reguh.
*
    MOVE-CORRESPONDING lw_reguh TO lw_reguh_modi.
    lw_reguh_modi-uname = sy-uname.
    lw_reguh_modi-datum = sy-datum.
    lw_reguh_modi-uzeit = sy-uzeit.
    lv_correl = 0.
    LOOP AT lt_dd03l INTO DATA(wa_dd03l).
      DATA(lv_campo1) = '<lw_datos>-' && wa_dd03l-fieldname.
      ASSIGN (lv_campo1) TO FIELD-SYMBOL(<valor1>).

      DATA(lv_campo2) = 'lw_reguh-'   && wa_dd03l-fieldname.
      ASSIGN (lv_campo2) TO FIELD-SYMBOL(<valor2>).
*
      CHECK <valor1> NE <valor2>.
      ADD 1 TO lv_correl.
      lw_reguh_modi-correl        = lv_correl.
      lw_reguh_modi-campo         = wa_dd03l-fieldname.
      CASE wa_dd03l-datatype.
        WHEN 'DATS'.
          PERFORM fecha_externa USING <valor2>
                                CHANGING lw_reguh_modi-valor_antes.
          PERFORM fecha_externa USING <valor1>
                                CHANGING lw_reguh_modi-valor_despues.
        WHEN OTHERS.
          lw_reguh_modi-valor_antes   = <valor2>.
          lw_reguh_modi-valor_despues = <valor1>.
      ENDCASE.

      MODIFY zfi_reguh_log FROM lw_reguh_modi.
    ENDLOOP.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FECHA_EXTERNA
*&---------------------------------------------------------------------*
FORM fecha_externa  USING    p_fecha
                    CHANGING p_fecha_s.

  CLEAR p_fecha_s.
  CHECK p_fecha IS NOT INITIAL.
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = p_fecha
    IMPORTING
      date_external            = p_fecha_s
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_CLIPBOARD
*&---------------------------------------------------------------------*
FORM upload_clipboard .
  DATA: lt_text  TYPE STANDARD TABLE OF char255,
        ls_text  LIKE LINE OF lt_text,
        lv_tabix TYPE sytabix,
        lv_field TYPE char50,
        lv_row   TYPE sytabix,
        lv_datum TYPE sydatum,
        lv_campo TYPE string.
*
  cl_gui_frontend_services=>clipboard_import(
    IMPORTING
      data                 = lt_text
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3 ).
*
  DESCRIBE TABLE lt_text LINES DATA(lv_lines).
  IF lv_lines GT 0.
*
    GET CURSOR FIELD lv_field.
    GET CURSOR LINE  lv_row.
    DATA(lv_index) = <vim_tctrl>-top_line + lv_row - 1.
    DATA(lv_posic) = line_index( x_namtab[ viewfield = lv_field+11(39) ] ).
    IF lv_posic GT 0.
      DATA(lw_data) = x_namtab[ lv_posic ].
*
      LOOP AT extract FROM lv_index TO lv_lines.
        DATA(lv_sytabix) = sy-tabix.
        lv_campo = 'EXTRACT' && lv_field+10().
        ASSIGN (lv_campo) TO FIELD-SYMBOL(<valor>).
        ADD 1 TO lv_tabix.
        READ TABLE  lt_text INTO ls_text INDEX lv_tabix.
        CHECK sy-subrc EQ 0.
        CASE lw_data-datatype.
          WHEN 'DATS'.
            TRANSLATE ls_text USING '-.'.
            CONDENSE ls_text NO-GAPS.
            CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
              EXPORTING
                date_external            = ls_text
              IMPORTING
                date_internal            = lv_datum
              EXCEPTIONS
                date_external_is_invalid = 1
                OTHERS                   = 2.
            IF sy-subrc <> 0.
* Implement suitable error handling here
            ELSE.
              <valor> = lv_datum.
            ENDIF.
          WHEN OTHERS.
            <valor>        = ls_text.
        ENDCASE.
*
        lv_campo = 'EXTRACT-ACTION'.
        ASSIGN (lv_campo) TO <valor>.
        <valor>        = 'U'.
        MODIFY extract INDEX lv_sytabix.
      ENDLOOP.
      zvfi_reguh_total[] = extract[].
      <status>-upd_flag = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.
