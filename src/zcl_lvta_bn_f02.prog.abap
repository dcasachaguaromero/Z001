*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZCL_LVTA_BN_F02
*&---------------------------------------------------------------------*
*  Textos de documentos, para cuando el apunte no tenga texto propio
DATA:
     BEGIN OF XT003T OCCURS 20,
         BLART LIKE BKPF-BLART,
         LTEXT LIKE T003T-LTEXT,
     END OF XT003T.


*---------------------------------------------------------------------*
*       FORM GET_BLART_TXT                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM GET_BLART_TXT.

*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES04 ECDK917080 *
*SELECT * FROM T003T WHERE SPRAS = 'S'. "Ver si es variable sistema
SELECT * FROM T003T WHERE SPRAS = 'S' ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES04 ECDK917080 *
    MOVE-CORRESPONDING T003T TO XT003T.
    APPEND XT003T.
  ENDSELECT.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM SRC_BLART_TXT                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_BLART                                                       *
*  -->  P_LTEXT                                                       *
*---------------------------------------------------------------------*
FORM SRC_BLART_TXT USING P_BLART CHANGING P_LTEXT.

  CLEAR P_LTEXT.
  LOOP AT XT003T WHERE BLART = P_BLART.
      MOVE XT003T-LTEXT TO P_LTEXT.
 ENDLOOP.

ENDFORM.
