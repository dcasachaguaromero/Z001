*&---------------------------------------------------------------------*
*& Report  ZZIMP_CHEQUES
*& REPORTE DE CHEQUES POR SOCIEDAD
*&---------------------------------------------------------------------*
*& OBSERVACION
*& CREADO :02NOV2009
*& ANALISTA:
*& PROGRAMADOR : LUIS  SEREÑO SILVA (ALYNEA-MVC)
*----------------------------------------------------------------------
*  LOG DE MODIFICACION:
*& FECHA
*& 02NOV2009
*&---------------------------------------------------------------------*

REPORT  ZIMP_CHEQUES.

TYPE-POOLS: slis.
TABLES: ZFIRMADIGITAL, T001.



DATA : BEGIN OF it_reporte OCCURS 0,
          MANDT	  TYPE MANDT , "Mandante
          BUKRS   TYPE BUKRS , "  Sociedad
          TDNAME  TYPE TDOBNAME, "Nombre
          RFCDEST	TYPE RFCDEST,	" Destino lógico (será indicado al llamar la función)
       END OF it_reporte.


DATA: alv_fieldcat TYPE slis_t_fieldcat_alv,
      alv_sort     TYPE slis_t_sortinfo_alv,
*      alv_GROUP    TYPE SLIS_T_SP_GROUP_ALV,
      alv_layout   TYPE slis_layout_alv,
      alv_events   TYPE slis_t_event,
      stru_disvar  TYPE disvariant,
      t_listheader  TYPE slis_t_listheader WITH HEADER LINE.
DATA: gs_variant               LIKE   disvariant.
DATA: g_save.
DATA: g_variant                LIKE disvariant.
DATA: g_repid                  LIKE   sy-repid.


* Heading of the report.
DATA: t_heading TYPE slis_t_listheader.
DATA:  gx_variant             LIKE disvariant.


*selection-screen: begin of block b1 with frame title text-t01.
*select-options: s_lifnr for lfa1-lifnr.
*SELECTION-SCREEN: END OF BLOCK b1.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
SELECT-OPTIONS: p_BUKRS FOR T001-BUKRS. " sOCIEDAD

SELECTION-SCREEN: END OF BLOCK b1.

INITIALIZATION.



*&---------------------------------------------------------------------*
*&      START-OF-SELECTION.
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  PERFORM select_data.

END-OF-SELECTION.

  PERFORM build_catalog USING alv_fieldcat.
  g_repid = sy-repid.
  g_save = 'A'.

  PERFORM build_events  USING alv_events.
  PERFORM build_header.
  PERFORM print_results.

*&---------------------------------------------------------------------*
*&      Form  BUILD
*&---------------------------------------------------------------------*
FORM build_catalog USING p_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: lw_fieldcat TYPE slis_fieldcat_alv.
  DATA: pos TYPE i.

  pos = pos + 1.
  CLEAR lw_fieldcat.
  lw_fieldcat-fieldname = 'BUKRS'.
  lw_fieldcat-col_pos = pos.
  lw_fieldcat-seltext_l = 'Sociedad'.
  lw_fieldcat-seltext_m = lw_fieldcat-seltext_l.
  lw_fieldcat-seltext_s = lw_fieldcat-seltext_l.
*  lw_fieldcat-outputlen = 12.
  APPEND  lw_fieldcat TO p_fieldcat.

  pos = pos + 1.
  CLEAR lw_fieldcat.
  lw_fieldcat-fieldname = 'TDNAME'.
  lw_fieldcat-col_pos = pos.
  lw_fieldcat-seltext_l = 'Firma'.
  lw_fieldcat-seltext_m = lw_fieldcat-seltext_l.
  lw_fieldcat-seltext_s = lw_fieldcat-seltext_l.
*  lw_fieldcat-outputlen = 10.
  APPEND  lw_fieldcat TO p_fieldcat.

  pos = pos + 1.
  CLEAR lw_fieldcat.
  lw_fieldcat-fieldname = 'RFCDEST'.
  lw_fieldcat-col_pos = pos.
  lw_fieldcat-seltext_l = 'Destino Logico'.
  lw_fieldcat-seltext_m = lw_fieldcat-seltext_l.
  lw_fieldcat-seltext_s = lw_fieldcat-seltext_l.
*  lw_fieldcat-outputlen = 20.
   APPEND  lw_fieldcat TO p_fieldcat.




ENDFORM.                    "FIELDCAT_UNIT

*&---------------------------------------------------------------------*
*&      Form  SHOW_ALV
*&---------------------------------------------------------------------*

FORM alv_grid_display .

  DATA: w_exit TYPE slis_exit_by_user.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = alv_layout
      it_fieldcat             = alv_fieldcat
      i_save                  = g_save
      is_variant              = g_variant
      it_events               = alv_events
      i_background_id         = 'ALV_BACKGROUND'
    TABLES
      t_outtab                = it_reporte
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "alv_grid_display

*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
FORM eventtab_build CHANGING lt_events TYPE slis_t_event.
  CONSTANTS:
  gc_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE'.

  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = lt_events.

  READ TABLE lt_events WITH KEY name =  slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE gc_formname_top_of_page TO ls_event-form.
*    LS_event-name = slis_ev_user_command.
*    LS_event-form = 'USER_COMMAND'.
    MODIFY lt_events INDEX sy-tabix FROM ls_event.
  ENDIF.
  CLEAR ls_event.
  READ TABLE lt_events WITH KEY name =  'USER_COMMAND'
         INTO ls_event.
  IF sy-subrc = 0.
    MOVE 'USER_COMMAND' TO ls_event-form.
    APPEND ls_event TO lt_events.
  ENDIF.

ENDFORM.                    "EVENTTAB_BUILD

*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*

FORM comment_build CHANGING gt_top_of_page TYPE slis_t_listheader.
  DATA: gs_line TYPE slis_listheader.
  CLEAR gs_line.

  CLEAR gs_line.
  gs_line-typ  = 'H'.
  gs_line-info = sy-title.
  APPEND gs_line TO gt_top_of_page.


ENDFORM.                    "COMMENT_BUILD

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM top_of_page.
  DATA: l_list_top_of_page TYPE slis_listheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_listheader[]
    EXCEPTIONS
      OTHERS             = 0.

*  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
*      EXPORTING
**     i_logo             = <<If you want to set a logo, please,
**                          uncomment and edit this line>>
*        it_list_commentary = t_heading.
*
**  l_list_top_of_page-typ = 'S'.
**  l_list_top_of_page-key = 'PROVEEDOR'.
**  l_list_top_of_page-info = 'XXXXXXXXXXXXXXXXXXXX'.
**  APPEND l_list_top_of_page TO gt_list_top_of_page.
ENDFORM.                    "TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  build_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_header .

  DATA:  fecha_head(10)   TYPE c,
         hora_head(8)     TYPE c.


  t_listheader-typ  = 'S'.
  t_listheader-key  = 'Reporte'.
  t_listheader-info = 'Reporte de cheques por sociedad'.
  APPEND t_listheader.


  t_listheader-typ  = 'S'.
  t_listheader-key  = 'Fecha'.
  CONCATENATE  sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum(4)
               INTO fecha_head.
  CONCATENATE  sy-uzeit(2) ':' sy-uzeit+2(2) ':' sy-uzeit+4(2)
               INTO hora_head.
  CONCATENATE  fecha_head '  -  ' hora_head  INTO  t_listheader-info.
  APPEND t_listheader.

  t_listheader-typ  = 'S'.
  t_listheader-key  = 'Usuario'.
  t_listheader-info = sy-uname.
  APPEND t_listheader.
  CLEAR t_listheader.
  APPEND t_listheader.




ENDFORM.                    " BUILD_HEADER
*---------------------------------------------------------------------*
*       FORM END_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM end_of_page.
*  WRITE at (sy-linsz) sy-pagno CENTERED.
ENDFORM.                    "END_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*

FORM layout_init USING rs_layout TYPE slis_layout_alv.
  rs_layout-group_change_edit = 'X'.
  rs_layout-detail_popup      = 'X'.
  rs_layout-info_fieldname    = 'X'.
  rs_layout-colwidth_optimize = 'X'.
  rs_layout-zebra             = 'X'.
ENDFORM.                    "LAYOUT_INIT

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.


ENDFORM.                    " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  build_events
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EVENTS  text
*----------------------------------------------------------------------*
FORM build_events USING rt_events TYPE slis_t_event.

  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = rt_events.

  READ TABLE rt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE 'TOP_OF_PAGE' TO ls_event-form.
    APPEND ls_event TO rt_events.
  ENDIF.

ENDFORM.                    "build_events
*&---------------------------------------------------------------------*
*&      Form  print_results
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM print_results .

  DATA: w_events .

  alv_layout-colwidth_optimize = ' '.
  alv_layout-zebra             = 'X'.

  PERFORM alv_grid_display.

ENDFORM.                    "print_results
form SELECT_DATA.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*Select BUKRS
*       TDNAME
*       RFCDEST
*  into corresponding fields of table  it_reporte
*  from ZFIRMADIGITAL
* WHERE BUKRS IN P_BUKRS
*  .
*
* NEW CODE
SELECT BUKRS
       TDNAME
       RFCDEST

  into corresponding fields of table  it_reporte
  from ZFIRMADIGITAL
 WHERE BUKRS IN P_BUKRS
   ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

ENDFORM.
