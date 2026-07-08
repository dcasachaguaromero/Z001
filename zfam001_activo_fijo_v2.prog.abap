*&---------------------------------------------------------------------*
*& Report  ZFAM001_ACTIVO_FIJO_V2
*&
*&---------------------------------------------------------------------*
*& Consultor: Luis Bernal - E2E Consultores Ltda. - www.e2e.cl
*& Creacion : 14.09.2011
************************************************************************
** Modificaciones:
**----------------
** LBERNAL    10-01-2012  -Funcionalidad MultiMoneda.
**
*&---------------------------------------------------------------------*

REPORT  ZFAM001_ACTIVO_FIJO_V2
  NO STANDARD PAGE HEADING
    MESSAGE-ID ZFI.

INCLUDE ZFAM001_ACTIVO_FIJO_TOP_V2.

*********** PARAMETROS ************************************************
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
PARAMETERS: p_bukrs    LIKE anlp-bukrs   OBLIGATORY MEMORY ID BUK,
            p_gjahr    LIKE anlc-gjahr   OBLIGATORY DEFAULT sy-datum+0(4),
            p_peraf(2) TYPE n            OBLIGATORY,
            P_AFABE    LIKE T093T-AFABER OBLIGATORY DEFAULT '01'.

SELECT-OPTIONS: S_ANLKL FOR anla-ANLKL NO INTERVALS,
                S_KOSTL FOR anlz-KOSTL NO INTERVALS,
                S_ANLN1 FOR anla-ANLN1 NO INTERVALS,
                S_ANLN2 FOR anla-ANLN2 NO INTERVALS.


PARAMETERS:
  p_deta    TYPE fot_no_send   RADIOBUTTON GROUP radi DEFAULT 'X' ,
  p_grupo   TYPE fot_no_send   RADIOBUTTON GROUP radi.


PARAMETERS: p_ktopl    LIKE t095-ktopl DEFAULT 'B100' NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK blk1.

* Process on value request
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_AFABE.
  PERFORM varianten_AFABE CHANGING P_AFABE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_ANLKL-LOW.
  PERFORM varianten_ANLKL CHANGING S_ANLKL-LOW.




*********** AUTORIZACIONES ************************************************
AT SELECTION-SCREEN ON p_bukrs.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e004(zfi) WITH 'Sin autorización para Sociedad.' p_bukrs.
  ENDIF.


*********** INICIALIZACION ************************************************
INITIALIZATION.
   p_gjahr = SY-DATUM+0(4).
   p_peraf = SY-DATUM+4(2) - 1.
  swF4 = 0.



***********   PROCESO     ************************************************
START-OF-SELECTION.
  PERFORM select_param.
  PERFORM select_datos.

END-OF-SELECTION.
  IF p_deta = 'X'.
     SORT TABLA BY  bukrs ANLN1 ANLN2 .
     PERFORM lista_alv.
  ELSEIF p_grupo = 'X'.
     SORT RESUMEN BY  bukrs ktansw ANLKL.
     PERFORM lista_alv_2.
  ENDIF.

INCLUDE ZFAM001_ACTIVO_FIJO_INCLUDE_V2.
