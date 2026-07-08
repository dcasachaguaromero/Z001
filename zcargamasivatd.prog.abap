*&---------------------------------------------------------------------*
*& Report  ZCARGAMASIVATD
*&
*&---------------------------------------------------------------------*
*&  Carga desde planilla EXCEL dtaos de conversion de tipos de
*&  documento usados en Banmedica por los que usa cda Banco
*&---------------------------------------------------------------------*

REPORT  zcargamasivatd.

TABLES: ztd_pagobanco.

DATA ruta(128).

TYPE-POOLS: truxs.

TYPES: BEGIN OF type_excel,
         ubnkl(3)      TYPE c, "Codigo Banco
         setval(24)    TYPE c, "Codigo TD interno
         glosatd(100)  TYPE c, "Descripcion Tipo DOcumento Interno
         codban(4)     TYPE c, "Código TD del Banco
         facncr(1)     TYPE c, "Indicador FAC - NCR
    END OF type_excel.

DATA: bancon(3)     TYPE n.

DATA: tl_exc TYPE STANDARD TABLE OF type_excel WITH HEADER LINE.

PERFORM set_filepath USING ruta.
DELETE FROM ztd_pagobanco.
PERFORM upload_excel_it USING ruta  .


LOOP AT tl_exc.
  WRITE:/ tl_exc-ubnkl,
          tl_exc-setval,
          tl_exc-glosatd,
          tl_exc-codban,
          tl_exc-facncr.
ENDLOOP.

*&---------------------------------------------------------------------*
* Este FORM sirve para el explorador en el que se selecciona el archivo
*----------------------------------------------------------------------*
FORM set_filepath  CHANGING po_ruta TYPE rlgrap-filename.

  CONSTANTS: c_ext_exl   TYPE string     VALUE '*.XLS'.

  DATA: lt_filetable TYPE filetable,
        lx_filetable TYPE file_table,
        wl_sel_text  TYPE string,
        lv_rc TYPE i.

  CLEAR po_ruta.

  wl_sel_text = text-s01.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = wl_sel_text
      default_extension       = c_ext_exl
    CHANGING
      file_table              = lt_filetable
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    READ TABLE lt_filetable INTO lx_filetable INDEX 1.
    CHECK sy-subrc EQ 0.
    po_ruta = lx_filetable-filename.
  ENDIF.

ENDFORM.                    " SET_FILEPATH

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_EXCEL_IT
*&---------------------------------------------------------------------*
*& Subir un archivo excel a una tabla interna
*&---------------------------------------------------------------------
FORM upload_excel_it USING    pi_ruta TYPE rlgrap-filename.

  DATA: it_raw TYPE truxs_t_text_data.

  REFRESH: tl_exc.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
*     i_line_header        = 'X'
      i_tab_raw_data       = it_raw       " WORK TABLE
      i_filename           = pi_ruta
    TABLES
      i_tab_converted_data = tl_exc[]    "ACTUAL DATA
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF ( sy-subrc <> 0 ).
    MESSAGE text-e02  TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    DELETE  tl_exc INDEX 1.                    "eliminar la cabecera
    LOOP AT tl_exc.
      MOVE   tl_exc-ubnkl   TO  bancon.
      MOVE   bancon         TO  ztd_pagobanco-banco.
      MOVE   tl_exc-setval  TO  ztd_pagobanco-codigo.
      MOVE   tl_exc-glosatd TO  ztd_pagobanco-glosatd.
      MOVE   tl_exc-codban  TO  ztd_pagobanco-codban.
      MOVE   tl_exc-facncr  TO  ztd_pagobanco-facncr.
      INSERT ztd_pagobanco.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " UPLOAD_EXCEL_IT

*&---------------------------------------------------------------------*
*&      Form  CONVERSION_SAP_NUM
*&---------------------------------------------------------------------*
FORM conversion_sap_num  USING    pi_output
                          CHANGING po_output.

  CALL FUNCTION 'MOVE_CHAR_TO_NUM'
    EXPORTING
      chr             = pi_output
    IMPORTING
      num             = po_output
    EXCEPTIONS
      convt_no_number = 1
      convt_overflow  = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    CLEAR po_output.
  ENDIF.

ENDFORM.                    " CONVERSION_SAP_FORMAT
