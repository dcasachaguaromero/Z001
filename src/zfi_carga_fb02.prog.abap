*---------------------------------------------------------------------*
* Nombre Programa : ZFII_CARGA_MASIVA_AP
* Descripción     : Interfaz de cuentas de mayor.
*---------------------------------------------------------------------*
* Objetivo        :
*---------------------------------------------------------------------*
* Creado por          : VIsionOne (copia a programa de Tienda).
* Creado en fecha     : 20-Abril-1999
*---------------------------------------------------------------------*
REPORT  zfi_carga_fb02 LINE-SIZE 250.
* Tablas y estructuras de transferencia para docs. contables.
* -----------------------------------------------------------
TABLES: bgr00,                         " Registro de juego de datos
        bbkpf,                         " Datos de cabecera BTCI
        bbseg, " Datos de segmento de doc. (incl. datos CpD, datos COBL)
        d020s, " Tabla de sistema D020S (sources de dynpro)
        mara.  " Datos generales maestro materiales

* Definición de variables y tablas internas.
* ------------------------------------------
FIELD-SYMBOLS <f>.
DATA:
*FICHERO   LIKE RLGRAP-FILENAME,
  cont(3) TYPE n VALUE 0,
  cierre  VALUE 'F'.
DATA: BEGIN OF t_reg_entrada OCCURS 0,
* BKPF
        bukrs      LIKE bbkpf-bukrs,
        belnr1     LIKE bbkpf-belnr,
        blart      LIKE bbkpf-blart,
        waers      LIKE bbkpf-waers,
        kursf      LIKE bbkpf-kursf,
        bldat      LIKE bbkpf-bldat,  "FECHA
        budat      LIKE bbkpf-budat,  "FECHA
        bktxt      LIKE bbkpf-bktxt,
        xblnr      LIKE bbkpf-xblnr,
        xblnr2     LIKE bkpf-xref2_hd,
* BSEG
        augbl      LIKE bseg-augbl,  "documento de compensacion
        newbs      LIKE bbseg-newbs,
        newko      LIKE bbseg-hkont,
        wrbtr      LIKE bbseg-stceg,  "VALOR
        dmbtr      LIKE bbseg-stceg,  "VALOR
        zuonr      LIKE bbseg-zuonr,
        valut      LIKE bbseg-valut,  "FECHA
        sgtxt      LIKE bbseg-sgtxt,
        kostl      LIKE bbseg-kostl,
        prctr      LIKE bbseg-prctr,
        aufnr      LIKE bbseg-aufnr,
        projk      LIKE bbseg-projk,
        hkont      LIKE bbseg-hkont,
        newum      LIKE bbseg-newum,
        mwskz      LIKE bbseg-mwskz,
        gsber      LIKE bbseg-gsber,
        xref1      LIKE bbseg-xref1,
        xref2      LIKE bbseg-xref2,
        zterm      LIKE bbseg-zterm,
        zfbdt      LIKE bbseg-zfbdt, "FECHA
        segment    LIKE bbseg-segment,
        lifnr      LIKE bseg-lifnr,
        hbkid      LIKE bbseg-hbkid,
        zzprestac  LIKE bbseg-zzprestac,
        zzunid_pro LIKE bbseg-zzunid_pro,
        zzdesc_est LIKE bbseg-zzdesc_est,
        zzmot_emis LIKE bbseg-zzmot_emis,
        zzrut_terc LIKE bseg-zzrut_terc,
        zz_agencia LIKE bseg-zz_agencia,
      END   OF t_reg_entrada.

DATA  cabecera LIKE t_reg_entrada.
DATA  strarq       TYPE string.

DATA: lv_mode TYPE allgazmd VALUE 'A'.

DATA: jobcount    LIKE tbtcjob-jobcount,
      jobname(32) TYPE c,
      l_datum     LIKE sy-datum,
      l_uzeit     LIKE sy-uzeit,
      l_hora_prev LIKE sy-uzeit,
      strtimmed   LIKE btch0000-char1,
      tit_job(30) TYPE c.

*--------------------------------------------------------------------*
*                      SELECTION-SCREEN
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.

PARAMETERS: fichero  LIKE rlgrap-filename DEFAULT 'C:\temp\Asiento_GL.txt',
            pa_file4 LIKE rlgrap-filename DEFAULT '/tmp' .

PARAMETERS pgrupojd  LIKE bgr00-group. " Nombre Juego de Datos
PARAMETERS pgenr_jd  AS   CHECKBOX DEFAULT 'X'.  " Generar  J. de Datos
PARAMETERS pejec_jd  AS   CHECKBOX DEFAULT 'X'.  " Ejecutar J. de Datos
PARAMETERS callmode  TYPE c DEFAULT 'B'.
SELECTION-SCREEN END   OF BLOCK bl1.
*

*--------------------------------------------------------------------*
*                          INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.
  pgrupojd = 'PI_RESULT'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR fichero.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = fichero
      def_path         = 'c:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Directorio de Datos'
    IMPORTING
      filename         = fichero
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

**---------------------------------------------------------------------
**- Inicio Programa Principal -----------------------------------------
**---------------------------------------------------------------------
START-OF-SELECTION.
* -> Tratamiento Archivo de Entrada
  PERFORM input_local.

* -> Tratamiento Archivo de Salida
  PERFORM output_file.

*** -> Generación y Tratamiento del juego de datos
*----------------------------------------------------------------------*
* En este segmento se ejecutan los siguientes programas:
* - RFBIBL00, este se encarga de generar el juego de datos para el batch
*   input.
* - RSBDCSUB, este se encarga de procesar l juego de datos generado.
*----------------------------------------------------------------------*
  IF NOT pgenr_jd IS INITIAL.
*
    CASE callmode.
      WHEN 'D'.
        DATA: BEGIN OF i_tjobs OCCURS 50.
                INCLUDE STRUCTURE tbier_s.
                DATA:   loesch,
                jstat,        " Status von TBIST-Jobs aus TBTCO
                icon              LIKE icon-name,
                text_mit_icon(75),
              END OF i_tjobs.

        DATA : tb        LIKE i_tjobs,
               newjob    TYPE c   VALUE 'X',
               continue  TYPE c,
               immediate TYPE c   VALUE 'X',
               no_print  TYPE c   VALUE 'X',
               pri_param LIKE pri_params,
               arc_param LIKE arc_params.

        tb-jobtext = 'BANMEDICA'.
        tb-repname = 'RFBIBL00'.
        tb-variant = 'BANMEDICA'.
        tb-uname   = sy-uname.

        CALL FUNCTION 'BI_START_JOB'
          EXPORTING
            jobid                 = tb-jobid
            jobtext               = tb-jobtext
            repname               = tb-repname
            server                = tb-execserver
            variant               = tb-variant
            new_job               = newjob
            continue_job          = continue
            priparam              = pri_param
            arcparam              = arc_param
            start_immediate       = immediate
            do_not_print          = no_print
            username              = tb-uname
          IMPORTING
            jobcount              = tb-jobcount
            jobid                 = tb-jobid
          EXCEPTIONS
            job_open_failed       = 01
            job_close_failed      = 02
            job_submit_failed     = 03
            wrong_parameters      = 04
            job_does_not_exist    = 06
            wrong_starttime_given = 07
            job_not_released      = 08
            wrong_variant         = 09
            no_authority          = 10
            dialog_cancelled      = 11
            periodic_not_allowed  = 12
            OTHERS                = 99.

        SET PARAMETER ID: 'BM5' FIELD sy-datum.
        CALL TRANSACTION 'BMV0'  AND SKIP FIRST SCREEN.
      WHEN OTHERS.
*        SUBMIT rfbibl00 WITH callmode  EQ callmode  "ansf.de datos
*                        WITH ds_name   EQ pa_file4   "Nom.vía acc.fichero
*                        WITH fl_check  EQ ' '"Sólo verificar fichero
*                        WITH os_xon    EQ ' '"Estructuras de release < 4.0
*                        WITH pa_xprot  EQ 'X'"Log ampliado
*                        AND RETURN.
** V1 RVY
        REPLACE ALL OCCURRENCES OF '/tmp/' IN pa_file4 WITH ''.
        SUBMIT zrfbibl00 WITH ds_name  = pa_file4 " se modifica programa Standar a Z
                         WITH callmode = 'B'
                         WITH anz_mode = lv_mode     " se agrega variable para modo de ejec. Batch Input
                         WITH xinf = 'X'
                         AND RETURN.
    ENDCASE.
  ENDIF.

  IF NOT pejec_jd IS INITIAL AND callmode NE 'D'.
    SUBMIT rsbdcsub WITH mappe    EQ pgrupojd  "Juego datos
                    WITH fehler   EQ ' '       "Erróneo
                    WITH logall   EQ 'X'       "Log ampliado
                    WITH z_verarb EQ 'X'       "A procesar
    AND RETURN.
  ENDIF.
*** -> Subrutinas (FORM)
***-----------------------------------------------------------------***
***-- Inicio Subrutinas --------------------------------------------***
***-----------------------------------------------------------------***

*---------------------------------------------------------------------*
*       FORM INIT_NODATA                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  TABLA                                                         *
*---------------------------------------------------------------------*
FORM init_nodata USING tabla.
  DATA: c_acumu TYPE i.
  DO.
    ADD 1 TO c_acumu.
    ASSIGN COMPONENT c_acumu OF STRUCTURE tabla TO <f>.
    IF sy-subrc NE 0. EXIT. ENDIF.
    MOVE '/' TO <f>.
  ENDDO.
ENDFORM.                    "INIT_NODATA

*---------------------------------------------------------------------*
*       FORM CHECK_FIELD                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM check_field.

  DATA: c_acumu TYPE i.
  DATA : xlifnr       LIKE bbseg-newko,
         xkunnr       LIKE bbseg-newko,
         xbbseg-newko LIKE bbseg-newko.

  DO.
    ADD 1 TO c_acumu.
    ASSIGN COMPONENT c_acumu OF STRUCTURE t_reg_entrada TO <f>.
    IF sy-subrc NE 0. EXIT. ENDIF.
*    CONDENSE <f> NO-GAPS.
    IF <f> IS INITIAL.
      MOVE '/' TO <f>.
    ENDIF.
  ENDDO.

* Formatear fechas para batch-input
  CONCATENATE t_reg_entrada-bldat+6(2)    "Dia
              t_reg_entrada-bldat+4(2)    "Mes
              t_reg_entrada-bldat(4)      "Año
  INTO t_reg_entrada-bldat.

  CONCATENATE t_reg_entrada-budat+6(2)    "Dia
              t_reg_entrada-budat+4(2)    "Mes
              t_reg_entrada-budat(4)      "Año
  INTO t_reg_entrada-budat.

  CONCATENATE t_reg_entrada-valut+6(2)    "Dia
              t_reg_entrada-valut+4(2)    "Mes
              t_reg_entrada-valut(4)      "Año
  INTO t_reg_entrada-valut.

  CONCATENATE t_reg_entrada-zfbdt+6(2)    "Dia
              t_reg_entrada-zfbdt+4(2)    "Mes
              t_reg_entrada-zfbdt(4)      "Año
  INTO t_reg_entrada-zfbdt.
*
*  Si Clave Contab. esta entre 21 y 39, Chequea si RUT Proveedor Existe
*
  IF t_reg_entrada-newbs >= '21' AND t_reg_entrada-newbs <= '39'.
    IF t_reg_entrada-newko > '0000010000' AND
       t_reg_entrada-newko < '0000999999'  OR
       t_reg_entrada-newko > 'REM000'  AND
       t_reg_entrada-newko < 'REM999'.
      MOVE t_reg_entrada-newko TO xbbseg-newko.
    ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE lifnr INTO xlifnr FROM lfa1
*                                WHERE stcd1 EQ t_reg_entrada-newko.
*
* NEW CODE
      SELECT lifnr
      UP TO 1 ROWS  INTO xlifnr FROM lfa1
                                WHERE stcd1 EQ t_reg_entrada-newko ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc <> 0.
        WRITE: / 'RUT del Proveedor no Existe : ', t_reg_entrada-newko.
        EXIT.
      ELSE.
        MOVE  xlifnr    TO t_reg_entrada-newko.    "Cuenta
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE lifnr INTO xlifnr FROM lfb1
*                             WHERE lifnr EQ xlifnr AND
*                                   bukrs EQ t_reg_entrada-bukrs.
*
* NEW CODE
        SELECT lifnr
        UP TO 1 ROWS  INTO xlifnr FROM lfb1
                             WHERE lifnr EQ xlifnr AND
                                   bukrs EQ t_reg_entrada-bukrs ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc <> 0.
          WRITE: / 'RUT del Proveedor no Existe en Sociedad : ',
                                 t_reg_entrada-newko.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*
*  Si Clave Contab. esta entre 1 y 19, Chequea si RUT Cliente Existe
*
  IF t_reg_entrada-newbs >= '01' AND t_reg_entrada-newbs <= '19'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE kunnr INTO xkunnr FROM kna1
*                              WHERE stcd1 EQ t_reg_entrada-newko.
*
* NEW CODE
    SELECT kunnr
    UP TO 1 ROWS  INTO xkunnr FROM kna1
                              WHERE stcd1 EQ t_reg_entrada-newko ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc <> 0.
      WRITE: / 'RUT del Cliente no Existe : ', t_reg_entrada-newko.
      EXIT.
    ELSE.
      MOVE xkunnr  TO t_reg_entrada-newko.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE kunnr INTO xkunnr FROM knb1
*                             WHERE kunnr EQ xkunnr AND
*                                   bukrs EQ t_reg_entrada-bukrs.
*
* NEW CODE
      SELECT kunnr
      UP TO 1 ROWS  INTO xkunnr FROM knb1
                             WHERE kunnr EQ xkunnr AND
                                   bukrs EQ t_reg_entrada-bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc <> 0.
        WRITE: / 'RUT del Cliente No Existe en Sociedad: ', t_reg_entrada-newko.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "CHECK_FIELD

*---------------------------------------------------------------------*
*       FORM INPUT_FILE                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM input_file.
*  Abrir para lectura el archivo de salida
  OPEN DATASET fichero FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc NE 0.
    FORMAT COLOR 4 INTENSIFIED ON.
    WRITE / 'No se pudo abrir el archivo especificado para entrada'.
    FORMAT RESET.
    EXIT.
  ENDIF.

  DO.
    READ DATASET fichero INTO t_reg_entrada.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
    APPEND t_reg_entrada.
  ENDDO.
  CLOSE DATASET fichero.
ENDFORM.                    "INPUT_FILE

*---------------------------------------------------------------------*
*       FORM OUTPUT_FILE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM output_file.
* Definicion de variables locales.
* --------------------------------

*"Imprime nombre de archivo de salida
  FORMAT COLOR 1 INTENSIFIED OFF.
  WRITE /1(250)  'Archivo de salida:'.
  WRITE /1(250)  pa_file4.
  WRITE /1(250)  sy-uline.
  FORMAT RESET.

*"Abrir para escritura el archivo de salida
  OPEN DATASET pa_file4 FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

  IF sy-subrc NE 0.
    FORMAT COLOR 4 INTENSIFIED ON.
    WRITE / 'No se pudo abrir el archivo especificado para salida'.
    FORMAT RESET.
    EXIT.
  ENDIF.

* -> Llenar estructuras de transferencia para archivo de salida
  "Llenar estructuras batch input para juego de datos
  PERFORM init_nodata USING bgr00.
  MOVE: '0'      TO bgr00-stype,
        pgrupojd TO bgr00-group,
        sy-mandt TO bgr00-mandt,
        '00000000' TO bgr00-start,
        sy-uname TO bgr00-usnam.
  TRANSFER bgr00 TO pa_file4.
  SORT t_reg_entrada BY bukrs belnr1.

  DATA: suma(16) VALUE 0.

  cont = 0.

  LOOP AT t_reg_entrada.               " Recorrer tabla interna
    PERFORM check_field.               " Verificaciones de cada campo
    MOVE t_reg_entrada TO cabecera.

    cont = cont + 1.
*"  En cada nuevo camión llena la estructura de cabecera
    IF cont = 1.
      PERFORM cabecera USING cont.
    ENDIF.
* cuando alcanza la cantidad maxima de posiciones cierra el documento
    IF cont = 900.
      PERFORM posicion.
      PERFORM cierra_doc USING suma.
    ENDIF.
* cuando cambia la fecha, se cierra el documento
    AT END OF belnr1.
      IF cont <> 900.
        PERFORM posicion.
        PERFORM cierra_doc USING suma.
      ENDIF.
    ENDAT.

*"  Llenar estructura para cada posición del documento
    IF cont <> 0 AND cierre = 'F'.
      PERFORM posicion.
    ENDIF.
*   cierra doc en el último registro
    AT LAST.
      IF cierre = 'F'.
        PERFORM cierra_doc USING suma.
      ENDIF.
    ENDAT.
  ENDLOOP.

*"Imprime juego de datos
  FORMAT COLOR 1 INTENSIFIED ON.
  WRITE: /01(20)  'Juego de Datos:',
          25      bgr00-group,
          250     '.'.
  FORMAT RESET.

  CLOSE DATASET pa_file4 .               "*Cerrar archivo de salida
ENDFORM.                    "OUTPUT_FILE


*&---------------------------------------------------------------------*
*&      Form  CABECERA
*&---------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cabecera USING cont.
  PERFORM init_nodata USING bbkpf.
  MOVE-CORRESPONDING cabecera TO bbkpf.
  MOVE: '1'    TO bbkpf-stype,
        'FB01' TO bbkpf-tcode.

  TRANSFER bbkpf TO pa_file4.
  cont = 1. cierre = 'F'.
ENDFORM.                               " CABECERA

*&---------------------------------------------------------------------*
*&      Form  POSICION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM posicion.
  DATA: w_wrbtr LIKE glt0-tslvt."bseg-wrbtr.
  CLEAR: w_wrbtr.

  PERFORM init_nodata USING bbseg.
  MOVE: '2'     TO bbseg-stype,
        'BBSEG' TO bbseg-tbnam.

  MOVE-CORRESPONDING cabecera TO bbseg.

  TRANSFER bbseg TO pa_file4.


ENDFORM.                               " POSICION

*&---------------------------------------------------------------------*
*&      Form  CIERRA_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cierra_doc USING suma.
  DATA: w_wrbtr LIKE glt0-tslvt."bseg-wrbtr.
  CLEAR: w_wrbtr.

*  PERFORM init_nodata USING bbseg.
*  MOVE: '2'        TO bbseg-stype,
*        'BBSEG'    TO bbseg-tbnam,
**        '1111010001'  TO bbseg-newko,
*          p_saknr  TO bbseg-newko,
*        '100' TO BBSEG-SEGMENT.
*  IF suma < 0.
*    suma = -1 * suma.
*    MOVE: '40'    TO bbseg-newbs, suma    TO bbseg-wrbtr.
*  ELSE.
*    MOVE: '50'    TO bbseg-newbs, suma    TO bbseg-wrbtr.
*  ENDIF.
*  suma = 0.

*  if cabecera-waers ne 'CLP'.
*    w_wrbtr = bbseg-wrbtr.
*    write w_wrbtr to bbseg-wrbtr currency cabecera-waers.
*  endif.

*  TRANSFER bbseg TO pa_file4.
  cierre = 'T'.
  CLEAR cont.

ENDFORM.                               " CIERRA_DOC
*&---------------------------------------------------------------------*
*&      Form  input_local
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM input_local .

  strarq = fichero.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = strarq
      filetype                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = t_reg_entrada
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " input_local
*&---------------------------------------------------------------------*
*&      Form  OPEN_JOB
*&---------------------------------------------------------------------*
FORM open_job  USING    VALUE(texto)
               CHANGING l_jobcount
                        l_jobname
                        l_datum
                        l_uzeit.
*
  CLEAR l_jobcount.
*
  CONCATENATE texto '-'  sy-uname INTO l_jobname.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname  = l_jobname
*     sdlstrtdt = l_datum
*     sdlstrttm = l_uzeit
      jobclass = 'A'
    IMPORTING
      jobcount = l_jobcount.
ENDFORM.                    " OPEN_JOB
