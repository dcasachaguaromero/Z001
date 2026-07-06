*&---------------------------------------------------------------------*
*&  Include           ZFI_CRE_ABONOS_TBK_F01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                  Form NEW_DATA
*----------------------------------------------------------------------*
FORM new_data.

  CLEAR: gt_bdcdata.

ENDFORM.                    "new_data


*----------------------------------------------------------------------*
*                  Form ADD_DYNPRO
*----------------------------------------------------------------------*
FORM add_dynpro USING iv_program TYPE bdc_prog
                      iv_dynpro  TYPE bdc_dynr.

  FIELD-SYMBOLS: <ls_bdc_data> TYPE bdcdata.

  APPEND INITIAL LINE TO gt_bdcdata ASSIGNING <ls_bdc_data>.
  <ls_bdc_data>-program  = iv_program.
  <ls_bdc_data>-dynpro   = iv_dynpro.
  <ls_bdc_data>-dynbegin = 'X'.

ENDFORM.                     "add_dynpro


*----------------------------------------------------------------------*
*                  Form ADD_FIELD
*----------------------------------------------------------------------*
FORM add_field USING iv_field TYPE fnam_____4
                     iv_value TYPE any.

  FIELD-SYMBOLS: <ls_bdc_data> TYPE bdcdata.

  APPEND INITIAL LINE TO gt_bdcdata ASSIGNING <ls_bdc_data>.
  <ls_bdc_data>-fnam = iv_field.
  <ls_bdc_data>-fval = iv_value.

ENDFORM.                   "add_field

*----------------------------------------------------------------------*
*           Form CALL_TRX
*----------------------------------------------------------------------*
FORM call_trx USING iv_tcode   TYPE sytcode
                    is_params  TYPE ctu_params
                    iv_msgid   TYPE bdc_mid
                    iv_msgnr   TYPE bdc_mnr
                    es_retcode TYPE bapiret2
                    ev_rc      TYPE sy-subrc.

  FIELD-SYMBOLS: <ls_messtab> TYPE bdcmsgcoll.
  DATA: lt_messtab TYPE tab_bdcmsgcoll.

  CLEAR: ev_rc, es_retcode.

  CALL TRANSACTION iv_tcode
    USING gt_bdcdata
    OPTIONS FROM is_params
    MESSAGES INTO lt_messtab.

  READ TABLE lt_messtab ASSIGNING <ls_messtab>
    WITH KEY msgtyp = 'S'
             msgid  = iv_msgid
             msgnr  = iv_msgnr.
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
    IF sy-subrc = 0.
      es_retcode-type = <ls_messtab>-msgtyp.
      es_retcode-id = <ls_messtab>-msgid.
      es_retcode-number = <ls_messtab>-msgnr.
      es_retcode-message_v1 = <ls_messtab>-msgv1.
      es_retcode-message_v2 = <ls_messtab>-msgv2.
      MESSAGE ID <ls_messtab>-msgid TYPE <ls_messtab>-msgtyp NUMBER <ls_messtab>-msgnr
        WITH <ls_messtab>-msgv1 <ls_messtab>-msgv2
        INTO es_retcode-message.
    ENDIF.
    ev_rc = 8.
  ENDIF.

ENDFORM.                    "call_trx
