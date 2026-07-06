*&---------------------------------------------------------------------*
*&  Include           ZFI_INC_BI
*&---------------------------------------------------------------------*

* Tablas Internas
DATA: BEGIN OF it_bdc_tab OCCURS 0.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF it_bdc_tab.

DATA BEGIN OF it_messtab OCCURS 0.                          "#EC NEEDED
        INCLUDE STRUCTURE bdcmsgcoll.
DATA END OF it_messtab.

*&---------------------------------------------------------------------*
*&      Form  dynpro
*&---------------------------------------------------------------------*
FORM dynpro USING dynbegin name value.                      "#EC *

  IF dynbegin = 'X'.

    CLEAR it_bdc_tab.

    MOVE : name  TO it_bdc_tab-program ,
           value TO it_bdc_tab-dynpro  ,
           'X'   TO it_bdc_tab-dynbegin.
    APPEND it_bdc_tab.
  ELSE.
    CLEAR it_bdc_tab.
    MOVE : name  TO it_bdc_tab-fnam,
           value TO it_bdc_tab-fval.
    APPEND it_bdc_tab.
  ENDIF.
ENDFORM.                    " DYNPRO


*&---------------------------------------------------------------------*
*&      Form  f_open_batch_input
*&---------------------------------------------------------------------*
FORM f_open_batch_input USING p_grup.                       "#EC *

  CALL FUNCTION 'BDC_OPEN_GROUP'                            "#EC *
    EXPORTING
      client = sy-mandt
      group  = p_grup
      keep   = 'X'
      user   = sy-uname.

ENDFORM.                   " F_OPEN_BATCH_INPUT

*&---------------------------------------------------------------------*
*&      Form  f_insert_bdc_tab
*&---------------------------------------------------------------------*
FORM f_insert_bdc_tab USING g_tcode.                        "#EC *

  CALL FUNCTION 'BDC_INSERT'                                "#EC *
    EXPORTING
      tcode     = g_tcode
    TABLES
      dynprotab = it_bdc_tab.

ENDFORM.                   " F_INSERT_BDC_TAB


*&---------------------------------------------------------------------*
*&      Form  f_close_batch_input
*&---------------------------------------------------------------------*
FORM f_close_batch_input.                                   "#EC CALLED

  CALL FUNCTION 'BDC_CLOSE_GROUP'                           "#EC *
    EXCEPTIONS
      not_open    = 1
      queue_error = 2
      OTHERS      = 3.

ENDFORM.                    " F_CLOSE_BATCH_INPUT
