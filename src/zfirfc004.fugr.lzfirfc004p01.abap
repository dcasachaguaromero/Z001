*&---------------------------------------------------------------------*
*&  Include           LZFIRFC004P01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS lcl_bdc IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_bdc IMPLEMENTATION.

  METHOD  new_data.
    CLEAR: gt_bdcdata.
  ENDMETHOD.

  METHOD add_dynpro.
    APPEND INITIAL LINE TO gt_bdcdata ASSIGNING FIELD-SYMBOL(<ls_bdc_data>).
    <ls_bdc_data>-program  = iv_program.
    <ls_bdc_data>-dynpro   = iv_dynpro.
    <ls_bdc_data>-dynbegin = abap_true.
  ENDMETHOD.

  METHOD add_field.

    IF NOT iv_value IS INITIAL.
      APPEND INITIAL LINE TO gt_bdcdata ASSIGNING FIELD-SYMBOL(<ls_bdc_data>).
      <ls_bdc_data>-fnam = iv_field.
      IF iv_value <> '\'.
        <ls_bdc_data>-fval = iv_value.
      ELSE.
        <ls_bdc_data>-fval = ' '.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD call_transaction.

    DATA: lt_messtab TYPE tab_bdcmsgcoll.

    CLEAR: ev_rc, es_retcode.

    CALL TRANSACTION iv_tcode WITHOUT AUTHORITY-CHECK
      USING gt_bdcdata
      MODE iv_mode
      UPDATE iv_update
      MESSAGES INTO lt_messtab.

    READ TABLE lt_messtab ASSIGNING FIELD-SYMBOL(<ls_messtab>)
      WITH KEY msgtyp = 'S'
               msgid  = 'F5'
               msgnr  = '312'.
    IF sy-subrc = 0.
      ev_rc = 0.
      es_retcode-type = <ls_messtab>-msgtyp.
      es_retcode-id = <ls_messtab>-msgid.
      es_retcode-number = <ls_messtab>-msgnr.
      es_retcode-message_v1 = <ls_messtab>-msgv1.
      es_retcode-message_v2 = <ls_messtab>-msgv2.
      MESSAGE ID <ls_messtab>-msgid TYPE <ls_messtab>-msgtyp NUMBER <ls_messtab>-msgnr
        WITH <ls_messtab>-msgv1 <ls_messtab>-msgv2
        INTO es_retcode-message.
    ELSE.
      READ TABLE lt_messtab ASSIGNING <ls_messtab> WITH KEY msgtyp = 'E'.
      IF sy-subrc <> 0.
        READ TABLE lt_messtab ASSIGNING <ls_messtab> WITH KEY msgtyp = 'S'
                                                              msgid = '00'.
        IF sy-subrc <> 0.
          READ TABLE lt_messtab ASSIGNING <ls_messtab> WITH KEY msgtyp = 'S'.
        ENDIF.
      ENDIF.
*      LOOP AT lt_messtab ASSIGNING <ls_messtab> WHERE msgtyp <> 'W'.
*        IF sy-subrc = 0.
      es_retcode-type = <ls_messtab>-msgtyp.
      es_retcode-id = <ls_messtab>-msgid.
      es_retcode-number = <ls_messtab>-msgnr.
      es_retcode-message_v1 = <ls_messtab>-msgv1.
      es_retcode-message_v2 = <ls_messtab>-msgv2.
      MESSAGE ID <ls_messtab>-msgid TYPE <ls_messtab>-msgtyp NUMBER <ls_messtab>-msgnr
        WITH <ls_messtab>-msgv1 <ls_messtab>-msgv2
        INTO es_retcode-message.
*        ENDIF.
      ev_rc = 8.
*        EXIT.
*      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
