*&---------------------------------------------------------------------*
*& Report  ZMM_CM_SALIDAMERC_NEW
*&
*&---------------------------------------------------------------------*
*&----------------------------------------------------------------------&*
*& REPORT ZMM_CM_SALIDAMERC.                                          &*
*&----------------------------------------------------------------------&*
*& Cliente            : vida integra                                   &*
*& Consultora         : Seidor Crystalis                                &*
*& Desarrollador ABAP : Felipe Garcia Trujillo                         &*
*& Funcional          : Cristian Navarro                                  &*
*& Fecha              : 26/03/2015                                     &*
*& Transporte         :                                     &*
*& Objetivo           : Carga masiva para salidas de mercancías                         &*
*&----------------------------------------------------------------------&*
*&
*&---------------------------------------------------------------------*

REPORT  zmm_cm_salidamerc_new.

TABLES: zmm_correlativo,
        zmm_log_carga.

*--------------------------------------------------------------------*
* TYPES
*--------------------------------------------------------------------*
TYPE-POOLS: slis.

TYPES: BEGIN OF ty_alv ,
  doc_matnr  TYPE mseg-mblnr,  " Doc material
  c_coste    TYPE mseg-kostl,  " Centro coste
  prd_con    TYPE mseg-zzunid_pro,  " Unid PRod
 END OF ty_alv.


TYPES: BEGIN OF ty_datos,
   secuencia(10) TYPE n,
   correlativo(10) TYPE n,
   fecha_doc(10),
   fecha_cont(10),
*  fecha_doc   TYPE mkpf-bldat,  " Fecha de documento
*  fecha_cont  TYPE mkpf-budat,  "Fecha de contabilizacion
   clase_mov   TYPE mseg-bwart,  "clase moviminto
   centro      TYPE mseg-werks,  " Centro
   almacen     TYPE mseg-lgort,     " almacen
   cta_mayor   TYPE mseg-sakto,    " cuenta de mayor
   kostl       TYPE mseg-kostl,     "Centro de coste
   prd_cont    TYPE mseg-zzunid_pro, " producto contable
   no_mat      TYPE mseg-matnr,      " numero de material
   cantidad(16),"mseg-menge,   " cantidad a consumir
   um(3)          TYPE c,    "unidad de medida
 END OF ty_datos.

TYPES: BEGIN OF ty_datos_clave,
    fecha_doc(10),
    fecha_cont(10),
    clase_mov   TYPE mseg-bwart,  "clase moviminto
    centro      TYPE mseg-werks,  " Centro
    almacen     TYPE mseg-lgort,     " almacen
    cta_mayor   TYPE mseg-sakto,    " cuenta de mayor
    kostl       TYPE mseg-kostl,     "Centro de coste
    prd_cont    TYPE mseg-zzunid_pro, " producto contable
END OF ty_datos_clave.

TYPES: BEGIN OF ty_mensaje,
    char1(10),  " char
    doc_matnr TYPE mseg-mblnr,   " Centro coste
    char3(10) ,  " Unid PRod
    c_coste    TYPE mseg-kostl,  " Centro coste
    prd_con    TYPE mseg-zzunid_pro,  " Unid PRod
END OF ty_mensaje.

*--------------------------------------------------------------------*
* DATA
*--------------------------------------------------------------------*
DATA: gt_excel          TYPE STANDARD TABLE OF alsmex_tabline,
      gs_excel          TYPE alsmex_tabline.

DATA: gt_datos          TYPE STANDARD TABLE OF ty_datos,
      gs_datos          TYPE ty_datos,
      gt_datos_clave    TYPE STANDARD TABLE OF ty_datos_clave,
      gs_datos_clave    TYPE ty_datos_clave,
      gt_alv            TYPE STANDARD TABLE OF ty_alv,
      gt_material_dat   TYPE STANDARD TABLE OF ty_datos,
      gs_alv            TYPE ty_alv,
      gt_mensaje        TYPE STANDARD TABLE OF ty_mensaje,
      gs_mensaje        TYPE ty_mensaje.

DATA: gv_file_name      TYPE string,
      gv_fullpath       TYPE string,
      gv_error          TYPE string,
      gv_obj_key        TYPE bapiache09-obj_key.

* Datos para batch input
DATA: BEGIN OF bdcdata OCCURS 0.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF bdcdata.

DATA: BEGIN OF messtab OCCURS 10.
        INCLUDE STRUCTURE bdcmsgcoll.

DATA END OF messtab.

DATA: wa_messtab TYPE bdcmsgcoll.

DATA: bdc_mode(1)   VALUE 'E',"N
      bdc_update(1) VALUE 'A'." asincronico

DATA: gv_shkzg    TYPE bsid-shkzg,   " Haber         -> 'H'
      gv_umskz    TYPE bsid-umskz,   " Indicador CME -> vacio
      gv_augbl    TYPE bsid-augbl,   " Doc. compra   -> vacio
      gv_vbtyp_n  TYPE vbfa-vbtyp_n, "               -> 'o'
      gv_vbtyp_v  TYPE vbfa-vbtyp_v. "               -> 'm'

DATA: lv_error      TYPE c,
      w_correl(10)  TYPE c,
      w_correln(10) TYPE n,
      cuenta1(5)    TYPE n,
      cuenta(5)     TYPE n,
      fechaw(10)    TYPE c,
      maxcol(3)     TYPE n,
      indice(3)     TYPE n,
      wf_error      TYPE c,
      wc_existe     TYPE c,
      wc_error      TYPE c.

" Variables ALV
*"Catalogo de campos

DATA: l_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      l_layout   TYPE slis_layout_alv,
      l_repid    LIKE sy-repid.

CLEAR l_fieldcat.

*--------------------------------------------------------------------*
* SELECTION-SCREEN
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-001.
PARAMETERS: p_anio TYPE ckmlpp-bdatj      OBLIGATORY.
PARAMETERS: p_mes TYPE ckmlpp-poper      OBLIGATORY.        " MES - periodo
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE text-002.
PARAMETERS:  p_file  TYPE rlgrap-filename OBLIGATORY.                "Ruta Archivo a Cargar
SELECTION-SCREEN END OF BLOCK b02.
SELECTION-SCREEN END OF BLOCK b01.

*--------------------------------------------------------------------*
* AT SELECTION-SCREEN
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
    EXPORTING
      window_title = 'Seleccione el archivo a cargar#'
      file_filter  = ',*.xls,*.xls.'
    IMPORTING
      filename     = gv_file_name
      fullpath     = gv_fullpath.
  IF sy-subrc = 0.
    p_file = gv_fullpath.
  ENDIF.

*--------------------------------------------------------------------*
* START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

  IF p_file NS '.xls'.
    PERFORM mensaje_error USING gv_file_name CHANGING gv_error.
    MESSAGE gv_error TYPE 'E'.
  ELSE.
    PERFORM cargar_excel.

    IF gt_datos[] IS NOT INITIAL.

      PERFORM cargar_batch.
      PERFORM armar_alv.
      PERFORM mostrar_alv.
      PERFORM grabar_zmm_correlativo.

    ENDIF.
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  mensaje_error
*&---------------------------------------------------------------------*
*    Subrutina que genera mensaje de error al verificar archivo de carga
*----------------------------------------------------------------------*
*      -->PV_FILE_NAME : Nombre Archivo
*      -->PR_ERROR     : String Error
*----------------------------------------------------------------------*
FORM mensaje_error USING pv_file_name CHANGING pr_error.

  CONCATENATE 'Archivo' pv_file_name 'inválido. Verifique que su archivo sea de tipo excel (.xls).'
         INTO pr_error SEPARATED BY space.

ENDFORM.                    "mensaje_error


*&---------------------------------------------------------------------*
*&      Form  cargar_excel
*&---------------------------------------------------------------------*
*    Subrutina que carga la planilla excel en una tabla interna
*----------------------------------------------------------------------*
FORM cargar_excel.

  REFRESH: gt_excel, gt_datos.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_file
      i_begin_col             = 1
      i_begin_row             = 7
      i_end_col               = 12
      i_end_row               = 5007
    TABLES
      intern                  = gt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE e010(ad) WITH 'Error en el archivo, verifique datos.'.
  ELSE.

    IF gt_excel[] IS NOT INITIAL.

      CLEAR: gs_datos.
      CLEAR: wc_existe.
      CLEAR: wc_error.
      CLEAR: wf_error.
      CLEAR: w_correl.
      CLEAR: cuenta.
      CLEAR: maxcol.
      CLEAR: indice.

      LOOP AT gt_excel INTO gs_excel.
        IF gs_excel-col > maxcol.
          maxcol = gs_excel-col.
        ENDIF.
        IF gs_excel-col = '0001'.
          fechaw = gs_excel-value.
          cuenta = cuenta + 1.
          IF cuenta = 1.
            w_correl = gs_excel-value.
            DO 10 TIMES.
              IF fechaw+indice(1) < '0' OR fechaw+indice(1) > '9'.
                indice = indice + 1.
                wf_error = 'X'.
              ELSE.
                w_correln = w_correl.
                SELECT SINGLE * FROM zmm_correlativo
                  WHERE correlativo = w_correln.
                IF sy-subrc = 0.
                  wc_existe = 'X'.
                ENDIF.
              ENDIF.
            ENDDO.
          ELSE.
            IF w_correl <> gs_excel-value.
              wc_error = 'X'.
            ENDIF.
          ENDIF.
        ENDIF.

        IF gs_excel-col = '0002'.
          IF p_mes+1(2) NE gs_excel-value+3(2) OR p_anio NE gs_excel-value+6(4).
            lv_error = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF wf_error <> ' ' OR maxcol <> 12.
        MESSAGE 'REVISE formato de archivo, se suspende proceso.' TYPE 'E'.
      ENDIF.
      IF wc_error <> ' '.
        MESSAGE 'Hay registros con correlativos diferentes, se suspende proceso' TYPE 'E'.
      ENDIF.

      cuenta1 = cuenta + 6.
      IF cuenta1 > 2000.
        MESSAGE 'Planilla excede 5000 filas,se suspende proceso' TYPE 'E'.
      ENDIF.

      IF lv_error <> ' '.
        MESSAGE 'Hay registros que no son del periodo contable ingresado, se suspende proceso' TYPE 'E'.
      ENDIF.

      IF wc_existe <> ' '.
        MESSAGE 'Correlativo procesado anteriormente, REVISE, se suspende proceso.' TYPE 'E'.
      ENDIF.

      LOOP AT gt_excel INTO gs_excel.
        CASE gs_excel-col.
          WHEN '0001'.
            gs_datos-correlativo = gs_excel-value.
          WHEN '0002'.
            gs_datos-fecha_doc   = gs_excel-value.
          WHEN '0003'.
            gs_datos-fecha_cont  = gs_excel-value.
          WHEN '0004'.
            gs_datos-clase_mov = gs_excel-value.
          WHEN '0005'.
            gs_datos-centro    = gs_excel-value.
          WHEN '0006'.
            gs_datos-almacen   = gs_excel-value.
          WHEN '0007'.
            gs_datos-cta_mayor = gs_excel-value.
          WHEN '0008'.
            gs_datos-kostl     = gs_excel-value.
          WHEN '0009'.
            gs_datos-prd_cont  = gs_excel-value.
          WHEN '0010'.
            gs_datos-no_mat    = gs_excel-value.
          WHEN '0011'.
            gs_datos-cantidad  = gs_excel-value.
          WHEN '0012'.
            gs_datos-um        = gs_excel-value.
            IF lv_error = ' ' AND wc_error = ' ' AND wf_error = ' ' AND wc_existe = ' '.

              gs_datos-secuencia = gs_excel-row + 6.
              PERFORM log_carga.
              APPEND gs_datos TO gt_datos.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ELSE.
      MESSAGE e010(ad) WITH 'Planilla de Carga no contiene datos.'.
    ENDIF.

  ENDIF.

ENDFORM.                    "cargar_excel

*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING  program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    " BDC_DYNPRO
*----------------------------------------------------------------------*
FORM bdc_field USING   fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.                    "bdc_field

*----------------------------------------------------------------------*
*FORM BATCH_INPUT
*----------------------------------------------------------------------*
FORM cargar_batch.

  DATA: lv_index  TYPE i,
        lv_index2 TYPE i,
        lv_index3 TYPE i,
        lv_index_char(2),
        lv_dato_char(14),
        lv_cantidad_char(17),
        lv_pos TYPE i,
        lv_pag TYPE i,
        lv_code(4),
        lv_resto TYPE i,
        lv_index_pag TYPE i.

  " PRIMERO ORDENO MI TABLA POR LAS CLAVES:
  SORT gt_datos BY   fecha_doc  fecha_cont clase_mov centro almacen cta_mayor  kostl  prd_cont.

  REFRESH gt_datos_clave.
  LOOP AT gt_datos INTO gs_datos.
    MOVE-CORRESPONDING gs_datos TO gs_datos_clave.
    COLLECT gs_datos_clave INTO gt_datos_clave.
  ENDLOOP.

*  gt_datos_clave[] = gt_datos[].
*  DELETE ADJACENT DUPLICATES FROM gt_datos_clave COMPARING fecha_doc  fecha_cont clase_mov centro almacen cta_mayor  kostl  prd_cont.
  " en base a gt-datos_clave generare n doc de materiales.

  LOOP AT gt_datos_clave INTO gs_datos_clave.

    PERFORM bdc_dynpro      USING 'SAPMM07M' '0400'.
    PERFORM bdc_field       USING 'BDC_CURSOR'    'RM07M-LGORT'.
    PERFORM bdc_field       USING 'BDC_OKCODE'    '/00'.
    PERFORM bdc_field       USING 'MKPF-BLDAT'    gs_datos_clave-fecha_doc. " Fecha de documento.
    PERFORM bdc_field       USING 'MKPF-BUDAT'    gs_datos_clave-fecha_cont.      " FECHA CONTABLE  "
    PERFORM bdc_field       USING 'RM07M-BWARTWA' gs_datos_clave-clase_mov . " CLAS MOV
    PERFORM bdc_field       USING 'RM07M-WERKS'   gs_datos_clave-centro.
    PERFORM bdc_field       USING 'RM07M-LGORT'   gs_datos_clave-almacen.
    PERFORM bdc_field       USING 'XFULL'         'X'. "record-XFULL_006.
    PERFORM bdc_field       USING 'RM07M-WVERS2'  'X'.  "record-WVERS2_007.
    "-----------------------------------------------------------------

    PERFORM bdc_dynpro      USING 'SAPMM07M' '0421'.
    PERFORM bdc_field       USING 'BDC_CURSOR'    'MSEGK-WEMPF'.
    PERFORM bdc_field       USING 'BDC_OKCODE'    '/00'.
    PERFORM bdc_field       USING 'MSEGK-KONTO'   gs_datos_clave-cta_mayor.
    PERFORM bdc_field       USING 'MSEGK-WEMPF'   ''. " record-WEMPF_009.

    "-----------------------------------------------------------------

    PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
    PERFORM bdc_field       USING 'BDC_OKCODE'     '=ENTE'.
    PERFORM bdc_field       USING 'COBL-KOSTL'     gs_datos_clave-kostl.
    PERFORM bdc_field       USING 'BDC_CURSOR'     'COBL-ZZUNID_PRO'.
    PERFORM bdc_field       USING 'COBL-ZZUNID_PRO' gs_datos_clave-prd_cont."1rd-ZZUNID_PRO_011.

    CLEAR: lv_index, lv_index_char.
    REFRESH: gt_material_dat.
    LOOP AT gt_datos INTO gs_datos WHERE fecha_doc  EQ gs_datos_clave-fecha_doc
                                     AND fecha_cont EQ gs_datos_clave-fecha_cont
                                     AND clase_mov  EQ gs_datos_clave-clase_mov
                                     AND centro     EQ gs_datos_clave-centro
                                     AND almacen    EQ gs_datos_clave-almacen
                                     AND cta_mayor  EQ gs_datos_clave-cta_mayor
                                     AND kostl      EQ gs_datos_clave-kostl
                                     AND prd_cont   EQ gs_datos_clave-prd_cont.

      APPEND gs_datos TO gt_material_dat.

    ENDLOOP.


    DESCRIBE TABLE gt_material_dat LINES lv_pos. " cantidad de posiciones
    lv_pag = lv_pos / 7. " cantidad estimada de paginas en el batch
    lv_resto  = lv_pos - lv_pag * 7.
    IF lv_resto > 0.
      lv_pag = lv_pag + 1.
    ENDIF.
*    lv_pag = lv_pos / 2. " cantidad estimada de paginas en el batch

*    IF lv_pag >= 0 AND lv_pag <= 3.
*      lv_pag = 1.
*    ELSEIF lv_pag  >= 4 AND lv_pag <= 7.
*      lv_pag = 2.
*    ELSEIF lv_pag >= 8 AND lv_pag <= 11.
*      lv_pag = 3.
*    ELSEIF lv_pag >= 12 AND lv_pag <= 15.
*      lv_pag = 4.
*    ELSEIF lv_pag >= 16 AND lv_pag <= 18.
*      lv_pag = 5.
*    ELSEIF lv_pag >= 19 AND lv_pag <= 21.
*      lv_pag = 6.
*    ELSEIF lv_pag >= 22 AND lv_pag <= 25.
*      lv_pag = 7.
*    ELSEIF lv_pag >= 26 AND lv_pag <= 28.
*      lv_pag = 8.
*    ENDIF.

    CLEAR: lv_index_pag.
    " cantidad paginas.

    lv_index_pag = lv_pag.
    "----------------------------------------------------------------------------------------------------------
    CLEAR: lv_index, lv_index3.
    DO lv_pag TIMES.
      lv_index3 = lv_index3 + 1.
      "-----------------------------------------------------------------------------------------------------------
      "POSICIONES MATERIAL
      PERFORM bdc_dynpro      USING 'SAPMM07M' '0421'.
      PERFORM bdc_field       USING 'BDC_CURSOR'  'MSEG-ERFMG(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.

      lv_index_pag = lv_index_pag - 1.

      CLEAR: lv_index_char, lv_index2.
      DO lv_pos TIMES.

        ADD 1 TO lv_index.
        ADD 1 TO lv_index2.
        lv_index_char = lv_index2.

        READ TABLE gt_material_dat INTO gs_datos INDEX lv_index.
        IF sy-subrc EQ 0.
          CASE lv_index2.
            WHEN 1.
              lv_index_char = '01'.
            WHEN 2.
              lv_index_char = '02'.
            WHEN 3.
              lv_index_char = '03'.
            WHEN 4.
              lv_index_char = '04'.
            WHEN 5.
              lv_index_char = '05'.
            WHEN 6.
              lv_index_char = '06'.
            WHEN 7.
              lv_index_char = '07'.
            WHEN 8.
              lv_index_char = '08'.
          ENDCASE.

          CONCATENATE 'MSEG-MATNR(' lv_index_char ')' INTO  lv_dato_char.
          PERFORM bdc_field       USING lv_dato_char gs_datos-no_mat.

          CLEAR: lv_dato_char.
          CONCATENATE 'MSEG-ERFMG(' lv_index_char')' INTO  lv_dato_char.
          CONDENSE gs_datos-cantidad.
          PERFORM bdc_field       USING lv_dato_char gs_datos-cantidad.

          CLEAR: lv_dato_char.
          CONCATENATE 'MSEG-ERFME(' lv_index_char ')'  INTO  lv_dato_char.
          CONDENSE gs_datos-um.
          PERFORM bdc_field       USING lv_dato_char gs_datos-um.

          PERFORM log_contab.
          IF lv_index2 = 7.
            lv_pos = lv_pos - 7.
            EXIT.
          ENDIF.
        ENDIF.
      ENDDO.

      PERFORM bdc_field       USING 'DKACB-FMORE' 'X'.  "record-FMORE_016.

      "FIN POSICION MATERIAL
      "-----------------------------------------------------------------------------------------------------------

      PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
      PERFORM bdc_field       USING 'BDC_CURSOR'  'COBL-KOSTL'.
      PERFORM bdc_field       USING 'BDC_OKCODE'  '=ENTE'.
      "-------------------------------------------------------------------------------------------------------------

      DO  lv_index2 TIMES. " como n posiciones

        PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
        PERFORM bdc_field   USING 'BDC_CURSOR'   'COBL-KOSTL'.
        PERFORM bdc_field   USING 'BDC_OKCODE'   '=ENTE'.
        PERFORM bdc_field   USING 'COBL-KOSTL'      gs_datos_clave-kostl. "" record-KOSTL_017.
        PERFORM bdc_field   USING 'COBL-ZZUNID_PRO' gs_datos_clave-prd_cont."'. "record-ZZUNID_PRO_018'.
      ENDDO.
      "-----------------------------------------------------------------

      IF lv_index_pag EQ 0.                                 " pagina 1
        lv_code = '=BU'.
      ELSEIF  lv_index_pag >= 1.
        lv_code = '=NLE'.
      ENDIF.

      PERFORM bdc_dynpro      USING 'SAPMM07M' '0421'.
      PERFORM bdc_field       USING 'BDC_CURSOR' 'MSEG-ERFMG(01)'.
      PERFORM bdc_field       USING 'BDC_OKCODE' lv_code.
      PERFORM bdc_field       USING 'DKACB-FMORE'  'X'."record-FMORE_021.
      "-----------------------------------------------------------------
      PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
      PERFORM bdc_field       USING 'BDC_CURSOR'  'COBL-KOSTL'.
      PERFORM bdc_field       USING 'BDC_OKCODE'  '=ENTE'.

    ENDDO. " FIN DE PAGINAS

    "¨************************************************************************
    CALL TRANSACTION 'MB1A'   USING bdcdata
                              MODE bdc_mode
                              UPDATE bdc_update
                              MESSAGES INTO messtab.

    PERFORM llenar_mensajes.
    CLEAR: bdcdata[],messtab[].

  ENDLOOP.

  COMMIT WORK.

ENDFORM." ENDFORM BATCH INPUT

*&---------------------------------------------------------------------*
*&      Form  llenar_mensajes
*&---------------------------------------------------------------------*

FORM llenar_mensajes.

  DATA: msje(80),
        indice_msg   TYPE i,
        variable_num TYPE i.
  CLEAR indice_msg.

  DESCRIBE TABLE messtab LINES variable_num.

  DO variable_num TIMES.                             " para verificar todos los mensajes.
    indice_msg = indice_msg + 1.

    READ TABLE messtab INDEX indice_msg INTO wa_messtab.

    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id        = wa_messtab-msgid
        no        = wa_messtab-msgnr
        lang      = 'S'
      IMPORTING
        msg       = msje
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    CLEAR: gs_mensaje.
    SPLIT msje AT ' '  INTO gs_mensaje-char1 gs_mensaje-doc_matnr gs_mensaje-char3.
    gs_mensaje-c_coste   = gs_datos_clave-kostl.     " Centro de coste
    gs_mensaje-prd_con   = gs_datos_clave-prd_cont.  " Unidad Prod

    APPEND gs_mensaje TO gt_mensaje.
  ENDDO.
ENDFORM.                    "llenar_mensajes

*&---------------------------------------------------------------------*
*&      Form  build_cat
*&---------------------------------------------------------------------*
FORM build_cat.

  "Doc. material
  l_fieldcat-fieldname  = 'DOC_MATNR'.
  l_fieldcat-tabname  = 'GT_ALV'.
  l_fieldcat-seltext_l  = 'Doc.Material'.
  APPEND l_fieldcat.
  CLEAR l_fieldcat.

  "Centro coste
  l_fieldcat-fieldname  = 'C_COSTE'.
  l_fieldcat-tabname  = 'GT_ALV'.
  l_fieldcat-seltext_l  = 'Centro coste'.
  APPEND l_fieldcat.
  CLEAR l_fieldcat.

  "Unid/Prd
  l_fieldcat-fieldname  = 'PRD_CON'.
  l_fieldcat-tabname  = 'GT_ALV'.
  l_fieldcat-seltext_l  = 'Unid/Prd'.
  APPEND l_fieldcat.
  CLEAR l_fieldcat.

ENDFORM.                    "BUILD_CAT
*&---------------------------------------------------------------------*
*&      Form  layout_cat
*&---------------------------------------------------------------------*

FORM layout_cat.
  " Mediante esta estructura podemos definir el formato de salida

  l_layout-colwidth_optimize = 'X'.
  l_layout-zebra = 'X'.
*   l_layout-f2code = '&ETA'.
*   l_layout-detail_popup = 'X'.
  l_layout-no_colhead = space.
  l_layout-no_hotspot = space. " headings not as hotspot
ENDFORM.                    "LAYOUT_CAT

*&---------------------------------------------------------------------*
*&      Form  dislplay_cat
*&---------------------------------------------------------------------*  "-------------------------------------------------------------------------
FORM display_cat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout     = l_layout
      it_fieldcat   = l_fieldcat[]
    TABLES
      t_outtab      = gt_alv
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    "DISPLAY_CAT


*&---------------------------------------------------------------------*
*&      Form  armar_alv
*&---------------------------------------------------------------------*
FORM armar_alv.

  LOOP AT gt_mensaje INTO gs_mensaje.
    gs_alv-doc_matnr = gs_mensaje-doc_matnr.
    gs_alv-c_coste   = gs_mensaje-c_coste.  " Centro coste
    gs_alv-prd_con   = gs_mensaje-prd_con.

    APPEND gs_alv TO gt_alv.

  ENDLOOP.

ENDFORM.                    "armar_alv
*&---------------------------------------------------------------------*
*&      Form  mostrar_alv
*&---------------------------------------------------------------------*
FORM mostrar_alv.
  PERFORM build_cat.
  PERFORM layout_cat.
  PERFORM display_cat.
ENDFORM.                    "mostrar_log_alv
*&---------------------------------------------------------------------*
*&      Form  grabar_zmm_correlativo
*&---------------------------------------------------------------------*
FORM grabar_zmm_correlativo.
  zmm_correlativo-correlativo   = w_correl.
  zmm_correlativo-fecha_proceso = sy-datum.
  zmm_correlativo-hora_proceso  = sy-uzeit.
  zmm_correlativo-usuario       = sy-uname.
  zmm_correlativo-archivo       = p_file.
  INSERT zmm_correlativo.
ENDFORM.                    "Grabar zmm_correlativo
*
*----------------------------------------------------------------------*
*FORM LOG DE CARGA DESDE PLANILLA
*----------------------------------------------------------------------*
FORM log_carga.

  zmm_log_carga-correl_carga   = gs_datos-correlativo.
  zmm_log_carga-evento_carga   = 'CARGA'.
  zmm_log_carga-fecha_carga    = sy-datum.
  zmm_log_carga-hora_carga     = sy-uzeit.
  zmm_log_carga-linea_carga    = gs_datos-secuencia.
  zmm_log_carga-articulo_carga = gs_datos-no_mat.
  zmm_log_carga-cant_carga     = gs_datos-cantidad.
  zmm_log_carga-um_carga       = gs_datos-um.
  INSERT  zmm_log_carga.

ENDFORM.                    "LOG de carga

*
*----------------------------------------------------------------------*
*FORM LOG DE CONTABILIZACACION DE LINEAS
*----------------------------------------------------------------------*
FORM log_contab.

  zmm_log_carga-correl_carga     = gs_datos-correlativo.
  zmm_log_carga-evento_carga     = 'CONTAB'.
  zmm_log_carga-fecha_carga      = sy-datum.
  zmm_log_carga-hora_carga       = sy-uzeit.
  zmm_log_carga-linea_carga      = gs_datos-secuencia.
  zmm_log_carga-articulo_carga   = gs_datos-no_mat.
  zmm_log_carga-cant_carga       = gs_datos-cantidad.
  zmm_log_carga-um_carga         = gs_datos-um.
  INSERT  zmm_log_carga.
ENDFORM.                    "LOG de contabilidad
