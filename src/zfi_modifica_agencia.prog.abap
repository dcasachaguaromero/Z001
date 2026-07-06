*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFI_MODIFICA_AGENCIA
*&
*&---------------------------------------------------------------------*
*& Descripción: Modificación individual/masiva de agencias en documentos
*&              contables
*& Fecha: 18.08.2010
*&---------------------------------------------------------------------*
REPORT  zfi_modifica_agencia.

TYPE-POOLS: slis.

TABLES: bkpf, bseg.

DATA: ti_bseg LIKE bseg OCCURS 0 WITH HEADER LINE,
      ti_bsec LIKE bsec OCCURS 0 WITH HEADER LINE,
      ti_bset LIKE bset OCCURS 0 WITH HEADER LINE,
      ti_bkpf LIKE bkpf OCCURS 0 WITH HEADER LINE,
      ti_bkdf LIKE bkdf OCCURS 0 WITH HEADER LINE,
      ti_bsed LIKE bsed OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF t_log OCCURS 0,
        bukrs LIKE bseg-bukrs,
        belnr LIKE bseg-belnr,
        gjahr LIKE bseg-gjahr,
        buzei LIKE bseg-buzei,
        agencia_old LIKE bseg-zz_agencia,
        agencia_new LIKE bseg-zz_agencia,
        mensaje(30),
      END OF t_log.

TYPES: BEGIN OF t_data,
        bukrs LIKE bseg-bukrs,
        belnr LIKE bseg-belnr,
        gjahr LIKE bseg-gjahr,
        buzei LIKE bseg-buzei,
        agencia LIKE bseg-zz_agencia,
      END OF t_data.

DATA: t_registros LIKE alsmex_tabline OCCURS 6000 WITH HEADER LINE,
      wa_data TYPE t_data,
      it_data TYPE STANDARD TABLE OF t_data INITIAL SIZE 0,
      tot_reg_leidos TYPE i.

DATA: todo_ok(1).
DATA:  fila TYPE i.

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Variables para uso de ALV
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
DATA : titulo       LIKE sy-title.
CONSTANTS: formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE',
           c_pf_status_set TYPE slis_formname VALUE 'PF_STATUS_SET'.

DATA: fieldtab TYPE slis_t_fieldcat_alv,
      heading  TYPE slis_t_listheader,
      layout   TYPE slis_layout_alv,
      events   TYPE slis_t_event,
      repname  LIKE sy-repid,
      f2code   LIKE sy-ucomm VALUE  '&ETA',
      g_save(1) TYPE c,
      g_exit(1) TYPE c,
      g_variant LIKE disvariant,
      gx_variant LIKE disvariant,
      i_list_comments     TYPE slis_t_listheader,
      gt_sort TYPE slis_t_sortinfo_alv,
      lt_commentary TYPE slis_t_listheader WITH HEADER LINE,
      w_list_comments LIKE LINE OF i_list_comments,
      t_print             TYPE slis_print_alv,
      w_callback_ucomm TYPE  slis_formname,
      alv_variant      LIKE disvariant,
      v_hora LIKE sy-timlo,
      v_indice TYPE i.

* Selección Individual
SELECTION-SCREEN: BEGIN OF BLOCK uno1 WITH FRAME TITLE text-001.
PARAMETERS: pa_bukrs LIKE bkpf-bukrs MODIF ID gr2,     " Sociedad
            pa_belnr LIKE bkpf-belnr MODIF ID gr2,     " N° documento
            pa_gjahr LIKE bkpf-gjahr MODIF ID gr2,     " Ejercicio
            pa_buzei LIKE bseg-buzei  MODIF ID gr2,     " Posición
            pagencia LIKE cobl-zz_agencia MODIF ID gr2. " Agencia
SELECTION-SCREEN: END OF BLOCK uno1.

* Selección masiva
SELECTION-SCREEN: BEGIN OF BLOCK uno WITH FRAME TITLE text-001.
PARAMETERS: p_file(128) TYPE c DEFAULT 'D:\' LOWER CASE MODIF ID gr1.
SELECTION-SCREEN: END OF BLOCK uno.

SELECTION-SCREEN: BEGIN OF BLOCK dos WITH FRAME TITLE text-003.
PARAMETERS: rad1 RADIOBUTTON GROUP grp1 USER-COMMAND uc1,
            rad2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN: END OF BLOCK dos.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = p_file
      def_path         = '\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Selección de Archivo'
    IMPORTING
      filename         = p_file
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

INITIALIZATION.
  rad1 = 'X'.

AT SELECTION-SCREEN OUTPUT.
* Si presiono el primer radiobutton entonces se ocultara el campo p_fecha
  IF rad1 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'GR1'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'GR1'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF rad2 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'GR2'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'GR2'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

START-OF-SELECTION.
  IF rad1 = 'X'.
* Individual
    PERFORM individual.
  ELSE.
* Masivo
    PERFORM masivo.
  ENDIF.
  IF NOT t_log[] IS INITIAL.
* Se emite log de salida
    PERFORM listado.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  individual
*&---------------------------------------------------------------------*
FORM individual.
  CLEAR todo_ok.
  IF pa_bukrs IS INITIAL.
    MESSAGE 'Debe ingresar sociedad.' TYPE 'I'.
    todo_ok = 'X'.
  ENDIF.
  IF todo_ok IS INITIAL.
    IF pa_belnr IS INITIAL.
      MESSAGE 'Debe ingresar documento.' TYPE 'I'.
      todo_ok = 'X'.
    ENDIF.
  ENDIF.
  IF todo_ok IS INITIAL.
    IF pa_gjahr IS INITIAL.
      MESSAGE 'Debe ingresar ejercicio.' TYPE 'I'.
      todo_ok = 'X'.
    ENDIF.
  ENDIF.
  IF todo_ok IS INITIAL.
    IF pa_buzei IS INITIAL.
      MESSAGE 'Debe ingresar posición.' TYPE 'I'.
      todo_ok = 'X'.
    ENDIF.
  ENDIF.
  IF todo_ok IS INITIAL.
    IF pagencia IS INITIAL.
      MESSAGE 'Debe ingresar agencia.' TYPE 'I'.
      todo_ok = 'X'.
    ENDIF.
  ENDIF.
  IF todo_ok IS INITIAL.
* Se valida que el documento exista
    SELECT SINGLE * FROM bkpf
      WHERE belnr = pa_belnr
        AND gjahr = pa_gjahr.
    IF sy-subrc EQ 0.
      PERFORM modifica_agencia USING pa_belnr pa_gjahr pa_bukrs pa_buzei pagencia.
    ELSE.
      t_log-bukrs = pa_bukrs.
      t_log-belnr = pa_belnr.
      t_log-gjahr = pa_gjahr.
      t_log-buzei = pa_buzei.
      t_log-agencia_old = ' '.
      t_log-agencia_new = pagencia.
      t_log-mensaje = 'No existe documento. Revisar.'.
      APPEND t_log.
    ENDIF.
  ENDIF.
ENDFORM.                    "individual

*&---------------------------------------------------------------------*
*&      Form  modifica_agencia
*&---------------------------------------------------------------------*
FORM modifica_agencia USING pa_belnr pa_gjahr pa_bukrs pa_buzei pagencia.
  REFRESH: ti_bseg, ti_bsec, ti_bset.
  CLEAR: ti_bseg, ti_bsec, ti_bset.


  CALL FUNCTION 'FI_DOCUMENT_READ1'
    EXPORTING
      i_docno = pa_belnr
      i_byear = pa_gjahr
      i_compy = pa_bukrs
    TABLES
      t_bseg  = ti_bseg
      t_bsec  = ti_bsec
      t_bset  = ti_bset.

  READ TABLE ti_bseg WITH KEY buzei = pa_buzei.
  IF sy-subrc EQ 0.
    CLEAR t_log.
    t_log-agencia_old = ti_bseg-zz_agencia.
    t_log-agencia_new = pagencia.
    t_log-bukrs = ti_bseg-bukrs.
    t_log-belnr = pa_belnr.
    t_log-gjahr = pa_gjahr.
    t_log-buzei = pa_buzei.
    ti_bseg-zz_agencia = pagencia.
    MODIFY ti_bseg INDEX sy-tabix.

    REFRESH ti_bkpf.
    CLEAR ti_bkpf.
    SELECT * INTO TABLE ti_bkpf
      FROM bkpf
      WHERE belnr = pa_belnr.

    REFRESH ti_bkdf.
    CLEAR ti_bkdf.
    SELECT * INTO TABLE ti_bkdf
      FROM bkdf
      WHERE bukrs = pa_bukrs
        AND belnr = pa_belnr
        AND gjahr = pa_gjahr.

    REFRESH ti_bsed.
    CLEAR ti_bsed.
SELECT * INTO TABLE ti_bsed
FROM bsed
WHERE bukrs = pa_bukrs
AND belnr = pa_belnr
AND gjahr = pa_gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND buzei = pa_buzei.
AND BUZEI = PA_BUZEI ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

    CALL FUNCTION 'CHANGE_DOCUMENT'
      TABLES
        t_bkdf = ti_bkdf
        t_bkpf = ti_bkpf
        t_bsec = ti_bsec
        t_bsed = ti_bsed
        t_bseg = ti_bseg
        t_bset = ti_bset.

    IF sy-subrc EQ 0.
*      update bsak set zz_agencia = pagencia
*      where bukrs = bukrs
*        and
      t_log-mensaje = 'Agencia modificada.'.
      COMMIT WORK AND WAIT.
    ELSE.
      t_log-mensaje = 'Agencia NO modificada.'.
    ENDIF.
    APPEND t_log.
  ENDIF.
ENDFORM.                    "individual

*&---------------------------------------------------------------------*
*&      Form  masivo
*&---------------------------------------------------------------------*
FORM masivo.
  PERFORM carga_archivo.
  PERFORM procesa.
ENDFORM.                    "masivo

*&---------------------------------------------------------------------*
*&      Form  carga_archivo
*&---------------------------------------------------------------------*
FORM carga_archivo.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_file
      i_begin_col             = '1'
      i_begin_row             = '2'
      i_end_col               = '5'
      i_end_row               = '10000'
    TABLES
      intern                  = t_registros
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

* Ordena la tabla por filas y columnas
  SORT t_registros BY row col.
  READ TABLE t_registros INDEX 1.
  fila = t_registros-row.

  LOOP AT t_registros.
    IF t_registros-row NE fila.
      APPEND wa_data TO it_data.
      CLEAR  wa_data.
      fila = t_registros-row.
    ENDIF.

    CASE t_registros-col.
      WHEN '001'.
        wa_data-bukrs = t_registros-value.
      WHEN '002'.
        wa_data-belnr = t_registros-value.
      WHEN '003'.
        wa_data-gjahr = t_registros-value.
      WHEN '004'.
        wa_data-buzei = t_registros-value.
      WHEN '005'.
        wa_data-agencia = t_registros-value.
    ENDCASE.
  ENDLOOP.
  APPEND wa_data TO it_data.

* Obtiene el total de registros leídos.
  DESCRIBE TABLE it_data LINES tot_reg_leidos.
ENDFORM.                    "carga_archivo

*&---------------------------------------------------------------------*
*&      Form  procesa
*&---------------------------------------------------------------------*
FORM procesa.
  LOOP AT it_data INTO wa_data.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_data-belnr
      IMPORTING
        output = wa_data-belnr.

    PERFORM modifica_agencia USING wa_data-belnr wa_data-gjahr wa_data-bukrs wa_data-buzei wa_data-agencia.
  ENDLOOP.
ENDFORM.                    "procesa
*&---------------------------------------------------------------------*
*&      Form  listado
*&---------------------------------------------------------------------*
FORM listado.
  repname = sy-repid.
  PERFORM inializar_fieldcat USING fieldtab[].
  PERFORM build_eventtab USING events[].
  PERFORM build_layout USING layout.
  PERFORM imprime_salida.
ENDFORM.                    "listado

*---------------------------------------------------------------------*
*       FORM inializar_fieldcat                                       *
*---------------------------------------------------------------------*
FORM inializar_fieldcat
               USING p_fieldtab TYPE slis_t_fieldcat_alv.
  DATA: l_fieldcat TYPE slis_fieldcat_alv.

  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_LOG'.
  l_fieldcat-fieldname = 'BUKRS'.
  l_fieldcat-seltext_l = 'Sociedad'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_LOG'.
  l_fieldcat-fieldname = 'BELNR'.
  l_fieldcat-seltext_l = 'N° Documento'.
  l_fieldcat-hotspot = 'X'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_LOG'.
  l_fieldcat-fieldname = 'GJAHR'.
  l_fieldcat-seltext_l = 'Ejercicio'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_LOG'.
  l_fieldcat-fieldname = 'BUZEI'.
  l_fieldcat-seltext_l = 'Posición'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_LOG'.
  l_fieldcat-fieldname = 'AGENCIA_OLD'.
  l_fieldcat-seltext_l = 'Antigua Agencia'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_LOG'.
  l_fieldcat-fieldname = 'AGENCIA_NEW'.
  l_fieldcat-seltext_l = 'Nueva Agencia'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_LOG'.
  l_fieldcat-fieldname = 'MENSAJE'.
  l_fieldcat-seltext_l = 'Mensaje proceso'.
  APPEND l_fieldcat TO p_fieldtab.
*
ENDFORM.                    "inializar_fieldcat

*---------------------------------------------------------------------*
*       FORM build_eventtab                                           *
*---------------------------------------------------------------------*
FORM build_eventtab USING    p_events TYPE slis_t_event.
  DATA: ls_event TYPE slis_alv_event.
  REFRESH p_events.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = p_events.

  READ TABLE p_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE formname_top_of_page TO ls_event-form.
    APPEND ls_event TO p_events.
  ENDIF.

ENDFORM.                    " build_eventtab

*---------------------------------------------------------------------*
*       FORM build_layout                                             *
*---------------------------------------------------------------------*
FORM build_layout USING    p_layout TYPE slis_layout_alv.
  p_layout-zebra        = 'X'.
  p_layout-detail_popup = 'X'.
  p_layout-colwidth_optimize = 'X'.
ENDFORM.                    " build_layout

*---------------------------------------------------------------------*
*       FORM imprime_salida                                           *
*---------------------------------------------------------------------*
FORM imprime_salida.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = repname
      i_callback_user_command = 'USER_COMMAND'
      is_layout               = layout
      it_fieldcat             = fieldtab
      it_events               = events[]
      i_save                  = 'A'
      is_variant              = gx_variant
    TABLES
      t_outtab                = t_log
    EXCEPTIONS
      program_error           = 1.
ENDFORM.                    "imprime_salida

*---------------------------------------------------------------------*
*       FORM top_of_page                                              *
*---------------------------------------------------------------------*
FORM top_of_page.
  DATA: hline TYPE slis_listheader,
        v_werks LIKE t001w-werks,
        w_texto(80) TYPE c,
        v_fecha(10),
        v_hora(8).

* Titulo Principal
  REFRESH i_list_comments.
  w_list_comments-typ  = 'H'. "H=Header, S=Selection, A=Action
  w_list_comments-key  = ''.
  w_list_comments-info = 'Modificación individual/masiva de Agencias'.
  APPEND w_list_comments TO i_list_comments.

* Fecha
  CLEAR: w_list_comments, w_texto, v_fecha.
  CONCATENATE sy-datum+6(2) '-' sy-datum+4(2) '-' sy-datum+0(4)
      INTO v_fecha.
  CONCATENATE 'Fecha:' v_fecha INTO w_texto SEPARATED BY space.
  w_list_comments-typ  = 'S'.
  w_list_comments-key  = ''.
  w_list_comments-info = w_texto.
  APPEND w_list_comments TO i_list_comments.

* Hora
  CLEAR: w_list_comments, w_texto, v_hora.
  CONCATENATE sy-timlo+0(2) ':' sy-datum+4(2) ':' sy-datum+6(2)
      INTO v_hora.
  CONCATENATE 'Hora:' v_hora INTO w_texto SEPARATED BY space.
  w_list_comments-typ  = 'S'.
  w_list_comments-key  = ''.
  w_list_comments-info = w_texto.
  APPEND w_list_comments TO i_list_comments.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_list_comments.
ENDFORM.                    "top_of_page

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&IC1'. " HotSpot
      READ TABLE t_log INDEX rs_selfield-tabindex.
      SET PARAMETER ID 'BLN' FIELD t_log-belnr.
      SET PARAMETER ID 'BUK' FIELD t_log-bukrs.
      SET PARAMETER ID 'GJR' FIELD t_log-gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDCASE.
ENDFORM.                    "user_command
