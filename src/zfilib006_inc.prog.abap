*----------------------------------------------------------------------*
***INCLUDE ZFILIB006_INC .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  REPORTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REPORTE.
*LEAVE TO LIST-PROCESSING. "AND RETURN TO SCREEN 0.
* LEAVE TO LIST-PROCESSING. NEW-PAGE NO-HEADING NO-TITLE.


  REFRESH: GT_FIELDCAT.
  CLEAR: GT_EVENTS, GT_LIST_TOP_OF_PAGE, LS_TOOLBAR.
  PERFORM BUILD.
*  PERFORM BUILD2.
  PERFORM EVENTTAB_BUILD CHANGING GT_EVENTS.
  PERFORM LAYOUT_INIT USING GS_LAYOUT.
  PERFORM COMMENT_BUILD  CHANGING GT_LIST_TOP_OF_PAGE.
  PERFORM CALL_ALV.
ENDFORM.                    " REPORTE_


*&---------------------------------------------------------------------*
*&      Form  BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD.
* DATA FIELD CATALOG
* Explain Field Description to ALV
  DATA: FIELDCAT_IN TYPE SLIS_FIELDCAT_ALV.
CONSTANTS p_len TYPE i value 15.

CLEAR: FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'LTEXT'.
  FIELDCAT_LN-KEY       = ' '.   "SUBTOTAL KEY
  FIELDCAT_LN-CHECKBOX   = ' '.
  FIELDCAT_LN-EDIT    = ' '.
  FIELDCAT_LN-SELTEXT_L = 'Tipo Documento'.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-FIX_COLUMN = 'X'.
  FIELDCAT_LN-outputlen = p_len.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

CLEAR: FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'BELNR'.
  FIELDCAT_LN-KEY       = ' '.   "SUBTOTAL KEY
  FIELDCAT_LN-CHECKBOX   = ' '.
  FIELDCAT_LN-EDIT    = ' '.
  FIELDCAT_LN-SELTEXT_L = 'Numero de Doc.'.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-FIX_COLUMN = ' '.
  FIELDCAT_LN-JUST = 'R'.
  FIELDCAT_LN-outputlen = p_len.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

CLEAR: FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'STCD1'.
  FIELDCAT_LN-KEY       = ' '.   "SUBTOTAL KEY
  FIELDCAT_LN-CHECKBOX   = ' '.
  FIELDCAT_LN-EDIT    = ' '.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-SELTEXT_L = 'R.U.T'.
  FIELDCAT_LN-JUST = ' '.
  FIELDCAT_LN-outputlen = p_len.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

CLEAR: FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'NAME1'.
  FIELDCAT_LN-KEY       = ' '.   "SUBTOTAL KEY
  FIELDCAT_LN-CHECKBOX   = ' '.
  FIELDCAT_LN-EDIT    = ' '.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-SELTEXT_L = 'Nombre'.
  FIELDCAT_LN-outputlen = 30.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

CLEAR: FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'XBLNR'.
  FIELDCAT_LN-KEY       = ' '.   "SUBTOTAL KEY
  FIELDCAT_LN-CHECKBOX   = ' '.
  FIELDCAT_LN-EDIT    = ' '.
  FIELDCAT_LN-SELTEXT_L = 'Boleta'.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-outputlen = p_len.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

CLEAR: FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'BLDAT'.
  FIELDCAT_LN-SELTEXT_L = 'Fecha Ref.'.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-outputlen = p_len.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

CLEAR: FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'BUDAT'.
  FIELDCAT_LN-SELTEXT_L = 'Fecha Contb'.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-outputlen = p_len.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

CLEAR: FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'WT_QSSHH'.
  FIELDCAT_LN-SELTEXT_L = 'Valor Boleta'.
  FIELDCAT_LN-CURRENCY  = 'CLP'.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-DO_SUM  = 'X'.
  FIELDCAT_LN-JUST = 'R'.
  FIELDCAT_LN-outputlen = p_len.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

CLEAR: FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'WT_QBSHH'.
  FIELDCAT_LN-CURRENCY  = 'CLP'.
  FIELDCAT_LN-SELTEXT_L = 'Valor Retencion'.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-DO_SUM  = 'X'.
  FIELDCAT_LN-JUST = ' '.
  FIELDCAT_LN-outputlen = p_len.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

CLEAR: FIELDCAT_IN.

  FIELDCAT_LN-FIELDNAME = 'DMBTR'.
  FIELDCAT_LN-SELTEXT_L = 'Valor a Pagar'.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-DO_SUM  = 'X'.
  FIELDCAT_LN-CURRENCY  = 'CLP'.
  FIELDCAT_LN-outputlen = p_len.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

* DATA SORTING AND SUBTOTAL
  DATA: GS_SORT TYPE SLIS_SORTINFO_ALV.
ENDFORM.                    "BUILD
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*

FORM LAYOUT_INIT USING RS_LAYOUT TYPE SLIS_LAYOUT_ALV.
  RS_LAYOUT-GROUP_CHANGE_EDIT = 'X'.
  RS_LAYOUT-DETAIL_POPUP      = 'X'.
  RS_LAYOUT-INFO_FIELDNAME    = 'X'.
*  RS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  RS_LAYOUT-ZEBRA             = 'X'.
ENDFORM.                    "LAYOUT_INIT

*&---------------------------------------------------------------------*
*&      Form  CALL_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_ALV.
  G_REPID = SY-REPID.

  PERFORM CANT_REGISTROS.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = G_REPID
      i_callback_html_top_of_page = l_callback_html_top_of_page
      I_CALLBACK_PF_STATUS_SET = 'ZFULLSCREEN'
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND_DET'
      I_BACKGROUND_ID          = 'LOGOISAPBAN002'
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT[]
      IT_EVENTS                = GT_EVENTS
      it_sort                     = gt_sort[]
      i_html_height_top         = 32
    TABLES
      T_OUTTAB                 = OUTPUT_LIST
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.

  ENDIF.
ENDFORM.                    "CALL_ALV

*&---------------------------------------------------------------------*
*&      Form  f008_set_pf_status
*&---------------------------------------------------------------------*
*       Customized PF status to include the icon for creating SES
*----------------------------------------------------------------------*
FORM ZFULLSCREEN USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZFULLSCREEN'.
ENDFORM.                    "f008_set_pf_status


* HEADER FORM
FORM EVENTTAB_BUILD CHANGING LT_EVENTS TYPE SLIS_T_EVENT.
  CONSTANTS:
  GC_FORMNAME_TOP_OF_PAGE TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE'.
  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.



  LS_EVENT-NAME = SLIS_EV_USER_COMMAND.
  LS_EVENT-FORM = 'USER_COMMAND_DET'.
  APPEND LS_EVENT TO GT_EVENTS.

  LS_EVENT-NAME = slis_ev_pf_status_set.
  LS_EVENT-FORM = 'ZFULLSCREEN'.
  APPEND LS_EVENT TO GT_EVENTS.



  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = LT_EVENTS.
  READ TABLE LT_EVENTS WITH KEY NAME =  SLIS_EV_TOP_OF_PAGE   INTO LS_EVENT.
  IF SY-SUBRC = 0.
    MOVE GC_FORMNAME_TOP_OF_PAGE TO LS_EVENT-FORM.
    APPEND LS_EVENT TO LT_EVENTS.
  ENDIF.
ENDFORM.                    "EVENTTAB_BUILD


*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->GT_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
FORM COMMENT_BUILD CHANGING GT_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.


  DATA: GS_LINE TYPE SLIS_LISTHEADER.
  CLEAR GS_LINE.
  GS_LINE-TYP  = 'H'.
  GS_LINE-INFO = 'Libro de Retenciones'.

  APPEND GS_LINE TO GT_TOP_OF_PAGE.

  CLEAR GS_LINE.
  GS_LINE-TYP  = 'S'.
  GS_LINE-KEY  = 'Sociedad'.
  GS_LINE-INFO = s_compy.
  APPEND GS_LINE TO GT_TOP_OF_PAGE.

  GS_LINE-TYP  = 'S'.
  GS_LINE-KEY  = 'Fecha de Ejecución'.
  WRITE: BKPF-BUDAT TO GS_LINE-INFO.
  APPEND GS_LINE TO GT_TOP_OF_PAGE.

  GS_LINE-KEY  = 'Usuario'.
  GS_LINE-INFO = SY-UNAME.
  APPEND GS_LINE TO GT_TOP_OF_PAGE.


ENDFORM.                    "COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TOP_OF_PAGE.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.
  WRITE: SY-DATUM, 'Page No', SY-PAGNO LEFT-JUSTIFIED.
ENDFORM.                    "TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  END_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM END_OF_PAGE.
  WRITE AT (SY-LINSZ) SY-PAGNO CENTERED.
ENDFORM.                    "END_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_DET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->F_UCOMM    text
*      -->I_SELFIELD text
*----------------------------------------------------------------------*
FORM USER_COMMAND_DET USING F_UCOMM LIKE SY-UCOMM
    I_SELFIELD TYPE SLIS_SELFIELD.

  I_SELFIELD-REFRESH = 'X'.

  DATA: ANN TYPE PAYR-GJAHR.
  DATA: AN1 TYPE PAYR-VBLNR.
  DATA: FEC(4) TYPE C.

  DATA: SAVE_CODE TYPE SY-UCOMM.
  DATA: G_CONCEP   TYPE SLIS_FIELDNAME.
  DATA: RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA : LS_OUTPUT LIKE LINE OF OUTPUT_LIST.

  RS_SELFIELD-REFRESH = 'X'.

  SAVE_CODE = SY-UCOMM.
*  CASE SAVE_CODE.
*    WHEN '&DATA_SAVE'.
*      IF T_RPT EQ 'C'.
*        PERFORM GENE_JUEGO_DATOS.
*      ENDIF.
*
*      IF T_RPT EQ 'A'. " Anulacion.
*        PERFORM GENE_TR_FCH9 USING BUKRS HBKID HKTID.
*      ENDIF.
*
*      IF T_RPT EQ 'R'. " REVERSA.
*        PERFORM REVERSA_CHEQUES USING BUKRS HBKID HKTID.
*      ENDIF.
*
*     WHEN '&ALL1'.
*        PERFORM MARCAR_ALL.
*     WHEN '&SAL1'.
*        PERFORM DESMARCA_MARCAR_ALL.
**     WHEN '&MASIVO'.
**        PERFORM ARCHIVOS_MASIVO.
*
*  ENDCASE.

 CASE SY-UCOMM.
    WHEN '&FILE'. "GENERA ARCHIVO
      IF ZFILE IS NOT INITIAL.
        PERFORM GET_FILE USING ZFILE.
      ELSE.
         MESSAGE 'Debe Indicar la Ruta del Archivo de Texto' type  'E'.
      ENDIF.
    WHEN 'LINE'.
      CALL SCREEN 0100
        STARTING AT 20 1.
  ENDCASE.

  CASE F_UCOMM.
    WHEN '&IC1'. "Doble Click
      READ TABLE  OUTPUT_LIST INTO LS_OUTPUT INDEX I_SELFIELD-TABINDEX.
      IF SY-SUBRC EQ 0.
        PERFORM CALL_FB03 USING LS_OUTPUT-belnr s_compy s_year.
      ENDIF.


  ENDCASE.

ENDFORM.                    "USER_COMMAND_DET
*&---------------------------------------------------------------------*
*&      Form  CANT_REGISTROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANT_REGISTROS .
  DATA: T_REG TYPE I.
  DATA: s_REG(4) TYPE c.
  DATA :P_TEXTO2(40) TYPE C.
  CLEAR P_TEXTO2.
  IF output_list[] IS NOT INITIAL.
      DESCRIBE TABLE output_list LINES T_REG.
      s_REG = t_REG.
      SHIFT s_REG RIGHT DELETING TRAILING SPACE.
      CONCATENATE 'Se Visualizan'  s_REG ' Registro(s).'   INTO P_TEXTO2.
      MESSAGE P_TEXTO2 TYPE 'S'.
  ENDIF.
ENDFORM. " CANT_REGISTROS
FORM sort_init  USING expa TYPE c
                CHANGING t_sort TYPE slis_t_sortinfo_alv.

  DATA: ls_sort TYPE slis_sortinfo_alv,
        l_expa.

  REFRESH  t_sort.
  MOVE expa TO l_expa.
  ls_sort-fieldname = 'LTEXT'.
  ls_sort-subtot = 'X'.
  ls_sort-expa = l_expa.
  APPEND ls_sort TO t_sort.CLEAR ls_sort.
ENDFORM.                    " SORT_INIT
*&---------------------------------------------------------------------*
*&      Form  LS_OUTPUT_ABS
*&---------------------------------------------------------------------*
*       Se dejan los valores de esta tabla interna en valores absolutos
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LS_OUTPUT_ABS .

LOOP AT OUTPUT_LIST.

  MOVE ABS( OUTPUT_LIST-DMBTR ) TO  OUTPUT_LIST-DMBTR.
  MOVE ABS( OUTPUT_LIST-DMBT2 ) TO    OUTPUT_LIST-DMBT2.
  MOVE ABS( OUTPUT_LIST-DMBT3 ) TO    OUTPUT_LIST-DMBT3.
  MOVE ABS( OUTPUT_LIST-WT_QSSHH ) TO OUTPUT_LIST-WT_QSSHH.
  MOVE ABS( OUTPUT_LIST-WT_QBSHH ) TO OUTPUT_LIST-WT_QBSHH.
  MOVE ABS( OUTPUT_LIST-WT_QBSH2 ) TO OUTPUT_LIST-WT_QBSH2.
  MOVE ABS( OUTPUT_LIST-WT_QBSH3 ) TO OUTPUT_LIST-WT_QBSH3.
  modify OUTPUT_LIST.
ENDLOOP.



ENDFORM.                    " LS_OUTPUT_ABS
