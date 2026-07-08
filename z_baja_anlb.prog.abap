*&---------------------------------------------------------------------*
*& Report  Z_BAJA_ANLB
*&
*&---------------------------------------------------------------------*
*&Respalda Tabla ANLB Original
*&
*&---------------------------------------------------------------------*

REPORT  Z_BAJA_ANLB.

tables ANLB.

DATA : BEGIN OF SALIDA OCCURS 20,
         LINEA(7000),
       END OF SALIDA.

SELECTION-SCREEN skip 1.
SELECTION-SCREEN BEGIN OF BLOCK rad1 WITH FRAME.
select-options : s_bukrs  for ANLB-bukrs no intervals no-extension
                              obligatory ,
                 s_ANLN1  for ANLB-ANLN1,
                 s_ANLN2  for ANLB-ANLN2,
                 s_AFABE for ANLB-AFABE OBLIGATORY.

SELECTION-SCREEN END OF BLOCK rad1.
SELECTION-SCREEN skip 1.
SELECTION-SCREEN BEGIN OF BLOCK rad2 WITH FRAME.
PARAMETERS: direct(128) LOWER CASE obligatory default
           '/usr/sap/DE9/DVEBMGS09/work/'.
PARAMETERS: ARCHIVO(128) LOWER CASE obligatory default
           'ANLB.TXT'.

*PARAMETERS :fil_nam3 like rlgrap-filename obligatory
*            default 'C:/Ventisqueros/'.


SELECTION-SCREEN END OF BLOCK rad2.

*at selection-screen on value-request for fil_nam3.
*  perform value_req_file(Z_BAJADA_DOCUMENTOS) using fil_nam3.


at selection-screen on VALUE-REQUEST for archivo.
  PERFORM lee_directorio(Z_BAJA_ANLP) USING DIRECT
                                          CHANGING ARCHIVO.

start-of-selection.

  perform graba_ANLB.

*&---------------------------------------------------------------------*
*&      Form  GRABA_ANLB
*&---------------------------------------------------------------------*
FORM GRABA_ANLB .
  data : t_ANLB         like ANLB occurs 0 with header line,
         t_ANLB50       like ANLB occurs 0 with header line,
         e_ANLB         type ANLB,
         filename       type string,
         txt_line       type string,
         valor(40)      type c.

  FIELD-SYMBOLS: <wa>   TYPE ANY,
                 <comp> TYPE ANY.

  ASSIGN e_ANLB TO <wa>.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into table t_ANLB
*       from ANLB where bukrs  in s_bukrs  and
*                       ANLN1  in s_ANLN1  and
*                       ANLN2  in s_ANLN2  and
*                       AFABE in s_AFABE.
*
* NEW CODE
  SELECT *
 into table t_ANLB
       from ANLB where bukrs  in s_bukrs  and
                       ANLN1  in s_ANLN1  and
                       ANLN2  in s_ANLN2  and
                       AFABE in s_AFABE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  concatenate direct archivo into filename.
  CLOSE DATASET filename.

  OPEN DATASET filename FOR OUTPUT IN text MODE encoding default.
  IF sy-subrc EQ 0.

  loop at t_ANLB into e_ANLB.
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
  MESSAGE s897(sd) WITH 'Datos tabla ANLB grabados en:'
                         filename.
  else.
    MESSAGE s897(sd) WITH 'ERROR al abrir archivo de salida'
                           filename.
  ENDIF.

ENDFORM.                    " GRABA_ANLB
*
