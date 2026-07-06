*&---------------------------------------------------------------------*
*&  Include           ZFITR016_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_nrotra   LIKE  zlog_pago_bancos-nrotran DEFAULT '1' NO-DISPLAY.
PARAMETERS : p_proc RADIOBUTTON GROUP cero DEFAULT 'X' USER-COMMAND wbs,
             p_repo RADIOBUTTON GROUP cero.
SELECTION-SCREEN SKIP 1.
PARAMETERS : p_bukrs      LIKE bkpf-bukrs,
             p_fecha      LIKE reguh-laufd,
             p_nomina     LIKE f110v-laufi                   MODIF ID web,
             p_fecpag     LIKE reguh-laufd                   MODIF ID nom,
             p_conven(10) AS LISTBOX VISIBLE LENGTH 20       MODIF ID web.
SELECT-OPTIONS : s_datum FOR wa_selec-datum MODIF ID wbs,
                 s_uname FOR wa_selec-uname MODIF ID wbs.
PARAMETERS     : p_proces AS LISTBOX VISIBLE LENGTH 20 DEFAULT '1'
                                            MODIF ID wbs.
SELECTION-SCREEN SKIP 1.
PARAMETERS : par_nom RADIOBUTTON GROUP uno  DEFAULT 'X' USER-COMMAND pro
                                            MODIF ID web,
             par_ren RADIOBUTTON GROUP uno  MODIF ID web.

SELECTION-SCREEN SKIP 1.
PARAMETERS : par_tes RADIOBUTTON GROUP test DEFAULT 'X' USER-COMMAND tst
                                            MODIF ID pro,
             par_di  RADIOBUTTON GROUP test MODIF ID pro. " Ejecución real
*             par_rej RADIOBUTTON GROUP test MODIF ID pro. " Re-Ejecución Test
SELECTION-SCREEN SKIP 1.

PARAMETERS  : p_archiv     TYPE string      MODIF ID ver
                                            DEFAULT 'C:\TRANSFER\'.
*SELECTION-SCREEN SKIP 1.
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT 10(25) TEXT-m01                     MODIF ID ver.
*SELECTION-SCREEN PUSHBUTTON 45(20) TEXT-but USER-COMMAND opc MODIF ID ver.
*SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK marco1 .

INITIALIZATION.
  PERFORM carga_datos.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_archiv.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'Carpeta de Almacenamiento'
      initial_folder  = 'C:\'
    CHANGING
      selected_folder = p_archiv.

*&---------------------------------------------------------------------*
*&     Validación de parámetros ingresados
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_bukrs.
  CHECK sy-ucomm EQ 'ONLI'.
  CLEAR wa_sociedad.
  IF p_bukrs IS NOT INITIAL.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
       ID 'BUKRS' FIELD p_bukrs.
    IF sy-subrc <> 0.
      MESSAGE e526(icc_tr) WITH p_bukrs.
    ELSE.
      PERFORM validacion_accesos USING p_bukrs.
    ENDIF.
  ELSEIF sy-batch IS INITIAL.
    MESSAGE e666(fi).
  ENDIF.

AT SELECTION-SCREEN ON p_fecha.
  CHECK sy-ucomm EQ 'ONLI' AND p_proc EQ gc_x AND sy-batch IS INITIAL.
  IF p_fecha IS INITIAL.
    MESSAGE e899(fi) WITH 'Indique la Fecha'.
  ENDIF.

AT SELECTION-SCREEN ON p_nomina.
  CHECK sy-ucomm EQ 'ONLI'  AND p_proc EQ gc_x AND sy-batch IS INITIAL.
  IF p_nomina IS INITIAL.
    MESSAGE e899(fi) WITH 'Indique la Nomina'.
  ENDIF.

AT SELECTION-SCREEN ON p_archiv.
  CHECK p_proc EQ gc_x AND  par_tes EQ 'X'.
  IF p_archiv IS INITIAL AND par_di EQ 'X' AND sy-ucomm EQ 'ONLI'.
    MESSAGE e899(fi) WITH 'No ingreso el PATH para'
                          'registro de archivo banco'.
  ELSEIF p_bukrs IS NOT INITIAL.
    p_archiv = 'C:\TRANSFER\' && p_bukrs && '_BCI_' && sy-datum && '_' && sy-uzeit && '.txt'.
  ENDIF.

AT SELECTION-SCREEN ON p_conven.
  CHECK sy-ucomm EQ 'ONLI'  AND p_proc EQ gc_x AND sy-batch IS INITIAL.
  IF p_conven IS INITIAL.
    MESSAGE e899(fi) WITH 'Indique Convenio de la Sociedad'.
  ELSE.
    wa_selec-convenio = |{ p_conven ALPHA = IN }|.
    SELECT SINGLE convenio INTO @DATA(lv_convenio)
           FROM zfitr016 WHERE bukrs    EQ @p_bukrs
                           AND convenio EQ @wa_selec-convenio.
    IF sy-subrc NE 0.
      MESSAGE e899(fi) WITH 'Convenio ingresado no corresponde a la Sociedad'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON p_fecpag.
  CHECK sy-ucomm EQ 'ONLI'  AND p_proc EQ gc_x AND par_ren IS INITIAL.
  IF p_fecpag IS INITIAL.
    MESSAGE e899(fi) WITH 'Ingrese fecha de Pago'.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fecha.
  PERFORM valida_ingreso USING 'P_NOMINA' '504'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_nomina.
  PERFORM valida_ingreso USING 'P_FECHA' '027'.

AT SELECTION-SCREEN ON BLOCK marco1.
*  IF sy-ucomm EQ 'OPC'.
*    PERFORM actualiza_tabla.
*  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'NOM'.
        IF par_nom IS INITIAL.
          screen-active = 0.
        ENDIF.
      WHEN 'VER'.
        CHECK par_di EQ 'X' OR  p_repo EQ gc_x OR par_ren EQ gc_x.
        screen-active = 0.
      WHEN 'WEB'.
        CHECK p_repo EQ gc_x.
        screen-active = 0.
      WHEN 'PRO'.
        CHECK par_ren EQ gc_x OR p_repo EQ gc_x.
        screen-active = 0.
      WHEN 'WBS'.
        CHECK p_proc EQ gc_x.
        screen-active = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
