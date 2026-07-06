*&---------------------------------------------------------------------*
*& Report  Z_BAJA_ANEP
*&
*&---------------------------------------------------------------------*
*&Respalda Tabla ANEP Original
*&
*&---------------------------------------------------------------------*

REPORT  Z_BAJA_ANEP.

tables ANEP.

DATA : BEGIN OF SALIDA OCCURS 20,
         LINEA(7000),
       END OF SALIDA.

SELECTION-SCREEN skip 1.
SELECTION-SCREEN BEGIN OF BLOCK rad1 WITH FRAME.
select-options : s_bukrs  for ANEP-bukrs no intervals no-extension
                              obligatory ,
                 s_ANLN1  for ANEP-ANLN1,
                 s_ANLN2  for ANEP-ANLN2,
                 s_GJAHR  for ANEP-GJAHR obligatory,
                 s_AFABE for ANEP-AFABE OBLIGATORY.

SELECTION-SCREEN END OF BLOCK rad1.
SELECTION-SCREEN skip 1.
SELECTION-SCREEN BEGIN OF BLOCK rad2 WITH FRAME.
PARAMETERS: direct(128) LOWER CASE obligatory default
           '/usr/sap/DE9/DVEBMGS09/work/'.
PARAMETERS: ARCHIVO(128) LOWER CASE obligatory default
           'ANEP.TXT'.

*PARAMETERS :fil_nam3 like rlgrap-filename obligatory
*            default 'C:/Ventisqueros/'.

SELECTION-SCREEN END OF BLOCK rad2.

*at selection-screen on value-request for fil_nam3.
*  perform value_req_file(Z_BAJADA_DOCUMENTOS) using fil_nam3.

at selection-screen on VALUE-REQUEST for archivo.
  PERFORM lee_directorio(Z_BAJA_ANLP) USING DIRECT
                                          CHANGING ARCHIVO.

start-of-selection.

  perform graba_ANEP.

*&---------------------------------------------------------------------*
*&      Form  GRABA_ANEP
*&---------------------------------------------------------------------*
FORM GRABA_ANEP .
  data : t_ANEP         like ANEP occurs 0 with header line,
         e_ANEP         type ANEP,
         filename       type string,
         txt_line       type string,
         valor(40)      type c.

  FIELD-SYMBOLS: <wa>   TYPE ANY,
                 <comp> TYPE ANY.

  ASSIGN e_ANEP TO <wa>.

  select * into table t_ANEP
       from ANEP where bukrs  in s_bukrs  and
                       GJAHR  in s_GJAHR  and
                       ANLN1  in s_ANLN1  and
                       ANLN2  in s_ANLN2  and
                       AFABE in s_AFABE.
*
  concatenate direct archivo into filename.
  CLOSE DATASET filename.

  OPEN DATASET filename FOR OUTPUT IN text MODE encoding default.
  IF sy-subrc EQ 0.

    loop at t_ANEP into e_ANEP.
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
    MESSAGE s897(sd) WITH 'Datos tabla ANEP grabados en:'
                           filename.
  else.
    MESSAGE s897(sd) WITH 'ERROR al abrir archivo de salida'
                           filename.
  ENDIF.

ENDFORM.                    " GRABA_ANEP
*
