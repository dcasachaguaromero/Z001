*&---------------------------------------------------------------------*
*& Report  ZFITR040
*&---------------------------------------------------------------------*
*&  Baja retorno de archivo de Novedades de Sociedad y Banco
*&  ingresados por parámetros
*&  Invoca funcion de formateo de datos propia de la sociedad y banco
*&---------------------------------------------------------------------*
REPORT  zfitr040.
TABLES: znovedadbanco, zbancossbif, t001.

DATA: soc(4),
      nom(15)           TYPE n,
      fec               TYPE sy-datum,
      sw(1)             TYPE n,
      men(30)           TYPE c,nombrefuncion(12).

* ini Waldo Alarcón - Visionone - 05-10-2020
DATA: lw_log_handle TYPE balloghndl,
      lv_error      TYPE c,
      lv_nomina     TYPE numc15,
      lv_fecha      TYPE xflag.
* fin Waldo Alarcón - Visionone - 05-10-2020

SELECTION-SCREEN BEGIN OF BLOCK b1.
PARAMETER : bukrs    LIKE bkpf-bukrs             VALUE CHECK OBLIGATORY .
PARAMETER : ubnkl    LIKE znovedadbanco-banco    VALUE CHECK OBLIGATORY .
PARAMETER : nomina   LIKE znovedadbanco-nomina.
* ini Waldo Alarcón - Visionone - 05-10-2020
PARAMETERS  p_fecha  TYPE sydatum  MODIF ID ver.
* fin Waldo Alarcón - Visionone - 05-10-2020
SELECTION-SCREEN END OF BLOCK b1.
*
* ini Waldo Alarcón - Visionone - 05-10-2020
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK b2.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 2(50) TEXT-mo1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(30) TEXT-mo2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 10(30) TEXT-mo3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

AT SELECTION-SCREEN ON ubnkl.
  SELECT SINGLE usa_fecha INTO lv_fecha
         FROM zbancossbif WHERE banco EQ ubnkl.

AT SELECTION-SCREEN ON p_fecha.
  IF lv_fecha IS NOT INITIAL AND p_fecha IS INITIAL AND
     lv_error EQ 'X'.
    MESSAGE e899(fi) WITH 'Ingrese fecha'.
  ENDIF.

AT SELECTION-SCREEN ON BLOCK b1 .
  IF lv_fecha IS NOT INITIAL AND p_fecha IS INITIAL.
    lv_error = 'X'.
  ELSE.
    CLEAR lv_error.
  ENDIF.
  lv_nomina = nomina.

AT SELECTION-SCREEN OUTPUT.
  IF ubnkl IS NOT INITIAL.
    SELECT SINGLE usa_fecha INTO lv_fecha
           FROM zbancossbif WHERE banco EQ ubnkl.
  ENDIF.

  LOOP AT SCREEN.
    CHECK screen-group1 EQ 'VER'.
    IF lv_fecha IS NOT INITIAL.
      screen-active = 1.
    ELSE.
      screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

START-OF-SELECTION.
  IF lv_error IS NOT INITIAL.
    MESSAGE i899(fi) WITH 'Debe Ingrese fecha para '
                          'Banco Seleccionado'.
  ELSE.
* fin Waldo Alarcón - Visionone - 05-10-2020
    SELECT SINGLE * FROM zbancossbif
    WHERE banco   = ubnkl.

    IF sy-subrc <> 0.
      WRITE: / '--------------------------------------------------------------'.
      WRITE: / 'El banco ingresado',  ubnkl+0(3), 'no esta ingresado en tabla'.
      WRITE: / 'de definciòn de Bancos ZBANCOSSBIF , de SuperIntendencia                           '.
      WRITE: / 'SE CANCELA PROCESO'.
      WRITE: / '--------------------------------------------------------------'.
      EXIT.
    ENDIF.

    IF  ubnkl+0(3) <> '012' AND  ubnkl+0(3) <> '027' AND ubnkl+0(3) <> '037'.
      WRITE: / '--------------------------------------------------------------'.
      WRITE: / 'El banco ingresado',  ubnkl+0(3), 'no tiene habilitado proceso'.
      WRITE: / ' automatico de recepcion de novedades. Consulte Sistemas      '.
      WRITE: / 'SE CANCELA PROCESO'.
      WRITE: / '--------------------------------------------------------------'.
      EXIT.
    ENDIF.

    IF  ubnkl+0(3) <> '027'.
      CONCATENATE '0' sy-datum+0(8) sy-uzeit INTO nomina.
    ELSE.
      IF nomina = 0.
        WRITE: / '--------------------------------------------------------------'.
        WRITE: / 'Debe ingresar numero de nomina para CORPBANCA'.
        WRITE: / '          o fecha de la nomiba para SANTANDER'.
        WRITE: / 'SE CANCELA PROCESO'.
        WRITE: / '--------------------------------------------------------------'.
        EXIT.
      ENDIF.
    ENDIF.

*SELECT SINGLE * FROM znovedadbanco
*                WHERE sociedad = bukrs
*                  AND banco   = ubnkl
*                  AND nomina  = nomina.
*IF sy-subrc = 0.
*  WRITE: / '--------------------------------------------------------------'.
*  WRITE: / 'Ya existen registros para novedades de nómina ingresada'.
*  WRITE: / 'Sociedad: ', bukrs, ' Banco: ', ubnkl+0(3), ' Nomina: ', nomina.
*  WRITE: / 'SE CANCELA PROCESO'.
*  WRITE: / '--------------------------------------------------------------'.
*  EXIT.
* ELSE.

* ini Waldo Alarcón - Visionone - 05-10-2020
    PERFORM crear_log_slg1  CHANGING lw_log_handle.
    PERFORM agregar_mensaje USING    lw_log_handle.
    PERFORM grabar_log      USING    lw_log_handle.
* fin Waldo Alarcón - Visionone - 05-10-2020

    CONCATENATE 'ZFITR040' ubnkl+0(3)  'A' INTO nombrefuncion.
    CALL FUNCTION nombrefuncion
      EXPORTING
        soc     = bukrs
        banco   = ubnkl
        nom     = nomina
* ini Waldo Alarcón - Visionone - 05-10-2020
        p_fecha = p_fecha
* fin Waldo Alarcón - Visionone - 05-10-2020
      IMPORTING
        men     = men.
    IF men <> ' '.
      WRITE: / '--------------------------------------------------------------'.
      WRITE: / 'Parametro Sociedad: ', bukrs.
      WRITE: / 'Parametro Banco   : ', ubnkl.
      WRITE: / 'Parametro Nomina  : ', nomina.
      WRITE: / '--------------------------------------------------------------'.
      WRITE: / 'Existen diferencias entre parámetros y datos de archivo '.
      WRITE: / 'Error:  ', men.
      WRITE: / 'SE CANCELA PROCESO'.
      WRITE: / '--------------------------------------------------------------'.
      EXIT.
    ENDIF.



  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  CREAR_LOG_SLG1
*&---------------------------------------------------------------------*
FORM crear_log_slg1 CHANGING p_log_handle  TYPE balloghndl.
  DATA: ls_header  TYPE bal_s_log.
  CONSTANTS : c_object    TYPE balobj_d  VALUE 'ZFI_040',
              c_subobject TYPE balsubobj VALUE 'Z01'.
*
  ls_header-object     = c_object.
  ls_header-subobject  = c_subobject.
  ls_header-aldate     = sy-datum.
  ls_header-altime     = sy-uzeit.
  ls_header-aluser     = sy-uname.
  ls_header-altcode    = sy-tcode.
  ls_header-alprog     = sy-repid.
*
  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = ls_header
    IMPORTING
      e_log_handle            = p_log_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AGREGAR_MENSAJE
*&---------------------------------------------------------------------*
FORM agregar_mensaje  USING p_log_handle TYPE balloghndl.
  DATA: ls_msg           TYPE bal_s_msg,
        lv_fecha         TYPE char10,
        l_msg_was_logged TYPE boolean.
*

  CLEAR ls_msg.
  ls_msg-msgty = 'I'.    "Tipo de Mensaje
  ls_msg-msgno = '899'.  "Numero de Mensaje
  ls_msg-msgid = 'FI'.   "Clase de Mensaje
  ls_msg-msgv1 = 'Sociedad:' && | | && bukrs && ', Banco : ' && ubnkl.
  ls_msg-msgv2 = ',Nomina ingresada:' && | | && lv_nomina.
  ls_msg-msgv3 = ',Nomina Proceso  :' && | | && nomina.
  IF p_fecha IS NOT INITIAL.
    WRITE p_fecha TO lv_fecha.
    ls_msg-msgv4 = 'Fecha Seleccionada' && | | && lv_fecha.
  ENDIF.
  ls_msg-probclass = '4'.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle     = p_log_handle
      i_s_msg          = ls_msg
    IMPORTING
      e_msg_was_logged = l_msg_was_logged
    EXCEPTIONS
      log_not_found    = 1
      msg_inconsistent = 2
      log_is_full      = 3
      OTHERS           = 4.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GRABAR_LOG
*&---------------------------------------------------------------------*
FORM grabar_log  USING  p_log_handle TYPE balloghndl.
  DATA: lt_log_handles  TYPE bal_t_logh.
*
  INSERT p_log_handle INTO TABLE lt_log_handles.

  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_save_all       = 'X'
      i_in_update_task = 'X'
      i_t_log_handle   = lt_log_handles
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.

  COMMIT WORK.

ENDFORM.
