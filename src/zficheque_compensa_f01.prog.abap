*&---------------------------------------------------------------------*
*&  Include           ZFI_CHEQUE_COMPENSA_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FILENAME_GET
*&---------------------------------------------------------------------*
FORM filename_get  CHANGING p_p_arch.
  DATA: lv_mensaje    TYPE string.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = p_p_arch
      def_path         = 'C:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Abrir'
    IMPORTING
      filename         = p_p_arch
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

  IF sy-subrc NE 0.
    MESSAGE s899(mm) DISPLAY LIKE 'E' WITH text-m01.
  ENDIF.
ENDFORM.                    " FILENAME_GET
*&---------------------------------------------------------------------*
*&      Form  VALIDA_PARAMETROS
*&---------------------------------------------------------------------*
FORM valida_parametros .
  IF p_arch IS INITIAL.
    MESSAGE s899(mm) DISPLAY LIKE 'E' WITH text-m02.
    STOP.
  ENDIF.
ENDFORM.                    " VALIDA_PARAMETROS
*&---------------------------------------------------------------------*
*&      Form  CARGA_ARCHIVO
*&---------------------------------------------------------------------*
FORM carga_archivo .
  DATA: lv_filename     TYPE rlgrap-filename.
* Lectura del archivo de entrada
  REFRESH: gt_carga_excel.
  CLEAR lv_filename.
  lv_filename = p_arch.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = lv_filename
      i_begin_col             = '1'
      i_begin_row             = '2'
      i_end_col               = '5'
      i_end_row               = '65536'
    TABLES
      intern                  = gt_carga_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE s899(mm) DISPLAY LIKE 'E' WITH text-m01.
    STOP.
  ELSE.
    PERFORM mapear_archivo.
  ENDIF.
ENDFORM.                    " CARGA_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  MAPEAR_ARCHIVO
*&---------------------------------------------------------------------*
FORM mapear_archivo .
  CLEAR: gv_lineas.
  DESCRIBE TABLE gt_carga_excel LINES gv_lineas.
  LOOP AT gt_carga_excel INTO gw_carga_excel.
    PERFORM indicador_progreso USING sy-tabix 'Cargando Archivo...'.
    CASE gw_carga_excel-col.
      WHEN 1.
        gw_data-bukrs  =   gw_carga_excel-value.  " Sociedad
        TRANSLATE gw_data-bukrs TO UPPER CASE.
      WHEN 2.
        gw_data-hbkid  =   gw_carga_excel-value.  " Banco
        TRANSLATE gw_data-hbkid TO UPPER CASE.
      WHEN 3.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = gw_carga_excel-value  " N° Referencia (N° Cheque)
          IMPORTING
            output = gw_data-chect.

    ENDCASE.
    AT END OF row.
      APPEND gw_data TO gt_data.
      CLEAR gw_data.
    ENDAT.
    CLEAR: gw_carga_excel.
  ENDLOOP.
ENDFORM.                    " MAPEAR_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  CALL_FEBAN
*&---------------------------------------------------------------------*
FORM call_feban .
  LOOP AT gt_data INTO gw_data.
    PERFORM indicador_progreso USING sy-tabix 'Compensando...'.
    PERFORM call_transaction. " Crea AF con TX AS91 Anterior
    PERFORM message_alv.      " Rescata Log de Mensaje TX AS91
  ENDLOOP.
ENDFORM.                    " CALL_FEBAN
*&---------------------------------------------------------------------*
*&      Form  INDICADOR_PROGRESO
*&---------------------------------------------------------------------*
FORM indicador_progreso  USING lv_lineas
                               lv_mensaje.
  " Declaración variables locales para msj informativo pant. selec.
  DATA: lv_calc       TYPE p DECIMALS 2,
        lv_info(100)  TYPE c,
        lv_calc_t     TYPE string,
        lv_total_t    TYPE string,
        lv_linea_t    TYPE string.
  IF gv_lineas > 0.
    lv_calc = ( lv_lineas * 100 ) / gv_lineas.
    lv_calc_t = lv_calc.
    lv_total_t = gv_lineas.
    lv_linea_t = lv_lineas.

    CONCATENATE lv_mensaje '' lv_calc_t '% ...  -  ' lv_linea_t ' de '  lv_total_t
    INTO lv_info
    SEPARATED BY space RESPECTING BLANKS.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lv_calc
        text       = lv_info.

  ENDIF.
ENDFORM.                    " INDICADOR_PROGRESO
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_transaction .
  CLEAR:gtmsj, bdcdata.
  REFRESH: gtmsj, bdcdata.

  PERFORM bdc_dynpro      USING 'SAPLNEW_FEBA' '0060'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'SL_HBKID-LOW'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=CRET'.
  PERFORM bdc_field       USING 'SL_BUKRS-LOW'
                                gw_data-bukrs.
  PERFORM bdc_field       USING 'SL_HBKID-LOW'
                                gw_data-hbkid.
  PERFORM bdc_dynpro      USING 'SAPLNEW_FEBA' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BS_CHANGE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'D0200_AMOUNT'.
  PERFORM bdc_dynpro      USING 'SAPLSSEL' '1104'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=CRET'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                '%%DYN001-LOW'.
  PERFORM bdc_field       USING '%%DYN001-LOW'
                                'zz02'.
  PERFORM bdc_dynpro      USING 'SAPLSSEL' '1104'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=CRET'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                '%%DYN002-LOW'.
  PERFORM bdc_field       USING '%%DYN001-LOW'
                                'ZZ02'.
  PERFORM bdc_field       USING '%%DYN002-LOW'
                                '0000000025893'.
  PERFORM bdc_dynpro      USING 'SAPLNEW_FEBA' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BS_SAVE'.
  PERFORM bdc_dynpro      USING 'SAPDF05X' '3100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=AB'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-ABPOS'.
  PERFORM bdc_field       USING 'RF05A-ABPOS'
                                '1'.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0700'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-NEWBS'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SL'.
  PERFORM bdc_field       USING 'BKPF-XBLNR'
                                'CHI010020013097'.
  PERFORM bdc_field       USING 'BKPF-BKTXT'
                                gw_data-chect.
  PERFORM bdc_dynpro      USING 'SAPMF05A' '0710'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-XAUTS'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RF05A-AGBUK'
                                'CL39'.
  PERFORM bdc_field       USING 'RF05A-AGKON'
                                '1011123792'.
  PERFORM bdc_field       USING 'RF05A-AGKOA'
                                'S'.
  PERFORM bdc_field       USING 'RF05A-XNOPS'
                                'X'.
  PERFORM bdc_field       USING 'RF05A-XAUTS'
                                'X'.
  PERFORM bdc_dynpro      USING 'SAPDF05X' '3100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BU'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF05A-ABPOS'.
  PERFORM bdc_field       USING 'RF05A-ABPOS'
                                '1'.
  PERFORM bdc_dynpro      USING 'SAPLNEW_FEBA' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BS_BACK'.
  PERFORM bdc_dynpro      USING 'SAPLNEW_FEBA' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BS_LEAVE'.

  CALL TRANSACTION 'FEBAN' USING bdcdata MODE gv_mode MESSAGES INTO gtmsj.
ENDFORM.                    " CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = c_x.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval IS NOT INITIAL.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
*  ELSE.
*    bdcdata-fnam = fnam.
*    bdcdata-fval = fval.
*    APPEND bdcdata.
  ENDIF.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_ALV
*&---------------------------------------------------------------------*
FORM message_alv .
  DATA:  lv_textout LIKE t100-text,
         lv_concat(300)  TYPE c,
         lv_index   TYPE sytabix.
  CLEAR: gw_alv, lv_textout, lv_concat, lv_index.

  READ TABLE gtmsj  WITH KEY msgtyp = 'S' msgnr = 312. " Busca si esta creado el Doc de compensacion.

** Determina el resultado del mensaje
  IF sy-subrc EQ 0. " SI SE CREO

    MESSAGE ID gtmsj-msgid
     TYPE gtmsj-msgtyp
     NUMBER gtmsj-msgnr
     WITH gtmsj-msgv1 gtmsj-msgv2 gtmsj-msgv3 gtmsj-msgv4 INTO lv_textout.

    gw_alv-pos        = gv_pos.         " linea del excel
    gw_alv-bukrs      = gw_data-bukrs.  " Sociedad
    gw_alv-hbkid      = gw_data-hbkid.  " Banco
    gw_alv-chect      = gw_data-chect.  " N° Cheque
    gw_alv-doc_comp   = gtmsj-msgv1.    " N° Documento.
    gw_alv-mensaje    = lv_textout.     " Mensaje.
    gw_alv-color_l    = 'C500'.         " Color Line.

    APPEND gw_alv TO gt_alv.
  ELSE.        " NO SE CREO
    LOOP AT gtmsj.
      lv_index = sy-tabix.
      CLEAR: lv_textout.
      MESSAGE ID gtmsj-msgid
        TYPE gtmsj-msgtyp
        NUMBER gtmsj-msgnr
        WITH gtmsj-msgv1 gtmsj-msgv2 gtmsj-msgv3 gtmsj-msgv4 INTO lv_textout.

      IF lv_index EQ 1.
        lv_concat = lv_textout.
      ELSE.
        CONCATENATE lv_concat ' | ' lv_textout INTO lv_concat.
      ENDIF.
    ENDLOOP.
    IF lv_concat IS NOT INITIAL.
      gw_alv-pos = gv_pos.       " linea del excel
      gw_alv-bukrs      = gw_data-bukrs.  " Sociedad
      gw_alv-hbkid      = gw_data-hbkid.  " Banco
      gw_alv-chect      = gw_data-chect.  " N° Cheque
      gw_alv-doc_comp   = gtmsj-msgv1.    " N° Documento.
      gw_alv-color_l    = 'C600'.   " Color Line.
      gw_alv-mensaje    = lv_concat." Mensaje Error.
      APPEND gw_alv TO gt_alv.
    ENDIF.
  ENDIF.
  CLEAR: gw_data.
ENDFORM.                    " MESSAGE_ALV
