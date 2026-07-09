*&---------------------------------------------------------------------*
*& Report  Z_SUBE_ANEP
*&
*&---------------------------------------------------------------------*
*&Rescata Tabla ANEP Original Respaldada
*&
*&---------------------------------------------------------------------*

REPORT  Z_SUBE_ANEP.

tables ANEP.

data : begin of t_texto occurs 0,
         valor(40),
       end of t_texto,
       begin of t_ANEP occurs 0.
        include structure ANEP.
data :    box   type c,
       end of t_ANEP,
       err_ANEP like ANEP occurs 0 with header line,
       ERROR    TYPE C.
* Variables ALV
TYPE-POOLS slis.

DATA: g_repid             LIKE sy-repid,
      gt_fieldcatalogo    TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gt_fieldcatal_err   TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gt_list_top_of_page TYPE slis_t_listheader,
      gt_events           TYPE slis_t_event,
      gs_layout           TYPE slis_layout_alv,
      gs_layout_err       TYPE slis_layout_alv,
      lt_events           TYPE slis_t_event,
      g_status            TYPE slis_formname VALUE 'BOTONES',
      g_top_of_page       TYPE slis_formname VALUE 'TOP_OF_PAGE',
      gs_variant          TYPE disvariant.

SELECTION-SCREEN skip 1.
SELECTION-SCREEN BEGIN OF BLOCK rad1 WITH FRAME.
PARAMETERS: direct(128) LOWER CASE obligatory default
           '/usr/sap/DE9/DVEBMGS09/work/'.
PARAMETERS: ARCHIVO(128) LOWER CASE obligatory default
           'ANEP.TXT'.

SELECTION-SCREEN skip 1.
  PARAMETERS : P_AF_ALT LIKE T093-AFABER.
SELECTION-SCREEN skip 1.
PARAMETERS: P_TEST AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK rad1.

at selection-screen on VALUE-REQUEST for archivo.
  PERFORM lee_directorio USING DIRECT
                         CHANGING ARCHIVO.


start-of-selection.

  perform lee_ANEP.
  IF SY-BATCH IS INITIAL.
  perform muestra_datos.
  ELSE.
   PERFORM ACTUALIZA_DATOS_BATCH.
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  LEE_ANEP
*&---------------------------------------------------------------------*
FORM LEE_ANEP .
  data : e_ANEP         type ANEP,
         filename       type string,
         txt_line       type string,
         valor(40)      type c,
         l_tabix        like sy-tabix.

  FIELD-SYMBOLS: <wa>   TYPE ANY,
                 <comp>.

  ASSIGN e_ANEP TO <wa>.

*
  concatenate direct archivo into filename.
  CLOSE DATASET filename.

  OPEN DATASET filename FOR INPUT IN text MODE encoding default.
  IF sy-subrc EQ 0.

    DO.
      READ DATASET filename INTO txt_line.
      IF SY-SUBRC <> 0.
        EXIT.
      ENDIF.
      split txt_line at ';' into TABLE t_texto IN CHARACTER MODE.

      clear e_ANEP.
      loop at t_texto.
        l_tabix = sy-tabix.
        ASSIGN COMPONENT l_tabix OF STRUCTURE <wa> TO <comp>.
        translate t_texto-valor using ',.'.
        <comp> = t_texto-valor.
      endloop.


        append e_ANEP to t_ANEP.

    ENDDO.

    CLOSE DATASET filename.
  else.
    MESSAGE s897(sd) WITH 'ERROR al abrir archivo de lectura'
                           filename.
  ENDIF.

ENDFORM.                    " LEE_ANEP
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM MUESTRA_DATOS .
*
  MOVE SY-REPID TO G_REPID.
  gs_variant-report = g_repid.
*-- Activa Catalogo en ALV
  PERFORM catalogo       USING gt_fieldcatalogo[]
                               'T_ANEP'
                               g_repid  'I'.
*-- Lista Cabecera en ALV
  PERFORM comment_build  USING gt_list_top_of_page[] text-004.
*-- Activacion eventos de ALV
  PERFORM eventtab_build USING gt_events[].
*-- Activa Eventos en ALV
  PERFORM layout_init    USING gs_layout ' '.
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
      I_CALLBACK_PF_STATUS_SET = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcatalogo[]
      is_variant               = gs_variant
      i_save                   = 'A'
      it_events                = gt_events[]
    TABLES
      t_outtab                 = t_ANEP
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

ENDFORM.                    " MUESTRA_DATOS
*---------------------------------------------------------------------*
*       FORM user_command                                             *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
  DATA L_TABIX LIKE SY-TABIX.

  CLEAR ERROR.
  case r_ucomm.
    when 'FC01'.
      refresh err_ANEP.
      LOOP AT T_ANEP WHERE BOX EQ 'X'.
        MOVE SY-TABIX TO L_TABIX.
        move-corresponding t_ANEP to ANEP.
*
* PGR CARGA EN AREA ALTERNATIVA
        IF NOT P_AF_ALT IS INITIAL.
          move P_AF_ALT to anep-afabe.
        ENDIF.
***********************************
*        insert ANEP.
* PGR
         check P_TEST is initial.
         MODIFY ANEP.
        if sy-subrc ne 0.
          append ANEP to err_ANEP.
        endif.
        T_ANEP-BOX = ' '.
        MODIFY T_ANEP INDEX L_TABIX.
      ENDLOOP.
      IF SY-SUBRC NE 0.
        MESSAGE e899(fi) WITH 'Seleccione registros que actualizara'.
      ENDIF.
    when 'FC02'.
      PERFORM MUESTRA_DATOS_ERR.
  endcase.

  rs_selfield-refresh = 'X'.
endform.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS_ERR
*&---------------------------------------------------------------------*
FORM MUESTRA_DATOS_ERR .
*
  MOVE 'X' TO ERROR.
*-- Activa Catalogo en ALV
  PERFORM catalogo       USING gt_fieldcatal_err[]
                               'ERR_ANEP'
                               g_repid 'I'.
*-- Lista Cabecera en ALV
  PERFORM comment_build  USING gt_list_top_of_page[] TEXT-003.
*-- Activa Eventos en ALV
  PERFORM layout_init    USING gs_layout_err 'X'.
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = g_repid
      is_layout          = gs_layout_ERR
      it_fieldcat        = gt_fieldcatal_err[]
      is_variant         = gs_variant
      i_save             = 'A'
      it_events          = gt_events[]
    TABLES
      t_outtab           = ERR_ANEP
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
ENDFORM.                    " MUESTRA_DATOS
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.

  DATA fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE.

  CLEAR: fcode_attrib_tab, fcode_attrib_tab[].
* function: participation-list
  fcode_attrib_tab-text      = text-001.
  fcode_attrib_tab-icon_id   = '@01@'.
  fcode_attrib_tab-icon_text = text-001.
  fcode_attrib_tab-quickinfo = space.
  fcode_attrib_tab-path      = space.
  APPEND fcode_attrib_tab.
*
  if err_ANEP[] is not initial.
    CLEAR: fcode_attrib_tab.
* function: participation-list
    fcode_attrib_tab-text      = text-002.
    fcode_attrib_tab-icon_id   = '@02@'.
    fcode_attrib_tab-icon_text = text-002.
    fcode_attrib_tab-quickinfo = space.
    fcode_attrib_tab-path      = space.
    APPEND fcode_attrib_tab.
  endif.
*
  PERFORM dynamic_report_fcodes(rhteiln0) TABLES fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.
  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.
ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  CATALOGO
*&---------------------------------------------------------------------*
FORM CATALOGO USING lt_fieldcat TYPE slis_t_fieldcat_alv
                    structure
                    p_g_repid
                    P_OPCION.

  CASE P_OPCION.
    WHEN 'I'.
      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          I_PROGRAM_NAME         = p_G_REPID
          I_INTERNAL_TABNAME     = structure
*      I_STRUCTURE_NAME       = structure
          I_INCLNAME             = p_g_repid
        CHANGING
          CT_FIELDCAT            = lt_fieldcat
        EXCEPTIONS
          INCONSISTENT_INTERFACE = 1
          PROGRAM_ERROR          = 2
          OTHERS                 = 3.
    WHEN 'E'.
      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          I_STRUCTURE_NAME       = structure
        CHANGING
          CT_FIELDCAT            = lt_fieldcat
        EXCEPTIONS
          INCONSISTENT_INTERFACE = 1
          PROGRAM_ERROR          = 2
          OTHERS                 = 3.
  ENDCASE.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " CATALOGO
*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM COMMENT_BUILD USING lt_top_of_page TYPE
                                        slis_t_listheader OPCION.
  DATA: ls_line TYPE slis_listheader,
        fecha(10) TYPE c.


  REFRESH lt_top_of_page.
*
  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = OPCION.
*  IF OPCION IS INITIAL.
*    ls_line-info = 'Datos de tabla ANEP Respaldados'.
*  ELSE.
*    ls_line-info = 'Datos con ERROR de tabla ANEP Respaldados'.
*  ENDIF.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-info = 'ENTEL PCS'.                               "#EC NOTEXT
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.

  CONCATENATE sy-datum+6(2) '-' sy-datum+4(2) '-' sy-datum+0(4)
              INTO fecha.

  CONCATENATE 'Fecha     : ' fecha
              INTO ls_line-info SEPARATED BY space.         "#EC NOTEXT

  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  CONCATENATE 'Usuario   : ' syst-uname
               INTO ls_line-info SEPARATED BY space.        "#EC NOTEXT

  APPEND ls_line TO lt_top_of_page.

ENDFORM.                    " COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
FORM eventtab_build USING rt_events TYPE slis_t_event.
*-- Registra eventos durante la lista de despliegue
  DATA: ls_event TYPE slis_alv_event.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = rt_events.
  READ TABLE rt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE g_top_of_page TO ls_event-form.
    APPEND ls_event TO rt_events.
  ENDIF.
ENDFORM.                    " EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv OPC.
*-- Construye layout para desplegar lista
  rs_layout-detail_popup      = 'X'.
  rs_layout-colwidth_optimize = 'X'.
  CHECK OPC IS INITIAL.
  rs_layout-box_fieldname     = 'BOX'.

ENDFORM.                    " LAYOUT_INIT
*---------------------------------------------------------------------*
*       FORM top_of_page                                              *
*---------------------------------------------------------------------*
FORM top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_list_top_of_page.
ENDFORM.                    "top_of_page
*&---------------------------------------------------------------------*
*&      Form  LEE_DIRECTORIO
*&---------------------------------------------------------------------*
FORM LEE_DIRECTORIO USING    P_DIRECT
                    CHANGING P_ARCHIVO.
  DATA:  dir_list       LIKE  epsfili     OCCURS 0 WITH HEADER LINE,
         l_name         LIKE epsf-epsfilnam,
         select_ext     LIKE dfies-fieldname,
         lt_selected    LIKE ddshretval   OCCURS 0 WITH HEADER LINE,
         BEGIN OF t_archivos OCCURS 0,
           archi     LIKE rlgrap-filename,
           SIZE      TYPE EPSFILSIZ,
         END OF t_archivos.
  DATA: BEGIN OF fields OCCURS 2.
          INCLUDE STRUCTURE dfies.
  DATA: END OF fields.
  DATA: BEGIN OF values OCCURS 80,
          line(80) TYPE c,
        END OF values.
*
  PERFORM leer_directorio TABLES dir_list
                          USING P_ARCHIVO P_DIRECT .
*
  LOOP AT dir_list.
    MOVE dir_list-name TO t_archivos-archi.
    MOVE dir_list-SIZE TO t_archivos-SIZE.
    APPEND t_archivos.
    CLEAR  t_archivos.
  ENDLOOP.
*
  CHECK NOT t_archivos[] IS INITIAL.
  REFRESH fields. REFRESH values.
  fields-tabname    = 'T_ARCHIVOS'.
  fields-fieldname  = 'ARCHI'.
  fields-outputlen  = 40.
  fields-intlen     = 50.
  APPEND fields.
*
*
  fields-tabname    = 'T_ARCHIVOS'.
  fields-fieldname  = 'SIZE'.
  fields-outputlen  = 10.
  fields-intlen     = 10.
  APPEND fields.
*
  LOOP AT  T_ARCHIVOS.
    values-line = t_archivos-archi.
    APPEND values.

    values-line = t_archivos-SIZE.
    CONDENSE values-line NO-GAPS.
    APPEND values.
  ENDLOOP.
*
  CLEAR select_ext.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ARCHI'
      value_org       = 'C'
    TABLES
      value_tab       = values
      field_tab       = fields
      return_tab      = lt_selected
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    READ TABLE lt_selected INDEX 1.
    MOVE lt_selected-fieldval TO p_ARCHIVO.
  ENDIF.
ENDFORM.                    " LEE_DIRECTORIO
*&---------------------------------------------------------------------*
*&      Form  LEER_DIRECTORIO
*&---------------------------------------------------------------------*
FORM leer_directorio TABLES l_dir_list STRUCTURE epsfili
                    USING  p_archivo P_DIRECT.
  DATA : p_archi       LIKE  epsf-epsfilnam,
         p_directorio  LIKE epsf-epsdirnam.

  MOVE p_direct    TO p_directorio.
  MOVE p_archivo   TO p_archi.

  REFRESH l_dir_list.
  CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
    EXPORTING
      dir_name               = p_directorio
      file_mask              = p_archi
    TABLES
      dir_list               = l_dir_list
    EXCEPTIONS
      invalid_eps_subdir     = 1
      sapgparam_failed       = 2
      build_directory_failed = 3
      no_authorization       = 4
      read_directory_failed  = 5
      too_many_read_errors   = 6
      empty_directory_list   = 7
      OTHERS                 = 8.
  IF sy-subrc <> 0 OR l_dir_list[] IS INITIAL.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " LEER_DIRECTORIO
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZA_DATOS_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form ACTUALIZA_DATOS_BATCH .
*
      LOOP AT T_ANEP.
        move-corresponding t_ANEP to ANEP.
* PGR CARGA EN AREA ALTERNATIVA
        IF NOT P_AF_ALT IS INITIAL.
          move P_AF_ALT to anep-afabe.
        ENDIF.
***********************************
        check p_test is initial.
         MODIFY ANEP.
        if sy-subrc ne 0.
          write:/ 'Error al Grabar' , ANEP-anln1, ANEP-anln2.
        endif.
      ENDLOOP.
*
endform.                    " ACTUALIZA_DATOS
