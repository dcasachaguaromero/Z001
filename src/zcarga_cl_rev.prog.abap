*&---------------------------------------------------------------------*
*& Report  ZCARGA_CL_REV
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZCARGA_CL_REV.

tables: ANLA , ANLB.

SELECTION-SCREEN skip 1.
SELECTION-SCREEN BEGIN OF BLOCK rad1 WITH FRAME.
select-options : s_bukrs  for ANLB-bukrs OBLIGATORY DEFAULT 'CL01' TO 'CL72',
                 s_ANLN1  for ANLB-ANLN1,
                 s_ANLN2  for ANLB-ANLN2,
                 s_AFABE  for ANLB-AFABE OBLIGATORY DEFAULT '30' TO '50'.

SELECTION-SCREEN END OF BLOCK rad1.
SELECTION-SCREEN skip 1.
SELECTION-SCREEN BEGIN OF BLOCK rad2 WITH FRAME.
PARAMETERS : P_TEST AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK rad2.


DATA: MAX_AFBLPE TYPE ANLC-AFBLPE,
      MAX_AFBANZ TYPE ANLC-AFBANZ,
      VEZ(07) TYPE C,
      REGMOD(10) TYPE C.

DATA: XANLA LIKE TABLE OF ANLA WITH HEADER LINE.
DATA: XANLB LIKE TABLE OF ANLB WITH HEADER LINE.

start-of-selection.
  PERFORM BUSCA_ANLA.
  IF NOT XANLA[] IS INITIAL.
  PERFORM BUSCA_ANLB.
  PERFORM AJUSTA_ANLB.
   ELSE.
    WRITE:/ 'NO EXISTEN DATOS ADECUADOS'.
  ENDIF.
  WRITE:/ REGMOD, 'REGISTROS ANLB MODIFICADOS'.
  WRITE:/ 'FIN DE PROCESO'.

*&---------------------------------------------------------------------*
*&      Form  BUSCA_ANLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUSCA_ANLA .
* SOLO ACTIVOS VIGENTES.
  select * FROM ANLA INTO TABLE XANLA
               WHERE BUKRS IN S_BUKRS
               AND   ANLN1 IN S_ANLN1
               AND   ANLN2 IN S_ANLN2
               AND   DEAKT EQ  '00000000'.
*
ENDFORM.                    " BUSCA_ANLA
*
*&---------------------------------------------------------------------*
*&      Form  BUSCA_ANLB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUSCA_ANLB .
**MOD INI
  if XANLA IS NOT INITIAL.
   SELECT * INTO TABLE XANLB FROM ANLB
            FOR ALL ENTRIES IN XANLA
                 WHERE BUKRS = XANLA-BUKRS
                 AND   ANLN1 = XANLA-ANLN1
                 AND   ANLN2 = XANLA-ANLN2
                 AND   AFABE IN S_AFABE.
   ENDIF.
**MOD FIN
ENDFORM.                    " BUSCA_ANLC
*
*&---------------------------------------------------------------------*
*&      Form  AJUSTA_ANLB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM AJUSTA_ANLB .
*
  LOOP AT XANLB.
    MOVE-CORRESPONDING XANLB TO ANLB.
    CHECK P_TEST IS INITIAL.
    MOVE '0000' TO ANLB-J_1AARVKEY.
    MODIFY ANLB.
    VEZ = VEZ + 1.
    IF VEZ > 10000.
      COMMIT WORK AND WAIT.
      REGMOD = REGMOD + VEZ.
      CLEAR VEZ.
    ENDIF.
  ENDLOOP.
  REGMOD = REGMOD + VEZ.
ENDFORM.                    " AJUSTA_ANLC
