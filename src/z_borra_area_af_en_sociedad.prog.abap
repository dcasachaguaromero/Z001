*&---------------------------------------------------------------------*
*& Report  Z_BORRA_AREA_AF_EN_SOCIEDAD
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_BORRA_AREA_AF_EN_SOCIEDAD.


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

    DELETE FROM ANEA CLIENT SPECIFIED
             WHERE BUKRS IN S_BUKRS   AND
                   ANLN1 IN S_ANLN1   AND
                   ANLN2 IN S_ANLN2   AND
                   AFABE = P_AFABER.             "#EC "#EC CI_NOFIRST
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANEA'.
    ENDIF.
*
    DELETE FROM ANEP CLIENT SPECIFIED
           WHERE BUKRS IN S_BUKRS   AND
                   ANLN1 IN S_ANLN1   AND
                   ANLN2 IN S_ANLN2   AND
                   AFABE = P_AFABER.             "#EC "#EC CI_NOFIRST
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANEP'.
    endif.
*
    DELETE FROM ANLC CLIENT SPECIFIED
           WHERE BUKRS IN S_BUKRS   AND
                   ANLN1 IN S_ANLN1   AND
                   ANLN2 IN S_ANLN2   AND
                   AFABE = P_AFABER.             "#EC "#EC CI_NOFIRST
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANLC'.
    endif.
*
    DELETE FROM ANLB CLIENT SPECIFIED
           WHERE BUKRS IN S_BUKRS   AND
                   ANLN1 IN S_ANLN1   AND
                   ANLN2 IN S_ANLN2   AND
                   AFABE = P_AFABER.             "#EC "#EC CI_NOFIRST
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANLB'.
    endif.
*
    DELETE FROM ANLP CLIENT SPECIFIED
           WHERE BUKRS IN S_BUKRS   AND
                   ANLN1 IN S_ANLN1   AND
                   ANLN2 IN S_ANLN2   AND
                   AFABER = P_AFABER.            "#EC "#EC CI_NOFIRST
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANLP'.
    endif.
*
    DELETE FROM ANLBZW CLIENT SPECIFIED
           WHERE
**INS INI
                   MANDT = SY-MANDT AND
**INS FIN
                   BUKRS IN S_BUKRS AND
                   ANLN1 IN S_ANLN1 AND
                   ANLN2 IN S_ANLN2 AND
                   AFABE = P_AFABER.             "#EC "#EC CI_NOFIRST
    if sy-subrc ne 0 AND sy-DBCNT ne 0.
      write:/ 'ERROR EN BORRADO TABLA ANLBZW'.
    endif.
*
  endif.

  if xtest is initial.
    write:/'PROCESO DE BORRADO FINALIZADO'.
  else.
    write:/'PROCESO FINALIZADO SIN BORRADO'.
  ENDIF.
