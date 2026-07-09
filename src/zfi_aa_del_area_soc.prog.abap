*&---------------------------------------------------------------------*
*& Report  ZFI_AA_DEL_AREA_SOC
*&---------------------------------------------------------------------*
*& Autor : Julio Sosa
*& Empresa : Visionone
*& Transacción : ZFI_AA_DEL_AREA
*& Fecha : 31.03.2014
*& Descripcion: Este programa permite borrar un area de Valoracion
*&              de los activos de una sociedad.
*&              Previamente esa sociedad debe quedar desactivada ya sea
*&              en el Plan de Valoracion o en la creacion de los datos
*&              maestros (este es el caso de CSC)
*&---------------------------------------------------------------------*
*& Historial de Modificaciones :
*&
*& Autor :
*& Empresa :
*& Fecha :
*& Descripcion:
*&---------------------------------------------------------------------*

REPORT  ZFI_AA_DEL_AREA_SOC.

Tables : ANLB , ANLC, ANEP,
         ANEA, ANLP, ANLBZW,
         T001, ANLA.

SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE text-000.
SELECT-OPTIONS: S_BUKRS FOR T001-BUKRS OBLIGATORY.
PARAMETERS: P_AFABER LIKE T093-AFABER DEFAULT '20' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bl0.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: S_ANLN1 FOR ANLA-ANLN1,
                S_ANLN2 FOR ANLA-ANLN2.
SELECTION-SCREEN END OF BLOCK bl1.

PARAMETERS: xtest as checkbox default 'X'.


START-OF-SELECTION.

  if xtest is initial.
*Mod ini
    DELETE FROM ANEA CLIENT SPECIFIED
             WHERE MANDT = SY-MANDT   AND
                   BUKRS IN S_BUKRS   AND
                   ANLN1 IN S_ANLN1   AND
                   ANLN2 IN S_ANLN2   AND
                   AFABE = P_AFABER.
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANEA'.
    ENDIF.
*
    DELETE FROM ANEP CLIENT SPECIFIED
           WHERE   MANDT = SY-MANDT   AND
                   BUKRS IN S_BUKRS   AND
                   ANLN1 IN S_ANLN1   AND
                   ANLN2 IN S_ANLN2   AND
                   AFABE = P_AFABER.
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANEP'.
    endif.
*
    DELETE FROM ANLC CLIENT SPECIFIED
           WHERE MANDT = SY-MANDT   AND
                 BUKRS IN S_BUKRS   AND
                 ANLN1 IN S_ANLN1   AND
                 ANLN2 IN S_ANLN2   AND
                 AFABE = P_AFABER.
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANLC'.
    endif.
*
    DELETE FROM ANLB CLIENT SPECIFIED
           WHERE MANDT = SY-MANDT   AND
                 BUKRS IN S_BUKRS   AND
                 ANLN1 IN S_ANLN1   AND
                 ANLN2 IN S_ANLN2   AND
                 AFABE = P_AFABER.
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANLB'.
    endif.
*
    DELETE FROM ANLP CLIENT SPECIFIED
           WHERE  MANDT = SY-MANDT   AND
                  BUKRS IN S_BUKRS   AND
                  ANLN1 IN S_ANLN1   AND
                  ANLN2 IN S_ANLN2   AND
                  AFABER = P_AFABER.
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANLP'.
    endif.
*
    DELETE FROM ANLBZW CLIENT SPECIFIED
           WHERE MANDT = SY-MANDT   AND
                 BUKRS IN S_BUKRS   AND
                 ANLN1 IN S_ANLN1   AND
                 ANLN2 IN S_ANLN2   AND
                 AFABE = P_AFABER.
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANLBZW'.
    endif.
*Mod Fin
  endif.

  if xtest is initial.
    write:/'PROCESO DE BORRADO FINALIZADO'.
  else.
    write:/'PROCESO FINALIZADO SIN BORRADO'.
  ENDIF.
