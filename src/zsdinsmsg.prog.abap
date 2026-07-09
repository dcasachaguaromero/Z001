*&---------------------------------------------------------------------*
*& Report  ZSDREPMSG
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZSDINSMSG.

DATA CTUMODE TYPE C LENGTH 1.
DATA BDCDATA LIKE BDCDATA OCCURS 0 WITH HEADER LINE.
DATA MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.

PARAMETERS P_VBELN LIKE VBRK-VBELN.

START-OF-SELECTION.
*
  CLEAR CTUMODE.
*
  FREE: MESSTAB, BDCDATA.
  PERFORM BDC_DYNPRO USING 'SAPMV60A'   '0101'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VBRK-VBELN'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '/00'.
  PERFORM BDC_FIELD  USING 'VBRK-VBELN' P_VBELN.
*
  PERFORM BDC_DYNPRO USING 'SAPMV60A'   '0104'.
  PERFORM BDC_FIELD  USING 'BDC_CURSOR' 'VBRK-FKART'.
  PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=SICH'.
*
  CTUMODE = 'N'.
  CALL TRANSACTION 'VF02' USING BDCDATA MODE CTUMODE UPDATE 'S'
        MESSAGES INTO MESSTAB.


*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FNAM       text
*      -->FVAL       text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.

  CLEAR BDCDATA.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  APPEND BDCDATA.

ENDFORM.                    " BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.

  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.

ENDFORM.                    " BDC_DYNPRO
