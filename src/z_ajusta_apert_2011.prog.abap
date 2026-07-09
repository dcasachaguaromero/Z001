*&---------------------------------------------------------------------*
*& Report  Z_AJUSTA_APERT_2011
*&
*&---------------------------------------------------------------------*
*&Ajusta Tabla ANLC Original
*&
*&---------------------------------------------------------------------*

REPORT  Z_AJUSTA_APERT_2011.

tables ANLC.

SELECTION-SCREEN skip 1.
SELECTION-SCREEN BEGIN OF BLOCK rad1 WITH FRAME.
select-options : s_bukrs  for ANLC-bukrs no intervals no-extension
                              obligatory,
                 s_ANLN1  for ANLC-ANLN1,
                 s_ANLN2  for ANLC-ANLN2,
                 s_GJAHR  for ANLC-GJAHR no intervals no-extension
                              obligatory DEFAULT '2011',
                 s_AFABE for ANLC-AFABE OBLIGATORY DEFAULT '20'.

SELECTION-SCREEN END OF BLOCK rad1.
SELECTION-SCREEN skip 1.
SELECTION-SCREEN BEGIN OF BLOCK rad2 WITH FRAME.
PARAMETERS : P_TEST AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK rad2.


DATA: MAX_AFBLPE TYPE ANLC-AFBLPE,
      MAX_AFBANZ TYPE ANLC-AFBANZ,
      VEZ(07) TYPE C,
      W_KANSW LIKE ANLC-KANSW,
      W_KNAFA LIKE ANLC-KNAFA.

DATA: XANLC LIKE TABLE OF ANLC WITH HEADER LINE.


start-of-selection.
  PERFORM BUSCA_ANLC.
  PERFORM AJUSTA_ANLC.
  WRITE:/ 'PROCESO FINALIZADO'.


*&---------------------------------------------------------------------*
*&      Form  BUSCA_ANLC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUSCA_ANLC .
*
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * FROM ANLC INTO TABLE XANLC
*               WHERE BUKRS IN S_BUKRS
*               AND   ANLN1 IN S_ANLN1
*               AND   ANLN2 IN S_ANLN2
*               AND   GJAHR IN S_GJAHR
*               AND   AFABE IN S_AFABE.
*
* NEW CODE
  SELECT *
 FROM ANLC INTO TABLE XANLC
               WHERE BUKRS IN S_BUKRS
               AND   ANLN1 IN S_ANLN1
               AND   ANLN2 IN S_ANLN2
               AND   GJAHR IN S_GJAHR
               AND   AFABE IN S_AFABE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*
ENDFORM.                    " BUSCA_ANLC
*&---------------------------------------------------------------------*
*&      Form  AJUSTA_ANLC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM AJUSTA_ANLC .
*
  LOOP AT XANLC.
    W_KANSW = XANLC-KANSW + XANLC-KAUFW.
    W_KNAFA = XANLC-KNAFA + XANLC-KAUFN.
    MOVE W_KANSW TO XANLC-KANSW.
    MOVE W_KNAFA TO XANLC-KNAFA.
    CLEAR: XANLC-KAUFW , XANLC-KAUFN.
    MODIFY XANLC INDEX SY-TABIX.
  ENDLOOP.
*
  IF P_TEST IS INITIAL.
    WRITE:/ 'AJUSTE REALIZADO'.
    LOOP AT XANLC.
      MOVE-CORRESPONDING XANLC TO ANLC.
      MODIFY ANLC.
      VEZ = VEZ + 1.
      IF VEZ > 10000.
        COMMIT WORK AND WAIT.
        WRITE:/ VEZ.
        CLEAR VEZ.
      ENDIF.
    ENDLOOP.
  ELSE.
    WRITE:/ 'SIN AJUSTE'.
  ENDIF.
*
ENDFORM.                    " AJUSTA_ANLC
