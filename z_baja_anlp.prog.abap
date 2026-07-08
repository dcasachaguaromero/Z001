*&---------------------------------------------------------------------*
*& Report  Z_BAJA_ANLP
*&
*&---------------------------------------------------------------------*
*&Respalda Tabla ANLP Original
*&
*&---------------------------------------------------------------------*

REPORT  Z_BAJA_ANLP.

tables ANLP.

DATA : BEGIN OF SALIDA OCCURS 20,
         LINEA(7000),
       END OF SALIDA.


SELECTION-SCREEN skip 1.
SELECTION-SCREEN BEGIN OF BLOCK rad1 WITH FRAME.
select-options : s_bukrs  for ANLP-bukrs obligatory,
                 s_GJAHR  for ANLP-GJAHR obligatory ,
                 s_PERAF  for anlp-PERAF,
                 s_AFBNR  for anlp-AFBNR,
                 s_ANLN1  for anlp-ANLN1,
                 s_ANLN2  for anlp-ANLN2,
                 s_AFABER for anlp-AFABER obligatory.
SELECTION-SCREEN END OF BLOCK rad1.
SELECTION-SCREEN skip 1.
SELECTION-SCREEN BEGIN OF BLOCK rad2 WITH FRAME.
PARAMETERS: direct(128) LOWER CASE obligatory default
           '/usr/sap/DE9/DVEBMGS09/work/'.
PARAMETERS: ARCHIVO(128) LOWER CASE obligatory default
           'ANLP.TXT'.

*PARAMETERS :fil_nam3 like rlgrap-filename obligatory
*            default 'C:/Ventisqueros/'.

SELECTION-SCREEN END OF BLOCK rad2.

*at selection-screen on value-request for fil_nam3.
*  perform value_req_file(Z_BAJADA_DOCUMENTOS) using fil_nam3.

at selection-screen on VALUE-REQUEST for archivo.
  PERFORM lee_directorio USING DIRECT CHANGING ARCHIVO.

start-of-selection.

  perform graba_anlp.


*&---------------------------------------------------------------------*
*&      Form  GRABA_ANLP
*&---------------------------------------------------------------------*
FORM GRABA_ANLP .
  data : t_anlp         like anlp occurs 0 with header line,
         e_anlp         type anlp,
         filename       type string,
         txt_line       type string,
         valor(40)      type c.

  FIELD-SYMBOLS: <wa>   TYPE ANY,
                 <comp> TYPE ANY.

  ASSIGN e_anlp TO <wa>.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into table t_anlp
*       from anlp where bukrs  in s_bukrs  and
*                       GJAHR  in s_GJAHR  and
*                       PERAF  in s_PERAF  and
*                       AFBNR  in s_AFBNR  and
*                       ANLN1  in s_ANLN1  and
*                       ANLN2  in s_ANLN2  and
*                       AFABER in s_AFABER.
*
* NEW CODE
  SELECT *
 into table t_anlp
       from anlp where bukrs  in s_bukrs  and
                       GJAHR  in s_GJAHR  and
                       PERAF  in s_PERAF  and
                       AFBNR  in s_AFBNR  and
                       ANLN1  in s_ANLN1  and
                       ANLN2  in s_ANLN2  and
                       AFABER in s_AFABER ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*
  concatenate direct archivo into filename.
  CLOSE DATASET filename.

  OPEN DATASET filename FOR OUTPUT IN text MODE encoding default.
  IF sy-subrc EQ 0.

  loop at t_anlp into e_anlp.
    CLEAR txt_line.
    WHILE sy-subrc = 0.
      ASSIGN COMPONENT sy-index OF STRUCTURE <wa> TO <comp>.
      check sy-subrc eq 0.
      move <comp>     to valor.
      translate valor using '.,'.
      condense valor no-gaps.
      concatenate txt_line valor ';' into txt_line.
    ENDWHILE.

*    clear salida.
*    MOVE txt_line TO SALIDA-linea.
*    APPEND SALIDA.

      TRANSFER txt_line TO filename.
  endloop.

*  PERFORM DOWNLOAD(Z_BAJADA_DOCUMENTOS) USING 'SALIDA' fil_nam3 ' '.

   CLOSE DATASET filename.
**
  MESSAGE s897(sd) WITH 'Datos tabla ANLP grabados en:'
                         filename.
  else.
    MESSAGE s897(sd) WITH 'ERROR al abrir archivo de salida'
                           filename.
  ENDIF.

ENDFORM.                    " GRABA_ANLP
*&---------------------------------------------------------------------*
*&      Form  LEE_DIRECTORIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DIRECT  text
*      <--P_ARCHIVO  text
*----------------------------------------------------------------------*
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
