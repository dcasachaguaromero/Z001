*&---------------------------------------------------------------------*
*&  Include           ZFIBI_AS92_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FILENAME_GET
*&---------------------------------------------------------------------*

FORM FILENAME_GET  CHANGING P_P_ARCH.
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
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDA_PARAMETROS .
 IF p_arch IS INITIAL.
    MESSAGE s899(mm) DISPLAY LIKE 'E' WITH text-m02.
    STOP.
  ENDIF.
ENDFORM.                    " VALIDA_PARAMETROS
*&---------------------------------------------------------------------*
*&      Form  CARGA_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CARGA_ARCHIVO .
DATA: lv_filename     TYPE rlgrap-filename.
* Lectura del archivo de entrada
  REFRESH: gt_carga_excel.
  CLEAR: lv_filename, gv_lineas.
  lv_filename = p_arch.
  gv_lineas = 2.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = lv_filename
      i_begin_col             = '1'
      i_begin_row             = '2'
      i_end_col               = '10'
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
*       text
*----------------------------------------------------------------------*
FORM MAPEAR_ARCHIVO .
  PERFORM indicador_progreso USING 1 'Cargando Archivo...'.
LOOP AT gt_carga_excel INTO gw_carga_excel.
    CASE gw_carga_excel-col.
      WHEN 1.
        gw_data-ANLN1           =   gw_carga_excel-value.  " Clase activos fijos
      WHEN 2.
        gw_data-bukrs           =   gw_carga_excel-value.  " Sociedad
      WHEN 3.
        gw_data-SCHRW           =   gw_carga_excel-value.  " Denominación
     ENDCASE.
    AT END OF row.
      APPEND gw_data TO gt_data .
      CLEAR gw_data.
    ENDAT.
    CLEAR: gw_carga_excel.
  ENDLOOP.
ENDFORM.                    " MAPEAR_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  MODIFICA_AF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MODIFICA_AF .
   DATA: lv_totalpos(6) TYPE N,
        lv_totalc(6) TYPE C,
        lv_msj  TYPE STRING.
  CLEAR: gv_pos, lv_totalpos,lv_totalc,lv_msj .
  ADD 1 to gv_pos. "linea de la cabecera del excel.
  DESCRIBE TABLE gt_data LINES lv_totalpos.
    IF lv_totalpos EQ 0.
      MESSAGE s899(mm) DISPLAY LIKE 'E' WITH text-m03.
      STOP.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT         = lv_totalpos
       IMPORTING
         OUTPUT        = lv_totalpos.
      WRITE lv_totalpos  TO lv_totalc .
      CONCATENATE 'Modificando ' lv_totalc ' AF.' INTO lv_msj SEPARATED BY space.
      PERFORM indicador_progreso USING 2 lv_msj.
     LOOP AT gt_data INTO gw_data.
        ADD 1 to gv_pos.
        PERFORM call_transaction. " Modifica AF con TX AS02
        PERFORM message_alv.      " Rescata Log de Mensaje TX AS92
      ENDLOOP.
      ENDIF.
ENDFORM.                    " MODIFICA_AF
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_TRANSACTION .
    CLEAR: gtmsj, bdcdata.
  REFRESH: gtmsj, bdcdata.
perform bdc_dynpro      using 'SAPLAIST' '0100'.
perform bdc_field       using 'BDC_CURSOR'
                              'ANLA-BUKRS'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'ANLA-ANLN1'
                              gw_data-anln1.  " N° AF
perform bdc_field       using 'ANLA-ANLN2'
                              '0'.
perform bdc_field       using 'ANLA-BUKRS'
                             gw_data-bukrs.  " Sociedad
perform bdc_dynpro      using 'SAPLAIST' '1000'.
perform bdc_field       using 'BDC_OKCODE'
                              '=TAB08'.
perform bdc_field       using 'BDC_CURSOR'
                              'ANLA-TXT50'.
*perform bdc_field       using 'ANLA-TXT50'
*                              'TORRE A ÁREA DE INSTALACIONES A-2'.
*perform bdc_field       using 'ANLH-ANLHTXT'
*                              'ÁREA DE INSTALACIONES'.
*perform bdc_field       using 'ANLA-MENGE'
*                              '1'.
*perform bdc_field       using 'ANLA-MEINS'
*                              'UN'.
*perform bdc_field       using 'ANLA-IVDAT'
*                              '31.12.2012'.
*perform bdc_field       using 'ANLA-INKEN'
*                              'X'.
*perform bdc_field       using 'ANLA-AKTIV'
*                              '01.01.1939'.
perform bdc_dynpro      using 'SAPLAIST' '1000'.
perform bdc_field       using 'BDC_OKCODE'
                              '=SELZ'.
perform bdc_field       using 'BDC_CURSOR'
                              'T093T-AFBKTX(01)'.
perform bdc_dynpro      using 'SAPLAIST' '0195'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BUCH'.
perform bdc_field       using 'BDC_CURSOR'
                              'ANLB-SCHRW'.
*perform bdc_field       using 'ANLB-AFASL'
*                              'ZCL'.
*perform bdc_field       using 'ANLB-NDJAR'
*                              ' 80'.
*perform bdc_field       using 'ANLC-NDABJ'
*                              ' 73'.
*perform bdc_field       using 'ANLC-NDABP'
*                              ' 11'.
*perform bdc_field       using 'ANLB-AFABG'
*                              '01.02.1939'.
perform bdc_field       using 'ANLB-SCHRW'
                              gw_data-SCHRW. .
CALL TRANSACTION 'AS02' USING bdcdata MODE gv_mode MESSAGES INTO gtmsj.
ENDFORM.                    " CALL_TRANSACTION


FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
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
  ENDIF.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MESSAGE_ALV .
 DATA:  lv_textout LIKE t100-text,
         lv_concat(300)  TYPE c,
         lv_index   TYPE sytabix.
  CLEAR: gw_alv, lv_textout, lv_concat, lv_index.
READ TABLE gtmsj  WITH KEY msgtyp = 'S' msgnr = 230. " Busca si se modifico el AF
** Determina el resultado del mensaje
  IF sy-subrc EQ 0. " SI SE MODIFICO
    MESSAGE ID gtmsj-msgid
     TYPE gtmsj-msgtyp
     NUMBER gtmsj-msgnr
     WITH gtmsj-msgv1 gtmsj-msgv2 gtmsj-msgv3 gtmsj-msgv4 INTO lv_textout.

    gw_alv-pos     = gv_pos.     " linea del excel
    gw_alv-activo  = gtmsj-msgv1." N° Activo Fijo.
    gw_alv-mensaje = lv_textout. " Mensaje.
    gw_alv-color_l = 'C500'.     " Color Line.
    gw_alv-bukrs   = gw_data-bukrs.
    APPEND gw_alv TO gt_alv.
    ELSE.        " NO SE MODIFICO
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
      gw_alv-color_l = 'C600'.   " Color Line.
      gw_alv-mensaje = lv_concat." Mensaje Error.
      APPEND gw_alv TO gt_alv.
    ENDIF.

    ENDIF.
ENDFORM.                    " MESSAGE_ALV

*&---------------------------------------------------------------------*
*&      Form  indicador_progreso
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
ENDFORM.                    " indicador_progreso
