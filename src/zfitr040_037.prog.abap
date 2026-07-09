*&---------------------------------------------------------------------*
*& Report  ZFITR040_037
*&---------------------------------------------------------------------*
*&  Baja retorno de archivo de Novedades de Banco Santander segun se
*&  indique en  parámetros ingresados
*&  Invoca funcion de formateo de datos propia de Santander
*&---------------------------------------------------------------------*
REPORT  zfitr040_037.

TABLES: t001, zfitr040_est, ztparamftp, zfitr040_log.

DATA: soc(4),
      nom(15)           TYPE n,
      fec               TYPE sy-datum,
      sw(1)             TYPE n,
      men(30)           TYPE c,nombrefuncion(12),
      nomina            LIKE znovedadbanco-nomina,
      fill(4)           TYPE n,
      buscar(100),
      bukrs             TYPE    t001-bukrs.

TYPES: BEGIN OF type_texto,
         todo(581) TYPE c,
       END OF type_texto.

DATA: cta(15)    TYPE  n,
      suma(15)   TYPE n,
      sumar(15)  TYPE n,
      nuevos(6)  TYPE n,
      idpagoe(6) TYPE n,
      errtra(6)  TYPE n,
      errvvi(6)  TYPE n,
      estadoe(6) TYPE n,
      estado8(6) TYPE n,
      rechazo(6) TYPE n,
      li_data    TYPE TABLE OF  type_texto WITH HEADER LINE.
* Tablas Dynpro
CONTROLS: tabla   TYPE TABLEVIEW USING SCREEN 100.


DATA : BEGIN OF int_tabla  OCCURS 1.
         INCLUDE STRUCTURE zfitr040_est.
       DATA  END OF int_tabla.
* ini Waldo Alarcón - Visionone - 15-07-2022
DATA  p_fecha  TYPE sydatum.
* fin Waldo Alarcón - Visionone - 15-07-2022

*DATA : BEGIN OF int_tabla_aux  OCCURS 1.
*        INCLUDE STRUCTURE zfitr040_est.
*DATA  END OF int_tabla_aux.

*PARAMETER : bukrs    LIKE bkpf-bukrs             VALUE CHECK OBLIGATORY .
*
*AT SELECTION-SCREEN ON bukrs.
*
*  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*     ID 'BUKRS' FIELD bukrs.
*
*  IF sy-subrc <> 0.
*    MESSAGE e526(icc_tr) WITH bukrs.
*  ENDIF.
*
*  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.




START-OF-SELECTION.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM ztparamftp WHERE zbukr = 'CL01'
*                            AND      zprog = sy-repid.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM ztparamftp WHERE zbukr = 'CL01'
                            AND      zprog = sy-repid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0.
    MESSAGE e016(z1) WITH  'Programa no tienen ' ' registrado rutas de archvos'.
  ENDIF.

  DATA lista_arc TYPE TABLE OF sdokpath WITH HEADER LINE.
  DATA lista_dir TYPE TABLE OF sdokpath WITH HEADER LINE.
  DATA nomfileinf(128).
  DATA: file_size TYPE  i.

  CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
    EXPORTING
      directory  = ztparamftp-zruta
      filter     = '*.txt'
    TABLES
      file_table = lista_arc
      dir_table  = lista_dir.

  IF lista_arc[] IS INITIAL.
    WRITE:/ 'No existen archivos a procesar '.

  ELSE.
    REFRESH int_tabla.

    LOOP AT lista_arc.
      CONCATENATE ztparamftp-zruta lista_arc-pathname INTO nomfileinf.
      CALL FUNCTION 'GUI_GET_FILE_INFO'
        EXPORTING
          fname     = nomfileinf
        IMPORTING
          file_size = file_size.

      int_tabla-archivo = lista_arc-pathname.
      int_tabla-corre =  lista_arc-pathname+16(20).
      int_tabla-fecha =  lista_arc-pathname+36(8).
      int_tabla-tamano = file_size.

      IF int_tabla-archivo+3(2) <> 'RE'.
        APPEND int_tabla.
      ENDIF.
    ENDLOOP.

    DESCRIBE TABLE int_tabla LINES fill.
    tabla-lines = fill.
    tabla-top_line = 1.
    SORT int_tabla BY fecha corre ASCENDING.

    PERFORM marco_todo_tabla.

    CLEAR p_fecha.
    CALL SCREEN 100.

  ENDIF.

  INCLUDE zfitr040_037_0100.

*&---------------------------------------------------------------------*
*&      Form  cargo_archivo_novedades
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cargo_archivo_novedades.
  DATA : selec(01).
  DATA nomfile TYPE string.
  DATA numa(5) TYPE n.
* ini - Waldo Alarcón - Visionone - 16-05-2021
  DATA lv_fecha TYPE sydatum.
* fin - Waldo Alarcón - Visionone - 16-05-2021

* ini - Waldo Alarcón - Visionone - 15-07-2022
  lv_fecha = p_fecha.
* fin - Waldo Alarcón - Visionone - 15-07-2022

  selec = 'N'.
  CLEAR numa.
  LOOP AT int_tabla.

    IF int_tabla-sel = 'X'.
      numa = numa + 1.
    ENDIF.
  ENDLOOP.
  IF numa IS NOT INITIAL.

    WRITE: / 'Archivo seleccionados a procesar  :  ',   numa.
  ENDIF.
  sy-tabix = 0.
  LOOP AT int_tabla.

    IF int_tabla-sel = 'X'.
      IF selec = 'N'.
        LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 100.
      ENDIF.
      selec = 'S'.
      CONCATENATE ztparamftp-zruta int_tabla-archivo  INTO nomfile.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          filename = nomfile
          filetype = 'DAT'
        TABLES
          data_tab = li_data.

      READ TABLE li_data INDEX 3.

      bukrs = li_data+143(4).
      CONCATENATE '0' sy-datum+0(8) sy-uzeit INTO nomina.
      CONCATENATE 'ZFITR040' '037B'  INTO nombrefuncion.

      CALL FUNCTION nombrefuncion
        EXPORTING
          soc     = bukrs
          banco   = '037'
          nom     = nomina
* ini - Waldo Alarcón - Visionone - 16-05-2021
          p_fecha = lv_fecha
* fin - Waldo Alarcón - Visionone - 16-05-2021
        IMPORTING
          men     = men
          cta     = cta
          nuevos  = nuevos
          estado8 = estado8
          idpagoe = idpagoe
          rechazo = rechazo
          errtra  = errtra
          errvvi  = errvvi
          suma    = suma
          sumar   = sumar
        TABLES
          t_exc   = li_data.
      WRITE: / 'Archivo :  ',  int_tabla-archivo.
      IF men <> ' '.
        WRITE: / '--------------------------------------------------------------'.
        WRITE: / 'Parametro Sociedad: ', bukrs.
        WRITE: / 'Parametro Banco   : ', '037'.
        WRITE: / 'Parametro Nomina  : ', nomina.
        WRITE: / '--------------------------------------------------------------'.
        WRITE: / 'Existen diferencias entre datos de banco y sociedad y datos de archivo '.
        WRITE: / 'Error:  ', men.
        WRITE: / 'Archivo no Procesado' .
        WRITE: / '--------------------------------------------------------------'.
        CLEAR zfitr040_log.
        MOVE bukrs   TO zfitr040_log-zbukr.
        MOVE 'ZFITR040_037' TO zfitr040_log-programa.
        MOVE sy-datum   TO  zfitr040_log-fecha.
        MOVE sy-uzeit   TO zfitr040_log-hora.
        MOVE nomfile TO zfitr040_log-arch.
        MOVE nomina TO zfitr040_log-nomina.
        CONCATENATE    'Archivo no Procesado' men INTO  zfitr040_log-men SEPARATED BY space.
        INSERT zfitr040_log.
      ELSE.
        WRITE:/ 'Registros procesados       ',  cta      DECIMALS 0.
        WRITE:/ 'Registros nuevos           ',  nuevos   DECIMALS 0.
        WRITE:/ 'Registros ID pago erroneo  ',  idpagoe  DECIMALS 0.
        WRITE:/ 'Registros rechazados       ',  rechazo  DECIMALS 0.
        WRITE:/ 'Estado erroneo  Transfers  ',  errtra   DECIMALS 0.
        WRITE:/ 'Estado erroneo  Vale Vista ',  errvvi   DECIMALS 0.
        WRITE:/ 'Suma de Montos grabados    ',  suma     DECIMALS 0.
        WRITE:/ 'Suma de Montos Rechazados  ',  sumar    DECIMALS 0.
        IF sumar IS INITIAL.
          WRITE:/   'Archivo  Procesado sin errores'.
        ELSE.
          WRITE:/     'Archivo  Procesado con errores'.
        ENDIF.
        MOVE bukrs   TO zfitr040_log-zbukr.

        MOVE 'ZFITR040_037' TO zfitr040_log-programa.
        MOVE sy-datum   TO  zfitr040_log-fecha.
        MOVE sy-uzeit   TO zfitr040_log-hora.
        MOVE nomfile TO zfitr040_log-arch.
        MOVE nomina TO zfitr040_log-nomina.
        MOVE    cta TO zfitr040_log-proces.

        MOVE    nuevos  TO zfitr040_log-nuevos.
        MOVE    estado8 TO zfitr040_log-nulos.
        MOVE    idpagoe TO zfitr040_log-iderr.
        MOVE    rechazo TO zfitr040_log-rechaz.
        MOVE    errtra TO zfitr040_log-trerr.
        MOVE    errvvi TO zfitr040_log-vverr.
        MOVE    suma TO zfitr040_log-mongr.
        MOVE    sumar TO zfitr040_log-monrec.
        IF sumar IS INITIAL.
          MOVE   'Archivo  Procesado sin errores' TO  zfitr040_log-men.
        ELSE.
          MOVE    'Archivo  Procesado con errores' TO  zfitr040_log-men.
        ENDIF.
        INSERT zfitr040_log.
        PERFORM renombrar_arc_procesados TABLES li_data USING int_tabla-archivo.

      ENDIF.
    ENDIF.
  ENDLOOP.

  IF selec = 'N'.
    MESSAGE w016(z1) WITH  'Debe Seleccionar ' ' a lo menos un archivo'.
  ELSE.
    LOOP AT int_tabla.

      IF int_tabla-sel = 'X'.
        DELETE int_tabla INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "cargo_archivo_novedades
**
**&---------------------------------------------------------------------*
**&      Form  renombrar_arce_procesados
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->P_GT_DTE_NOMBRE  text
**      -->P_LI_DATA        text
**----------------------------------------------------------------------*
FORM renombrar_arc_procesados  TABLES p_li_data USING    p_gt_dte_nombre.


  DATA nomfile TYPE string.
  DATA nomfiledel(128).

  CONCATENATE ztparamftp-zruta_respaldo p_gt_dte_nombre INTO nomfile.

**Dejo el archivo en el direcrtorio

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename = nomfile
      filetype = 'DAT'
    TABLES
      data_tab = p_li_data.

  IF sy-subrc <> 0.

  ENDIF.

* elimino archivo

  CONCATENATE ztparamftp-zruta p_gt_dte_nombre INTO nomfiledel.

  CALL FUNCTION 'TMP_GUI_DELETE_FILE'
    EXPORTING
      file_name = nomfiledel.

  .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



ENDFORM.                    " MOVER_DTE_PROCESADOS
